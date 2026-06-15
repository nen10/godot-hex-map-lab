extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexRandomizer = preload("res://addons/hex_map_kit/core/hex_randomizer.gd")
const HexDistribution = preload("res://addons/hex_map_kit/adapter/hex_distribution.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexOverlayData = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexOverlayResource = preload("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapDocumentDependencyService = preload("res://addons/hex_map_kit/adapter/hex_map_document_dependency_service.gd")
const HexMapDocumentValidator = preload("res://addons/hex_map_kit/adapter/hex_map_document_validator.gd")
const HexMapDocumentLabelPlacementResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_label_placement_resource.gd")
const HexMapDocumentObjectPlacementResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_object_placement_resource.gd")
const HexMapDocumentOverlayLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_overlay_layer_resource.gd")
const HexMapDocumentTerrainLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_terrain_layer_resource.gd")
const HexMapValidationResult = preload("res://addons/hex_map_kit/adapter/hex_map_validation_result.gd")
const HexLayerStackResource = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd")
const HexObjectDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_object_database_resource.gd")
const HexObjectDefinitionResource = preload("res://addons/hex_map_kit/adapter/hex_object_definition_resource.gd")
const HexGenerationProfileResource = preload("res://addons/hex_map_kit/adapter/hex_generation_profile_resource.gd")
const HexGenerationResultResource = preload("res://addons/hex_map_kit/adapter/hex_generation_result_resource.gd")
const HexLabelDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_label_database_resource.gd")
const HexLabelDefinitionResource = preload("res://addons/hex_map_kit/adapter/hex_label_definition_resource.gd")
const HexMovementProfileResource = preload("res://addons/hex_map_kit/adapter/hex_movement_profile_resource.gd")
const HexExportProfileResource = preload("res://addons/hex_map_kit/adapter/hex_export_profile_resource.gd")
const HexMapGenDock = preload("res://addons/hex_map_kit/editor/hex_map_gen_dock.gd")
const HexMapGenStateEvaluator = preload("res://addons/hex_map_kit/editor/hex_map_gen_state_evaluator.gd")
const HexMapGenerationRunState = preload("res://addons/hex_map_kit/editor/hex_map_generation_run_state.gd")
const HexMapGenRunControls = preload("res://addons/hex_map_kit/editor/hex_map_gen_run_controls.gd")
const HexMapGenSourceControls = preload("res://addons/hex_map_kit/editor/hex_map_gen_source_controls.gd")
const HexMapGenOutputControls = preload("res://addons/hex_map_kit/editor/hex_map_gen_output_controls.gd")
const HexMapGenResultControls = preload("res://addons/hex_map_kit/editor/hex_map_gen_result_controls.gd")
const HexMapPreviewThumbnail = preload("res://addons/hex_map_kit/editor/hex_map_preview_thumbnail.gd")
const HexMapEditTool = preload("res://addons/hex_map_kit/editor/hex_map_edit_tool.gd")
const HexMapEditMutationBuilder = preload("res://addons/hex_map_kit/editor/hex_map_edit_mutation_builder.gd")
const HexMapEditViewportInputAdapter = preload("res://addons/hex_map_kit/editor/hex_map_edit_viewport_input_adapter.gd")
const HexMapPaintInteractionState = preload("res://addons/hex_map_kit/editor/hex_map_paint_interaction_state.gd")
const HexMapDocumentInspector = preload("res://addons/hex_map_kit/editor/hex_map_document_inspector.gd")
const HexMapEditorSessionState = preload("res://addons/hex_map_kit/editor/hex_map_editor_session_state.gd")
const HexMapEditorAssetSlotState = preload("res://addons/hex_map_kit/editor/hex_map_editor_asset_slot_state.gd")
const HexMapEditorAssetSlotControl = preload("res://addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd")
const HexMapEditorPathSelector = preload("res://addons/hex_map_kit/editor/hex_map_editor_path_selector.gd")
const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")
const HexMapWorkspaceAssetResourceFactory = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_resource_factory.gd")
const HexMapWorkspaceBindingService = preload("res://addons/hex_map_kit/editor/hex_map_workspace_binding_service.gd")
const HexMapValidationWorkflowState = preload("res://addons/hex_map_kit/editor/hex_map_validation_workflow_state.gd")
const HexMapExportWorkflowState = preload("res://addons/hex_map_kit/editor/hex_map_export_workflow_state.gd")
const HexMapSampleLearningState = preload("res://addons/hex_map_kit/editor/hex_map_sample_learning_state.gd")
const HexMapDialogLifecycleState = preload("res://addons/hex_map_kit/editor/hex_map_dialog_lifecycle_state.gd")
const HexMapWorkspaceRootState = preload("res://addons/hex_map_kit/editor/hex_map_workspace_root_state.gd")
const HexMapWorkspaceDispatcher = preload("res://addons/hex_map_kit/editor/hex_map_workspace_dispatcher.gd")
const HexMapSampleAssetDuplicator = preload("res://addons/hex_map_kit/editor/hex_map_sample_asset_duplicator.gd")
const HexMapSampleSettingsPanel = preload("res://addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd")
const HexMapResourcesScreen = preload("res://addons/hex_map_kit/editor/hex_map_resources_screen.gd")
const HexMapCatalogScreen = preload("res://addons/hex_map_kit/editor/hex_map_catalog_screen.gd")
const HexMapCatalogEditorComponent = preload("res://addons/hex_map_kit/editor/hex_map_catalog_editor_component.gd")
const HexTileCatalogPreviewControl = preload("res://addons/hex_map_kit/editor/hex_tile_catalog_preview_control.gd")
const HexMapLayersScreen = preload("res://addons/hex_map_kit/editor/hex_map_layers_screen.gd")
const HexMapValidateScreen = preload("res://addons/hex_map_kit/editor/hex_map_validate_screen.gd")
const HexMapQAScreen = preload("res://addons/hex_map_kit/editor/hex_map_qa_screen.gd")
const HexMapExportScreen = preload("res://addons/hex_map_kit/editor/hex_map_export_screen.gd")
const HexMapSettingsScreen = preload("res://addons/hex_map_kit/editor/hex_map_settings_screen.gd")
const HexMapBuildScreen = preload("res://addons/hex_map_kit/editor/hex_map_build_screen.gd")
const HexMapBuildGraphCanvas = preload("res://addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd")
const HexMapBuildNodeInspector = preload("res://addons/hex_map_kit/editor/hex_map_build_node_inspector.gd")
const HexMapBuildNodePalette = preload("res://addons/hex_map_kit/editor/hex_map_build_node_palette.gd")
const HexMapWorkspace = preload("res://addons/hex_map_kit/editor/hex_map_workspace.gd")
const HexDistEditor = preload("res://addons/hex_map_kit/editor/hex_dist_editor.gd")
const HexAdjacencyRuleEditor = preload("res://addons/hex_map_kit/editor/hex_adjacency_rule_editor.gd")
const HexCellButtonLayout = preload("res://addons/hex_map_kit/editor/hex_cell_button_layout.gd")
const HexCellButtonPanel = preload("res://addons/hex_map_kit/editor/hex_cell_button_panel.gd")
const HexTileCatalogEntry = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_entry.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")
const HexTileCatalogValidator = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_validator.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")
const HexValidationRuleSuiteResource = preload("res://addons/hex_map_kit/adapter/hex_validation_rule_suite_resource.gd")

class FakeTileLayer:
	var cleared := false
	var calls: Array = []

	func clear() -> void:
		cleared = true

	func set_cell(map_cell: Vector2i, source_id: int, atlas_coords: Vector2i, alternative_tile: int = 0) -> void:
		calls.append({
			"map_cell": map_cell,
			"source_id": source_id,
			"atlas_coords": atlas_coords,
			"alternative_tile": alternative_tile,
		})


class CountingHexTileMapLayer:
	extends HexTileMapLayer

	var apply_document_cell_count := 0
	var redraw_count := 0

	func apply_document_cell(document, hex: HexVector) -> bool:
		apply_document_cell_count += 1
		return super.apply_document_cell(document, hex)

	func _redraw() -> void:
		redraw_count += 1
		super._redraw()


class CellPressRecorder:
	var entries: Array = []

	func record(entry: Dictionary) -> void:
		entries.append(entry)


class SessionChangeRecorder:
	var keys: PackedStringArray = PackedStringArray()

	func record(key: String) -> void:
		keys.append(key)


class AssetCreatePathRecorder:
	var entries: Array[Dictionary] = []

	func record(slot_id: String, path: String) -> void:
		entries.append({
			"slot_id": slot_id,
			"path": path,
		})


class AssetSampleActionRecorder:
	var slots: PackedStringArray = PackedStringArray()

	func record(slot_id: String) -> void:
		slots.append(slot_id)


var _failures: Array[String] = []
var _test_output_root := ""


func _assert_generation_dock_internal_component_contract(dock: HexMapGenDock) -> void:
	var expected := {
		"generate_run_controls": {
			"screen_script": "hex_map_gen_run_controls.gd",
			"screen_role_source": "HexMapGenRunControls",
			"builder": "build_run_controls",
			"layout_section": "input",
		},
		"generate_progress_controls": {
			"screen_script": "hex_map_gen_run_controls.gd",
			"screen_role_source": "HexMapGenRunControls",
			"builder": "build_progress_controls",
			"layout_section": "performance",
		},
		"generate_source_registry": {
			"screen_script": "hex_map_gen_source_controls.gd",
			"screen_role_source": "HexMapGenSourceControls",
			"builder": "build_source_registry_controls",
			"layout_section": "profile_source",
		},
		"generate_output_target": {
			"screen_script": "hex_map_gen_output_controls.gd",
			"screen_role_source": "HexMapGenOutputControls",
			"builder": "build_output_target_controls",
			"layout_section": "apply_save",
		},
		"generate_save_apply_controls": {
			"screen_script": "hex_map_gen_output_controls.gd",
			"screen_role_source": "HexMapGenOutputControls",
			"builder": "build_save_apply_controls",
			"layout_section": "apply_save",
		},
		"generate_seed_lab": {
			"screen_script": "hex_map_gen_result_controls.gd",
			"screen_role_source": "HexMapGenResultControls",
			"builder": "build_seed_lab_controls",
			"layout_section": "preview",
		},
		"generate_candidate_thumbnail": {
			"screen_script": "hex_map_gen_result_controls.gd",
			"screen_role_source": "HexMapGenResultControls",
			"builder": "build_candidate_thumbnail",
			"layout_section": "preview",
		},
		"generate_result_summary": {
			"screen_script": "hex_map_gen_result_controls.gd",
			"screen_role_source": "HexMapGenResultControls",
			"builder": "build_result_summary_label",
			"layout_section": "preview",
		},
	}
	var script_rows := []
	for rows in [
		HexMapGenRunControls.component_owner_rows(),
		HexMapGenSourceControls.component_owner_rows(),
		HexMapGenOutputControls.component_owner_rows(),
		HexMapGenResultControls.component_owner_rows(),
	]:
		for row in rows:
			var row_data := row as Dictionary
			script_rows.append(row_data.duplicate(true))
	_assert_eq(dock.generation_component_owner_rows().size(), expected.size(), "ARCH-NEXT-11 Generate owner row count")
	_assert_eq(script_rows.size(), expected.size(), "ARCH-NEXT-11 Generate script owner row count")
	for script_row in script_rows:
		var row_data := script_row as Dictionary
		var component_id := String(row_data.get("component_id", ""))
		_assert_true(expected.has(component_id), "ARCH-NEXT-11 script row component is expected: %s" % component_id)
		var expected_row = expected[component_id] as Dictionary
		_assert_eq(String(row_data.get("screen_script", "")), String(expected_row["screen_script"]), "ARCH-NEXT-11 %s script row owner" % component_id)
		_assert_eq(String(row_data.get("screen_role_source", "")), String(expected_row["screen_role_source"]), "ARCH-NEXT-11 %s script row role" % component_id)
		_assert_eq(String(row_data.get("builder", "")), String(expected_row["builder"]), "ARCH-NEXT-11 %s script row builder" % component_id)
		_assert_eq(String(row_data.get("layout_section", "")), String(expected_row["layout_section"]), "GEN-NEXT-10 %s script row layout section" % component_id)
	for component_id in expected.keys():
		var expected_row_data = expected[component_id] as Dictionary
		_assert_true(dock.generation_component_ids().has(String(component_id)), "ARCH-NEXT-11 Generate component id exists: %s" % component_id)
		var mounted := dock.mounted_generation_component_owner_for(String(component_id))
		_assert_eq(String(mounted.get("screen_script", "")), String(expected_row_data["screen_script"]), "ARCH-NEXT-11 %s mounted script owner" % component_id)
		_assert_eq(String(mounted.get("screen_role_source", "")), String(expected_row_data["screen_role_source"]), "ARCH-NEXT-11 %s mounted role owner" % component_id)
		_assert_eq(String(mounted.get("builder", "")), String(expected_row_data["builder"]), "ARCH-NEXT-11 %s mounted builder owner" % component_id)
		_assert_eq(String(mounted.get("layout_section", "")), String(expected_row_data["layout_section"]), "GEN-NEXT-10 %s mounted layout section" % component_id)
	var layout = dock.generation_layout_snapshot()
	_assert_true(bool(layout["input_profile_preview_apply_save_performance_separated"]), "GEN-NEXT-10 Generate layout sections are all mounted")
	_assert_true(bool(layout["reload_save_apply_purpose_clear"]), "GEN-NEXT-10 Generate reload/save/apply purposes are classified")
	_assert_eq((layout["missing_section_ids"] as PackedStringArray).size(), 0, "GEN-NEXT-10 Generate layout has no missing sections")
	var section_ids = layout["section_ids"] as PackedStringArray
	for section_id in ["input", "profile_source", "preview", "apply_save", "performance"]:
		_assert_true(section_ids.has(String(section_id)), "GEN-NEXT-10 Generate layout section exists: %s" % String(section_id))
	var sections_by_id := {}
	for section in layout["sections"] as Array:
		var section_data := section as Dictionary
		sections_by_id[String(section_data["section_id"])] = section_data
	_assert_true(((sections_by_id["input"] as Dictionary)["component_ids"] as PackedStringArray).has("generate_run_controls"), "GEN-NEXT-10 Input section owns run controls")
	_assert_true(((sections_by_id["profile_source"] as Dictionary)["component_ids"] as PackedStringArray).has("generate_source_registry"), "GEN-NEXT-10 Profile/Source section owns source registry")
	_assert_true(((sections_by_id["preview"] as Dictionary)["component_ids"] as PackedStringArray).has("generate_result_summary"), "GEN-NEXT-10 Preview section owns result summary")
	_assert_true(((sections_by_id["preview"] as Dictionary)["component_ids"] as PackedStringArray).has("generate_candidate_thumbnail"), "GEN-NEXT-11 Preview section owns candidate thumbnail")
	_assert_true(((sections_by_id["apply_save"] as Dictionary)["component_ids"] as PackedStringArray).has("generate_output_target"), "GEN-NEXT-10 Apply/Save section owns output target")
	_assert_true(((sections_by_id["performance"] as Dictionary)["component_ids"] as PackedStringArray).has("generate_progress_controls"), "GEN-NEXT-10 Performance section owns progress controls")
	var actions = layout["actions"] as Dictionary
	_assert_eq(String((actions["target_refresh"] as Dictionary)["purpose"]), "refresh_target_layers", "GEN-NEXT-10 target refresh purpose is explicit")
	_assert_eq(String((actions["source_load"] as Dictionary)["purpose"]), "browse_mapdata_source", "GEN-NEXT-10 source browse purpose is explicit")
	_assert_eq(String((actions["output_apply"] as Dictionary)["purpose"]), "apply_to_selected_document", "GEN-NEXT-10 output apply purpose is explicit")
	_assert_eq(String((actions["save_as"] as Dictionary)["purpose"]), "save_generated_resource_as_tres", "GEN-NEXT-10 save purpose is explicit")


func _assert_project_asset_slot(
	workspace,
	tab_name: String,
	slot_id: String,
	expected_resource: Resource,
	expected_path: String,
	label: String
) -> void:
	var snapshot = workspace.tab_asset_slot_snapshot(tab_name, slot_id)
	var actual_path := String(snapshot.get("current_path", ""))
	_assert_true(bool(snapshot.get("selected", false)), "%s is selected" % label)
	_assert_eq(snapshot.get("current_source", ""), HexMapEditorAssetSlotState.SOURCE_PROJECT, "%s source is project" % label)
	_assert_eq(snapshot.get("current_resource", null), expected_resource, "%s resource is selected" % label)
	_assert_eq(actual_path, expected_path, "%s path is selected" % label)
	_assert_true(not _is_bundled_sample_asset_path(actual_path), "%s path is not bundled sample asset" % label)


func _is_bundled_sample_asset_path(path: String) -> bool:
	return path.begins_with("res://addons/hex_map_kit/assets/")


func _sample_asset_rows_have_path(rows: Array, path: String) -> bool:
	for row in rows:
		if String((row as Dictionary).get("path", "")) == path:
			return true
	return false


func _safe_path_part(value: String) -> String:
	var result := ""
	for index in range(value.length()):
		var code = value.unicode_at(index)
		if (code >= 48 and code <= 57) \
			or (code >= 65 and code <= 90) \
			or (code >= 97 and code <= 122) \
			or code == 45 \
			or code == 46 \
			or code == 95:
			result += char(code)
		else:
			result += "-"
	return "run" if result == "" else result


func _test_resource_path(filename: String) -> String:
	return "%s/%s" % [_test_output_dir(), filename]


func _test_resource_dir(dirname: String) -> String:
	var path = "%s/%s" % [_test_output_dir(), dirname]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
	return path


func _test_output_dir() -> String:
	if _test_output_root == "":
		_test_output_root = "res://.godot_user/test-runs/%s/test_editor_plugin" % _safe_path_part(_test_run_id())
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_test_output_root))
	return _test_output_root


