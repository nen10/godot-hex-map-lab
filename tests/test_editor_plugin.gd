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
const HexMapDocumentLabelPlacementResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_label_placement_resource.gd")
const HexMapDocumentObjectPlacementResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_object_placement_resource.gd")
const HexMapDocumentOverlayLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_overlay_layer_resource.gd")
const HexMapDocumentTerrainLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_terrain_layer_resource.gd")
const HexMapValidationResult = preload("res://addons/hex_map_kit/adapter/hex_map_validation_result.gd")
const HexLayerStackResource = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd")
const HexObjectDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_object_database_resource.gd")
const HexObjectDefinitionResource = preload("res://addons/hex_map_kit/adapter/hex_object_definition_resource.gd")
const HexLabelDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_label_database_resource.gd")
const HexLabelDefinitionResource = preload("res://addons/hex_map_kit/adapter/hex_label_definition_resource.gd")
const HexMovementProfileResource = preload("res://addons/hex_map_kit/adapter/hex_movement_profile_resource.gd")
const HexMapGenDock = preload("res://addons/hex_map_kit/editor/hex_map_gen_dock.gd")
const HexMapGenStateEvaluator = preload("res://addons/hex_map_kit/editor/hex_map_gen_state_evaluator.gd")
const HexMapEditTool = preload("res://addons/hex_map_kit/editor/hex_map_edit_tool.gd")
const HexMapEditMutationBuilder = preload("res://addons/hex_map_kit/editor/hex_map_edit_mutation_builder.gd")
const HexMapEditViewportInputAdapter = preload("res://addons/hex_map_kit/editor/hex_map_edit_viewport_input_adapter.gd")
const HexMapDocumentInspector = preload("res://addons/hex_map_kit/editor/hex_map_document_inspector.gd")
const HexMapEditorSessionState = preload("res://addons/hex_map_kit/editor/hex_map_editor_session_state.gd")
const HexMapEditorAssetSlotState = preload("res://addons/hex_map_kit/editor/hex_map_editor_asset_slot_state.gd")
const HexMapEditorAssetSlotControl = preload("res://addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd")
const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")
const HexMapWorkspaceAssetResourceFactory = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_resource_factory.gd")
const HexMapSampleAssetDuplicator = preload("res://addons/hex_map_kit/editor/hex_map_sample_asset_duplicator.gd")
const HexMapSampleSettingsPanel = preload("res://addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd")
const HexMapWorkspace = preload("res://addons/hex_map_kit/editor/hex_map_workspace.gd")
const HexDistEditor = preload("res://addons/hex_map_kit/editor/hex_dist_editor.gd")
const HexAdjacencyRuleEditor = preload("res://addons/hex_map_kit/editor/hex_adjacency_rule_editor.gd")
const HexCellButtonLayout = preload("res://addons/hex_map_kit/editor/hex_cell_button_layout.gd")
const HexCellButtonPanel = preload("res://addons/hex_map_kit/editor/hex_cell_button_panel.gd")
const HexTileCatalogEntry = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_entry.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")
const HexTileCatalogValidator = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_validator.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")

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


var _failures: Array[String] = []
var _test_output_root := ""


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_plugin_registration_files()
	await _test_hex_map_workspace_exposes_tabs_and_routes_editing()
	await _test_workspace_first_run_learning_cta_routes_to_settings_without_sample_defaults()
	await _test_workspace_asset_context_is_shared_by_workspace_generate_and_paint()
	await _test_document_asset_screen_manages_project_document_without_samples()
	await _test_catalog_asset_screen_manages_project_catalog_without_samples()
	await _test_layer_stack_asset_screen_manages_project_stack_without_samples()
	await _test_object_label_asset_screen_manages_project_definitions_without_samples()
	await _test_paint_brush_asset_screen_routes_missing_assets_without_raw_controls()
	await _test_workspace_sample_settings_panel_controls_sample_mode_sources()
	_test_sample_asset_duplicator_copies_catalog_dependencies_to_project()
	_test_asset_slot_state_model_reports_selection_validation_and_sample_source()
	await _test_asset_slot_control_exposes_state_snapshot_contract()
	_test_asset_resource_factory_creates_project_resources_and_assigns_context()
	await _test_map_edit_tool_builds_dock_controls()
	await _test_plugin_handles_canvas_item_when_map_edit_ready()
	await _test_editor_session_state_shares_generate_target_and_edit_document()
	_test_map_edit_tool_mutation_builder_and_viewport_adapter()
	await _test_document_inspector_component_summarizes_document_and_validation()
	await _test_map_edit_tool_auto_target_uses_selected_layer()
	await _test_map_edit_tool_auto_target_maps_hex_internal_layer_selection()
	await _test_map_edit_tool_initializes_document_from_hex_target()
	await _test_map_edit_tool_imports_generated_map_resource()
	await _test_map_edit_tool_path_file_handlers_and_action_states()
	await _test_map_edit_tool_loads_saves_document_without_losing_typed_payloads()
	await _test_map_edit_tool_click_updates_document_with_undo_redo()
	await _test_map_edit_tool_debug_report_copy_includes_reportable_state()
	await _test_map_edit_tool_forward_canvas_gui_input_uses_viewport_transform()
	await _test_map_edit_tool_target_selection_sync_for_explicit_target()
	await _test_map_edit_tool_forward_canvas_gui_input_reports_no_editable_cell()
	await _test_map_edit_tool_target_readiness_reports_plain_tile_map_layer()
	await _test_map_edit_tool_target_readiness_reports_hex_tile_map_layer_loop_state()
	await _test_map_edit_tool_preserves_plain_target_tile_settings_when_redrawing()
	await _test_map_edit_tool_target_atlas_settings_use_target_tileset()
	await _test_map_edit_tool_catalog_selectors_drive_defaults_and_payloads()
	await _test_map_edit_tool_object_palette_uses_definitions_and_typed_properties()
	await _test_map_edit_tool_layer_stack_screen_manages_roles()
	await _test_map_edit_tool_reports_missing_catalog_assignment_validation()
	await _test_map_edit_tool_validation_dashboard_groups_and_focuses_cell_issue()
	await _test_map_edit_tool_debug_report_includes_validation_summary_without_status_bloat()
	await _test_map_edit_tool_target_status_reports_tileset_and_overlay_payload()
	await _test_map_edit_tool_last_edit_trace_distinguishes_document_and_redraw()
	await _test_map_edit_tool_last_edit_trace_reports_target_apply_failure()
	await _test_map_edit_tool_persistence_checkpoint_reports_save_and_export_counts()
	await _test_map_edit_tool_local_hit_uses_hex_tile_map_layer()
	await _test_map_edit_tool_hex_target_uses_command_apply_path()
	await _test_map_edit_tool_hex_tile_payload_modes_change_display()
	await _test_map_edit_tool_overlay_tile_payload_changes_hex_display()
	await _test_map_edit_tool_keeps_tile_payloads_per_mode()
	await _test_map_edit_tool_object_and_label_payloads_change_hex_display()
	await _test_map_edit_tool_forward_canvas_gui_input_edits_loop_visual_duplicate()
	await _test_map_edit_tool_undo_redo_preserves_loop_visual_identity()
	await _test_map_edit_tool_mode_specific_payload_controls()
	_test_hex_cell_button_layout_direction_cells_flat_top()
	_test_hex_cell_button_layout_direction_cells_pointy_top()
	_test_hex_cell_button_layout_minimum_size_uses_padding()
	_test_hex_cell_button_layout_polygon_hit_rejects_rect_corner()
	_test_hex_cell_button_layout_shape_cells_custom_ring_disc()
	await _test_hex_cell_button_panel_emits_pressed_for_hex_hit()
	await _test_hex_cell_button_panel_emits_hover_for_hex_hit()
	await _test_hex_cell_button_panel_accepts_label_display_state()
	await _test_hex_cell_button_panel_does_not_press_disabled_cell()
	await _test_hex_cell_button_panel_focus_navigation()
	await _test_distribution_editor_loads_default_preset_values()
	await _test_distribution_editor_loads_resource_values_and_colors_cells()
	await _test_distribution_editor_uses_hex_cell_layout_for_patterns()
	await _test_distribution_editor_pattern_redraw_uses_layout_entries()
	await _test_distribution_editor_close_button_uses_cancel_flow()
	await _test_distribution_editor_manages_recent_custom_and_duplicate_preset()
	await _test_adjacency_rule_editor_applies_rule_text()
	_test_generation_dock_state_evaluator_splits_control_logic()
	await _test_generation_dock_adjacency_rule_validation()
	await _test_generation_dock_symmetric_hexagon_minimum_radii()
	await _test_generation_dock_shape_universe_uses_canonical_hexagon_and_square_torus()
	await _test_generation_dock_torus_connectivity_controls()
	await _test_generation_dock_torus_connectivity_generation()
	await _test_generation_dock_tracks_generation_progress_state()
	await _test_generation_dock_debug_report_includes_validation_summary()
	await _test_generation_dock_validates_generation_result_before_auto_apply()
	await _test_generation_dock_captures_generation_validation_failure()
	await _test_generation_dock_batch_runner_scores_and_sorts()
	await _test_generation_dock_promotes_batch_seed_to_canonical_document()
	await _test_generation_dock_only_generates_from_generate_button()
	await _test_generation_dock_wires_core_progress_and_cancel()
	await _test_generation_dock_applies_configured_tile_entries()
	await _test_generation_dock_applies_orientation_to_tile_entries()
	await _test_generation_dock_resource_stores_orientation()
	await _test_generation_dock_configures_tile_map_layer_tileset()
	await _test_generation_dock_applies_primary_map_to_hex_tile_map_layer()
	await _test_generation_dock_swaps_tile_size_on_orientation_change()
	await _test_generation_dock_lists_hex_tile_map_layer_common_target()
	await _test_generation_dock_lists_and_auto_applies_selected_tile_layer()
	await _test_generation_dock_disambiguates_duplicate_target_names()
	await _test_generation_dock_adds_new_target_layer()
	await _test_generation_dock_duplicates_shared_tileset_for_selected_layer()
	await _test_generation_dock_sets_up_sample_tiles()
	await _test_generation_dock_selects_atlas_image()
	await _test_generation_dock_generate_auto_applies_current_map()
	await _test_generation_dock_generate_auto_applies_hex_tile_map_layer()
	await _test_generation_dock_overlay_uniform_generation_and_apply()
	await _test_generation_dock_overlay_applies_to_hex_tile_map_layer()
	await _test_generation_dock_overlay_limit_and_apply_policy()
	await _test_generation_dock_overlay_placement_mask_filters_candidates()
	await _test_generation_dock_overlay_adjacency_reference_generation()
	await _test_generation_dock_adjacency_generated_reference_snapshot()
	await _test_generation_dock_adjacency_generated_reference_changes_result()
	await _test_generation_dock_overlay_item_pool_tile_mapping()
	await _test_generation_dock_catalog_selectors_drive_tile_defaults()
	await _test_generation_dock_mapdata_source_registry_load_reload_clear()
	await _test_generation_dock_path_action_labels_and_failure_status()
	await _test_generation_dock_mapdata_query_rows_evaluate_offset_and_toric()
	await _test_generation_dock_overlay_deductor_floor_source_query()
	await _test_generation_dock_mapdata_crop_result_and_reset_rules()
	await _test_generation_dock_mapdata_crop_off_stacks_overlay_sources()
	await _test_generation_dock_generate_history_saves_overlay_delta_source()

	if _failures.is_empty():
		print("test_editor_plugin.gd: all tests passed")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _test_plugin_registration_files() -> void:
	var config = ConfigFile.new()
	var error = config.load("res://addons/hex_map_kit/plugin.cfg")
	_assert_eq(error, OK, "plugin.cfg loads")
	_assert_eq(config.get_value("plugin", "name", ""), "Hex Map Kit", "plugin.cfg has addon name")
	var script_path = "res://addons/hex_map_kit/%s" % config.get_value("plugin", "script", "")
	_assert_true(load(script_path) != null, "plugin.cfg script can be loaded")


func _test_hex_map_workspace_exposes_tabs_and_routes_editing() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var expected_tabs = PackedStringArray([
		"Document",
		"Generate",
		"Paint",
		"Catalog",
		"Layers",
		"Validate",
		"QA",
		"Export",
		"Settings",
	])
	_assert_eq(workspace.name, "Hex Map Workspace", "workspace has stable dock name")
	_assert_eq(workspace.workspace_tab_names(), expected_tabs, "workspace exposes UX responsibility tabs")
	_assert_true(
		workspace.component_rows().size() >= expected_tabs.size(),
		"workspace exposes component responsibility map"
	)
	_assert_eq(
		workspace.component_for_responsibility("CatalogPanel").get("tab", ""),
		"Catalog",
		"workspace maps CatalogPanel to Catalog tab"
	)
	_assert_eq(
		workspace.component_for_responsibility("ValidationPanel").get("tab", ""),
		"Validate",
		"workspace maps ValidationPanel to Validate tab"
	)
	_assert_eq(
		workspace.component_for_responsibility("SampleSettingsPanel").get("tab", ""),
		"Settings",
		"workspace maps SampleSettingsPanel to Settings tab"
	)
	_assert_true(workspace.generation_dock() is HexMapGenDock, "workspace mounts generation component")
	_assert_true(workspace.edit_tool() is HexMapEditTool, "workspace mounts paint/edit component")
	_assert_true(workspace.sample_settings_panel() is HexMapSampleSettingsPanel, "workspace mounts sample settings component")
	_assert_eq(workspace.generation_dock().editor_session_state(), session, "workspace forwards session to generation component")
	_assert_eq(workspace.edit_tool().editor_session_state(), session, "workspace forwards session to paint/edit component")
	_assert_eq(workspace.sample_settings_panel().editor_session_state(), session, "workspace forwards session to sample settings component")
	var asset_tab_expectations := [
		{"tab": "Document", "component": "document_asset_panel", "count": 5, "slot": "level_document"},
		{"tab": "Paint", "component": "object_label_asset_panel", "count": 2, "slot": "object_database"},
		{"tab": "Catalog", "component": "catalog_asset_panel", "count": 1, "slot": "tile_catalog"},
		{"tab": "Layers", "component": "layer_stack_asset_panel", "count": 1, "slot": "layer_stack"},
		{"tab": "Validate", "component": "validation_asset_panel", "count": 2, "slot": "validation_rule_suite"},
		{"tab": "QA", "component": "qa_asset_panel", "count": 3, "slot": "generation_profile"},
		{"tab": "Export", "component": "export_asset_panel", "count": 1, "slot": "level_document"},
		{"tab": "Settings", "component": "settings_project_defaults_panel", "count": 1, "slot": "movement_profile"},
	]
	for expectation in asset_tab_expectations:
		var tab_name := String(expectation["tab"])
		_assert_true(
			workspace.tab_has_component(tab_name, String(expectation["component"])),
			"%s tab has real asset component" % tab_name
		)
		_assert_eq(
			workspace.asset_slot_count(tab_name),
			int(expectation["count"]),
			"%s tab owns expected asset slot count" % tab_name
		)
		_assert_true(
			workspace.tab_asset_slot_ids(tab_name).has(String(expectation["slot"])),
			"%s tab exposes expected asset slot id" % tab_name
		)
	_assert_true(workspace.tab_has_component("Generate", "generation_panel"), "Generate tab keeps generation component")
	_assert_true(
		workspace.tab_component_ids("Catalog").has("catalog_asset_panel"),
		"Catalog tab registry exposes catalog asset panel"
	)
	_assert_true(
		workspace.tab_component_ids("Validate").has("validation_issue_navigator"),
		"Validate tab registry exposes issue navigator"
	)
	_assert_true(
		workspace.tab_asset_slot_ids("Catalog").has(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG),
		"Catalog tab registry exposes tile catalog asset slot"
	)
	_assert_true(
		workspace.tab_asset_slot_ids("QA").has(HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE),
		"QA tab registry exposes generation profile asset slot"
	)
	_assert_true(workspace.tab_has_component("Paint", "brush_palette"), "Paint tab keeps paint component")
	_assert_eq(workspace.asset_slot_count("Paint"), 2, "Paint tab owns object and label asset slots")
	_assert_true(
		workspace.tab_asset_slot_ids("Paint").has(HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE),
		"Paint tab registry exposes label database asset slot"
	)
	_assert_true(not workspace.tab_has_component("Paint", "document_asset_panel"), "Paint tab does not own Document setup component")
	_assert_true(workspace.tab_has_component("Settings", "sample_settings_panel"), "Settings tab keeps sample settings component")

	var layer = TileMapLayer.new()
	root.add_child(layer)
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	workspace.edit_tool().set_document(document)
	workspace.edit_tool().set_target_layer(layer)
	_assert_true(workspace.viewport_input_enabled(), "workspace gates viewport input through paint/edit component")

	layer.queue_free()
	workspace.queue_free()
	await process_frame


func _test_workspace_first_run_learning_cta_routes_to_settings_without_sample_defaults() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	_assert_true(session.sample_learning_cta_visible(), "sample learning CTA is visible for first workspace session")
	var snapshot = workspace.sample_learning_cta_snapshot()
	_assert_true(bool(snapshot["visible"]), "workspace exposes visible first-run sample CTA")
	_assert_eq(String(snapshot["learn_label"]), "Learn with bundled samples", "sample CTA uses learning action label")
	_assert_eq(workspace.current_workspace_tab_name(), "Document", "workspace starts on normal project document tab")
	_assert_true(
		not session.show_bundled_samples_in_main_selectors,
		"sample CTA does not enable sample selector visibility by default"
	)
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "sample CTA initial state does not assign generation sample catalog")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "sample CTA initial state does not assign paint sample catalog")

	workspace.open_sample_learning_cta()
	await process_frame
	snapshot = workspace.sample_learning_cta_snapshot()
	_assert_true(not bool(snapshot["visible"]), "opening sample CTA hides it for this session")
	_assert_true(bool(snapshot["dismissed"]), "opening sample CTA records dismissed first-run state")
	_assert_eq(workspace.current_workspace_tab_name(), "Settings", "sample CTA routes to Settings tab")
	_assert_true(
		not session.show_bundled_samples_in_main_selectors,
		"sample CTA routing does not enable sample mode"
	)
	_assert_true(
		not session.use_bundled_sample_assets_for_scratch_documents,
		"sample CTA routing does not enable scratch sample assets"
	)
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "sample CTA routing does not assign generation sample catalog")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "sample CTA routing does not assign paint sample catalog")

	workspace.queue_free()
	await process_frame

	var reused_workspace = HexMapWorkspace.new()
	reused_workspace.set_editor_session_state(session)
	root.add_child(reused_workspace)
	await process_frame
	_assert_true(not reused_workspace.sample_learning_cta_visible(), "dismissed sample CTA does not reappear in same session")
	reused_workspace.queue_free()
	await process_frame

	var dismiss_session = HexMapEditorSessionState.new()
	var dismiss_workspace = HexMapWorkspace.new()
	dismiss_workspace.set_editor_session_state(dismiss_session)
	root.add_child(dismiss_workspace)
	await process_frame
	_assert_true(dismiss_workspace.sample_learning_cta_visible(), "fresh session starts with sample CTA")
	dismiss_workspace.dismiss_sample_learning_cta()
	await process_frame
	_assert_true(not dismiss_workspace.sample_learning_cta_visible(), "sample CTA dismiss action hides CTA")
	_assert_eq(dismiss_workspace.current_workspace_tab_name(), "Document", "dismissing sample CTA keeps normal project tab")
	_assert_true(
		not dismiss_session.show_bundled_samples_in_main_selectors,
		"dismissing sample CTA does not enable sample mode"
	)
	_assert_eq(dismiss_workspace.generation_dock().tile_catalog(), null, "dismissed sample CTA leaves generation catalog unset")
	_assert_eq(dismiss_workspace.edit_tool().tile_catalog(), null, "dismissed sample CTA leaves paint catalog unset")

	dismiss_workspace.queue_free()
	await process_frame


func _test_workspace_asset_context_is_shared_by_workspace_generate_and_paint() -> void:
	var context = HexMapWorkspaceAssetContext.new()
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var catalog = HexTileCatalogResource.new()
	var object_database = HexObjectDatabaseResource.new()
	var label_database = HexLabelDatabaseResource.new()
	var layer_stack = HexLayerStackResource.minimal_runtime_template()
	var movement_profile = HexMovementProfileResource.new()
	var validation_suite = Resource.new()
	var generation_profile = Resource.new()

	context.set_level_document(document)
	context.set_tile_catalog(catalog)
	context.set_object_database(object_database)
	context.set_label_database(label_database)
	context.set_layer_stack(layer_stack)
	context.set_movement_profile(movement_profile)
	context.set_validation_rule_suite(validation_suite)
	context.set_generation_profile(generation_profile)

	var slot_ids = HexMapWorkspaceAssetContext.asset_slot_ids()
	_assert_true(slot_ids.has("tile_catalog"), "workspace asset context exposes tile catalog slot id")
	_assert_true(slot_ids.has("object_database"), "workspace asset context exposes object database slot id")
	_assert_true(slot_ids.has("label_database"), "workspace asset context exposes label database slot id")
	_assert_true(slot_ids.has("layer_stack"), "workspace asset context exposes layer stack slot id")
	_assert_true(slot_ids.has("movement_profile"), "workspace asset context exposes movement profile slot id")
	_assert_true(slot_ids.has("validation_rule_suite"), "workspace asset context exposes validation suite slot id")
	_assert_true(slot_ids.has("generation_profile"), "workspace asset context exposes generation profile slot id")

	var snapshot = context.snapshot()
	_assert_eq(snapshot["level_document"], document, "workspace asset context holds level document")
	_assert_eq(snapshot["tile_catalog"], catalog, "workspace asset context holds tile catalog")
	_assert_eq(snapshot["object_database"], object_database, "workspace asset context holds object database")
	_assert_eq(snapshot["label_database"], label_database, "workspace asset context holds label database")
	_assert_eq(snapshot["layer_stack"], layer_stack, "workspace asset context holds layer stack")
	_assert_eq(snapshot["movement_profile"], movement_profile, "workspace asset context holds movement profile")
	_assert_eq(snapshot["validation_rule_suite"], validation_suite, "workspace asset context holds validation suite")
	_assert_eq(snapshot["generation_profile"], generation_profile, "workspace asset context holds generation profile")

	var session = HexMapEditorSessionState.new()
	var recorder = SessionChangeRecorder.new()
	session.changed.connect(Callable(recorder, "record"))
	session.set_workspace_asset_context(context, "test.asset_context")
	_assert_eq(session.current_workspace_asset_context(), context, "session owns workspace asset context")
	_assert_true(recorder.keys.has("workspace_asset_context"), "session emits context replacement key")

	var session_catalog = HexTileCatalogResource.new()
	session.set_workspace_asset(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, session_catalog, "test.tile_catalog")
	_assert_eq(context.tile_catalog, session_catalog, "session publishes asset changes into context")
	_assert_true(
		recorder.keys.has("workspace_asset_context.tile_catalog"),
		"session republishes context slot change key"
	)

	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	_assert_eq(workspace.workspace_asset_context(), context, "workspace exposes session asset context")
	_assert_eq(
		workspace.workspace_asset_context_for_tab("Generate"),
		context,
		"Generate tab receives workspace asset context"
	)
	_assert_eq(
		workspace.workspace_asset_context_for_tab("Paint"),
		context,
		"Paint tab receives workspace asset context"
	)
	_assert_eq(
		workspace.workspace_asset_context_for_tab("Validate"),
		context,
		"Validate tab resolves the shared workspace asset context"
	)
	_assert_eq(
		workspace.workspace_asset_context_for_tab("QA"),
		context,
		"QA tab resolves the shared workspace asset context"
	)
	_assert_eq(
		workspace.generation_dock().workspace_asset_context(),
		context,
		"generation dock references workspace asset context"
	)
	_assert_eq(
		workspace.edit_tool().workspace_asset_context(),
		context,
		"paint tool references workspace asset context"
	)
	_assert_eq(
		workspace.generation_dock().tile_catalog(),
		session_catalog,
		"generation dock consumes context tile catalog"
	)
	_assert_eq(
		workspace.tab_asset_slot_snapshot("Catalog", HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG).get("current_resource", null),
		session_catalog,
		"Catalog tab asset slot consumes context tile catalog"
	)
	_assert_eq(
		workspace.edit_tool().tile_catalog(),
		session_catalog,
		"paint tool consumes context tile catalog"
	)

	var paint_catalog = HexTileCatalogResource.new()
	var paint_object_database = HexObjectDatabaseResource.new()
	var paint_label_database = HexLabelDatabaseResource.new()
	var paint_layer_stack = HexLayerStackResource.standard_template()
	workspace.edit_tool().set_tile_catalog(paint_catalog)
	workspace.edit_tool().set_object_database(paint_object_database)
	workspace.edit_tool().set_label_database(paint_label_database)
	workspace.edit_tool().set_layer_stack_resource(paint_layer_stack)
	_assert_eq(context.tile_catalog, paint_catalog, "paint tool publishes selected catalog to context")
	_assert_eq(context.object_database, paint_object_database, "paint tool publishes selected object database to context")
	_assert_eq(context.label_database, paint_label_database, "paint tool publishes selected label database to context")
	_assert_eq(context.layer_stack, paint_layer_stack, "paint tool publishes selected layer stack to context")
	_assert_eq(
		workspace.generation_dock().tile_catalog(),
		paint_catalog,
		"generation dock consumes paint-selected project catalog through context"
	)
	_assert_eq(
		workspace.tab_asset_slot_snapshot("Catalog", HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG).get("current_resource", null),
		paint_catalog,
		"Catalog tab asset slot tracks paint-selected project catalog through context"
	)

	workspace.queue_free()
	await process_frame


