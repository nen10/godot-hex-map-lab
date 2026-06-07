# LD2-04 Adapter Roundtrip Implementation Plan

作成日: 2026-06-07
Queue task: `LD2-04`

## Inputs

- `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- v2 schema resources from `LD2-01`
- migration helpers from `LD2-02`
- summary/validation helpers from `LD2-03`
- `tests/test_hex_adapter.gd`
- `tests/test_hex_tile_map_layer.gd`
- `docs/TEST.md`

## Outputs

- v2-aware adapter payload/map helpers.
- v2 deleted-cell cleanup.
- `HexTileMapLayer` application of v2 tile/object/label payloads.
- Tests and docs updates.
- LD2-04 test result, self-review, and queue proof.

## Implementation Steps

1. Add normalized adapter helpers for tile, object, and label entries.
2. Update map conversion/apply helpers to read v2 terrain layer maps.
3. Extend deleted-cell cleanup to v2 terrain/overlay/object/label/zone resources.
4. Update `HexTileMapLayer` document payload loops to use adapter helpers.
5. Add adapter roundtrip and cleanup tests.
6. Add layer application test for pure v2 document payloads.
7. Run `./tools/test.sh`.

## Test Path

- `tests/test_hex_adapter.gd`
- `tests/test_hex_tile_map_layer.gd`
- `./tools/test.sh`
