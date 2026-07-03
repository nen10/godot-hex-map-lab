extends "res://tests/test_editor_plugin_test_base.gd"

const HexMapAssetLibrary = preload("res://addons/hex_map_kit/editor/hex_map_asset_library.gd")
const HexGenerationPreset = preload("res://addons/hex_map_kit/generation/hex_generation_preset.gd")
const HexGenerationGraph = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexGenerationGraphRunner = preload("res://addons/hex_map_kit/generation/hex_generation_graph_runner.gd")
const HexGenerationNodeTypes = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_preset_factory_maps_generation_profile_to_two_node_graph()
	await _test_build_header_sweeps_old_controls_and_lists_templates()
	await _test_basic_template_applies_and_generates()
	await _test_graph_save_as_load_roundtrip()
	await _test_result_save_lists_project_result_without_thumbnail()
	await _test_workspace_generate_bootstraps_graphless_selected_layer_without_profile()
	_finish("res://tests/test_build_screen_full.gd")


func _test_preset_factory_maps_generation_profile_to_two_node_graph() -> void:
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
	_assert_true(bool(validation["ok"]), "GQM-13 headless preset graph validates")
	_assert_eq((graph["nodes"] as Dictionary).size(), 2, "GQM-13 headless Simple preset has Terrain Generation and Result")
	_assert_eq((graph["edges"] as Array).size(), 1, "GQM-13 headless Simple preset connects terrain to Result")
	var terrain = (graph["nodes"] as Dictionary)["terrain"] as Dictionary
	var result = (graph["nodes"] as Dictionary)["result"] as Dictionary
	_assert_eq(String(terrain["type"]), HexGenerationNodeTypes.NODE_TERRAIN_GENERATION, "GQM-13 Simple preset uses consolidated terrain")
	_assert_eq(String(result["type"]), HexGenerationNodeTypes.NODE_RESULT, "GQM-13 Simple preset keeps Result node")
	_assert_true(_all_nodes_are_consolidated(graph), "GQM-13 Simple preset contains only consolidated node types")
	_assert_eq(String((terrain["params"] as Dictionary)["shape"]), "hexagon", "GQM-13 profile shape reaches graph params")
	_assert_eq(int((terrain["params"] as Dictionary)["radius"]), 5, "GQM-13 profile radius reaches graph params")
	_assert_eq(float((terrain["params"] as Dictionary)["wall_probability"]), 0.37, "GQM-13 profile wall probability reaches graph params")
	_assert_eq(int((terrain["params"] as Dictionary)["wall_seed"]), 42, "GQM-13 profile seed reaches wall graph params")
	_assert_eq(String((terrain["params"] as Dictionary)["connectivity_method"]), "sparse", "GQM-13 profile connectivity reaches graph params")
	var promote_targets = HexGenerationPreset.promote_targets_for_profile(profile)
	_assert_eq(String((promote_targets[0] as Dictionary)["node_id"]), "result", "GQM-13 preset promote target is Result")
	_assert_eq(String((promote_targets[0] as Dictionary)["role"]), "result", "GQM-13 preset promote role is Result")
	_assert_simple_preset_matches_legacy_chain(graph, _legacy_simple_profile_graph(profile), "GQM-13 Simple preset output matches legacy chain")


