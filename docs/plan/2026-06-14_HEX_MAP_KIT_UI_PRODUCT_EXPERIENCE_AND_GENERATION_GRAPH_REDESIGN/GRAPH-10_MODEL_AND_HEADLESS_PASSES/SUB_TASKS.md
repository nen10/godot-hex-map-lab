# GRAPH-10 SUB_TASKS

Complexity class: **C4**（製品本体の新規 subsystem。model + pass dispatch + Source + validation + runner + tests。複数実装フロー。UI なし・headless。）

## Task Resolution

製品の背骨である Generation Graph の **headless 基盤**を作る。Node/Port/Edge の Dictionary model、型検証、各 node type の headless pass（core static を再利用）、Source ノード、topo 実行 runner を実装し、**UI 前に「中間 output → 次 node」の連鎖が成立する**ことを test で証明する。

**生成 engine は新規に作らない**。core static（`hex_map_generator.gd` / `hex_map_data.gd` / `hex_overlay_data.gd`）を node の run から呼ぶ。

## Scope（このtaskに含む / 含まない）

含む:
- Graph/Node/Port/Edge の Dictionary model と structural validation。
- Port 型4種（terrain / selection / overlay / result）と互換判定。
- node types: `source` / `shape` / `wall_field` / `connectivity` / `region_filter` / `item_generator` / `compose` の headless run。
- topo 実行 + 中間 output cache の runner。
- `tests/test_generation_graph.gd`。

含まない（後続 task）:
- `promote`（Document 書き込み）→ `GRAPH-12`。
- editor canvas / inspector → `GRAPH-11`。
- dirty 伝播 / cancel UX → `GRAPH-13`。
- `HexGenerationGraphResource` 化 → `GRAPH-14`。

## Task Resolution Candidate Matrix

| 決定点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| データ表現 | A: Dictionary / B: Resource 即 / C: class 群 | **A** | `GENERATION_GRAPH_MODEL.md` G3。Resource 化は `GRAPH-14`。 |
| node dispatch | A: data-driven registry(Callable) / B: match 文 / C: class-per-node | **A** | 追加容易・data 駆動。registry に node type 定義を集約。 |
| run model | A: eager topo + cache / B: lazy + dirty | **A**（GRAPH-10）| dirty/cancel は `GRAPH-13`。まず通すことを証明。 |
| port 多型入力 | A: 入力が型集合を許容 / B: 単一型のみ | **A** | `region_filter` は terrain/overlay の両方を受ける。 |
| Source の入力源 | A: Resource ref + context 直渡しの両対応 / B: Resource のみ | **A** | headless test が Document なしで実行できる。 |

## Scheduled Task Audit

このtask完了時に queue へ追加する scheduled task: なし（後続 GRAPH-11..14 は既に queue 済み）。

## Sub-tasks

1. `hex_generation_ports.gd`: 港型定数 + `compatible(out_type, in_accepts) -> bool`。
2. `hex_generation_graph.gd`: `new_graph` / `add_node` / `add_edge` / structural `validate`（端点存在・型互換・DAG・必須入力）。
3. `hex_generation_node_types.gd`: node type registry（inputs/output/run）。各 run は core static を呼ぶ。
4. `hex_generation_graph_runner.gd`: validate → topo（Kahn）→ run → 中間 cache。
5. `tests/test_generation_graph.gd`: 2連鎖の成立、invalid edge / cycle / missing input の検出、決定性、空入力。

fallback / mirror 有無: なし（`POLICY.md` 参照）。
