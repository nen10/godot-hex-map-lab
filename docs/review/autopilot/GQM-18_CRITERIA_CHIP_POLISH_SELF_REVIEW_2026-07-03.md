# GQM-18 Criteria Chip Polish Self Review

Task: `GQM-18_CRITERIA_CHIP_POLISH`  
Queue: `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md`  
Plan: queue row contract + user contract `GQM-18_CRITERIA_CHIP_POLISH`

## Execution Summary

Implemented the four polish findings: raw `*_asset_path` inspector rows are hidden by schema declaration, criteria chips now own Load/Save/Detach asset actions, unconnected adaptation/Result rows have a separate `未接続` state, and consolidated node titlebar name fields reserve and expand width.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/generation/hex_generation_param_schema.gd` | Added `hidden: true` to `distribution_asset_path`, `item_pool_asset_path`, and `rules_asset_path`. |
| `addons/hex_map_kit/editor/hex_generation_criteria_ui.gd` | Added shared chip menu, asset load/save/detach, and params/resource conversion helpers using `HexMapAssetLibrary`. |
| `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd` | Filters hidden schema entries out of inspector rows and renders criteria chips as asset operation menus. |
| `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd` | Adds titlebar chip menus, wider/expanding display-name field, unconnected adaptation labels, and unconnected Result row resolution. |
| `tests/test_build_graph_canvas.gd` | Covers unconnected vs connected selection adaptation, Result unconnected vs unused rows, and titlebar width/menu behavior. |
| `tests/test_editor_generation.gd` | Covers hidden raw asset path rows and chip menu Load/Detach params mutation without path labels in menu UI. |
| `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md` | Marks GQM-18 complete. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| none | none | none | none |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Hide raw `*_asset_path` LineEdit rows | pass | `tests/test_editor_generation.gd` asserts param fields and mounted rows exclude all three raw asset path keys. |
| Chip is the asset operation path | pass | Inspector and canvas titlebar chips are `MenuButton`s with `Load from asset...`, `Save as asset...`, `Detach to inline`; Load/Detach mutate params through `HexMapAssetLibrary`. |
| Unconnected input rows differ from connected selection rows | pass | `tests/test_build_graph_canvas.gd` asserts unconnected rows show `未接続` and no dropdown, while connected selection remains `そのまま (selection)` with dropdown. |
| Result empty row differs from connected unused row | pass | `tests/test_build_graph_canvas.gd` asserts empty Result row is `未接続`; connected selection/extra terrain rows remain `unused` with reasons. |
| Titlebar node name field has width | pass | `tests/test_build_graph_canvas.gd` asserts min width >= 220 and horizontal expand flag. |

## Experiential DoD (UI / graph task)

| item | result | evidence |
|---|---|---|
| What user sees first | pass | Inspector no longer presents raw path text rows; node titlebar shows a readable name field and criteria chip menus. |
| What user can do | pass | User can open editor, load an asset by display name, save current criteria as an asset, or detach back to inline from the chip menu. |
| (graph task) chain runs | pass | Existing graph canvas and full test suite still run; GQM-18 only changes row/chip presentation and params mutation. |
| Label-heavy but metrics pass | no | The change removes misleading labels/dropdowns and raw path text rather than adding explanatory clutter. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | pass | `.godot_user/ui-metrics/20260703-082916-34691/workspace_layout_metrics.md` |
| P0 failures | `0` | Report records `total_p0_failures: 0`. |
| P1 issues | `0` | Report records `total_p1_issues: 0`. |
| UI metric applicability | UI task | Graph/editor row presentation changed. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| Visual capture confirmation | policy | User contract states merge-after orchestrator owns actual rendering capture confirmation for GQM-18. |

## Repair-now Review

No repair-now issue remains.

## Test Review

- Command: focused `res://tests/test_build_graph_canvas.gd`
- Result: exit `0`
- Notes: Passed after GQM-18 row/menu/titlebar assertions.

- Command: focused `res://tests/test_editor_generation.gd`
- Result: exit `0`
- Notes: Passed after GQM-18 hidden asset path and chip menu assertions.

- Command: `./tools/test.sh`
- Result: exit `0`; run id `20260703-082916-34691`
- Notes: Required one local Godot import-cache generation because `.godot/` was absent; final standard run passed. macOS certificate warnings were non-fatal.
