# UI-METRIC-06 P1 Acceptance Gate Sub Tasks

## Complexity

Class: C4
Reason:
- This task adds P1 report semantics on top of the shared layout metric evaluator.
- It covers several layout polish risks that should be reportable separately from P0 failure gating.
- It touches evaluator behavior, tests, docs, queue proof, and dependency sweep.

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
| Add `evaluate_p1()` to the evaluator. | Adopt | P1 issues need a stable machine-readable report. |
| Promote warn categories for resource rows, truncation, and dead area to P1 issues. | Adopt | These were measured by UI-METRIC-04 and are required P1 categories. |
| Add disabled-action-without-tooltip and summary-only task tab checks. | Adopt | These are required by UI-METRIC-06 and need metadata-assisted detection. |
| Test synthetic P1 fail/pass reports. | Adopt | It proves semantics without depending on current UI state. |
| Wire P1 to standard failing tests now. | Reject | `UI-METRIC-07` explicitly allows P1 to stay separate initially. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Standard P1 gate integration | `UI-METRIC-07` | already queued | P1 can stay separate initially. |
| UI task self-review metric reference | `UI-METRIC-08` | already queued | Template update depends on metric report availability. |
| Current UI repair from P1 issues | later screen/architecture task ids | policy-deferred | P1 report output must identify owning task before repair. |

## Scheduled Task

No scheduled task is added from this slice.
