# UI-METRIC-08 Implementation Plan

## Scope

- Update `SELF_REVIEW_TEMPLATE.md` with UI metric report fields.
- Update autopilot orchestration to require metric summary for UI tasks.
- Update queue proof rules to include metric report evidence for UI tasks.
- Update commit checklist to require P0 failures = 0 for UI task completion.
- Run `./tools/test.sh`.
- Write proof docs, update queue status/proof, create M2 phase review, and commit.

## Target Files

- `docs/review/autopilot/SELF_REVIEW_TEMPLATE.md`
- `docs/process/CODEX_AUTOPILOT_ORCHESTRATION.md`
- `docs/process/QUEUE_OPERATION_RULES.md`
- `docs/process/CODEX_AUTOPILOT_COMMIT_POLICY.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/UI-METRIC-08_AUTOPILOT_ACCEPTANCE_TEMPLATE_UPDATE/`
- `docs/review/autopilot/UI-METRIC-08_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/UI-METRIC-08_TEST_RESULT_2026-06-10.md`
- `docs/review/roadmap/UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP_M2_PHASE_REVIEW_2026-06-10.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Planned Steps

- Mark `UI-METRIC-08` RUNNING and create plan docs.
- Update self-review/process/commit docs.
- Run `./tools/test.sh`.
- Write self-review and test result docs.
- Mark `UI-METRIC-08` COMPLETE, promote dependency-satisfied tasks, write M2 phase review, update pointer, and commit.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| `PROCESS-13` plan boundary | Metric proof gets placed in planning docs. | Template/process wording. |
| `UI-METRIC-07` report output | Template references a nonexistent artifact. | `./tools/test.sh` metric report from standard test. |
| Future UI task completion | P0 failures can be ignored. | Commit/orchestration/queue proof docs. |
| Standard verification | Docs-only changes should not break tests. | `./tools/test.sh`. |

## Test Path

- `./tools/test.sh`

## Planned Completion Criteria

- Self-review template has UI metric review fields.
- Autopilot process requires UI metric report summary for UI tasks.
- Queue/commit proof says UI task completion includes P0 failures = 0.
- M2 phase review records UI-METRIC-05 through UI-METRIC-08 completion.
