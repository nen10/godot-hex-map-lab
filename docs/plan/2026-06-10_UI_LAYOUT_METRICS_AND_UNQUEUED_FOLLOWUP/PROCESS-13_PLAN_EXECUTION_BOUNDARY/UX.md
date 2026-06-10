# PROCESS-13 UX

## User Goal

Codex should leave a plan that reads as the intended implementation before work began, and a separate execution proof that explains what actually changed, what deviated, and how it was verified.

## UX Candidate Matrix

| candidate | user value | risk | cost | decision | reason |
|---|---|---|---|---|---|
| A. Keep updating `IMPLEMENTATION_PLAN.md` as work is executed | low | high | low | reject | The original plan becomes indistinguishable from execution proof. |
| B. Keep `IMPLEMENTATION_PLAN.md` as pre-execution plan and write actuals in self-review | high | low | low | adopt | This preserves planning intent and gives execution proof a required home. |
| C. Require `EXECUTION_LOG.md` for all tasks | medium | medium | medium | reject | It creates unnecessary overhead for C1-C3 tasks. |
| D. Allow optional `EXECUTION_LOG.md` for C4/C5 or long tasks | high | low | low | adopt | Large tasks can keep detailed execution history without mutating the plan. |

## Adopted UX

- `IMPLEMENTATION_PLAN.md` records intended scope, target files, planned steps, planned test path, and planned completion criteria.
- Self-review records executed steps, changed files, deviations, acceptance proof, repair-now findings, and test result summary.
- Optional `EXECUTION_LOG.md` can be added when the actual execution has enough steps or deviations to need its own artifact.

## Deferred UX

- UI metric report fields in self-review remain owned by `UI-METRIC-08`.
- Existing completed plan docs are not rewritten.

## Experience Steps

1. Before implementation, create `IMPLEMENTATION_PLAN.md`.
2. During implementation, update plan only when the intended scope or design decision changes before acting.
3. After implementation, write actual changes and deviations in self-review or optional `EXECUTION_LOG.md`.
4. Queue proof links both the plan and the execution proof.

## Existing UX Interference

Previous tasks often used checked task lists inside implementation plans as execution progress. This task changes the forward process without rewriting those already-committed docs.