func _test_run_id() -> String:
	var run_id = OS.get_environment("HEX_MAP_TEST_RUN_ID")
	if run_id == "":
		run_id = "manual-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()]
	return run_id


func _test_catalog_tileset() -> TileSet:
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.2, 0.7, 0.4, 1.0))
	var texture := ImageTexture.create_from_image(image)
	var tile_set := TileSet.new()
	HexMapTileAdapter.configure_atlas_tile_set(
		tile_set,
		texture,
		true,
		Vector2i(32, 32),
		0,
		[Vector2i.ZERO]
	)
	return tile_set


func _save_distribution(path: String, distribution: HexDistribution) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var error = ResourceSaver.save(distribution, path)
	_assert_eq(error, OK, "test distribution resource saves")


func _save_resource(path: String, resource: Resource) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var error = ResourceSaver.save(resource, path)
	_assert_eq(error, OK, "test resource saves")


func _count_cancel(state: Dictionary) -> void:
	state["count"] += 1


func _capture_rules(rules_text: String, state: Dictionary) -> void:
	state["rules"] = rules_text


func _spin_values(spins: Array) -> Array:
	var result: Array = []
	for spin in spins:
		result.append(float(spin.value))
	return result


func _connect_method_index(method: int) -> int:
	for index in range(HexMapGenDock.CONNECT_METHOD_VALUES.size()):
		if HexMapGenDock.CONNECT_METHOD_VALUES[index] == method:
			return index
	_failures.append("connect method %d is not listed in dock" % method)
	return 0


