extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexRandomizer = preload("res://addons/hex_map_kit/core/hex_randomizer.gd")
const HexDistribution = preload("res://addons/hex_map_kit/adapter/hex_distribution.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexOverlayData = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexOverlayResource = preload("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexMapGenDock = preload("res://addons/hex_map_kit/editor/hex_map_gen_dock.gd")
const HexDistEditor = preload("res://addons/hex_map_kit/editor/hex_dist_editor.gd")
const HexAdjacencyRuleEditor = preload("res://addons/hex_map_kit/editor/hex_adjacency_rule_editor.gd")

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
	await _test_distribution_editor_manages_recent_custom_and_duplicate_preset()
	await _test_adjacency_rule_editor_applies_rule_text()
	await _test_generation_dock_symmetric_hexagon_minimum_radii()
	await _test_generation_dock_torus_connectivity_controls()
	await _test_generation_dock_torus_connectivity_generation()
	await _test_generation_dock_tracks_generation_progress_state()
	await _test_generation_dock_only_generates_from_generate_button()
	await _test_generation_dock_wires_core_progress_and_cancel()
	await _test_generation_dock_applies_configured_tile_entries()
	await _test_generation_dock_applies_orientation_to_tile_entries()
	await _test_generation_dock_resource_stores_orientation()
	await _test_generation_dock_configures_tile_map_layer_tileset()
	await _test_generation_dock_swaps_tile_size_on_orientation_change()
	await _test_generation_dock_lists_and_auto_applies_selected_tile_layer()
	await _test_generation_dock_disambiguates_duplicate_target_names()
	await _test_generation_dock_adds_new_target_layer()
	await _test_generation_dock_duplicates_shared_tileset_for_selected_layer()
	await _test_generation_dock_sets_up_sample_tiles()
	await _test_generation_dock_selects_atlas_image()
	await _test_generation_dock_generate_auto_applies_current_map()
	await _test_generation_dock_overlay_uniform_generation_and_apply()
	await _test_generation_dock_overlay_limit_and_apply_policy()
	await _test_generation_dock_overlay_placement_mask_filters_candidates()
	await _test_generation_dock_overlay_adjacency_reference_generation()
	await _test_generation_dock_overlay_item_pool_tile_mapping()
	await _test_generation_dock_mapdata_source_registry_load_reload_clear()
	await _test_generation_dock_mapdata_query_rows_evaluate_offset_and_toric()
	await _test_generation_dock_mapdata_crop_result_and_reset_rules()
	await _test_generation_dock_mapdata_crop_off_stacks_overlay_sources()
	await _test_generation_dock_generate_history_saves_overlay_delta_source()

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


func _test_distribution_editor_manages_recent_custom_and_duplicate_preset() -> void:
	HexDistEditor.clear_recent_distributions()
	var path = "res://.godot_user/test_hex_distribution_duplicate.tres"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.godot_user"))

	var editor = HexDistEditor.new()
	root.add_child(editor)
	await process_frame

	var expected = HexDistribution.from_preset_id(
		HexRandomizer.get_preset_id(HexRandomizer.get_preset_names()[0])
	)
	_assert_true(editor._duplicate_preset_button != null, "distribution editor exposes duplicate preset button")
	_assert_eq(editor._duplicate_preset_button.text, "Duplicate Preset...", "distribution editor labels duplicate preset flow")
	_assert_true(editor.save_current_distribution_as(path), "distribution editor saves current preset as custom distribution")
	_assert_eq(HexDistEditor.recent_distribution_paths(), [path], "distribution editor remembers saved custom distribution")
	_assert_eq(editor._editing_path, path, "distribution editor switches to saved custom distribution")
	var saved = load(path)
	_assert_true(saved is HexDistribution, "duplicate preset save creates HexDistribution resource")
	_assert_eq(saved.distribution_3, expected.distribution_3, "duplicate preset save keeps preset 3-neighbor values")
	_assert_eq(saved.distribution_2, expected.distribution_2, "duplicate preset save keeps preset 2-neighbor values")
	_assert_eq(saved.distribution_1, expected.distribution_1, "duplicate preset save keeps preset 1-neighbor values")

	editor.queue_free()
	await process_frame

	var recent_editor = HexDistEditor.new()
	root.add_child(recent_editor)
	await process_frame
	_assert_eq(recent_editor._recent_option.item_count, 1, "distribution editor lists recent custom distributions")
	_assert_eq(recent_editor._recent_option.get_item_text(0), path, "distribution editor shows recent custom path")
	recent_editor._on_recent_selected(0)
	_assert_eq(recent_editor._editing_path, path, "distribution editor loads custom distribution from recent list")
	_assert_eq(_spin_values(recent_editor._d3_spins), expected.distribution_3, "recent custom load restores saved values")

	recent_editor.queue_free()
	await process_frame


func _test_adjacency_rule_editor_applies_rule_text() -> void:
	var state := {"rules": "", "count": 0}
	var editor = HexAdjacencyRuleEditor.new(
		"default=0.2",
		Callable(self, "_capture_rules").bind(state),
		Callable(self, "_count_cancel").bind(state)
	)
	root.add_child(editor)
	await process_frame

	_assert_eq(editor._rules_edit.text, "default=0.2", "adjacency rule editor loads initial rule text")
	editor._rules_edit.text = "1=0.8;default=0.1"
	editor._on_apply_pressed()
	await process_frame

	_assert_eq(state["rules"], "1=0.8;default=0.1", "adjacency rule editor apply returns rule text")
	_assert_eq(state["count"], 0, "adjacency rule editor apply does not call cancel")


func _test_generation_dock_symmetric_hexagon_minimum_radii() -> void:
	var dock = await _new_ready_dock()

	dock._generate_option.select(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_HEXAGON)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._connect_method_option.select(1)
	dock._refresh_controls()
	for radius in [1, 2]:
		dock._gen_radius_spin.set_value_no_signal(radius)
		_assert_true(await dock._generate_map(), "generation dock completes radius %d symmetric hexagon generation" % radius)

		var data = dock._current_data
		var hex_cell_count = 1 + 3 * radius * (radius + 1)
		_assert_eq(data.cells.size(), hex_cell_count, "generation dock creates radius %d symmetric hexagon cells" % radius)
		_assert_true(data.walls.size() > 0, "generation dock radius %d symmetric hexagon creates walls" % radius)
		_assert_true(data.walls.size() <= hex_cell_count - 1, "generation dock radius %d symmetric hexagon keeps protected floor" % radius)
		_assert_true(HexMapGenerator.is_floor_connected(data), "generation dock radius %d symmetric hexagon completes connectivity" % radius)
		_assert_true(
			dock._stats_label.text.contains(HexMapGenDock.GENERATE_NAMES[HexMapGenDock.GENERATE_SYMMETRIC]),
			"generation dock stats include generation mode"
		)

	dock.queue_free()
	await process_frame


func _test_generation_dock_torus_connectivity_controls() -> void:
	var dock = await _new_ready_dock()

	_assert_eq(dock._generate_option.selected, HexMapGenDock.GENERATE_SYMMETRIC, "generation dock defaults to symmetric generator")
	_assert_true(dock._torus_connectivity_check.visible, "toric connection is visible for symmetric generation")
	_assert_true(not dock._torus_connectivity_check.disabled, "toric connection is enabled for symmetric generation")

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._on_generate_changed(HexMapGenDock.GENERATE_SIMPLE)
	await process_frame
	_assert_true(not dock._torus_connectivity_check.visible, "toric connection is hidden for simple generation")
	_assert_true(dock._torus_connectivity_check.disabled, "toric connection is disabled for simple generation")

	dock._generate_option.select(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._on_generate_changed(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_HEXAGON)
	dock._on_symmetric_shape_changed(HexMapGenDock.SHAPE_HEXAGON)
	dock._torus_connectivity_check.set_pressed_no_signal(true)
	dock._on_torus_connectivity_toggled(true)
	await process_frame
	_assert_eq(dock._shape_option_symmetric.selected, HexMapGenDock.SHAPE_RECTANGLE, "toric connection selects symmetric square")
	_assert_true(dock._torus_connectivity_check.button_pressed, "toric connection remains on after selecting square")

	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_HEXAGON)
	dock._on_symmetric_shape_changed(HexMapGenDock.SHAPE_HEXAGON)
	await process_frame
	_assert_true(not dock._torus_connectivity_check.button_pressed, "symmetric hexagon turns toric connection off")

	_begin_manual_generation(dock, false)
	_assert_true(dock._torus_connectivity_check.disabled, "toric connection is disabled while generation is running")
	dock._finish_generation(true)

	dock.queue_free()
	await process_frame


func _test_generation_dock_torus_connectivity_generation() -> void:
	var dock = await _new_ready_dock()

	dock._generate_option.select(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._on_generate_changed(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._on_symmetric_shape_changed(HexMapGenDock.SHAPE_RECTANGLE)
	dock._gen_radius_spin.set_value_no_signal(2)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._connect_method_option.select(_connect_method_index(HexMapGenerator.CONNECT_NONE))
	dock._torus_connectivity_check.set_pressed_no_signal(false)
	dock._refresh_controls()

	_assert_true(await dock._generate_map(), "generation dock completes non-toric symmetric square generation")
	_assert_eq(dock._current_data.cyclic_size, 0, "symmetric square without toric connection is non-toric")

	dock._torus_connectivity_check.set_pressed_no_signal(true)
	dock._on_torus_connectivity_toggled(true)
	_assert_true(await dock._generate_map(), "generation dock completes toric symmetric square generation")
	_assert_eq(dock._current_data.cyclic_size, 5, "symmetric square with toric connection uses toric size")

	dock.queue_free()
	await process_frame


func _test_generation_dock_tracks_generation_progress_state() -> void:
	var dock = await _new_ready_dock()

	var idle_status = dock.generation_status()
	_assert_true(not idle_status["running"], "generation dock is not running before Generate")
	_assert_true(not idle_status["cancel_requested"], "generation dock has no cancel request before Generate")
	_assert_eq(idle_status["progress"], 0.0, "generation dock starts with zero progress")
	_assert_eq(idle_status["status"], "Ready", "generation dock starts ready")
	_assert_eq(dock._generation_id, 0, "generation dock does not auto generate on creation")
	_assert_eq(dock._current_data, null, "generation dock starts without generated data")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on creation")
	_assert_eq(_window_child_count(dock), 0, "generation dock has no modal progress window on creation")

	dock._on_generate_pressed()
	await _wait_for_progress_controls(dock, "Generate button generation")
	await _wait_for_generation(dock, "Generate button generation")
	var ready_status = dock.generation_status()
	_assert_true(not ready_status["running"], "generation dock clears running state after Generate")
	_assert_true(not ready_status["cancel_requested"], "generation dock clears cancel request after Generate")
	_assert_eq(ready_status["progress"], 1.0, "generation dock reports completed progress")
	_assert_eq(ready_status["status"], "Ready", "generation dock reports ready status")
	_assert_true(_progress_controls_visible(dock), "generation dock keeps Generate progress visible after fast generation")
	_assert_true(dock._generation_progress_cancel_button.disabled, "generation dock disables progress cancel after Generate finish")
	_assert_eq(_window_child_count(dock), 0, "generation dock does not create modal progress window for Generate")
	await _wait_seconds(HexMapGenDock.GENERATION_PROGRESS_MIN_VISIBLE_SEC + 0.1)
	_assert_true(_progress_controls_hidden(dock), "generation dock hides Generate progress after minimum display time")

	_begin_manual_generation(dock, true)
	await _wait_for_progress_controls(dock, "manual successful generation")
	_assert_true(not dock._generation_progress_cancel_button.disabled, "generation dock enables progress cancel while running")
	dock._generation_progress_visible_started_msec = Time.get_ticks_msec()
	dock._finish_generation(false)
	var finished_status = dock.generation_status()
	_assert_true(not finished_status["running"], "generation dock clears running state immediately after successful finish")
	_assert_eq(finished_status["status"], "Ready", "generation dock reports ready before progress hide delay completes")
	_assert_true(_progress_controls_visible(dock), "generation dock keeps success progress visible for minimum display time")
	_assert_true(dock._generation_progress_cancel_button.disabled, "generation dock disables progress cancel after successful finish")
	await _wait_seconds(HexMapGenDock.GENERATION_PROGRESS_MIN_VISIBLE_SEC + 0.1)
	_assert_true(_progress_controls_hidden(dock), "generation dock hides success progress after minimum display time")

	_begin_manual_generation(dock, true)
	await _wait_for_progress_controls(dock, "manual cancelled generation")
	dock.request_generation_cancel()
	var cancel_status = dock.generation_status()
	_assert_true(cancel_status["running"], "generation dock keeps running state after cancel request")
	_assert_true(cancel_status["cancel_requested"], "generation dock stores cancel request state")
	_assert_eq(cancel_status["status"], "Cancel requested", "generation dock reports cancel request status")
	_assert_true(dock._generation_progress_cancel_button.disabled, "generation dock disables progress cancel after cancel request")

	dock._finish_generation(true)
	var cancelled_status = dock.generation_status()
	_assert_true(not cancelled_status["running"], "generation dock clears running state after cancelled finish")
	_assert_true(not cancelled_status["cancel_requested"], "generation dock clears cancel request after cancelled finish")
	_assert_eq(cancelled_status["status"], "Cancelled", "generation dock reports cancelled status")
	_assert_true(_progress_controls_hidden(dock), "generation dock hides progress after cancellation")

	dock.queue_free()
	await process_frame


func _test_generation_dock_only_generates_from_generate_button() -> void:
	var dock = await _new_ready_dock()

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._connect_method_option.select(0)
	dock._refresh_controls()

	var generation_id = dock._generation_id
	dock._rect_width_spin.value = 2
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on SpinBox value change")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on SpinBox value change")

	dock._rect_width_spin.emit_signal("focus_exited")
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on focus exit")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on focus exit")

	dock._generate_option.select(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._gen_radius_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._on_generate_changed(HexMapGenDock.GENERATE_SYMMETRIC)
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on generator selection change")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on generator selection change")

	dock._wall_prob_slider.value = 0.25
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on slider value change")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on slider value change")

	dock._on_dist_changed(0)
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on dist selection change")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on dist selection change")

	dock._on_seed_randomize()
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on seed randomize")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on seed randomize")

	dock._on_generate_pressed()
	await _wait_for_progress_controls(dock, "explicit Generate button generation")
	await _wait_for_generation(dock, "explicit Generate button generation")
	_assert_eq(dock._generation_id, generation_id + 1, "generation dock regenerates immediately from Generate")
	_assert_true(
		dock._stats_label.text.contains(HexMapGenDock.GENERATE_NAMES[HexMapGenDock.GENERATE_SYMMETRIC]),
		"Generate button updates generator mode"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_wires_core_progress_and_cancel() -> void:
	var dock = await _new_ready_dock()

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._connect_method_option.select(0)
	dock._refresh_controls()
	await dock._generate_map()
	var completed_data = dock._current_data

	dock._rect_width_spin.set_value_no_signal(20)
	dock._rect_height_spin.set_value_no_signal(20)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._connect_method_option.select(0)
	dock._generation_chunk_size = 1
	dock._generation_progress_delay_usec = 5000
	dock._refresh_controls()

	dock._generate_map(true)
	await _wait_for_core_progress(dock)
	await _wait_for_progress_controls(dock, "long threaded generation")
	_assert_true(not dock._generation_progress_cancel_button.disabled, "generation dock shows cancellable progress for long generation")
	_assert_eq(_window_child_count(dock), 0, "generation dock does not create modal progress window for long generation")
	dock.request_generation_cancel()
	await _wait_for_generation(dock, "cancelled threaded generation")

	var cancelled_status = dock.generation_status()
	_assert_eq(cancelled_status["status"], "Cancelled", "generation dock reports threaded cancellation")
	_assert_true(dock._generation_core_progress_event_count > 0, "generation dock receives core progress callback events")
	_assert_true(dock._generation_cancel_poll_count > 0, "generation dock exposes cancel state through core cancel callback")
	_assert_true(dock._generation_last_core_progress > 0.0, "generation dock records non-hardcoded core progress")
	_assert_eq(dock._current_data, completed_data, "generation dock keeps last completed map when cancel returns partial data")

	dock.queue_free()
	await process_frame


func _test_generation_dock_applies_configured_tile_entries() -> void:
	var dock = await _new_ready_dock()

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
	var dock = await _new_ready_dock()

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
	var dock = await _new_ready_dock()

	dock._current_data = HexMapData.rectangle(1, 1)
	dock._tile_orientation_option.select(1)
	var resource = dock.current_resource()

	_assert_eq(resource.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "generation dock saves pointy-top orientation to resource")
	_assert_eq(resource.cells.size(), 1, "generation dock saved resource keeps map data")

	dock.queue_free()
	await process_frame


func _test_generation_dock_configures_tile_map_layer_tileset() -> void:
	var dock = await _new_ready_dock()

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


func _test_generation_dock_swaps_tile_size_on_orientation_change() -> void:
	var dock = await _new_ready_dock()

	dock._tile_width_spin.value = 80
	dock._tile_height_spin.value = 72
	dock._tile_orientation_option.select(1)
	dock._on_tile_orientation_changed(1)
	_assert_eq(Vector2i(int(dock._tile_width_spin.value), int(dock._tile_height_spin.value)), Vector2i(72, 80), "pointy-top switch swaps tile size controls")

	dock._tile_orientation_option.select(0)
	dock._on_tile_orientation_changed(0)
	_assert_eq(Vector2i(int(dock._tile_width_spin.value), int(dock._tile_height_spin.value)), Vector2i(80, 72), "flat-top switch swaps tile size controls back")

	dock.queue_free()
	await process_frame


func _test_generation_dock_lists_and_auto_applies_selected_tile_layer() -> void:
	var dock = await _new_ready_dock()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var first_layer = TileMapLayer.new()
	first_layer.name = "FirstLayer"
	scene_root.add_child(first_layer)
	var second_layer = TileMapLayer.new()
	second_layer.name = "SecondLayer"
	scene_root.add_child(second_layer)
	await process_frame

	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	dock._current_data = data
	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.item_count, 4, "generation dock lists Auto, TileMapLayers, and add new layer")
	_assert_eq(dock._tile_layer_option.get_item_text(0), "Auto: Selected / first scene layer", "generation dock keeps Auto target")
	_assert_eq(dock._tile_layer_option.get_item_text(1), "FirstLayer", "generation dock shows short first TileMapLayer name")
	_assert_eq(dock._tile_layer_option.get_item_text(2), "SecondLayer", "generation dock shows short second TileMapLayer name")
	_assert_eq(dock._tile_layer_option.get_item_text(3), "Add new layer...", "generation dock exposes add new layer target")
	dock._tile_layer_option.select(2)
	_assert_eq(dock.selected_tile_map_layer(), second_layer, "generation dock returns selected TileMapLayer")
	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.get_item_text(0), "Auto: Selected / first scene layer", "generation dock keeps Auto after refresh")
	_assert_eq(dock.selected_tile_map_layer(), second_layer, "generation dock preserves selected TileMapLayer after refresh")

	dock._tile_layer_option.select(1)
	dock._set_editor_selected_tile_map_layer_for_test(second_layer)
	dock._on_sample_tiles_pressed()
	_assert_eq(first_layer.tile_set, null, "sample tile setup ignores Target and does not touch unselected TileMapLayer")
	_assert_true(second_layer.tile_set != null, "sample tile setup uses editor-selected TileMapLayer")
	dock._floor_atlas_x_spin.value = 1
	dock._wall_atlas_x_spin.value = 0

	_assert_eq(first_layer.get_used_cells().size(), 0, "tile setting auto apply ignores Target and does not touch unselected TileMapLayer")
	_assert_eq(second_layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "floor SpinBox change reapplies editor-selected TileMapLayer")
	_assert_eq(second_layer.get_cell_atlas_coords(Vector2i(1, 0)), Vector2i(0, 0), "wall SpinBox change reapplies editor-selected TileMapLayer")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_disambiguates_duplicate_target_names() -> void:
	var dock = await _new_ready_dock()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var group_a = Node2D.new()
	group_a.name = "Terrain"
	scene_root.add_child(group_a)
	var group_b = Node2D.new()
	group_b.name = "Overlay"
	scene_root.add_child(group_b)
	var terrain_layer = TileMapLayer.new()
	terrain_layer.name = "Layer"
	group_a.add_child(terrain_layer)
	var overlay_layer = TileMapLayer.new()
	overlay_layer.name = "Layer"
	group_b.add_child(overlay_layer)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.get_item_text(1), "Terrain/Layer", "duplicate Target names show short scene tree path")
	_assert_eq(dock._tile_layer_option.get_item_text(2), "Overlay/Layer", "duplicate Target names include parent path")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_adds_new_target_layer() -> void:
	var dock = await _new_ready_dock()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.item_count, 2, "empty Target list still shows Auto and add new layer")
	_assert_eq(dock._tile_layer_option.get_item_text(0), "Auto: Selected / first scene layer", "empty Target list keeps Auto")
	_assert_eq(dock._tile_layer_option.get_item_text(1), "Add new layer...", "empty Target list keeps add new layer")

	var add_index = dock._add_tile_layer_option_index()
	dock._tile_layer_option.select(add_index)
	dock._on_tile_layer_target_selected(add_index)
	await process_frame

	var added_layer = dock.selected_tile_map_layer()
	_assert_true(added_layer is TileMapLayer, "add new layer creates a TileMapLayer")
	_assert_eq(added_layer.get_parent(), scene_root, "add new layer places TileMapLayer under scene root")
	_assert_true(String(added_layer.name).begins_with("HexMapLayer"), "add new layer uses HexMapLayer base name")
	_assert_eq(dock._tile_layer_option.selected, 1, "add new layer selects the created Target")
	_assert_eq(dock._find_editor_selected_tile_map_layer(), added_layer, "add new layer selects the created TileMapLayer")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_duplicates_shared_tileset_for_selected_layer() -> void:
	var dock = await _new_ready_dock()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var first_layer = TileMapLayer.new()
	first_layer.name = "FirstLayer"
	scene_root.add_child(first_layer)
	var second_layer = TileMapLayer.new()
	second_layer.name = "SecondLayer"
	scene_root.add_child(second_layer)
	await process_frame

	var shared_tile_set = TileSet.new()
	first_layer.tile_set = shared_tile_set
	second_layer.tile_set = shared_tile_set
	dock.refresh_tile_layer_options(scene_root)
	dock._tile_layer_option.select(1)
	dock._set_editor_selected_tile_map_layer_for_test(second_layer)
	dock._current_data = HexMapData.rectangle(1, 1)
	dock._tile_width_spin.value = 96
	await process_frame

	_assert_eq(first_layer.tile_set, shared_tile_set, "tile setting auto apply leaves unselected shared TileSet owner untouched")
	_assert_true(second_layer.tile_set != shared_tile_set, "tile setting auto apply duplicates shared TileSet for selected layer")
	_assert_eq(second_layer.tile_set.tile_size, Vector2i(96, 57), "selected layer receives updated TileSet size")
	_assert_true(first_layer.get_used_cells().is_empty(), "shared TileSet isolation does not apply cells to unselected layer")
	_assert_eq(second_layer.get_used_cells().size(), 1, "shared TileSet isolation still applies cells to selected layer")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_sets_up_sample_tiles() -> void:
	var dock = await _new_ready_dock()

	dock._tile_orientation_option.select(1)
	var layer = TileMapLayer.new()
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(layer), "generation dock configures sample tiles")
	_assert_true(layer.tile_set != null, "sample tile setup creates TileSet")
	_assert_eq(layer.tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "sample tile setup follows dock orientation")
	_assert_eq(layer.tile_set.tile_size, HexMapTileAdapter.SAMPLE_TILE_SIZE, "sample tile setup uses sample tile size")
	_assert_true(layer.tile_set.has_source(0), "sample tile setup creates source 0")
	_assert_eq(Vector2i(int(dock._tile_width_spin.value), int(dock._tile_height_spin.value)), HexMapTileAdapter.SAMPLE_TILE_SIZE, "sample tile setup syncs tile size controls")
	_assert_eq(int(dock._floor_source_spin.value), 0, "sample tile setup sets floor source")
	_assert_eq(Vector2i(int(dock._floor_atlas_x_spin.value), int(dock._floor_atlas_y_spin.value)), Vector2i.ZERO, "sample tile setup sets floor atlas")
	_assert_eq(int(dock._wall_source_spin.value), 0, "sample tile setup sets wall source")
	_assert_eq(Vector2i(int(dock._wall_atlas_x_spin.value), int(dock._wall_atlas_y_spin.value)), Vector2i(1, 0), "sample tile setup sets wall atlas")

	layer.free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_selects_atlas_image() -> void:
	var dock = await _new_ready_dock()

	dock._tile_orientation_option.select(0)
	var layer = TileMapLayer.new()
	_assert_true(
		dock.setup_atlas_tiles_on_tile_map_layer(
			layer,
			HexMapTileAdapter.SAMPLE_TILE_ATLAS_PATH,
			3,
			HexMapTileAdapter.SAMPLE_TILE_SIZE,
			Vector2i(0, 0),
			Vector2i(1, 0)
		),
		"generation dock configures selected atlas image"
	)
	_assert_eq(dock._current_atlas_image_path, HexMapTileAdapter.SAMPLE_TILE_ATLAS_PATH, "generation dock stores selected atlas path")
	_assert_true(layer.tile_set.has_source(3), "selected atlas creates configured source id")
	_assert_eq(layer.tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_VERTICAL, "selected atlas follows flat-top orientation")
	var source = layer.tile_set.get_source(3)
	_assert_true(source is TileSetAtlasSource, "selected atlas source is TileSetAtlasSource")
	_assert_true(source.has_tile(Vector2i(0, 0)), "selected atlas creates floor tile")
	_assert_true(source.has_tile(Vector2i(1, 0)), "selected atlas creates wall tile")
	_assert_eq(int(dock._floor_source_spin.value), 3, "selected atlas syncs floor source")
	_assert_eq(int(dock._wall_source_spin.value), 3, "selected atlas syncs wall source")

	layer.free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_generate_auto_applies_current_map() -> void:
	var dock = await _new_ready_dock()

	_assert_true(dock._apply_layer_button != null, "generation dock keeps Apply Layer button")
	_assert_eq(dock._apply_layer_button.text, "Apply Layer", "generation dock labels manual apply button")
	_assert_true(not _has_button_text(dock, "Generate & Apply"), "generation dock removes Generate & Apply button")

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._refresh_controls()

	_assert_true(await dock._generate_map(), "generation dock regenerates without a target TileMapLayer")
	_assert_eq(dock._current_data.cells.size(), 2, "auto apply generation regenerates current data from controls")
	_assert_eq(dock._current_data.walls.size(), 0, "auto apply generation uses current wall probability")

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var layer = TileMapLayer.new()
	layer.name = "AutoApplyLayer"
	scene_root.add_child(layer)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.item_count, 3, "generation dock lists Auto, auto apply target, and add new layer")
	dock._tile_layer_option.select(1)
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(layer), "auto apply test configures sample tiles")

	var generation_id = dock._generation_id
	dock._on_generate_pressed()
	await _wait_for_progress_controls(dock, "auto apply Generate button generation")
	await _wait_for_generation(dock, "auto apply Generate button generation")
	_assert_eq(dock._generation_id, generation_id + 1, "generation dock auto apply Generate button generation succeeds")
	_assert_eq(layer.get_used_cells().size(), 2, "generation dock auto applies regenerated cells")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i.ZERO, "auto apply writes floor tile atlas")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i(1, 0)), Vector2i.ZERO, "auto apply writes every generated floor cell")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_uniform_generation_and_apply() -> void:
	var dock = await _new_ready_dock()

	_assert_eq(dock._generate_button.text, "Primary Generation", "generation dock starts in primary generation mode")
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._refresh_controls()
	_assert_eq(dock._generate_button.text, "Overlay Generation", "overlay mode relabels Generate button")
	_assert_true(dock._overlay_controls_container.visible, "overlay mode shows overlay controls")
	_assert_true(dock._wall_prob_row.visible, "overlay uniform mode keeps placement probability visible")

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._overlay_item_pool_rows[0]["name"].text = "Tree"
	dock._overlay_item_pool_rows[0]["amount"].value = 1.0
	dock._on_overlay_add_item_pressed()
	dock._overlay_item_pool_rows[1]["name"].text = "Rock"
	dock._overlay_item_pool_rows[1]["amount"].value = 0.0
	dock._refresh_controls()

	var data = HexMapData.rectangle(2, 2)
	data.set_walls([HexVector.q_axis()])
	dock._current_data = data

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var layer = TileMapLayer.new()
	layer.name = "OverlayLayer"
	scene_root.add_child(layer)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	dock._tile_layer_option.select(1)
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(layer), "overlay apply test configures sample tiles")

	_assert_true(await dock._generate_map(), "generation dock generates overlay data")
	_assert_true(dock._current_data == data, "overlay generation keeps current primary data")
	_assert_true(dock._current_overlay_data != null, "overlay generation stores current overlay data")
	_assert_eq(dock._current_overlay_data.item_cells("Tree").size(), data.floor_cells().size(), "overlay uniform generation uses primary floor cells as candidates")
	_assert_eq(dock._current_overlay_data.item_cells("Rock").size(), 0, "overlay uniform generation honors item weights")
	_assert_eq(layer.get_used_cells().size(), data.floor_cells().size(), "overlay generation auto applies overlay cells to Target")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "overlay apply uses Wall atlas controls as item tile")
	_assert_true(dock.current_resource() is HexOverlayResource, "overlay mode saves current overlay resource")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_limit_and_apply_policy() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._overlay_item_pool_rows[0]["name"].text = "Coin"
	dock._overlay_item_limit_check.set_pressed_no_signal(true)
	dock._overlay_item_pool_rows[0]["amount"].value = 2
	dock._on_overlay_add_item_pressed()
	dock._overlay_item_pool_rows[1]["name"].text = "Gem"
	dock._overlay_item_pool_rows[1]["amount"].value = 1
	dock._current_data = HexMapData.rectangle(4, 1)
	dock._refresh_controls()

	_assert_eq(dock._overlay_item_pool_rows[0]["amount_label"].text, "Limit", "overlay limited uniform mode shows item limits")
	_assert_true(not dock._wall_prob_row.visible, "overlay limited uniform mode hides placement probability")
	_assert_true(await dock._generate_map(), "generation dock generates limited overlay data")
	_assert_eq(dock._current_overlay_data.item_cells("Coin").size(), 2, "overlay limited generation places requested item count")
	_assert_eq(dock._current_overlay_data.item_cells("Gem").size(), 1, "overlay limited generation supports multiple item limits")

	dock._overlay_item_pool_rows[0]["name"].text = "Key"
	dock._overlay_item_pool_rows[0]["amount"].value = 1
	dock._overlay_item_pool_rows[1]["amount"].value = 0
	dock._overlay_write_policy_option.select(1)
	_assert_true(await dock._generate_map(), "generation dock merges overlay data with Add Item policy")
	_assert_eq(dock._current_overlay_data.item_cells("Coin").size(), 2, "overlay Add Item policy preserves existing item data")
	_assert_eq(dock._current_overlay_data.item_cells("Gem").size(), 1, "overlay Add Item policy preserves existing second item data")
	_assert_eq(dock._current_overlay_data.item_cells("Key").size(), 1, "overlay Add Item policy adds generated item data")

	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_placement_mask_filters_candidates() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._overlay_item_pool_rows[0]["name"].text = "Moss"
	dock._overlay_item_pool_rows[0]["amount"].value = 1.0
	dock._overlay_mask_primary_items_edit.text = "Wall"
	var data = HexMapData.rectangle(3, 1)
	data.set_walls([HexVector.q_axis()])
	dock._current_data = data
	dock._refresh_controls()

	_assert_true(await dock._generate_map(), "generation dock generates overlay from placement mask")
	_assert_eq(dock._current_overlay_data.item_cells("Moss").size(), 1, "placement mask restricts overlay candidates to selected primary item")
	_assert_eq(dock._current_overlay_data.item_cells("Moss")[0].key(), HexVector.q_axis().key(), "placement mask item is generated on the selected wall cell")

	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_adjacency_reference_generation() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_adjacency_check.set_pressed_no_signal(true)
	dock._on_overlay_adjacency_toggled(true)
	dock._overlay_item_name_edit.text = "NearWall"
	dock._overlay_mask_primary_items_edit.text = "Floor"
	dock._overlay_reference_primary_items_edit.text = "Wall"
	dock._overlay_neighbor_radius_spin.value = 1
	dock._overlay_adjacency_rules_edit.text = "1=1.0;default=0.0"
	var data = HexMapData.hexagon(1)
	data.set_walls([HexVector.q_axis()])
	dock._current_data = data
	dock._refresh_controls()

	_assert_eq(dock._generate_option.selected, HexMapGenDock.GENERATE_SYMMETRIC, "adjacency reference switches overlay generation to Markov Mesh")
	_assert_true(dock._overlay_reference_container.visible, "adjacency reference shows reference controls")
	_assert_true(await dock._generate_map(), "generation dock generates adjacency overlay")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "NearWall"), "adjacency reference generates item next to reference cell")
	_assert_true(not dock._current_overlay_data.has_item(HexVector.apply_basis(-1, 1, 0), "NearWall"), "adjacency reference leaves cells without matching neighbor rule empty")

	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_item_pool_tile_mapping() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_item_pool_rows[0]["name"].text = "Tree"
	dock._overlay_item_pool_rows[0]["tile_atlas_x"].value = 0
	dock._overlay_item_pool_rows[0]["tile_atlas_y"].value = 0
	dock._on_overlay_add_item_pressed()
	dock._overlay_item_pool_rows[1]["name"].text = "Rock"
	dock._overlay_item_pool_rows[1]["tile_atlas_x"].value = 1
	dock._overlay_item_pool_rows[1]["tile_atlas_y"].value = 0
	dock._current_overlay_data = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{
			"Tree": [HexVector.zero()],
			"Rock": [HexVector.q_axis()],
		}
	)

	var layer = TileMapLayer.new()
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(layer), "overlay tile mapping test configures sample tiles")
	_assert_true(dock.apply_current_overlay_data_to_tile_map_layer(layer), "overlay tile mapping applies current overlay data")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(0, 0), "overlay item pool maps Tree to its configured tile")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i(1, 0)), Vector2i(1, 0), "overlay item pool maps Rock to its configured tile")

	layer.free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_mapdata_source_registry_load_reload_clear() -> void:
	var dock = await _new_ready_dock()
	var path = "res://.godot_user/test_mapdata_source_overlay.tres"
	var overlay = HexOverlayData.from_cells(
		[HexVector.zero()],
		{"Tree": [HexVector.zero()]}
	)
	_save_resource(path, HexOverlayResource.from_overlay_data(overlay))

	var source_id = dock.load_mapdata_source(path)
	_assert_true(source_id > 0, "source registry loads HexOverlayResource")
	_assert_eq(dock._mapdata_sources.size(), 1, "source registry stores loaded source")
	_assert_eq(dock._mapdata_sources[0]["resource_type"], HexMapGenDock.MAPDATA_SOURCE_OVERLAY, "source registry records overlay type")
	_assert_eq(dock._mapdata_sources[0]["item_keys"], ["Tree"], "source registry exposes overlay item keys")

	var reloaded = HexOverlayData.from_cells(
		[HexVector.zero()],
		{"Rock": [HexVector.zero()]}
	)
	_save_resource(path, HexOverlayResource.from_overlay_data(reloaded))
	var reloaded_id = dock.load_mapdata_source(path)
	_assert_eq(reloaded_id, source_id, "same source path reloads existing entry")
	_assert_eq(dock._mapdata_sources.size(), 1, "same source path does not add duplicate")
	_assert_eq(dock._mapdata_sources[0]["item_keys"], ["Rock"], "reload updates item keys")

	dock._add_query_row(true, source_id, "Rock")
	_assert_eq(dock._overlay_mask_query_rows.size(), 1, "query row references loaded source")
	dock.clear_mapdata_source(source_id)
	_assert_eq(dock._mapdata_sources.size(), 0, "clear removes source")
	_assert_eq(dock._overlay_mask_query_rows.size(), 0, "clear removes query rows using source")

	dock.queue_free()
	await process_frame


