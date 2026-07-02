extends "res://tests/test_editor_plugin_test_base.gd"

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	await _test_generation_dock_state_evaluator_splits_control_logic()
	await _test_generation_dock_adjacency_rule_validation()
	await _test_build_inspector_adjacency_rules_dialog_uses_flow_cards()
	await _test_build_inspector_item_pool_fields_follow_placement_method()
	await _test_build_inspector_param_fields_follow_toric_ownership()
	await _test_generation_dock_symmetric_hexagon_minimum_radii()
	await _test_generation_dock_shape_universe_uses_canonical_hexagon_and_square_torus()
	await _test_generation_dock_torus_connectivity_controls()
	await _test_generation_dock_torus_connectivity_generation()
	await _test_generation_dock_tracks_generation_progress_state()
	await _test_generation_dock_run_state_drives_progress_without_mirror_fields()
	await _test_generation_dock_debug_report_includes_validation_summary()
	await _test_generation_dock_validates_generation_result_before_auto_apply()
	await _test_generation_dock_captures_generation_validation_failure()
	await _test_generation_dock_batch_runner_scores_and_sorts()
	await _test_generation_dock_promotes_batch_seed_to_canonical_document()
	await _test_generation_dock_only_generates_from_generate_button()
	await _test_generation_dock_wires_core_progress_and_cancel()
	await _test_tile_map_adapter_chunked_apply_reports_progress_and_cancel()
	await _test_generation_dock_applies_configured_tile_entries()
	await _test_generation_dock_applies_orientation_to_tile_entries()
	await _test_generation_dock_resource_stores_orientation()
	await _test_generation_dock_configures_tile_map_layer_tileset()
	await _test_generation_dock_applies_primary_map_to_hex_tile_map_layer()
	await _test_generation_dock_swaps_tile_size_on_orientation_change()
	await _test_generation_dock_lists_hex_tile_map_layer_common_target()
	await _test_generation_dock_lists_and_auto_applies_selected_tile_layer()
	await _test_generation_dock_disambiguates_duplicate_target_names()
	await _test_generation_dock_adds_new_target_layer()
	await _test_generation_dock_duplicates_shared_tileset_for_selected_layer()
	await _test_generation_dock_sets_up_sample_tiles()
	await _test_generation_dock_selects_atlas_image()
	await _test_generation_dock_generate_auto_applies_current_map()
	await _test_generation_dock_generate_auto_applies_hex_tile_map_layer()
	await _test_generation_dock_output_target_preview_and_selected_document()
	await _test_generation_profile_options_drive_generation_snapshot()
	await _test_generation_dock_overlay_uniform_generation_and_apply()
	await _test_generation_dock_overlay_applies_to_hex_tile_map_layer()
	await _test_generation_dock_overlay_limit_and_apply_policy()
	await _test_generation_dock_overlay_placement_mask_filters_candidates()
	await _test_generation_dock_overlay_adjacency_reference_generation()
	await _test_generation_dock_adjacency_generated_reference_snapshot()
	await _test_generation_dock_adjacency_generated_reference_changes_result()
	await _test_generation_dock_overlay_item_pool_tile_mapping()
	await _test_generation_dock_catalog_selectors_drive_tile_defaults()
	await _test_generation_dock_mapdata_source_registry_load_reload_clear()
	await _test_generation_dock_path_action_labels_and_failure_status()
	await _test_generation_dock_mapdata_query_rows_evaluate_offset_and_toric()
	await _test_generation_dock_overlay_deductor_floor_source_query()
	await _test_generation_dock_mapdata_crop_result_and_reset_rules()
	await _test_generation_dock_mapdata_crop_off_stacks_overlay_sources()
	await _test_generation_dock_generate_history_saves_overlay_delta_source()
	_finish("res://tests/test_editor_generation.gd")

func _test_generation_dock_state_evaluator_splits_control_logic() -> void:
	var simple = HexMapGenStateEvaluator.evaluate_control_state({
		"symmetric": false,
		"overlay": false,
		"generation_running": false,
		"overlay_adjacency_enabled": false,
		"overlay_item_limit_enabled": false,
		"simple_shape": HexMapGenDock.SHAPE_RECTANGLE,
		"shape_rectangle": HexMapGenDock.SHAPE_RECTANGLE,
		"shape_hexagon": HexMapGenDock.SHAPE_HEXAGON,
	})
	_assert_true(bool(simple["shape_simple_row_visible"]), "state evaluator shows simple shape row for simple generation")
	_assert_true(bool(simple["rect_row_visible"]), "state evaluator shows rectangle row for rectangle shape")
	_assert_true(not bool(simple["hex_row_visible"]), "state evaluator hides hex row for rectangle shape")
	_assert_true(not bool(simple["radius_row_visible"]), "state evaluator hides radius row for simple generation")
	_assert_eq(simple["probability_label"], "  Probability / Cell", "state evaluator labels simple probability")
	_assert_eq(simple["generate_button_text"], "Primary Generation", "state evaluator labels primary generation button")
	_assert_true(not bool(simple["overlay_controls_visible"]), "state evaluator hides overlay controls in primary mode")
	_assert_true(bool(simple["wall_probability_row_visible"]), "state evaluator shows wall probability in primary mode")

	var overlay_symmetric = HexMapGenStateEvaluator.evaluate_control_state({
		"symmetric": true,
		"overlay": true,
		"generation_running": false,
		"overlay_adjacency_enabled": true,
		"overlay_item_limit_enabled": false,
		"simple_shape": HexMapGenDock.SHAPE_HEXAGON,
		"shape_rectangle": HexMapGenDock.SHAPE_RECTANGLE,
		"shape_hexagon": HexMapGenDock.SHAPE_HEXAGON,
	})
	_assert_true(bool(overlay_symmetric["shape_symmetric_row_visible"]), "state evaluator shows symmetric shape row")
	_assert_true(bool(overlay_symmetric["radius_row_visible"]), "state evaluator shows radius row for symmetric generation")
	_assert_true(not bool(overlay_symmetric["sym_options_visible"]), "state evaluator hides symmetric options during overlay adjacency")
	_assert_eq(overlay_symmetric["probability_label"], "  Initial Probability", "state evaluator labels symmetric probability")
	_assert_eq(overlay_symmetric["generate_button_text"], "Overlay Generation", "state evaluator labels overlay generation button")
	_assert_eq(overlay_symmetric["deductor_label_text"], "Overlay Deductor", "state evaluator labels overlay deductor")
	_assert_eq(overlay_symmetric["generator_label_text"], "Overlay Generator", "state evaluator labels overlay generator")
	_assert_true(bool(overlay_symmetric["overlay_controls_visible"]), "state evaluator shows overlay controls")
	_assert_true(bool(overlay_symmetric["overlay_item_name_row_visible"]), "state evaluator shows symmetric overlay item name row")
	_assert_true(not bool(overlay_symmetric["overlay_item_pool_visible"]), "state evaluator hides item pool for symmetric overlay")
	_assert_true(bool(overlay_symmetric["overlay_reference_visible"]), "state evaluator shows adjacency reference controls")
	_assert_true(not bool(overlay_symmetric["overlay_deductor_floor_visible"]), "state evaluator hides deductor source during overlay adjacency")
	_assert_true(not bool(overlay_symmetric["wall_probability_row_visible"]), "state evaluator hides wall probability during overlay adjacency")

	var running_limit = HexMapGenStateEvaluator.evaluate_control_state({
		"symmetric": true,
		"overlay": true,
		"generation_running": true,
		"overlay_adjacency_enabled": false,
		"overlay_item_limit_enabled": true,
		"simple_shape": HexMapGenDock.SHAPE_HEXAGON,
		"shape_rectangle": HexMapGenDock.SHAPE_RECTANGLE,
		"shape_hexagon": HexMapGenDock.SHAPE_HEXAGON,
	})
	_assert_true(bool(running_limit["torus_connectivity_disabled"]), "state evaluator disables torus connectivity while generating")
	_assert_true(bool(running_limit["overlay_adjacency_disabled"]), "state evaluator disables adjacency toggle during item limit or generation")
	_assert_true(bool(running_limit["overlay_item_limit_disabled"]), "state evaluator disables item limit toggle while generating")
	_assert_true(bool(running_limit["overlay_deductor_floor_visible"]), "state evaluator shows symmetric overlay deductor source outside adjacency")
	_assert_true(not bool(running_limit["wall_probability_row_visible"]), "state evaluator hides wall probability during item limit")

	_assert_eq(
		HexMapGenStateEvaluator.generation_block_reason({
			"overlay_mode": false,
			"mask_query_enabled": true,
			"mask_candidate_count": 0,
			"overlay_adjacency_enabled": true,
			"adjacency_rule_count": 0,
		}),
		"",
		"state evaluator does not block primary generation"
	)
	_assert_eq(
		HexMapGenStateEvaluator.generation_block_reason({
			"overlay_mode": true,
			"mask_query_enabled": true,
			"mask_candidate_count": 0,
			"overlay_adjacency_enabled": false,
			"adjacency_rule_count": 1,
		}),
		HexMapGenStateEvaluator.DEFAULT_EMPTY_MASK_REASON,
		"state evaluator blocks empty overlay mask"
	)
	_assert_eq(
		HexMapGenStateEvaluator.generation_block_reason({
			"overlay_mode": true,
			"mask_query_enabled": false,
			"mask_candidate_count": 0,
			"overlay_adjacency_enabled": true,
			"adjacency_rule_count": 0,
		}),
		HexMapGenStateEvaluator.DEFAULT_EMPTY_ADJACENCY_RULES_REASON,
		"state evaluator blocks empty adjacency rules"
	)
	_assert_eq(
		HexMapGenStateEvaluator.generation_block_reason({
			"generation_running": true,
			"overlay_mode": true,
			"mask_query_enabled": true,
			"mask_candidate_count": 0,
			"overlay_adjacency_enabled": true,
			"adjacency_rule_count": 0,
		}),
		"",
		"state evaluator does not change block reason while generation is running"
	)
	_assert_eq(
		HexMapGenStateEvaluator.generation_block_reason({
			"overlay_mode": true,
			"mask_query_enabled": false,
			"mask_candidate_count": 0,
			"overlay_adjacency_enabled": true,
			"adjacency_rule_count": 1,
		}),
		"",
		"state evaluator allows valid adjacency overlay generation"
	)


func _test_generation_dock_adjacency_rule_validation() -> void:
	var dock = await _new_ready_dock()
	dock._wall_prob_slider.set_value_no_signal(0.35)
	dock._overlay_adjacency_rules_edit.text = "default=0.2;1=0.8;2,1=0.4;bad=x;bad=0.5"
	var rules = dock._overlay_adjacency_rules()
	_assert_eq(rules["default"], 0.2, "generation dock adjacency rules keep default")
	_assert_eq(rules[1], 0.8, "generation dock adjacency rules keep count rule")
	_assert_eq(rules[Vector2i(2, 1)], 0.4, "generation dock adjacency rules normalize count/component rule")
	_assert_true(dock._overlay_adjacency_rules_status_label.text.contains("Rules: 3"), "generation dock adjacency status shows valid rule count")
	_assert_true(dock._overlay_adjacency_rules_status_label.text.contains("Invalid: bad=x, bad=0.5"), "generation dock adjacency status shows invalid entries")

	dock._overlay_adjacency_rules_edit.text = "bad"
	rules = dock._overlay_adjacency_rules()
	_assert_eq(rules, {}, "generation dock adjacency rules stay empty when no valid rules exist")
	_assert_true(dock._overlay_adjacency_rules_status_label.text.contains("Rules: 0"), "generation dock adjacency status shows empty rules")
	_assert_true(not dock._overlay_adjacency_rules_status_label.text.contains("fallback default"), "generation dock adjacency status does not show fallback")

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_adjacency_check.set_pressed_no_signal(true)
	dock._on_overlay_adjacency_toggled(true)
	dock._overlay_adjacency_rules_edit.text = "bad"
	dock._refresh_controls()
	_assert_true(dock._generate_button.disabled, "generation dock disables Generate when adjacency rules are empty")
	_assert_true(not await dock._generate_map(), "generation dock does not generate adjacency overlay with empty rules")
	_assert_eq(
		dock.generation_status()["status"],
		HexMapGenDock.GENERATION_BLOCK_STATUS_PREFIX + HexMapGenDock.GENERATION_BLOCK_EMPTY_ADJACENCY_RULES,
		"empty adjacency rules block generation status"
	)

	dock._overlay_adjacency_rules_edit.text = "default=0.0"
	dock._refresh_controls()
	_assert_true(not dock._generate_button.disabled, "valid adjacency rules unblock Generate")
	_assert_eq(dock.generation_status()["status"], "Ready", "resolved adjacency block restores ready status")

	dock.queue_free()
	await process_frame


