# PROCESS-10 Complexity Class For Task Plans Sub Tasks

## Complexity

Class: C2
Reason:
- This task updates one process policy and its active task-plan templates.
- It does not change product code or UI behavior.
- It still needs explicit adoption/rejection choices because it changes future task planning obligations.

Required artifacts:
- Task Resolution
- Scheduled Task Audit
- UX Candidate Matrix
- Fallback / Mirror Handling check
- Standard test proof

## Task Resolution

| candidate | decision | reason |
|---|---|---|
| Add C1-C5 classes to `PLANNING_POLICY.md`. | Adopt | The feedback explicitly requires a complexity class model for task plans. |
| Add a required `SUB_TASKS.md` complexity header. | Adopt | The class must be visible before candidate resolution begins. |
| Require C4/C5 candidate, fallback, state, and dependency/test matrices. | Adopt | Broad tasks are where deferred/mirror work most often gets lost. |
| Add separate template files under `docs/templates/`. | Reject | The repo currently treats policy docs as the active template source; separate templates would duplicate policy. |
| Change existing completed task plan files retroactively. | Reject | The new policy governs future tasks; rewriting completed proof docs would add churn without improving current queue execution. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Separate docs/templates files | none | rejected | Policy remains the source template until a future process task explicitly creates template files. |
| Retroactive rewrite of old plan docs | none | rejected | Completed queue proof should remain stable. |

## Scheduled Task

No scheduled task is added from this slice.
