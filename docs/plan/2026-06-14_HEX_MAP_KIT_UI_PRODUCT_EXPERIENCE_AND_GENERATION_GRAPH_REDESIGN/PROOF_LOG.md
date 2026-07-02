# Completed Task Proof Log

Companion to `IMPLEMENTATION_QUEUE.md`（queue を executor context 用に lean に保つため分離）。完了時に `### <TASK-ID>` proof entry を追記する。

### REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY/`
  source_handoff:
    - `docs/development_log/2026-06-21_BUILD_TAB_UX_IMPLEMENTATION_HANDOFF.md`
    - `docs/development_log/2026-06-22_BUILD_GENERATE_VIEWPORT_PREVIEW_DESIGN_CLARIFICATION.md`
    - `docs/development_log/2026-06-22_BUILD_GENERATE_VIEWPORT_PREVIEW_REPAIR_MATRIX.md`
  diagnostic_probe:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/repair10-viewport-probe.log --path . --script res://tools/build_generate_viewport_probe.gd`（exit 0）
    - `.godot_user/visual-verification/REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY/2026-06-22_020936/build_generate_viewport_probe.json`
    - probe result: `selected_layer_inside_tree=true`, `selected_layer_display_used_cell_count=24`, `viewport_projection_ok=true`, `preview_commit_state=preview_pending`, `node_thumbnail_secondary=true`
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/repair10-generation-promote.log --path . --script res://tests/test_generation_promote.gd`（exit 0）
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/repair10-build-screen-full.log --path . --script res://tests/test_build_screen_full.gd`（exit 0）
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/repair10-build-graph-canvas.log --path . --script res://tests/test_build_graph_canvas.gd`（exit 0）
    - `./tools/test.sh`（run id `20260622-021019-48573`, exit 0）
  acceptance:
    - Top `Generate` synchronously acquires Build context before graph run.
    - No selected layer path creates/selects `BuildHexMapLayer` and records successful viewport projection.
    - Selected graphless layer path keeps the selected `HexTileMapLayer`, attaches document/graph, and records successful viewport projection.
    - Result output promotion applies terrain + overlay to the active document/layer path.
    - `Apply` keeps the projected result and disables Revert; `Revert` restores the previous in-memory document and viewport display.
    - Thumbnail/cache-only proof is rejected by tests via `node_thumbnail_secondary` and `viewport_apply_report.projection_ok`.
  follow_up_tasks:
    - `REPAIR-11_GRAPH_RESULT_MULTI_OVERLAY_CONTRACT`
    - `REPAIR-12_INTERMEDIATE_OUTPUT_CHILD_NODES`
    - `REPAIR-13_GRAPH_WIDE_STATE_AND_FILTER_SPLIT`
    - `REPAIR-14_GRAPH_CANVAS_EDGE_DELETE`
    - `REPAIR-15_MARKOV_ADJACENCY_MAPPING`
  major files:
    - `addons/hex_map_kit/editor/hex_map_build_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
    - `addons/hex_map_kit/generation/hex_generation_preset.gd`
    - `addons/hex_map_kit/adapter/hex_map_document_adapter.gd`
    - `tools/build_generate_viewport_probe.gd`
    - `tests/test_generation_promote.gd`
    - `tests/test_build_screen_full.gd`
    - `tests/test_build_graph_canvas.gd`

### ADOPT-00 Baselines and acceptance gate

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/ADOPT-00_BASELINES_AND_ACCEPTANCE_GATE/`
  review: `docs/review/autopilot/ADOPT-00_SELF_REVIEW_2026-06-15.md`
  tests:
    - `./tools/test.sh`（全 `test_*.gd` が `all tests passed`。警告は overlay test の既存 push_warning で失敗ではない。docs/process のみの変更でコード非変更。）
  docs:
    - `docs/review/autopilot/SELF_REVIEW_TEMPLATE.md`（Experiential DoD セクション追加）
    - `docs/process/QUEUE_OPERATION_RULES.md`（Two-layer DoD gate / QA park 追加）
    - `docs/policy/PLANNING_POLICY.md`（review checklist に experiential DoD / baseline 整合追加）
    - `docs/design/PRODUCT_DEFINITION.md` / `docs/design/GENERATION_GRAPH_MODEL.md`（baseline 参照元）
  major files:
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/ADOPT-00_BASELINES_AND_ACCEPTANCE_GATE/SUB_TASKS.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/ADOPT-00_BASELINES_AND_ACCEPTANCE_GATE/UX.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/ADOPT-00_BASELINES_AND_ACCEPTANCE_GATE/POLICY.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/ADOPT-00_BASELINES_AND_ACCEPTANCE_GATE/IMPLEMENTATION_PLAN.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/IMPLEMENTATION_QUEUE.md`

### GRAPH-10_MODEL_AND_HEADLESS_PASSES

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-10_MODEL_AND_HEADLESS_PASSES/`
  review: `docs/review/autopilot/GRAPH-10_MODEL_AND_HEADLESS_PASSES_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/GRAPH-10_MODEL_AND_HEADLESS_PASSES_SELF_REVIEW_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-144621-75831/workspace_layout_metrics.md`（non-UI task; P0 failures = 0, P1 issues = 0）
  tests:
    - `./tools/test.sh`（run id `20260615-144621-75831`, exit 0）
    - `.godot_user/test-runs/20260615-144621-75831/logs/test_generation_graph.gd.log`
  docs:
    - `docs/TEST.md`
    - `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
  major files:
    - `addons/hex_map_kit/generation/hex_generation_ports.gd`
    - `addons/hex_map_kit/generation/hex_generation_graph.gd`
    - `addons/hex_map_kit/generation/hex_generation_node_types.gd`
    - `addons/hex_map_kit/generation/hex_generation_graph_runner.gd`
    - `tests/test_generation_graph.gd`
    - `tools/test.sh`
    - `tools/hexq_queue.py`
    - `tools/verify_task.py`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-10_MODEL_AND_HEADLESS_PASSES/SUB_TASKS.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-10_MODEL_AND_HEADLESS_PASSES/UX.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-10_MODEL_AND_HEADLESS_PASSES/POLICY.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-10_MODEL_AND_HEADLESS_PASSES/IMPLEMENTATION_PLAN.md`