func _sample_editor_document() -> HexMapDocumentResource:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentResource.new()

	var terrain_layer = HexMapDocumentTerrainLayerResource.new()
	terrain_layer.map = HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_POINTY_TOP)
	terrain_layer.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 0,
		"atlas_coords": Vector2i(1, 0),
		"alternative_tile": 0,
	})
	document.terrain_layers.append(terrain_layer)

	var overlay_layer = HexMapDocumentOverlayLayerResource.new()
	overlay_layer.item_key = "Treasure"
	overlay_layer.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"source_id": 0,
		"atlas_coords": Vector2i(1, 0),
		"alternative_tile": 0,
	})
	document.overlay_layers.append(overlay_layer)

	var placement = HexMapDocumentObjectPlacementResource.new()
	placement.object_id = "chest"
	placement.cell = Vector3i.ZERO
	document.object_placements.append(placement)

	var label = HexMapDocumentLabelPlacementResource.new()
	label.label_id = "area"
	label.cell = Vector3i.ZERO
	label.text = "North"
	document.label_placements.append(label)
	return document


func _new_ready_dock():
	var dock = HexMapGenDock.new()
	root.add_child(dock)
	await process_frame
	return dock


func _new_ready_edit_tool():
	var tool = HexMapEditTool.new()
	root.add_child(tool)
	await process_frame
	return tool


