class_name HexToricMapSplitRule
extends RefCounted

const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexToricCoordinateScript = preload("res://addons/hex_map_kit/core/hex_toric_coordinate.gd")

var map_unit_radius: int
var cyclic_size: int
var split_canvas: Array = []
var split_canvas_origins: Array = []
var split_tag: Dictionary = {}


func _init(p_map_unit_radius: int = 1) -> void:
	assert(p_map_unit_radius > 0)
	map_unit_radius = p_map_unit_radius
	cyclic_size = map_unit_radius * 2 + 1
	_build_split_canvas()


func canvas_cells() -> Array:
	var result: Array = []
	for area in split_canvas:
		result.append_array(area)
	return result


func split_index_for(point) -> int:
	var wrapped = HexToricCoordinateScript.wrap_vector(point, cyclic_size)
	return split_tag.get(wrapped.key(), -1)


func get_rough_split_tag(point) -> int:
	var split_index = split_index_for(point)
	if split_index == -1:
		return -1
	return split_index if split_index % 7 == 0 else 8


func get_split_area_unit(origin, flat_left: bool = true) -> Array:
	return triangle(map_unit_radius, origin, flat_left)


static func triangle(edge_length: int, origin, flat_left: bool = true) -> Array:
	assert(edge_length > 0)
	var result: Array = []
	for q in range(edge_length):
		for r in range(edge_length):
			var delta = r - q
			if flat_left and delta < 0:
				continue
			if not flat_left and delta > 0:
				continue
			result.append(origin.add(HexVectorScript.apply_basis(q, 0, r)))
	return result


func _build_split_canvas() -> void:
	split_canvas_origins = [
		HexVectorScript.apply_basis(0, 0, map_unit_radius + 1),
		HexVectorScript.apply_basis(0, 0, map_unit_radius),
		HexVectorScript.apply_basis(0, 0, 0),
		HexVectorScript.apply_basis(1, 0, 0),
		HexVectorScript.apply_basis(map_unit_radius, 0, map_unit_radius + 1),
		HexVectorScript.apply_basis(map_unit_radius + 1, 0, map_unit_radius + 1),
		HexVectorScript.apply_basis(map_unit_radius + 1, 0, 1),
		HexVectorScript.apply_basis(map_unit_radius + 1, 0, 0),
	]

	split_canvas = []
	for index in range(split_canvas_origins.size()):
		split_canvas.append(get_split_area_unit(split_canvas_origins[index], index % 2 == 0))

	split_canvas_origins.append(HexVectorScript.apply_basis(map_unit_radius, 0, map_unit_radius))
	split_canvas.append([HexVectorScript.apply_basis(map_unit_radius, 0, map_unit_radius)])

	split_tag = {}
	for area_index in range(split_canvas.size()):
		for point in split_canvas[area_index]:
			split_tag[point.key()] = area_index
