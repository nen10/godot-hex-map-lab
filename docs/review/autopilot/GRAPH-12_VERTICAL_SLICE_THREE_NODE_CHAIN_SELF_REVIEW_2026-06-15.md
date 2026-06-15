Task: GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN
Queue: docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/IMPLEMENTATION_QUEUE.md
Plan: docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN/
Optional execution log: docs/review/autopilot/GRAPH-12_HEADLESS_VISUAL_VERIFICATION_2026-06-15.md

## Execution Summary

Implemented the vertical graph slice from Shape through Item Generator and Promote. Region Filter now supports distance-bounded floor selection, the Build screen can construct/run the five-node chain, selected item output previews before promotion, and `HexGenerationPromote` writes generated terrain/overlay/object output into a `HexMapDocumentResource` while preserving manual document layers.

## Changed Files

| file | change |
|---|---|
| `addons/hex_map_kit/generation/hex_generation_promote.gd` | New Promote service for terrain, overlay, and object roles with generated metadata and generated-only replacement. |
| `addons/hex_map_kit/generation/hex_generation_node_types.gd` | Added distance filtering support for Region Filter selection. |
| `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd` | Added GRAPH-12 vertical slice chain builder and spawn-distance default params. |
| `addons/hex_map_kit/editor/hex_map_build_screen.gd` | Added vertical slice run helper, selected output Promote, promote snapshot state, and Promote enablement from Level Document context. |
| `tests/test_generation_promote.gd` | Added promote, save/load, distance filter, and Build screen vertical slice coverage. |
| `tests/test_editor_plugin_test_base.gd`, `tools/test.sh`, `docs/TEST.md`, `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` | Registered GRAPH-12 test coverage in standard verification and docs. |
| `tools/graph12_visual_verify.gd` | Added headless visual verification tool for GRAPH-12 Build screen state and layout. |
| `docs/review/autopilot/GRAPH-12_HEADLESS_VISUAL_VERIFICATION_2026-06-15.md` | Added Godot-doc-based visual verification method and result record. |

## Plan Deviation

| planned item | actual result | reason | follow-up |
|---|---|---|---|
| Raster screenshot as visual proof | Headless raster capture is supplementary and skipped when the Godot display server is `headless`; layout/state proof is the stable gate | In this environment, `--headless` provides dummy/headless display behavior; viewport texture capture is not reliable as a completion gate | none |

## Acceptance Review

| requirement | result | evidence |
|---|---|---|
| Intermediate selection connects into next node input | PASS | `HexMapBuildGraphCanvas.build_default_vertical_slice_chain()` connects Connectivity -> Region Filter -> Item Generator; `tests/test_generation_promote.gd`. |
| Promote creates a real Document layer | PASS | Overlay promote creates a generated overlay layer in `HexMapDocumentResource`; terrain role save/load round-trip passes. |
| `floor intersect spawn distance <= 3` selection | PASS | Region Filter supports `within_distance_of`/`max_distance`; test asserts selected cells stay within distance. |
| Weighted item output previews before Promote | PASS | Build screen test and headless visual report record `preview_available: true` for `weighted_items`. |
| Manual data is preserved | PASS | Overlay/object/terrain promote tests preserve manual entries and replace only generated entries. |

## Experiential DoD (UI / graph task)

| item | result | evidence |
|---|---|---|
| What user sees first | PASS | Build screen exposes graph canvas as primary surface with node palette, output preview, inspector, and Generate action visible in the headless layout snapshot. |
| What user can do | PASS | User can run the five-node graph, inspect weighted item output, then Promote it into the active Level Document. |
| (graph task) chain runs | PASS | Shape -> Wall Field -> Connectivity -> Region Filter -> Item Generator -> Promote runs in the Build screen path and writes a generated overlay layer. |
| Label-heavy but metrics pass | no | Completion evidence is graph state, preview state, Promote result, Document mutation, and visible control rectangles. |

## UI Metric Review

| item | result | evidence |
|---|---|---|
| Metric report path | PASS | `.godot_user/ui-metrics/20260615-155012-74831/workspace_layout_metrics.md` |
| P0 failures | PASS | `0` |
| P1 issues | PASS | `0` report-only |
| UI metric applicability | applicable | UI-facing graph task; metrics are regression evidence, not sole acceptance proof. |

## Deferred / Prose-only Audit

| item | classification | queue / ledger / reject / policy |
|---|---|---|
| DAG cache/dirty UX and Generate(N=1) run controls | existing queue id | `GRAPH-13_RUN_UX` |
| Graph resource save/load | existing queue id | `GRAPH-14_GRAPH_RESOURCE` |

## Repair-now Review

No repair-now issue remains. Standard tests pass, GRAPH-12 targeted tests pass, UI metric P0 failures are zero, and headless visual verification records the Build screen visual/control state and Promote result.

## Test Review

- Command: `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/manual-graph12-promote.log --path . --script res://tests/test_generation_promote.gd`
- Result: PASS, exit 0
- Notes: `res://tests/test_generation_promote.gd: all tests passed`

- Command: `TEST_JOBS=4 ./tools/test.sh`
- Result: PASS, exit 0
- Notes: run id `20260615-155012-74831`; macOS certificate warning and existing push_warning messages are non-fatal.

- Command: `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/graph12-visual-verify.log --path . --script res://tools/graph12_visual_verify.gd`
- Result: PASS, exit 0
- Notes: artifact dir `.godot_user/visual-verification/GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN/2026-06-15_154938`; raster capture skipped under `--headless`, layout/state record completed.