### DESIGN-10 Backbone wireframes

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DESIGN-10_BACKBONE_WIREFRAMES/`
  review: `docs/review/autopilot/DESIGN-10_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/DESIGN-10_SELF_REVIEW_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-145019-87564/workspace_layout_metrics.md`（UI-facing design artifact; P0 failures = 0, P1 issues = 0）
  tests:
    - `./tools/test.sh`（run id `20260615-145019-87564`, exit 0）
  docs:
    - `docs/policy/LAYOUT_SKETCH_POLICY.md`
  major files:
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DESIGN-10_BACKBONE_WIREFRAMES/SUB_TASKS.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DESIGN-10_BACKBONE_WIREFRAMES/UX.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DESIGN-10_BACKBONE_WIREFRAMES/POLICY.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DESIGN-10_BACKBONE_WIREFRAMES/IMPLEMENTATION_PLAN.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DESIGN-10_BACKBONE_WIREFRAMES/WIREFRAMES.md`

### DESIGN-11 Tab IA and priority

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DESIGN-11_TAB_IA_AND_PRIORITY/`
  review: `docs/review/autopilot/DESIGN-11_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/DESIGN-11_SELF_REVIEW_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-145948-8021/workspace_layout_metrics.md`（UI-facing design artifact; P0 failures = 0, P1 issues = 0）
  tests:
    - `./tools/test.sh`（run id `20260615-145948-8021`, exit 0）
  phase_review:
    - `docs/review/roadmap/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN_Y1_PHASE_REVIEW_2026-06-15.md`
  docs:
    - `docs/policy/LAYOUT_SKETCH_POLICY.md`
  major files:
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DESIGN-11_TAB_IA_AND_PRIORITY/SUB_TASKS.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DESIGN-11_TAB_IA_AND_PRIORITY/UX.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DESIGN-11_TAB_IA_AND_PRIORITY/POLICY.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DESIGN-11_TAB_IA_AND_PRIORITY/IMPLEMENTATION_PLAN.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DESIGN-11_TAB_IA_AND_PRIORITY/TAB_IA.md`

### GRAPH-11_BUILD_TAB_GRAPH_CANVAS

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-11_BUILD_TAB_GRAPH_CANVAS/`
  review: `docs/review/autopilot/GRAPH-11_BUILD_TAB_GRAPH_CANVAS_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/GRAPH-11_BUILD_TAB_GRAPH_CANVAS_SELF_REVIEW_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-153318-51063/workspace_layout_metrics.md`（UI-facing task; P0 failures = 0, P1 issues = 0）
  tests:
    - `./tools/test.sh`（run id `20260615-153318-51063`, exit 0）
    - `.godot_user/test-runs/20260615-153318-51063/logs/test_build_graph_canvas.gd.log`
  docs:
    - `docs/TEST.md`
    - `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
    - `addons/hex_map_kit/editor/hex_map_build_node_palette.gd`
    - `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd`
    - `addons/hex_map_kit/editor/hex_map_build_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
    - `tests/test_build_graph_canvas.gd`
    - `tests/test_editor_plugin.gd`
    - `tests/test_editor_workspace.gd`
    - `tests/test_editor_plugin_test_base.gd`
    - `tools/test.sh`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-11_BUILD_TAB_GRAPH_CANVAS/SUB_TASKS.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-11_BUILD_TAB_GRAPH_CANVAS/UX.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-11_BUILD_TAB_GRAPH_CANVAS/POLICY.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-11_BUILD_TAB_GRAPH_CANVAS/IMPLEMENTATION_PLAN.md`

### GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN/`
  review: `docs/review/autopilot/GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN_SELF_REVIEW_2026-06-15.md`
    - `docs/review/autopilot/GRAPH-12_HEADLESS_VISUAL_VERIFICATION_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-155012-74831/workspace_layout_metrics.md`（UI-facing graph task; P0 failures = 0, P1 issues = 0）
  visual_verification:
    - `.godot_user/visual-verification/GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN/2026-06-15_154938/graph12_visual_verification.md`
    - `.godot_user/visual-verification/GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN/2026-06-15_154938/graph12_visual_verification.json`
    - `.godot_user/test-runs/graph12-visual-verify.log`
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/manual-graph12-promote.log --path . --script res://tests/test_generation_promote.gd`（exit 0）
    - `./tools/test.sh`（run id `20260615-155012-74831`, exit 0）
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/graph12-visual-verify.log --path . --script res://tools/graph12_visual_verify.gd`（exit 0）
  docs:
    - `docs/TEST.md`
    - `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
    - `docs/review/autopilot/GRAPH-12_HEADLESS_VISUAL_VERIFICATION_2026-06-15.md`
  major files:
    - `addons/hex_map_kit/generation/hex_generation_promote.gd`
    - `addons/hex_map_kit/generation/hex_generation_node_types.gd`
    - `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
    - `addons/hex_map_kit/editor/hex_map_build_screen.gd`
    - `tests/test_generation_promote.gd`
    - `tests/test_editor_plugin_test_base.gd`
    - `tools/test.sh`
    - `tools/graph12_visual_verify.gd`

### GRAPH-12A_BUILD_CONTEXT_BOOTSTRAP

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-12A_BUILD_CONTEXT_BOOTSTRAP/`
  review: `docs/review/autopilot/GRAPH-12A_BUILD_CONTEXT_BOOTSTRAP_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/GRAPH-12A_BUILD_CONTEXT_BOOTSTRAP_SELF_REVIEW_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-163327-12391/workspace_layout_metrics.md`（UI-facing graph task; P0 failures = 0, P1 issues = 0）
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/graph12a-generation-promote.log --path . --script res://tests/test_generation_promote.gd`（exit 0）
    - `./tools/test.sh`（run id `20260615-163327-12391`, exit 0）
  docs:
    - `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
  major files:
    - `addons/hex_map_kit/adapter/hex_generation_graph_resource.gd`
    - `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
    - `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
    - `addons/hex_map_kit/editor/hex_map_build_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_generation_promote.gd`
    - `tests/test_editor_plugin_test_base.gd`

### GRAPH-13_RUN_UX

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-13_RUN_UX/`
  review: `docs/review/autopilot/GRAPH-13_RUN_UX_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/GRAPH-13_RUN_UX_SELF_REVIEW_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-171816-63647/workspace_layout_metrics.md`（UI-facing graph task; P0 failures = 0, P1 issues = 0）
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/graph13-runner-dirty.log --path . --script res://tests/test_generation_graph_runner_dirty.gd`（exit 0）
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/graph13-build-canvas.log --path . --script res://tests/test_build_graph_canvas.gd`（exit 0）
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/graph13-generation-promote.log --path . --script res://tests/test_generation_promote.gd`（exit 0）
    - `./tools/test.sh`（run id `20260615-171816-63647`, exit 0）
  docs:
    - `docs/TEST.md`
    - `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
  major files:
    - `addons/hex_map_kit/generation/hex_generation_graph_runner.gd`
    - `addons/hex_map_kit/generation/hex_generation_node_types.gd`
    - `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
    - `addons/hex_map_kit/editor/hex_map_build_screen.gd`
    - `tests/test_generation_graph_runner_dirty.gd`
    - `tests/test_build_graph_canvas.gd`
    - `tools/test.sh`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-13_RUN_UX/SUB_TASKS.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-13_RUN_UX/UX.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-13_RUN_UX/POLICY.md`
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-13_RUN_UX/IMPLEMENTATION_PLAN.md`