func _test_build_inspector_adjacency_rules_dialog_uses_flow_cards() -> void:
	var inspector := HexMapBuildNodeInspector.new()
	root.add_child(inspector)
	await process_frame

	var rules := []
	var directions := HexVector.directions()
	for index in range(12):
		var rule_directions := [directions[index % directions.size()].key()]
		if index == 0:
			rule_directions = [
				directions[0].key(),
				directions[1].key(),
				directions[3].key(),
			]
		rules.append({
			"directions": rule_directions,
			"probability": float(index % 10) / 10.0,
		})
	inspector.inspect_node({
		"id": "items",
		"type": HexGenerationNodeTypes.NODE_ITEM_GENERATOR,
		"params": {
			"placement_method": "adjacency_rules",
			"probability_rules": {
				"default": 0.1,
				"rules": rules,
			},
		},
	}, "overlay")
	await process_frame

	inspector._open_adjacency_rules_dialog(null)
	await process_frame
	await process_frame

	var dialog := inspector.find_child("Adjacency Rules Window", true, false)
	_assert_true(dialog is AcceptDialog, "Adjacency Rules dialog opens from build inspector")
	var scroll := dialog.find_child("AdjacencyRulesPatternScroll", true, false)
	_assert_true(scroll is ScrollContainer, "Adjacency Rules patterns are contained in a scroll area")
	var flow := dialog.find_child("AdjacencyRulesPatternList", true, false)
	_assert_true(flow is HFlowContainer, "Adjacency Rules patterns use a horizontal flow container")
	_assert_true(flow.get_parent() == scroll, "Adjacency Rules flow is inside the scroll area so it cannot force dialog height")
	_assert_eq(flow.get_child_count(), 12, "Adjacency Rules flow contains one card per pattern")

	var card := flow.get_child(0) as Control
	_assert_true(card is VBoxContainer, "Adjacency pattern card stacks preview and probability spin")
	var preview := card.find_child("AdjacencyPatternPreviewArea_0", true, false)
	var panel := card.find_child("AdjacencyPatternPanel_0", true, false)
	var spin := card.find_child("AdjacencyPatternProbabilitySpin_0", true, false)
	var components_label := card.find_child("AdjacencyPatternComponentsLabel_0", true, false)
	var remove_button := card.find_child("AdjacencyPatternRemoveButton_0", true, false)
	_assert_true(panel is HexCellButtonPanel and panel.get_parent() == preview, "Adjacency pattern preview owns the HexCellButton")
	_assert_true(spin is SpinBox and card.is_ancestor_of(spin), "Adjacency pattern card has a probability spin")
	_assert_true(components_label is Label and components_label.get_parent() == card, "Adjacency pattern card shows component set below the HexCellButton")
	_assert_true(remove_button is Button and remove_button.get_parent() == preview, "Adjacency pattern remove button sits in the preview area's top-right control layer")

	var pattern_panel := panel as HexCellButtonPanel
	var panel_entries := _entries_by_id(pattern_panel.get_entries())
	_send_panel_click(pattern_panel, pattern_panel.local_pos_from_layout(panel_entries[directions[1].key()]["center"]))
	await process_frame

	var add_button := dialog.find_child("AddAdjacencyPattern", true, false) as Button
	add_button.pressed.emit()
	await process_frame
	_assert_eq(flow.get_child_count(), 13, "Add pattern appends another card to the same flow container")

	dialog.queue_free()
	inspector.queue_free()
	await process_frame


func _test_build_inspector_item_pool_fields_follow_placement_method() -> void:
	var inspector := HexMapBuildNodeInspector.new()
	root.add_child(inspector)
	await process_frame

	inspector.inspect_node({
		"id": "items",
		"type": HexGenerationNodeTypes.NODE_ITEM_GENERATOR,
		"params": {
			"placement_method": "weighted",
			"item_pool": [{"name": "chest", "weight": 0.5}],
		},
	}, "overlay")
	await process_frame

	var weight_label := inspector.find_child("ItemPoolValueLabel_0", true, false) as Label
	_assert_true(weight_label != null and weight_label.text == "weight:", "weighted method shows a weight field per pool entry")
	var weight_spin := inspector.find_child("ItemPoolValueSpin_0", true, false) as SpinBox
	_assert_true(weight_spin != null and is_equal_approx(weight_spin.step, 0.05), "weighted pool value spin edits a 0..1 weight")

	var committed: Array = []
	inspector.node_params_changed.connect(func(_node_id: String, params: Dictionary):
		committed.append(params.duplicate(true))
	)
	inspector.set_param("placement_method", "limited")
	await process_frame

	var count_label := inspector.find_child("ItemPoolValueLabel_0", true, false) as Label
	_assert_true(count_label != null and count_label.text == "count:", "limited method relabels the pool entry field as a count")
	var count_spin := inspector.find_child("ItemPoolValueSpin_0", true, false) as SpinBox
	_assert_true(count_spin != null and is_equal_approx(count_spin.step, 1.0), "limited pool value spin edits an integer count")
	_assert_eq(int(count_spin.value), 0, "limited count renders the stored limit value honestly instead of reusing weight")

	count_spin.value_changed.emit(3.0)
	await process_frame
	_assert_true(not committed.is_empty(), "editing the limited count commits node params")
	var pool = (committed.back() as Dictionary).get("item_pool", []) as Array
	_assert_eq(int((pool[0] as Dictionary).get("limit", 0)), 3, "limited count writes the core-visible limit key")
	_assert_true((pool[0] as Dictionary).has("weight"), "switching methods preserves the weighted setting")

	inspector.queue_free()
	await process_frame


func _test_build_inspector_param_fields_follow_toric_ownership() -> void:
	var inspector := HexMapBuildNodeInspector.new()
	root.add_child(inspector)
	await process_frame

	inspector.inspect_node({
		"id": "shape",
		"type": HexGenerationNodeTypes.NODE_SHAPE,
		"params": {"shape": "square", "size": 3},
	}, "terrain")
	await process_frame
	var shape_fields := Array(inspector.inspector_snapshot()["param_fields"])
	_assert_true(not shape_fields.has("toric"), "Shape inspector no longer offers a toric switch")

	inspector.inspect_node({
		"id": "connect",
		"type": HexGenerationNodeTypes.NODE_CONNECTIVITY,
		"params": {"method": "dense"},
	}, "terrain")
	await process_frame
	var connectivity_fields := Array(inspector.inspector_snapshot()["param_fields"])
	_assert_true(connectivity_fields.has("toric_passage"), "Connectivity inspector owns the toric passage switch")
	var toric_row := inspector.find_child("ParamRow_toric_passage", true, false) as Control
	_assert_true(toric_row != null and toric_row.visible, "Connectivity toric passage control is visible")

	inspector.inspect_node({
		"id": "items",
		"type": HexGenerationNodeTypes.NODE_ITEM_GENERATOR,
		"params": {"placement_method": "adjacency_rules"},
	}, "overlay")
	await process_frame
	var item_fields := Array(inspector.inspector_snapshot()["param_fields"])
	_assert_true(item_fields.has("item_name"), "Item Generator exposes the adjacency item name")
	var item_name_row := inspector.find_child("ParamRow_item_name", true, false) as Control
	_assert_true(item_name_row != null and item_name_row.visible, "adjacency method shows the item name field")
	var pool_editor := inspector.find_child("ItemPoolEditor", true, false) as Control
	_assert_true(pool_editor != null and not pool_editor.visible, "adjacency method hides the weighted/limited pool editor")

	inspector.queue_free()
	await process_frame


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


