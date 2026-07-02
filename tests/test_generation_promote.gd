extends "res://tests/test_editor_plugin_test_base.gd"

const HexGenerationGraph = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexGenerationGraphRunner = preload("res://addons/hex_map_kit/generation/hex_generation_graph_runner.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_region_filter_limits_floor_by_spawn_distance()
	_test_overlay_promote_creates_generated_layer_and_preserves_manual_layer()
	_test_object_promote_replaces_generated_objects_and_preserves_manual_object()
	_test_terrain_promote_save_load_roundtrip()
	_test_result_write_policy_composes_overlay_stack()
	await _test_build_screen_vertical_slice_promotes_overlay()
	await _test_build_context_bootstrap_selected_graphless_layer()
	await _test_build_graph_node_params_flush_to_embedded_resource()
	await _test_build_context_bootstrap_creates_layer_when_none_selected()
	await _test_build_context_bootstrap_preserves_existing_resources()
	await _test_top_generate_creates_layer_and_projects_viewport_preview()
	await _test_top_generate_uses_selected_graphless_layer_for_viewport_preview()
	await _test_top_generate_apply_revert_preview_contract()
	await _test_result_preview_promotes_multiple_overlays_as_separate_layers()
	await _test_result_row_promote_writes_document_layers()
	_finish("res://tests/test_generation_promote.gd")


func _test_region_filter_limits_floor_by_spawn_distance() -> void:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle",
		"width": 6,
		"height": 4,
	})
	HexGenerationGraph.add_node(graph, "spawn_floor", "region_filter", {
		"filter_target": "floor",
		"within_distance_of": [HexVector.zero()],
		"max_distance": 2,
	})
	HexGenerationGraph.add_edge(graph, "shape", "spawn_floor", "in")

	var cache = HexGenerationGraphRunner.run(graph)
	var selection = cache["spawn_floor"] as Array
	_assert_true(selection.size() > 0, "GRAPH-12 distance filter keeps spawn-near floor cells")
	for cell in selection:
		_assert_true(cell.subtract(HexVector.zero()).l1_norm() <= 2, "GRAPH-12 selected cell is within spawn distance")


func _test_overlay_promote_creates_generated_layer_and_preserves_manual_layer() -> void:
	var document = HexMapDocumentResource.new()
	var manual_layer = HexMapDocumentOverlayLayerResource.new()
	manual_layer.layer_id = "manual_overlay"
	manual_layer.display_name = "Manual Overlay"
	manual_layer.metadata = {"writable_source": "document"}
	document.overlay_layers.append(manual_layer)

	var overlay = HexOverlayData.from_item_cells(
		[HexVector.zero(), HexVector.q_axis()],
		"spawn",
		[HexVector.zero(), HexVector.q_axis()]
	)
	var result = HexGenerationPromote.promote(overlay, document, "overlay", {"graph_node_id": "weighted_items"})
	_assert_true(bool(result["ok"]), "GRAPH-12 overlay promote succeeds")
	_assert_eq(int(result["cell_count"]), 2, "GRAPH-12 overlay promote reports item count")
	_assert_eq(document.overlay_layers.size(), 2, "GRAPH-12 overlay promote preserves manual overlay and adds generated layer")
	var generated = document.overlay_layers[1] as HexMapDocumentOverlayLayerResource
	_assert_eq(String(generated.metadata["writable_source"]), "generated", "GRAPH-12 generated overlay records writable source")
	_assert_eq(generated.overlay.to_overlay_data().item_cells("spawn").size(), 2, "GRAPH-12 generated overlay stores item cells")
	_assert_eq(generated.tile_assignments.size(), 2, "GRAPH-12 generated overlay creates overlay tile assignment payloads")

	var second = HexOverlayData.from_item_cells([HexVector.zero()], "spawn", [HexVector.zero()])
	result = HexGenerationPromote.promote(second, document, "overlay", {"graph_node_id": "weighted_items"})
	_assert_true(bool(result["ok"]), "GRAPH-12 second overlay promote succeeds")
	_assert_eq(document.overlay_layers.size(), 2, "GRAPH-12 second overlay promote replaces only generated layer")
	_assert_eq((document.overlay_layers[0] as HexMapDocumentOverlayLayerResource).layer_id, "manual_overlay", "GRAPH-12 manual overlay remains first")
	_assert_eq((document.overlay_layers[1] as HexMapDocumentOverlayLayerResource).overlay.to_overlay_data().item_cells("spawn").size(), 1, "GRAPH-12 generated overlay is replaced")


