# VAL-01 Implementation Plan

## Scope

Add a document validation helper, core rule tests, `docs/TEST.md` update, full test run, self-review, queue proof, and commit.

## Steps

1. Add `addons/hex_map_kit/adapter/hex_map_document_validator.gd`.
2. Implement `validate_document(document, options)` returning `HexMapValidationResult`.
3. Detect outside map, orphan payload, missing catalog, missing tile, missing dependency, and object-on-wall rules.
4. Add `tests/test_hex_adapter.gd` coverage for every accepted rule id.
5. Update `docs/TEST.md`.
6. Run `./tools/test.sh`; repair failures in-task.
7. Write self-review/test-result docs, update queue proof, and commit.
