class_name HexMapGenerator
extends RefCounted

const HexGridScript = preload("res://addons/hex_map_kit/core/hex_grid.gd")
const HexMapDataScript = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexRandomizerScript = preload("res://addons/hex_map_kit/core/hex_randomizer.gd")
const HexToricCoordinateScript = preload("res://addons/hex_map_kit/core/hex_toric_coordinate.gd")
const HexToricMapSplitRuleScript = preload("res://addons/hex_map_kit/core/hex_toric_map_split_rule.gd")
const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")


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
	var data = HexMapDataScript.square(size, true)
	data.set_walls(generate_random_walls(data.cells, wall_probability, seed, protected_floor))
	if ensure_connected:
		restore_connectivity(data)
	return data


static func generate_symmetric_square(
	radius: int,
	wall_probability: float,
	seed: int = 0,
	ensure_connected: bool = false,
	protected_floor: Array = [],
	distribution_id: int = 20,
	terminal_floor: Array = [],
	connect_toric: bool = false,
):
	assert(radius > 0)
	var size: int = radius * 2 + 1 
	var data = HexMapDataScript.square(size, connect_toric)
	var forced_floor = protected_floor.duplicate()
	for terminal in terminal_floor:
		forced_floor.append(terminal)
	data.set_walls(generate_symmetric_toric_walls(
		radius,
		wall_probability,
		seed,
		distribution_id,
		forced_floor
	))
	if not terminal_floor.is_empty():
		restore_terminal_connectivity(data, terminal_floor)
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


static func generate_symmetric_hexagon(
	radius: int,
	wall_probability: float,
	seed: int = 0,
	ensure_connected: bool = false,
	protected_floor: Array = [],
	distribution_id: int = 20,
	terminal_floor: Array = []
):
	assert(radius > 0)
	var size: int = radius * 2 + 1

	var forced_floor = protected_floor.duplicate()
	for terminal in terminal_floor:
		forced_floor.append(terminal)

	var all_walls = generate_symmetric_toric_walls(
		radius,
		wall_probability,
		seed,
		distribution_id,
		forced_floor
	)

	var rule = HexToricMapSplitRuleScript.new(radius)
	var edge_keys := {}
	for area_index in [0, 7]:
		for point in rule.split_canvas[area_index]:
			edge_keys[point.key()] = true

	var square_cells = HexMapDataScript.square(size, false).cells
	var hex_cells: Array = []
	for cell in square_cells:
		if not edge_keys.has(cell.key()):
			hex_cells.append(cell)

	var hex_walls: Array = []
	var wall_set = HexMapDataScript.make_set(all_walls)
	for wall in all_walls:
		if not edge_keys.has(wall.key()):
			hex_walls.append(wall)

	var data = HexMapDataScript.from_cells(hex_cells, hex_walls, 0)
	if not terminal_floor.is_empty():
		restore_terminal_connectivity(data, terminal_floor)
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


static func generate_symmetric_toric_walls(
	radius: int,
	wall_probability: float,
	seed: int = 0,
	distribution_id: int = 20,
	protected_floor: Array = []
) -> Array:
	assert(radius > 0)
	var size: int = radius * 2 + 1 
	assert(wall_probability >= 0.0)
	assert(wall_probability <= 1.0)

	var rule = HexToricMapSplitRuleScript.new(radius)
	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	var state := {
		"rule": rule,
		"rng": rng,
		"walls": {},
		"protected": HexMapDataScript.make_set(_wrapped_points(protected_floor, size)),
		"distribution_id": distribution_id,
	}
	var outer = _draw_symmetric_outer_area(state, wall_probability)
	var border = _draw_symmetric_border(
		state,
		outer["edge_count"],
		outer["draw_node"],
		wall_probability
	)
	_draw_symmetric_inner_area(
		state,
		border["edge_count"],
		border["draw_node"],
		wall_probability
	)

	var data = HexMapDataScript.square(size, true)
	var result: Array = []
	var wall_set: Dictionary = state["walls"]
	for cell in data.cells:
		if wall_set.has(cell.key()):
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


static func are_terminals_connected(data, terminals: Array) -> bool:
	var terminal_points = _normalized_terminals(data, terminals)
	if terminal_points.size() <= 1:
		return true

	var floors = data.floor_cells()
	var connected = HexGridScript.connected_area(terminal_points[0], floors, data.cyclic_size)
	var connected_set = HexMapDataScript.make_set(connected)
	for terminal in terminal_points:
		if not connected_set.has(terminal.key()):
			return false
	return true