func _test_document_asset_screen_manages_project_document_without_samples() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var snapshot = workspace.document_screen_snapshot()
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("document_asset_panel"),
		"Document screen exposes document asset component"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT),
		"Document screen exposes level document slot"
	)
	_assert_true(
		PackedStringArray(snapshot["dependency_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG),
		"Document screen exposes catalog dependency slot"
	)
	_assert_true(
		PackedStringArray(snapshot["dependency_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK),
		"Document screen exposes layer stack dependency slot"
	)
	_assert_eq(workspace.workspace_asset_context().level_document, null, "Document screen starts without a sample document")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Document screen starts with sample mode OFF")

	var output_dir = _test_resource_dir("screen20_document")
	var document_path = "%s/level_document.tres" % output_dir
	var create_result = workspace.create_level_document(document_path)
	_assert_true(bool(create_result["ok"]), "Document screen creates Level Document")
	_assert_true(FileAccess.file_exists(document_path), "Document screen writes created Level Document")
	var document = create_result["resource"] as HexMapDocumentResource
	_assert_true(document is HexMapDocumentResource, "Document screen create returns document resource")
	_assert_eq(workspace.workspace_asset_context().level_document, document, "created document enters workspace context")
	_assert_eq(session.current_document(), document, "created document enters editor session")
	_assert_eq(session.document_saved_path, document_path, "created document updates session saved path")
	_assert_eq(
		workspace.tab_asset_slot_snapshot("Document", HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT).get("current_source", ""),
		HexMapEditorAssetSlotState.SOURCE_PROJECT,
		"Document screen marks created document as project asset"
	)

	var open_result = workspace.open_level_document()
	_assert_true(bool(open_result["ok"]), "Document screen opens selected Level Document")
	_assert_eq(open_result["resource"], document, "Document screen open returns selected document")

	var save_as_path = "%s/level_document_saved_as.tres" % output_dir
	var save_result = workspace.save_level_document_as(save_as_path)
	_assert_true(bool(save_result["ok"]), "Document screen saves Level Document as project resource")
	_assert_true(FileAccess.file_exists(save_as_path), "Document screen Save As writes project resource")
	_assert_eq(document.resource_path, save_as_path, "Document screen Save As updates document resource path")
	_assert_eq(session.document_saved_path, save_as_path, "Document screen Save As updates session saved path")

	var validation = workspace.validate_level_document()
	_assert_true(validation is HexMapValidationResult, "Document screen validate returns validation result")
	_assert_true(validation.summary.has("cells"), "Document screen validation returns document summary")
	_assert_true(validation.to_dictionary().has("errors"), "Document screen validation returns issue counts")

	var clear_result = workspace.clear_level_document()
	_assert_true(bool(clear_result["ok"]), "Document screen clears Level Document")
	_assert_eq(workspace.workspace_asset_context().level_document, null, "cleared document leaves workspace context")
	_assert_eq(session.current_document(), null, "cleared document leaves editor session")
	_assert_eq(session.document_saved_path, "", "cleared document resets saved path")
	_assert_true(
		not bool(workspace.tab_asset_slot_snapshot("Document", HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT).get("selected", true)),
		"Document screen level document slot becomes unselected after clear"
	)
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Document screen actions do not enable sample mode")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "Document screen actions do not inject generation sample catalog")

	workspace.queue_free()
	await process_frame


func _test_catalog_asset_screen_manages_project_catalog_without_samples() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var snapshot = workspace.catalog_screen_snapshot()
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("catalog_asset_panel"),
		"Catalog screen exposes catalog asset component"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG),
		"Catalog screen exposes tile catalog slot"
	)
	_assert_true(not bool(snapshot["sample_candidates_visible"]), "Catalog screen hides sample catalog candidates while sample mode is OFF")
	_assert_eq(workspace.workspace_asset_context().tile_catalog, null, "Catalog screen starts without sample catalog")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "Catalog screen does not inject generation sample catalog")

	var output_dir = _test_resource_dir("screen21_catalog")
	var catalog_path = "%s/tile_catalog.tres" % output_dir
	var create_result = workspace.create_tile_catalog(catalog_path)
	_assert_true(bool(create_result["ok"]), "Catalog screen creates project Tile Catalog")
	_assert_true(FileAccess.file_exists(catalog_path), "Catalog screen writes project Tile Catalog")
	var catalog = create_result["resource"] as HexTileCatalogResource
	_assert_true(catalog is HexTileCatalogResource, "Catalog screen create returns catalog resource")
	_assert_eq(workspace.workspace_asset_context().tile_catalog, catalog, "created catalog enters workspace context")
	_assert_eq(
		workspace.tab_asset_slot_snapshot("Catalog", HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG).get("current_source", ""),
		HexMapEditorAssetSlotState.SOURCE_PROJECT,
		"Catalog screen marks created catalog as project asset"
	)

	var tile_set := _test_catalog_tileset()
	var tile_set_result = workspace.set_catalog_tile_set(tile_set)
	_assert_true(bool(tile_set_result["ok"]), "Catalog screen assigns arbitrary TileSet")
	_assert_eq(catalog.tile_set, tile_set, "Catalog screen stores selected TileSet on catalog")

	var atlas_result = workspace.create_catalog_atlas_entry_from_tileset("terrain.floor", tile_set, 0, Vector2i.ZERO)
	_assert_true(bool(atlas_result["ok"]), "Catalog screen creates atlas entry from TileSet selection")
	var atlas_entry = atlas_result["entry"] as HexTileCatalogEntry
	_assert_true(atlas_entry is HexTileCatalogEntry, "Catalog screen returns atlas entry")
	_assert_eq(atlas_entry.entry_type, HexTileCatalogEntry.TYPE_ATLAS, "Catalog atlas entry uses atlas type")

	var marker := Node2D.new()
	var scene := PackedScene.new()
	_assert_eq(scene.pack(marker), OK, "test PackedScene packs")
	marker.free()
	var scene_result = workspace.create_catalog_scene_entry_from_packed_scene("object.spawn", scene)
	_assert_true(bool(scene_result["ok"]), "Catalog screen creates scene entry from PackedScene selection")
	var scene_entry = scene_result["entry"] as HexTileCatalogEntry
	_assert_true(scene_entry is HexTileCatalogEntry, "Catalog screen returns scene entry")
	_assert_eq(scene_entry.entry_type, HexTileCatalogEntry.TYPE_SCENE, "Catalog scene entry uses scene type")
	_assert_eq(scene_entry.scene, scene, "Catalog scene entry stores selected PackedScene")

	snapshot = workspace.catalog_screen_snapshot()
	_assert_eq(int(snapshot["entry_count"]), 2, "Catalog screen snapshot reports created entries")
	_assert_true(PackedStringArray(snapshot["entry_keys"]).has("terrain.floor"), "Catalog screen snapshot lists atlas key")
	_assert_true(PackedStringArray(snapshot["entry_keys"]).has("object.spawn"), "Catalog screen snapshot lists scene key")
	var validation = workspace.validate_tile_catalog()
	_assert_true(validation is HexMapValidationResult, "Catalog screen validate returns validation result")
	_assert_eq(validation.issue_count(), 0, "Catalog screen validates project catalog with selected TileSet and PackedScene")

	var open_result = workspace.open_tile_catalog()
	_assert_true(bool(open_result["ok"]), "Catalog screen opens selected Tile Catalog")
	_assert_eq(open_result["resource"], catalog, "Catalog screen open returns selected catalog")

	var save_as_path = "%s/tile_catalog_saved_as.tres" % output_dir
	var save_result = workspace.save_tile_catalog_as(save_as_path)
	_assert_true(bool(save_result["ok"]), "Catalog screen saves Tile Catalog as project resource")
	_assert_true(FileAccess.file_exists(save_as_path), "Catalog screen Save As writes project catalog")
	_assert_eq(catalog.resource_path, save_as_path, "Catalog screen Save As updates catalog resource path")

	var clear_result = workspace.clear_tile_catalog()
	_assert_true(bool(clear_result["ok"]), "Catalog screen clears Tile Catalog")
	_assert_eq(workspace.workspace_asset_context().tile_catalog, null, "cleared catalog leaves workspace context")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Catalog screen actions do not enable sample mode")

	workspace.queue_free()
	await process_frame


func _test_layer_stack_asset_screen_manages_project_stack_without_samples() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var snapshot = workspace.layer_stack_screen_snapshot()
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("layer_stack_asset_panel"),
		"Layers screen exposes layer stack asset component"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK),
		"Layers screen exposes layer stack slot"
	)
	_assert_true(PackedStringArray(snapshot["template_candidates"]).has("standard"), "Layers screen exposes standard template candidate")
	_assert_true(PackedStringArray(snapshot["template_candidates"]).has("minimal"), "Layers screen exposes minimal template candidate")
	_assert_true(not bool(snapshot["sample_template_present"]), "Layers screen has no sample template default")
	_assert_eq(workspace.workspace_asset_context().layer_stack, null, "Layers screen starts without selected sample layer stack")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Layers screen starts with sample mode OFF")

	var output_dir = _test_resource_dir("screen22_layer_stack")
	var stack_path = "%s/layer_stack.tres" % output_dir
	var create_result = workspace.create_layer_stack(stack_path)
	_assert_true(bool(create_result["ok"]), "Layers screen creates project Layer Stack")
	_assert_true(FileAccess.file_exists(stack_path), "Layers screen writes project Layer Stack")
	var stack = create_result["resource"] as HexLayerStackResource
	_assert_true(stack is HexLayerStackResource, "Layers screen create returns layer stack resource")
	_assert_eq(workspace.workspace_asset_context().layer_stack, stack, "created layer stack enters workspace context")
	_assert_eq(workspace.edit_tool().layer_stack_resource(), stack, "created layer stack enters edit tool")
	_assert_eq(
		workspace.tab_asset_slot_snapshot("Layers", HexMapWorkspaceAssetContext.SLOT_LAYER_STACK).get("current_source", ""),
		HexMapEditorAssetSlotState.SOURCE_PROJECT,
		"Layers screen marks created layer stack as project asset"
	)
	_assert_true(not String(stack.display_name).to_lower().contains("sample"), "created layer stack is not sample-named")

	var open_result = workspace.open_layer_stack()
	_assert_true(bool(open_result["ok"]), "Layers screen opens selected Layer Stack")
	_assert_eq(open_result["resource"], stack, "Layers screen open returns selected layer stack")

	var save_as_path = "%s/layer_stack_saved_as.tres" % output_dir
	var save_result = workspace.save_layer_stack_as(save_as_path)
	_assert_true(bool(save_result["ok"]), "Layers screen saves Layer Stack as project resource")
	_assert_true(FileAccess.file_exists(save_as_path), "Layers screen Save As writes project layer stack")
	_assert_eq(stack.resource_path, save_as_path, "Layers screen Save As updates stack resource path")

	var template_path = "%s/layer_stack_standard_template_copy.tres" % output_dir
	var duplicate_result = workspace.duplicate_layer_stack_template_to_project("standard", template_path)
	_assert_true(bool(duplicate_result["ok"]), "Layers screen duplicates standard template to project asset")
	_assert_true(FileAccess.file_exists(template_path), "Layers screen writes duplicated project template")
	var duplicated_stack = duplicate_result["resource"] as HexLayerStackResource
	_assert_true(duplicated_stack is HexLayerStackResource, "duplicated template is a layer stack resource")
	_assert_eq(duplicated_stack.metadata.get("template_source", ""), "standard", "duplicated stack records template source")
	_assert_eq(workspace.workspace_asset_context().layer_stack, duplicated_stack, "duplicated template enters workspace context")
	_assert_eq(duplicated_stack.role_names().size(), 7, "duplicated standard template keeps authoring roles")

	var scene_root := Node2D.new()
	scene_root.name = "Screen22SceneRoot"
	var layer := HexTileMapLayer.new()
	layer.name = "AuthoringHexLayer"
	scene_root.add_child(layer)
	root.add_child(scene_root)
	await process_frame

	var pick_result = workspace.pick_layer_stack_target_root(scene_root)
	_assert_true(bool(pick_result["ok"]), "Layers screen picks target from scene root")
	_assert_eq(pick_result["target_layer"], layer, "Layers screen resolves scene HexTileMapLayer target")

	var document := _sample_editor_document()
	var document_result = workspace.set_layer_stack_document(document)
	_assert_true(bool(document_result["ok"]), "Layers screen accepts document for layer stack actions")
	snapshot = workspace.layer_stack_screen_snapshot()
	var terrain_row = _layer_stack_row_for_role(snapshot["role_rows"], HexLayerStackResource.ROLE_TERRAIN)
	_assert_eq(terrain_row["status"], "missing", "Layers screen reports missing terrain role before create")
	_assert_eq(
		String((snapshot["target_status"] as Dictionary).get("target_class", "")),
		"HexTileMapLayer",
		"Layers screen target status names HexTileMapLayer"
	)

	var create_layers_result = workspace.create_missing_layer_stack_layers()
	_assert_true(bool(create_layers_result["ok"]), "Layers screen creates missing target layers")
	terrain_row = _layer_stack_row_for_role(create_layers_result["role_rows"], HexLayerStackResource.ROLE_TERRAIN)
	_assert_eq(terrain_row["status"], "ok", "Layers screen reports created terrain role")
	var terrain_node = layer.layer_for_stack_role(HexLayerStackResource.ROLE_TERRAIN) as TileMapLayer
	_assert_true(terrain_node != null, "Layers screen creates terrain target node")

	var apply_result = workspace.apply_layer_stack_document_to_target()
	_assert_true(bool(apply_result["ok"]), "Layers screen applies document to target stack")
	_assert_true(terrain_node.get_used_cells().size() > 0, "Layers screen populates terrain role from document")

	var clear_role_result = workspace.clear_layer_stack_role(HexLayerStackResource.ROLE_TERRAIN)
	_assert_true(bool(clear_role_result["ok"]), "Layers screen clears selected role")
	_assert_eq(terrain_node.get_used_cells().size(), 0, "Layers screen clear role removes terrain cells")

	var clear_stack_result = workspace.clear_layer_stack()
	_assert_true(bool(clear_stack_result["ok"]), "Layers screen clears Layer Stack selection")
	_assert_eq(workspace.workspace_asset_context().layer_stack, null, "cleared layer stack leaves workspace context")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Layers screen actions do not enable sample mode")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _test_object_label_asset_screen_manages_project_definitions_without_samples() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var snapshot = workspace.object_label_screen_snapshot()
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("object_label_asset_panel"),
		"Object/Label screen exposes asset component"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE),
		"Object/Label screen exposes object database slot"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE),
		"Object/Label screen exposes label database slot"
	)
	_assert_eq(workspace.workspace_asset_context().object_database, null, "Object/Label screen starts without sample object database")
	_assert_eq(workspace.workspace_asset_context().label_database, null, "Object/Label screen starts without sample label database")
	_assert_true(not bool(snapshot["sample_object_scene_assigned"]), "Object/Label screen does not assign sample object scene")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Object/Label screen starts with sample mode OFF")

	var output_dir = _test_resource_dir("screen23_object_label")
	var object_db_path = "%s/object_database.tres" % output_dir
	var object_create_result = workspace.create_object_database(object_db_path)
	_assert_true(bool(object_create_result["ok"]), "Object/Label screen creates project Object Database")
	_assert_true(FileAccess.file_exists(object_db_path), "Object/Label screen writes project Object Database")
	var object_database = object_create_result["resource"] as HexObjectDatabaseResource
	_assert_true(object_database is HexObjectDatabaseResource, "Object/Label screen create returns object database resource")
	_assert_eq(workspace.workspace_asset_context().object_database, object_database, "created object database enters workspace context")
	_assert_eq(workspace.edit_tool().object_database(), object_database, "created object database enters edit tool")
	_assert_eq(
		workspace.tab_asset_slot_snapshot("Paint", HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE).get("current_source", ""),
		HexMapEditorAssetSlotState.SOURCE_PROJECT,
		"Object/Label screen marks created object database as project asset"
	)

	var label_db_path = "%s/label_database.tres" % output_dir
	var label_create_result = workspace.create_label_database(label_db_path)
	_assert_true(bool(label_create_result["ok"]), "Object/Label screen creates project Label Database")
	_assert_true(FileAccess.file_exists(label_db_path), "Object/Label screen writes project Label Database")
	var label_database = label_create_result["resource"] as HexLabelDatabaseResource
	_assert_true(label_database is HexLabelDatabaseResource, "Object/Label screen create returns label database resource")
	_assert_eq(workspace.workspace_asset_context().label_database, label_database, "created label database enters workspace context")
	_assert_eq(workspace.edit_tool().label_database(), label_database, "created label database enters edit tool")

	var marker := Node2D.new()
	var scene := PackedScene.new()
	_assert_eq(scene.pack(marker), OK, "test PackedScene packs for object definition")
	marker.free()
	var object_definition_result = workspace.create_object_definition_from_packed_scene("object.door", scene, "Door")
	_assert_true(bool(object_definition_result["ok"]), "Object/Label screen creates Object Definition from PackedScene")
	var object_definition = object_definition_result["definition"] as HexObjectDefinitionResource
	_assert_true(object_definition is HexObjectDefinitionResource, "Object/Label screen returns object definition")
	_assert_eq(object_definition.scene, scene, "Object Definition stores selected PackedScene")
	_assert_true(object_database.definition_ids().has("object.door"), "Object Database lists created object definition")

	var object_select_result = workspace.select_object_definition("object.door")
	_assert_true(bool(object_select_result["ok"]), "Object/Label screen selects Object Definition for placement")
	_assert_eq(String(object_select_result["payload"].get("object_id", "")), "object.door", "Object placement payload uses selected definition id")
	snapshot = workspace.object_label_screen_snapshot()
	_assert_eq(snapshot["selected_object_definition_id"], "object.door", "Object/Label snapshot reports selected object definition")
	var door_row = _object_definition_row_for_id(snapshot["object_definition_rows"], "object.door")
	_assert_eq(door_row["scene"], "PackedScene", "Object Definition row reports PackedScene status")

	var label_definition_result = workspace.create_label_definition("label.zone", "Zone Label", "North Gate", "map")
	_assert_true(bool(label_definition_result["ok"]), "Object/Label screen creates Label Definition")
	var label_definition = label_definition_result["definition"] as HexLabelDefinitionResource
	_assert_true(label_definition is HexLabelDefinitionResource, "Object/Label screen returns label definition")
	_assert_eq(label_definition.default_text, "North Gate", "Label Definition stores default text")
	_assert_true(label_database.definition_ids().has("label.zone"), "Label Database lists created label definition")

	var label_select_result = workspace.select_label_definition("label.zone")
	_assert_true(bool(label_select_result["ok"]), "Object/Label screen selects Label Definition for placement")
	_assert_eq(String(label_select_result["payload"].get("label_id", "")), "label.zone", "Label placement payload uses selected definition id")
	_assert_eq(String(label_select_result["payload"].get("text", "")), "North Gate", "Label placement payload uses definition default text")
	snapshot = workspace.object_label_screen_snapshot()
	_assert_eq(snapshot["selected_label_definition_id"], "label.zone", "Object/Label snapshot reports selected label definition")
	_assert_true(PackedStringArray(snapshot["label_definition_ids"]).has("label.zone"), "Object/Label snapshot lists label definition")

	var object_open_result = workspace.open_object_database()
	_assert_true(bool(object_open_result["ok"]), "Object/Label screen opens selected Object Database")
	_assert_eq(object_open_result["resource"], object_database, "Object/Label open returns selected Object Database")
	var object_save_as_path = "%s/object_database_saved_as.tres" % output_dir
	var object_save_result = workspace.save_object_database_as(object_save_as_path)
	_assert_true(bool(object_save_result["ok"]), "Object/Label screen saves Object Database as project resource")
	_assert_true(FileAccess.file_exists(object_save_as_path), "Object/Label screen Save As writes object database")

	var label_open_result = workspace.open_label_database()
	_assert_true(bool(label_open_result["ok"]), "Object/Label screen opens selected Label Database")
	_assert_eq(label_open_result["resource"], label_database, "Object/Label open returns selected Label Database")
	var label_save_as_path = "%s/label_database_saved_as.tres" % output_dir
	var label_save_result = workspace.save_label_database_as(label_save_as_path)
	_assert_true(bool(label_save_result["ok"]), "Object/Label screen saves Label Database as project resource")
	_assert_true(FileAccess.file_exists(label_save_as_path), "Object/Label screen Save As writes label database")

	var object_clear_result = workspace.clear_object_database()
	_assert_true(bool(object_clear_result["ok"]), "Object/Label screen clears Object Database")
	_assert_eq(workspace.workspace_asset_context().object_database, null, "cleared object database leaves workspace context")
	var label_clear_result = workspace.clear_label_database()
	_assert_true(bool(label_clear_result["ok"]), "Object/Label screen clears Label Database")
	_assert_eq(workspace.workspace_asset_context().label_database, null, "cleared label database leaves workspace context")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Object/Label screen actions do not enable sample mode")

	workspace.queue_free()
	await process_frame


func _test_paint_brush_asset_screen_routes_missing_assets_without_raw_controls() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var terrain_mode = workspace.select_paint_brush_mode("terrain")
	_assert_true(bool(terrain_mode["ok"]), "Paint brush screen selects terrain mode")
	var brush = (terrain_mode["brush"] as Dictionary)
	_assert_eq(brush["mode"], "terrain", "Paint brush snapshot reports terrain mode")
	_assert_true(not bool(brush["ready"]), "Paint brush terrain is not ready without catalog")
	var cta = brush["missing_asset_cta"] as Dictionary
	_assert_eq(cta["target_tab"], "Catalog", "Paint brush missing terrain catalog points to Catalog tab")
	_assert_eq(cta["target_component_id"], "catalog_asset_panel", "Paint brush missing terrain catalog points to catalog panel")
	_assert_eq(cta["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "Paint brush missing terrain catalog points to tile catalog slot")

	var controls = brush["normal_internal_controls_visible"] as Dictionary
	_assert_true(not bool(controls["source_id"]), "Paint brush hides source id control")
	_assert_true(not bool(controls["atlas_x"]), "Paint brush hides atlas x control")
	_assert_true(not bool(controls["atlas_y"]), "Paint brush hides atlas y control")
	_assert_true(not bool(controls["raw_object_id"]), "Paint brush hides raw object id control")
	_assert_true(not bool(controls["raw_label_id"]), "Paint brush hides raw label id control")

	var output_dir = _test_resource_dir("screen24_paint_brush")
	var catalog_path = "%s/tile_catalog.tres" % output_dir
	var catalog_result = workspace.create_tile_catalog(catalog_path)
	_assert_true(bool(catalog_result["ok"]), "Paint brush test creates project Tile Catalog")
	var tile_set := _test_catalog_tileset()
	_assert_true(bool(workspace.set_catalog_tile_set(tile_set)["ok"]), "Paint brush test assigns TileSet")
	_assert_true(
		bool(workspace.create_catalog_atlas_entry_from_tileset("terrain.floor", tile_set, 0, Vector2i.ZERO)["ok"]),
		"Paint brush test creates catalog key"
	)
	var terrain_brush = workspace.select_paint_catalog_brush_key("terrain.floor", "terrain")
	_assert_true(bool(terrain_brush["ok"]), "Paint brush selects terrain catalog key")
	brush = terrain_brush["brush"] as Dictionary
	_assert_true(bool(brush["ready"]), "Paint brush terrain is ready with selected catalog key")
	_assert_eq(brush["brush_key"], "terrain.floor", "Paint brush terrain reports catalog key")

	var overlay_brush = workspace.select_paint_catalog_brush_key("terrain.floor", "overlay")
	_assert_true(bool(overlay_brush["ok"]), "Paint brush selects overlay catalog key")
	brush = overlay_brush["brush"] as Dictionary
	_assert_eq(brush["mode"], "overlay", "Paint brush snapshot reports overlay mode")
	_assert_true(bool(brush["ready"]), "Paint brush overlay is ready with selected catalog key")

	var object_mode = workspace.select_paint_brush_mode("object")
	_assert_true(bool(object_mode["ok"]), "Paint brush screen selects object mode")
	brush = object_mode["brush"] as Dictionary
	_assert_true(not bool(brush["ready"]), "Paint brush object is not ready without object database")
	cta = brush["missing_asset_cta"] as Dictionary
	_assert_eq(cta["target_component_id"], "object_label_asset_panel", "Paint brush missing object points to object/label panel")
	_assert_eq(cta["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE, "Paint brush missing object points to object database slot")

	var object_db_result = workspace.create_object_database("%s/object_database.tres" % output_dir)
	_assert_true(bool(object_db_result["ok"]), "Paint brush test creates project Object Database")
	var marker := Node2D.new()
	var scene := PackedScene.new()
	_assert_eq(scene.pack(marker), OK, "test PackedScene packs for paint brush object")
	marker.free()
	_assert_true(
		bool(workspace.create_object_definition_from_packed_scene("object.spawn", scene, "Spawn")["ok"]),
		"Paint brush test creates object definition"
	)
	var object_select = workspace.select_object_definition("object.spawn")
	_assert_true(bool(object_select["ok"]), "Paint brush selects object definition")
	brush = (workspace.paint_brush_screen_snapshot()["brush"] as Dictionary)
	_assert_true(bool(brush["ready"]), "Paint brush object is ready with selected definition")
	_assert_eq(brush["brush_key"], "object.spawn", "Paint brush object reports definition id")

	var label_mode = workspace.select_paint_brush_mode("label")
	_assert_true(bool(label_mode["ok"]), "Paint brush screen selects label mode")
	brush = label_mode["brush"] as Dictionary
	_assert_true(not bool(brush["ready"]), "Paint brush label is not ready without label database")
	cta = brush["missing_asset_cta"] as Dictionary
	_assert_eq(cta["target_component_id"], "object_label_asset_panel", "Paint brush missing label points to object/label panel")
	_assert_eq(cta["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE, "Paint brush missing label points to label database slot")

	var label_db_result = workspace.create_label_database("%s/label_database.tres" % output_dir)
	_assert_true(bool(label_db_result["ok"]), "Paint brush test creates project Label Database")
	_assert_true(
		bool(workspace.create_label_definition("label.spawn", "Spawn Label", "Spawn", "map")["ok"]),
		"Paint brush test creates label definition"
	)
	var label_select = workspace.select_label_definition("label.spawn")
	_assert_true(bool(label_select["ok"]), "Paint brush selects label definition")
	brush = (workspace.paint_brush_screen_snapshot()["brush"] as Dictionary)
	_assert_true(bool(brush["ready"]), "Paint brush label is ready with selected definition")
	_assert_eq(brush["brush_key"], "label.spawn", "Paint brush label reports definition id")
	_assert_true(not bool(brush["zone_mode_available"]), "Paint brush reports zone mode as deferred")

	var zone_mode = workspace.select_paint_brush_mode("zone")
	_assert_true(not bool(zone_mode["ok"]), "Paint brush rejects zone mode until document mutation exists")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Paint brush actions do not enable sample mode")

	workspace.queue_free()
	await process_frame


func _test_workspace_sample_settings_panel_controls_sample_mode_sources() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var panel = workspace.sample_settings_panel()
	_assert_true(panel is HexMapSampleSettingsPanel, "workspace exposes sample settings panel")
	var snapshot = panel.snapshot()
	_assert_true(
		not bool(snapshot["show_bundled_samples_in_main_selectors"]),
		"sample visibility is off by default"
	)
	_assert_true(
		not bool(snapshot["use_bundled_sample_assets_for_scratch_documents"]),
		"scratch sample assets are off by default"
	)
	_assert_true(
		not bool(snapshot["auto_create_project_copy_when_applying_sample"]),
		"auto project copy is off by default"
	)
	_assert_eq(Array(snapshot["sample_assets"]).size(), 3, "sample settings lists bundled sample assets")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "sample mode OFF hides generation sample catalog fallback")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "sample mode OFF hides paint sample catalog fallback")
	_assert_true(
		not workspace.generation_dock().main_sample_controls_visible(),
		"workspace generation main UI hides sample controls"
	)
	_assert_true(
		not workspace.edit_tool().main_sample_controls_visible(),
		"workspace paint main UI hides sample controls"
	)

	panel.set_show_bundled_samples_in_main_selectors(true)
	snapshot = panel.snapshot()
	_assert_true(bool(snapshot["show_bundled_samples_in_main_selectors"]), "sample setting can enable sample selector visibility")
	var generation_sample_catalog = workspace.generation_dock().tile_catalog()
	var paint_sample_catalog = workspace.edit_tool().tile_catalog()
	_assert_true(generation_sample_catalog is HexTileCatalogResource, "sample mode ON exposes generation sample catalog fallback")
	_assert_true(paint_sample_catalog is HexTileCatalogResource, "sample mode ON exposes paint sample catalog fallback")
	_assert_eq(
		generation_sample_catalog.resource_path,
		"res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres",
		"generation sample fallback is the bundled sample catalog"
	)
	_assert_eq(
		paint_sample_catalog.resource_path,
		"res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres",
		"paint sample fallback is the bundled sample catalog"
	)

	var project_catalog = HexTileCatalogResource.new()
	session.set_workspace_asset(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, project_catalog, "test.project_catalog")
	_assert_eq(workspace.generation_dock().tile_catalog(), project_catalog, "project catalog remains primary for generation when sample mode is ON")
	_assert_eq(workspace.edit_tool().tile_catalog(), project_catalog, "project catalog remains primary for paint when sample mode is ON")

	panel.set_show_bundled_samples_in_main_selectors(false)
	_assert_eq(workspace.generation_dock().tile_catalog(), project_catalog, "project catalog remains primary for generation when sample mode is OFF")
	_assert_eq(workspace.edit_tool().tile_catalog(), project_catalog, "project catalog remains primary for paint when sample mode is OFF")
	session.set_workspace_asset(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, null, "test.clear_project_catalog")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "cleared project catalog does not reveal generation sample fallback while sample mode is OFF")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "cleared project catalog does not reveal paint sample fallback while sample mode is OFF")

	workspace.queue_free()
	await process_frame


func _test_sample_asset_duplicator_copies_catalog_dependencies_to_project() -> void:
	var context = HexMapWorkspaceAssetContext.new()
	_assert_eq(context.tile_catalog, null, "sample duplicate does not silently assign catalog before action")
	var output_dir = _test_resource_dir("sample11_duplicate")
	var catalog_path = "%s/project_sample_catalog.tres" % output_dir
	var result = HexMapSampleAssetDuplicator.duplicate_sample_catalog_to_project(catalog_path, context)
	_assert_true(bool(result["ok"]), "sample duplicate succeeds")
	_assert_eq(int(result["error"]), OK, "sample duplicate reports OK")
	_assert_true(FileAccess.file_exists(String(result["catalog_path"])), "sample duplicate writes catalog")
	_assert_true(FileAccess.file_exists(String(result["texture_path"])), "sample duplicate copies sample tile texture")
	_assert_true(FileAccess.file_exists(String(result["scene_path"])), "sample duplicate copies sample object scene")
	_assert_true(not String(result["catalog_path"]).begins_with("res://addons/hex_map_kit/assets/"), "sample duplicate catalog path is project-owned")
	_assert_true(not String(result["texture_path"]).begins_with("res://addons/hex_map_kit/assets/"), "sample duplicate texture path is project-owned")
	_assert_true(not String(result["scene_path"]).begins_with("res://addons/hex_map_kit/assets/"), "sample duplicate scene path is project-owned")

	var catalog = result["catalog"] as HexTileCatalogResource
	_assert_true(catalog is HexTileCatalogResource, "sample duplicate returns catalog resource")
	_assert_eq(context.tile_catalog, catalog, "sample duplicate assigns project catalog to context")
	_assert_eq(catalog.resource_path, catalog_path, "sample duplicate catalog stores project path")
	_assert_eq(
		String(catalog.metadata.get("duplicated_from_sample", "")),
		"res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres",
		"sample duplicate records source sample path"
	)
	_assert_true(bool(catalog.metadata.get("project_copy", false)), "sample duplicate marks catalog as project copy")
	_assert_true(catalog.tile_set != null, "sample duplicate preserves embedded TileSet")
	var atlas_source = catalog.tile_set.get_source(0) as TileSetAtlasSource
	_assert_true(atlas_source is TileSetAtlasSource, "sample duplicate TileSet has atlas source")
	_assert_true(atlas_source.texture != null, "sample duplicate atlas source has texture")
	_assert_eq(atlas_source.texture.resource_path, String(result["texture_path"]), "sample duplicate TileSet texture points to project copy")
	var scene_source = catalog.tile_set.get_source(1) as TileSetScenesCollectionSource
	_assert_true(scene_source is TileSetScenesCollectionSource, "sample duplicate TileSet has scene source")
	_assert_true(scene_source.has_scene_tile_id(1), "sample duplicate scene source preserves scene tile id")
	var scene = scene_source.get_scene_tile_scene(1)
	_assert_true(scene is PackedScene, "sample duplicate scene source has PackedScene")
	_assert_eq(scene.resource_path, String(result["scene_path"]), "sample duplicate scene source points to project scene")
	var scene_entry = catalog.entry_for_key("object.spawn_marker")
	_assert_true(scene_entry != null, "sample duplicate preserves scene catalog entry")
	_assert_eq(scene_entry.get("scene").resource_path, String(result["scene_path"]), "sample duplicate scene entry points to project scene")
	var validation = HexTileCatalogValidator.validate_catalog(catalog)
	_assert_eq(validation.issue_count(), 0, "sample duplicate catalog validates cleanly")

	var session = HexMapEditorSessionState.new()
	var panel = HexMapSampleSettingsPanel.new()
	panel.set_editor_session_state(session)
	var panel_rows = panel.sample_asset_rows()
	_assert_true(bool(panel_rows[0].get("duplicate_available", false)), "sample settings exposes duplicate availability")
	_assert_true(not bool(panel_rows[1].get("duplicate_available", false)), "sample tile texture duplicates through catalog action")
	_assert_true(not bool(panel_rows[2].get("duplicate_available", false)), "sample object scene duplicates through catalog action")
	var panel_result = panel.duplicate_sample_catalog_to_project("%s/panel_sample_catalog.tres" % output_dir)
	_assert_true(bool(panel_result["ok"]), "sample settings panel can duplicate sample catalog")
	_assert_eq(
		session.current_workspace_asset_context().tile_catalog,
		panel_result["catalog"],
		"sample settings panel duplicate assigns catalog to session context"
	)
	context.set_tile_catalog(null)
	catalog.tile_set = null
	session.current_workspace_asset_context().set_tile_catalog(null)
	var panel_catalog = panel_result["catalog"] as HexTileCatalogResource
	if panel_catalog != null:
		panel_catalog.tile_set = null
	panel.free()


func _test_asset_slot_state_model_reports_selection_validation_and_sample_source() -> void:
	var slot = HexMapEditorAssetSlotState.new()
	slot.configure("tile_catalog", "Tile Catalog", &"HexTileCatalogResource", true)
	var snapshot = slot.snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_NOT_SELECTED, "asset slot starts not selected")
	_assert_true(not bool(snapshot["selected"]), "asset slot starts without current selection")
	_assert_true(String(snapshot["validation_messages"][0]).contains("required"), "required slot reports missing selection")

	var sample_catalog = HexTileCatalogResource.new()
	slot.set_sample_source(
		sample_catalog,
		"res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres",
		"Sample Catalog"
	)
	snapshot = slot.snapshot()
	_assert_true(bool(snapshot["sample_available"]), "asset slot records optional sample source")
	_assert_true(not bool(snapshot["selected"]), "sample source is not selected by default")
	_assert_eq(snapshot["current_source"], HexMapEditorAssetSlotState.SOURCE_NONE, "sample source does not become current source")

	slot.set_selected_resource(HexMapDocumentResource.new(), "res://project/document.tres")
	snapshot = slot.snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_INVALID, "asset slot detects type mismatch")
	_assert_true(not bool(snapshot["type_matches"]), "asset slot exposes failed type match")
	_assert_true(
		String(snapshot["validation_messages"][0]).contains("Expected HexTileCatalogResource"),
		"asset slot mismatch message names expected type"
	)

	var project_catalog = HexTileCatalogResource.new()
	slot.set_selected_resource(project_catalog, "res://project/catalog.tres")
	snapshot = slot.snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_SELECTED, "asset slot accepts required project resource type")
	_assert_true(bool(snapshot["type_matches"]), "asset slot exposes successful type match")
	_assert_eq(snapshot["current_source"], HexMapEditorAssetSlotState.SOURCE_PROJECT, "project resource is current source")
	_assert_eq(snapshot["current_path"], "res://project/catalog.tres", "asset slot stores selected project path")

	slot.mark_warning(["TileSet missing."])
	snapshot = slot.snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_WARNING, "asset slot represents warning state")
	_assert_eq(snapshot["validation_messages"][0], "TileSet missing.", "asset slot stores warning messages")

	slot.clear_selection()
	snapshot = slot.snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_NOT_SELECTED, "clear returns slot to not selected")
	_assert_true(not bool(snapshot["selected"]), "clear removes selected resource")

	_assert_true(slot.apply_sample_source(), "asset slot can explicitly apply sample source")
	snapshot = slot.snapshot()
	_assert_eq(snapshot["current_source"], HexMapEditorAssetSlotState.SOURCE_SAMPLE, "explicit sample application marks sample source")
	_assert_eq(snapshot["current_resource"], sample_catalog, "explicit sample application selects sample resource")
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_SELECTED, "explicit sample application can produce selected state")


