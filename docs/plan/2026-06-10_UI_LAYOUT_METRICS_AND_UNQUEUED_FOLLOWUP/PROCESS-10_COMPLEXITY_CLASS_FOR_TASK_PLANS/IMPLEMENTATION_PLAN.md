# PROCESS-10 Implementation Plan

## Scope

- Add C1-C5 complexity classes to `docs/policy/PLANNING_POLICY.md`.
- Add the `SUB_TASKS.md` complexity header template.
- Define mandatory C4/C5 candidate, fallback/mirror, state/invariant, and dependency/test matrices.
- Run standard verification and write proof docs.

## Target Files

- `docs/policy/PLANNING_POLICY.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-10_COMPLEXITY_CLASS_FOR_TASK_PLANS/`
- `docs/review/autopilot/PROCESS-10_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/PROCESS-10_TEST_RESULT_2026-06-10.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Steps

- [x] Mark `PROCESS-10` RUNNING and create plan docs.
- [x] Update `PLANNING_POLICY.md` with complexity classes and templates.
- [x] Run `./tools/test.sh`.
- [x] Write self-review and test-result docs.
- [x] Mark `PROCESS-10` COMPLETE, promote `PROCESS-11` to READY, update proof, and commit.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Planning policy readers | Complexity classes unclear or too heavy. | Policy tables and PROCESS-10 self-review. |
| Future C4/C5 tasks | Required matrices missing. | Policy mandatory artifact list and future queue reviews. |
| Standard repo verification | Docs-only change still needs baseline proof. | `./tools/test.sh`. |

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] C1-C5 complexity classes exist.
- [x] `SUB_TASKS.md` complexity header template exists.
- [x] C4/C5 candidate matrix requirement exists.
- [x] C4/C5 fallback/mirror table requirement exists.
- [x] C4/C5 state/invariant table requirement exists.
