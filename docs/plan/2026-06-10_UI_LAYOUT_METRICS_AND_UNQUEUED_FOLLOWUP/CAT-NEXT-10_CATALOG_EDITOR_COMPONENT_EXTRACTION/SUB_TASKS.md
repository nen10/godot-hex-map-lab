# Sub Tasks

## Complexity

Class: C4
Reason:
- Catalog behavior is currently split across Workspace screen snapshots and Paint/EditTool helper paths.
- The task changes editor architecture, visible Catalog contracts, and tests.
- Completion requires proof that Catalog owns entry list/detail/create/validate while Paint only consumes selected catalog keys.

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
| A. Move all Catalog UI into a full Control subclass | complete ownership | reject | Too large before the queued rich preview visual task. |
| B. Extract a Catalog editor component for entry data, validation, and create actions | focused ownership | adopt | Meets ownership proof while preserving existing visible behavior. |
| C. Only add owner metadata to existing Workspace methods | weak proof | reject | Paint/Workspace would still own normal Catalog editing behavior. |
| D. Remove Paint catalog helper UI entirely | strict separation | reject | Paint still needs catalog-key consumption and compatibility with current brush tests. |

## Adopted Sub-Tasks

| sub-task | scope | proof |
|---|---|---|
| `CAT-NEXT-10.01` | Add a dedicated Catalog editor component for entry rows, entry detail, previews, validation summaries, and create actions. | Component exposes owner rows for entry list/detail/create/validate. |
| `CAT-NEXT-10.02` | Route Workspace Catalog snapshot/action helpers through the component. | Catalog screen snapshot reports component ownership and existing screen tests pass. |
| `CAT-NEXT-10.03` | Route EditTool catalog list/status helper formatting through the component while preserving brush key selection. | Paint snapshot still hides catalog management while catalog rows remain valid. |
| `CAT-NEXT-10.04` | Add ownership contract assertions and docs proof. | `tests/test_editor_plugin.gd`, `docs/TEST.md`, and `./tools/test.sh`. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Rich tile / scene preview rendering | `CAT-NEXT-11` | defer | This task extracts ownership and keeps current preview text/state contracts. |
| Full Catalog visual redesign | `CAT-NEXT-11` | defer | Preview UI polish belongs with rich preview work. |
| Removing Paint catalog key selector | none | reject | Paint must keep catalog-key consumption for brush workflows. |
| Full Control subclass rewrite | none | reject | The adopted component is the smallest proof-bearing architecture slice. |

Scheduled task:

None. Existing queue items cover deferred preview and visual work.
