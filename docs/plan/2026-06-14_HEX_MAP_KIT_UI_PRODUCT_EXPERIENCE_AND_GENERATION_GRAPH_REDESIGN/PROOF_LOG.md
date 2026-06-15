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

