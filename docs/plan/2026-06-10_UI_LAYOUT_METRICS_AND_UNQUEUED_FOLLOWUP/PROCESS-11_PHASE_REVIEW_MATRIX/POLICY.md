# PROCESS-11 Policy

## Adopted Decisions

- Phase review matrix rules live in `docs/process/QUEUE_OPERATION_RULES.md`.
- The reusable template lives in `docs/review/roadmap/PHASE_REVIEW_MATRIX_TEMPLATE.md`.
- Phase review is required when a phase is being closed or advanced past, not for every individual task.
- Phase review must classify all deferred/prose-only items before the phase can be considered closed.

## Rejected Decisions

- Do not add a script or test runner for matrix enforcement in this task.
- Do not force all deferred items to become immediate `READY` tasks.
- Do not retroactively rewrite earlier task proof docs.

## Invariants

- A closed phase must not contain unclassified prose-only deferred work.
- Every task in the phase review has a score, proof link, debt classification, and next-readiness result.
- Queue pointer changes must remain explainable from dependency sweep plus phase review output.
- `COMPLETE_WITH_BACKLOG` is acceptable only when the backlog item is named and tracked.

## Fallback / Mirror Handling

| item | decision | why | removal condition | test |
|---|---|---|---|---|
| Prose-only deferred item | forbid at phase close | Deferred work can disappear if it is only written in narrative review text. | It is mapped to queue candidate, fallback ledger, explicit reject, or policy-deferred reason. | Phase review matrix deferred conversion table. |
| Fallback/mirror/debug/sample debt | track, do not hide | These categories were called out by feedback as common sources of lingering debt. | Owner/status/removal condition is recorded in queue or ledger. | Phase review matrix plus future fallback ledger task. |
| Automation for phase matrix | reject for this slice | The process can be made concrete with a template before scripts exist. | A later task explicitly schedules automation. | `./tools/test.sh` and self-review. |

## State / Invariant Table

| state/source | invariant | risk | proof/test |
|---|---|---|---|
| Phase still has active task | Do not close the phase review as ready. | Review hides unfinished work. | Queue rule lists statuses that block phase close. |
| Phase task marked `COMPLETE_WITH_BACKLOG` | Backlog item must be named and tracked. | Nonblocking debt remains prose-only. | Matrix debt/readiness columns. |
| Deferred prose in self-review or plan | Must map to queue candidate, ledger, explicit reject, or policy-deferred reason. | Future work is lost. | Deferred conversion table in template. |
| Dependency sweep after phase review | Current pointer reflects the first valid `READY` task. | Next task selection skips a dependency. | Queue operation rules dependency sweep. |

## Resource / API / UI Boundary

- This task changes process docs and review templates only.
- Product Resource APIs and UI behavior are unchanged.
