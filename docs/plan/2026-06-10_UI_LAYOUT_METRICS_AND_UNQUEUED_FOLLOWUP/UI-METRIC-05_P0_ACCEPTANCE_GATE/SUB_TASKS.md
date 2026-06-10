# UI-METRIC-05 P0 Acceptance Gate Sub Tasks

## Complexity

Class: C4
Reason:
- This task promotes selected runtime metric categories from warn-only signal to P0 failure report semantics.
- It must define fail/passed report behavior without prematurely wiring actual Workspace gate execution into `tools/test.sh`.
- It touches shared evaluator behavior, tests, docs, and queue dependency sweep.

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
| Add `evaluate_p0()` to the existing evaluator. | Adopt | P0 gate should reuse warning detection and expose fail semantics. |
| Convert P0 categories into `failure_count` and `passed=false`. | Adopt | Later integration can consume a stable gate report. |
| Add P0 categories for sample fallback and unreachable primary action. | Adopt | These are required by UI-METRIC-05 but were not needed for warn-only coverage. |
| Test synthetic P0 failures without failing the script. | Adopt | The test proves fail semantics while standard integration remains later. |
| Wire actual Workspace P0 gate into `tools/test.sh` now. | Reject | Queue row `UI-METRIC-07` owns standard test gate/report output integration. |
| Repair current product UI P0 findings now. | Reject | This task creates the gate; repair belongs to later UI/architecture tasks after integration reveals actual failures. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Actual `tools/test.sh` P0 gate over current Workspace report | `UI-METRIC-07` | already queued | This task only creates the P0 gate report/API. |
| P1 acceptance gate | `UI-METRIC-06` | already queued | P1 categories require different thresholds. |
| UI task completion template requiring P0 failures = 0 | `UI-METRIC-08` | already queued | Depends on gate/report integration. |
| Current UI repair from P0 failures | later screen/architecture task ids | policy-deferred | Actual findings are classified after integration, then repaired by owning UI tasks. |

## Scheduled Task

No scheduled task is added from this slice.
