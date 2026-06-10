# NEXT-00 Adopt UI Metric And Unqueued Feedbacks Sub Tasks

## Task Resolution

| candidate | decision | reason |
|---|---|---|
| Create a new follow-up roadmap instead of overwriting the completed Resource / State / Workspace refactor roadmap. | Adopt | The existing roadmap and queue are complete; these feedbacks describe the next body of work. |
| Queue both UI metric process tasks and the unqueued implementation requirements. | Adopt | The feedback explicitly asks to prevent future requirements from staying prose-only. |
| Put process guardrails before the larger UI/architecture work. | Adopt | Complexity, phase review, and fallback ledger reduce the same class of leakage during the next large tasks. |
| Put UI metric contract/gates before P0 UI extraction work. | Adopt | Future UI changes need measurable acceptance for scroll, no-op, debug leakage, generic picker, and state contradiction risks. |
| Start with a feedback-adoption task. | Adopt | It gives the new roadmap/queue a committed source-of-truth boundary before process and code tasks begin. |
| Create analog tests now. | Reject | Current policy defers new analog tests unless the user explicitly asks. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Analog tests | none | policy-deferred | User/project policy defers analog tests until explicitly requested. |
| Public package upload | none | policy-deferred | Human release step, not an autopilot queue task. |
| Dist freshness testization | `PROC-NEXT-90` | process-only | Final package regeneration remains outside normal `tools/test.sh`. |

## Scheduled Task

No extra scheduled task is added from this slice. The roadmap and queue include the feedback-proposed implementation and process tasks directly.