func _begin_manual_generation(dock: HexMapGenDock, show_progress: bool = false) -> void:
	dock._generation_id += 1
	dock._begin_generation(dock._generation_id, show_progress)


func _wait_for_generation(dock: HexMapGenDock, message: String) -> void:
	var guard := 0
	while _generation_operation_active(dock) and guard < 240:
		await process_frame
		guard += 1
	_assert_true(guard < 240, "%s finishes" % message)
	await process_frame


func _wait_for_progress_status(dock: HexMapGenDock, expected_status: String, message: String) -> void:
	var guard := 0
	while String(dock.generation_progress_snapshot()["status"]) != expected_status and guard < 240:
		await process_frame
		guard += 1
	_assert_eq(String(dock.generation_progress_snapshot()["status"]), expected_status, "%s reaches progress status" % message)


func _wait_for_tile_settings_apply_count(dock: HexMapGenDock, expected_count: int, message: String) -> void:
	var guard := 0
	while int(dock.tile_settings_apply_debounce_snapshot()["apply_count"]) < expected_count and guard < 240:
		await process_frame
		guard += 1
	_assert_eq(
		int(dock.tile_settings_apply_debounce_snapshot()["apply_count"]),
		expected_count,
		"%s reaches expected apply count" % message
	)


func _generation_operation_active(dock: HexMapGenDock) -> bool:
	var status = dock.generation_status()
	if bool(status["running"]):
		return true
	var text := String(status["status"])
	return text == "Validating generated document" \
		or text == "Applying generated result" \
		or text == "Finalizing"


