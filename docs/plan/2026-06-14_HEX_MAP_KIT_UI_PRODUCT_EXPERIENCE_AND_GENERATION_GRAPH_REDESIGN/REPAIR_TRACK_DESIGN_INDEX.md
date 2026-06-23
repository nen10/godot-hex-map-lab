# Build Repair Track Design Index

日付: 2026-06-23
状態: REPAIR-11 Codex handoff ready

## 目的

Build graph repair track の各 queue を、今後の相談開始点として使えるように整理する。

この index は実装完了証明ではない。各 repair queue の設計入口、判断済み事項、未決事項、依存関係を確認するための案内である。

## repair queue 一覧

| queue | status | 設計入口 | 主題 |
|---|---|---|---|
| `REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY` | `COMPLETE` | [REPAIR-10](./REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY/SUB_TASKS.md) | Generate 結果を viewport に出す hotfix、Apply/Revert、handoff matrix |
| `REPAIR-11_GRAPH_RESULT_MULTI_OVERLAY_CONTRACT` | `READY` | [REPAIR-11](./REPAIR-11_GRAPH_RESULT_MULTI_OVERLAY_CONTRACT/CODEX_HANDOFF.md) | `Result = 1 terrain + overlay_0..2` 契約 |
| `REPAIR-12_INTERMEDIATE_OUTPUT_CHILD_NODES` | `BACKLOG` | [REPAIR-12](./REPAIR-12_INTERMEDIATE_OUTPUT_CHILD_NODES/SUB_TASKS.md) | 中間出力を main layer に混ぜず、run-replaced child node として保持 |
| `REPAIR-13_GRAPH_WIDE_STATE_AND_FILTER_SPLIT` | `BACKLOG` | [REPAIR-13](./REPAIR-13_GRAPH_WIDE_STATE_AND_FILTER_SPLIT/SUB_TASKS.md) | graph-wide state、設定伝達監査、Terrain/Overlay Filter 分離 |
| `REPAIR-13A_BUILD_NODE_ADD_ROW_AND_SOURCE_TYPING` | `BACKLOG` | [REPAIR-13A](./REPAIR-13A_BUILD_NODE_ADD_ROW_AND_SOURCE_TYPING/SUB_TASKS.md) | node add row 下部配置、Source typing |
| `REPAIR-14_GRAPH_CANVAS_EDGE_DELETE` | `COMPLETE` | [REPAIR-14](./REPAIR-14_GRAPH_CANVAS_EDGE_DELETE/SUB_TASKS.md) | edge deletion interaction |
| `REPAIR-15_MARKOV_ADJACENCY_MAPPING` | `BACKLOG` | [REPAIR-15](./REPAIR-15_MARKOV_ADJACENCY_MAPPING/SUB_TASKS.md) | Markov Mesh / adjacency と旧 Generate 意図の対応 |

## 相談時の読み順

1. viewport に出ない問題を扱うなら [REPAIR-10 HANDOFF_ISSUE_MATRIX](./REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY/HANDOFF_ISSUE_MATRIX.md)。
2. `Result`、複数 overlay、`Compose` の扱いを実装依頼するなら [REPAIR-11 Codex handoff](./REPAIR-11_GRAPH_RESULT_MULTI_OVERLAY_CONTRACT/CODEX_HANDOFF.md)。設計判断を見るなら [REPAIR-11 policy](./REPAIR-11_GRAPH_RESULT_MULTI_OVERLAY_CONTRACT/POLICY.md)。
3. 中間 preview / run cache / scene node ownership を相談するなら [REPAIR-12](./REPAIR-12_INTERMEDIATE_OUTPUT_CHILD_NODES/SUB_TASKS.md)。
4. node state、param 伝達、filter split を相談するなら [REPAIR-13](./REPAIR-13_GRAPH_WIDE_STATE_AND_FILTER_SPLIT/SUB_TASKS.md)。
5. node add row の並び、Source Terrain / Source Overlay の見せ方を相談するなら [REPAIR-13A](./REPAIR-13A_BUILD_NODE_ADD_ROW_AND_SOURCE_TYPING/SUB_TASKS.md)。
6. edge 削除操作を相談するなら [REPAIR-14](./REPAIR-14_GRAPH_CANVAS_EDGE_DELETE/SUB_TASKS.md)。
7. Markov / adjacency / 旧 Generate parity を相談するなら [REPAIR-15](./REPAIR-15_MARKOV_ADJACENCY_MAPPING/SUB_TASKS.md)。

## 共通判断

- サムネイルだけを viewport proof として扱わない。
- サンプルだけの成功を production proof として扱わない。
- `Result` は終端であり、`result` input を受け取らない。
- `REPAIR-11` の実装単位では dynamic overlay slot ではなく、`overlay_0`, `overlay_1`, `overlay_2` の固定 slot で multi-overlay contract を証明する。
- `Compose` は primary row から外し、初期設計では `Result` に final composition を寄せる。
- Source は UI 上で `Source Terrain` / `Source Overlay` に分ける方向を第一候補にする。
- Region Filter は曖昧なため、Terrain Filter / Overlay Filter へ分離する。

## まだ相談が必要な横断論点

| 論点 | 主担当 queue | 備考 |
|---|---|---|
| overlay 合成順序 | `REPAIR-11` | `overlay_0..2` numeric order は決定済み。dynamic slot / 並べ替え UI は将来相談。 |
| 中間出力の lifetime | `REPAIR-12` | run replacement、Apply/Revert との関係 |
| Derived Graph State の所有 class | `REPAIR-13` | canvas / runner / graph resource の責務分離 |
| Source node の内部 model | `REPAIR-13A` | typed Source か完全別 node type か |
| edge deletion の gesture | `REPAIR-14` | keyboard / toolbar / edge selection hit target |
| Markov / adjacency の node 分割 | `REPAIR-15` | Wall Field / Item Generator に残すか、専用 node に分けるか |
