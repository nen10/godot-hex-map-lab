extends "res://tests/test_editor_plugin_test_base.gd"

const HexGenerationPreset = preload("res://addons/hex_map_kit/generation/hex_generation_preset.gd")
const HexGenerationGraph = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_preset_factory_maps_generation_profile_to_three_node_graph()
	await _test_build_screen_simple_profile_opens_graph_and_promotes_terrain()
	await _test_workspace_simple_generate_bootstraps_graphless_selected_layer()
	await _test_simple_profile_without_project_profile_uses_default_graph()
	_finish("res://tests/test_build_screen_full.gd")


func _test_preset_factory_maps_generation_profile_to_three_node_graph() -> void:
	var profile := HexGenerationProfileResource.new()
	profile.profile_id = "screen30_hex"
	profile.display_name = "Screen 30 Hex"
	profile.shape_id = "hexagon"
	profile.radius = 5
	profile.default_seed = 42
	profile.wall_probability = 0.37
	profile.connectivity_mode = "sparse"

	var graph: Dictionary = HexGenerationPreset.from_profile(profile)
	var validation: Dictionary = HexGenerationGraph.validate(graph)
	_assert_true(bool(validation["ok"]), "SCREEN-30 preset graph validates")
	_assert_eq((graph["nodes"] as Dictionary).size(), 4, "SCREEN-30 preset graph has shape, wall, connectivity, result")
	_assert_eq((graph["edges"] as Array).size(), 3, "SCREEN-30 preset graph connects through Result")
	var shape = (graph["nodes"] as Dictionary)["shape"] as Dictionary
	var walls = (graph["nodes"] as Dictionary)["walls"] as Dictionary
	var connect = (graph["nodes"] as Dictionary)["connectivity"] as Dictionary
	var result = (graph["nodes"] as Dictionary)["result"] as Dictionary
	_assert_eq(String(shape["type"]), "shape", "SCREEN-30 shape node is present")
	_assert_eq(String(result["type"]), "result", "SCREEN-30 Result node is present")
	_assert_eq(String((shape["params"] as Dictionary)["shape"]), "hexagon", "SCREEN-30 profile shape reaches graph params")
	_assert_eq(int((shape["params"] as Dictionary)["radius"]), 5, "SCREEN-30 profile radius reaches graph params")
	_assert_eq(float((walls["params"] as Dictionary)["wall_probability"]), 0.37, "SCREEN-30 profile wall probability reaches graph params")
	_assert_eq(int((walls["params"] as Dictionary)["seed"]), 42, "SCREEN-30 profile seed reaches wall graph params")
	_assert_eq(String((connect["params"] as Dictionary)["method"]), "sparse", "SCREEN-30 profile connectivity reaches graph params")
	var promote_targets = HexGenerationPreset.promote_targets_for_profile(profile)
	_assert_eq(String((promote_targets[0] as Dictionary)["node_id"]), "result", "SCREEN-30 preset promote target is Result")
	_assert_eq(String((promote_targets[0] as Dictionary)["role"]), "result", "SCREEN-30 preset promote role is Result")


