# GRAPH-12 IMPLEMENTATION_PLAN（pre-execution）

## Scope
背骨 vertical slice：6-node chain を editor で通し、Promote で Document 層を作る。

## 変更対象ファイル（想定）
```
addons/hex_map_kit/generation/hex_generation_promote.gd   # output+role+writable_source → Document 書込
addons/hex_map_kit/editor/hex_map_build_node_inspector.gd # [Promote output to Layer] 活性化（GRAPH-11 で placeholder）
addons/hex_map_kit/editor/hex_map_build_screen.gd         # promote 配線・status
tests/test_generation_promote.gd
tests/test_build_graph_canvas.gd  # chain 通しを追加
```
（Document 書込は既存 `addons/hex_map_kit/adapter/hex_map_document_adapter.gd` を使用。）

## Promote 仕様（核心）

`promote(node_output, document, role, writable_source="generated") -> {written_role, cell_count}`
- 入力 `node_output` は `HexMapData`(terrain) または `HexOverlayData`(overlay)。
- role→Document 書込:
  | role | 入力型 | 書込先（adapter 経由） |
  |---|---|---|
  | terrain | HexMapData | map cells/walls |
  | overlay | HexOverlayData | tile_overrides（kind=overlay） |
  | object | HexOverlayData | objects |
- **`generated` 層のみ置換**: 同 role の既存 `generated` payload を消してから書く。`document`/手動 payload は触らない（Layer Stack の writable source を参照、無ければ「generated 由来」を payload metadata で識別）。
- 戻り値で status 表示（「overlay 層へ N cells を promote」）。

## chain 結線（editor）

- `GRAPH-11` canvas で 6 node を組める。`region_filter.out(selection)` → `item_generator.scope(selection)` の接続が型 OK（GRAPH-10）。
- `[Generate]` → `runner.run` → 各 node output cache。
- 選択 node の inspector `[Promote output to Layer]` → role 選択 dialog → `promote(output, document, role)`。

## Dependency / Test Matrix
| area | risk | proof |
|---|---|---|
| chain 通し | 中間 feed 不成立 | `Shape→Wall→Connectivity→region_filter(floor)→item_generator(weighted)` を組み run、item は selection 上のみ |
| promote 実在 | Document 層が出来ない | promote(overlay role) 後、document.tile_overrides に kind=overlay の cell が N 個 |
| 手動層保持 | Paint 層が消える | document に手動(overlay,document source) cell を置き、promote 後もそれが残る |
| generated 置換 | 再 promote で重複 | 同 role を2回 promote → generated cell は重複せず置換 |
| 保存 | 保存不可 | promote 後 document を `.tres` save/load して内容一致 |

## Planned steps
promote.gd → inspector 活性化 → build_screen 配線 → tests。

## Test path
`./tools/test.sh` ; `python3 tools/verify_task.py --task GRAPH-12 --head <branch>`

## Planned completion criteria（二層 DoD）
- S: 中間 selection→次 node 接続 / promote 後 Document 層実在 / 手動層保持 test。
- E: ユーザーが「floor∩距離≤3」→weighted item→中間 preview→Promote→Document に使える層。**動くまで COMPLETE 不可**。
- `./tools/test.sh` green。