func _wait_for_progress_controls(dock: HexMapGenDock, message: String) -> void:
	var guard := 0
	while not _progress_controls_ready(dock) \
		and dock.generation_status()["running"] \
		and guard < 240:
		await process_frame
		guard += 1
	_assert_true(_progress_controls_ready(dock), "%s shows dock progress" % message)


func _wait_for_core_progress(dock: HexMapGenDock) -> void:
	var guard := 0
	while dock._generation_last_core_progress <= 0.0 \
		and dock.generation_status()["running"] \
		and guard < 240:
		await process_frame
		guard += 1
	_assert_true(dock._generation_core_progress_event_count > 0, "threaded generation emits core progress")
	_assert_true(dock._generation_last_core_progress > 0.0, "threaded generation emits nonzero core progress")


func _wait_seconds(seconds: float) -> void:
	await create_timer(seconds).timeout


func _progress_controls_visible(dock: HexMapGenDock) -> bool:
	return dock._generation_progress_container != null \
		and dock._generation_progress_container.visible


func _progress_controls_ready(dock: HexMapGenDock) -> bool:
	return _progress_controls_visible(dock) \
		and dock._generation_progress_cancel_button != null


func _progress_controls_hidden(dock: HexMapGenDock) -> bool:
	return dock._generation_progress_container == null \
		or not dock._generation_progress_container.visible


