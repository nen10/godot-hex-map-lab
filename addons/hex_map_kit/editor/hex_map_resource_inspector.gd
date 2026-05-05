@tool
extends EditorInspectorPlugin

const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")


func _can_handle(object) -> bool:
	return object is HexMapResource


func _parse_begin(object) -> void:
	if not object is HexMapResource:
		return

	var data = object.to_map_data()
	var connected = HexMapGenerator.is_floor_connected(data)
	var orientation = "flat-top" if object.is_flat_top() else "pointy-top"
	var toric_info = ""
	if data.cyclic_size > 0:
		toric_info = "  torus=%s×%s" % [data.cyclic_size, data.cyclic_size]

	var info_label = Label.new()
	info_label.text = "cells=%d  walls=%d  floors=%d  connected=%s  orientation=%s%s" % [
		data.cells.size(),
		data.walls.size(),
		data.floor_cells().size(),
		"yes" if connected else "no",
		orientation,
		toric_info,
	]
	add_custom_control(info_label)
