extends "res://tests/test_editor_plugin_test_base.gd"

const HexGenerationNodeTypes = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const HexGenerationParamSchema = preload("res://addons/hex_map_kit/generation/hex_generation_param_schema.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await _test_build_screen_opens_on_graph_canvas()
	await _test_consolidated_editor_connections_and_result_rows()
	await _test_result_overlay_row_reorder_updates_run_order()
	await _test_canvas_rejects_cycles()
	await _test_adaptation_dropdown_persists_and_changes_run_output()
	await _test_selection_adaptation_display_is_passthrough()
	await _test_consolidated_titlebar_criteria_chip_opens_editor()
	await _test_canvas_uses_untyped_ports_and_legacy_rejection()
	await _test_canvas_builds_model_and_runs_three_node_preview()
	await _test_run_state_caches_and_marks_dirty_downstream()
	await _test_edge_selection_and_delete_updates_graph_state()
	await _test_run_state_reports_failure_node()
	await _test_build_screen_generate_is_primary_and_batch_secondary()
	await _test_build_screen_generate_opens_popup_progress()
	await _test_build_screen_cancel_passes_interrupt_options()
	await _test_palette_and_inspector_reflect_graph_contract()
	await _test_workspace_mounts_build_screen_with_generate_alias()
	await _test_markov_reference_panels_align_to_plus_q_generation()
	_finish("res://tests/test_build_graph_canvas.gd")


func _test_build_screen_opens_on_graph_canvas() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	var snapshot = screen.build_screen_snapshot()
	_assert_eq(String(snapshot["first_surface"]), "graph_canvas", "GRAPH-11 Build screen first surface is graph canvas")
	_assert_true(bool(snapshot["canvas_is_dominant"]), "GRAPH-11 graph canvas is the dominant work surface")
	_assert_true(not bool(snapshot["resource_row_primary"]), "GRAPH-11 resources are not the primary row")
	_assert_true(bool(snapshot["generate_button_present"]), "GRAPH-11 Build screen exposes Generate primary action")
	_assert_true(bool(snapshot["commit_actions_below_canvas"]), "REPAIR-10 Apply/Revert actions are below the graph canvas")
	_assert_true(int(snapshot["canvas_minimum_height"]) >= 420, "REPAIR-10 Build graph canvas has dominant minimum height")

	screen.queue_free()
	await process_frame


func _test_consolidated_editor_connections_and_result_rows() -> void:
	var canvas = HexMapBuildGraphCanvas.new()
	root.add_child(canvas)
	await process_frame

	var terrain = canvas.add_graph_node(HexGenerationNodeTypes.NODE_TERRAIN_GENERATION, Vector2.ZERO, "terrain")
	var terrain_extra = canvas.add_graph_node(HexGenerationNodeTypes.NODE_TERRAIN_GENERATION, Vector2(0, 180), "terrain_extra")
	var items = canvas.add_graph_node(HexGenerationNodeTypes.NODE_ITEM_GENERATION, Vector2(220, 0), "items")
	var union = canvas.add_graph_node(HexGenerationNodeTypes.NODE_SET_OPERATION, Vector2(440, 0), "union")
	var result = canvas.add_graph_node(HexGenerationNodeTypes.NODE_RESULT, Vector2(660, 0), "result")
	_assert_true(bool(canvas.request_connection(terrain, 0, items, canvas._slot_for_input_name(items, "domain"))["ok"]), "GQM-10 terrain_generation connects to item_generation.domain through canvas")
	_assert_true(bool(canvas.request_connection(items, 0, union, canvas._slot_for_input_name(union, "in_0"))["ok"]), "GQM-10 item_generation connects to set_operation.in_0 through canvas")
	_assert_true(canvas._slot_for_input_name(union, "in_1") >= 0, "GQM-10 set_operation grows a new empty input after connection")
	_assert_true(bool(canvas.request_connection(terrain, 0, union, canvas._slot_for_input_name(union, "in_1"))["ok"]), "GQM-10 terrain_generation connects to the next set_operation input")
	_assert_true(canvas._slot_for_input_name(union, "in_2") >= 0, "GQM-10 set_operation keeps one empty input row")
	_assert_true(bool(canvas.request_connection(terrain, 0, result, canvas._slot_for_input_name(result, "in_0"))["ok"]), "GQM-10 terrain_generation connects to result input")
	_assert_true(bool(canvas.request_connection(items, 0, result, canvas._slot_for_input_name(result, "in_1"))["ok"]), "GQM-10 item_generation connects to result input")
	_assert_true(bool(canvas.request_connection(union, 0, result, canvas._slot_for_input_name(result, "in_2"))["ok"]), "GQM-10 set_operation connects to result input")
	_assert_true(bool(canvas.request_connection(terrain_extra, 0, result, canvas._slot_for_input_name(result, "in_3"))["ok"]), "GQM-12 extra terrain connects to result input")
	_assert_true(canvas._slot_for_input_name(result, "in_4") >= 0, "GQM-10 result keeps one empty input row")

	var report = canvas.run_graph()
	_assert_true(bool(report["ok"]), "GQM-10 consolidated editor graph runs")
	var rows := _rows_by_input(canvas.canvas_snapshot()["result_rows"] as Array)
	_assert_eq(String((rows["in_0"] as Dictionary)["resolution"]), "substrate", "GQM-10 result row resolves terrain as substrate")
	_assert_eq(String((rows["in_1"] as Dictionary)["resolution"]), "overlay 0", "GQM-10 result row resolves item output as overlay 0")
	_assert_eq(String((rows["in_2"] as Dictionary)["resolution"]), "unused", "GQM-18 connected selection result row remains unused")
	_assert_eq(String((rows["in_3"] as Dictionary)["unused_reason"]), "extra_terrain", "GQM-12 extra terrain row records unused reason")
	_assert_true(String((rows["in_3"] as Dictionary)["tooltip"]).contains("first connected terrain"), "GQM-12 extra terrain tooltip explains substrate selection")
	_assert_eq(String((rows["in_4"] as Dictionary)["resolution"]), "未接続", "GQM-18 empty Result row has an unconnected label instead of unused")
	_assert_eq(String((rows["in_4"] as Dictionary)["unused_reason"]), "not_connected", "GQM-18 empty Result row is tracked separately from connected unused rows")

	canvas.queue_free()
	await process_frame


func _test_result_overlay_row_reorder_updates_run_order() -> void:
	var canvas = HexMapBuildGraphCanvas.new()
	root.add_child(canvas)
	await process_frame

	var terrain_params = HexGenerationParamSchema.default_params(HexGenerationNodeTypes.NODE_TERRAIN_GENERATION)
	terrain_params["base_mode"] = "shape"
	terrain_params["shape"] = "rectangle"
	terrain_params["width"] = 3
	terrain_params["height"] = 1
	terrain_params["wall_method"] = "none"
	var spawn_params = HexGenerationParamSchema.default_params(HexGenerationNodeTypes.NODE_ITEM_GENERATION)
	spawn_params["placement_method"] = "weighted"
	spawn_params["placement_probability"] = 1.0
	spawn_params["item_pool"] = [{"name": "spawn", "weight": 1.0}]
	var loot_params = HexGenerationParamSchema.default_params(HexGenerationNodeTypes.NODE_ITEM_GENERATION)
	loot_params["placement_method"] = "weighted"
	loot_params["placement_probability"] = 1.0
	loot_params["item_pool"] = [{"name": "loot", "weight": 1.0}]
	var terrain = canvas.add_graph_node(HexGenerationNodeTypes.NODE_TERRAIN_GENERATION, Vector2.ZERO, "terrain", terrain_params)
	var spawn = canvas.add_graph_node(HexGenerationNodeTypes.NODE_ITEM_GENERATION, Vector2(220, 0), "items_spawn", spawn_params)
	var loot = canvas.add_graph_node(HexGenerationNodeTypes.NODE_ITEM_GENERATION, Vector2(220, 140), "items_loot", loot_params)
	var result = canvas.add_graph_node(HexGenerationNodeTypes.NODE_RESULT, Vector2(520, 0), "result")
	_assert_true(bool(canvas.request_connection(terrain, 0, spawn, canvas._slot_for_input_name(spawn, "domain"))["ok"]), "GQM-12 setup terrain->spawn")
	_assert_true(bool(canvas.request_connection(terrain, 0, loot, canvas._slot_for_input_name(loot, "domain"))["ok"]), "GQM-12 setup terrain->loot")
	_assert_true(bool(canvas.request_connection(terrain, 0, result, canvas._slot_for_input_name(result, "in_0"))["ok"]), "GQM-12 setup terrain->result")
	_assert_true(bool(canvas.request_connection(spawn, 0, result, canvas._slot_for_input_name(result, "in_1"))["ok"]), "GQM-12 setup spawn overlay row")
	_assert_true(bool(canvas.request_connection(loot, 0, result, canvas._slot_for_input_name(result, "in_2"))["ok"]), "GQM-12 setup loot overlay row")

	var initial_report = canvas.run_graph()
	_assert_true(bool(initial_report["ok"]), "GQM-12 initial Result stack graph runs")
	var initial_result = (initial_report["cache"] as Dictionary)["result"]
	var initial_inputs = (initial_result.get("metadata") as Dictionary)["overlay_inputs"] as Array
	_assert_eq(String((initial_inputs[0] as Dictionary)["from_node"]), "items_spawn", "GQM-12 initial overlay 0 is the first connected overlay")
	_assert_true(canvas.move_result_overlay_row(result, "in_2", -1), "GQM-12 row move accepts moving second overlay up")
	var moved_graph = canvas.build_graph_model()
	var result_edges: Array = []
	for edge in moved_graph["edges"] as Array:
		var edge_dict := edge as Dictionary
		if String(edge_dict.get("to_node", "")) == result and String(edge_dict.get("from_node", "")).begins_with("items_"):
			result_edges.append(edge_dict)
	_assert_eq(String((result_edges[0] as Dictionary)["from_node"]), "items_loot", "GQM-12 graph edge order follows moved overlay row")
	var moved_report = canvas.run_graph()
	_assert_true(bool(moved_report["ok"]), "GQM-12 moved Result stack graph runs")
	var moved_result = (moved_report["cache"] as Dictionary)["result"]
	var moved_inputs = (moved_result.get("metadata") as Dictionary)["overlay_inputs"] as Array
	_assert_eq(String((moved_inputs[0] as Dictionary)["from_node"]), "items_loot", "GQM-12 run overlay order follows row move")
	var rows := _rows_by_input(canvas.canvas_snapshot()["result_rows"] as Array)
	_assert_eq(String((rows["in_1"] as Dictionary)["source_node"]), "items_loot", "GQM-12 visible row order follows moved overlay")
	_assert_true(bool((rows["in_1"] as Dictionary)["can_move_down"]), "GQM-12 moved overlay row exposes reverse move action")

	canvas.queue_free()
	await process_frame


func _test_canvas_rejects_cycles() -> void:
	var canvas = HexMapBuildGraphCanvas.new()
	root.add_child(canvas)
	await process_frame

	var terrain = canvas.add_graph_node(HexGenerationNodeTypes.NODE_TERRAIN_GENERATION, Vector2.ZERO, "terrain")
	var items = canvas.add_graph_node(HexGenerationNodeTypes.NODE_ITEM_GENERATION, Vector2(220, 0), "items")
	var union = canvas.add_graph_node(HexGenerationNodeTypes.NODE_SET_OPERATION, Vector2(440, 0), "union")
	_assert_true(bool(canvas.request_connection(terrain, 0, items, canvas._slot_for_input_name(items, "domain"))["ok"]), "GQM-10 setup terrain->items")
	_assert_true(bool(canvas.request_connection(items, 0, union, canvas._slot_for_input_name(union, "in_0"))["ok"]), "GQM-10 setup items->set")
	var rejected = canvas.request_connection(union, 0, terrain, canvas._slot_for_input_name(terrain, "terminals"))
	_assert_true(not bool(rejected["ok"]), "GQM-10 canvas rejects a cycle-forming connection")
	_assert_true(String(rejected["reason"]).contains("cycle"), "GQM-10 cycle rejection explains the reason")
	_assert_eq(int(canvas.canvas_snapshot()["connection_count"]), 2, "GQM-10 rejected cycle connection is not kept")

	canvas.queue_free()
	await process_frame


func _test_adaptation_dropdown_persists_and_changes_run_output() -> void:
	var canvas = HexMapBuildGraphCanvas.new()
	root.add_child(canvas)
	await process_frame

	var terrain_params = HexGenerationParamSchema.default_params(HexGenerationNodeTypes.NODE_TERRAIN_GENERATION)
	terrain_params["base_mode"] = "shape"
	terrain_params["shape"] = "rectangle"
	terrain_params["width"] = 2
	terrain_params["height"] = 1
	terrain_params["wall_method"] = "random_probability"
	terrain_params["wall_probability"] = 1.0
	terrain_params["wall_seed"] = 5
	var item_params = HexGenerationParamSchema.default_params(HexGenerationNodeTypes.NODE_ITEM_GENERATION)
	item_params["placement_method"] = "weighted"
	item_params["placement_probability"] = 1.0
	item_params["item_pool"] = [{"name": "spawn", "weight": 1.0}]
	var terrain = canvas.add_graph_node(HexGenerationNodeTypes.NODE_TERRAIN_GENERATION, Vector2.ZERO, "terrain", terrain_params)
	var items = canvas.add_graph_node(HexGenerationNodeTypes.NODE_ITEM_GENERATION, Vector2(220, 0), "items", item_params)
	var result = canvas.add_graph_node(HexGenerationNodeTypes.NODE_RESULT, Vector2(440, 0), "result")

	var connected = canvas.request_connection(terrain, 0, items, canvas._slot_for_input_name(items, "domain"))
	_assert_true(bool(connected["ok"]), "GQM-10 terrain->item_generation.domain connects")
	_assert_eq(String(canvas.connection_adaptation(items, "domain")), "floor", "GQM-10 terrain producer defaults domain adaptation to floor")
	_assert_true(bool(canvas.request_connection(items, 0, result, canvas._slot_for_input_name(result, "in_0"))["ok"]), "GQM-10 item output connects to result")

	var floor_report = canvas.run_graph()
	_assert_true(bool(floor_report["ok"]), "GQM-10 floor-adapted graph runs")
	var floor_overlay = (floor_report["cache"] as Dictionary)["items"] as HexOverlayData
	_assert_eq(floor_overlay.item_cells("spawn").size(), 0, "GQM-10 floor adaptation sees no cells when all terrain cells are walls")

	var option = (canvas._graph_node(items) as GraphNode).find_child("Adaptation items domain", true, false) as OptionButton
	_assert_true(option is OptionButton, "GQM-10 adaptation OptionButton is embedded in the input row")
	var wall_index := _option_index_by_metadata(option, "wall")
	_assert_true(wall_index >= 0, "GQM-10 adaptation dropdown contains wall")
	option.select(wall_index)
	option.emit_signal("item_selected", wall_index)
	await process_frame

	var graph = canvas.build_graph_model()
	var domain_edge := _edge_to(graph, "items", "domain")
	_assert_eq(String(domain_edge.get("adaptation", "")), "wall", "GQM-10 dropdown change persists adaptation on the graph edge")
	var wall_report = canvas.run_graph()
	_assert_true(bool(wall_report["ok"]), "GQM-10 wall-adapted graph runs")
	var wall_overlay = (wall_report["cache"] as Dictionary)["items"] as HexOverlayData
	_assert_eq(wall_overlay.item_cells("spawn").size(), 2, "GQM-10 wall adaptation changes the placement target for the next run")

	canvas.queue_free()
	await process_frame


func _test_selection_adaptation_display_is_passthrough() -> void:
	var canvas = HexMapBuildGraphCanvas.new()
	root.add_child(canvas)
	await process_frame

	var terrain = canvas.add_graph_node(HexGenerationNodeTypes.NODE_TERRAIN_GENERATION, Vector2.ZERO, "terrain")
	var selector = canvas.add_graph_node(HexGenerationNodeTypes.NODE_SET_OPERATION, Vector2(220, 0), "selector")
	var consumer = canvas.add_graph_node(HexGenerationNodeTypes.NODE_SET_OPERATION, Vector2(440, 0), "consumer")
	_assert_true(bool(canvas.request_connection(terrain, 0, selector, canvas._slot_for_input_name(selector, "in_0"))["ok"]), "GQM-11 setup terrain to selection producer")
	_assert_true(bool(canvas.request_connection(selector, 0, consumer, canvas._slot_for_input_name(consumer, "in_0"))["ok"]), "GQM-11 selection producer connects to selection consumer")

	var rows := _rows_by_node_input(canvas.canvas_snapshot()["adaptation_rows"] as Array)
	var row = rows["consumer:in_0"] as Dictionary
	_assert_eq(String(row.get("adaptation", "")), "", "GQM-11 selection passthrough adaptation is stored as empty")
	_assert_eq(String(row.get("display", "")), "そのまま (selection)", "GQM-11 selection passthrough is displayed clearly")
	var option = (canvas._graph_node(consumer) as GraphNode).find_child("Adaptation consumer in_0", true, false) as OptionButton
	_assert_true(option is OptionButton, "GQM-18 connected selection passthrough keeps an adaptation control")
	_assert_eq(option.get_item_text(0), "そのまま (selection)", "GQM-11 dropdown first item names passthrough selection instead of none")
	var empty_row = rows["consumer:in_1"] as Dictionary
	_assert_true(not bool(empty_row.get("connected", true)), "GQM-18 dynamic empty input row is recorded as unconnected")
	_assert_eq(String(empty_row.get("display", "")), "未接続", "GQM-18 unconnected input row uses a distinct unconnected label")
	_assert_true(not bool(empty_row.get("control_present", true)), "GQM-18 unconnected input row hides the adaptation dropdown")
	var empty_option = (canvas._graph_node(consumer) as GraphNode).find_child("Adaptation consumer in_1", true, false) as OptionButton
	_assert_true(empty_option == null, "GQM-18 unconnected input row does not mount an adaptation OptionButton")

	canvas.queue_free()
	await process_frame


func _test_consolidated_titlebar_criteria_chip_opens_editor() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	var params := HexGenerationParamSchema.default_params(HexGenerationNodeTypes.NODE_TERRAIN_GENERATION)
	params["wall_method"] = "markov_mesh"
	params["distribution_mode"] = "preset"
	params["distribution_id"] = 20
	var terrain = screen.graph_canvas().add_graph_node(HexGenerationNodeTypes.NODE_TERRAIN_GENERATION, Vector2.ZERO, "terrain", params)
	screen.graph_canvas().select_graph_node(terrain)
	await process_frame

	var titlebars := screen.graph_canvas().canvas_snapshot()["node_titlebars"] as Dictionary
	_assert_true(float((titlebars["terrain"] as Dictionary)["display_name_field_min_width"]) >= 220.0, "GQM-18 titlebar node name field reserves enough width")
	_assert_true(bool((titlebars["terrain"] as Dictionary)["display_name_field_expands"]), "GQM-18 titlebar node name field expands within the titlebar")
	var chips := ((titlebars["terrain"] as Dictionary)["criteria_chips"] as Array)
	_assert_true(_chip_labels(chips).has("dist: Maze"), "GQM-11 canvas titlebar chip displays the applied distribution source")
	var chip_button := (screen.graph_canvas()._graph_node("terrain") as GraphNode).find_child("HexTitlebarCriteriaChip_terrain_distribution", true, false) as MenuButton
	_assert_true(chip_button is MenuButton, "GQM-18 canvas titlebar mounts a criteria chip menu")
	var popup := chip_button.get_popup()
	popup.id_pressed.emit(_popup_item_id_by_text(popup, "Open editor..."))
	await process_frame
	_assert_true(screen.node_inspector().find_child("Markov Distribution Window", true, false) is AcceptDialog, "GQM-18 titlebar distribution chip menu opens the Markov distribution editor")

	screen.queue_free()
	await process_frame


func _test_canvas_uses_untyped_ports_and_legacy_rejection() -> void:
	var canvas = HexMapBuildGraphCanvas.new()
	root.add_child(canvas)
	await process_frame

	var terrain = canvas.add_graph_node(HexGenerationNodeTypes.NODE_TERRAIN_GENERATION, Vector2.ZERO, "terrain")
	var items = canvas.add_graph_node(HexGenerationNodeTypes.NODE_ITEM_GENERATION, Vector2(220, 0), "items")
	var shape = canvas.add_graph_node(HexGenerationNodeTypes.NODE_SHAPE, Vector2(440, 0), "shape")
	var legacy_items = canvas.add_graph_node(HexGenerationNodeTypes.NODE_ITEM_GENERATOR, Vector2(660, 0), "legacy_items")
	_assert_true(bool(canvas.request_connection(terrain, 0, items, canvas._slot_for_input_name(items, "domain"))["ok"]), "GQM-10 consolidated target accepts untyped terrain output")
	var rejected = canvas.request_connection(shape, 0, legacy_items, canvas._slot_for_input_name(legacy_items, "scope"))
	_assert_true(not bool(rejected["ok"]), "GQM-10 legacy incompatible shape->item_generator.scope remains rejected")
	_assert_true(String(rejected["reason"]).contains("Cannot connect"), "GQM-10 legacy rejection still uses logical port compatibility")

	var terrain_node = canvas._graph_node(terrain) as GraphNode
	var items_node = canvas._graph_node(items) as GraphNode
	var shape_node = canvas._graph_node(shape) as GraphNode
	var legacy_node = canvas._graph_node(legacy_items) as GraphNode
	_assert_eq(terrain_node.get_output_port_type(0), 0, "GQM-10 consolidated output port type is untyped")
	_assert_eq(items_node.get_input_port_type(0), 0, "GQM-10 consolidated input port type is untyped")
	_assert_eq(shape_node.get_output_port_type(0), 0, "GQM-10 legacy output port type is also untyped")
	_assert_eq(legacy_node.get_input_port_type(0), 0, "GQM-10 legacy input port type is also untyped")
	var colors = canvas.canvas_snapshot()["port_type_colors"] as Dictionary
	_assert_eq(colors.keys().size(), 1, "GQM-10 canvas exposes a single untyped port color")

	canvas.queue_free()
	await process_frame


func _test_canvas_builds_model_and_runs_three_node_preview() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	var report = screen.build_default_three_node_chain_and_preview()
	var canvas_snapshot = screen.graph_canvas().canvas_snapshot()
	var screen_snapshot = screen.build_screen_snapshot()
	_assert_true(bool(report["ok"]), "GRAPH-11 Build screen runs Shape->Wall->Connectivity")
	_assert_eq(int(canvas_snapshot["node_count"]), 3, "GRAPH-11 three graph nodes are present")
	_assert_eq(int(canvas_snapshot["connection_count"]), 2, "GRAPH-11 two graph edges are present")
	_assert_true(bool(screen_snapshot["preview_available"]), "GRAPH-11 selected node output preview is available")
	_assert_eq(String((screen_snapshot["preview"] as Dictionary)["source_kind"]), HexMapPreviewThumbnail.SOURCE_MAP_DATA, "GRAPH-11 preview uses map data")
	_assert_true(bool(screen_snapshot["three_node_chain_ready"]), "GRAPH-11 screen snapshot marks the three-node chain ready")
	_assert_true(bool(screen_snapshot["graph_chain_runs"]), "GRAPH-11 screen snapshot records the chain run")

	screen.queue_free()
	await process_frame


func _test_run_state_caches_and_marks_dirty_downstream() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	var report = screen.build_default_three_node_chain_and_preview()
	_assert_true(bool(report["ok"]), "GRAPH-13 initial run succeeds")
	var run_state = screen.graph_canvas().run_state_snapshot()
	_assert_true(bool(run_state["cache_ready"]), "GRAPH-13 run state marks cache ready after successful run")
	_assert_eq(int(run_state["cache_node_count"]), 3, "GRAPH-13 cache records three node outputs")
	_assert_eq((run_state["recomputed_node_ids"] as PackedStringArray).size(), 3, "GRAPH-13 initial Build run computes graph nodes")
	_assert_eq((run_state["dirty_node_ids"] as PackedStringArray).size(), 0, "GRAPH-13 successful run clears dirty nodes")

	screen.graph_canvas().set_node_params("walls", {
		"wall_probability": 0.4,
		"seed": 17,
	})
	run_state = screen.graph_canvas().run_state_snapshot()
	var dirty_ids = run_state["dirty_node_ids"] as PackedStringArray
	_assert_true(bool(run_state["cache_dirty"]), "GRAPH-13 param edit marks cache dirty")
	_assert_true(dirty_ids.has("walls"), "GRAPH-13 edited node is dirty")
	_assert_true(dirty_ids.has("connectivity"), "GRAPH-13 downstream node is dirty")
	_assert_true(not bool(run_state["cache_ready"]), "GRAPH-13 stale cache is not reported as ready")

	screen.run_graph()
	run_state = screen.graph_canvas().run_state_snapshot()
	_assert_true(bool(run_state["cache_ready"]), "GRAPH-13 rerun restores cache-ready state")
	_assert_true((run_state["reused_node_ids"] as PackedStringArray).has("shape"), "GRAPH-13 rerun reuses clean upstream cache")
	_assert_true((run_state["recomputed_node_ids"] as PackedStringArray).has("walls"), "GRAPH-13 rerun recomputes dirty node")
	_assert_eq((run_state["dirty_node_ids"] as PackedStringArray).size(), 0, "GRAPH-13 rerun clears dirty state")

	screen.queue_free()
	await process_frame


func _test_edge_selection_and_delete_updates_graph_state() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	var report = screen.build_default_three_node_chain_and_preview()
	_assert_true(bool(report["ok"]), "REPAIR-14 three-node chain runs before edge delete")
	var canvas = screen.graph_canvas()
	_assert_eq(int(canvas.canvas_snapshot()["connection_count"]), 2, "REPAIR-14 chain has two edges before delete")

	var selected := canvas.select_edge("shape", 0, "walls", 0)
	_assert_true(not selected.is_empty(), "REPAIR-14 edge between shape and walls can be selected")
	var selected_snapshot = canvas.canvas_snapshot()
	_assert_true(bool(selected_snapshot["selected_edge_present"]), "REPAIR-14 snapshot records the selected edge")
	_assert_eq(String(selected_snapshot["selected_node_id"]), "", "REPAIR-14 edge selection clears node selection")

	var delete_edge_button = screen.find_child("Build Delete Edge Button", true, false) as Button
	_assert_true(delete_edge_button is Button, "REPAIR-14 Build screen mounts a Delete Edge button")
	_assert_true(not delete_edge_button.disabled, "REPAIR-14 Delete Edge button enables while an edge is selected")

	var deleted := canvas.delete_selected_edge()
	_assert_true(deleted, "REPAIR-14 selected edge can be deleted")
	var after_snapshot = canvas.canvas_snapshot()
	_assert_eq(int(after_snapshot["connection_count"]), 1, "REPAIR-14 edge delete removes only the selected edge")
	_assert_eq(int(after_snapshot["node_count"]), 3, "REPAIR-14 edge delete keeps all nodes")
	_assert_true(not bool(after_snapshot["selected_edge_present"]), "REPAIR-14 edge selection clears after delete")

	var run_state = after_snapshot["run_state"] as Dictionary
	var dirty_ids = run_state["dirty_node_ids"] as PackedStringArray
	_assert_true(dirty_ids.has("walls"), "REPAIR-14 edge delete marks the edge target dirty")
	_assert_true(dirty_ids.has("connectivity"), "REPAIR-14 edge delete marks downstream nodes dirty")

	screen._on_canvas_graph_changed()
	_assert_true(delete_edge_button.disabled, "REPAIR-14 Delete Edge button disables when no edge is selected")

	screen.queue_free()
	await process_frame


func _test_run_state_reports_failure_node() -> void:
	await _test_run_state_reports_failure_node_impl()


func _test_run_state_reports_failure_node_impl() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	var items = screen.graph_canvas().add_graph_node(HexGenerationNodeTypes.NODE_ITEM_GENERATOR, Vector2.ZERO, "items")
	screen.graph_canvas().select_graph_node(items)
	var report = screen.run_graph()
	_assert_true(not bool(report["ok"]), "GRAPH-13 invalid graph reports failed run")
	var snapshot = screen.build_screen_snapshot()
	_assert_eq(String(snapshot["failure_node_id"]), "items", "GRAPH-13 Build snapshot names failing node")
	_assert_true(bool((snapshot["run_state"] as Dictionary)["failure_node_highlighted"]), "GRAPH-13 failing node is highlighted")
	_assert_true(String(snapshot["status_text"]).contains("items"), "GRAPH-13 status text names failing node")

	screen.queue_free()
	await process_frame


func _test_build_screen_generate_is_primary_and_batch_secondary() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	var snapshot = screen.build_screen_snapshot()
	_assert_eq(String(snapshot["primary_action"]), "Generate", "GRAPH-13 primary action remains Generate")
	_assert_true(bool(snapshot["cancel_button_present"]), "GRAPH-13 cancel control is present for busy runs")
	_assert_true(not bool(snapshot["cancel_available"]), "GRAPH-13 cancel is unavailable while idle")
	_assert_eq(int(snapshot["primary_generate_count"]), 1, "GRAPH-13 primary Generate means N=1")
	_assert_eq(int(snapshot["generate_default_count"]), 1, "GRAPH-13 default run count is one")
	_assert_true(bool(snapshot["batch_controls_secondary"]), "GRAPH-13 N/randomize controls are secondary")
	_assert_true(bool(snapshot["commit_actions_below_canvas"]), "REPAIR-10 batch and commit controls share the lower graph action row")
	_assert_eq(int(snapshot["batch_count"]), 1, "GRAPH-13 batch count defaults to one")
	_assert_true(not bool(snapshot["seed_randomize"]), "GRAPH-13 seed randomize defaults off")
	_assert_true(not bool(snapshot["shape_randomize"]), "GRAPH-13 shape randomize defaults off")

	screen.queue_free()
	await process_frame


func _test_build_screen_generate_opens_popup_progress() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame
	screen.graph_canvas().build_default_three_node_chain()

	var button = screen.find_child("Build Generate Button", true, false) as Button
	_assert_true(button is Button, "GRAPH-13 Build screen mounts primary Generate button")
	button.emit_signal("pressed")
	var snapshot = screen.build_screen_snapshot()
	_assert_true(bool(snapshot["run_busy"]), "GRAPH-13 Generate button starts an async graph run")
	_assert_true(bool(snapshot["run_progress_popup_present"]), "GRAPH-13 Generate progress is hosted in a popup")
	_assert_true(bool(snapshot["run_progress_popup_visible"]), "GRAPH-13 progress popup is visible immediately after Generate")
	_assert_eq(String(snapshot["cancel_button_location"]), "popup", "GRAPH-13 Cancel action is located in the progress popup")
	_assert_true(bool(snapshot["cancel_available"]), "GRAPH-13 popup Cancel is available while the run is busy")

	await _wait_for_build_screen_idle(screen)
	screen.queue_free()
	await process_frame


func _test_build_screen_cancel_passes_interrupt_options() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	screen.graph_canvas().build_default_three_node_chain()
	var recorder = GraphCancelRecorder.new()
	recorder.cancel_phase_prefix = "random_walls"
	var report = screen.run_graph({
		"interrupt_options": {
			"chunk_size": 1,
			"progress_callback": Callable(recorder, "progress"),
			"cancel_callback": Callable(recorder, "cancel"),
		},
	})
	var snapshot = screen.build_screen_snapshot()
	_assert_true(not bool(report["ok"]), "GRAPH-13 Build screen cancelled run is not ok")
	_assert_true(bool(report["cancelled"]), "GRAPH-13 Build screen reports cancellation")
	_assert_true(bool(snapshot["last_cancelled"]), "GRAPH-13 Build snapshot records cancellation")
	_assert_true(String(snapshot["status_text"]).contains("cancelled"), "GRAPH-13 Build status names cancellation")
	_assert_true(recorder.progress_events.size() > 0, "GRAPH-13 Build screen forwards run progress")

	screen.queue_free()
	await process_frame


func _wait_for_build_screen_idle(screen: HexMapBuildScreen) -> void:
	for _i in range(180):
		if not bool(screen.build_screen_snapshot()["run_busy"]):
			return
		await process_frame
	_assert_true(false, "Build screen async graph run finished within the test budget")


func _test_palette_and_inspector_reflect_graph_contract() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	var palette_snapshot = screen.node_palette().palette_snapshot()
	_assert_eq(String(palette_snapshot["layout"]), "bottom_grouped_row", "REPAIR-13A Add Node row is grouped below the graph")
	_assert_eq(int(palette_snapshot["button_count"]), 4, "GQM-10 Add Node row exposes only the consolidated four node types")
	_assert_true((palette_snapshot["group_ids"] as PackedStringArray).has("consolidated"), "GQM-10 Add Node row has consolidated group")
	var palette_types = palette_snapshot["node_types"] as PackedStringArray
	_assert_true(palette_types.has(HexGenerationNodeTypes.NODE_TERRAIN_GENERATION), "GQM-10 Add Node row has Terrain Generation")
	_assert_true(palette_types.has(HexGenerationNodeTypes.NODE_ITEM_GENERATION), "GQM-10 Add Node row has Item Generation")
	_assert_true(palette_types.has(HexGenerationNodeTypes.NODE_SET_OPERATION), "GQM-10 Add Node row has Set Operation")
	_assert_true(palette_types.has(HexGenerationNodeTypes.NODE_RESULT), "GQM-10 Add Node row has Result")
	_assert_true(not bool(palette_snapshot["compose_primary"]), "REPAIR-13A Compose is not in the primary Add Node row")

	screen.node_palette().request_node_type(HexGenerationNodeTypes.NODE_TERRAIN_GENERATION)
	await process_frame
	var palette_node_id := screen.graph_canvas().selected_node_id()
	var palette_params := screen.graph_canvas().node_params(palette_node_id)
	var schema_defaults := HexGenerationParamSchema.default_params(HexGenerationNodeTypes.NODE_TERRAIN_GENERATION)
	_assert_eq(String(screen.graph_canvas().selected_node_dictionary().get("type", "")), HexGenerationNodeTypes.NODE_TERRAIN_GENERATION, "GQM-10 Terrain Generation button creates a consolidated node")
	_assert_eq(String(palette_params.get("base_mode", "")), String(schema_defaults.get("base_mode", "")), "GQM-10 palette node uses schema default params")

	var canvas = screen.graph_canvas()
	var shape = canvas.add_graph_node(HexGenerationNodeTypes.NODE_SHAPE, Vector2.ZERO, "shape")
	canvas.select_graph_node(shape)
	await process_frame
	var inspector = screen.node_inspector().inspector_snapshot()
	_assert_true((inspector["param_fields"] as PackedStringArray).has("width"), "GRAPH-11 inspector reflects shape width param")
	_assert_true((inspector["param_fields"] as PackedStringArray).has("height"), "GRAPH-11 inspector reflects shape height param")
	_assert_true(bool(inspector["promote_button_present"]), "GRAPH-11 inspector reserves Promote action for GRAPH-12")
	_assert_true(not bool(inspector["promote_enabled"]), "GRAPH-11 Promote action stays disabled before GRAPH-12")
	screen.node_inspector().set_param("shape", "square")
	await process_frame
	var square_params = canvas.node_params(shape)
	_assert_eq(int(square_params.get("size", 0)), 3, "Shape inspector persists default square size when switching to Square")

	var source = canvas.add_graph_node(HexGenerationNodeTypes.NODE_SOURCE, Vector2(200, 0), "source")
	canvas.select_graph_node(source)
	await process_frame
	inspector = screen.node_inspector().inspector_snapshot()
	_assert_true(bool(inspector["resource_ref_binding_present"]), "GRAPH-11 inspector exposes Resource ref binding for Source")
	_assert_true((inspector["resource_ref_fields"] as PackedStringArray).has("document"), "GRAPH-11 Source inspector exposes document Resource ref")

	var wall = canvas.add_graph_node(HexGenerationNodeTypes.NODE_WALL_FIELD, Vector2(400, 0), "wall_for_distribution")
	canvas.set_node_params(wall, {"wall_method": "markov_mesh", "distribution_mode": "custom"})
	canvas.select_graph_node(wall)
	await process_frame
	inspector = screen.node_inspector().inspector_snapshot()
	_assert_true((inspector["param_fields"] as PackedStringArray).has("custom_distribution"), "REPAIR-18 Wall Field exposes custom distribution state")
	_assert_true((inspector["param_fields"] as PackedStringArray).has("distribution_mode"), "REPAIR-18 Wall Field exposes preset/custom distribution mode")
	_assert_true(screen.node_inspector().find_child("OpenMarkovDistributionEditor", true, false) is Button, "REPAIR-18 Wall Field shows Markov distribution editor button")

	var items = canvas.add_graph_node(HexGenerationNodeTypes.NODE_ITEM_GENERATOR, Vector2(600, 0), "items_for_rules")
	canvas.set_node_params(items, {"placement_method": "adjacency_rules"})
	canvas.select_graph_node(items)
	await process_frame
	_assert_true(screen.node_inspector().find_child("OpenAdjacencyRulesEditor", true, false) is Button, "REPAIR-17 Item Generator shows Adjacency Rules editor button")

	screen.queue_free()
	await process_frame


func _test_workspace_mounts_build_screen_with_generate_alias() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	_assert_true(workspace.build_screen() is HexMapBuildScreen, "GRAPH-11 workspace mounts Build screen")
	_assert_true(workspace.generation_dock() is HexMapGenDock, "GRAPH-11 workspace keeps legacy Generate dock API")
	_assert_true(workspace.tab_has_component("Build", "build_graph_screen"), "GRAPH-11 Build tab owns graph screen component")
	_assert_true(workspace.tab_has_component("Generate", "build_graph_screen"), "GRAPH-11 legacy Generate tab name resolves to Build")
	_assert_true(workspace.tab_has_component("Generate", "generation_panel"), "GRAPH-11 legacy generation component remains queryable")
	_assert_eq(workspace.workspace_tab_names()[0], "Build", "GRAPH-11 Build is the first workspace tab")
	var snapshot = workspace.generation_screen_snapshot()
	_assert_eq(String(snapshot["workflow_owner"]), "Build", "GRAPH-11 generation snapshot is now Build-owned")
	_assert_eq(String((snapshot["view_state"] as Dictionary)["state_source"]), "HexMapBuildScreen", "GRAPH-11 root view state comes from Build screen")

	workspace.queue_free()
	await process_frame


func _test_markov_reference_panels_align_to_plus_q_generation() -> void:
	var inspector := HexMapBuildNodeInspector.new()
	root.add_child(inspector)
	await process_frame

	var plus_q: String = HexVector.q_axis().key()
	var behind_q: String = HexVector.q_axis().negated().key()
	for reference_count in [1, 2, 3]:
		if reference_count == 1:
			continue # single reference is might not be single directional, so skip the test
		var dir_id: int = inspector._markov_reference_frame_direction_id(reference_count)
		var frame := HexMapGenerator.markov_distribution_reference_frame(dir_id, reference_count)
		var generation_direction = frame.get("generation_direction", null)
		_assert_true(generation_direction != null, "Markov panel count %d exposes a generation direction" % reference_count)
		_assert_eq(generation_direction.key(), plus_q, "Markov panel count %d generation arrow points at +q" % reference_count)
		var slots := inspector._markov_reference_visual_slots(reference_count)
		_assert_eq(slots.size(), reference_count, "Markov panel count %d shows exactly %d reference cells" % [reference_count, reference_count])
		_assert_eq(int((slots[0] as Dictionary).get("bit", -1)), 0, "Markov panel count %d keeps reference bit 0 first" % reference_count)
		_assert_eq(((slots[0] as Dictionary).get("cell", null)).key(), behind_q, "Markov panel count %d reference bit 0 sits directly behind +q" % reference_count)
		if reference_count == 2:
			var second_ref = (slots[1] as Dictionary).get("cell", null)
			_assert_eq(second_ref.key(), HexVector.r_axis().negated().key(), "Markov panel count 2 bit 1 uses the non-adjacent border-start reference")
			var ref_delta = ((slots[0] as Dictionary).get("cell", null)).subtract(second_ref)
			_assert_true(ref_delta.l1_norm() > 1, "Markov panel count 2 reference cells are not adjacent")

	inspector.queue_free()
	await process_frame


func _rows_by_input(rows: Array) -> Dictionary:
	var result := {}
	for row in rows:
		var row_dict := row as Dictionary
		result[String(row_dict.get("input", ""))] = row_dict
	return result


func _rows_by_node_input(rows: Array) -> Dictionary:
	var result := {}
	for row in rows:
		var row_dict := row as Dictionary
		result["%s:%s" % [String(row_dict.get("node_id", "")), String(row_dict.get("input", ""))]] = row_dict
	return result


func _chip_labels(chips: Array) -> Array:
	var result: Array = []
	for chip in chips:
		result.append(String((chip as Dictionary).get("label", "")))
	return result


func _option_index_by_metadata(option: OptionButton, metadata: String) -> int:
	for index in range(option.item_count):
		if String(option.get_item_metadata(index)) == metadata:
			return index
	return -1


func _popup_item_id_by_text(popup: PopupMenu, text: String) -> int:
	for index in range(popup.item_count):
		if popup.get_item_text(index) == text:
			return popup.get_item_id(index)
	return -1


func _edge_to(graph: Dictionary, to_node: String, to_port: String) -> Dictionary:
	for edge in graph.get("edges", []) as Array:
		var edge_dict := edge as Dictionary
		if String(edge_dict.get("to_node", "")) == to_node and String(edge_dict.get("to_port", "")) == to_port:
			return edge_dict
	return {}


class GraphCancelRecorder:
	var cancel_phase_prefix := ""
	var progress_events: Array = []

	func progress(status: Dictionary) -> void:
		progress_events.append(status.duplicate(true))

	func cancel(status: Dictionary) -> bool:
		return cancel_phase_prefix != "" and String(status.get("phase", "")).begins_with(cancel_phase_prefix)
