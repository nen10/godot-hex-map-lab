extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexRandomizer = preload("res://addons/hex_map_kit/core/hex_randomizer.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexMapDebug = preload("res://addons/hex_map_kit/core/hex_map_debug.gd")
const HexToricMapSplitRule = preload("res://addons/hex_map_kit/core/hex_toric_map_split_rule.gd")

class ZeroDistribution:
	var calls := 0

	func prob(_ref_conditions: Array) -> float:
		calls += 1
		return 0.0

var _failures: Array[String] = []


func _init() -> void:
	_run()


func _run() -> void:
	_test_distribution_probabilities_match_unity_tables()
	_test_rectangle_map_data()
	_test_hexagon_map_data()
	_test_random_walls_are_seeded_and_protect_floor_cells()
	_test_connection_detection_uses_wall_set()
	_test_restore_connectivity_removes_blocking_walls()
	_test_toric_connection_detection_wraps_edges()
	_test_restore_connectivity_uses_toric_shortcut()
	_test_generate_rectangle_can_restore_connectivity()
	_test_generate_toric_square_can_restore_connectivity()
	_test_symmetric_toric_walls_are_seeded_and_mapped_to_split_canvas()
	_test_minimum_radius_symmetric_generation_uses_direct_wall_probability()
	_test_restore_terminal_connectivity_connects_only_requested_terminals()
	_test_generate_symmetric_toric_square_can_restore_terminal_connectivity()
	_test_generate_hexagon_can_restore_connectivity()
	_test_debug_ascii_renders_wall_layout()
	_test_debug_summary_reports_counts()

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


func _line_cells(length: int) -> Array:
	var result: Array = []
	for q in range(length):
		result.append(HexVector.q_axis().scaled(q))
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


func _test_generate_rectangle_can_restore_connectivity() -> void:
	var data = HexMapGenerator.generate_rectangle(6, 6, 0.45, 321, true, false, [HexVector.zero()])

	_assert_false(HexMapData.has_key(data.walls, HexVector.zero().key()), "protected cell remains floor")
	_assert_true(HexMapGenerator.is_floor_connected(data), "generated rectangle can be connectivity-restored")


func _test_generate_toric_square_can_restore_connectivity() -> void:
	var data = HexMapGenerator.generate_toric_square(6, 0.45, 987, true, [HexVector.zero()])

	_assert_eq(data.cyclic_size, 6, "generated toric square stores cyclic size")
	_assert_false(HexMapData.has_key(data.walls, HexVector.zero().key()), "protected toric cell remains floor")
	_assert_true(HexMapGenerator.is_floor_connected(data), "generated toric square can be restored")


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


func _test_minimum_radius_symmetric_generation_uses_direct_wall_probability() -> void:
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

		_assert_eq(custom_distribution.calls, 0, "radius %d symmetric generation does not require distribution references" % radius)
		_assert_eq(walls.size(), square_cell_count - 1, "radius %d direct generation walls every unprotected square cell" % radius)
		_assert_false(HexMapData.has_key(walls, HexVector.zero().key()), "radius %d protected cell remains floor" % radius)

		var hexagon = HexMapGenerator.generate_symmetric_hexagon(
			radius,
			1.0,
			909,
			true,
			protected,
			20,
			[],
			custom_distribution
		)
		_assert_eq(hexagon.cells.size(), hex_cell_count, "radius %d symmetric hexagon keeps the expected hex cell count" % radius)
		_assert_eq(hexagon.walls.size(), hex_cell_count - 1, "radius %d symmetric hexagon walls every unprotected hex cell" % radius)
		_assert_true(HexMapGenerator.is_floor_connected(hexagon), "radius %d symmetric hexagon completes connectivity check" % radius)

		var toric = HexMapGenerator.generate_symmetric_square(
			radius,
			1.0,
			909,
			true,
			protected,
			20,
			[],
			true,
			custom_distribution
		)
		_assert_eq(toric.cells.size(), square_cell_count, "radius %d symmetric toric square keeps the expected square cell count" % radius)
		_assert_eq(toric.cyclic_size, size, "radius %d symmetric toric square stores cyclic size" % radius)
		_assert_eq(toric.walls.size(), square_cell_count - 1, "radius %d symmetric toric square walls every unprotected cell" % radius)
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
		true,
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
	var data = HexMapGenerator.generate_hexagon(3, 0.45, 246, true, [HexVector.zero()])

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