func _test_asset_slot_control_exposes_state_snapshot_contract() -> void:
	var state = HexMapEditorAssetSlotState.new()
	state.configure("object_database", "Object Database", &"HexObjectDatabaseResource", true)
	state.allows_create_new = true
	state.set_sample_source(HexObjectDatabaseResource.new(), "res://addons/hex_map_kit/assets/sample_object_db.tres", "Sample Object DB")

	var control = HexMapEditorAssetSlotControl.new()
	root.add_child(control)
	control.set_slot_state(state)
	await process_frame

	var snapshot = control.slot_state_snapshot()
	_assert_eq(snapshot["slot_id"], "object_database", "asset slot control exposes slot id in state snapshot")
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_NOT_SELECTED, "asset slot control exposes missing state")
	_assert_true(bool(snapshot["allows_sample"]), "asset slot control snapshot exposes sample availability")
	_assert_true(bool(snapshot["allows_create_new"]), "asset slot control snapshot exposes create-new availability")
	_assert_true(not bool(snapshot["selected"]), "asset slot control does not auto-select sample source")

	var database = HexObjectDatabaseResource.new()
	control.set_selected_resource(database, "res://project/object_database.tres")
	snapshot = control.slot_state_snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_SELECTED, "asset slot control records selected state")
	_assert_eq(snapshot["current_resource"], database, "asset slot control records selected resource")
	_assert_eq(snapshot["current_path"], "res://project/object_database.tres", "asset slot control records selected path")

	control.mark_invalid(["Object database is missing required definitions."])
	snapshot = control.slot_state_snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_INVALID, "asset slot control can expose invalid state")
	_assert_eq(
		snapshot["validation_messages"][0],
		"Object database is missing required definitions.",
		"asset slot control exposes validation messages"
	)

	_assert_true(control.apply_sample_source(), "asset slot control applies sample only through explicit action")
	snapshot = control.slot_state_snapshot()
	_assert_eq(snapshot["current_source"], HexMapEditorAssetSlotState.SOURCE_SAMPLE, "asset slot control records explicit sample source")
	_assert_eq(snapshot["current_path"], "res://addons/hex_map_kit/assets/sample_object_db.tres", "asset slot control records sample path after explicit action")

	var create_recorder = AssetCreatePathRecorder.new()
	control.create_path_selected.connect(Callable(create_recorder, "record"))
	_assert_eq(control.default_create_file_name(), "object_database.tres", "asset slot control exposes default create file name")
	var dialog_config = control.create_dialog_config()
	_assert_eq(String(dialog_config["current_file"]), "object_database.tres", "asset slot create dialog uses slot-specific file name")
	_assert_eq(int(dialog_config["file_mode"]), EditorFileDialog.FILE_MODE_SAVE_FILE, "asset slot create dialog uses Save As mode")
	control.select_create_path("res://project/new_object_database.tres")
	_assert_eq(create_recorder.entries.size(), 1, "asset slot create dialog emits selected path")
	_assert_eq(create_recorder.entries[0]["slot_id"], "object_database", "asset slot create path includes slot id")
	_assert_eq(create_recorder.entries[0]["path"], "res://project/new_object_database.tres", "asset slot create path includes selected path")

	control.queue_free()
	await process_frame


func _test_asset_resource_factory_creates_project_resources_and_assigns_context() -> void:
	var context = HexMapWorkspaceAssetContext.new()
	var output_dir = _test_resource_dir("asset12_create_new")
	var expectations := {
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT: "HexMapDocumentResource",
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG: "HexTileCatalogResource",
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE: "HexObjectDatabaseResource",
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE: "HexLabelDatabaseResource",
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK: "HexLayerStackResource",
		HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE: "HexMovementProfileResource",
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE: "Resource",
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE: "Resource",
	}

	for slot_id in HexMapWorkspaceAssetContext.asset_slot_ids():
		var default_file = HexMapWorkspaceAssetResourceFactory.default_file_name(slot_id)
		_assert_true(default_file.ends_with(".tres"), "create-new default file uses .tres for %s" % slot_id)
		var path = "%s/%s" % [output_dir, default_file]
		var result = HexMapWorkspaceAssetResourceFactory.create_and_save_for_slot(slot_id, path, context)
		_assert_true(bool(result["ok"]), "create-new saves resource for %s" % slot_id)
		_assert_eq(int(result["error"]), OK, "create-new reports OK for %s" % slot_id)
		_assert_true(FileAccess.file_exists(String(result["path"])), "create-new writes resource file for %s" % slot_id)
		_assert_eq(context.asset_for_slot(slot_id), result["resource"], "create-new assigns resource to context for %s" % slot_id)
		_assert_eq(
			HexMapWorkspaceAssetResourceFactory.resource_type_name(slot_id),
			expectations[slot_id],
			"create-new reports expected resource type for %s" % slot_id
		)
		_assert_created_asset_resource_type(slot_id, result["resource"])
		_assert_created_asset_has_no_sample_payload(slot_id, result["resource"])

	var extension_result = HexMapWorkspaceAssetResourceFactory.create_and_save_for_slot(
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE,
		"%s/profile_without_extension" % output_dir,
		context
	)
	_assert_true(String(extension_result["path"]).ends_with(".tres"), "create-new normalizes missing .tres extension")
	_assert_true(
		not String(extension_result["path"]).contains("sample"),
		"create-new normalized path does not introduce sample naming"
	)


func _test_map_edit_tool_mutation_builder_and_viewport_adapter() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var edit = HexMapEditMutationBuilder.build_document_edit(
		document,
		HexVector.zero(),
		HexMapEditTool.EditMode.WALL_FLOOR,
		{},
		"",
		{},
		{},
		HexMapEditTool.EDIT_MODE_NAMES
	)
	_assert_true(not edit.is_empty(), "mutation builder creates document edit")
	_assert_true(
		not HexMapDocumentAdapter.to_map_resource(edit["before"]).to_map_data().has_wall(HexVector.zero()),
		"mutation builder document edit captures before state"
	)
	_assert_true(
		HexMapDocumentAdapter.to_map_resource(edit["after"]).to_map_data().has_wall(HexVector.zero()),
		"mutation builder document edit captures after state"
	)
	_assert_eq(edit["mode"], "Wall / Floor", "mutation builder stores mode name")

	var tile_payload = {
		"source_id": 2,
		"atlas_coords": Vector2i(3, 4),
		"alternative_tile": 1,
		"catalog_key": "",
	}
	var before_state = {
		"hex": HexVector.zero(),
		"exists": true,
		"wall": false,
		"tile_overrides": [],
		"overlay_tiles": [],
		"objects": [],
		"labels": [],
	}
	var floor_command = HexMapEditMutationBuilder.build_hex_tile_map_layer_edit_command(
		before_state,
		HexVector.zero(),
		HexMapEditTool.EditMode.FLOOR_TILE,
		tile_payload,
		"",
		{},
		{},
		HexMapEditTool.EDIT_MODE_NAMES
	)
	_assert_true(not floor_command.is_empty(), "mutation builder creates HexTileMapLayer command")
	var floor_after: Dictionary = floor_command["after"]
	_assert_eq(floor_after["tile_overrides"].size(), 1, "mutation builder adds floor tile override")
	_assert_eq(floor_after["tile_overrides"][0]["kind"], HexMapDocumentAdapter.KIND_FLOOR, "mutation builder marks floor tile kind")
	_assert_eq(floor_after["tile_overrides"][0]["atlas_coords"], Vector2i(3, 4), "mutation builder keeps tile atlas")
	_assert_eq(floor_command["payload"], "2:(3,4):1", "mutation builder keeps payload summary")

	var missing_state = before_state.duplicate(true)
	missing_state["exists"] = false
	_assert_true(
		HexMapEditMutationBuilder.build_hex_tile_map_layer_edit_command(
			missing_state,
			HexVector.zero(),
			HexMapEditTool.EditMode.WALL_FLOOR,
			tile_payload,
			"",
			{},
			{},
			HexMapEditTool.EDIT_MODE_NAMES
		).is_empty(),
		"mutation builder blocks non-shape edits for missing cells"
	)
	var delete_command = HexMapEditMutationBuilder.build_hex_tile_map_layer_edit_command(
		{
			"hex": HexVector.zero(),
			"exists": true,
			"wall": true,
			"tile_overrides": [{"cell": Vector3i.ZERO, "kind": HexMapDocumentAdapter.KIND_WALL}],
			"overlay_tiles": [{"cell": Vector3i.ZERO, "kind": HexMapDocumentAdapter.KIND_OVERLAY}],
			"objects": [{"cell": Vector3i.ZERO, "object_id": "chest"}],
			"labels": [{"cell": Vector3i.ZERO, "label_id": "area"}],
		},
		HexVector.zero(),
		HexMapEditTool.EditMode.SHAPE,
		{},
		"",
		{},
		{},
		HexMapEditTool.EDIT_MODE_NAMES
	)
	var delete_after: Dictionary = delete_command["after"]
	_assert_true(not bool(delete_after["exists"]), "mutation builder shape delete clears existence")
	_assert_true(not bool(delete_after["wall"]), "mutation builder shape delete clears wall")
	_assert_eq(delete_after["tile_overrides"], [], "mutation builder shape delete clears tile overrides")
	_assert_eq(delete_after["overlay_tiles"], [], "mutation builder shape delete clears overlay tiles")
	_assert_eq(delete_after["objects"], [], "mutation builder shape delete clears objects")
	_assert_eq(delete_after["labels"], [], "mutation builder shape delete clears labels")

	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	_assert_true(HexMapEditViewportInputAdapter.accepts_mouse_press(press), "viewport adapter accepts left press")
	var release = InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	_assert_true(not HexMapEditViewportInputAdapter.accepts_mouse_press(release), "viewport adapter rejects release")
	var right_press = InputEventMouseButton.new()
	right_press.button_index = MOUSE_BUTTON_RIGHT
	right_press.pressed = true
	_assert_true(not HexMapEditViewportInputAdapter.accepts_mouse_press(right_press), "viewport adapter rejects non-left press")
	_assert_true(
		HexMapEditViewportInputAdapter.hit_is_editable({"exists": false}, HexMapEditTool.EditMode.SHAPE, HexMapEditTool.EditMode.SHAPE),
		"viewport adapter allows shape edits for missing cells"
	)
	_assert_true(
		not HexMapEditViewportInputAdapter.hit_is_editable({"exists": false}, HexMapEditTool.EditMode.WALL_FLOOR, HexMapEditTool.EditMode.SHAPE),
		"viewport adapter blocks non-shape edits for missing cells"
	)

	var target = Node2D.new()
	target.position = Vector2(3, 5)
	root.add_child(target)
	var trace = HexMapEditViewportInputAdapter.target_local_trace(Vector2(20, 30), Vector2(13, 17), target)
	_assert_true(bool(trace["ok"]), "viewport adapter resolves target local trace")
	_assert_vec2_approx(trace["local_position"], Vector2(10, 12), "viewport adapter converts scene to local")
	var missing_trace = HexMapEditViewportInputAdapter.target_local_trace(Vector2.ZERO, Vector2.ZERO, null)
	_assert_true(not bool(missing_trace["ok"]), "viewport adapter reports missing target")
	_assert_eq(missing_trace["status"], "No editable target layer.", "viewport adapter keeps missing target status")
	var hit = HexMapEditViewportInputAdapter.local_hit(Vector2.ZERO, null, document, 24.0)
	_assert_vector_eq(hit["hex"], HexVector.zero(), "viewport adapter fallback local hit returns origin")
	_assert_true(bool(hit["exists"]), "viewport adapter fallback local hit records document existence")
	target.queue_free()


func _test_document_inspector_component_summarizes_document_and_validation() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_object(document, HexVector.zero(), {"object_id": "marker"})
	HexMapDocumentAdapter.set_label(document, HexVector.q_axis(), {"label_id": "area", "text": "East"})

	var inspector = HexMapDocumentInspector.new()
	root.add_child(inspector)
	await process_frame
	inspector.set_document_state(document, HexMapEditTool.DOCUMENT_SOURCE_PROVIDED, "res://map.tres")
	var summary = inspector.inspector_summary()
	_assert_eq(summary["document"]["cell_count"], 2, "document inspector reports cell count")
	_assert_eq(summary["document"]["wall_count"], 1, "document inspector reports wall count")
	_assert_eq(summary["document"]["object_count"], 1, "document inspector reports object count")
	_assert_eq(summary["document"]["label_count"], 1, "document inspector reports label count")
	_assert_eq(summary["document"]["source"], HexMapEditTool.DOCUMENT_SOURCE_PROVIDED, "document inspector reports document source")
	_assert_true(inspector._document_summary_label.text.contains("cells=2"), "document inspector renders document summary")

	var result = HexMapValidationResult.new()
	result.add_error(
		"document.object_on_wall",
		"Object is on a wall.",
		HexMapValidationResult.SCOPE_CELL,
		{"cell": Vector3i(1, 0, 0)}
	)
	result.add_warning("document.optional", "Optional warning.")
	var validation_summary = HexMapDocumentInspector.validation_summary_from_result(result, {"document_present": true})
	inspector.set_validation_summary(validation_summary)
	summary = inspector.inspector_summary()
	_assert_eq(summary["validation"]["issues"], 2, "document inspector reports validation issues")
	_assert_eq(summary["validation"]["errors"], 1, "document inspector reports validation errors")
	_assert_eq(summary["validation"]["warnings"], 1, "document inspector reports validation warnings")
	_assert_true(inspector._validation_summary_label.text.contains("errors=1"), "document inspector renders validation summary")
	var rows = HexMapDocumentInspector.validation_issue_report_rows(result)
	_assert_eq(rows.size(), 2, "document inspector formats validation issue rows")
	_assert_true(rows[0].contains("document.object_on_wall"), "document inspector issue row includes rule id")
	_assert_true(rows[0].contains("cell=(1,0,0)"), "document inspector issue row includes cell")

	inspector.queue_free()
	await process_frame


func _test_map_edit_tool_builds_dock_controls() -> void:
	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var tile_layer = TileMapLayer.new()
	tile_layer.name = "LegacyPlainLayer"
	scene_root.add_child(tile_layer)
	var hex_layer = HexTileMapLayer.new()
	hex_layer.name = "PaintLayer"
	scene_root.add_child(hex_layer)
	await process_frame

	var tool = await _new_ready_edit_tool()
	tool.refresh_target_layer_options(scene_root)

	_assert_eq(tool.name, "Hex Map Edit", "map edit tool keeps stable standalone component name")
	var scroll = tool.get_child(0) as ScrollContainer
	_assert_true(scroll != null, "map edit tool wraps dock controls in a ScrollContainer")
	_assert_eq(scroll.anchor_right, 1.0, "map edit tool ScrollContainer fills dock width")
	_assert_eq(scroll.anchor_bottom, 1.0, "map edit tool ScrollContainer fills dock height")
	_assert_true(scroll.get_child(0) is VBoxContainer, "map edit tool ScrollContainer owns the controls container")
	_assert_eq(
		(scroll.get_child(0) as VBoxContainer).size_flags_vertical,
		Control.SIZE_SHRINK_BEGIN,
		"map edit tool controls keep vertical minimum size inside ScrollContainer"
	)
	if tool._can_use_editor_resource_picker():
		_assert_true(tool._document_resource_picker != null, "map edit tool exposes document resource picker")
	else:
		_assert_true(tool._document_browse_button != null, "map edit tool exposes document Browse fallback")
	_assert_true(tool._document_new_button != null, "map edit tool exposes New Document button")
	_assert_eq(tool._document_open_button.text, "Open...", "map edit tool exposes Open action")
	_assert_eq(tool._document_save_button.text, "Save", "map edit tool exposes Save action")
	_assert_eq(tool._document_save_as_button.text, "Save As...", "map edit tool exposes Save As action")
	_assert_eq(tool._document_validate_button.text, "Validate", "map edit tool exposes header Validate action")
	if tool._can_use_editor_resource_picker():
		_assert_true(tool._import_map_resource_picker != null, "map edit tool exposes HexMapResource import resource picker")
	else:
		_assert_true(tool._import_map_browse_button != null, "map edit tool exposes HexMapResource import Browse fallback")
	_assert_true(tool._import_map_browse_button != null, "map edit tool exposes HexMapResource import browse button")
	_assert_true(tool._import_map_button != null, "map edit tool exposes HexMapResource import button")
	_assert_true(tool._export_button != null, "map edit tool exposes map export button")
	_assert_true(tool._export_save_as_button != null, "map edit tool exposes map export save-as button")
	_assert_true(tool._document_inspector != null, "map edit tool exposes document inspector")
	_assert_true(tool._validation_dashboard != null, "map edit tool exposes validation dashboard")
	_assert_true(tool._validation_dashboard._validate_button != null, "validation dashboard exposes Validate button")
	_assert_true(tool._copy_debug_report_button != null, "map edit tool exposes debug report copy button")
	_assert_eq(tool._mode_option.item_count, HexMapEditTool.EDIT_MODE_NAMES.size(), "map edit tool lists edit modes")
	_assert_true(tool._layer_stack_template_option != null, "map edit tool exposes layer stack template picker")
	_assert_true(tool._layer_stack_role_tree != null, "map edit tool exposes layer stack role list")
	_assert_true(tool._layer_stack_create_missing_button != null, "map edit tool exposes Create Missing Layers")
	_assert_true(tool._layer_stack_apply_document_button != null, "map edit tool exposes Apply Document layer action")
	_assert_true(tool._layer_stack_clear_role_button != null, "map edit tool exposes Clear Role layer action")
	_assert_true(tool._object_properties_edit != null, "map edit tool exposes object properties payload control")
	_assert_true(tool._object_definition_tree != null, "map edit tool exposes object definition list")
	_assert_true(tool._object_add_definition_button != null, "map edit tool exposes add object definition action")
	_assert_true(tool._object_palette_status_label != null, "map edit tool exposes object palette status")
	_assert_true(tool._object_property_editor != null, "map edit tool exposes typed object property editor")
	_assert_true(tool._object_rotation_spin != null, "map edit tool exposes object rotation control")
	_assert_true(tool._object_variant_edit != null, "map edit tool exposes object variant control")
	_assert_true(tool._object_spawn_condition_edit != null, "map edit tool exposes object spawn condition control")
	_assert_true(tool._object_properties_table != null, "map edit tool exposes object property table")
	_assert_true(tool._default_floor_catalog_option != null, "map edit tool exposes default floor catalog control")
	_assert_true(tool._default_wall_catalog_option != null, "map edit tool exposes default wall catalog control")
	_assert_true(tool._tile_catalog_option != null, "map edit tool exposes tile payload catalog control")
	_assert_true(tool._object_catalog_option != null, "map edit tool exposes object catalog control")
	_assert_true(tool._default_tile_read_button != null, "map edit tool exposes default tile read button")
	_assert_true(tool._default_tile_apply_button != null, "map edit tool exposes default tile apply button")
	_assert_true(tool._target_atlas_browse_button != null, "map edit tool exposes target atlas browse button")
	_assert_true(not tool._target_atlas_path_edit.editable, "target atlas path is read-only status text")
	_assert_true(tool._target_sample_option.item_count >= 3, "map edit tool exposes sample atlas presets")
	_assert_true(tool._select_display_layer_button != null, "map edit tool exposes display layer selection")
	_assert_eq(tool._select_display_layer_button.text, "Select Internal TileMapLayer", "display layer button describes internal selection")
	_assert_true(tool._target_option.item_count >= 2, "map edit tool lists target TileMapLayer options")
	_assert_eq(tool.target_layer(), hex_layer, "map edit tool resolves Auto target to first HexTileMapLayer")
	var object_db = HexObjectDatabaseResource.new()
	var label_db = HexLabelDatabaseResource.new()
	tool.set_object_database(object_db)
	tool.set_label_database(label_db)
	_assert_eq(tool.object_database(), object_db, "map edit tool stores object database resource")
	_assert_eq(tool.label_database(), label_db, "map edit tool stores label database resource")

	scene_root.queue_free()
	tool.queue_free()
	await process_frame


func _test_plugin_handles_canvas_item_when_map_edit_ready() -> void:
	var plugin_source = FileAccess.get_file_as_string("res://addons/hex_map_kit/plugin.gd")
	var edit_tool_source = FileAccess.get_file_as_string("res://addons/hex_map_kit/editor/hex_map_edit_tool.gd")
	_assert_true(plugin_source.contains("func _handles(object: Object) -> bool:"), "plugin defines _handles for 2D viewport input")
	_assert_true(plugin_source.contains("hex_map_workspace.gd"), "plugin creates the workspace dock")
	_assert_true(plugin_source.contains("_workspace.name = \"Hex Map Workspace\""), "plugin gives workspace a stable dock name")
	_assert_true(plugin_source.contains("viewport_input_enabled"), "plugin gates viewport input through workspace")
	_assert_true(plugin_source.contains("hex_map_editor_session_state.gd"), "plugin creates shared editor session state")
	_assert_true(plugin_source.contains("set_editor_session_state"), "plugin wires shared editor session state into workspace")
	_assert_true(plugin_source.contains("object is CanvasItem"), "plugin handles CanvasItem viewport objects")
	_assert_true(not plugin_source.contains("_dock.name = \"Hex Map Generate\""), "plugin no longer registers a separate generation dock")
	_assert_true(
		edit_tool_source.contains("global_canvas_transform"),
		"map edit viewport conversion uses editor viewport global canvas transform"
	)
	_assert_true(
		not plugin_source.contains("get_editor_undo_redo"),
		"plugin does not wire EditorUndoRedoManager into the edit tool"
	)

	var tool = await _new_ready_edit_tool()
	var layer = TileMapLayer.new()
	root.add_child(layer)
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	tool.set_document(document)
	tool.set_target_layer(layer)

	_assert_true(tool.viewport_input_enabled(), "map edit tool enables viewport input when target and document are ready")
	tool.set_document(null)
	_assert_true(not tool.viewport_input_enabled(), "map edit tool disables viewport input without document")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_editor_session_state_shares_generate_target_and_edit_document() -> void:
	var session = HexMapEditorSessionState.new()
	var scene_root = Node2D.new()
	scene_root.name = "SessionSceneRoot"
	root.add_child(scene_root)
	var target_layer = HexTileMapLayer.new()
	target_layer.name = "SessionTarget"
	scene_root.add_child(target_layer)
	await process_frame

	var dock = await _new_ready_dock()
	dock.set_editor_session_state(session)
	dock.refresh_tile_layer_options(scene_root)
	dock._select_tile_layer_target(target_layer)
	_assert_eq(session.current_target_layer(), target_layer, "generation dock publishes selected target to session")

	var tool = await _new_ready_edit_tool()
	tool.set_editor_session_state(session)
	_assert_eq(tool.target_layer(), target_layer, "edit tool consumes session target")
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	tool.set_document(document)
	tool.set_document_path("res://session_document.tres")
	var import_resource = HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	tool.set_import_map_resource(import_resource, "res://session_import_map.tres")
	tool.set_export_path("res://session_export_map.tres")
	_assert_eq(session.current_document(), document, "edit tool publishes document to session")
	_assert_eq(session.document_source, HexMapEditTool.DOCUMENT_SOURCE_PROVIDED, "session records document source")
	_assert_eq(session.document_saved_path, "res://session_document.tres", "session records document saved path")
	_assert_eq(session.current_import_map(), import_resource, "session records import resource")
	_assert_eq(session.import_map_saved_path, "res://session_import_map.tres", "session records import map saved path")
	_assert_eq(session.export_saved_path, "res://session_export_map.tres", "session records export saved path")

	var second_tool = await _new_ready_edit_tool()
	second_tool.set_editor_session_state(session)
	_assert_eq(second_tool.target_layer(), target_layer, "later edit tool consumes existing session target")
	_assert_eq(second_tool.document(), document, "later edit tool consumes existing session document")
	_assert_eq(second_tool.document_path(), "res://session_document.tres", "later edit tool consumes existing document path")
	_assert_eq(
		second_tool.import_map_resource_selection(),
		import_resource,
		"later edit tool consumes existing import resource"
	)

	second_tool.queue_free()
	tool.queue_free()
	dock.queue_free()
	scene_root.queue_free()
	await process_frame


