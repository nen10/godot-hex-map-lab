# PROCESS-13 Policy

## Adopted Decisions

- `IMPLEMENTATION_PLAN.md` is pre-execution planning proof.
- Executed steps, changed files, deviations, and final acceptance status belong in self-review or optional `EXECUTION_LOG.md`.
- Queue proof must link plan and self-review separately.
- Optional `EXECUTION_LOG.md` is allowed for C4/C5 tasks or long-running tasks with notable deviations.

## Rejected Decisions

- Do not require a separate execution log for every task.
- Do not rewrite historical plan docs.
- Do not remove implementation plans from the planning workflow.
- Do not let self-review omit deviations by claiming the plan was updated.

## Invariants

- Plan and execution proof are distinct artifacts.
- A reader can tell what was intended before implementation and what actually happened.
- Deviation from plan is not a failure if it is recorded and tested.
- Queue completion proof links the execution proof.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Checked execution boxes inside future `IMPLEMENTATION_PLAN.md` | discourage | They make the plan double as a mutable execution log. | Actual status moves to self-review or execution log. | Policy text and self-review template. |
| Missing deviation record | forbid | It hides scope changes and proof gaps. | Self-review includes deviation table, even when empty. | Self-review template. |
| Optional `EXECUTION_LOG.md` | allow for large tasks | Some tasks need richer execution history than self-review can hold. | None | Queue proof can link it when present. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Pre-execution plan | Shows intended scope and planned proof, not final status. | Plan becomes rewritten history. | `PLANNING_POLICY.md` boundary section. |
| Self-review | Shows actual changes, deviations, acceptance, repair, and tests. | Execution proof is scattered or missing. | Self-review template. |
| Optional execution log | Used only when self-review would be too compressed. | Excess process overhead on simple tasks. | Policy states optional use. |
| Queue proof | Links both planning and execution proof. | Completion proof is ambiguous. | `QUEUE_OPERATION_RULES.md` proof update. |

## Resource / API / UI Boundary

- This task changes process docs and review templates only.
- Product Resource APIs and UI behavior are unchanged.
