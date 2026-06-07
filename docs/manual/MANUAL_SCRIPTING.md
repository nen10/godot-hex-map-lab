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
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexLayerStackResource = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd")
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

`radius` は `map_unit_radius` で、toric square の一辺は `2 * radius + 1` です。radius `1` / `2` も larger radius と同じ対称生成フローを通ります。

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

Weighted path と movement range は `HexGrid.weighted_path()` / `HexGrid.movement_range()`、または `HexTileMapLayer.find_weighted_path()` / `HexTileMapLayer.movement_range()` を使います。Canonical Level Document を runtime で読み込む最小例は `examples/basic_runtime/runtime_query_sample.gd` です。API の短い一覧は `docs/api/API_REFERENCE.md`、authoring から runtime までの流れは `docs/manual/MANUAL_WORKFLOW.md` を参照してください。

```gdscript
const HexRuntimeQuerySample = preload("res://examples/basic_runtime/runtime_query_sample.gd")
const HexMovementProfileResource = preload("res://addons/hex_map_kit/adapter/hex_movement_profile_resource.gd")

var profile = HexMovementProfileResource.new()
profile.wall_passable = true

var result = HexRuntimeQuerySample.query_document_path(
	"res://maps/level_document.tres",
	HexVector.zero(),
	HexVector.q_axis(),
	4.0,
	profile
)

print(result["path_count"])
print(result["range_count"])
```

## 6. Resource-backed authoring

Editor-authored levels should use `HexMapDocumentResource` and Resource references first. The document is the authoring container for terrain layers, overlay layers, object placements, label placements, zones, metadata, and dependencies.

```gdscript
const HexEditorWorkflowExample = preload("res://examples/editor_workflow/editor_workflow_example.gd")

var document: HexMapDocumentResource = HexEditorWorkflowExample.build_authoring_document()
ResourceSaver.save(document, "res://maps/level_document.tres")
```

Use catalog keys in document payloads and catalog resources instead of raw tile source numbers in gameplay-facing authoring code. Use `HexLayerStackResource` when the same document should apply to multiple role-specific layers:

```gdscript
var stack = HexLayerStackResource.standard_template()
$HexTileMapLayer.apply_document_to_layer_stack(document, stack)
```

For editor workflows, Resource pickers select documents, catalogs, TileSets, object databases, label databases, and PackedScenes. Path strings are useful for `load()` / `ResourceSaver.save()` calls, but they are not the normal authoring UI.

## 7. Godot 表示層との接続

### HexMapTileAdapter

`HexMapTileAdapter` は既存の `TileMapLayer` に `HexMapData` を一括表示する低レベル bridge です。簡単な debug 表示や既存 scene への接続には使えますが、editor-authored level では document、catalog key、layer stack を優先します。

```gdscript
HexMapTileAdapter.apply_to_tile_map_layer(
	$TileMapLayer,
	data,
	0,
	Vector2i.ZERO,
	0,
	Vector2i(1, 0),
	true,
	true
)
```

最後の `true` は `flat-top / Vertical Offset` を表します。`false` にすると `pointy-top / Horizontal Offset` 用の cell 座標を出力します。`vector_to_map_cell(vector, flat_top)` は TileMapLayer の cell 座標を返します。`hex_to_local(vector, hex_size, flat_top)` は Node2D 描画用の local 座標を返します。

TileSet を Hex 表示用に合わせる場合:

```gdscript
HexMapTileAdapter.configure_hex_tile_set(
	$TileMapLayer.tile_set,
	true,
	Vector2i(64, 64)
)
```

`flat_top=true` は `TileSet.TILE_OFFSET_AXIS_VERTICAL`、`flat_top=false` は `TileSet.TILE_OFFSET_AXIS_HORIZONTAL` を設定します。どちらも `TileSet.TILE_SHAPE_HEXAGON` と `TileSet.TILE_LAYOUT_STACKED` を使います。

### HexMapResource

Core の `HexMapData` だけを `.tres` に保存する場合は `HexMapResource` に変換します。terrain、overlay、objects、labels、metadata、dependencies を一緒に扱う level authoring では `HexMapDocumentResource` を使います。

```gdscript
var resource = HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_FLAT_TOP)
ResourceSaver.save(resource, "res://maps/level_01.tres")

var loaded = load("res://maps/level_01.tres")
var loaded_data = loaded.to_map_data()
```

保存形式は以下です。

- `cells: Array[Vector3i]`
- `walls: Array[Vector3i]`
- `cyclic_size: int`
- `orientation: int`

`orientation` は `ORIENTATION_FLAT_TOP` または `ORIENTATION_POINTY_TOP` です。Editor Dock と `HexTileMapLayer.apply_map()` はこの値を表示レイアウトの正として扱います。

### HexTileMapLayer

`HexTileMapLayer` は `Node2D` 派生の実行時用ノードです。子 `TileMapLayer` を内部で管理し、`HexMapResource` を適用できます。

```gdscript
@onready var layer: HexTileMapLayer = $HexTileMapLayer

func _ready() -> void:
	layer.apply_map(load("res://maps/level_01.tres"))
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
- `find_weighted_path(start, goal, movement_profile)`
- `movement_range(start, movement_budget, movement_profile)`
- `show_movement_range(start, movement_budget, movement_profile)`
- `draw_path(path, color)`, `clear_path()`
- `highlight_cell(hex, color)`, `clear_highlights()`
- `is_map_connected()`, `connected_component(hex)`

## 8. デバッグ

スクリプトから文字列で確認する場合:

```gdscript
print(HexMapDebug.render_summary(data))
print(HexMapDebug.render_ascii(data))
```

視覚確認用 scene は `docs/TEST.md` の Debug 実行を参照してください。
