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

## Build Generate Button Phases

Build Generate button timing was measured separately because the button path includes UI context preparation, graph snapshot creation, graph execution, result promotion, document preparation, and viewport apply.

Measurement command:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tools/profile_build_generate_phases.gd -- --run-id=manual-size130-second-final-20260628 --side=130
```

Artifacts:

```text
.godot_user/perf/build-generate/manual-size130-second-final-20260628/build_generate_phase_profile.json
.godot_user/perf/build-generate/manual-size130-second-final-20260628/build_generate_phase_profile.md
```

| case | pass | total ms | popup present | context | graph prepare | graph run | promote | cached skip | viewport document prepare | viewport apply |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `build_generate_side130_adjacency_result` | `first` | 2557.512 | 0.452 | 5.568 | 0.057 | 1834.447 | 246.255 | 0.000 | 0.013 | 421.877 |
| `build_generate_side130_adjacency_result` | `second_after_popup_hide` | 36.373 | 4.847 | 2.853 | 4.300 | 3.759 | 0.000 | 0.022 | 0.000 | 0.000 |

Size 130 second Generate before the cached-preview repair:

| run | total ms | popup present | context | graph run | promote | viewport tiles | viewport document prepare | viewport apply |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| before preview repair | 2522.307 | 5.848 | 2.041 | 3.800 | 562.913 | 537.895 | 662.329 | 693.432 |
| after tile/direct-map repair, before cached skip | 1311.922 | 4.582 | 2.755 | 3.709 | 545.318 | 0.003 | 0.013 | 698.506 |
| after cached skip | 36.373 | 4.847 | 2.853 | 3.759 | 0.000 | 0.000 | 0.000 | 0.000 |

Size 130 second Generate with forced recompute after the viewport redraw repair:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tools/profile_build_generate_phases.gd -- --run-id=manual-size130-essential-flat-top-guard-20260628 --side=130 --force-second-recompute
```

| run | total ms | popup present | context | graph run | promote | viewport document prepare | viewport apply |
|---|---:|---:|---:|---:|---:|---:|---:|
| first | 2646.181 | 0.838 | 10.506 | 1842.291 | 270.532 | 0.041 | 451.245 |
| second forced recompute | 2327.817 | 5.004 | 1.837 | 1597.592 | 247.528 | 0.013 | 430.124 |

Implications:

- `context_prepare` and `graph_prepare` are not heavy in the measured cases, but the popup must appear before them so the user gets immediate feedback.
- second Generate after the previous popup is hidden presents the popup in single-digit milliseconds in headless timing.
- For size 130, popup presentation is not the measured bottleneck; the popup appears in single-digit milliseconds.
- The repeated-run viewport slowdown was caused by redundant `flat_top` setter redraws. Assigning the same orientation redrew the previous large viewport during promote/apply before the new result was applied.
- Guarding same-value `flat_top` assignments brings forced-recompute second Generate promote/apply back to the first-run range.
- If the graph run recomputes no nodes and the previous generated preview is still pending and visible, Build skips result promotion and viewport apply because the cached output is already shown.
- Build preview apply avoids redundant display tile redraw/reconfiguration and uses the selected viewport terrain map directly instead of duplicating the full Level Document twice.
- cold `graph_run` is roughly half of the end-to-end button path.
- preview work is also material: result promotion, document apply preparation, and viewport apply together are close to the cold graph runtime for the side 81 adjacency result case, and dominate the second cached run.
- Build progress should therefore allocate visible progress range to post-graph preview work, not compress it into the final few percent.
- Workspace Generate defers non-required context snapshots and context-panel refresh during the pre-run path so repeated Generate does not spend time producing debug/UI snapshots before graph execution.

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

Build Generate popup phase ranges after button-path measurement:

| phase | popup range |
|---|---:|
| context / graph preparation | `0.00` to `0.01` |
| graph execution | `0.01` to `0.54` |
| result promotion | `0.56` to `0.64` |
| viewport document preparation | `0.64` to `0.84` |
| viewport tile apply | `0.84` to `0.99` |

## Follow-Up Tasks

Recommended scheduled slices:

1. `GRAPH-PROGRESS-02B`: implement `estimated_work_for_node(node, inputs, context)` using the measured policy above.
2. `GRAPH-PROGRESS-02C`: map core progress into weighted graph progress in `HexGenerationGraphRunner`.
3. `GRAPH-PROGRESS-03`: expose promote / viewport apply phases in the progress popup.
4. `GRAPH-PERF-ADJ-02`: optional constant/reference-full fast path for adjacency rules, after weighted progress is wired.
