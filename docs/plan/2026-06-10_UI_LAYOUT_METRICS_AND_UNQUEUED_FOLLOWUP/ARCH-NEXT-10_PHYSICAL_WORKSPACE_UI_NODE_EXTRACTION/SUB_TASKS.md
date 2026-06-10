## Complexity

Class: C4
Reason:
- The task changes physical Workspace UI construction across several tabs.
- The current Workspace owns both tab hosting and screen-specific Control creation.
- Completion needs code ownership proof, existing screen behavior preservation, and UI metric proof.

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
| A. Move every Workspace screen into new Control subclasses | maximal extraction | reject | Too large for one commit and would mix ownership extraction with visual redesign. |
| B. Move screen-specific Control construction into existing screen scripts as builders | ownership extraction | adopt | Existing scripts already define screen role contracts; builder methods can own physical node creation without changing visible UX. |
| C. Only add metadata/test proof and leave construction in Workspace | weak proof | reject | Does not satisfy the physical node construction extraction acceptance. |
| D. Split this task before implementation | scoped fallback | reject for now | The builder slice is small enough to complete with one commit and preserve current behavior. |

## Adopted Sub-Tasks

| sub-task | scope | proof |
|---|---|---|
| `ARCH-NEXT-10.01` | Add screen builder methods for Resources, Catalog, Layers, Validate, QA, Export, and Settings panels. | Screen scripts expose component builder ownership. |
| `ARCH-NEXT-10.02` | Update `HexMapWorkspace` mount methods to call screen builders and keep session/context/dispatcher wiring in Workspace. | Existing tab/component snapshots remain unchanged. |
| `ARCH-NEXT-10.03` | Add screen ownership contract tests for builder-owned components. | Headless tests verify each component maps to its screen script. |
| `ARCH-NEXT-10.04` | Run standard test and UI metric gate. | `./tools/test.sh` passes; P0 metric failures are zero. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Full visual redesign of Resources / Layers / Export | `SCREEN-NEXT-10` | defer | This task extracts construction ownership only. |
| Generate Dock internal component split | `ARCH-NEXT-11` | defer | Generate already mounts as a component; internal split is separate. |
| Catalog editor deep component extraction | `CAT-NEXT-10` | defer | This task only moves current Catalog node construction to the Catalog screen script. |
| New Control subclasses per screen | none | reject | Adds churn before visual redesign proves the component boundaries. |

Scheduled task:

None. Existing queue items cover deferred visual and internal component work.
