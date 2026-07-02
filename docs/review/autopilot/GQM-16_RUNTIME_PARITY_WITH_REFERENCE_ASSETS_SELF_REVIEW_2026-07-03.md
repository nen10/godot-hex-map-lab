# GQM-16 Runtime Parity With Reference Assets Self Review

Task: `GQM-16_RUNTIME_PARITY_WITH_REFERENCE_ASSETS`  
Queue: `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md`  
Plan: user contract, 2026-07-03

## Execution Summary

Implemented generation-layer reference resolution for consolidated node params:
`distribution_asset_path`, `rules_asset_path`, and `item_pool_asset_path`.
Editor-side graph runner and runtime Map Build now share the same resolution path because
the resolver runs inside `HexGenerationNodeTypes.run_node()`.

Missing or wrong-type asset references fall back to inline params and append structured
warnings to runner/build reports. `HexGenerationGraphResource` now preserves edge
`adaptation` during dictionary and `.tres` round-trips.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/generation/hex_generation_node_types.gd` | Added consolidated asset path resolution, warning reporting, path priority for wall distributions, adjacency resource conversion, and item pool loading. |
| `addons/hex_map_kit/generation/hex_generation_param_schema.gd` | Declared the three canonical asset path params with `line_edit` control and asset kinds. |
| `addons/hex_map_kit/generation/hex_generation_graph_runner.gd` | Added `warnings` collection to run reports. |
| `addons/hex_map_kit/generation/hex_map_graph_builder.gd` | Propagates runner warnings through runtime Map Build results. |
| `addons/hex_map_kit/adapter/hex_generation_graph_resource.gd` | Preserves edge `adaptation` in graph resource round-trips. |
| `tests/test_generation_graph.gd` | Covers three valid reference asset kinds and missing-path inline fallback warnings. |
| `tests/test_graph_runtime_build.gd` | Covers editor runner vs runtime Map Build parity for inline/embed and reference asset graph resources. |
| `tests/test_generation_graph_resource.gd` | Covers edge adaptation save/load round-trip. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| `./tools/test.sh` first run | First full run failed in `test_editor_sample.gd` due missing local Godot import cache for tracked `sample_hex_tiles.png`. | Local `.godot/imported` cache was absent after package/import state changes. | Regenerated imports with `/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --quit --path .`; rerun passed. |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Reference resolution for `distribution_asset_path` | pass | `tests/test_generation_graph.gd` asserts a referenced `HexWallDistributionResource` takes priority over inline distribution values. |
| Reference resolution for `rules_asset_path` | pass | `tests/test_generation_graph.gd` asserts a referenced `HexAdjacencyRuleSet` replaces inline probability rules. |
| Reference resolution for `item_pool_asset_path` | pass | `tests/test_generation_graph.gd` asserts a referenced `HexItemPoolResource` replaces inline item pool entries. |
| Load failure fallback is explicit | pass | `tests/test_generation_graph.gd` asserts unresolved references for all three params emit `asset_reference_unresolved` warnings and use inline values. |
| Runtime parity inline/embed | pass | `tests/test_graph_runtime_build.gd` compares editor runner Result output with runtime Map Build promoted terrain/overlay for the inline graph. |
| Runtime parity reference assets | pass | `tests/test_graph_runtime_build.gd` compares editor runner Result output with runtime Map Build promoted terrain/overlay for generated `.tres` asset references. |
| Edge adaptation round-trip | pass | `tests/test_generation_graph_resource.gd` saves/loads a graph resource and verifies edge `adaptation` is preserved. |
| No editor scope edits | pass | No files under `addons/hex_map_kit/editor/` changed. |

## Experiential DoD (UI / graph task)

| item | result | evidence |
|---|---|---|
| What user sees first | not applicable | This is a headless runtime/generation task; GQM-11 owns editor presentation. |
| What user can do | not applicable | Runtime/API behavior is exercised by graph resource tests, not a UI workflow. |
| (graph task) chain runs | pass | Runtime parity graph chains `terrain_generation -> item_generation -> set_operation -> item_generation -> result`, then promotes terrain and overlay through Map Build. |
| Label-heavy but metrics pass | no | No UI labels or editor surfaces changed. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | recorded | `.godot_user/ui-metrics/20260703-073022-75457/workspace_layout_metrics.md` |
| P0 failures | `0` | Standard `./tools/test.sh` metric gate. |
| P1 issues | `0` | Report-only. |
| UI metric applicability | non-UI task | Metrics ran as part of the standard suite; they are not the completion proof for this headless task. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| none | none | none |

## Repair-now Review

No repair-now issue remains.

## Test Review

- Command: focused `test_generation_graph.gd`, `test_generation_graph_resource.gd`, `test_graph_runtime_build.gd`
- Result: all pass
- Command: `./tools/test.sh`
- Result: exit `0`, run id `20260703-073022-75457`
- Notes: First full run failed because local Godot imports for tracked sample textures were missing; regenerated imports, then reran successfully.