func _test_generation_dock_shape_universe_uses_canonical_hexagon_and_square_torus() -> void:
	var dock = await _new_ready_dock()

	var simple_hexagon = dock._shape_universe_from_values(
		false,
		HexMapGenDock.SHAPE_HEXAGON,
		2,
		1,
		1,
		3
	)
	var symmetric_hexagon = dock._shape_universe_from_values(
		true,
		HexMapGenDock.SHAPE_HEXAGON,
		1,
		1,
		1,
		2
	)
	var torus_universe = dock._shape_universe_from_values(
		false,
		HexMapGenDock.SHAPE_TORUS,
		1,
		1,
		1,
		2
	)
	_assert_keys_eq(simple_hexagon, HexMapData.hexagon(2).cells, "simple hexagon universe uses canonical HexMapData shape")
	_assert_keys_eq(symmetric_hexagon, HexMapData.hexagon(2).cells, "symmetric hexagon universe uses canonical HexMapData shape")
	_assert_keys_eq(simple_hexagon, symmetric_hexagon, "simple and symmetric hexagon universes match for the same radius")
	_assert_keys_eq(torus_universe, HexMapData.square(5, false).cells, "torus universe remains a non-toric square cell set")

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
	_assert_eq(String(idle_status["state_source"]), "HexMapGenerationRunState", "STATE-10 status comes from generation run state")
	_assert_eq(String(idle_status["state_id"]), HexMapGenerationRunState.STATE_IDLE, "STATE-10 generation dock starts in idle run state")
	var idle_view_state = dock.generation_run_view_state()
	_assert_eq(String(idle_view_state["state_source"]), "HexMapGenerationRunState", "STATE-10 view state comes from generation run state")
	_assert_true(not bool(idle_view_state["generate_button_disabled"]), "STATE-10 idle view state allows Generate")
	_assert_eq(dock._generation_id, 0, "generation dock does not auto generate on creation")
	_assert_eq(dock._current_data, null, "generation dock starts without generated data")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on creation")
	_assert_eq(_window_child_count(dock), 0, "generation dock has no modal progress window on creation")

	dock._on_generate_pressed()
	await _wait_for_progress_controls(dock, "Generate button generation")
	await _wait_for_progress_status(dock, "Validating generated document", "Generate validation progress")
	await _wait_for_progress_status(dock, "Applying generated result", "Generate apply progress")
	await _wait_for_generation(dock, "Generate button generation")
	var ready_status = dock.generation_status()
	_assert_true(not ready_status["running"], "generation dock clears running state after Generate")
	_assert_true(not ready_status["cancel_requested"], "generation dock clears cancel request after Generate")
	_assert_eq(ready_status["progress"], 1.0, "generation dock reports completed progress")
	_assert_eq(ready_status["status"], "Ready", "generation dock reports ready status")
	_assert_eq(String(ready_status["step"]), HexMapGenDock.PROGRESS_STEP_COMPLETE, "PERF-61 generation status exposes complete step")
	_assert_eq(String(ready_status["state_id"]), HexMapGenerationRunState.STATE_GENERATED_PREVIEW, "STATE-10 completed generation exposes generated preview state")
	var progress_snapshot = dock.generation_progress_snapshot()
	_assert_eq(String(progress_snapshot["current_step_text"]), "Ready", "PERF-61 progress snapshot exposes current step text")
	_assert_true(bool(progress_snapshot["progress_bar_visible"]), "PERF-61 progress snapshot exposes visible ProgressBar")
	_assert_eq(String(progress_snapshot["state_source"]), "HexMapGenerationRunState", "STATE-10 progress snapshot comes from generation run state")
	_assert_true(not bool(progress_snapshot["cancel_available"]), "PERF-61 cancel is unavailable after synchronous apply/finalize")
	_assert_true(_progress_controls_visible(dock), "generation dock keeps Generate progress visible after fast generation")
	_assert_true(dock._generation_progress_cancel_button.disabled, "generation dock disables progress cancel after Generate finish")
	_assert_eq(_window_child_count(dock), 0, "generation dock does not create modal progress window for Generate")
	await _wait_seconds(HexMapGenDock.GENERATION_PROGRESS_MIN_VISIBLE_SEC + 0.1)
	_assert_true(_progress_controls_hidden(dock), "generation dock hides Generate progress after minimum display time")

	_begin_manual_generation(dock, true)
	await _wait_for_progress_controls(dock, "manual successful generation")
	var running_view_state = dock.generation_run_view_state()
	_assert_eq(String(running_view_state["state_id"]), HexMapGenerationRunState.STATE_PREPARING, "STATE-10 manual begin enters preparing state")
	_assert_true(bool(running_view_state["controls_disabled"]), "STATE-10 running view state disables generation controls")
	_assert_true(not dock._generation_progress_cancel_button.disabled, "generation dock enables progress cancel while running")
	dock._set_generation_progress_visible_started_msec(Time.get_ticks_msec())
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
	_assert_eq(String(cancel_status["state_id"]), HexMapGenerationRunState.STATE_CANCELLING, "STATE-10 cancel request enters cancelling state")
	_assert_true(dock._generation_progress_cancel_button.disabled, "generation dock disables progress cancel after cancel request")

	dock._finish_generation(true)
	var cancelled_status = dock.generation_status()
	_assert_true(not cancelled_status["running"], "generation dock clears running state after cancelled finish")
	_assert_true(not cancelled_status["cancel_requested"], "generation dock clears cancel request after cancelled finish")
	_assert_eq(cancelled_status["status"], "Cancelled", "generation dock reports cancelled status")
	_assert_eq(String(cancelled_status["state_id"]), HexMapGenerationRunState.STATE_CANCELLED, "STATE-10 cancelled finish exposes cancelled state")
	_assert_true(_progress_controls_hidden(dock), "generation dock hides progress after cancellation")

	var layer = TileMapLayer.new()
	root.add_child(layer)
	await process_frame
	dock._current_data = HexMapData.rectangle(2, 1)
	dock._current_orientation = HexMapResource.ORIENTATION_FLAT_TOP
	dock._set_editor_selected_tile_map_layer_for_test(layer)
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(layer), "PERF-61 tile setting progress test configures display tiles")
	_assert_true(dock._apply_tile_settings_to_current_layer(), "PERF-61 tile setting apply succeeds")
	progress_snapshot = dock.generation_progress_snapshot()
	_assert_true(bool(progress_snapshot["visible"]), "PERF-61 tile setting apply shows inline progress")
	_assert_eq(String(progress_snapshot["status"]), "Tile settings applied", "PERF-61 tile setting apply reports completion")
	_assert_eq(String(progress_snapshot["step"]), HexMapGenDock.PROGRESS_STEP_COMPLETE, "PERF-61 tile setting completion uses complete step")
	_assert_eq(String(progress_snapshot["state_id"]), HexMapGenerationRunState.STATE_APPLIED_TILE_SETTINGS, "STATE-10 tile setting apply exposes applied state")
	_assert_true(not bool(progress_snapshot["cancel_available"]), "PERF-61 tile setting apply is not cancellable")
	_assert_eq(_window_child_count(dock), 0, "PERF-61 tile setting apply does not create modal busy window")

	var apply_count_before := int(dock.tile_settings_apply_debounce_snapshot()["apply_count"])
	dock._tile_settings_apply_debounce_sec = 0.01
	dock._on_tile_setting_changed(66.0)
	dock._on_tile_setting_changed(67.0)
	var debounce_snapshot = dock.tile_settings_apply_debounce_snapshot()
	_assert_true(bool(debounce_snapshot["pending"]), "PERF-62 repeated tile setting changes leave one pending apply")
	_assert_eq(String(debounce_snapshot["state_id"]), HexMapGenerationRunState.STATE_PREVIEW_QUEUED, "STATE-10 tile setting change enters queued preview state")
	_assert_eq(String(debounce_snapshot["heavy_update_reason"]), "tile_setting", "STATE-10 tile setting change records heavy update reason")
	_assert_eq(int(debounce_snapshot["apply_count"]), apply_count_before, "PERF-62 pending debounced apply does not run immediately")
	_assert_eq(
		String((debounce_snapshot["progress"] as Dictionary)["status"]),
		"Tile settings update queued",
		"PERF-62 pending debounced apply reports queued progress"
	)
	await _wait_for_tile_settings_apply_count(dock, apply_count_before + 1, "PERF-62 debounced tile settings")
	debounce_snapshot = dock.tile_settings_apply_debounce_snapshot()
	_assert_true(not bool(debounce_snapshot["pending"]), "PERF-62 debounced tile setting apply clears pending state")
	_assert_eq(int(debounce_snapshot["apply_count"]), apply_count_before + 1, "PERF-62 repeated tile settings coalesce to one apply")
	_assert_eq(String(debounce_snapshot["state_id"]), HexMapGenerationRunState.STATE_APPLIED_TILE_SETTINGS, "STATE-10 debounced tile setting apply exposes applied state")
	_assert_eq(
		String((debounce_snapshot["progress"] as Dictionary)["status"]),
		"Tile settings applied",
		"PERF-62 debounced apply finishes through progress UI"
	)

	apply_count_before = int(dock.tile_settings_apply_debounce_snapshot()["apply_count"])
	dock._tile_orientation_option.select(1)
	dock._on_tile_orientation_changed(1)
	debounce_snapshot = dock.tile_settings_apply_debounce_snapshot()
	_assert_true(bool(debounce_snapshot["pending"]), "STATE-10 orientation change queues tile settings apply")
	_assert_eq(String(debounce_snapshot["state_id"]), HexMapGenerationRunState.STATE_PREVIEW_QUEUED, "STATE-10 orientation change enters queued preview state")
	_assert_eq(String(debounce_snapshot["heavy_update_reason"]), "orientation", "STATE-10 orientation change records heavy update reason")
	await _wait_for_tile_settings_apply_count(dock, apply_count_before + 1, "STATE-10 debounced orientation tile settings")

	layer.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_run_state_drives_progress_without_mirror_fields() -> void:
	var dock = await _new_ready_dock()
	var started_msec := Time.get_ticks_msec()

	dock._generation_run_state.update_from_context({
		"running": true,
		"progress": 0.41,
		"status": "Generating",
		"step": HexMapGenDock.PROGRESS_STEP_GENERATING,
		"cancel_requested": true,
		"visible": true,
		"progress_bar_visible": true,
		"progress_visible_started_msec": started_msec,
		"cancel_available": true,
	})
	if dock._generation_progress_status_label != null:
		dock._generation_progress_status_label.text = "Generating"
	dock._sync_generation_run_state("run-state-driven progress test")
	var status = dock.generation_status()
	_assert_true(bool(status["running"]), "generation status reflects run-state running")
	_assert_eq(float(status["progress"]), 0.41, "generation status reflects run-state progress")
	_assert_eq(String(status["status"]), "Generating", "generation status reflects run-state status")
	_assert_eq(String(status["step"]), HexMapGenDock.PROGRESS_STEP_GENERATING, "generation status reflects run-state step")
	_assert_true(bool(status["cancel_requested"]), "generation status reflects run-state cancel request")
	var view_state = dock.generation_run_view_state()
	_assert_true(bool(view_state["controls_disabled"]), "run-state running disables controls")
	_assert_eq(
		String(view_state["status_text"]),
		"Generating",
		"run-state status text flows into view-state text"
	)
	_assert_eq(int(view_state["progress_visible_started_msec"]), started_msec, "run-state timestamp flows into view state")

	dock._generation_run_state.update_from_context({
		"running": false,
		"status": "Ready",
		"progress": 1.0,
		"step": HexMapGenDock.PROGRESS_STEP_COMPLETE,
		"cancel_requested": false,
	})
	dock._sync_generation_run_state("run-state-driven status clear")
	status = dock.generation_status()
	_assert_true(not bool(status["running"]), "run-state stop clears generation running")
	_assert_eq(String(status["status"]), "Ready", "run-state status ready is reflected in generation status")
	_assert_true(
		not bool(status["cancel_requested"]),
		"run-state cancel-request clear is reflected in generation status"
	)
	dock.queue_free()
	await process_frame


func _test_generation_dock_debug_report_includes_validation_summary() -> void:
	var dock = await _new_ready_dock()
	dock._current_data = HexMapData.rectangle(1, 1)
	dock._current_orientation = HexMapResource.ORIENTATION_FLAT_TOP

	var summary = dock.validation_debug_summary()
	var report = dock.debug_report_text()
	_assert_eq(bool(summary.get("generated_map_present", false)), true, "generation validation summary sees current map")
	_assert_eq(int(summary.get("errors", -1)), 0, "generation validation summary reports no errors for valid map")
	_assert_true(report.contains("Hex Map Generate Debug Report"), "generation debug report has a stable header")
	_assert_true(report.contains("validation_summary:"), "generation debug report includes validation summary")
	_assert_true(not dock._stats_label.text.contains("validation_summary"), "generation stats label does not include validation dump")

	dock.queue_free()
	await process_frame