func _test_generation_dock_mapdata_query_rows_evaluate_offset_and_toric() -> void:
	var dock = await _new_ready_dock()
	var map_data = HexMapData.rectangle(3, 1)
	map_data.set_walls([HexVector.q_axis()])
	var map_id = dock.register_mapdata_source(HexMapResource.from_map_data(map_data), "res://map_query.tres")

	dock._add_query_row(true, map_id, "Floor")
	var wall_row = dock._add_query_row(true, map_id, "Wall")
	wall_row["operation"].select(1)
	_assert_keys_eq(
		dock._evaluate_query_rows(true, false),
		map_data.cells,
		"query rows OR selected item cells"
	)

	wall_row["operation"].select(0)
	wall_row["match"].select(1)
	_assert_keys_eq(
		dock._evaluate_query_rows(true, false),
		map_data.floor_cells(),
		"query rows apply Exclude as universe complement with AND"
	)

	var overlay = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{"Gem": [HexVector.zero()]}
	)
	var overlay_id = dock.register_mapdata_source(HexOverlayResource.from_overlay_data(overlay), "res://offset_query.tres")
	dock._overlay_reference_query_rows.clear()
	var offset_row = dock._add_query_row(false, overlay_id, "Gem")
	dock._on_query_row_direction_pressed(0, offset_row, false)
	_assert_keys_eq(
		dock._evaluate_query_rows(false, false),
		[HexVector.q_axis()],
		"query rows offset item cells"
	)

	var toric_data = HexOverlayData.from_cells(
		HexMapData.square(3, true).cells,
		{"Wrap": [HexVector.apply_basis(2, 0, 0)]},
		3
	)
	var toric_id = dock.register_mapdata_source(HexOverlayResource.from_overlay_data(toric_data), "res://toric_query.tres")
	dock._overlay_reference_query_rows.clear()
	var toric_row = dock._add_query_row(false, toric_id, "Wrap")
	dock._on_query_row_direction_pressed(0, toric_row, false)
	_assert_keys_eq(
		dock._evaluate_query_rows(false, false),
		[HexVector.zero()],
		"query rows wrap offset cells for toric source"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_mapdata_crop_result_and_reset_rules() -> void:
	var dock = await _new_ready_dock()
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.value = 1
	dock._rect_height_spin.value = 1
	dock._refresh_controls()

	var overlay = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{
			"Tree": [HexVector.zero()],
			"Rock": [HexVector.q_axis()],
		}
	)
	var source_id = dock.register_mapdata_source(HexOverlayResource.from_overlay_data(overlay), "res://crop_query.tres")
	dock._add_query_row(true, source_id, "Tree")
	var exclude_row = dock._add_query_row(true, source_id, "Rock")
	exclude_row["operation"].select(1)
	exclude_row["match"].select(1)
	dock._overlay_mask_crop_check.set_pressed_no_signal(true)
	dock._refresh_mask_crop_count()

	var crop = dock._overlay_crop_result_data()
	_assert_keys_eq(crop.cells, [HexVector.zero()], "crop result uses current shape universe")
	_assert_keys_eq(crop.item_cells("Any"), [HexVector.zero()], "crop result stores Any universe")
	_assert_keys_eq(crop.item_cells("crop_query.tres / Tree"), [HexVector.zero()], "crop result stores prefixed contain item")
	_assert_eq(crop.item_cells("crop_query.tres / Rock").size(), 0, "crop result excludes Exclude item output")
	_assert_eq(dock._overlay_mask_count_label.text, "Cells: 1", "crop count ignores Any and duplicate cells")

	dock._on_query_row_direction_pressed(0, dock._overlay_mask_query_rows[0], true)
	_assert_true(not dock._overlay_mask_crop_check.button_pressed, "mask query edit turns Crop off")
	dock._overlay_mask_crop_check.set_pressed_no_signal(true)
	dock._on_shape_size_changed(2)
	_assert_true(not dock._overlay_mask_crop_check.button_pressed, "shape size edit turns Crop off")
	dock._overlay_mask_crop_check.set_pressed_no_signal(true)
	dock._add_query_row(false, source_id, "Tree")
	_assert_true(dock._overlay_mask_crop_check.button_pressed, "reference query edit does not turn Crop off")

	dock.queue_free()
	await process_frame


