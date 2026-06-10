# UI-METRIC-08 Autopilot Acceptance Template Update Sub Tasks

## Complexity

Class: C4
Reason:
- This task updates shared autopilot process expectations after metric gate integration.
- It changes completion proof templates and commit/process guardrails used by later UI tasks.
- It must preserve the plan/execution boundary from `PROCESS-13`.

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
| Add UI metric review fields to `SELF_REVIEW_TEMPLATE.md`. | Adopt | UI task self-review must reference metric report and P0 status. |
| Update autopilot orchestration. | Adopt | The loop must tell future runs to include metric report summary for UI tasks. |
| Update queue proof rules. | Adopt | Completion proof should know where metric report evidence belongs. |
| Update commit checklist. | Adopt | UI tasks should not commit complete with missing P0 evidence. |
| Change `IMPLEMENTATION_PLAN.md` execution boundary. | Reject | Metric proof is execution evidence and belongs in self-review/test result, not planning docs. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Metric report inside future `IMPLEMENTATION_PLAN.md` | none | rejected | Would violate `PROCESS-13` plan/execution boundary. |
| P1 standard failure requirement | none | policy-deferred | `UI-METRIC-07` intentionally keeps P1 report-only initially. |
| Manual UI screenshot proof | none | policy-deferred | Metric report is required automated proof; manual/screenshot proof remains task-specific if requested. |

## Scheduled Task

No scheduled task is added from this slice.
