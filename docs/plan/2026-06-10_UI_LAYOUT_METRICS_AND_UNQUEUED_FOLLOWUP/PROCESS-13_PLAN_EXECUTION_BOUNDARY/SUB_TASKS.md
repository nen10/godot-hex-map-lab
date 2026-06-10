# PROCESS-13 Plan Execution Boundary Sub Tasks

## Complexity

Class: C4
Reason:
- This task changes process rules for how future task plans and execution proof are recorded.
- It touches planning policy, queue proof expectations, and self-review template shape.
- If the boundary is vague, `IMPLEMENTATION_PLAN.md` can become a mutable execution log and hide deviations.

Required artifacts:
- Task Resolution candidate matrix
- Scheduled Task Audit
- UX Candidate Matrix
- Fallback / Mirror Handling table
- State / Invariant Table
- Dependency / Test Matrix
- Standard test proof

## Task Resolution Candidate Matrix

| candidate | decision | reason |
|---|---|---|
| Add a planning/execution boundary section to `PLANNING_POLICY.md`. | Adopt | The acceptance explicitly requires `IMPLEMENTATION_PLAN.md` to stay pre-execution. |
| Add an autopilot self-review template with execution summary and deviation sections. | Adopt | Execution results need a stable home. |
| Update queue completion proof rules to reference execution proof. | Adopt | Queue proof should point to self-review/execution log, not rely on mutating plans. |
| Require every task to create a separate `EXECUTION_LOG.md`. | Reject | Self-review is already required; a separate log should be optional for large tasks. |
| Rewrite previous completed task plans to remove checked boxes. | Reject | This rule is forward-looking and should not churn completed proof docs. |
| Stop writing `IMPLEMENTATION_PLAN.md` entirely. | Reject | Plans remain necessary; only the post-execution mutation boundary changes. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Mandatory `EXECUTION_LOG.md` for every task | none | rejected | Self-review template is sufficient for normal tasks; large tasks can add execution logs. |
| Retroactive rewrite of completed `IMPLEMENTATION_PLAN.md` files | none | rejected | Completed proof should remain stable. |
| UI metric self-review expansion | `UI-METRIC-08` | already queued | This task creates the generic boundary; UI metric report requirements are later. |

## Scheduled Task

No scheduled task is added from this slice.
