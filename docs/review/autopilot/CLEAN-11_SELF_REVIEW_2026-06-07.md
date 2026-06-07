# CLEAN-11 Self Review 2026-06-07

Task: `CLEAN-11_ADAPTER_COMPATIBILITY_REMOVAL`

## Acceptance Review

| Acceptance item | Result | Evidence |
|---|---|---|
| Normal adapter path has no public `legacy` / `v1` / `fallback` compatibility warning API | pass | `HexMapDocumentAdapter.catalog_compatibility_warnings()` and helper warning builders were removed. Stale scan finds no production references. |
| Missing catalog or assignment becomes validation issue | pass | `HexMapDocumentValidator.RULE_TILE_ASSIGNMENT_MISSING` covers missing terrain defaults and tile assignment keys; existing missing catalog/key/resource rules still report catalog/resource failures. |
| Runtime apply succeeds for validation-clean document | pass | Adapter and layer tests now use catalog-key documents for clean apply paths and `./tools/test.sh` passes. |
| Catalogless numeric fallback is not normal adapter behavior | pass | `HexMapTileAdapter.tile_config_from_catalog()` has no fallback config parameter. `HexMapDocumentAdapter.apply_to_tile_map_layer()` skips unresolved catalog entries by default. |

## Repair Log

- Initial test run exposed a `Resource.get()` API misuse in `tile_config_from_catalog()`; fixed by using one-argument property reads.
- Editor and generation tests initially failed because generated/plain documents lacked catalog defaults. Repaired by adding catalog defaults to generated document snapshots and by keeping editor numeric display behind explicit `debug_numeric_fallback_enabled`.
- Rewrote old compatibility warning tests to validation-dashboard and missing-assignment assertions.

## Follow-Up Classification

- `accepted-risk`: `HexMapEditTool` still has the visible `Advanced numeric fallback` selection and can pass `debug_numeric_fallback_enabled` for the old plain `TileMapLayer` path. This is isolated from the normal adapter API and is already covered by `CLEAN-20` / `CLEAN-33` UI cleanup.
- `follow-up-ready`: none added; existing `CLEAN-12` owns object database legacy cleanup and `CLEAN-13` owns tile catalog fallback field/type cleanup.
- `repair-now`: complete.

## Verification

- `./tools/test.sh` PASS on Godot `v4.6.2.stable.official.71f334935`.
- `git diff --check` clean.
- Stale API scan: no production `catalog_compatibility_warnings` / `catalog_warning` references remain; the only `catalog_warning_count` hit is a negative editor test assertion.