func _test_object_promote_replaces_generated_objects_and_preserves_manual_object() -> void:
	var document = HexMapDocumentResource.new()
	var manual = HexMapDocumentObjectPlacementResource.new()
	manual.object_id = "manual_door"
	manual.cell = Vector3i(5, 0, 0)
	manual.metadata = {"writable_source": "document"}
	document.object_placements.append(manual)

	var overlay = HexOverlayData.from_item_cells([HexVector.zero()], "chest", [HexVector.zero()])
	var result = HexGenerationPromote.promote(overlay, document, "object")
	_assert_true(bool(result["ok"]), "GRAPH-12 object promote succeeds")
	_assert_eq(document.object_placements.size(), 2, "GRAPH-12 object promote preserves manual object and adds generated object")
	_assert_eq(String(document.object_placements[1].object_id), "chest", "GRAPH-12 object id comes from item key")
	_assert_eq(String(document.object_placements[1].metadata["writable_source"]), "generated", "GRAPH-12 generated object records writable source")

	result = HexGenerationPromote.promote(overlay, document, "object")
	_assert_true(bool(result["ok"]), "GRAPH-12 second object promote succeeds")
	_assert_eq(document.object_placements.size(), 2, "GRAPH-12 second object promote replaces generated objects only")
	_assert_eq(String(document.object_placements[0].object_id), "manual_door", "GRAPH-12 manual object remains")


func _test_terrain_promote_save_load_roundtrip() -> void:
	var document = HexMapDocumentResource.new()
	var manual_terrain = HexMapDocumentTerrainLayerResource.new()
	manual_terrain.layer_id = "manual_terrain"
	manual_terrain.metadata = {"writable_source": "document"}
	document.terrain_layers.append(manual_terrain)
	var data = HexMapData.rectangle(2, 2)
	var result = HexGenerationPromote.promote(data, document, "terrain")
	_assert_true(bool(result["ok"]), "GRAPH-12 terrain promote succeeds")
	_assert_eq(document.terrain_layers.size(), 2, "GRAPH-12 terrain promote preserves manual terrain and adds generated terrain")
	_assert_eq(document.terrain_layers[1].map.to_map_data().cells.size(), 4, "GRAPH-12 generated terrain stores cells")

	var path = _test_resource_path("graph12_promoted_document.tres")
	_assert_eq(ResourceSaver.save(document, path), OK, "GRAPH-12 promoted document saves")
	var loaded = ResourceLoader.load(path)
	_assert_true(loaded is HexMapDocumentResource, "GRAPH-12 promoted document reloads")
	_assert_eq(loaded.terrain_layers.size(), 2, "GRAPH-12 loaded document keeps terrain layers")
	_assert_eq(loaded.terrain_layers[1].map.to_map_data().cells.size(), 4, "GRAPH-12 loaded generated terrain keeps cells")


func _test_result_write_policy_composes_overlay_stack() -> void:
	var merge_result = HexGenerationGraphRunner.run(_policy_result_graph("add_item"))["result"]
	_assert_eq(_stack_items_at(merge_result, HexVector.zero()), ["Shop", "Treasure"], "GQM-12 add_item keeps both stacked item keys")

	var replace_result = HexGenerationGraphRunner.run(_policy_result_graph("replace_item"))["result"]
	_assert_eq(_stack_items_at(replace_result, HexVector.zero()), ["Shop"], "GQM-12 replace_item replaces previous item at the incoming cell")
	_assert_eq(String(((replace_result.metadata["overlay_inputs"] as Array)[1] as Dictionary)["write_policy"]), "replace_item", "GQM-12 Result metadata records row write policy")

	var add_replace_result = HexGenerationGraphRunner.run(_policy_result_graph("add_replace"))["result"]
	_assert_eq(_stack_items_at(add_replace_result, HexVector.zero()), ["Treasure"], "GQM-12 add_replace preserves occupied cells")
	_assert_eq(_stack_items_at(add_replace_result, HexVector.q_axis()), ["Shop"], "GQM-12 add_replace adds incoming items on empty stack cells")


func _test_build_screen_vertical_slice_promotes_overlay() -> void:
	var context = HexMapWorkspaceAssetContext.new()
	context.set_level_document(HexMapDocumentResource.new())
	var screen = HexMapBuildScreen.new()
	screen.set_workspace_asset_context(context)
	root.add_child(screen)
	await process_frame

	var report = screen.build_vertical_slice_chain_and_preview()
	_assert_true(bool(report["ok"]), "GRAPH-12 Build screen runs Shape->Wall->Connectivity->Filter->Item->Result")
	var snapshot = screen.build_screen_snapshot()
	_assert_true(bool(snapshot["preview_available"]), "GRAPH-12 item output preview is available before promote")
	_assert_true(not bool(snapshot["promote_available"]), "GQM-12 selected Result uses row Promote instead of duplicate inspector Promote")
	var canvas_snapshot = snapshot["canvas"] as Dictionary
	var result_rows := _rows_by_input(canvas_snapshot["result_rows"] as Array)
	_assert_true(bool((result_rows["in_1"] as Dictionary)["promotable"]), "GQM-12 Result overlay row is promotable")
	screen.graph_canvas().select_graph_node("weighted_items")
	await process_frame
	snapshot = screen.build_screen_snapshot()
	_assert_true(bool(snapshot["promote_available"]), "GRAPH-12 promote is available after selecting generated item output")
	screen.graph_canvas().select_graph_node("connectivity")
	var promote_terrain = screen.promote_selected_output("terrain")
	_assert_true(bool(promote_terrain["ok"]), "GRAPH-12 Build screen promotes connectivity output as terrain")
	screen.graph_canvas().select_graph_node("weighted_items")
	var promote = screen.promote_selected_output("overlay")
	_assert_true(bool(promote["ok"]), "GRAPH-12 Build screen promotes selected overlay output")
	_assert_eq(context.level_document.overlay_layers.size(), 1, "GRAPH-12 promote creates document overlay layer")
	_assert_true(context.level_document.overlay_layers[0].overlay.to_overlay_data().item_cells("spawn").size() > 0, "GRAPH-12 promoted overlay is usable")
	snapshot = screen.build_screen_snapshot()
	_assert_true(bool((snapshot["promote_result"] as Dictionary)["ok"]), "GRAPH-12 Build snapshot records promote success")

	screen.queue_free()
	await process_frame


