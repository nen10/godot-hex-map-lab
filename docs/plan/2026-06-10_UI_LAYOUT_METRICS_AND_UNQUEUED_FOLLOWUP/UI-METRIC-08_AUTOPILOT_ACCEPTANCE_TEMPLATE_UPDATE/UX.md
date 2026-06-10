# UI-METRIC-08 UX

## User Goal

Future autopilot UI tasks should show, in their self-review, which metric report was used and whether P0 failures were zero, so completion proof is easy to audit.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Add metric fields to self-review template | high | low | low | adopt | It puts evidence where reviewers already look. |
| B. Put metric report in implementation plan | low | high | low | reject | Execution evidence does not belong in pre-execution planning proof. |
| C. Update autopilot loop/checklists | high | low | low | adopt | It prevents future UI tasks from omitting P0 evidence. |
| D. Require P1 zero now | medium | medium | low | reject | P1 remains report-only initially. |

## Adopted UX

- Self-review includes a UI metric review section.
- UI tasks record metric report path, P0 failures, P1 issues, and applicability.
- Process docs require P0 failures = 0 for UI task completion.

## Deferred UX

- P1 zero-failure completion remains deferred.
- Manual visual proof remains task-specific.

## Experience Steps

1. Run `./tools/test.sh`.
2. Copy metric report path and P0/P1 counts into self-review for UI tasks.
3. Do not mark UI task complete if P0 failures are nonzero.

## Existing UX Interference

This task changes process only. It does not alter product UI behavior or metric evaluator semantics.
