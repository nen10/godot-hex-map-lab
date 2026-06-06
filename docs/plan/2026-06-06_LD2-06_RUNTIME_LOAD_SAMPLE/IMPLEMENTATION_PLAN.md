# LD2-06 Runtime Load Sample Implementation Plan

作成日: 2026-06-07
Queue task: `LD2-06`

## Inputs

- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `addons/hex_map_kit/adapter/hex_map_document_resource.gd`
- `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
- `tests/test_debug_scenes.gd`
- `docs/TEST.md`

## Outputs

- Runtime-safe document load helper on or near `HexTileMapLayer`.
- Headless test proving a v2 document resource path loads into `HexTileMapLayer`.
- LD2-06 test result, self-review, and queue proof.

## Implementation Steps

1. Inspect existing debug scene/runtime tests and `HexTileMapLayer` resource APIs.
2. Add a runtime-safe load helper for `HexMapDocumentResource` path/resource application.
3. Add a headless test that saves or constructs a v2 document and loads it through the runtime path.
4. Update `docs/TEST.md`.
5. Run `./tools/test.sh`.

## Test Path

- `tests/test_debug_scenes.gd`
- `./tools/test.sh`
