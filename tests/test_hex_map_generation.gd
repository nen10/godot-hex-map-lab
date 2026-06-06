extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexRandomizer = preload("res://addons/hex_map_kit/core/hex_randomizer.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexOverlayData = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexMapDebug = preload("res://addons/hex_map_kit/core/hex_map_debug.gd")
const HexToricMapSplitRule = preload("res://addons/hex_map_kit/core/hex_toric_map_split_rule.gd")
const HexGrid = preload("res://addons/hex_map_kit/core/hex_grid.gd")

const QA04_GOLDEN_SEED_FIXTURE_PATH := "res://docs/test/fixtures/qa04_golden_seed_previews_2026-06-07.json"

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
	_test_primary_map_data_exposes_item_keys()
	_test_overlay_data_stores_user_item_keys()
	_test_item_query_combines_primary_and_overlay_sources()
	_test_random_walls_are_seeded_and_protect_floor_cells()
	_test_interruptible_random_walls_reports_progress_and_cancel()
	_test_random_items_use_weighted_pool_and_mask()
	_test_limited_items_respect_item_limits()
	_test_interruptible_item_generation_reports_progress_and_cancel()
	_test_toric_adjacency_items_use_count_component_rules()
	_test_toric_adjacency_items_wrap_reference_neighbors()
	_test_toric_adjacency_items_can_reference_generated_item()
	_test_toric_adjacency_generated_reference_wraps()
	_test_toric_adjacency_generated_reference_preserves_cancel()
	_test_symmetric_toric_items_respect_target_and_blocked_cells()
	_test_symmetric_toric_items_are_seeded_and_interruptible()
	_test_overlay_deductor_restores_item_blocked_connectivity()
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
	_test_generated_hexagon_shapes_share_canonical_cells()
	_test_minimum_radius_symmetric_generation_uses_unified_flow()
	_test_restore_terminal_connectivity_connects_only_requested_terminals()
	_test_generate_symmetric_toric_square_can_restore_terminal_connectivity()
	_test_generate_hexagon_can_restore_connectivity()
	_test_golden_seed_fixtures_match_preview_data()
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


func _canonical_hexagon_cells(radius: int) -> Array:
	if radius == 0:
		return [HexVector.zero()]
	var rule = HexToricMapSplitRule.new(radius)
	var trimmed_keys := {}
	for area_index in [0, 7]:
		for point in rule.split_canvas[area_index]:
			trimmed_keys[point.key()] = true
	var result: Array = []
	for cell in HexMapData.square(radius * 2 + 1, false).cells:
		if not trimmed_keys.has(cell.key()):
			result.append(cell)
	return result


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
	_assert_keys_eq(data.cells, _canonical_hexagon_cells(2), "radius 2 hexagon uses square with split 0 and 7 trimmed")
	_assert_keys_eq(HexMapData.hexagon(0).cells, [HexVector.zero()], "radius 0 hexagon is the origin cell")


func _test_primary_map_data_exposes_item_keys() -> void:
	var data = HexMapData.rectangle(3, 1)
	data.set_walls([_rect_cell(1, 0)])

	_assert_eq(data.item_keys(), ["Any", "Floor", "Wall"], "primary map data exposes fixed item keys")
	_assert_keys_eq(data.item_cells("Any"), data.cells, "primary Any item contains every cell")
	_assert_keys_eq(data.item_cells("Floor"), [_rect_cell(0, 0), _rect_cell(2, 0)], "primary Floor item excludes walls")
	_assert_keys_eq(data.item_cells("Wall"), [_rect_cell(1, 0)], "primary Wall item contains walls")
	_assert_true(data.item_set("Floor").has(_rect_cell(0, 0).key()), "primary item_set exposes floor membership")
	_assert_eq(data.item_cells("Treasure"), [], "primary unknown item key is empty")


func _test_overlay_data_stores_user_item_keys() -> void:
	var cells = HexMapData.rectangle(3, 1).cells
	var overlay = HexOverlayData.from_cells(cells, {
		"Treasure": [_rect_cell(0, 0), _rect_cell(9, 9)],
		"Wall": [_rect_cell(1, 0), _rect_cell(1, 0)],
	})
	overlay.add_item_cell("Shop", _rect_cell(2, 0))
	overlay.add_item_cell("Shop", _rect_cell(9, 9))

	_assert_eq(overlay.item_keys(), ["Shop", "Treasure", "Wall"], "overlay data exposes sorted user item keys")
	_assert_keys_eq(overlay.item_cells("Treasure"), [_rect_cell(0, 0)], "overlay data filters item cells by known cells")
	_assert_keys_eq(overlay.item_cells("Wall"), [_rect_cell(1, 0)], "overlay item names may match primary item names")
	_assert_keys_eq(overlay.item_cells("Shop"), [_rect_cell(2, 0)], "overlay add_item_cell stores valid cells")
	_assert_true(overlay.has_item(_rect_cell(1, 0), "Wall"), "overlay has_item checks item membership")
	_assert_eq(overlay.items_at(_rect_cell(2, 0)), ["Shop"], "overlay items_at returns item keys for a cell")
	_assert_keys_eq(overlay.occupied_cells(), [_rect_cell(0, 0), _rect_cell(1, 0), _rect_cell(2, 0)], "overlay occupied_cells unions item cells")


func _test_item_query_combines_primary_and_overlay_sources() -> void:
	var primary = HexMapData.rectangle(4, 1)
	primary.set_walls([_rect_cell(1, 0)])
	var overlay = HexOverlayData.from_cells(primary.cells, {
		"Treasure": [_rect_cell(0, 0), _rect_cell(2, 0)],
		"Shop": [_rect_cell(3, 0)],
	})

	var floor_selector = HexOverlayData.item_selector(primary, "Floor")
	var treasure_selector = HexOverlayData.item_selector(overlay, "Treasure")
	var shop_selector = HexOverlayData.item_selector(overlay, "Shop")
	_assert_keys_eq(
		HexOverlayData.query_item_cells([floor_selector, treasure_selector], HexOverlayData.ITEM_QUERY_OR),
		[_rect_cell(0, 0), _rect_cell(2, 0), _rect_cell(3, 0)],
		"item query OR unions Primary and Overlay item cells"
	)
	_assert_keys_eq(
		HexOverlayData.query_item_cells([floor_selector, treasure_selector], HexOverlayData.ITEM_QUERY_AND),
		[_rect_cell(0, 0), _rect_cell(2, 0)],
		"item query AND intersects Primary and Overlay item cells"
	)
	_assert_eq(
		HexOverlayData.query_item_cells([treasure_selector, shop_selector], HexOverlayData.ITEM_QUERY_AND),
		[],
		"item query AND returns empty when selected overlay items do not overlap"
	)
	_assert_true(
		HexOverlayData.query_item_set([treasure_selector]).has(_rect_cell(0, 0).key()),
		"item query set exposes selected cell membership"
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


func _test_random_items_use_weighted_pool_and_mask() -> void:
	var cells = HexMapData.rectangle(4, 1).cells
	var blocked = [_rect_cell(1, 0)]
	var item_pool = [
		{"name": "Treasure", "weight": 0.0},
		{"name": "Wall", "weight": 1.0},
	]
	var overlay_a = HexMapGenerator.generate_random_items(cells, 1.0, item_pool, 123, blocked)
	var overlay_b = HexMapGenerator.generate_random_items(cells, 1.0, item_pool, 123, blocked)

	_assert_keys_eq(overlay_a.cells, [_rect_cell(0, 0), _rect_cell(2, 0), _rect_cell(3, 0)], "random items use unblocked cells as generation candidates")
	_assert_eq(overlay_a.item_keys(), ["Wall"], "random items ignore zero weight items")
	_assert_keys_eq(overlay_a.item_cells("Wall"), overlay_a.cells, "probability one fills every candidate with weighted item")
	_assert_keys_eq(overlay_a.item_cells("Wall"), overlay_b.item_cells("Wall"), "random item generation is seeded")

	var empty_overlay = HexMapGenerator.generate_random_items(cells, 0.0, item_pool, 123)
	_assert_eq(empty_overlay.occupied_cells().size(), 0, "zero placement probability creates no overlay items")


func _test_limited_items_respect_item_limits() -> void:
	var cells = HexMapData.rectangle(6, 1).cells
	var blocked = [_rect_cell(5, 0)]
	var item_pool = [
		{"name": "Treasure", "limit": 2},
		{"name": "Wall", "limit": 1},
	]
	var overlay = HexMapGenerator.generate_limited_items(cells, item_pool, 456, blocked)

	_assert_eq(overlay.cells.size(), 5, "limited items use unblocked cells as generation candidates")
	_assert_eq(overlay.item_cells("Treasure").size(), 2, "limited items place the requested Treasure count")
	_assert_eq(overlay.item_cells("Wall").size(), 1, "limited items place the requested Wall count")
	_assert_eq(overlay.occupied_cells().size(), 3, "limited items stop at the total requested limit")
	_assert_false(HexMapData.make_set(overlay.occupied_cells()).has(_rect_cell(5, 0).key()), "limited items do not use blocked cells")


func _test_interruptible_item_generation_reports_progress_and_cancel() -> void:
	var cells = HexMapData.rectangle(4, 1).cells
	var options = _cancel_interrupt_options(2)
	var result = HexMapGenerator.generate_random_items_interruptible(
		cells,
		1.0,
		[{"name": "Treasure", "weight": 1.0}],
		77,
		[],
		options
	)
	var recorder = options["_recorder"]

	_assert_true(result["cancelled"], "interruptible random items reports cancelled result")
	_assert_true(options["cancelled"], "interruptible random items records cancelled option state")
	_assert_eq(result["data"].occupied_cells().size(), 2, "interruptible random items stops after requested step")
	_assert_eq(options["phase"], "random_items", "interruptible random items records phase")
	_assert_true(recorder.progress_events.size() >= 3, "interruptible random items emits start and chunk progress")
	_assert_eq(recorder.progress_events[0]["progress"], 0.0, "interruptible random items starts at zero progress")


func _test_toric_adjacency_items_use_count_component_rules() -> void:
	var directions = HexGrid.directions()
	var connected_candidate = HexVector.zero()
	var split_candidate = _rect_cell(10, 10)
	var reference_cells = [
		connected_candidate.add(directions[0]),
		connected_candidate.add(directions[1]),
		split_candidate.add(directions[0]),
		split_candidate.add(directions[3]),
	]
	var overlay = HexMapGenerator.generate_toric_adjacency_items(
		[connected_candidate, split_candidate],
		"Cluster",
		reference_cells,
		{
			"default": 0.0,
			"2,1": 1.0,
			"2,2": 0.0,
		},
		99
	)

	_assert_keys_eq(overlay.item_cells("Cluster"), [connected_candidate], "adjacency item generator uses neighbor count and component rule")


func _test_toric_adjacency_items_wrap_reference_neighbors() -> void:
	var cells = HexMapData.square(3, true).cells
	var candidate = HexVector.zero()
	var reference = _rect_cell(2, 0)
	var overlay = HexMapGenerator.generate_toric_adjacency_items(
		cells,
		"Portal",
		[reference],
		{
			"default": 0.0,
			"1,1": 1.0,
		},
		7,
		[],
		3
	)

	_assert_true(overlay.has_item(candidate, "Portal"), "adjacency item generator wraps toric reference neighbors")


func _test_toric_adjacency_items_can_reference_generated_item() -> void:
	var first_candidate = HexVector.zero()
	var second_candidate = HexVector.q_axis()
	var reference = HexVector.q_axis().scaled(-1)
	var rules = {
		"default": 0.0,
		"1,1": 1.0,
	}
	var static_only = HexMapGenerator.generate_toric_adjacency_items(
		[first_candidate, second_candidate],
		"Vine",
		[reference],
		rules,
		11
	)
	var dynamic = HexMapGenerator.generate_toric_adjacency_items(
		[first_candidate, second_candidate],
		"Vine",
		[reference],
		rules,
		11,
		[],
		0,
		1,
		true
	)

	_assert_keys_eq(static_only.item_cells("Vine"), [first_candidate], "adjacency generated reference defaults to static reference cells")
	_assert_keys_eq(dynamic.item_cells("Vine"), [first_candidate, second_candidate], "adjacency generated reference adds placed target items to later reference stats")


func _test_toric_adjacency_generated_reference_wraps() -> void:
	var edge_candidate = _rect_cell(2, 0)
	var wrapped_candidate = HexVector.zero()
	var reference = edge_candidate.add(HexVector.r_axis())
	var rules = {
		"default": 0.0,
		"1,1": 1.0,
	}
	var static_only = HexMapGenerator.generate_toric_adjacency_items(
		[edge_candidate, wrapped_candidate],
		"Portal",
		[reference],
		rules,
		12,
		[],
		3
	)
	var dynamic = HexMapGenerator.generate_toric_adjacency_items(
		[edge_candidate, wrapped_candidate],
		"Portal",
		[reference],
		rules,
		12,
		[],
		3,
		1,
		true
	)

	_assert_keys_eq(static_only.item_cells("Portal"), [edge_candidate], "toric generated reference starts from static reference cells only")
	_assert_keys_eq(dynamic.item_cells("Portal"), [edge_candidate, wrapped_candidate], "toric generated reference uses wrapped generated item representatives")


func _test_toric_adjacency_generated_reference_preserves_cancel() -> void:
	var first_candidate = HexVector.zero()
	var second_candidate = HexVector.q_axis()
	var third_candidate = HexVector.q_axis().scaled(2)
	var reference = HexVector.q_axis().scaled(-1)
	var options = _cancel_interrupt_options(1)
	var result = HexMapGenerator.generate_toric_adjacency_items_interruptible(
		[first_candidate, second_candidate, third_candidate],
		"Vine",
		[reference],
		{
			"default": 0.0,
			"1,1": 1.0,
		},
		13,
		[],
		0,
		1,
		options,
		true
	)

	_assert_true(result["cancelled"], "generated reference adjacency reports cancelled result")
	_assert_true(options["cancelled"], "generated reference adjacency records cancelled option state")
	_assert_eq(result["steps"], 1, "generated reference adjacency stops at requested cancel step")
	_assert_keys_eq(result["data"].item_cells("Vine"), [first_candidate], "generated reference adjacency returns partial data at cancellation")


func _test_symmetric_toric_items_respect_target_and_blocked_cells() -> void:
	var radius := 2
	var cells = HexMapData.square(radius * 2 + 1, true).cells
	var target_cells = [
		cells[0],
		cells[1],
		cells[2],
		cells[3],
	]
	var blocked = [cells[1]]
	var overlay = HexMapGenerator.generate_symmetric_toric_items(
		radius,
		"Decor",
		target_cells,
		1.0,
		12,
		20,
		blocked
	)

	_assert_keys_eq(overlay.cells, [cells[0], cells[2], cells[3]], "symmetric toric items use target cells minus blocked cells as candidates")
	_assert_keys_eq(overlay.item_cells("Decor"), overlay.cells, "probability one fills every unblocked target item cell")
	_assert_false(overlay.has_item(cells[1], "Decor"), "symmetric toric items exclude blocked target cells")


func _test_symmetric_toric_items_are_seeded_and_interruptible() -> void:
	var radius := 2
	var cells = HexMapData.square(radius * 2 + 1, true).cells
	var target_cells = cells.slice(0, 10)
	var overlay_a = HexMapGenerator.generate_symmetric_toric_items(
		radius,
		"Decor",
		target_cells,
		0.45,
		345,
		20
	)
	var overlay_b = HexMapGenerator.generate_symmetric_toric_items(
		radius,
		"Decor",
		target_cells,
		0.45,
		345,
		20
	)
	_assert_keys_eq(overlay_a.item_cells("Decor"), overlay_b.item_cells("Decor"), "symmetric toric item generation is seeded")

	var options = _phase_cancel_interrupt_options("symmetric_toric")
	var result = HexMapGenerator.generate_symmetric_toric_items_interruptible(
		radius,
		"Decor",
		target_cells,
		0.45,
		345,
		20,
		[],
		null,
		options
	)
	_assert_true(result["cancelled"], "interruptible symmetric toric items reports cancelled result")
	_assert_true(options["cancelled"], "interruptible symmetric toric items records cancelled option state")
	_assert_true(result["data"] is HexOverlayData, "interruptible symmetric toric items returns overlay data")


func _test_overlay_deductor_restores_item_blocked_connectivity() -> void:
	var cells = _line_cells(3)
	var overlay = HexOverlayData.from_item_cells(cells, "Block", [HexVector.q_axis()])
	var removed = HexMapGenerator.deduct_items_for_connectivity(
		overlay,
		"Block",
		cells,
		HexMapGenerator.CONNECT_DENSE,
		101
	)

	_assert_keys_eq(removed, [HexVector.q_axis()], "overlay deductor removes item blocking floor connectivity")
	_assert_false(overlay.has_item(HexVector.q_axis(), "Block"), "overlay deductor updates overlay item cells")


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

		var expected_hex_cells = _canonical_hexagon_cells(radius)
		var expected_hex_cell_set = HexMapData.make_set(expected_hex_cells)
		var expected_hex_walls: Array = []
		for wall in square.walls:
			if expected_hex_cell_set.has(wall.key()):
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


func _test_generated_hexagon_shapes_share_canonical_cells() -> void:
	for radius in [1, 2, 3]:
		var simple = HexMapGenerator.generate_hexagon(
			radius,
			0.0,
			4000 + radius,
			HexMapGenerator.CONNECT_NONE
		)
		var symmetric = HexMapGenerator.generate_symmetric_hexagon(
			radius,
			0.0,
			5000 + radius,
			HexMapGenerator.CONNECT_NONE
		)
		var expected = _canonical_hexagon_cells(radius)
		_assert_keys_eq(simple.cells, expected, "radius %d simple hexagon uses canonical cells" % radius)
		_assert_keys_eq(symmetric.cells, expected, "radius %d symmetric hexagon uses canonical cells" % radius)
		_assert_keys_eq(simple.cells, symmetric.cells, "radius %d simple and symmetric hexagon share cells" % radius)


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


func _test_golden_seed_fixtures_match_preview_data() -> void:
	var fixture_text := FileAccess.get_file_as_string(QA04_GOLDEN_SEED_FIXTURE_PATH)
	_assert_true(fixture_text != "", "QA-04 golden seed fixture is readable")
	var fixture = JSON.parse_string(fixture_text)
	_assert_true(fixture is Dictionary, "QA-04 golden seed fixture parses as a dictionary")
	if not fixture is Dictionary:
		return
	_assert_eq(fixture.get("schema", ""), "hex-map-kit/qa04-golden-seeds/v1", "QA-04 fixture schema is current")
	var scenarios: Array = fixture.get("scenarios", [])
	_assert_true(scenarios.size() >= 2, "QA-04 fixture records multiple important seeds")

	for scenario in scenarios:
		_assert_true(scenario is Dictionary, "QA-04 scenario is a dictionary")
		if not scenario is Dictionary:
			continue
		var name := str(scenario.get("name", "unnamed"))
		var expected = scenario.get("expected", {})
		_assert_true(expected is Dictionary, "%s fixture has expected preview data" % name)
		if not expected is Dictionary:
			continue
		var data = _golden_seed_data(scenario)
		var actual = _golden_seed_preview(data)
		_assert_eq(actual["summary"], expected.get("summary", ""), "%s summary matches fixture" % name)
		_assert_eq(actual["score"], int(expected.get("score", -1)), "%s deterministic score matches fixture" % name)
		_assert_eq(actual["cells"], int(expected.get("cells", -1)), "%s cell count matches fixture" % name)
		_assert_eq(actual["walls"], int(expected.get("walls", -1)), "%s wall count matches fixture" % name)
		_assert_eq(actual["floors"], int(expected.get("floors", -1)), "%s floor count matches fixture" % name)
		_assert_eq(actual["connected"], bool(expected.get("connected", false)), "%s connected flag matches fixture" % name)
		_assert_eq(actual["cyclic_size"], int(expected.get("cyclic_size", -1)), "%s cyclic size matches fixture" % name)
		_assert_eq(actual["wall_keys"], expected.get("wall_keys", []), "%s wall keys match fixture" % name)
		_assert_eq(actual["ascii_rows"], expected.get("ascii_rows", []), "%s ASCII preview rows match fixture" % name)


func _golden_seed_data(scenario: Dictionary):
	var protected_floor := _cells_from_keys(scenario.get("protected_floor", []))
	var connect_method := _connect_method_from_key(str(scenario.get("connect_method", "none")))
	match str(scenario.get("generator", "")):
		"rectangle":
			return HexMapGenerator.generate_rectangle(
				int(scenario["width"]),
				int(scenario["height"]),
				float(scenario["wall_probability"]),
				int(scenario["seed"]),
				connect_method,
				false,
				protected_floor
			)
		"symmetric_square":
			return HexMapGenerator.generate_symmetric_square(
				int(scenario["radius"]),
				float(scenario["wall_probability"]),
				int(scenario["seed"]),
				connect_method,
				protected_floor,
				int(scenario.get("distribution_id", 20)),
				[],
				bool(scenario.get("connect_toric", false))
			)
	_failures.append("QA-04 fixture uses unsupported generator %s" % str(scenario.get("generator", "")))
	return HexMapData.from_cells([], [])


func _golden_seed_preview(data) -> Dictionary:
	var wall_keys := _keys(data.walls)
	var ascii_rows := Array(HexMapDebug.render_ascii(data, ".", "#", " ", false).split("\n"))
	var floors: int = data.floor_cells().size()
	var connected := HexMapGenerator.is_floor_connected(data)
	var cyclic_size := int(data.cyclic_size)
	var score: int = (floors * 10) - wall_keys.size() + (100 if connected else -100) + cyclic_size
	return {
		"summary": HexMapDebug.render_summary(data),
		"score": score,
		"cells": data.cells.size(),
		"walls": wall_keys.size(),
		"floors": floors,
		"connected": connected,
		"cyclic_size": cyclic_size,
		"wall_keys": wall_keys,
		"ascii_rows": ascii_rows,
	}


func _connect_method_from_key(key: String) -> int:
	match key:
		"dense":
			return HexMapGenerator.CONNECT_DENSE
		"sparse":
			return HexMapGenerator.CONNECT_SPARSE
	return HexMapGenerator.CONNECT_NONE


func _cells_from_keys(keys: Array) -> Array:
	var result: Array = []
	for key in keys:
		result.append(_cell_from_key(str(key)))
	return result


func _cell_from_key(key: String):
	var parts = key.split(",")
	return HexVector.new(int(parts[0]), int(parts[1]), int(parts[2]))


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
