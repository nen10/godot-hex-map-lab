extends "res://tests/test_editor_plugin_test_base.gd"

const HexGenerationNodeTypes = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await _test_build_screen_opens_on_graph_canvas()
	await _test_canvas_rejects_type_mismatched_connection()
	await _test_result_canvas_exposes_numbered_overlay_ports()
	await _test_canvas_builds_model_and_runs_three_node_preview()
	await _test_run_state_caches_and_marks_dirty_downstream()
	await _test_edge_selection_and_delete_updates_graph_state()
	await _test_typed_filter_nodes_match_editor_connection_types()
	await _test_run_state_reports_failure_node()
	await _test_build_screen_generate_is_primary_and_batch_secondary()
	await _test_build_screen_generate_opens_popup_progress()
	await _test_build_screen_cancel_passes_interrupt_options()
	await _test_palette_and_inspector_reflect_graph_contract()
	await _test_workspace_mounts_build_screen_with_generate_alias()
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


func _test_canvas_rejects_type_mismatched_connection() -> void:
	var canvas = HexMapBuildGraphCanvas.new()
	root.add_child(canvas)
	await process_frame

	var shape = canvas.add_graph_node(HexGenerationNodeTypes.NODE_SHAPE, Vector2.ZERO, "shape")
	var item = canvas.add_graph_node(HexGenerationNodeTypes.NODE_ITEM_GENERATOR, Vector2(200, 0), "items")
	var result = canvas.request_connection(shape, 0, item, 0)
	_assert_true(not bool(result["ok"]), "GRAPH-11 canvas rejects terrain->selection mismatch")
	_assert_eq(int(canvas.canvas_snapshot()["connection_count"]), 0, "GRAPH-11 rejected connection is not kept")
	_assert_true(String(result["reason"]).contains("Cannot connect"), "GRAPH-11 rejected connection explains type")

	canvas.queue_free()
	await process_frame


func _test_result_canvas_exposes_numbered_overlay_ports() -> void:
	var canvas = HexMapBuildGraphCanvas.new()
	root.add_child(canvas)
	await process_frame

	var shape = canvas.add_graph_node(HexGenerationNodeTypes.NODE_SHAPE, Vector2.ZERO, "shape")
	var filter = canvas.add_graph_node(HexGenerationNodeTypes.NODE_REGION_FILTER, Vector2(220, 0), "filter")
	var items_a = canvas.add_graph_node(HexGenerationNodeTypes.NODE_ITEM_GENERATOR, Vector2(440, 0), "items_a")
	var items_b = canvas.add_graph_node(HexGenerationNodeTypes.NODE_ITEM_GENERATOR, Vector2(660, 0), "items_b")
	var result = canvas.add_graph_node(HexGenerationNodeTypes.NODE_RESULT, Vector2(880, 0), "result")
	_assert_true(bool(canvas.request_connection(shape, 0, filter, 0)["ok"]), "REPAIR-11 canvas connects terrain into filter")
	_assert_true(bool(canvas.request_connection(filter, 0, items_a, 0)["ok"]), "REPAIR-11 canvas connects filter into first item generator")
	_assert_true(bool(canvas.request_connection(filter, 0, items_b, 0)["ok"]), "REPAIR-11 canvas connects filter into second item generator")
	_assert_true(bool(canvas.request_connection(shape, 0, result, 0)["ok"]), "REPAIR-11 canvas connects terrain into Result.terrain")
	_assert_true(bool(canvas.request_connection(items_a, 0, result, 1)["ok"]), "REPAIR-11 canvas connects overlay into Result.overlay_0")
	_assert_true(bool(canvas.request_connection(items_b, 0, result, 2)["ok"]), "REPAIR-11 canvas connects overlay into Result.overlay_1")

	var graph = canvas.build_graph_model()
	var ports: Array = []
	for edge in graph.get("edges", []) as Array:
		var edge_dict = edge as Dictionary
		if String(edge_dict.get("to_node", "")) == "result":
			ports.append(String(edge_dict.get("to_port", "")))
	ports.sort()
	_assert_eq(ports, ["overlay_0", "overlay_1", "terrain"], "REPAIR-11 canvas stores numbered Result input port names")
	var validation = canvas.validate_graph_model()
	_assert_true(bool(validation.get("ok", false)), "REPAIR-11 canvas graph with numbered Result overlays validates")

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
	_assert_eq(int(canvas_snapshot["connection_count"]), 2, "GRAPH-11 two typed edges are present")
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