func _test_map_edit_tool_auto_target_uses_selected_layer() -> void:
	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var first_layer = TileMapLayer.new()
	first_layer.name = "FirstLayer"
	first_layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(first_layer.tile_set, true, Vector2i(64, 64))
	scene_root.add_child(first_layer)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "SelectedLayer"
	scene_root.add_child(selected_layer)
	await process_frame
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	selected_layer.apply_map(HexMapDocumentAdapter.to_map_resource(document))
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.refresh_target_layer_options(scene_root)
	tool.set_editor_selected_target_layer_for_test(selected_layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	_assert_eq(tool.target_layer(), selected_layer, "Auto target resolves to the editor-selected layer")
	_assert_true(tool.viewport_input_enabled(), "Auto target enables viewport input for the selected layer")
	var origin_local = selected_layer._tile_map.position + selected_layer.hex_to_display_local(HexVector.zero())
	_assert_true(tool.apply_local_position(origin_local), "Auto target edit applies to the selected layer")
	_assert_eq(selected_layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i(1, 0), "Auto target redraws selected layer")
	_assert_eq(first_layer.get_used_cells().size(), 0, "Auto target does not redraw the first layer when selection exists")
	_assert_eq(tool.last_edit_status()["target_resolution_reason"], "auto editor selection", "Last Edit records Auto selection reason")

	scene_root.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_auto_target_maps_hex_internal_layer_selection() -> void:
	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var hex_layer = HexTileMapLayer.new()
	hex_layer.name = "HexLayer"
	scene_root.add_child(hex_layer)
	await process_frame
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.refresh_target_layer_options(scene_root)

	_assert_eq(tool._target_option.item_count, 2, "target list exposes wrapper HexTileMapLayer only")
	_assert_eq(tool._target_option.get_item_text(1), "HexLayer", "target list labels HexTileMapLayer wrapper")
	tool.set_editor_selected_target_layer_for_test(hex_layer._tile_map)
	_assert_eq(tool.target_layer(), hex_layer, "Auto target maps selected internal TileMapLayer to HexTileMapLayer")
	_assert_eq(tool.last_edit_status().get("target_resolution_reason", ""), "", "fixture has no edit trace yet")
	_assert_true(tool.viewport_input_enabled(), "Auto target remains input-enabled through HexTileMapLayer wrapper")
	_assert_eq(
		tool.target_readiness_status()["target_class"],
		"HexTileMapLayer",
		"internal TileMapLayer selection reports wrapper target readiness"
	)

	scene_root.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_initializes_document_from_hex_target() -> void:
	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var data = HexMapData.rectangle(2, 1)
	var resource = HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_POINTY_TOP)
	var hex_layer = HexTileMapLayer.new()
	hex_layer.name = "RuntimeMap"
	scene_root.add_child(hex_layer)
	await process_frame
	hex_layer.hex_map = resource
	var tool = await _new_ready_edit_tool()
	tool.refresh_target_layer_options(scene_root)
	tool.set_editor_selected_target_layer_for_test(hex_layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	_assert_true(tool.document() != null, "map edit tool creates a document from selected HexTileMapLayer target")
	_assert_eq(tool._document_source, HexMapEditTool.DOCUMENT_SOURCE_TARGET, "target document source is recorded")
	_assert_eq(HexMapDocumentAdapter.to_map_resource(tool.document()).orientation, HexMapResource.ORIENTATION_POINTY_TOP, "target document preserves target map orientation")
	_assert_true(tool.viewport_input_enabled(), "target-derived document enables viewport input")
	var origin_local = hex_layer._tile_map.position + hex_layer.hex_to_display_local(HexVector.zero())
	_assert_true(tool.apply_local_position(origin_local), "target-derived document accepts viewport edit")
	_assert_true(HexMapDocumentAdapter.to_map_resource(tool.document()).to_map_data().has_wall(HexVector.zero()), "target-derived document mutates on edit")
	_assert_true(hex_layer.hex_map.to_map_data().has_wall(HexVector.zero()), "target-derived edit updates HexTileMapLayer resource")
	_assert_true(tool.debug_report_text().contains("document_source: target"), "debug report includes target document source")

	scene_root.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_imports_generated_map_resource() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var resource = HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_POINTY_TOP)
	var tool = await _new_ready_edit_tool()

	var document = tool.import_map_resource(resource)
	var exported = tool.export_map_resource()

	_assert_true(document != null, "map edit tool imports generated HexMapResource into a document")
	_assert_eq(exported.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "map edit tool export preserves orientation")
	_assert_keys_eq(exported.to_map_data().cells, data.cells, "map edit tool export preserves cells")
	_assert_keys_eq(exported.to_map_data().walls, data.walls, "map edit tool export preserves walls")

	var document_path = _test_resource_path("test_map_edit_tool_document.tres")
	var export_path = _test_resource_path("test_map_edit_tool_export.tres")
	var import_path = _test_resource_path("test_map_edit_tool_import_source.tres")
	_save_resource(import_path, resource)
	_assert_true(tool.save_document(document_path), "map edit tool saves document resource")
	_assert_true(tool.export_map_resource_to_path(export_path), "map edit tool saves exported HexMapResource")
	_assert_true(tool.import_map_resource_from_path(import_path), "map edit tool imports HexMapResource from path")
	_assert_true(load(document_path) != null, "map edit tool saved document can be loaded")
	_assert_true(load(export_path) is HexMapResource, "map edit tool exported map can be loaded")

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_path_file_handlers_and_action_states() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var map_resource = HexMapResource.from_map_data(data)
	var document = HexMapDocumentAdapter.from_map_resource(map_resource)
	var document_path = _test_resource_path("test_selector_document.tres")
	var import_path = _test_resource_path("test_selector_import_map.tres")
	var export_path = _test_resource_path("test_selector_export_map.tres")
	_save_resource(document_path, document)
	_save_resource(import_path, map_resource)

	var tool = await _new_ready_edit_tool()
	_assert_true(tool._document_save_button.disabled, "Save is disabled without a document")
	_assert_true(tool._document_save_as_button.disabled, "Save As is disabled without a document")
	_assert_true(tool._document_validate_button.disabled, "header Validate is disabled without a document")
	_assert_true(tool._import_map_button.disabled, "Convert is disabled while resource is empty")
	_assert_true(tool._document_open_button != null and not tool._document_open_button.disabled, "Document Open remains enabled")
	_assert_true(tool._export_button.disabled, "Export is disabled without document")

	tool.new_document()
	_assert_true(tool.document() != null, "New Document creates a document")
	_assert_true(tool._document_label.text.contains("Document: new"), "document header shows new document state")
	_assert_true(tool._document_label.text.contains("Dirty: yes"), "document header marks new document dirty")
	_assert_true(not tool._document_save_as_button.disabled, "Save As is enabled after New Document")

	tool._on_document_file_selected(document_path)
	_assert_true(tool.document() != null, "document file selected handler loads document")
	_assert_eq(tool.document_path(), document_path, "document file selected handler syncs path")
	_assert_eq(tool._document_source, HexMapEditTool.DOCUMENT_SOURCE_LOAD, "document file selected handler records load source")
	_assert_true(tool._document_label.text.contains("Saved: " + document_path), "document header shows saved path")
	_assert_true(tool._document_label.text.contains("Dirty: no"), "document header marks loaded document clean")
	_assert_true(not tool._document_save_button.disabled, "Save is enabled after document load")
	_assert_true(not tool._document_validate_button.disabled, "header Validate is enabled after document load")

	tool._on_import_map_file_selected(import_path)
	_assert_eq(tool.import_map_path(), import_path, "import file selected handler syncs path")
	_assert_true(tool.import_map_resource_selection() is HexMapResource, "import file selected handler stores resource selection")
	_assert_eq(tool._document_source, HexMapEditTool.DOCUMENT_SOURCE_IMPORT, "import file selected handler records import source")
	_assert_true(tool._document_label.text.contains("Document: converted"), "document header shows converted document state")
	_assert_true(tool._document_label.text.contains("Dirty: yes"), "document header marks converted document dirty")
	_assert_true(not tool._export_button.disabled, "Export is enabled after import")

	tool._on_export_file_selected(export_path)
	_assert_eq(tool.export_path(), export_path, "export file selected handler syncs path")
	_assert_true(load(export_path) is HexMapResource, "export file selected handler saves HexMapResource")

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_debug_report_copy_includes_reportable_state() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var layer = TileMapLayer.new()
	layer.name = "ReportLayer"
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	root.add_child(layer)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var origin_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true))

	_assert_true(tool.apply_local_position(origin_local), "debug report fixture records an edit")
	var report = tool.debug_report_text()
	_assert_true(report.contains("Hex Map Edit Debug Report"), "debug report has a stable header")
	_assert_true(report.contains("target_status:"), "debug report includes target status")
	_assert_true(report.contains("last_edit_status:"), "debug report includes raw last edit status")
	_assert_true(report.contains("target_resolution_reason:"), "debug report includes target resolution reason")
	_assert_true(report.contains("ReportLayer"), "debug report includes target path/name context")
	_assert_true(tool.copy_debug_report_to_clipboard(), "copy debug report produces clipboard text")
	_assert_eq(tool._last_copied_debug_report, report, "copy debug report stores the exact generated report")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_loads_saves_document_without_losing_typed_payloads() -> void:
	var document = _sample_editor_document()
	var document_path = _test_resource_path("test_map_edit_document.tres")
	var saved_path = _test_resource_path("test_map_edit_saved_document.tres")
	var export_path = _test_resource_path("test_map_edit_export.tres")
	_save_resource(document_path, document)

	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	_assert_true(
		layer.ensure_display_tiles(
			HexMapTileAdapter.SAMPLE_TILE_SIZE,
			4,
			Vector2i(0, 0),
			5,
			Vector2i(1, 0)
		),
			"canonical document target display tiles are configured"
		)

	var tool = await _new_ready_edit_tool()
	tool.set_target_layer(layer)
	_assert_true(tool.load_document(document_path), "map edit tool loads canonical document from path")
	_assert_eq(layer.hex_map.to_map_data().walls.size(), 1, "canonical document load applies terrain map to HexTileMapLayer")
	var initial_state = layer.display_state_for_hex(HexVector.zero())
	_assert_eq(initial_state["overlay_count"], 1, "canonical document load applies overlay assignment")
	_assert_eq(initial_state["object_count"], 1, "canonical document load applies object placement")
	_assert_eq(initial_state["label_count"], 1, "canonical document load applies label placement")

	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	tool.set_tile_payload(0, Vector2i(2, 0), 0)
	_assert_true(tool.apply_cell(HexVector.zero()), "map edit tool edits loaded canonical document")
	_assert_eq(
		tool.document().terrain_layers[0].tile_assignments[0]["atlas_coords"],
		Vector2i(2, 0),
		"canonical document edit updates typed terrain assignment"
	)

	_assert_true(tool.save_document(saved_path), "map edit tool saves loaded canonical document")
	_assert_true(tool.export_map_resource_to_path(export_path), "map edit tool exports map from loaded canonical document")
	var saved = ResourceLoader.load(saved_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	_assert_true(saved is HexMapDocumentResource, "saved canonical document loads as document resource")
	_assert_eq(saved.terrain_layers.size(), 1, "saved document keeps typed terrain layer")
	_assert_eq(saved.overlay_layers.size(), 1, "saved document keeps typed overlay layer")
	_assert_eq(saved.object_placements.size(), 1, "saved document keeps typed object placement")
	_assert_eq(saved.label_placements.size(), 1, "saved document keeps typed label placement")
	_assert_eq(
		saved.terrain_layers[0].tile_assignments[0]["atlas_coords"],
		Vector2i(2, 0),
		"saved document keeps edited typed terrain assignment"
	)
	var exported = ResourceLoader.load(export_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	_assert_true(exported is HexMapResource, "canonical document export loads as HexMapResource")
	_assert_eq(exported.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "canonical document export preserves orientation")
	_assert_eq(exported.to_map_data().walls.size(), 1, "canonical document export preserves walls")
	var save_status = tool.persistence_status()
	_assert_eq(save_status["cell_count"], 2, "canonical document save status reports cells")
	_assert_eq(save_status["wall_count"], 1, "canonical document save status reports walls")

	tool.queue_free()
	layer.queue_free()
	await process_frame


func _test_map_edit_tool_click_updates_document_with_undo_redo() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	var undo_redo = UndoRedo.new()
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_undo_redo(undo_redo)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	var origin_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true))
	_assert_true(tool.apply_local_position(origin_local), "map edit tool applies local click to document")
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "map edit tool click toggles wall in document")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "map edit tool click redraws wall tile")

	undo_redo.undo()
	_assert_true(not HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "map edit tool undo restores document")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i.ZERO, "map edit tool undo redraws floor tile")

	undo_redo.redo()
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "map edit tool redo restores document edit")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "map edit tool redo redraws wall tile")

	tool.set_edit_mode(HexMapEditTool.EditMode.SHAPE)
	var added = HexVector.q_axis().scaled(2)
	var added_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(added, true))
	_assert_true(tool.apply_local_position(added_local), "map edit tool shape mode can add a missing cell from local click")
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_cell(added), "map edit tool shape mode adds cell")

	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	tool.set_tile_payload(9, Vector2i(2, 3), 1)
	_assert_true(tool.apply_cell(HexVector.zero()), "map edit tool applies floor tile override")
	var tile_entries = HexMapDocumentAdapter.document_tile_entries(document)
	_assert_eq(tile_entries[0]["source_id"], 9, "map edit tool stores tile assignment source")
	_assert_eq(tile_entries[0]["atlas_coords"], Vector2i(2, 3), "map edit tool stores tile assignment atlas")

	tool.set_edit_mode(HexMapEditTool.EditMode.OBJECT)
	tool.set_object_payload("door", {"locked": true}, 90.0, "iron", "flag:opened")
	var property_row = tool._object_properties_table.get_root().get_first_child()
	_assert_eq(property_row.get_text(0), "locked", "map edit tool object property table shows property key")
	_assert_eq(property_row.get_text(1), "true", "map edit tool object property table shows property value")
	_assert_true(tool.apply_cell(HexVector.zero()), "map edit tool applies object payload")
	var object_entries = HexMapDocumentAdapter.document_object_entries(document)
	_assert_eq(object_entries[0]["object_id"], "door", "map edit tool stores object payload")
	_assert_eq(object_entries[0]["properties"]["locked"], true, "map edit tool stores object properties")
	_assert_eq(document.object_placements[0].object_id, "door", "map edit tool stores typed object placement")
	_assert_eq(document.object_placements[0].rotation_degrees, 90.0, "map edit tool stores typed object rotation")
	_assert_eq(document.object_placements[0].variant, "iron", "map edit tool stores typed object variant")
	_assert_eq(document.object_placements[0].spawn_condition, "flag:opened", "map edit tool stores typed object spawn condition")
	_assert_eq(document.object_placements[0].properties["locked"], true, "map edit tool stores typed object properties")

	undo_redo.undo()
	_assert_eq(document.object_placements.size(), 0, "map edit tool undo removes typed object placement")
	undo_redo.redo()
	_assert_eq(document.object_placements[0].variant, "iron", "map edit tool redo restores object variant")
	_assert_eq(document.object_placements[0].properties["locked"], true, "map edit tool redo restores object properties")

	tool.set_edit_mode(HexMapEditTool.EditMode.LABEL)
	tool.set_label_payload("room", "Entry")
	_assert_true(tool.apply_cell(HexVector.zero()), "map edit tool applies label payload")
	var label_entries = HexMapDocumentAdapter.document_label_entries(document)
	_assert_eq(label_entries[0]["label_id"], "room", "map edit tool stores label payload")
	_assert_eq(label_entries[0]["text"], "Entry", "map edit tool stores label text")

	undo_redo.clear_history()
	undo_redo.free()
	layer.free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_forward_canvas_gui_input_uses_viewport_transform() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var layer = TileMapLayer.new()
	layer.position = Vector2(30.0, 18.0)
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	root.add_child(layer)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var canvas_transform = Transform2D(0.0, Vector2(120.0, -40.0))
	tool.set_viewport_canvas_transform_for_test(canvas_transform)
	var origin_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true))
	var scene_position = layer.to_global(origin_local)
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = canvas_transform * scene_position

	_assert_true(tool.forward_canvas_gui_input(press), "map edit tool accepts viewport click through transform bridge")
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "viewport click toggles wall in document")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "viewport click redraws target layer")
	_assert_true(bool(tool.last_edit_status().get("applied", false)), "viewport click records target redraw status")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_target_selection_sync_for_explicit_target() -> void:
	var scene_root = Node2D.new()
	root.add_child(scene_root)
	var first_layer = HexTileMapLayer.new()
	first_layer.name = "FirstLayer"
	scene_root.add_child(first_layer)
	var second_layer = HexTileMapLayer.new()
	second_layer.name = "SecondLayer"
	scene_root.add_child(second_layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.refresh_target_layer_options(scene_root)
	var before_count = tool._target_selection_sync_request_count

	tool._target_option.select(2)
	tool._on_target_selected(2)

	_assert_eq(tool.target_layer(), second_layer, "explicit target selection chooses requested layer")
	_assert_true(
		tool._target_selection_sync_request_count > before_count,
		"explicit target selection requests editor selection sync"
	)
	_assert_eq(tool._last_selection_sync_target, second_layer, "target selection sync records selected layer")
	var before_refresh_count = tool._target_selection_sync_request_count
	tool.refresh_target_layer_options(scene_root)
	_assert_eq(tool.target_layer(), second_layer, "target refresh preserves explicit selected layer")
	_assert_true(
		tool._target_selection_sync_request_count > before_refresh_count,
		"target refresh requests editor selection sync for preserved target"
	)

	scene_root.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_forward_canvas_gui_input_reports_no_editable_cell() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	root.add_child(layer)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var outside_local = layer.map_to_local(Vector2i(20, 20))
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = layer.to_global(outside_local)

	_assert_true(tool.forward_canvas_gui_input(press), "viewport click outside document is consumed by edit tool")
	_assert_eq(tool._status_label.text, "No editable cell.", "viewport click reports no editable cell")
	var origin_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true))
	var valid_press = InputEventMouseButton.new()
	valid_press.button_index = MOUSE_BUTTON_LEFT
	valid_press.pressed = true
	valid_press.position = layer.to_global(origin_local)
	_assert_true(tool.forward_canvas_gui_input(valid_press), "valid viewport click still works after an invalid click")
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "valid click after invalid click edits document")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_target_readiness_reports_plain_tile_map_layer() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool._apply_document_to_target()

	var status = tool.target_readiness_status()
	_assert_eq(status["target_class"], "TileMapLayer", "plain target readiness reports TileMapLayer class")
	_assert_true(bool(status["tile_set_present"]), "plain target readiness reports TileSet presence")
	_assert_true(bool(status["ready"]), "plain target readiness is ready with a TileSet")
	_assert_eq(status["used_cell_count"], 2, "plain target readiness reports used cell count")
	_assert_eq(status["floor_atlas_coords"], Vector2i.ZERO, "plain target readiness reports default floor atlas")
	_assert_eq(status["wall_atlas_coords"], Vector2i(1, 0), "plain target readiness reports default wall atlas")
	_assert_true(tool._target_status_label.text.contains("TileMapLayer"), "plain target readiness appears in Dock detail")

	layer.free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_target_readiness_reports_hex_tile_map_layer_loop_state() -> void:
	var resource = HexMapResource.from_map_data(HexMapData.square(3, true))
	var document = HexMapDocumentAdapter.from_map_resource(resource)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.floor_source_id = 4
	layer.floor_atlas_coords = Vector2i(2, 0)
	layer.wall_source_id = 5
	layer.wall_atlas_coords = Vector2i(3, 0)
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	layer.apply_map(resource)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)

	var status = tool.target_readiness_status()
	_assert_eq(status["target_class"], "HexTileMapLayer", "hex target readiness reports HexTileMapLayer class")
	_assert_true(bool(status["is_hex_tile_map_layer"]), "hex target readiness marks HexTileMapLayer")
	_assert_true(bool(status["tile_set_present"]), "hex target readiness reports internal TileSet presence")
	_assert_eq(status["floor_source_id"], 4, "hex target readiness reports floor source id")
	_assert_eq(status["floor_atlas_coords"], Vector2i(2, 0), "hex target readiness reports floor atlas")
	_assert_eq(status["wall_source_id"], 5, "hex target readiness reports wall source id")
	_assert_eq(status["wall_atlas_coords"], Vector2i(3, 0), "hex target readiness reports wall atlas")
	_assert_eq(status["loop_display_mode"], HexTileMapLayer.LOOP_DISPLAY_TORIC, "hex target readiness reports loop mode")
	_assert_true(tool._target_status_label.text.contains("loop=toric"), "hex target readiness appears in Dock detail")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_preserves_plain_target_tile_settings_when_redrawing() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	var image = Image.create(256, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture = ImageTexture.create_from_image(image)
	HexMapTileAdapter.configure_atlas_tile_set(
		layer.tile_set,
		texture,
		true,
		Vector2i(64, 64),
		0,
		[Vector2i(2, 0), Vector2i(3, 0)]
	)
	HexMapTileAdapter.apply_to_tile_map_layer(
		layer,
		data,
		0,
		Vector2i(2, 0),
		0,
		Vector2i(3, 0),
		true,
		true
	)
	root.add_child(layer)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	var readiness = tool.target_readiness_status()
	_assert_eq(readiness["floor_atlas_coords"], Vector2i(2, 0), "map edit infers plain target floor atlas")
	_assert_eq(readiness["wall_atlas_coords"], Vector2i(3, 0), "map edit infers plain target wall atlas")
	var origin_map_cell = HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true)
	var origin_local = layer.map_to_local(origin_map_cell)

	_assert_true(tool.apply_local_position(origin_local), "map edit redraws using inferred target tile settings")
	_assert_eq(
		layer.get_cell_atlas_coords(origin_map_cell),
		Vector2i(3, 0),
		"map edit redraw changes clicked floor to target wall atlas"
	)
	var trace = tool.last_edit_status()
	_assert_eq(trace["display_atlas_before"], Vector2i(2, 0), "last edit trace records inferred floor atlas before edit")
	_assert_eq(trace["display_atlas_after"], Vector2i(3, 0), "last edit trace records inferred wall atlas after edit")
	_assert_true(bool(trace["display_changed"]), "last edit trace detects display change with inferred tile settings")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_target_atlas_settings_use_target_tileset() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var hex_layer = HexTileMapLayer.new()
	root.add_child(hex_layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(hex_layer)
	hex_layer.floor_source_id = 0
	hex_layer.floor_atlas_coords = Vector2i.ZERO
	hex_layer.wall_source_id = 0
	hex_layer.wall_atlas_coords = Vector2i(1, 0)

	_assert_true(
		tool._apply_target_atlas_path(
			"res://addons/hex_map_kit/assets/tactics_flat_top_hex_tiles_64x57_10.png",
			Vector2i(64, 57)
		),
		"map edit tool applies sample atlas to target TileSet"
	)
	var tile_set = hex_layer.display_tile_set()
	_assert_true(tile_set.has_source(0), "target atlas setup creates source on HexTileMapLayer TileSet")
	_assert_eq(tile_set.tile_size, Vector2i(64, 57), "target atlas setup stores tile size on Target TileSet")
	_assert_eq(HexMapDocumentAdapter.document_tile_entries(document).size(), 0, "target atlas setup does not write asset data into document tile assignments")
	tool._apply_document_to_target()
	_assert_eq(hex_layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i.ZERO, "target atlas setup draws floor atlas after apply")

	var replacement = TileSet.new()
	_assert_true(tool._apply_target_tile_set(replacement), "map edit tool accepts explicit Target TileSet resource")
	_assert_eq(hex_layer.display_tile_set(), replacement, "explicit Target TileSet is stored on HexTileMapLayer display layer")

	hex_layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_catalog_selectors_drive_defaults_and_payloads() -> void:
	var tool = await _new_ready_edit_tool()
	_assert_true(tool.tile_catalog() != null, "map edit tool loads sample tile catalog")
	_assert_true(tool._catalog_entries_tree != null, "map edit tool exposes catalog entry list")
	_assert_true(tool._catalog_add_atlas_button != null, "map edit tool exposes Add Atlas Entry action")
	_assert_true(tool._catalog_add_scene_button != null, "map edit tool exposes Add Scene Entry action")
	_assert_true(tool._catalog_validate_button != null, "map edit tool exposes Validate Catalog action")
	var catalog_rows = tool.catalog_entry_rows()
	_assert_true(catalog_rows.size() >= 3, "catalog screen lists sample catalog entries")
	var floor_row = _catalog_row_for_key(catalog_rows, "terrain.floor")
	_assert_eq(floor_row["type"], HexTileCatalogEntry.TYPE_ATLAS, "catalog row shows atlas entry type")
	_assert_true(String(floor_row["preview"]).begins_with("tile "), "catalog row shows atlas preview")
	_assert_eq(floor_row["status"], "ok", "catalog row shows clean entry status")
	var summary = tool.catalog_validation_summary()
	_assert_eq(summary["errors"], 0, "catalog validation summary starts clean")
	_assert_eq(summary["warnings"], 0, "catalog validation summary starts without warnings")

	var packed_scene = PackedScene.new()
	var scene_root = Node2D.new()
	_assert_eq(packed_scene.pack(scene_root), OK, "test PackedScene packs for catalog scene entry")
	tool._on_catalog_scene_changed(packed_scene)
	var catalog_entry_count = tool.tile_catalog().entries.size()
	tool._on_add_catalog_scene_entry_pressed()
	var scene_entry = tool.tile_catalog().entries[catalog_entry_count]
	_assert_eq(scene_entry.entry_type, HexTileCatalogEntry.TYPE_SCENE, "Add Scene Entry creates scene catalog entry")
	_assert_eq(scene_entry.scene, packed_scene, "scene catalog entry stores PackedScene resource")
	scene_root.free()

	tool._on_add_catalog_atlas_entry_pressed()
	_assert_eq(tool.tile_catalog().entries.size(), catalog_entry_count + 2, "Add Atlas Entry appends catalog entry")
	tool._on_validate_catalog_pressed()
	var updated_rows = tool.catalog_entry_rows()
	var added_scene_row = _catalog_row_for_key(updated_rows, scene_entry.key)
	_assert_eq(added_scene_row["type"], HexTileCatalogEntry.TYPE_SCENE, "catalog rows include newly added scene entry")
	_assert_true(tool._default_floor_catalog_option.item_count >= 2, "map edit tool default floor catalog lists sample entries")
	_assert_true(tool._default_wall_catalog_option.item_count >= 2, "map edit tool default wall catalog lists sample entries")

	tool._select_catalog_option_by_key(tool._default_floor_catalog_option, "terrain.floor")
	tool._on_default_floor_catalog_selected(tool._default_floor_catalog_option.selected)
	tool._select_catalog_option_by_key(tool._default_wall_catalog_option, "terrain.wall")
	tool._on_default_wall_catalog_selected(tool._default_wall_catalog_option.selected)
	var defaults = tool._default_tile_settings_from_controls()
	_assert_eq(defaults["floor_catalog_key"], "terrain.floor", "default floor selector stores catalog key")
	_assert_eq(defaults["floor_atlas_coords"], Vector2i(0, 0), "default floor selector resolves atlas coords")
	_assert_eq(defaults["wall_catalog_key"], "terrain.wall", "default wall selector stores catalog key")
	_assert_eq(defaults["wall_atlas_coords"], Vector2i(1, 0), "default wall selector resolves atlas coords")

	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	tool._select_catalog_option_by_key(tool._tile_catalog_option, "terrain.floor")
	tool._on_tile_catalog_selected(tool._tile_catalog_option.selected)
	_assert_eq(tool._floor_tile_payload["catalog_key"], "terrain.floor", "floor tile payload stores catalog key")
	_assert_eq(tool._floor_tile_payload["atlas_coords"], Vector2i(0, 0), "floor tile payload resolves catalog atlas")
	_assert_true(not _control_row_visible(tool._tile_source_spin), "floor tile mode hides source id paint control")
	_assert_true(not _control_row_visible(tool._tile_atlas_x_spin), "floor tile mode hides atlas coordinate paint controls")

	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_TILE)
	tool._select_catalog_option_by_key(tool._tile_catalog_option, "terrain.wall")
	tool._on_tile_catalog_selected(tool._tile_catalog_option.selected)
	_assert_eq(tool._wall_tile_payload["catalog_key"], "terrain.wall", "wall tile payload stores catalog key")
	_assert_eq(tool._wall_tile_payload["atlas_coords"], Vector2i(1, 0), "wall tile payload resolves catalog atlas")

	tool.set_edit_mode(HexMapEditTool.EditMode.OVERLAY_TILE)
	tool._select_catalog_option_by_key(tool._tile_catalog_option, "overlay.treasure")
	tool._on_tile_catalog_selected(tool._tile_catalog_option.selected)
	_assert_eq(tool._overlay_tile_payload["catalog_key"], "overlay.treasure", "overlay tile payload stores catalog key")

	tool.set_edit_mode(HexMapEditTool.EditMode.OBJECT)
	tool._select_catalog_option_by_key(tool._object_catalog_option, "object.spawn_marker")
	tool._on_object_catalog_selected(tool._object_catalog_option.selected)
	_assert_eq(tool._object_payload["object_id"], "object.spawn_marker", "object selector stores catalog key as object default")
	_assert_eq(tool._object_id_edit.text, "object.spawn_marker", "object selector updates object id text")
	_assert_true(not _control_row_visible(tool._object_id_edit), "object mode hides raw object id paint control")

	var invalid_catalog = HexTileCatalogResource.new()
	invalid_catalog.catalog_id = "broken"
	invalid_catalog.display_name = "Broken Catalog"
	var invalid_entry = HexTileCatalogEntry.new()
	invalid_entry.key = "broken.scene"
	invalid_entry.display_name = "Broken Scene"
	invalid_entry.entry_type = HexTileCatalogEntry.TYPE_SCENE
	invalid_catalog.add_entry(invalid_entry)
	tool.set_tile_catalog(invalid_catalog)
	tool._on_validate_catalog_pressed()
	var catalog_issue_rows = tool._validation_dashboard.issue_rows()
	var scene_issue_index := -1
	for index in range(catalog_issue_rows.size()):
		if String(catalog_issue_rows[index].get("rule_id", "")) == "catalog.scene_missing":
			scene_issue_index = index
			break
	_assert_true(scene_issue_index >= 0, "validation dashboard lists catalog scene issue")
	var scene_issue_row = catalog_issue_rows[scene_issue_index]
	_assert_eq(scene_issue_row.get("domain", ""), "Catalog", "catalog issue row is grouped by Catalog domain")
	_assert_eq(scene_issue_row.get("severity_label", ""), "Error", "catalog issue row exposes severity label")
	_assert_true(String(scene_issue_row.get("focus_target", "")).contains("Catalog entry"), "catalog issue row exposes entry focus target")
	_assert_true(String(scene_issue_row.get("fix_suggestion", "")).contains("PackedScene"), "catalog issue row exposes fix suggestion")
	_assert_true(tool.select_validation_issue(scene_issue_index), "catalog validation issue can be selected")
	var catalog_focus = tool.validation_focus_status()
	_assert_eq(catalog_focus.get("focus_type", ""), "catalog_entry", "catalog issue selection records catalog focus type")
	_assert_eq(int(catalog_focus.get("catalog_entry_index", -1)), 0, "catalog issue selection records entry index")
	_assert_true(bool(catalog_focus.get("focused", false)), "catalog issue selection focuses catalog row")
	_assert_true(tool._validation_dashboard._selected_detail_label.text.contains("Fix:"), "selected issue detail shows fix suggestion")

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_object_palette_uses_definitions_and_typed_properties() -> void:
	var tool = await _new_ready_edit_tool()
	var database = HexObjectDatabaseResource.new()
	var door = HexObjectDefinitionResource.new()
	door.id = "object.door"
	door.display_name = "Door"
	door.tags = PackedStringArray(["door", "interactive"])
	door.default_properties = {
		"health": 10,
		"label": "North",
		"locked": true,
		"speed": 1.5,
		"state": {
			"type": "enum",
			"options": ["closed", "open"],
			"value": "closed",
		},
	}
	database.add_definition(door)
	tool.set_object_database(database)
	tool.set_edit_mode(HexMapEditTool.EditMode.OBJECT)

	var rows = tool.object_definition_rows()
	var door_row = _object_definition_row_for_id(rows, "object.door")
	_assert_eq(door_row["display_name"], "Door", "object palette lists definition display name")
	_assert_eq(door_row["scene"], "missing scene", "object palette reports missing scene before resource selection")
	_assert_eq(tool._object_payload["object_id"], "object.door", "object database selection chooses first object key")
	_assert_true(_control_row_visible(tool._object_definition_tree), "object mode shows definition list")
	_assert_true(_control_row_visible(tool._object_property_editor), "object mode shows typed property editor")
	_assert_true(not _control_row_visible(tool._object_properties_edit), "object mode hides raw JSON properties")
	_assert_true(not _control_row_visible(tool._object_properties_table), "object mode hides raw property table")

	var packed_scene = PackedScene.new()
	var scene_root = Node2D.new()
	_assert_eq(packed_scene.pack(scene_root), OK, "test PackedScene packs for object definition")
	tool._select_object_definition("object.door")
	tool._on_object_definition_scene_changed(packed_scene)
	_assert_eq(door.scene, packed_scene, "object definition scene picker stores PackedScene")
	door_row = _object_definition_row_for_id(tool.object_definition_rows(), "object.door")
	_assert_eq(door_row["scene"], "PackedScene", "object definition row shows PackedScene status")

	tool._select_object_key_option_by_key("object.door")
	tool._on_object_catalog_selected(tool._object_catalog_option.selected)
	_assert_eq(tool._object_payload["object_id"], "object.door", "object key selector stores definition id")
	var control_types = tool.object_property_control_types()
	_assert_eq(control_types["locked"], "bool", "bool property uses CheckBox")
	_assert_eq(control_types["health"], "number", "int property uses SpinBox")
	_assert_eq(control_types["speed"], "number", "float property uses SpinBox")
	_assert_eq(control_types["label"], "string", "string property uses LineEdit")
	_assert_eq(control_types["state"], "enum", "enum property uses OptionButton")

	tool._on_object_property_bool_toggled(false, "locked")
	tool._on_object_property_number_changed(12.0, "health", false)
	tool._on_object_property_number_changed(2.25, "speed", true)
	tool._on_object_property_text_changed("South", "label")
	var state_option = tool._object_property_controls["state"] as OptionButton
	state_option.select(1)
	tool._on_object_property_enum_selected(1, "state", state_option)
	var properties = tool._object_payload["properties"]
	_assert_eq(properties["locked"], false, "typed bool editor updates placement property")
	_assert_eq(properties["health"], 12, "typed int editor updates placement property")
	_assert_eq(properties["speed"], 2.25, "typed float editor updates placement property")
	_assert_eq(properties["label"], "South", "typed string editor updates placement property")
	_assert_eq(properties["state"], "open", "typed enum editor updates placement property")

	var count_before = database.definitions.size()
	tool._on_add_object_definition_pressed()
	_assert_eq(database.definitions.size(), count_before + 1, "Add Object Definition appends definition")

	scene_root.free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_layer_stack_screen_manages_roles() -> void:
	var tool = await _new_ready_edit_tool()
	var rows = tool.layer_stack_rows()
	var terrain_row = _layer_stack_row_for_role(rows, HexLayerStackResource.ROLE_TERRAIN)
	_assert_eq(terrain_row["node"], "TerrainTileMapLayer", "layer stack screen lists terrain node")
	_assert_eq(terrain_row["status"], "missing", "layer stack row starts missing without HexTileMapLayer target")
	_assert_eq(terrain_row["writable"], "document", "layer stack row exposes writable source")

	tool._on_layer_stack_template_selected(1)
	_assert_eq(tool.layer_stack_rows().size(), 3, "minimal layer stack template has three roles")
	tool._on_layer_stack_template_selected(0)
	_assert_eq(tool.layer_stack_rows().size(), 7, "standard layer stack template has seven roles")

	var data = HexMapData.rectangle(1, 1)
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame

	tool.set_document(document)
	tool.set_target_layer(layer)
	_assert_true(tool._layer_stack_create_missing_button.disabled == false, "layer stack create action is enabled for HexTileMapLayer document")
	tool._on_create_missing_layers_pressed()
	terrain_row = _layer_stack_row_for_role(tool.layer_stack_rows(), HexLayerStackResource.ROLE_TERRAIN)
	_assert_eq(terrain_row["status"], "ok", "Create Missing Layers creates terrain role layer")
	var terrain_node = layer.layer_for_stack_role(HexLayerStackResource.ROLE_TERRAIN) as TileMapLayer
	_assert_true(terrain_node != null, "terrain role resolves to TileMapLayer after create")

	tool._selected_layer_stack_role = HexLayerStackResource.ROLE_TERRAIN
	tool._on_clear_layer_stack_role_pressed()
	_assert_eq(terrain_node.get_used_cells().size(), 0, "Clear Role clears selected role layer")
	tool._on_apply_layer_stack_document_pressed()
	_assert_true(terrain_node.get_used_cells().size() > 0, "Apply Document repopulates terrain role layer")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_reports_missing_catalog_assignment_validation() -> void:
	var data = HexMapData.rectangle(1, 1)
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_tile_override(document, HexVector.zero(), {
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 8,
		"atlas_coords": Vector2i(4, 5),
	})
	var layer = TileMapLayer.new()
	layer.name = "CatalogFallbackLayer"
	root.add_child(layer)
	await process_frame

	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool._validation_dashboard._validate_button.pressed.emit()
	var rows = tool._validation_dashboard.issue_rows()
	var has_missing_assignment := false
	for row in rows:
		if String(row.get("rule_id", "")) == "document.tile_assignment_missing":
			has_missing_assignment = true
	_assert_true(has_missing_assignment, "validation dashboard reports missing catalog assignment")
	var report = tool.debug_report_text()
	_assert_true(not report.contains("catalog_warning_count"), "debug report omits compatibility warning count")
	_assert_true(report.contains("document.tile_assignment_missing"), "debug report includes validation rule id")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_validation_dashboard_groups_and_focuses_cell_issue() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_label(document, HexVector.apply_basis(4, 0, 0), {
		"label_id": "outside",
		"text": "Outside",
	})
	HexMapDocumentAdapter.set_object(document, HexVector.q_axis(), {"object_id": "chest"})
	var hex_layer = HexTileMapLayer.new()
	hex_layer.name = "ValidationLayer"
	root.add_child(hex_layer)
	await process_frame
	hex_layer.apply_map(HexMapDocumentAdapter.to_map_resource(document))

	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(hex_layer)
	tool._validation_dashboard._validate_button.pressed.emit()

	var summary = tool.validation_dashboard_summary()
	_assert_true(int(summary.get("errors", 0)) >= 2, "validation dashboard reports error count")
	_assert_true(int(summary.get("groups", 0)) >= 2, "validation dashboard groups validation rows")
	var inspector_summary = tool.document_inspector_summary()
	_assert_true(int(inspector_summary["validation"].get("errors", 0)) >= 2, "document inspector mirrors validation error count")
	_assert_true(tool._document_inspector._validation_summary_label.text.contains("errors="), "document inspector shows validation summary")
	var rows = tool._validation_dashboard.issue_rows()
	_assert_true(rows.size() >= 2, "validation dashboard exposes issue rows")
	_assert_true(String(rows[0].get("group_key", "")).contains("/"), "validation issue row stores grouped key")
	_assert_true(tool._validation_dashboard._summary_label.text.contains("errors="), "validation summary label includes error count")

	var wall_issue_index := -1
	for index in range(rows.size()):
		if String(rows[index].get("rule_id", "")) == "document.object_on_wall":
			wall_issue_index = index
			break
	_assert_true(wall_issue_index >= 0, "validation dashboard lists object-on-wall issue")
	var wall_row = rows[wall_issue_index]
	_assert_eq(wall_row.get("domain", ""), "Object", "object issue row is grouped by Object domain")
	_assert_eq(wall_row.get("severity_label", ""), "Error", "object issue row exposes severity label")
	_assert_true(String(wall_row.get("focus_target", "")).contains("Cell"), "object issue row exposes cell focus target")
	_assert_true(String(wall_row.get("fix_suggestion", "")).contains("floor"), "object issue row exposes fix suggestion")
	_assert_true(tool.select_validation_issue(wall_issue_index), "validation dashboard selects a cell-scoped issue")
	var selected = tool.selected_validation_issue()
	var focus = tool.validation_focus_status()
	_assert_eq(selected.get("rule_id", ""), "document.object_on_wall", "selected validation issue records rule id")
	_assert_eq(focus.get("domain", ""), "Object", "validation issue focus records domain")
	_assert_eq(focus.get("focus_type", ""), "cell", "validation issue focus records cell focus type")
	_assert_eq(focus.get("cell", Vector3i.ZERO), Vector3i(1, 0, 0), "validation issue focus records selected cell")
	_assert_eq(focus.get("cell_key", ""), HexVector.q_axis().key(), "validation issue focus records cell key")
	_assert_eq(bool(focus.get("focused", false)), true, "validation issue focus marks existing cell focused")
	_assert_true(hex_layer._highlights.has(HexVector.q_axis().key()), "cell-scoped validation issue highlights HexTileMapLayer target")
	_assert_true(tool._validation_dashboard._selected_detail_label.text.contains("Fix:"), "selected cell issue detail shows fix suggestion")

	hex_layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_debug_report_includes_validation_summary_without_status_bloat() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_object(document, HexVector.q_axis(), {"object_id": "chest"})
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.validate_document_now()

	var report = tool.debug_report_text()
	_assert_true(report.contains("validation_summary:"), "edit debug report includes validation summary")
	_assert_true(report.contains("validation_issues:"), "edit debug report includes validation issue rows")
	_assert_true(report.contains("document.object_on_wall"), "edit debug report includes validation rule id")
	_assert_true(
		not tool._target_status_label.text.contains("document.object_on_wall"),
		"target status label does not include validation issue dump"
	)

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_target_status_reports_tileset_and_overlay_payload() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var hex_layer = HexTileMapLayer.new()
	root.add_child(hex_layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(hex_layer)
	tool.set_overlay_tile_payload("Treasure", 4, Vector2i(2, 0), 1)
	_assert_true(
		tool._apply_target_atlas_path(
			"res://addons/hex_map_kit/assets/tactics_flat_top_hex_tiles_64x57_10.png",
			Vector2i(64, 57)
		),
		"target status test configures target atlas"
	)
	var status = tool.target_readiness_status()
	_assert_true(bool(status["tile_set_present"]), "target status reports TileSet presence")
	_assert_true(int(status["tile_set_source_count"]) >= 1, "target status reports source count")
	_assert_eq(status["tile_size"], Vector2i(64, 57), "target status reports tile size")
	_assert_eq(status["overlay_item_key"], "Treasure", "target status reports overlay item key")
	_assert_eq(status["overlay_source_id"], 4, "target status reports overlay payload source")
	_assert_true(status.has("overlay_tile_visible"), "target status reports overlay visibility")
	_assert_true(tool._target_status_label.text.contains("overlay=Treasure"), "target status label includes overlay payload")

	hex_layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_last_edit_trace_distinguishes_document_and_redraw() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	root.add_child(layer)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	tool._apply_document_to_target()
	var origin_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true))
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = layer.to_global(origin_local)

	_assert_true(tool.forward_canvas_gui_input(press), "last edit trace accepts viewport click")
	var trace = tool.last_edit_status()
	_assert_true(bool(trace["document_changed"]), "last edit trace records document mutation")
	_assert_true(bool(trace["target_applied"]), "last edit trace records target apply")
	_assert_true(bool(trace["display_changed"]), "last edit trace records display tile change")
	_assert_true(not bool(trace["wall_before"]), "last edit trace records previous floor state")
	_assert_true(bool(trace["wall_after"]), "last edit trace records next wall state")
	_assert_eq(trace["display_atlas_before"], Vector2i.ZERO, "last edit trace records floor atlas before edit")
	_assert_eq(trace["display_atlas_after"], Vector2i(1, 0), "last edit trace records wall atlas after edit")
	_assert_eq(trace["target_used_cells_before"], 2, "last edit trace records used cells before edit")
	_assert_eq(trace["target_used_cells_after"], 2, "last edit trace records used cells after edit")
	_assert_true(tool._last_edit_detail_label.text.contains("document=yes"), "last edit trace appears in Dock detail")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_last_edit_trace_reports_target_apply_failure() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	_assert_true(tool.apply_cell(HexVector.zero()), "last edit trace mutates document without a target")
	var trace = tool.last_edit_status()
	_assert_true(bool(trace["document_changed"]), "target failure trace records document mutation")
	_assert_true(not bool(trace["target_applied"]), "target failure trace records target apply failure")
	_assert_true(not bool(trace["display_changed"]), "target failure trace keeps display unchanged")
	_assert_eq(trace["display_atlas_before"], Vector2i(-1, -1), "target failure trace has no display atlas before")
	_assert_eq(trace["display_atlas_after"], Vector2i(-1, -1), "target failure trace has no display atlas after")
	_assert_true(tool._last_edit_detail_label.text.contains("target=no"), "target failure trace appears in Dock detail")

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_persistence_checkpoint_reports_save_and_export_counts() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	var document_path = _test_resource_path("test_map_edit_visibility_document.tres")
	var export_path = _test_resource_path("test_map_edit_visibility_export.tres")

	_assert_true(tool.save_document(document_path), "persistence checkpoint saves document")
	var save_status = tool.persistence_status()
	_assert_eq(save_status["operation"], "save_document", "persistence checkpoint records save operation")
	_assert_eq(save_status["path"], document_path, "persistence checkpoint records save path")
	_assert_true(bool(save_status["ok"]), "persistence checkpoint records save success")
	_assert_eq(save_status["resource_class"], "HexMapDocumentResource", "persistence checkpoint records document class")
	_assert_eq(save_status["cell_count"], 2, "persistence checkpoint records save cell count")
	_assert_eq(save_status["wall_count"], 1, "persistence checkpoint records save wall count")

	_assert_true(tool.export_map_resource_to_path(export_path), "persistence checkpoint exports map")
	var export_status = tool.persistence_status()
	_assert_eq(export_status["operation"], "export_map", "persistence checkpoint records export operation")
	_assert_eq(export_status["path"], export_path, "persistence checkpoint records export path")
	_assert_true(bool(export_status["ok"]), "persistence checkpoint records export success")
	_assert_eq(export_status["resource_class"], "HexMapResource", "persistence checkpoint records export class")
	_assert_eq(export_status["cell_count"], 2, "persistence checkpoint records export cell count")
	_assert_eq(export_status["wall_count"], 1, "persistence checkpoint records export wall count")
	_assert_true(tool._persistence_detail_label.text.contains("HexMapResource"), "persistence checkpoint appears in Dock detail")

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_local_hit_uses_hex_tile_map_layer() -> void:
	var data = HexMapData.square(3, true)
	var resource = HexMapResource.from_map_data(data)
	var document = HexMapDocumentAdapter.from_map_resource(resource)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	layer.apply_map(resource)
	await process_frame

	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var wrapped_visual = HexVector.apply_basis(3, 0, 0)
	var hit_local = layer._tile_map.position + layer.hex_to_display_local(wrapped_visual)

	_assert_true(tool.apply_local_position(hit_local), "map edit tool uses HexTileMapLayer loop-aware hit")
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "map edit tool edits canonical toric cell from visual duplicate")
	_assert_true(layer.hex_map.to_map_data().has_wall(HexVector.zero()), "map edit tool updates HexTileMapLayer hex_map resource")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_hex_target_uses_command_apply_path() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var layer = CountingHexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var undo_redo = UndoRedo.new()
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_undo_redo(undo_redo)
	tool._apply_document_to_target()
	var redraw_count_after_full_apply = layer.redraw_count
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	_assert_true(tool.apply_cell(HexVector.zero()), "Hex target edit uses command apply path")
	_assert_eq(layer.apply_document_cell_count, 0, "Hex target edit does not call apply_document_cell")
	_assert_eq(layer.redraw_count, redraw_count_after_full_apply, "Hex target edit does not call full redraw")
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "Hex target command updates document")
	_assert_true(layer.is_wall(HexVector.zero()), "Hex target command updates target state")

	undo_redo.undo()
	_assert_eq(layer.apply_document_cell_count, 0, "Hex target undo does not call apply_document_cell")
	_assert_eq(layer.redraw_count, redraw_count_after_full_apply, "Hex target undo does not call full redraw")
	_assert_true(not HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "Hex target command undo updates document")
	_assert_true(layer.is_floor(HexVector.zero()), "Hex target command undo restores target state")

	undo_redo.redo()
	_assert_eq(layer.apply_document_cell_count, 0, "Hex target redo does not call apply_document_cell")
	_assert_eq(layer.redraw_count, redraw_count_after_full_apply, "Hex target redo does not call full redraw")
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "Hex target command redo updates document")
	_assert_true(layer.is_wall(HexVector.zero()), "Hex target command redo restores target state")

	undo_redo.clear_history()
	undo_redo.free()
	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_hex_tile_payload_modes_change_display() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool._apply_document_to_target()
	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	tool.set_tile_payload(0, Vector2i(1, 0), 0)

	_assert_true(tool.apply_cell(HexVector.zero()), "floor tile mode applies payload to HexTileMapLayer")
	_assert_eq(HexMapDocumentAdapter.document_tile_entries(document).size(), 1, "floor tile mode stores a document tile assignment")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i(1, 0), "floor tile mode redraws HexTileMapLayer tile")
	var trace = tool.last_edit_status()
	_assert_true(bool(trace["display_changed"]), "floor tile mode Last Edit records display change")
	_assert_eq(trace["display_renderer_after"], "HexTileMapLayer", "floor tile mode Last Edit records Hex renderer")
	_assert_true(tool._last_edit_detail_label.text.contains("payload=0:(1,0):0"), "floor tile mode Last Edit includes payload")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_overlay_tile_payload_changes_hex_display() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool._apply_document_to_target()
	tool.set_edit_mode(HexMapEditTool.EditMode.OVERLAY_TILE)
	tool.set_overlay_tile_payload("Treasure", 0, Vector2i(1, 0), 0)

	_assert_true(tool.apply_cell(HexVector.zero()), "overlay tile mode applies payload to HexTileMapLayer")
	var overlay_entries = HexMapDocumentAdapter.document_tile_entries(document)
	_assert_eq(overlay_entries.size(), 1, "overlay tile mode stores a document tile assignment")
	_assert_eq(overlay_entries[0]["kind"], HexMapDocumentAdapter.KIND_OVERLAY, "overlay tile mode stores overlay kind")
	_assert_eq(overlay_entries[0]["item_key"], "Treasure", "overlay tile mode stores item key")
	var map_cell = HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true)
	_assert_eq(layer._overlay_tile_map.get_cell_atlas_coords(map_cell), Vector2i(1, 0), "overlay tile mode draws overlay tile")
	var state = layer.display_state_for_hex(HexVector.zero())
	_assert_eq(state["overlay_count"], 1, "overlay tile mode exposes overlay count")
	var trace = tool.last_edit_status()
	_assert_true(bool(trace["display_changed"]), "overlay tile mode Last Edit records display change")
	_assert_eq(trace["display_overlay_count_after"], 1, "overlay tile mode Last Edit records overlay count")
	_assert_eq(trace["target_apply_reason"], "Applied overlay tile to HexTileMapLayer.", "overlay tile mode uses overlay apply reason")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_keeps_tile_payloads_per_mode() -> void:
	var tool = await _new_ready_edit_tool()
	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	tool._select_catalog_option_by_key(tool._tile_catalog_option, "terrain.floor")
	tool._on_tile_catalog_selected(tool._tile_catalog_option.selected)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_TILE)
	tool._select_catalog_option_by_key(tool._tile_catalog_option, "terrain.wall")
	tool._on_tile_catalog_selected(tool._tile_catalog_option.selected)
	tool.set_edit_mode(HexMapEditTool.EditMode.OVERLAY_TILE)
	tool._select_catalog_option_by_key(tool._tile_catalog_option, "overlay.treasure")
	tool._on_tile_catalog_selected(tool._tile_catalog_option.selected)

	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	_assert_eq(tool._floor_tile_payload["catalog_key"], "terrain.floor", "floor tile mode preserves floor catalog key")
	_assert_eq(tool._floor_tile_payload["atlas_coords"], Vector2i.ZERO, "floor tile mode preserves floor catalog atlas")

	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_TILE)
	_assert_eq(tool._wall_tile_payload["catalog_key"], "terrain.wall", "wall tile mode preserves wall catalog key")
	_assert_eq(tool._wall_tile_payload["atlas_coords"], Vector2i(1, 0), "wall tile mode preserves wall catalog atlas")

	tool.set_edit_mode(HexMapEditTool.EditMode.OVERLAY_TILE)
	_assert_eq(tool._overlay_tile_payload["catalog_key"], "overlay.treasure", "overlay tile mode preserves overlay catalog key")
	_assert_true(_control_row_visible(tool._overlay_item_key_option), "overlay tile mode shows known item key option")

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_object_and_label_payloads_change_hex_display() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool._apply_document_to_target()
	tool.set_edit_mode(HexMapEditTool.EditMode.OBJECT)
	tool.set_object_payload("chest")

	_assert_true(tool.apply_cell(HexVector.zero()), "object mode applies payload to HexTileMapLayer")
	var object_state = layer.display_state_for_hex(HexVector.zero())
	_assert_eq(object_state["object_count"], 1, "object mode exposes Hex object marker state")
	_assert_true(bool(tool.last_edit_status()["display_changed"]), "object mode Last Edit records marker display change")
	_assert_eq(tool.last_edit_status()["display_marker_count_after"], 1, "object mode Last Edit records marker count")

	tool.set_edit_mode(HexMapEditTool.EditMode.LABEL)
	tool.set_label_payload("area", "North")
	_assert_true(tool.apply_cell(HexVector.zero()), "label mode applies payload to HexTileMapLayer")
	var label_state = layer.display_state_for_hex(HexVector.zero())
	_assert_eq(label_state["label_count"], 1, "label mode exposes Hex label marker state")
	_assert_eq(label_state["marker_count"], 2, "label mode keeps object and label markers visible")
	_assert_true(bool(tool.last_edit_status()["display_changed"]), "label mode Last Edit records marker display change")
	_assert_eq(tool.last_edit_status()["display_marker_count_before"], 1, "label mode Last Edit records marker count before")
	_assert_eq(tool.last_edit_status()["display_marker_count_after"], 2, "label mode Last Edit records marker count after")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_forward_canvas_gui_input_edits_loop_visual_duplicate() -> void:
	var data = HexMapData.square(3, true)
	var resource = HexMapResource.from_map_data(data)
	var document = HexMapDocumentAdapter.from_map_resource(resource)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var duplicate_visual = HexVector.apply_basis(-3, 0, 0)
	layer.hex_size = 10.0
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	layer.loop_display_rect = Rect2(layer.hex_to_display_local(duplicate_visual) - Vector2.ONE, Vector2(2, 2))
	layer.apply_map(resource)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = layer.to_global(layer._tile_map.position + layer.hex_to_display_local(duplicate_visual))
	var duplicate_map_cell = HexMapTileAdapter.vector_to_map_cell(duplicate_visual, true)

	_assert_true(tool.forward_canvas_gui_input(press), "map edit tool edits loop visual duplicate via viewport input")
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "loop visual duplicate edits canonical document cell")
	_assert_eq(
		layer._loop_tile_map.get_cell_atlas_coords(duplicate_map_cell),
		layer.wall_atlas_coords,
		"map edit tool refreshes duplicate tile after viewport edit"
	)
	_assert_true(layer._highlights.has(HexVector.zero().key()), "map edit tool highlights last edited canonical cell")
	_assert_vector_eq(tool.last_edit_status()["hex"], HexVector.zero(), "last edit status stores canonical hex")
	_assert_vector_eq(tool.last_edit_status()["visual_hex"], duplicate_visual, "last edit status stores visual hex")
	_assert_true(
		tool.apply_local_position(layer._tile_map.position + layer.hex_to_display_local(HexVector.q_axis())),
		"map edit tool accepts a second loop target edit"
	)
	_assert_eq(layer._highlights.size(), 1, "map edit tool keeps only one last-edit highlight")
	_assert_true(not layer._highlights.has(HexVector.zero().key()), "map edit tool clears previous last-edit highlight")
	_assert_true(layer._highlights.has(HexVector.q_axis().key()), "map edit tool highlights the newest canonical cell")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_undo_redo_preserves_loop_visual_identity() -> void:
	var data = HexMapData.square(3, true)
	var resource = HexMapResource.from_map_data(data)
	var document = HexMapDocumentAdapter.from_map_resource(resource)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var duplicate_visual = HexVector.apply_basis(-3, 0, 0)
	layer.hex_size = 10.0
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	layer.loop_display_rect = Rect2(layer.hex_to_display_local(duplicate_visual) - Vector2.ONE, Vector2(2, 2))
	layer.apply_map(resource)
	var tool = await _new_ready_edit_tool()
	var undo_redo = UndoRedo.new()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_undo_redo(undo_redo)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var duplicate_map_cell = HexMapTileAdapter.vector_to_map_cell(duplicate_visual, true)
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = layer.to_global(layer._tile_map.position + layer.hex_to_display_local(duplicate_visual))

	_assert_true(tool.forward_canvas_gui_input(press), "loop visual duplicate edit is undoable")
	undo_redo.undo()
	_assert_true(not HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "undo restores canonical document floor")
	_assert_eq(
		layer._loop_tile_map.get_cell_atlas_coords(duplicate_map_cell),
		layer.floor_atlas_coords,
		"undo restores duplicate floor tile"
	)
	undo_redo.redo()
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "redo restores canonical document wall")
	_assert_eq(
		layer._loop_tile_map.get_cell_atlas_coords(duplicate_map_cell),
		layer.wall_atlas_coords,
		"redo restores duplicate wall tile"
	)

	undo_redo.clear_history()
	undo_redo.free()
	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_mode_specific_payload_controls() -> void:
	var tool = await _new_ready_edit_tool()

	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	_assert_true(not _control_row_visible(tool._tile_catalog_option), "wall/floor mode hides tile catalog control")
	_assert_true(not _control_row_visible(tool._object_id_edit), "wall/floor mode hides object payload controls")
	_assert_true(not _control_row_visible(tool._label_id_edit), "wall/floor mode hides label payload controls")

	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	_assert_true(_control_row_visible(tool._tile_catalog_option), "floor tile mode shows tile catalog control")
	_assert_true(not _control_row_visible(tool._object_id_edit), "floor tile mode hides object payload controls")

	tool.set_edit_mode(HexMapEditTool.EditMode.OVERLAY_TILE)
	_assert_true(_control_row_visible(tool._tile_catalog_option), "overlay tile mode shows tile catalog control")
	_assert_true(_control_row_visible(tool._overlay_item_key_edit), "overlay tile mode shows item key control")
	_assert_true(not _control_row_visible(tool._object_id_edit), "overlay tile mode hides object payload controls")

	tool.set_edit_mode(HexMapEditTool.EditMode.OBJECT)
	_assert_true(_control_row_visible(tool._object_catalog_option), "object mode shows object catalog key control")
	_assert_true(not _control_row_visible(tool._object_id_edit), "object mode hides raw object id control")
	_assert_true(_control_row_visible(tool._object_definition_tree), "object mode shows object definition list")
	_assert_true(_control_row_visible(tool._object_property_editor), "object mode shows typed object property editor")
	_assert_true(not _control_row_visible(tool._object_properties_edit), "object mode hides raw object properties text")
	_assert_true(_control_row_visible(tool._object_rotation_spin), "object mode shows object rotation control")
	_assert_true(_control_row_visible(tool._object_variant_edit), "object mode shows object variant control")
	_assert_true(_control_row_visible(tool._object_spawn_condition_edit), "object mode shows object spawn condition control")
	_assert_true(not _control_row_visible(tool._object_properties_table), "object mode hides raw object property table")
	_assert_true(not _control_row_visible(tool._tile_catalog_option), "object mode hides tile catalog control")

	tool.set_edit_mode(HexMapEditTool.EditMode.LABEL)
	_assert_true(not _control_row_visible(tool._label_id_edit), "label mode hides raw label id control")
	_assert_true(_control_row_visible(tool._label_definition_tree), "label mode shows label definition list")
	_assert_true(_control_row_visible(tool._label_text_edit), "label mode shows label text control")
	_assert_true(not _control_row_visible(tool._object_id_edit), "label mode hides object payload controls")

	tool.queue_free()
	await process_frame


