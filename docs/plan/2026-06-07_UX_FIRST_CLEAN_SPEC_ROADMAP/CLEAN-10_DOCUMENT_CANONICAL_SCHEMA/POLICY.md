# CLEAN-10 Policy

Task: `CLEAN-10_DOCUMENT_CANONICAL_SCHEMA`
Status: RUNNING

## 採用方針

1. `HexMapDocumentResource` の public exported fields は canonical fields のみとする。
2. `map`, `tile_overrides`, `objects`, `labels`, `version` は document resource の public contract から削除する。
3. `ensure_v2_defaults()`, `is_v2()`, `v2_schema_fields()`, `migrate_v1_to_v2()` は削除する。
4. 新規 document は constructor default で metadata を持つ。
5. Adapter helpers may keep existing mutation method names when later tasks own naming cleanup, but they must mutate canonical fields only.
6. Current API/manual/examples must not instruct users to migrate or call version upgrade helpers.
7. Historical review and old plan files are not rewritten unless they are current user-facing guidance.

## Test policy

- Delete tests whose purpose is preserving v1 fixture or migration behavior.
- Keep and update save/load tests for canonical resources.
- Keep and update adapter roundtrip and mutation cleanup tests.
- Run full `./tools/test.sh` because document shape touches editor, runtime, and debug scene tests.

## Follow-up boundaries

- `CLEAN-11` owns broader adapter compatibility/fallback removal.
- `CLEAN-13` owns Tile Catalog resource canonical cleanup.
- `CLEAN-12` owns Object Database canonical cleanup.
- `CLEAN-41` owns a later full API vocabulary pass.
