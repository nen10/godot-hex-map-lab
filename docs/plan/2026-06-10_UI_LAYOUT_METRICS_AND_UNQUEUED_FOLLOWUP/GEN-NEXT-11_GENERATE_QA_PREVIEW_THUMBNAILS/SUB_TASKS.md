# Sub Tasks

## Complexity

Class: C4
Reason:
- Generate and QA both consume generated candidate rows but expose different screen surfaces.
- The task adds a visible preview component plus a reusable data contract for current candidate, selected seed, and QA score rows.
- Completion needs proof that previews come from generated project candidate/document data, not bundled sample assets.

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
| A. Render thumbnails by instancing TileMapLayer/TileSet preview scenes | rich visual parity | reject | Too heavy for this slice and risks sample/catalog fallback behavior. |
| B. Add shared lightweight thumbnail Control backed by generated map/overlay/document data | visible connected preview | adopt | Provides real visual preview and testable snapshot without sample dependency. |
| C. Store only text summaries in score rows | weak preview | reject | Does not satisfy thumbnail acceptance. |
| D. Add cache/budget metadata with row preview snapshots | performance guard | adopt | Keeps row thumbnails bounded and avoids unbounded Control drawing. |
| E. Full QA score table redesign | richer comparison | defer | Covered by `QA-NEXT-10`. |

## Adopted Sub-Tasks

| sub-task | scope | proof |
|---|---|---|
| `GEN-NEXT-11.01` | Add shared `HexMapPreviewThumbnail` Control and snapshot builder. | Unit/editor tests inspect map/overlay/document preview snapshots. |
| `GEN-NEXT-11.02` | Wire Generate current candidate thumbnail and selected Seed Lab row thumbnail. | Generate output/screen snapshots expose candidate and selected seed preview. |
| `GEN-NEXT-11.03` | Add preview payloads to batch score rows and QA selected seed panel. | QA screen snapshot and score rows expose project-data previews. |
| `GEN-NEXT-11.04` | Add cache/budget metadata and tests. | Preview snapshots have bounded entries and non-sample source. |
| `GEN-NEXT-11.05` | Update docs, run tests, self-review, queue proof. | `./tools/test.sh` and UI metric report. |

## Scheduled Task Audit

| deferred / rejected item | existing queue id | decision | reason |
|---|---|---|---|
| Full QA score table visual redesign | `QA-NEXT-10` | defer | This task connects previews; table layout is separate. |
| GenerationResultResource/replay API | `GENPIPE-NEXT-10` | defer | Row preview payloads can exist before formal result resources. |
| Pipeline graph UI research | `GENPIPE-NEXT-20` | defer | Not needed for thumbnails. |
| TileSet/PackedScene-rendered thumbnail parity | none | reject for this task | Current acceptance needs data-connected thumbnails, not full renderer parity. |

Scheduled task:

None. Existing queue rows cover richer QA/table and generation pipeline work.
