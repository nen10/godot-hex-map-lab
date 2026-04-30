# ALGORITHM_ADAPTER.md

## 目的

Core の `HexMapData` を Godot 側で使いやすい形式へ変換する Adapter 層を説明する。

現時点の対象は `addons/hex_map_kit/adapter/hex_map_tile_adapter.gd`。

## TileMapLayer 用変換

`HexMapTileAdapter.to_tile_entries(data)` は、`HexMapData.cells` を stable な順序で走査し、各 cell を Dictionary に変換する。

各 entry は以下を持つ。

- `vector`: 元の `HexVector`
- `kind`: `"floor"` または `"wall"`
- `map_cell`: Godot の TileMapLayer で使う `Vector2i`
- `sort_z`: scene node 生成時の補助順序

`map_cell` は `HexPoint.from_cube(q, s, r).to_offset()` によって求める。これは現行 Core が移植している Unity 版の offset 変換と同じ理解を使う。

`apply_to_tile_map_layer(layer, data, ...)` は `to_tile_entries()` の結果を使い、floor/wall の source id と atlas coords を `TileMapLayer.set_cell()` に渡す薄い adapter である。

## Node2D 用変換

`HexMapTileAdapter.hex_to_local(vector, hex_size, flat_top)` は、Hex 座標からローカル座標 `Vector2` を返す。

flat-top の式:

```text
x = size * 3/2 * q
y = size * sqrt(3) * (r + q/2)
```

pointy-top の式:

```text
x = size * sqrt(3) * (q + r/2)
y = size * 3/2 * r
```
