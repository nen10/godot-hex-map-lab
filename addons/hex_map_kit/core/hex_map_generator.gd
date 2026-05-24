class_name HexMapGenerator
extends RefCounted

const HexGridScript = preload("res://addons/hex_map_kit/core/hex_grid.gd")
const HexMapDataScript = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexRandomizerScript = preload("res://addons/hex_map_kit/core/hex_randomizer.gd")
const HexToricCoordinateScript = preload("res://addons/hex_map_kit/core/hex_toric_coordinate.gd")
const HexToricMapSplitRuleScript = preload("res://addons/hex_map_kit/core/hex_toric_map_split_rule.gd")
const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")


const CONNECT_NONE := 0
const CONNECT_DENSE := 1
const CONNECT_SPARSE := 2
const _CONNECTIVITY_PROGRESS_START := 0.35
const _INTERRUPT_PROGRESS_START_KEY := "_progress_range_start"
const _INTERRUPT_PROGRESS_END_KEY := "_progress_range_end"

static func generate_rectangle(
	width: int,
	height: int,
	wall_probability: float,
	seed: int = 0,
	connect_method: int = 0,
	toric: bool = false,
	protected_floor: Array = [],
	interrupt_options: Dictionary = {}
):
	var data = HexMapDataScript.rectangle(width, height, toric)
	_prepare_wall_generation_progress(interrupt_options, connect_method)
	var wall_result = generate_random_walls_interruptible(
		data.cells,
		wall_probability,
		seed,
		protected_floor,
		interrupt_options
	)
	data.set_walls(wall_result["walls"])
	if wall_result["cancelled"]:
		_interrupt_clear_progress_range(interrupt_options)
		_record_generation_result(interrupt_options, data, true)
		return data
	_restore_generated_connectivity(connect_method, data, [], seed, interrupt_options)
	if bool(interrupt_options.get("cancelled", false)):
		_interrupt_clear_progress_range(interrupt_options)
		_record_generation_result(interrupt_options, data, true)
		return data
	_interrupt_clear_progress_range(interrupt_options)
	_record_generation_result(interrupt_options, data, false)
	return data


static func generate_toric_square(
	size: int,
	wall_probability: float,
	seed: int = 0,
	connect_method: int = 0,
	protected_floor: Array = [],
	interrupt_options: Dictionary = {}
):
	var data = HexMapDataScript.square(size, true)
	_prepare_wall_generation_progress(interrupt_options, connect_method)
	var wall_result = generate_random_walls_interruptible(
		data.cells,
		wall_probability,
		seed,
		protected_floor,
		interrupt_options
	)
	data.set_walls(wall_result["walls"])
	if wall_result["cancelled"]:
		_interrupt_clear_progress_range(interrupt_options)
		_record_generation_result(interrupt_options, data, true)
		return data
	_restore_generated_connectivity(connect_method, data, [], seed, interrupt_options)
	if bool(interrupt_options.get("cancelled", false)):
		_interrupt_clear_progress_range(interrupt_options)
		_record_generation_result(interrupt_options, data, true)
		return data
	_interrupt_clear_progress_range(interrupt_options)
	_record_generation_result(interrupt_options, data, false)
	return data


static func generate_symmetric_square(
	radius: int,
	wall_probability: float,
	seed: int = 0,
	connect_method: int = 0,
	protected_floor: Array = [],
	distribution_id: int = 20,
	terminal_floor: Array = [],
	connect_toric: bool = false,
	custom_distribution = null,
	interrupt_options: Dictionary = {}
):
	assert(radius > 0)
	var size: int = radius * 2 + 1 
	var data = HexMapDataScript.square(size, connect_toric)
	_prepare_wall_generation_progress(interrupt_options, connect_method)
	var forced_floor = protected_floor.duplicate()
	for terminal in terminal_floor:
		forced_floor.append(terminal)
	var wall_result = generate_symmetric_toric_walls_interruptible(
		radius,
		wall_probability,
		seed,
		distribution_id,
		forced_floor,
		custom_distribution,
		interrupt_options
	)
	data.set_walls(wall_result["walls"])
	if wall_result["cancelled"]:
		_interrupt_clear_progress_range(interrupt_options)
		_record_generation_result(interrupt_options, data, true)
		return data
	if not terminal_floor.is_empty():
		restore_terminal_connectivity(data, terminal_floor, _connectivity_direction_seed(seed, 101))
	_restore_generated_connectivity(connect_method, data, [], seed, interrupt_options)
	if bool(interrupt_options.get("cancelled", false)):
		_interrupt_clear_progress_range(interrupt_options)
		_record_generation_result(interrupt_options, data, true)
		return data
	_interrupt_clear_progress_range(interrupt_options)
	_record_generation_result(interrupt_options, data, false)
	return data


static func generate_hexagon(
	radius: int,
	wall_probability: float,
	seed: int = 0,
	connect_method: int = 0,
	protected_floor: Array = [],
	interrupt_options: Dictionary = {}
):
	var data = HexMapDataScript.hexagon(radius)
	_prepare_wall_generation_progress(interrupt_options, connect_method)
	var wall_result = generate_random_walls_interruptible(
		data.cells,
		wall_probability,
		seed,
		protected_floor,
		interrupt_options
	)
	data.set_walls(wall_result["walls"])
	if wall_result["cancelled"]:
		_interrupt_clear_progress_range(interrupt_options)
		_record_generation_result(interrupt_options, data, true)
		return data
	_restore_generated_connectivity(connect_method, data, [], seed, interrupt_options)
	if bool(interrupt_options.get("cancelled", false)):
		_interrupt_clear_progress_range(interrupt_options)
		_record_generation_result(interrupt_options, data, true)
		return data
	_interrupt_clear_progress_range(interrupt_options)
	_record_generation_result(interrupt_options, data, false)
	return data


