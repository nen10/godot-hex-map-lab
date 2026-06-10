# QA-NEXT-10 Self Review 2026-06-10

Task: `QA-NEXT-10_SCORE_TABLE_VISUAL_REDESIGN`
Queue: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`
Plan: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/QA-NEXT-10_SCORE_TABLE_VISUAL_REDESIGN/`
Optional execution log: none

## Execution Summary

Added a mounted QA score table widget and a structured scored table snapshot for Seed Lab rows. The table exposes rank, seed, score, validation, selected state, preview state, and promotion state. QA refresh logic now populates the mounted table and rich row text from the same scored table contract used by snapshots and tests.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/editor/hex_map_qa_screen.gd` | Added mounted QA score table tree with comparison columns. |
| `addons/hex_map_kit/editor/hex_map_workspace.gd` | Added scored table row helpers, selected/promoted state, mounted tree refresh, and snapshot proof fields. |
| `tests/test_editor_plugin.gd` | Added QA-NEXT-10 assertions for columns, mounted table proof, selected state, preview state, validation status, and promoted row state. |
| `docs/TEST.md` | Documented `QA-NEXT-10` coverage. |
| `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/QA-NEXT-10_SCORE_TABLE_VISUAL_REDESIGN/` | Added C4 planning artifacts. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| Rich scored table contract | done | Matches plan. | none |
| Mounted table widget | done | Matches plan. | none |
| Selected/promoted row state | done | Matches plan. | none |
| Per-row thumbnail Controls | deferred | Existing row preview payloads and selected thumbnail satisfy this task. | none |
| New scoring formula | deferred | Presentation task only. | none |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Seed rows and score columns are comparable | pass | `scored_table.columns` includes rank, seed, and score; row count matches batch rows. |
| Validation status is visible | pass | Rows expose `validation` and mounted row text includes validation status. |
| Selected seed is visible | pass | Selected row index and selected row state update after batch/select. |
| Preview state is visible | pass | Rows expose `preview_available` and preview text. |
| Promotion state is visible | pass | Promoted row index, promoted flag, and mounted row text update after promotion. |
| Mounted UI proof | pass | Mounted score tree row count and rich row text are asserted. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | pass | `.godot_user/ui-metrics/20260610-204647-49048/workspace_layout_metrics.md` |
| P0 failures | pass | `0` |
| P1 issues | pass | `0` |
| UI metric applicability | pass | UI-facing QA table task. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| New generation scoring formula | deferred | Existing scoring remains stable. |
| Per-row thumbnail Controls | deferred | Existing `GEN-NEXT-11` preview payloads remain sufficient. |
| Per-row promote buttons | rejected | Existing selected-row promotion remains the real action. |

## Repair-now Review

No repair-now issue remains. Initial verification caught a test assumption that validation status would always be `0E/0W`; the assertion was repaired to verify visible, internally consistent validation status.

## Test Review

- Command: `./tools/test.sh`
- Result: pass
- UI metric report: `.godot_user/ui-metrics/20260610-204647-49048/workspace_layout_metrics.md`
- Notes: Godot emitted existing macOS CA certificate warnings and expected warning-path messages; no test failed.
