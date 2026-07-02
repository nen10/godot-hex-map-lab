# Proof Log — GQM track

Queue: `IMPLEMENTATION_QUEUE.md`（本 dir）。Entry 形式は `docs/process/QUEUE_OPERATION_RULES.md` に従う。

### GQM_DESIGN_LOCK_2026-07-03

proof:
  design:
    - `DESIGN_DIALOGUE.md`（round 1-3 + 確定記録）
    - `RESOURCE_MODEL.md`（Q-RM-1..3 確定）
    - `DEPENDENCY_UX_PROPOSALS.md`（round 1-4。統合4ノード・無型edge・adaptation・Q-DEP 全確定）
  godot_feasibility:
    - GraphEdit / GraphNode stable class docs 確認（same-type 接続規則 / connection_request 委譲 / 循環防止なし / 子Control=slot行 / titlebar 拡張）— `DEPENDENCY_UX_PROPOSALS.md` R3-3
  decision:
    - 旧 queue `REPAIR-21` は `GQM-03` に吸収（SUPERSEDED）。`REPAIR-22` は既に SUPERSEDED、`REPAIR-23` は tail BACKLOG。

### GQM-01_CONSOLIDATED_NODE_ENGINE_AND_ADAPTATION

proof:
  review: `docs/review/autopilot/GQM-01_SELF_REVIEW_2026-07-03.md`
  execution:
    - `docs/review/autopilot/GQM-01_SELF_REVIEW_2026-07-03.md`
  tests:
    - `./tools/test.sh` (exit 0)
  acceptance:
    - `tests/test_generation_graph.gd` builds the R2-3 basic form as consolidated 7 node / 9 edge graph and compares Result substrate cells/walls plus overlay item cells against the legacy 15 node / 16 edge graph with the same seed.
    - `tests/test_generation_graph.gd` covers the adaptation matrix for terrain / overlay / selection / empty producers and floor / wall / any / cells / item adaptations.
    - `tests/test_generation_graph.gd` covers `would_create_cycle()` true and false cases.
    - `tests/test_generation_graph.gd` covers `normalize_graph()` parity for a straight legacy chain and the basic legacy graph.
  major files:
    - `addons/hex_map_kit/generation/hex_generation_adaptation.gd`
    - `addons/hex_map_kit/generation/hex_generation_graph_normalizer.gd`
    - `addons/hex_map_kit/generation/hex_generation_node_types.gd`
    - `addons/hex_map_kit/generation/hex_generation_graph.gd`
    - `addons/hex_map_kit/generation/hex_generation_graph_runner.gd`
    - `tests/test_generation_graph.gd`
    - `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md`

### GQM-02_ASSET_TWO_TIER_SERVICE_AND_RESOURCES

proof:
  implementation:
    - Added `HexMapAssetLibrary` as the generic two-tier asset service for bundled read-only presets and project assets under `hex_map_kit/asset_root`.
    - Migrated `HexAdjacencyRulePresets` to the service and kept existing bundled adjacency presets visible through the legacy bundled directory alias.
    - Added `HexItemPoolResource` with `display_name` and normalized `name` / `weight` / `limit` entries.
    - Extended `HexWallDistributionResource` with `display_name` and `from_preset(11/20/24)` initialization from `HexRandomizer` built-in weight arrays.
    - Added a minimal adjacency-rule dialog callsite update for source labels, project save, and duplicate-to-project.
  tests:
    - `tests/test_generation_graph_resource.gd` covers bundled/project integrated listing, source distinction, bundled write rejection, project root setting changes, duplicate-to-project, V5 graph save/load params, item pool `.tres` round-trip, wall distribution `.tres` round-trip, and preset weight equivalence.
    - `./tools/test.sh` passed with exit `0` after regenerating ignored local Godot imports; run id `20260703-062141-16845`.
    - UI metric report `.godot_user/ui-metrics/20260703-062141-16845/workspace_layout_metrics.md`: P0 `0`, P1 `0`.
  self_review:
    - `docs/review/autopilot/GQM-02_SELF_REVIEW_2026-07-03.md`

### GQM-03_SCHEMA_FOR_CONSOLIDATED_NODES