static func restore_terminal_connectivity(data, terminals: Array) -> Array:
	var terminal_points = _normalized_terminals(data, terminals)
	var removed_walls: Array = []
	if terminal_points.is_empty():
		return removed_walls

	_remove_walls_at_points(data, terminal_points, removed_walls)

	var max_iterations = data.cells.size() + data.walls.size() + terminal_points.size() + 1
	var iterations = 0
	while iterations < max_iterations:
		iterations += 1
		var floors = data.floor_cells()
		var connected = HexGridScript.connected_area(terminal_points[0], floors, data.cyclic_size)
		var connected_set = HexMapDataScript.make_set(connected)
		var targets: Array = []
		for terminal in terminal_points:
			if connected_set.has(terminal.key()):
				continue
			targets.append(terminal)

		if targets.is_empty():
			return removed_walls

		var path = HexGridScript.shortest_path_to_any(
			connected,
			targets,
			data.cells,
			data.cyclic_size
		)
		if path.is_empty():
			return removed_walls

		var changed = _remove_walls_at_points(data, path, removed_walls)
		if not changed:
			return removed_walls

	return removed_walls


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


static func _draw_symmetric_outer_area(state: Dictionary, wall_probability: float) -> Dictionary:
	var rule = state["rule"]
	var left = _draw_symmetric_edge_area(
		state,
		true,
		rule.split_canvas_origins[0],
		wall_probability
	)
	var right = _draw_symmetric_edge_area(
		state,
		false,
		rule.split_canvas_origins[7],
		wall_probability
	)
	var draw_node: Array = []
	draw_node.append_array(left["draw_node"])
	draw_node.append_array(right["draw_node"])
	return {
		"edge_count": left["edge_count"] + right["edge_count"],
		"draw_node": draw_node,
	}


static func _draw_symmetric_edge_area(
	state: Dictionary,
	flat_left: bool,
	origin,
	wall_probability: float
) -> Dictionary:
	var centered = _draw_symmetric_area_center(state, flat_left, origin, wall_probability)
	var rule = state["rule"]
	if (rule.map_unit_radius - 1) % 3 == 2:
		return {
			"edge_count": _sum_int(centered["draw_counts"]),
			"draw_node": _symmetry_outer_boundary_nodes(rule, flat_left, origin),
		}
	return _draw_symmetric_area_from_center(
		state,
		flat_left,
		origin,
		centered["draw_node"],
		centered["draw_counts"],
		wall_probability
	)


static func _draw_symmetric_area_center(
	state: Dictionary,
	flat_left: bool,
	origin,
	wall_probability: float
) -> Dictionary:
	var rule = state["rule"]
	var step_directions = _symmetry_edge_step_directions(flat_left)
	var center_direction = _r_axis().subtract(_s_axis()) if flat_left else _q_axis().subtract(_s_axis())
	var pen = origin.add(center_direction.scaled(int(rule.map_unit_radius / 3)))
	var arc_size = (rule.map_unit_radius - 1) % 3
	var draw_count = 0
	var draw_counts: Array = []
	var draw_node: Array = []

	if arc_size == 0:
		draw_count = _draw_from_prob(state, pen, wall_probability)

	for step in step_directions:
		if arc_size != 0:
			draw_count = 0
		draw_node.append(pen)
		for _index in range(arc_size):
			draw_count += _draw_from_prob(
				state,
				pen,
				wall_probability * (1.0 - (float(draw_count) / float(arc_size)))
			)
			pen = pen.add(step)
		draw_counts.append(draw_count)

	return {
		"draw_counts": draw_counts,
		"draw_node": draw_node,
	}


static func _draw_symmetric_area_from_center(
	state: Dictionary,
	flat_left: bool,
	origin,
	draw_node: Array,
	draw_counts: Array,
	wall_probability: float
) -> Dictionary:
	var rule = state["rule"]
	var step_directions = _symmetry_edge_step_directions(flat_left)
	var wave_directions: Array = []
	var reference_directions: Array = []
	var arc_size = (rule.map_unit_radius - 1) % 3
	var pen = _zero()
	var edge_count = _sum_int(draw_counts) * (1 if arc_size == 2 else 2)

	for side in range(3):
		wave_directions.append(step_directions[(side + 2) % 3].subtract(step_directions[side]))
	for side in range(3):
		reference_directions.append([
			step_directions[side].negated(),
			wave_directions[side].negated().subtract(step_directions[side]).subtract(step_directions[side]),
			wave_directions[side].negated().subtract(step_directions[side]),
		])

	while not pen.is_equal(origin):
		arc_size += 3
		for side in range(3):
			draw_node[side] = draw_node[side].add(wave_directions[side])
			pen = draw_node[side]
			var density = (float(draw_counts[side]) + 1.0 + wall_probability) / float(arc_size)
			draw_counts[side] = _draw_from_prob(state, pen, 1.0 - density)
			_draw_from_prob(
				state,
				pen.add(reference_directions[side][2]),
				wall_probability * (1.0 - ((float(draw_counts[side]) + density) / 2.0))
			)

		edge_count += _sum_int(draw_counts)

		for side in range(3):
			pen = draw_node[side]
			for _index in range(1, arc_size - 1):
				pen = pen.add(step_directions[side])
				draw_counts[side] += _draw_arc_point(state, pen, reference_directions[side])

		for side in range(3):
			pen = draw_node[side].add(step_directions[side].scaled(arc_size - 1))
			draw_counts[side] += _over_draw_arc_point(state, pen, reference_directions[side])
			pen = pen.add(step_directions[side])

	return {
		"edge_count": edge_count,
		"draw_node": draw_node,
	}