func _test_build_context_bootstrap_selected_graphless_layer() -> void:
	var workspace = HexMapWorkspace.new()
	root.add_child(workspace)
	await process_frame
	var scene_root = Node2D.new()
	root.add_child(scene_root)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "GraphlessBuildLayer"
	scene_root.add_child(selected_layer)
	await process_frame
	workspace.set_selected_hex_tile_map_node(selected_layer, "test.graph12a.select_graphless")

	var result = workspace.ensure_build_graph_context("test.graph12a.bootstrap_graphless")
	_assert_true(bool(result["ok"]), "GRAPH-12A bootstraps a selected graph-less HexTileMapLayer")
	_assert_true(not bool(result["created_layer"]), "GRAPH-12A does not create a second layer when one is selected")
	_assert_true(bool(result["created_graph"]), "GRAPH-12A creates an embedded graph resource")
	_assert_true(bool(result["created_document"]), "GRAPH-12A creates a document context")
	_assert_true(selected_layer.generation_graph_resource is HexGenerationGraphResource, "GRAPH-12A selected layer owns graph resource")
	_assert_true(selected_layer.level_document_resource is HexMapDocumentResource, "GRAPH-12A selected layer owns document resource")
	_assert_eq(workspace.workspace_asset_context().level_document, selected_layer.level_document_resource, "GRAPH-12A workspace context follows selected document")
	_assert_eq(String(workspace.selected_hex_tile_map_snapshot()["generation_graph_status"]), "Linked", "GRAPH-12A selected snapshot exposes graph link")

	var snapshot = workspace.generation_screen_snapshot()
	_assert_true(bool(snapshot["build_context_ready"]), "GRAPH-12A Build snapshot records ready context")
	_assert_true(bool(snapshot["preview_available"]), "GRAPH-12A Build preview is available after bootstrap run")
	workspace.build_screen().graph_canvas().select_graph_node("weighted_items")
	var promote = workspace.build_screen().promote_selected_output("overlay")
	_assert_true(bool(promote["ok"]), "GRAPH-12A promoted output after bootstrap")
	_assert_true(selected_layer.level_document_resource.overlay_layers.size() > 0, "GRAPH-12A promoted overlay writes to selected document")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _test_build_graph_node_params_flush_to_embedded_resource() -> void:
	var workspace = HexMapWorkspace.new()
	root.add_child(workspace)
	await process_frame
	var scene_root = Node2D.new()
	root.add_child(scene_root)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "ParamFlushBuildLayer"
	scene_root.add_child(selected_layer)
	await process_frame
	workspace.set_selected_hex_tile_map_node(selected_layer, "test.repair13.param_flush")

	var result = workspace.ensure_build_graph_context("test.repair13.param_flush")
	_assert_true(bool(result["ok"]), "REPAIR-13 param flush creates build context")
	var screen = workspace.build_screen()
	var params := screen.graph_canvas().node_params("shape")
	params["width"] = 9
	params["height"] = 3
	screen._on_inspector_params_changed("shape", params)

	var resource = selected_layer.generation_graph_resource as HexGenerationGraphResource
	_assert_true(resource is HexGenerationGraphResource, "REPAIR-13 param flush keeps embedded graph resource")
	var model = resource.to_graph_model()
	var shape_node = ((model["nodes"] as Dictionary)["shape"] as Dictionary)
	var persisted_params = shape_node["params"] as Dictionary
	_assert_eq(int(persisted_params.get("width", 0)), 9, "REPAIR-13 Shape width flushes to graph resource before Generate")
	_assert_eq(int(persisted_params.get("height", 0)), 3, "REPAIR-13 Shape height flushes to graph resource before Generate")

	screen.graph_canvas().restore_graph_model(resource.to_graph_model(), "shape")
	var restored_params := screen.graph_canvas().node_params("shape")
	_assert_eq(int(restored_params.get("width", 0)), 9, "REPAIR-13 restored canvas keeps flushed Shape width")
	_assert_eq(int(restored_params.get("height", 0)), 3, "REPAIR-13 restored canvas keeps flushed Shape height")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _test_build_context_bootstrap_creates_layer_when_none_selected() -> void:
	var workspace = HexMapWorkspace.new()
	root.add_child(workspace)
	await process_frame

	var result = workspace.ensure_build_graph_context("test.graph12a.bootstrap_new_layer")
	_assert_true(bool(result["ok"]), "GRAPH-12A bootstraps Build with no selected layer")
	_assert_true(bool(result["created_layer"]), "GRAPH-12A creates a HexTileMapLayer when none is selected")
	var selected_snapshot = result["selected_snapshot"] as Dictionary
	var selected_layer = selected_snapshot["selected_node"] as HexTileMapLayer
	_assert_true(selected_layer is HexTileMapLayer, "GRAPH-12A result selects the new HexTileMapLayer")
	_assert_eq(workspace.editor_session_state().current_selected_hex_tile_map_layer(), selected_layer, "GRAPH-12A session tracks the new layer")
	_assert_true(selected_layer.generation_graph_resource is HexGenerationGraphResource, "GRAPH-12A new layer owns graph resource")
	_assert_true(selected_layer.level_document_resource is HexMapDocumentResource, "GRAPH-12A new layer owns document resource")
	_assert_true(bool((result["generation_snapshot"] as Dictionary)["preview_available"]), "GRAPH-12A new layer path runs graph preview")

	workspace.queue_free()
	await process_frame