proof:
  review: `docs/review/autopilot/GQM-03_SCHEMA_FOR_CONSOLIDATED_NODES_SELF_REVIEW_2026-07-03.md`
  execution:
    - `docs/review/autopilot/GQM-03_SCHEMA_FOR_CONSOLIDATED_NODES_SELF_REVIEW_2026-07-03.md`
  tests:
    - `res://tests/test_generation_graph.gd` (focused run exit 0)
    - `./tools/test.sh` (exit 0; run id `20260703-063936-34518`)
  acceptance:
    - `HexGenerationParamSchema` exposes generation-layer `declarations(node_type)`, `schema_for(node_type, params)`, and `default_params(node_type)` for `terrain_generation`, `item_generation`, `set_operation`, and `result`.
    - `tests/test_generation_graph.gd` enumerates all consolidated node method options and validates declaration shape, effective boolean visibility, dynamic Markov wall probability label, derived defaults, affects arrays, and asset kinds without editor imports.
    - `tests/test_generation_graph.gd` proves schema default params execute through the runner for terrain-only, terrain+item+result, adjacency default item generation, and two-input set_operation graphs.
    - `tests/test_generation_graph.gd` mechanically verifies declared `affects` keys match the effective schema diffs across enumerated method states.
  major files:
    - `addons/hex_map_kit/generation/hex_generation_param_schema.gd`
    - `addons/hex_map_kit/generation/hex_generation_param_schema.gd.uid`
    - `tests/test_generation_graph.gd`
    - `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md`

### GQM_G1_PHASE_INTEGRATION_2026-07-03

proof:
  merged:
    - agent/cx-GQM-01（gate ACCEPT・engine/adaptation/normalizer）
    - agent/cx-GQM-02（gate ACCEPT・asset two-tier/resources）
    - agent/cx-GQM-03（gate ACCEPT・consolidated param schema）
  integration_tests:
    - `./tools/test.sh`（GQM-01+02 合流後, run id `20260703-062750-23496`, exit 0, 37 files all pass）
    - `./tools/test.sh`（GQM-03 合流後, run id `20260703-064503-39097`, exit 0）
  notes:
    - GQM-01/02 の self-review 命名は orchestrator 契約書の指定ミスを gate 規約（完全 task id 形式）へ是正
    - GQM-01 の commit は sandbox gitdir 制約により orchestrator 代行

### GQM-10_UNTYPED_CANVAS_AND_ADAPTATION_ROWS

proof:
  review: `docs/review/autopilot/GQM-10_UNTYPED_CANVAS_AND_ADAPTATION_ROWS_SELF_REVIEW_2026-07-03.md`
  execution:
    - `docs/review/autopilot/GQM-10_UNTYPED_CANVAS_AND_ADAPTATION_ROWS_SELF_REVIEW_2026-07-03.md`
  implementation:
    - Build graph canvas ports now render with a single untyped GraphEdit port type id `0` and one shared color for consolidated and legacy nodes.
    - `connection_request` is centralized in the canvas: cycle rejection uses `HexGenerationGraph.would_create_cycle`, consolidated inputs accept any producer with default edge adaptation, legacy inputs still use `HexGenerationPorts.compatible`, and one input keeps one connection.
    - Consolidated input rows embed adaptation controls for terrain/item/set inputs, persist the selected edge adaptation in the graph model, and feed the next graph run.
    - `set_operation` and `result` keep one empty variadic input row; connected rows are compacted after disconnection.
    - Result rows display runner resolution labels (`substrate`, `overlay N`, `unused`) from the last run report.
    - The Add Node row exposes only Terrain Generation / Item Generation / Set Operation / Result and creates nodes from `HexGenerationParamSchema.default_params()`.
  tests:
    - `res://tests/test_build_graph_canvas.gd` covers consolidated editor connections, cycle rejection, adaptation persistence/run effect, untyped ports, consolidated Add buttons, and legacy incompatible rejection.
    - `res://tests/test_build_screen_full.gd` passed in the standard suite with the updated consolidated canvas behavior.
    - `./tools/test.sh` exit `0`; run id `20260703-070921-58547`.
    - UI metric report `.godot_user/ui-metrics/20260703-070921-58547/workspace_layout_metrics.md`: P0 `0`, P1 `0`.
  major files:
    - `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
    - `addons/hex_map_kit/editor/hex_map_build_node_palette.gd`
    - `tests/test_build_graph_canvas.gd`
    - `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
    - `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md`

### GQM-10_VISUAL_VERIFICATION_2026-07-03（orchestrator 実施）

proof:
  method:
    - 非 headless Godot + `tools/probe_gqm10_canvas_visual.gd`（基本形 7 node / 9 edge を canvas API で構築し実描画キャプチャ）
  capture:
    - `.godot_user/visual-verification/GQM-10/basic_form_consolidated_canvas.png`
  verified:
    - 統合4ノードの構築・一色 edge・adaptation dropdown（terrain→floor / overlay→cells）・可変入力行（空き行1つ方式）・Result 行の substrate / overlay 0 / unused 解決・循環拒否（"Connection would create a cycle."）・run ok
  finding:
    - selection 入力の adaptation 表示が `none` で passthrough の意味が読めない → GQM-11 の deliverable に引き継ぎ済み