func _test_generation_dock_validates_generation_result_before_auto_apply() -> void:
	var dock = await _new_ready_dock()
	var scene_root = Node2D.new()
	scene_root.name = "ValidationAutoApplyRoot"
	root.add_child(scene_root)
	var layer = TileMapLayer.new()
	layer.name = "ValidationAutoApplyLayer"
	scene_root.add_child(layer)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	dock._tile_layer_option.select(1)
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(layer), "generation validation test configures sample tiles")

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._refresh_controls()

	_assert_true(not bool(dock.generation_validation_summary().get("validated", true)), "generation validation starts uncaptured")
	dock._on_generate_pressed()
	await _wait_for_progress_controls(dock, "validation Generate button generation")
	await _wait_for_generation(dock, "validation Generate button generation")

	var summary = dock.generation_validation_summary()
	_assert_true(dock.generation_validation_result() != null, "generation validation stores raw result")
	_assert_true(bool(summary.get("validated", false)), "generation validation summary records validation run")
	_assert_true(bool(summary.get("passed", false)), "valid generated map passes validation")
	_assert_eq(int(summary.get("errors", -1)), 0, "valid generated map records zero validation errors")
	_assert_true(int(summary.get("capture_order", 0)) > 0, "generation validation records capture order")
	_assert_true(
		int(summary.get("apply_order", 0)) > int(summary.get("capture_order", 0)),
		"generation validation is captured before auto apply"
	)
	_assert_eq(layer.get_used_cells().size(), 2, "generation still auto applies after validation capture")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_captures_generation_validation_failure() -> void:
	var dock = await _new_ready_dock()
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	document.terrain_layers[0].default_floor_key = "terrain.floor"
	document.terrain_layers[0].default_wall_key = "terrain.wall"
	HexMapDocumentAdapter.set_label(document, HexVector.q_axis(), {
		"label_id": "outside",
		"text": "Outside",
	})

	var result = dock.validate_generation_document(document, {"show_progress": true})
	var summary = dock.generation_validation_summary()
	var progress_snapshot = dock.generation_progress_snapshot()
	_assert_true(result != null, "generation validation failure stores raw result")
	_assert_true(bool(summary.get("validated", false)), "generation validation failure records validation run")
	_assert_true(not bool(summary.get("passed", true)), "invalid generated document records failed validation")
	_assert_true(int(summary.get("errors", 0)) >= 1, "invalid generated document records validation errors")
	_assert_eq(int(summary.get("apply_order", -1)), 0, "direct validation capture does not mark auto apply")
	_assert_true(bool(progress_snapshot.get("visible", false)), "PERF-NEXT-11 direct generation validation shows progress")
	_assert_eq(
		String(progress_snapshot.get("status", "")),
		"Validating generated document",
		"PERF-NEXT-11 direct generation validation uses Generate validating status"
	)
	_assert_eq(
		String(progress_snapshot.get("step", "")),
		HexMapGenDock.PROGRESS_STEP_VALIDATING,
		"PERF-NEXT-11 direct generation validation uses validating step"
	)
	_assert_true(
		is_equal_approx(float(progress_snapshot.get("progress", 0.0)), HexMapGenDock.GENERATION_PROGRESS_APPLY),
		"PERF-NEXT-11 validation progress maps into Generate progress range"
	)
	var generation_validation_progress = summary.get("validation_progress", {}) as Dictionary
	_assert_eq(
		String(generation_validation_progress.get("phase", "")),
		HexMapDocumentValidator.VALIDATION_PHASE_COMPLETE,
		"PERF-NEXT-11 generation validation summary stores final validator progress"
	)
	_assert_eq(
		String(result.issues[0].get("rule_id", "")),
		"document.orphan_payload",
		"invalid generated document records failing rule id"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_batch_runner_scores_and_sorts() -> void:
	var dock = await _new_ready_dock()
	dock._current_data = HexMapData.rectangle(1, 1)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(3)
	dock._rect_height_spin.set_value_no_signal(2)
	dock._wall_prob_slider.set_value_no_signal(0.45)
	dock._connect_method_option.select(_connect_method_index(HexMapGenerator.CONNECT_DENSE))
	dock._refresh_controls()

	var rows = dock.run_generation_batch(3, {"seeds": [501, 502, 503]})
	_assert_eq(rows.size(), 3, "generation batch creates one row per explicit seed")
	_assert_eq(dock._current_data.cells.size(), 1, "generation batch does not promote candidate into current map")
	for row in rows:
		var summary: Dictionary = row["validation_summary"]
		var generation_result = row.get("generation_result", null) as HexGenerationResultResource
		_assert_eq(String(row.get("status", "")), "generated", "generation batch row records generated status")
		_assert_eq(int(row.get("cells", 0)), 6, "generation batch row records generated cell count")
		_assert_true(row.has("score"), "generation batch row records score")
		_assert_true(generation_result is HexGenerationResultResource, "GENPIPE-NEXT-10 batch row carries generation result resource")
		_assert_eq(String(row.get("generation_result_id", "")), generation_result.result_id, "GENPIPE-NEXT-10 batch row exposes result id")
		_assert_true(bool(row.get("replay_available", false)), "GENPIPE-NEXT-10 generated row is replayable")
		_assert_true(generation_result.replay_document() is HexMapDocumentResource, "GENPIPE-NEXT-10 result resource replays candidate document")
		var result_scope = row.get("result_scope", {}) as Dictionary
		_assert_true(bool(result_scope.get("primary_map_present", false)), "GENPIPE-NEXT-10 result scope exposes primary map")
		_assert_true(bool(result_scope.get("candidate_document_present", false)), "GENPIPE-NEXT-10 result scope exposes candidate document")
		_assert_true(bool(result_scope.get("validation_result_present", false)), "GENPIPE-NEXT-10 result scope exposes validation result")
		_assert_true(bool(summary.get("validated", false)), "generation batch row records validation summary")
		_assert_true(bool(summary.get("passed", false)), "generation batch row passes validation")
		_assert_eq(int(row.get("validation_errors", -1)), 0, "generation batch row flattens validation errors")
		var preview = row["preview"] as Dictionary
		_assert_true(bool(preview["available"]), "GEN-NEXT-11 generation batch row exposes preview")
		_assert_eq(String(preview["source_kind"]), HexMapPreviewThumbnail.SOURCE_MAP_DATA, "GEN-NEXT-11 batch preview comes from generated map data")
		_assert_eq(int(preview["cell_count"]), int(row.get("cells", 0)), "GEN-NEXT-11 batch preview matches row cell count")
		_assert_true(int(preview["entry_count"]) <= int(preview["budget"]), "GEN-NEXT-11 batch preview respects budget")
		_assert_true(not bool(preview["sample_source"]), "GEN-NEXT-11 batch preview does not use sample source")

	var score_table = dock.generation_batch_score_table("score", true)
	_assert_eq(score_table.size(), 3, "score table returns every batch row")
	for index in range(score_table.size() - 1):
		_assert_true(
			float(score_table[index].get("score", 0.0)) >= float(score_table[index + 1].get("score", 0.0)),
			"score table sorts by descending score"
		)
	_assert_eq(int(score_table[0].get("rank", 0)), 1, "score table assigns first rank")

	var seed_table = dock.generation_batch_score_table("seed", false)
	_assert_eq(int(seed_table[0].get("seed", 0)), 501, "score table sorts by seed ascending")
	_assert_eq(int(seed_table[2].get("seed", 0)), 503, "score table keeps seed ascending order")

	_assert_true(dock._seed_lab_count_spin != null, "generation dock exposes Seed Lab seed count")
	_assert_true(dock._seed_lab_run_button != null, "generation dock exposes Seed Lab batch run")
	_assert_true(dock._seed_lab_score_tree != null, "generation dock exposes Seed Lab score table")
	_assert_true(dock._seed_lab_promote_button != null, "generation dock exposes Promote to Document")
	dock._seed_lab_count_spin.set_value_no_signal(3)
	dock._on_seed_lab_run_pressed()
	var score_root = dock._seed_lab_score_tree.get_root()
	_assert_true(score_root.get_first_child() != null, "Seed Lab score table renders rows")
	var first_score_item = score_root.get_first_child()
	first_score_item.select(0)
	dock._on_seed_lab_score_selected()
	_assert_true(dock._seed_lab_preview_label.text.contains("Selected Seed:"), "Seed Lab selection updates preview")
	var selected_preview = dock._seed_lab_preview_thumbnail.preview_snapshot()
	_assert_true(bool(selected_preview["available"]), "GEN-NEXT-11 Seed Lab selected row thumbnail is available")
	_assert_eq(String(selected_preview["source_context"]), "generate_batch_row", "GEN-NEXT-11 Seed Lab selected thumbnail uses row preview")
	dock._on_seed_lab_promote_pressed()
	_assert_true(dock.promoted_generation_document() is HexMapDocumentResource, "Seed Lab promotes selected row to document")
	_assert_true(dock._seed_lab_status_label.text.contains("Dirty: yes"), "Seed Lab promotion displays dirty state")

	dock.queue_free()
	await process_frame


func _test_generation_dock_promotes_batch_seed_to_canonical_document() -> void:
	var dock = await _new_ready_dock()
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._connect_method_option.select(_connect_method_index(HexMapGenerator.CONNECT_DENSE))
	dock._refresh_controls()

	dock.run_generation_batch(2, {"seeds": [801, 802]})
	var chosen = dock.generation_batch_score_table("score", true)[0]
	var chosen_result = chosen.get("generation_result", null) as HexGenerationResultResource
	_assert_true(chosen_result is HexGenerationResultResource, "GENPIPE-NEXT-10 score row carries result resource")
	_assert_true(dock.replay_generation_result_document(chosen_result) is HexMapDocumentResource, "GENPIPE-NEXT-10 dock replays result resource document")
	var document = dock.promote_generation_batch_row(chosen)
	_assert_true(document is HexMapDocumentResource, "promoted seed creates a document resource")
	_assert_true(document.metadata != null, "promoted seed creates document metadata")
	_assert_eq(document.terrain_layers.size(), 1, "promoted seed stores typed terrain layer")
	_assert_true(document.terrain_layers[0].map != null, "promoted terrain layer stores map resource")
	_assert_eq(document.terrain_layers[0].map.to_map_data().cells.size(), 2, "promoted seed stores generated map cells")
	_assert_eq(document.metadata.generation_seed, int(chosen.get("seed", 0)), "promoted metadata stores chosen seed")
	_assert_eq(
		int(document.metadata.generation_snapshot.get("seed", 0)),
		int(chosen.get("seed", 0)),
		"promoted metadata stores generation snapshot seed"
	)
	_assert_eq(
		int(document.metadata.generation_snapshot.get("rect_width", 0)),
		2,
		"promoted metadata stores generation snapshot settings"
	)
	_assert_true(
		not document.metadata.generation_snapshot.has("generation_id"),
		"promoted metadata omits transient generation id"
	)
	_assert_eq(
		int(document.metadata.custom_properties.get("generation_batch_index", -1)),
		int(chosen.get("index", -2)),
		"promoted metadata stores source batch index"
	)
	_assert_true(
		document.metadata.custom_properties.get("generation_validation_summary", {}) is Dictionary,
		"promoted metadata stores validation summary"
	)
	_assert_eq(
		String(document.metadata.custom_properties.get("generation_result_id", "")),
		chosen_result.result_id,
		"GENPIPE-NEXT-10 promoted metadata stores result id"
	)

	var path = _test_resource_path("test_generation_seed_promoted_document.tres")
	_save_resource(path, document)
	var loaded = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	_assert_true(loaded is HexMapDocumentResource, "promoted seed saved document reloads as document")
	_assert_eq(loaded.metadata.generation_seed, document.metadata.generation_seed, "reloaded promoted document keeps seed")
	_assert_eq(
		int(loaded.metadata.generation_snapshot.get("seed", 0)),
		document.metadata.generation_seed,
		"reloaded promoted document keeps generation snapshot"
	)

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


func _test_tile_map_adapter_chunked_apply_reports_progress_and_cancel() -> void:
	var data = HexMapData.rectangle(5, 1)
	var fake_layer = FakeTileLayer.new()
	var progress_events: Array = []
	var report := HexMapTileAdapter.apply_to_tile_map_layer_chunked(
		fake_layer,
		data,
		4,
		Vector2i(2, 3),
		5,
		Vector2i(6, 7),
		true,
		true,
		0,
		0,
		{
			"chunk_size": 2,
			"apply_reason": "test_chunked_apply",
			"progress_callback": Callable(self, "_capture_apply_progress_event").bind(progress_events),
		}
	)
	_assert_true(bool(report["ok"]), "PERF-NEXT-10 chunked apply completes")
	_assert_true(bool(report["chunked"]), "PERF-NEXT-10 report marks apply as chunked")
	_assert_eq(int(report["chunk_size"]), 2, "PERF-NEXT-10 report stores chunk size")
	_assert_eq(int(report["total_cells"]), 5, "PERF-NEXT-10 report stores target cell count")
	_assert_eq(int(report["processed_cells"]), 5, "PERF-NEXT-10 report stores processed cell count")
	_assert_eq(int(report["written_cells"]), 5, "PERF-NEXT-10 report stores written cell count")
	_assert_eq(fake_layer.calls.size(), 5, "PERF-NEXT-10 chunked apply writes each cell")
	_assert_true(progress_events.size() >= 4, "PERF-NEXT-10 chunked apply emits clear/chunk/complete progress")
	_assert_eq(String((progress_events[0] as Dictionary)["phase"]), "clear", "PERF-NEXT-10 first progress phase is clear")
	_assert_eq(
		String((progress_events[progress_events.size() - 1] as Dictionary)["phase"]),
		"complete",
		"PERF-NEXT-10 final progress phase is complete"
	)
	_assert_eq(
		String((report["target_scope"] as Dictionary)["target_kind"]),
		"tile_map",
		"PERF-NEXT-10 report stores target scope"
	)

	var cancel_layer = FakeTileLayer.new()
	var cancel_report := HexMapTileAdapter.apply_to_tile_map_layer_chunked(
		cancel_layer,
		data,
		4,
		Vector2i(2, 3),
		5,
		Vector2i(6, 7),
		true,
		true,
		0,
		0,
		{
			"chunk_size": 2,
			"apply_reason": "test_cancelled_apply",
			"cancel_callback": Callable(self, "_cancel_apply_after_processed").bind(2),
		}
	)
	_assert_true(bool(cancel_report["cancelled"]), "PERF-NEXT-10 chunked apply cancel callback cancels apply")
	_assert_true(not bool(cancel_report["ok"]), "PERF-NEXT-10 cancelled apply is not ok")
	_assert_eq(int(cancel_report["processed_cells"]), 2, "PERF-NEXT-10 cancelled apply stops at chunk boundary")
	_assert_eq(cancel_layer.calls.size(), 2, "PERF-NEXT-10 cancelled apply does not write later chunks")


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
	_assert_true(dock._apply_write_policy_option.visible, "Apply Write is visible in Primary mode")

	dock._apply_write_policy_option.select(1)
	var preserving_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_data_to_tile_map_layer(preserving_layer), "generation dock applies current data with Add Item write policy")
	_assert_true(not preserving_layer.cleared, "Apply Write Add Item preserves existing Primary layer cells")

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


func _test_generation_dock_applies_primary_map_to_hex_tile_map_layer() -> void:
	var dock = await _new_ready_dock()

	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	dock._current_data = data
	dock._tile_orientation_option.select(1)
	dock._tile_width_spin.value = HexMapTileAdapter.SAMPLE_TILE_SIZE.x
	dock._tile_height_spin.value = HexMapTileAdapter.SAMPLE_TILE_SIZE.y
	dock._floor_source_spin.value = 4
	dock._floor_atlas_x_spin.value = 0
	dock._floor_atlas_y_spin.value = 0
	dock._wall_source_spin.value = 5
	dock._wall_atlas_x_spin.value = 1
	dock._wall_atlas_y_spin.value = 0
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame

	_assert_true(dock.apply_current_data_to_tile_map_layer(layer), "generation dock applies primary data to HexTileMapLayer")
	_assert_true(layer.hex_map is HexMapResource, "HexTileMapLayer primary apply stores hex_map resource")
	_assert_eq(layer.hex_map.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "HexTileMapLayer primary apply stores orientation")
	_assert_eq(layer.display_used_cell_count(), 2, "HexTileMapLayer primary apply redraws display cells")
	_assert_eq(layer.floor_source_id, 4, "HexTileMapLayer primary apply stores floor source")
	_assert_eq(layer.wall_source_id, 5, "HexTileMapLayer primary apply stores wall source")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i(0, 0), "HexTileMapLayer primary apply uses floor atlas")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.q_axis()), Vector2i(1, 0), "HexTileMapLayer primary apply uses wall atlas")
	var tile_set = layer.display_tile_set()
	_assert_true(tile_set.has_source(4), "HexTileMapLayer primary apply creates floor source")
	_assert_true(tile_set.has_source(5), "HexTileMapLayer primary apply creates wall source")
	_assert_eq(tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "HexTileMapLayer primary apply configures pointy-top axis")

	layer.queue_free()
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


