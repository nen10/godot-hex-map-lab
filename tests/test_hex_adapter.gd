extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexPoint = preload("res://addons/hex_map_kit/core/hex_point.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run()


func _run() -> void:
	_test_vector_to_map_cell_matches_flat_top_offset()
	_test_to_tile_entries_marks_floor_and_wall()
	_test_entries_are_sorted_for_stable_scene_generation()
	_test_vector_to_display_axial_keeps_six_neighbor_shape()
	_test_flat_top_offset_neighbor_deltas_match_unity_even_row()
	_test_flat_top_offset_neighbor_deltas_match_unity_odd_row()
	_test_flat_top_offset_local_positions_are_center_parity_invariant()
	_test_hex_to_local_flat_top_positions()
	_test_hex_to_local_pointy_top_positions()
	_test_flat_top_neighbor_layout()
	_test_pointy_top_neighbor_layout()
	_test_map_resource_stores_map_data()
	_test_map_resource_roundtrips_to_map_data()

	if _failures.is_empty():
		print("test_hex_adapter.gd: all tests passed")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _assert_vec2_approx(actual: Vector2, expected: Vector2, message: String) -> void:
	if not actual.is_equal_approx(expected):
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _assert_keys_eq(actual: Array, expected: Array, message: String) -> void:
	var actual_keys = []
	var expected_keys = []
	for point in actual:
		actual_keys.append(point.key())
	for point in expected:
		expected_keys.append(point.key())
	actual_keys.sort()
	expected_keys.sort()
	if actual_keys != expected_keys:
		_failures.append("%s: expected %s, got %s" % [message, str(expected_keys), str(actual_keys)])


func _test_vector_to_map_cell_matches_flat_top_offset() -> void:
	_assert_eq(
		HexMapTileAdapter.vector_to_map_cell(HexVector.zero()),
		Vector2i(0, 0),
		"origin maps to TileMap cell origin"
	)
	_assert_eq(
		HexMapTileAdapter.vector_to_map_cell(HexVector.apply_basis(1, 0, 1)),
		Vector2i(0, 1),
		"basis-normalized vector maps through HexPoint offset conversion"
	)


func _test_to_tile_entries_marks_floor_and_wall() -> void:
	var data = HexMapData.rectangle(2, 2)
	var wall = HexVector.apply_basis(1, 0, 0)
	data.set_walls([wall])

	var entries = HexMapTileAdapter.to_tile_entries(data)

	_assert_eq(entries.size(), 4, "adapter emits every cell by default")
	_assert_eq(entries[0]["kind"], HexMapTileAdapter.KIND_FLOOR, "origin is floor")
	_assert_eq(entries[0]["map_cell"], Vector2i(0, 0), "origin map cell")
	_assert_eq(entries[1]["kind"], HexMapTileAdapter.KIND_WALL, "wall is marked")
	_assert_eq(entries[1]["map_cell"], Vector2i(1, 0), "wall map cell")


func _test_entries_are_sorted_for_stable_scene_generation() -> void:
	var cells = [
		HexVector.apply_basis(1, 0, 1),
		HexVector.zero(),
		HexVector.apply_basis(1, 0, 0),
	]
	var data = HexMapData.from_cells(cells)
	var entries = HexMapTileAdapter.to_tile_entries(data)

	_assert_eq(entries[0]["vector"].key(), HexVector.zero().key(), "origin sorts first")
	_assert_eq(entries[1]["vector"].key(), HexVector.apply_basis(1, 0, 0).key(), "row 0 q=1 sorts second")
	_assert_eq(entries[2]["vector"].key(), HexVector.apply_basis(1, 0, 1).key(), "next row sorts last")


func _test_vector_to_display_axial_keeps_six_neighbor_shape() -> void:
	var expected = [
		Vector2i(1, 0),
		Vector2i(1, -1),
		Vector2i(0, -1),
		Vector2i(-1, 0),
		Vector2i(-1, 1),
		Vector2i(0, 1),
	]
	var directions = HexVector.directions()

	for index in range(directions.size()):
		_assert_eq(
			HexMapTileAdapter.vector_to_display_axial(directions[index]),
			expected[index],
			"display axial neighbor layout %d" % index
		)


func _test_flat_top_offset_neighbor_deltas_match_unity_even_row() -> void:
	_assert_neighbor_offset_deltas(
		HexPoint.from_cube(0, 0, 0),
		[
			Vector2i(1, 0),
			Vector2i(0, -1),
			Vector2i(-1, -1),
			Vector2i(-1, 0),
			Vector2i(-1, 1),
			Vector2i(0, 1),
		],
		"flat-top offset deltas from even R center"
	)


func _test_flat_top_offset_neighbor_deltas_match_unity_odd_row() -> void:
	var expected = [
		Vector2i(1, 0),
		Vector2i(1, -1),
		Vector2i(0, -1),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(1, 1),
	]

	_assert_neighbor_offset_deltas(
		HexPoint.from_cube(0, 0, 1),
		expected,
		"flat-top offset deltas from positive odd R center"
	)
	_assert_neighbor_offset_deltas(
		HexPoint.from_cube(0, 0, -1),
		expected,
		"flat-top offset deltas from negative odd R center"
	)


func _test_flat_top_offset_local_positions_are_center_parity_invariant() -> void:
	var size = 10.0
	var centers = [
		HexPoint.from_cube(0, 0, 0),
		HexPoint.from_cube(0, 0, 1),
		HexPoint.from_cube(0, 0, -1),
		HexPoint.from_cube(2, 0, 2),
		HexPoint.from_cube(2, 0, 3),
	]
	var directions = HexVector.directions()

	for center_index in range(centers.size()):
		for direction_index in range(directions.size()):
			_assert_vec2_approx(
				_flat_top_offset_relative_local(centers[center_index], directions[direction_index], size),
				HexMapTileAdapter.hex_to_local(directions[direction_index], size, true),
				"flat-top local neighbor position center %d direction %d" % [center_index, direction_index]
			)


func _test_hex_to_local_flat_top_positions() -> void:
	_assert_vec2_approx(
		HexMapTileAdapter.hex_to_local(HexVector.apply_basis(1, 0, 0), 10.0),
		Vector2(15.0, 8.660254),
		"flat-top Q axis uses 3/2 x and sqrt(3)/2 y"
	)


func _test_hex_to_local_pointy_top_positions() -> void:
	_assert_vec2_approx(
		HexMapTileAdapter.hex_to_local(HexVector.apply_basis(0, 0, 1), 10.0, false),
		Vector2(-8.660254, 15.0),
		"pointy-top R axis uses display axial projection"
	)


func _test_flat_top_neighbor_layout() -> void:
	var size = 10.0
	var expected = [
		Vector2(15.0, 8.660254),
		Vector2(15.0, -8.660254),
		Vector2(0.0, -17.320508),
		Vector2(-15.0, -8.660254),
		Vector2(-15.0, 8.660254),
		Vector2(0.0, 17.320508),
	]
	var directions = HexVector.directions()

	for index in range(directions.size()):
		_assert_vec2_approx(
			HexMapTileAdapter.hex_to_local(directions[index], size, true),
			expected[index],
			"flat-top neighbor layout %d" % index
		)


func _test_pointy_top_neighbor_layout() -> void:
	var size = 10.0
	var expected = [
		Vector2(17.320508, 0.0),
		Vector2(8.660254, -15.0),
		Vector2(-8.660254, -15.0),
		Vector2(-17.320508, 0.0),
		Vector2(-8.660254, 15.0),
		Vector2(8.660254, 15.0),
	]
	var directions = HexVector.directions()

	for index in range(directions.size()):
		_assert_vec2_approx(
			HexMapTileAdapter.hex_to_local(directions[index], size, false),
			expected[index],
			"pointy-top neighbor layout %d" % index
		)


func _test_map_resource_stores_map_data() -> void:
	var data = HexMapData.square(2, true)
	data.set_walls([HexVector.q_axis()])

	var resource = HexMapResource.from_map_data(data)

	_assert_eq(resource.cyclic_size, 2, "resource stores cyclic size")
	_assert_eq(resource.cells.size(), 4, "resource stores all cells")
	_assert_eq(resource.walls, [Vector3i(1, 0, 0)], "resource stores wall vector components")


func _test_map_resource_roundtrips_to_map_data() -> void:
	var data = HexMapData.rectangle(3, 2)
	data.set_walls([
		HexVector.apply_basis(1, 0, 0),
		HexVector.apply_basis(0, 0, 1),
	])

	var roundtrip = HexMapResource.from_map_data(data).to_map_data()

	_assert_eq(roundtrip.cyclic_size, data.cyclic_size, "roundtrip preserves cyclic size")
	_assert_keys_eq(roundtrip.cells, data.cells, "roundtrip preserves cells")
	_assert_keys_eq(roundtrip.walls, data.walls, "roundtrip preserves walls")


func _assert_neighbor_offset_deltas(center, expected: Array, message: String) -> void:
	var center_cell = center.to_offset()
	var directions = HexVector.directions()

	for index in range(directions.size()):
		var neighbor_cell = center.add_vector(directions[index]).to_offset()
		_assert_eq(
			neighbor_cell - center_cell,
			expected[index],
			"%s direction %d" % [message, index]
		)


func _flat_top_offset_relative_local(center, direction, size: float) -> Vector2:
	var center_local = _flat_top_point_local_from_unity_offset(center, size)
	var neighbor_local = _flat_top_point_local_from_unity_offset(center.add_vector(direction), size)
	return neighbor_local - center_local


func _flat_top_point_local_from_unity_offset(point, size: float) -> Vector2:
	var cell = point.to_offset()
	var offset_point = HexPoint.from_offset(cell.x, cell.y)
	var a = float(offset_point.q - offset_point.r)
	var b = float(offset_point.r)
	var sqrt3 = sqrt(3.0)
	return Vector2(
		size * 1.5 * a,
		size * sqrt3 * (b + a * 0.5)
	)
