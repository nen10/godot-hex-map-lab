extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await _test_apply_map_and_cell_editing()
	await _test_apply_map_uses_resource_orientation()
	await _test_coordinate_roundtrips()
	await _test_path_highlight_and_connectivity_helpers()
	await _test_apply_map_before_ready_redraws_after_ready()

	if _failures.is_empty():
		print("test_hex_tile_map_layer.gd: all tests passed")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _test_apply_map_and_cell_editing() -> void:
	var data = HexMapData.rectangle(3, 2)
	var wall = HexVector.q_axis()
	data.set_walls([wall])

	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(data))

	_assert_eq(layer.get_cells().size(), 6, "layer exposes all applied cells")
	_assert_true(layer.has_cell(HexVector.zero()), "layer has origin cell")
	_assert_true(layer.is_floor(HexVector.zero()), "origin starts as floor")
	_assert_true(layer.is_wall(wall), "wall cell is queryable")

	layer.set_floor(wall)
	_assert_true(layer.is_floor(wall), "set_floor changes a wall to floor")
	layer.set_wall(HexVector.zero())
	_assert_true(layer.is_wall(HexVector.zero()), "set_wall changes a floor to wall")
	layer.set_wall(HexVector.apply_basis(9, 0, 9))
	_assert_eq(layer.get_floor_cells().size(), 5, "editing ignores cells outside the map")

	layer.queue_free()
	await process_frame


func _test_apply_map_uses_resource_orientation() -> void:
	var data = HexMapData.from_cells([
		HexVector.zero(),
		HexVector.r_axis().negated(),
	])
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame

	layer.apply_map(HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_POINTY_TOP))
	_assert_true(not layer.flat_top, "layer adopts pointy-top resource orientation")
	_assert_eq(layer._tile_map.tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "layer configures pointy-top TileSet axis")
	_assert_true(layer._tile_map.get_used_cells().has(Vector2i(0, -1)), "layer uses pointy-top map cell")

	layer.apply_map(HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_FLAT_TOP))
	_assert_true(layer.flat_top, "layer adopts flat-top resource orientation")
	_assert_eq(layer._tile_map.tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_VERTICAL, "layer configures flat-top TileSet axis")
	_assert_true(layer._tile_map.get_used_cells().has(Vector2i(1, -1)), "layer uses flat-top map cell")

	layer.queue_free()
	await process_frame


func _test_coordinate_roundtrips() -> void:
	var layer = HexTileMapLayer.new()
	layer.hex_size = 10.0
	root.add_child(layer)
	await process_frame

	var points: Array = [
		HexVector.zero(),
		HexVector.q_axis(),
		HexVector.r_axis(),
		HexVector.s_axis(),
		HexVector.q_axis().add(HexVector.r_axis()),
		HexVector.q_axis().scaled(2).subtract(HexVector.r_axis()),
	]

	for flat_top in [true, false]:
		layer.flat_top = flat_top
		for point in points:
			_assert_vector_eq(
				layer.local_to_hex(layer.hex_to_local(point)),
				point,
				"local_to_hex roundtrips hex_to_local flat_top=%s point=%s" % [str(flat_top), point.key()]
			)

	layer.queue_free()
	await process_frame


func _test_path_highlight_and_connectivity_helpers() -> void:
	var data = HexMapData.rectangle(4, 1)
	var bridge = HexVector.q_axis().scaled(2)
	data.set_walls([bridge])

	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(data))

	_assert_true(not layer.is_map_connected(), "layer reports disconnected floor cells")
	_assert_eq(
		layer.find_path(HexVector.zero(), HexVector.q_axis().scaled(3)).size(),
		0,
		"find_path returns empty when floor cells are disconnected"
	)

	layer.set_floor(bridge)
	var expected_path = [
		HexVector.zero(),
		HexVector.q_axis(),
		HexVector.q_axis().scaled(2),
		HexVector.q_axis().scaled(3),
	]
	_assert_keys_eq(
		layer.find_path(HexVector.zero(), HexVector.q_axis().scaled(3)),
		expected_path,
		"find_path follows floor cells after editing"
	)
	_assert_true(layer.is_map_connected(), "layer reports restored connectivity")
	_assert_keys_eq(
		layer.connected_component(HexVector.zero()),
		expected_path,
		"connected_component returns the floor component"
	)

	layer.highlight_cell(HexVector.q_axis(), Color(1.0, 0.0, 0.0))
	_assert_eq(layer._highlights.size(), 1, "highlight_cell stores one highlight")
	layer.clear_highlights()
	_assert_eq(layer._highlights.size(), 0, "clear_highlights clears highlights")

	layer.draw_path(expected_path, Color(0.0, 1.0, 0.0))
	_assert_eq(layer._display_path.size(), 4, "draw_path stores display path")
	layer.clear_path()
	_assert_eq(layer._display_path.size(), 0, "clear_path clears display path")

	layer.queue_free()
	await process_frame


func _test_apply_map_before_ready_redraws_after_ready() -> void:
	var data = HexMapData.rectangle(2, 1)
	var layer = HexTileMapLayer.new()
	layer.apply_map(HexMapResource.from_map_data(data))
	root.add_child(layer)
	await process_frame

	_assert_true(layer.has_cell(HexVector.zero()), "apply_map before ready stores map data")
	_assert_true(layer._tile_map != null, "ready creates the managed TileMapLayer child")

	layer.queue_free()
	await process_frame


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
	result.sort()
	return result