func _test_build_header_sweeps_old_controls_and_lists_templates() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	var snapshot = screen.build_screen_snapshot()
	_assert_eq(String(snapshot["primary_action"]), "Generate", "GQM-13 primary action is Generate")
	_assert_true(bool(snapshot["template_dropdown_present"]), "GQM-13 Build header exposes Template dropdown")
	_assert_true(bool(snapshot["save_as_button_present"]), "GQM-13 Build header exposes Save as")
	_assert_true(bool(snapshot["load_button_present"]), "GQM-13 Build header exposes Load")
	_assert_true(bool(snapshot["template_basic_first"]), "GQM-13 Basic template is first")
	_assert_true(int(snapshot["template_option_count"]) >= 2, "GQM-13 bundled graph templates are listed")
	_assert_eq(String(snapshot["template_selected"]), "基本形", "GQM-13 Basic template is selected first")
	_assert_true(not bool(snapshot["load_graph_button_present"]), "GQM-13 old Load Graph button is absent")
	_assert_true(not bool(snapshot["overwrite_selected_graph_check_present"]), "GQM-13 old Overwrite selected checkbox is absent")
	_assert_true(not bool(snapshot["simple_profile_bar_present"]), "GQM-13 old Profile row is absent")
	_assert_true(not bool(snapshot["simple_generate_button_present"]), "GQM-13 old Generate Simple button is absent")
	_assert_true(not bool(snapshot["batch_controls_secondary"]), "GQM-13 batch controls are removed")
	_assert_true(not bool(snapshot["seed_randomize"]), "GQM-13 Seed randomize is removed")
	_assert_true(not bool(snapshot["shape_randomize"]), "GQM-13 Shape randomize is removed")
	_assert_true(not bool(snapshot["context_chips_visible"]), "GQM-13 context chip text label is absent")
	_assert_true(screen.find_child("Build Simple Generate Button", true, false) == null, "GQM-13 Simple Generate node is not mounted")
	_assert_true(screen.find_child("Build Simple Profile Option", true, false) == null, "GQM-13 Profile option node is not mounted")
	_assert_true(screen.find_child("Build Batch Count", true, false) == null, "GQM-13 Batch count node is not mounted")
	_assert_true(screen.find_child("Build Seed Randomize", true, false) == null, "GQM-13 Seed randomize node is not mounted")
	_assert_true(screen.find_child("Build Shape Randomize", true, false) == null, "GQM-13 Shape randomize node is not mounted")
	_assert_true(screen.find_child("Build Load Graph Button", true, false) == null, "GQM-13 old Load Graph node is not mounted")
	_assert_true(screen.find_child("Build Overwrite Selected Graph", true, false) == null, "GQM-13 Overwrite node is not mounted")
	_assert_true(screen.find_child("Build Context Chips", true, false) == null, "GQM-13 context chip label node is not mounted")

	screen.queue_free()
	await process_frame


func _test_basic_template_applies_and_generates() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	var simple_load = screen.apply_template_by_name("Simple")
	_assert_true(bool(simple_load["ok"]), "GQM-13 Simple template applies")
	var blocked = screen.apply_template_by_name("基本形")
	_assert_true(bool(blocked.get("confirmation_required", false)), "GQM-13 existing graph replacement requires confirmation")
	var basic_load = screen.apply_template_by_name("基本形", {"confirm_replace": true})
	_assert_true(bool(basic_load["ok"]), "GQM-13 Basic template applies after confirmation")
	var snapshot = screen.build_screen_snapshot()
	var canvas = snapshot["canvas"] as Dictionary
	_assert_true(int(canvas["node_count"]) >= 7, "GQM-13 Basic template creates 7+ nodes")
	_assert_eq(int(canvas["connection_count"]), 9, "GQM-13 Basic template creates 9 edges")
	var node_ids = canvas["node_ids"] as PackedStringArray
	for node_id in PackedStringArray(["terrain", "pattern_b", "seeds_a", "seeds_b", "mask_1", "domain_items", "items", "result"]):
		_assert_true(node_ids.has(node_id), "GQM-13 Basic template has node %s" % node_id)
	var report = screen.run_graph()
	_assert_true(bool(report["ok"]), "GQM-13 Basic template Generate succeeds")
	_assert_true(bool(screen.build_screen_snapshot()["preview_available"]), "GQM-13 Basic template produces graph preview cache")

	screen.queue_free()
	await process_frame


