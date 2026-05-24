class_name HexMapGenerator
extends RefCounted

const HexGridScript = preload("res://addons/hex_map_kit/core/hex_grid.gd")
const HexMapDataScript = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexRandomizerScript = preload("res://addons/hex_map_kit/core/hex_randomizer.gd")
const HexToricCoordinateScript = preload("res://addons/hex_map_kit/core/hex_toric_coordinate.gd")
const HexToricMapSplitRuleScript = preload("res://addons/hex_map_kit/core/hex_toric_map_split_rule.gd")
const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexDisjointSetScript = preload("res://addons/hex_map_kit/core/hex_disjoint_set.gd")


static func generate_rectangle(
	width: int,
	height: int,
	wall_probability: float,
	seed: int = 0,
	ensure_connected: bool = false,
	toric: bool = false,
	protected_floor: Array = [],
	interrupt_options: Dictionary = {}
):
	var data = HexMapDataScript.rectangle(width, height, toric)
	var wall_result = generate_random_walls_interruptible(
		data.cells,
		wall_probability,
		seed,
		protected_floor,
		interrupt_options
	)
	data.set_walls(wall_result["walls"])
	if wall_result["cancelled"]:
		_record_generation_result(interrupt_options, data, true)
		return data
	if ensure_connected:
		restore_connectivity_flood(data)
	_record_generation_result(interrupt_options, data, false)
	return data


static func generate_toric_square(
	size: int,
	wall_probability: float,
	seed: int = 0,
	ensure_connected: bool = false,
	protected_floor: Array = [],
	interrupt_options: Dictionary = {}
):
	var data = HexMapDataScript.square(size, true)
	var wall_result = generate_random_walls_interruptible(
		data.cells,
		wall_probability,
		seed,
		protected_floor,
		interrupt_options
	)
	data.set_walls(wall_result["walls"])
	if wall_result["cancelled"]:
		_record_generation_result(interrupt_options, data, true)
		return data
	if ensure_connected:
		restore_connectivity_flood(data)
	_record_generation_result(interrupt_options, data, false)
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
	custom_distribution = null,
	interrupt_options: Dictionary = {}
):
	assert(radius > 0)
	var size: int = radius * 2 + 1 
	var data = HexMapDataScript.square(size, connect_toric)
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
		_record_generation_result(interrupt_options, data, true)
		return data
	if not terminal_floor.is_empty():
		restore_terminal_connectivity(data, terminal_floor)
	if ensure_connected:
		restore_connectivity_flood(data)
	_record_generation_result(interrupt_options, data, false)
	return data


static func generate_hexagon(
	radius: int,
	wall_probability: float,
	seed: int = 0,
	ensure_connected: bool = false,
	protected_floor: Array = [],
	interrupt_options: Dictionary = {}
):
	var data = HexMapDataScript.hexagon(radius)
	var wall_result = generate_random_walls_interruptible(
		data.cells,
		wall_probability,
		seed,
		protected_floor,
		interrupt_options
	)
	data.set_walls(wall_result["walls"])
	if wall_result["cancelled"]:
		_record_generation_result(interrupt_options, data, true)
		return data
	if ensure_connected:
		restore_connectivity_flood(data)
	_record_generation_result(interrupt_options, data, false)
	return data


