# ALGORITHM_ADAPTER.md

## 目的

Core の `HexMapData` を Godot 側で使いやすい形式へ変換する Adapter 層を説明する。

現時点の対象は以下。

- `addons/hex_map_kit/adapter/hex_map_tile_adapter.gd`
- `addons/hex_map_kit/adapter/hex_map_resource.gd`

## TileMapLayer 用変換

`HexMapTileAdapter.to_tile_entries(data)` は、`HexMapData.cells` を stable な順序で走査し、各 cell を Dictionary に変換する。

各 entry は以下を持つ。

- `vector`: 元の `HexVector`
- `kind`: `"floor"` または `"wall"`
- `map_cell`: Godot の TileMapLayer で使う `Vector2i`
- `sort_z`: scene node 生成時の補助順序

`map_cell` は `HexPoint.from_cube(q, s, r).to_offset()` によって求める。これは現行 Core が移植している Unity 版の offset 変換と同じ理解を使う。

Unity 版の対応箇所は `HexPoint.cs` の `coord()` / `relCoord()` である。`R` の偶奇により offset cell 上の近傍差分は変わるが、これは flat-top offset 座標の表現差であり、実座標上の六方向配置は変わらない。

`apply_to_tile_map_layer(layer, data, ...)` は `to_tile_entries()` の結果を使い、floor/wall の source id と atlas coords を `TileMapLayer.set_cell()` に渡す薄い adapter である。

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

## Resource 用変換

`HexMapResource` は `Resource` 派生の保存用データである。

保持する値は以下。

- `cells: Array[Vector3i]`
- `walls: Array[Vector3i]`
- `cyclic_size: int`

`Vector3i` は `HexVector` の `(q, s, r)` 成分を保存する。読み戻し時は `HexVector.apply_basis(q, s, r)` を通すため、保存データが非正規化成分を含んでも Core 側では正規化される。

`HexMapResource.from_map_data(data)` は `HexMapData` から Resource を作る。

`resource.to_map_data()` は Resource から `HexMapData` を復元する。