func _test_generation_dock_mapdata_crop_off_stacks_overlay_sources() -> void:
	var dock = await _new_ready_dock()
	dock._overlay_mode_check.set_pressed_no_signal(true)
	var primary = HexMapData.rectangle(1, 1)
	dock.register_mapdata_source(HexMapResource.from_map_data(primary), "res://stack_primary.tres")
	var first = HexOverlayData.from_cells(
		[HexVector.zero()],
		{"Tree": [HexVector.zero()]}
	)
	var second = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{"Rock": [HexVector.zero()], "Gem": [HexVector.q_axis()]}
	)
	dock.register_mapdata_source(HexOverlayResource.from_overlay_data(first), "res://stack_first.tres")
	dock.register_mapdata_source(HexOverlayResource.from_overlay_data(second), "res://stack_second.tres")
	dock._overlay_existing_policy_option.select(1)

	_assert_true(dock._apply_overlay_source_stack_to_current(), "crop off stack applies overlay sources")
	_assert_eq(dock._current_overlay_data.item_cells("Tree").size(), 0, "replace existing removes earlier item on same cell")
	_assert_keys_eq(dock._current_overlay_data.item_cells("Rock"), [HexVector.zero()], "stack keeps later replacement item")
	_assert_keys_eq(dock._current_overlay_data.item_cells("Gem"), [HexVector.q_axis()], "stack preserves non-conflicting later item")
	_assert_eq(dock._current_overlay_data.item_cells("Floor").size(), 0, "stack ignores Primary source")

	dock._current_overlay_data = HexOverlayData.from_cells([HexVector.zero()], {"Old": [HexVector.zero()]})
	dock._overlay_write_policy_option.select(1)
	dock._overlay_existing_policy_option.select(0)
	_assert_true(dock._apply_overlay_source_stack_to_current(), "Add Item write policy merges stack into current overlay")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "Old"), "Add Item write policy preserves existing current item")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "Tree"), "Add Item write policy adds stacked source item")

	var empty_dock = await _new_ready_dock()
	empty_dock._overlay_mode_check.set_pressed_no_signal(true)
	_assert_true(not empty_dock._apply_overlay_source_stack_to_current(), "empty overlay source stack does not update current overlay")

	empty_dock.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_generate_history_saves_overlay_delta_source() -> void:
	var dock = await _new_ready_dock()
	var history_dir = "res://.godot_user/mapdata_history"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(history_dir))
	dock._set_generate_history_directory_for_test(history_dir)
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._overlay_item_pool_rows[0]["name"].text = "Key"
	dock._overlay_item_pool_rows[0]["amount"].value = 1.0
	dock._overlay_write_policy_option.select(1)
	dock._current_data = HexMapData.rectangle(1, 1)
	dock._current_overlay_data = HexOverlayData.from_cells(
		[HexVector.zero()],
		{"Old": [HexVector.zero()]}
	)
	dock._refresh_controls()

	var before_count = dock._mapdata_sources.size()
	_assert_true(await dock._generate_map(), "generate history test generates overlay")
	_assert_eq(dock._mapdata_sources.size(), before_count + 1, "generate history adds saved source")
	var source = dock._mapdata_sources[dock._mapdata_sources.size() - 1]
	var saved_data = source["data"]
	_assert_eq(source["resource_type"], HexMapGenDock.MAPDATA_SOURCE_OVERLAY, "generate history registers overlay source")
	_assert_eq(saved_data.item_cells("Old").size(), 0, "generate history stores overlay delta before Add Item policy")
	_assert_eq(saved_data.item_cells("Key").size(), 1, "generate history stores generated overlay delta item")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "Old"), "current overlay still applies Add Item policy")

	var primary_dock = await _new_ready_dock()
	primary_dock._set_generate_history_directory_for_test(history_dir)
	primary_dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	primary_dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	primary_dock._rect_width_spin.set_value_no_signal(2)
	primary_dock._rect_height_spin.set_value_no_signal(1)
	primary_dock._wall_prob_slider.set_value_no_signal(0.0)
	var primary_before_count = primary_dock._mapdata_sources.size()
	_assert_true(await primary_dock._generate_map(), "generate history test generates primary map")
	_assert_eq(primary_dock._mapdata_sources.size(), primary_before_count + 1, "generate history adds primary source")
	_assert_eq(primary_dock._mapdata_sources[0]["resource_type"], HexMapGenDock.MAPDATA_SOURCE_MAP, "generate history registers primary source")
	_assert_eq(primary_dock._mapdata_sources[0]["item_keys"], ["Any", "Floor", "Wall"], "generate history primary source exposes primary item keys")

	var cancel_dock = await _new_ready_dock()
	cancel_dock._set_generate_history_directory_for_test(history_dir)
	cancel_dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	cancel_dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	cancel_dock._rect_width_spin.set_value_no_signal(20)
	cancel_dock._rect_height_spin.set_value_no_signal(20)
	cancel_dock._wall_prob_slider.set_value_no_signal(1.0)
	cancel_dock._generation_chunk_size = 1
	cancel_dock._generation_progress_delay_usec = 5000
	cancel_dock._generate_map(true)
	await _wait_for_core_progress(cancel_dock)
	cancel_dock.request_generation_cancel()
	await _wait_for_generation(cancel_dock, "cancelled generate history generation")
	_assert_eq(cancel_dock._mapdata_sources.size(), 0, "generate history does not add source when generation is cancelled")

	cancel_dock.queue_free()
	primary_dock.queue_free()
	dock.queue_free()
	await process_frame


