## Complexity

Class: C4
Reason:
- `hex_map_gen_dock.gd` is a large mixed UI/state/action file.
- The task touches visible Generate controls, state binding, and editor tests.
- Completion needs ownership proof without changing generation behavior.

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
| A. Rewrite Generate Dock into full Control subclasses | complete split | reject | Too large and would mix architecture with visual redesign. |
| B. Move key physical control groups into builder scripts | component ownership | adopt | Satisfies internal split proof while preserving current behavior. |
| C. Only add registry metadata | weak proof | reject | Does not move physical construction out of the dock. |
| D. Split task as C5 | delayed proof | reject for now | The builder slice is small enough to complete with existing tests. |

## Adopted Sub-Tasks

| sub-task | scope | proof |
|---|---|---|
| `ARCH-NEXT-11.01` | Add Generate component builder scripts for run/progress, source registry, output target, and result/preview summary controls. | Builder scripts expose component ownership rows. |
| `ARCH-NEXT-11.02` | Update `HexMapGenDock` to call builders and keep orchestration/state binding. | Existing generation tests pass. |
| `ARCH-NEXT-11.03` | Add component ownership snapshot/contract tests. | Headless tests verify builder ids and screen ownership. |
| `ARCH-NEXT-11.04` | Run standard and UI metric verification. | `./tools/test.sh` passes with P0 metric failures = 0. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Full Generate visual layout redesign | `GEN-NEXT-10` | defer | This task is architecture ownership only. |
| Generate / QA preview thumbnails | `GEN-NEXT-11` | defer | Thumbnail rendering is visual/product work, not physical builder extraction. |
| Generation private flag mirror retirement | `STATE-NEXT-11` | defer | This task keeps existing state fields and behavior. |
| Complete subclass rewrite of Generate Dock | none | reject | Too much churn before state and visual follow-ups. |

Scheduled task:

None. Existing queue items cover deferred visual/state work.
