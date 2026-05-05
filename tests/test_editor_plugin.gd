extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexRandomizer = preload("res://addons/hex_map_kit/core/hex_randomizer.gd")
const HexDistribution = preload("res://addons/hex_map_kit/adapter/hex_distribution.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexMapGenDock = preload("res://addons/hex_map_kit/editor/hex_map_gen_dock.gd")
const HexDistEditor = preload("res://addons/hex_map_kit/editor/hex_dist_editor.gd")

class FakeTileLayer:
	var cleared := false
	var calls: Array = []

	func clear() -> void:
		cleared = true

	func set_cell(map_cell: Vector2i, source_id: int, atlas_coords: Vector2i) -> void:
		calls.append({
			"map_cell": map_cell,
			"source_id": source_id,
			"atlas_coords": atlas_coords,
		})

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_plugin_registration_files()
	await _test_distribution_editor_loads_default_preset_values()
	await _test_distribution_editor_loads_resource_values_and_colors_cells()
	await _test_distribution_editor_close_button_uses_cancel_flow()
	await _test_generation_dock_symmetric_hexagon_minimum_radii()
	await _test_generation_dock_applies_configured_tile_entries()
	await _test_generation_dock_applies_orientation_to_tile_entries()
	await _test_generation_dock_resource_stores_orientation()
	await _test_generation_dock_configures_tile_map_layer_tileset()
	await _test_generation_dock_generate_and_apply_refreshes_map()

	if _failures.is_empty():
		print("test_editor_plugin.gd: all tests passed")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _test_plugin_registration_files() -> void:
	var config = ConfigFile.new()
	var error = config.load("res://addons/hex_map_kit/plugin.cfg")
	_assert_eq(error, OK, "plugin.cfg loads")
	_assert_eq(config.get_value("plugin", "name", ""), "Hex Map Kit", "plugin.cfg has addon name")
	var script_path = "res://addons/hex_map_kit/%s" % config.get_value("plugin", "script", "")
	_assert_true(load(script_path) != null, "plugin.cfg script can be loaded")


func _test_distribution_editor_loads_default_preset_values() -> void:
	var editor = HexDistEditor.new()
	root.add_child(editor)
	await process_frame

	var expected = HexDistribution.from_preset_id(
		HexRandomizer.get_preset_id(HexRandomizer.get_preset_names()[0])
	)
	_assert_eq(_spin_values(editor._d3_spins), expected.distribution_3, "distribution editor shows preset 3-neighbor values")
	_assert_eq(_spin_values(editor._d2_spins), expected.distribution_2, "distribution editor shows preset 2-neighbor values")
	_assert_eq(_spin_values(editor._d1_spins), expected.distribution_1, "distribution editor shows preset 1-neighbor values")
	_assert_eq(editor._pattern_controls.size(), 14, "distribution editor tracks every pattern control")

	editor.queue_free()
	await process_frame


func _test_distribution_editor_loads_resource_values_and_colors_cells() -> void:
	var path = "res://.godot_user/test_hex_distribution_editor.tres"
	var custom = HexDistribution.new(
		[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0],
		[0.5, 2.5, 4.5, 6.5],
		[1.5, 7.5]
	)
	_save_distribution(path, custom)

	var editor = HexDistEditor.new(path)
	root.add_child(editor)
	await process_frame

	_assert_eq(_spin_values(editor._d3_spins), custom.distribution_3, "distribution editor loads custom 3-neighbor values")
	_assert_eq(_spin_values(editor._d2_spins), custom.distribution_2, "distribution editor loads custom 2-neighbor values")
	_assert_eq(_spin_values(editor._d1_spins), custom.distribution_1, "distribution editor loads custom 1-neighbor values")
	_assert_eq(editor._editing_path, path, "distribution editor keeps the loaded resource path")
	_assert_true(not editor._save_button.disabled, "distribution editor enables apply for loaded resources")

	editor._d3_spins[0].value = 8.0
	editor._on_spin_changed(8.0, 3, 0)
	_assert_color_approx(
		editor._center_color(3, 0),
		Color(0.1, 0.1, 0.1),
		"distribution editor center color follows spin value"
	)

	editor.queue_free()
	await process_frame


func _test_distribution_editor_close_button_uses_cancel_flow() -> void:
	var state := {"count": 0}
	var editor = HexDistEditor.new("", Callable(), Callable(self, "_count_cancel").bind(state))
	root.add_child(editor)
	await process_frame

	editor.emit_signal("close_requested")
	await process_frame

	_assert_eq(state["count"], 1, "distribution editor window close calls cancel callback")


func _test_generation_dock_symmetric_hexagon_minimum_radii() -> void:
	var dock = HexMapGenDock.new()
	root.add_child(dock)
	await process_frame

	dock._generate_option.select(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_HEXAGON)
	dock._wall_prob_slider.value = 1.0
	dock._connectivity_check.button_pressed = true
	dock._refresh_controls()
	for radius in [1, 2]:
		dock._gen_radius_spin.value = radius
		dock._generate_map()

		var data = dock._current_data
		var hex_cell_count = 1 + 3 * radius * (radius + 1)
		_assert_eq(data.cells.size(), hex_cell_count, "generation dock creates radius %d symmetric hexagon cells" % radius)
		_assert_eq(data.walls.size(), hex_cell_count - 1, "generation dock radius %d symmetric hexagon uses wall probability" % radius)
		_assert_true(HexMapGenerator.is_floor_connected(data), "generation dock radius %d symmetric hexagon completes connectivity" % radius)
		_assert_true(dock._stats_label.text.contains("Hex-inward Markov mesh model"), "generation dock stats include generation mode")

	dock.queue_free()
	await process_frame


func _test_generation_dock_applies_configured_tile_entries() -> void:
	var dock = HexMapGenDock.new()
	root.add_child(dock)
	await process_frame

	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	dock._current_data = data
	dock._floor_source_spin.value = 4
	dock._floor_atlas_x_spin.value = 2
	dock._floor_atlas_y_spin.value = 3
	dock._wall_source_spin.value = 5
	dock._wall_atlas_x_spin.value = 6
	dock._wall_atlas_y_spin.value = 7

	var fake_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_data_to_tile_map_layer(fake_layer), "generation dock applies current data to a layer")
	_assert_true(fake_layer.cleared, "generation dock clears target layer before applying")
	_assert_eq(fake_layer.calls.size(), 2, "generation dock emits one tile entry per cell")
	_assert_eq(fake_layer.calls[0]["map_cell"], Vector2i.ZERO, "generation dock applies floor cell position")
	_assert_eq(fake_layer.calls[0]["source_id"], 4, "generation dock applies configured floor source")
	_assert_eq(fake_layer.calls[0]["atlas_coords"], Vector2i(2, 3), "generation dock applies configured floor atlas")
	_assert_eq(fake_layer.calls[1]["map_cell"], Vector2i(1, 0), "generation dock applies wall cell position")
	_assert_eq(fake_layer.calls[1]["source_id"], 5, "generation dock applies configured wall source")
	_assert_eq(fake_layer.calls[1]["atlas_coords"], Vector2i(6, 7), "generation dock applies configured wall atlas")

	dock.queue_free()
	await process_frame


