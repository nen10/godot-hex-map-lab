extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexRandomizer = preload("res://addons/hex_map_kit/core/hex_randomizer.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run()


func _run() -> void:
	_test_distribution_probabilities_match_unity_tables()
	_test_rectangle_map_data()
	_test_random_walls_are_seeded_and_protect_floor_cells()
	_test_connection_detection_uses_wall_set()
	_test_restore_connectivity_removes_blocking_walls()
	_test_toric_connection_detection_wraps_edges()
	_test_restore_connectivity_uses_toric_shortcut()
	_test_generate_rectangle_can_restore_connectivity()
	_test_generate_toric_square_can_restore_connectivity()

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
	var data = HexMapData.toric_square(3)
	var left = HexVector.zero()
	var right = HexVector.q_axis().scaled(2)
	data.walls = HexMapData.points_except(data.cells, [left, right])

	_assert_true(HexMapGenerator.is_floor_connected(data), "toric map connects q edge to wrapped q edge")


func _test_restore_connectivity_uses_toric_shortcut() -> void:
	var data = HexMapData.toric_square(4)
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
