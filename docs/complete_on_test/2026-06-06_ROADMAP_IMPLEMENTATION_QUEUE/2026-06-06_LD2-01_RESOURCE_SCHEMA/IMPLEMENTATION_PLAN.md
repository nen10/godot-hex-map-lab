# LD2-01 Level Document v2 Resource Schema Implementation Plan

作成日: 2026-06-07
Queue task: `LD2-01`

## Inputs

- `addons/hex_map_kit/adapter/hex_map_document_resource.gd`
- `addons/hex_map_kit/adapter/hex_map_resource.gd`
- `addons/hex_map_kit/adapter/hex_overlay_resource.gd`
- `tests/test_hex_adapter.gd`
- `docs/TEST.md`

## Outputs

- Additive v2 fields on `HexMapDocumentResource`.
- New typed v2 resource scripts under `addons/hex_map_kit/adapter/`.
- Updated `tests/test_hex_adapter.gd`.
- Updated `docs/TEST.md`.
- LD2-01 test result, self-review, and queue proof.

## Implementation Steps

1. Add typed resource scripts for metadata, dependencies, terrain layers, overlay layers, object placements, label placements, and zones.
2. Add v2 exported fields to `HexMapDocumentResource` without changing current v1 fields.
3. Add small helper methods/constants for v2 defaults and schema inspection.
4. Add adapter tests for v2 schema roundtrip.
5. Add adapter tests proving v1-style documents still roundtrip.
6. Update `docs/TEST.md` test summary.
7. Run `./tools/test.sh`.
8. Write self-review and update queue proof.

## Test Path

- `tests/test_hex_adapter.gd`
- `./tools/test.sh`
