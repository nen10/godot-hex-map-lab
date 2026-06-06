# OBJ-01 Object Database v2 Implementation Plan

作成日: 2026-06-07

## Scope

- Add `addons/hex_map_kit/adapter/hex_object_definition_resource.gd`.
- Expand `HexObjectDatabaseResource` with v2 definitions and migration helpers.
- Add adapter tests for typed definitions, legacy array fallback, lookup, replacement, and save/load roundtrip.
- Update `docs/TEST.md`.
- Run `./tools/test.sh`.
- Write test result and self-review, then update queue proof.

## Test Path

- `tests/test_hex_adapter.gd`
- `./tools/test.sh`

## Repair Policy

Any acceptance miss, failing object database roundtrip, or legacy fallback regression is `repair-now` and must be fixed before moving to `OBJ-02`.
