# RUNTIME-51 Self Review

Task: `RUNTIME-51_GRAPH_LOAD_AND_CONTEXT_OWNERSHIP`
Queue: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/IMPLEMENTATION_QUEUE.md`
Plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/RUNTIME-51_GRAPH_LOAD_AND_CONTEXT_OWNERSHIP/`
Optional execution log: none

## Execution Summary

Added graph load context ownership using the existing selected `HexTileMapLayer` tracking. Build now exposes `Load Graph` plus an off-by-default overwrite checkbox. Default load creates a new `HexTileMapLayer`, copies the graph and embedded semantics, selects the new node, and restores the graph canvas. Opt-in overwrite assigns the graph to the selected layer and replaces only generated document resources while preserving manual Paint/document layers.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/editor/hex_map_graph_instantiator.gd` | New graph-to-layer instantiator with default embed-copy and overwrite merge paths. |
| `addons/hex_map_kit/editor/hex_map_build_screen.gd` | Added `Load Graph` action, overwrite checkbox, graph restore API, and snapshot fields. |
| `addons/hex_map_kit/editor/hex_map_workspace.gd` | Added graph resource/path load APIs, file dialog wiring, selected-node ownership reuse, and snapshot proof. |
| `tests/test_graph_load_context.gd` | Added default load, overwrite preservation, path load, and UI control tests. |
| `tools/test.sh` | Added graph load context test to the standard suite. |
| `docs/TEST.md` | Added graph load context test to standard target list. |
| `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` | Recorded test responsibility. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| Factory reuse | Implemented as `HexMapGraphInstantiator` and reused `HexMapDocumentAdapter.duplicate_document()` for embedded document copies. | The existing factory creates slot resources, while graph load needs graph-to-node instantiation and generated-layer merge. | none |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Default load creates new node | pass | `test_graph_load_context.gd` asserts `created_layer=true`, selected node changes to the new layer, and existing node remains unchanged. |
| Default semantics are embed/copy | pass | Test asserts graph resource and embedded document are duplicated and reference path is cleared. |
| Overwrite is opt-in and off by default | pass | Build snapshot asserts overwrite checkbox exists and starts unchecked. |
| Overwrite generated only | pass | Test asserts old generated overlay is removed, new generated overlay is present, and manual overlay remains. |
| Single context owner | pass | Tests assert selected node is the loaded/overwritten `HexTileMapLayer`; no independent graph context owner is created. |
| Graph opens into editable canvas | pass | Workspace calls `HexMapBuildScreen.load_graph_resource()` and tests assert `screen_load_result.ok`. |
| Path load uses same path | pass | Test saves a graph resource, loads it by path, creates a new selected layer. |

## Experiential DoD (UI / graph task)

| item | result | evidence |
|---|---|---|
| What user sees first | pass | Build top row contains `Load Graph`, off-by-default `Overwrite selected`, and primary `Generate`; graph canvas remains first surface. |
| What user can do | pass | User can load a graph into a new node by default, or explicitly overwrite the selected node while preserving manual layers. |
| (graph task) chain runs | pass | Loaded graph restores into canvas; runtime execution chain remains covered by `RUNTIME-50`, and RUNTIME-51 validates restoration/ownership path. |
| Label-heavy but metrics pass | no | Controls perform actual load/overwrite actions; completion is backed by stateful tests, not labels only. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | `.godot_user/ui-metrics/20260615-174804-14344/workspace_layout_metrics.md` | Produced by `TEST_JOBS=4 ./tools/test.sh`. |
| P0 failures | `0` | Report total. |
| P1 issues | `0` | Report total. |
| UI metric applicability | UI/graph task | Build screen controls changed; metric is regression evidence plus state tests. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| none | none | none |

## Repair-now Review

No repair-now issue remains.

## Test Review

- Command: `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/runtime51-graph-load-context.log --path . --script res://tests/test_graph_load_context.gd`
- Result: pass; `res://tests/test_graph_load_context.gd: all tests passed`
- Command: `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/runtime51-build-canvas.log --path . --script res://tests/test_build_graph_canvas.gd`
- Result: pass; `res://tests/test_build_graph_canvas.gd: all tests passed`
- Command: `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/runtime51-generation-promote.log --path . --script res://tests/test_generation_promote.gd`
- Result: pass; `res://tests/test_generation_promote.gd: all tests passed`
- Command: `TEST_JOBS=4 ./tools/test.sh`
- Result: pass; run id `20260615-174804-14344`, UI metric P0 failures `0`, P1 issues `0`
- Notes: macOS certificate warnings and an existing `test_hex_tile_map_layer.gd` RID leak warning were non-fatal; all listed tests passed with exit `0`.