static func generate_symmetric_hexagon(
	radius: int,
	wall_probability: float,
	seed: int = 0,
	connect_method: int = 0,
	protected_floor: Array = [],
	distribution_id: int = 20,
	terminal_floor: Array = [],
	custom_distribution = null,
	interrupt_options: Dictionary = {}
):
	assert(radius > 0)
	var size: int = radius * 2 + 1

	_prepare_wall_generation_progress(interrupt_options, connect_method)
	var forced_floor = protected_floor.duplicate()
	for terminal in terminal_floor:
		forced_floor.append(terminal)

	var wall_result = generate_symmetric_toric_walls_interruptible(
		radius,
		wall_probability,
		seed,
		distribution_id,
		forced_floor,
		custom_distribution,
		interrupt_options
	)
	var all_walls = wall_result["walls"]

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
	if wall_result["cancelled"]:
		_interrupt_clear_progress_range(interrupt_options)
		_record_generation_result(interrupt_options, data, true)
		return data
	if not terminal_floor.is_empty():
		restore_terminal_connectivity(data, terminal_floor, _connectivity_direction_seed(seed, 101))
	_restore_generated_connectivity(connect_method, data, [], seed, interrupt_options)
	if bool(interrupt_options.get("cancelled", false)):
		_interrupt_clear_progress_range(interrupt_options)
		_record_generation_result(interrupt_options, data, true)
		return data
	_interrupt_clear_progress_range(interrupt_options)
	_record_generation_result(interrupt_options, data, false)
	return data


static func generate_random_walls(
	cells: Array,
	wall_probability: float,
	seed: int = 0,
	protected_floor: Array = []
) -> Array:
	return generate_random_walls_interruptible(
		cells,
		wall_probability,
		seed,
		protected_floor
	)["walls"]


static func generate_random_walls_interruptible(
	cells: Array,
	wall_probability: float,
	seed: int = 0,
	protected_floor: Array = [],
	interrupt_options: Dictionary = {}
) -> Dictionary:
	assert(wall_probability >= 0.0)
	assert(wall_probability <= 1.0)

	var protected_set = HexMapDataScript.make_set(protected_floor)
	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	var result: Array = []
	var total = cells.size()
	var chunk_size = _interrupt_chunk_size(interrupt_options)
	if _interrupt_update(interrupt_options, "random_walls", 0, total):
		return _wall_generation_result(result, true, 0, total)

	for index in range(cells.size()):
		var cell = cells[index]
		if protected_set.has(cell.key()):
			pass
		elif rng.randf() < wall_probability:
			result.append(cell)
		var steps = index + 1
		if steps % chunk_size == 0 or steps == total:
			if _interrupt_update(interrupt_options, "random_walls", steps, total):
				return _wall_generation_result(result, true, steps, total)
	_interrupt_update(interrupt_options, "random_walls", total, total)
	return _wall_generation_result(result, false, total, total)


static func generate_symmetric_toric_walls(
	radius: int,
	wall_probability: float,
	seed: int = 0,
	distribution_id: int = 20,
	protected_floor: Array = [],
	custom_distribution = null,
	interrupt_options: Dictionary = {}
) -> Array:
	return generate_symmetric_toric_walls_interruptible(
		radius,
		wall_probability,
		seed,
		distribution_id,
		protected_floor,
		custom_distribution,
		interrupt_options
	)["walls"]


static func generate_symmetric_toric_walls_interruptible(
	radius: int,
	wall_probability: float,
	seed: int = 0,
	distribution_id: int = 20,
	protected_floor: Array = [],
	custom_distribution = null,
	interrupt_options: Dictionary = {}
) -> Dictionary:
	assert(radius > 0)
	var size: int = radius * 2 + 1 
	assert(wall_probability >= 0.0)
	assert(wall_probability <= 1.0)

	var rule = HexToricMapSplitRuleScript.new(radius)
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	var total_cells = rule.canvas_cells().size()
	var total_steps = max(total_cells, 1)
	if _interrupt_update(interrupt_options, "symmetric_toric_start", 0, total_steps):
		return _wall_generation_result([], true, 0, total_steps)

	var state := {
		"rule": rule,
		"rng": rng,
		"walls": {},
		"visited": {},
		"protected": HexMapDataScript.make_set(_wrapped_points(protected_floor, size)),
		"distribution_id": distribution_id,
		"_progress_total": total_steps,
		"_last_reported_visited": 0,
	}
	if custom_distribution and custom_distribution.has_method("prob"):
		state["custom_dist"] = custom_distribution
	var outer = _draw_symmetric_outer_area(state, wall_probability)
	if _report_visited_progress(state, interrupt_options, "symmetric_toric_outer"):
		return _symmetric_wall_generation_result(state, size, true, int(interrupt_options.get("steps", 0)), total_steps)
	var border = _draw_symmetric_border(
		state,
		outer["edge_count"],
		outer["draw_node"],
		wall_probability
	)
	if _report_visited_progress(state, interrupt_options, "symmetric_toric_border"):
		return _symmetric_wall_generation_result(state, size, true, int(interrupt_options.get("steps", 0)), total_steps)
	if _draw_symmetric_inner_area(
		state,
		border["edge_count"],
		border["draw_node"],
		wall_probability,
		interrupt_options
	):
		return _symmetric_wall_generation_result(
			state,
			size,
			true,
			int(interrupt_options.get("steps", 0)),
			total_steps
		)

	return _symmetric_wall_generation_result(state, size, false, total_steps, total_steps)


