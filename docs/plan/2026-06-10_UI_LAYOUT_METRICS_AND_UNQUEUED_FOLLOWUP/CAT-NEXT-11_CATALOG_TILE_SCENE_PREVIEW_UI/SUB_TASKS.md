# Sub Tasks

## Complexity

Class: C4
Reason:
- Catalog entry detail is a visible workspace surface and must satisfy first-impression completion, not just data availability.
- The task needs a dedicated rendered preview component, unavailable-state badges/tooltips, snapshot exposure, tests, and UI metric proof.
- Atlas and scene entries have different source contracts and validation failure modes.

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
| A. Keep text-only `preview_text` in entry detail | lowest cost | reject | Text-only detail does not satisfy rich tile / scene preview acceptance. |
| B. Add a Catalog-specific preview Control with atlas texture-region and scene-glyph rendering | visible preview | adopt | Keeps Catalog semantics separate from map thumbnail data and supports mounted UI proof. |
| C. Reuse `HexMapPreviewThumbnail` for Catalog entries | shared component | reject | That component is cell-map oriented; overloading it would blur preview contracts. |
| D. Render unavailable states as explicit badge plus tooltip | validation clarity | adopt | Missing TileSet/source/scene/placeholder states need visible explanation without path/raw JSON UI. |
| E. Add full TileSet editor-style tile inspector | rich inspection | defer | Larger editor inspector belongs outside this slice; current acceptance is preview detail. |

## Adopted Sub-Tasks

| sub-task | scope | proof |
|---|---|---|
| `CAT-NEXT-11.01` | Add Catalog preview snapshot/render component for atlas and scene entries. | Headless tests inspect control snapshot and render kind. |
| `CAT-NEXT-11.02` | Wire mounted Catalog detail panel with preview control and unavailable badge/tooltip. | Workspace test finds mounted preview/badge and snapshot state. |
| `CAT-NEXT-11.03` | Expose preview detail snapshot from `catalog_screen_snapshot()`. | Catalog screen snapshot tests assert atlas/scene/missing states. |
| `CAT-NEXT-11.04` | Update docs, run tests, self-review, queue proof. | `./tools/test.sh` and UI metric report. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Full TileSet editor-style inspector | none | reject for this task | Current acceptance needs detail preview, not an alternate TileSet editor. |
| Full table/card redesign for Catalog list | none | reject for this task | Entry list already exists; acceptance targets detail preview. |
| Paint-side catalog preview duplication | `PAINT-NEXT-10` | defer | Paint should consume catalog keys; Catalog owns entry management. |
| Sample catalog preview fallback | none | reject | Production preview must come from selected project catalog resources or explicit unavailable state. |

Scheduled task:

None. Existing queue rows cover Paint affordances and broader screen redesign work.
