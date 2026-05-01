extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexPoint = preload("res://addons/hex_map_kit/core/hex_point.gd")
const HexToricCoordinate = preload("res://addons/hex_map_kit/core/hex_toric_coordinate.gd")
const HexGrid = preload("res://addons/hex_map_kit/core/hex_grid.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run()


func _run() -> void:
	_test_hex_vector_basis_normalization()
	_test_hex_vector_directions()
	_test_hex_point_offset_roundtrip()
	_test_hex_point_distance_and_addition()
	_test_toric_coordinate_wraps_axial_values()
	_test_grid_neighbors_and_connected_area()
	_test_grid_toric_connected_area_wraps_neighbors()
	_test_grid_l1_ring_and_disc()
	_test_grid_shortest_path_uses_enterable_points()
	_test_grid_toric_shortest_path_wraps_edges()

	if _failures.is_empty():
		print("test_hex_core.gd: all tests passed")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _assert_vector_eq(actual, expected, message: String) -> void:
	if not actual.is_equal(expected):
		_failures.append(
			"%s: expected %s, got %s" % [message, expected.debug_string(), actual.debug_string()]
		)


func _assert_keys_eq(actual: Array, expected: Array, message: String) -> void:
	var actual_keys = _keys(actual)
	var expected_keys = _keys(expected)
	if actual_keys != expected_keys:
		_failures.append("%s: expected %s, got %s" % [message, str(expected_keys), str(actual_keys)])


func _keys(points: Array) -> Array:
	var result: Array = []
	for point in points:
		result.append(point.key())
	return result


func _test_hex_vector_basis_normalization() -> void:
	_assert_vector_eq(
		HexVector.apply_basis(1, 0, 1),
		HexVector.s_axis().negated(),
		"Q + R should normalize to -S"
	)
	_assert_vector_eq(
		HexVector.apply_basis(3, 1, 3),
		HexVector.apply_basis(0, -2, 0),
		"basis should slide redundant shared components"
	)
	_assert_eq(HexVector.apply_basis(3, 1, 3).l1_norm(), 2, "normalized L1 norm")
	_assert_eq(HexVector.zero().l2_norm(), 0.0, "zero L2 norm")


func _test_hex_vector_directions() -> void:
	var keys: Dictionary = {}
	for direction in HexVector.directions():
		keys[direction.key()] = true
		_assert_eq(direction.l1_norm(), 1, "each axial neighbor direction has cost 1")

	_assert_eq(keys.size(), 6, "six directions should be unique")
	_assert_vector_eq(
		HexVector.q_axis().add(HexVector.r_axis()),
		HexVector.s_axis().negated(),
		"axis addition follows the Unity basis"
	)


func _test_hex_point_offset_roundtrip() -> void:
	for y in range(-3, 4):
		for x in range(-2, 3):
			var point = HexPoint.from_offset(x, y)
			_assert_eq(point.to_offset(), Vector2i(x, y), "offset roundtrip")


func _test_hex_point_distance_and_addition() -> void:
	var origin = HexPoint.from_offset(0, 0)
	var east = origin.add_vector(HexVector.q_axis())
	var southeast = origin.add_vector(HexVector.s_axis().negated())

	_assert_eq(east.to_offset(), Vector2i(1, 0), "Q direction maps to offset east")
	_assert_eq(southeast.to_offset(), Vector2i(0, 1), "-S direction maps to next row")
	_assert_eq(origin.l1_distance_to(east), 1, "neighbor distance is 1")
	_assert_eq(origin.l1_distance_to(southeast), 1, "diagonal row neighbor distance is 1")
	_assert_vector_eq(origin.vector_to(east), HexVector.q_axis(), "vector_to points toward target")
	_assert_vector_eq(east.vector_from(origin), HexVector.q_axis(), "vector_from points away from source")


func _test_toric_coordinate_wraps_axial_values() -> void:
	var wrapped_negative = HexToricCoordinate.apply_cyclic(HexVector.q_axis().negated(), 5)
	_assert_eq(wrapped_negative.axial(), Vector2i(4, 0), "negative Q wraps into cyclic range")

	var wrapped_overflow = HexToricCoordinate.apply_cyclic(HexVector.apply_basis(0, 0, 5), 5)
	_assert_eq(wrapped_overflow.axial(), Vector2i(0, 0), "R overflow wraps to zero")

	var wrapped_s = HexToricCoordinate.apply_cyclic(HexVector.s_axis(), 5)
	_assert_eq(wrapped_s.axial(), Vector2i(4, 4), "S axis wraps through q-s/r-s axial values")


func _test_grid_neighbors_and_connected_area() -> void:
	var origin = HexVector.zero()
	var neighbors = HexGrid.neighbors(origin)

	_assert_eq(neighbors.size(), 6, "grid returns six neighbors")
	_assert_vector_eq(neighbors[0], HexVector.q_axis(), "neighbor order matches Unity HexPath")
	_assert_vector_eq(neighbors[1], HexVector.r_axis().negated(), "neighbor order includes -R second")

	var enterable: Array = [origin]
	enterable.append_array(neighbors)
	var connected = HexGrid.connected_area(origin, enterable)
	_assert_eq(connected.size(), 7, "origin plus all neighbors are connected")

	var split_area: Array = [
		origin,
		HexVector.q_axis(),
		HexVector.q_axis().scaled(2),
		HexVector.r_axis().scaled(2),
	]
	_assert_eq(
		HexGrid.connected_area(origin, split_area).size(),
		3,
		"disconnected enterable positions stay excluded"
	)


func _test_grid_toric_connected_area_wraps_neighbors() -> void:
	var origin = HexVector.zero()
	var wrapped_west = HexToricCoordinate.wrap_vector(HexVector.q_axis().negated(), 3)
	var enterable: Array = [origin, wrapped_west]
	var connected = HexGrid.connected_area(origin, enterable, 3)

	_assert_eq(connected.size(), 2, "toric connected area follows wrapped neighbor")


func _test_grid_l1_ring_and_disc() -> void:
	var radius = 2
	var ring = HexGrid.l1_ring(radius)
	var ring_keys := {}
	for point in ring:
		ring_keys[point.key()] = true
		_assert_eq(point.l1_norm(), radius, "L1 ring contains only radius-distance cells")

	_assert_eq(ring.size(), 12, "radius 2 L1 ring has 6r cells")
	for direction in HexVector.directions():
		_assert_true(
			ring_keys.has(direction.scaled(radius).key()),
			"L1 ring contains every axial corner"
		)

	var disc = HexGrid.l1_disc(radius)
	for point in disc:
		_assert_true(point.l1_norm() <= radius, "L1 disc contains only cells within radius")

	_assert_eq(disc.size(), 19, "radius 2 L1 disc has hexagonal cell count")
	_assert_vector_eq(HexGrid.l1_disc(0)[0], HexVector.zero(), "radius 0 disc is origin only")

	var center = HexVector.apply_basis(2, 0, 3)
	var shifted = HexGrid.l1_disc(1, center)
	for point in shifted:
		_assert_true(point.subtract(center).l1_norm() <= 1, "shifted L1 disc is relative to origin")


func _test_grid_shortest_path_uses_enterable_points() -> void:
	var cells: Array = [
		HexVector.zero(),
		HexVector.q_axis(),
		HexVector.q_axis().scaled(2),
		HexVector.q_axis().scaled(3),
	]
	var path = HexGrid.shortest_path(HexVector.zero(), [HexVector.q_axis().scaled(3)], cells)
	_assert_keys_eq(path, cells, "shortest path follows a simple line")

	var blocked: Array = [
		HexVector.zero(),
		HexVector.q_axis(),
		HexVector.q_axis().scaled(3),
	]
	_assert_eq(
		HexGrid.shortest_path(HexVector.zero(), [HexVector.q_axis().scaled(3)], blocked).size(),
		0,
		"shortest path fails when enterable points are disconnected"
	)

	var nearest = HexGrid.shortest_path(
		HexVector.zero(),
		[HexVector.q_axis().scaled(3), HexVector.q_axis()],
		cells
	)
	_assert_keys_eq(
		nearest,
		[HexVector.zero(), HexVector.q_axis()],
		"shortest path stops at the nearest reachable goal"
	)


func _test_grid_toric_shortest_path_wraps_edges() -> void:
	var origin = HexVector.zero()
	var wrapped_west = HexToricCoordinate.wrap_vector(HexVector.q_axis().negated(), 3)
	var path = HexGrid.shortest_path(
		origin,
		[HexVector.q_axis().negated()],
		[origin, wrapped_west],
		3
	)

	_assert_keys_eq(path, [origin, wrapped_west], "toric shortest path follows wrapped edge")
