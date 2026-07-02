extends "res://tests/test_editor_plugin_test_base.gd"

const HexGenerationGraph = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexGenerationGraphRunner = preload("res://addons/hex_map_kit/generation/hex_generation_graph_runner.gd")
const HexGenerationNodeTypes = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await _test_build_screen_graph_asset_operations_replace_load_graph_controls()
	await _test_legacy_sample_graph_load_normalizes_canvas_and_preserves_output()
	await _test_load_graph_default_creates_new_selected_layer_with_embed_copy()
	await _test_load_graph_overwrite_preserves_manual_layers()
	await _test_load_graph_path_uses_same_context_owner_path()
	_finish("res://tests/test_graph_load_context.gd")


func _test_build_screen_graph_asset_operations_replace_load_graph_controls() -> void:
	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	var snapshot = screen.build_screen_snapshot()
	_assert_true(bool(snapshot["template_dropdown_present"]), "GQM-13 Build screen exposes Template dropdown")
	_assert_true(bool(snapshot["load_button_present"]), "GQM-13 Build screen exposes graph asset Load action")
	_assert_true(bool(snapshot["save_as_button_present"]), "GQM-13 Build screen exposes graph asset Save as action")
	_assert_true(not bool(snapshot["load_graph_button_present"]), "GQM-13 old Load Graph action is removed")
	_assert_true(not bool(snapshot["overwrite_selected_graph_check_present"]), "GQM-13 old overwrite opt-in is removed")
	_assert_true(not bool(snapshot["overwrite_selected_graph"]), "GQM-13 overwrite selected no longer has header state")

	screen.queue_free()
	await process_frame


func _test_legacy_sample_graph_load_normalizes_canvas_and_preserves_output() -> void:
	var legacy_graph := _legacy_sample_graph()
	var graph_resource := HexGenerationGraphResource.from_dict(legacy_graph)
	graph_resource.graph_id = "gqm15_legacy_sample_graph"
	graph_resource.ownership_semantics = "embed"
	graph_resource.semantics_snapshot = {"embed": true}
	graph_resource.promote_targets = [{"node_id": "result", "role": "result"}]

	var screen = HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	var load_result := screen.load_graph_resource(graph_resource, {"run": true})
	_assert_true(bool(load_result.get("ok", false)), "GQM-15 legacy graph resource loads")
	var normalization_report := load_result.get("normalization_report", {}) as Dictionary
	_assert_true(bool(normalization_report.get("normalized", false)), "GQM-15 load report records legacy normalization")
	_assert_eq(int(normalization_report.get("before_node_count", 0)), 6, "GQM-15 load report records legacy node count")
	_assert_eq(int(normalization_report.get("after_node_count", 0)), 3, "GQM-15 load report records consolidated node count")
	_assert_true(String(load_result.get("status_text", "")).contains("normalized"), "GQM-15 load status mentions normalization")
	_assert_true(String(screen.build_screen_snapshot().get("status_text", "")).contains("normalized"), "GQM-15 visible Build status mentions normalization")

	var canvas_graph := screen.graph_canvas().build_graph_model()
	_assert_true(_all_nodes_are_consolidated(canvas_graph), "GQM-15 loaded canvas contains only consolidated node types")

	var legacy_report := HexGenerationGraphRunner.run_with_report(legacy_graph)
	var loaded_report := load_result.get("run_report", {}) as Dictionary
	_assert_true(bool(legacy_report.get("ok", false)), "GQM-15 direct legacy sample graph runs")
	_assert_true(bool(loaded_report.get("ok", false)), "GQM-15 normalized loaded graph runs")
	if bool(legacy_report.get("ok", false)) and bool(loaded_report.get("ok", false)):
		_assert_eq(
			_result_signature((loaded_report["cache"] as Dictionary).get("result", null)),
			_result_signature((legacy_report["cache"] as Dictionary).get("result", null)),
			"GQM-15 loaded normalized output matches direct legacy output"
		)

	screen.queue_free()
	await process_frame