### GRAPH-14_GRAPH_RESOURCE

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/GRAPH-14_GRAPH_RESOURCE/`
  review: `docs/review/autopilot/GRAPH-14_GRAPH_RESOURCE_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/GRAPH-14_GRAPH_RESOURCE_SELF_REVIEW_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-172332-74043/workspace_layout_metrics.md`（graph/resource task; P0 failures = 0, P1 issues = 0）
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/graph14-resource.log --path . --script res://tests/test_generation_graph_resource.gd`（exit 0）
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/graph14-generation-promote.log --path . --script res://tests/test_generation_promote.gd`（exit 0）
    - `./tools/test.sh`（run id `20260615-172332-74043`, exit 0）
  docs:
    - `docs/TEST.md`
    - `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
  major files:
    - `addons/hex_map_kit/adapter/hex_generation_graph_resource.gd`
    - `addons/hex_map_kit/editor/hex_map_build_screen.gd`
    - `tests/test_generation_graph_resource.gd`
    - `tools/test.sh`

### RUNTIME-50_GRAPH_RESOURCE_AND_RUNTIME_MAP_BUILD_API

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/RUNTIME-50_GRAPH_RESOURCE_AND_RUNTIME_MAP_BUILD_API/`
  review: `docs/review/autopilot/RUNTIME-50_GRAPH_RESOURCE_AND_RUNTIME_MAP_BUILD_API_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/RUNTIME-50_GRAPH_RESOURCE_AND_RUNTIME_MAP_BUILD_API_SELF_REVIEW_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-173729-97207/workspace_layout_metrics.md`（runtime API task; P0 failures = 0, P1 issues = 0）
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/runtime50-graph-build.log --path . --script res://tests/test_graph_runtime_build.gd`（exit 0）
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/runtime50-graph-resource.log --path . --script res://tests/test_generation_graph_resource.gd`（exit 0）
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/runtime50-tile-layer.log --path . --script res://tests/test_hex_tile_map_layer.gd`（exit 0）
    - `./tools/test.sh`（run id `20260615-173729-97207`, exit 0）
  docs:
    - `docs/TEST.md`
    - `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
  major files:
    - `addons/hex_map_kit/generation/hex_map_graph_builder.gd`
    - `addons/hex_map_kit/adapter/hex_generation_graph_resource.gd`
    - `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
    - `examples/basic_runtime/runtime_graph_build_sample.gd`
    - `examples/basic_runtime/README.md`
    - `tests/test_graph_runtime_build.gd`
    - `tools/test.sh`

### RUNTIME-51_GRAPH_LOAD_AND_CONTEXT_OWNERSHIP

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/RUNTIME-51_GRAPH_LOAD_AND_CONTEXT_OWNERSHIP/`
  review: `docs/review/autopilot/RUNTIME-51_GRAPH_LOAD_AND_CONTEXT_OWNERSHIP_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/RUNTIME-51_GRAPH_LOAD_AND_CONTEXT_OWNERSHIP_SELF_REVIEW_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-174804-14344/workspace_layout_metrics.md`（UI/graph task; P0 failures = 0, P1 issues = 0）
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/runtime51-graph-load-context.log --path . --script res://tests/test_graph_load_context.gd`（exit 0）
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/runtime51-build-canvas.log --path . --script res://tests/test_build_graph_canvas.gd`（exit 0）
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/runtime51-generation-promote.log --path . --script res://tests/test_generation_promote.gd`（exit 0）
    - `./tools/test.sh`（run id `20260615-174804-14344`, exit 0）
  phase_review:
    - `docs/review/roadmap/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN_Y2_PHASE_REVIEW_2026-06-15.md`
  docs:
    - `docs/TEST.md`
    - `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_graph_instantiator.gd`
    - `addons/hex_map_kit/editor/hex_map_build_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_graph_load_context.gd`
    - `tools/test.sh`

### SCREEN-30_BUILD_TAB_FULL

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/SCREEN-30_BUILD_TAB_FULL/`
  review: `docs/review/autopilot/SCREEN-30_BUILD_TAB_FULL_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/SCREEN-30_BUILD_TAB_FULL_SELF_REVIEW_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-180325-42117/workspace_layout_metrics.md`（UI task; P0 failures = 0, P1 issues = 0）
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/screen30-targeted/logs/test_build_screen_full.gd.log --path . --script res://tests/test_build_screen_full.gd`（exit 0）
    - `TEST_JOBS=1 HEX_MAP_TEST_RUN_ID=screen30-nearby ./tools/test.sh`（exit 0）
    - `TEST_JOBS=4 ./tools/test.sh`（run id `20260615-180325-42117`, exit 0）
  docs:
    - `docs/TEST.md`
    - `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
  major files:
    - `addons/hex_map_kit/generation/hex_generation_preset.gd`
    - `addons/hex_map_kit/editor/hex_map_build_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_build_screen_full.gd`
    - `tools/test.sh`

### SCREEN-31_PAINT_AS_DESIGN_WORKSPACE

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/SCREEN-31_PAINT_AS_DESIGN_WORKSPACE/`
  review: `docs/review/autopilot/SCREEN-31_PAINT_AS_DESIGN_WORKSPACE_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/SCREEN-31_PAINT_AS_DESIGN_WORKSPACE_SELF_REVIEW_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-181231-58565/workspace_layout_metrics.md`（UI task; P0 failures = 0, P1 issues = 0）
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/screen31-targeted/logs/test_editor_paint.gd.log --path . --script res://tests/test_editor_paint.gd`（exit 0）
    - `TEST_JOBS=4 ./tools/test.sh`（run id `20260615-181231-58565`, exit 0）
  docs:
    - `docs/TEST.md`
    - `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_paint_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_paint.gd`

