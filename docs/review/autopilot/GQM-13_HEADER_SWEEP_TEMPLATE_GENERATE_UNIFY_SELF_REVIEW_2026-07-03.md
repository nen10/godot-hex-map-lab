# GQM-13 Header Sweep Template Generate Unify Self Review

Task: `GQM-13_HEADER_SWEEP_TEMPLATE_GENERATE_UNIFY`
Queue: `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md`
Plan: `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/GQM-13_HEADER_SWEEP_TEMPLATE_GENERATE_UNIFY/`

## Execution Summary

Build now opens on graph asset operations instead of profile/simple/batch controls. The header is `Template / Save as... / Load... / Generate / Apply / Revert / status`; the removed controls are absent from both the Control tree and the header snapshot.

Bundled `graphs` templates now include `基本形` and `Simple`. `基本形` is listed first from `HexMapAssetLibrary.list("graphs")` and expands to the R2-3 structure as an 8-node / 9-edge graph. `Simple` absorbs the old Simple profile path as `terrain -> result`. Template load uses the normalized graph-resource load path and asks for confirmation before replacing an existing canvas graph.

Primary Generate always runs the current canvas graph. Graphless Build bootstrap creates the integrated Simple graph resource on the selected or newly created `HexTileMapLayer`; the public preset API remains for headless callers.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/adapter/hex_generation_graph_resource.gd` | Added graph `display_name` metadata for asset-library labels. |
| `addons/hex_map_kit/assets/graphs_presets/basic.tres` | Added bundled `基本形` graph template. |
| `addons/hex_map_kit/assets/graphs_presets/simple.tres` | Added bundled `Simple` graph template. |
| `addons/hex_map_kit/editor/hex_map_build_screen.gd` | Replaced old header controls with Template / Save as / Load / Generate / Apply / Revert / status; added template apply/save/load and confirmation flow; removed Simple/profile/batch screen wiring; unified Generate on current canvas graph. |
| `addons/hex_map_kit/editor/hex_map_workspace.gd` | Removed the old Build header Load Graph route and context-chip injection for Build snapshots. |
| `addons/hex_map_kit/generation/hex_generation_preset.gd` | Added Simple and Basic template graph factories while keeping `from_profile()` for API callers. |
| `tests/test_build_screen_full.gd` | Reworked Build tests around header sweep, Basic template Generate, Save as -> Load round-trip, and profile-free Generate. |
| `tests/test_build_graph_canvas.gd` | Updated header/layout assertions for the unified header and removed batch-control expectations. |
| `tests/test_graph_load_context.gd` | Replaced old Load Graph / Overwrite header assertions with graph asset operation coverage. |
| `tests/test_editor_workspace.gd` | Updated workspace screen contracts so Build no longer requires context chips. |
| `tests/test_generation_promote.gd` | Updated stale bootstrap expectations to the new Simple template `terrain -> result` graph. |
| `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` | Updated test ownership notes for the rewritten Build/header graph asset tests. |
| `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/GQM-13_HEADER_SWEEP_TEMPLATE_GENERATE_UNIFY/` | Added task packet. |
| `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md` | Marked only GQM-13 `COMPLETE`. |
| `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/PROOF_LOG.md` | Added GQM-13 proof. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| Target test files | Also updated `tests/test_generation_promote.gd`. | Existing GRAPH-12A tests still assumed the old bootstrap graph exposed `shape` / `weighted_items`; GQM-13 intentionally changed graphless bootstrap to Simple `terrain -> result`. | None; updated assertions still cover bootstrap, params persistence, Generate projection, and promote/document writeback. |
| First standard `./tools/test.sh` run | Failed before focused code failures were resolved because local `.godot/imported` texture cache was absent. | The tracked sample PNG existed, but the ignored Godot import cache did not. | Ran `Godot --headless --path . --import`; final `./tools/test.sh` passed. |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Remove Batch N / seed randomize / shape randomize / profile row / Generate(Simple) / Load Graph / Overwrite / context chips | pass | `tests/test_build_screen_full.gd` asserts removed snapshot keys and removed Control names are absent. |
| Add Template dropdown from `HexMapAssetLibrary.list("graphs")` | pass | Header snapshot records template entries; test asserts `基本形` first and `Simple` present. |
| Bundle `基本形` and `Simple` templates | pass | New `.tres` files under `addons/hex_map_kit/assets/graphs_presets/`; Basic apply test asserts 8 nodes and 9 edges. |
| Template selection replaces current graph with confirmation | pass | Basic-over-Simple test asserts confirmation is required without force and succeeds with confirm option. |
| Save as / Load graph asset operation | pass | Save as -> Load round-trip test writes a project graph asset and reloads it through template load. |
| Generate unified on current graph | pass | Build tests use primary Generate with no profile and verify the graphless selected layer receives a generated preview. |
| `./tools/test.sh` green | pass | Final standard run exited 0 with run id `20260703-084635-53903`. |

## Experiential DoD (UI / graph task)

| item | result | evidence |
|---|---|---|
| What user sees first | pass | Build header begins with Template and graph asset operations, not low-level profile/batch/randomize controls or dense context chips. |
| What user can do | pass | User can choose a bundled/project graph, save the current graph to project assets, load another graph, Generate, then Apply/Revert from the same header. |
| Chain runs | pass | Basic template apply creates an 8-node / 9-edge graph and Generate succeeds; Save as -> Load round-trip preserves the graph and reruns it. |
| Label-heavy but metrics pass | pass | Removed context-chip text packing and profile rows; workspace metrics report P0 `0`, P1 `0`. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | generated by standard suite | `.godot_user/ui-metrics/20260703-084635-53903/workspace_layout_metrics.md` |
| P0 failures | 0 | Metric report total_p0_failures = 0. |
| P1 issues | 0 | Metric report total_p1_issues = 0. |
| UI metric applicability | UI task | GQM-13 changes Build header first-impression controls and graph asset operations. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| Result resource save/switch | queued outside this task | GQM-14 owns named generated result resources. |
| Criteria chip polish / inspector polish | forbidden/outside this task | GQM-18 owns inspector, criteria UI, and canvas titlebar work. |

## Repair-now Review

No repair-now item remains.

## Test Review

- Environment prep: `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --import` exited 0 to regenerate the missing local import cache.
- Focused Godot run: `res://tests/test_build_screen_full.gd` passed.
- Focused Godot run: `res://tests/test_build_graph_canvas.gd` passed.
- Focused Godot run: `res://tests/test_graph_load_context.gd` passed.
- Focused Godot run: `res://tests/test_editor_workspace.gd` passed.
- Focused Godot run: `res://tests/test_generation_promote.gd` passed.
- Command: `./tools/test.sh`
- Result: exit 0
- Run id: `20260703-084635-53903`
- Notes: Final run had known non-fatal macOS CA certificate warnings. The first full run exposed stale GRAPH-12A bootstrap assertions, which were updated to the new Simple template behavior.