static func _symmetric_wall_generation_result(
	state: Dictionary,
	size: int,
	cancelled: bool,
	steps: int,
	total_steps: int
) -> Dictionary:
	var data = HexMapDataScript.square(size, true)
	var result: Array = []
	var wall_set: Dictionary = state["walls"]
	for cell in data.cells:
		if wall_set.has(cell.key()):
			result.append(cell)
	return _wall_generation_result(result, cancelled, steps, total_steps)


static func _wall_generation_result(
	walls: Array,
	cancelled: bool,
	steps: int,
	total_steps: int
) -> Dictionary:
	var progress = 1.0 if total_steps <= 0 else float(steps) / float(total_steps)
	return {
		"walls": walls,
		"cancelled": cancelled,
		"progress": clampf(progress, 0.0, 1.0),
		"steps": steps,
		"total_steps": total_steps,
	}


static func _record_generation_result(
	interrupt_options: Dictionary,
	data,
	cancelled: bool
) -> void:
	if interrupt_options.is_empty():
		return
	interrupt_options["data"] = data
	interrupt_options["cancelled"] = cancelled
	if not interrupt_options.has("progress"):
		interrupt_options["progress"] = 0.0 if cancelled else 1.0


static func _interrupt_chunk_size(interrupt_options: Dictionary) -> int:
	if interrupt_options.has("chunk_size"):
		return max(1, int(interrupt_options["chunk_size"]))
	return 1


static func _interrupt_update(
	interrupt_options: Dictionary,
	phase: String,
	steps: int,
	total_steps: int
) -> bool:
	if interrupt_options.is_empty():
		return false

	var raw_progress = 1.0 if total_steps <= 0 else clampf(float(steps) / float(total_steps), 0.0, 1.0)
	var progress = _interrupt_mapped_progress(interrupt_options, raw_progress)
	var status := {
		"phase": phase,
		"steps": steps,
		"total_steps": total_steps,
		"progress": progress,
	}
	interrupt_options["phase"] = phase
	interrupt_options["steps"] = steps
	interrupt_options["total_steps"] = total_steps
	interrupt_options["progress"] = progress
	interrupt_options["cancelled"] = false

	var progress_callback = interrupt_options.get("progress_callback", Callable())
	if progress_callback is Callable and progress_callback.is_valid():
		progress_callback.call(status)

	var cancel_callback = interrupt_options.get("cancel_callback", Callable())
	if cancel_callback is Callable and cancel_callback.is_valid() and bool(cancel_callback.call(status)):
		interrupt_options["cancelled"] = true
		return true
	return false


static func _interrupt_mapped_progress(interrupt_options: Dictionary, raw_progress: float) -> float:
	if not interrupt_options.has(_INTERRUPT_PROGRESS_START_KEY):
		return raw_progress
	var start = float(interrupt_options.get(_INTERRUPT_PROGRESS_START_KEY, 0.0))
	var end = float(interrupt_options.get(_INTERRUPT_PROGRESS_END_KEY, 1.0))
	return clampf(start + (end - start) * raw_progress, 0.0, 1.0)


static func _interrupt_set_progress_range(interrupt_options: Dictionary, start: float, end: float) -> void:
	if interrupt_options.is_empty():
		return
	interrupt_options[_INTERRUPT_PROGRESS_START_KEY] = clampf(start, 0.0, 1.0)
	interrupt_options[_INTERRUPT_PROGRESS_END_KEY] = clampf(end, 0.0, 1.0)


static func _interrupt_clear_progress_range(interrupt_options: Dictionary) -> void:
	if interrupt_options.is_empty():
		return
	interrupt_options.erase(_INTERRUPT_PROGRESS_START_KEY)
	interrupt_options.erase(_INTERRUPT_PROGRESS_END_KEY)


static func _connectivity_restore_uses_progress(connect_method: int) -> bool:
	return connect_method == CONNECT_DENSE or connect_method == CONNECT_SPARSE


static func _prepare_wall_generation_progress(interrupt_options: Dictionary, connect_method: int) -> void:
	if _connectivity_restore_uses_progress(connect_method):
		_interrupt_set_progress_range(interrupt_options, 0.0, _CONNECTIVITY_PROGRESS_START)
	else:
		_interrupt_clear_progress_range(interrupt_options)


static func _restore_generated_connectivity(
	connect_method: int,
	data,
	terminals: Array,
	seed: int,
	interrupt_options: Dictionary
) -> Array:
	if _connectivity_restore_uses_progress(connect_method):
		_interrupt_set_progress_range(interrupt_options, _CONNECTIVITY_PROGRESS_START, 1.0)
		return restore_connectivity_by(connect_method, data, terminals, seed, interrupt_options)
	return restore_connectivity_by(connect_method, data, terminals, seed)


static func _restore_progress_state(interrupt_options: Dictionary, total_steps: int) -> Dictionary:
	return {
		"active": not interrupt_options.is_empty(),
		"chunk_size": _interrupt_chunk_size(interrupt_options),
		"interrupt_options": interrupt_options,
		"steps": 0,
		"total_steps": max(1, total_steps),
	}


