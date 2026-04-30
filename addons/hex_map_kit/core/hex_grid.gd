class_name HexGrid
extends RefCounted

const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexToricCoordinateScript = preload("res://addons/hex_map_kit/core/hex_toric_coordinate.gd")


static func directions() -> Array:
	return HexVectorScript.directions()


static func neighbors(position, cyclic_size: int = 0) -> Array:
	var result: Array = []
	for direction in directions():
		var neighbor = position.add(direction)
		if cyclic_size > 0:
			neighbor = HexToricCoordinateScript.wrap_vector(neighbor, cyclic_size)
		result.append(neighbor)
	return result


static func make_set(points: Array) -> Dictionary:
	var result := {}
	for point in points:
		result[point.key()] = point
	return result


static func connected_area(
	start,
	enterable_points: Array,
	cyclic_size: int = 0
) -> Array:
	var normalized_start = start
	if cyclic_size > 0:
		normalized_start = HexToricCoordinateScript.wrap_vector(start, cyclic_size)

	var enterable := make_set(enterable_points)
	if not enterable.has(normalized_start.key()):
		return []

	var closed := {}
	var queued := {normalized_start.key(): true}
	var result: Array = []
	var open: Array = [normalized_start]

	while not open.is_empty():
		var current = open.pop_front()
		var current_key = current.key()
		if closed.has(current_key):
			continue
		if not enterable.has(current_key):
			continue

		closed[current_key] = true
		result.append(current)

		for neighbor in neighbors(current, cyclic_size):
			var neighbor_key = neighbor.key()
			if closed.has(neighbor_key):
				continue
			if queued.has(neighbor_key):
				continue
			if not enterable.has(neighbor_key):
				continue
			queued[neighbor_key] = true
			open.append(neighbor)

	return result