func _save_distribution(path: String, distribution: HexDistribution) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.godot_user"))
	var error = ResourceSaver.save(distribution, path)
	_assert_eq(error, OK, "test distribution resource saves")


func _save_resource(path: String, resource: Resource) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.godot_user"))
	var error = ResourceSaver.save(resource, path)
	_assert_eq(error, OK, "test resource saves")


func _count_cancel(state: Dictionary) -> void:
	state["count"] += 1


func _capture_rules(rules_text: String, state: Dictionary) -> void:
	state["rules"] = rules_text


func _spin_values(spins: Array) -> Array:
	var result: Array = []
	for spin in spins:
		result.append(float(spin.value))
	return result


func _connect_method_index(method: int) -> int:
	for index in range(HexMapGenDock.CONNECT_METHOD_VALUES.size()):
		if HexMapGenDock.CONNECT_METHOD_VALUES[index] == method:
			return index
	_failures.append("connect method %d is not listed in dock" % method)
	return 0


func _new_ready_dock():
	var dock = HexMapGenDock.new()
	root.add_child(dock)
	await process_frame
	return dock


func _begin_manual_generation(dock: HexMapGenDock, show_progress: bool = false) -> void:
	dock._generation_id += 1
	dock._begin_generation(dock._generation_id, show_progress)