func _test_generation_dock_lists_hex_tile_map_layer_common_target() -> void:
	var dock = await _new_ready_dock()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var plain_layer = TileMapLayer.new()
	plain_layer.name = "PlainLayer"
	scene_root.add_child(plain_layer)
	var hex_layer = HexTileMapLayer.new()
	hex_layer.name = "RuntimeMap"
	scene_root.add_child(hex_layer)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.item_count, 4, "generation dock lists Auto, HexTileMapLayer, plain target, and add new layer")
	_assert_eq(dock._tile_layer_option.get_item_text(1), "RuntimeMap (HexTileMapLayer)", "generation dock prioritizes HexTileMapLayer target")
	_assert_eq(dock._tile_layer_option.get_item_text(2), "PlainLayer", "generation dock keeps plain target label for explicit/Overlay use")
	dock._tile_layer_option.select(1)
	_assert_eq(dock.selected_tile_map_layer(), hex_layer, "generation dock returns selected HexTileMapLayer")
	dock._set_editor_selected_tile_map_layer_for_test(hex_layer)
	_assert_eq(dock._find_editor_selected_tile_map_layer(), hex_layer, "generation dock accepts editor-selected HexTileMapLayer")

	scene_root.queue_free()
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
	dock._tile_settings_apply_debounce_sec = 0.01
	var apply_count_before := int(dock.tile_settings_apply_debounce_snapshot()["apply_count"])
	dock._floor_atlas_x_spin.value = 1
	dock._wall_atlas_x_spin.value = 0
	_assert_true(bool(dock.tile_settings_apply_debounce_snapshot()["pending"]), "PERF-62 SpinBox changes queue debounced tile apply")
	await _wait_for_tile_settings_apply_count(dock, apply_count_before + 1, "target TileMapLayer debounced SpinBox apply")

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
	_assert_true(added_layer is HexTileMapLayer, "add new layer creates a HexTileMapLayer")
	_assert_eq(added_layer.get_parent(), scene_root, "add new layer places HexTileMapLayer under scene root")
	_assert_true(String(added_layer.name).begins_with("HexMapLayer"), "add new layer uses HexMapLayer base name")
	_assert_eq(dock._tile_layer_option.selected, 1, "add new layer selects the created Target")
	_assert_eq(dock._find_editor_selected_tile_map_layer(), added_layer, "add new layer selects the created HexTileMapLayer")

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
	dock._tile_settings_apply_debounce_sec = 0.01
	var apply_count_before := int(dock.tile_settings_apply_debounce_snapshot()["apply_count"])
	dock._tile_width_spin.value = 96
	_assert_true(bool(dock.tile_settings_apply_debounce_snapshot()["pending"]), "PERF-62 TileSet size change queues debounced tile apply")
	await _wait_for_tile_settings_apply_count(dock, apply_count_before + 1, "shared TileSet debounced size apply")

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

	var hex_layer = HexTileMapLayer.new()
	root.add_child(hex_layer)
	await process_frame
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(hex_layer), "generation dock configures sample tiles on HexTileMapLayer")
	var hex_tile_set = hex_layer.display_tile_set()
	_assert_true(hex_tile_set != null, "HexTileMapLayer sample tile setup creates display TileSet")
	_assert_eq(hex_tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "HexTileMapLayer sample tile setup follows dock orientation")
	_assert_true(hex_tile_set.has_source(0), "HexTileMapLayer sample tile setup creates source 0")
	_assert_eq(hex_layer.floor_atlas_coords, Vector2i.ZERO, "HexTileMapLayer sample tile setup stores floor atlas")
	_assert_eq(hex_layer.wall_atlas_coords, Vector2i(1, 0), "HexTileMapLayer sample tile setup stores wall atlas")

	layer.free()
	hex_layer.queue_free()
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


