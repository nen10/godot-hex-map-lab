extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexRandomizer = preload("res://addons/hex_map_kit/core/hex_randomizer.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexMapDebug = preload("res://addons/hex_map_kit/core/hex_map_debug.gd")
const HexToricMapSplitRule = preload("res://addons/hex_map_kit/core/hex_toric_map_split_rule.gd")
const HexGrid = preload("res://addons/hex_map_kit/core/hex_grid.gd")

class ZeroDistribution:
	var calls := 0

	func prob(_ref_conditions: Array) -> float:
		calls += 1
		return 0.0

class InterruptRecorder:
	var progress_events: Array = []
	var cancel_at_step := -1
	var cancel_phase_prefix := ""

	func progress(status: Dictionary) -> void:
		progress_events.append(status.duplicate())

	func cancel(status: Dictionary) -> bool:
		if cancel_phase_prefix != "" and str(status["phase"]).begins_with(cancel_phase_prefix):
			return true
		return cancel_at_step >= 0 and int(status["steps"]) >= cancel_at_step

var _failures: Array[String] = []


func _init() -> void:
	_run()


func _run() -> void:
	_test_distribution_probabilities_match_unity_tables()
	_test_rectangle_map_data()
	_test_hexagon_map_data()
	_test_random_walls_are_seeded_and_protect_floor_cells()
	_test_interruptible_random_walls_reports_progress_and_cancel()
	_test_connection_detection_uses_wall_set()
	_test_restore_connectivity_removes_blocking_walls()
	_test_toric_connection_detection_wraps_edges()
	_test_restore_connectivity_uses_toric_shortcut()
	_test_restore_connectivity_by_dense_restores_line()
	_test_restore_connectivity_by_sparse_restores_line()
	_test_restore_connectivity_by_none_preserves_walls()
	_test_dense_restore_reports_progress_and_cancel()
	_test_sparse_restore_reports_progress_and_cancel()
	_test_generation_connectivity_restore_reports_progress_range()
	_test_generation_connectivity_restore_can_cancel()
	_test_generation_none_progress_uses_full_wall_range()
	_test_generate_rectangle_can_restore_connectivity()
	_test_generate_toric_square_can_restore_connectivity()
	_test_interruptible_shape_generation_matches_regular_shapes()
	_test_interruptible_shape_generation_cancels_each_shape()
	_test_symmetric_toric_walls_are_seeded_and_mapped_to_split_canvas()
	_test_symmetric_toric_generation_handles_radius_multiple_of_three()
	_test_phase2_edge_area_runs_from_center_for_radius_multiple_of_three()
	_test_symmetric_generation_matches_unity_source_sequence()
	_test_symmetric_square_torus_and_hex_shape_outputs_share_source_walls()
	_test_minimum_radius_symmetric_generation_uses_unified_flow()
	_test_restore_terminal_connectivity_connects_only_requested_terminals()
	_test_generate_symmetric_toric_square_can_restore_terminal_connectivity()
	_test_generate_hexagon_can_restore_connectivity()
	_test_debug_ascii_renders_wall_layout()
	_test_debug_summary_reports_counts()
	_test_dense_restores_line_with_single_wall()
	_test_dense_uses_toric_shortcut()
	_test_dense_matches_restore_count_on_y_shape()
	_test_dense_chooses_remote_short_bridge()
	_test_dense_restores_symmetric_toric_square()
	_test_sparse_direction_seed_changes_bridge_choice()
	_test_restore_direction_seed_is_accepted_by_supported_modes()

	if _failures.is_empty():
		print("test_hex_map_generation.gd: all tests passed")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_false(value: bool, message: String) -> void:
	if value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _assert_keys_eq(actual: Array, expected: Array, message: String) -> void:
	var actual_keys = _keys(actual)
	var expected_keys = _keys(expected)
	if actual_keys != expected_keys:
		_failures.append("%s: expected %s, got %s" % [message, str(expected_keys), str(actual_keys)])


func _keys(points: Array) -> Array:
	var result: Array = []
	for point in points:
		result.append(point.key())
	result.sort()
	return result


func _keys_in_order(points: Array) -> Array:
	var result: Array = []
	for point in points:
		result.append(point.key())
	return result


func _line_cells(length: int) -> Array:
	var result: Array = []
	for q in range(length):
		result.append(HexVector.q_axis().scaled(q))
	return result


func _rect_cell(q: int, r: int):
	return HexVector.apply_basis(q, 0, r)


func _ring_bridge_tie_data():
	var cells: Array = [HexVector.zero()]
	cells.append_array(HexGrid.l1_ring(1))
	cells.append_array(HexGrid.l1_ring(2))
	return HexMapData.from_cells(
		cells,
		HexGrid.l1_ring(1)
	)


func _seed_for_first_direction(direction_key: String) -> int:
	for seed in range(1, 200):
		var directions = HexMapGenerator._connectivity_directions(seed)
		if directions[0].key() == direction_key:
			return seed
	_failures.append("no connectivity seed found for first direction %s" % direction_key)
	return 0


func _complete_interrupt_options() -> Dictionary:
	var recorder = InterruptRecorder.new()
	return {
		"chunk_size": 2,
		"progress_callback": Callable(recorder, "progress"),
		"_recorder": recorder,
	}


func _cancel_interrupt_options(cancel_at_step: int) -> Dictionary:
	var recorder = InterruptRecorder.new()
	recorder.cancel_at_step = cancel_at_step
	return {
		"chunk_size": 1,
		"progress_callback": Callable(recorder, "progress"),
		"cancel_callback": Callable(recorder, "cancel"),
		"_recorder": recorder,
	}


func _phase_cancel_interrupt_options(phase_prefix: String) -> Dictionary:
	var recorder = InterruptRecorder.new()
	recorder.cancel_phase_prefix = phase_prefix
	return {
		"chunk_size": 1,
		"progress_callback": Callable(recorder, "progress"),
		"cancel_callback": Callable(recorder, "cancel"),
		"_recorder": recorder,
	}


func _assert_interruptible_matches_regular(message: String, expected, actual, options: Dictionary) -> void:
	_assert_eq(actual.cyclic_size, expected.cyclic_size, "%s interruptible cyclic size matches regular generation" % message)
	_assert_keys_eq(actual.cells, expected.cells, "%s interruptible cells match regular generation" % message)
	_assert_keys_eq(actual.walls, expected.walls, "%s interruptible walls match regular generation" % message)
	_assert_false(options.get("cancelled", false), "%s interruptible options report completion" % message)
	_assert_eq(options.get("progress", -1.0), 1.0, "%s interruptible options finish at full progress" % message)
	_assert_progress_events_monotonic(options["_recorder"].progress_events, "%s interruptible progress" % message)


func _assert_shape_can_cancel(message: String, data, max_wall_count: int, options: Dictionary) -> void:
	_assert_true(options.get("cancelled", false), "%s interruptible options report cancellation" % message)
	_assert_true(data.walls.size() < max_wall_count, "%s interruptible generation stops with partial walls" % message)
	_assert_eq(options.get("data", null), data, "%s interruptible options store returned data" % message)
	_assert_progress_events_monotonic(options["_recorder"].progress_events, "%s cancellation progress" % message)


func _assert_progress_events_monotonic(events: Array, message: String) -> void:
	_assert_true(events.size() > 0, "%s emits progress events" % message)
	var previous = -1.0
	for event in events:
		var progress = float(event["progress"])
		_assert_true(progress >= previous, "%s progress is monotonic" % message)
		previous = progress


func _has_progress_phase(events: Array, phase_prefix: String) -> bool:
	for event in events:
		if str(event["phase"]).begins_with(phase_prefix):
			return true
	return false


func _has_progress_at_or_above(events: Array, threshold: float) -> bool:
	for event in events:
		if float(event["progress"]) >= threshold:
			return true
	return false


func _symmetric_draw_state(radius: int, seed: int, protected_floor: Array = []) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	var size = radius * 2 + 1
	return {
		"rule": HexToricMapSplitRule.new(radius),
		"rng": rng,
		"distribution_id": 20,
		"protected": HexMapData.make_set(HexMapGenerator._wrapped_points(protected_floor, size)),
		"walls": {},
		"visited": {},
	}


func _manual_draw_symmetric_edge_area_in_state(
	state: Dictionary,
	flat_left: bool,
	origin,
	wall_probability: float
) -> Dictionary:
	var result = HexMapGenerator._draw_symmetric_edge_area(
		state,
		flat_left,
		origin,
		wall_probability
	)
	result["wall_keys"] = _keys(state["walls"].values())
	return result


func _manual_draw_symmetric_edge_area(
	radius: int,
	flat_left: bool,
	origin,
	seed: int,
	wall_probability: float
) -> Dictionary:
	var state = _symmetric_draw_state(radius, seed)
	return _manual_draw_symmetric_edge_area_in_state(
		state,
		flat_left,
		origin,
		wall_probability
	)


func _manual_draw_threads_symmetric_toric_walls(
	radius: int,
	wall_probability: float,
	seed: int,
	protected_floor: Array = []
) -> Array:
	var state = _symmetric_draw_state(radius, seed, protected_floor)
	var rule = state["rule"]
	var left = _manual_draw_symmetric_edge_area_in_state(
		state,
		true,
		rule.split_canvas_origins[0],
		wall_probability
	)
	var right = _manual_draw_symmetric_edge_area_in_state(
		state,
		false,
		rule.split_canvas_origins[7],
		wall_probability
	)
	var draw_node: Array = []
	draw_node.append_array(left["draw_node"])
	draw_node.append_array(right["draw_node"])
	var border = HexMapGenerator._draw_symmetric_border(
		state,
		int(left["edge_count"]) + int(right["edge_count"]),
		draw_node,
		wall_probability
	)
	HexMapGenerator._draw_symmetric_inner_area(
		state,
		int(border["edge_count"]),
		border["draw_node"],
		wall_probability
	)

	var data = HexMapData.square(radius * 2 + 1, true)
	var wall_set: Dictionary = state["walls"]
	var result: Array = []
	for cell in data.cells:
		if wall_set.has(cell.key()):
			result.append(cell)
	return result


func _test_distribution_probabilities_match_unity_tables() -> void:
	_assert_eq(
		HexRandomizer.prob_from_distribution([true, false, true], 20),
		0.875,
		"distribution id 20 uses Unity 2x2x2 table"
	)
	_assert_eq(
		HexRandomizer.prob_from_distribution([false, true], 70),
		0.375,
		"distribution id 70 uses Unity 2x2 table"
	)
	_assert_eq(
		HexRandomizer.prob_from_distribution([true], 50),
		0.25,
		"distribution id 50 uses Unity 2 table"
	)


func _test_rectangle_map_data() -> void:
	var data = HexMapData.rectangle(3, 2)
	_assert_eq(data.cells.size(), 6, "rectangle contains width * height cells")
	_assert_eq(data.cyclic_size, 0, "non-toric rectangle has no cyclic size")
	_assert_keys_eq(
		data.cells,
		[
			HexVector.apply_basis(0, 0, 0),
			HexVector.apply_basis(1, 0, 0),
			HexVector.apply_basis(2, 0, 0),
			HexVector.apply_basis(0, 0, 1),
			HexVector.apply_basis(1, 0, 1),
			HexVector.apply_basis(2, 0, 1),
		],
		"rectangle cells are axial q/r positions"
	)

	var toric_data = HexMapData.rectangle(3, 3, true)
	_assert_eq(toric_data.cyclic_size, 3, "toric square stores cyclic size")


func _test_hexagon_map_data() -> void:
	var data = HexMapData.hexagon(2)

	_assert_eq(data.cells.size(), 19, "radius 2 hexagon has 1 + 3r(r + 1) cells")
	_assert_eq(data.cyclic_size, 0, "hexagon map is non-toric")
	for direction in HexVector.directions():
		_assert_true(
			data.has_cell(direction.scaled(2)),
			"hexagon includes every radius corner"
		)


func _test_random_walls_are_seeded_and_protect_floor_cells() -> void:
	var cells = HexMapData.rectangle(4, 4).cells
	var protected = [HexVector.zero()]
	var walls_a = HexMapGenerator.generate_random_walls(cells, 0.45, 12345, protected)
	var walls_b = HexMapGenerator.generate_random_walls(cells, 0.45, 12345, protected)

	_assert_keys_eq(walls_a, walls_b, "same seed produces same wall set")
	_assert_false(HexMapData.has_key(walls_a, HexVector.zero().key()), "protected floor is not walled")
	_assert_eq(
		HexMapGenerator.generate_random_walls(cells, 0.0, 9).size(),
		0,
		"zero probability creates no walls"
	)
	_assert_eq(
		HexMapGenerator.generate_random_walls(cells, 1.0, 9, protected).size(),
		cells.size() - protected.size(),
		"one probability walls every unprotected cell"
	)


func _test_interruptible_random_walls_reports_progress_and_cancel() -> void:
	var cells = HexMapData.rectangle(4, 1).cells
	var recorder = InterruptRecorder.new()
	recorder.cancel_at_step = 2
	var options := {
		"chunk_size": 1,
		"progress_callback": Callable(recorder, "progress"),
		"cancel_callback": Callable(recorder, "cancel"),
	}
	var result = HexMapGenerator.generate_random_walls_interruptible(cells, 1.0, 77, [], options)

	_assert_true(result["cancelled"], "interruptible random walls reports cancelled result")
	_assert_true(options["cancelled"], "interruptible random walls records cancelled option state")
	_assert_eq(result["walls"].size(), 2, "interruptible random walls stops after requested step")
	_assert_eq(options["steps"], 2, "interruptible random walls records cancelled step")
	_assert_true(recorder.progress_events.size() >= 3, "interruptible random walls emits start and chunk progress")
	_assert_eq(recorder.progress_events[0]["progress"], 0.0, "interruptible random walls starts at zero progress")
	_assert_eq(recorder.progress_events[recorder.progress_events.size() - 1]["steps"], 2, "interruptible random walls last progress matches cancellation")


func _test_connection_detection_uses_wall_set() -> void:
	var cells = _line_cells(3)
	var data = HexMapData.from_cells(cells, [HexVector.q_axis()])

	_assert_false(HexMapGenerator.is_floor_connected(data), "middle wall splits a three-cell line")
	_assert_eq(HexMapGenerator.connected_components(data).size(), 2, "split line has two components")


func _test_restore_connectivity_removes_blocking_walls() -> void:
	var cells = _line_cells(3)
	var data = HexMapData.from_cells(cells, [HexVector.q_axis()])
	var removed = HexMapGenerator.restore_connectivity(data)

	_assert_keys_eq(removed, [HexVector.q_axis()], "connectivity recovery removes the bridge wall")
	_assert_eq(data.walls.size(), 0, "bridge wall is carved from map data")
	_assert_true(HexMapGenerator.is_floor_connected(data), "restored line is connected")


func _test_toric_connection_detection_wraps_edges() -> void:
	var data = HexMapData.square(3, true)
	var left = HexVector.zero()
	var right = HexVector.q_axis().scaled(2)
	data.walls = HexMapData.points_except(data.cells, [left, right])

	_assert_true(HexMapGenerator.is_floor_connected(data), "toric map connects q edge to wrapped q edge")


func _test_restore_connectivity_uses_toric_shortcut() -> void:
	var data = HexMapData.square(4, true)
	var start = HexVector.zero()
	var goal = HexVector.q_axis().scaled(2)
	data.walls = HexMapData.points_except(data.cells, [start, goal])

	var removed = HexMapGenerator.restore_connectivity(data)

	_assert_eq(removed.size(), 1, "toric shortcut only needs one wall removal")
	_assert_true(HexMapGenerator.is_floor_connected(data), "toric shortcut restores floor connectivity")


func _test_restore_connectivity_by_dense_restores_line() -> void:
	var cells = _line_cells(3)
	var bridge = HexVector.q_axis()
	var data = HexMapData.from_cells(cells, [bridge])

	var removed = HexMapGenerator.restore_connectivity_by(HexMapGenerator.CONNECT_DENSE, data)

	_assert_keys_eq(removed, [bridge], "dense method removes the single bridge wall")
	_assert_true(HexMapGenerator.is_floor_connected(data), "dense method restores line connectivity")


func _test_restore_connectivity_by_sparse_restores_line() -> void:
	var cells = _line_cells(3)
	var bridge = HexVector.q_axis()
	var data = HexMapData.from_cells(cells, [bridge])

	var removed = HexMapGenerator.restore_connectivity_by(HexMapGenerator.CONNECT_SPARSE, data)

	_assert_keys_eq(removed, [bridge], "sparse method removes the single bridge wall")
	_assert_true(HexMapGenerator.is_floor_connected(data), "sparse method restores line connectivity")


func _test_restore_connectivity_by_none_preserves_walls() -> void:
	var cells = _line_cells(3)
	var bridge = HexVector.q_axis()
	var data = HexMapData.from_cells(cells, [bridge])

	var removed = HexMapGenerator.restore_connectivity_by(HexMapGenerator.CONNECT_NONE, data)

	_assert_eq(removed.size(), 0, "none method removes no walls")
	_assert_true(data.has_wall(bridge), "none method leaves bridge wall intact")
	_assert_false(HexMapGenerator.is_floor_connected(data), "none method does not restore connectivity")


func _test_dense_restore_reports_progress_and_cancel() -> void:
	var bridge = HexVector.q_axis()
	var complete_data = HexMapData.from_cells(_line_cells(3), [bridge])
	var complete_options = _complete_interrupt_options()
	var complete_removed = HexMapGenerator.restore_connectivity_dense(complete_data, 0, complete_options)

	_assert_keys_eq(complete_removed, [bridge], "dense restore removes bridge with progress options")
	_assert_true(HexMapGenerator.is_floor_connected(complete_data), "dense restore completes with progress options")
	_assert_eq(complete_options.get("progress", -1.0), 1.0, "dense restore progress finishes at full progress")
	_assert_true(
		_has_progress_phase(complete_options["_recorder"].progress_events, "restore_dense_"),
		"dense restore emits restore progress phase"
	)
	_assert_progress_events_monotonic(complete_options["_recorder"].progress_events, "dense restore progress")

	var cancel_data = HexMapData.from_cells(_line_cells(3), [bridge])
	var cancel_options = _phase_cancel_interrupt_options("restore_dense_")
	HexMapGenerator.restore_connectivity_dense(cancel_data, 0, cancel_options)

	_assert_true(cancel_options.get("cancelled", false), "dense restore can cancel from restore progress")
	_assert_true(cancel_data.has_wall(bridge), "dense restore cancel keeps partial wall data")


func _test_sparse_restore_reports_progress_and_cancel() -> void:
	var bridge = HexVector.q_axis()
	var complete_data = HexMapData.from_cells(_line_cells(3), [bridge])
	var complete_options = _complete_interrupt_options()
	var complete_removed = HexMapGenerator.restore_connectivity_sparse(complete_data, [], 0, complete_options)

	_assert_keys_eq(complete_removed, [bridge], "sparse restore removes bridge with progress options")
	_assert_true(HexMapGenerator.is_floor_connected(complete_data), "sparse restore completes with progress options")
	_assert_eq(complete_options.get("progress", -1.0), 1.0, "sparse restore progress finishes at full progress")
	_assert_true(
		_has_progress_phase(complete_options["_recorder"].progress_events, "restore_sparse_"),
		"sparse restore emits restore progress phase"
	)
	_assert_progress_events_monotonic(complete_options["_recorder"].progress_events, "sparse restore progress")

	var cancel_data = HexMapData.from_cells(_line_cells(3), [bridge])
	var cancel_options = _phase_cancel_interrupt_options("restore_sparse_")
	HexMapGenerator.restore_connectivity_sparse(cancel_data, [], 0, cancel_options)

	_assert_true(cancel_options.get("cancelled", false), "sparse restore can cancel from restore progress")
	_assert_true(cancel_data.has_wall(bridge), "sparse restore cancel keeps partial wall data")


func _test_generation_connectivity_restore_reports_progress_range() -> void:
	var protected = [HexVector.zero(), HexVector.q_axis().scaled(2)]

	for method in [HexMapGenerator.CONNECT_DENSE, HexMapGenerator.CONNECT_SPARSE]:
		var options = _complete_interrupt_options()
		var data = HexMapGenerator.generate_rectangle(
			3,
			1,
			1.0,
			912,
			method,
			false,
			protected,
			options
		)

		_assert_true(HexMapGenerator.is_floor_connected(data), "connectivity generation method %d connects protected endpoints" % method)
		_assert_eq(options.get("progress", -1.0), 1.0, "connectivity generation method %d finishes at full progress" % method)
		_assert_true(
			_has_progress_at_or_above(options["_recorder"].progress_events, 0.35),
			"connectivity generation method %d reports restore progress range" % method
		)
		_assert_progress_events_monotonic(options["_recorder"].progress_events, "connectivity generation method %d progress" % method)


func _test_generation_connectivity_restore_can_cancel() -> void:
	var bridge = HexVector.q_axis()
	var options = _phase_cancel_interrupt_options("restore_dense_")
	var data = HexMapGenerator.generate_rectangle(
		3,
		1,
		1.0,
		913,
		HexMapGenerator.CONNECT_DENSE,
		false,
		[HexVector.zero(), HexVector.q_axis().scaled(2)],
		options
	)

	_assert_true(options.get("cancelled", false), "generation can cancel during connectivity restore")
	_assert_eq(options.get("data", null), data, "generation cancel stores partial data")
	_assert_true(data.has_wall(bridge), "generation restore cancel keeps partial bridge wall")
	_assert_false(HexMapGenerator.is_floor_connected(data), "generation restore cancel returns disconnected partial data")


func _test_generation_none_progress_uses_full_wall_range() -> void:
	var options = _complete_interrupt_options()
	var data = HexMapGenerator.generate_rectangle(
		3,
		1,
		1.0,
		914,
		HexMapGenerator.CONNECT_NONE,
		false,
		[HexVector.zero(), HexVector.q_axis().scaled(2)],
		options
	)

	_assert_eq(options.get("progress", -1.0), 1.0, "none generation wall progress reaches full progress")
	_assert_true(not _has_progress_phase(options["_recorder"].progress_events, "restore_"), "none generation emits no restore progress")
	_assert_false(HexMapGenerator.is_floor_connected(data), "none generation does not restore connectivity")


func _test_generate_rectangle_can_restore_connectivity() -> void:
	var data = HexMapGenerator.generate_rectangle(
		6,
		6,
		0.45,
		321,
		HexMapGenerator.CONNECT_DENSE,
		false,
		[HexVector.zero()]
	)

	_assert_false(HexMapData.has_key(data.walls, HexVector.zero().key()), "protected cell remains floor")
	_assert_true(HexMapGenerator.is_floor_connected(data), "generated rectangle can be connectivity-restored")


func _test_generate_toric_square_can_restore_connectivity() -> void:
	var data = HexMapGenerator.generate_toric_square(
		6,
		0.45,
		987,
		HexMapGenerator.CONNECT_DENSE,
		[HexVector.zero()]
	)

	_assert_eq(data.cyclic_size, 6, "generated toric square stores cyclic size")
	_assert_false(HexMapData.has_key(data.walls, HexVector.zero().key()), "protected toric cell remains floor")
	_assert_true(HexMapGenerator.is_floor_connected(data), "generated toric square can be restored")


func _test_interruptible_shape_generation_matches_regular_shapes() -> void:
	var rectangle_options = _complete_interrupt_options()
	_assert_interruptible_matches_regular(
		"rectangle",
		HexMapGenerator.generate_rectangle(
			5,
			4,
			0.45,
			111,
			HexMapGenerator.CONNECT_DENSE,
			false,
			[HexVector.zero()]
		),
		HexMapGenerator.generate_rectangle(
			5,
			4,
			0.45,
			111,
			HexMapGenerator.CONNECT_DENSE,
			false,
			[HexVector.zero()],
			rectangle_options
		),
		rectangle_options
	)
	var toric_options = _complete_interrupt_options()
	_assert_interruptible_matches_regular(
		"toric square",
		HexMapGenerator.generate_toric_square(
			5,
			0.45,
			112,
			HexMapGenerator.CONNECT_DENSE,
			[HexVector.zero()]
		),
		HexMapGenerator.generate_toric_square(
			5,
			0.45,
			112,
			HexMapGenerator.CONNECT_DENSE,
			[HexVector.zero()],
			toric_options
		),
		toric_options
	)
	var hexagon_options = _complete_interrupt_options()
	_assert_interruptible_matches_regular(
		"hexagon",
		HexMapGenerator.generate_hexagon(
			3,
			0.45,
			113,
			HexMapGenerator.CONNECT_DENSE,
			[HexVector.zero()]
		),
		HexMapGenerator.generate_hexagon(
			3,
			0.45,
			113,
			HexMapGenerator.CONNECT_DENSE,
			[HexVector.zero()],
			hexagon_options
		),
		hexagon_options
	)
	var symmetric_square_options = _complete_interrupt_options()
	_assert_interruptible_matches_regular(
		"symmetric square",
		HexMapGenerator.generate_symmetric_square(
			3,
			0.45,
			114,
			HexMapGenerator.CONNECT_DENSE,
			[HexVector.zero()]
		),
		HexMapGenerator.generate_symmetric_square(
			3,
			0.45,
			114,
			HexMapGenerator.CONNECT_DENSE,
			[HexVector.zero()],
			20,
			[],
			false,
			null,
			symmetric_square_options
		),
		symmetric_square_options
	)
	var symmetric_toric_options = _complete_interrupt_options()
	_assert_interruptible_matches_regular(
		"symmetric toric square",
		HexMapGenerator.generate_symmetric_square(
			3,
			0.45,
			115,
			HexMapGenerator.CONNECT_DENSE,
			[HexVector.zero()],
			20,
			[],
			true
		),
		HexMapGenerator.generate_symmetric_square(
			3,
			0.45,
			115,
			HexMapGenerator.CONNECT_DENSE,
			[HexVector.zero()],
			20,
			[],
			true,
			null,
			symmetric_toric_options
		),
		symmetric_toric_options
	)
	var symmetric_hex_options = _complete_interrupt_options()
	_assert_interruptible_matches_regular(
		"symmetric hexagon",
		HexMapGenerator.generate_symmetric_hexagon(
			3,
			0.45,
			116,
			HexMapGenerator.CONNECT_DENSE,
			[HexVector.zero()]
		),
		HexMapGenerator.generate_symmetric_hexagon(
			3,
			0.45,
			116,
			HexMapGenerator.CONNECT_DENSE,
			[HexVector.zero()],
			20,
			[],
			null,
			symmetric_hex_options
		),
		symmetric_hex_options
	)


func _test_interruptible_shape_generation_cancels_each_shape() -> void:
	var rectangle_options = _cancel_interrupt_options(2)
	_assert_shape_can_cancel(
		"rectangle",
		HexMapGenerator.generate_rectangle(
			5,
			4,
			1.0,
			211,
			HexMapGenerator.CONNECT_DENSE,
			false,
			[HexVector.zero()],
			rectangle_options
		),
		20,
		rectangle_options
	)
	var toric_options = _cancel_interrupt_options(2)
	_assert_shape_can_cancel(
		"toric square",
		HexMapGenerator.generate_toric_square(
			5,
			1.0,
			212,
			HexMapGenerator.CONNECT_DENSE,
			[HexVector.zero()],
			toric_options
		),
		25,
		toric_options
	)
	var hexagon_options = _cancel_interrupt_options(2)
	_assert_shape_can_cancel(
		"hexagon",
		HexMapGenerator.generate_hexagon(
			3,
			1.0,
			213,
			HexMapGenerator.CONNECT_DENSE,
			[HexVector.zero()],
			hexagon_options
		),
		37,
		hexagon_options
	)
	var symmetric_square_options = _cancel_interrupt_options(1)
	_assert_shape_can_cancel(
		"symmetric square",
		HexMapGenerator.generate_symmetric_square(
			3,
			1.0,
			214,
			HexMapGenerator.CONNECT_DENSE,
			[HexVector.zero()],
			20,
			[],
			false,
			null,
			symmetric_square_options
		),
		49,
		symmetric_square_options
	)
	var symmetric_toric_options = _cancel_interrupt_options(1)
	_assert_shape_can_cancel(
		"symmetric toric square",
		HexMapGenerator.generate_symmetric_square(
			3,
			1.0,
			215,
			HexMapGenerator.CONNECT_DENSE,
			[HexVector.zero()],
			20,
			[],
			true,
			null,
			symmetric_toric_options
		),
		49,
		symmetric_toric_options
	)
	var symmetric_hex_options = _cancel_interrupt_options(1)
	_assert_shape_can_cancel(
		"symmetric hexagon",
		HexMapGenerator.generate_symmetric_hexagon(
			3,
			1.0,
			216,
			HexMapGenerator.CONNECT_DENSE,
			[HexVector.zero()],
			20,
			[],
			null,
			symmetric_hex_options
		),
		37,
		symmetric_hex_options
	)


func _test_symmetric_toric_walls_are_seeded_and_mapped_to_split_canvas() -> void:
	var protected = [HexVector.zero()]
	for size in [7, 9, 11, 13]:
		var radius = int((size - 1) / 2)
		var seed = 1200 + size
		var walls_a = HexMapGenerator.generate_symmetric_toric_walls(radius, 0.45, seed, 20, protected)
		var walls_b = HexMapGenerator.generate_symmetric_toric_walls(radius, 0.45, seed, 20, protected)
		var walls_c = HexMapGenerator.generate_symmetric_toric_walls(radius, 0.45, seed + 1, 20, protected)
		var data = HexMapData.square(size, true)
		var split_rule = HexToricMapSplitRule.new(radius)
		var split_counts := {}

		_assert_keys_eq(walls_a, walls_b, "symmetric toric walls are seeded for N=%d" % size)
		_assert_true(_keys(walls_a) != _keys(walls_c), "different seed changes symmetric toric walls for N=%d" % size)
		_assert_false(HexMapData.has_key(walls_a, HexVector.zero().key()), "symmetric protected cell remains floor for N=%d" % size)
		_assert_true(walls_a.size() > 0, "symmetric toric generation creates walls for N=%d" % size)
		_assert_true(walls_a.size() < data.cells.size(), "symmetric toric generation leaves floors for N=%d" % size)
		for wall in walls_a:
			_assert_true(data.has_cell(wall), "symmetric wall is inside toric square for N=%d" % size)
			var split_index = split_rule.split_index_for(wall)
			_assert_true(split_index >= 0, "symmetric wall maps to a 9-split region for N=%d" % size)
			split_counts[split_index] = split_counts.get(split_index, 0) + 1

		_assert_true(split_counts.size() >= 2, "symmetric generation maps walls across split regions for N=%d" % size)


func _test_symmetric_toric_generation_handles_radius_multiple_of_three() -> void:
	var protected = [HexVector.zero()]
	for radius in [3, 6]:
		var size = radius * 2 + 1
		var seed = 3300 + radius
		var walls_a = HexMapGenerator.generate_symmetric_toric_walls(radius, 0.52, seed, 20, protected)
		var walls_b = HexMapGenerator.generate_symmetric_toric_walls(radius, 0.52, seed, 20, protected)
		var square = HexMapData.square(size, true)
		var split_rule = HexToricMapSplitRule.new(radius)
		var split_counts := {}

		_assert_keys_eq(walls_a, walls_b, "radius %d symmetric toric walls remain seeded" % radius)
		_assert_false(HexMapData.has_key(walls_a, HexVector.zero().key()), "radius %d protected floor remains floor" % radius)
		_assert_true(walls_a.size() > 0, "radius %d symmetric toric generation creates walls" % radius)
		_assert_true(walls_a.size() < square.cells.size(), "radius %d symmetric toric generation leaves floors" % radius)
		for wall in walls_a:
			_assert_true(square.has_cell(wall), "radius %d symmetric wall stays inside toric canvas" % radius)
			var split_index = split_rule.split_index_for(wall)
			_assert_true(split_index >= 0, "radius %d symmetric wall maps to a 9-split region" % radius)
			split_counts[split_index] = split_counts.get(split_index, 0) + 1
		_assert_true(split_counts.size() >= 2, "radius %d symmetric walls distribute across split regions" % radius)

		var connected = HexMapGenerator.generate_symmetric_square(
			radius,
			0.52,
			seed,
			HexMapGenerator.CONNECT_DENSE,
			protected,
			20,
			[],
			true
		)
		_assert_eq(connected.cyclic_size, size, "radius %d connected symmetric square stores cyclic size" % radius)
		_assert_false(connected.has_wall(HexVector.zero()), "radius %d connected symmetric square keeps protected floor" % radius)
		_assert_true(
			HexMapGenerator.is_floor_connected(connected),
			"radius %d symmetric toric square is connected after restoration" % radius
		)


func _test_phase2_edge_area_runs_from_center_for_radius_multiple_of_three() -> void:
	var wall_probability = 0.45
	for radius in [3, 6]:
		var rule = HexToricMapSplitRule.new(radius)
		for edge in [
			{"flat_left": true, "origin": rule.split_canvas_origins[0], "name": "left"},
			{"flat_left": false, "origin": rule.split_canvas_origins[7], "name": "right"},
		]:
			var seed = 4400 + radius + (0 if edge["flat_left"] else 100)
			var actual_state = _symmetric_draw_state(radius, seed)
			var actual = HexMapGenerator._draw_symmetric_edge_area(
				actual_state,
				edge["flat_left"],
				edge["origin"],
				wall_probability
			)
			var expected = _manual_draw_symmetric_edge_area(
				radius,
				edge["flat_left"],
				edge["origin"],
				seed,
				wall_probability
			)
			_assert_eq(
				actual["edge_count"],
				expected["edge_count"],
				"radius %d phase2 %s edge uses DrawAreaFromCenter edge count" % [radius, edge["name"]]
			)
			_assert_eq(
				_keys_in_order(actual["draw_node"]),
				_keys_in_order(expected["draw_node"]),
				"radius %d phase2 %s edge uses DrawAreaFromCenter draw nodes" % [radius, edge["name"]]
			)
			_assert_eq(
				_keys(actual_state["walls"].values()),
				expected["wall_keys"],
				"radius %d phase2 %s edge uses DrawAreaFromCenter wall set" % [radius, edge["name"]]
			)


func _test_symmetric_generation_matches_unity_source_sequence() -> void:
	var protected = [HexVector.zero()]
	for scenario in [
		{"radius": 1, "seed": 1401, "wall_probability": 0.45},
		{"radius": 2, "seed": 1402, "wall_probability": 0.45},
		{"radius": 3, "seed": 888, "wall_probability": 1.0},
		{"radius": 4, "seed": 1404, "wall_probability": 0.45},
		{"radius": 5, "seed": 1405, "wall_probability": 0.45},
		{"radius": 6, "seed": 888, "wall_probability": 1.0},
		{"radius": 9, "seed": 888, "wall_probability": 1.0},
	]:
		var radius = int(scenario["radius"])
		var seed = int(scenario["seed"])
		var wall_probability = float(scenario["wall_probability"])
		var expected = _manual_draw_threads_symmetric_toric_walls(
			radius,
			wall_probability,
			seed,
			protected
		)
		var actual = HexMapGenerator.generate_symmetric_toric_walls(
			radius,
			wall_probability,
			seed,
			20,
			protected
		)
		_assert_keys_eq(
			actual,
			expected,
			"radius %d symmetric generation follows Unity DrawThreadsOnToricMap source order" % radius
		)


func _test_symmetric_square_torus_and_hex_shape_outputs_share_source_walls() -> void:
	var protected = [HexVector.zero()]
	for radius in [1, 2, 3, 6, 9]:
		var wall_probability := 1.0
		var seed := 888
		var size = radius * 2 + 1
		var square = HexMapGenerator.generate_symmetric_square(
			radius,
			wall_probability,
			seed,
			HexMapGenerator.CONNECT_NONE,
			protected,
			20,
			[],
			false
		)
		var torus = HexMapGenerator.generate_symmetric_square(
			radius,
			wall_probability,
			seed,
			HexMapGenerator.CONNECT_NONE,
			protected,
			20,
			[],
			true
		)
		_assert_eq(square.cyclic_size, 0, "radius %d symmetric square is non-toric" % radius)
		_assert_eq(torus.cyclic_size, size, "radius %d symmetric torus stores cyclic size" % radius)
		_assert_keys_eq(square.cells, torus.cells, "radius %d symmetric square and torus share cells" % radius)
		_assert_keys_eq(square.walls, torus.walls, "radius %d raw symmetric square and torus share source walls" % radius)

		var rule = HexToricMapSplitRule.new(radius)
		var edge_keys := {}
		for area_index in [0, 7]:
			for point in rule.split_canvas[area_index]:
				edge_keys[point.key()] = true
		var expected_hex_cells: Array = []
		for cell in square.cells:
			if not edge_keys.has(cell.key()):
				expected_hex_cells.append(cell)
		var expected_hex_walls: Array = []
		for wall in square.walls:
			if not edge_keys.has(wall.key()):
				expected_hex_walls.append(wall)
		var hexagon = HexMapGenerator.generate_symmetric_hexagon(
			radius,
			wall_probability,
			seed,
			HexMapGenerator.CONNECT_NONE,
			protected
		)
		_assert_keys_eq(hexagon.cells, expected_hex_cells, "radius %d symmetric hexagon filters split 0 and 7 cells" % radius)
		_assert_keys_eq(hexagon.walls, expected_hex_walls, "radius %d symmetric hexagon filters split 0 and 7 walls" % radius)


func _test_minimum_radius_symmetric_generation_uses_unified_flow() -> void:
	var protected = [HexVector.zero()]
	for radius in [1, 2]:
		var custom_distribution = ZeroDistribution.new()
		var size = radius * 2 + 1
		var square_cell_count = size * size
		var hex_cell_count = 1 + 3 * radius * (radius + 1)
		var walls = HexMapGenerator.generate_symmetric_toric_walls(
			radius,
			1.0,
			909,
			20,
			protected,
			custom_distribution
		)
		var custom_distribution_again = ZeroDistribution.new()
		var walls_again = HexMapGenerator.generate_symmetric_toric_walls(
			radius,
			1.0,
			909,
			20,
			protected,
			custom_distribution_again
		)

		_assert_true(custom_distribution.calls > 0, "radius %d symmetric generation uses the same distribution flow as larger radii" % radius)
		_assert_keys_eq(walls, walls_again, "radius %d minimum symmetric generation remains seeded" % radius)
		_assert_true(walls.size() > 0, "radius %d unified symmetric generation creates walls" % radius)
		_assert_true(walls.size() <= square_cell_count - 1, "radius %d unified symmetric generation does not exceed unprotected cells" % radius)
		_assert_false(HexMapData.has_key(walls, HexVector.zero().key()), "radius %d protected cell remains floor" % radius)

		var hexagon = HexMapGenerator.generate_symmetric_hexagon(
			radius,
			1.0,
			909,
			HexMapGenerator.CONNECT_DENSE,
			protected,
			20,
			[],
			custom_distribution
		)
		_assert_eq(hexagon.cells.size(), hex_cell_count, "radius %d symmetric hexagon keeps the expected hex cell count" % radius)
		_assert_true(hexagon.walls.size() <= hex_cell_count - 1, "radius %d symmetric hexagon keeps walls inside unprotected hex cells" % radius)
		_assert_true(HexMapGenerator.is_floor_connected(hexagon), "radius %d symmetric hexagon completes connectivity check" % radius)

		var toric = HexMapGenerator.generate_symmetric_square(
			radius,
			1.0,
			909,
			HexMapGenerator.CONNECT_DENSE,
			protected,
			20,
			[],
			true,
			custom_distribution
		)
		_assert_eq(toric.cells.size(), square_cell_count, "radius %d symmetric toric square keeps the expected square cell count" % radius)
		_assert_eq(toric.cyclic_size, size, "radius %d symmetric toric square stores cyclic size" % radius)
		_assert_true(toric.walls.size() <= square_cell_count - 1, "radius %d symmetric toric square keeps walls inside unprotected cells" % radius)
		_assert_true(HexMapGenerator.is_floor_connected(toric), "radius %d symmetric toric square completes connectivity check" % radius)


func _test_restore_terminal_connectivity_connects_only_requested_terminals() -> void:
	var data = HexMapData.square(5, true)
	var start = HexVector.zero()
	var goal = HexVector.q_axis().scaled(2)
	var unrelated_floor = HexVector.r_axis().scaled(2)
	data.walls = HexMapData.points_except(data.cells, [start, goal, unrelated_floor])

	var removed = HexMapGenerator.restore_terminal_connectivity(data, [start, goal])

	_assert_eq(removed.size(), 1, "terminal recovery removes the shortest terminal bridge")
	_assert_true(HexMapGenerator.are_terminals_connected(data, [start, goal]), "terminal recovery connects requested terminals")
	_assert_false(
		HexMapGenerator.is_floor_connected(data),
		"terminal recovery does not force unrelated floor components to connect"
	)


func _test_generate_symmetric_toric_square_can_restore_terminal_connectivity() -> void:
	var radius = 3
	var size = radius * 2 + 1
	var center = HexVector.apply_basis(radius, 0, radius)
	var terminal_offset = int((radius * 2) / 3)
	var terminals = [
		center,
		center.add(HexVector.r_axis().subtract(HexVector.q_axis()).scaled(terminal_offset)),
		center.add(HexVector.q_axis().subtract(HexVector.r_axis()).scaled(terminal_offset)),
	]
	var data = HexMapGenerator.generate_symmetric_square(
		radius,
		0.45,
		2468,
		HexMapGenerator.CONNECT_DENSE,
		[HexVector.zero()],
		20,
		terminals,
		true
	)

	_assert_eq(data.cyclic_size, size, "symmetric toric square stores cyclic size")
	_assert_false(HexMapData.has_key(data.walls, HexVector.zero().key()), "symmetric protected floor remains floor")
	for terminal in terminals:
		_assert_false(data.has_wall(terminal), "symmetric terminal remains floor")
	_assert_true(
		HexMapGenerator.are_terminals_connected(data, terminals),
		"symmetric toric square connects requested terminals"
	)
	_assert_true(
		HexMapGenerator.is_floor_connected(data),
		"symmetric toric square can be fully restored after terminal recovery"
	)


func _test_generate_hexagon_can_restore_connectivity() -> void:
	var data = HexMapGenerator.generate_hexagon(
		3,
		0.45,
		246,
		HexMapGenerator.CONNECT_DENSE,
		[HexVector.zero()]
	)

	_assert_eq(data.cells.size(), 37, "generated radius 3 hexagon has expected cell count")
	_assert_false(HexMapData.has_key(data.walls, HexVector.zero().key()), "protected hex cell remains floor")
	_assert_true(HexMapGenerator.is_floor_connected(data), "generated hexagon can be restored")


func _test_debug_ascii_renders_wall_layout() -> void:
	var data = HexMapData.rectangle(3, 2)
	data.set_walls([
		HexVector.apply_basis(1, 0, 0),
		HexVector.apply_basis(0, 0, 1),
	])

	_assert_eq(
		HexMapDebug.render_ascii(data, ".", "#", " ", false),
		".#.\n#..",
		"debug ascii renders q/r wall layout"
	)


func _test_debug_summary_reports_counts() -> void:
	var data = HexMapData.square(2, true)
	data.set_walls([HexVector.zero()])

	_assert_eq(
		HexMapDebug.render_summary(data),
		"cells=4 walls=1 floors=3 cyclic_size=2",
		"debug summary reports map counts"
	)


func _test_dense_restores_line_with_single_wall() -> void:
	var cells = _line_cells(3)
	var bridge = HexVector.q_axis()
	var data = HexMapData.from_cells(cells, [bridge])

	var removed = HexMapGenerator.restore_connectivity_dense(data)

	_assert_keys_eq(removed, [bridge], "dense recovery removes the single blocking wall")
	_assert_eq(data.walls.size(), 0, "dense recovery carves the bridge wall")
	_assert_true(HexMapGenerator.is_floor_connected(data), "dense recovery connects a split line")


func _test_dense_uses_toric_shortcut() -> void:
	var data = HexMapData.square(4, true)
	var start = HexVector.zero()
	var goal = HexVector.q_axis().scaled(2)
	data.walls = HexMapData.points_except(data.cells, [start, goal])

	var removed = HexMapGenerator.restore_connectivity_dense(data)

	_assert_eq(removed.size(), 1, "dense recovery uses the one-wall toric shortcut")
	_assert_true(HexMapGenerator.is_floor_connected(data), "dense recovery connects through toric wrapping")


func _test_dense_matches_restore_count_on_y_shape() -> void:
	var cells: Array = [HexVector.zero()]
	cells.append(HexVector.q_axis())
	cells.append(HexVector.q_axis().scaled(2))
	cells.append(HexVector.q_axis().scaled(3))
	cells.append(HexVector.r_axis())
	cells.append(HexVector.r_axis().scaled(2))
	cells.append(HexVector.r_axis().scaled(3))
	cells.append(HexVector.r_axis().scaled(4))

	var walls = [HexVector.q_axis(), HexVector.r_axis()]
	var dense_data = HexMapData.from_cells(cells, walls)
	var restore_data = HexMapData.from_cells(cells, walls)

	var dense_removed = HexMapGenerator.restore_connectivity_dense(dense_data)
	var restore_removed = HexMapGenerator.restore_connectivity(restore_data)

	_assert_true(HexMapGenerator.is_floor_connected(dense_data), "dense recovery connects the y shape")
	_assert_eq(
		dense_removed.size(),
		restore_removed.size(),
		"dense recovery matches restore wall count on y shape"
	)


func _test_dense_chooses_remote_short_bridge() -> void:
	var cells: Array = []
	for q in range(0, 6):
		cells.append(_rect_cell(q, 0))

	var near_tunnel = [_rect_cell(0, 1), _rect_cell(0, 2), _rect_cell(0, 3)]
	var far_bridge = _rect_cell(5, 1)
	var remote_component = [
		_rect_cell(0, 4),
		_rect_cell(1, 4),
		_rect_cell(2, 4),
		_rect_cell(3, 4),
		_rect_cell(4, 4),
		_rect_cell(5, 4),
		_rect_cell(5, 3),
		_rect_cell(5, 2),
	]
	cells.append_array(near_tunnel)
	cells.append(far_bridge)
	cells.append_array(remote_component)

	var walls = near_tunnel.duplicate()
	walls.append(far_bridge)
	var dense_data = HexMapData.from_cells(cells, walls)

	var dense_removed = HexMapGenerator.restore_connectivity_dense(dense_data)

	_assert_true(HexMapGenerator.is_floor_connected(dense_data), "dense recovery connects remote short bridge fixture")
	_assert_keys_eq(dense_removed, [far_bridge], "dense recovery chooses the one-wall remote bridge")


func _test_dense_restores_symmetric_toric_square() -> void:
	var data = HexMapGenerator.generate_symmetric_square(
		3,
		1.0,
		888,
		HexMapGenerator.CONNECT_NONE,
		[HexVector.zero()],
		20,
		[],
		true
	)

	var removed = HexMapGenerator.restore_connectivity_dense(data)

	_assert_false(data.has_wall(HexVector.zero()), "dense symmetric recovery keeps protected floor")
	_assert_true(HexMapGenerator.is_floor_connected(data), "dense symmetric recovery connects toric square")


func _test_sparse_direction_seed_changes_bridge_choice() -> void:
	var directions = HexGrid.directions()
	var seed_a = _seed_for_first_direction(directions[0].key())
	var seed_b = _seed_for_first_direction(directions[3].key())
	var data_a = _ring_bridge_tie_data()
	var data_b = _ring_bridge_tie_data()

	var removed_a = HexMapGenerator.restore_connectivity_sparse(data_a, [HexVector.zero()], seed_a)
	var removed_b = HexMapGenerator.restore_connectivity_sparse(data_b, [HexVector.zero()], seed_b)

	_assert_eq(removed_a.size(), 1, "direction seed fixture removes one wall for seed A")
	_assert_eq(removed_b.size(), 1, "direction seed fixture removes one wall for seed B")
	_assert_true(HexMapGenerator.is_floor_connected(data_a), "seed A sparse restore connects ring fixture")
	_assert_true(HexMapGenerator.is_floor_connected(data_b), "seed B sparse restore connects ring fixture")
	if removed_a.size() == 1 and removed_b.size() == 1:
		_assert_true(
			removed_a[0].key() != removed_b[0].key(),
			"direction seed changes the selected bridge wall"
		)


func _test_restore_direction_seed_is_accepted_by_supported_modes() -> void:
	var seed = _seed_for_first_direction(HexGrid.directions()[2].key())
	var terminal_goal = HexGrid.l1_ring(2)[0]

	var restore_data = _ring_bridge_tie_data()
	var dense_data = _ring_bridge_tie_data()
	var sparse_data = _ring_bridge_tie_data()
	var terminal_data = _ring_bridge_tie_data()

	var restore_removed = HexMapGenerator.restore_connectivity(restore_data, seed)
	var dense_removed = HexMapGenerator.restore_connectivity_dense(dense_data, seed)
	var sparse_removed = HexMapGenerator.restore_connectivity_sparse(sparse_data, [HexVector.zero()], seed)
	var terminal_removed = HexMapGenerator.restore_terminal_connectivity(
		terminal_data,
		[HexVector.zero(), terminal_goal],
		seed
	)

	_assert_eq(restore_removed.size(), 1, "seeded restore removes one bridge wall")
	_assert_eq(dense_removed.size(), 1, "seeded dense restore removes one bridge wall")
	_assert_eq(sparse_removed.size(), 1, "seeded sparse restore removes one bridge wall")
	_assert_eq(terminal_removed.size(), 1, "seeded terminal restore removes one bridge wall")

	_assert_true(HexMapGenerator.is_floor_connected(restore_data), "seeded restore connects ring fixture")
	_assert_true(HexMapGenerator.is_floor_connected(dense_data), "seeded dense restore connects ring fixture")
	_assert_true(HexMapGenerator.is_floor_connected(sparse_data), "seeded sparse restore connects ring fixture")
	_assert_true(HexMapGenerator.is_floor_connected(terminal_data), "seeded terminal restore connects ring fixture")