func _test_build_context_bootstrap_preserves_existing_resources() -> void:
	var workspace = HexMapWorkspace.new()
	root.add_child(workspace)
	await process_frame
	var scene_root = Node2D.new()
	root.add_child(scene_root)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "ExistingBuildLayer"
	scene_root.add_child(selected_layer)
	await process_frame

	var existing_document = HexMapDocumentResource.new()
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame
	screen.build_vertical_slice_chain_and_preview()
	var existing_graph = HexGenerationGraphResource.new()
	existing_graph.graph_id = "existing_build_graph"
	existing_graph.graph_model = screen.graph_canvas().build_graph_model()
	screen.queue_free()
	await process_frame
	selected_layer.level_document_resource = existing_document
	selected_layer.generation_graph_resource = existing_graph
	workspace.set_selected_hex_tile_map_node(selected_layer, "test.graph12a.select_existing")

	var result = workspace.ensure_build_graph_context("test.graph12a.bootstrap_existing")
	_assert_true(bool(result["ok"]), "GRAPH-12A bootstraps existing graph resources")
	_assert_true(not bool(result["created_graph"]), "GRAPH-12A preserves existing graph resource")
	_assert_true(not bool(result["created_document"]), "GRAPH-12A preserves existing document resource")
	_assert_eq(selected_layer.generation_graph_resource, existing_graph, "GRAPH-12A graph resource reference is unchanged")
	_assert_eq(selected_layer.level_document_resource, existing_document, "GRAPH-12A document reference is unchanged")
	_assert_eq(String((result["restore_report"] as Dictionary)["selected_node_id"]), "weighted_items", "GRAPH-12A restores graph and selected output")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _test_top_generate_creates_layer_and_projects_viewport_preview() -> void:
	var workspace = HexMapWorkspace.new()
	root.add_child(workspace)
	await process_frame

	var button = workspace.build_screen().find_child("Build Generate Button", true, false) as Button
	_assert_true(button is Button, "Build top Generate button is mounted")
	button.emit_signal("pressed")
	_assert_top_generate_progress_visible(workspace, "Generate shows progress immediately on press")
	await process_frame
	_assert_top_generate_progress_visible(workspace, "Generate shows progress before context/graph preparation blocks the UI")
	await _wait_for_top_generate_preview(workspace, "Generate creates/selects a layer")

	var selected_layer = workspace.editor_session_state().current_selected_hex_tile_map_layer() as HexTileMapLayer
	_assert_true(selected_layer is HexTileMapLayer, "Generate creates/selects a Build HexTileMapLayer when none is selected")
	_assert_true(String(selected_layer.name).begins_with("BuildHexMapLayer"), "Generate-created layer uses BuildHexMapLayer naming")
	_assert_true(selected_layer.level_document_resource is HexMapDocumentResource, "Generate-created layer owns a Level Document")
	_assert_true(selected_layer.generation_graph_resource is HexGenerationGraphResource, "Generate-created layer owns an embedded graph")
	_assert_true(selected_layer.level_document_resource.overlay_layers.size() > 0, "Generate-created Result preview writes generated overlay to the document")
	_assert_true(selected_layer.display_used_cell_count() > 0, "Generate projects the result to the selected viewport layer")

	var snapshot = workspace.generation_screen_snapshot()
	_assert_top_generate_timing_phases(snapshot, "Generate records measured phase timings")
	_assert_true(bool(snapshot["viewport_preview_visible"]), "Generate snapshot records visible viewport preview")
	_assert_true(int(snapshot["viewport_preview_cell_count"]) > 0, "Generate snapshot records viewport display cell count")
	_assert_viewport_projection_ok(snapshot, "Generate creates a successful viewport projection report")
	_assert_eq(String(snapshot["preview_commit_state"]), "preview_pending", "Generate leaves preview pending Apply/Revert")
	_assert_true(String(snapshot["viewport_preview_layer_path"]).contains("BuildHexMapLayer"), "Generate snapshot records viewport layer path")
	_assert_true(bool(snapshot["node_thumbnail_secondary"]), "Generate marks node thumbnail as secondary proof only")

	var asset_recorder := SessionChangeRecorder.new()
	workspace.workspace_asset_context().asset_changed.connect(asset_recorder.record)
	button.emit_signal("pressed")
	_assert_top_generate_progress_visible(workspace, "Second Generate shows progress immediately on press")
	await process_frame
	_assert_top_generate_progress_visible(workspace, "Second Generate shows progress before context/graph preparation")
	await _wait_for_top_generate_preview(workspace, "Second Generate reuses current canvas")
	_assert_eq(asset_recorder.keys.size(), 0, "Second Generate does not reassign unchanged node-owned assets during context preparation")
	var second_snapshot = workspace.generation_screen_snapshot()
	var second_context = second_snapshot["build_context"] as Dictionary
	var second_restore = second_context.get("restore_report", {}) as Dictionary
	_assert_true(bool(second_restore.get("preserved_canvas", false)), "Second Generate preserves current canvas instead of restoring graph resource")
	_assert_true(bool(second_context.get("deferred_snapshots", false)), "Second Generate defers context snapshots until after popup is visible")
	var second_timings = second_snapshot.get("run_phase_timings", {}) as Dictionary
	_assert_true(second_timings.has("preview_cached_skip"), "Second Generate skips redundant preview apply when cached output is already pending")
	_assert_true(float(second_timings.get("preview_cached_skip", -1.0)) >= 0.0, "Second Generate cached preview skip timing is recorded")

	workspace.queue_free()
	await process_frame