func _test_generation_dock_generate_auto_applies_hex_tile_map_layer() -> void:
	var dock = await _new_ready_dock()

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._refresh_controls()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var layer = HexTileMapLayer.new()
	layer.name = "HexAutoApplyLayer"
	scene_root.add_child(layer)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.item_count, 3, "generation dock lists Auto, HexTileMapLayer target, and add new layer")
	_assert_eq(dock._tile_layer_option.get_item_text(1), "HexAutoApplyLayer (HexTileMapLayer)", "generation dock labels HexTileMapLayer auto apply target")
	dock._tile_layer_option.select(1)

	var generation_id = dock._generation_id
	dock._on_generate_pressed()
	await _wait_for_progress_controls(dock, "HexTileMapLayer auto apply Generate button generation")
	await _wait_for_generation(dock, "HexTileMapLayer auto apply Generate button generation")
	_assert_eq(dock._generation_id, generation_id + 1, "generation dock auto apply HexTileMapLayer generation succeeds")
	_assert_true(layer.hex_map is HexMapResource, "generation dock auto apply stores HexTileMapLayer resource")
	_assert_eq(layer.display_used_cell_count(), 2, "generation dock auto applies regenerated cells to HexTileMapLayer")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i.ZERO, "HexTileMapLayer auto apply writes floor tile atlas")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.q_axis()), Vector2i.ZERO, "HexTileMapLayer auto apply writes every generated floor cell")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_output_target_preview_and_selected_document() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var scene_root = Node2D.new()
	scene_root.name = "OutputTargetScene"
	root.add_child(scene_root)
	var layer = HexTileMapLayer.new()
	layer.name = "OutputTargetHexTileMap"
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	layer.level_document_resource = document
	scene_root.add_child(layer)
	await process_frame

	workspace.set_selected_hex_tile_map_node(layer, "test.node24.select")
	var dock = workspace.generation_dock()
	dock.refresh_tile_layer_options(scene_root)
	dock._tile_layer_option.select(1)
	dock._on_tile_layer_target_selected(1)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._seed_spin.set_value_no_signal(2401)
	dock._refresh_controls()

	var initial_output = dock.output_target_snapshot()
	_assert_true(dock._output_target_option != null, "NODE-24 Generate exposes Output target option")
	_assert_eq(String(initial_output["mode"]), HexMapGenDock.OUTPUT_TARGET_PREVIEW_ONLY, "NODE-24 preview only is the default output target")
	_assert_eq(String(initial_output["label"]), "Preview only", "NODE-24 preview target label is visible")
	_assert_true(not bool(initial_output["generated_document_present"]), "NODE-24 starts without generated output")
	_assert_eq(String(initial_output["preview_result_state"]), "empty", "UI-03 preview result starts empty")
	_assert_eq(String(initial_output["save_result_state"]), "waiting_for_preview", "UI-03 save state waits for generated preview")
	_assert_true(String(initial_output["visible_status_text"]).contains("Preview: none"), "UI-03 output status exposes no-preview state")
	var initial_screen = workspace.generation_screen_snapshot()
	var initial_result = initial_screen["result_summary"] as Dictionary
	var initial_layout = initial_screen["layout"] as Dictionary
	_assert_true(not bool(initial_screen["empty_state_visible"]), "UI-03 unblocked Generate screen has no visible empty-state placeholder")
	_assert_true(not bool(initial_screen["unexplained_empty_area_visible"]), "UI-03 unblocked Generate screen has no unexplained dead-space marker")
	_assert_true(String(initial_result["visible_text"]).contains("Save: waiting for preview"), "UI-03 screen summary exposes initial save state")
	_assert_true(bool(initial_layout["input_profile_preview_apply_save_performance_separated"]), "GEN-NEXT-10 workspace Generate snapshot exposes separated layout")
	_assert_true((initial_screen["generate_layout_section_ids"] as PackedStringArray).has("apply_save"), "GEN-NEXT-10 workspace Generate snapshot exposes Apply/Save section")
	_assert_true((initial_screen["layout_sections"] as Array).size() >= 5, "GEN-NEXT-10 workspace Generate snapshot exposes layout sections")

	_assert_true(await dock._generate_map(), "NODE-24 preview output generation succeeds")
	_assert_true(layer.hex_map is HexMapResource, "NODE-24 preview writes runtime HexTileMap map")
	_assert_eq(layer.display_used_cell_count(), 2, "NODE-24 preview updates selected HexTileMap display")
	_assert_eq(HexMapDocumentAdapter.document_summary(document)["cells"], 1, "NODE-24 preview leaves Level Document unchanged")
	_assert_eq(layer.level_document_resource, document, "NODE-24 preview keeps selected node document reference")
	var preview_output = dock.output_target_snapshot()
	_assert_true(bool(preview_output["generated_document_present"]), "NODE-24 preview snapshot records generated output")
	var candidate_preview = preview_output["candidate_preview"] as Dictionary
	_assert_true(bool(candidate_preview["available"]), "GEN-NEXT-11 Generate candidate preview is available after generation")
	_assert_eq(String(candidate_preview["source_kind"]), HexMapPreviewThumbnail.SOURCE_MAP_DATA, "GEN-NEXT-11 Generate candidate preview uses generated map data")
	_assert_eq(int(candidate_preview["cell_count"]), 2, "GEN-NEXT-11 Generate candidate preview records generated cell count")
	_assert_true(not bool(candidate_preview["sample_source"]), "GEN-NEXT-11 Generate candidate preview does not use sample source")
	_assert_eq(String(dock._candidate_preview_thumbnail.preview_snapshot()["source_context"]), "generate_current_candidate", "GEN-NEXT-11 mounted candidate thumbnail uses current candidate")
	_assert_true(not bool((preview_output["document_generation_metadata"] as Dictionary)["present"]), "NODE-24 preview does not mark document generated")
	_assert_eq(String(preview_output["preview_result_state"]), "ready", "UI-03 preview result state is visible after generation")
	_assert_eq(String(preview_output["document_result_state"]), "unchanged_preview_only", "UI-03 document state stays unchanged in preview-only mode")
	_assert_eq(String(preview_output["save_result_state"]), "available", "UI-03 save state is available after generation")
	_assert_true(String(preview_output["visible_status_text"]).contains("Save: available"), "UI-03 visible status exposes save availability")
	_assert_true(dock._output_target_status_label.text.contains("Preview: ready"), "UI-03 output target label exposes preview result")
	var preview_screen = workspace.generation_screen_snapshot()
	var preview_result = preview_screen["result_summary"] as Dictionary
	var screen_candidate_preview = preview_screen["candidate_preview"] as Dictionary
	_assert_eq(String(preview_result["preview_result_state"]), "ready", "UI-03 screen result summary exposes preview readiness")
	_assert_true(bool(screen_candidate_preview["available"]), "GEN-NEXT-11 workspace Generate snapshot exposes candidate preview")
	_assert_eq(String(preview_result["document_result_state"]), "unchanged_preview_only", "UI-03 screen result summary exposes document state")
	_assert_eq(String(preview_result["save_result_state"]), "available", "UI-03 screen result summary exposes save state")

	dock.set_output_target_mode(HexMapGenDock.OUTPUT_TARGET_SELECTED_DOCUMENT)
	var ready_output = dock.output_target_snapshot()
	_assert_eq(String(ready_output["label"]), "Apply to selected Document", "NODE-24 selected document output target is visible")
	_assert_true(bool(ready_output["can_apply_selected_document"]), "NODE-24 selected document output can apply when node/document/generated output exist")
	_assert_eq(String(ready_output["document_result_state"]), "ready_to_apply", "UI-03 document output state is ready to apply")
	var apply_result = dock.apply_current_generation_to_selected_document()
	_assert_true(bool(apply_result["ok"]), "NODE-24 applies current generation to selected document")
	var apply_report = apply_result["apply_report"] as Dictionary
	_assert_true(bool(apply_report["ok"]), "PERF-NEXT-10 selected document apply report succeeds")
	_assert_true(bool(apply_report["chunked"]), "PERF-NEXT-10 selected document apply uses chunked report")
	_assert_eq(int(apply_report["total_cells"]), 2, "PERF-NEXT-10 selected document report stores target cell count")
	_assert_eq(int(apply_report["processed_cells"]), 2, "PERF-NEXT-10 selected document report stores processed count")
	_assert_eq(
		String((apply_report["target_scope"] as Dictionary)["target_kind"]),
		"hex_tile_map_layer",
		"PERF-NEXT-10 selected document report stores HexTileMapLayer target scope"
	)
	_assert_eq(HexMapDocumentAdapter.document_summary(document)["cells"], 2, "NODE-24 apply replaces selected Level Document terrain")
	_assert_eq(workspace.workspace_asset_context().level_document, document, "NODE-24 apply updates workspace Level Document relationship")
	_assert_eq(session.current_document(), document, "NODE-24 apply updates session current document")
	var applied_output = dock.output_target_snapshot()
	var output_apply_report = applied_output["last_tile_map_apply_report"] as Dictionary
	_assert_eq(
		int(output_apply_report["processed_cells"]),
		2,
		"PERF-NEXT-10 output target snapshot stores last chunked apply report"
	)
	_assert_eq(String(applied_output["document_result_state"]), "updated", "UI-03 document output state reflects applied generation")
	_assert_true(String(applied_output["visible_status_text"]).contains("Document: updated"), "UI-03 visible status exposes applied document result")
	var applied_screen = workspace.generation_screen_snapshot()
	var applied_result = applied_screen["result_summary"] as Dictionary
	_assert_eq(String(applied_result["document_result_state"]), "updated", "UI-03 screen summary exposes applied document state")
	var metadata = (applied_output["document_generation_metadata"] as Dictionary)
	_assert_true(bool(metadata["present"]), "NODE-24 apply records generated metadata on document")
	_assert_eq(String(metadata["generation_source"]), "hex_map_gen_dock", "NODE-24 apply records Generate as metadata source")
	_assert_eq(String(metadata["generation_output_target"]), HexMapGenDock.OUTPUT_TARGET_SELECTED_DOCUMENT, "NODE-24 apply records output target metadata")
	_assert_eq(int(metadata["generation_seed"]), 2401, "NODE-24 apply records generation seed metadata")
	_assert_true((metadata["generation_snapshot"] as Dictionary).has("rect_width"), "NODE-24 apply records generation snapshot metadata")

	var writeback = workspace.selected_hex_tile_map_writeback_snapshot()
	var relationships = writeback["relationships"] as Dictionary
	var document_relationship = relationships[HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT] as Dictionary
	_assert_eq(String(document_relationship["status"]), "linked", "NODE-24 Resources relationship remains linked after apply")
	var relationship_metadata = document_relationship["generation_metadata"] as Dictionary
	_assert_true(bool(relationship_metadata["present"]), "NODE-24 Resources relationship exposes generated metadata")
	_assert_eq(String(relationship_metadata["generation_output_target"]), HexMapGenDock.OUTPUT_TARGET_SELECTED_DOCUMENT, "NODE-24 Resources relationship classifies generated output target")

	workspace.clear_selected_hex_tile_map_layer("test.node24.clear")
	var blocked = dock.apply_current_generation_to_selected_document()
	_assert_true(not bool(blocked["ok"]), "NODE-24 apply blocks without selected HexTileMap")
	_assert_eq(String(blocked["blocked_reason"]), "No HexTileMap selected", "NODE-24 no selected node reason is visible")
	_assert_eq(String(dock.output_target_snapshot()["blocked_reason"]), "No HexTileMap selected", "NODE-24 output target snapshot keeps no-selection reason")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _test_generation_profile_options_drive_generation_snapshot() -> void:
	var dock = await _new_ready_dock()
	var context := HexMapWorkspaceAssetContext.new()
	dock.set_workspace_asset_context(context)
	var baseline_snapshot = dock._create_generation_snapshot()
	_assert_true(
		not bool(baseline_snapshot.get("generation_profile_used", true)),
		"PROFILE-NEXT-11 missing Generation Profile keeps default snapshot path"
	)

	var profile := HexGenerationProfileResource.new()
	profile.default_seed = 331
	profile.shape_id = "hexagon"
	profile.radius = 3
	profile.wall_probability = 0.0
	profile.connectivity_mode = "none"
	context.set_generation_profile(profile)

	var snapshot = dock._create_generation_snapshot()
	_assert_true(bool(snapshot["generation_profile_used"]), "PROFILE-NEXT-11 snapshot records Generation Profile use")
	_assert_eq(int(snapshot["seed"]), 331, "PROFILE-NEXT-11 Generation Profile seed drives snapshot")
	_assert_eq(int(snapshot["shape"]), HexMapGenDock.SHAPE_HEXAGON, "PROFILE-NEXT-11 Generation Profile shape drives snapshot")
	_assert_eq(bool(snapshot["symmetric"]), false, "PROFILE-NEXT-11 hexagon profile uses primary generation")
	_assert_eq(int(snapshot["hex_radius"]), 3, "PROFILE-NEXT-11 Generation Profile radius drives snapshot")
	_assert_eq(float(snapshot["wall_probability"]), 0.0, "PROFILE-NEXT-11 Generation Profile terrain drives snapshot")
	_assert_eq(
		int(snapshot["connect_method"]),
		HexMapGenerator.CONNECT_NONE,
		"PROFILE-NEXT-11 Generation Profile connectivity drives snapshot"
	)
	var profile_options = snapshot["generation_profile_options"] as Dictionary
	_assert_eq(String(profile_options["shape_id"]), "hexagon", "PROFILE-NEXT-11 snapshot keeps raw profile options")

	var data = dock._generate_data_from_snapshot(snapshot, {})
	_assert_eq(data.cells.size(), 37, "PROFILE-NEXT-11 profile snapshot generates radius 3 hexagon")
	_assert_eq(data.walls.size(), 0, "PROFILE-NEXT-11 profile terrain probability drives generated walls")

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
	dock.register_mapdata_source(HexMapResource.from_map_data(data), "res://overlay_basic.tres")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, dock._mapdata_sources[0]["id"], "Floor")
	dock._refresh_controls()

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

	_assert_true(dock._current_data == null, "overlay generation does not require current primary data")
	_assert_true(dock._apply_write_policy_option.visible, "Apply Write remains visible in Overlay mode")
	_assert_true(await dock._generate_map(), "generation dock generates overlay data")
	_assert_true(dock._current_overlay_data != null, "overlay generation stores current overlay data")
	_assert_eq(dock._current_overlay_data.item_cells("Tree").size(), data.floor_cells().size(), "overlay uniform generation uses primary floor cells as candidates")
	_assert_eq(dock._current_overlay_data.item_cells("Rock").size(), 0, "overlay uniform generation honors item weights")
	_assert_eq(layer.get_used_cells().size(), data.floor_cells().size(), "overlay generation auto applies overlay cells to Target")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "overlay apply uses Wall atlas controls as item tile")
	_assert_true(dock.current_resource() is HexOverlayResource, "overlay mode saves current overlay resource")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_applies_to_hex_tile_map_layer() -> void:
	var dock = await _new_ready_dock()
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_item_pool_rows[0]["name"].text = "Tree"
	dock._overlay_item_pool_rows[0]["tile_source"].value = 0
	dock._overlay_item_pool_rows[0]["tile_atlas_x"].value = 1
	dock._overlay_item_pool_rows[0]["tile_atlas_y"].value = 0
	dock._refresh_controls()
	var data = HexMapData.rectangle(2, 1)
	dock._current_overlay_data = HexOverlayData.from_item_cells(data.cells, "Tree", data.cells)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(data))

	_assert_true(dock.apply_current_overlay_data_to_tile_map_layer(layer), "generation dock applies overlay data to HexTileMapLayer")
	var origin_map_cell = HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true)
	_assert_eq(layer._overlay_tile_map.get_cell_atlas_coords(origin_map_cell), Vector2i(1, 0), "HexTileMapLayer overlay apply writes overlay atlas")
	var state = layer.display_state_for_hex(HexVector.zero())
	_assert_eq(state["overlay_count"], 1, "HexTileMapLayer overlay apply exposes overlay state")
	var snapshot = layer.to_document_resource()
	var snapshot_tile_entries = HexMapDocumentAdapter.document_tile_entries(snapshot)
	_assert_eq(snapshot_tile_entries.size(), 2, "HexTileMapLayer overlay apply exports overlay entries")
	_assert_eq(snapshot_tile_entries[0]["kind"], HexMapDocumentAdapter.KIND_OVERLAY, "HexTileMapLayer overlay snapshot stores overlay kind")

	layer.queue_free()
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
	var data = HexMapData.rectangle(4, 1)
	dock.register_mapdata_source(HexMapResource.from_map_data(data), "res://overlay_limit.tres")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, dock._mapdata_sources[0]["id"], "Floor")
	dock._refresh_controls()

	_assert_eq(dock._overlay_item_pool_rows[0]["amount_label"].text, "Limit", "overlay limited uniform mode shows item limits")
	_assert_true(not dock._wall_prob_row.visible, "overlay limited uniform mode hides placement probability")
	_assert_true(await dock._generate_map(), "generation dock generates limited overlay data")
	_assert_eq(dock._current_overlay_data.item_cells("Coin").size(), 2, "overlay limited generation places requested item count")
	_assert_eq(dock._current_overlay_data.item_cells("Gem").size(), 1, "overlay limited generation supports multiple item limits")

	dock._overlay_item_pool_rows[0]["name"].text = "Key"
	dock._overlay_item_pool_rows[0]["amount"].value = 1
	dock._overlay_item_pool_rows[1]["amount"].value = 0
	dock._apply_write_policy_option.select(1)
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
	var data = HexMapData.rectangle(3, 1)
	data.set_walls([HexVector.q_axis()])
	var source_id = dock.register_mapdata_source(HexMapResource.from_map_data(data), "res://mask_data.tres")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Wall")
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
	dock._overlay_neighbor_radius_spin.value = 1
	dock._overlay_adjacency_rules_edit.text = "1=1.0;default=0.0"
	var data = HexMapData.hexagon(1)
	data.set_walls([HexVector.q_axis()])
	var source_id = dock.register_mapdata_source(HexMapResource.from_map_data(data), "res://adjacency_data.tres")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Floor")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_REFERENCE, source_id, "Wall")
	dock._refresh_controls()

	_assert_eq(dock._generate_option.selected, HexMapGenDock.GENERATE_SYMMETRIC, "adjacency reference switches overlay generation to Markov Mesh")
	_assert_true(dock._overlay_reference_container.visible, "adjacency reference shows reference controls")
	_assert_true(await dock._generate_map(), "generation dock generates adjacency overlay")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "NearWall"), "adjacency reference generates item next to reference cell")
	_assert_true(not dock._current_overlay_data.has_item(HexVector.apply_basis(-1, 1, 0), "NearWall"), "adjacency reference leaves cells without matching neighbor rule empty")

	dock.queue_free()
	await process_frame


