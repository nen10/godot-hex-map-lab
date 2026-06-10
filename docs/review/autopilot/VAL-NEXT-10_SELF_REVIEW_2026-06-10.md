# VAL-NEXT-10 Self Review 2026-06-10

Task: `VAL-NEXT-10_VALIDATE_RICH_ISSUE_TABLE_ACTIONS`
Queue: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`
Plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/VAL-NEXT-10_VALIDATE_RICH_ISSUE_TABLE_ACTIONS/`
Optional execution log: none

## Execution Summary

Added a structured Validate issue table contract to workspace validation snapshots. Issue rows now expose severity, domain, scope, target text, suggestion text, and available real focus actions. The mounted Validate issue list now renders the richer table row text, and the editor test verifies missing asset rows plus cell-scoped Paint routing through the same table/action contract.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/editor/hex_map_workspace.gd` | Added Validate issue table snapshot, rich issue row fields, real focus action metadata, and mounted rich row text. |
| `tests/test_editor_plugin.gd` | Added assertions for issue table columns, row count, real actions, mounted text, missing asset routing, and cell-scoped Paint routing. |
| `docs/TEST.md` | Documented `VAL-NEXT-10` coverage. |
| `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/VAL-NEXT-10_VALIDATE_RICH_ISSUE_TABLE_ACTIONS/` | Added C4 planning artifacts. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| Rich issue table columns | done | Matches plan. | none |
| Real per-issue focus actions | done | Matches plan; actions reuse existing route metadata. | none |
| Mounted Validate issue text | done | Matches plan. | none |
| Placeholder table actions | rejected | Only real actions are allowed by task policy. | none |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Severity/domain/scope/target/suggestion/actions columns | pass | `issue_table.columns` contains all required columns. |
| Real action metadata only | pass | `issue_table.real_actions_only` is true and actions include target tab metadata. |
| Missing project asset route | pass | Missing document issue exposes Resources focus action. |
| Cell-scoped route | pass | Object-on-wall issue exposes Paint target text, suggestion, and Paint action. |
| Mounted UI proof | pass | `mounted_issue_table_text` contains rich row text. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | pass | `.godot_user/ui-metrics/20260610-203734-34721/workspace_layout_metrics.md` |
| P0 failures | pass | `0` |
| P1 issues | pass | `0` |
| UI metric applicability | pass | UI-facing Validate table task. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| Placeholder action buttons | rejected | Task requires only real per-issue actions. |
| Validation traversal progress | deferred | Existing `PERF-NEXT-11`. |
| Debug overlay renderer extraction | deferred | Existing `ARCH-NEXT-22`. |

## Repair-now Review

No repair-now issue remains.

## Test Review

- Command: `./tools/test.sh`
- Result: pass
- UI metric report: `.godot_user/ui-metrics/20260610-203734-34721/workspace_layout_metrics.md`
- Notes: Godot emitted existing macOS CA certificate warnings and expected warning-path messages; no test failed.