func _test_generation_dock_applies_orientation_to_tile_entries() -> void:
	var dock = HexMapGenDock.new()
	root.add_child(dock)
	await process_frame

	dock._current_data = HexMapData.from_cells([
		HexVector.zero(),
		HexVector.r_axis().negated(),
	])
	dock._tile_orientation_option.select(1)

	var fake_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_data_to_tile_map_layer(fake_layer), "generation dock applies pointy-top data")
	_assert_eq(fake_layer.calls[0]["map_cell"], Vector2i(0, -1), "pointy-top uses Horizontal Offset map cell")
	_assert_eq(fake_layer.calls[1]["map_cell"], Vector2i.ZERO, "pointy-top keeps origin map cell")

	dock._tile_orientation_option.select(0)
	fake_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_data_to_tile_map_layer(fake_layer), "generation dock applies flat-top data")
	_assert_eq(fake_layer.calls[0]["map_cell"], Vector2i(1, -1), "flat-top uses Vertical Offset map cell")
	_assert_eq(fake_layer.calls[1]["map_cell"], Vector2i.ZERO, "flat-top keeps origin map cell")

	dock.queue_free()
	await process_frame


func _test_generation_dock_resource_stores_orientation() -> void:
	var dock = HexMapGenDock.new()
	root.add_child(dock)
	await process_frame

	dock._current_data = HexMapData.rectangle(1, 1)
	dock._tile_orientation_option.select(1)
	var resource = dock.current_resource()

	_assert_eq(resource.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "generation dock saves pointy-top orientation to resource")
	_assert_eq(resource.cells.size(), 1, "generation dock saved resource keeps map data")

	dock.queue_free()
	await process_frame