func _test_hex_cell_button_layout_direction_cells_flat_top() -> void:
	var radius := 12.0
	var gap := 1.5
	var entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"flat_top": true,
		"cell_radius": radius,
		"cell_gap": gap,
		"padding": Vector2(2, 2),
	})
	var by_id = _entries_by_id(entries)
	var origin: Vector2 = by_id[HexVector.zero().key()]["center"]
	_assert_eq(entries.size(), 7, "direction layout includes center and six neighbor cells")
	for direction in HexVector.directions():
		var actual: Vector2 = by_id[direction.key()]["center"] - origin
		var expected = HexMapTileAdapter.hex_to_local(direction, radius + gap, true)
		_assert_vec2_approx(actual, expected, "flat-top direction cell uses tile adapter pitch")


func _test_hex_cell_button_layout_direction_cells_pointy_top() -> void:
	var radius := 12.0
	var gap := 1.5
	var flat_entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"flat_top": true,
		"cell_radius": radius,
		"cell_gap": gap,
		"padding": Vector2(2, 2),
	})
	var pointy_entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"flat_top": false,
		"cell_radius": radius,
		"cell_gap": gap,
		"padding": Vector2(2, 2),
	})
	var direction = HexVector.q_axis()
	var flat_by_id = _entries_by_id(flat_entries)
	var pointy_by_id = _entries_by_id(pointy_entries)
	var flat_delta: Vector2 = flat_by_id[direction.key()]["center"] - flat_by_id[HexVector.zero().key()]["center"]
	var pointy_delta: Vector2 = pointy_by_id[direction.key()]["center"] - pointy_by_id[HexVector.zero().key()]["center"]
	_assert_vec2_approx(
		pointy_delta,
		HexMapTileAdapter.hex_to_local(direction, radius + gap, false),
		"pointy-top direction cell uses tile adapter pitch"
	)
	_assert_true(not pointy_delta.is_equal_approx(flat_delta), "pointy-top layout differs from flat-top layout")


func _test_hex_cell_button_layout_minimum_size_uses_padding() -> void:
	var tight_padding := Vector2(2, 2)
	var wide_padding := Vector2(10, 10)
	var tight_entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_CUSTOM,
		"shape_cells": [HexVector.zero()],
		"cell_radius": 12.0,
		"padding": tight_padding,
	})
	var wide_entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_CUSTOM,
		"shape_cells": [HexVector.zero()],
		"cell_radius": 12.0,
		"padding": wide_padding,
	})
	var tight_size = HexCellButtonLayout.minimum_size(tight_entries, tight_padding)
	var wide_size = HexCellButtonLayout.minimum_size(wide_entries, wide_padding)
	_assert_true(wide_size.x > tight_size.x and wide_size.y > tight_size.y, "layout minimum size grows with padding")


func _test_hex_cell_button_layout_polygon_hit_rejects_rect_corner() -> void:
	var entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_CUSTOM,
		"shape_cells": [HexVector.zero()],
		"cell_radius": 12.0,
		"padding": Vector2(2, 2),
	})
	var entry: Dictionary = entries[0]
	var rect_corner = entry["bounds"].position + Vector2(0.2, 0.2)
	_assert_true(entry["bounds"].has_point(rect_corner), "hex rect corner fixture is inside entry bounds")
	_assert_true(HexCellButtonLayout.hit_entry(entries, rect_corner).is_empty(), "hex hit test rejects bounds corner outside polygon")
	_assert_eq(HexCellButtonLayout.hit_entry(entries, entry["center"])["id"], entry["id"], "hex hit test accepts polygon center")


func _test_hex_cell_button_layout_shape_cells_custom_ring_disc() -> void:
	var custom = [HexVector.zero(), HexVector.q_axis()]
	var custom_cells = HexCellButtonLayout.shape_cells(HexCellButtonLayout.SHAPE_CUSTOM, {"shape_cells": custom})
	_assert_keys_eq(custom_cells, custom, "custom shape returns the requested cell set")
	custom.clear()
	_assert_eq(custom_cells.size(), 2, "custom shape returns a duplicate cell array")
	_assert_eq(
		HexCellButtonLayout.shape_cells(HexCellButtonLayout.SHAPE_RING, {"radius": 1}).size(),
		6,
		"ring shape hook returns radius-1 ring cells"
	)
	_assert_eq(
		HexCellButtonLayout.shape_cells(HexCellButtonLayout.SHAPE_DISC, {"radius": 1}).size(),
		7,
		"disc shape hook returns radius-1 disc cells"
	)


func _test_hex_cell_button_panel_emits_pressed_for_hex_hit() -> void:
	var panel = HexCellButtonPanel.new()
	panel.configure({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"pressable_cells": _direction_pressable_cells(),
		"cell_radius": 12.0,
	})
	var recorder = CellPressRecorder.new()
	panel.cell_pressed.connect(Callable(recorder, "record"))
	root.add_child(panel)
	await process_frame

	var entry: Dictionary = _entries_by_id(panel.get_entries())[HexVector.q_axis().key()]
	_send_panel_click(panel, entry["center"])
	_assert_eq(recorder.entries.size(), 1, "hex cell panel emits pressed for hex polygon hit")
	_assert_eq(recorder.entries[0]["id"], HexVector.q_axis().key(), "hex cell panel emits the hit cell entry")

	panel.queue_free()
	await process_frame


func _test_hex_cell_button_panel_emits_hover_for_hex_hit() -> void:
	var panel = HexCellButtonPanel.new()
	panel.configure({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"pressable_cells": _direction_pressable_cells(),
		"cell_radius": 12.0,
	})
	var recorder = CellPressRecorder.new()
	panel.cell_hovered.connect(Callable(recorder, "record"))
	root.add_child(panel)
	await process_frame

	var entry: Dictionary = _entries_by_id(panel.get_entries())[HexVector.q_axis().key()]
	_send_panel_motion(panel, entry["center"])
	_assert_eq(recorder.entries.size(), 1, "hex cell panel emits hover for hex polygon hit")
	_assert_eq(recorder.entries[0]["id"], HexVector.q_axis().key(), "hex cell panel hover emits the hit cell entry")

	panel.queue_free()
	await process_frame


func _test_hex_cell_button_panel_accepts_label_display_state() -> void:
	var labels := {HexVector.zero().key(): "0,0,0"}
	var panel = HexCellButtonPanel.new()
	panel.configure({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"label_by_cell": labels,
		"show_labels": true,
		"cell_radius": 12.0,
	})
	root.add_child(panel)
	await process_frame

	var center_entry: Dictionary = _entries_by_id(panel.get_entries())[HexVector.zero().key()]
	_assert_true(panel.show_labels, "hex cell panel keeps label display enabled")
	_assert_eq(center_entry["label"], "0,0,0", "hex cell panel keeps label text in layout entry")

	panel.queue_free()
	await process_frame


func _test_hex_cell_button_panel_does_not_press_disabled_cell() -> void:
	var disabled := {}
	disabled[HexVector.q_axis().key()] = true
	var panel = HexCellButtonPanel.new()
	panel.configure({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"pressable_cells": _direction_pressable_cells(),
		"disabled_cells": disabled,
		"cell_radius": 12.0,
	})
	var recorder = CellPressRecorder.new()
	panel.cell_pressed.connect(Callable(recorder, "record"))
	root.add_child(panel)
	await process_frame

	var entry: Dictionary = _entries_by_id(panel.get_entries())[HexVector.q_axis().key()]
	_send_panel_click(panel, entry["center"])
	_assert_eq(recorder.entries.size(), 0, "hex cell panel ignores disabled cell press")

	panel.queue_free()
	await process_frame


func _test_hex_cell_button_panel_focus_navigation() -> void:
	var panel = HexCellButtonPanel.new()
	panel.configure({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"pressable_cells": _direction_pressable_cells(),
		"cell_radius": 12.0,
	})
	var focus_recorder = CellPressRecorder.new()
	var press_recorder = CellPressRecorder.new()
	panel.cell_focus_changed.connect(Callable(focus_recorder, "record"))
	panel.cell_pressed.connect(Callable(press_recorder, "record"))
	root.add_child(panel)
	await process_frame

	_send_panel_key(panel, KEY_RIGHT)
	_send_panel_key(panel, KEY_SPACE)
	_assert_eq(focus_recorder.entries.size(), 1, "hex cell panel emits focus change for keyboard navigation")
	_assert_eq(press_recorder.entries.size(), 1, "hex cell panel emits pressed for focused keyboard cell")
	_assert_eq(press_recorder.entries[0]["id"], HexVector.directions()[0].key(), "keyboard press uses the focused cell")

	panel.queue_free()
	await process_frame


func _test_distribution_editor_loads_default_preset_values() -> void:
	var editor = HexDistEditor.new()
	root.add_child(editor)
	await process_frame

	var expected = HexDistribution.from_preset_id(
		HexRandomizer.get_preset_id(HexRandomizer.get_preset_names()[0])
	)
	_assert_eq(_spin_values(editor._d3_spins), expected.distribution_3, "distribution editor shows preset 3-neighbor values")
	_assert_eq(_spin_values(editor._d2_spins), expected.distribution_2, "distribution editor shows preset 2-neighbor values")
	_assert_eq(_spin_values(editor._d1_spins), expected.distribution_1, "distribution editor shows preset 1-neighbor values")
	_assert_eq(editor._pattern_controls.size(), 14, "distribution editor tracks every pattern control")

	editor.queue_free()
	await process_frame


func _test_distribution_editor_loads_resource_values_and_colors_cells() -> void:
	var path = _test_resource_path("test_hex_distribution_editor.tres")
	var custom = HexDistribution.new(
		[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0],
		[0.5, 2.5, 4.5, 6.5],
		[1.5, 7.5]
	)
	_save_distribution(path, custom)

	var editor = HexDistEditor.new(path)
	root.add_child(editor)
	await process_frame

	_assert_eq(_spin_values(editor._d3_spins), custom.distribution_3, "distribution editor loads custom 3-neighbor values")
	_assert_eq(_spin_values(editor._d2_spins), custom.distribution_2, "distribution editor loads custom 2-neighbor values")
	_assert_eq(_spin_values(editor._d1_spins), custom.distribution_1, "distribution editor loads custom 1-neighbor values")
	_assert_eq(editor._editing_path, path, "distribution editor keeps the loaded resource path")
	_assert_true(not editor._save_button.disabled, "distribution editor enables apply for loaded resources")

	editor._d3_spins[0].value = 8.0
	editor._on_spin_changed(8.0, 3, 0)
	_assert_color_approx(
		editor._center_color(3, 0),
		Color(0.1, 0.1, 0.1),
		"distribution editor center color follows spin value"
	)

	editor.queue_free()
	await process_frame


func _test_distribution_editor_uses_hex_cell_layout_for_patterns() -> void:
	var editor = HexDistEditor.new()
	var origin := Vector2(70, 36)
	var entries = editor._distribution_pattern_entries(3, origin)
	var center_entry := {}
	var refs := {}
	for entry in entries:
		var metadata: Dictionary = entry["metadata"]
		if bool(metadata.get("center", false)):
			center_entry = entry
		else:
			refs[int(metadata["ref_index"])] = entry

	var hex_size := 16.0
	var expected_refs = [
		origin + Vector2(-hex_size * 1.5, -hex_size * sqrt(3.0) / 2.0),
		origin + Vector2(0, -hex_size * sqrt(3.0)),
		origin + Vector2(hex_size * 1.5, -hex_size * sqrt(3.0) / 2.0),
	]
	_assert_eq(entries.size(), 4, "distribution 3-neighbor pattern uses center and three reference entries")
	_assert_true(not center_entry.is_empty(), "distribution pattern marks the center entry")
	_assert_vec2_approx(center_entry["center"], origin, "distribution pattern keeps the existing center position")
	for index in range(expected_refs.size()):
		_assert_vec2_approx(refs[index]["center"], expected_refs[index], "distribution pattern keeps the existing reference position")

	editor.free()


func _test_distribution_editor_pattern_redraw_uses_layout_entries() -> void:
	var editor = HexDistEditor.new()
	root.add_child(editor)
	await process_frame

	var control = editor._pattern_controls[0]
	var entries = editor._distribution_pattern_entries(3)
	_assert_eq(entries.size(), 4, "distribution redraw test uses layout-backed entries")
	_assert_true(
		control.draw.is_connected(Callable(editor, "_draw_pattern").bind(3, 0, control)),
		"distribution pattern control draws through the layout-backed draw method"
	)
	editor._on_spin_changed(1.0, 3, 0)

	editor.queue_free()
	await process_frame


