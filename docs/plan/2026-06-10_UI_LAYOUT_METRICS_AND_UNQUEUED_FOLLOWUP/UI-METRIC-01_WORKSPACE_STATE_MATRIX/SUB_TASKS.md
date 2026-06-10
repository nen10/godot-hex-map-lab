# UI-METRIC-01 Workspace State Matrix Sub Tasks

## Complexity

Class: C4
Reason:
- This task defines scenario-level Workspace state contracts across root, Resources, Generate, Paint, Validate, QA, Export, Settings, sample, and debug states.
- It feeds later runtime layout snapshot and state contradiction metrics.
- It must keep sample/debug/manual override/fallback behavior explicit without implementing the evaluator now.

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
| Create `docs/ui/WORKSPACE_STATE_MATRIX.md`. | Adopt | This is the required deliverable. |
| Cover the minimum state list from UI layout metric policy. | Adopt | Later scenario builders need stable state ids. |
| Define expected and forbidden visible output per state. | Adopt | State contradiction metrics need both sides. |
| Link states to state sources and likely tabs. | Adopt | It prevents tests from reading private booleans or private node names. |
| Implement scenario builder code now. | Reject | `UI-METRIC-03` owns runtime scenario builder/snapshot code. |
| Add failing state contradiction tests now. | Reject | Gates and enforcement start later. |
| Model every possible intermediate state now. | Reject | This matrix defines foundation states; future tasks can add rows with review. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Runtime scenario builder | `UI-METRIC-03` | already queued | This task is state contract docs only. |
| State contradiction evaluator | `UI-METRIC-04`, `UI-METRIC-05` | already queued | Warn-only and P0 gate tasks own implementation/enforcement. |
| Additional polish states from future screen work | later screen tasks | already queued | Screen-specific tasks may extend the matrix as they change UX. |

## Scheduled Task

No scheduled task is added from this slice.
