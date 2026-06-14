# ARCH-NEXT-22 Self Review 2026-06-14

Task: `ARCH-NEXT-22_DEBUG_OVERLAY_RENDERER_EXTRACTION`
Status: COMPLETE

## Summary

Moved immediate-mode debug overlay drawing out of `HexTileMapLayer` into
`HexDebugOverlayRenderer`, while keeping `HexTileMapLayer` as the coordinator for gameplay
state and object rendering.

## Changed Files

- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `addons/hex_map_kit/adapter/hex_debug_overlay_renderer.gd`
- `addons/hex_map_kit/adapter/hex_debug_overlay_renderer.gd.uid`
- `tests/test_hex_tile_map_layer.gd`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-22_DEBUG_OVERLAY_RENDERER_EXTRACTION/SUB_TASKS.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-22_DEBUG_OVERLAY_RENDERER_EXTRACTION/UX.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-22_DEBUG_OVERLAY_RENDERER_EXTRACTION/POLICY.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-22_DEBUG_OVERLAY_RENDERER_EXTRACTION/IMPLEMENTATION_PLAN.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Debug overlay rendering is moved to a dedicated renderer | pass | `addons/hex_map_kit/adapter/hex_debug_overlay_renderer.gd`, `addons/hex_map_kit/adapter/hex_tile_map_layer.gd` |
| Gameplay rendering (TileMap + object markers) remains in layer/object renderer pathway | pass | `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`, `tests/test_hex_tile_map_layer.gd` |
| Validate/debug focus entry point exists and drives overlay highlights | pass | `focus_validation_cells` in `hex_tile_map_layer.gd`, `_test_focus_validation_cells_drives_overlay` |
| Overlay parity is test-covered against renderer replay | pass | `_test_debug_overlay_renderer_replays_overlay_output` |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| none | none | none | none |

## UI Metric Review

Task is runtime extraction; UI metric report path is not applicable.

## Test Review

- Command:

```sh
./tools/test.sh
```

- Result: recorded in `docs/review/autopilot/ARCH-NEXT-22_TEST_RESULT_2026-06-14.md`
