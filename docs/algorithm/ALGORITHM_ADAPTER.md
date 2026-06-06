# ALGORITHM_ADAPTER.md

## 目的

Core の `HexMapData` を Godot 側で使いやすい形式へ変換する Adapter 層を説明する。

現時点の対象は以下。

- `addons/hex_map_kit/adapter/hex_map_tile_adapter.gd`
- `addons/hex_map_kit/adapter/hex_map_resource.gd`
- `addons/hex_map_kit/adapter/hex_overlay_resource.gd`
- `addons/hex_map_kit/adapter/hex_overlay_tile_adapter.gd`
- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`

## TileMapLayer 用変換

`HexMapTileAdapter.to_tile_entries(data)` は、`HexMapData.cells` を stable な順序で走査し、各 cell を Dictionary に変換する。

各 entry は以下を持つ。

- `vector`: 元の `HexVector`
- `kind`: `"floor"` または `"wall"`
- `map_cell`: Godot の TileMapLayer で使う `Vector2i`
- `sort_z`: scene node 生成時の補助順序

`map_cell` は display axial 座標を Godot の TileMapLayer offset 座標へ変換して求める。display axial は以下。

```text
a = q - r
b = r - s
```

flat-top / Vertical Offset の場合:

```text
map_cell = Vector2i(a, b + floor(a / 2))
```

pointy-top / Horizontal Offset の場合:

```text
map_cell = Vector2i(a + floor(b / 2), b)
```

負座標を含む radius 2 Hexagon でも Godot の `TileMapLayer.map_to_local()` 上で六方向近傍が崩れないよう、offset 計算の 2 除算は truncate ではなく floor を使う。

`apply_to_tile_map_layer(layer, data, ...)` は `to_tile_entries()` の結果を使い、floor/wall の source id と atlas coords を `TileMapLayer.set_cell()` に渡す薄い adapter である。

`configure_hex_tile_set(tile_set, flat_top, tile_size)` は TileSet 側の Hex 表示設定をそろえる helper である。

- `tile_shape = TILE_SHAPE_HEXAGON`
- `tile_layout = TILE_LAYOUT_STACKED`
- `flat_top=true`: `tile_offset_axis = TILE_OFFSET_AXIS_VERTICAL`
- `flat_top=false`: `tile_offset_axis = TILE_OFFSET_AXIS_HORIZONTAL`
- `tile_size` が正の場合は `TileSet.tile_size` に反映

Editor Dock / `HexMapResource` が orientation の管理主体である。Apply 後に TileMapLayer Inspector 側だけで `tile_offset_axis` を手動変更する経路は管理対象外で、表示レイアウトは resource の orientation と `map_cell` 変換を同時に適用して保つ。

`configure_sample_tile_set(tile_set, flat_top, tile_size)` は addon 同梱の `addons/hex_map_kit/assets/sample_hex_tiles.png` を source id `0` の `TileSetAtlasSource` として設定する。sample atlas は `64 x 57` の tile region を横に 2 つ持ち、floor は atlas `Vector2i(0, 0)`、wall は atlas `Vector2i(1, 0)` である。

## Node2D 用変換

`HexMapTileAdapter.hex_to_local(vector, hex_size, flat_top)` は、Hex 座標からローカル座標 `Vector2` を返す。

Core の `HexVector` は Q/S/R の semimodule 表現を保持している。表示式に入れる前に、以下の display axial 座標へ変換する。

```text
a = q - r
b = r - s
```

これは `vector.axial()` の `(q - s, r - s)` とは異なる。`vector.axial()` をそのまま描画に使うと、S/-S 方向の近傍だけ中心からの距離が変わり、六方向の tile 並びが崩れる。

Unity 版 `HexPoint` の `Q = q - s`, `R = r - s` から見ると、表示用 axial は以下になる。

```text
a = Q - R
b = R
```

`HexPoint.coord()` 相当の offset 変換は `x = Q - (R + abs(R) % 2) / 2`, `y = R` で、`R` 偶奇によって cell 上の近傍 delta は変わる。この差は offset 座標の性質であり、offset から `Q/R` に戻して上記の表示用 axial に投影すると、中心点が偶数行/奇数行のどちらでも同じ六方向配置になる。

flat-top の式:

```text
x = size * 3/2 * a
y = size * sqrt(3) * (b + a/2)
```

pointy-top の式:

```text
x = size * sqrt(3) * (a + b/2)
y = size * 3/2 * b
```

`flat_top=true` は横方向の間隔が `size * 3/2`、縦方向の間隔が `size * sqrt(3)` になる。`flat_top=false` は横方向の間隔が `size * sqrt(3)`、縦方向の間隔が `size * 3/2` になる。どちらも同じ display axial 座標を使い、変わるのは最終的な画面上の投影式だけである。

視覚確認用 scene は `debug/hex_orientation_debug.tscn`、起動用 script は `tools/debug_hex_orientation.sh` に置いている。

toric square を六角形寄りに表示する場合は、描画前に `HexToricCoordinate.centered_vector(vector, cyclic_size)` で同じ toric cell の centered representative に変換する。この変換は `wrap_vector(centered, cyclic_size) == original` を満たすため、map data の cell identity は変えずに表示 domain だけを切り替える。

糊代つきの展開図として表示する場合は `HexToricCoordinate.unfolded_vectors(vector, cyclic_size)` を使う。戻り値は同一 toric cell の複数代表座標で、各要素は `wrap_vector(copy, cyclic_size) == original` を満たす。表示側は同一 cell を複数回描画できるが、map data は重複させない。

## Resource 用変換

`HexMapResource` は `Resource` 派生の保存用データである。

保持する値は以下。

- `cells: Array[Vector3i]`
- `walls: Array[Vector3i]`
- `cyclic_size: int`
- `orientation: int`

`orientation` は `ORIENTATION_FLAT_TOP = 0` または `ORIENTATION_POINTY_TOP = 1` である。既定値は flat-top。

`Vector3i` は `HexVector` の `(q, s, r)` 成分を保存する。読み戻し時は `HexVector.apply_basis(q, s, r)` を通すため、保存データが非正規化成分を含んでも Core 側では正規化される。

`HexMapResource.from_map_data(data, orientation)` は `HexMapData` と orientation から Resource を作る。

`resource.to_map_data()` は Resource から `HexMapData` を復元する。

`HexOverlayResource` は `HexOverlayData` の保存用 Resource である。Primary の floor/wall とは異なり、Overlay は user item key ごとに cell 集合を持つ。

保持する値は以下。

- `cells: Array[Vector3i]`
- `item_keys: PackedStringArray`
- `item_cells: Array`
- `cyclic_size: int`
- `orientation: int`

`HexOverlayResource.from_overlay_data(data, orientation)` は `HexOverlayData` と orientation から Resource を作る。`resource.to_overlay_data()` は Resource から `HexOverlayData` を復元する。

## Overlay TileMapLayer Adapter

`HexOverlayTileAdapter` は Overlay item key を TileMapLayer の tile 指定へ変換する。

入力は以下。

- `HexOverlayData`
- item tile mapping
  - item key
  - source id
  - atlas coords
  - alternative tile
- flat-top / pointy-top orientation
- optional item order

`to_tile_entries()` は item key ごとの cell を `HexMapTileAdapter.vector_to_map_cell()` と同じ座標変換で TileMapLayer cell に変換する。item tile mapping に存在しない item key は描画対象外である。

`apply_to_tile_map_layer(layer, data, item_tiles, clear_layer, flat_top, item_order)` は `TileMapLayer.set_cell()` に source id / atlas coords / alternative tile を渡す。`clear_layer=false` の場合、既存 cell を残して Overlay cell を追加する。

`TileMapLayer` は1 cellに複数 item を直接保持できない。複数 item の merge / replace / skip は `HexOverlayData.apply_overlay()` で data として表現し、描画時は item order に従って1 cellに表示する tile を決める。

## Runtime Layer

`HexTileMapLayer` は `Node2D` 派生の実行時 helper で、内部に子 `TileMapLayer` を持つ。`HexMapResource` を `apply_map(resource)` で読み込み、resource の orientation に従って `HexMapTileAdapter.to_tile_entries()` と同じ cell 変換で TileMapLayer へ反映する。

`hex_to_local(hex)` は `HexMapTileAdapter.hex_to_local(hex, hex_size, flat_top)` と同じ表示用 axial を使う。`local_to_hex(local_pos)` はその逆変換で、local 座標から表示用 axial `(a, b)` を求めたあと、`HexVector` の basis へ `q = a + b`, `r = b` として戻す。これにより flat-top / pointy-top のどちらでも `local_to_hex(hex_to_local(hex)) == hex` が成り立つ。

`set_wall(hex)` / `set_floor(hex)` は内部の `HexMapData.walls` を更新し、該当 cell だけ TileMapLayer に反映する。`find_path(start, goal)`、`is_map_connected()`、`connected_component(hex)` は内部 map data の floor cell と `cyclic_size` を使って Core の `HexGrid` / `HexMapGenerator` に委譲する。
