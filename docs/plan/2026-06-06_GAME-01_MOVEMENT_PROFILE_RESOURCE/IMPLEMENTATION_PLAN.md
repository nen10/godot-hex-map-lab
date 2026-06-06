# GAME-01 Implementation Plan

## Scope

Add movement profile core/resource files, gameplay layer data extraction, tests, docs update, full proof, self-review, queue proof, and commit.

## Steps

1. Add core `HexMovementProfile` for passability/cost/blocker defaults.
2. Add saveable `HexMovementProfileResource`.
3. Add `HexGameplayLayerData` extraction from `HexMapData` and `HexMapDocumentResource`.
4. Cover profile defaults in `tests/test_hex_core.gd`.
5. Cover resource roundtrip and document/catalog/object gameplay extraction in `tests/test_hex_adapter.gd`.
6. Update `docs/TEST.md`.
7. Run `./tools/test.sh`; repair failures in-task.
8. Write self-review/test-result docs, update queue proof, and commit.