### SCREEN-32_EXPORT_AS_HANDOFF

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/SCREEN-32_EXPORT_AS_HANDOFF/`
  review: `docs/review/autopilot/SCREEN-32_EXPORT_AS_HANDOFF_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/SCREEN-32_EXPORT_AS_HANDOFF_SELF_REVIEW_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-182931-82510/workspace_layout_metrics.md`（UI task; P0 failures = 0, P1 issues = 0）
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/screen32-targeted/logs/test_editor_output.gd.log --path . --script res://tests/test_editor_output.gd`（exit 0）
    - `TEST_JOBS=4 ./tools/test.sh`（run id `20260615-182931-82510`, exit 0）
  phase_review:
    - `docs/review/roadmap/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN_Y3_PHASE_REVIEW_2026-06-15.md`
  major files:
    - `addons/hex_map_kit/editor/hex_map_export_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_export_workflow_state.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `tests/test_editor_output.gd`

### SCREEN-40_CATALOG_VISUAL_BOARD

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/SCREEN-40_CATALOG_VISUAL_BOARD/`
  review: `docs/review/autopilot/SCREEN-40_CATALOG_VISUAL_BOARD_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/SCREEN-40_CATALOG_VISUAL_BOARD_SELF_REVIEW_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-184103-1111/workspace_layout_metrics.md`（UI task; P0 failures = 0, P1 issues = 0）
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/screen40-targeted/logs/test_editor_catalog.gd.log --path . --script res://tests/test_editor_catalog.gd`（exit 0）
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/screen40-workspace/logs/test_editor_workspace.gd.log --path . --script res://tests/test_editor_workspace.gd`（exit 0）
    - `TEST_JOBS=4 ./tools/test.sh`（run id `20260615-184103-1111`, exit 0）
  major files:
    - `addons/hex_map_kit/editor/hex_map_catalog_editor_component.gd`
    - `addons/hex_map_kit/editor/hex_map_catalog_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
    - `tests/test_editor_catalog.gd`
    - `tests/test_editor_workspace.gd`

### SCREEN-41_LAYERS_STACK_VISUAL

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/SCREEN-41_LAYERS_STACK_VISUAL/`
  review: `docs/review/autopilot/SCREEN-41_LAYERS_STACK_VISUAL_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/SCREEN-41_LAYERS_STACK_VISUAL_SELF_REVIEW_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-185605-25968/workspace_layout_metrics.md`（UI task; P0 failures = 0, P1 issues = 0）
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/screen41-target/logs/test_editor_layer.gd.log --path . --script res://tests/test_editor_layer.gd`（exit 0）
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/screen41-target/logs/test_editor_workspace.gd.log --path . --script res://tests/test_editor_workspace.gd`（exit 0）
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/screen41-target/logs/test_workspace_screen_contracts.gd.log --path . --script res://tests/test_workspace_screen_contracts.gd`（exit 0）
    - `TEST_JOBS=4 ./tools/test.sh`（run id `20260615-185605-25968`, exit 0）
  major files:
    - `addons/hex_map_kit/editor/hex_map_layers_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
    - `tests/test_editor_layer.gd`
    - `tests/test_editor_workspace.gd`

### RESCTX-42_RESOURCES_SHELF_AND_CONTEXT_CHIPS

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/RESCTX-42_RESOURCES_SHELF_AND_CONTEXT_CHIPS/`
  review: `docs/review/autopilot/RESCTX-42_RESOURCES_SHELF_AND_CONTEXT_CHIPS_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/RESCTX-42_RESOURCES_SHELF_AND_CONTEXT_CHIPS_SELF_REVIEW_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-191640-55354/workspace_layout_metrics.md`（UI task; P0 failures = 0, P1 issues = 0）
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/resctx42-target/logs/test_editor_document.gd.log --path . --script res://tests/test_editor_document.gd`（exit 0）
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/resctx42-target/logs/test_editor_workspace.gd.log --path . --script res://tests/test_editor_workspace.gd`（exit 0）
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/resctx42-target/logs/test_editor_paint.gd.log --path . --script res://tests/test_editor_paint.gd`（exit 0）
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/test-runs/resctx42-target/logs/test_build_screen_full.gd.log --path . --script res://tests/test_build_screen_full.gd`（exit 0）
    - `TEST_JOBS=4 ./tools/test.sh`（run id `20260615-191640-55354`, exit 0）
  major files:
    - `addons/hex_map_kit/editor/hex_map_resources_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_workspace.gd`
    - `addons/hex_map_kit/editor/hex_map_build_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_paint_screen.gd`
    - `tests/test_editor_document.gd`
    - `tests/test_editor_workspace.gd`
    - `tests/test_editor_paint.gd`