static func generate_symmetric_hexagon(
	radius: int,
	wall_probability: float,
	seed: int = 0,
	ensure_connected: bool = false,
	protected_floor: Array = [],
	distribution_id: int = 20,
	terminal_floor: Array = [],
	custom_distribution = null,
	interrupt_options: Dictionary = {}
):
	assert(radius > 0)
	var size: int = radius * 2 + 1

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
		_record_generation_result(interrupt_options, data, true)
		return data
	if not terminal_floor.is_empty():
		restore_terminal_connectivity(data, terminal_floor)
	if ensure_connected:
		restore_connectivity_flood(data)
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

	var progress = 1.0 if total_steps <= 0 else clampf(float(steps) / float(total_steps), 0.0, 1.0)
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

	var dsu = HexDisjointSetScript.new()
	var cells_set = HexMapDataScript.make_set(data.cells)
	var wall_set = data.wall_set()
	var floor_cells = data.floor_cells()

	var visited = {}
	for cell in floor_cells:
		var key = cell.key()
		if visited.has(key):
			continue
		var component = HexGridScript.connected_area(cell, floor_cells, data.cyclic_size)
		dsu.add_component(component)
		for c in component:
			visited[c.key()] = true

	if dsu.root_count() <= 1:
		return removed_walls

	var max_iterations = data.cells.size() + data.walls.size() + 1
	var iterations = 0
	while iterations < max_iterations and dsu.root_count() > 1:
		iterations += 1

		var root0 = dsu.find(floor_cells[0].key())

		var starts: Array = []
		for cell in data.cells:
			var key = cell.key()
			if wall_set.has(key):
				continue
			if not dsu.has(key):
				continue
			if dsu.find(key) == root0:
				starts.append(cell)

		var path = HexGridScript.shortest_path_with_tiebreak(
			starts,
			data.cells,
			data.cyclic_size,
			dsu,
			root0
		)
		if path.is_empty():
			return removed_walls

		var changed = false
		for point in path:
			var key = point.key()
			if wall_set.has(key):
				removed_walls.append(wall_set[key])
				wall_set.erase(key)
				changed = true
			dsu.make_set(point)
			for neighbor in HexGridScript.neighbors(point, data.cyclic_size):
				var nkey = neighbor.key()
				if wall_set.has(nkey):
					continue
				if not cells_set.has(nkey):
					continue
				dsu.make_set(neighbor)
				dsu.union(point, neighbor)

		if not changed:
			return removed_walls

		var new_walls: Array = []
		for key in wall_set:
			new_walls.append(wall_set[key])
		data.set_walls(new_walls)

	return removed_walls


static func restore_connectivity_expand(data, terminals: Array = []) -> Array:
	var removed_walls: Array = []
	if data.cells.is_empty():
		return removed_walls

	var wall_set = data.wall_set()
	var cells_set = HexMapDataScript.make_set(data.cells)
	var floor_cells = data.floor_cells()

	if floor_cells.is_empty():
		removed_walls.append(data.cells[0])
		data.set_walls(HexMapDataScript.points_except(data.walls, [data.cells[0]]))
		return removed_walls

	var dist := {}

	if terminals.is_empty():
		terminals = [floor_cells[0]]

	# Phase 1: terminal BFS through floors only
	for t in terminals:
		var tk = t.key()
		if wall_set.has(tk): continue
		if not cells_set.has(tk): continue
		if dist.has(tk): continue
		dist[tk] = 0

	var frontier: Array = []
	for key in dist:
		frontier.append(cells_set[key])

	var front_idx = 0
	while front_idx < frontier.size():
		var current = frontier[front_idx]
		front_idx += 1
		var d = dist[current.key()] + 1
		for neighbor in HexGridScript.neighbors(current, data.cyclic_size):
			var nk = neighbor.key()
			if not cells_set.has(nk): continue
			if wall_set.has(nk): continue
			if dist.has(nk): continue
			dist[nk] = d
			frontier.append(cells_set[nk])

	# Phase 2: iteratively connect unreachable floors via shortest paths
	while true:
		var unreachable: Array = []
		for f in data.floor_cells():
			if not dist.has(f.key()):
				unreachable.append(f)

		if unreachable.is_empty():
			break

		var path = _bfs_to_unreachable(dist, unreachable, cells_set, wall_set, data.cyclic_size)
		if path.is_empty():
			break

		for point in path:
			var pk = point.key()
			if wall_set.has(pk):
				removed_walls.append(wall_set[pk])
				wall_set.erase(pk)

		_expand_dist_from_path(dist, path, cells_set, wall_set, data.cyclic_size)

	var new_walls: Array = []
	for key in wall_set:
		new_walls.append(wall_set[key])
	data.set_walls(new_walls)

	return removed_walls


