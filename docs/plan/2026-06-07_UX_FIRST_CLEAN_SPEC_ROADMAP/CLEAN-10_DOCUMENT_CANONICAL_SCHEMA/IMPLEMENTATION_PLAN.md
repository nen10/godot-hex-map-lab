# CLEAN-10 Implementation Plan

Task: `CLEAN-10_DOCUMENT_CANONICAL_SCHEMA`
Status: RUNNING

## Scope

Primary files:

- `addons/hex_map_kit/adapter/hex_map_document_resource.gd`
- `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `tests/test_hex_adapter.gd`
- related editor/runtime/debug tests
- current API/manual/example docs

## Steps

1. Remove legacy/version fields and helper methods from `HexMapDocumentResource`.
2. Rework `HexMapDocumentAdapter.from_map_resource()`, duplication, summary, mutation, cleanup, and map lookup to canonical fields only.
3. Remove editor and generator upgrade/migration calls.
4. Update `HexTileMapLayer.to_document_resource()` to emit canonical terrain/object/label resources.
5. Rewrite adapter tests from v2/migration assertions to canonical save/load and roundtrip assertions.
6. Update editor/runtime/debug tests that asserted document version or direct `document.map`.
7. Update current API/manual/example docs and delete the public migration guide.
8. Run `./tools/test.sh`.
9. Self-review and classify repairs.
10. Mark queue complete and run dependency sweep.

## Acceptance mapping

| Acceptance | Plan |
|---|---|
| `v1` / `v2` / `version` removed from document public contract | Resource, docs, tests no longer expose those APIs. |
| legacy fields removed | Document resource and adapter no longer read/write direct map/payload fallback arrays. |
| `ensure_v2_defaults()` removed | Callers construct canonical documents directly. |
| new document canonical by construction | `metadata` exists by default; canonical arrays are the only fields. |
| tests verify canonical save/load and roundtrip | Adapter tests cover resource save/load, adapter roundtrip, mutation, cleanup. |
