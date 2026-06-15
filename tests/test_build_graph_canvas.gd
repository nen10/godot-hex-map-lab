extends "res://tests/test_editor_plugin_test_base.gd"

const HexGenerationNodeTypes = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await _test_build_screen_opens_on_graph_canvas()
	await _test_canvas_rejects_type_mismatched_connection()
	await _test_canvas_builds_model_and_runs_three_node_preview()
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


func _test_palette_and_inspector_reflect_graph_contract() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	var palette_snapshot = screen.node_palette().palette_snapshot()
	_assert_eq(int(palette_snapshot["button_count"]), 7, "GRAPH-11 palette exposes seven MVP node types")
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
