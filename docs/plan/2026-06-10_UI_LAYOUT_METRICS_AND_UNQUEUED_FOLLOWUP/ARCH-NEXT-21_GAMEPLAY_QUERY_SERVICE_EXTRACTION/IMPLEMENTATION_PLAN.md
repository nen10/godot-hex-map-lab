# Implementation Plan

## Scope

Extract gameplay query logic out of `HexTileMapLayer` into a dedicated runtime service while preserving public query APIs and rendering responsibilities.

## Target Files

- `addons/hex_map_kit/adapter/hex_gameplay_query_service.gd`
- `addons/hex_map_kit/adapter/hex_gameplay_query_service.gd.uid`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `examples/basic_runtime/runtime_query_sample.gd`
- `tests/test_hex_tile_map_layer.gd`
- `tests/test_debug_scenes.gd`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-21_GAMEPLAY_QUERY_SERVICE_EXTRACTION/`

## Planned Implementation Steps

1. Finalize service implementation with methods: `from_map_data`, `find_path`, `find_weighted_path`, `movement_range`, `is_map_connected`, `connected_component`, `connected_component_from_local`, plus profile/catalog-safe initialization.
2. Update `HexTileMapLayer` query API methods to delegate through `_gameplay_query_service`, keeping public signatures unchanged.
3. Keep rendering/overlay methods on `HexTileMapLayer`; they may use service outputs but remain coordinator-owned.
4. Update `examples/basic_runtime/runtime_query_sample.gd` to instantiate and use `HexGameplayQueryService` in `query_document`/`query_document_path`.
5. Update tests:
   - `tests/test_hex_tile_map_layer.gd`: add parity tests (service vs core and layer delegation).
   - `tests/test_debug_scenes.gd`: add runtime sample parity checks against service output and service-path source assertion.
6. Run `./tools/test.sh`, then run remaining required review updates.
7. Update queue proof log for `ARCH-NEXT-21` and add self-review/test-result docs.

## Planned Completion Criteria

- Public gameplay query APIs remain callable on `HexTileMapLayer` and produce identical results through service-backed delegation.
- `HexGameplayQueryService` can be used independently of any Node context.
- Runtime query sample returns weighted path/range via service path.
- `./tools/test.sh` passes and self-review/test-result docs exist under `docs/review/autopilot/`.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Gameplay output parity | service mismatch on walls/profiles/toric costs | `tests/test_hex_tile_map_layer.gd`
| Layer delegation coverage | calls still pass through service | `tests/test_hex_tile_map_layer.gd` probe assertions |
| Runtime sample query path | sample bypasses intended service boundary | `tests/test_debug_scenes.gd` runtime sample assertions |
| Test gate | regression or missing fixture | `./tools/test.sh` |
