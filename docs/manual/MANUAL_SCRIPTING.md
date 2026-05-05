# Scripting Manual

Hex Map Kit の Core API は、Hex 座標上のセル集合を作り、壁集合を生成し、連結性や経路を検証して、Godot の表示層へ渡すための薄い部品群です。

```gdscript
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexPoint = preload("res://addons/hex_map_kit/core/hex_point.gd")
const HexGrid = preload("res://addons/hex_map_kit/core/hex_grid.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexMapDebug = preload("res://addons/hex_map_kit/core/hex_map_debug.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")
```

## 1. 座標データ

### HexVector

`HexVector` は Core の基本座標です。`q/s/r` の 3 成分を持ちますが、`HexVector.apply_basis(q, s, r)` が同じ地点を一意な代表値へ正規化します。

```gdscript
var origin = HexVector.zero()
var q = HexVector.q_axis()
var r = HexVector.r_axis()
var s = HexVector.s_axis()

var neighbor = origin.add(q)
var delta = neighbor.subtract(origin)
var far = q.scaled(3)

print(neighbor.key())          # "1,0,0"
print(neighbor.debug_string()) # "(Q:1, S:0, R:0)"
```

`HexVector` は位置にも移動量にも使います。API 上は `add()` できますが、位置として扱っている値同士を足すのではなく、片方を移動量として扱うのが読みやすい使い方です。

```gdscript
var position = HexVector.zero()
var offset = HexVector.q_axis().add(HexVector.r_axis())
var moved = position.add(offset)
```

距離は `l1_norm()` / `l_infinity_norm()` / `l2_norm()` を使います。2 点間の差分は `target.subtract(start)` で求めます。

### HexPoint

`HexPoint` は offset 座標との変換に使う補助クラスです。TileMapLayer の cell 座標へ変換する場合は、通常 `HexMapTileAdapter.vector_to_map_cell()` を使うため、直接触る場面は少なめです。

```gdscript
var point = HexPoint.from_offset(2, 1)
var offset = point.to_offset()
var moved_point = point.add_vector(HexVector.q_axis())
var movement = point.vector_to(moved_point)
```

## 2. List と Set

範囲や経路は `Array[HexVector]` として返ります。演算や順序が必要な場合は Array を使います。

```gdscript
var ring = HexGrid.l1_ring(2)
var disc = HexGrid.l1_disc(2)
var neighbors = HexGrid.neighbors(HexVector.zero())
var toric_neighbors = HexGrid.neighbors(HexVector.zero(), 7)
```

membership 判定には `HexMapData.make_set(points)` が返す Dictionary を使います。これは `{ point.key(): point }` の辞書で、主用途は重複除去と高速な存在確認です。

```gdscript
var cells = HexGrid.l1_disc(2)
var cell_set = HexMapData.make_set(cells)
if cell_set.has(HexVector.zero().key()):
	print("origin exists")
```

集合操作が必要な場合は、`HexMapData.unique_points()`、`HexMapData.filter_points()`、`HexMapData.points_except()` を使います。Dictionary を直接加工するより、Array を入力して Array を返す helper に寄せると、後続の生成処理へ渡しやすくなります。

## 3. マップデータ

`HexMapData` は、存在するセルと壁セルだけを持ちます。floor は保存せず、`cells - walls` として計算します。

```gdscript
var data = HexMapData.rectangle(8, 6)
var hex = HexMapData.hexagon(3)
var toric = HexMapData.square(7, true)

print(data.cells.size())
print(data.walls.size())
print(data.floor_cells().size())
print(data.cyclic_size) # 0なら non-toric、正なら toric の一辺サイズ
```

任意のセル集合から作る場合:

```gdscript
var cells = HexGrid.l1_disc(2)
var walls = [HexVector.q_axis()]
var custom = HexMapData.from_cells(cells, walls, 0)
```

## 4. 壁集合の生成

単純生成は、各セルに対して `wall_probability` で独立に壁を置きます。`protected_floor` に含めたセルは壁になりません。

```gdscript
var data = HexMapGenerator.generate_rectangle(
	8,
	6,
	0.45,
	1201,
	true,
	false,
	[HexVector.zero()]
)
```

