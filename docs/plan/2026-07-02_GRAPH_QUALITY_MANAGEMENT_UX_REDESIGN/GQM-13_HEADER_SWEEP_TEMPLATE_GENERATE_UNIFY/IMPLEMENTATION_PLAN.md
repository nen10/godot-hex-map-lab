# GQM-13 Implementation Plan

## Scope

- Sweep Build header controls to Template / Save as / Load / Generate / Apply / Revert / status.
- Add bundled `graphs` templates for `基本形` and `Simple`.
- Load/apply templates through `HexMapAssetLibrary.list("graphs")` and normalized graph resource load.
- Save current canvas graph to the project `graphs` layer.
- Update tests and proof docs for GQM-13.

## Target Files

- `addons/hex_map_kit/editor/hex_map_build_screen.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/generation/hex_generation_preset.gd`
- `addons/hex_map_kit/adapter/hex_generation_graph_resource.gd`
- `addons/hex_map_kit/assets/graphs_presets/basic.tres`
- `addons/hex_map_kit/assets/graphs_presets/simple.tres`
- `tests/test_build_screen_full.gd`
- `tests/test_build_graph_canvas.gd`
- `tests/test_graph_load_context.gd`
- `tests/test_editor_workspace.gd`
- `tests/test_generation_promote.gd`
- `tests/test_workspace_layout_metrics.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md`
- `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/PROOF_LOG.md`
- `docs/review/autopilot/GQM-13_HEADER_SWEEP_TEMPLATE_GENERATE_UNIFY_SELF_REVIEW_2026-07-03.md`

## Steps

1. Add graph template factory helpers and bundled graph resources.
2. Replace Build header UI and snapshot contract with Template / Save as / Load / Generate / Apply / Revert / status.
3. Remove Simple/Profile and batch/randomize screen wiring; keep headless preset API.
4. Make context bootstrap use the integrated Simple graph template.
5. Update Build/workspace tests for header absence/presence, basic template generate, Save as -> Load, and profile-free Generate.
6. Run `./tools/test.sh`, repair failures, write self-review/proof, mark GQM-13 complete, and commit.

## Dependency / Test Matrix

| dependency / area | risk | proof / test |
|---|---|---|
| `HexMapAssetLibrary.list("graphs")` | bundled templates not visible or ordered | header snapshot/template list assertions |
| normalized graph load | legacy/project load path bypassed | template/load tests assert normalized load result exists |
| graph execution | basic graph topology fails at runtime | basic template apply + Generate succeeds |
| workspace bootstrap | profile-free Generate fails on graphless selected layer | workspace Generate test without profile |

## Completion Criteria

- Header removed controls are absent and new controls are present.
- `基本形` template expands to at least 7 nodes and generates successfully.
- Save as -> Load round-trip works with a project graph asset.
- Generate works without a generation profile.
- `./tools/test.sh` exits 0.
