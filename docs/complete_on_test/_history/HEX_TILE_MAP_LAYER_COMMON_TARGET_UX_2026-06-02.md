# HEX_TILE_MAP_LAYER_COMMON_TARGET_UX_2026-06-02.md

## 目的

生成 Dock と Hex Map Edit Dock で同じ `HexTileMapLayer` を target として扱い、`HexMapResource` を読み込んだ時点で Godot Editor viewport に map tile が表示される UX を作る。

## 背景

Godot の `TileMapLayer` は `Node2D` 派生で、tile 表示には `TileSet`、source id、atlas coords、alternative id が必要になる。Godot 公式 docs では、`TileMapLayer.set_cell()` は source id / atlas coords / alternative id の3要素で tile を識別し、無効値では cell が消えると説明されている。

EditorPlugin の 2D viewport input は `_handles()` の対象と `_forward_canvas_gui_input()` の戻り値で他 editor へ渡るかが決まる。plain `TileMapLayer` を Scene Tree で選択すると Godot 標準 TileMap editor の操作対象にもなるため、addon の manual edit UX と標準 atlas paint UX が混ざりやすい。

`HexTileMapLayer` は `Node2D` wrapper として内部 `TileMapLayer` を持つため、Scene Tree 上の選択対象を addon 専用 node にできる。この分離を正規 UX とする。

References:

- <https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html>
- <https://docs.godotengine.org/en/stable/classes/class_tileset.html>
- <https://docs.godotengine.org/en/stable/classes/class_editorplugin.html>
- <https://docs.godotengine.org/en/4.2/classes/class_node.html>

## Use Case

- Actor: Godot Editor で Hex Map Kit addon を使う制作者。
- Goal: 生成した primary map を scene 上の同じ `HexTileMapLayer` で表示し、その node を Hex Map Edit の target として編集する。
- Scenario: 生成 Dock で map を生成して `HexTileMapLayer` に反映し、保存した `HexMapResource` または Dock 上の import から手動編集へ進む。
- Success state: `HexTileMapLayer.hex_map` の読み込み、生成 Dock apply、manual edit redraw のいずれでも viewport に floor / wall tile が表示され、Hex Map Edit の Last Edit が document mutation と target redraw を報告する。

## Operation Steps

| # | Step | 評価 | 目標 |
| --- | --- | --- | --- |
| 1 | Scene に `HexTileMapLayer` を置く、または生成 Dock の Target から新規 target を追加する | 有用 / 追加 | 新規追加は `HexTileMapLayer` を作る。 |
| 2 | `HexMapResource` を `HexTileMapLayer.hex_map` に読み込む | 有用 / 追加 | TileSet 未設定でも sample atlas を使って floor / wall tile が表示される。 |
| 3 | 生成 Dock で `HexTileMapLayer` を Target に選ぶ | 有用 / 追加 | Target list に `HexTileMapLayer` が表示され、plain `TileMapLayer` と区別できる。 |
| 4 | Primary Generation を実行し、Target へ反映する | 有用 / 維持 | `HexTileMapLayer.hex_map` と内部表示 layer が更新される。 |
| 5 | Hex Map Edit Dock で同じ `HexTileMapLayer` を Target に選ぶ | 有用 / 維持 | target readiness に `HexTileMapLayer`、TileSet readiness、used cell count、loop state が出る。 |
| 6 | viewport 上の tile を click して wall / floor を編集する | 有用 / 維持 | canonical document と `HexTileMapLayer` 表示が同時に更新される。 |

## 既存 UX との干渉

### Plain TileMapLayer Target

plain `TileMapLayer` は互換 target として残す。既存 scene や overlay 表示では引き続き利用できる。ただし manual edit の代表 target にはしない。Godot 標準 TileMap editor の atlas paint と addon manual edit が競合する場合、`HexTileMapLayer` target へ移行する。

### Overlay Generation

Overlay data は複数 item key と tile mapping を持つため、現段階では plain `TileMapLayer` target を維持する。`HexTileMapLayer` 共通 target は primary `HexMapResource` 表示と manual edit を対象にする。

### Runtime Loop Display

`HexTileMapLayer` の toric / infinite loop display は target scene state として維持する。Manual edit Dock は hit 判定に `HexTileMapLayer.local_to_cell_hit()` を使い、loop display の schema を変更しない。

## UX 完了条件

- `HexTileMapLayer.hex_map` に resource を設定すると、TileSet 未設定でも viewport に tile が表示される。
- 生成 Dock の Target で `HexTileMapLayer` を選択できる。
- 生成 Dock の Primary Generation apply が `HexTileMapLayer.hex_map` と内部表示を更新する。
- Hex Map Edit Dock は同じ `HexTileMapLayer` を target として manual edit に使える。
- plain `TileMapLayer` は互換 fallback として残る。