主な入口:

- `generate_rectangle(width, height, wall_probability, seed, ensure_connected, toric, protected_floor)`
- `generate_hexagon(radius, wall_probability, seed, ensure_connected, protected_floor)`
- `generate_toric_square(size, wall_probability, seed, ensure_connected, protected_floor)`

対称生成は、外周から中心へ進む Markov 風の生成順を使います。

```gdscript
var symmetric_torus = HexMapGenerator.generate_symmetric_square(
	3,
	0.45,
	1201,
	true,
	[HexVector.zero()],
	20,
	[],
	true
)
```

`radius` は `map_unit_radius` で、toric square の一辺は `2 * radius + 1` です。`radius == 1` は参照済みリングが存在しないため、distribution ではなく `wall_probability` による直接生成として扱います。

distribution は `HexRandomizer` の preset id、または `HexDistribution` resource で指定できます。値は 0.0 から 8.0 の重みで、確率は `value / 8.0` です。

## 5. 連結性と経路

連結性は floor cell 上で判定します。

```gdscript
if not HexMapGenerator.is_floor_connected(data):
	var removed_walls = HexMapGenerator.restore_connectivity(data)
```

terminal だけを先につなぐ場合:

```gdscript
var terminals = [HexVector.zero(), HexVector.q_axis().scaled(3)]
HexMapGenerator.restore_terminal_connectivity(data, terminals)
```

経路探索は `HexGrid.shortest_path()` を使います。探索可能なセル集合は `enterable_points` で明示します。

```gdscript
var floors = data.floor_cells()
var path = HexGrid.shortest_path(
	HexVector.zero(),
	[HexVector.q_axis().scaled(3)],
	floors,
	data.cyclic_size
)
```

toric map では `cyclic_size` を渡すことで、端を越える近傍が wrap されます。

## 6. Godot 表示層との接続

### HexMapTileAdapter

既存の `TileMapLayer` に一括適用する場合は adapter を使います。

```gdscript
HexMapTileAdapter.apply_to_tile_map_layer(
	$TileMapLayer,
	data,
	0,
	Vector2i.ZERO,
	0,
	Vector2i(1, 0)
)
```

`vector_to_map_cell()` は TileMapLayer の cell 座標を返します。`hex_to_local(vector, hex_size, flat_top)` は Node2D 描画用の local 座標を返します。`flat_top=false` にすると pointy-top 投影になります。

### HexMapResource

`.tres` に保存する場合は `HexMapResource` に変換します。

```gdscript
var resource = HexMapResource.from_map_data(data)
ResourceSaver.save(resource, "res://maps/level_01.tres")

var loaded = load("res://maps/level_01.tres")
var loaded_data = loaded.to_map_data()
```

保存形式は以下です。

- `cells: Array[Vector3i]`
- `walls: Array[Vector3i]`
- `cyclic_size: int`

### HexTileMapLayer

`HexTileMapLayer` は `Node2D` 派生の実行時用ノードです。子 `TileMapLayer` を内部で管理し、`HexMapResource` を適用できます。

```gdscript
@onready var layer: HexTileMapLayer = $HexTileMapLayer

func _ready() -> void:
	layer.apply_map(load("res://maps/level_01.tres"))
	layer.flat_top = true
	layer.hex_size = 24.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var hex = layer.local_to_hex(layer.to_local(event.position))
		if layer.is_floor(hex):
			layer.highlight_cell(hex, Color(1.0, 0.8, 0.1))
```

主な helper:

- `has_cell(hex)`, `is_wall(hex)`, `is_floor(hex)`
- `set_wall(hex)`, `set_floor(hex)`
- `get_cells()`, `get_floor_cells()`
- `find_path(start, goal)`
- `draw_path(path, color)`, `clear_path()`
- `highlight_cell(hex, color)`, `clear_highlights()`
- `is_map_connected()`, `connected_component(hex)`

## 7. デバッグ

スクリプトから文字列で確認する場合:

```gdscript
print(HexMapDebug.render_summary(data))
print(HexMapDebug.render_ascii(data))
```

視覚確認用 scene は `docs/TEST.md` の Debug 実行を参照してください。