static func _bfs_to_unreachable(
	dist: Dictionary,
	unreachable: Array,
	cells_set: Dictionary,
	wall_set: Dictionary,
	cyclic_size: int
) -> Array:
	var goal_set = HexMapDataScript.make_set(unreachable)
	var current_level: Array = []
	var closed := {}
	var parent := {}
	var queued := {}

	# Starts: all reachable cells (dist keys)
	for key in dist:
		current_level.append(cells_set[key])
		queued[key] = true
		parent[key] = ""

	var best_goal = null
	var best_dist_score = -2

	while not current_level.is_empty():
		var next_level: Array = []
		for current in current_level:
			var ck = current.key()

			if closed.has(ck): continue
			closed[ck] = current

			if goal_set.has(ck):
				var neighbor_score = -1
				for neighbor in HexGridScript.neighbors(current, cyclic_size):
					var nk = neighbor.key()
					if dist.has(nk):
						if dist[nk] > neighbor_score:
							neighbor_score = dist[nk]
				if neighbor_score > best_dist_score:
					best_goal = current
					best_dist_score = neighbor_score
				continue

			for neighbor in HexGridScript.neighbors(current, cyclic_size):
				var nk = neighbor.key()
				if not cells_set.has(nk): continue
				if closed.has(nk): continue
				if queued.has(nk): continue
				parent[nk] = ck
				queued[nk] = true
				next_level.append(cells_set[nk])

		if best_goal:
			return _rebuild_path_inline(best_goal.key(), parent, closed)

		current_level = next_level

	if best_goal:
		return _rebuild_path_inline(best_goal.key(), parent, closed)
	return []


static func _expand_dist_from_path(
	dist: Dictionary,
	path: Array,
	cells_set: Dictionary,
	wall_set: Dictionary,
	cyclic_size: int
) -> void:
	var new_seeds: Array = []
	for point in path:
		var pk = point.key()
		if dist.has(pk): continue
		if not cells_set.has(pk): continue
		if wall_set.has(pk): continue

		var min_d = -1
		for neighbor in HexGridScript.neighbors(point, cyclic_size):
			var nk = neighbor.key()
			if dist.has(nk):
				var d = dist[nk]
				if min_d == -1 or d < min_d:
					min_d = d

		if min_d < 0: continue
		dist[pk] = min_d + 1
		new_seeds.append(point)

	var idx = 0
	while idx < new_seeds.size():
		var current = new_seeds[idx]
		idx += 1
		var nd = dist[current.key()] + 1
		for neighbor in HexGridScript.neighbors(current, cyclic_size):
			var nk = neighbor.key()
			if not cells_set.has(nk): continue
			if wall_set.has(nk): continue
			if dist.has(nk): continue
			dist[nk] = nd
			new_seeds.append(cells_set[nk])


static func _rebuild_path_inline(goal_key: String, parent: Dictionary, closed: Dictionary) -> Array:
	var keys: Array = []
	var current_key = goal_key
	while current_key != "":
		keys.push_front(current_key)
		current_key = parent[current_key]

	var result: Array = []
	for key in keys:
		result.append(closed[key])
	return result


