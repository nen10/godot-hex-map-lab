# PROCESS-13 Implementation Plan

## Scope

- Update `docs/policy/PLANNING_POLICY.md` so `IMPLEMENTATION_PLAN.md` is explicitly pre-execution planning proof.
- Add a self-review template that owns execution summary, changed files, deviations, acceptance, repair-now, and tests.
- Update queue operation proof rules to reference execution proof and optional execution logs.
- Run standard verification and write proof docs.
- Update queue status, dependency sweep, proof log, and current pointer.

## Target Files

- `docs/policy/PLANNING_POLICY.md`
- `docs/process/QUEUE_OPERATION_RULES.md`
- `docs/review/autopilot/SELF_REVIEW_TEMPLATE.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/PROCESS-13_PLAN_EXECUTION_BOUNDARY/`
- `docs/review/autopilot/PROCESS-13_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/PROCESS-13_TEST_RESULT_2026-06-10.md`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`

## Planned Steps

- Mark `PROCESS-13` RUNNING and create plan docs.
- Update `PLANNING_POLICY.md` with the plan/execution boundary.
- Add the self-review template.
- Update queue operation proof rules for execution proof.
- Run `./tools/test.sh`.
- Write self-review and test-result docs.
- Mark `PROCESS-13` COMPLETE, promote dependency-satisfied tasks, update proof, and commit.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| Planning policy | Future plans keep acting as execution logs. | New boundary section in `PLANNING_POLICY.md`. |
| Self-review process | Actual changes/deviations have no template home. | `SELF_REVIEW_TEMPLATE.md`. |
| Queue proof | Completion proof links plan but not execution actuals. | `QUEUE_OPERATION_RULES.md` proof fields. |
| UI metric self-review | This task conflicts with later UI metric template work. | `UI-METRIC-08` remains the owner for metric-specific fields. |
| Standard repo verification | Docs-only change still needs baseline proof. | `./tools/test.sh`. |

## Test Path

- `./tools/test.sh`

## Planned Completion Criteria

- `IMPLEMENTATION_PLAN.md` is documented as pre-execution planning proof.
- Executed checklist/deviation belongs to self-review or optional `EXECUTION_LOG.md`.
- Self-review template contains execution summary, changed files, deviation table, acceptance, repair-now, and tests.
- Queue proof can link execution proof separately from plan proof.
