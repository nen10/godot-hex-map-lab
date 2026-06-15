# RUNTIME-50 Self Review

Task: `RUNTIME-50_GRAPH_RESOURCE_AND_RUNTIME_MAP_BUILD_API`
Queue: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/IMPLEMENTATION_QUEUE.md`
Plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/RUNTIME-50_GRAPH_RESOURCE_AND_RUNTIME_MAP_BUILD_API/`
Optional execution log: none

## Execution Summary

Added an editor-independent runtime graph build path. `HexMapGraphBuilder.build()` runs a `HexGenerationGraphResource` through the generation runner, resolves runtime semantics in the planned order, collects promote targets into `map_data` / overlays, and reports errors instead of crashing. `HexTileMapLayer.build_from_graph()` applies the generated map through the existing `apply_map()` path.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/generation/hex_map_graph_builder.gd` | New runtime builder API with semantics resolution, runner execution, promote target collection, and structured errors. |
| `addons/hex_map_kit/adapter/hex_generation_graph_resource.gd` | Added `semantics_reference_path` for the planned reference semantics path while preserving embed default. |
| `addons/hex_map_kit/adapter/hex_tile_map_layer.gd` | Added `build_from_graph()` and `last_graph_build_result()` using existing `apply_map()`. |
| `examples/basic_runtime/runtime_graph_build_sample.gd` | Added a runtime sample for embedded random graph builds. |
| `examples/basic_runtime/README.md` | Documented the graph build sample. |
| `tests/test_graph_runtime_build.gd` | Added runtime build API coverage. |
| `tools/test.sh` | Added runtime graph build test to standard suite. |
| `docs/TEST.md` | Added runtime graph build test to standard target list. |
| `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` | Recorded test responsibility. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| none | none | none | none |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Editor-independent graph to map headless path | pass | `HexMapGraphBuilder` lives under `generation/` and imports no editor scripts; `tests/test_graph_runtime_build.gd` checks runtime files for editor imports. |
| Embed semantics self-contained | pass | Saved embedded graph resource builds from `.tres` without external semantics in `test_graph_runtime_build.gd`. |
| Runtime random generation use case | pass | `HexRuntimeGraphBuildSample.build_random_map()` and random wall graph tests produce `HexMapData`. |
| Same seed reproducible | pass | `test_graph_runtime_build.gd` compares map signatures for seed `41`. |
| Different seed changes map | pass | `test_graph_runtime_build.gd` compares wall signatures for seeds `51` and `52`. |
| Reference semantics path | pass | `test_graph_runtime_build.gd` saves a `HexMapResource`, loads it through `semantics_reference_path`, and supplies it to a Source node. |
| Unresolved semantics returns errors | pass | Missing reference path returns `ok=false` with `semantics_unresolved`. |
| Node apply API | pass | `HexTileMapLayer.build_from_graph()` applies generated map data and keeps the graph resource reference. |

## Experiential DoD (UI / graph task)

| item | result | evidence |
|---|---|---|
| What user sees first | not applicable | Runtime API task; there is no editor screen surface in scope. |
| What user can do | pass | Runtime developer can call `HexMapGraphBuilder.build(graph_res, {"seed": n})` or `HexTileMapLayer.build_from_graph(graph_res, seed)` and receive/apply map data. |
| (graph task) chain runs | pass | Headless resource → runner → promote target → `map_data` → layer apply is covered by `tests/test_graph_runtime_build.gd`. |
| Label-heavy but metrics pass | no | Non-UI task; completion is API/test based, not label-based UI evidence. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | `.godot_user/ui-metrics/20260615-173729-97207/workspace_layout_metrics.md` | Produced by `TEST_JOBS=4 ./tools/test.sh`. |
| P0 failures | `0` | Report total. |
| P1 issues | `0` | Report total. |
| UI metric applicability | non-UI task | Runtime API task; metric is regression evidence only. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| none | none | none |

## Repair-now Review

No repair-now issue remains.

## Test Review

- Command: `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/runtime50-graph-build.log --path . --script res://tests/test_graph_runtime_build.gd`
- Result: pass; `test_graph_runtime_build.gd: all tests passed`
- Command: `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/runtime50-graph-resource.log --path . --script res://tests/test_generation_graph_resource.gd`
- Result: pass; `test_generation_graph_resource.gd: all tests passed`
- Command: `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/runtime50-tile-layer.log --path . --script res://tests/test_hex_tile_map_layer.gd`
- Result: pass; `test_hex_tile_map_layer.gd: all tests passed`
- Command: `TEST_JOBS=4 ./tools/test.sh`
- Result: pass; run id `20260615-173729-97207`, UI metric P0 failures `0`, P1 issues `0`
- Notes: macOS certificate warnings and an existing `test_hex_tile_map_layer.gd` RID leak warning were non-fatal; all listed tests passed with exit `0`.
