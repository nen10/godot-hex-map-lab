class_name HexMapEditViewportInputAdapter
extends RefCounted

const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")


static func accepts_mouse_press(event: InputEvent) -> bool:
	if not event is InputEventMouseButton:
		return false
	var mouse_event := event as InputEventMouseButton
	return mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed


static func target_local_trace(viewport_position: Vector2, scene_position, target_layer: Node) -> Dictionary:
	if target_layer == null or not is_instance_valid(target_layer) or not (target_layer is CanvasItem):
		return {
			"ok": false,
			"status": "No editable target layer.",
			"debug_stage": "target missing",
			"viewport_position": viewport_position,
			"scene_position": Vector2.ZERO,
			"local_position": Vector2.ZERO,
		}
	if scene_position == null:
		return {
			"ok": false,
			"status": "Cannot resolve editor viewport position.",
			"debug_stage": "scene position missing",
			"viewport_position": viewport_position,
			"scene_position": Vector2.ZERO,
			"local_position": Vector2.ZERO,
		}
	var local_pos = (target_layer as CanvasItem).to_local(scene_position)
	return {
		"ok": true,
		"viewport_position": viewport_position,
		"scene_position": scene_position,
		"local_position": local_pos,
	}


static func local_hit(local_pos: Vector2, target_layer: Node, document, fallback_hex_size: float) -> Dictionary:
	if target_layer is HexTileMapLayer:
		return (target_layer as HexTileMapLayer).local_to_cell_hit(local_pos)
	if target_layer is TileMapLayer:
		var map_cell = (target_layer as TileMapLayer).local_to_map(local_pos)
		var flat_top = _document_is_flat_top(document)
		var tile_hex = HexMapTileAdapter.map_cell_to_vector(map_cell, flat_top)
		return {
			"hex": tile_hex,
			"visual_hex": tile_hex,
			"local": local_pos,
			"exists": _document_has_cell(document, tile_hex),
		}
	var hex = _local_to_hex(local_pos, document, fallback_hex_size)
	return {
		"hex": hex,
		"visual_hex": hex,
		"local": local_pos,
		"exists": _document_has_cell(document, hex),
	}


static func hit_is_editable(hit: Dictionary, edit_mode: int, shape_mode: int) -> bool:
	if hit.is_empty():
		return false
	return edit_mode == shape_mode or bool(hit.get("exists", false))


static func _document_has_cell(document, hex) -> bool:
	var map_resource = HexMapDocumentAdapter.to_map_resource(document)
	return map_resource != null and map_resource.to_map_data().has_cell(hex)


static func _document_is_flat_top(document) -> bool:
	var map_resource = HexMapDocumentAdapter.to_map_resource(document)
	return map_resource == null or map_resource.is_flat_top()


static func _local_to_hex(local_pos: Vector2, document, fallback_hex_size: float):
	var flat_top = _document_is_flat_top(document)
	var frac_q: float
	var frac_r: float
	var sqrt3 = sqrt(3.0)
	if flat_top:
		frac_q = (2.0 / 3.0 * local_pos.x) / fallback_hex_size
		frac_r = (-1.0 / 3.0 * local_pos.x + sqrt3 / 3.0 * local_pos.y) / fallback_hex_size
	else:
		frac_q = (sqrt3 / 3.0 * local_pos.x - 1.0 / 3.0 * local_pos.y) / fallback_hex_size
		frac_r = (2.0 / 3.0 * local_pos.y) / fallback_hex_size
	return _cube_round(frac_q, frac_r)


static func _cube_round(frac_q: float, frac_r: float):
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
	return HexVector.apply_basis(rq + rr, 0, rr)