func _test_graph_save_as_load_roundtrip() -> void:
	var had_setting := ProjectSettings.has_setting(HexMapAssetLibrary.ASSET_ROOT_SETTING)
	var previous_setting = ProjectSettings.get_setting(HexMapAssetLibrary.ASSET_ROOT_SETTING) if had_setting else HexMapAssetLibrary.DEFAULT_ASSET_ROOT
	var asset_root := _test_resource_dir("gqm13_asset_root")
	ProjectSettings.set_setting(HexMapAssetLibrary.ASSET_ROOT_SETTING, asset_root)

	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	_assert_true(bool(screen.apply_template_by_name("基本形", {"confirm_replace": true})["ok"]), "GQM-13 roundtrip starts from Basic template")
	var save_result = screen.save_current_graph_as("GQM13 Round Trip")
	var save_path := String(save_result.get("path", ""))
	_assert_eq(int(save_result.get("error", FAILED)), OK, "GQM-13 Save as stores project graph")
	_assert_true(save_path.begins_with("%s/graphs/" % asset_root), "GQM-13 Save as writes to project graphs layer")
	_assert_true(HexMapAssetLibrary.load(save_path) is HexGenerationGraphResource, "GQM-13 saved graph reloads as graph resource")

	_assert_true(bool(screen.apply_template_by_name("Simple", {"confirm_replace": true})["ok"]), "GQM-13 Simple template can replace current graph")
	_assert_eq(int((screen.build_screen_snapshot()["canvas"] as Dictionary)["node_count"]), 2, "GQM-13 Simple replacement changes canvas")
	var load_result = screen.apply_template_by_name("GQM13 Round Trip", {"confirm_replace": true})
	_assert_true(bool(load_result["ok"]), "GQM-13 Load reads saved project graph")
	_assert_eq(String(load_result.get("template_source", "")), HexMapAssetLibrary.SOURCE_PROJECT, "GQM-13 Load identifies project source")
	var loaded_canvas = (screen.build_screen_snapshot()["canvas"] as Dictionary)
	_assert_true(int(loaded_canvas["node_count"]) >= 7, "GQM-13 loaded project graph restores Basic node count")
	_assert_eq(int(loaded_canvas["connection_count"]), 9, "GQM-13 loaded project graph restores Basic edge count")

	screen.queue_free()
	await process_frame
	ProjectSettings.set_setting(HexMapAssetLibrary.ASSET_ROOT_SETTING, previous_setting)


func _test_result_save_lists_project_result_without_thumbnail() -> void:
	var had_setting := ProjectSettings.has_setting(HexMapAssetLibrary.ASSET_ROOT_SETTING)
	var previous_setting = ProjectSettings.get_setting(HexMapAssetLibrary.ASSET_ROOT_SETTING) if had_setting else HexMapAssetLibrary.DEFAULT_ASSET_ROOT
	var asset_root := _test_resource_dir("gqm14_result_asset_root")
	ProjectSettings.set_setting(HexMapAssetLibrary.ASSET_ROOT_SETTING, asset_root)

	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	_assert_true(bool(screen.apply_template_by_name("基本形", {"confirm_replace": true})["ok"]), "GQM-14 result save starts from Basic template")
	var report = screen.run_graph()
	_assert_true(bool(report["ok"]), "GQM-14 result save has generated Result output")
	var before_save = screen.build_screen_snapshot()
	_assert_true(bool(before_save["save_result_button_present"]), "GQM-14 Save result action is mounted")
	_assert_true(bool(before_save["save_result_available"]), "GQM-14 Save result enables after Generate")
	_assert_true(bool(before_save["result_dropdown_present"]), "GQM-14 Results dropdown is mounted")
	_assert_eq(int(before_save["header_control_count"]), 7, "GQM-14 header keeps seven logical groups")

	var save_result = screen.save_current_result_as("GQM14 Saved Result")
	var save_path := String(save_result.get("path", ""))
	_assert_eq(int(save_result.get("error", FAILED)), OK, "GQM-14 Save result stores project result")
	_assert_true(save_path.begins_with("%s/results/" % asset_root), "GQM-14 Save result writes to project results layer")
	var loaded = HexMapAssetLibrary.load(save_path)
	_assert_true(loaded is HexGenerationResultResource, "GQM-14 saved result reloads as HexGenerationResultResource")
	var saved_result := loaded as HexGenerationResultResource
	var limited := saved_result.field_limited_snapshot()
	_assert_eq(String(limited["result_id"]), "gqm_14_saved_result", "GQM-14 saved result records result_id")
	_assert_true(bool(limited["primary_map_present"]), "GQM-14 saved result stores substrate data")
	_assert_true(int(limited["overlay_maps_count"]) > 0, "GQM-14 saved result stores overlay data")
	_assert_true((limited["generation_snapshot_keys"] as Array).has("graph"), "GQM-14 saved result stores graph snapshot")
	_assert_true((limited["metadata_keys"] as Array).has("display_name"), "GQM-14 saved result stores name in metadata")
	_assert_eq(String(limited["park_status"]), "", "GQM-14 saved result does not write status")
	_assert_eq(bool(limited["park_overlay_mode"]), false, "GQM-14 saved result does not write overlay_mode")
	_assert_eq(float(limited["park_score"]), 0.0, "GQM-14 saved result does not write score")
	_assert_true(not bool(limited["park_candidate_document_present"]), "GQM-14 saved result does not write candidate_document")
	_assert_true(not bool(limited["park_validation_result_present"]), "GQM-14 saved result does not write validation_result")
	_assert_true(bool(limited["park_validation_summary_empty"]), "GQM-14 saved result leaves validation_summary empty")
	_assert_true(bool(limited["park_source_snapshot_empty"]), "GQM-14 saved result leaves source_snapshot empty")
	_assert_true(bool(limited["park_score_row_empty"]), "GQM-14 saved result leaves score_row empty")
	_assert_true(bool(limited["park_preview_empty"]), "GQM-14 saved result leaves preview empty")

	var snapshot = screen.build_screen_snapshot()
	_assert_eq(String(snapshot["result_selected"]), "GQM14 Saved Result", "GQM-14 Results dropdown lists saved result by name")
	_assert_eq(int(snapshot["result_option_count"]), 1, "GQM-14 Results dropdown lists project result")
	_assert_true(not bool(snapshot["result_thumbnail_present"]), "GQM-14 Results list has no thumbnail surface")
	var entries = snapshot["result_entries"] as Array
	_assert_eq(entries.size(), 1, "GQM-14 result entries contain saved project result")
	_assert_eq(String((entries[0] as Dictionary).get("source", "")), HexMapAssetLibrary.SOURCE_PROJECT, "GQM-14 result list uses project source")
	_assert_true(not (entries[0] as Dictionary).has("preview"), "GQM-14 result list entry does not include preview payload")

	screen.queue_free()
	await process_frame
	ProjectSettings.set_setting(HexMapAssetLibrary.ASSET_ROOT_SETTING, previous_setting)