func _test_top_generate_uses_selected_graphless_layer_for_viewport_preview() -> void:
	var workspace = HexMapWorkspace.new()
	root.add_child(workspace)
	await process_frame
	var scene_root = Node2D.new()
	root.add_child(scene_root)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "SelectedGraphlessTopGenerateLayer"
	scene_root.add_child(selected_layer)
	await process_frame
	workspace.set_selected_hex_tile_map_node(selected_layer, "test.top_generate.select_graphless")

	var button = workspace.build_screen().find_child("Build Generate Button", true, false) as Button
	_assert_true(button is Button, "Build top Generate button is mounted for selected layer")
	button.emit_signal("pressed")
	await process_frame
	_assert_top_generate_progress_visible(workspace, "Selected layer Generate shows progress before graph preparation")
	await _wait_for_top_generate_preview(workspace, "Selected layer Generate creates preview")

	_assert_eq(workspace.editor_session_state().current_selected_hex_tile_map_layer(), selected_layer, "Generate keeps the selected HexTileMapLayer as target")
	_assert_true(selected_layer.level_document_resource is HexMapDocumentResource, "Generate attaches a document to selected graphless layer")
	_assert_true(selected_layer.generation_graph_resource is HexGenerationGraphResource, "Generate attaches graph resource to selected graphless layer")
	_assert_true(selected_layer.level_document_resource.overlay_layers.size() > 0, "Selected layer Generate Result writes generated overlay to the document")
	_assert_true(selected_layer.display_used_cell_count() > 0, "Generate projects to the selected graphless layer viewport display")
	var snapshot = workspace.generation_screen_snapshot()
	_assert_top_generate_timing_phases(snapshot, "Selected layer Generate records measured phase timings")
	_assert_eq(String(snapshot["preview_commit_state"]), "preview_pending", "Selected layer Generate creates a pending preview")
	_assert_true(bool(snapshot["viewport_preview_visible"]), "Selected layer Generate records viewport preview visibility")
	_assert_viewport_projection_ok(snapshot, "Selected layer Generate creates a successful viewport projection report")
	_assert_true(String(snapshot["viewport_preview_layer_path"]).contains("SelectedGraphlessTopGenerateLayer"), "Selected layer path is recorded as preview target")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _test_top_generate_apply_revert_preview_contract() -> void:
	var workspace = HexMapWorkspace.new()
	root.add_child(workspace)
	await process_frame
	var scene_root = Node2D.new()
	root.add_child(scene_root)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "ApplyRevertTopGenerateLayer"
	var original_document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	selected_layer.level_document_resource = original_document
	scene_root.add_child(selected_layer)
	await process_frame
	selected_layer.ensure_display_tiles()
	selected_layer.apply_document(original_document)
	workspace.set_selected_hex_tile_map_node(selected_layer, "test.top_generate.apply_revert")
	var original_cells := int(HexMapDocumentAdapter.document_summary(original_document)["cells"])
	_assert_eq(original_cells, 1, "Apply/Revert fixture starts with one document cell")

	var generate_button = workspace.build_screen().find_child("Build Generate Button", true, false) as Button
	var apply_button = workspace.build_screen().find_child("Build Apply Button", true, false) as Button
	var revert_button = workspace.build_screen().find_child("Build Revert Button", true, false) as Button
	_assert_true(generate_button is Button, "Build top Generate button is mounted for Apply/Revert")
	_assert_true(apply_button is Button, "Build Apply button is mounted")
	_assert_true(revert_button is Button, "Build Revert button is mounted")

	generate_button.emit_signal("pressed")
	await process_frame
	_assert_top_generate_progress_visible(workspace, "Apply/Revert Generate shows progress before graph preparation")
	await _wait_for_top_generate_preview(workspace, "Apply/Revert Generate creates pending preview")
	var pending_snapshot = workspace.generation_screen_snapshot()
	_assert_top_generate_timing_phases(pending_snapshot, "Apply/Revert Generate records measured phase timings")
	_assert_eq(String(pending_snapshot["preview_commit_state"]), "preview_pending", "Generate enters preview pending state")
	_assert_true(bool(pending_snapshot["viewport_preview_visible"]), "Generate applies pending preview to viewport")
	_assert_viewport_projection_ok(pending_snapshot, "Apply/Revert Generate creates a successful viewport projection report")
	_assert_true(not apply_button.disabled, "Apply is enabled while preview is pending")
	_assert_true(not revert_button.disabled, "Revert is enabled while preview is pending")
	_assert_true(_generated_terrain_cell_count(selected_layer.level_document_resource) > original_cells, "Pending preview writes generated terrain into the in-memory document")

	revert_button.emit_signal("pressed")
	await process_frame
	var reverted_snapshot = workspace.generation_screen_snapshot()
	_assert_eq(String(reverted_snapshot["preview_commit_state"]), "reverted", "Revert records reverted state")
	_assert_eq(int(HexMapDocumentAdapter.document_summary(selected_layer.level_document_resource)["cells"]), original_cells, "Revert restores previous document cells")
	_assert_eq(selected_layer.display_used_cell_count(), original_cells, "Revert reapplies previous document to viewport")
	_assert_true(apply_button.disabled, "Apply disables after Revert")
	_assert_true(revert_button.disabled, "Revert disables after Revert")

	generate_button.emit_signal("pressed")
	await process_frame
	await _wait_for_top_generate_preview(workspace, "Apply path Generate recreates pending preview")
	apply_button.emit_signal("pressed")
	await process_frame
	var applied_snapshot = workspace.generation_screen_snapshot()
	_assert_eq(String(applied_snapshot["preview_commit_state"]), "applied", "Apply records applied state")
	_assert_true(bool(applied_snapshot["viewport_preview_visible"]), "Apply keeps the generated result visible in viewport")
	_assert_viewport_projection_ok(applied_snapshot, "Apply keeps a successful viewport projection report")
	_assert_true(apply_button.disabled, "Apply disables after commit")
	_assert_true(revert_button.disabled, "Revert disables after commit")
	_assert_true(_generated_terrain_cell_count(selected_layer.level_document_resource) > original_cells, "Apply keeps generated document cells")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _test_result_preview_promotes_multiple_overlays_as_separate_layers() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame
	var scene_root = Node2D.new()
	root.add_child(scene_root)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "MultiOverlayResultPreviewLayer"
	scene_root.add_child(selected_layer)
	await process_frame
	screen.ensure_graph_context_for_hex_tile_map_layer(selected_layer, {"run": false})
	screen.graph_canvas().restore_graph_model(_two_overlay_result_graph(), "result")
	var run_report = screen.run_graph()
	_assert_true(bool(run_report["ok"]), "REPAIR-11 multi-overlay Result graph runs in Build screen")
	screen._auto_preview_after_generate()
	await process_frame

	var snapshot = screen.build_screen_snapshot()
	var promote_result = snapshot["promote_result"] as Dictionary
	_assert_true(bool(promote_result["ok"]), "REPAIR-11 Result preview promote succeeds")
	_assert_eq(int(promote_result["overlay_count"]), 2, "REPAIR-11 Result preview reports two overlays")
	_assert_eq(promote_result["overlay_layer_ids"], ["generated_overlay_0", "generated_overlay_1"], "REPAIR-11 Result preview records generated overlay layer ids")
	var generated_layers = _generated_overlay_layers(selected_layer.level_document_resource)
	_assert_eq(generated_layers.size(), 2, "REPAIR-11 Result preview creates two generated overlay document layers")
	_assert_eq(String(generated_layers[0].layer_id), "generated_overlay_0", "REPAIR-11 first generated overlay layer id is deterministic")
	_assert_eq(String(generated_layers[1].layer_id), "generated_overlay_1", "REPAIR-11 second generated overlay layer id is deterministic")
	_assert_eq(String((generated_layers[0].metadata as Dictionary).get("result_port", "")), "overlay_0", "REPAIR-11 first generated overlay records source port")
	_assert_eq(String((generated_layers[1].metadata as Dictionary).get("result_port", "")), "overlay_1", "REPAIR-11 second generated overlay records source port")
	_assert_viewport_projection_ok(snapshot, "REPAIR-11 multi-overlay Result preview projects to viewport")
	var viewport_report = snapshot["viewport_apply_report"] as Dictionary
	_assert_eq(int(viewport_report.get("result_overlay_count", 0)), 2, "REPAIR-11 viewport report includes Result overlay count")
	_assert_eq(viewport_report.get("result_overlay_layer_ids", []), ["generated_overlay_0", "generated_overlay_1"], "REPAIR-11 viewport report includes Result overlay layer ids")

	var apply_button = screen.find_child("Build Apply Button", true, false) as Button
	var revert_button = screen.find_child("Build Revert Button", true, false) as Button
	_assert_true(apply_button is Button and not apply_button.disabled, "REPAIR-11 Apply is enabled for multi-overlay preview")
	_assert_true(revert_button is Button and not revert_button.disabled, "REPAIR-11 Revert is enabled for multi-overlay preview")
	revert_button.emit_signal("pressed")
	await process_frame
	_assert_eq(String(screen.build_screen_snapshot()["preview_commit_state"]), "reverted", "REPAIR-11 Revert records reverted state for multi-overlay preview")
	_assert_eq(_generated_overlay_layers(selected_layer.level_document_resource).size(), 0, "REPAIR-11 Revert removes generated overlay preview layers")

	screen._auto_preview_after_generate()
	await process_frame
	apply_button.emit_signal("pressed")
	await process_frame
	snapshot = screen.build_screen_snapshot()
	_assert_eq(String(snapshot["preview_commit_state"]), "applied", "REPAIR-11 Apply records applied state for multi-overlay preview")
	_assert_eq(_generated_overlay_layers(selected_layer.level_document_resource).size(), 2, "REPAIR-11 Apply keeps both generated overlay layers")

	scene_root.queue_free()
	screen.queue_free()
	await process_frame


