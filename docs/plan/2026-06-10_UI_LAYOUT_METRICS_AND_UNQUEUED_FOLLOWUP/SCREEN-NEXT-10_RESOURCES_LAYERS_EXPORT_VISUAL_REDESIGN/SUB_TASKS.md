# Sub Tasks

## Complexity

Class: C4
Reason:
- The task spans three visible workspace screens with separate state contracts.
- Completion requires mounted visual-state proof for Resources, Layers, and Export, plus snapshot/test coverage and UI metric proof.
- It must improve screen task clarity without absorbing the later Layer role editor, Paint affordance polish, or Export product decision tasks.

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
| A. Full multi-screen redesign with new controls and editing affordances | high | reject | Too broad and would absorb `LAYER-NEXT-10`, `PAINT-NEXT-10`, and `EXPORT-NEXT-10`. |
| B. Add grouped visual summaries and mounted labels to existing screen components | high | adopt | Satisfies clearer task surfaces while preserving existing workflows. |
| C. Add richer Resources readiness rows for node/document/dependency state | high | adopt | Directly addresses node/document/dependency acceptance. |
| D. Add Layer role tree summary with role/status/writable counts and rows | high | adopt | Directly addresses role tree acceptance without implementing role editing. |
| E. Add Export runtime handoff summary and readiness rows | high | adopt | Directly addresses runtime handoff acceptance without package-build decision scope. |

## Adopted Sub-Tasks

| sub-task | scope | proof |
|---|---|---|
| `SCREEN-NEXT-10.01` | Add Resources task surface rows for selected node, document, dependency groups, source badges, and next actions. | Snapshot and mounted-label tests. |
| `SCREEN-NEXT-10.02` | Add Layers role tree summary rows and role tree text for the mounted role panel. | Layer screen tests inspect role tree snapshot and mounted text. |
| `SCREEN-NEXT-10.03` | Add Export runtime handoff summary/readiness rows and mounted destination/status text. | Export tests inspect readiness rows and mounted text. |
| `SCREEN-NEXT-10.04` | Update docs, run tests, self-review, queue proof. | `./tools/test.sh` and UI metric report. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Fine-grained Layer role editing | `LAYER-NEXT-10` | defer | This task only clarifies the role tree surface. |
| Paint viewport affordance polish | `PAINT-NEXT-10` | defer | Paint interaction feedback is separate from Resources/Layers/Export surfaces. |
| Package build UI product decision | `EXPORT-NEXT-10` | defer | Runtime handoff clarity can improve before package-build placement is decided. |
| Full replacement of existing asset panels | none | reject | Existing typed asset slots already satisfy Resource selection policy. |

Scheduled task:

None. Existing queue rows cover the deferred interaction and product-decision scope.