func _test_workspace_generate_bootstraps_graphless_selected_layer_without_profile() -> void:
	var workspace = HexMapWorkspace.new()
	root.add_child(workspace)
	await process_frame
	var scene_root = Node2D.new()
	root.add_child(scene_root)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "GQM13GraphlessLayer"
	scene_root.add_child(selected_layer)
	await process_frame
	workspace.set_selected_hex_tile_map_node(selected_layer, "test.gqm13.select_graphless")
	await process_frame

	var before = workspace.generation_screen_snapshot()
	_assert_true(bool(before["template_dropdown_present"]), "GQM-13 workspace Build exposes Template")
	_assert_true(not bool(before["simple_generate_button_present"]), "GQM-13 workspace does not expose Simple Generate")
	var button = workspace.build_screen().find_child("Build Generate Button", true, false) as Button
	_assert_true(button is Button, "GQM-13 Workspace mounts primary Generate button")
	button.emit_signal("pressed")
	await process_frame
	await _wait_for_workspace_preview_pending(workspace, "GQM-13 primary Generate path")

	var snapshot = workspace.generation_screen_snapshot()
	_assert_true(selected_layer.level_document_resource is HexMapDocumentResource, "GQM-13 graphless selected layer receives document context")
	_assert_true(selected_layer.generation_graph_resource is HexGenerationGraphResource, "GQM-13 graphless selected layer receives graph resource")
	var stored_graph: Dictionary = selected_layer.generation_graph_resource.to_graph_model()
	_assert_eq((stored_graph["nodes"] as Dictionary).size(), 2, "GQM-13 profile-free bootstrap stores Simple graph")
	_assert_true((stored_graph["nodes"] as Dictionary).has("result"), "GQM-13 profile-free bootstrap stores Result graph")
	_assert_true(selected_layer.level_document_resource.terrain_layers.size() > 0, "GQM-13 primary Generate promotes terrain")
	_assert_true(selected_layer.display_used_cell_count() > 0, "GQM-13 primary Generate projects generated terrain to viewport layer")
	_assert_true(bool(snapshot["build_context_ready"]), "GQM-13 primary Generate records ready build context")
	_assert_true(bool(snapshot["viewport_preview_visible"]), "GQM-13 primary Generate records visible viewport preview")
	_assert_viewport_projection_ok(snapshot, "GQM-13 primary Generate has successful viewport projection report")
	_assert_eq(String(snapshot["preview_commit_state"]), "preview_pending", "GQM-13 primary Generate leaves Apply/Revert preview pending")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _legacy_simple_profile_graph(profile: HexGenerationProfileResource) -> Dictionary:
	var graph := HexGenerationGraph.new_graph()
	var shape_id := String(profile.shape_id)
	match shape_id:
		"hexagon":
			HexGenerationGraph.add_node(graph, "shape", "shape", {
				"shape": "hexagon",
				"radius": max(0, int(profile.radius)),
			})
		"square":
			HexGenerationGraph.add_node(graph, "shape", "shape", {
				"shape": "square",
				"size": max(1, int(profile.radius)),
			})
		"rectangle", _:
			HexGenerationGraph.add_node(graph, "shape", "shape", {
				"shape": "rectangle",
				"width": max(1, int(profile.width)),
				"height": max(1, int(profile.height)),
			})
	HexGenerationGraph.add_node(graph, "walls", "wall_field", {
		"wall_probability": clampf(float(profile.wall_probability), 0.0, 1.0),
		"seed": int(profile.default_seed),
	})
	HexGenerationGraph.add_node(graph, "connectivity", "connectivity", {
		"method": String(profile.connectivity_mode),
		"seed": int(profile.default_seed) + 101,
	})
	HexGenerationGraph.add_node(graph, "result", "result", {
		"orientation": 0,
	})
	HexGenerationGraph.add_edge(graph, "shape", "walls", "in")
	HexGenerationGraph.add_edge(graph, "walls", "connectivity", "in")
	HexGenerationGraph.add_edge(graph, "connectivity", "result", "terrain")
	return graph


