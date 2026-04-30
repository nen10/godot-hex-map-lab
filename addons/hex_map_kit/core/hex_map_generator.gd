class_name HexMapGenerator
extends RefCounted

const HexGridScript = preload("res://addons/hex_map_kit/core/hex_grid.gd")
const HexMapDataScript = preload("res://addons/hex_map_kit/core/hex_map_data.gd")


static func generate_rectangle(
	width: int,
	height: int,
	wall_probability: float,
	seed: int = 0,
	ensure_connected: bool = false,
	toric: bool = false,
	protected_floor: Array = []
):
	var data = HexMapDataScript.rectangle(width, height, toric)
	data.set_walls(generate_random_walls(data.cells, wall_probability, seed, protected_floor))
	if ensure_connected:
		restore_connectivity(data)
	return data


static func generate_random_walls(
	cells: Array,
	wall_probability: float,
	seed: int = 0,
	protected_floor: Array = []
) -> Array:
	assert(wall_probability >= 0.0)
	assert(wall_probability <= 1.0)

	var protected_set = HexMapDataScript.make_set(protected_floor)
	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	var result: Array = []
	for cell in cells:
		if protected_set.has(cell.key()):
			continue
		if rng.randf() < wall_probability:
			result.append(cell)
	return result


static func is_floor_connected(data) -> bool:
	var floors = data.floor_cells()
	if floors.size() <= 1:
		return true
	return HexGridScript.connected_area(floors[0], floors, data.cyclic_size).size() == floors.size()


static func connected_components(data) -> Array:
	var floors = data.floor_cells()
	var unvisited = HexMapDataScript.make_set(floors)
	var components: Array = []

	for floor in floors:
		if not unvisited.has(floor.key()):
			continue

		var component = HexGridScript.connected_area(floor, floors, data.cyclic_size)
		components.append(component)
		for point in component:
			unvisited.erase(point.key())

	return components


static func restore_connectivity(data) -> Array:
	var removed_walls: Array = []
	if data.cells.is_empty():
		return removed_walls

	if data.floor_cells().is_empty():
		removed_walls.append(data.cells[0])
		data.set_walls(HexMapDataScript.points_except(data.walls, [data.cells[0]]))

	var max_iterations = data.cells.size() + data.walls.size() + 1
	var iterations = 0
	while iterations < max_iterations:
		iterations += 1
		var components = connected_components(data)
		if components.size() <= 1:
			return removed_walls

		var target_set = {}
		for index in range(1, components.size()):
			for point in components[index]:
				target_set[point.key()] = true

		var path = _shortest_path_to_any(components[0], target_set, data)
		if path.is_empty():
			return removed_walls

		var wall_set = data.wall_set()
		var remove_keys = {}
		var changed = false
		for point in path:
			var key = point.key()
			if not wall_set.has(key):
				continue
			removed_walls.append(wall_set[key])
			remove_keys[key] = true
			changed = true

		if not changed:
			return removed_walls

		data.set_walls(_points_without_keys(data.walls, remove_keys))

	return removed_walls


static func _shortest_path_to_any(starts: Array, goal_set: Dictionary, data) -> Array:
	var cell_set = data.cell_set()
	var open: Array = []
	var closed = {}
	var queued = {}
	var parent = {}

	for start in starts:
		var start_key = start.key()
		if not cell_set.has(start_key):
			continue
		open.append(cell_set[start_key])
		queued[start_key] = true
		parent[start_key] = ""

	while not open.is_empty():
		var current = open.pop_front()
		var current_key = current.key()
		if closed.has(current_key):
			continue

		closed[current_key] = current
		if goal_set.has(current_key):
			return _rebuild_path(current_key, parent, closed)

		for neighbor in HexGridScript.neighbors(current, data.cyclic_size):
			var neighbor_key = neighbor.key()
			if closed.has(neighbor_key):
				continue
			if queued.has(neighbor_key):
				continue
			if not cell_set.has(neighbor_key):
				continue
			if not parent.has(neighbor_key):
				parent[neighbor_key] = current_key
			queued[neighbor_key] = true
			open.append(cell_set[neighbor_key])

	return []


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


static func _points_without_keys(points: Array, removed_keys: Dictionary) -> Array:
	var result: Array = []
	for point in points:
		if removed_keys.has(point.key()):
			continue
		result.append(point)
	return result
