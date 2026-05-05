@tool
class_name HexTileMapLayer
extends Node2D

const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexGrid = preload("res://addons/hex_map_kit/core/hex_grid.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")


@export var hex_map: HexMapResource:
	set(v):
		hex_map = v
		if v and is_node_ready():
			apply_map(v)

@export var hex_size: float = 24.0:
	set(v):
		hex_size = v
		if is_node_ready():
			_redraw()

@export var flat_top: bool = true:
	set(v):
		flat_top = v
		if is_node_ready():
			_redraw()

@export var floor_source_id: int = 0
@export var floor_atlas_coords: Vector2i = Vector2i.ZERO
@export var wall_source_id: int = 0
@export var wall_atlas_coords: Vector2i = Vector2i(1, 0)

var _tile_map: TileMapLayer
var _data = null
var _highlights: Dictionary = {}
var _display_path: Array = []
var _path_color := Color(0.12, 0.48, 0.88, 0.90)


func _ready() -> void:
	_ensure_tile_map_layer()
	if hex_map:
		apply_map(hex_map)
	elif _data != null:
		_redraw()


func _draw() -> void:
	if _tile_map == null:
		return

	for key in _highlights:
		var hex = _highlights[key]["hex"]
		var color: Color = _highlights[key]["color"]
		var local = hex_to_local(hex)
		var tile_center = _tile_map.position + local
		_draw_hex_highlight(tile_center, color)

	if _display_path.size() > 1:
		var points := PackedVector2Array()
		for hex in _display_path:
			points.append(_tile_map.position + hex_to_local(hex))
		draw_polyline(points, _path_color, 4.0, true)
		if points.size() > 0:
			draw_circle(points[0], 5.0, Color(0.12, 0.62, 0.42))
			draw_circle(points[points.size() - 1], 5.0, Color(0.88, 0.24, 0.24))


func _draw_hex_highlight(center: Vector2, color: Color) -> void:
	var points: PackedVector2Array = []
	var rotation = 0.0 if flat_top else 30.0
	for index in range(6):
		var angle = deg_to_rad(rotation + 60.0 * float(index))
		points.append(center + Vector2(cos(angle), sin(angle)) * hex_size)
	var outline = points
	outline.append(points[0])
	draw_polyline(outline, color, 2.5)


func apply_map(resource: HexMapResource) -> void:
	if resource == null:
		return
	_data = resource.to_map_data()
	_data = _normalize_data(_data)
	_highlights.clear()
	_display_path.clear()
	_redraw()


func local_to_hex(local_pos: Vector2) -> HexVector:
	var frac_q: float
	var frac_r: float
	var sqrt3 = sqrt(3.0)

	if flat_top:
		frac_q = (2.0 / 3.0 * local_pos.x) / hex_size
		frac_r = (-1.0 / 3.0 * local_pos.x + sqrt3 / 3.0 * local_pos.y) / hex_size
	else:
		frac_q = (sqrt3 / 3.0 * local_pos.x - 1.0 / 3.0 * local_pos.y) / hex_size
		frac_r = (2.0 / 3.0 * local_pos.y) / hex_size

	return _cube_round(frac_q, frac_r)


func hex_to_local(hex: HexVector) -> Vector2:
	return HexMapTileAdapter.hex_to_local(hex, hex_size, flat_top)


func is_wall(hex: HexVector) -> bool:
	if _data == null:
		return false
	return _data.wall_set().has(HexVector.apply_basis(hex.q, hex.s, hex.r).key())


func is_floor(hex: HexVector) -> bool:
	if _data == null:
		return false
	var key = HexVector.apply_basis(hex.q, hex.s, hex.r).key()
	return _data.cell_set().has(key) and not _data.wall_set().has(key)


func has_cell(hex: HexVector) -> bool:
	if _data == null:
		return false
	return _data.cell_set().has(HexVector.apply_basis(hex.q, hex.s, hex.r).key())


func get_cells() -> Array:
	if _data == null:
		return []
	return _data.cells.duplicate()


func get_floor_cells() -> Array:
	if _data == null:
		return []
	return _data.floor_cells()


func set_wall(hex: HexVector) -> void:
	if _data == null:
		return
	var key = HexVector.apply_basis(hex.q, hex.s, hex.r).key()
	if not _data.cell_set().has(key):
		return
	if _data.wall_set().has(key):
		return
	var wall = _data.cell_set()[key]
	var new_walls = _data.walls.duplicate()
	new_walls.append(wall)
	_data.set_walls(new_walls)
	_update_tile(hex)