func _test_distribution_editor_close_button_uses_cancel_flow() -> void:
	var state := {"count": 0}
	var editor = HexDistEditor.new("", Callable(), Callable(self, "_count_cancel").bind(state))
	root.add_child(editor)
	await process_frame

	editor.emit_signal("close_requested")
	await process_frame

	_assert_eq(state["count"], 1, "distribution editor window close calls cancel callback")


func _test_distribution_editor_manages_recent_custom_and_duplicate_preset() -> void:
	HexDistEditor.clear_recent_distributions()
	var path = _test_resource_path("test_hex_distribution_duplicate.tres")

	var editor = HexDistEditor.new()
	root.add_child(editor)
	await process_frame

	var expected = HexDistribution.from_preset_id(
		HexRandomizer.get_preset_id(HexRandomizer.get_preset_names()[0])
	)
	_assert_true(editor._duplicate_preset_button != null, "distribution editor exposes duplicate preset button")
	_assert_eq(editor._duplicate_preset_button.text, "Duplicate Preset...", "distribution editor labels duplicate preset flow")
	_assert_true(editor.save_current_distribution_as(path), "distribution editor saves current preset as custom distribution")
	_assert_eq(HexDistEditor.recent_distribution_paths(), [path], "distribution editor remembers saved custom distribution")
	_assert_eq(editor._editing_path, path, "distribution editor switches to saved custom distribution")
	var saved = load(path)
	_assert_true(saved is HexDistribution, "duplicate preset save creates HexDistribution resource")
	_assert_eq(saved.distribution_3, expected.distribution_3, "duplicate preset save keeps preset 3-neighbor values")
	_assert_eq(saved.distribution_2, expected.distribution_2, "duplicate preset save keeps preset 2-neighbor values")
	_assert_eq(saved.distribution_1, expected.distribution_1, "duplicate preset save keeps preset 1-neighbor values")

	editor.queue_free()
	await process_frame

	var recent_editor = HexDistEditor.new()
	root.add_child(recent_editor)
	await process_frame
	_assert_eq(recent_editor._recent_option.item_count, 1, "distribution editor lists recent custom distributions")
	_assert_eq(recent_editor._recent_option.get_item_text(0), path, "distribution editor shows recent custom path")
	recent_editor._on_recent_selected(0)
	_assert_eq(recent_editor._editing_path, path, "distribution editor loads custom distribution from recent list")
	_assert_eq(_spin_values(recent_editor._d3_spins), expected.distribution_3, "recent custom load restores saved values")

	recent_editor.queue_free()
	await process_frame


func _test_adjacency_rule_editor_applies_rule_text() -> void:
	var state := {"rules": "", "count": 0}
	var editor = HexAdjacencyRuleEditor.new(
		"default=0.2",
		Callable(self, "_capture_rules").bind(state),
		Callable(self, "_count_cancel").bind(state)
	)
	root.add_child(editor)
	await process_frame

	_assert_eq(editor._rules_edit.text, "default=0.2", "adjacency rule editor loads initial rule text")
	_assert_eq(editor._rules_status_label.text, "Rules: 1", "adjacency rule editor shows initial valid rule count")
	editor._rules_edit.text = "1=0.8;default=0.1"
	editor._on_rules_text_changed(editor._rules_edit.text)
	_assert_eq(editor._rules_status_label.text, "Rules: 2", "adjacency rule editor updates valid rule count")
	editor._rules_edit.text = "1=0.8;bad=x"
	editor._on_rules_text_changed(editor._rules_edit.text)
	_assert_true(editor._rules_status_label.text.contains("Invalid: bad=x"), "adjacency rule editor reports invalid entry")
	_assert_true(not editor._rules_status_label.text.contains("fallback default"), "adjacency rule editor does not show fallback status")
	editor._on_apply_pressed()
	await process_frame

	_assert_eq(state["rules"], "1=0.8;bad=x", "adjacency rule editor apply returns rule text")
	_assert_eq(state["count"], 0, "adjacency rule editor apply does not call cancel")


func _test_generation_dock_state_evaluator_splits_control_logic() -> void:
	var simple = HexMapGenStateEvaluator.evaluate_control_state({
		"symmetric": false,
		"overlay": false,
		"generation_running": false,
		"overlay_adjacency_enabled": false,
		"overlay_item_limit_enabled": false,
		"simple_shape": HexMapGenDock.SHAPE_RECTANGLE,
		"shape_rectangle": HexMapGenDock.SHAPE_RECTANGLE,
		"shape_hexagon": HexMapGenDock.SHAPE_HEXAGON,
	})
	_assert_true(bool(simple["shape_simple_row_visible"]), "state evaluator shows simple shape row for simple generation")
	_assert_true(bool(simple["rect_row_visible"]), "state evaluator shows rectangle row for rectangle shape")
	_assert_true(not bool(simple["hex_row_visible"]), "state evaluator hides hex row for rectangle shape")
	_assert_true(not bool(simple["radius_row_visible"]), "state evaluator hides radius row for simple generation")
	_assert_eq(simple["probability_label"], "  Probability / Cell", "state evaluator labels simple probability")
	_assert_eq(simple["generate_button_text"], "Primary Generation", "state evaluator labels primary generation button")
	_assert_true(not bool(simple["overlay_controls_visible"]), "state evaluator hides overlay controls in primary mode")
	_assert_true(bool(simple["wall_probability_row_visible"]), "state evaluator shows wall probability in primary mode")

	var overlay_symmetric = HexMapGenStateEvaluator.evaluate_control_state({
		"symmetric": true,
		"overlay": true,
		"generation_running": false,
		"overlay_adjacency_enabled": true,
		"overlay_item_limit_enabled": false,
		"simple_shape": HexMapGenDock.SHAPE_HEXAGON,
		"shape_rectangle": HexMapGenDock.SHAPE_RECTANGLE,
		"shape_hexagon": HexMapGenDock.SHAPE_HEXAGON,
	})
	_assert_true(bool(overlay_symmetric["shape_symmetric_row_visible"]), "state evaluator shows symmetric shape row")
	_assert_true(bool(overlay_symmetric["radius_row_visible"]), "state evaluator shows radius row for symmetric generation")
	_assert_true(not bool(overlay_symmetric["sym_options_visible"]), "state evaluator hides symmetric options during overlay adjacency")
	_assert_eq(overlay_symmetric["probability_label"], "  Initial Probability", "state evaluator labels symmetric probability")
	_assert_eq(overlay_symmetric["generate_button_text"], "Overlay Generation", "state evaluator labels overlay generation button")
	_assert_eq(overlay_symmetric["deductor_label_text"], "Overlay Deductor", "state evaluator labels overlay deductor")
	_assert_eq(overlay_symmetric["generator_label_text"], "Overlay Generator", "state evaluator labels overlay generator")
	_assert_true(bool(overlay_symmetric["overlay_controls_visible"]), "state evaluator shows overlay controls")
	_assert_true(bool(overlay_symmetric["overlay_item_name_row_visible"]), "state evaluator shows symmetric overlay item name row")
	_assert_true(not bool(overlay_symmetric["overlay_item_pool_visible"]), "state evaluator hides item pool for symmetric overlay")
	_assert_true(bool(overlay_symmetric["overlay_reference_visible"]), "state evaluator shows adjacency reference controls")
	_assert_true(not bool(overlay_symmetric["overlay_deductor_floor_visible"]), "state evaluator hides deductor source during overlay adjacency")
	_assert_true(not bool(overlay_symmetric["wall_probability_row_visible"]), "state evaluator hides wall probability during overlay adjacency")

	var running_limit = HexMapGenStateEvaluator.evaluate_control_state({
		"symmetric": true,
		"overlay": true,
		"generation_running": true,
		"overlay_adjacency_enabled": false,
		"overlay_item_limit_enabled": true,
		"simple_shape": HexMapGenDock.SHAPE_HEXAGON,
		"shape_rectangle": HexMapGenDock.SHAPE_RECTANGLE,
		"shape_hexagon": HexMapGenDock.SHAPE_HEXAGON,
	})
	_assert_true(bool(running_limit["torus_connectivity_disabled"]), "state evaluator disables torus connectivity while generating")
	_assert_true(bool(running_limit["overlay_adjacency_disabled"]), "state evaluator disables adjacency toggle during item limit or generation")
	_assert_true(bool(running_limit["overlay_item_limit_disabled"]), "state evaluator disables item limit toggle while generating")
	_assert_true(bool(running_limit["overlay_deductor_floor_visible"]), "state evaluator shows symmetric overlay deductor source outside adjacency")
	_assert_true(not bool(running_limit["wall_probability_row_visible"]), "state evaluator hides wall probability during item limit")

	_assert_eq(
		HexMapGenStateEvaluator.generation_block_reason({
			"overlay_mode": false,
			"mask_query_enabled": true,
			"mask_candidate_count": 0,
			"overlay_adjacency_enabled": true,
			"adjacency_rule_count": 0,
		}),
		"",
		"state evaluator does not block primary generation"
	)
	_assert_eq(
		HexMapGenStateEvaluator.generation_block_reason({
			"overlay_mode": true,
			"mask_query_enabled": true,
			"mask_candidate_count": 0,
			"overlay_adjacency_enabled": false,
			"adjacency_rule_count": 1,
		}),
		HexMapGenStateEvaluator.DEFAULT_EMPTY_MASK_REASON,
		"state evaluator blocks empty overlay mask"
	)
	_assert_eq(
		HexMapGenStateEvaluator.generation_block_reason({
			"overlay_mode": true,
			"mask_query_enabled": false,
			"mask_candidate_count": 0,
			"overlay_adjacency_enabled": true,
			"adjacency_rule_count": 0,
		}),
		HexMapGenStateEvaluator.DEFAULT_EMPTY_ADJACENCY_RULES_REASON,
		"state evaluator blocks empty adjacency rules"
	)
	_assert_eq(
		HexMapGenStateEvaluator.generation_block_reason({
			"generation_running": true,
			"overlay_mode": true,
			"mask_query_enabled": true,
			"mask_candidate_count": 0,
			"overlay_adjacency_enabled": true,
			"adjacency_rule_count": 0,
		}),
		"",
		"state evaluator does not change block reason while generation is running"
	)
	_assert_eq(
		HexMapGenStateEvaluator.generation_block_reason({
			"overlay_mode": true,
			"mask_query_enabled": false,
			"mask_candidate_count": 0,
			"overlay_adjacency_enabled": true,
			"adjacency_rule_count": 1,
		}),
		"",
		"state evaluator allows valid adjacency overlay generation"
	)


func _test_generation_dock_adjacency_rule_validation() -> void:
	var dock = await _new_ready_dock()
	dock._wall_prob_slider.set_value_no_signal(0.35)
	dock._overlay_adjacency_rules_edit.text = "default=0.2;1=0.8;2,1=0.4;bad=x;bad=0.5"
	var rules = dock._overlay_adjacency_rules()
	_assert_eq(rules["default"], 0.2, "generation dock adjacency rules keep default")
	_assert_eq(rules[1], 0.8, "generation dock adjacency rules keep count rule")
	_assert_eq(rules[Vector2i(2, 1)], 0.4, "generation dock adjacency rules normalize count/component rule")
	_assert_true(dock._overlay_adjacency_rules_status_label.text.contains("Rules: 3"), "generation dock adjacency status shows valid rule count")
	_assert_true(dock._overlay_adjacency_rules_status_label.text.contains("Invalid: bad=x, bad=0.5"), "generation dock adjacency status shows invalid entries")

	dock._overlay_adjacency_rules_edit.text = "bad"
	rules = dock._overlay_adjacency_rules()
	_assert_eq(rules, {}, "generation dock adjacency rules stay empty when no valid rules exist")
	_assert_true(dock._overlay_adjacency_rules_status_label.text.contains("Rules: 0"), "generation dock adjacency status shows empty rules")
	_assert_true(not dock._overlay_adjacency_rules_status_label.text.contains("fallback default"), "generation dock adjacency status does not show fallback")

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_adjacency_check.set_pressed_no_signal(true)
	dock._on_overlay_adjacency_toggled(true)
	dock._overlay_adjacency_rules_edit.text = "bad"
	dock._refresh_controls()
	_assert_true(dock._generate_button.disabled, "generation dock disables Generate when adjacency rules are empty")
	_assert_true(not await dock._generate_map(), "generation dock does not generate adjacency overlay with empty rules")
	_assert_eq(
		dock.generation_status()["status"],
		HexMapGenDock.GENERATION_BLOCK_STATUS_PREFIX + HexMapGenDock.GENERATION_BLOCK_EMPTY_ADJACENCY_RULES,
		"empty adjacency rules block generation status"
	)

	dock._overlay_adjacency_rules_edit.text = "default=0.0"
	dock._refresh_controls()
	_assert_true(not dock._generate_button.disabled, "valid adjacency rules unblock Generate")
	_assert_eq(dock.generation_status()["status"], "Ready", "resolved adjacency block restores ready status")

	dock.queue_free()
	await process_frame


func _test_generation_dock_symmetric_hexagon_minimum_radii() -> void:
	var dock = await _new_ready_dock()

	dock._generate_option.select(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_HEXAGON)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._connect_method_option.select(1)
	dock._refresh_controls()
	for radius in [1, 2]:
		dock._gen_radius_spin.set_value_no_signal(radius)
		_assert_true(await dock._generate_map(), "generation dock completes radius %d symmetric hexagon generation" % radius)

		var data = dock._current_data
		var hex_cell_count = 1 + 3 * radius * (radius + 1)
		_assert_eq(data.cells.size(), hex_cell_count, "generation dock creates radius %d symmetric hexagon cells" % radius)
		_assert_true(data.walls.size() > 0, "generation dock radius %d symmetric hexagon creates walls" % radius)
		_assert_true(data.walls.size() <= hex_cell_count - 1, "generation dock radius %d symmetric hexagon keeps protected floor" % radius)
		_assert_true(HexMapGenerator.is_floor_connected(data), "generation dock radius %d symmetric hexagon completes connectivity" % radius)
		_assert_true(
			dock._stats_label.text.contains(HexMapGenDock.GENERATE_NAMES[HexMapGenDock.GENERATE_SYMMETRIC]),
			"generation dock stats include generation mode"
		)

	dock.queue_free()
	await process_frame


func _test_generation_dock_shape_universe_uses_canonical_hexagon_and_square_torus() -> void:
	var dock = await _new_ready_dock()

	var simple_hexagon = dock._shape_universe_from_values(
		false,
		HexMapGenDock.SHAPE_HEXAGON,
		2,
		1,
		1,
		3
	)
	var symmetric_hexagon = dock._shape_universe_from_values(
		true,
		HexMapGenDock.SHAPE_HEXAGON,
		1,
		1,
		1,
		2
	)
	var torus_universe = dock._shape_universe_from_values(
		false,
		HexMapGenDock.SHAPE_TORUS,
		1,
		1,
		1,
		2
	)
	_assert_keys_eq(simple_hexagon, HexMapData.hexagon(2).cells, "simple hexagon universe uses canonical HexMapData shape")
	_assert_keys_eq(symmetric_hexagon, HexMapData.hexagon(2).cells, "symmetric hexagon universe uses canonical HexMapData shape")
	_assert_keys_eq(simple_hexagon, symmetric_hexagon, "simple and symmetric hexagon universes match for the same radius")
	_assert_keys_eq(torus_universe, HexMapData.square(5, false).cells, "torus universe remains a non-toric square cell set")

	dock.queue_free()
	await process_frame


func _test_generation_dock_torus_connectivity_controls() -> void:
	var dock = await _new_ready_dock()

	_assert_eq(dock._generate_option.selected, HexMapGenDock.GENERATE_SYMMETRIC, "generation dock defaults to symmetric generator")
	_assert_true(dock._torus_connectivity_check.visible, "toric connection is visible for symmetric generation")
	_assert_true(not dock._torus_connectivity_check.disabled, "toric connection is enabled for symmetric generation")

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._on_generate_changed(HexMapGenDock.GENERATE_SIMPLE)
	await process_frame
	_assert_true(not dock._torus_connectivity_check.visible, "toric connection is hidden for simple generation")
	_assert_true(dock._torus_connectivity_check.disabled, "toric connection is disabled for simple generation")

	dock._generate_option.select(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._on_generate_changed(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_HEXAGON)
	dock._on_symmetric_shape_changed(HexMapGenDock.SHAPE_HEXAGON)
	dock._torus_connectivity_check.set_pressed_no_signal(true)
	dock._on_torus_connectivity_toggled(true)
	await process_frame
	_assert_eq(dock._shape_option_symmetric.selected, HexMapGenDock.SHAPE_RECTANGLE, "toric connection selects symmetric square")
	_assert_true(dock._torus_connectivity_check.button_pressed, "toric connection remains on after selecting square")

	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_HEXAGON)
	dock._on_symmetric_shape_changed(HexMapGenDock.SHAPE_HEXAGON)
	await process_frame
	_assert_true(not dock._torus_connectivity_check.button_pressed, "symmetric hexagon turns toric connection off")

	_begin_manual_generation(dock, false)
	_assert_true(dock._torus_connectivity_check.disabled, "toric connection is disabled while generation is running")
	dock._finish_generation(true)

	dock.queue_free()
	await process_frame


func _test_generation_dock_torus_connectivity_generation() -> void:
	var dock = await _new_ready_dock()

	dock._generate_option.select(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._on_generate_changed(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._on_symmetric_shape_changed(HexMapGenDock.SHAPE_RECTANGLE)
	dock._gen_radius_spin.set_value_no_signal(2)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._connect_method_option.select(_connect_method_index(HexMapGenerator.CONNECT_NONE))
	dock._torus_connectivity_check.set_pressed_no_signal(false)
	dock._refresh_controls()

	_assert_true(await dock._generate_map(), "generation dock completes non-toric symmetric square generation")
	_assert_eq(dock._current_data.cyclic_size, 0, "symmetric square without toric connection is non-toric")

	dock._torus_connectivity_check.set_pressed_no_signal(true)
	dock._on_torus_connectivity_toggled(true)
	_assert_true(await dock._generate_map(), "generation dock completes toric symmetric square generation")
	_assert_eq(dock._current_data.cyclic_size, 5, "symmetric square with toric connection uses toric size")

	dock.queue_free()
	await process_frame


func _test_generation_dock_tracks_generation_progress_state() -> void:
	var dock = await _new_ready_dock()

	var idle_status = dock.generation_status()
	_assert_true(not idle_status["running"], "generation dock is not running before Generate")
	_assert_true(not idle_status["cancel_requested"], "generation dock has no cancel request before Generate")
	_assert_eq(idle_status["progress"], 0.0, "generation dock starts with zero progress")
	_assert_eq(idle_status["status"], "Ready", "generation dock starts ready")
	_assert_eq(dock._generation_id, 0, "generation dock does not auto generate on creation")
	_assert_eq(dock._current_data, null, "generation dock starts without generated data")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on creation")
	_assert_eq(_window_child_count(dock), 0, "generation dock has no modal progress window on creation")

	dock._on_generate_pressed()
	await _wait_for_progress_controls(dock, "Generate button generation")
	await _wait_for_generation(dock, "Generate button generation")
	var ready_status = dock.generation_status()
	_assert_true(not ready_status["running"], "generation dock clears running state after Generate")
	_assert_true(not ready_status["cancel_requested"], "generation dock clears cancel request after Generate")
	_assert_eq(ready_status["progress"], 1.0, "generation dock reports completed progress")
	_assert_eq(ready_status["status"], "Ready", "generation dock reports ready status")
	_assert_true(_progress_controls_visible(dock), "generation dock keeps Generate progress visible after fast generation")
	_assert_true(dock._generation_progress_cancel_button.disabled, "generation dock disables progress cancel after Generate finish")
	_assert_eq(_window_child_count(dock), 0, "generation dock does not create modal progress window for Generate")
	await _wait_seconds(HexMapGenDock.GENERATION_PROGRESS_MIN_VISIBLE_SEC + 0.1)
	_assert_true(_progress_controls_hidden(dock), "generation dock hides Generate progress after minimum display time")

	_begin_manual_generation(dock, true)
	await _wait_for_progress_controls(dock, "manual successful generation")
	_assert_true(not dock._generation_progress_cancel_button.disabled, "generation dock enables progress cancel while running")
	dock._generation_progress_visible_started_msec = Time.get_ticks_msec()
	dock._finish_generation(false)
	var finished_status = dock.generation_status()
	_assert_true(not finished_status["running"], "generation dock clears running state immediately after successful finish")
	_assert_eq(finished_status["status"], "Ready", "generation dock reports ready before progress hide delay completes")
	_assert_true(_progress_controls_visible(dock), "generation dock keeps success progress visible for minimum display time")
	_assert_true(dock._generation_progress_cancel_button.disabled, "generation dock disables progress cancel after successful finish")
	await _wait_seconds(HexMapGenDock.GENERATION_PROGRESS_MIN_VISIBLE_SEC + 0.1)
	_assert_true(_progress_controls_hidden(dock), "generation dock hides success progress after minimum display time")

	_begin_manual_generation(dock, true)
	await _wait_for_progress_controls(dock, "manual cancelled generation")
	dock.request_generation_cancel()
	var cancel_status = dock.generation_status()
	_assert_true(cancel_status["running"], "generation dock keeps running state after cancel request")
	_assert_true(cancel_status["cancel_requested"], "generation dock stores cancel request state")
	_assert_eq(cancel_status["status"], "Cancel requested", "generation dock reports cancel request status")
	_assert_true(dock._generation_progress_cancel_button.disabled, "generation dock disables progress cancel after cancel request")

	dock._finish_generation(true)
	var cancelled_status = dock.generation_status()
	_assert_true(not cancelled_status["running"], "generation dock clears running state after cancelled finish")
	_assert_true(not cancelled_status["cancel_requested"], "generation dock clears cancel request after cancelled finish")
	_assert_eq(cancelled_status["status"], "Cancelled", "generation dock reports cancelled status")
	_assert_true(_progress_controls_hidden(dock), "generation dock hides progress after cancellation")

	dock.queue_free()
	await process_frame


func _test_generation_dock_debug_report_includes_validation_summary() -> void:
	var dock = await _new_ready_dock()
	dock._current_data = HexMapData.rectangle(1, 1)
	dock._current_orientation = HexMapResource.ORIENTATION_FLAT_TOP

	var summary = dock.validation_debug_summary()
	var report = dock.debug_report_text()
	_assert_eq(bool(summary.get("generated_map_present", false)), true, "generation validation summary sees current map")
	_assert_eq(int(summary.get("errors", -1)), 0, "generation validation summary reports no errors for valid map")
	_assert_true(report.contains("Hex Map Generate Debug Report"), "generation debug report has a stable header")
	_assert_true(report.contains("validation_summary:"), "generation debug report includes validation summary")
	_assert_true(not dock._stats_label.text.contains("validation_summary"), "generation stats label does not include validation dump")

	dock.queue_free()
	await process_frame


func _test_generation_dock_validates_generation_result_before_auto_apply() -> void:
	var dock = await _new_ready_dock()
	var scene_root = Node2D.new()
	scene_root.name = "ValidationAutoApplyRoot"
	root.add_child(scene_root)
	var layer = TileMapLayer.new()
	layer.name = "ValidationAutoApplyLayer"
	scene_root.add_child(layer)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	dock._tile_layer_option.select(1)
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(layer), "generation validation test configures sample tiles")

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._refresh_controls()

	_assert_true(not bool(dock.generation_validation_summary().get("validated", true)), "generation validation starts uncaptured")
	dock._on_generate_pressed()
	await _wait_for_progress_controls(dock, "validation Generate button generation")
	await _wait_for_generation(dock, "validation Generate button generation")

	var summary = dock.generation_validation_summary()
	_assert_true(dock.generation_validation_result() != null, "generation validation stores raw result")
	_assert_true(bool(summary.get("validated", false)), "generation validation summary records validation run")
	_assert_true(bool(summary.get("passed", false)), "valid generated map passes validation")
	_assert_eq(int(summary.get("errors", -1)), 0, "valid generated map records zero validation errors")
	_assert_true(int(summary.get("capture_order", 0)) > 0, "generation validation records capture order")
	_assert_true(
		int(summary.get("apply_order", 0)) > int(summary.get("capture_order", 0)),
		"generation validation is captured before auto apply"
	)
	_assert_eq(layer.get_used_cells().size(), 2, "generation still auto applies after validation capture")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_captures_generation_validation_failure() -> void:
	var dock = await _new_ready_dock()
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	document.terrain_layers[0].default_floor_key = "terrain.floor"
	document.terrain_layers[0].default_wall_key = "terrain.wall"
	HexMapDocumentAdapter.set_label(document, HexVector.q_axis(), {
		"label_id": "outside",
		"text": "Outside",
	})

	var result = dock.validate_generation_document(document)
	var summary = dock.generation_validation_summary()
	_assert_true(result != null, "generation validation failure stores raw result")
	_assert_true(bool(summary.get("validated", false)), "generation validation failure records validation run")
	_assert_true(not bool(summary.get("passed", true)), "invalid generated document records failed validation")
	_assert_true(int(summary.get("errors", 0)) >= 1, "invalid generated document records validation errors")
	_assert_eq(int(summary.get("apply_order", -1)), 0, "direct validation capture does not mark auto apply")
	_assert_eq(
		String(result.issues[0].get("rule_id", "")),
		"document.orphan_payload",
		"invalid generated document records failing rule id"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_batch_runner_scores_and_sorts() -> void:
	var dock = await _new_ready_dock()
	dock._current_data = HexMapData.rectangle(1, 1)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(3)
	dock._rect_height_spin.set_value_no_signal(2)
	dock._wall_prob_slider.set_value_no_signal(0.45)
	dock._connect_method_option.select(_connect_method_index(HexMapGenerator.CONNECT_DENSE))
	dock._refresh_controls()

	var rows = dock.run_generation_batch(3, {"seeds": [501, 502, 503]})
	_assert_eq(rows.size(), 3, "generation batch creates one row per explicit seed")
	_assert_eq(dock._current_data.cells.size(), 1, "generation batch does not promote candidate into current map")
	for row in rows:
		var summary: Dictionary = row["validation_summary"]
		_assert_eq(String(row.get("status", "")), "generated", "generation batch row records generated status")
		_assert_eq(int(row.get("cells", 0)), 6, "generation batch row records generated cell count")
		_assert_true(row.has("score"), "generation batch row records score")
		_assert_true(bool(summary.get("validated", false)), "generation batch row records validation summary")
		_assert_true(bool(summary.get("passed", false)), "generation batch row passes validation")
		_assert_eq(int(row.get("validation_errors", -1)), 0, "generation batch row flattens validation errors")

	var score_table = dock.generation_batch_score_table("score", true)
	_assert_eq(score_table.size(), 3, "score table returns every batch row")
	for index in range(score_table.size() - 1):
		_assert_true(
			float(score_table[index].get("score", 0.0)) >= float(score_table[index + 1].get("score", 0.0)),
			"score table sorts by descending score"
		)
	_assert_eq(int(score_table[0].get("rank", 0)), 1, "score table assigns first rank")

	var seed_table = dock.generation_batch_score_table("seed", false)
	_assert_eq(int(seed_table[0].get("seed", 0)), 501, "score table sorts by seed ascending")
	_assert_eq(int(seed_table[2].get("seed", 0)), 503, "score table keeps seed ascending order")

	_assert_true(dock._seed_lab_count_spin != null, "generation dock exposes Seed Lab seed count")
	_assert_true(dock._seed_lab_run_button != null, "generation dock exposes Seed Lab batch run")
	_assert_true(dock._seed_lab_score_tree != null, "generation dock exposes Seed Lab score table")
	_assert_true(dock._seed_lab_promote_button != null, "generation dock exposes Promote to Document")
	dock._seed_lab_count_spin.set_value_no_signal(3)
	dock._on_seed_lab_run_pressed()
	var score_root = dock._seed_lab_score_tree.get_root()
	_assert_true(score_root.get_first_child() != null, "Seed Lab score table renders rows")
	var first_score_item = score_root.get_first_child()
	first_score_item.select(0)
	dock._on_seed_lab_score_selected()
	_assert_true(dock._seed_lab_preview_label.text.contains("Selected Seed:"), "Seed Lab selection updates preview")
	dock._on_seed_lab_promote_pressed()
	_assert_true(dock.promoted_generation_document() is HexMapDocumentResource, "Seed Lab promotes selected row to document")
	_assert_true(dock._seed_lab_status_label.text.contains("Dirty: yes"), "Seed Lab promotion displays dirty state")

	dock.queue_free()
	await process_frame


func _test_generation_dock_promotes_batch_seed_to_canonical_document() -> void:
	var dock = await _new_ready_dock()
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._connect_method_option.select(_connect_method_index(HexMapGenerator.CONNECT_DENSE))
	dock._refresh_controls()

	dock.run_generation_batch(2, {"seeds": [801, 802]})
	var chosen = dock.generation_batch_score_table("score", true)[0]
	var document = dock.promote_generation_batch_row(chosen)
	_assert_true(document is HexMapDocumentResource, "promoted seed creates a document resource")
	_assert_true(document.metadata != null, "promoted seed creates document metadata")
	_assert_eq(document.terrain_layers.size(), 1, "promoted seed stores typed terrain layer")
	_assert_true(document.terrain_layers[0].map != null, "promoted terrain layer stores map resource")
	_assert_eq(document.terrain_layers[0].map.to_map_data().cells.size(), 2, "promoted seed stores generated map cells")
	_assert_eq(document.metadata.generation_seed, int(chosen.get("seed", 0)), "promoted metadata stores chosen seed")
	_assert_eq(
		int(document.metadata.generation_snapshot.get("seed", 0)),
		int(chosen.get("seed", 0)),
		"promoted metadata stores generation snapshot seed"
	)
	_assert_eq(
		int(document.metadata.generation_snapshot.get("rect_width", 0)),
		2,
		"promoted metadata stores generation snapshot settings"
	)
	_assert_true(
		not document.metadata.generation_snapshot.has("generation_id"),
		"promoted metadata omits transient generation id"
	)
	_assert_eq(
		int(document.metadata.custom_properties.get("generation_batch_index", -1)),
		int(chosen.get("index", -2)),
		"promoted metadata stores source batch index"
	)
	_assert_true(
		document.metadata.custom_properties.get("generation_validation_summary", {}) is Dictionary,
		"promoted metadata stores validation summary"
	)

	var path = _test_resource_path("test_generation_seed_promoted_document.tres")
	_save_resource(path, document)
	var loaded = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	_assert_true(loaded is HexMapDocumentResource, "promoted seed saved document reloads as document")
	_assert_eq(loaded.metadata.generation_seed, document.metadata.generation_seed, "reloaded promoted document keeps seed")
	_assert_eq(
		int(loaded.metadata.generation_snapshot.get("seed", 0)),
		document.metadata.generation_seed,
		"reloaded promoted document keeps generation snapshot"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_only_generates_from_generate_button() -> void:
	var dock = await _new_ready_dock()

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._connect_method_option.select(0)
	dock._refresh_controls()

	var generation_id = dock._generation_id
	dock._rect_width_spin.value = 2
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on SpinBox value change")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on SpinBox value change")

	dock._rect_width_spin.emit_signal("focus_exited")
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on focus exit")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on focus exit")

	dock._generate_option.select(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._gen_radius_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._on_generate_changed(HexMapGenDock.GENERATE_SYMMETRIC)
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on generator selection change")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on generator selection change")

	dock._wall_prob_slider.value = 0.25
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on slider value change")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on slider value change")

	dock._on_dist_changed(0)
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on dist selection change")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on dist selection change")

	dock._on_seed_randomize()
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on seed randomize")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on seed randomize")

	dock._on_generate_pressed()
	await _wait_for_progress_controls(dock, "explicit Generate button generation")
	await _wait_for_generation(dock, "explicit Generate button generation")
	_assert_eq(dock._generation_id, generation_id + 1, "generation dock regenerates immediately from Generate")
	_assert_true(
		dock._stats_label.text.contains(HexMapGenDock.GENERATE_NAMES[HexMapGenDock.GENERATE_SYMMETRIC]),
		"Generate button updates generator mode"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_wires_core_progress_and_cancel() -> void:
	var dock = await _new_ready_dock()

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._connect_method_option.select(0)
	dock._refresh_controls()
	await dock._generate_map()
	var completed_data = dock._current_data

	dock._rect_width_spin.set_value_no_signal(20)
	dock._rect_height_spin.set_value_no_signal(20)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._connect_method_option.select(0)
	dock._generation_chunk_size = 1
	dock._generation_progress_delay_usec = 5000
	dock._refresh_controls()

	dock._generate_map(true)
	await _wait_for_core_progress(dock)
	await _wait_for_progress_controls(dock, "long threaded generation")
	_assert_true(not dock._generation_progress_cancel_button.disabled, "generation dock shows cancellable progress for long generation")
	_assert_eq(_window_child_count(dock), 0, "generation dock does not create modal progress window for long generation")
	dock.request_generation_cancel()
	await _wait_for_generation(dock, "cancelled threaded generation")

	var cancelled_status = dock.generation_status()
	_assert_eq(cancelled_status["status"], "Cancelled", "generation dock reports threaded cancellation")
	_assert_true(dock._generation_core_progress_event_count > 0, "generation dock receives core progress callback events")
	_assert_true(dock._generation_cancel_poll_count > 0, "generation dock exposes cancel state through core cancel callback")
	_assert_true(dock._generation_last_core_progress > 0.0, "generation dock records non-hardcoded core progress")
	_assert_eq(dock._current_data, completed_data, "generation dock keeps last completed map when cancel returns partial data")

	dock.queue_free()
	await process_frame


func _test_generation_dock_applies_configured_tile_entries() -> void:
	var dock = await _new_ready_dock()

	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	dock._current_data = data
	dock._floor_source_spin.value = 4
	dock._floor_atlas_x_spin.value = 2
	dock._floor_atlas_y_spin.value = 3
	dock._wall_source_spin.value = 5
	dock._wall_atlas_x_spin.value = 6
	dock._wall_atlas_y_spin.value = 7

	var fake_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_data_to_tile_map_layer(fake_layer), "generation dock applies current data to a layer")
	_assert_true(fake_layer.cleared, "generation dock clears target layer before applying")
	_assert_eq(fake_layer.calls.size(), 2, "generation dock emits one tile entry per cell")
	_assert_eq(fake_layer.calls[0]["map_cell"], Vector2i.ZERO, "generation dock applies floor cell position")
	_assert_eq(fake_layer.calls[0]["source_id"], 4, "generation dock applies configured floor source")
	_assert_eq(fake_layer.calls[0]["atlas_coords"], Vector2i(2, 3), "generation dock applies configured floor atlas")
	_assert_eq(fake_layer.calls[1]["map_cell"], Vector2i(1, 0), "generation dock applies wall cell position")
	_assert_eq(fake_layer.calls[1]["source_id"], 5, "generation dock applies configured wall source")
	_assert_eq(fake_layer.calls[1]["atlas_coords"], Vector2i(6, 7), "generation dock applies configured wall atlas")
	_assert_true(dock._apply_write_policy_option.visible, "Apply Write is visible in Primary mode")

	dock._apply_write_policy_option.select(1)
	var preserving_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_data_to_tile_map_layer(preserving_layer), "generation dock applies current data with Add Item write policy")
	_assert_true(not preserving_layer.cleared, "Apply Write Add Item preserves existing Primary layer cells")

	dock.queue_free()
	await process_frame