### GQM-16_RUNTIME_PARITY_WITH_REFERENCE_ASSETS

proof:
  review: `docs/review/autopilot/GQM-16_RUNTIME_PARITY_WITH_REFERENCE_ASSETS_SELF_REVIEW_2026-07-03.md`
  execution:
    - `docs/review/autopilot/GQM-16_RUNTIME_PARITY_WITH_REFERENCE_ASSETS_SELF_REVIEW_2026-07-03.md`
  tests:
    - focused `res://tests/test_generation_graph.gd` (exit 0)
    - focused `res://tests/test_generation_graph_resource.gd` (exit 0)
    - focused `res://tests/test_graph_runtime_build.gd` (exit 0)
    - `./tools/test.sh` (exit 0; run id `20260703-073022-75457`)
    - UI metric report `.godot_user/ui-metrics/20260703-073022-75457/workspace_layout_metrics.md`: P0 `0`, P1 `0`
  acceptance:
    - `distribution_asset_path`, `rules_asset_path`, and `item_pool_asset_path` resolve in the shared generation run layer before node execution.
    - Missing reference paths fall back to inline params and produce explicit `asset_reference_unresolved` warnings in runner/build reports.
    - Runtime Map Build and editor-side `HexGenerationGraphRunner` produce identical promoted terrain and overlay signatures for inline/embed and generated `.tres` reference-asset graph resources with the same seed.
    - Edge `adaptation` survives `HexGenerationGraphResource` dictionary conversion and `.tres` save/load round-trip.
  major files:
    - `addons/hex_map_kit/generation/hex_generation_node_types.gd`
    - `addons/hex_map_kit/generation/hex_generation_param_schema.gd`
    - `addons/hex_map_kit/generation/hex_generation_graph_runner.gd`
    - `addons/hex_map_kit/generation/hex_map_graph_builder.gd`
    - `addons/hex_map_kit/adapter/hex_generation_graph_resource.gd`
    - `tests/test_generation_graph.gd`
    - `tests/test_graph_runtime_build.gd`
    - `tests/test_generation_graph_resource.gd`

### GQM-11_CONSOLIDATED_NODE_INTERNAL_UI

