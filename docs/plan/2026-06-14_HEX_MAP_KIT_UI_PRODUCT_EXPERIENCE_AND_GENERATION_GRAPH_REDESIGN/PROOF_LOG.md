# Completed Task Proof Log

Companion to `IMPLEMENTATION_QUEUE.md`（queue を executor context 用に lean に保つため分離）。完了時に `### <TASK-ID>` proof entry を追記する。

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
