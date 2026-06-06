# LD2-03 Document Summary and Validation Result Implementation Plan

作成日: 2026-06-07
Queue task: `LD2-03`

## Inputs

- `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
- `addons/hex_map_kit/adapter/hex_map_document_resource.gd`
- v2 resource scripts from `LD2-01`
- `tests/test_hex_adapter.gd`
- `docs/TEST.md`

## Outputs

- `addons/hex_map_kit/adapter/hex_map_validation_result.gd`
- Adapter summary and validation result helpers.
- Tests for summary counts and validation result serialization.
- `docs/TEST.md` update.
- LD2-03 test result, self-review, and queue proof.

## Implementation Steps

1. Add `HexMapValidationResult` resource.
2. Add adapter helper `document_summary(document)`.
3. Add adapter helper `validation_result_for_document(document)`.
4. Add tests for v2 summary counts.
5. Add tests for validation result serialization and warning count.
6. Run `./tools/test.sh`.

## Test Path

- `tests/test_hex_adapter.gd`
- `./tools/test.sh`