func _window_child_count(node: Node) -> int:
	var count := 0
	for child in node.get_children():
		if child is Window:
			count += 1
		count += _window_child_count(child)
	return count


func _has_button_text(node: Node, text: String) -> bool:
	if node is Button and node.text == text:
		return true
	for child in node.get_children():
		if _has_button_text(child, text):
			return true
	return false


func _button_with_text(node: Node, text: String) -> Button:
	if node is Button and node.text == text:
		return node as Button
	for child in node.get_children():
		var found := _button_with_text(child, text)
		if found != null:
			return found
	return null


func _find_preview_thumbnail(node: Node, node_name: String) -> HexMapPreviewThumbnail:
	if node is HexMapPreviewThumbnail and node.name == node_name:
		return node as HexMapPreviewThumbnail
	for child in node.get_children():
		var found := _find_preview_thumbnail(child, node_name)
		if found != null:
			return found
	return null


func _find_catalog_preview_control(node: Node, node_name: String) -> HexTileCatalogPreviewControl:
	if node is HexTileCatalogPreviewControl and node.name == node_name:
		return node as HexTileCatalogPreviewControl
	for child in node.get_children():
		var found := _find_catalog_preview_control(child, node_name)
		if found != null:
			return found
	return null


func _entries_by_id(entries: Array) -> Dictionary:
	var result := {}
	for entry in entries:
		result[String(entry["id"])] = entry
	return result