func _test_build_screen_simple_profile_opens_graph_and_promotes_terrain() -> void:
	var context := HexMapWorkspaceAssetContext.new()
	context.set_level_document(HexMapDocumentResource.new())
	var profile := HexGenerationProfileResource.new()
	profile.profile_id = "screen30_profile"
	profile.display_name = "Screen 30 Profile"
	profile.shape_id = "rectangle"
	profile.width = 7
	profile.height = 5
	profile.default_seed = 9
	profile.wall_probability = 0.2
	profile.connectivity_mode = "dense"
	context.set_generation_profile(profile)

	var screen = HexMapBuildScreen.new()
	screen.set_workspace_asset_context(context)
	root.add_child(screen)
	var scene_root = Node2D.new()
	root.add_child(scene_root)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "Screen30DirectLayer"
	selected_layer.level_document_resource = context.level_document
	scene_root.add_child(selected_layer)
	await process_frame
	screen.ensure_graph_context_for_hex_tile_map_layer(selected_layer, {"run": false})

	var before = screen.build_screen_snapshot()
	_assert_true(bool(before["simple_profile_bar_present"]), "SCREEN-30 Build screen exposes Simple profile band")
	_assert_true(bool(before["simple_generate_button_present"]), "SCREEN-30 Build screen exposes Simple Generate action")
	_assert_true(bool(before["canvas_is_dominant"]), "SCREEN-30 canvas remains dominant with Simple band present")
	_assert_eq(String(before["simple_profile_selected"]), "Screen 30 Profile", "SCREEN-30 Simple band shows selected project profile")

	var result = screen.run_simple_profile_graph()
	_assert_true(bool(result["ok"]), "SCREEN-30 Simple profile graph runs")
	_assert_eq(String(result["profile_id"]), "screen30_profile", "SCREEN-30 Simple graph records profile id")
	_assert_true(bool(result["preset_graph_visible_in_canvas"]), "SCREEN-30 Simple graph is visible in the canvas")
	_assert_eq(String(result["promote_target_role"]), "result", "SCREEN-30 Simple graph targets Result promote")
	_assert_true(bool((result["promote_result"] as Dictionary).get("ok", false)), "SCREEN-30 Simple graph promotes Result")
	_assert_eq(context.level_document.terrain_layers.size(), 1, "SCREEN-30 terrain promote writes generated terrain")

	var snapshot = screen.build_screen_snapshot()
	_assert_true(bool(snapshot["preview_available"]), "SCREEN-30 Simple graph has preview after generate")
	_assert_true(bool(snapshot["simple_and_graph_same_model"]), "SCREEN-30 Simple and graph share the same visible model")
	_assert_true(bool(snapshot["preset_graph_visible_in_canvas"]), "SCREEN-30 snapshot records preset graph on canvas")
	_assert_eq(String(snapshot["promote_target_role"]), "result", "SCREEN-30 snapshot shows Result promote role")
	_assert_true(bool(snapshot["dirty_status_visible"]), "SCREEN-30 dirty state is visible")
	_assert_true(bool(snapshot["last_run_visible"]), "SCREEN-30 last run state is visible")
	_assert_viewport_projection_ok(snapshot, "SCREEN-30 direct Simple graph projects to viewport")

	screen.graph_canvas().set_node_params("walls", {
		"wall_probability": 0.12,
		"seed": 9,
	})
	snapshot = screen.build_screen_snapshot()
	var dirty_ids = snapshot["dirty_node_ids"] as PackedStringArray
	_assert_true(dirty_ids.has("walls"), "SCREEN-30 graph edit marks preset wall node dirty")
	_assert_true(dirty_ids.has("connectivity"), "SCREEN-30 graph edit marks downstream preset node dirty")
	var rerun = screen.run_graph()
	_assert_true(bool(rerun["ok"]), "SCREEN-30 edited preset graph reruns through the graph path")

	scene_root.queue_free()
	screen.queue_free()
	await process_frame