func _test_generation_dock_adjacency_generated_reference_snapshot() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_adjacency_check.set_pressed_no_signal(true)
	dock._on_overlay_adjacency_toggled(true)
	dock._refresh_controls()

	_assert_true(dock._overlay_generated_reference_check.visible, "Generated Item Reference control is visible for adjacency overlay")
	var static_snapshot = dock._create_generation_snapshot()
	_assert_true(
		not bool(static_snapshot.get("overlay_generated_reference_enabled", true)),
		"Generated Item Reference is disabled in snapshot by default"
	)

	dock._overlay_generated_reference_check.set_pressed_no_signal(true)
	var dynamic_snapshot = dock._create_generation_snapshot()
	_assert_true(
		bool(dynamic_snapshot.get("overlay_generated_reference_enabled", false)),
		"Generated Item Reference checkbox is reflected in generation snapshot"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_adjacency_generated_reference_changes_result() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_adjacency_check.set_pressed_no_signal(true)
	dock._on_overlay_adjacency_toggled(true)
	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._gen_radius_spin.set_value_no_signal(1)
	dock._overlay_item_name_edit.text = "Vine"
	dock._overlay_neighbor_radius_spin.value = 1
	dock._overlay_adjacency_rules_edit.text = "1=1.0;default=0.0"
	var first_candidate = HexVector.q_axis()
	var second_candidate = HexVector.q_axis().scaled(2)
	var source_data = HexOverlayData.from_cells(
		HexMapData.square(3, false).cells,
		{
			"Candidate": [first_candidate, second_candidate],
			"Seed": [HexVector.zero()],
		}
	)
	var source_id = dock.register_mapdata_source(
		HexOverlayResource.from_overlay_data(source_data),
		"res://generated_reference.tres"
	)
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Candidate")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_REFERENCE, source_id, "Seed")
	dock._refresh_controls()

	var static_snapshot = dock._create_generation_snapshot()
	var static_data = dock._generate_overlay_data_from_snapshot(static_snapshot, {})
	_assert_keys_eq(
		static_data.item_cells("Vine"),
		[first_candidate],
		"adjacency snapshot without Generated Item Reference keeps generated items out of reference stats"
	)

	dock._overlay_generated_reference_check.set_pressed_no_signal(true)
	var dynamic_snapshot = dock._create_generation_snapshot()
	var dynamic_data = dock._generate_overlay_data_from_snapshot(dynamic_snapshot, {})
	_assert_keys_eq(
		dynamic_data.item_cells("Vine"),
		[first_candidate, second_candidate],
		"adjacency snapshot with Generated Item Reference uses generated target items as later references"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_item_pool_tile_mapping() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_item_pool_rows[0]["name"].text = "Tree"
	dock._overlay_item_pool_rows[0]["tile_atlas_x"].value = 0
	dock._overlay_item_pool_rows[0]["tile_atlas_y"].value = 0
	dock._floor_source_spin.set_value_no_signal(0)
	dock._floor_atlas_x_spin.set_value_no_signal(0)
	dock._floor_atlas_y_spin.set_value_no_signal(0)
	dock._on_overlay_item_tile_copy_pressed(dock._overlay_item_pool_rows[0], false)
	_assert_eq(dock._overlay_item_pool_rows[0]["tile_source"].value, 0.0, "item pool copies Floor tile source")
	_assert_eq(dock._overlay_item_pool_rows[0]["tile_atlas_x"].value, 0.0, "item pool copies Floor tile atlas x")
	_assert_eq(dock._overlay_item_pool_rows[0]["tile_atlas_y"].value, 0.0, "item pool copies Floor tile atlas y")
	dock._on_overlay_add_item_pressed()
	dock._overlay_item_pool_rows[1]["name"].text = "Rock"
	dock._wall_source_spin.set_value_no_signal(0)
	dock._wall_atlas_x_spin.set_value_no_signal(1)
	dock._wall_atlas_y_spin.set_value_no_signal(0)
	dock._on_overlay_item_tile_copy_pressed(dock._overlay_item_pool_rows[1], true)
	_assert_eq(dock._overlay_item_pool_rows[1]["tile_source"].value, 0.0, "item pool copies Wall tile source")
	_assert_eq(dock._overlay_item_pool_rows[1]["tile_atlas_x"].value, 1.0, "item pool copies Wall tile atlas x")
	_assert_eq(dock._overlay_item_pool_rows[1]["tile_atlas_y"].value, 0.0, "item pool copies Wall tile atlas y")
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
	_assert_eq(layer.get_cell_source_id(Vector2i.ZERO), 0, "overlay item pool maps Tree to copied source")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(0, 0), "overlay item pool maps Tree to copied Floor tile")
	_assert_eq(layer.get_cell_source_id(Vector2i(1, 0)), 0, "overlay item pool maps Rock to copied source")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i(1, 0)), Vector2i(1, 0), "overlay item pool maps Rock to copied Wall tile")

	var replacing_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_overlay_data_to_tile_map_layer(replacing_layer), "overlay apply clears with Clear And Write")
	_assert_true(replacing_layer.cleared, "Apply Write Clear And Write clears existing Overlay layer cells")

	dock._apply_write_policy_option.select(1)
	var fake_overlay_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_overlay_data_to_tile_map_layer(fake_overlay_layer), "overlay apply works without clearing")
	_assert_true(not fake_overlay_layer.cleared, "Apply Write Add Item preserves existing Overlay layer cells")

	layer.free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_catalog_selectors_drive_tile_defaults() -> void:
	var dock = await _new_ready_dock()
	_assert_true(dock.tile_catalog() != null, "generation dock loads sample tile catalog")
	_assert_true(dock._floor_catalog_option.item_count >= 2, "generation dock floor catalog lists sample entries")
	_assert_true(dock._wall_catalog_option.item_count >= 2, "generation dock wall catalog lists sample entries")

	dock._select_catalog_option_by_key(dock._floor_catalog_option, "terrain.floor")
	dock._on_floor_catalog_selected(dock._floor_catalog_option.selected)
	dock._select_catalog_option_by_key(dock._wall_catalog_option, "terrain.wall")
	dock._on_wall_catalog_selected(dock._wall_catalog_option.selected)
	_assert_eq(dock._catalog_key_from_option(dock._floor_catalog_option), "terrain.floor", "generation floor selector stores catalog key")
	_assert_eq(dock._catalog_key_from_option(dock._wall_catalog_option), "terrain.wall", "generation wall selector stores catalog key")

	dock._overlay_item_pool_rows[0]["name"].text = "Treasure"
	var overlay_option: OptionButton = dock._overlay_item_pool_rows[0]["catalog_option"]
	dock._select_catalog_option_by_key(overlay_option, "overlay.treasure")
	dock._on_overlay_item_catalog_selected(overlay_option.selected, dock._overlay_item_pool_rows[0])
	_assert_eq(dock._catalog_key_from_option(overlay_option), "overlay.treasure", "overlay item pool selector stores catalog key")
	dock._current_overlay_data = HexOverlayData.from_cells([HexVector.zero()], {"Treasure": [HexVector.zero()]})
	var catalog_configs = dock._overlay_item_tile_configs()
	_assert_eq(catalog_configs["Treasure"]["catalog_key"], "overlay.treasure", "overlay item pool config preserves catalog key")
	_assert_eq(catalog_configs["Treasure"]["atlas_coords"], Vector2i(0, 0), "overlay item pool catalog resolves atlas coords")

	dock.queue_free()
	await process_frame


func _test_generation_dock_mapdata_source_registry_load_reload_clear() -> void:
	var dock = await _new_ready_dock()
	var path = _test_resource_path("test_mapdata_source_overlay.tres")
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
	_assert_true(_has_button_text(dock, "Refresh Source"), "UI-03 source registry reload action explains source-file refresh")
	_assert_true(not _has_button_text(dock, "Reload"), "UI-03 source registry removes ambiguous reload wording")
	var refresh_source_button := _button_with_text(dock, "Refresh Source")
	_assert_true(refresh_source_button != null, "GEN-NEXT-10 source registry refresh action is mounted")
	_assert_eq(String(refresh_source_button.get_meta("hex_generate_action_purpose", "")), "refresh_mapdata_source", "GEN-NEXT-10 source registry refresh purpose is explicit")
	_assert_true(
		dock._source_entry_details_text(dock._mapdata_sources[0]).contains("Tree: 1"),
		"source registry details show overlay item cell count"
	)
	_assert_true(
		dock._source_entry_details_text(dock._mapdata_sources[0]).contains(path),
		"source registry details show resource path"
	)

	var reloaded = HexOverlayData.from_cells(
		[HexVector.zero()],
		{"Rock": [HexVector.zero()]}
	)
	_save_resource(path, HexOverlayResource.from_overlay_data(reloaded))
	var reloaded_id = dock.load_mapdata_source(path)
	_assert_eq(reloaded_id, source_id, "same source path reloads existing entry")
	_assert_eq(dock._mapdata_sources.size(), 1, "same source path does not add duplicate")
	_assert_eq(dock._mapdata_sources[0]["item_keys"], ["Rock"], "reload updates item keys")

	var map_data = HexMapData.rectangle(2, 1)
	map_data.set_walls([HexVector.q_axis()])
	var map_id = dock.register_mapdata_source(HexMapResource.from_map_data(map_data), "res://source_registry_map.tres")
	var map_entry = dock._source_entry_by_id(map_id)
	var map_details = dock._source_entry_details_text(map_entry)
	_assert_true(map_details.contains("Any: 2"), "source registry details show primary Any count")
	_assert_true(map_details.contains("Floor: 1"), "source registry details show primary Floor count")
	_assert_true(map_details.contains("Wall: 1"), "source registry details show primary Wall count")

	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Rock")
	_assert_eq(dock._overlay_mask_query_rows.size(), 1, "query row references loaded source")
	dock.clear_mapdata_source(source_id)
	_assert_eq(dock._mapdata_sources.size(), 1, "clear removes only selected source")
	_assert_eq(dock._overlay_mask_query_rows.size(), 0, "clear removes query rows using source")
	_assert_true(dock._source_registry_status_label.text.contains("Sources: 1"), "source registry status shows remaining source count")
	dock.clear_mapdata_source(map_id)
	_assert_eq(dock._mapdata_sources.size(), 0, "clear removes all sources")
	_assert_eq(dock._source_registry_status_label.text, "No mapdata sources loaded.", "source registry status shows empty state")

	dock.queue_free()
	await process_frame


func _test_generation_dock_path_action_labels_and_failure_status() -> void:
	var dock = await _new_ready_dock()
	_assert_eq(dock._source_load_button.text, "Browse .tres", "source registry uses browse wording")
	_assert_eq(dock._generate_history_dir_button.text, "History Dir", "generate history uses directory wording")
	_assert_eq(dock._save_button.text, "Save As .tres", "generation save uses save-as wording")
	_assert_eq(dock._atlas_image_button.text, "Browse Atlas Image", "atlas image uses browse wording")

	dock._on_source_file_selected(_test_resource_path("missing_source_registry_resource.tres"))
	_assert_true(
		dock._source_registry_status_label.text.contains("Failed to load mapdata source"),
		"source registry file selection failure appears in status"
	)
	dock._generate_history_check.set_pressed_no_signal(true)
	dock._generate_history_dir = ""
	dock._refresh_generate_history_label()
	_assert_eq(dock._generate_history_dir_label.text, "History: choose directory", "history enabled without dir asks for directory")

	dock.queue_free()
	await process_frame


