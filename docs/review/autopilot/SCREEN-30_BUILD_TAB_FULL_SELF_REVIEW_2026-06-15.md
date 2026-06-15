# SCREEN-30 Self Review

Task: `SCREEN-30_BUILD_TAB_FULL`
Queue: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/IMPLEMENTATION_QUEUE.md`
Plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/SCREEN-30_BUILD_TAB_FULL/`
Optional execution log: none

## Execution Summary

Added the Build tab Simple entry as a preset generation graph, not a second generation model. `HexGenerationPreset.from_profile()` maps a `HexGenerationProfileResource` into `shape -> wall_field -> connectivity`, the Build screen restores that graph into the existing canvas, runs it, promotes the final terrain output, and keeps dirty/last-run/preview state visible. The Workspace UI button path now asks the existing selected-layer bootstrap path for context before running, so graph-less selected `HexTileMapLayer` nodes receive an embedded graph resource and document instead of failing on missing Resource references.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/generation/hex_generation_preset.gd` | New profile-to-preset-graph factory with terrain promote target. |
| `addons/hex_map_kit/editor/hex_map_build_screen.gd` | Added Simple profile band, `Generate (Simple)`, preset graph restore/run/promote path, and snapshot fields. |
| `addons/hex_map_kit/editor/hex_map_workspace.gd` | Connected Build UI generate actions to the existing build context bootstrap. |
| `tests/test_build_screen_full.gd` | Added SCREEN-30 preset, Build screen, and graph-less selected layer UI path tests. |
| `tools/test.sh` | Added SCREEN-30 test to the standard suite. |
| `docs/TEST.md` | Added SCREEN-30 test to the standard target list. |
| `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` | Recorded test responsibility. |
| `docs/plan/.../IMPLEMENTATION_QUEUE.md` | Marked SCREEN-30 complete and advanced the pointer to SCREEN-31. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| Simple band + preset graph | Implemented as planned. | none | none |
| graph-less layer UI path | Added Workspace `build_context_requested` connection before button-run. | User identified Resource reference failure in the Build tab UI path; this preserves existing GRAPH-12A/RUNTIME-51 ownership instead of adding a new owner. | none |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Simple is preset graph | pass | `HexGenerationPreset.from_profile()` returns a 3-node graph and `test_build_screen_full.gd` validates nodes/edges. |
| Simple and Graph share one model | pass | Simple restores the preset into `HexMapBuildGraphCanvas`; test edits `walls` and reruns through `run_graph()`. |
| Profile drives graph params | pass | Test asserts shape/radius/wall probability/seed/connectivity method reach graph params. |
| Terrain promote default | pass | Simple selects `connectivity`, promotes role `terrain`, and test asserts generated terrain layer is written. |
| graph-less selected layer UI path | pass | Workspace button test starts with a graph-less selected `HexTileMapLayer`, presses `Generate (Simple)`, and asserts document + embedded graph resource + terrain promote. |
| Canvas remains dominant | pass | Snapshot asserts `canvas_is_dominant=true`; Simple band is present but does not replace graph canvas. |
| Dirty / last run visible | pass | Snapshot fields and dirty propagation are asserted after editing preset graph params. |

## Experiential DoD (UI / graph task)

| item | result | evidence |
|---|---|---|
| What user sees first | pass | Build opens on graph canvas with a compact Simple `Profile` band and `Generate (Simple)` above it. |
| What user can do | pass | Beginner path: choose/current Profile -> `Generate (Simple)` -> preview + terrain promote. Advanced path: edit the visible graph nodes and run `Generate`. |
| (graph task) chain runs | pass | `shape -> wall_field -> connectivity` runs from the Simple band; prior vertical slice remains covered by GRAPH-12/12A tests. |
| Label-heavy but metrics pass | no | Completion depends on button-triggered graph/context/promote state tests, not labels only. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | `.godot_user/ui-metrics/20260615-180325-42117/workspace_layout_metrics.md` | Produced by `TEST_JOBS=4 ./tools/test.sh`. |
| P0 failures | `0` | Report total. |
| P1 issues | `0` | Report total. |
| UI metric applicability | UI task | Build tab controls and first-screen workflow changed. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| none | none | none |

## Repair-now Review

No repair-now issue remains.

## Test Review

- Command: `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/screen30-targeted/logs/test_build_screen_full.gd.log --path . --script res://tests/test_build_screen_full.gd`
- Result: pass; `res://tests/test_build_screen_full.gd: all tests passed`
- Command: `TEST_JOBS=1 HEX_MAP_TEST_RUN_ID=screen30-nearby ./tools/test.sh`
- Result: pass; run id `screen30-nearby`, UI metric P0 failures `0`, P1 issues `0`
- Command: `TEST_JOBS=4 ./tools/test.sh`
- Result: pass; run id `20260615-180325-42117`, UI metric P0 failures `0`, P1 issues `0`
- Notes: macOS certificate warnings and the existing `test_hex_tile_map_layer.gd` RID leak warning were non-fatal; all tests passed with exit `0`.
