# REPAIR-10 Handoff Issue Matrix

Date: 2026-06-22
Source: `docs/development_log/2026-06-21_BUILD_TAB_UX_IMPLEMENTATION_HANDOFF.md`

This matrix keeps the handoff uncertainties visible. It intentionally separates repair-now work from follow-up design work so implementation does not pretend that all Build graph confusion is solved by one viewport patch.

## Repair Now

| issue | handoff signal | decision | proof |
|---|---|---|---|
| Generate does not show in viewport | "結局viewportには表示できていない" | Fix top Generate and Simple Generate viewport projection. | viewport projection report + layer display cells |
| Context race | Generate depended on `build_context_requested.emit()` side effects | Add synchronous provider and inspect its result before run. | `set_build_context_provider` tests |
| Thumbnail confusion | square tile panel was mistaken for Generate result | Do not treat thumbnail/cache as completion proof. | snapshot field `node_thumbnail_secondary: true`; tests reject thumbnail-only proof |
| Result priority | Result node was added but proof unknown | Promote selected/terminal Result before other outputs. | vertical slice Result test |
| Reversible preview | Apply/Revert added but proof unknown | Snapshot document before projection; Apply/Revert mutate state explicitly. | Apply/Revert test |
| Apply failure | UI could imply success despite projection failure | Apply remains disabled unless projection success rule passes. | projection failure state in code/test coverage |
| Canvas height/readability | graph height, button placement, clipped node text called out | Hotfix layout only: dominant graph height and readable labels. | screen snapshot/layout contract |

## Follow-Up Required

| follow-up id | issue | why not in REPAIR-10 |
|---|---|---|
| `REPAIR-11_GRAPH_RESULT_MULTI_OVERLAY_CONTRACT` | Result should be `1 terrain + N overlay`, each overlay preserved separately. | Requires Resource/runtime contract expansion beyond viewport repair. |
| `REPAIR-12_INTERMEDIATE_OUTPUT_CHILD_NODES` | Intermediate terrain/overlay should not be mixed into the main scene node data. | Requires scene ownership/run-replace design. |
| `REPAIR-13_GRAPH_WIDE_STATE_AND_FILTER_SPLIT` | Old Generate state model, Region Filter item-key UX, Terrain Filter/Overlay Filter split. | Requires full node-state design and inspector redesign. |
| `REPAIR-14_GRAPH_CANVAS_EDGE_DELETE` | Edge deletion still reported broken. | Interaction model and GraphEdit event proof need separate task. |
| `REPAIR-15_MARKOV_ADJACENCY_MAPPING` | Markov Mesh and adjacency rules may not match old Generate intent. | Needs old-state parity audit and generation method mapping. |

## Rejected As Completion Proof

| rejected item | reason |
|---|---|
| Thumbnail-only preview | Proves output summary/cache, not viewport display. |
| Sample-only success | Samples are onboarding assets, not arbitrary project proof. |
| Cache-only tests | Graph cache can exist while viewport projection fails. |
| `display_used_cell_count()` alone | Cell count does not prove tree attachment, tile source readiness, or successful projection report. |
| Old roadmap COMPLETE status | Existing completion state is contradicted by the screenshot and handoff. |

## Code Unknowns To Keep Visible

| code area | current uncertainty | REPAIR-10 action |
|---|---|---|
| `HexTileMapLayer.ensure_display_tiles()` | Whether editor timing leaves display layers unready. | Projection report records `display_tiles_ready`, tree state, tile status, and used cells. |
| `HexMapDocumentApplier.prepare_document_apply()` | Whether generated layer order hides generated terrain behind old empty/manual layers. | Viewport apply uses a duplicated document with generated nonempty terrain ordered first for preview. |
| `HexGenerationPreset` | Simple Generate did not end at Result. | Preset graph ends in Result and selects Result. |
| `HexMapBuildGraphCanvas` slot types | Region Filter accepts terrain/overlay but GraphNode slot has one visual type; valid connection types are not registered. | Documented for follow-up; not solved by viewport repair. |
| `_run_region_filter` item-key mode | Handoff says overlay-only/dropdown is intended, current code also maps terrain item keys. | Follow-up state/filter split. |
| `_run_wall_field` / `_run_item_generator` | Markov/adjacency mapping may misunderstand old Generate. | Follow-up parity task. |
| edge deletion | Remove button removes selected node, but reported edge deletion is broken. | Follow-up interaction task. |