func _test_workspace_simple_generate_bootstraps_graphless_selected_layer() -> void:
	var workspace = HexMapWorkspace.new()
	root.add_child(workspace)
	await process_frame
	var scene_root = Node2D.new()
	root.add_child(scene_root)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "Screen30GraphlessLayer"
	scene_root.add_child(selected_layer)
	await process_frame
	workspace.set_selected_hex_tile_map_node(selected_layer, "test.screen30.select_graphless")

	var profile := HexGenerationProfileResource.new()
	profile.profile_id = "screen30_workspace_profile"
	profile.display_name = "Screen 30 Workspace Profile"
	profile.shape_id = "rectangle"
	profile.width = 6
	profile.height = 4
	profile.wall_probability = 0.1
	workspace.workspace_asset_context().set_generation_profile(profile)
	await process_frame

	var button = workspace.build_screen().find_child("Build Simple Generate Button", true, false) as Button
	_assert_true(button is Button, "SCREEN-30 Workspace mounts Simple Generate button")
	button.emit_signal("pressed")
	await process_frame

	var snapshot = workspace.generation_screen_snapshot()
	_assert_true(selected_layer.level_document_resource is HexMapDocumentResource, "SCREEN-30 graphless selected layer receives document context")
	_assert_true(selected_layer.generation_graph_resource is HexGenerationGraphResource, "SCREEN-30 graphless selected layer receives embedded graph resource")
	_assert_eq(String(selected_layer.generation_graph_resource.ownership_semantics), "embed", "SCREEN-30 generated graph resource is embedded")
	_assert_eq(String(selected_layer.generation_graph_resource.semantics_reference_path), "", "SCREEN-30 embedded graph resource is self-contained")
	var stored_graph: Dictionary = selected_layer.generation_graph_resource.to_graph_model()
	_assert_true((stored_graph["nodes"] as Dictionary).has("result"), "SCREEN-30 selected layer graph resource stores the Simple preset Result graph")
	_assert_true(selected_layer.level_document_resource.terrain_layers.size() > 0, "SCREEN-30 Simple button path promotes terrain without Resource reference failure")
	_assert_true(selected_layer.display_used_cell_count() > 0, "SCREEN-30 Simple button path projects generated terrain to viewport layer")
	_assert_true(bool(snapshot["build_context_ready"]), "SCREEN-30 Workspace button path records ready build context")
	_assert_true(bool(snapshot["viewport_preview_visible"]), "SCREEN-30 Simple button path records visible viewport preview")
	_assert_true(int(snapshot["viewport_preview_cell_count"]) > 0, "SCREEN-30 Simple button path records viewport cell count")
	_assert_viewport_projection_ok(snapshot, "SCREEN-30 Simple button path has a successful viewport projection report")
	_assert_eq(String(snapshot["preview_commit_state"]), "preview_pending", "SCREEN-30 Simple button path leaves Apply/Revert preview pending")
	_assert_true(bool(snapshot["node_thumbnail_secondary"]), "SCREEN-30 node thumbnail remains secondary proof only")
	_assert_true(bool((snapshot["simple_generate_result"] as Dictionary).get("context_layer_has_graph_resource", false)), "SCREEN-30 Simple result records context layer graph resource")
	_assert_true(bool((snapshot["simple_generate_result"] as Dictionary).get("preset_graph_visible_in_canvas", false)), "SCREEN-30 Workspace button path opens preset graph in canvas")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _test_simple_profile_without_project_profile_uses_default_graph() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	var result = screen.run_simple_profile_graph()
	_assert_true(bool(result["ok"]), "SCREEN-30 Simple profile runs with default profile when no project profile is selected")
	_assert_eq(String(result["profile_id"]), "default_profile", "SCREEN-30 default profile is explicit")
	_assert_true(bool(result["preset_graph_visible_in_canvas"]), "SCREEN-30 default Simple graph is visible in canvas")
	var snapshot = screen.build_screen_snapshot()
	_assert_eq(String(snapshot["simple_profile_selected"]), "Default Profile", "SCREEN-30 default profile appears in Simple band")
	_assert_true(bool(snapshot["preview_available"]), "SCREEN-30 default Simple graph generates preview")

	screen.queue_free()
	await process_frame


func _assert_viewport_projection_ok(snapshot: Dictionary, message: String) -> void:
	var report := snapshot.get("viewport_apply_report", {}) as Dictionary
	_assert_true(bool(report.get("projection_ok", false)), message)
	_assert_true(bool(report.get("layer_inside_tree", false)), "%s: target layer is inside tree" % message)
	_assert_true(bool(report.get("display_tiles_ready", false)), "%s: display tiles are ready" % message)
	_assert_true(int(report.get("display_tile_source_count", 0)) > 0, "%s: tile source exists" % message)
	_assert_true(int(report.get("display_used_cell_count", 0)) > 0, "%s: display cells exist" % message)
