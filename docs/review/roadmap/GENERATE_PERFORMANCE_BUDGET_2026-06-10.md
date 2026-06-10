# Generate Performance Budget 2026-06-10

Task: `PERF-60_GENERATE_PERFORMANCE_BUDGET_AND_CHUNKED_APPLY_REVIEW`

## Summary

Generate responsiveness is bounded by the main-thread apply/redraw paths, not by the core generator alone.

The 2026-06-08 measured profile showed that core generation, validation, and direct `TileMapLayer` writes scale acceptably through the measured sizes, while full `HexTileMapLayer.apply_map()` and layer-stack `apply_document()` become multi-second operations by 2,500 to 5,625 cells. The current 2026-06-10 source has better progress/busy/debounce state, but the expensive apply paths are still synchronous once they begin.

Decision:

- Keep threaded generation with progress/cancel as the core generation policy.
- Keep debounce for orientation/tile setting changes, but do not treat debounce as a performance fix for one large apply.
- Require chunked visual apply before large maps are considered a smooth editor workflow.
- Keep document/resource mutation atomic; chunk the visual scene-tree apply first.

## Evidence Sources

- Prior measured profile: `docs/review/roadmap/GENERATE_UPDATE_PERFORMANCE_PROFILE_2026-06-08.md`
- Generate run path: `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
  - `_generate_map()`
  - `_create_generation_snapshot()`
  - `_generation_thread_main()`
  - `_complete_generation_from_thread()`
  - `_validate_current_generation_result()`
  - `_find_target_tile_map_layer_and_apply_current()`
  - `apply_current_generation_to_selected_document()`
  - `_schedule_tile_settings_apply()`
  - `_apply_tile_settings_to_current_layer()`
- Tile/document apply path: `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
  - `apply_map()`
  - `apply_document()`
  - `apply_document_to_layer_stack()`
  - `apply_document_cell()`
  - `refresh_loop_display()`
  - `_redraw()`
  - `_apply_document_payloads()`
- Direct adapter paths:
  - `addons/hex_map_kit/adapter/hex_map_tile_adapter.gd`
  - `addons/hex_map_kit/adapter/hex_overlay_tile_adapter.gd`
  - `addons/hex_map_kit/adapter/hex_object_layer_adapter.gd`
- Validation path: `addons/hex_map_kit/adapter/hex_map_document_validator.gd`

## Baseline Measurement Carried Forward

Environment and raw table are recorded in `GENERATE_UPDATE_PERFORMANCE_PROFILE_2026-06-08.md`.

Key measured values:

| Cells | Generation dense | Validation | Direct TileMap apply | HexTileMapLayer apply_map | Layer stack apply_document |
|---:|---:|---:|---:|---:|---:|
| 625 | 47.799 ms | 7.936 ms | 5.219 ms | 101.670 ms | 317.502 ms |
| 2,500 | 189.831 ms | 30.804 ms | 21.428 ms | 1,465.139 ms | 2,881.984 ms |
| 5,625 | 421.017 ms | 70.124 ms | 51.648 ms | 7,054.401 ms | 16,831.399 ms |

Interpretation:

- Generation core needs progress/cancel for medium+ maps, but it is not the worst freeze source.
- Validation is acceptable in the baseline, but object/label-heavy documents and movement reachability can increase it.
- Direct TileMap apply is comparatively cheap.
- Full `HexTileMapLayer` apply and layer-stack apply are over budget for normal interactive UI by 2,500 cells and are already visible at 625 cells.

## Operation Cost Classes

| Class | Current source path | Primary cost | Main-thread risk | Current state |
|---|---|---|---|---|
| Generation core | `_generate_map()` -> `_generation_thread_main()` -> `_generate_data_from_snapshot()` | Map data generation, connectivity, overlay source processing | Low after thread starts | Threaded with progress/cancel callbacks and chunk polling. |
| Result update | `_complete_generation_from_thread()` | Save history, merge overlay/current data, stats update | Medium | Main-thread update after thread completion. |
| Validation | `_validate_current_generation_result()` -> `HexMapDocumentValidator.validate_document()` | Document traversal, dependency checks, object/label traversal, optional reachability | Medium for baseline, high for payload/profile-heavy docs | Synchronous, but visible as a busy/progress step. |
| Direct TileMap preview apply | `HexMapTileAdapter.apply_to_tile_map_layer()` / `HexOverlayTileAdapter.apply_to_tile_map_layer()` | Clear layer, sort entries, `set_cell()` per tile | Medium | Synchronous, no mid-apply cancel. |
| `HexTileMapLayer` preview apply | `_apply_current_data_to_hex_tile_map_layer()` -> `layer.hex_map = ...` -> `apply_map()` -> `_redraw()` | Resource conversion, payload clear, terrain redraw, overlay redraw, loop redraw | High | Synchronous, busy/progress can show before apply only. |
| Selected document apply | `apply_current_generation_to_selected_document()` -> `copy_document_state()` -> `selected_layer.apply_document()` | Document copy, metadata, full layer apply, payload redraw | High | Synchronous, no mid-apply cancel. |
| Layer stack apply | `HexTileMapLayer.apply_document_to_layer_stack()` | Role layer ensure/sync, terrain/overlay/object fan-out | Very high | Synchronous. |
| Global display update | orientation/tile size/catalog/loop display changes -> `_apply_tile_settings_to_current_layer()` / `refresh_loop_display()` | Full apply/redraw or loop duplicate writes | High | Debounced and visible as queued/applying tile settings. |