func _test_result_row_promote_writes_document_layers() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame
	var scene_root = Node2D.new()
	root.add_child(scene_root)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "ResultRowPromoteLayer"
	scene_root.add_child(selected_layer)
	await process_frame
	screen.ensure_graph_context_for_hex_tile_map_layer(selected_layer, {"run": false})
	screen.graph_canvas().restore_graph_model(_two_overlay_result_graph(), "result")
	var run_report = screen.run_graph()
	_assert_true(bool(run_report["ok"]), "GQM-12 Result row promote graph runs")

	var terrain_promote = screen.promote_result_row("result", "terrain")
	_assert_true(bool(terrain_promote["ok"]), "GQM-12 substrate row promotes to terrain layer")
	var terrain_layers = _generated_terrain_layers(selected_layer.level_document_resource)
	_assert_eq(terrain_layers.size(), 1, "GQM-12 substrate row writes one generated terrain layer")
	_assert_eq(String((terrain_layers[0].metadata as Dictionary).get("result_port", "")), "terrain", "GQM-12 terrain row metadata records source port")

	var overlay_promote = screen.promote_result_row("result", "overlay_1")
	_assert_true(bool(overlay_promote["ok"]), "GQM-12 overlay row promotes to overlay layer")
	var generated_layers = _generated_overlay_layers(selected_layer.level_document_resource)
	_assert_eq(generated_layers.size(), 1, "GQM-12 single row promote writes one generated overlay layer")
	_assert_eq(String(generated_layers[0].layer_id), "generated_overlay_1", "GQM-12 row promote uses overlay index layer id")
	_assert_eq(String((generated_layers[0].metadata as Dictionary).get("result_port", "")), "overlay_1", "GQM-12 overlay row metadata records source port")
	_assert_true(generated_layers[0].overlay.to_overlay_data().item_cells("loot").size() > 0, "GQM-12 promoted row keeps selected overlay data")

	overlay_promote = screen.promote_result_row("result", "overlay_1")
	_assert_true(bool(overlay_promote["ok"]), "GQM-12 repeated row promote succeeds")
	_assert_eq(_generated_overlay_layers(selected_layer.level_document_resource).size(), 1, "GQM-12 repeated row promote replaces the same generated row layer")

	scene_root.queue_free()
	screen.queue_free()
	await process_frame