static func _draw_symmetric_border(
	state: Dictionary,
	edge_count: int,
	draw_node: Array,
	wall_probability: float
) -> Dictionary:
	var rule = state["rule"]
	var step_directions = _symmetry_step_directions_for_arcs()
	var reference_directions = _symmetry_reference_directions_for_arcs()
	var denominator = float(int((rule.map_unit_radius + 2) / 3) * 6) + 1.0
	var density = (float(edge_count) + wall_probability) / denominator

	for side in range(3):
		var pen = _reference_position(state, draw_node[side].add(step_directions[side]))
		edge_count += _draw_from_prob(state, pen, 1.0 - density)

	for side in range(6):
		var index = 1 - int(side / 3)
		var pen = _reference_position(state, draw_node[side].add(step_directions[side].scaled(index)))
		for _cursor in range(index, rule.map_unit_radius):
			pen = _reference_position(state, pen.add(step_directions[side]))
			_safe_draw_arc_point(state, pen, reference_directions[side])

	var next_draw_node: Array = []
	for side in range(draw_node.size()):
		next_draw_node.append(_reference_position(state, draw_node[side].add(step_directions[side])))

	return {
		"edge_count": edge_count,
		"draw_node": next_draw_node,
	}


static func _draw_symmetric_inner_area(
	state: Dictionary,
	edge_count: int,
	draw_node: Array,
	wall_probability: float
) -> void:
	var rule = state["rule"]
	var step_directions = _symmetry_step_directions_for_arcs()
	var reference_directions = _symmetry_reference_directions_for_arcs()
	for wave in range(1, rule.map_unit_radius):
		var next_draw_node: Array = []
		for side in range(draw_node.size()):
			next_draw_node.append(draw_node[side].subtract(reference_directions[side][1]))
		draw_node = next_draw_node
		for side in range(6):
			for index in range(rule.map_unit_radius - wave):
				_draw_arc_point(
					state,
					draw_node[side].add(step_directions[side].scaled(index)),
					reference_directions[side]
				)

	var denominator = float(int((rule.map_unit_radius + 2) / 3) * 6) + 4.0
	var density = (float(edge_count) + wall_probability) / denominator
	_draw_from_prob(
		state,
		draw_node[0].add(draw_node[1]).add(draw_node[2]).divided(3),
		1.0 - density
	)


static func _draw_arc_point(state: Dictionary, pen, reference_orders: Array) -> int:
	var references: Array = []
	for reference_order in reference_orders:
		references.append(pen.add(reference_order))
	return _draw_from_distribution(state, pen, references)


static func _safe_draw_arc_point(state: Dictionary, pen, reference_orders: Array) -> int:
	var references: Array = []
	for reference_order in reference_orders:
		references.append(_reference_position(state, pen.add(reference_order)))
	return _draw_from_distribution(state, pen, references)


static func _over_draw_arc_point(state: Dictionary, pen, reference_orders: Array) -> int:
	var references: Array = []
	for reference_order in reference_orders:
		references.append(pen.add(reference_order))
	return _over_draw_from_distribution(state, pen, references)


static func _draw_from_distribution(state: Dictionary, pen, reference_points: Array) -> int:
	var wall_set: Dictionary = state["walls"]
	var ref_conditions: Array = []
	for point in reference_points:
		var reference = _reference_position(state, point)
		ref_conditions.append(wall_set.has(reference.key()))
	return _draw_from_prob(
		state,
		pen,
		HexRandomizerScript.prob_from_distribution(ref_conditions, state["distribution_id"])
	)


static func _over_draw_from_distribution(state: Dictionary, pen, reference_points: Array) -> int:
	var wall_set: Dictionary = state["walls"]
	var ref_conditions: Array = []
	for point in reference_points:
		var reference = _reference_position(state, point)
		ref_conditions.append(wall_set.has(reference.key()))
	return _over_draw_from_prob(
		state,
		pen,
		HexRandomizerScript.prob_from_distribution(ref_conditions, state["distribution_id"])
	)


