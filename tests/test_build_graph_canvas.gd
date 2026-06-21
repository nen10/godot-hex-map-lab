extends "res://tests/test_editor_plugin_test_base.gd"

const HexGenerationNodeTypes = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await _test_build_screen_opens_on_graph_canvas()
	await _test_canvas_rejects_type_mismatched_connection()
	await _test_canvas_builds_model_and_runs_three_node_preview()
	await _test_run_state_caches_and_marks_dirty_downstream()
	await _test_run_state_reports_failure_node()
	await _test_build_screen_generate_is_primary_and_batch_secondary()
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


func _test_run_state_reports_failure_node() -> void:
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
	_assert_eq(int(snapshot["batch_count"]), 1, "GRAPH-13 batch count defaults to one")
	_assert_true(not bool(snapshot["seed_randomize"]), "GRAPH-13 seed randomize defaults off")
	_assert_true(not bool(snapshot["shape_randomize"]), "GRAPH-13 shape randomize defaults off")

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


func _test_palette_and_inspector_reflect_graph_contract() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	var palette_snapshot = screen.node_palette().palette_snapshot()
	_assert_eq(int(palette_snapshot["button_count"]), 9, "GRAPH-11 palette exposes nine MVP node types")
	_assert_true((palette_snapshot["node_types"] as PackedStringArray).has(HexGenerationNodeTypes.NODE_REGION_FILTER), "GRAPH-11 palette includes Region Filter")

	var canvas = screen.graph_canvas()
	var shape = canvas.add_graph_node(HexGenerationNodeTypes.NODE_SHAPE, Vector2.ZERO, "shape")
	canvas.select_graph_node(shape)
	await process_frame
	var inspector = screen.node_inspector().inspector_snapshot()
	_assert_true((inspector["param_fields"] as PackedStringArray).has("width"), "GRAPH-11 inspector reflects shape width param")
	_assert_true((inspector["param_fields"] as PackedStringArray).has("height"), "GRAPH-11 inspector reflects shape height param")
	_assert_true(bool(inspector["promote_button_present"]), "GRAPH-11 inspector reserves Promote action for GRAPH-12")
	_assert_true(not bool(inspector["promote_enabled"]), "GRAPH-11 Promote action stays disabled before GRAPH-12")

	var source = canvas.add_graph_node(HexGenerationNodeTypes.NODE_SOURCE, Vector2(200, 0), "source")
	canvas.select_graph_node(source)
	await process_frame
	inspector = screen.node_inspector().inspector_snapshot()
	_assert_true(bool(inspector["resource_ref_binding_present"]), "GRAPH-11 inspector exposes Resource ref binding for Source")
	_assert_true((inspector["resource_ref_fields"] as PackedStringArray).has("document"), "GRAPH-11 Source inspector exposes document Resource ref")

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
