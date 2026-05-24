class_name HexGrid
extends RefCounted

const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexToricCoordinateScript = preload("res://addons/hex_map_kit/core/hex_toric_coordinate.gd")


static func directions() -> Array:
	return HexVectorScript.directions()


static func neighbors(position, cyclic_size: int = 0) -> Array:
	return neighbors_in_directions(position, directions(), cyclic_size)


static func neighbors_in_directions(position, direction_order: Array, cyclic_size: int = 0) -> Array:
	var result: Array = []
	for direction in direction_order:
		var neighbor = position.add(direction)
		if cyclic_size > 0:
			neighbor = HexToricCoordinateScript.wrap_vector(neighbor, cyclic_size)
		result.append(neighbor)
	return result


static func l1_ring(radius: int, origin = null) -> Array:
	assert(radius >= 0)
	var center = origin if origin != null else HexVectorScript.zero()
	var result: Array = []
	for r in range(-radius, radius + 1):
		for q in range(-radius, radius + 1):
			var offset = HexVectorScript.apply_basis(q, 0, r)
			if offset.l1_norm() != radius:
				continue
			result.append(center.add(offset))
	return result


static func l1_disc(radius: int, origin = null) -> Array:
	assert(radius >= 0)
	var center = origin if origin != null else HexVectorScript.zero()
	var result: Array = []
	for r in range(-radius, radius + 1):
		for q in range(-radius, radius + 1):
			var offset = HexVectorScript.apply_basis(q, 0, r)
			if offset.l1_norm() > radius:
				continue
			result.append(center.add(offset))
	return result


static func make_set(points: Array) -> Dictionary:
	var result := {}
	for point in points:
		result[point.key()] = point
	return result


static func connected_area(
	start,
	enterable_points: Array,
	cyclic_size: int = 0,
	direction_order: Array = []
) -> Array:
	var directions_ordered = directions() if direction_order.is_empty() else direction_order
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

		for neighbor in neighbors_in_directions(current, directions_ordered, cyclic_size):
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


static func shortest_path(
	start,
	goals: Array,
	enterable_points: Array,
	cyclic_size: int = 0,
	direction_order: Array = []
) -> Array:
	return shortest_path_to_any([start], goals, enterable_points, cyclic_size, direction_order)


static func shortest_path_to_any(
	starts: Array,
	goals: Array,
	enterable_points: Array,
	cyclic_size: int = 0,
	direction_order: Array = []
) -> Array:
	var directions_ordered = directions() if direction_order.is_empty() else direction_order
	var enterable := _make_wrapped_set(enterable_points, cyclic_size)
	var goal_set := _make_wrapped_set(goals, cyclic_size)
	var open: Array = []
	var closed = {}
	var queued = {}
	var parent = {}

	for start in starts:
		var normalized_start = _wrap_if_needed(start, cyclic_size)
		var start_key = normalized_start.key()
		if not enterable.has(start_key):
			continue
		if queued.has(start_key):
			continue
		open.append(enterable[start_key])
		queued[start_key] = true
		parent[start_key] = ""

	while not open.is_empty():
		var current = open.pop_front()
		var current_key = current.key()
		if closed.has(current_key):
			continue
		if not enterable.has(current_key):
			continue

		closed[current_key] = enterable[current_key]
		if goal_set.has(current_key):
			return _rebuild_path(current_key, parent, closed)

		for neighbor in neighbors_in_directions(current, directions_ordered, cyclic_size):
			var neighbor_key = neighbor.key()
			if closed.has(neighbor_key):
				continue
			if queued.has(neighbor_key):
				continue
			if not enterable.has(neighbor_key):
				continue
			parent[neighbor_key] = current_key
			queued[neighbor_key] = true
			open.append(enterable[neighbor_key])

	return []


static func _wrap_if_needed(point, cyclic_size: int):
	if cyclic_size <= 0:
		return point
	return HexToricCoordinateScript.wrap_vector(point, cyclic_size)


static func _make_wrapped_set(points: Array, cyclic_size: int) -> Dictionary:
	var result := {}
	for point in points:
		var normalized = _wrap_if_needed(point, cyclic_size)
		result[normalized.key()] = normalized
	return result


static func _rebuild_path(goal_key: String, parent: Dictionary, closed: Dictionary) -> Array:
	var keys: Array = []
	var current_key = goal_key
	while current_key != "":
		keys.push_front(current_key)
		current_key = parent[current_key]

	var result: Array = []
	for key in keys:
		result.append(closed[key])
	return result
