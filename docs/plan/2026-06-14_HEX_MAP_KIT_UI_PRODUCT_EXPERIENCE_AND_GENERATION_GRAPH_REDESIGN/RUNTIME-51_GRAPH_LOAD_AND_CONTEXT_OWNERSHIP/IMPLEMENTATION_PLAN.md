# RUNTIME-51 IMPLEMENTATION_PLAN（pre-execution）

## Scope
graph resource の editor 読込 + 文脈所有（新規 node 生成 / opt-in overwrite）。

## 変更対象ファイル（想定）
```
addons/hex_map_kit/editor/hex_map_build_screen.gd            # Load Graph 入口 + overwrite checkbox
addons/hex_map_kit/editor/hex_map_graph_instantiator.gd      # graph→新 HexTileMapLayer 具現化 / overwrite
addons/hex_map_kit/editor/hex_map_workspace_asset_resource_factory.gd  # 再利用/拡張
tests/test_graph_load_context.gd
```

## 復元フロー

### default（新規 HexTileMapLayer）
1. `Load Graph` で `HexGenerationGraphResource` を選ぶ。
2. 新 `HexTileMapLayer` node を編集中 scene に生成。
3. graph に **embed された semantics**（catalog/layer stack/document の snapshot）を **複製**して新 node の resource に割当（factory 再利用）。
4. graph も新 node に紐づけて復元。
5. 新 node を選択 → 既存の resource 追跡がそのまま適用。

### opt-in overwrite（既存 HexTileMapLayer）
- 条件: 選択中が `HexTileMapLayer` かつ checkbox `Overwrite selected` = on（**default off**）。
- semantics は **reference**（既存 resource を指す）/ merge。
- 層書込は **`generated` writable source のみ置換**、`document`/手動層は保持（`GRAPH-12` promote と同じ安全弁を再利用）。

## embed/reference の所在
- graph resource は `GRAPH-14` で semantics を **embed（snapshot）** 可能に持つ（runtime build と共用）。
- reference 経路は resource path を保持。

## Dependency / Test Matrix
| area | risk | proof |
|---|---|---|
| 新規生成 | node が出来ない/既存破壊 | Load(default) で新 HexTileMapLayer が増え、既存 node は不変 |
| embed 自己完結 | 復元に外部依存 | 新 node の semantics が複製で揃う（元 resource を参照しない） |
| overwrite 手動保持 | Paint 層消失 | 手動層を持つ既存 node に overwrite(on) → `generated` のみ置換、手動層残存 |
| 二重所有なし | 文脈が二重 | load 後も「選択 node = 文脈」一意 |
| 既定非破壊 | default で既存変更 | overwrite off では既存 node に書込なし |

## Planned steps
instantiator（新規 embed）→ overwrite path → Load 入口/checkbox → tests。

## Test path
`./tools/test.sh` ; `python3 tools/verify_task.py --task RUNTIME-51 --head <branch>`

## Planned completion criteria（二層 DoD）
- S: default=新規 node(embed) / opt-in overwrite(generated 層のみ) / 既存追跡再利用・独立 owner 無し。
- E: graph を開く→新 node に復元・編集できる / overwrite off 時 Paint 手編集保持。
- `./tools/test.sh` green。