func _wait_for_generation(dock: HexMapGenDock, message: String) -> void:
	var guard := 0
	while dock.generation_status()["running"] and guard < 240:
		await process_frame
		guard += 1
	_assert_true(guard < 240, "%s finishes" % message)
	await process_frame


func _wait_for_progress_controls(dock: HexMapGenDock, message: String) -> void:
	var guard := 0
	while not _progress_controls_ready(dock) \
		and dock.generation_status()["running"] \
		and guard < 240:
		await process_frame
		guard += 1
	_assert_true(_progress_controls_ready(dock), "%s shows dock progress" % message)


func _wait_for_core_progress(dock: HexMapGenDock) -> void:
	var guard := 0
	while dock._generation_last_core_progress <= 0.0 \
		and dock.generation_status()["running"] \
		and guard < 240:
		await process_frame
		guard += 1
	_assert_true(dock._generation_core_progress_event_count > 0, "threaded generation emits core progress")
	_assert_true(dock._generation_last_core_progress > 0.0, "threaded generation emits nonzero core progress")


func _wait_seconds(seconds: float) -> void:
	await create_timer(seconds).timeout


func _progress_controls_visible(dock: HexMapGenDock) -> bool:
	return dock._generation_progress_container != null \
		and dock._generation_progress_container.visible