func _test_generation_dock_applies_orientation_to_tile_entries() -> void:
	var dock = await _new_ready_dock()

	dock._current_data = HexMapData.from_cells([
		HexVector.zero(),
		HexVector.r_axis().negated(),
	])
	dock._tile_orientation_option.select(1)

	var fake_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_data_to_tile_map_layer(fake_layer), "generation dock applies pointy-top data")
	_assert_eq(fake_layer.calls[0]["map_cell"], Vector2i(0, -1), "pointy-top uses Horizontal Offset map cell")
	_assert_eq(fake_layer.calls[1]["map_cell"], Vector2i.ZERO, "pointy-top keeps origin map cell")

	dock._tile_orientation_option.select(0)
	fake_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_data_to_tile_map_layer(fake_layer), "generation dock applies flat-top data")
	_assert_eq(fake_layer.calls[0]["map_cell"], Vector2i(1, -1), "flat-top uses Vertical Offset map cell")
	_assert_eq(fake_layer.calls[1]["map_cell"], Vector2i.ZERO, "flat-top keeps origin map cell")

	dock.queue_free()
	await process_frame


func _test_generation_dock_resource_stores_orientation() -> void:
	var dock = await _new_ready_dock()

	dock._current_data = HexMapData.rectangle(1, 1)
	dock._tile_orientation_option.select(1)
	var resource = dock.current_resource()

	_assert_eq(resource.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "generation dock saves pointy-top orientation to resource")
	_assert_eq(resource.cells.size(), 1, "generation dock saved resource keeps map data")

	dock.queue_free()
	await process_frame


func _test_generation_dock_configures_tile_map_layer_tileset() -> void:
	var dock = await _new_ready_dock()

	dock._current_data = HexMapData.rectangle(1, 1)
	dock._tile_orientation_option.select(1)
	dock._tile_width_spin.value = 96
	dock._tile_height_spin.value = 84

	var layer = TileMapLayer.new()
	_assert_true(dock.apply_current_data_to_tile_map_layer(layer), "generation dock applies to a TileMapLayer")
	_assert_true(layer.tile_set != null, "generation dock creates a TileSet when configuring TileMapLayer")
	_assert_eq(layer.tile_set.tile_shape, TileSet.TILE_SHAPE_HEXAGON, "generation dock configures TileSet shape")
	_assert_eq(layer.tile_set.tile_layout, TileSet.TILE_LAYOUT_STACKED, "generation dock configures TileSet layout")
	_assert_eq(layer.tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "generation dock maps pointy-top to Horizontal Offset")
	_assert_eq(layer.tile_set.tile_size, Vector2i(96, 84), "generation dock configures TileSet tile size")

	layer.free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_applies_primary_map_to_hex_tile_map_layer() -> void:
	var dock = await _new_ready_dock()

	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	dock._current_data = data
	dock._tile_orientation_option.select(1)
	dock._tile_width_spin.value = HexMapTileAdapter.SAMPLE_TILE_SIZE.x
	dock._tile_height_spin.value = HexMapTileAdapter.SAMPLE_TILE_SIZE.y
	dock._floor_source_spin.value = 4
	dock._floor_atlas_x_spin.value = 0
	dock._floor_atlas_y_spin.value = 0
	dock._wall_source_spin.value = 5
	dock._wall_atlas_x_spin.value = 1
	dock._wall_atlas_y_spin.value = 0
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame

	_assert_true(dock.apply_current_data_to_tile_map_layer(layer), "generation dock applies primary data to HexTileMapLayer")
	_assert_true(layer.hex_map is HexMapResource, "HexTileMapLayer primary apply stores hex_map resource")
	_assert_eq(layer.hex_map.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "HexTileMapLayer primary apply stores orientation")
	_assert_eq(layer.display_used_cell_count(), 2, "HexTileMapLayer primary apply redraws display cells")
	_assert_eq(layer.floor_source_id, 4, "HexTileMapLayer primary apply stores floor source")
	_assert_eq(layer.wall_source_id, 5, "HexTileMapLayer primary apply stores wall source")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i(0, 0), "HexTileMapLayer primary apply uses floor atlas")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.q_axis()), Vector2i(1, 0), "HexTileMapLayer primary apply uses wall atlas")
	var tile_set = layer.display_tile_set()
	_assert_true(tile_set.has_source(4), "HexTileMapLayer primary apply creates floor source")
	_assert_true(tile_set.has_source(5), "HexTileMapLayer primary apply creates wall source")
	_assert_eq(tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "HexTileMapLayer primary apply configures pointy-top axis")

	layer.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_swaps_tile_size_on_orientation_change() -> void:
	var dock = await _new_ready_dock()

	dock._tile_width_spin.value = 80
	dock._tile_height_spin.value = 72
	dock._tile_orientation_option.select(1)
	dock._on_tile_orientation_changed(1)
	_assert_eq(Vector2i(int(dock._tile_width_spin.value), int(dock._tile_height_spin.value)), Vector2i(72, 80), "pointy-top switch swaps tile size controls")

	dock._tile_orientation_option.select(0)
	dock._on_tile_orientation_changed(0)
	_assert_eq(Vector2i(int(dock._tile_width_spin.value), int(dock._tile_height_spin.value)), Vector2i(80, 72), "flat-top switch swaps tile size controls back")

	dock.queue_free()
	await process_frame


func _test_generation_dock_lists_hex_tile_map_layer_common_target() -> void:
	var dock = await _new_ready_dock()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var plain_layer = TileMapLayer.new()
	plain_layer.name = "PlainLayer"
	scene_root.add_child(plain_layer)
	var hex_layer = HexTileMapLayer.new()
	hex_layer.name = "RuntimeMap"
	scene_root.add_child(hex_layer)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.item_count, 4, "generation dock lists Auto, HexTileMapLayer, plain target, and add new layer")
	_assert_eq(dock._tile_layer_option.get_item_text(1), "RuntimeMap (HexTileMapLayer)", "generation dock prioritizes HexTileMapLayer target")
	_assert_eq(dock._tile_layer_option.get_item_text(2), "PlainLayer", "generation dock keeps plain target label for explicit/Overlay use")
	dock._tile_layer_option.select(1)
	_assert_eq(dock.selected_tile_map_layer(), hex_layer, "generation dock returns selected HexTileMapLayer")
	dock._set_editor_selected_tile_map_layer_for_test(hex_layer)
	_assert_eq(dock._find_editor_selected_tile_map_layer(), hex_layer, "generation dock accepts editor-selected HexTileMapLayer")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_lists_and_auto_applies_selected_tile_layer() -> void:
	var dock = await _new_ready_dock()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var first_layer = TileMapLayer.new()
	first_layer.name = "FirstLayer"
	scene_root.add_child(first_layer)
	var second_layer = TileMapLayer.new()
	second_layer.name = "SecondLayer"
	scene_root.add_child(second_layer)
	await process_frame

	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	dock._current_data = data
	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.item_count, 4, "generation dock lists Auto, TileMapLayers, and add new layer")
	_assert_eq(dock._tile_layer_option.get_item_text(0), "Auto: Selected / first scene layer", "generation dock keeps Auto target")
	_assert_eq(dock._tile_layer_option.get_item_text(1), "FirstLayer", "generation dock shows short first TileMapLayer name")
	_assert_eq(dock._tile_layer_option.get_item_text(2), "SecondLayer", "generation dock shows short second TileMapLayer name")
	_assert_eq(dock._tile_layer_option.get_item_text(3), "Add new layer...", "generation dock exposes add new layer target")
	dock._tile_layer_option.select(2)
	_assert_eq(dock.selected_tile_map_layer(), second_layer, "generation dock returns selected TileMapLayer")
	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.get_item_text(0), "Auto: Selected / first scene layer", "generation dock keeps Auto after refresh")
	_assert_eq(dock.selected_tile_map_layer(), second_layer, "generation dock preserves selected TileMapLayer after refresh")

	dock._tile_layer_option.select(1)
	dock._set_editor_selected_tile_map_layer_for_test(second_layer)
	dock._on_sample_tiles_pressed()
	_assert_eq(first_layer.tile_set, null, "sample tile setup ignores Target and does not touch unselected TileMapLayer")
	_assert_true(second_layer.tile_set != null, "sample tile setup uses editor-selected TileMapLayer")
	dock._floor_atlas_x_spin.value = 1
	dock._wall_atlas_x_spin.value = 0

	_assert_eq(first_layer.get_used_cells().size(), 0, "tile setting auto apply ignores Target and does not touch unselected TileMapLayer")
	_assert_eq(second_layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "floor SpinBox change reapplies editor-selected TileMapLayer")
	_assert_eq(second_layer.get_cell_atlas_coords(Vector2i(1, 0)), Vector2i(0, 0), "wall SpinBox change reapplies editor-selected TileMapLayer")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_disambiguates_duplicate_target_names() -> void:
	var dock = await _new_ready_dock()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var group_a = Node2D.new()
	group_a.name = "Terrain"
	scene_root.add_child(group_a)
	var group_b = Node2D.new()
	group_b.name = "Overlay"
	scene_root.add_child(group_b)
	var terrain_layer = TileMapLayer.new()
	terrain_layer.name = "Layer"
	group_a.add_child(terrain_layer)
	var overlay_layer = TileMapLayer.new()
	overlay_layer.name = "Layer"
	group_b.add_child(overlay_layer)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.get_item_text(1), "Terrain/Layer", "duplicate Target names show short scene tree path")
	_assert_eq(dock._tile_layer_option.get_item_text(2), "Overlay/Layer", "duplicate Target names include parent path")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_adds_new_target_layer() -> void:
	var dock = await _new_ready_dock()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.item_count, 2, "empty Target list still shows Auto and add new layer")
	_assert_eq(dock._tile_layer_option.get_item_text(0), "Auto: Selected / first scene layer", "empty Target list keeps Auto")
	_assert_eq(dock._tile_layer_option.get_item_text(1), "Add new layer...", "empty Target list keeps add new layer")

	var add_index = dock._add_tile_layer_option_index()
	dock._tile_layer_option.select(add_index)
	dock._on_tile_layer_target_selected(add_index)
	await process_frame

	var added_layer = dock.selected_tile_map_layer()
	_assert_true(added_layer is HexTileMapLayer, "add new layer creates a HexTileMapLayer")
	_assert_eq(added_layer.get_parent(), scene_root, "add new layer places HexTileMapLayer under scene root")
	_assert_true(String(added_layer.name).begins_with("HexMapLayer"), "add new layer uses HexMapLayer base name")
	_assert_eq(dock._tile_layer_option.selected, 1, "add new layer selects the created Target")
	_assert_eq(dock._find_editor_selected_tile_map_layer(), added_layer, "add new layer selects the created HexTileMapLayer")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_duplicates_shared_tileset_for_selected_layer() -> void:
	var dock = await _new_ready_dock()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var first_layer = TileMapLayer.new()
	first_layer.name = "FirstLayer"
	scene_root.add_child(first_layer)
	var second_layer = TileMapLayer.new()
	second_layer.name = "SecondLayer"
	scene_root.add_child(second_layer)
	await process_frame

	var shared_tile_set = TileSet.new()
	first_layer.tile_set = shared_tile_set
	second_layer.tile_set = shared_tile_set
	dock.refresh_tile_layer_options(scene_root)
	dock._tile_layer_option.select(1)
	dock._set_editor_selected_tile_map_layer_for_test(second_layer)
	dock._current_data = HexMapData.rectangle(1, 1)
	dock._tile_width_spin.value = 96
	await process_frame

	_assert_eq(first_layer.tile_set, shared_tile_set, "tile setting auto apply leaves unselected shared TileSet owner untouched")
	_assert_true(second_layer.tile_set != shared_tile_set, "tile setting auto apply duplicates shared TileSet for selected layer")
	_assert_eq(second_layer.tile_set.tile_size, Vector2i(96, 57), "selected layer receives updated TileSet size")
	_assert_true(first_layer.get_used_cells().is_empty(), "shared TileSet isolation does not apply cells to unselected layer")
	_assert_eq(second_layer.get_used_cells().size(), 1, "shared TileSet isolation still applies cells to selected layer")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_sets_up_sample_tiles() -> void:
	var dock = await _new_ready_dock()

	dock._tile_orientation_option.select(1)
	var layer = TileMapLayer.new()
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(layer), "generation dock configures sample tiles")
	_assert_true(layer.tile_set != null, "sample tile setup creates TileSet")
	_assert_eq(layer.tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "sample tile setup follows dock orientation")
	_assert_eq(layer.tile_set.tile_size, HexMapTileAdapter.SAMPLE_TILE_SIZE, "sample tile setup uses sample tile size")
	_assert_true(layer.tile_set.has_source(0), "sample tile setup creates source 0")
	_assert_eq(Vector2i(int(dock._tile_width_spin.value), int(dock._tile_height_spin.value)), HexMapTileAdapter.SAMPLE_TILE_SIZE, "sample tile setup syncs tile size controls")
	_assert_eq(int(dock._floor_source_spin.value), 0, "sample tile setup sets floor source")
	_assert_eq(Vector2i(int(dock._floor_atlas_x_spin.value), int(dock._floor_atlas_y_spin.value)), Vector2i.ZERO, "sample tile setup sets floor atlas")
	_assert_eq(int(dock._wall_source_spin.value), 0, "sample tile setup sets wall source")
	_assert_eq(Vector2i(int(dock._wall_atlas_x_spin.value), int(dock._wall_atlas_y_spin.value)), Vector2i(1, 0), "sample tile setup sets wall atlas")

	var hex_layer = HexTileMapLayer.new()
	root.add_child(hex_layer)
	await process_frame
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(hex_layer), "generation dock configures sample tiles on HexTileMapLayer")
	var hex_tile_set = hex_layer.display_tile_set()
	_assert_true(hex_tile_set != null, "HexTileMapLayer sample tile setup creates display TileSet")
	_assert_eq(hex_tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "HexTileMapLayer sample tile setup follows dock orientation")
	_assert_true(hex_tile_set.has_source(0), "HexTileMapLayer sample tile setup creates source 0")
	_assert_eq(hex_layer.floor_atlas_coords, Vector2i.ZERO, "HexTileMapLayer sample tile setup stores floor atlas")
	_assert_eq(hex_layer.wall_atlas_coords, Vector2i(1, 0), "HexTileMapLayer sample tile setup stores wall atlas")

	layer.free()
	hex_layer.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_selects_atlas_image() -> void:
	var dock = await _new_ready_dock()

	dock._tile_orientation_option.select(0)
	var layer = TileMapLayer.new()
	_assert_true(
		dock.setup_atlas_tiles_on_tile_map_layer(
			layer,
			HexMapTileAdapter.SAMPLE_TILE_ATLAS_PATH,
			3,
			HexMapTileAdapter.SAMPLE_TILE_SIZE,
			Vector2i(0, 0),
			Vector2i(1, 0)
		),
		"generation dock configures selected atlas image"
	)
	_assert_eq(dock._current_atlas_image_path, HexMapTileAdapter.SAMPLE_TILE_ATLAS_PATH, "generation dock stores selected atlas path")
	_assert_true(layer.tile_set.has_source(3), "selected atlas creates configured source id")
	_assert_eq(layer.tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_VERTICAL, "selected atlas follows flat-top orientation")
	var source = layer.tile_set.get_source(3)
	_assert_true(source is TileSetAtlasSource, "selected atlas source is TileSetAtlasSource")
	_assert_true(source.has_tile(Vector2i(0, 0)), "selected atlas creates floor tile")
	_assert_true(source.has_tile(Vector2i(1, 0)), "selected atlas creates wall tile")
	_assert_eq(int(dock._floor_source_spin.value), 3, "selected atlas syncs floor source")
	_assert_eq(int(dock._wall_source_spin.value), 3, "selected atlas syncs wall source")

	layer.free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_generate_auto_applies_current_map() -> void:
	var dock = await _new_ready_dock()

	_assert_true(not _control_row_visible(dock._floor_source_spin), "generation floor source spin is hidden from normal UI")
	_assert_true(not _control_row_visible(dock._floor_atlas_x_spin), "generation floor atlas spin is hidden from normal UI")
	_assert_true(not _control_row_visible(dock._wall_source_spin), "generation wall source spin is hidden from normal UI")
	_assert_true(not _control_row_visible(dock._wall_atlas_x_spin), "generation wall atlas spin is hidden from normal UI")
	_assert_true(dock._apply_layer_button != null, "generation dock keeps advanced manual apply button")
	_assert_true(not dock._apply_layer_button.visible, "generation dock hides manual apply from normal UI")
	_assert_eq(dock._apply_layer_button.text, "Advanced Apply", "generation dock demotes manual apply wording")
	_assert_true(not _has_button_text(dock, "Apply Layer"), "generation dock removes Apply Layer primary wording")
	_assert_true(not _has_button_text(dock, "Generate & Apply"), "generation dock removes Generate & Apply button")

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._refresh_controls()

	_assert_true(await dock._generate_map(), "generation dock regenerates without a target TileMapLayer")
	_assert_eq(dock._current_data.cells.size(), 2, "auto apply generation regenerates current data from controls")
	_assert_eq(dock._current_data.walls.size(), 0, "auto apply generation uses current wall probability")

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var layer = TileMapLayer.new()
	layer.name = "AutoApplyLayer"
	scene_root.add_child(layer)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.item_count, 3, "generation dock lists Auto, auto apply target, and add new layer")
	dock._tile_layer_option.select(1)
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(layer), "auto apply test configures sample tiles")

	var generation_id = dock._generation_id
	dock._on_generate_pressed()
	await _wait_for_progress_controls(dock, "auto apply Generate button generation")
	await _wait_for_generation(dock, "auto apply Generate button generation")
	_assert_eq(dock._generation_id, generation_id + 1, "generation dock auto apply Generate button generation succeeds")
	_assert_eq(layer.get_used_cells().size(), 2, "generation dock auto applies regenerated cells")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i.ZERO, "auto apply writes floor tile atlas")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i(1, 0)), Vector2i.ZERO, "auto apply writes every generated floor cell")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_generate_auto_applies_hex_tile_map_layer() -> void:
	var dock = await _new_ready_dock()

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._refresh_controls()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var layer = HexTileMapLayer.new()
	layer.name = "HexAutoApplyLayer"
	scene_root.add_child(layer)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.item_count, 3, "generation dock lists Auto, HexTileMapLayer target, and add new layer")
	_assert_eq(dock._tile_layer_option.get_item_text(1), "HexAutoApplyLayer (HexTileMapLayer)", "generation dock labels HexTileMapLayer auto apply target")
	dock._tile_layer_option.select(1)

	var generation_id = dock._generation_id
	dock._on_generate_pressed()
	await _wait_for_progress_controls(dock, "HexTileMapLayer auto apply Generate button generation")
	await _wait_for_generation(dock, "HexTileMapLayer auto apply Generate button generation")
	_assert_eq(dock._generation_id, generation_id + 1, "generation dock auto apply HexTileMapLayer generation succeeds")
	_assert_true(layer.hex_map is HexMapResource, "generation dock auto apply stores HexTileMapLayer resource")
	_assert_eq(layer.display_used_cell_count(), 2, "generation dock auto applies regenerated cells to HexTileMapLayer")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i.ZERO, "HexTileMapLayer auto apply writes floor tile atlas")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.q_axis()), Vector2i.ZERO, "HexTileMapLayer auto apply writes every generated floor cell")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_uniform_generation_and_apply() -> void:
	var dock = await _new_ready_dock()

	_assert_eq(dock._generate_button.text, "Primary Generation", "generation dock starts in primary generation mode")
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._refresh_controls()
	_assert_eq(dock._generate_button.text, "Overlay Generation", "overlay mode relabels Generate button")
	_assert_true(dock._overlay_controls_container.visible, "overlay mode shows overlay controls")
	_assert_true(dock._wall_prob_row.visible, "overlay uniform mode keeps placement probability visible")

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._overlay_item_pool_rows[0]["name"].text = "Tree"
	dock._overlay_item_pool_rows[0]["amount"].value = 1.0
	dock._on_overlay_add_item_pressed()
	dock._overlay_item_pool_rows[1]["name"].text = "Rock"
	dock._overlay_item_pool_rows[1]["amount"].value = 0.0
	dock._refresh_controls()

	var data = HexMapData.rectangle(2, 2)
	data.set_walls([HexVector.q_axis()])
	dock.register_mapdata_source(HexMapResource.from_map_data(data), "res://overlay_basic.tres")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, dock._mapdata_sources[0]["id"], "Floor")
	dock._refresh_controls()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var layer = TileMapLayer.new()
	layer.name = "OverlayLayer"
	scene_root.add_child(layer)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	dock._tile_layer_option.select(1)
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(layer), "overlay apply test configures sample tiles")

	_assert_true(dock._current_data == null, "overlay generation does not require current primary data")
	_assert_true(dock._apply_write_policy_option.visible, "Apply Write remains visible in Overlay mode")
	_assert_true(await dock._generate_map(), "generation dock generates overlay data")
	_assert_true(dock._current_overlay_data != null, "overlay generation stores current overlay data")
	_assert_eq(dock._current_overlay_data.item_cells("Tree").size(), data.floor_cells().size(), "overlay uniform generation uses primary floor cells as candidates")
	_assert_eq(dock._current_overlay_data.item_cells("Rock").size(), 0, "overlay uniform generation honors item weights")
	_assert_eq(layer.get_used_cells().size(), data.floor_cells().size(), "overlay generation auto applies overlay cells to Target")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "overlay apply uses Wall atlas controls as item tile")
	_assert_true(dock.current_resource() is HexOverlayResource, "overlay mode saves current overlay resource")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_applies_to_hex_tile_map_layer() -> void:
	var dock = await _new_ready_dock()
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_item_pool_rows[0]["name"].text = "Tree"
	dock._overlay_item_pool_rows[0]["tile_source"].value = 0
	dock._overlay_item_pool_rows[0]["tile_atlas_x"].value = 1
	dock._overlay_item_pool_rows[0]["tile_atlas_y"].value = 0
	dock._refresh_controls()
	var data = HexMapData.rectangle(2, 1)
	dock._current_overlay_data = HexOverlayData.from_item_cells(data.cells, "Tree", data.cells)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(data))

	_assert_true(dock.apply_current_overlay_data_to_tile_map_layer(layer), "generation dock applies overlay data to HexTileMapLayer")
	var origin_map_cell = HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true)
	_assert_eq(layer._overlay_tile_map.get_cell_atlas_coords(origin_map_cell), Vector2i(1, 0), "HexTileMapLayer overlay apply writes overlay atlas")
	var state = layer.display_state_for_hex(HexVector.zero())
	_assert_eq(state["overlay_count"], 1, "HexTileMapLayer overlay apply exposes overlay state")
	var snapshot = layer.to_document_resource()
	var snapshot_tile_entries = HexMapDocumentAdapter.document_tile_entries(snapshot)
	_assert_eq(snapshot_tile_entries.size(), 2, "HexTileMapLayer overlay apply exports overlay entries")
	_assert_eq(snapshot_tile_entries[0]["kind"], HexMapDocumentAdapter.KIND_OVERLAY, "HexTileMapLayer overlay snapshot stores overlay kind")

	layer.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_limit_and_apply_policy() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._overlay_item_pool_rows[0]["name"].text = "Coin"
	dock._overlay_item_limit_check.set_pressed_no_signal(true)
	dock._overlay_item_pool_rows[0]["amount"].value = 2
	dock._on_overlay_add_item_pressed()
	dock._overlay_item_pool_rows[1]["name"].text = "Gem"
	dock._overlay_item_pool_rows[1]["amount"].value = 1
	var data = HexMapData.rectangle(4, 1)
	dock.register_mapdata_source(HexMapResource.from_map_data(data), "res://overlay_limit.tres")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, dock._mapdata_sources[0]["id"], "Floor")
	dock._refresh_controls()

	_assert_eq(dock._overlay_item_pool_rows[0]["amount_label"].text, "Limit", "overlay limited uniform mode shows item limits")
	_assert_true(not dock._wall_prob_row.visible, "overlay limited uniform mode hides placement probability")
	_assert_true(await dock._generate_map(), "generation dock generates limited overlay data")
	_assert_eq(dock._current_overlay_data.item_cells("Coin").size(), 2, "overlay limited generation places requested item count")
	_assert_eq(dock._current_overlay_data.item_cells("Gem").size(), 1, "overlay limited generation supports multiple item limits")

	dock._overlay_item_pool_rows[0]["name"].text = "Key"
	dock._overlay_item_pool_rows[0]["amount"].value = 1
	dock._overlay_item_pool_rows[1]["amount"].value = 0
	dock._apply_write_policy_option.select(1)
	_assert_true(await dock._generate_map(), "generation dock merges overlay data with Add Item policy")
	_assert_eq(dock._current_overlay_data.item_cells("Coin").size(), 2, "overlay Add Item policy preserves existing item data")
	_assert_eq(dock._current_overlay_data.item_cells("Gem").size(), 1, "overlay Add Item policy preserves existing second item data")
	_assert_eq(dock._current_overlay_data.item_cells("Key").size(), 1, "overlay Add Item policy adds generated item data")

	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_placement_mask_filters_candidates() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._overlay_item_pool_rows[0]["name"].text = "Moss"
	dock._overlay_item_pool_rows[0]["amount"].value = 1.0
	var data = HexMapData.rectangle(3, 1)
	data.set_walls([HexVector.q_axis()])
	var source_id = dock.register_mapdata_source(HexMapResource.from_map_data(data), "res://mask_data.tres")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Wall")
	dock._refresh_controls()

	_assert_true(await dock._generate_map(), "generation dock generates overlay from placement mask")
	_assert_eq(dock._current_overlay_data.item_cells("Moss").size(), 1, "placement mask restricts overlay candidates to selected primary item")
	_assert_eq(dock._current_overlay_data.item_cells("Moss")[0].key(), HexVector.q_axis().key(), "placement mask item is generated on the selected wall cell")

	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_adjacency_reference_generation() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_adjacency_check.set_pressed_no_signal(true)
	dock._on_overlay_adjacency_toggled(true)
	dock._overlay_item_name_edit.text = "NearWall"
	dock._overlay_neighbor_radius_spin.value = 1
	dock._overlay_adjacency_rules_edit.text = "1=1.0;default=0.0"
	var data = HexMapData.hexagon(1)
	data.set_walls([HexVector.q_axis()])
	var source_id = dock.register_mapdata_source(HexMapResource.from_map_data(data), "res://adjacency_data.tres")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Floor")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_REFERENCE, source_id, "Wall")
	dock._refresh_controls()

	_assert_eq(dock._generate_option.selected, HexMapGenDock.GENERATE_SYMMETRIC, "adjacency reference switches overlay generation to Markov Mesh")
	_assert_true(dock._overlay_reference_container.visible, "adjacency reference shows reference controls")
	_assert_true(await dock._generate_map(), "generation dock generates adjacency overlay")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "NearWall"), "adjacency reference generates item next to reference cell")
	_assert_true(not dock._current_overlay_data.has_item(HexVector.apply_basis(-1, 1, 0), "NearWall"), "adjacency reference leaves cells without matching neighbor rule empty")

	dock.queue_free()
	await process_frame


