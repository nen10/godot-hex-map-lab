# LD2-03 Document Summary and Validation Result Policy

作成日: 2026-06-07
Queue task: `LD2-03`

## Decisions

| Topic | Decision | Reason |
| --- | --- | --- |
| Summary shape | Return a Dictionary from adapter helper. | Summary is compact and easy for tests/UI/debug report to consume. |
| Validation result | Add `HexMapValidationResult` Resource with `summary` and issue array. | It must be serializable and reusable by dashboard/debug report tasks. |
| Issue schema | Store issue dictionaries with severity, rule id, message, scope, cell, object id, dependency path, and metadata. | This covers document/catalog/object/cell scoped future rules without creating many resource classes. |
| Rules in LD2-03 | Only add baseline schema warnings for missing map and missing dependencies. | Full validation matrix belongs to `VAL-01`. |

## Test Policy

Update `tests/test_hex_adapter.gd` to verify:

- Summary counts cells/walls/floors/objects/labels/zones/dependencies.
- Warning count is included in summary.
- Validation result saves and loads with issue data.

Update `docs/TEST.md` to mention summary and validation result schema coverage.