func _progress_controls_ready(dock: HexMapGenDock) -> bool:
	return _progress_controls_visible(dock) \
		and dock._generation_progress_cancel_button != null


func _progress_controls_hidden(dock: HexMapGenDock) -> bool:
	return dock._generation_progress_container == null \
		or not dock._generation_progress_container.visible


func _window_child_count(node: Node) -> int:
	var count := 0
	for child in node.get_children():
		if child is Window:
			count += 1
		count += _window_child_count(child)
	return count


func _has_button_text(node: Node, text: String) -> bool:
	if node is Button and node.text == text:
		return true
	for child in node.get_children():
		if _has_button_text(child, text):
			return true
	return false


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _assert_keys_eq(actual: Array, expected: Array, message: String) -> void:
	var actual_keys: Array = []
	for point in actual:
		actual_keys.append(point.key())
	actual_keys.sort()
	var expected_keys: Array = []
	for point in expected:
		expected_keys.append(point.key())
	expected_keys.sort()
	_assert_eq(actual_keys, expected_keys, message)


func _assert_color_approx(actual: Color, expected: Color, message: String) -> void:
	if not is_equal_approx(actual.r, expected.r) \
		or not is_equal_approx(actual.g, expected.g) \
		or not is_equal_approx(actual.b, expected.b) \
		or not is_equal_approx(actual.a, expected.a):
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])
