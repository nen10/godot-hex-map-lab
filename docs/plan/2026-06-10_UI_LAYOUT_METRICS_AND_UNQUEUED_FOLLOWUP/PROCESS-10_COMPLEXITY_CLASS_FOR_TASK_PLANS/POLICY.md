# PROCESS-10 Policy

## Adopted Decisions

- Complexity classes live in `docs/policy/PLANNING_POLICY.md`.
- `SUB_TASKS.md` owns the class declaration because it is the first task planning artifact.
- C4/C5 tasks require candidate, fallback/mirror, state/invariant, and dependency/test matrices.
- C5 tasks must split into scheduled queue tasks when one completion commit cannot prove the whole goal.

## Rejected Decisions

- Do not create duplicate template files in this task.
- Do not rewrite old completed task plans.
- Do not allow broad tasks to skip fallback/mirror review just because the code change seems straightforward.

## Invariants

- Planning overhead should scale with risk and blast radius.
- Small C1/C2 tasks must stay lightweight enough to keep autopilot moving.
- Broad C4/C5 tasks must not leave deferred work prose-only.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Existing Fallback / Mirror Handling table | keep and strengthen | The table already exists but was not tied to task scale. | none | Policy review and future task plans. |
| C4/C5 skipped state table | forbid | State omission is a common source of UI contradiction and mirror debt. | none | Policy text and self-review. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| C1/C2 small task | Planning remains short and actionable. | Process overhead slows simple fixes. | Required artifacts table limits C1/C2 requirements. |
| C4 architecture/UI/process task | Fallback/mirror/state risks are explicit before implementation. | Deferred work remains prose-only. | Mandatory C4/C5 tables in policy. |
| C5 phase-scale task | Completion boundary is split if proof would be vague. | One commit claims too much. | C5 split rule references scheduled tasks and `RESOLUTED` status. |

## Resource / API / UI Boundary

- This task changes process policy only.
- Product code, Resource APIs, and UI behavior are unchanged.