## Map-Size Budget

These are editor interaction budgets, not claims that current code meets every target.

| Size class | Cells | Generation budget | Validation budget | Visual apply budget | Required UI policy |
|---|---:|---:|---:|---:|---|
| Tiny | `<= 256` | `< 50 ms` | `< 25 ms` | `< 50 ms` for full layer apply | Inline updates allowed. Status may remain lightweight. |
| Small | `257-625` | `< 100 ms` | `< 50 ms` | `< 100 ms` full layer, `< 250 ms` layer stack | Show busy/progress when full `HexTileMapLayer` or layer-stack apply is used. |
| Medium | `626-2,500` | `< 250 ms` | `< 100 ms` | `< 150 ms` target; current full apply exceeds this | Progress/busy must be visible before validation/apply. Chunking is required for full layer smoothness. |
| Large | `2,501-10,000` | `< 750 ms` with progress/cancel | `< 250 ms` or deferred/progress | Chunked apply required; single pass is not acceptable UX | Generation cancel required. Apply should yield between chunks and report progress. |
| Extra large | `> 10,000` | Cancellable and chunk/progress based | Deferred/chunked validation required | Chunked or streamed apply required | No broad main-thread full redraw may be treated as normal interaction. |

Budget thresholds:

- `> 50 ms`: operation should have a visible status if user-triggered.
- `> 100 ms`: operation should show progress/busy before it starts.
- `> 150 ms`: visual apply should be chunked or explicitly treated as non-smooth backlog.
- `> 750 ms`: cancellation or interruption between chunks is required where state consistency allows it.

## Global Update Classification

| Trigger | Classification | Current handling | Budget decision |
|---|---|---|---|
| Orientation switch | Global display update | `_schedule_tile_settings_apply("orientation")` debounces then applies current data. | Debounce required. Full apply over small size needs busy/progress; medium+ needs chunking. |
| Tile size change | Global display update | Debounced tile setting apply. | Same as orientation. |
| Floor/wall catalog tile change | Global tile redraw | Catalog selection updates spin values and schedules tile settings apply. | Debounce required; medium+ needs chunked redraw. |
| Atlas/TileSet configuration | Global tile set update plus redraw | TileSet configured before apply. | Show busy/progress before broad changes. |
| Loop display toggle/mode/margin/rect | Global duplicate redraw | `refresh_loop_display()` clears loop layer and writes duplicate visual cells. | Chunk loop duplicate writes for large toric maps. |
| Overlay apply | Overlay tile redraw | Overlay adapter clears/writes overlay item cells. | Chunk independently from terrain for medium+ dense overlays. |
| Object scene tile/direct instance apply | Object layer fan-out | Object adapter clears and writes/instantiates placements. | Chunk object placement separately; direct instance creation needs cancel-between-chunks. |
| Selected document promotion | Document mutation plus visual apply | Metadata/copy is atomic, then `selected_layer.apply_document()`. | Keep document write atomic; chunk visual apply after state mutation or apply from a prepared snapshot. |

## Progress / Busy / Cancel Policy

Generation core:

- Required for medium+ maps or estimated work above `100 ms`.
- Existing chunk size, progress callback, and cancel callback remain the correct path.
- Cancel is meaningful during core generation and before post-generation apply begins.

Validation:

- Tiny/small baseline validation may remain synchronous.
- Medium+ validation must show busy/progress before it starts.
- Payload-heavy validation or movement-profile reachability over `150 ms` should be deferred or chunked in a later task.

Visual apply:

- Any direct user action expected to exceed `50 ms` should expose status.
- Any full `HexTileMapLayer` / layer-stack apply expected to exceed `100 ms` should show busy/progress before starting.
- Any visual apply expected to exceed `150 ms` should be chunked before being considered production-smooth.
- Cancel during synchronous apply is not available today. After chunking, cancellation can be offered between chunks and must leave the document/resource state consistent.

Debounce:

- Orientation, tile size, catalog tile, and other global visual changes must keep coalescing repeated input.
- Debounce only reduces repeated work; it does not replace chunking for a single large redraw.

## Chunked Apply Requirement

Chunked apply is required for future large-map Generate UX.

Recommended chunk boundaries:

- Terrain tile entries from `HexMapTileAdapter.to_tile_entries()`.
- Overlay entries from `HexOverlayTileAdapter.to_tile_entries()`.
- Document payload marker collection and overlay redraw.
- Loop display duplicate entries from `visual_cell_entries_for_rect()`.
- Object scene tile writes and direct instance creation.
- Layer-stack role fan-out: terrain, overlay, object, debug/collision/navigation roles should report separate coarse steps.

Required properties:

- The prepared document/map snapshot is fixed before chunks start.
- Document/resource mutation remains atomic from the user perspective.
- Visual chunks yield to the editor loop between batches.
- Progress state names the active phase and completed/total chunk count.
- Cancellation can stop future visual chunks but must either keep the already-committed Resource state or explicitly roll visual state back from the fixed snapshot.

Non-goal for this task:

- No chunked apply implementation is introduced in `PERF-60`.

## Acceptance Result

- Map-size update budgets: PASS
- Redraw/generation/apply/validation cost classification: PASS
- Orientation/global update classification: PASS
- Budget-overrun progress/busy/cancel policy: PASS
- Chunked apply need evaluated: PASS
