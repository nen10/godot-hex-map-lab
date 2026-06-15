# GRAPH-11 SUB_TASKS

Complexity class: **C4**（Build tab の UI architecture。GraphEdit + palette + inspector + preview + run wiring。複数 component。）

## Task Resolution

Build tab を **GraphEdit ベースの graph canvas** にする。`GRAPH-10` の Dictionary model（`hex_generation_graph.gd` 他）を canvas の backing store とし、GraphEdit 上の node/connection を model に同期する。node palette / selected-node inspector / output preview / run を組み、**Build を開いた最初が graph canvas** になる。

**縮めない方針**: linear pass stack / card board に逃げず、`GraphEdit`/`GraphNode` を採用（本命案）。ただし MVP は node 種別と port 種別を限定する。

## Locked decisions

| 論点 | 決定 |
|---|---|
| canvas 実装 | **Godot `GraphEdit` + `GraphNode`**（A 案。linear/board にしない） |
| backing store | `GRAPH-10` の Dictionary graph model（UI と model を同期） |
| 接続可否 | GraphEdit の connection request を **`GRAPH-10` の型検証**で許可/拒否 |
| port 可視化 | slot 色を port 型（terrain/selection/overlay）で分ける |
| preview | 既存 `hex_map_preview_thumbnail.gd` を再利用 |
| 配置 | DESIGN-10 Build wireframe（canvas 中央 dominant / preview 右 / inspector 下 / `[Generate]` 上） |

## Scope

含む: GraphEdit canvas、node palette（7 node type）、selected node inspector（params 編集）、output preview、`[Generate]`（run → preview 更新）、GraphEdit↔model 同期。
含まない: Promote→Document（`GRAPH-12`）/ dirty・cancel・N batch UI（`GRAPH-13`）/ graph resource 永続化（`GRAPH-14`）。

## Candidate Matrix

| 論点 | 候補 | 採用 | 理由 |
|---|---|---|---|
| canvas | A: GraphEdit / B: linear stack / C: card board | **A** | ノードグラフとして自然。製品の本体表現。 |
| model 同期 | A: GraphEdit を真実→model 生成 / B: model 真実→GraphEdit 再描画 | **A**（MVP）| 編集操作を GraphEdit が握り、run 時に model へ変換。 |
| inspector | A: 右/下の専用 panel に param schema を反映 / B: GraphNode 内に全 param | **A** | GraphNode は最小（型/名/port）、詳細は inspector。 |

## Scheduled Task Audit: なし。

## Sub-tasks
1. `HexMapBuildGraphCanvas`（GraphEdit 派生）: node 追加/接続/選択、connection 型検証。
2. node palette（7 type を追加できる）。
3. selected node inspector（`GRAPH-10` param schema を編集 UI 化）。
4. output preview（選択 node の run 結果を thumbnail 表示）。
5. `[Generate]` 配線（GraphEdit→model→runner.run→preview）。
6. Build screen 組み立て（DESIGN-10 wireframe 準拠）。
7. tests。

fallback/mirror: なし。
