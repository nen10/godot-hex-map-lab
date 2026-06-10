# Sub Tasks

## Complexity

Class: C4
Reason:
- The task changes the visible Validate issue navigator contract and row metadata.
- Completion requires mounted table proof plus route/action invariants for workspace asset and cell-scoped issues.
- The work must avoid fake per-row actions and preserve existing Validate routing behavior.

Required artifacts:
- Task resolution candidate matrix.
- Scheduled Task Audit.
- UX Candidate Matrix.
- Fallback / Mirror Handling table.
- State / Invariant Table.
- Dependency / Test Matrix.

## Task Resolution Candidate Matrix

| candidate | goal / UX | decision | reason |
|---|---|---|---|
| A. Add structured issue table snapshot with explicit columns | high | adopt | Gives tests and UI a clear severity/domain/scope/target/suggestion contract. |
| B. Add fake row buttons for every issue | low | reject | Acceptance requires only real per-issue actions. |
| C. Reuse existing issue selection route as the per-issue focus action | high | adopt | Selection already routes to the responsible screen/component. |
| D. Replace validation dashboard internals | low | reject | Existing dashboard already computes rows and fix suggestions. |

## Adopted Sub-Tasks

| sub-task | scope | proof |
|---|---|---|
| `VAL-NEXT-10.01` | Add Validate issue table columns and rich row fields. | Snapshot tests inspect columns and rows. |
| `VAL-NEXT-10.02` | Add real per-issue focus action metadata only for routable rows. | Tests inspect actions and selection route. |
| `VAL-NEXT-10.03` | Update mounted issue rows text to include severity/domain/scope/target/suggestion. | Mounted text assertions. |
| `VAL-NEXT-10.04` | Update docs, run tests, self-review, queue proof. | `./tools/test.sh` and UI metric report. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Validation traversal progress | `PERF-NEXT-11` | defer | This task is issue table UX, not traversal progress. |
| Debug overlay renderer | `ARCH-NEXT-22` | defer | Cell focus can route to Paint without renderer extraction. |
| Fake row actions | none | reject | Row actions must correspond to a working selection/focus route. |

Scheduled task:

None. Existing queue rows cover progress/debug overlay work.
