@tool
class_name HexTileMapLayer
extends Node2D

const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexGrid = preload("res://addons/hex_map_kit/core/hex_grid.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexToricCoordinate = preload("res://addons/hex_map_kit/core/hex_toric_coordinate.gd")

signal cell_clicked(hex, event)
signal cell_hovered(hex)
signal cell_hit_clicked(hit: Dictionary, event)
signal cell_hit_hovered(hit: Dictionary)

const LOOP_DISPLAY_NONE := 0
const LOOP_DISPLAY_TORIC := 1
const LOOP_DISPLAY_INFINITE := 2
const BASE_TILE_MAP_NAME := "TileMapLayer"
const LOOP_TILE_MAP_NAME := "LoopTileMapLayer"
const OVERLAY_TILE_MAP_NAME := "OverlayTileMapLayer"
const OVERLAY_NAME := "OverlayLayer"


class OverlayCanvas:
	extends Node2D

	var layer: Node = null

	func _draw() -> void:
		if layer != null and is_instance_valid(layer) and layer.has_method("_draw_overlay"):
			layer._draw_overlay(self)


@export var hex_map: HexMapResource:
	set(v):
		hex_map = v
		if v and is_node_ready() and not _hex_map_setter_suppressed:
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
@export var floor_alternative_tile: int = 0
@export var wall_source_id: int = 0
@export var wall_atlas_coords: Vector2i = Vector2i(1, 0)
@export var wall_alternative_tile: int = 0
@export var input_enabled: bool = true
@export var emit_hovered_cell: bool = true
@export var loop_display_enabled: bool = false:
	set(v):
		loop_display_enabled = v
		if is_node_ready():
			refresh_loop_display()
			_queue_visual_redraw()
@export_enum("None", "Toric", "Infinite") var loop_display_mode: int = LOOP_DISPLAY_NONE:
	set(v):
		loop_display_mode = v
		if is_node_ready():
			refresh_loop_display()
			_queue_visual_redraw()
@export var loop_display_margin: int = 1:
	set(v):
		loop_display_margin = max(0, v)
		if is_node_ready():
			refresh_loop_display()
			_queue_visual_redraw()
@export var loop_display_rect: Rect2 = Rect2():
	set(v):
		loop_display_rect = v
		if is_node_ready():
			refresh_loop_display()
			_queue_visual_redraw()

var _tile_map: TileMapLayer
var _loop_tile_map: TileMapLayer
var _overlay_tile_map: TileMapLayer
var _overlay: OverlayCanvas
var _data = null
var _highlights: Dictionary = {}
var _display_path: Array = []
var _path_color := Color(0.12, 0.48, 0.88, 0.90)
var _hovered_hit_key := ""
var _hex_map_setter_suppressed := false
var _pending_document_payloads = null
var _tile_overrides_by_key: Dictionary = {}
var _overlay_tiles_by_key: Dictionary = {}
var _object_markers_by_key: Dictionary = {}
var _label_markers_by_key: Dictionary = {}


func _ready() -> void:
	_ensure_tile_map_layers()
	if hex_map:
		apply_map(hex_map)
	elif _data != null:
		_redraw()
	if _pending_document_payloads != null:
		_apply_document_payloads(_pending_document_payloads)
		_pending_document_payloads = null


func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		return
	if event is InputEventMouseMotion:
		_emit_hover_hit(local_to_cell_hit(to_local(event.position)))
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_emit_click_hit(local_to_cell_hit(to_local(mouse_event.position)), event)


func _draw() -> void:
	if _overlay != null:
		return
	_draw_overlay(self)


func _draw_overlay(canvas: Node2D) -> void:
	if _tile_map == null:
		return

	_draw_loop_cell_outlines(canvas)

	for key in _highlights:
		var hex = _highlights[key]["hex"]
		var color: Color = _highlights[key]["color"]
		for visual_hex in _visual_hexes_for_draw(hex):
			var tile_center = _display_center_for_hex(visual_hex)
			_draw_hex_highlight(canvas, tile_center, color)

	_draw_document_payload_markers(canvas)

	if _display_path.size() > 1:
		var points := PackedVector2Array()
		for hex in _display_path:
			points.append(_display_center_for_hex(hex))
		canvas.draw_polyline(points, _path_color, 4.0, true)
		if points.size() > 0:
			canvas.draw_circle(points[0], 5.0, Color(0.12, 0.62, 0.42))
			canvas.draw_circle(points[points.size() - 1], 5.0, Color(0.88, 0.24, 0.24))


func _draw_hex_highlight(canvas: Node2D, center: Vector2, color: Color) -> void:
	var points: PackedVector2Array = []
	var rotation = 0.0 if flat_top else 30.0
	for index in range(6):
		var angle = deg_to_rad(rotation + 60.0 * float(index))
		points.append(center + Vector2(cos(angle), sin(angle)) * hex_size)
	var outline = points
	outline.append(points[0])
	canvas.draw_polyline(outline, color, 2.5)


func apply_map(resource: HexMapResource) -> void:
	if resource == null:
		return
	flat_top = resource.is_flat_top()
	_sync_hex_size_for_current_display()
	_data = resource.to_map_data()
	_data = _normalize_data(_data)
	_clear_document_payload_display()
	_highlights.clear()
	_display_path.clear()
	_redraw()


func apply_document(document) -> void:
	if document == null or document.map == null:
		return
	var snapshot = HexMapDocumentAdapter.duplicate_document(document)
	var resource = HexMapDocumentAdapter.to_map_resource(snapshot)
	_hex_map_setter_suppressed = true
	hex_map = resource
	_hex_map_setter_suppressed = false
	if not is_node_ready():
		_pending_document_payloads = snapshot
		return
	apply_map(resource)
	_apply_document_payloads(snapshot)


func apply_document_cell(document, hex: HexVector) -> bool:
	if document == null or document.map == null:
		return false
	var snapshot = HexMapDocumentAdapter.duplicate_document(document)
	var resource = HexMapDocumentAdapter.to_map_resource(snapshot)
	flat_top = resource.is_flat_top()
	_sync_hex_size_for_current_display()
	_hex_map_setter_suppressed = true
	hex_map = resource
	_hex_map_setter_suppressed = false
	if not is_node_ready() or _tile_map == null:
		_pending_document_payloads = snapshot
		return true
	_data = _normalize_data(resource.to_map_data())
	var normalized = HexVector.apply_basis(hex.q, hex.s, hex.r)
	_refresh_document_payloads_for_cell(snapshot, normalized)
	_update_tile(normalized)
	_update_overlay_tile(normalized)
	return true


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


func local_to_cell_hit(local_pos: Vector2) -> Dictionary:
	return display_local_to_cell_hit(local_pos)


func display_local_to_cell_hit(local_pos: Vector2) -> Dictionary:
	var visual_local = local_pos
	if _tile_map != null:
		visual_local -= _tile_map.position
	var visual_hex: HexVector
	if _tile_map != null and _tile_map.tile_set != null:
		var map_cell = _tile_map.local_to_map(visual_local)
		visual_hex = HexMapTileAdapter.map_cell_to_vector(map_cell, flat_top)
	else:
		visual_hex = local_to_hex(visual_local)
	var canonical_hex = HexVector.apply_basis(visual_hex.q, visual_hex.s, visual_hex.r)
	if _uses_toric_loop_identity():
		canonical_hex = HexToricCoordinate.wrap_vector(visual_hex, int(_data.cyclic_size))
	return {
		"hex": canonical_hex,
		"visual_hex": visual_hex,
		"local": local_pos,
		"exists": has_cell(canonical_hex),
	}


func hex_to_local(hex: HexVector) -> Vector2:
	return HexMapTileAdapter.hex_to_local(hex, hex_size, flat_top)


func hex_to_display_local(hex: HexVector) -> Vector2:
	if _tile_map == null or _tile_map.tile_set == null:
		return hex_to_local(hex)
	return _tile_map.map_to_local(HexMapTileAdapter.vector_to_map_cell(hex, flat_top))


func display_tile_map_layer() -> TileMapLayer:
	_ensure_tile_map_layers()
	return _tile_map


func set_display_tile_set(tile_set: TileSet) -> void:
	_ensure_tile_map_layers()
	_tile_map.tile_set = tile_set
	_sync_hex_size_for_current_display()
	_sync_loop_tile_map()
	_sync_overlay_tile_map()
	if _data != null:
		_redraw()


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
	_queue_visual_redraw()


func remove_highlight(hex: HexVector) -> void:
	if _highlights.erase(hex.key()):
		_queue_visual_redraw()


func clear_highlights() -> void:
	_highlights.clear()
	_queue_visual_redraw()


func display_tile_set_present() -> bool:
	return _tile_map != null and _tile_map.tile_set != null


func display_tile_set() -> TileSet:
	_ensure_tile_map_layers()
	_configure_tile_map()
	return _tile_map.tile_set if _tile_map != null else null


func ensure_display_tiles(
	tile_size: Vector2i = HexMapTileAdapter.SAMPLE_TILE_SIZE,
	floor_source: int = 0,
	floor_atlas: Vector2i = Vector2i.ZERO,
	wall_source: int = 0,
	wall_atlas: Vector2i = Vector2i(1, 0)
) -> bool:
	_sync_hex_size_from_tile_size(tile_size)
	floor_source_id = floor_source
	floor_atlas_coords = floor_atlas
	wall_source_id = wall_source
	wall_atlas_coords = wall_atlas
	_ensure_tile_map_layers()
	if _tile_map.tile_set == null:
		_tile_map.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(_tile_map.tile_set, flat_top, tile_size)
	var ok = _ensure_display_tiles_available(tile_size)
	_sync_loop_tile_map()
	_sync_overlay_tile_map()
	if ok and _data != null:
		_redraw()
	return ok


func configure_atlas_display_tiles(
	atlas_path: String,
	source_id: int = 0,
	tile_size: Vector2i = HexMapTileAdapter.SAMPLE_TILE_SIZE,
	floor_atlas: Vector2i = Vector2i.ZERO,
	wall_atlas: Vector2i = Vector2i(1, 0)
) -> bool:
	return configure_display_tiles_from_texture(
		HexMapTileAdapter.load_tile_texture(atlas_path),
		source_id,
		source_id,
		tile_size,
		floor_atlas,
		wall_atlas
	)


func configure_display_tiles_from_texture(
	texture: Texture2D,
	floor_source: int = 0,
	wall_source: int = 0,
	tile_size: Vector2i = HexMapTileAdapter.SAMPLE_TILE_SIZE,
	floor_atlas: Vector2i = Vector2i.ZERO,
	wall_atlas: Vector2i = Vector2i(1, 0)
) -> bool:
	if texture == null:
		return false
	_sync_hex_size_from_tile_size(tile_size)
	floor_source_id = floor_source
	floor_atlas_coords = floor_atlas
	wall_source_id = wall_source
	wall_atlas_coords = wall_atlas
	_ensure_tile_map_layers()
	if _tile_map.tile_set == null:
		_tile_map.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(_tile_map.tile_set, flat_top, tile_size)
	var ok = _configure_display_tile_sources(texture, tile_size)
	_sync_loop_tile_map()
	_sync_overlay_tile_map()
	if ok and _data != null:
		_redraw()
	return ok


func display_used_cell_count() -> int:
	var count := 0
	if _tile_map != null:
		count += _tile_map.get_used_cells().size()
	if _loop_tile_map != null:
		count += _loop_tile_map.get_used_cells().size()
	if _overlay_tile_map != null:
		count += _overlay_tile_map.get_used_cells().size()
	return count


func display_atlas_coords_for_hex(hex: HexVector, visual_hex = null) -> Vector2i:
	var target_hex = visual_hex if visual_hex != null else hex
	if visual_hex != null and visual_hex.key() != hex.key() and _loop_tile_map != null:
		var visual_map_cell = HexMapTileAdapter.vector_to_map_cell(target_hex, flat_top)
		if _loop_tile_map.get_cell_source_id(visual_map_cell) >= 0:
			return _loop_tile_map.get_cell_atlas_coords(visual_map_cell)
	if _tile_map == null:
		return Vector2i(-1, -1)
	var canonical = HexVector.apply_basis(hex.q, hex.s, hex.r)
	var map_cell = HexMapTileAdapter.vector_to_map_cell(canonical, flat_top)
	return _tile_map.get_cell_atlas_coords(map_cell)


func display_source_id_for_hex(hex: HexVector, visual_hex = null) -> int:
	var target_hex = visual_hex if visual_hex != null else hex
	if visual_hex != null and visual_hex.key() != hex.key() and _loop_tile_map != null:
		var visual_map_cell = HexMapTileAdapter.vector_to_map_cell(target_hex, flat_top)
		var loop_source_id = _loop_tile_map.get_cell_source_id(visual_map_cell)
		if loop_source_id >= 0:
			return loop_source_id
	if _tile_map == null:
		return -1
	var canonical = HexVector.apply_basis(hex.q, hex.s, hex.r)
	var map_cell = HexMapTileAdapter.vector_to_map_cell(canonical, flat_top)
	return _tile_map.get_cell_source_id(map_cell)


func display_alternative_tile_for_hex(hex: HexVector, visual_hex = null) -> int:
	var target_hex = visual_hex if visual_hex != null else hex
	if visual_hex != null and visual_hex.key() != hex.key() and _loop_tile_map != null:
		var visual_map_cell = HexMapTileAdapter.vector_to_map_cell(target_hex, flat_top)
		if _loop_tile_map.get_cell_source_id(visual_map_cell) >= 0:
			return _loop_tile_map.get_cell_alternative_tile(visual_map_cell)
	if _tile_map == null:
		return -1
	var canonical = HexVector.apply_basis(hex.q, hex.s, hex.r)
	var map_cell = HexMapTileAdapter.vector_to_map_cell(canonical, flat_top)
	return _tile_map.get_cell_alternative_tile(map_cell)


func display_state_for_hex(hex: HexVector, visual_hex = null) -> Dictionary:
	var canonical = HexVector.apply_basis(hex.q, hex.s, hex.r)
	var object_count = _payload_marker_count(_object_markers_by_key, canonical.key())
	var label_count = _payload_marker_count(_label_markers_by_key, canonical.key())
	var overlay_state = _overlay_tile_state_for_hex(canonical, visual_hex)
	var state = {
		"renderer": "HexTileMapLayer",
		"source_id": display_source_id_for_hex(canonical, visual_hex),
		"atlas_coords": display_atlas_coords_for_hex(canonical, visual_hex),
		"alternative_tile": display_alternative_tile_for_hex(canonical, visual_hex),
		"overlay_source_id": int(overlay_state.get("source_id", -1)),
		"overlay_atlas_coords": overlay_state.get("atlas_coords", Vector2i(-1, -1)),
		"overlay_alternative_tile": int(overlay_state.get("alternative_tile", -1)),
		"overlay_count": int(overlay_state.get("count", 0)),
		"object_count": object_count,
		"label_count": label_count,
		"marker_count": object_count + label_count,
	}
	state["signature"] = "%s:%d:%s:%d:%d:%s:%d:%d:%d:%d" % [
		String(state["renderer"]),
		int(state["source_id"]),
		str(state["atlas_coords"]),
		int(state["alternative_tile"]),
		int(state["overlay_source_id"]),
		str(state["overlay_atlas_coords"]),
		int(state["overlay_alternative_tile"]),
		int(state["overlay_count"]),
		object_count,
		label_count,
	]
	return state


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
	_queue_visual_redraw()


func draw_loop_path(path: Array, color: Color = Color(0.12, 0.48, 0.88, 0.90)) -> void:
	_display_path = visual_path_for_canonical_path(path)
	_path_color = color
	_queue_visual_redraw()


func clear_path() -> void:
	_display_path.clear()
	_queue_visual_redraw()


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


func connected_component_from_local(local_pos: Vector2) -> Array:
	var hit = local_to_cell_hit(local_pos)
	if not bool(hit["exists"]):
		return []
	return connected_component(hit["hex"])


func highlight_connected_component(hex: HexVector, color: Color) -> void:
	for cell in connected_component(hex):
		highlight_cell(cell, color)


func visual_representatives_for_cell(hex: HexVector, rect: Rect2, margin: int = 1) -> Array:
	if not _uses_toric_visuals():
		return [HexVector.apply_basis(hex.q, hex.s, hex.r)]
	var canonical = HexToricCoordinate.wrap_vector(hex, int(_data.cyclic_size))
	var display_rect = rect
	if display_rect.size == Vector2.ZERO:
		display_rect = _effective_loop_display_rect()
	if display_rect.size == Vector2.ZERO:
		return [canonical]
	display_rect = display_rect.grow(float(max(0, margin)) * hex_size)
	var result: Array = []
	for visual_hex in _toric_period_candidates(canonical, display_rect):
		if display_rect.has_point(hex_to_display_local(visual_hex)):
			result.append(visual_hex)
	if result.is_empty():
		result.append(canonical)
	return result


func visual_cell_entries_for_rect(rect: Rect2, margin: int = 1) -> Array:
	if _data == null:
		return []
	var display_rect = rect
	if display_rect.size == Vector2.ZERO:
		display_rect = _effective_loop_display_rect()
	var result: Array = []
	for cell in _data.cells:
		var canonical = HexVector.apply_basis(cell.q, cell.s, cell.r)
		var representatives: Array
		if loop_display_enabled and _uses_toric_visuals():
			representatives = visual_representatives_for_cell(canonical, display_rect, margin)
		else:
			representatives = [canonical]
		for visual_hex in representatives:
			result.append({
				"hex": canonical,
				"visual_hex": visual_hex,
				"map_cell": HexMapTileAdapter.vector_to_map_cell(visual_hex, flat_top),
				"is_canonical": visual_hex.key() == canonical.key(),
			})
	return result


func refresh_loop_display() -> void:
	if _loop_tile_map == null:
		if not is_node_ready():
			return
		_ensure_tile_map_layers()
	_configure_tile_map()
	_loop_tile_map.clear()
	if not loop_display_enabled or not _uses_toric_visuals() or _data == null:
		return
	for entry in visual_cell_entries_for_rect(_effective_loop_display_rect(), loop_display_margin):
		if bool(entry["is_canonical"]):
			continue
		_set_tile_cell_for_hex(_loop_tile_map, entry["map_cell"], entry["hex"])


func visual_path_for_canonical_path(path: Array, anchor_local: Vector2 = Vector2.ZERO) -> Array:
	if path.is_empty():
		return []
	if not _uses_toric_visuals():
		var result: Array = []
		for point in path:
			result.append(HexVector.apply_basis(point.q, point.s, point.r))
		return result

	var visual_path: Array = []
	var first = path[0]
	var first_anchor = anchor_local
	if anchor_local == Vector2.ZERO:
		first_anchor = hex_to_display_local(first)
	var first_visual = _nearest_toric_period_candidate(first, first_anchor)
	visual_path.append(first_visual)
	var previous_local = hex_to_display_local(first_visual)
	for index in range(1, path.size()):
		var visual = _nearest_toric_period_candidate(path[index], previous_local)
		visual_path.append(visual)
		previous_local = hex_to_display_local(visual)
	return visual_path


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


func _emit_click_hit(hit: Dictionary, event: InputEvent) -> void:
	if not bool(hit["exists"]):
		return
	cell_clicked.emit(hit["hex"], event)
	cell_hit_clicked.emit(hit, event)


func _emit_hover_hit(hit: Dictionary) -> void:
	if not emit_hovered_cell:
		return
	var hover_key = ""
	if bool(hit["exists"]):
		hover_key = "%s|%s" % [hit["hex"].key(), hit["visual_hex"].key()]
	if hover_key == _hovered_hit_key:
		return
	_hovered_hit_key = hover_key
	if not bool(hit["exists"]):
		return
	cell_hovered.emit(hit["hex"])
	cell_hit_hovered.emit(hit)


func _uses_toric_loop_identity() -> bool:
	return loop_display_enabled \
		and loop_display_mode == LOOP_DISPLAY_TORIC \
		and _data != null \
		and int(_data.cyclic_size) > 0


func _uses_toric_visuals() -> bool:
	return loop_display_mode == LOOP_DISPLAY_TORIC \
		and _data != null \
		and int(_data.cyclic_size) > 0


func _visual_hexes_for_draw(hex: HexVector) -> Array:
	if loop_display_enabled:
		return visual_representatives_for_cell(hex, _effective_loop_display_rect(), loop_display_margin)
	return [hex]


func _draw_loop_cell_outlines(canvas: Node2D) -> void:
	if not loop_display_enabled or not _uses_toric_visuals() or _data == null:
		return
	var rect = _effective_loop_display_rect()
	var duplicate_color = Color(0.18, 0.44, 0.82, 0.26)
	for cell in _data.cells:
		for visual_hex in visual_representatives_for_cell(cell, rect, loop_display_margin):
			if visual_hex.key() == cell.key():
				continue
			_draw_hex_highlight(canvas, _display_center_for_hex(visual_hex), duplicate_color)


func _draw_document_payload_markers(canvas: Node2D) -> void:
	if _data == null:
		return
	var object_color := Color(0.10, 0.60, 0.82, 0.92)
	var label_color := Color(0.94, 0.74, 0.18, 0.92)
	for key in _object_markers_by_key:
		var bucket: Dictionary = _object_markers_by_key[key]
		var hex = bucket.get("hex", null)
		if hex == null:
			continue
		for visual_hex in _visual_hexes_for_draw(hex):
			var center = _display_center_for_hex(visual_hex)
			canvas.draw_circle(center + Vector2(0.0, -hex_size * 0.24), maxf(3.0, hex_size * 0.13), object_color)
	for key in _label_markers_by_key:
		var bucket: Dictionary = _label_markers_by_key[key]
		var hex = bucket.get("hex", null)
		if hex == null:
			continue
		for visual_hex in _visual_hexes_for_draw(hex):
			var center = _display_center_for_hex(visual_hex)
			var marker_size = Vector2(maxf(7.0, hex_size * 0.42), maxf(3.0, hex_size * 0.12))
			canvas.draw_rect(Rect2(center + Vector2(-marker_size.x * 0.5, hex_size * 0.18), marker_size), label_color)


func _effective_loop_display_rect() -> Rect2:
	if loop_display_rect.size != Vector2.ZERO:
		return loop_display_rect
	if _data == null or _data.cells.is_empty():
		return Rect2()
	var first = hex_to_display_local(_data.cells[0])
	var min_position = first
	var max_position = first
	for cell in _data.cells:
		var local = hex_to_display_local(cell)
		min_position.x = minf(min_position.x, local.x)
		min_position.y = minf(min_position.y, local.y)
		max_position.x = maxf(max_position.x, local.x)
		max_position.y = maxf(max_position.y, local.y)
	return Rect2(min_position, max_position - min_position).grow(hex_size * 2.0)


func _nearest_toric_period_candidate(hex: HexVector, target_local: Vector2) -> HexVector:
	var result = HexToricCoordinate.wrap_vector(hex, int(_data.cyclic_size))
	var result_distance = INF
	for candidate in _toric_period_candidates(result):
		var distance = hex_to_display_local(candidate).distance_to(target_local)
		if distance < result_distance:
			result = candidate
			result_distance = distance
	return result


func _toric_period_candidates(hex: HexVector, rect: Rect2 = Rect2()) -> Array:
	var result: Array = []
	if _data == null or int(_data.cyclic_size) <= 0:
		return [HexVector.apply_basis(hex.q, hex.s, hex.r)]
	var seen := {}
	var canonical = HexToricCoordinate.wrap_vector(hex, int(_data.cyclic_size))
	var size = int(_data.cyclic_size)
	var offset_limit = 1
	if rect.size != Vector2.ZERO:
		var period_local_q = hex_to_display_local(HexVector.apply_basis(size, 0, 0)).length()
		var period_local_r = hex_to_display_local(HexVector.apply_basis(0, 0, size)).length()
		var period = maxf(1.0, minf(period_local_q, period_local_r))
		var rect_extent = maxf(
			maxf(absf(rect.position.x), absf(rect.position.y)),
			maxf(absf(rect.end.x), absf(rect.end.y))
		)
		offset_limit = max(1, int(ceil((rect_extent + rect.size.length()) / period)) + 1)
	for r_offset in range(-offset_limit, offset_limit + 1):
		for q_offset in range(-offset_limit, offset_limit + 1):
			var candidate = canonical.add(HexVector.apply_basis(q_offset * size, 0, r_offset * size))
			if seen.has(candidate.key()):
				continue
			seen[candidate.key()] = true
			result.append(candidate)
	return result


func _redraw() -> void:
	if _tile_map == null or _data == null:
		return
	_configure_tile_map()
	_tile_map.clear()
	if _overlay_tile_map != null:
		_overlay_tile_map.clear()
	for entry in HexMapTileAdapter.to_tile_entries(_data, true, true, flat_top):
		_set_tile_cell_for_hex(_tile_map, entry["map_cell"], entry["vector"])
	_redraw_overlay_tile_map()
	refresh_loop_display()
	_queue_visual_redraw()


func _update_tile(hex: HexVector) -> void:
	if _tile_map == null:
		return
	var normalized = HexVector.apply_basis(hex.q, hex.s, hex.r)
	var map_cell = HexMapTileAdapter.vector_to_map_cell(normalized, flat_top)
	if _data == null or not _data.cell_set().has(normalized.key()):
		_tile_map.erase_cell(map_cell)
	else:
		_set_tile_cell_for_hex(_tile_map, map_cell, normalized)
	refresh_loop_display()
	_queue_visual_redraw()


func _set_tile_cell_for_hex(tile_map: TileMapLayer, map_cell: Vector2i, hex: HexVector) -> void:
	if tile_map == null or _data == null:
		return
	var normalized = HexVector.apply_basis(hex.q, hex.s, hex.r)
	var key = normalized.key()
	var is_wall_cell = _data.wall_set().has(key)
	var override = _tile_override_for_hex(normalized, is_wall_cell)
	if not override.is_empty():
		tile_map.set_cell(
			map_cell,
			int(override.get("source_id", 0)),
			override.get("atlas_coords", Vector2i.ZERO),
			int(override.get("alternative_tile", 0))
		)
	elif is_wall_cell:
		tile_map.set_cell(map_cell, wall_source_id, wall_atlas_coords, wall_alternative_tile)
	else:
		tile_map.set_cell(map_cell, floor_source_id, floor_atlas_coords, floor_alternative_tile)


func _clear_document_payload_display() -> void:
	_tile_overrides_by_key.clear()
	_overlay_tiles_by_key.clear()
	_object_markers_by_key.clear()
	_label_markers_by_key.clear()


func _apply_document_payloads(document) -> void:
	_clear_document_payload_display()
	if document == null or document.map == null or _data == null:
		_redraw()
		return
	var cell_set = _data.cell_set()
	var wall_set = _data.wall_set()
	for raw_entry in document.tile_overrides:
		if not raw_entry is Dictionary:
			continue
		var entry: Dictionary = (raw_entry as Dictionary).duplicate(true)
		var hex = _hex_from_entry_cell(entry)
		var key = hex.key()
		if not cell_set.has(key):
			continue
		var entry_kind = String(entry.get("kind", HexMapDocumentAdapter.KIND_FLOOR))
		if entry_kind == HexMapDocumentAdapter.KIND_OVERLAY:
			_append_overlay_tile_entry(hex, entry)
			continue
		var is_wall_cell = wall_set.has(key)
		if entry_kind == HexMapDocumentAdapter.KIND_FLOOR and is_wall_cell:
			continue
		if entry_kind == HexMapDocumentAdapter.KIND_WALL and not is_wall_cell:
			continue
		_tile_overrides_by_key[_tile_override_key(key, entry_kind)] = entry
	for raw_entry in document.objects:
		if raw_entry is Dictionary:
			_store_payload_marker(_object_markers_by_key, raw_entry as Dictionary, cell_set)
	for raw_entry in document.labels:
		if raw_entry is Dictionary:
			_store_payload_marker(_label_markers_by_key, raw_entry as Dictionary, cell_set)
	_redraw()


func _refresh_document_payloads_for_cell(document, hex: HexVector) -> void:
	var normalized = HexVector.apply_basis(hex.q, hex.s, hex.r)
	var key = normalized.key()
	_tile_overrides_by_key.erase(_tile_override_key(key, HexMapDocumentAdapter.KIND_FLOOR))
	_tile_overrides_by_key.erase(_tile_override_key(key, HexMapDocumentAdapter.KIND_WALL))
	_overlay_tiles_by_key.erase(key)
	_object_markers_by_key.erase(key)
	_label_markers_by_key.erase(key)
	if document == null or document.map == null or _data == null:
		return
	var cell_set = _data.cell_set()
	if not cell_set.has(key):
		return
	var wall_set = _data.wall_set()
	for raw_entry in document.tile_overrides:
		if not raw_entry is Dictionary:
			continue
		var entry: Dictionary = (raw_entry as Dictionary).duplicate(true)
		var entry_hex = _hex_from_entry_cell(entry)
		if entry_hex.key() != key:
			continue
		var entry_kind = String(entry.get("kind", HexMapDocumentAdapter.KIND_FLOOR))
		if entry_kind == HexMapDocumentAdapter.KIND_OVERLAY:
			_append_overlay_tile_entry(normalized, entry)
			continue
		var is_wall_cell = wall_set.has(key)
		if entry_kind == HexMapDocumentAdapter.KIND_FLOOR and is_wall_cell:
			continue
		if entry_kind == HexMapDocumentAdapter.KIND_WALL and not is_wall_cell:
			continue
		_tile_overrides_by_key[_tile_override_key(key, entry_kind)] = entry
	for raw_entry in document.objects:
		if raw_entry is Dictionary and _entry_cell_key(raw_entry as Dictionary) == key:
			_store_payload_marker(_object_markers_by_key, raw_entry as Dictionary, cell_set)
	for raw_entry in document.labels:
		if raw_entry is Dictionary and _entry_cell_key(raw_entry as Dictionary) == key:
			_store_payload_marker(_label_markers_by_key, raw_entry as Dictionary, cell_set)


func _store_payload_marker(store: Dictionary, entry: Dictionary, cell_set: Dictionary) -> void:
	var hex = _hex_from_entry_cell(entry)
	var key = hex.key()
	if not cell_set.has(key):
		return
	if not store.has(key):
		store[key] = {
			"hex": hex,
			"entries": [],
		}
	store[key]["entries"].append(entry.duplicate(true))


func _append_overlay_tile_entry(hex: HexVector, entry: Dictionary) -> void:
	var normalized = HexVector.apply_basis(hex.q, hex.s, hex.r)
	var key = normalized.key()
	if not _overlay_tiles_by_key.has(key):
		_overlay_tiles_by_key[key] = {
			"hex": normalized,
			"entries": [],
		}
	_overlay_tiles_by_key[key]["entries"].append(entry.duplicate(true))


func _tile_override_for_hex(hex: HexVector, is_wall_cell: bool) -> Dictionary:
	var kind = HexMapDocumentAdapter.KIND_WALL if is_wall_cell else HexMapDocumentAdapter.KIND_FLOOR
	var key = _tile_override_key(hex.key(), kind)
	if _tile_overrides_by_key.has(key):
		return _tile_overrides_by_key[key]
	return {}


func _tile_override_key(hex_key: String, kind: String) -> String:
	return "%s|%s" % [hex_key, kind]


func _payload_marker_count(store: Dictionary, key: String) -> int:
	if not store.has(key):
		return 0
	var bucket: Dictionary = store[key]
	return (bucket.get("entries", []) as Array).size()


func _overlay_tile_count(key: String) -> int:
	if not _overlay_tiles_by_key.has(key):
		return 0
	var bucket: Dictionary = _overlay_tiles_by_key[key]
	return (bucket.get("entries", []) as Array).size()


func _overlay_tile_state_for_hex(hex: HexVector, visual_hex = null) -> Dictionary:
	var normalized = HexVector.apply_basis(hex.q, hex.s, hex.r)
	var result = {
		"source_id": -1,
		"atlas_coords": Vector2i(-1, -1),
		"alternative_tile": -1,
		"count": _overlay_tile_count(normalized.key()),
	}
	if _overlay_tile_map == null:
		return result
	var target_hex = visual_hex if visual_hex != null else normalized
	var map_cell = HexMapTileAdapter.vector_to_map_cell(target_hex, flat_top)
	result["source_id"] = _overlay_tile_map.get_cell_source_id(map_cell)
	result["atlas_coords"] = _overlay_tile_map.get_cell_atlas_coords(map_cell)
	result["alternative_tile"] = _overlay_tile_map.get_cell_alternative_tile(map_cell)
	return result


func _redraw_overlay_tile_map() -> void:
	if _overlay_tile_map == null:
		return
	_sync_overlay_tile_map()
	_overlay_tile_map.clear()
	for key in _overlay_tiles_by_key:
		var bucket: Dictionary = _overlay_tiles_by_key[key]
		var hex = bucket.get("hex", null)
		if hex == null:
			continue
		_set_overlay_tile_cell_for_hex(hex)


func _update_overlay_tile(hex: HexVector) -> void:
	if _overlay_tile_map == null:
		return
	var normalized = HexVector.apply_basis(hex.q, hex.s, hex.r)
	var map_cell = HexMapTileAdapter.vector_to_map_cell(normalized, flat_top)
	if not _overlay_tiles_by_key.has(normalized.key()) or _data == null or not _data.cell_set().has(normalized.key()):
		_overlay_tile_map.erase_cell(map_cell)
	else:
		_set_overlay_tile_cell_for_hex(normalized)
	_queue_visual_redraw()


func _set_overlay_tile_cell_for_hex(hex: HexVector) -> void:
	if _overlay_tile_map == null:
		return
	var normalized = HexVector.apply_basis(hex.q, hex.s, hex.r)
	var entry = _top_overlay_tile_entry(normalized.key())
	var map_cell = HexMapTileAdapter.vector_to_map_cell(normalized, flat_top)
	if entry.is_empty() or int(entry.get("source_id", -1)) < 0:
		_overlay_tile_map.erase_cell(map_cell)
		return
	_overlay_tile_map.set_cell(
		map_cell,
		int(entry.get("source_id", 0)),
		entry.get("atlas_coords", Vector2i.ZERO),
		int(entry.get("alternative_tile", 0))
	)


func _top_overlay_tile_entry(key: String) -> Dictionary:
	if not _overlay_tiles_by_key.has(key):
		return {}
	var entries: Array = _overlay_tiles_by_key[key].get("entries", [])
	for index in range(entries.size() - 1, -1, -1):
		if entries[index] is Dictionary:
			return (entries[index] as Dictionary).duplicate(true)
	return {}


func _hex_from_entry_cell(entry: Dictionary) -> HexVector:
	var cell = entry.get("cell", Vector3i.ZERO)
	if typeof(cell) == TYPE_VECTOR3I:
		return HexVector.apply_basis(cell.x, cell.y, cell.z)
	if cell is HexVector:
		return HexVector.apply_basis(cell.q, cell.s, cell.r)
	return HexVector.zero()


func _entry_cell_key(entry: Dictionary) -> String:
	return _hex_from_entry_cell(entry).key()


func _display_center_for_hex(hex: HexVector) -> Vector2:
	if _tile_map == null:
		return hex_to_display_local(hex)
	return _tile_map.position + hex_to_display_local(hex)


func _sync_hex_size_from_tile_size(tile_size: Vector2i) -> void:
	if tile_size.x <= 0 or tile_size.y <= 0:
		return
	var next_hex_size = float(tile_size.x) * 0.5 if flat_top else float(tile_size.y) * 0.5
	if is_equal_approx(hex_size, next_hex_size):
		return
	hex_size = next_hex_size


func _sync_hex_size_for_current_display() -> void:
	var tile_size := HexMapTileAdapter.SAMPLE_TILE_SIZE
	if _tile_map != null \
		and _tile_map.tile_set != null \
		and _tile_map.tile_set.tile_size.x > 0 \
		and _tile_map.tile_set.tile_size.y > 0:
		tile_size = _tile_map.tile_set.tile_size
	_sync_hex_size_from_tile_size(tile_size)


func _queue_visual_redraw() -> void:
	queue_redraw()
	if _overlay != null and is_instance_valid(_overlay):
		_overlay.queue_redraw()


func _ensure_tile_map_layers() -> void:
	for child in get_children(true):
		if child is TileMapLayer and child.name == BASE_TILE_MAP_NAME:
			_tile_map = child
		elif child is TileMapLayer and child.name == LOOP_TILE_MAP_NAME:
			_loop_tile_map = child
		elif child is TileMapLayer and child.name == OVERLAY_TILE_MAP_NAME:
			_overlay_tile_map = child
		elif child is OverlayCanvas and child.name == OVERLAY_NAME:
			_overlay = child
		elif child is TileMapLayer and _tile_map == null:
			_tile_map = child
	if _tile_map == null:
		_tile_map = TileMapLayer.new()
		_tile_map.name = BASE_TILE_MAP_NAME
		add_child(_tile_map, false, INTERNAL_MODE_BACK)
	if _loop_tile_map == null:
		_loop_tile_map = TileMapLayer.new()
		_loop_tile_map.name = LOOP_TILE_MAP_NAME
		add_child(_loop_tile_map, false, INTERNAL_MODE_BACK)
	if _overlay_tile_map == null:
		_overlay_tile_map = TileMapLayer.new()
		_overlay_tile_map.name = OVERLAY_TILE_MAP_NAME
		add_child(_overlay_tile_map, false, INTERNAL_MODE_FRONT)
	if _overlay == null:
		_overlay = OverlayCanvas.new()
		_overlay.name = OVERLAY_NAME
		add_child(_overlay, false, INTERNAL_MODE_FRONT)
	_overlay_tile_map.z_index = 50
	_overlay.layer = self
	_overlay.z_index = 100
	_overlay.position = Vector2.ZERO


func _configure_tile_map() -> void:
	if _tile_map.tile_set == null:
		_tile_map.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(_tile_map.tile_set, flat_top)
	_ensure_display_tiles_available()
	_sync_loop_tile_map()
	_sync_overlay_tile_map()


func _sync_loop_tile_map() -> void:
	if _loop_tile_map != null:
		_loop_tile_map.tile_set = _tile_map.tile_set
		_loop_tile_map.position = _tile_map.position


func _sync_overlay_tile_map() -> void:
	if _overlay_tile_map != null and _tile_map != null:
		_overlay_tile_map.tile_set = _tile_map.tile_set
		_overlay_tile_map.position = _tile_map.position


func _ensure_display_tiles_available(tile_size: Vector2i = HexMapTileAdapter.SAMPLE_TILE_SIZE) -> bool:
	if _tile_map == null:
		return false
	if _tile_map.tile_set == null:
		_tile_map.tile_set = TileSet.new()
	if _display_tiles_available(_tile_map.tile_set):
		return true
	var texture := HexMapTileAdapter.load_sample_tile_texture()
	if texture == null:
		return false
	if tile_size.x <= 0 or tile_size.y <= 0:
		tile_size = HexMapTileAdapter.SAMPLE_TILE_SIZE
	_sync_hex_size_from_tile_size(tile_size)
	return _configure_display_tile_sources(texture, tile_size)


func _display_tiles_available(tile_set: TileSet) -> bool:
	return _tile_set_has_display_tile(tile_set, floor_source_id, floor_atlas_coords) \
		and _tile_set_has_display_tile(tile_set, wall_source_id, wall_atlas_coords)


func _tile_set_has_display_tile(tile_set: TileSet, source_id: int, atlas_coords: Vector2i) -> bool:
	if tile_set == null or source_id < 0 or not tile_set.has_source(source_id):
		return false
	var source = tile_set.get_source(source_id)
	if source is TileSetAtlasSource:
		return (source as TileSetAtlasSource).has_tile(atlas_coords)
	return true


func _configure_display_tile_sources(texture: Texture2D, tile_size: Vector2i) -> bool:
	if _tile_map == null or _tile_map.tile_set == null or texture == null:
		return false
	if not _texture_supports_atlas_tile(texture, tile_size, floor_atlas_coords) \
		or not _texture_supports_atlas_tile(texture, tile_size, wall_atlas_coords):
		return false
	var ok := true
	if floor_source_id == wall_source_id:
		ok = HexMapTileAdapter.configure_atlas_tile_set(
			_tile_map.tile_set,
			texture,
			flat_top,
			tile_size,
			floor_source_id,
			[floor_atlas_coords, wall_atlas_coords]
		)
	else:
		ok = HexMapTileAdapter.configure_atlas_tile_set(
			_tile_map.tile_set,
			texture,
			flat_top,
			tile_size,
			floor_source_id,
			[floor_atlas_coords]
		)
		ok = HexMapTileAdapter.configure_atlas_tile_set(
			_tile_map.tile_set,
			texture,
			flat_top,
			tile_size,
			wall_source_id,
			[wall_atlas_coords]
		) and ok
	return ok


func _texture_supports_atlas_tile(texture: Texture2D, tile_size: Vector2i, atlas_coords: Vector2i) -> bool:
	if texture == null or tile_size.x <= 0 or tile_size.y <= 0:
		return false
	if atlas_coords.x < 0 or atlas_coords.y < 0:
		return false
	return (atlas_coords.x + 1) * tile_size.x <= texture.get_width() \
		and (atlas_coords.y + 1) * tile_size.y <= texture.get_height()


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