static func _draw_from_prob(state: Dictionary, point, draw_probability: float) -> int:
	var pen = _reference_position(state, point)
	var protected_set: Dictionary = state["protected"]
	var wall_set: Dictionary = state["walls"]
	var key = pen.key()
	if protected_set.has(key):
		wall_set.erase(key)
		return 0

	var probability = draw_probability
	if wall_set.has(key):
		var erased = _erase_wall(state, pen)
		probability = (draw_probability + (1.0 if erased else 0.5)) / 2.0

	var rng: RandomNumberGenerator = state["rng"]
	if rng.randf() < probability:
		wall_set[key] = pen
		return 1
	return 0


static func _over_draw_from_prob(state: Dictionary, point, draw_probability: float) -> int:
	var pen = _reference_position(state, point)
	var protected_set: Dictionary = state["protected"]
	var wall_set: Dictionary = state["walls"]
	var key = pen.key()
	wall_set.erase(key)
	if protected_set.has(key):
		return 0

	var rng: RandomNumberGenerator = state["rng"]
	if rng.randf() < draw_probability:
		wall_set[key] = pen
		return 1
	return 0


static func _erase_wall(state: Dictionary, point) -> bool:
	var pen = _reference_position(state, point)
	var wall_set: Dictionary = state["walls"]
	var key = pen.key()
	var had_wall = wall_set.has(key)
	wall_set.erase(key)
	return had_wall


static func _reference_position(state: Dictionary, point):
	var rule = state["rule"]
	return HexToricCoordinateScript.wrap_vector(point, rule.cyclic_size)


static func _wrapped_points(points: Array, cyclic_size: int) -> Array:
	var result: Array = []
	for point in points:
		result.append(HexToricCoordinateScript.wrap_vector(point, cyclic_size))
	return HexMapDataScript.unique_points(result)


static func _normalized_terminals(data, terminals: Array) -> Array:
	var result: Array = []
	var seen := {}
	var cell_set = data.cell_set()
	for terminal in terminals:
		var point = terminal
		if data.cyclic_size > 0:
			point = HexToricCoordinateScript.wrap_vector(terminal, data.cyclic_size)
		var key = point.key()
		if seen.has(key):
			continue
		if not cell_set.has(key):
			continue
		seen[key] = true
		result.append(cell_set[key])
	return result


static func _remove_walls_at_points(data, points: Array, removed_walls: Array) -> bool:
	var wall_set = data.wall_set()
	var remove_keys := {}
	var changed = false
	var removed_seen = HexMapDataScript.make_set(removed_walls)
	for point in points:
		var key = point.key()
		if not wall_set.has(key):
			continue
		remove_keys[key] = true
		if not removed_seen.has(key):
			removed_walls.append(wall_set[key])
			removed_seen[key] = wall_set[key]
		changed = true

	if changed:
		data.set_walls(_points_without_keys(data.walls, remove_keys))
	return changed


static func _symmetry_outer_boundary_nodes(rule, flat_left: bool, origin) -> Array:
	var forward = _r_axis() if flat_left else _q_axis()
	return [
		origin,
		origin.add(forward.scaled(rule.map_unit_radius - 1)),
		origin.add(_s_axis().negated().scaled(rule.map_unit_radius - 1)),
	]


static func _symmetry_edge_step_directions(flat_left: bool) -> Array:
	if flat_left:
		return [_r_axis(), _q_axis(), _s_axis()]
	return [_q_axis(), _r_axis(), _s_axis()]


static func _symmetry_step_directions_for_arcs() -> Array:
	return [
		_r_axis().negated(),
		_q_axis().negated(),
		_s_axis().negated(),
		_s_axis(),
		_q_axis(),
		_r_axis(),
	]


static func _symmetry_reference_directions_for_arcs() -> Array:
	var steps = _symmetry_step_directions_for_arcs()
	var result: Array = []
	for side in range(6):
		var group = int(side / 3)
		result.append([
			steps[5 - side],
			steps[group * 3 + (side + 1 + group) % 3],
			steps[group * 3 + (side + 2 - group) % 3].negated(),
		])
	return result


static func _sum_int(values: Array) -> int:
	var result = 0
	for value in values:
		result += int(value)
	return result


static func _points_without_keys(points: Array, removed_keys: Dictionary) -> Array:
	var result: Array = []
	for point in points:
		if removed_keys.has(point.key()):
			continue
		result.append(point)
	return result


static func _zero():
	return HexVectorScript.zero()


static func _q_axis():
	return HexVectorScript.q_axis()


static func _s_axis():
	return HexVectorScript.s_axis()


static func _r_axis():
	return HexVectorScript.r_axis()