func _assert_simple_preset_matches_legacy_chain(consolidated: Dictionary, legacy: Dictionary, message: String) -> void:
	var consolidated_report := HexGenerationGraphRunner.run_with_report(consolidated)
	var legacy_report := HexGenerationGraphRunner.run_with_report(legacy)
	_assert_true(bool(consolidated_report.get("ok", false)), "%s: consolidated graph runs" % message)
	_assert_true(bool(legacy_report.get("ok", false)), "%s: legacy graph runs" % message)
	if not bool(consolidated_report.get("ok", false)) or not bool(legacy_report.get("ok", false)):
		return
	var consolidated_result = (consolidated_report["cache"] as Dictionary).get("result", null)
	var legacy_result = (legacy_report["cache"] as Dictionary).get("result", null)
	_assert_eq(_result_signature(consolidated_result), _result_signature(legacy_result), message)


func _all_nodes_are_consolidated(graph: Dictionary) -> bool:
	for node in (graph.get("nodes", {}) as Dictionary).values():
		if not HexGenerationNodeTypes.is_consolidated_type(String((node as Dictionary).get("type", ""))):
			return false
	return true


func _result_signature(result) -> String:
	if not result is HexGenerationResultResource:
		return "<missing-result>"
	var result_resource := result as HexGenerationResultResource
	if result_resource.primary_map == null:
		return "<missing-primary>"
	return _map_signature(result_resource.primary_map.to_map_data())


func _map_signature(data) -> String:
	if not data is HexMapData:
		return "<missing-map>"
	return "%s|%s|%d" % [
		str(HexMapData.sorted_keys(data.cells)),
		str(HexMapData.sorted_keys(data.walls)),
		int(data.cyclic_size),
	]


func _wait_for_workspace_preview_pending(workspace: HexMapWorkspace, message: String) -> void:
	var guard := 0
	var snapshot = workspace.generation_screen_snapshot()
	while String(snapshot["preview_commit_state"]) != "preview_pending" and guard < 240:
		await process_frame
		snapshot = workspace.generation_screen_snapshot()
		guard += 1
	_assert_eq(String(snapshot["preview_commit_state"]), "preview_pending", "%s reaches preview pending state" % message)


func _assert_viewport_projection_ok(snapshot: Dictionary, message: String) -> void:
	var report := snapshot.get("viewport_apply_report", {}) as Dictionary
	_assert_true(bool(report.get("projection_ok", false)), message)
	_assert_true(bool(report.get("layer_inside_tree", false)), "%s: target layer is inside tree" % message)
	_assert_true(bool(report.get("display_tiles_ready", false)), "%s: display tiles are ready" % message)
	_assert_true(int(report.get("display_tile_source_count", 0)) > 0, "%s: tile source exists" % message)
	_assert_true(int(report.get("display_used_cell_count", 0)) > 0, "%s: display cells exist" % message)
