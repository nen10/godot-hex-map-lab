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
	await _test_build_screen_vertical_slice_promotes_overlay()
	await _test_build_context_bootstrap_selected_graphless_layer()
	await _test_build_context_bootstrap_creates_layer_when_none_selected()
	await _test_build_context_bootstrap_preserves_existing_resources()
	_finish("res://tests/test_generation_promote.gd")


func _test_region_filter_limits_floor_by_spawn_distance() -> void:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle",
		"width": 6,
		"height": 4,
	})
	HexGenerationGraph.add_node(graph, "spawn_floor", "region_filter", {
		"mode": "floor",
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


func _test_build_screen_vertical_slice_promotes_overlay() -> void:
	var context = HexMapWorkspaceAssetContext.new()
	context.set_level_document(HexMapDocumentResource.new())
	var screen = HexMapBuildScreen.new()
	screen.set_workspace_asset_context(context)
	root.add_child(screen)
	await process_frame

	var report = screen.build_vertical_slice_chain_and_preview()
	_assert_true(bool(report["ok"]), "GRAPH-12 Build screen runs Shape->Wall->Connectivity->Filter->Item")
	var snapshot = screen.build_screen_snapshot()
	_assert_true(bool(snapshot["preview_available"]), "GRAPH-12 item output preview is available before promote")
	_assert_true(bool(snapshot["promote_available"]), "GRAPH-12 promote is available for selected generated output")
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
	var promote = workspace.build_screen().promote_selected_output("overlay")
	_assert_true(bool(promote["ok"]), "GRAPH-12A promoted output after bootstrap")
	_assert_true(selected_layer.level_document_resource.overlay_layers.size() > 0, "GRAPH-12A promoted overlay writes to selected document")

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
