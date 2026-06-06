# LD2-02 v1 to v2 Migration Implementation Plan

作成日: 2026-06-07
Queue task: `LD2-02`

## Inputs

- `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
- `addons/hex_map_kit/adapter/hex_map_document_resource.gd`
- v2 resource scripts added by `LD2-01`
- `tests/test_hex_adapter.gd`
- `docs/TEST.md`

## Outputs

- Migration helper on `HexMapDocumentAdapter`.
- Tests for v1 migration roundtrip and missing-field behavior.
- `docs/TEST.md` update.
- LD2-02 test result, self-review, and queue proof.

## Implementation Steps

1. Preload v2 resource classes in `HexMapDocumentAdapter`.
2. Add `migrate_v1_to_v2(document)` returning a migrated copy.
3. Preserve legacy fields and source version metadata.
4. Populate default terrain layer from `map`.
5. Populate overlay layers from v1 overlay tile overrides.
6. Populate object placements and label placements from v1 payload arrays.
7. Add roundtrip and missing-field tests.
8. Run `./tools/test.sh`.

## Test Path

- `tests/test_hex_adapter.gd`
- `./tools/test.sh`