proof:
  review: `docs/review/autopilot/GQM-11_CONSOLIDATED_NODE_INTERNAL_UI_SELF_REVIEW_2026-07-03.md`
  execution:
    - `docs/review/autopilot/GQM-11_CONSOLIDATED_NODE_INTERNAL_UI_SELF_REVIEW_2026-07-03.md`
  implementation:
    - Consolidated inspector param rows now render from `HexGenerationParamSchema.schema_for()`; old consolidated `_param_*` match helpers were removed and remaining branch logic is legacy-only.
    - Method fields refresh dependent rows in place through schema `affects`, including terrain wall/distribution mode changes and item placement criteria changes.
    - Consolidated node titlebars and inspector headers expose editable `display_name` plus criteria chips for wall distribution, adjacency rules, and item pool sources.
    - Criteria chips display inline/reference names through canonical params `distribution_asset_path`, `rules_asset_path`, and `item_pool_asset_path`, and criteria UI operations use `HexMapAssetLibrary`.
    - Selection input passthrough adaptation is displayed as `そのまま (selection)` instead of raw `none`.
  tests:
    - `res://tests/test_build_graph_canvas.gd` focused run exit `0`.
    - `res://tests/test_editor_generation.gd` focused run exit `0`.
    - `res://tests/test_build_screen_full.gd` focused run exit `0`.
    - `./tools/test.sh` exit `0`; run id `20260703-073658-80829`.
    - UI metric report `.godot_user/ui-metrics/20260703-073658-80829/workspace_layout_metrics.md`: P0 `0`, P1 `0`.
  acceptance:
    - `tests/test_editor_generation.gd` compares consolidated inspector rows to schema key order, verifies visible-row morphing without reselection, and checks inline/reference criteria chip labels.
    - `tests/test_build_graph_canvas.gd` verifies titlebar criteria chip display/open behavior and the clarified selection passthrough label.
    - `generation/` and `adapter/` were not changed; runtime path resolution remains owned by GQM-16 per contract.
  major files:
    - `addons/hex_map_kit/editor/hex_generation_criteria_ui.gd`
    - `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd`
    - `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
    - `addons/hex_map_kit/editor/hex_map_build_screen.gd`
    - `tests/test_editor_generation.gd`
    - `tests/test_build_graph_canvas.gd`
    - `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md`

### GQM-11_VISUAL_VERIFICATION_2026-07-03（orchestrator 実施）

proof:
  method:
    - 非 headless Godot + `tools/probe_gqm11_ui_visual.gd`（canvas+inspector 並置・morph 前後キャプチャ）
  capture:
    - `.godot_user/visual-verification/GQM-11/terrain_schema_inspector_and_chips.png`
    - `.godot_user/visual-verification/GQM-11/item_generation_weighted_before_morph.png`
    - `.godot_user/visual-verification/GQM-11/item_generation_adjacency_after_morph.png`
  verified:
    - schema 駆動 inspector（Terrain Generation の全 cascade 同居）・label_by_mode（markov 時 "Initial Probability"）・titlebar chip の preset 名解決（`dist: Maze`）・placement_method 変更での即時 morph と chip 名称変化（`rules: inline`）・Q-DEP-9 連動 default の可視化（Domain Source: Result Terrain Floor）・selection adaptation の「そのまま (selection)」表示
  integration_repair:
    - 並行 merge の意味的衝突（GQM-16 の `distribution_asset_path` 追加 × GQM-11 chip の先頭 entry 依存）を orchestrator が修理し、統合 `./tools/test.sh` exit 0 を確認
  findings:
    - 磨き込み3点を `GQM-18_CRITERIA_CHIP_POLISH` として queue 化

### GQM-15_LEGACY_GRAPH_LOAD_NORMALIZATION

proof:
  review: `docs/review/autopilot/GQM-15_LEGACY_GRAPH_LOAD_NORMALIZATION_SELF_REVIEW_2026-07-03.md`
  execution:
    - `docs/review/autopilot/GQM-15_LEGACY_GRAPH_LOAD_NORMALIZATION_SELF_REVIEW_2026-07-03.md`
  tests:
    - focused `res://tests/test_graph_load_context.gd` (exit 0)
    - focused `res://tests/test_graph_runtime_build.gd` (exit 0)
    - focused `res://tests/test_build_screen_full.gd` (exit 0)
    - `./tools/test.sh` (exit 0; run id `20260703-080151-6308`)
    - UI metric report `.godot_user/ui-metrics/20260703-080151-6308/workspace_layout_metrics.md`: P0 `0`, P1 `0`
  acceptance:
    - `HexGenerationGraphNormalizer.normalize_graph_for_load()` detects legacy non-consolidated node types, normalizes the graph once, and returns an explicit `normalization_report` with before/after counts and status text.
    - Build screen graph resource load and selected-layer context restore pass normalized dictionaries to the canvas; `tests/test_graph_load_context.gd` verifies a legacy sample resource loads into consolidated node types only and matches direct legacy Result output.
    - Runtime Map Build normalizes legacy graph resources before validation/run/promote; `tests/test_graph_runtime_build.gd` verifies same-seed terrain parity against direct legacy execution.
    - `HexGenerationPreset.from_profile()` emits the Simple profile as consolidated `terrain_generation -> result`; `tests/test_build_screen_full.gd` verifies consolidated node types and legacy-chain output parity.
  major files:
    - `addons/hex_map_kit/generation/hex_generation_graph_normalizer.gd`
    - `addons/hex_map_kit/editor/hex_map_build_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_graph_instantiator.gd`
    - `addons/hex_map_kit/generation/hex_map_graph_builder.gd`
    - `addons/hex_map_kit/generation/hex_generation_preset.gd`
    - `addons/hex_map_kit/generation/hex_generation_node_types.gd`
    - `tests/test_graph_load_context.gd`
    - `tests/test_graph_runtime_build.gd`
    - `tests/test_build_screen_full.gd`

### GQM-12_RESULT_STACK_AND_PROMOTE