### PROCESS-60_METRIC_AS_REGRESSION_ONLY

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/PROCESS-60_METRIC_AS_REGRESSION_ONLY/`
  review: `docs/review/autopilot/PROCESS-60_METRIC_AS_REGRESSION_ONLY_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/PROCESS-60_METRIC_AS_REGRESSION_ONLY_SELF_REVIEW_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-192722-74644/workspace_layout_metrics.md`（process task regression proof; P0 failures = 0, P1 issues = 0）
  tests:
    - `TEST_JOBS=4 ./tools/test.sh`（run id `20260615-192722-74644`, exit 0）
  phase_review:
    - `docs/review/roadmap/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN_Y6_PHASE_REVIEW_2026-06-15.md`
  docs:
    - `docs/TEST.md`
    - `docs/policy/UI_LAYOUT_METRIC_TEST_PROCESS_AND_ACCEPTANCE_POLICY_2026-06-10.md`
  major files:
    - `docs/policy/UI_LAYOUT_METRIC_TEST_PROCESS_AND_ACCEPTANCE_POLICY_2026-06-10.md`
    - `docs/TEST.md`
    - `tools/test.sh`
    - `tests/test_workspace_layout_metric_gate.gd`

### DOC-70_WORKFLOW_MANUAL

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/DOC-70_WORKFLOW_MANUAL/`
  review: `docs/review/autopilot/DOC-70_WORKFLOW_MANUAL_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/DOC-70_WORKFLOW_MANUAL_SELF_REVIEW_2026-06-15.md`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-193412-87175/workspace_layout_metrics.md`（docs task regression proof; P0 failures = 0, P1 issues = 0）
  tests:
    - `TEST_JOBS=4 ./tools/test.sh`（run id `20260615-193412-87175`, exit 0）
  docs:
    - `docs/manual/MANUAL_WORKFLOW.md`
    - `README.md`
  major files:
    - `docs/manual/MANUAL_WORKFLOW.md`
    - `README.md`

### PROC-90_FINAL_DIST_REGEN

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/PROC-90_FINAL_DIST_REGEN/`
  review: `docs/review/autopilot/PROC-90_FINAL_DIST_REGEN_SELF_REVIEW_2026-06-15.md`
  execution:
    - `docs/review/autopilot/PROC-90_FINAL_DIST_REGEN_SELF_REVIEW_2026-06-15.md`
  package:
    - `./tools/package_addon.sh`（wrote `dist/hex_map_kit-0.3.0.manifest.txt`, `dist/hex_map_kit-0.3.0.zip`）
    - manifest sha256 `b6595acd4df7f9dfd1c47eb2aebcb049ebbe75efed3922b22a4ad61371d33cbd`
    - zip sha256 `ac6379a2597f8e9a0ac48c2cdf3bde3d21bee1093fcb48937c6f8fdc1f9a02c4`
  ui_metrics:
    - `.godot_user/ui-metrics/20260615-193715-93980/workspace_layout_metrics.md`（process task regression proof; P0 failures = 0, P1 issues = 0）
  tests:
    - `TEST_JOBS=4 ./tools/test.sh`（run id `20260615-193715-93980`, exit 0）
  phase_review:
    - `docs/review/roadmap/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN_Y7_PHASE_REVIEW_2026-06-15.md`
  major files:
    - `dist/hex_map_kit-0.3.0.manifest.txt`
    - `dist/hex_map_kit-0.3.0.zip`

### REPAIR-14_GRAPH_CANVAS_EDGE_DELETE

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/REPAIR-14_GRAPH_CANVAS_EDGE_DELETE/`
  execution:
    - `docs/review/autopilot/REPAIR-14_GRAPH_CANVAS_EDGE_DELETE_SELF_REVIEW_2026-06-24.md`
    - `docs/review/autopilot/REPAIR-14_GRAPH_CANVAS_EDGE_DELETE_TEST_RESULT_2026-06-24.md`
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/probe-logs/repair14_canvas.log --path . --script res://tests/test_build_graph_canvas.gd` (exit 0)
    - `TEST_JOBS=4 ./tools/test.sh` (run id `20260624-024316-3036`, exit 0)
  major files:
    - `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
    - `addons/hex_map_kit/editor/hex_map_build_screen.gd`
    - `tests/test_build_graph_canvas.gd`

### REPAIR-13A_BUILD_NODE_ADD_ROW_AND_SOURCE_TYPING

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/REPAIR-13A_BUILD_NODE_ADD_ROW_AND_SOURCE_TYPING/`
  execution:
    - `docs/review/autopilot/REPAIR-13A_BUILD_NODE_ADD_ROW_AND_SOURCE_TYPING_SELF_REVIEW_2026-06-24.md`
    - `docs/review/autopilot/REPAIR-13A_BUILD_NODE_ADD_ROW_AND_SOURCE_TYPING_TEST_RESULT_2026-06-24.md`
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/probe-logs/repair13a_canvas.log --path . --script res://tests/test_build_graph_canvas.gd` (exit 0)
    - `TEST_JOBS=4 ./tools/test.sh` (run id `20260624-025040-8356`, exit 0)
  major files:
    - `addons/hex_map_kit/editor/hex_map_build_node_palette.gd`
    - `addons/hex_map_kit/editor/hex_map_build_screen.gd`
    - `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
    - `tests/test_build_graph_canvas.gd`


### REPAIR-11_GRAPH_RESULT_MULTI_OVERLAY_CONTRACT

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/REPAIR-11_GRAPH_RESULT_MULTI_OVERLAY_CONTRACT/`
  implementation_commit:
    - `0814740 Implement REPAIR-11, REPAIR-13 result multi-overlay projection`
  tests:
    - `TEST_JOBS=4 ./tools/test.sh` (run id `20260624-025040-8356`, exit 0)
  major files:
    - `addons/hex_map_kit/generation/hex_generation_node_types.gd`
    - `addons/hex_map_kit/adapter/hex_generation_result_resource.gd`
    - `addons/hex_map_kit/generation/hex_generation_promote.gd`
    - `addons/hex_map_kit/editor/hex_map_build_screen.gd`
    - `tests/test_generation_graph.gd`
    - `tests/test_generation_promote.gd`