static func _restore_progress_step(
	state: Dictionary,
	phase: String,
	step_count: int = 1,
	force: bool = false
) -> bool:
	if not bool(state["active"]):
		return false
	state["steps"] = min(int(state["total_steps"]), int(state["steps"]) + max(0, step_count))
	var steps = int(state["steps"])
	var chunk_size = int(state["chunk_size"])
	if not force and steps < int(state["total_steps"]) and steps % chunk_size != 0:
		return false
	return _interrupt_update(state["interrupt_options"], phase, steps, int(state["total_steps"]))


static func _restore_progress_finish(state: Dictionary, phase: String) -> bool:
	if not bool(state["active"]):
		return false
	state["steps"] = int(state["total_steps"])
	return _interrupt_update(state["interrupt_options"], phase, int(state["steps"]), int(state["total_steps"]))


static func _report_visited_progress(state: Dictionary, interrupt_options: Dictionary, phase: String = "symmetric_toric_inner") -> bool:
	if interrupt_options.is_empty():
		return false
	var visited_count = state["visited"].size()
	var total_steps = state["_progress_total"]
	var debounce = max(1, int(float(total_steps) / 50.0))
	var last_reported = state.get("_last_reported_visited", 0)
	if visited_count - last_reported < debounce and visited_count < total_steps:
		return false
	state["_last_reported_visited"] = visited_count
	var steps = min(visited_count, total_steps)
	return _interrupt_update(interrupt_options, phase, steps, total_steps)


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


static func _connectivity_direction_seed(seed: int, salt: int) -> int:
	var result = int(seed) + salt
	if result < 0:
		result = -result
	if result == 0:
		return salt
	return result


static func _connectivity_directions(direction_seed: int = 0) -> Array:
	var result = HexGridScript.directions()
	if direction_seed == 0:
		return result

	var seed_value = direction_seed
	if seed_value < 0:
		seed_value = -seed_value
	if seed_value == 0:
		return result

	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in range(result.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		if i == j:
			continue
		var tmp = result[i]
		result[i] = result[j]
		result[j] = tmp
	return result


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


static func restore_connectivity_by(
	method_type,
	data,
	terminals: Array = [],
	seed: int = 0,
	interrupt_options: Dictionary = {}
) -> Array:
	match method_type:
		CONNECT_DENSE:
			return restore_connectivity_dense(data, _connectivity_direction_seed(seed, 101), interrupt_options)
		CONNECT_SPARSE:
			return restore_connectivity_sparse(data, terminals, _connectivity_direction_seed(seed, 101), interrupt_options)
		CONNECT_NONE, _:
			return []


static func restore_terminal_connectivity(data, terminals: Array, direction_seed: int = 0) -> Array:
	var terminal_points = _normalized_terminals(data, terminals)
	var removed_walls: Array = []
	if terminal_points.is_empty():
		return removed_walls

	var direction_order = _connectivity_directions(direction_seed)
	_remove_walls_at_points(data, terminal_points, removed_walls)

	var max_iterations = data.cells.size() + data.walls.size() + terminal_points.size() + 1
	var iterations = 0
	while iterations < max_iterations:
		iterations += 1
		var floors = data.floor_cells()
		var connected = HexGridScript.connected_area(terminal_points[0], floors, data.cyclic_size, direction_order)
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
			data.cyclic_size,
			direction_order
		)
		if path.is_empty():
			return removed_walls

		var changed = _remove_walls_at_points(data, path, removed_walls)
		if not changed:
			return removed_walls

	return removed_walls


static func restore_connectivity(data, direction_seed: int = 0, interrupt_options: Dictionary = {}) -> Array:
	return restore_connectivity_dense(data, direction_seed, interrupt_options)