func _test_generation_dock_configures_tile_map_layer_tileset() -> void:
	var dock = HexMapGenDock.new()
	root.add_child(dock)
	await process_frame

	dock._current_data = HexMapData.rectangle(1, 1)
	dock._tile_orientation_option.select(1)
	dock._tile_width_spin.value = 96
	dock._tile_height_spin.value = 84

	var layer = TileMapLayer.new()
	_assert_true(dock.apply_current_data_to_tile_map_layer(layer), "generation dock applies to a TileMapLayer")
	_assert_true(layer.tile_set != null, "generation dock creates a TileSet when configuring TileMapLayer")
	_assert_eq(layer.tile_set.tile_shape, TileSet.TILE_SHAPE_HEXAGON, "generation dock configures TileSet shape")
	_assert_eq(layer.tile_set.tile_layout, TileSet.TILE_LAYOUT_STACKED, "generation dock configures TileSet layout")
	_assert_eq(layer.tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "generation dock maps pointy-top to Horizontal Offset")
	_assert_eq(layer.tile_set.tile_size, Vector2i(96, 84), "generation dock configures TileSet tile size")

	layer.free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_generate_and_apply_refreshes_map() -> void:
	var dock = HexMapGenDock.new()
	root.add_child(dock)
	await process_frame

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.value = 2
	dock._rect_height_spin.value = 1
	dock._wall_prob_slider.value = 0.0
	dock._refresh_controls()

	var fake_layer = FakeTileLayer.new()
	_assert_true(dock.generate_and_apply_to_tile_map_layer(fake_layer), "generation dock generate-and-apply succeeds")
	_assert_eq(dock._current_data.cells.size(), 2, "generate-and-apply regenerates current data from controls")
	_assert_eq(dock._current_data.walls.size(), 0, "generate-and-apply uses current wall probability")
	_assert_eq(fake_layer.calls.size(), 2, "generate-and-apply emits regenerated cells")

	dock.queue_free()
	await process_frame


func _save_distribution(path: String, distribution: HexDistribution) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.godot_user"))
	var error = ResourceSaver.save(distribution, path)
	_assert_eq(error, OK, "test distribution resource saves")


func _count_cancel(state: Dictionary) -> void:
	state["count"] += 1


func _spin_values(spins: Array) -> Array:
	var result: Array = []
	for spin in spins:
		result.append(float(spin.value))
	return result


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _assert_color_approx(actual: Color, expected: Color, message: String) -> void:
	if not is_equal_approx(actual.r, expected.r) \
		or not is_equal_approx(actual.g, expected.g) \
		or not is_equal_approx(actual.b, expected.b) \
		or not is_equal_approx(actual.a, expected.a):
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])
