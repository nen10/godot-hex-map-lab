# UI Layout Metrics And Unqueued Follow-up M2 Phase Review 2026-06-10

Roadmap: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ROADMAP.md`
Phase: M2 UI metric evaluator and acceptance gates
Date: 2026-06-10
Reviewer: Codex autopilot
Queue: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Phase Close Condition

| check | result | evidence |
|---|---|---|
| No phase task remains `READY`, `RUNNING`, `VERIFYING`, or `REPAIR_NOW`. | Pass | `UI-METRIC-05` through `UI-METRIC-08` are `COMPLETE`. |
| No phase task remains `SPLIT_REQUIRED` or `BLOCKED_BY_TEST_ENV` without an explicit next action. | Pass | No M2 task has those statuses. |
| `COMPLETE_WITH_BACKLOG` tasks name a queue id, dynamic follow-up item, or ledger entry. | Pass | No M2 task is `COMPLETE_WITH_BACKLOG`. |
| Dependency sweep result is recorded. | Pass | `TEST-NEXT-10` is promoted to READY; current pointer is `ARCH-NEXT-10`. |

## Task Matrix

| task id | status | score | evidence | debt / follow-up | next readiness |
|---|---|---:|---|---|---|
| `UI-METRIC-05` | COMPLETE | 3 | P0 report API, self-review, test result, `./tools/test.sh` | none | closed |
| `UI-METRIC-06` | COMPLETE | 2 | P1 report API, self-review, test result, `./tools/test.sh` | P1 standard failure remains policy-deferred | closed |
| `UI-METRIC-07` | COMPLETE | 2 | Standard P0 gate, generated metric report, self-review, test result | P1 remains report-only by roadmap policy | closed |
| `UI-METRIC-08` | COMPLETE | 3 | Template/process/commit proof updates, self-review, test result | none | closed |

## Deferred / Prose-only Conversion

| source | phrase / item | classification | queue id / ledger entry / reject reason / revisit condition | owner |
|---|---|---|---|---|
| `UI-METRIC-06` / `UI-METRIC-07` | P1 standard failure integration | Policy-deferred | Revisit when an active roadmap enables P1 gating; current roadmap allows P1 report-only initially. | Future metric roadmap |
| `UI-METRIC-07` | Expanded viewport/state matrix | Policy-deferred | Revisit when a UI task needs more scenario coverage or report time budget changes. | Future metric/UI task |
| `UI-METRIC-08` | Metric proof in `IMPLEMENTATION_PLAN.md` | Explicit reject | Violates `PROCESS-13`; metric proof belongs in self-review/test result. | none |

## Evidence Links

- Queue: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`
- Proof log: `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md#10-completed-task-proof-log`
- Plan docs:
  - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-05_P0_ACCEPTANCE_GATE/`
  - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-06_P1_ACCEPTANCE_GATE/`
  - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-07_TEST_SH_INTEGRATION/`
  - `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-08_AUTOPILOT_ACCEPTANCE_TEMPLATE_UPDATE/`
- Self-review docs:
  - `docs/review/autopilot/UI-METRIC-05_SELF_REVIEW_2026-06-10.md`
  - `docs/review/autopilot/UI-METRIC-06_SELF_REVIEW_2026-06-10.md`
  - `docs/review/autopilot/UI-METRIC-07_SELF_REVIEW_2026-06-10.md`
  - `docs/review/autopilot/UI-METRIC-08_SELF_REVIEW_2026-06-10.md`
- Test-result docs:
  - `docs/review/autopilot/UI-METRIC-05_TEST_RESULT_2026-06-10.md`
  - `docs/review/autopilot/UI-METRIC-06_TEST_RESULT_2026-06-10.md`
  - `docs/review/autopilot/UI-METRIC-07_TEST_RESULT_2026-06-10.md`
  - `docs/review/autopilot/UI-METRIC-08_TEST_RESULT_2026-06-10.md`
- Test command: `./tools/test.sh`

## Next Readiness

| next action | result | reason |
|---|---|---|
| Continue to next READY task | Pass | `ARCH-NEXT-10` is first READY in queue order. |
| Add dynamic follow-up | Not needed | Deferred items are policy-deferred or already represented by queue/process. |
| Mark repair-now | Not needed | M2 acceptance and tests pass. |
| Split task | Not needed | No oversized unresolved M2 task remains. |
| Block on environment | Not needed | Godot tests ran successfully. |

## Required Action

Proceed to `ARCH-NEXT-10_PHYSICAL_WORKSPACE_UI_NODE_EXTRACTION` as the next queue task.
