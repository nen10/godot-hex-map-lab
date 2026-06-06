# LD2-02 v1 to v2 Migration Policy

作成日: 2026-06-07
Queue task: `LD2-02`

## Source Documents

- `docs/review/roadmap/SCHEMA_BOUNDARY_DECISIONS_2026-06-06.md`
- `docs/plan/2026-06-06_LD2-01_RESOURCE_SCHEMA/`
- `docs/policy/IMPLEMENTATION_POLICY.md`

## Decisions

| Topic | Decision | Reason |
| --- | --- | --- |
| Migration shape | Return a migrated copy rather than mutating the source. | Existing editor/runtime code should not lose v1 state by calling migration. |
| Version handling | Set migrated document `version` to v2 and record source version in metadata. | v2 documents need version 2 while acceptance requires preserving version information. |
| Legacy fields | Preserve `map`, `tile_overrides`, `objects`, and `labels` on migrated copies. | Compatibility paths continue to use these fields until later tasks switch primary paths. |
| Missing fields | Treat null/missing fields as empty data. | Old or partially-authored resources must not crash migration. |
| Overlay grouping | Convert v1 `kind=overlay` tile overrides into a default overlay layer grouped by `item_key`. | LD2-01 schema can represent overlays, while full catalog/layer apply waits for later tasks. |

## Test Policy

Update `tests/test_hex_adapter.gd` to verify:

- v1 migration preserves legacy fields and records source version.
- migrated documents save/load with typed v2 fields.
- missing-field inputs migrate to a valid empty v2 document.

Update `docs/TEST.md` to mention v1 to v2 migration coverage.
