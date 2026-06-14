class_name HexObjectLayerRenderer
extends RefCounted

const OBJECT_INSTANCE_LAYER_NAME := "ObjectInstanceLayer"
const OBJECT_MARKER_COLOR = Color(0.10, 0.60, 0.82, 0.92)
const LABEL_MARKER_COLOR = Color(0.94, 0.74, 0.18, 0.92)
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")

const HexObjectLayerAdapter = preload("res://addons/hex_map_kit/adapter/hex_object_layer_adapter.gd")


func ensure_object_instance_layer(parent: Node) -> Node2D:
	if parent == null:
		return null
	if not parent is Node:
		return null
	var existing: Node2D = parent.get_node_or_null(NodePath(OBJECT_INSTANCE_LAYER_NAME))
	if existing == null:
		existing = Node2D.new()
		existing.name = OBJECT_INSTANCE_LAYER_NAME
		parent.add_child(existing, false, Node.INTERNAL_MODE_FRONT)
	existing.z_index = 60
	return existing


func apply_scene_tile_prototypes(target_layer: TileMapLayer, document_or_entries: Variant, options: Dictionary = {}) -> int:
	return HexObjectLayerAdapter.apply_scene_tile_prototypes(target_layer, document_or_entries, options)


func apply_direct_instance_prototypes(parent: Node, document_or_entries: Variant, options: Dictionary = {}) -> int:
	if parent == null:
		return 0
	return HexObjectLayerAdapter.apply_direct_instance_prototypes(parent, document_or_entries, options)


func draw_document_payload_markers(
	canvas,
	object_markers_by_key: Dictionary,
	label_markers_by_key: Dictionary,
	visual_hexes_for_draw: Callable,
	display_center_for_hex: Callable,
	hex_size: float,
	has_payload_data: bool
) -> void:
	if not has_payload_data:
		return
	if canvas == null:
		return
	if not visual_hexes_for_draw.is_valid() or not display_center_for_hex.is_valid():
		return
	if not is_instance_valid(canvas):
		return

	for key in object_markers_by_key:
		var bucket: Dictionary = object_markers_by_key[key]
		var hex = bucket.get("hex", null)
		if hex == null:
			continue
		var raw_visual_hexes = visual_hexes_for_draw.call(hex)
		if not raw_visual_hexes is Array:
			continue
		var visual_hexes: Array = raw_visual_hexes
		for raw_visual_hex in visual_hexes:
			if not raw_visual_hex is HexVector:
				continue
			var visual_hex = raw_visual_hex as HexVector
			var center = display_center_for_hex.call(visual_hex)
			if canvas.has_method("draw_circle"):
				canvas.draw_circle(center + Vector2(0.0, -hex_size * 0.24), maxf(3.0, hex_size * 0.13), OBJECT_MARKER_COLOR)

	for key in label_markers_by_key:
		var bucket: Dictionary = label_markers_by_key[key]
		var hex = bucket.get("hex", null)
		if hex == null:
			continue
		var raw_visual_hexes = visual_hexes_for_draw.call(hex)
		if not raw_visual_hexes is Array:
			continue
		var visual_hexes: Array = raw_visual_hexes
		for raw_visual_hex in visual_hexes:
			if not raw_visual_hex is HexVector:
				continue
			var visual_hex = raw_visual_hex as HexVector
			var center = display_center_for_hex.call(visual_hex)
			var marker_size = Vector2(maxf(7.0, hex_size * 0.42), maxf(3.0, hex_size * 0.12))
			if canvas.has_method("draw_rect"):
				canvas.draw_rect(Rect2(center + Vector2(-marker_size.x * 0.5, hex_size * 0.18), marker_size), LABEL_MARKER_COLOR)
