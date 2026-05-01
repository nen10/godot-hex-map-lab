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


static func generate_toric_square(
	size: int,
	wall_probability: float,
	seed: int = 0,
	ensure_connected: bool = false,
	protected_floor: Array = []
):
	var data = HexMapDataScript.toric_square(size)
	data.set_walls(generate_random_walls(data.cells, wall_probability, seed, protected_floor))
	if ensure_connected:
		restore_connectivity(data)
	return data


static func generate_hexagon(
	radius: int,
	wall_probability: float,
	seed: int = 0,
	ensure_connected: bool = false,
	protected_floor: Array = []
):
	var data = HexMapDataScript.hexagon(radius)
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

		var targets: Array = []
		for index in range(1, components.size()):
			for point in components[index]:
				targets.append(point)

		var path = HexGridScript.shortest_path_to_any(
			components[0],
			targets,
			data.cells,
			data.cyclic_size
		)
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


static func _points_without_keys(points: Array, removed_keys: Dictionary) -> Array:
	var result: Array = []
	for point in points:
		if removed_keys.has(point.key()):
			continue
		result.append(point)
	return result