func _rows_by_slot(rows: Array) -> Dictionary:
	var result := {}
	for row in rows:
		if row is Dictionary:
			result[String((row as Dictionary).get("slot_id", ""))] = row
	return result


func _pressable_entry_count(entries: Array) -> int:
	var count := 0
	for entry in entries:
		if bool(entry.get("pressable", false)) and not bool(entry.get("disabled", false)):
			count += 1
	return count


func _direction_pressable_cells() -> Dictionary:
	var result := {}
	for direction in HexVector.directions():
		result[direction.key()] = true
	return result


func _press_query_row_direction(row: Dictionary, direction_index: int) -> void:
	var panel: HexCellButtonPanel = row["offset_panel"]
	var direction = HexVector.directions()[direction_index]
	var entry: Dictionary = _entries_by_id(panel.get_entries())[direction.key()]
	_send_panel_click(panel, entry["center"])


func _send_panel_click(panel: HexCellButtonPanel, position: Vector2) -> void:
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.position = position
	press.pressed = true
	panel._gui_input(press)

	var release = InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.position = position
	release.pressed = false
	panel._gui_input(release)


func _send_panel_motion(panel: HexCellButtonPanel, position: Vector2) -> void:
	var motion = InputEventMouseMotion.new()
	motion.position = position
	panel._gui_input(motion)


func _send_panel_key(panel: HexCellButtonPanel, keycode: int) -> void:
	var event = InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	panel._gui_input(event)


func _control_row_visible(control: Control) -> bool:
	if control == null:
		return false
	var parent = control.get_parent()
	if parent is Control:
		return (parent as Control).visible
	return control.visible


func _catalog_row_for_key(rows: Array, key: String) -> Dictionary:
	for row in rows:
		if String(row.get("key", "")) == key:
			return row
	return {}


func _object_definition_row_for_id(rows: Array, object_id: String) -> Dictionary:
	for row in rows:
		if String(row.get("id", "")) == object_id:
			return row
	return {}


func _layer_stack_row_for_role(rows: Array, role: String) -> Dictionary:
	for row in rows:
		if String(row.get("role", "")) == role:
			return row
	return {}


func _validation_issue_row_for_rule(rows: Array, rule_id: String) -> Dictionary:
	for row in rows:
		if String(row.get("rule_id", "")) == rule_id:
			return row
	return {}


func _export_mode_status(modes: Array, mode_id: String) -> String:
	for mode in modes:
		if mode is Dictionary and String((mode as Dictionary).get("id", "")) == mode_id:
			return String((mode as Dictionary).get("status", ""))
	return ""


func _validation_result_has_rule(result: HexMapValidationResult, rule_id: String) -> bool:
	if result == null:
		return false
	for issue in result.issues:
		if issue is Dictionary and String((issue as Dictionary).get("rule_id", "")) == rule_id:
			return true
	return false


