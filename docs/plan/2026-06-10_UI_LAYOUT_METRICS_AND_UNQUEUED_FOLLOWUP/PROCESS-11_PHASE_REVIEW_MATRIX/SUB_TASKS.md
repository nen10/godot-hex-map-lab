# PROCESS-11 Phase Review Matrix Sub Tasks

## Complexity

Class: C3
Reason:
- This task updates queue operation rules and adds a reusable review template.
- It affects future phase-close behavior, dependency sweep, and deferred-item handling.
- It does not change product code, but incomplete process wording could let prose-only debt escape the queue.

Required artifacts:
- Task Resolution
- Scheduled Task Audit
- UX Candidate Matrix
- Fallback / Mirror Handling check
- State / Invariant Table
- Dependency / Test Matrix
- Standard test proof

## Task Resolution

| candidate | decision | reason |
|---|---|---|
| Add a phase review matrix section to `QUEUE_OPERATION_RULES.md`. | Adopt | The acceptance requires phase completion to record score, debt, evidence, and next readiness. |
| Add a reusable phase review matrix template under `docs/review/roadmap/`. | Adopt | Future phase reviews need a concrete document shape rather than prose instructions only. |
| Require prose-only deferred items to become queue candidates, ledger entries, or explicit rejects. | Adopt | This is the core guardrail from the feedback. |
| Require a phase review for every single task completion. | Reject | Task-level proof already exists; the phase review should run when a phase is ready to close. |
| Create a new script to enforce the review matrix. | Reject | This process slice is documentation/template only; metric automation is covered by later UI-METRIC tasks. |
| Rewrite previous phase proof retroactively. | Reject | Current proof remains stable; the process applies to future phase closures. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Scripted enforcement for phase review matrix | none | rejected | No automation is needed for this process slice; later metric tasks cover tooling. |
| Retroactive phase review for completed M0 work | none | rejected | The current task defines future phase-close behavior and should not rewrite completed proof docs. |
| Every-task phase review | none | rejected | Task self-review and proof log already cover task-level completion. |

## Scheduled Task

No scheduled task is added from this slice.
