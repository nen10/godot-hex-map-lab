# SCREEN-32 Self Review

Task: `SCREEN-32_EXPORT_AS_HANDOFF`
Queue: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/IMPLEMENTATION_QUEUE.md`
Plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/SCREEN-32_EXPORT_AS_HANDOFF/`
Optional execution log: none

## Execution Summary

Export now opens on three Godot handoff purpose cards: `Runtime Map Resource (.tres)`, `Runtime Scene (.tscn)`, and `Generation Graph (.tres)`. The primary Runtime Map action keeps the existing `HexMapResource` export path, while new actions create a loadable `PackedScene` rooted at `HexTileMapLayer` and an embedded `HexGenerationGraphResource` for the runtime Map Build API. The secondary row exposes Debug Report, JSON Snapshot, and a disabled process-only Package action with tooltip.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/editor/hex_map_export_screen.gd` | Added purpose card and secondary action contracts plus mounted buttons. |
| `addons/hex_map_kit/editor/hex_map_export_workflow_state.gd` | Added card/action state to snapshots and exported-state matching for derived paths. |
| `addons/hex_map_kit/editor/hex_map_workspace.gd` | Added purpose card snapshots, runtime scene export, generation graph export, debug/json actions, and button dispatch. |
| `tests/test_editor_output.gd` | Covered 3 card visibility, package disabled behavior, scene export, graph export, JSON snapshot, and Debug Report action. |
| `docs/plan/.../IMPLEMENTATION_QUEUE.md` | Marked SCREEN-32 complete and advanced pointer to SCREEN-40. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| Target test file named `tests/test_editor_distribution.gd` in plan | Assertions were added to `tests/test_editor_output.gd` | Existing Export coverage already lives there and `./tools/test.sh` runs it. | none |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Runtime Map Resource card | pass | Snapshot exposes `runtime_map_resource`, title `Runtime Map Resource (.tres)`, action `Export .tres`, primary=true. |
| Runtime Scene card | pass | Snapshot exposes `runtime_scene`; test writes `.tscn`, reloads `PackedScene`, and instantiates `HexTileMapLayer`. |
| Generation Graph card | pass | Snapshot exposes `generation_graph_resource`; test saves and reloads `HexGenerationGraphResource` with `embed` semantics and no reference path. |
| Debug Report secondary action | pass | Test invokes secondary action and checks workspace report text. |
| JSON Snapshot secondary action | pass | Test writes JSON and checks purpose cards plus `gameplay_framework=false`. |
| Package process-only | pass | Snapshot and action result keep Package visible, disabled, process-only, and tooltip-bound to release/package process. |
| Gameplay framework boundary | pass | Scene/graph/json results explicitly carry `gameplay_framework=false`; no gameplay framework nodes are generated. |

## Experiential DoD (UI / graph task)

| item | result | evidence |
|---|---|---|
| What user sees first | pass | Export purpose panel shows the three handoff cards before destination details. |
| What user can do | pass | User can choose `.tres` map, `.tscn` scene, or graph `.tres`; secondary Debug Report and JSON Snapshot are available; Package is visibly disabled. |
| (graph task) chain runs | not applicable | This is an export handoff task; graph proof is save/load of the selected layer graph resource. |
| Label-heavy but metrics pass | no | Completion is backed by mounted buttons and end-to-end save/load assertions, not labels alone. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | `.godot_user/ui-metrics/20260615-182931-82510/workspace_layout_metrics.md` | Produced by `TEST_JOBS=4 ./tools/test.sh`. |
| P0 failures | `0` | Report total. |
| P1 issues | `0` | Report total. |
| UI metric applicability | UI task | Export first surface and action set changed. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| package build implementation | explicit process boundary | Package remains disabled/process-only; final dist remains `PROC-90_FINAL_DIST_REGEN`. |

## Repair-now Review

No repair-now issue remains.

## Test Review

- Command: `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/screen32-targeted/logs/test_editor_output.gd.log --path . --script res://tests/test_editor_output.gd`
- Result: pass; `res://tests/test_editor_output.gd: all tests passed`
- Command: `TEST_JOBS=4 ./tools/test.sh`
- Result: pass; run id `20260615-182931-82510`, UI metric P0 failures `0`, P1 issues `0`
- Notes: macOS certificate warnings and the existing `test_hex_tile_map_layer.gd` RID leak warning were non-fatal; all tests passed with exit `0`.