### BUILD_NODE_DESIGN_GAPS_FINDINGS_2026-06-24

proof:
  findings: `docs/development_log/2026-06-24_BUILD_NODE_DESIGN_GAPS_FINDINGS.md`
  probe:
    - `tools/probe_region_filter_connection_typing.gd`
  command:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/probe-logs/probe_region_filter_typing3.log --path . --script /tmp/probe_region_filter_typing.gd` (exit 0)
  result:
    - `logical_validate_ok = true`
    - `graphedit_drag_allows_overlay_to_filter = false`
    - `item_generator_output_type_id = 3`, `region_filter_input_type_id = 1`


### REPAIR-16_REGION_FILTER_NODE_TYPING_REDESIGN

proof:
  findings: `docs/development_log/2026-06-24_BUILD_NODE_DESIGN_GAPS_FINDINGS.md`
  execution:
    - `docs/review/autopilot/REPAIR-16_REGION_FILTER_NODE_TYPING_REDESIGN_SELF_REVIEW_2026-06-24.md`
    - `docs/review/autopilot/REPAIR-16_REGION_FILTER_NODE_TYPING_REDESIGN_TEST_RESULT_2026-06-24.md`
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/probe-logs/repair16_canvas.log --path . --script res://tests/test_build_graph_canvas.gd` (exit 0)
    - `TEST_JOBS=4 ./tools/test.sh` (run id `20260624-041801-44801`, exit 0)
  major files:
    - `addons/hex_map_kit/generation/hex_generation_node_types.gd`
    - `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
    - `addons/hex_map_kit/editor/hex_map_build_node_palette.gd`
    - `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd`
    - `addons/hex_map_kit/editor/hex_map_build_screen.gd`
    - `tests/test_build_graph_canvas.gd`


### REPAIR-17_ADJACENCY_RULES_WINDOW

proof:
  findings: `docs/development_log/2026-06-24_BUILD_NODE_DESIGN_GAPS_FINDINGS.md`
  execution:
    - `docs/review/autopilot/REPAIR-17_ADJACENCY_RULES_WINDOW_SELF_REVIEW_2026-06-24.md`
    - `docs/review/autopilot/REPAIR-17_ADJACENCY_RULES_WINDOW_TEST_RESULT_2026-06-24.md`
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/probe-logs/repair17_18_test_generation_graph.log --path . --script res://tests/test_generation_graph.gd` (exit 0)
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/probe-logs/repair17_18_test_build_graph_canvas.log --path . --script res://tests/test_build_graph_canvas.gd` (exit 0)
    - `TEST_JOBS=4 ./tools/test.sh` (run id `20260624-044658-56029`, exit 0)
  major files:
    - `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd`
    - `addons/hex_map_kit/generation/hex_generation_node_types.gd`
    - `tests/test_generation_graph.gd`
    - `tests/test_build_graph_canvas.gd`

### REPAIR-18_MARKOV_DISTRIBUTION_WINDOW

proof:
  findings: `docs/development_log/2026-06-24_BUILD_NODE_DESIGN_GAPS_FINDINGS.md`
  execution:
    - `docs/review/autopilot/REPAIR-18_MARKOV_DISTRIBUTION_WINDOW_SELF_REVIEW_2026-06-24.md`
    - `docs/review/autopilot/REPAIR-18_MARKOV_DISTRIBUTION_WINDOW_TEST_RESULT_2026-06-24.md`
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/probe-logs/repair17_18_test_generation_graph.log --path . --script res://tests/test_generation_graph.gd` (exit 0)
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/probe-logs/repair17_18_test_build_graph_canvas.log --path . --script res://tests/test_build_graph_canvas.gd` (exit 0)
    - `TEST_JOBS=4 ./tools/test.sh` (run id `20260624-044658-56029`, exit 0)
  major files:
    - `addons/hex_map_kit/adapter/hex_wall_distribution_resource.gd`
    - `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd`
    - `addons/hex_map_kit/generation/hex_generation_node_types.gd`
    - `tests/test_generation_graph.gd`
    - `tests/test_build_graph_canvas.gd`

