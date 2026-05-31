extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexGrid = preload("res://addons/hex_map_kit/core/hex_grid.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")

class RuntimeSignalRecorder:
	var clicked_cells: Array = []
	var clicked_hits: Array = []
	var hovered_cells: Array = []
	var hovered_hits: Array = []

	func record_cell_clicked(hex, _event) -> void:
		clicked_cells.append(hex)

	func record_hit_clicked(hit: Dictionary, _event) -> void:
		clicked_hits.append(hit)

	func record_cell_hovered(hex) -> void:
		hovered_cells.append(hex)

	func record_hit_hovered(hit: Dictionary) -> void:
		hovered_hits.append(hit)

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await _test_apply_map_and_cell_editing()
	await _test_apply_map_uses_resource_orientation()
	await _test_coordinate_roundtrips()
	await _test_path_highlight_and_connectivity_helpers()
	await _test_runtime_input_signals_use_cell_hit()
	await _test_local_to_cell_hit_wraps_toric_visual_cell()
	await _test_infinite_loop_mode_keeps_visual_cell_identity()
	await _test_visual_representatives_for_toric_cell()
	await _test_visual_path_for_toric_path_uses_nearest_representatives()
	await _test_connected_component_from_local_matches_core()
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


func _test_runtime_input_signals_use_cell_hit() -> void:
	var layer = HexTileMapLayer.new()
	var recorder = RuntimeSignalRecorder.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(HexMapData.rectangle(2, 1)))
	layer.cell_clicked.connect(Callable(recorder, "record_cell_clicked"))
	layer.cell_hit_clicked.connect(Callable(recorder, "record_hit_clicked"))
	layer.cell_hovered.connect(Callable(recorder, "record_cell_hovered"))
	layer.cell_hit_hovered.connect(Callable(recorder, "record_hit_hovered"))

	var target = HexVector.q_axis()
	var target_position = layer.to_global(layer._tile_map.position + layer.hex_to_local(target))
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = target_position
	layer._unhandled_input(press)

	var motion = InputEventMouseMotion.new()
	motion.position = target_position
	layer._unhandled_input(motion)
	layer._unhandled_input(motion)

	_assert_eq(recorder.clicked_cells.size(), 1, "runtime layer emits one clicked cell signal")
	_assert_vector_eq(recorder.clicked_cells[0], target, "clicked cell signal uses canonical hit cell")
	_assert_eq(recorder.clicked_hits.size(), 1, "runtime layer emits detailed click hit")
	_assert_vector_eq(recorder.clicked_hits[0]["visual_hex"], target, "click hit includes visual cell")
	_assert_eq(recorder.hovered_cells.size(), 1, "runtime layer emits hover once for the same hit")
	_assert_eq(recorder.hovered_hits.size(), 1, "runtime layer emits detailed hover hit")

	layer.queue_free()
	await process_frame


func _test_local_to_cell_hit_wraps_toric_visual_cell() -> void:
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(HexMapData.square(3, true)))
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	var visual = HexVector.apply_basis(3, 0, 0)
	var hit = layer.local_to_cell_hit(layer._tile_map.position + layer.hex_to_local(visual))

	_assert_vector_eq(hit["visual_hex"], visual, "toric hit keeps visual representative")
	_assert_vector_eq(hit["hex"], HexVector.zero(), "toric hit wraps visual representative to canonical cell")
	_assert_true(hit["exists"], "toric hit exists when canonical cell exists")

	layer.queue_free()
	await process_frame


func _test_infinite_loop_mode_keeps_visual_cell_identity() -> void:
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(HexMapData.square(3, true)))
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_INFINITE
	var visual = HexVector.apply_basis(3, 0, 0)
	var hit = layer.local_to_cell_hit(layer._tile_map.position + layer.hex_to_local(visual))

	_assert_vector_eq(hit["hex"], visual, "infinite hit keeps visual cell as canonical identity")
	_assert_true(not bool(hit["exists"]), "infinite hit does not collapse outside finite resource into toric cell")

	layer.queue_free()
	await process_frame


func _test_visual_representatives_for_toric_cell() -> void:
	var layer = HexTileMapLayer.new()
	layer.hex_size = 10.0
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(HexMapData.square(3, true)))
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	var visual = HexVector.apply_basis(-3, 0, 0)
	var rect = Rect2(layer.hex_to_local(visual) - Vector2.ONE, Vector2(2, 2))
	var reps = layer.visual_representatives_for_cell(HexVector.zero(), rect, 0)

	_assert_keys_eq(reps, [visual], "toric visual representatives include the visible period copy only")

	var far_visual = HexVector.apply_basis(9, 0, 0)
	var far_rect = Rect2(layer.hex_to_local(far_visual) - Vector2.ONE, Vector2(2, 2))
	var far_reps = layer.visual_representatives_for_cell(HexVector.zero(), far_rect, 0)
	_assert_keys_eq(far_reps, [far_visual], "toric visual representatives honor far-from-origin display rects")

	layer.queue_free()
	await process_frame


func _test_visual_path_for_toric_path_uses_nearest_representatives() -> void:
	var layer = HexTileMapLayer.new()
	layer.hex_size = 10.0
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(HexMapData.square(3, true)))
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	var canonical_path = [
		HexVector.zero(),
		HexVector.apply_basis(2, 0, 0),
	]
	var visual_path = layer.visual_path_for_canonical_path(canonical_path)
	var wrapped_visual = HexVector.q_axis().scaled(-1)
	var canonical_distance = layer.hex_to_local(canonical_path[0]).distance_to(layer.hex_to_local(canonical_path[1]))
	var visual_distance = layer.hex_to_local(visual_path[0]).distance_to(layer.hex_to_local(visual_path[1]))

	_assert_keys_eq(visual_path, [HexVector.zero(), wrapped_visual], "toric visual path chooses adjacent representative across wrap")
	_assert_true(visual_distance < canonical_distance, "toric visual path is shorter than canonical jump")
	layer.draw_loop_path(canonical_path)
	_assert_keys_eq(layer._display_path, visual_path, "draw_loop_path stores visual representatives")

	layer.queue_free()
	await process_frame


func _test_connected_component_from_local_matches_core() -> void:
	var data = HexMapData.rectangle(3, 1)
	data.set_walls([HexVector.q_axis()])
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(data))
	var target = HexVector.q_axis().scaled(2)
	var component = layer.connected_component_from_local(layer._tile_map.position + layer.hex_to_local(target))
	var expected = HexGrid.connected_area(target, data.floor_cells(), data.cyclic_size)

	_assert_keys_eq(component, expected, "connected_component_from_local uses canonical hit cell")
	layer.highlight_connected_component(target, Color(0.0, 0.5, 1.0))
	_assert_eq(layer._highlights.size(), expected.size(), "highlight_connected_component stores component highlights")

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