func _test_typed_filter_nodes_match_editor_connection_types() -> void:
	var canvas = HexMapBuildGraphCanvas.new()
	root.add_child(canvas)
	await process_frame

	var shape = canvas.add_graph_node(HexGenerationNodeTypes.NODE_SHAPE, Vector2.ZERO, "shape")
	var terrain_filter = canvas.add_graph_node(HexGenerationNodeTypes.NODE_TERRAIN_FILTER, Vector2(220, 0), "terrain_filter")
	var item_generator = canvas.add_graph_node(HexGenerationNodeTypes.NODE_ITEM_GENERATOR, Vector2(440, 0), "items")
	var overlay_filter = canvas.add_graph_node(HexGenerationNodeTypes.NODE_OVERLAY_FILTER, Vector2(660, 0), "overlay_filter")

	_assert_true(bool(canvas.request_connection(shape, 0, terrain_filter, 0)["ok"]), "REPAIR-16 terrain output connects to Terrain Filter")
	_assert_true(bool(canvas.request_connection(terrain_filter, 0, item_generator, 0)["ok"]), "REPAIR-16 selection output connects to Item Generator")
	_assert_true(bool(canvas.request_connection(item_generator, 0, overlay_filter, 0)["ok"]), "REPAIR-16 overlay output connects to Overlay Filter")
	_assert_true(not bool(canvas.validate_connection(item_generator, 0, terrain_filter, 0)["ok"]), "REPAIR-16 overlay output is not valid for Terrain Filter")
	_assert_true(not bool(canvas.validate_connection(shape, 0, overlay_filter, 0)["ok"]), "REPAIR-16 terrain output is not valid for Overlay Filter")

	var item_node = canvas.get_node(NodePath(item_generator)) as GraphNode
	var overlay_filter_node = canvas.get_node(NodePath(overlay_filter)) as GraphNode
	var shape_node = canvas.get_node(NodePath(shape)) as GraphNode
	var terrain_filter_node = canvas.get_node(NodePath(terrain_filter)) as GraphNode
	# GraphEdit allows a drag connection only when port type ids match (default implicit equal-type rule).
	var overlay_out := item_node.get_output_port_type(0)
	var terrain_out := shape_node.get_output_port_type(0)
	var overlay_filter_in := overlay_filter_node.get_input_port_type(0)
	var terrain_filter_in := terrain_filter_node.get_input_port_type(0)
	_assert_eq(overlay_out, overlay_filter_in, "REPAIR-16 overlay output port type matches Overlay Filter input port type (editor-connectable)")
	_assert_eq(terrain_out, terrain_filter_in, "REPAIR-16 terrain output port type matches Terrain Filter input port type (editor-connectable)")
	_assert_true(overlay_out != terrain_filter_in, "REPAIR-16 overlay output port type does not match Terrain Filter input (editor blocks the drag)")
	_assert_true(terrain_out != overlay_filter_in, "REPAIR-16 terrain output port type does not match Overlay Filter input (editor blocks the drag)")

	canvas.queue_free()
	await process_frame


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
	_assert_eq(int(palette_snapshot["button_count"]), 10, "REPAIR-13A Add Node row exposes typed Source and role buttons")
	_assert_true((palette_snapshot["group_ids"] as PackedStringArray).has("anchor"), "REPAIR-13A Add Node row has Anchor group")
	_assert_true((palette_snapshot["group_ids"] as PackedStringArray).has("build"), "REPAIR-13A Add Node row has Build group")
	_assert_true((palette_snapshot["group_ids"] as PackedStringArray).has("select"), "REPAIR-13A Add Node row has Select group")
	_assert_true(not bool(palette_snapshot["compose_primary"]), "REPAIR-13A Compose is not in the primary Add Node row")

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

	screen._on_palette_node_template_requested(HexGenerationNodeTypes.NODE_SOURCE, {
		"kind": "context",
		"source_key": "document_overlay",
		"output_type": "overlay",
	})
	var typed_source_id := canvas.selected_node_id()
	var typed_params := canvas.node_params(typed_source_id)
	_assert_eq(String(typed_params.get("output_type", "")), "overlay", "REPAIR-13A Source Overlay button creates typed Source params")
	_assert_eq(canvas.selected_output_type(), "overlay", "REPAIR-13A Source Overlay output type matches connection validation")
	_assert_true(String((canvas._graph_node(typed_source_id) as GraphNode).title).contains("Source Overlay"), "REPAIR-13A Source node title exposes output type")

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


class GraphCancelRecorder:
	var cancel_phase_prefix := ""
	var progress_events: Array = []

	func progress(status: Dictionary) -> void:
		progress_events.append(status.duplicate(true))

	func cancel(status: Dictionary) -> bool:
		return cancel_phase_prefix != "" and String(status.get("phase", "")).begins_with(cancel_phase_prefix)
