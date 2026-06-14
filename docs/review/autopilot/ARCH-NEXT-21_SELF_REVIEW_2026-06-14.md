# ARCH-NEXT-21 Self Review 2026-06-14

Task: `ARCH-NEXT-21_GAMEPLAY_QUERY_SERVICE_EXTRACTION`
Status: COMPLETE

## Summary

Extracted runtime gameplay query computation into `HexGameplayQueryService` and made `HexTileMapLayer` delegate query helpers to it while preserving the public layer API and rendering methods.

## Changed Files

- `addons/hex_map_kit/adapter/hex_gameplay_query_service.gd`
- `addons/hex_map_kit/adapter/hex_gameplay_query_service.gd.uid`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `examples/basic_runtime/runtime_query_sample.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_debug_scenes.gd`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-21_GAMEPLAY_QUERY_SERVICE_EXTRACTION/SUB_TASKS.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-21_GAMEPLAY_QUERY_SERVICE_EXTRACTION/UX.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-21_GAMEPLAY_QUERY_SERVICE_EXTRACTION/POLICY.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-21_GAMEPLAY_QUERY_SERVICE_EXTRACTION/IMPLEMENTATION_PLAN.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Gameplay query methods are service-owned and layer delegates path/range/connectivity calls | pass | `addons/hex_map_kit/adapter/hex_gameplay_query_service.gd`, `addons/hex_map_kit/adapter/hex_tile_map_layer.gd` |
| `HexTileMapLayer` public API remains callable and behavior is preserved | pass | `tests/test_hex_tile_map_layer.gd` parity and delegation assertions |
| Layer rendering/overlay methods remain in the layer coordinator | pass | `addons/hex_map_kit/adapter/hex_tile_map_layer.gd` retains `draw_path`, `draw_movement_range`, highlight methods |
| Runtime query sample uses service path | pass | `examples/basic_runtime/runtime_query_sample.gd` + `tests/test_debug_scenes.gd` service-output equality assertions |
| Service is usable without node context where reasonable | pass | `HexGameplayQueryService` methods guard nil map data and return neutral outputs |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| none | none | none | none |

## UI Metric Review

Task is runtime runtime-core extraction and not UI-facing.

- Metric report path: not applicable
- P0 failures: not applicable
- P1 issues: not applicable

## Repair-Now Review

None.

## Test Review

- Command:

```sh
./tools/test.sh
```

- Result: pass (`./tools/test.sh` exited with code 0); see `docs/review/autopilot/ARCH-NEXT-21_TEST_RESULT_2026-06-14.md`
- Notes: all regression and delegation assertions were added to existing tests; no new negative assumptions.
