# Graph Progress Timing Profile 2026-06-28

Task context: Build Graph progress popup / weighted progress planning

## Summary

The latest `HexTileMapLayer` visual apply optimization is effective. `apply_map()` is no longer the dominant measured cost for the profiled graph generation path.

The dominant cost is now adjacency-rule item generation, followed by sparse/dense connectivity, Markov mesh wall generation, and multi-layer document apply. Weighted graph progress should therefore not be node-count based and should not over-focus on visual apply alone.

Measurement command:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tools/profile_graph_progress_weights.gd -- --run-id=manual-graph-progress-final-20260628
```

Artifacts:

```text
.godot_user/perf/graph-progress/manual-graph-progress-final-20260628/graph_progress_profile.json
.godot_user/perf/graph-progress/manual-graph-progress-final-20260628/graph_progress_profile.md
```

Environment:

- Godot `4.6.2.stable`
- Headless run from project root
- Current baseline commit before this slice: `7dc8963 Generateの表示部分O(n^2)をO(n)に改善`

## Measured Results

| case | median ms | interpretation |
|---|---:|---|
| `item_adjacency_side_81_r2` | 9876.933 | Dominant cost. Must drive progress weight and probably deserves a separate optimization task. |
| `item_adjacency_side_40_r3_generated_ref` | 4487.623 | Neighbor radius dominates. Generated reference does not change the weight class as much as neighbor area. |
| `item_adjacency_side_40_r1` | 876.013 | Even radius 1 is heavier than Markov radius 40. |
| `connect_sparse_side_81_p45` | 764.342 | Second-tier heavy node. |
| `connect_dense_side_81_p45` | 490.663 | Similar class to Markov radius 40 and document apply. |
| `apply_document_terrain_3_overlays_side_81` | 474.695 | Still visible and must be reported as an apply phase. |
| `wall_markov_radius_40_p35` | 418.539 | Important, but not the top cost after adjacency enters the graph. |
| `apply_map_side_81` | 193.146 | Much improved, still above visible-progress threshold. |
| `apply_map_side_75` | 155.050 | Much improved from the prior PERF-60 profile. |
| `connect_terminal_side_81_p45` | 151.721 | Moderate. |
| `wall_markov_radius_20_p35` | 105.838 | Moderate. |
| `shape_hexagon_radius_40` | 86.121 | More expensive than rectangle shape, but not a primary blocker. |
| `apply_map_side_50` | 67.625 | Visible but no longer severe. |
| `compose_overlay_side_81` | 36.168 | Was a hotspot before this slice; now moderate after bulk merge. |
| `filter_distance_side_81` | 38.160 | Light/moderate. |
| `wall_random_side_81_p35` | 21.231 | Light. |
| `result_terrain_3_overlays_side_81` | 17.339 | Light. |
| `item_random_side_40` | 8.777 | Was a hotspot before this slice; now light after bulk placement. |
| `item_limited_side_40` | 4.877 | Light. |

## Visual Apply Comparison

Compared with the 2026-06-08 PERF-60 carried-forward measurements, current `HexTileMapLayer.apply_map()` is substantially faster:

| cells | previous `apply_map` | current `apply_map` | result |
|---:|---:|---:|---|
| 625 | 101.670 ms | 17.337 ms | ~5.9x faster |
| 2,500 | 1,465.139 ms | 67.625 ms | ~21.7x faster |
| 5,625 | 7,054.401 ms | 155.050 ms | ~45.5x faster |

This validates the recent O(n²) to O(n) visual apply work for the measured cases.

## Repairs Applied During Profiling

The first profile showed two non-visual O(n²)-style hotspots:

- random item generation used repeated per-cell `add_item_cell()`.
- overlay compose used repeated per-cell merge writes.

This slice changes item generation to accumulate placements by item key and applies them in bulk, and changes overlay merge to bulk-add each item key. After that:

- `item_random_side_40`: ~1378 ms -> ~8.8 ms
- `compose_overlay_side_81`: ~8787 ms -> ~36 ms

Adjacency-rule item generation remains heavy because neighborhood/component statistics dominate, not item insertion.

## Weight Policy

Adopt an estimated-work model, not equal node count.

Suggested initial estimator:

| node / mode | estimated work |
|---|---|
| shape rectangle / square | `cells * 0.004` |
| shape hexagon | `cells * 0.018` |
| wall random | `cells * 0.003` |
| wall Markov mesh | `canvas_cells * 0.064` |
| connectivity dense | `cells * 0.075` |
| connectivity sparse | `cells * 0.115` |
| connectivity terminal | `cells * 0.023` |
| item weighted / random | `scope_cells * 0.006` |
| item limited | `scope_cells * 0.004` |
| item adjacency_rules | `scope_cells * neighbor_area * 0.085` |
| filter simple | `input_cells * 0.002` |
| filter distance | `input_cells * 0.006` |
| compose overlay merge | `input_cells * 0.006` |
| result bundle | `terrain_cells * 0.002 + overlay_count * 2` |
| visual apply map | `cells * 0.028` |
| document apply terrain + overlays | `cells * 0.070` for multi-overlay preview |

Notes:

- `neighbor_area` should be the L1 disc area excluding center after toric wrapping, approximately `3r(r+1)` for radius `r`.
- These are relative work units derived from this machine's headless timings. They should drive progress proportions, not be displayed as time predictions.
- Unknown modes should use conservative fallback work and still show a textual phase, without exposing raw fallback language in UI.

## Progress UX Implication

Priority order for weighted progress:

1. `Item Generator / adjacency_rules`
2. `Connectivity / sparse|dense`
3. `Wall Field / markov_mesh`
4. `Promote / viewport apply`
5. `Shape / hexagon`
6. `Filter / compose / result`
7. random wall/item modes

The popup should show current node, node mode, core phase, and layer/apply phase. For adjacency item generation, node-local progress is especially important because one node can dominate the whole run.

## Follow-Up Tasks

Recommended scheduled slices:

1. `GRAPH-PROGRESS-02B`: implement `estimated_work_for_node(node, inputs, context)` using the measured policy above.
2. `GRAPH-PROGRESS-02C`: map core progress into weighted graph progress in `HexGenerationGraphRunner`.
3. `GRAPH-PROGRESS-03`: expose promote / viewport apply phases in the progress popup.
4. `GRAPH-PERF-ADJ-01`: optimize adjacency item stats. Start by replacing per-cell neighborhood allocation/component traversal with reusable radius offsets and single-pass local component calculation.