static func restore_connectivity_dense(data, direction_seed: int = 0, interrupt_options: Dictionary = {}) -> Array:
	var removed_walls: Array = []
	var progress_state = _restore_progress_state(
		interrupt_options,
		data.cells.size() * 10 + data.walls.size() * 2 + 1
	)
	var progress_active = bool(progress_state["active"])
	if data.cells.is_empty():
		_restore_progress_finish(progress_state, "restore_dense_carve")
		return removed_walls

	var direction_order = _connectivity_directions(direction_seed)
	var cells_set = HexMapDataScript.make_set(data.cells)
	var wall_set = data.wall_set()
	var floor_cells: Array = []
	var floor_set := {}
	for cell in data.cells:
		var key = cell.key()
		if wall_set.has(key):
			pass
		else:
			floor_cells.append(cell)
			floor_set[key] = cell
		if progress_active and _restore_progress_step(progress_state, "restore_dense_components"):
			data.set_walls(_points_from_set(wall_set))
			return removed_walls

	if floor_cells.is_empty():
		var first = data.cells[0]
		var first_key = first.key()
		if wall_set.has(first_key):
			removed_walls.append(first)
			wall_set.erase(first_key)
			data.set_walls(_points_from_set(wall_set))
		_restore_progress_finish(progress_state, "restore_dense_carve")
		return removed_walls

	var component_result = _dense_floor_components(
		floor_cells,
		floor_set,
		data.cyclic_size,
		direction_order,
		progress_state,
		progress_active
	)
	if bool(component_result.get("cancelled", false)):
		data.set_walls(_points_from_set(wall_set))
		return removed_walls
	var owner: Dictionary = component_result["owner"]
	var component_count: int = component_result["count"]
	if component_count <= 1:
		_restore_progress_finish(progress_state, "restore_dense_carve")
		return removed_walls

	var wall_cost := {}
	var parent := {}
	var search_buckets := {0: []}
	for floor in floor_cells:
		var key = floor.key()
		wall_cost[key] = 0
		parent[key] = ""
		search_buckets[0].append(floor)

	var current_cost := 0
	var max_cost = data.walls.size()
	while current_cost <= max_cost:
		if not search_buckets.has(current_cost):
			current_cost += 1
			continue

		var bucket: Array = search_buckets[current_cost]
		var idx := 0
		while idx < bucket.size():
			var current = bucket[idx]
			idx += 1
			var current_key = current.key()
			if int(wall_cost.get(current_key, -1)) != current_cost:
				continue

			for neighbor in HexGridScript.neighbors_in_directions(current, direction_order, data.cyclic_size):
				var neighbor_key = neighbor.key()
				if not cells_set.has(neighbor_key):
					continue
				if owner.has(neighbor_key):
					continue

				var next_cost = current_cost + (1 if wall_set.has(neighbor_key) else 0)
				owner[neighbor_key] = owner[current_key]
				wall_cost[neighbor_key] = next_cost
				parent[neighbor_key] = current_key
				if not search_buckets.has(next_cost):
					search_buckets[next_cost] = []
				search_buckets[next_cost].append(cells_set[neighbor_key])

			if progress_active and _restore_progress_step(progress_state, "restore_dense_search"):
				data.set_walls(_points_from_set(wall_set))
				return removed_walls

		current_cost += 1

	var bridge_buckets := {}
	var max_bridge_cost := -1
	var seen_edges := {}
	for cell in data.cells:
		var key = cell.key()
		if not owner.has(key):
			continue
		for neighbor in HexGridScript.neighbors_in_directions(cell, direction_order, data.cyclic_size):
			var neighbor_key = neighbor.key()
			if key == neighbor_key:
				continue
			if not cells_set.has(neighbor_key):
				continue
			if not owner.has(neighbor_key):
				continue

			var left_owner = int(owner[key])
			var right_owner = int(owner[neighbor_key])
			if left_owner == right_owner:
				continue

			var edge_key = _ordered_edge_key(key, neighbor_key)
			if seen_edges.has(edge_key):
				continue
			seen_edges[edge_key] = true

			var bridge_cost = int(wall_cost[key]) + int(wall_cost[neighbor_key])
			if not bridge_buckets.has(bridge_cost):
				bridge_buckets[bridge_cost] = []
			bridge_buckets[bridge_cost].append({
				"a": key,
				"b": neighbor_key,
				"owner_a": left_owner,
				"owner_b": right_owner,
			})
			if bridge_cost > max_bridge_cost:
				max_bridge_cost = bridge_cost

		if progress_active and _restore_progress_step(progress_state, "restore_dense_bridges"):
			data.set_walls(_points_from_set(wall_set))
			return removed_walls

	var component_parent := {}
	var component_size := {}
	for component_id in range(component_count):
		component_parent[component_id] = component_id
		component_size[component_id] = 1

	var selected_bridges: Array = []
	var selected_count := 0
	for bridge_cost in range(max_bridge_cost + 1):
		if not bridge_buckets.has(bridge_cost):
			continue
		for bridge in bridge_buckets[bridge_cost]:
			if not _dense_component_union(
				component_parent,
				component_size,
				int(bridge["owner_a"]),
				int(bridge["owner_b"])
			):
				continue
			selected_bridges.append(bridge)
			selected_count += 1
			if selected_count >= component_count - 1:
				break
			if progress_active and _restore_progress_step(progress_state, "restore_dense_bridges"):
				data.set_walls(_points_from_set(wall_set))
				return removed_walls
		if selected_count >= component_count - 1:
			break

	var processed_paths := {}
	for bridge in selected_bridges:
		if _dense_remove_parent_path(
			bridge["a"],
			parent,
			wall_set,
			processed_paths,
			removed_walls,
			progress_state,
			progress_active
		):
			data.set_walls(_points_from_set(wall_set))
			return removed_walls
		if _dense_remove_parent_path(
			bridge["b"],
			parent,
			wall_set,
			processed_paths,
			removed_walls,
			progress_state,
			progress_active
		):
			data.set_walls(_points_from_set(wall_set))
			return removed_walls

	data.set_walls(_points_from_set(wall_set))
	_restore_progress_finish(progress_state, "restore_dense_carve")
	return removed_walls


static func _dense_floor_components(
	floor_cells: Array,
	floor_set: Dictionary,
	cyclic_size: int,
	direction_order: Array,
	progress_state: Dictionary,
	progress_active: bool
) -> Dictionary:
	var owner := {}
	var component_id := 0
	for floor in floor_cells:
		var key = floor.key()
		if owner.has(key):
			continue

		var open: Array = [floor]
		var idx := 0
		owner[key] = component_id
		while idx < open.size():
			var current = open[idx]
			idx += 1
			if progress_active and _restore_progress_step(progress_state, "restore_dense_components"):
				return {
					"owner": owner,
					"count": component_id,
					"cancelled": true,
				}
			for neighbor in HexGridScript.neighbors_in_directions(current, direction_order, cyclic_size):
				var neighbor_key = neighbor.key()
				if not floor_set.has(neighbor_key):
					continue
				if owner.has(neighbor_key):
					continue
				owner[neighbor_key] = component_id
				open.append(floor_set[neighbor_key])

		component_id += 1

	return {
		"owner": owner,
		"count": component_id,
		"cancelled": false,
	}