### REPAIR-15_OLD_GENERATE_STATE_MIGRATION_AUDIT

proof:
  plan: `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/REPAIR-15_MARKOV_ADJACENCY_MAPPING/`
  audit:
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/REPAIR-15_MARKOV_ADJACENCY_MAPPING/OLD_GENERATE_MIGRATION_AUDIT_MATRIX.md`
  major sources inspected:
    - `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
    - `addons/hex_map_kit/editor/hex_adjacency_rule_editor.gd`
    - `addons/hex_map_kit/core/hex_map_generator.gd`


### REPAIR-17-18_REDESIGN_SPEC_2026-06-24

proof:
  user_feedback_correction:
    - `docs/development_log/2026-06-24_REPAIR-17-18_REDESIGN_SPEC.md`
  decision:
    - REPAIR-17/18 first-pass implementation is insufficient and tasks are reopened as `BACKLOG-REDESIGN`.
    - REPAIR-18 preset arrays are verified intact in `addons/hex_map_kit/core/hex_randomizer.gd`; custom path is independent.


### REPAIR-17-18_REDESIGN_COMPLETION_2026-06-24

proof:
  corrected_spec:
    - `docs/development_log/2026-06-24_REPAIR-17-18_REDESIGN_SPEC.md`
  visual_capture:
    - `.godot_user/visual-verification/REPAIR-17-18/markov_distribution_window.png`
    - `.godot_user/visual-verification/REPAIR-17-18/adjacency_rules_window.png`
  capture_tool:
    - `tools/probe_rule_windows.gd`
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/probe-logs/redesign_graph2.log --path . --script res://tests/test_generation_graph.gd` (exit 0)
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --log-file .godot_user/probe-logs/redesign_test_build_graph_canvas.log --path . --script res://tests/test_build_graph_canvas.gd` (exit 0; see latest focused run)
    - `TEST_JOBS=4 ./tools/test.sh` (run id `20260624-082448-42976`, exit 0)
  result:
    - REPAIR-18 uses distribution_mode (`preset` vs `custom`), custom weights 0..8, 0/1/2/3 reference cases, and independent preset preservation.
    - REPAIR-17 uses multi-pattern hex panels with present=black/absent=white and component-size multiset core keys.


### OLD_GENERATE_EXECUTION_DEPENDENCY_DECISIONS_2026-07-02

proof:
  decision_record:
    - `docs/development_log/2026-07-02_OLD_GENERATE_EXECUTION_DEPENDENCY_MODEL_DECISIONS.md`
  user_decisions:
    - protected_floor: UI移行しない（drop、filter中間レイヤー合成で表現）。
    - toric: Connectivity側で管理（Shape param撤去、`toric_passage`へ移設）。
    - mask+crop / deductor floor: drop（明示記録）。
    - adjacency direction toggle: multiset のまま確定（closed）。
    - seed lab: park（QA park方針準拠）。source registry: typed Source nodesでsuperseded。
  matrix_update:
    - `docs/plan/2026-06-14_HEX_MAP_KIT_UI_PRODUCT_EXPERIENCE_AND_GENERATION_GRAPH_REDESIGN/REPAIR-15_MARKOV_ADJACENCY_MAPPING/OLD_GENERATE_MIGRATION_AUDIT_MATRIX.md`（2026-07-02 決定反映 section）


### REPAIR-19_ITEM_METHOD_FIELD_WIRING / REPAIR-20_CONNECTIVITY_TORIC_OWNERSHIP

proof:
  decision_record:
    - `docs/development_log/2026-07-02_OLD_GENERATE_EXECUTION_DEPENDENCY_MODEL_DECISIONS.md`
  tests:
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --script tests/test_generation_graph.gd` (exit 0; toric ownership契約 + limited正確数配置)
    - `/Applications/Godot.app/Contents/MacOS/Godot --headless --script tests/test_editor_generation.gd` (exit 0; method依存item行 + toric ownership inspector検証)
    - `./tools/test.sh` (run id `20260702-061528-6983`, exit 0)
  major files:
    - `addons/hex_map_kit/generation/hex_generation_node_types.gd`
    - `addons/hex_map_kit/editor/hex_map_build_node_inspector.gd`
    - `addons/hex_map_kit/generation/hex_generation_preset.gd`
    - `addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd`
    - `tests/test_generation_graph.gd`
    - `tests/test_editor_generation.gd`
  result:
    - limited pool 行は core が読む `limit` key を書き、graph 実行で正確数配置を確認。
    - adjacency は `item_name` を露出し pool editor を隠す。
    - Connectivity `toric_passage` が square cell 集合でのみ wrap topology を設定し、Shape は topology を所有しない。
