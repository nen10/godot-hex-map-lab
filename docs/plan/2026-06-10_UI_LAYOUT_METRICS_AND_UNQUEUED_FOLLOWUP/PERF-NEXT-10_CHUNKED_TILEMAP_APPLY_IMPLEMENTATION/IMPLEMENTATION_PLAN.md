# Implementation Plan

## Scope

Add chunked TileMap apply with progress/cancel reports and connect it to Generate output apply while preserving current synchronous editor APIs.

## Target Files

- `addons/hex_map_kit/adapter/hex_map_tile_adapter.gd`
- `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_generation_run_state.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## Planned Implementation Steps

1. Add `HexMapTileAdapter.apply_to_tile_map_layer_chunked()` returning a report with target scope, chunk size, applied/total counts, progress events, cancellation, and error state.
2. Route existing direct `apply_to_tile_map_layer()` through the chunked API.
3. Add HexTileMapLayer chunk report support for override-aware redraw/apply paths.
4. Pass chunk options through document apply and Generate output apply, storing last apply report in output snapshots and progress state.
5. Add tests for chunk progress, cancellation, direct apply preservation, HexTileMapLayer report state, and Generate output snapshot report.
6. Update `docs/TEST.md`.
7. Run `./tools/test.sh`.

## Fallback / Deferred Steps

| step | decision | reason |
|---|---|---|
| Async frame-yielding apply | defer/reject for this task | Existing synchronous editor APIs stay stable while chunk checkpoints are introduced. |
| Large validation progress | defer | Covered by `PERF-NEXT-11`. |
| Runtime rendering service extraction | defer | Covered by architecture follow-up rows. |

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Direct TileMap apply | Existing FakeTileLayer tests regress. | Existing generation apply tests plus new report assertions. |
| HexTileMapLayer display apply | Loop/overlay/object display regressions. | Existing HexTileMapLayer and editor tests. |
| Generate output target | NODE-24 document apply state regresses. | Existing NODE-24 tests plus chunk report assertion. |
| Cancel semantics | Cancel callback ignored. | New adapter cancellation test. |
| UI metrics | Progress UI regression. | `./tools/test.sh` metric gate. |

## Docs Updates

- Update `docs/TEST.md` with `PERF-NEXT-10` coverage.
- Record self-review and test result under `docs/review/autopilot/`.

## Planned Completion Criteria

- TileMap apply exposes chunked progress/cancel report.
- Existing synchronous apply callers still work.
- Generate selected-document apply records chunk report and keeps output target state.
- Tests verify chunk progress/cancel and UI metric P0 failures = 0.