static func _dense_remove_parent_path(
	start_key: String,
	parent: Dictionary,
	wall_set: Dictionary,
	processed_paths: Dictionary,
	removed_walls: Array,
	progress_state: Dictionary,
	progress_active: bool
) -> bool:
	var current_key = start_key
	while current_key != "":
		if processed_paths.has(current_key):
			return false
		processed_paths[current_key] = true
		if wall_set.has(current_key):
			removed_walls.append(wall_set[current_key])
			wall_set.erase(current_key)
		if progress_active and _restore_progress_step(progress_state, "restore_dense_carve"):
			return true
		current_key = parent.get(current_key, "")
	return false


static func _dense_component_find(parent: Dictionary, component_id: int) -> int:
	var current = component_id
	while int(parent[current]) != current:
		current = int(parent[current])

	var root = current
	current = component_id
	while int(parent[current]) != current:
		var next = int(parent[current])
		parent[current] = root
		current = next
	return root


static func _dense_component_union(parent: Dictionary, size: Dictionary, left: int, right: int) -> bool:
	var left_root = _dense_component_find(parent, left)
	var right_root = _dense_component_find(parent, right)
	if left_root == right_root:
		return false

	if int(size[left_root]) < int(size[right_root]):
		var tmp = left_root
		left_root = right_root
		right_root = tmp

	parent[right_root] = left_root
	size[left_root] = int(size[left_root]) + int(size[right_root])
	return true


static func _ordered_edge_key(left: String, right: String) -> String:
	if left < right:
		return "%s|%s" % [left, right]
	return "%s|%s" % [right, left]


static func _points_from_set(point_set: Dictionary) -> Array:
	var result: Array = []
	for key in point_set:
		result.append(point_set[key])
	return result


static func restore_connectivity_sparse(
	data,
	terminals: Array = [],
	direction_seed: int = 0,
	interrupt_options: Dictionary = {}
) -> Array:
	var removed_walls: Array = []
	var progress_state = _restore_progress_state(
		interrupt_options,
		data.cells.size() * 12 + data.walls.size() * 4 + 1
	)
	var progress_active = bool(progress_state["active"])
	if data.cells.is_empty():
		_restore_progress_finish(progress_state, "restore_sparse_expand")
		return removed_walls

	var direction_order = _connectivity_directions(direction_seed)
	var wall_set = data.wall_set()
	var cells_set = HexMapDataScript.make_set(data.cells)
	var floor_cells = data.floor_cells()
	if progress_active and _restore_progress_step(progress_state, "restore_sparse_floor", data.cells.size(), true):
		data.set_walls(_points_from_set(wall_set))
		return removed_walls

	if floor_cells.is_empty():
		removed_walls.append(data.cells[0])
		data.set_walls(HexMapDataScript.points_except(data.walls, [data.cells[0]]))
		_restore_progress_finish(progress_state, "restore_sparse_expand")
		return removed_walls

	if terminals.is_empty():
		terminals = [floor_cells[0]]

	# Phase 1: terminal BFS through floors
	var dist := {}
	for t in terminals:
		var tk = t.key()
		if wall_set.has(tk): continue
		if not cells_set.has(tk): continue
		if dist.has(tk): continue
		dist[tk] = 0

	var frontier: Array = []
	for key in dist:
		frontier.append(cells_set[key])

	var fi = 0
	while fi < frontier.size():
		var cur = frontier[fi]; fi += 1
		var d = dist[cur.key()] + 1
		for n in HexGridScript.neighbors_in_directions(cur, direction_order, data.cyclic_size):
			var nk = n.key()
			if not cells_set.has(nk): continue
			if wall_set.has(nk): continue
			if dist.has(nk): continue
			dist[nk] = d
			frontier.append(cells_set[nk])
		if progress_active and _restore_progress_step(progress_state, "restore_sparse_floor"):
			data.set_walls(_points_from_set(wall_set))
			return removed_walls

	# Phase 2: build wall buckets by terminal distance
	var wall_buckets := {}
	var current_dist := 0
	for key in dist:
		var cell = cells_set[key]
		var d = dist[key]
		for n in HexGridScript.neighbors_in_directions(cell, direction_order, data.cyclic_size):
			var nk = n.key()
			if not cells_set.has(nk): continue
			if not wall_set.has(nk): continue
			if not wall_buckets.has(d):
				wall_buckets[d] = {}
			if wall_buckets[d].has(nk): continue
			wall_buckets[d][nk] = wall_set[nk]
			if d > current_dist:
				current_dist = d
		if progress_active and _restore_progress_step(progress_state, "restore_sparse_buckets"):
			data.set_walls(_points_from_set(wall_set))
			return removed_walls

	var dead_end := {}


	# Phase 3: per-level combined BFS, highest terminal distance first
	while true:
		while current_dist >= 0:
			if wall_buckets.has(current_dist) and wall_buckets[current_dist].size() > 0:
				break
			current_dist -= 1
		if current_dist < 0:
			break

		# Collect live entry walls at this distance
		var entry_keys: Array = []
		var stale_keys: Array = []
		for wk in wall_buckets[current_dist]:
			if not wall_set.has(wk):
				stale_keys.append(wk)
				continue
			if dead_end.has(wk): continue
			entry_keys.append(wk)
			if progress_active and _restore_progress_step(progress_state, "restore_sparse_search"):
				data.set_walls(_points_from_set(wall_set))
				return removed_walls
		for wk in stale_keys:
			wall_buckets[current_dist].erase(wk)

		if entry_keys.is_empty():
			current_dist -= 1
			continue

		# Single combined BFS from all entry walls at this distance
		var result = _flood_bfs(
			entry_keys,
			dist,
			wall_set,
			cells_set,
			dead_end,
			data.cyclic_size,
			direction_order,
			progress_state,
			progress_active
		)
		if bool(result.get("cancelled", false)):
			data.set_walls(_points_from_set(wall_set))
			return removed_walls
		var best_goal = result["goal"]
		var explored_map: Dictionary = result["explored_map"]
		var bfs_parent: Dictionary = result["parent"]

		if best_goal == null:
			for key in explored_map:
				dead_end[key] = true
			current_dist -= 1
			continue

		# Trace entry wall from the best goal
		var entry_wall_key = best_goal.key()
		while bfs_parent.get(entry_wall_key, "") != "":
			entry_wall_key = bfs_parent[entry_wall_key]
		var entry_wall = cells_set[entry_wall_key]

		# Trace path from best goal to entry wall; collect walls on the path
		var useful := {entry_wall_key: true}
		var ck = best_goal.key()
		useful[ck] = true
		var pk = bfs_parent.get(ck, "")
		while pk != "":
			if useful.has(pk): break
			useful[pk] = true
			pk = bfs_parent.get(pk, "")

		# Remove walls and expand dist
		for key in explored_map:
			var cell = cells_set[key]
			dead_end.erase(key)
			if wall_set.has(key) and useful.has(key):
				wall_set.erase(key)
				removed_walls.append(cell)
			if progress_active and _restore_progress_step(progress_state, "restore_sparse_search"):
				data.set_walls(_points_from_set(wall_set))
				return removed_walls

		# Expand dist from entry wall through floors and newly-removed walls
		var expand_frontier: Array = [entry_wall]
		var expand_idx = 0
		while expand_idx < expand_frontier.size():
			var cur = expand_frontier[expand_idx]; expand_idx += 1
			var cur_key = cur.key()

			if dist.has(cur_key): continue
			if not cells_set.has(cur_key): continue
			if wall_set.has(cur_key): continue
			if not explored_map.has(cur_key): continue

			var min_d = -1
			for n in HexGridScript.neighbors_in_directions(cur, direction_order, data.cyclic_size):
				var nk = n.key()
				if dist.has(nk):
					var d = dist[nk]
					if min_d == -1 or d < min_d:
						min_d = d
			if min_d < 0: continue
			dist[cur_key] = min_d + 1

			for n in HexGridScript.neighbors_in_directions(cur, direction_order, data.cyclic_size):
				var nk = n.key()
				if not cells_set.has(nk): continue
				if dist.has(nk): continue
				if wall_set.has(nk):
					var nd = dist[cur_key]
					if not wall_buckets.has(nd):
						wall_buckets[nd] = {}
					if not wall_buckets[nd].has(nk):
						wall_buckets[nd][nk] = wall_set[nk]
						if nd > current_dist:
							current_dist = nd
					continue
				expand_frontier.append(cells_set[nk])
			if progress_active and _restore_progress_step(progress_state, "restore_sparse_expand"):
				data.set_walls(_points_from_set(wall_set))
				return removed_walls

	var new_walls: Array = []
	for key in wall_set:
		new_walls.append(wall_set[key])
	data.set_walls(new_walls)
	_restore_progress_finish(progress_state, "restore_sparse_expand")

	return removed_walls