static func restore_connectivity_flood(data, terminals: Array = []) -> Array:
	var removed_walls: Array = []
	if data.cells.is_empty():
		return removed_walls

	var wall_set = data.wall_set()
	var cells_set = HexMapDataScript.make_set(data.cells)
	var floor_cells = data.floor_cells()

	if floor_cells.is_empty():
		removed_walls.append(data.cells[0])
		data.set_walls(HexMapDataScript.points_except(data.walls, [data.cells[0]]))
		return removed_walls

	if terminals.is_empty():
		terminals = [floor_cells[0]]

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
		for n in HexGridScript.neighbors(cur, data.cyclic_size):
			var nk = n.key()
			if not cells_set.has(nk): continue
			if wall_set.has(nk): continue
			if dist.has(nk): continue
			dist[nk] = d
			frontier.append(cells_set[nk])

	var wall_buckets := {}
	var current_dist := 0
	for key in dist:
		var cell = cells_set[key]
		var d = dist[key]
		for n in HexGridScript.neighbors(cell, data.cyclic_size):
			var nk = n.key()
			if not cells_set.has(nk): continue
			if not wall_set.has(nk): continue
			if not wall_buckets.has(d):
				wall_buckets[d] = {}
			if wall_buckets[d].has(nk): continue
			wall_buckets[d][nk] = wall_set[nk]
			if d > current_dist:
				current_dist = d

	var dead_end := {}

	while true:
		while current_dist >= 0:
			if wall_buckets.has(current_dist) and wall_buckets[current_dist].size() > 0:
				break
			current_dist -= 1
		if current_dist < 0:
			break

		var bucket: Dictionary = wall_buckets[current_dist]
		var wk = bucket.keys()[0]
		var wall_cell = bucket[wk]
		bucket.erase(wk)

		if not wall_set.has(wk): continue
		if dead_end.has(wk): continue

		var result = _explore_behind_wall(wall_cell, current_dist, dist, wall_set, cells_set, dead_end, data.cyclic_size)
		var new_floors: Array = result["floors"]
		var explored_map: Dictionary = result["explored_map"]

		if new_floors.is_empty():
			for key in explored_map:
				dead_end[key] = true
			continue

		# Backward BFS from new floors toward the entry wall (shorter explored_map distance)
		var useful := {}
		var useful_frontier: Array = []
		for f in new_floors:
			var fk = f.key()
			if not useful.has(fk):
				useful[fk] = true
				useful_frontier.append(f)
		var useful_idx = 0
		while useful_idx < useful_frontier.size():
			var cur = useful_frontier[useful_idx]; useful_idx += 1
			var cur_dist = explored_map[cur.key()]
			for n in HexGridScript.neighbors(cur, data.cyclic_size):
				var nk = n.key()
				if useful.has(nk): continue
				if not explored_map.has(nk): continue
				if explored_map[nk] >= cur_dist: continue
				useful[nk] = true
				useful_frontier.append(cells_set[nk])

		for key in explored_map:
			var cell = cells_set[key]
			dead_end.erase(key)
			if wall_set.has(key) and useful.has(key):
				wall_set.erase(key)
				removed_walls.append(cell)
			if not dist.has(key):
				dist[key] = current_dist + explored_map[key]
				for n in HexGridScript.neighbors(cell, data.cyclic_size):
					var nk = n.key()
					if not cells_set.has(nk): continue
					if dist.has(nk): continue
					if dead_end.has(nk): continue
					if wall_set.has(nk):
						if not wall_buckets.has(dist[key]):
							wall_buckets[dist[key]] = {}
						if not wall_buckets[dist[key]].has(nk):
							wall_buckets[dist[key]][nk] = wall_set[nk]
							if dist[key] > current_dist:
								current_dist = dist[key]

	var new_walls: Array = []
	for key in wall_set:
		new_walls.append(wall_set[key])
	data.set_walls(new_walls)

	return removed_walls


static func _explore_behind_wall(
	wall_cell,
	start_dist: int,
	dist: Dictionary,
	wall_set: Dictionary,
	cells_set: Dictionary,
	dead_end: Dictionary,
	cyclic_size: int
) -> Dictionary:
	var frontier: Array = [{"cell": wall_cell, "term_dist": 1}]
	var new_floors: Array = []
	var explored_map := {}
	var idx = 0

	while idx < frontier.size():
		var entry = frontier[idx]; idx += 1
		var current = entry["cell"]
		var td = entry["term_dist"]
		var ck = current.key()

		if dist.has(ck): continue
		if dead_end.has(ck): continue
		if not cells_set.has(ck): continue
		if explored_map.has(ck): continue
		explored_map[ck] = td

		if wall_set.has(ck):
			for n in HexGridScript.neighbors(current, cyclic_size):
				var nk = n.key()
				if not cells_set.has(nk): continue
				if dist.has(nk): continue
				if dead_end.has(nk): continue
				if explored_map.has(nk): continue
				frontier.append({"cell": cells_set[nk], "term_dist": td + 1})
		else:
			new_floors.append(current)
			for n in HexGridScript.neighbors(current, cyclic_size):
				var nk = n.key()
				if not cells_set.has(nk): continue
				if dist.has(nk): continue
				if dead_end.has(nk): continue
				if explored_map.has(nk): continue
				frontier.append({"cell": cells_set[nk], "term_dist": td + 1})

	return {"floors": new_floors, "explored_map": explored_map}


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
