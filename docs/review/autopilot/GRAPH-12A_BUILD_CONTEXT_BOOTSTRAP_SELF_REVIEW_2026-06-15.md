Task: GRAPH-12A_BUILD_CONTEXT_BOOTSTRAP
Queue: docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/IMPLEMENTATION_QUEUE.md
Plan: docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-12A_BUILD_CONTEXT_BOOTSTRAP/
Optional execution log: none

## Execution Summary

Added the missing Build context bootstrap required by `GENERATION_GRAPH_MODEL.md` §10. Build can now create an embedded graph context for a selected graph-less `HexTileMapLayer`, or create/select a new `HexTileMapLayer` when none is selected. The selected node owns the embedded graph resource and Level Document; Build restores the graph to the canvas, runs the vertical slice, previews `weighted_items`, and can Promote without Resource-reference shortages.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/adapter/hex_generation_graph_resource.gd` | Added minimal embedded graph Resource wrapper for Dictionary graph models. |
| `addons/hex_map_kit/adapter/hex_tile_map_layer.gd` | Added selected-node-owned `generation_graph_resource`. |
| `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd` | Added graph restore, resource-ref restore, and slot lookup helpers. |
| `addons/hex_map_kit/editor/hex_map_build_screen.gd` | Added Build context bootstrap API and snapshot state. |
| `addons/hex_map_kit/editor/hex_map_workspace.gd` | Added workspace-level Build context bootstrap and selected snapshot graph status. |
| `tests/test_generation_promote.gd` | Added GRAPH-12A coverage for selected graph-less, no-selection, existing-resource, Generate, Preview, and Promote paths. |
| `tests/test_editor_plugin_test_base.gd` | Exposed `HexGenerationGraphResource` to tests. |
| `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` | Updated GRAPH-12 test responsibility log. |
| `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-12A_BUILD_CONTEXT_BOOTSTRAP/` | Added task planning docs. |
| `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/IMPLEMENTATION_QUEUE.md` | Added and completed GRAPH-12A; adjusted downstream graph dependencies. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| Update `docs/TEST.md` | Not changed | No new test script or command was added; existing `tests/test_generation_promote.gd` remains the standard target. | none |
| Full graph resource lifecycle | Not implemented | `GRAPH-14_GRAPH_RESOURCE` remains the full save/load resource task. | `GRAPH-14_GRAPH_RESOURCE` |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Graph new creation path | PASS | `workspace.ensure_build_graph_context()` creates `HexGenerationGraphResource` when selected layer has none. |
| Graph-less HexTileMapLayer UI execution path | PASS | `tests/test_generation_promote.gd` selected graph-less layer test runs Build preview and Promote. |
| No selected HexTileMapLayer default path | PASS | Test asserts Build creates/selects a new `HexTileMapLayer`. |
| Existing selected-node tracking remains owner | PASS | Tests assert selected layer owns graph/document refs and workspace context follows selected document. |
| Existing resources preserved | PASS | Test asserts existing graph and document references are unchanged. |
| No sample-only completion | PASS | Tests use project-created resources and unsaved embedded resources, not bundled samples. |

## Experiential DoD (UI / graph task)

| item | result | evidence |
|---|---|---|
| What user sees first | PASS | Build remains graph-first; snapshot records `build_context_ready` only after context bootstrap. |
| What user can do | PASS | From an unconfigured selected layer or no selection, user can create Build context, Generate, inspect preview, and Promote. |
| (graph task) chain runs | PASS | Shape -> Wall -> Connectivity -> Region Filter -> Item Generator -> Promote runs after bootstrap. |
| Label-heavy but metrics pass | no | Completion proof is selected-node graph/document ownership, canvas restore/run, preview state, and document mutation. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | PASS | `.godot_user/ui-metrics/20260615-163327-12391/workspace_layout_metrics.md` |
| P0 failures | PASS | `0` |
| P1 issues | PASS | `0` report-only |
| UI metric applicability | applicable | Build tab UI-facing graph task; metrics are regression evidence, not sole acceptance proof. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| Full graph resource save/load round trip | existing queue id | `GRAPH-14_GRAPH_RESOURCE` |
| Runtime graph build API | existing queue id | `RUNTIME-50_GRAPH_RESOURCE_AND_RUNTIME_MAP_BUILD_API` |
| Opt-in overwrite/reference/merge load UX | existing queue id | `RUNTIME-51_GRAPH_LOAD_AND_CONTEXT_OWNERSHIP` |

## Repair-now Review

No repair-now issue remains. The reported Build Resource-reference shortage is repaired for graph new creation, selected graph-less layer, and no-selection default paths.

## Test Review

- Command: `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/graph12a-generation-promote.log --path . --script res://tests/test_generation_promote.gd`
- Result: PASS, exit 0
- Notes: `res://tests/test_generation_promote.gd: all tests passed`

- Command: `TEST_JOBS=4 ./tools/test.sh`
- Result: PASS, exit 0
- Notes: run id `20260615-163327-12391`; macOS certificate warning and existing push_warning messages are non-fatal.
