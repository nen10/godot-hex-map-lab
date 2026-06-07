# VAL-04 UX

## User Outcome

Validation behavior should be dependable enough for dashboard and debug-report users to trust each core rule. Every accepted core rule needs both a failing fixture and a passing fixture so regressions are easy to identify.

## Rules Covered

- `document.payload_outside_map`
- `document.orphan_payload`
- `document.catalog_missing`
- `document.tile_missing`
- `document.dependency_missing`
- `document.object_on_wall`

## Non-Goals

- New validation rules are outside this task.
- Dashboard layout changes are outside this task.
