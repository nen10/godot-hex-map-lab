# Sub Tasks

## Complexity

Class: C4
Reason:
- Generate is a large editor screen where inputs, source/profile controls, preview/result state, apply/save actions, and performance state share one scrolling surface.
- The task changes visible layout grouping and the screen snapshot contract, while generation behavior must remain stable.
- Completion needs UI metric proof plus tests that the new grouping is not only visual prose.

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
| A. Full Generate screen rewrite with new subclasses | maximum visual reset | reject | Too much churn for one queue item and would duplicate `ARCH-NEXT-11` ownership work. |
| B. Add named layout sections around existing component groups and expose section snapshot proof | clear first impression | adopt | Separates Input/Profile/Preview/Apply/Save/Performance while preserving behavior and component builders. |
| C. Only rename buttons/status labels | weak clarity | reject | Does not visually separate state groups or prove layout structure. |
| D. Add map thumbnails now | rich preview | defer | Covered by `GEN-NEXT-11`; this task should not invent thumbnail rendering. |
| E. Move generation pipeline into graph/resource UI | pipeline clarity | defer | Covered by `GENPIPE-NEXT-10` and `GENPIPE-NEXT-20`. |

## Adopted Sub-Tasks

| sub-task | scope | proof |
|---|---|---|
| `GEN-NEXT-10.01` | Define Generate layout sections and button-purpose contract in plan artifacts. | C4 tables present. |
| `GEN-NEXT-10.02` | Group existing controls into Input, Profile/Source, Preview, Apply/Save, and Performance sections. | Mounted section snapshot contains every required section and component mapping. |
| `GEN-NEXT-10.03` | Keep output target, save, apply, and progress state bound to existing ViewState/report data. | Existing NODE-24 and progress tests pass. |
| `GEN-NEXT-10.04` | Add tests for layout separation and action purpose clarity. | Headless test asserts section ids, component ids, action purposes, and no missing section. |
| `GEN-NEXT-10.05` | Run standard verification and record review/queue proof. | `./tools/test.sh` passes with UI metric P0 failures = 0. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Generate / QA preview thumbnails | `GEN-NEXT-11` | defer | Visual map preview rendering is the next queue item and needs candidate/document data rendering decisions. |
| QA score table visual redesign | `QA-NEXT-10` | defer | QA comparison is separate from the Generate tab first impression. |
| GenerationResultResource and replay API | `GENPIPE-NEXT-10` | defer | This task can clarify current preview/document state without changing pipeline resources. |
| Pipeline graph UI research | `GENPIPE-NEXT-20` | defer | The graph decision belongs after result resource scope exists. |
| Generation private flag mirror retirement | `STATE-NEXT-11` | defer | Layout proof should read existing state; it should not remove private mirrors. |
| Full Control subclass rewrite | none | reject | Current builder split is sufficient for this layout slice. |

Scheduled task:

None. Existing queue rows cover thumbnails, QA redesign, generation pipeline, and state retirement.
