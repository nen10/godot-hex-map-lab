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


static func weighted_path(
	start,
	goals: Array,
	enterable_points: Array,
	movement_costs: Dictionary = {},
	cyclic_size: int = 0,
	direction_order: Array = []
) -> Array:
	return weighted_path_to_any([start], goals, enterable_points, movement_costs, cyclic_size, direction_order)


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


static func weighted_path_to_any(
	starts: Array,
	goals: Array,
	enterable_points: Array,
	movement_costs: Dictionary = {},
	cyclic_size: int = 0,
	direction_order: Array = []
) -> Array:
	var directions_ordered = directions() if direction_order.is_empty() else direction_order
	var enterable := _make_wrapped_set(enterable_points, cyclic_size)
	var goal_set := _make_wrapped_set(goals, cyclic_size)
	var open_keys: Array = []
	var costs := {}
	var closed := {}
	var parent := {}

	for start in starts:
		var normalized_start = _wrap_if_needed(start, cyclic_size)
		var start_key = normalized_start.key()
		if not enterable.has(start_key):
			continue
		if costs.has(start_key):
			continue
		open_keys.append(start_key)
		costs[start_key] = 0.0
		parent[start_key] = ""

	while not open_keys.is_empty():
		var current_key = _pop_lowest_cost_key(open_keys, costs)
		if closed.has(current_key):
			continue
		if not enterable.has(current_key):
			continue

		var current = enterable[current_key]
		closed[current_key] = current
		if goal_set.has(current_key):
			return _rebuild_path(current_key, parent, closed)

		for neighbor in neighbors_in_directions(current, directions_ordered, cyclic_size):
			var neighbor_key = neighbor.key()
			if closed.has(neighbor_key):
				continue
			if not enterable.has(neighbor_key):
				continue
			var step_cost = _movement_cost_for_key(neighbor_key, movement_costs)
			if step_cost < 0.0:
				continue
			var candidate_cost = float(costs[current_key]) + step_cost
			if costs.has(neighbor_key) and candidate_cost >= float(costs[neighbor_key]):
				continue
			costs[neighbor_key] = candidate_cost
			parent[neighbor_key] = current_key
			if not open_keys.has(neighbor_key):
				open_keys.append(neighbor_key)

	return []


static func movement_range(
	start,
	enterable_points: Array,
	movement_budget: float,
	movement_costs: Dictionary = {},
	cyclic_size: int = 0,
	direction_order: Array = []
) -> Dictionary:
	if movement_budget < 0.0:
		return {}

	var directions_ordered = directions() if direction_order.is_empty() else direction_order
	var enterable := _make_wrapped_set(enterable_points, cyclic_size)
	var normalized_start = _wrap_if_needed(start, cyclic_size)
	var start_key = normalized_start.key()
	if not enterable.has(start_key):
		return {}

	var open_keys: Array = [start_key]
	var costs := {start_key: 0.0}
	var closed := {}
	var result := {}

	while not open_keys.is_empty():
		var current_key = _pop_lowest_cost_key(open_keys, costs)
		if closed.has(current_key):
			continue
		if not enterable.has(current_key):
			continue
		var current_cost = float(costs[current_key])
		if current_cost > movement_budget:
			continue

		var current = enterable[current_key]
		closed[current_key] = true
		result[current_key] = {
			"cell": current,
			"cost": current_cost,
		}

		for neighbor in neighbors_in_directions(current, directions_ordered, cyclic_size):
			var neighbor_key = neighbor.key()
			if closed.has(neighbor_key):
				continue
			if not enterable.has(neighbor_key):
				continue
			var step_cost = _movement_cost_for_key(neighbor_key, movement_costs)
			if step_cost < 0.0:
				continue
			var candidate_cost = current_cost + step_cost
			if candidate_cost > movement_budget:
				continue
			if costs.has(neighbor_key) and candidate_cost >= float(costs[neighbor_key]):
				continue
			costs[neighbor_key] = candidate_cost
			if not open_keys.has(neighbor_key):
				open_keys.append(neighbor_key)

	return result


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


static func _movement_cost_for_key(key: String, movement_costs: Dictionary) -> float:
	if not movement_costs.has(key):
		return 1.0
	var value = movement_costs[key]
	if value == null:
		return 1.0
	if value is Dictionary:
		return float(value.get("cost", 1.0))
	return float(value)


static func _pop_lowest_cost_key(open_keys: Array, costs: Dictionary) -> String:
	var best_index := 0
	var best_cost = float(costs[open_keys[0]])
	for index in range(1, open_keys.size()):
		var key = open_keys[index]
		var cost = float(costs[key])
		if cost < best_cost:
			best_cost = cost
			best_index = index
	var best_key = open_keys[best_index]
	open_keys.remove_at(best_index)
	return best_key
