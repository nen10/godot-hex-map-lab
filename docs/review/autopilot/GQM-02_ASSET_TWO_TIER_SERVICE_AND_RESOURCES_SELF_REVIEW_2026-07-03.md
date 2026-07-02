# GQM-02 Self Review

Task: `GQM-02_ASSET_TWO_TIER_SERVICE_AND_RESOURCES`
Queue: `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md`
Plan: `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/RESOURCE_MODEL.md` sections 1-4
Optional execution log: `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/PROOF_LOG.md`

## Execution Summary

Implemented the GQM-02 resource foundation as real save/load behavior, not a placeholder. The new asset library lists bundled and project assets with source metadata, writes only to the configured project root, rejects bundled writes, and duplicates bundled assets into the project tier. Adjacency rules now use that service. Item pool and wall distribution resources round-trip through `.tres`, and graph V5 params now have regression coverage for persistence fidelity.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/editor/hex_map_asset_library.gd` | Added generic static two-tier asset library for bundled/project list, load, project save, and duplicate-to-project. |
| `addons/hex_map_kit/editor/hex_map_asset_library.gd.uid` | Added Godot script UID for the new library. |
| `addons/hex_map_kit/editor/hex_adjacency_rule_presets.gd` | Migrated adjacency preset listing/loading/saving to `HexMapAssetLibrary`. |
| `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd` | Updated the adjacency rules dialog to show preset source, save project assets, and duplicate presets to project. |
| `addons/hex_map_kit/adapter/hex_item_pool_resource.gd` | Added item pool resource with `display_name` and normalized `name` / `weight` / `limit` entries. |
| `addons/hex_map_kit/adapter/hex_item_pool_resource.gd.uid` | Added Godot script UID for the new resource. |
| `addons/hex_map_kit/adapter/hex_wall_distribution_resource.gd` | Added `display_name` and `from_preset()` initialization from `HexRandomizer` built-in arrays. |
| `addons/hex_map_kit/adapter/hex_adjacency_rule_set.gd` | Repaired static factory self-instantiation for stable headless compilation. |
| `addons/hex_map_kit/adapter/hex_generation_graph_resource.gd` | Repaired static factory self-instantiation for stable headless compilation. |
| `addons/hex_map_kit/adapter/hex_tile_map_layer.gd` | Added explicit `HexMapData` preload to avoid global class resolution failures in tests. |
| `addons/hex_map_kit/adapter/hex_debug_overlay_renderer.gd` | Added explicit `HexVector` preload to avoid global class resolution failures in tests. |
| `tests/test_generation_graph_resource.gd` | Added GQM-02 service, graph V5 persistence, new resource round-trip, and preset equivalence tests. |
| `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md` | Marked only the GQM-02 row complete. |
| `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/PROOF_LOG.md` | Added GQM-02 proof entry. |
| `docs/review/autopilot/GQM-02_SELF_REVIEW_2026-07-03.md` | Added this self-review. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| Asset service and resource implementation | Implemented as planned. | none | none |
| Minimal callsite update | Added source labels, project save text, and duplicate-to-project in the adjacency dialog. | Required to expose the new two-tier behavior without changing broader Build screen ownership. | none |
| Adapter-only compile stability repairs | Added explicit preloads and load-based static factory instantiation in adapter files. | Godot headless compilation hit `class_name` cache resolution failures during the gate; the fixes are local and within allowed adapter scope. | none |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Bundled/project integrated listing and source distinction | pass | `_test_asset_library_two_tier_service()` asserts both `bundled` and `project` entries. |
| Bundled write rejection | pass | `_test_asset_library_two_tier_service()` asserts saving to a bundled adjacency preset path fails. |
| Project root setting reflected | pass | `_test_asset_library_two_tier_service()` switches `hex_map_kit/asset_root` and verifies the listed/saved project path changes. |
| Project directory creation | pass | `HexMapAssetLibrary.save()` creates the parent project directory before `ResourceSaver.save()`. |
| `HexAdjacencyRulePresets` service migration | pass | Wrapper path/save/load behavior is asserted in `_test_asset_library_two_tier_service()`. |
| V5 graph save/load round-trip | pass | `_test_graph_resource_v5_params_save_load_roundtrip()` preserves `toric_passage`, dict `custom_distribution`, structured `probability_rules`, and item `limit`. |
| `HexItemPoolResource` `.tres` round-trip | pass | `_test_item_pool_resource_save_load_roundtrip()`. |
| `HexWallDistributionResource` `.tres` round-trip | pass | `_test_wall_distribution_resource_save_load_roundtrip()`. |
| `from_preset(11/20/24)` equals built-in arrays | pass | `_test_wall_distribution_from_preset_matches_builtin()` compares against `HexRandomizer.distribution1/2/3`. |
| Standard verification | pass | `./tools/test.sh` exited `0`, run id `20260703-062141-16845`. |

## Experiential DoD (UI / graph task)

| item | result | evidence |
|---|---|---|
| What user sees first | pass | The adjacency rules dialog still presents the preset selector first, now with source labels such as `[bundled]` and `[project]`. |
| What user can do | pass | Users can load bundled presets, duplicate them into the project tier, and save edited adjacency rules as project assets. |
| (graph task) chain runs | pass | Existing graph runner/resource tests remain green; GQM-02 adds V5 graph resource persistence coverage. |
| Label-heavy but metrics pass | no | New controls call the asset service and are backed by save/load round-trip tests. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | `.godot_user/ui-metrics/20260703-062141-16845/workspace_layout_metrics.md` | Produced by `./tools/test.sh`. |
| P0 failures | `0` | Metric report total. |
| P1 issues | `0` | Metric report total. |
| UI metric applicability | regression only | This is primarily a resource/API task with a narrow dialog callsite update. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| none | none | none |

## Repair-now Review

No repair-now issue remains. The class resolution failures found during test execution were fixed locally and verified by the full standard test run.

## Test Review

- Command: `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file /Users/nenten/Desktop/cosmos/projects/wt-gqm02/.godot_user/test-runs/gqm02-import/logs/import.log --path . --import`
- Result: pass; exit `0`
- Notes: Regenerated ignored local `.godot/imported` files needed by texture-backed editor tests.

- Command: `./tools/test.sh`
- Result: pass; exit `0`, run id `20260703-062141-16845`
- Notes: Godot emitted existing macOS certificate warnings and expected warning-path messages; all tests passed.
