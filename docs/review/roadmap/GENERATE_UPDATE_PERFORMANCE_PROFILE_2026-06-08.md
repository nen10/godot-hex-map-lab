# Generate / Global Update Performance Profile 2026-06-08

Task: `PERF-60_GENERATE_GLOBAL_UPDATE_PROFILE`

## Summary

The heaviest visible freezes are not the core generation loop. `HexMapGenDock._generate_map()` runs generation in a `Thread`, but then validation and target apply run synchronously after `generation_finished`.

The largest measured cost is applying generated/document data to a ready `HexTileMapLayer`. The cost comes from full resource conversion, full tile-map clear/rewrite, loop display refresh, and layer-stack fan-out. Validation is much cheaper for the measured sizes, and direct `HexMapTileAdapter.apply_to_tile_map_layer()` is cheaper than the full `HexTileMapLayer` path.

## Measurement

Environment:

- Godot `4.6.2.stable`
- Headless run from project root
- Temporary script: `/private/tmp/perf60_profile.gd`
- Data: rectangle maps, wall probability `0.35`, seed `60608`, dense connectivity
- Nodes awaited one process frame before `HexTileMapLayer` apply timings

| Size | Cells | Generation dense | Validation | Direct TileMap apply | HexTileMapLayer apply_map | Layer stack apply_document | Single cell document update |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 25 | 625 | 47.799 ms | 7.936 ms | 5.219 ms | 101.670 ms | 317.502 ms | 92.392 ms |
| 50 | 2,500 | 189.831 ms | 30.804 ms | 21.428 ms | 1,465.139 ms | 2,881.984 ms | 1,482.419 ms |
| 75 | 5,625 | 421.017 ms | 70.124 ms | 51.648 ms | 7,054.401 ms | 16,831.399 ms | 8,295.210 ms |

## Operation Classification

| Operation | Primary cost | Freeze cause | Current progress visibility | Notes |
|---|---|---|---|---|
| Orientation change / tile settings apply | apply/redraw | Synchronous layer apply after setting orientation/tile options | None unless generation progress is already visible | `_apply_tile_settings_to_current_layer()` calls full apply for current data. |
| Map regenerate | generation + apply/redraw | Generation is threaded; post-generation validation/apply is synchronous | Generation progress exists; post-generation validation/apply is not separately visible | `_generate_map()` awaits generation, then calls validation and apply on the main/editor path. |
| Document apply | apply/redraw | `HexTileMapLayer.apply_document()` converts document to map resource, applies map, then payloads | None | Full apply pays conversion and redraw cost even when only a subset changes. |
| Layer stack apply | apply/redraw + role fan-out | `apply_document_to_layer_stack()` ensures role layers, syncs TileSets, applies terrain/overlay/object data | None | Measured as the largest path because one user action can update multiple child layers. |
| Tile redraw | redraw | `_redraw()` clears tile maps, builds sorted tile entries, writes every cell, refreshes loop display | None | Direct adapter apply is comparatively cheap; full layer path adds conversion, overrides, overlays, loop display, and queue redraw. |
| Validation run | validation | Synchronous document traversal | None | Measured under 100 ms up to 5,625 cells without heavy object/label/profile cases; still should report busy state for larger projects. |

## Source Path Notes

- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
  - `_generate_map()` starts `_generation_thread`, awaits `generation_finished`, then calls `_validate_current_generation_result()` and `_find_target_tile_map_layer_and_apply_current()`.
  - `apply_current_data_to_tile_map_layer()` routes `HexTileMapLayer` through `_apply_current_data_to_hex_tile_map_layer()`.
  - `_apply_current_data_to_hex_tile_map_layer()` configures display tiles, assigns `layer.hex_map`, and refreshes loop display.
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
  - `apply_map()` converts resource data, clears payload display, clears overlays/highlights/path, then calls `_redraw()`.
  - `_redraw()` clears terrain/overlay tile maps, iterates `HexMapTileAdapter.to_tile_entries()`, redraws overlay tiles, refreshes loop display, then queues visual redraw.
  - `apply_document_cell()` is intended as an incremental path, but `_update_tile()` calls `refresh_loop_display()`, so a single-cell update can still pay global loop display work.
- `addons/hex_map_kit/adapter/hex_map_document_validator.gd`
  - `validate_document()` traverses terrain defaults, tile entries, object entries, label entries, dependencies, and movement profile reachability.

## Priority Recommendations

1. `PERF-61`: show post-generation busy/progress steps for `Validate generated document`, `Apply to target`, `Refresh layer stack`, and `Done`. The current ProgressBar can reach Ready while the expensive apply phase is still the perceived freeze.
2. `PERF-62`: split `HexTileMapLayer.apply_map()` into conversion, full terrain redraw, overlay redraw, payload refresh, and loop display refresh so incremental paths can skip unrelated global work.
3. `PERF-62`: debounce orientation/tile settings changes. Multiple immediate `_apply_tile_settings_to_current_layer()` calls can repeat full apply/redraw while the user is still adjusting controls.
4. `PERF-62`: make `apply_document_cell()` avoid full `refresh_loop_display()` when toric loop visuals are disabled or the changed cell cannot affect loop duplicates.
5. Backlog / research: profile validation with dense object/label payloads and movement profile reachability. The baseline validation cost is not the top issue, but object/profile-heavy documents can change that ranking.

## Acceptance Result

- Heavy operations classified: PASS
- UI freeze cause attributed to redraw/generation/apply/validation: PASS
- Improvement candidates prioritized: PASS