func _test_generation_dock_adjacency_generated_reference_snapshot() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_adjacency_check.set_pressed_no_signal(true)
	dock._on_overlay_adjacency_toggled(true)
	dock._refresh_controls()

	_assert_true(dock._overlay_generated_reference_check.visible, "Generated Item Reference control is visible for adjacency overlay")
	var static_snapshot = dock._create_generation_snapshot()
	_assert_true(
		not bool(static_snapshot.get("overlay_generated_reference_enabled", true)),
		"Generated Item Reference is disabled in snapshot by default"
	)

	dock._overlay_generated_reference_check.set_pressed_no_signal(true)
	var dynamic_snapshot = dock._create_generation_snapshot()
	_assert_true(
		bool(dynamic_snapshot.get("overlay_generated_reference_enabled", false)),
		"Generated Item Reference checkbox is reflected in generation snapshot"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_adjacency_generated_reference_changes_result() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_adjacency_check.set_pressed_no_signal(true)
	dock._on_overlay_adjacency_toggled(true)
	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._gen_radius_spin.set_value_no_signal(1)
	dock._overlay_item_name_edit.text = "Vine"
	dock._overlay_neighbor_radius_spin.value = 1
	dock._overlay_adjacency_rules_edit.text = "1=1.0;default=0.0"
	var first_candidate = HexVector.q_axis()
	var second_candidate = HexVector.q_axis().scaled(2)
	var source_data = HexOverlayData.from_cells(
		HexMapData.square(3, false).cells,
		{
			"Candidate": [first_candidate, second_candidate],
			"Seed": [HexVector.zero()],
		}
	)
	var source_id = dock.register_mapdata_source(
		HexOverlayResource.from_overlay_data(source_data),
		"res://generated_reference.tres"
	)
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Candidate")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_REFERENCE, source_id, "Seed")
	dock._refresh_controls()

	var static_snapshot = dock._create_generation_snapshot()
	var static_data = dock._generate_overlay_data_from_snapshot(static_snapshot, {})
	_assert_keys_eq(
		static_data.item_cells("Vine"),
		[first_candidate],
		"adjacency snapshot without Generated Item Reference keeps generated items out of reference stats"
	)

	dock._overlay_generated_reference_check.set_pressed_no_signal(true)
	var dynamic_snapshot = dock._create_generation_snapshot()
	var dynamic_data = dock._generate_overlay_data_from_snapshot(dynamic_snapshot, {})
	_assert_keys_eq(
		dynamic_data.item_cells("Vine"),
		[first_candidate, second_candidate],
		"adjacency snapshot with Generated Item Reference uses generated target items as later references"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_item_pool_tile_mapping() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_item_pool_rows[0]["name"].text = "Tree"
	dock._overlay_item_pool_rows[0]["tile_atlas_x"].value = 0
	dock._overlay_item_pool_rows[0]["tile_atlas_y"].value = 0
	_assert_true(not dock._overlay_item_pool_rows[0]["tile_source"].visible, "item pool source spin is hidden from normal UI")
	_assert_true(not dock._overlay_item_pool_rows[0]["tile_atlas_x"].visible, "item pool atlas x spin is hidden from normal UI")
	_assert_true(not dock._overlay_item_pool_rows[0]["copy_floor"].visible, "item pool Floor tile copy is hidden from normal UI")
	_assert_true(not dock._overlay_item_pool_rows[0]["copy_wall"].visible, "item pool Wall tile copy is hidden from normal UI")
	dock._floor_source_spin.set_value_no_signal(0)
	dock._floor_atlas_x_spin.set_value_no_signal(0)
	dock._floor_atlas_y_spin.set_value_no_signal(0)
	dock._on_overlay_item_tile_copy_pressed(dock._overlay_item_pool_rows[0], false)
	_assert_eq(dock._overlay_item_pool_rows[0]["tile_source"].value, 0.0, "item pool copies Floor tile source")
	_assert_eq(dock._overlay_item_pool_rows[0]["tile_atlas_x"].value, 0.0, "item pool copies Floor tile atlas x")
	_assert_eq(dock._overlay_item_pool_rows[0]["tile_atlas_y"].value, 0.0, "item pool copies Floor tile atlas y")
	dock._on_overlay_add_item_pressed()
	dock._overlay_item_pool_rows[1]["name"].text = "Rock"
	dock._wall_source_spin.set_value_no_signal(0)
	dock._wall_atlas_x_spin.set_value_no_signal(1)
	dock._wall_atlas_y_spin.set_value_no_signal(0)
	dock._on_overlay_item_tile_copy_pressed(dock._overlay_item_pool_rows[1], true)
	_assert_eq(dock._overlay_item_pool_rows[1]["tile_source"].value, 0.0, "item pool copies Wall tile source")
	_assert_eq(dock._overlay_item_pool_rows[1]["tile_atlas_x"].value, 1.0, "item pool copies Wall tile atlas x")
	_assert_eq(dock._overlay_item_pool_rows[1]["tile_atlas_y"].value, 0.0, "item pool copies Wall tile atlas y")
	_assert_true(not dock._overlay_item_pool_rows[1]["copy_floor"].visible, "item pool keeps Floor tile copy out of normal UI")
	_assert_true(not dock._overlay_item_pool_rows[1]["copy_wall"].visible, "item pool keeps Wall tile copy out of normal UI")
	dock._current_overlay_data = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{
			"Tree": [HexVector.zero()],
			"Rock": [HexVector.q_axis()],
		}
	)

	var layer = TileMapLayer.new()
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(layer), "overlay tile mapping test configures sample tiles")
	_assert_true(dock.apply_current_overlay_data_to_tile_map_layer(layer), "overlay tile mapping applies current overlay data")
	_assert_eq(layer.get_cell_source_id(Vector2i.ZERO), 0, "overlay item pool maps Tree to copied source")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(0, 0), "overlay item pool maps Tree to copied Floor tile")
	_assert_eq(layer.get_cell_source_id(Vector2i(1, 0)), 0, "overlay item pool maps Rock to copied source")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i(1, 0)), Vector2i(1, 0), "overlay item pool maps Rock to copied Wall tile")

	var replacing_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_overlay_data_to_tile_map_layer(replacing_layer), "overlay apply clears with Clear And Write")
	_assert_true(replacing_layer.cleared, "Apply Write Clear And Write clears existing Overlay layer cells")

	dock._apply_write_policy_option.select(1)
	var fake_overlay_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_overlay_data_to_tile_map_layer(fake_overlay_layer), "overlay apply works without clearing")
	_assert_true(not fake_overlay_layer.cleared, "Apply Write Add Item preserves existing Overlay layer cells")

	layer.free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_catalog_selectors_drive_tile_defaults() -> void:
	var dock = await _new_ready_dock()
	_assert_true(dock.tile_catalog() != null, "generation dock loads sample tile catalog")
	_assert_true(dock._floor_catalog_option.item_count >= 2, "generation dock floor catalog lists sample entries")
	_assert_true(dock._wall_catalog_option.item_count >= 2, "generation dock wall catalog lists sample entries")

	dock._select_catalog_option_by_key(dock._floor_catalog_option, "terrain.floor")
	dock._on_floor_catalog_selected(dock._floor_catalog_option.selected)
	dock._select_catalog_option_by_key(dock._wall_catalog_option, "terrain.wall")
	dock._on_wall_catalog_selected(dock._wall_catalog_option.selected)
	_assert_eq(dock._catalog_key_from_option(dock._floor_catalog_option), "terrain.floor", "generation floor selector stores catalog key")
	_assert_eq(dock._catalog_key_from_option(dock._wall_catalog_option), "terrain.wall", "generation wall selector stores catalog key")

	dock._overlay_item_pool_rows[0]["name"].text = "Treasure"
	var overlay_option: OptionButton = dock._overlay_item_pool_rows[0]["catalog_option"]
	dock._select_catalog_option_by_key(overlay_option, "overlay.treasure")
	dock._on_overlay_item_catalog_selected(overlay_option.selected, dock._overlay_item_pool_rows[0])
	_assert_eq(dock._catalog_key_from_option(overlay_option), "overlay.treasure", "overlay item pool selector stores catalog key")
	dock._current_overlay_data = HexOverlayData.from_cells([HexVector.zero()], {"Treasure": [HexVector.zero()]})
	var catalog_configs = dock._overlay_item_tile_configs()
	_assert_eq(catalog_configs["Treasure"]["catalog_key"], "overlay.treasure", "overlay item pool config preserves catalog key")
	_assert_eq(catalog_configs["Treasure"]["atlas_coords"], Vector2i(0, 0), "overlay item pool catalog resolves atlas coords")

	dock.queue_free()
	await process_frame


func _test_generation_dock_mapdata_source_registry_load_reload_clear() -> void:
	var dock = await _new_ready_dock()
	var path = _test_resource_path("test_mapdata_source_overlay.tres")
	var overlay = HexOverlayData.from_cells(
		[HexVector.zero()],
		{"Tree": [HexVector.zero()]}
	)
	_save_resource(path, HexOverlayResource.from_overlay_data(overlay))

	var source_id = dock.load_mapdata_source(path)
	_assert_true(source_id > 0, "source registry loads HexOverlayResource")
	_assert_eq(dock._mapdata_sources.size(), 1, "source registry stores loaded source")
	_assert_eq(dock._mapdata_sources[0]["resource_type"], HexMapGenDock.MAPDATA_SOURCE_OVERLAY, "source registry records overlay type")
	_assert_eq(dock._mapdata_sources[0]["item_keys"], ["Tree"], "source registry exposes overlay item keys")
	_assert_true(
		dock._source_entry_details_text(dock._mapdata_sources[0]).contains("Tree: 1"),
		"source registry details show overlay item cell count"
	)
	_assert_true(
		dock._source_entry_details_text(dock._mapdata_sources[0]).contains(path),
		"source registry details show resource path"
	)

	var reloaded = HexOverlayData.from_cells(
		[HexVector.zero()],
		{"Rock": [HexVector.zero()]}
	)
	_save_resource(path, HexOverlayResource.from_overlay_data(reloaded))
	var reloaded_id = dock.load_mapdata_source(path)
	_assert_eq(reloaded_id, source_id, "same source path reloads existing entry")
	_assert_eq(dock._mapdata_sources.size(), 1, "same source path does not add duplicate")
	_assert_eq(dock._mapdata_sources[0]["item_keys"], ["Rock"], "reload updates item keys")

	var map_data = HexMapData.rectangle(2, 1)
	map_data.set_walls([HexVector.q_axis()])
	var map_id = dock.register_mapdata_source(HexMapResource.from_map_data(map_data), "res://source_registry_map.tres")
	var map_entry = dock._source_entry_by_id(map_id)
	var map_details = dock._source_entry_details_text(map_entry)
	_assert_true(map_details.contains("Any: 2"), "source registry details show primary Any count")
	_assert_true(map_details.contains("Floor: 1"), "source registry details show primary Floor count")
	_assert_true(map_details.contains("Wall: 1"), "source registry details show primary Wall count")

	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Rock")
	_assert_eq(dock._overlay_mask_query_rows.size(), 1, "query row references loaded source")
	dock.clear_mapdata_source(source_id)
	_assert_eq(dock._mapdata_sources.size(), 1, "clear removes only selected source")
	_assert_eq(dock._overlay_mask_query_rows.size(), 0, "clear removes query rows using source")
	_assert_true(dock._source_registry_status_label.text.contains("Sources: 1"), "source registry status shows remaining source count")
	dock.clear_mapdata_source(map_id)
	_assert_eq(dock._mapdata_sources.size(), 0, "clear removes all sources")
	_assert_eq(dock._source_registry_status_label.text, "No mapdata sources loaded.", "source registry status shows empty state")

	dock.queue_free()
	await process_frame


func _test_generation_dock_path_action_labels_and_failure_status() -> void:
	var dock = await _new_ready_dock()
	_assert_eq(dock._source_load_button.text, "Browse .tres", "source registry uses browse wording")
	_assert_eq(dock._generate_history_dir_button.text, "History Dir", "generate history uses directory wording")
	_assert_eq(dock._save_button.text, "Save As .tres", "generation save uses save-as wording")
	_assert_eq(dock._atlas_image_button.text, "Browse Atlas Image", "atlas image uses browse wording")

	dock._on_source_file_selected(_test_resource_path("missing_source_registry_resource.tres"))
	_assert_true(
		dock._source_registry_status_label.text.contains("Failed to load mapdata source"),
		"source registry file selection failure appears in status"
	)
	dock._generate_history_check.set_pressed_no_signal(true)
	dock._generate_history_dir = ""
	dock._refresh_generate_history_label()
	_assert_eq(dock._generate_history_dir_label.text, "History: choose directory", "history enabled without dir asks for directory")

	dock.queue_free()
	await process_frame


func _test_generation_dock_mapdata_query_rows_evaluate_offset_and_toric() -> void:
	var dock = await _new_ready_dock()
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(3)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._refresh_controls()
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		HexMapData.rectangle(3, 1).cells,
		"zero Mask Query Rows pass the full shape universe"
	)
	var map_data = HexMapData.rectangle(3, 1)
	map_data.set_walls([HexVector.q_axis()])
	var map_id = dock.register_mapdata_source(HexMapResource.from_map_data(map_data), "res://map_query.tres")
	_assert_eq(dock._overlay_mask_add_source_option.get_item_text(0), "map_query.tres", "query add source option is scoped to resource name")
	_assert_eq(dock._overlay_mask_add_source_option.get_popup().max_size.y, 260, "query add source option popup is height-limited for scrolling")

	var floor_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, map_id, "Floor")
	_assert_true(floor_row["row"] is VBoxContainer, "query row uses two-line container")
	_assert_eq(floor_row["source_label"].text, "map_query.tres", "query row shows resource name as a label")
	_assert_eq(floor_row["source_item"].get_item_text(floor_row["source_item"].selected), "Floor", "query row item combo is scoped to item key")
	_assert_eq(floor_row["source_item"].item_count, 3, "query row item combo lists only selected resource items")
	_assert_eq(floor_row["source_item"].get_popup().max_size.y, 260, "query row item combo popup is height-limited for scrolling")
	_assert_true(floor_row["offset_panel"] is HexCellButtonPanel, "query row has common hex cell offset panel")
	_assert_eq(floor_row["offset_panel"].get_entries().size(), 7, "query row offset panel lays out center and six direction cells")
	_assert_eq(_pressable_entry_count(floor_row["offset_panel"].get_entries()), 6, "query row offset panel exposes six pressable directions")
	var center_entry: Dictionary = _entries_by_id(floor_row["offset_panel"].get_entries())[HexVector.zero().key()]
	_send_panel_motion(floor_row["offset_panel"], center_entry["center"])
	_assert_true(floor_row["offset_panel"].tooltip_text.contains("Current offset"), "query row center cell shows current offset tooltip")
	var wall_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, map_id, "Wall")
	wall_row["operation"].select(1)
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		map_data.cells,
		"query rows OR selected item cells"
	)

	wall_row["operation"].select(0)
	wall_row["match"].select(1)
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		map_data.floor_cells(),
		"query rows apply Exclude as universe complement with AND"
	)

	dock._overlay_mask_query_rows.clear()
	dock._rect_width_spin.set_value_no_signal(1)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._refresh_controls()
	var outside_overlay = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{"Outside": [HexVector.q_axis()], "Inside": [HexVector.zero()]}
	)
	var outside_id = dock.register_mapdata_source(HexOverlayResource.from_overlay_data(outside_overlay), "res://outside_query.tres")
	var outside_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, outside_id, "Outside")
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		[],
		"mask query Crop Off clips Contain cells to current shape universe"
	)
	outside_row["match"].select(1)
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		[HexVector.zero()],
		"mask query Crop Off uses current shape universe for Exclude complement"
	)

	dock._overlay_mask_query_rows.clear()
	var shifted_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, outside_id, "Inside")
	_press_query_row_direction(shifted_row, 0)
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		[],
		"mask query Crop Off clips offset results outside current shape universe"
	)
	dock._current_data = HexMapData.rectangle(2, 1)
	var snapshot = dock._create_generation_snapshot()
	_assert_keys_eq(
		snapshot["overlay_candidate_cells"],
		[],
		"empty Mask query does not fallback to current Primary floor cells"
	)
	_assert_true(dock._generate_button.disabled, "empty Mask query disables Generate")
	_assert_true(not await dock._generate_map(), "empty Mask query does not start generation")
	_assert_eq(
		dock.generation_status()["status"],
		HexMapGenDock.GENERATION_BLOCK_STATUS_PREFIX + HexMapGenDock.GENERATION_BLOCK_EMPTY_MASK,
		"empty Mask query block reason is visible"
	)

	var overlay = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{"Gem": [HexVector.zero()]}
	)
	var overlay_id = dock.register_mapdata_source(HexOverlayResource.from_overlay_data(overlay), "res://offset_query.tres")
	dock._overlay_reference_query_rows.clear()
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._refresh_controls()
	var offset_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_REFERENCE, overlay_id, "Gem")
	var offset_panel: HexCellButtonPanel = offset_row["offset_panel"]
	dock._on_query_cell_radius_changed(18.0)
	dock._on_query_cell_gap_changed(3.0)
	dock._on_query_cell_padding_changed(5.0)
	_assert_eq(offset_panel.cell_radius, 18.0, "query offset panel radius is adjustable")
	_assert_eq(offset_panel.cell_gap, 3.0, "query offset panel gap is adjustable")
	_assert_eq(offset_panel.padding, Vector2(5, 5), "query offset panel padding is adjustable")
	_assert_eq(dock._query_cell_radius_spin.value, 18.0, "query cell radius syncs shared control")
	_assert_eq(dock._query_cell_gap_spin.value, 3.0, "query cell gap syncs shared control")
	_assert_eq(dock._query_cell_padding_spin.value, 5.0, "query cell padding syncs shared control")
	var q_entry: Dictionary = _entries_by_id(offset_panel.get_entries())[HexVector.q_axis().key()]
	_send_panel_click(offset_panel, q_entry["center"])
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_REFERENCE),
		[HexVector.q_axis()],
		"query rows offset item cells"
	)
	dock._set_generation_controls_disabled(true)
	_assert_true(not offset_panel.enabled, "generation disable state disables query offset panel")
	dock._set_generation_controls_disabled(false)
	_assert_true(offset_panel.enabled, "generation enable state re-enables query offset panel")

	var toric_data = HexOverlayData.from_cells(
		HexMapData.square(3, true).cells,
		{"Wrap": [HexVector.apply_basis(2, 0, 0)]},
		3
	)
	var toric_id = dock.register_mapdata_source(HexOverlayResource.from_overlay_data(toric_data), "res://toric_query.tres")
	dock._overlay_reference_query_rows.clear()
	var toric_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_REFERENCE, toric_id, "Wrap")
	_press_query_row_direction(toric_row, 0)
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_REFERENCE),
		[HexVector.zero()],
		"query rows wrap offset cells for toric source"
	)
	dock._rect_width_spin.set_value_no_signal(5)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._refresh_controls()
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_REFERENCE),
		[HexVector.zero(), HexVector.apply_basis(3, 0, 0)],
		"toric source query expands all matching representatives inside the shape universe"
	)

	dock._overlay_mask_query_rows.clear()
	var toric_mask_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, toric_id, "Wrap")
	_press_query_row_direction(toric_mask_row, 0)
	var crop_data = dock._overlay_crop_result_data()
	_assert_keys_eq(
		crop_data.item_cells(dock._crop_result_item_key(toric_mask_row)),
		[HexVector.zero(), HexVector.apply_basis(3, 0, 0)],
		"Crop result stores all toric source representatives inside the shape universe"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_deductor_floor_source_query() -> void:
	var dock = await _new_ready_dock()
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._gen_radius_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._connect_method_option.select(_connect_method_index(HexMapGenerator.CONNECT_DENSE))
	dock._refresh_controls()
	_assert_true(dock._overlay_deductor_floor_container.visible, "deductor floor source is visible for Markov Mesh overlay")

	dock._overlay_adjacency_check.set_pressed_no_signal(true)
	dock._refresh_controls()
	_assert_true(not dock._overlay_deductor_floor_container.visible, "deductor floor source hides for adjacency overlay")
	dock._overlay_adjacency_check.set_pressed_no_signal(false)
	dock._refresh_controls()

	var candidate_source = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{"Candidate": [HexVector.q_axis()]}
	)
	var candidate_id = dock.register_mapdata_source(
		HexOverlayResource.from_overlay_data(candidate_source),
		"res://deductor_candidate.tres"
	)
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, candidate_id, "Candidate")

	var default_snapshot = dock._create_generation_snapshot()
	_assert_keys_eq(
		default_snapshot["overlay_candidate_cells"],
		[HexVector.q_axis()],
		"deductor floor test uses placement mask candidate"
	)
	_assert_keys_eq(
		default_snapshot["overlay_deductor_floor_cells"],
		[],
		"deductor floor default is resolved after generation"
	)
	_assert_eq(
		default_snapshot["overlay_deductor_floor_source_enabled"],
		false,
		"deductor floor snapshot records missing source rows"
	)
	_assert_eq(
		dock._overlay_deductor_floor_status_label.text,
		"Default: generated complement",
		"deductor floor default status describes generated complement"
	)
	var default_generated = dock._generate_overlay_data_from_snapshot(default_snapshot, {})
	_assert_true(
		default_generated.has_item(HexVector.q_axis(), "Item1"),
		"deductor floor default uses generated complement instead of placement candidates"
	)

	var floor_source = HexMapData.rectangle(1, 1)
	var floor_id = dock.register_mapdata_source(
		HexMapResource.from_map_data(floor_source),
		"res://deductor_floor.tres"
	)
	dock._overlay_mask_crop_check.set_pressed_no_signal(true)
	var floor_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_DEDUCTOR_FLOOR, floor_id, "Floor")
	_assert_true(dock._overlay_mask_crop_check.button_pressed, "deductor floor query edit does not turn Crop off")
	var custom_snapshot = dock._create_generation_snapshot()
	_assert_keys_eq(
		custom_snapshot["overlay_candidate_cells"],
		[HexVector.q_axis()],
		"deductor floor source keeps placement mask candidates separate"
	)
	_assert_keys_eq(
		custom_snapshot["overlay_deductor_floor_cells"],
		[HexVector.zero()],
		"deductor floor source overrides connectivity floor cells"
	)
	_assert_true(
		dock._overlay_deductor_floor_status_label.text.contains("Deductor floor cells: 1"),
		"deductor floor source shows resolved cell count"
	)

	var generated = dock._generate_overlay_data_from_snapshot(custom_snapshot, {})
	_assert_true(
		generated.has_item(HexVector.q_axis(), "Item1"),
		"deductor floor source can differ from candidates during generation"
	)

	dock._on_query_row_remove_pressed(floor_row, HexMapGenDock.QUERY_KIND_DEDUCTOR_FLOOR)
	dock._gen_radius_spin.set_value_no_signal(0)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(1)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._refresh_controls()
	var empty_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_DEDUCTOR_FLOOR, floor_id, "Any")
	empty_row["match"].select(1)
	var empty_snapshot = dock._create_generation_snapshot()
	_assert_keys_eq(
		empty_snapshot["overlay_deductor_floor_cells"],
		[],
		"empty deductor floor query stays empty"
	)
	_assert_eq(
		dock._overlay_deductor_floor_status_label.text,
		"Deductor Floor Source query result is empty.",
		"empty deductor floor query shows status warning"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_mapdata_crop_result_and_reset_rules() -> void:
	var dock = await _new_ready_dock()
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.value = 1
	dock._rect_height_spin.value = 1
	dock._refresh_controls()

	var overlay = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{
			"Tree": [HexVector.zero()],
			"Rock": [HexVector.q_axis()],
		}
	)
	var source_id = dock.register_mapdata_source(HexOverlayResource.from_overlay_data(overlay), "res://crop_query.tres")
	var contain_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Tree")
	var exclude_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Rock")
	exclude_row["operation"].select(1)
	exclude_row["match"].select(1)
	dock._overlay_mask_crop_check.set_pressed_no_signal(true)
	dock._refresh_mask_crop_count()

	var crop = dock._overlay_crop_result_data()
	_assert_keys_eq(crop.cells, [HexVector.zero()], "crop result uses current shape universe")
	_assert_keys_eq(crop.item_cells("Any"), [HexVector.zero()], "crop result stores Any universe")
	_assert_keys_eq(crop.item_cells("crop_query.tres / Tree"), [HexVector.zero()], "crop result stores prefixed contain item")
	_assert_eq(crop.item_cells("crop_query.tres / Rock").size(), 0, "crop result excludes Exclude item output")
	_assert_eq(dock._overlay_mask_count_label.text, "Cells: 1", "crop count ignores Any and duplicate cells")

	var crop_item_key = dock._crop_result_item_key(contain_row)
	var crop_layer = FakeTileLayer.new()
	_assert_true(dock._apply_crop_result_to_tile_map_layer(crop_layer), "crop result applies with Clear And Write")
	_assert_true(crop_layer.cleared, "crop result Clear And Write clears target layer")
	_assert_keys_eq(dock._current_overlay_data.item_cells(crop_item_key), [HexVector.zero()], "crop result Clear And Write replaces current overlay")

	dock._current_overlay_data = HexOverlayData.from_cells([HexVector.zero()], {"Old": [HexVector.zero()]})
	dock._apply_write_policy_option.select(1)
	var crop_add_layer = FakeTileLayer.new()
	_assert_true(dock._apply_crop_result_to_tile_map_layer(crop_add_layer), "crop result applies with Add Item")
	_assert_true(not crop_add_layer.cleared, "crop result Add Item preserves target layer cells")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "Old"), "crop result Add Item preserves current overlay item")
	_assert_keys_eq(dock._current_overlay_data.item_cells(crop_item_key), [HexVector.zero()], "crop result Add Item merges crop item")

	_press_query_row_direction(dock._overlay_mask_query_rows[0], 0)
	_assert_true(not dock._overlay_mask_crop_check.button_pressed, "mask query edit turns Crop off")
	dock._overlay_mask_crop_check.set_pressed_no_signal(true)
	dock._on_shape_size_changed(2)
	_assert_true(not dock._overlay_mask_crop_check.button_pressed, "shape size edit turns Crop off")
	dock._overlay_mask_crop_check.set_pressed_no_signal(true)
	dock._add_query_row(HexMapGenDock.QUERY_KIND_REFERENCE, source_id, "Tree")
	_assert_true(dock._overlay_mask_crop_check.button_pressed, "reference query edit does not turn Crop off")

	dock.queue_free()
	await process_frame


func _test_generation_dock_mapdata_crop_off_stacks_overlay_sources() -> void:
	var dock = await _new_ready_dock()
	dock._overlay_mode_check.set_pressed_no_signal(true)
	var primary = HexMapData.rectangle(1, 1)
	dock.register_mapdata_source(HexMapResource.from_map_data(primary), "res://stack_primary.tres")
	var first = HexOverlayData.from_cells(
		[HexVector.zero()],
		{"Tree": [HexVector.zero()]}
	)
	var second = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{"Rock": [HexVector.zero()], "Gem": [HexVector.q_axis()]}
	)
	dock.register_mapdata_source(HexOverlayResource.from_overlay_data(first), "res://stack_first.tres")
	dock.register_mapdata_source(HexOverlayResource.from_overlay_data(second), "res://stack_second.tres")
	dock._overlay_existing_policy_option.select(1)
	dock._current_overlay_data = HexOverlayData.from_cells([HexVector.zero()], {"Old": [HexVector.zero()]})

	_assert_true(dock._apply_overlay_source_stack_to_current(), "crop off stack applies overlay sources")
	_assert_true(dock._source_registry_status_label.text.contains("Stacked 2 overlay source(s)"), "crop off stack status shows source count")
	_assert_true(dock._source_registry_status_label.text.contains("occupied=2"), "crop off stack status shows occupied count")
	_assert_true(dock._source_registry_status_label.text.contains(HexOverlayData.APPLY_CLEAR_AND_WRITE), "crop off stack status shows Clear And Write policy")
	_assert_eq(dock._current_overlay_data.item_cells("Tree").size(), 0, "replace existing removes earlier item on same cell")
	_assert_eq(dock._current_overlay_data.item_cells("Old").size(), 0, "Clear And Write policy replaces existing current overlay")
	_assert_keys_eq(dock._current_overlay_data.item_cells("Rock"), [HexVector.zero()], "stack keeps later replacement item")
	_assert_keys_eq(dock._current_overlay_data.item_cells("Gem"), [HexVector.q_axis()], "stack preserves non-conflicting later item")
	_assert_eq(dock._current_overlay_data.item_cells("Floor").size(), 0, "stack ignores Primary source")

	dock._current_overlay_data = HexOverlayData.from_cells([HexVector.zero()], {"Old": [HexVector.zero()]})
	dock._apply_write_policy_option.select(1)
	dock._overlay_existing_policy_option.select(0)
	_assert_true(dock._apply_overlay_source_stack_to_current(), "Add Item write policy merges stack into current overlay")
	_assert_true(dock._source_registry_status_label.text.contains(HexOverlayData.APPLY_ADD_ITEM), "crop off stack status shows Add Item policy")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "Old"), "Add Item write policy preserves existing current item")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "Tree"), "Add Item write policy adds stacked source item")

	var empty_dock = await _new_ready_dock()
	empty_dock._overlay_mode_check.set_pressed_no_signal(true)
	_assert_true(not empty_dock._apply_overlay_source_stack_to_current(), "empty overlay source stack does not update current overlay")
	_assert_eq(
		empty_dock._source_registry_status_label.text,
		"No HexOverlayData source found in Source Registry.",
		"empty overlay source stack shows status reason"
	)

	empty_dock.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_generate_history_saves_overlay_delta_source() -> void:
	var dock = await _new_ready_dock()
	var history_dir = _test_resource_dir("mapdata_history")
	dock._set_generate_history_directory_for_test(history_dir)
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._overlay_item_limit_check.set_pressed_no_signal(true)
	dock._overlay_item_pool_rows[0]["name"].text = "Key"
	dock._overlay_item_pool_rows[0]["amount"].value = 1.0
	dock._apply_write_policy_option.select(1)
	dock._current_data = HexMapData.rectangle(1, 1)
	dock._current_overlay_data = HexOverlayData.from_cells(
		[HexVector.zero()],
		{"Old": [HexVector.zero()]}
	)
	dock._refresh_controls()

	var before_count = dock._mapdata_sources.size()
	_assert_true(await dock._generate_map(), "generate history test generates overlay")
	_assert_eq(dock._mapdata_sources.size(), before_count + 1, "generate history adds saved source")
	var source = dock._mapdata_sources[dock._mapdata_sources.size() - 1]
	var saved_data = source["data"]
	_assert_eq(source["resource_type"], HexMapGenDock.MAPDATA_SOURCE_OVERLAY, "generate history registers overlay source")
	_assert_true(String(source["resource_path"]).contains("overlay-combination-key"), "generate history uses combination in limited overlay filenames")
	_assert_eq(saved_data.item_cells("Old").size(), 0, "generate history stores overlay delta before Add Item policy")
	_assert_eq(saved_data.item_cells("Key").size(), 1, "generate history stores generated overlay delta item")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "Old"), "current overlay still applies Add Item policy")
	_assert_eq(dock._history_condition_name({"overlay_mode": true}), "overlay-uniform", "generate history keeps overlay uniform name")
	_assert_eq(dock._history_condition_name({"overlay_mode": true, "symmetric": true}), "overlay-markov", "generate history keeps overlay markov name")
	_assert_eq(dock._history_condition_name({"overlay_mode": true, "overlay_adjacency_enabled": true}), "overlay-adjacency", "generate history keeps overlay adjacency name")

	var primary_dock = await _new_ready_dock()
	primary_dock._set_generate_history_directory_for_test(history_dir)
	primary_dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	primary_dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	primary_dock._rect_width_spin.set_value_no_signal(2)
	primary_dock._rect_height_spin.set_value_no_signal(1)
	primary_dock._wall_prob_slider.set_value_no_signal(0.0)
	var primary_before_count = primary_dock._mapdata_sources.size()
	_assert_true(await primary_dock._generate_map(), "generate history test generates primary map")
	_assert_eq(primary_dock._mapdata_sources.size(), primary_before_count + 1, "generate history adds primary source")
	_assert_eq(primary_dock._mapdata_sources[0]["resource_type"], HexMapGenDock.MAPDATA_SOURCE_MAP, "generate history registers primary source")
	_assert_eq(primary_dock._mapdata_sources[0]["item_keys"], ["Any", "Floor", "Wall"], "generate history primary source exposes primary item keys")

	var cancel_dock = await _new_ready_dock()
	cancel_dock._set_generate_history_directory_for_test(history_dir)
	cancel_dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	cancel_dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	cancel_dock._rect_width_spin.set_value_no_signal(20)
	cancel_dock._rect_height_spin.set_value_no_signal(20)
	cancel_dock._wall_prob_slider.set_value_no_signal(1.0)
	cancel_dock._generation_chunk_size = 1
	cancel_dock._generation_progress_delay_usec = 5000
	cancel_dock._generate_map(true)
	await _wait_for_core_progress(cancel_dock)
	cancel_dock.request_generation_cancel()
	await _wait_for_generation(cancel_dock, "cancelled generate history generation")
	_assert_eq(cancel_dock._mapdata_sources.size(), 0, "generate history does not add source when generation is cancelled")

	cancel_dock.queue_free()
	primary_dock.queue_free()
	dock.queue_free()
	await process_frame


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
	while dock.generation_status()["running"] and guard < 240:
		await process_frame
		guard += 1
	_assert_true(guard < 240, "%s finishes" % message)
	await process_frame


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


func _entries_by_id(entries: Array) -> Dictionary:
	var result := {}
	for entry in entries:
		result[String(entry["id"])] = entry
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
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE, HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE:
			_assert_true(resource is Resource, "create-new generic profile has resource type")


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
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE, HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE:
			_assert_true(not resource.resource_name.to_lower().contains("sample"), "create-new generic profile is not sample-named")


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
