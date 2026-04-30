extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run()


func _run() -> void:
	_test_vector_to_map_cell_matches_flat_top_offset()
	_test_to_tile_entries_marks_floor_and_wall()
	_test_entries_are_sorted_for_stable_scene_generation()
	_test_hex_to_local_flat_top_positions()
	_test_hex_to_local_pointy_top_positions()

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


func _test_hex_to_local_flat_top_positions() -> void:
	_assert_vec2_approx(
		HexMapTileAdapter.hex_to_local(HexVector.apply_basis(1, 0, 0), 10.0),
		Vector2(15.0, 8.660254),
		"flat-top Q axis uses 3/2 x and sqrt(3)/2 y"
	)


func _test_hex_to_local_pointy_top_positions() -> void:
	_assert_vec2_approx(
		HexMapTileAdapter.hex_to_local(HexVector.apply_basis(0, 0, 1), 10.0, false),
		Vector2(8.660254, 15.0),
		"pointy-top R axis uses sqrt(3)/2 x and 3/2 y"
	)
