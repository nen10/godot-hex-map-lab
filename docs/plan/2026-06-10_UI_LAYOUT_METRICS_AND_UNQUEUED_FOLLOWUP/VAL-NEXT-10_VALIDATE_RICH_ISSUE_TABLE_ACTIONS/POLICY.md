# Policy

## Adopted Decisions

- Validate owns issue table presentation and issue focus routing.
- Per-issue actions must be real routes backed by `select_validate_issue()`.
- Issue table rows must expose severity, domain, scope, target, and suggestion.
- Mounted UI text must summarize the table columns and avoid raw JSON.

## Rejected Decisions

- Do not add fake or disabled per-row actions just to fill a column.
- Do not move validation ownership to Paint or Resources.
- Do not expose raw issue dictionaries as primary text.
- Do not add analog tests.

## Resource / API / UI Boundary

- `HexMapWorkspace` owns Validate screen snapshots, mounted navigator labels, and workspace issue routing.
- `HexMapValidationDashboard` remains the issue enrichment source for severity/domain/focus/suggestion helpers.
- Asset rows remain typed Resource selection controls, not Validate row action buttons.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Existing selection route | keep | It is a real working action for issue focus. | Future action dispatcher replaces it. | Validate issue selection tests. |
| Raw issue dictionary | reject as primary UI | It is debug data, not table UX. | none | Mounted text tests. |
| Placeholder row actions | reject | Violates real-action policy. | none | Row action metadata tests. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Issue table columns | Columns include severity/domain/scope/target/suggestion/actions. | Validate remains hard to scan. | Snapshot tests. |
| Per-issue actions | Action exists only when a focus route exists. | UI exposes no-op actions. | Row action tests. |
| Mounted row text | Text includes table semantics and selected issue route. | Table stays headless-only. | Mounted text tests. |
| Sample boundary | Validation does not inject sample assets. | Validate completion relies on samples. | Existing and updated tests. |

## Completion Rule

`VAL-NEXT-10` is complete only when Validate exposes rich issue table columns and real per-issue focus action metadata, mounted issue text reflects the table, issue selection routes still work, tests cover workspace and cell-scoped rows, and `./tools/test.sh` passes with UI metric P0 failures = 0.
