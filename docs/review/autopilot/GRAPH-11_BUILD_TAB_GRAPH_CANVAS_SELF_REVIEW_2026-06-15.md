Task: GRAPH-11_BUILD_TAB_GRAPH_CANVAS
Queue: docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/IMPLEMENTATION_QUEUE.md
Plan: docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-11_BUILD_TAB_GRAPH_CANVAS/
Optional execution log: none

## Execution Summary

Implemented the Build graph surface as the first workspace tab surface: GraphEdit canvas, typed node palette, selected-node inspector, output preview, and Generate wiring from canvas state into the GRAPH-10 Dictionary model and runner. The legacy Generate dock remains hidden and queryable for existing simple-generation APIs, while the visible Build screen owns the tab snapshot and root view state.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd` | New GraphEdit-backed graph canvas with node creation, typed connection rejection, model construction, run, and output preview snapshots. |
| `addons/hex_map_kit/editor/hex_map_build_node_palette.gd` | New node palette for the seven MVP graph node types. |
| `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd` | New selected-node inspector with params, Source resource refs, and disabled GRAPH-12 Promote action. |
| `addons/hex_map_kit/editor/hex_map_build_screen.gd` | New Build screen layout with graph canvas first, preview, inspector, context chips, and Generate action. |
| `addons/hex_map_kit/editor/hex_map_workspace.gd` | Mounted Build screen as the tab owner, kept legacy Generate dock hidden for existing API compatibility, and updated Build snapshot/root state. |
| `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd` | Registered Build tab alias and Build graph screen component; kept `Generate` as canonical alias. |
| `tests/test_build_graph_canvas.gd` | Added GRAPH-11 coverage for canvas first impression, typed rejection, 3-node run/preview, palette, inspector, and workspace mount. |
| `tests/test_editor_plugin.gd`, `tests/test_editor_workspace.gd`, `tests/test_editor_plugin_test_base.gd` | Updated workspace contract tests for Build-first tab order and new component ownership. |
| `tools/test.sh`, `docs/TEST.md`, `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` | Added the Build graph canvas test to standard verification and test responsibility docs. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| Build tab replaces Generate tab | Implemented Build as `TAB_GENERATE` canonical value with `Generate` legacy alias | Existing code and tests still call `Generate`; alias avoids breakage while user-facing tab is Build | none |
| Legacy generation dock not in GRAPH-11 scope | Kept hidden legacy dock mounted | Existing simple generation tests and workspace API depend on `generation_dock()` | none |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Graph canvas / node palette / selected node inspector / output preview / run | PASS | `tests/test_build_graph_canvas.gd`; `HexMapBuildScreen` composition |
| Inspector references Resource refs | PASS | Source node inspector exposes `map`, `overlay`, `document`, `result` resource ref fields |
| Canvas is primary, Resource row is not primary | PASS | `build_screen_snapshot().first_surface == graph_canvas`, `resource_row_primary == false` |
| 3 node placement and typed connection | PASS | Build test creates Shape -> Wall Field -> Connectivity and rejects terrain -> selection mismatch |
| Intermediate output preview | PASS | Build test runs selected Connectivity node and records `HexMapPreviewThumbnail.SOURCE_MAP_DATA` preview |

## Experiential DoD (UI / graph task)

| item | result | evidence |
|---|---|---|
| What user sees first | PASS | Build is first workspace tab; first Build surface is graph canvas with palette, preview, and inspector. |
| What user can do | PASS | User can add nodes, connect compatible ports, press Generate, and preview the selected node output. |
| (graph task) chain runs | PASS | Shape -> Wall Field -> Connectivity runs from the Build canvas through GRAPH-10 runner; GRAPH-12 will extend this to Filter -> Item Generator -> Promote. |
| Label-heavy but metrics pass | no | Canvas/preview/inspector are functional surfaces; labels are not the only completion evidence. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | PASS | `.godot_user/ui-metrics/20260615-153318-51063/workspace_layout_metrics.md` |
| P0 failures | PASS | `0` |
| P1 issues | PASS | `0` report-only |
| UI metric applicability | applicable | UI-facing Build tab task; metrics are regression evidence, not sole acceptance proof. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| Promote output to Layer remains disabled | existing queue id | `GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN` |

## Repair-now Review

No repair-now issue remains. Standard tests pass, Build canvas coverage passes, and UI metric P0 failures are zero.

## Test Review

- Command: `TEST_JOBS=4 ./tools/test.sh`
- Result: PASS, exit 0
- Notes: run id `20260615-153318-51063`; macOS certificate warning and existing push_warning messages are non-fatal.