func _test_generation_dock_mapdata_query_rows_evaluate_offset_and_toric() -> void:
	var dock = await _new_ready_dock()
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(3)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._refresh_controls()
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		HexMapData.rectangle(3, 1).cells,
		"zero Mask Query Rows pass the full shape universe"
	)
	var map_data = HexMapData.rectangle(3, 1)
	map_data.set_walls([HexVector.q_axis()])
	var map_id = dock.register_mapdata_source(HexMapResource.from_map_data(map_data), "res://map_query.tres")
	_assert_eq(dock._overlay_mask_add_source_option.get_item_text(0), "map_query.tres", "query add source option is scoped to resource name")
	_assert_eq(dock._overlay_mask_add_source_option.get_popup().max_size.y, 260, "query add source option popup is height-limited for scrolling")

	var floor_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, map_id, "Floor")
	_assert_true(floor_row["row"] is VBoxContainer, "query row uses two-line container")
	_assert_eq(floor_row["source_label"].text, "map_query.tres", "query row shows resource name as a label")
	_assert_eq(floor_row["source_item"].get_item_text(floor_row["source_item"].selected), "Floor", "query row item combo is scoped to item key")
	_assert_eq(floor_row["source_item"].item_count, 3, "query row item combo lists only selected resource items")
	_assert_eq(floor_row["source_item"].get_popup().max_size.y, 260, "query row item combo popup is height-limited for scrolling")
	_assert_true(floor_row["offset_panel"] is HexCellButtonPanel, "query row has common hex cell offset panel")
	_assert_eq(floor_row["offset_panel"].get_entries().size(), 7, "query row offset panel lays out center and six direction cells")
	_assert_eq(_pressable_entry_count(floor_row["offset_panel"].get_entries()), 6, "query row offset panel exposes six pressable directions")
	var center_entry: Dictionary = _entries_by_id(floor_row["offset_panel"].get_entries())[HexVector.zero().key()]
	_send_panel_motion(floor_row["offset_panel"], center_entry["center"])
	_assert_true(floor_row["offset_panel"].tooltip_text.contains("Current offset"), "query row center cell shows current offset tooltip")
	var wall_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, map_id, "Wall")
	wall_row["operation"].select(1)
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		map_data.cells,
		"query rows OR selected item cells"
	)

	wall_row["operation"].select(0)
	wall_row["match"].select(1)
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		map_data.floor_cells(),
		"query rows apply Exclude as universe complement with AND"
	)

	dock._overlay_mask_query_rows.clear()
	dock._rect_width_spin.set_value_no_signal(1)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._refresh_controls()
	var outside_overlay = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{"Outside": [HexVector.q_axis()], "Inside": [HexVector.zero()]}
	)
	var outside_id = dock.register_mapdata_source(HexOverlayResource.from_overlay_data(outside_overlay), "res://outside_query.tres")
	var outside_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, outside_id, "Outside")
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		[],
		"mask query Crop Off clips Contain cells to current shape universe"
	)
	outside_row["match"].select(1)
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		[HexVector.zero()],
		"mask query Crop Off uses current shape universe for Exclude complement"
	)

	dock._overlay_mask_query_rows.clear()
	var shifted_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, outside_id, "Inside")
	_press_query_row_direction(shifted_row, 0)
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		[],
		"mask query Crop Off clips offset results outside current shape universe"
	)
	dock._current_data = HexMapData.rectangle(2, 1)
	var snapshot = dock._create_generation_snapshot()
	_assert_keys_eq(
		snapshot["overlay_candidate_cells"],
		[],
		"empty Mask query does not fallback to current Primary floor cells"
	)
	_assert_true(dock._generate_button.disabled, "empty Mask query disables Generate")
	_assert_true(not await dock._generate_map(), "empty Mask query does not start generation")
	_assert_eq(
		dock.generation_status()["status"],
		HexMapGenDock.GENERATION_BLOCK_STATUS_PREFIX + HexMapGenDock.GENERATION_BLOCK_EMPTY_MASK,
		"empty Mask query block reason is visible"
	)
	_assert_eq(
		String(dock.generation_run_view_state()["block_reason"]),
		HexMapGenDock.GENERATION_BLOCK_EMPTY_MASK,
		"UI-03 blocked Generate state keeps block reason in ViewState"
	)

	var overlay = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{"Gem": [HexVector.zero()]}
	)
	var overlay_id = dock.register_mapdata_source(HexOverlayResource.from_overlay_data(overlay), "res://offset_query.tres")
	dock._overlay_reference_query_rows.clear()
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._refresh_controls()
	var offset_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_REFERENCE, overlay_id, "Gem")
	var offset_panel: HexCellButtonPanel = offset_row["offset_panel"]
	dock._on_query_cell_radius_changed(18.0)
	dock._on_query_cell_gap_changed(3.0)
	dock._on_query_cell_padding_changed(5.0)
	_assert_eq(offset_panel.cell_radius, 18.0, "query offset panel radius is adjustable")
	_assert_eq(offset_panel.cell_gap, 3.0, "query offset panel gap is adjustable")
	_assert_eq(offset_panel.padding, Vector2(5, 5), "query offset panel padding is adjustable")
	_assert_eq(dock._query_cell_radius_spin.value, 18.0, "query cell radius syncs shared control")
	_assert_eq(dock._query_cell_gap_spin.value, 3.0, "query cell gap syncs shared control")
	_assert_eq(dock._query_cell_padding_spin.value, 5.0, "query cell padding syncs shared control")
	var q_entry: Dictionary = _entries_by_id(offset_panel.get_entries())[HexVector.q_axis().key()]
	_send_panel_click(offset_panel, q_entry["center"])
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_REFERENCE),
		[HexVector.q_axis()],
		"query rows offset item cells"
	)
	dock._set_generation_controls_disabled(true)
	_assert_true(not offset_panel.enabled, "generation disable state disables query offset panel")
	dock._set_generation_controls_disabled(false)
	_assert_true(offset_panel.enabled, "generation enable state re-enables query offset panel")

	var toric_data = HexOverlayData.from_cells(
		HexMapData.square(3, true).cells,
		{"Wrap": [HexVector.apply_basis(2, 0, 0)]},
		3
	)
	var toric_id = dock.register_mapdata_source(HexOverlayResource.from_overlay_data(toric_data), "res://toric_query.tres")
	dock._overlay_reference_query_rows.clear()
	var toric_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_REFERENCE, toric_id, "Wrap")
	_press_query_row_direction(toric_row, 0)
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_REFERENCE),
		[HexVector.zero()],
		"query rows wrap offset cells for toric source"
	)
	dock._rect_width_spin.set_value_no_signal(5)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._refresh_controls()
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_REFERENCE),
		[HexVector.zero(), HexVector.apply_basis(3, 0, 0)],
		"toric source query expands all matching representatives inside the shape universe"
	)

	dock._overlay_mask_query_rows.clear()
	var toric_mask_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, toric_id, "Wrap")
	_press_query_row_direction(toric_mask_row, 0)
	var crop_data = dock._overlay_crop_result_data()
	_assert_keys_eq(
		crop_data.item_cells(dock._crop_result_item_key(toric_mask_row)),
		[HexVector.zero(), HexVector.apply_basis(3, 0, 0)],
		"Crop result stores all toric source representatives inside the shape universe"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_deductor_floor_source_query() -> void:
	var dock = await _new_ready_dock()
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._gen_radius_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._connect_method_option.select(_connect_method_index(HexMapGenerator.CONNECT_DENSE))
	dock._refresh_controls()
	_assert_true(dock._overlay_deductor_floor_container.visible, "deductor floor source is visible for Markov Mesh overlay")

	dock._overlay_adjacency_check.set_pressed_no_signal(true)
	dock._refresh_controls()
	_assert_true(not dock._overlay_deductor_floor_container.visible, "deductor floor source hides for adjacency overlay")
	dock._overlay_adjacency_check.set_pressed_no_signal(false)
	dock._refresh_controls()

	var candidate_source = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{"Candidate": [HexVector.q_axis()]}
	)
	var candidate_id = dock.register_mapdata_source(
		HexOverlayResource.from_overlay_data(candidate_source),
		"res://deductor_candidate.tres"
	)
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, candidate_id, "Candidate")

	var default_snapshot = dock._create_generation_snapshot()
	_assert_keys_eq(
		default_snapshot["overlay_candidate_cells"],
		[HexVector.q_axis()],
		"deductor floor test uses placement mask candidate"
	)
	_assert_keys_eq(
		default_snapshot["overlay_deductor_floor_cells"],
		[],
		"deductor floor default is resolved after generation"
	)
	_assert_eq(
		default_snapshot["overlay_deductor_floor_source_enabled"],
		false,
		"deductor floor snapshot records missing source rows"
	)
	_assert_eq(
		dock._overlay_deductor_floor_status_label.text,
		"Default: generated complement",
		"deductor floor default status describes generated complement"
	)
	var default_generated = dock._generate_overlay_data_from_snapshot(default_snapshot, {})
	_assert_true(
		default_generated.has_item(HexVector.q_axis(), "Item1"),
		"deductor floor default uses generated complement instead of placement candidates"
	)

	var floor_source = HexMapData.rectangle(1, 1)
	var floor_id = dock.register_mapdata_source(
		HexMapResource.from_map_data(floor_source),
		"res://deductor_floor.tres"
	)
	dock._overlay_mask_crop_check.set_pressed_no_signal(true)
	var floor_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_DEDUCTOR_FLOOR, floor_id, "Floor")
	_assert_true(dock._overlay_mask_crop_check.button_pressed, "deductor floor query edit does not turn Crop off")
	var custom_snapshot = dock._create_generation_snapshot()
	_assert_keys_eq(
		custom_snapshot["overlay_candidate_cells"],
		[HexVector.q_axis()],
		"deductor floor source keeps placement mask candidates separate"
	)
	_assert_keys_eq(
		custom_snapshot["overlay_deductor_floor_cells"],
		[HexVector.zero()],
		"deductor floor source overrides connectivity floor cells"
	)
	_assert_true(
		dock._overlay_deductor_floor_status_label.text.contains("Deductor floor cells: 1"),
		"deductor floor source shows resolved cell count"
	)

	var generated = dock._generate_overlay_data_from_snapshot(custom_snapshot, {})
	_assert_true(
		generated.has_item(HexVector.q_axis(), "Item1"),
		"deductor floor source can differ from candidates during generation"
	)

	dock._on_query_row_remove_pressed(floor_row, HexMapGenDock.QUERY_KIND_DEDUCTOR_FLOOR)
	dock._gen_radius_spin.set_value_no_signal(0)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(1)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._refresh_controls()
	var empty_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_DEDUCTOR_FLOOR, floor_id, "Any")
	empty_row["match"].select(1)
	var empty_snapshot = dock._create_generation_snapshot()
	_assert_keys_eq(
		empty_snapshot["overlay_deductor_floor_cells"],
		[],
		"empty deductor floor query stays empty"
	)
	_assert_eq(
		dock._overlay_deductor_floor_status_label.text,
		"Deductor Floor Source query result is empty.",
		"empty deductor floor query shows status warning"
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
	var contain_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Tree")
	var exclude_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Rock")
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

	var crop_item_key = dock._crop_result_item_key(contain_row)
	var crop_layer = FakeTileLayer.new()
	_assert_true(dock._apply_crop_result_to_tile_map_layer(crop_layer), "crop result applies with Clear And Write")
	_assert_true(crop_layer.cleared, "crop result Clear And Write clears target layer")
	_assert_keys_eq(dock._current_overlay_data.item_cells(crop_item_key), [HexVector.zero()], "crop result Clear And Write replaces current overlay")

	dock._current_overlay_data = HexOverlayData.from_cells([HexVector.zero()], {"Old": [HexVector.zero()]})
	dock._apply_write_policy_option.select(1)
	var crop_add_layer = FakeTileLayer.new()
	_assert_true(dock._apply_crop_result_to_tile_map_layer(crop_add_layer), "crop result applies with Add Item")
	_assert_true(not crop_add_layer.cleared, "crop result Add Item preserves target layer cells")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "Old"), "crop result Add Item preserves current overlay item")
	_assert_keys_eq(dock._current_overlay_data.item_cells(crop_item_key), [HexVector.zero()], "crop result Add Item merges crop item")

	_press_query_row_direction(dock._overlay_mask_query_rows[0], 0)
	_assert_true(not dock._overlay_mask_crop_check.button_pressed, "mask query edit turns Crop off")
	dock._overlay_mask_crop_check.set_pressed_no_signal(true)
	dock._on_shape_size_changed(2)
	_assert_true(not dock._overlay_mask_crop_check.button_pressed, "shape size edit turns Crop off")
	dock._overlay_mask_crop_check.set_pressed_no_signal(true)
	dock._add_query_row(HexMapGenDock.QUERY_KIND_REFERENCE, source_id, "Tree")
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
	dock._current_overlay_data = HexOverlayData.from_cells([HexVector.zero()], {"Old": [HexVector.zero()]})

	_assert_true(dock._apply_overlay_source_stack_to_current(), "crop off stack applies overlay sources")
	_assert_true(dock._source_registry_status_label.text.contains("Stacked 2 overlay source(s)"), "crop off stack status shows source count")
	_assert_true(dock._source_registry_status_label.text.contains("occupied=2"), "crop off stack status shows occupied count")
	_assert_true(dock._source_registry_status_label.text.contains(HexOverlayData.APPLY_CLEAR_AND_WRITE), "crop off stack status shows Clear And Write policy")
	_assert_eq(dock._current_overlay_data.item_cells("Tree").size(), 0, "replace existing removes earlier item on same cell")
	_assert_eq(dock._current_overlay_data.item_cells("Old").size(), 0, "Clear And Write policy replaces existing current overlay")
	_assert_keys_eq(dock._current_overlay_data.item_cells("Rock"), [HexVector.zero()], "stack keeps later replacement item")
	_assert_keys_eq(dock._current_overlay_data.item_cells("Gem"), [HexVector.q_axis()], "stack preserves non-conflicting later item")
	_assert_eq(dock._current_overlay_data.item_cells("Floor").size(), 0, "stack ignores Primary source")

	dock._current_overlay_data = HexOverlayData.from_cells([HexVector.zero()], {"Old": [HexVector.zero()]})
	dock._apply_write_policy_option.select(1)
	dock._overlay_existing_policy_option.select(0)
	_assert_true(dock._apply_overlay_source_stack_to_current(), "Add Item write policy merges stack into current overlay")
	_assert_true(dock._source_registry_status_label.text.contains(HexOverlayData.APPLY_ADD_ITEM), "crop off stack status shows Add Item policy")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "Old"), "Add Item write policy preserves existing current item")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "Tree"), "Add Item write policy adds stacked source item")

	var empty_dock = await _new_ready_dock()
	empty_dock._overlay_mode_check.set_pressed_no_signal(true)
	_assert_true(not empty_dock._apply_overlay_source_stack_to_current(), "empty overlay source stack does not update current overlay")
	_assert_eq(
		empty_dock._source_registry_status_label.text,
		"No HexOverlayData source found in Source Registry.",
		"empty overlay source stack shows status reason"
	)

	empty_dock.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_generate_history_saves_overlay_delta_source() -> void:
	var dock = await _new_ready_dock()
	var history_dir = _test_resource_dir("mapdata_history")
	dock._set_generate_history_directory_for_test(history_dir)
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._overlay_item_limit_check.set_pressed_no_signal(true)
	dock._overlay_item_pool_rows[0]["name"].text = "Key"
	dock._overlay_item_pool_rows[0]["amount"].value = 1.0
	dock._apply_write_policy_option.select(1)
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
	_assert_true(String(source["resource_path"]).contains("overlay-combination-key"), "generate history uses combination in limited overlay filenames")
	_assert_eq(saved_data.item_cells("Old").size(), 0, "generate history stores overlay delta before Add Item policy")
	_assert_eq(saved_data.item_cells("Key").size(), 1, "generate history stores generated overlay delta item")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "Old"), "current overlay still applies Add Item policy")
	_assert_eq(dock._history_condition_name({"overlay_mode": true}), "overlay-uniform", "generate history keeps overlay uniform name")
	_assert_eq(dock._history_condition_name({"overlay_mode": true, "symmetric": true}), "overlay-markov", "generate history keeps overlay markov name")
	_assert_eq(dock._history_condition_name({"overlay_mode": true, "overlay_adjacency_enabled": true}), "overlay-adjacency", "generate history keeps overlay adjacency name")

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