proof:
  review: `docs/review/autopilot/GQM-12_RESULT_STACK_AND_PROMOTE_SELF_REVIEW_2026-07-03.md`
  execution:
    - `docs/review/autopilot/GQM-12_RESULT_STACK_AND_PROMOTE_SELF_REVIEW_2026-07-03.md`
  docs:
    - `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
  implementation:
    - Result slot rows expose substrate/unused/overlay resolution, tooltip reasons, overlay row ordering controls, write-policy controls, and per-row Promote.
    - Result graph edges carry `write_policy`; Result run metadata records ordered overlay inputs and a policy-composed stack signature while preserving the legacy first-overlay `overlay_map` contract.
    - Build screen routes Result row Promote through `HexGenerationPromote`, and the selected-Result inspector Promote action is disabled in favor of the row-level path.
  tests:
    - focused `res://tests/test_build_graph_canvas.gd` (exit 0)
    - focused `res://tests/test_generation_promote.gd` (exit 0)
    - focused `res://tests/test_generation_graph.gd` (exit 0; compatibility repair for legacy `overlay_map`)
    - `./tools/test.sh` (exit 0; run id `20260703-081215-16972`)
    - UI metric report `.godot_user/ui-metrics/20260703-081215-16972/workspace_layout_metrics.md`: P0 `0`, P1 `0`
  acceptance:
    - Overlay row reorder updates graph edge order and Result run overlay input order.
    - Row write policy (`add_item`, `replace_item`, `add_replace`) changes the policy-composed Result stack signature.
    - Substrate and overlay Result rows promote to generated document terrain/overlay layers with row metadata and stable replacement behavior.
    - Extra terrain remains an unused, non-blocking row with tooltip reason that the first terrain is the substrate.
  major files:
    - `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
    - `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd`
    - `addons/hex_map_kit/editor/hex_map_build_screen.gd`
    - `addons/hex_map_kit/generation/hex_generation_node_types.gd`
    - `addons/hex_map_kit/generation/hex_generation_promote.gd`
    - `tests/test_build_graph_canvas.gd`
    - `tests/test_generation_promote.gd`
    - `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
    - `docs/plan/2026-07-02_GRAPH_QUALITY_MANAGEMENT_UX_REDESIGN/IMPLEMENTATION_QUEUE.md`

### GQM-12_VISUAL_VERIFICATION_2026-07-03（orchestrator 実施）

proof:
  method:
    - 非 headless Godot + `tools/probe_gqm12_result_visual.gd`
  capture:
    - `.godot_user/visual-verification/GQM-12/result_stack_rows.png`
  verified:
    - Result 行の substrate/overlay N 解決・Up/Down 並べ替え（先頭/末尾の正しい無効化）・write policy dropdown・行 Promote・run ok
  finding:
    - 空き変則行の「unused」表示は未接続表現へ分離 → GQM-18 に追記済み

### GQM-18_CRITERIA_CHIP_POLISH

proof:
  review: `docs/review/autopilot/GQM-18_CRITERIA_CHIP_POLISH_SELF_REVIEW_2026-07-03.md`
  execution:
    - `docs/review/autopilot/GQM-18_CRITERIA_CHIP_POLISH_SELF_REVIEW_2026-07-03.md`
  implementation:
    - `*_asset_path` schema entries are declared `hidden: true`, and the inspector filters hidden entries out of `param_fields`, visible rows, and mounted controls.
    - Criteria chips are `MenuButton` asset operation menus with `Open editor...`, `Load from asset...`, `Save as asset...`, and `Detach to inline`; menu labels use asset display names and source badges, not paths.
    - Chip menu Load/Detach uses `HexMapAssetLibrary` and writes canonical reference params while preserving inline criteria data on detach.
    - Unconnected adaptation rows render `未接続` with no dropdown; connected selection passthrough remains `そのまま (selection)`.
    - Result empty rows render `未接続`, while connected unused rows retain `unused` and explicit `unused_reason`.
    - Consolidated titlebar display-name fields now reserve 220px and expand horizontally.
  tests:
    - focused `res://tests/test_build_graph_canvas.gd` (exit 0)
    - focused `res://tests/test_editor_generation.gd` (exit 0)
    - `./tools/test.sh` (exit 0; run id `20260703-082916-34691`)
    - UI metric report `.godot_user/ui-metrics/20260703-082916-34691/workspace_layout_metrics.md`: P0 `0`, P1 `0`
  acceptance:
    - `tests/test_editor_generation.gd` verifies hidden raw asset path rows and chip menu Load/Detach params mutation.
    - `tests/test_build_graph_canvas.gd` verifies unconnected vs connected selection rows, Result unconnected vs unused rows, and titlebar chip/menu/name-field behavior.
    - Actual rendered capture confirmation remains assigned to orchestrator per GQM-18 user contract.
  major files:
    - `addons/hex_map_kit/editor/hex_generation_criteria_ui.gd`
    - `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd`
    - `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
    - `addons/hex_map_kit/generation/hex_generation_param_schema.gd`
    - `tests/test_build_graph_canvas.gd`
    - `tests/test_editor_generation.gd`
    - `docs/review/autopilot/GQM-18_CRITERIA_CHIP_POLISH_SELF_REVIEW_2026-07-03.md`