func _test_load_graph_default_creates_new_selected_layer_with_embed_copy() -> void:
	var workspace = HexMapWorkspace.new()
	root.add_child(workspace)
	await process_frame
	var scene_root = Node2D.new()
	root.add_child(scene_root)
	var existing_layer = HexTileMapLayer.new()
	existing_layer.name = "ExistingRuntime51Layer"
	var existing_document = _document_with_manual_and_generated("old")
	existing_layer.level_document_resource = existing_document
	scene_root.add_child(existing_layer)
	await process_frame
	workspace.set_selected_hex_tile_map_node(existing_layer, "test.runtime51.select_existing")

	var embedded_document = _document_with_manual_and_generated("loaded")
	var graph_resource = _graph_resource_with_semantics(embedded_document)
	var result = workspace.load_generation_graph_resource(graph_resource, false, "test.runtime51.default_load")
	var loaded_layer = result["layer"] as HexTileMapLayer
	_assert_true(bool(result["ok"]), "RUNTIME-51 default graph load succeeds")
	_assert_true(bool(result["created_layer"]), "RUNTIME-51 default graph load creates a new layer")
	_assert_true(loaded_layer != existing_layer, "RUNTIME-51 default graph load does not overwrite selected layer")
	_assert_eq(workspace.editor_session_state().current_selected_hex_tile_map_layer(), loaded_layer, "RUNTIME-51 new graph layer becomes selected context owner")
	_assert_true(loaded_layer.generation_graph_resource != graph_resource, "RUNTIME-51 default graph load copies graph resource for embed ownership")
	_assert_eq(String(loaded_layer.generation_graph_resource.ownership_semantics), "embed", "RUNTIME-51 default graph copy uses embed semantics")
	_assert_eq(String(loaded_layer.generation_graph_resource.semantics_reference_path), "", "RUNTIME-51 default graph copy removes reference path")
	_assert_true(loaded_layer.level_document_resource != embedded_document, "RUNTIME-51 embedded document is duplicated for the new node")
	_assert_eq(existing_layer.level_document_resource, existing_document, "RUNTIME-51 default graph load keeps existing layer document")
	_assert_eq(existing_layer.generation_graph_resource, null, "RUNTIME-51 default graph load keeps existing layer graph reference unchanged")
	_assert_true(bool((result["screen_load_result"] as Dictionary)["ok"]), "RUNTIME-51 Build screen restores loaded graph")
	_assert_true(bool(result["single_context_owner"]), "RUNTIME-51 default load reports single context owner")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _test_load_graph_overwrite_preserves_manual_layers() -> void:
	var workspace = HexMapWorkspace.new()
	root.add_child(workspace)
	await process_frame
	var scene_root = Node2D.new()
	root.add_child(scene_root)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "OverwriteRuntime51Layer"
	var existing_document = _document_with_manual_and_generated("old")
	selected_layer.level_document_resource = existing_document
	scene_root.add_child(selected_layer)
	await process_frame
	workspace.set_selected_hex_tile_map_node(selected_layer, "test.runtime51.select_overwrite")

	var graph_resource = _graph_resource_with_semantics(_document_with_manual_and_generated("new"))
	graph_resource.ownership_semantics = "reference"
	graph_resource.semantics_reference_path = "res://graph_context_reference.tres"
	var result = workspace.load_generation_graph_resource(graph_resource, true, "test.runtime51.overwrite")
	_assert_true(bool(result["ok"]), "RUNTIME-51 overwrite graph load succeeds")
	_assert_true(not bool(result["created_layer"]), "RUNTIME-51 overwrite does not create a new layer")
	_assert_true(bool(result["overwrote_selected"]), "RUNTIME-51 overwrite reports selected layer overwrite")
	_assert_eq(workspace.editor_session_state().current_selected_hex_tile_map_layer(), selected_layer, "RUNTIME-51 overwrite keeps selected node as context owner")
	_assert_eq(selected_layer.generation_graph_resource, graph_resource, "RUNTIME-51 overwrite uses reference graph resource")
	_assert_eq(_manual_overlay_count(existing_document), 1, "RUNTIME-51 overwrite preserves manual overlay layer")
	_assert_true(_has_generated_overlay(existing_document, "generated_overlay_new"), "RUNTIME-51 overwrite replaces generated overlay layer from graph semantics")
	_assert_true(not _has_generated_overlay(existing_document, "generated_overlay_old"), "RUNTIME-51 overwrite removes previous generated overlay layer")
	_assert_true(bool((result["merge_report"] as Dictionary).get("preserved_manual", false)), "RUNTIME-51 overwrite merge reports manual preservation")
	_assert_true(bool(result["single_context_owner"]), "RUNTIME-51 overwrite reports single context owner")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _test_load_graph_path_uses_same_context_owner_path() -> void:
	var workspace = HexMapWorkspace.new()
	root.add_child(workspace)
	await process_frame

	var graph_resource = _graph_resource_with_semantics(null)
	var path := _test_resource_path("runtime51_graph_resource.tres")
	_assert_eq(ResourceSaver.save(graph_resource, path), OK, "RUNTIME-51 graph resource saves for load path")
	var result = workspace.load_generation_graph_path(path, false, "test.runtime51.load_path")
	_assert_true(bool(result["ok"]), "RUNTIME-51 graph load path succeeds")
	_assert_true(bool(result["created_layer"]), "RUNTIME-51 graph load path creates a selected layer")
	_assert_eq(workspace.editor_session_state().current_selected_hex_tile_map_layer(), result["layer"], "RUNTIME-51 graph load path selects the new context owner")

	workspace.queue_free()
	await process_frame