static func _flood_bfs(
	entry_wall_keys: Array,
	dist: Dictionary,
	wall_set: Dictionary,
	cells_set: Dictionary,
	dead_end: Dictionary,
	cyclic_size: int,
	direction_order: Array,
	progress_state: Dictionary,
	progress_active: bool
) -> Dictionary:
	var current_level: Array = []
	var queued := {}
	var parent := {}
	var explored_map := {}

	for wk in entry_wall_keys:
		current_level.append(cells_set[wk])
		queued[wk] = true
		parent[wk] = ""

	var best_goal = null
	var best_neighbor_dist = -2

	while not current_level.is_empty():
		var next_level: Array = []
		for current in current_level:
			var ck = current.key()

			if dist.has(ck): continue
			if dead_end.has(ck): continue
			if not cells_set.has(ck): continue
			if explored_map.has(ck): continue
			explored_map[ck] = true
			if progress_active and _restore_progress_step(progress_state, "restore_sparse_search"):
				return {
					"goal": null,
					"explored_map": explored_map,
					"parent": parent,
					"cancelled": true,
				}

			# Floor cell (not wall) → unreachable floor = goal
			if not wall_set.has(ck):
				var neighbor_dist = -1
				for n in HexGridScript.neighbors_in_directions(current, direction_order, cyclic_size):
					var nk = n.key()
					if dist.has(nk):
						if dist[nk] > neighbor_dist:
							neighbor_dist = dist[nk]
				if neighbor_dist > best_neighbor_dist:
					best_goal = current
					best_neighbor_dist = neighbor_dist
				continue

			# Wall cell → expand
			for n in HexGridScript.neighbors_in_directions(current, direction_order, cyclic_size):
				var nk = n.key()
				if not cells_set.has(nk): continue
				if dist.has(nk): continue
				if dead_end.has(nk): continue
				if queued.has(nk): continue
				parent[nk] = ck
				queued[nk] = true
				next_level.append(cells_set[nk])

		if best_goal:
			return {
				"goal": best_goal,
				"explored_map": explored_map,
				"parent": parent,
				"cancelled": false,
			}

		current_level = next_level

	return {
		"goal": null,
		"explored_map": explored_map,
		"parent": parent,
		"cancelled": false,
	}


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
	var rule = state["rule"]
	var centered = _draw_symmetric_area_center(state, flat_left, origin, wall_probability)
	if (rule.map_unit_radius - 1) % 3 == 2:
		return _draw_symmetric_phase2_outer_boundary(state, flat_left, origin, centered, wall_probability)
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
	var edge_count = _sum_int(draw_counts) * (1 if arc_size == 2 else 2)

	for side in range(3):
		wave_directions.append(step_directions[(side + 2) % 3].subtract(step_directions[side]))
	for side in range(3):
		reference_directions.append([
			step_directions[side].negated(),
			wave_directions[side].negated().subtract(step_directions[side]).subtract(step_directions[side]),
			wave_directions[side].negated().subtract(step_directions[side]),
		])

	for _wave_index in range(int(rule.map_unit_radius / 3)):
		arc_size += 3
		for side in range(3):
			draw_node[side] = draw_node[side].add(wave_directions[side])
			var pen = draw_node[side]
			var density = (float(draw_counts[side]) + 1.0 + wall_probability) / float(arc_size)
			draw_counts[side] = _draw_from_prob(state, pen, 1.0 - density)
			_draw_from_prob(
				state,
				pen.add(reference_directions[side][2]),
				wall_probability * (1.0 - ((float(draw_counts[side]) + density) / 2.0))
			)

		edge_count += _sum_int(draw_counts)

		for side in range(3):
			var pen = draw_node[side]
			for _index in range(1, arc_size - 1):
				pen = pen.add(step_directions[side])
				draw_counts[side] += _draw_arc_point(state, pen, reference_directions[side])

		for side in range(3):
			var pen = draw_node[side].add(step_directions[side].scaled(arc_size - 1))
			draw_counts[side] += _over_draw_arc_point(state, pen, reference_directions[side])
			pen = pen.add(step_directions[side])

	return {
		"edge_count": edge_count,
		"draw_node": draw_node,
	}


