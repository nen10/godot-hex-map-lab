# PROCESS-11 UX

## User Goal

Codex should be able to close a roadmap phase with a compact, evidence-backed matrix that shows which tasks are complete, what debt remains, and what must become queue work next.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Keep phase close as free-form prose | low | high | low | reject | Prose-only defer is the failure mode this task is meant to prevent. |
| B. Add a required task score/debt/evidence/readiness matrix | high | low | low | adopt | It gives reviewers a scannable phase-level completion state. |
| C. Force all remaining debt into immediate READY tasks | medium | medium | medium | reject | Some debt may belong in backlog or a fallback ledger, but it must be explicitly classified. |
| D. Add a template in `docs/review/roadmap/` | high | low | low | adopt | Review authors need a copyable structure at the point they write phase proof. |

## Adopted UX

- Phase close produces one review matrix document.
- The matrix records each task's status, score, evidence, debt, and next-readiness result.
- Deferred or rejected prose must resolve into one of: existing queue id, new queue candidate, fallback ledger entry, explicit reject with reason, or policy-deferred reason.
- The review ends with the next queue action so a reader knows whether to continue, repair, split, or create follow-up work.

## Deferred UX

- No automated matrix generator is added in this slice.
- No old phase proof is rewritten.

## Experience Steps

1. Finish a phase's task-level queue updates and proof logs.
2. Check that no phase task remains `READY`, `RUNNING`, `VERIFYING`, `REPAIR_NOW`, or dependency-satisfied `BACKLOG`.
3. Create a phase review matrix from the template.
4. Convert all prose-only deferred items to queue candidates, ledger entries, or explicit decisions.
5. Update the queue pointer and dependency sweep using the matrix result.

## Existing UX Interference

This adds a phase-level review on top of existing task-level self-review. It should not duplicate every task detail; it should summarize evidence and expose remaining debt.