func _graph_resource_with_semantics(document: HexMapDocumentResource) -> HexGenerationGraphResource:
	var graph := HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle",
		"width": 5,
		"height": 4,
	})
	HexGenerationGraph.add_node(graph, "walls", "wall_field", {
		"wall_probability": 0.2,
	})
	HexGenerationGraph.add_edge(graph, "shape", "walls", "in")
	var graph_resource := HexGenerationGraphResource.from_dict(graph)
	graph_resource.graph_id = "runtime51_loaded_graph"
	graph_resource.ownership_semantics = "embed"
	graph_resource.promote_targets = [{"node_id": "walls", "role": "terrain"}]
	graph_resource.semantics_snapshot = {"embed": true}
	if document != null:
		graph_resource.semantics_snapshot["document"] = document
	graph_resource.semantics_snapshot["layer_stack"] = HexLayerStackResource.standard_template()
	return graph_resource


func _legacy_sample_graph() -> Dictionary:
	var graph := HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle",
		"width": 5,
		"height": 4,
	})
	HexGenerationGraph.add_node(graph, "walls", "wall_field", {
		"wall_method": "random_probability",
		"wall_probability": 0.0,
		"seed": 17,
	})
	HexGenerationGraph.add_node(graph, "connect", "connectivity", {
		"method": "dense",
		"seed": 23,
	})
	HexGenerationGraph.add_node(graph, "floor_filter", "terrain_filter", {
		"filter_target": "floor",
	})
	HexGenerationGraph.add_node(graph, "items", "item_generator", {
		"placement_method": "weighted",
		"placement_probability": 1.0,
		"seed": 29,
		"item_pool": [{"name": "gem", "weight": 1.0}],
	})
	HexGenerationGraph.add_node(graph, "result", "result")
	HexGenerationGraph.add_edge(graph, "shape", "walls", "in")
	HexGenerationGraph.add_edge(graph, "walls", "connect", "in")
	HexGenerationGraph.add_edge(graph, "connect", "floor_filter", "in")
	HexGenerationGraph.add_edge(graph, "floor_filter", "items", "scope")
	HexGenerationGraph.add_edge(graph, "connect", "result", "terrain")
	HexGenerationGraph.add_edge(graph, "items", "result", "overlay_0")
	return graph


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
	var overlay_parts: Array = []
	for overlay_resource in result_resource.overlay_maps:
		if overlay_resource == null:
			continue
		var overlay_data = overlay_resource.to_overlay_data()
		var item_parts: Array = []
		for item_key in overlay_data.item_keys():
			item_parts.append("%s=%s" % [String(item_key), str(HexMapData.sorted_keys(overlay_data.item_cells(String(item_key))))])
		overlay_parts.append("%s|%s" % [str(HexMapData.sorted_keys(overlay_data.cells)), ";".join(item_parts)])
	return "%s|%s" % [
		_map_signature(result_resource.primary_map.to_map_data()),
		"||".join(overlay_parts),
	]


func _map_signature(data) -> String:
	if not data is HexMapData:
		return "<missing-map>"
	return "%s|%s|%d" % [
		str(HexMapData.sorted_keys(data.cells)),
		str(HexMapData.sorted_keys(data.walls)),
		int(data.cyclic_size),
	]


func _document_with_manual_and_generated(suffix: String) -> HexMapDocumentResource:
	var document = HexMapDocumentResource.new()
	var manual = HexMapDocumentOverlayLayerResource.new()
	manual.layer_id = "manual_overlay"
	manual.display_name = "Manual Overlay"
	manual.metadata = {"writable_source": "document"}
	document.overlay_layers.append(manual)

	var generated = HexMapDocumentOverlayLayerResource.new()
	generated.layer_id = "generated_overlay_%s" % suffix
	generated.display_name = "Generated Overlay %s" % suffix
	generated.metadata = {
		"source": "generation_graph",
		"target_role": "overlay",
		"writable_source": "generated",
	}
	generated.overlay = HexOverlayResource.from_overlay_data(
		HexOverlayData.from_item_cells(
			[HexVector.zero()],
			"spawn_%s" % suffix,
			[HexVector.zero()]
		)
	)
	document.overlay_layers.append(generated)
	return document


func _manual_overlay_count(document: HexMapDocumentResource) -> int:
	var count := 0
	for layer in document.overlay_layers:
		if not layer is Resource:
			continue
		var metadata = layer.get("metadata")
		if metadata is Dictionary and String((metadata as Dictionary).get("writable_source", "")) == "document":
			count += 1
	return count


func _has_generated_overlay(document: HexMapDocumentResource, layer_id: String) -> bool:
	for layer in document.overlay_layers:
		if not layer is Resource:
			continue
		var metadata = layer.get("metadata")
		if not metadata is Dictionary:
			continue
		if String(layer.get("layer_id")) == layer_id \
				and String((metadata as Dictionary).get("writable_source", "")) == "generated":
			return true
	return false