static func _draw_symmetric_phase2_outer_boundary(
	state: Dictionary,
	flat_left: bool,
	origin,
	centered: Dictionary,
	wall_probability: float
) -> Dictionary:
	var rule = state["rule"]
	var from_center = _draw_symmetric_area_from_center(
		state,
		flat_left,
		origin,
		centered["draw_node"].duplicate(),
		centered["draw_counts"].duplicate(),
		wall_probability
	)
	var draw_node = _outer_boundary_nodes(flat_left, origin, rule.map_unit_radius)
	return {
		"edge_count": from_center["edge_count"],
		"draw_node": draw_node,
	}


static func _outer_boundary_nodes(flat_left: bool, origin, map_unit_radius: int) -> Array:
	var forward = _r_axis() if flat_left else _q_axis()
	return [
		origin,
		origin.add(forward.scaled(map_unit_radius - 1)),
		origin.add(_s_axis().negated().scaled(map_unit_radius - 1)),
	]


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
	wall_probability: float,
	interrupt_options: Dictionary = {},
	progress_start: int = 0,
	total_steps: int = 1
) -> bool:
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
			if _report_visited_progress(state, interrupt_options):
				return true
		if _report_visited_progress(state, interrupt_options):
			return true

	var denominator = float(int((rule.map_unit_radius + 2) / 3) * 6) + 4.0
	var density = (float(edge_count) + wall_probability) / denominator
	_draw_from_prob(
		state,
		draw_node[0].add(draw_node[1]).add(draw_node[2]).divided(3),
		1.0 - density
	)
	if _report_visited_progress(state, interrupt_options):
		return true
	if _draw_symmetric_canvas_completion(state, wall_probability, interrupt_options):
		return true
	return _report_visited_progress(state, interrupt_options, "symmetric_toric_complete")


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
	var prob: float
	if state.has("custom_dist"):
		prob = state["custom_dist"].prob(ref_conditions)
	else:
		prob = HexRandomizerScript.prob_from_distribution(ref_conditions, state["distribution_id"])
	return _draw_from_prob(state, pen, prob)


static func _over_draw_from_distribution(state: Dictionary, pen, reference_points: Array) -> int:
	var wall_set: Dictionary = state["walls"]
	var ref_conditions: Array = []
	for point in reference_points:
		var reference = _reference_position(state, point)
		ref_conditions.append(wall_set.has(reference.key()))
	var prob: float
	if state.has("custom_dist"):
		prob = state["custom_dist"].prob(ref_conditions)
	else:
		prob = HexRandomizerScript.prob_from_distribution(ref_conditions, state["distribution_id"])
	return _over_draw_from_prob(state, pen, prob)


static func _draw_from_prob(state: Dictionary, point, draw_probability: float) -> int:
	var pen = _reference_position(state, point)
	var protected_set: Dictionary = state["protected"]
	var wall_set: Dictionary = state["walls"]
	var key = pen.key()
	if state.has("visited"):
		state["visited"][key] = pen
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
	if state.has("visited"):
		state["visited"][key] = pen
	wall_set.erase(key)
	if protected_set.has(key):
		return 0

	var rng: RandomNumberGenerator = state["rng"]
	if rng.randf() < draw_probability:
		wall_set[key] = pen
		return 1
	return 0


static func _draw_symmetric_canvas_completion(state: Dictionary, wall_probability: float, interrupt_options: Dictionary = {}) -> bool:
	var rule = state["rule"]
	var visited: Dictionary = state.get("visited", {})
	for cell in rule.canvas_cells():
		if visited.has(cell.key()):
			continue
		_draw_from_prob(state, cell, wall_probability)
		if _report_visited_progress(state, interrupt_options, "symmetric_toric_completion"):
			return true
	return false


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
