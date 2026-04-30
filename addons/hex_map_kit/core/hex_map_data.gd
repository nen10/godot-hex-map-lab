class_name HexMapData
extends RefCounted

const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")

var cells: Array = []
var walls: Array = []
var cyclic_size: int = 0


func _init(p_cells: Array = [], p_walls: Array = [], p_cyclic_size: int = 0) -> void:
	cells = unique_points(p_cells)
	walls = filter_points(p_walls, make_set(cells))
	cyclic_size = p_cyclic_size


static func rectangle(width: int, height: int, toric: bool = false):
	assert(width > 0)
	assert(height > 0)
	if toric:
		assert(width == height)

	var result: Array = []
	for r in range(height):
		for q in range(width):
			result.append(HexVectorScript.apply_basis(q, 0, r))

	return from_cells(result, [], width if toric else 0)


static func toric_square(size: int):
	return rectangle(size, size, true)


static func from_cells(p_cells: Array, p_walls: Array = [], p_cyclic_size: int = 0):
	return load("res://addons/hex_map_kit/core/hex_map_data.gd").new(
		p_cells,
		p_walls,
		p_cyclic_size
	)


func cell_set() -> Dictionary:
	return make_set(cells)


func wall_set() -> Dictionary:
	return make_set(walls)


func floor_cells() -> Array:
	return points_except(cells, walls)


func has_cell(point) -> bool:
	return has_key(cells, point.key())


func has_wall(point) -> bool:
	return has_key(walls, point.key())


func set_walls(p_walls: Array) -> void:
	walls = filter_points(p_walls, cell_set())


static func make_set(points: Array) -> Dictionary:
	var result := {}
	for point in points:
		result[point.key()] = point
	return result


static func has_key(points: Array, key: String) -> bool:
	for point in points:
		if point.key() == key:
			return true
	return false


static func unique_points(points: Array) -> Array:
	var result: Array = []
	var seen := {}
	for point in points:
		var key = point.key()
		if seen.has(key):
			continue
		seen[key] = true
		result.append(point)
	return result


static func filter_points(points: Array, allowed_set: Dictionary) -> Array:
	var result: Array = []
	var seen := {}
	for point in points:
		var key = point.key()
		if seen.has(key):
			continue
		if not allowed_set.has(key):
			continue
		seen[key] = true
		result.append(allowed_set[key])
	return result


static func points_except(points: Array, excluded_points: Array) -> Array:
	var excluded := make_set(excluded_points)
	var result: Array = []
	for point in points:
		if excluded.has(point.key()):
			continue
		result.append(point)
	return result


static func sorted_keys(points: Array) -> Array:
	var result: Array = []
	for point in points:
		result.append(point.key())
	result.sort()
	return result
