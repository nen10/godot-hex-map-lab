# Autopilot Self Review Template

Task:
Queue:
Plan:
Optional execution log:

## Execution Summary

Summarize what actually changed in this task.

## Changed Files

| file | change |
|---|---|
|  |  |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
|  |  |  |  |

Use `none` when there is no deviation.

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
|  |  |  |

## Experiential DoD (UI / graph task)

UI/graph task は structural DoD（構造・型・test）に加えて experiential DoD を満たすこと。非 UI task は `not applicable` + 理由。

| item | result | evidence |
|---|---|---|
| What user sees first |  | tab/画面を開いた最初に見えるもの（ラベル列でないこと） |
| What user can do |  | 触れる primary action と、その結果 |
| (graph task) chain runs |  | 中間 output → 次 node → Promote が editor / headless で通る |
| Label-heavy but metrics pass |  | `no` であること（ラベル依存で画面を説明していない） |

両方の DoD を満たさない UI/graph task は `COMPLETE` にしない（`docs/process/QUEUE_OPERATION_RULES.md` two-layer DoD gate）。

## UI Metric Review

For UI-facing tasks, record the metric report from `./tools/test.sh`.
For non-UI tasks, use `not applicable` with a reason.

| item | result | evidence |
|---|---|---|
| Metric report path |  |  |
| P0 failures |  | Must be `0` for UI task completion. |
| P1 issues |  | Report-only unless the active roadmap says otherwise. |
| UI metric applicability |  | UI task / non-UI task reason. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
|  |  |  |

Use `none` when there is no deferred or prose-only item.

## Repair-now Review

State whether any repair-now issue remains. If yes, do not mark the task complete.

## Test Review

- Command:
- Result:
- Notes:
