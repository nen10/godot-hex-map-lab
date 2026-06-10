# UI Layout Metric Test Process Roadmap 2026-06-10

目的: `docs/policy/UI_LAYOUT_METRIC_TEST_PROCESS_AND_ACCEPTANCE_POLICY_2026-06-10.md` を実装プロセスへ組み込み、Godot Editor Workspace UIを数値・状態・構造で評価できるようにする。

---

## Phase M0: Contract docs

### UI-METRIC-00_WORKSPACE_UI_CONTRACT

status: READY  
成果物: `docs/ui/WORKSPACE_UI_CONTRACT.md`

Acceptance:
- 各tabのPurpose / Required components / Forbidden visible text / Metric thresholdsがある。
- Resource row / button / debug report / sample mode の契約がある。

### UI-METRIC-01_WORKSPACE_STATE_MATRIX

status: BACKLOG  
dependencies: UI-METRIC-00

成果物: `docs/ui/WORKSPACE_STATE_MATRIX.md`

Acceptance:
- no selected node / selected node without resources / selected with resources / sample on/off / generate preview / validation errors等の状態がある。
- 各状態のExpected visible / Forbidden visibleが定義される。

---

## Phase M1: Static audit

### UI-METRIC-02_STATIC_UI_AUDIT

status: BACKLOG  
dependencies: UI-METRIC-00

成果物: `tools/ui_static_audit.py`

Acceptance:
- Button without pressed connection疑いを検出する。
- Details/Clear/Open/Select等の禁止button textを検出する。
- visible debug label patternを検出する。
- generic ResourcePicker patternを検出する。
- tab constructor without ScrollContainer疑いを検出する。

---

## Phase M2: Runtime layout snapshot

### UI-METRIC-03_LAYOUT_SNAPSHOT_COLLECTOR

status: BACKLOG  
dependencies: UI-METRIC-00, UI-METRIC-01

成果物:
- `addons/hex_map_kit/editor/testing/hex_ui_layout_snapshot_collector.gd`
- `addons/hex_map_kit/editor/testing/hex_ui_state_scenario_builder.gd`

Acceptance:
- Workspaceを複数scenario/sizeで構築できる。
- 各Controlのrect/minimum/text/base_type/tooltip/scroll parent/metadataをJSON化できる。
- まだFAIL gateにしない。report生成のみ。

### UI-METRIC-04_LAYOUT_METRIC_EVALUATOR_WARN_ONLY

status: BACKLOG  
dependencies: UI-METRIC-03

成果物:
- `addons/hex_map_kit/editor/testing/hex_ui_layout_metric_evaluator.gd`
- `tests/test_workspace_layout_metrics.gd`

Acceptance:
- text truncation / resource row / scroll / dead area / debug leakage / no-op / picker specificity / state contradiction のWARN reportを出す。
- WARNはまだtest failにしない。

---

## Phase M3: Acceptance gates

### UI-METRIC-05_P0_ACCEPTANCE_GATE

status: BACKLOG  
dependencies: UI-METRIC-04

Acceptance:
- visible no-op button
- no scroll when required
- state contradiction
- sample fallback in production
- debug leakage in normal UI
- required generic Resource picker

をP0 failにする。

### UI-METRIC-06_P1_ACCEPTANCE_GATE

status: BACKLOG  
dependencies: UI-METRIC-05

Acceptance:
- resource row compression
- normal width label truncation
- large dead area
- disabled action without tooltip
- summary-only tab marked editor complete

をP1 failにする。

---

## Phase M4: Integration

### UI-METRIC-07_TEST_SH_INTEGRATION

status: BACKLOG  
dependencies: UI-METRIC-05

Acceptance:
- `tools/test.sh` から P0 gate を実行する。
- P1 gateは最初は個別コマンドでもよい。
- `.godot_user/ui-metrics/<run-id>/` にJSON/MD reportを出す。

### UI-METRIC-08_AUTOPILOT_ACCEPTANCE_TEMPLATE_UPDATE

status: BACKLOG  
dependencies: UI-METRIC-05

Acceptance:
- UI task self-reviewがUI metric reportを参照する。
- UI taskの完了条件にP0 failures = 0が入る。
- docs/policy/TEST_DESIGN_POLICY.md と AGENTS.md へ要約を追加する。