func _assert_created_asset_resource_type(slot_id: String, resource: Resource) -> void:
	match slot_id:
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT:
			_assert_true(resource is HexMapDocumentResource, "create-new level document has document resource type")
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG:
			_assert_true(resource is HexTileCatalogResource, "create-new tile catalog has catalog resource type")
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE:
			_assert_true(resource is HexObjectDatabaseResource, "create-new object database has object database type")
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE:
			_assert_true(resource is HexLabelDatabaseResource, "create-new label database has label database type")
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK:
			_assert_true(resource is HexLayerStackResource, "create-new layer stack has layer stack type")
		HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE:
			_assert_true(resource is HexMovementProfileResource, "create-new movement profile has movement profile type")
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE:
			_assert_true(resource is HexValidationRuleSuiteResource, "create-new validation suite has validation suite type")
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE:
			_assert_true(resource is HexGenerationProfileResource, "create-new generation profile has generation profile type")
		HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE:
			_assert_true(resource is HexExportProfileResource, "create-new export profile has export profile type")


func _assert_created_asset_has_no_sample_payload(slot_id: String, resource: Resource) -> void:
	match slot_id:
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT:
			var document := resource as HexMapDocumentResource
			_assert_eq(document.dependencies.size(), 0, "create-new document has no sample dependencies")
			_assert_eq(document.terrain_layers.size(), 0, "create-new document has no sample terrain layers")
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG:
			var catalog := resource as HexTileCatalogResource
			_assert_eq(catalog.tile_set, null, "create-new catalog has no sample TileSet")
			_assert_eq(catalog.entries.size(), 0, "create-new catalog has no sample entries")
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE:
			var object_database := resource as HexObjectDatabaseResource
			_assert_eq(object_database.definitions.size(), 0, "create-new object database has no sample definitions")
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE:
			var label_database := resource as HexLabelDatabaseResource
			_assert_eq(label_database.definitions.size(), 0, "create-new label database has no sample definitions")
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK:
			var stack := resource as HexLayerStackResource
			_assert_true(stack.layers.size() > 0, "create-new layer stack uses project template roles")
		HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE:
			var movement_profile := resource as HexMovementProfileResource
			_assert_true(not movement_profile.profile_id.contains("sample"), "create-new movement profile is not sample-named")
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE:
			var validation_suite := resource as HexValidationRuleSuiteResource
			_assert_true(not validation_suite.suite_id.contains("sample"), "create-new validation suite is not sample-named")
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE:
			var generation_profile := resource as HexGenerationProfileResource
			_assert_true(not generation_profile.profile_id.contains("sample"), "create-new generation profile is not sample-named")
		HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE:
			var export_profile := resource as HexExportProfileResource
			_assert_true(not export_profile.profile_id.contains("sample"), "create-new export profile is not sample-named")


func _capture_apply_progress_event(status: Dictionary, events: Array) -> void:
	events.append(status.duplicate(true))


func _cancel_apply_after_processed(status: Dictionary, processed_limit: int) -> bool:
	return String(status.get("phase", "")) == "tiles" \
		and int(status.get("processed_cells", 0)) >= processed_limit


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _assert_vec2_approx(actual: Vector2, expected: Vector2, message: String, tolerance: float = 0.01) -> void:
	if actual.distance_to(expected) > tolerance:
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _assert_vector_eq(actual, expected, message: String) -> void:
	if not actual.is_equal(expected):
		_failures.append(
			"%s: expected %s, got %s" % [message, expected.debug_string(), actual.debug_string()]
		)


func _assert_keys_eq(actual: Array, expected: Array, message: String) -> void:
	var actual_keys: Array = []
	for point in actual:
		actual_keys.append(point.key())
	actual_keys.sort()
	var expected_keys: Array = []
	for point in expected:
		expected_keys.append(point.key())
	expected_keys.sort()
	_assert_eq(actual_keys, expected_keys, message)


func _assert_color_approx(actual: Color, expected: Color, message: String) -> void:
	if not is_equal_approx(actual.r, expected.r) \
		or not is_equal_approx(actual.g, expected.g) \
		or not is_equal_approx(actual.b, expected.b) \
		or not is_equal_approx(actual.a, expected.a):
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])

func _finish(script_name: String) -> void:
	if _failures.is_empty():
		print("%s: all tests passed" % script_name)
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)
