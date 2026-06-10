# UI-METRIC-07 Test.sh Integration Sub Tasks

## Complexity

Class: C4
Reason:
- This task connects runtime UI metric reports to standard verification.
- It introduces report file output and P0 failure enforcement in `tools/test.sh`.
- It must preserve P1 as report-only while making P0 failures actionable.

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
| Add a dedicated Workspace metric gate test script. | Adopt | It keeps report execution separate from evaluator unit tests. |
| Write JSON and Markdown reports under `.godot_user/ui-metrics/<run-id>/`. | Adopt | This is required acceptance and gives self-review a stable artifact. |
| Run P0 gate from `tools/test.sh`. | Adopt | This task owns standard P0 integration. |
| Keep P1 report in output but do not fail standard tests on P1. | Adopt | Queue acceptance explicitly says P1 can stay separate initially. |
| Gate all possible viewport sizes immediately. | Reject | Start with representative scenarios/sizes; later tasks can expand. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| UI task self-review template requiring metric report | `UI-METRIC-08` | already queued | This task creates the artifact first. |
| P1 failure integration | none | policy-deferred | Roadmap says P1 can stay separate initially; revisit after P0 flow is stable. |
| Expanded viewport matrix | later metric/UI task | policy-deferred | Initial report covers representative scenarios without exploding test time. |

## Scheduled Task

No scheduled task is added from this slice.