func set_floor(hex: HexVector) -> void:
	if _data == null:
		return
	var key = HexVector.apply_basis(hex.q, hex.s, hex.r).key()
	if not _data.cell_set().has(key):
		return
	if not _data.wall_set().has(key):
		return
	var new_walls: Array = []
	for wall in _data.walls:
		if wall.key() != key:
			new_walls.append(wall)
	_data.set_walls(new_walls)
	_update_tile(hex)


func highlight_cell(hex: HexVector, color: Color) -> void:
	if _data == null or not has_cell(hex):
		return
	_highlights[hex.key()] = {"hex": hex, "color": color}
	queue_redraw()


func clear_highlights() -> void:
	_highlights.clear()
	queue_redraw()


func find_path(start: HexVector, goal: HexVector) -> Array:
	if _data == null:
		return []
	var start_normalized = HexVector.apply_basis(start.q, start.s, start.r)
	var goal_normalized = HexVector.apply_basis(goal.q, goal.s, goal.r)
	var floors = _data.floor_cells()
	return HexGrid.shortest_path(start_normalized, [goal_normalized], floors, _data.cyclic_size)


func draw_path(path: Array, color: Color = Color(0.12, 0.48, 0.88, 0.90)) -> void:
	_display_path = path
	_path_color = color
	queue_redraw()


func clear_path() -> void:
	_display_path.clear()
	queue_redraw()


func is_map_connected() -> bool:
	if _data == null:
		return true
	return HexMapGenerator.is_floor_connected(_data)


func connected_component(hex: HexVector) -> Array:
	if _data == null:
		return []
	var start = HexVector.apply_basis(hex.q, hex.s, hex.r)
	var floors = _data.floor_cells()
	return HexGrid.connected_area(start, floors, _data.cyclic_size)


func _cube_round(frac_q: float, frac_r: float) -> HexVector:
	var frac_s = -frac_q - frac_r
	var rq = roundi(frac_q)
	var rr = roundi(frac_r)
	var rs = roundi(frac_s)

	var q_diff = abs(rq - frac_q)
	var r_diff = abs(rr - frac_r)
	var s_diff = abs(rs - frac_s)

	if q_diff > r_diff and q_diff > s_diff:
		rq = -rr - rs
	elif r_diff > s_diff:
		rr = -rq - rs

	# frac_q/frac_r are display axial a/b; HexVector uses q=a+b, r=b.
	return HexVector.apply_basis(rq + rr, 0, rr)


func _redraw() -> void:
	if _tile_map == null or _data == null:
		return
	_tile_map.clear()
	for entry in HexMapTileAdapter.to_tile_entries(_data):
		if entry["kind"] == HexMapTileAdapter.KIND_WALL:
			_tile_map.set_cell(entry["map_cell"], wall_source_id, wall_atlas_coords)
		else:
			_tile_map.set_cell(entry["map_cell"], floor_source_id, floor_atlas_coords)
	queue_redraw()


func _update_tile(hex: HexVector) -> void:
	if _tile_map == null:
		return
	var normalized = HexVector.apply_basis(hex.q, hex.s, hex.r)
	var map_cell = HexMapTileAdapter.vector_to_map_cell(normalized)
	var key = normalized.key()
	if _data.wall_set().has(key):
		_tile_map.set_cell(map_cell, wall_source_id, wall_atlas_coords)
	else:
		_tile_map.set_cell(map_cell, floor_source_id, floor_atlas_coords)


func _ensure_tile_map_layer() -> void:
	for child in get_children():
		if child is TileMapLayer:
			_tile_map = child
			return
	_tile_map = TileMapLayer.new()
	_tile_map.name = "TileMapLayer"
	add_child(_tile_map, false, INTERNAL_MODE_BACK)


static func _normalize_data(data) -> HexMapData:
	var normalized_cells: Array = []
	for cell in data.cells:
		normalized_cells.append(HexVector.apply_basis(cell.q, cell.s, cell.r))
	var normalized_walls: Array = []
	for wall in data.walls:
		normalized_walls.append(HexVector.apply_basis(wall.q, wall.s, wall.r))
	return load("res://addons/hex_map_kit/core/hex_map_data.gd").from_cells(
		normalized_cells,
		normalized_walls,
		data.cyclic_size
	)