func _policy_result_graph(write_policy: String) -> Dictionary:
	var graph = HexGenerationGraph.new_graph()
	var cells := [HexVector.zero(), HexVector.q_axis()]
	var base_overlay = HexOverlayData.from_cells(cells, {
		"Treasure": [HexVector.zero()],
	})
	var incoming_overlay = HexOverlayData.from_cells(cells, {
		"Shop": [HexVector.zero(), HexVector.q_axis()],
	})
	HexGenerationGraph.add_node(graph, "base_overlay", "source", {
		"kind": "provided",
		"output_type": "overlay",
		"data": base_overlay,
	})
	HexGenerationGraph.add_node(graph, "incoming_overlay", "source", {
		"kind": "provided",
		"output_type": "overlay",
		"data": incoming_overlay,
	})
	HexGenerationGraph.add_node(graph, "result", "result")
	HexGenerationGraph.add_edge(graph, "base_overlay", "result", "overlay_0")
	var incoming_edge = HexGenerationGraph.add_edge(graph, "incoming_overlay", "result", "overlay_1")
	incoming_edge["write_policy"] = write_policy
	return graph


func _two_overlay_result_graph() -> Dictionary:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle",
		"width": 4,
		"height": 3,
	})
	HexGenerationGraph.add_node(graph, "filter", "region_filter", {"filter_target": "floor"})
	HexGenerationGraph.add_node(graph, "items_spawn", "item_generator", {
		"placement_method": "weighted",
		"placement_probability": 1.0,
		"item_pool": [{"name": "spawn", "weight": 1.0}],
	})
	HexGenerationGraph.add_node(graph, "items_loot", "item_generator", {
		"placement_method": "weighted",
		"placement_probability": 1.0,
		"item_pool": [{"name": "loot", "weight": 1.0}],
	})
	HexGenerationGraph.add_node(graph, "result", "result")
	HexGenerationGraph.add_edge(graph, "shape", "filter", "in")
	HexGenerationGraph.add_edge(graph, "filter", "items_spawn", "scope")
	HexGenerationGraph.add_edge(graph, "filter", "items_loot", "scope")
	HexGenerationGraph.add_edge(graph, "shape", "result", "terrain")
	HexGenerationGraph.add_edge(graph, "items_spawn", "result", "overlay_0")
	HexGenerationGraph.add_edge(graph, "items_loot", "result", "overlay_1")
	return graph


