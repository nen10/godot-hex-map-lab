# Graph Progress Timing Profile 2026-06-28

Task context: Build Graph progress popup / weighted progress planning

## Summary

The latest `HexTileMapLayer` visual apply optimization is effective. `apply_map()` is no longer the dominant measured cost for the profiled graph generation path.

After the adjacency-rule optimization, adjacency item generation is no longer an order-of-magnitude outlier. The heavy tier is now sparse connectivity, adjacency-rule item generation, dense connectivity, multi-layer document apply, and Markov mesh wall generation. Weighted graph progress should therefore not be node-count based and should not over-focus on visual apply alone.

Measurement command:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tools/profile_graph_progress_weights.gd -- --run-id=manual-adjacency-final-20260628
```

Artifacts:

```text
.godot_user/perf/graph-progress/manual-adjacency-final-20260628/graph_progress_profile.json
.godot_user/perf/graph-progress/manual-adjacency-final-20260628/graph_progress_profile.md
```

Environment:

- Godot `4.6.2.stable`
- Headless run from project root
- Current baseline commit before this slice: `7dc8963 Generateの表示部分O(n^2)をO(n)に改善`

## Measured Results

| case | median ms | interpretation |
|---|---:|---|
| `connect_sparse_side_81_p45` | 738.632 | Heaviest remaining measured graph-core node. |
| `item_adjacency_side_81_r2` | 570.308 | Now comparable to connectivity instead of dominating the whole run. |
| `connect_dense_side_81_p45` | 487.008 | Similar class to document apply and Markov radius 40. |
| `apply_document_terrain_3_overlays_side_81` | 474.233 | Still visible and must be reported as an apply phase. |
| `wall_markov_radius_40_p35` | 425.726 | Important, but no longer above optimized adjacency. |
| `item_adjacency_side_40_r3_generated_ref` | 236.264 | Neighbor radius remains the main adjacency multiplier. |
| `apply_map_side_81` | 185.814 | Much improved, still above visible-progress threshold. |
| `apply_map_side_75` | 158.158 | Much improved from the prior PERF-60 profile. |
| `connect_terminal_side_81_p45` | 133.127 | Moderate. |
| `wall_markov_radius_20_p35` | 103.395 | Moderate. |
| `shape_hexagon_radius_40` | 86.418 | More expensive than rectangle shape, but not a primary blocker. |
| `apply_map_side_50` | 68.512 | Visible but no longer severe. |
| `item_adjacency_side_40_r1` | 64.466 | Optimized to the same class as medium visual apply. |
| `compose_overlay_side_81` | 37.294 | Was a hotspot before this slice; now moderate after bulk merge. |
| `filter_distance_side_81` | 24.495 | Light/moderate. |
| `wall_random_side_81_p35` | 21.327 | Light. |
| `result_terrain_3_overlays_side_81` | 17.403 | Light. |
| `item_random_side_40` | 8.004 | Was a hotspot before this slice; now light after bulk placement. |
| `item_limited_side_40` | 4.975 | Light. |

## Visual Apply Comparison

Compared with the 2026-06-08 PERF-60 carried-forward measurements, current `HexTileMapLayer.apply_map()` is substantially faster:

| cells | previous `apply_map` | current `apply_map` | result |
|---:|---:|---:|---|
| 625 | 101.670 ms | 17.123 ms | ~5.9x faster |
| 2,500 | 1,465.139 ms | 68.512 ms | ~21.4x faster |
| 5,625 | 7,054.401 ms | 158.158 ms | ~44.6x faster |

This validates the recent O(n²) to O(n) visual apply work for the measured cases.

## Repairs Applied During Profiling

The first profile showed two non-visual O(n²)-style hotspots:

- random item generation used repeated per-cell `add_item_cell()`.
- overlay compose used repeated per-cell merge writes.

This slice changes item generation to accumulate placements by item key and applies them in bulk, and changes overlay merge to bulk-add each item key. After that:

- `item_random_side_40`: ~1378 ms -> ~8.8 ms
- `compose_overlay_side_81`: ~8787 ms -> ~36 ms

Adjacency-rule item generation was then optimized separately:

- precompute reusable radius offsets and direction offsets.
- compute only the statistics required by the active probability rules: neighbor count, component count, or component-size multiset.
- represent local adjacency stats with `Vector2i` axial coordinates instead of repeated `HexVector.add()` / toric wrap / string `key()` allocation.

After that:

- `item_adjacency_side_40_r1`: ~876 ms -> ~64 ms
- `item_adjacency_side_40_r3_generated_ref`: ~4488 ms -> ~236 ms
- `item_adjacency_side_81_r2`: ~9877 ms -> ~570 ms

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
| item adjacency_rules | `scope_cells * neighbor_area * 0.006` |
| filter simple | `input_cells * 0.002` |
| filter distance | `input_cells * 0.006` |
| compose overlay merge | `input_cells * 0.006` |
| result bundle | `terrain_cells * 0.002 + overlay_count * 2` |
| visual apply map | `cells * 0.028` |
| document apply terrain + overlays | `cells * 0.070` for multi-overlay preview |

Notes:

- `neighbor_area` should be the L1 disc area excluding center after toric wrapping, approximately `3r(r+1)` for radius `r`. Add a conservative multiplier when rules use `components:*` multiset keys, because that path must keep component sizes rather than only component count.
- These are relative work units derived from this machine's headless timings. They should drive progress proportions, not be displayed as time predictions.
- Unknown modes should use conservative fallback work and still show a textual phase, without exposing raw fallback language in UI.

## Progress UX Implication

Priority order for weighted progress:

1. `Connectivity / sparse`
2. `Item Generator / adjacency_rules`
3. `Connectivity / dense`
4. `Wall Field / markov_mesh`
5. `Promote / viewport apply`
6. `Shape / hexagon`
7. `Filter / compose / result`
8. random wall/item modes

The popup should show current node, node mode, core phase, and layer/apply phase. For adjacency item generation, node-local progress is still important because neighbor radius can make one node comparable to the largest connectivity pass.

## Follow-Up Tasks

Recommended scheduled slices:

1. `GRAPH-PROGRESS-02B`: implement `estimated_work_for_node(node, inputs, context)` using the measured policy above.
2. `GRAPH-PROGRESS-02C`: map core progress into weighted graph progress in `HexGenerationGraphRunner`.
3. `GRAPH-PROGRESS-03`: expose promote / viewport apply phases in the progress popup.
4. `GRAPH-PERF-ADJ-02`: optional constant/reference-full fast path for adjacency rules, after weighted progress is wired.
