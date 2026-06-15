# GRAPH-11 IMPLEMENTATION_PLAN（pre-execution）

## Scope
Build tab を GraphEdit graph canvas にする（palette/inspector/preview/run）。Promote・dirty・persistence は scope 外。

## 変更対象ファイル（新規・想定）
```
addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd   # GraphEdit 派生
addons/hex_map_kit/editor/hex_map_build_node_palette.gd   # node 追加 UI
addons/hex_map_kit/editor/hex_map_build_node_inspector.gd # 選択 node の param 編集
addons/hex_map_kit/editor/hex_map_build_screen.gd         # Build tab 組み立て（DESIGN-10 wireframe）
tests/test_build_graph_canvas.gd
```
（既存 `hex_map_preview_thumbnail.gd` を preview に再利用。Build を tab registry の `Generate` 枠へ接続。改名 `Generate→Build` は DESIGN-11 範囲だが、canvas 接続箇所は本 task で触れる。）

## GraphEdit ↔ model 同期（核心）

- 各 GraphNode は `GRAPH-10` の Node に1:1対応（`node_id` を GraphNode name に持つ）。
- GraphNode の slot（入力左 / 出力右）は node type registry の inputs/output から生成。
- **connection_request**: `from_node/from_port → to_node/to_port` を `GRAPH-10` の型互換で判定。OK なら `connect_node` + model に edge 追加、NG なら拒否（理由を status に）。
- **run 時**: GraphEdit の node 群 + connections から `GRAPH-10` の Graph(Dictionary) を構築 → `validate` → `runner.run`。

## node type → GraphNode 表示

| node type | 入力 slot | 出力 slot(色) | GraphNode title |
|---|---|---|---|
| source | （なし） | terrain/overlay | "Source" |
| shape | （なし） | terrain | "Shape" |
| wall_field | in:terrain | terrain | "Wall Field" |
| connectivity | in:terrain | terrain | "Connectivity" |
| region_filter | in:terrain｜overlay | selection | "Region Filter" |
| item_generator | scope:selection | overlay | "Item Generator" |
| compose | base,add:overlay | overlay | "Compose" |

port 色: terrain / selection / overlay を別色（凡例を canvas 隅に）。

## inspector（選択 node の param 編集）

`GRAPH-10` の param schema を UI 化:
- shape: shape option + width/height/size/radius/toric
- wall_field: wall_probability(slider) + seed
- connectivity: method option + direction_seed
- region_filter: mode option(floor/wall/query) + selectors
- item_generator: mode + placement_probability + item_pool(編集) + seed
- source: kind option + Resource picker（resource_refs）

## preview

- 選択 node の run 出力（terrain→`HexMapData` / overlay→`HexOverlayData`）を `HexMapPreviewThumbnail.preview_from_map_data` / `preview_from_overlay_data` で表示。
- 出力なし/未 run は `unavailable_preview`。

## Build screen レイアウト（DESIGN-10 準拠）

- 上: context chips（Map/Catalog/Target）+ `[Generate]`
- 中央 dominant: GraphEdit canvas（+ palette）
- 右: output preview
- 下: selected node inspector（+ `[Promote output to Layer]` は GRAPH-12 で活性化、ここでは disabled placeholder 可）

## Dependency / Test Matrix

| area | risk | proof（`tests/test_build_graph_canvas.gd`）|
|---|---|---|
| canvas first | 先頭が canvas でない | Build screen の dominant child が GraphEdit |
| 型接続 | 不正接続を通す | selection→terrain 入力など型違いを connection_request が拒否 |
| model 同期 | GraphEdit→model 変換ミス | 3 node + 2 接続を組み、構築 model が `validate` ok |
| run+preview | preview 出ない | `Shape→Wall→Connectivity` を canvas で組み Generate→選択 node の preview available |
| palette | node 追加不可 | 各 type を palette から追加できる |

## Planned steps
canvas → palette → inspector → preview → screen 組立 → tests。

## Test path
`./tools/test.sh` ; `python3 tools/verify_task.py --task GRAPH-11 --head <branch>`

## Planned completion criteria（二層 DoD）
- S: GraphEdit canvas / 型検証接続 / inspector が param schema 反映 / model 同期 test。
- E: Build を開いた最初が graph canvas、3 node を置いて繋ぎ、Generate で選択 node の中間 output を preview できる。
- `./tools/test.sh` green。