func _assert_top_generate_progress_visible(workspace: HexMapWorkspace, message: String) -> void:
	var snapshot = workspace.generation_screen_snapshot()
	_assert_true(bool(snapshot["run_progress_popup_visible"]), message)
	_assert_true(
		String(snapshot["run_progress_popup_status"]) in ["Preparing context", "Preparing graph", "Generating"],
		"%s: progress popup reports pre-run or running status" % message
	)


func _wait_for_top_generate_preview(workspace: HexMapWorkspace, message: String) -> void:
	var guard := 0
	var snapshot = workspace.generation_screen_snapshot()
	while (String(snapshot["preview_commit_state"]) != "preview_pending" or bool(snapshot.get("run_busy", false))) and guard < 240:
		await process_frame
		snapshot = workspace.generation_screen_snapshot()
		guard += 1
	_assert_eq(String(snapshot["preview_commit_state"]), "preview_pending", "%s reaches preview pending state" % message)
	_assert_true(not bool(snapshot.get("run_busy", false)), "%s completes the active Generate run" % message)


func _assert_top_generate_timing_phases(snapshot: Dictionary, message: String) -> void:
	var timings = snapshot.get("run_phase_timings", {}) as Dictionary
	for phase in [
		"context_prepare",
		"popup_present",
		"graph_prepare",
		"graph_run",
		"preview_promote",
		"viewport_prepare_document",
		"viewport_apply_map",
	]:
		_assert_true(timings.has(phase), "%s: timing includes %s" % [message, phase])
		_assert_true(float(timings.get(phase, -1.0)) >= 0.0, "%s: timing %s is non-negative" % [message, phase])


func _generated_terrain_cell_count(document: HexMapDocumentResource) -> int:
	if document == null:
		return 0
	var total := 0
	for layer in document.terrain_layers:
		if layer == null:
			continue
		var metadata = layer.get("metadata")
		if not metadata is Dictionary or String((metadata as Dictionary).get("writable_source", "")) != "generated":
			continue
		var map = layer.get("map")
		if map != null and map.has_method("to_map_data"):
			var data = map.to_map_data()
			if data != null:
				total += data.cells.size()
	return total


func _generated_terrain_layers(document: HexMapDocumentResource) -> Array:
	var result: Array = []
	if document == null:
		return result
	for layer in document.terrain_layers:
		if layer == null:
			continue
		var metadata = layer.get("metadata")
		if metadata is Dictionary and String((metadata as Dictionary).get("writable_source", "")) == "generated":
			result.append(layer)
	return result


func _stack_items_at(result_resource, cell: HexVector) -> Array:
	if result_resource == null:
		return []
	var metadata = result_resource.get("metadata")
	if not metadata is Dictionary:
		return []
	var cells = (metadata as Dictionary).get("overlay_stack_cells", []) as Array
	var cell_key := cell.key()
	for entry in cells:
		var entry_dict := entry as Dictionary
		if String(entry_dict.get("cell_key", "")) == cell_key:
			return (entry_dict.get("items", []) as Array).duplicate()
	return []


func _generated_overlay_layers(document: HexMapDocumentResource) -> Array:
	var result: Array = []
	if document == null:
		return result
	for layer in document.overlay_layers:
		if layer == null:
			continue
		var metadata = layer.get("metadata")
		if metadata is Dictionary and String((metadata as Dictionary).get("writable_source", "")) == "generated":
			result.append(layer)
	return result


func _rows_by_input(rows: Array) -> Dictionary:
	var result := {}
	for row in rows:
		var row_dict := row as Dictionary
		result[String(row_dict.get("input", ""))] = row_dict
	return result


func _assert_viewport_projection_ok(snapshot: Dictionary, message: String) -> void:
	var report := snapshot.get("viewport_apply_report", {}) as Dictionary
	_assert_true(bool(report.get("projection_ok", false)), message)
	_assert_true(bool(report.get("layer_inside_tree", false)), "%s: target layer is inside tree" % message)
	_assert_true(bool(report.get("display_tiles_ready", false)), "%s: display tiles are ready" % message)
	_assert_true(int(report.get("display_tile_source_count", 0)) > 0, "%s: tile source exists" % message)
	_assert_true(int(report.get("display_used_cell_count", 0)) > 0, "%s: display cells exist" % message)
