# GRAPH-13 Run UX Self Review

Task: `GRAPH-13_RUN_UX`
Queue: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/IMPLEMENTATION_QUEUE.md`
Plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-13_RUN_UX/IMPLEMENTATION_PLAN.md`

## Execution Summary

GRAPH-13 makes the Build graph run path practical under the existing task spec. The runner now accepts previous node cache, dirty node ids, and interrupt options; clean upstream nodes are reused, dirty/downstream nodes are recomputed, and cancellation returns partial cache separately from committed cache. Build exposes primary Generate(N=1), secondary N/randomize controls, busy/cancel state, progress state, and highlighted failure nodes.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/generation/hex_generation_graph_runner.gd` | Added previous cache reuse, dirty-node recompute selection, interrupt/cancel handling, partial cache separation, and recomputed/reused node reporting. |
| `addons/hex_map_kit/generation/hex_generation_node_types.gd` | Passed `interrupt_options` into existing interruptible wall/connectivity/item generation APIs. |
| `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd` | Added run-state snapshot, cache-ready tracking, dirty propagation, progress/cancel state, and failure-node highlighting. |
| `addons/hex_map_kit/editor/hex_map_build_screen.gd` | Added secondary batch controls, primary Generate(N=1) snapshot fields, busy/cancel controls, progress state, and failure-node status text. |
| `tests/test_generation_graph_runner_dirty.gd` | Added dirty cache reuse, downstream recompute, interrupt/cancel, and partial-cache safety coverage. |
| `tests/test_build_graph_canvas.gd` | Added cache/dirty/failure-highlight/generate-default coverage. |
| `tools/test.sh` | Added the new runner dirty/cancel test to the standard suite. |
| `docs/TEST.md` / `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` | Updated standard target and test responsibility records. |
| `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/IMPLEMENTATION_QUEUE.md` | Marked GRAPH-13 complete and swept newly ready dependencies. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| none | none | none | none |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Topological graph run remains through existing runner | pass | `HexMapBuildGraphCanvas.run_graph()` still calls `HexGenerationGraphRunner.run_with_report()`. |
| Cache state visible after successful run | pass | `run_state_snapshot()` reports `cache_ready`, `cache_node_ids`, `cache_node_count`, `recomputed_node_ids`, and `reused_node_ids`; `tests/test_build_graph_canvas.gd`. |
| Dirty propagation and minimum rerun | pass | `_mark_dirty_from_node()` traverses outgoing edges; runner dirty test asserts clean upstream reuse and dirty/downstream recompute. |
| Cancel/progress uses existing interrupt options | pass | Runner passes `interrupt_options` into interruptible generation APIs and reports cancellation without committing partial cache; `tests/test_generation_graph_runner_dirty.gd`. |
| Generate defaults to N=1 and remains primary | pass | `Build Generate Button` calls `run_graph({"count": 1})`; snapshot asserts `primary_generate_count == 1`. |
| N/randomize controls are secondary | pass | Batch controls are below the work surface and snapshot exposes `batch_controls_secondary == true`. |
| Failure node is visible | pass | Invalid item-generator run reports `failure_node_id == "items"`, highlights the GraphNode, and status names the node. |

## Experiential DoD (UI / graph task)

| item | result | evidence |
|---|---|---|
| What user sees first | pass | Build opens on the graph canvas with the Generate primary action; resources remain context chips, not the work surface. |
| What user can do | pass | User can Generate one graph, see preview/cache readiness, edit a node, see downstream dirty state, rerun only dirty/downstream nodes, and cancel long runs through the interrupt path. |
| (graph task) chain runs | pass | `tests/test_generation_promote.gd` keeps Shape→Wall→Connectivity→Region Filter→Item Generator→Promote passing. |
| Label-heavy but metrics pass | no | Build snapshot keeps `label_heavy_but_metrics_pass == false`; UI metrics P0/P1 = 0. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | pass | `.godot_user/ui-metrics/20260615-171816-63647/workspace_layout_metrics.md` |
| P0 failures | pass | `0` |
| P1 issues | pass | `0` |
| UI metric applicability | pass | UI-facing graph task. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| Full persistent graph resource semantics | existing queue | `GRAPH-14_GRAPH_RESOURCE` |
| Full Build tab beginner/simple flow | existing queue | `SCREEN-30_BUILD_TAB_FULL` |
| Runtime build API | existing queue | `RUNTIME-50_GRAPH_RESOURCE_AND_RUNTIME_MAP_BUILD_API` |
| Persistence is not in GRAPH-13 scope | existing queue | `GRAPH-14_GRAPH_RESOURCE` |

## Repair-now Review

No repair-now issue remains.

## Test Review

- Command: `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/graph13-build-canvas.log --path . --script res://tests/test_build_graph_canvas.gd`
- Result: pass
- Notes: Focused GRAPH-13 Build graph canvas coverage passed.

- Command: `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/graph13-runner-dirty.log --path . --script res://tests/test_generation_graph_runner_dirty.gd`
- Result: pass
- Notes: Focused runner dirty/cache/cancel coverage passed.

- Command: `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/graph13-generation-promote.log --path . --script res://tests/test_generation_promote.gd`
- Result: pass
- Notes: GRAPH-12/12A promote path remains passing.

- Command: `TEST_JOBS=4 ./tools/test.sh`
- Result: pass
- Notes: Run id `20260615-171816-63647`; all tests passed. Godot emitted existing macOS certificate warnings and expected warning-path messages; they did not fail the run.
