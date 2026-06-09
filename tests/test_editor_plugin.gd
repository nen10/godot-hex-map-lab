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
const HexMapDocumentValidator = preload("res://addons/hex_map_kit/adapter/hex_map_document_validator.gd")
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
const HexMapEditorPathSelector = preload("res://addons/hex_map_kit/editor/hex_map_editor_path_selector.gd")
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


class AssetSampleActionRecorder:
	var slots: PackedStringArray = PackedStringArray()

	func record(slot_id: String) -> void:
		slots.append(slot_id)


var _failures: Array[String] = []
var _test_output_root := ""


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_plugin_registration_files()
	await _test_hex_map_workspace_exposes_tabs_and_routes_editing()
	await _test_workspace_selected_hex_tile_map_auto_binding()
	await _test_workspace_create_missing_unique_resources_for_selected_hex_tile_map()
	await _test_workspace_asset_selection_writes_back_to_selected_hex_tile_map()
	await _test_workspace_tab_content_query_contract_lists_expected_components_and_slots()
	await _test_workspace_first_run_learning_cta_routes_to_settings_without_sample_defaults()
	await _test_workspace_asset_context_is_shared_by_workspace_generate_and_paint()
	await _test_document_asset_screen_manages_project_document_without_samples()
	await _test_catalog_asset_screen_manages_project_catalog_without_samples()
	await _test_layer_stack_asset_screen_manages_project_stack_without_samples()
	await _test_object_label_asset_screen_manages_project_definitions_without_samples()
	await _test_paint_brush_asset_screen_routes_missing_assets_without_raw_controls()
	await _test_validate_asset_screen_reports_missing_project_assets_without_samples()
	await _test_qa_asset_screen_manages_profiles_and_score_context_without_samples()
	await _test_export_asset_screen_requires_user_destination_and_exports_project_document()
	await _test_feature_screen_completion_contract_uses_project_assets_with_sample_mode_off()
	await _test_workspace_sample_settings_panel_controls_sample_mode_sources()
	await _test_sample_learning_package_contract_keeps_bundled_assets_opt_in()
	await _test_clean_project_package_contract_uses_project_assets_without_samples()
	await _test_debug_numeric_fallback_quarantine_requires_settings_opt_in()
	_test_sample_asset_duplicator_copies_catalog_dependencies_to_project()
	_test_asset_slot_state_model_reports_selection_validation_and_sample_source()
	await _test_asset_slot_state_model_contract_covers_sample_visibility_and_project_duplicates()
	await _test_asset_slot_control_exposes_state_snapshot_contract()
	await _test_file_dialog_lifecycle_helper_attaches_without_reparenting()
	await _test_workspace_asset_slots_use_strict_resource_type_filters()
	await _test_workspace_resource_purpose_tooltips_cover_resource_rows()
	await _test_workspace_tab_purpose_empty_states_route_to_project_actions()
	await _test_workspace_asset_slot_actions_remove_redundant_buttons()
	await _test_workspace_asset_remaining_actions_are_wired_or_deleted()
	await _test_sample_settings_duplicate_button_creates_project_catalog()
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
	await _test_distribution_editor_file_dialogs_use_lifecycle_helper_contract()
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
	await _test_generation_dock_output_target_preview_and_selected_document()
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
		"Resources",
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
	for tab_name in expected_tabs:
		_assert_true(workspace.tab_has_scroll_container(tab_name), "%s tab has workspace scroll root" % tab_name)
		_assert_eq(workspace.tab_scroll_root_class(tab_name), "ScrollContainer", "%s tab root is a ScrollContainer" % tab_name)
		_assert_eq(workspace.tab_content_root_class(tab_name), "VBoxContainer", "%s tab keeps vertical content layout" % tab_name)
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
	_assert_eq(
		workspace.component_for_responsibility("SettingsPreferencesPanel").get("tab", ""),
		"Settings",
		"workspace maps SettingsPreferencesPanel to Settings tab"
	)
	_assert_true(workspace.generation_dock() is HexMapGenDock, "workspace mounts generation component")
	_assert_true(workspace.edit_tool() is HexMapEditTool, "workspace mounts paint/edit component")
	_assert_true(workspace.sample_settings_panel() is HexMapSampleSettingsPanel, "workspace mounts sample settings component")
	_assert_eq(workspace.generation_dock().editor_session_state(), session, "workspace forwards session to generation component")
	_assert_eq(workspace.edit_tool().editor_session_state(), session, "workspace forwards session to paint/edit component")
	_assert_eq(workspace.sample_settings_panel().editor_session_state(), session, "workspace forwards session to sample settings component")
	_assert_true(workspace.tab_has_component("Layers", "layer_stack_role_panel"), "workspace mounts Layers role editor component")
	_assert_true(workspace.tab_has_component("QA", "qa_seed_lab_panel"), "workspace mounts QA Seed Lab component")
	_assert_true(workspace.tab_has_component("Export", "export_purpose_panel"), "workspace mounts Export purpose component")
	_assert_true(workspace.tab_has_component("Settings", "settings_preferences_panel"), "workspace mounts Settings purpose component")
	var asset_tab_expectations := [
		{"tab": "Resources", "component": "document_asset_panel", "count": 6, "slot": "movement_profile"},
		{"tab": "Catalog", "component": "catalog_asset_panel", "count": 1, "slot": "tile_catalog"},
		{"tab": "Layers", "component": "layer_stack_asset_panel", "count": 1, "slot": "layer_stack"},
		{"tab": "Validate", "component": "validation_asset_panel", "count": 2, "slot": "validation_rule_suite"},
		{"tab": "QA", "component": "qa_asset_panel", "count": 3, "slot": "generation_profile"},
		{"tab": "Export", "component": "export_asset_panel", "count": 2, "slot": "export_profile"},
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
	_assert_eq(workspace.asset_slot_count("Paint"), 0, "TAB-51 Paint tab no longer owns ResourcePicker asset slots")
	_assert_eq(workspace.tab_asset_slot_ids("Paint"), PackedStringArray(), "TAB-51 Paint tab asset slots live in Resources")
	_assert_true(not workspace.tab_has_component("Paint", "document_asset_panel"), "Paint tab does not own Document setup component")
	_assert_true(workspace.tab_has_component("Settings", "sample_settings_panel"), "Settings tab keeps sample settings component")
	_assert_eq(workspace.asset_slot_count("Settings"), 0, "TAB-57 Settings tab owns no production asset slots")
	_assert_true(not workspace.tab_asset_slot_ids("Settings").has(HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE), "TAB-57 Settings does not expose Movement Profile selection")

	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	root.add_child(layer)
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	session.set_debug_numeric_tile_fallback_enabled(true, "test.tab51_workspace_viewport")
	workspace.edit_tool().set_document(document)
	workspace.edit_tool().set_target_layer(layer)
	_assert_true(workspace.viewport_input_enabled(), "workspace gates viewport input through paint/edit component")
	_assert_eq(workspace.current_workspace_tab_name(), "Resources", "TAB-51 workspace starts on Resources before viewport edit")
	var canvas_transform = Transform2D(0.0, Vector2(120.0, -40.0))
	workspace.edit_tool().set_viewport_canvas_transform_for_test(canvas_transform)
	var origin_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true))
	var scene_position = layer.to_global(origin_local)
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = canvas_transform * scene_position
	_assert_true(workspace.forward_canvas_gui_input(press), "TAB-51 workspace consumes viewport paint edit")
	_assert_eq(workspace.current_workspace_tab_name(), "Paint", "TAB-51 viewport edit switches to Paint tab")
	var paint_snapshot = workspace.paint_brush_screen_snapshot()
	_assert_eq(paint_snapshot["active_document"], document, "TAB-51 Paint snapshot reports active document")
	_assert_eq(paint_snapshot["active_layer"], layer, "TAB-51 Paint snapshot reports active layer")
	var selected_cell = paint_snapshot["selected_cell"] as Dictionary
	_assert_true(bool(selected_cell["present"]), "TAB-51 Paint snapshot reports selected/last edited cell")
	_assert_eq(String(selected_cell["cell_key"]), HexVector.zero().key(), "TAB-51 Paint snapshot reports edited cell key")
	_assert_true(
		String(paint_snapshot["last_edit_message"]).contains("document=yes"),
		"TAB-51 Paint snapshot reports last edit detail"
	)
	_assert_true(String(paint_snapshot["undo_hint"]) != "", "TAB-51 Paint snapshot reports undo hint")

	layer.queue_free()
	workspace.queue_free()
	await process_frame


func _test_workspace_selected_hex_tile_map_auto_binding() -> void:
	var session = HexMapEditorSessionState.new()
	var recorder = SessionChangeRecorder.new()
	session.changed.connect(Callable(recorder, "record"))
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var empty_snapshot = workspace.selected_hex_tile_map_snapshot()
	_assert_true(session.selected_hex_tile_map_auto_link_enabled(), "NODE-21 auto-link defaults ON in session state")
	_assert_true(not bool(empty_snapshot["selected"]), "NODE-21 workspace starts without selected HexTileMap")
	_assert_eq(String(empty_snapshot["status_text"]), "No HexTileMap selected", "NODE-21 empty state text is visible")
	_assert_true(bool(empty_snapshot["auto_link"]), "NODE-21 workspace snapshot exposes auto-link ON")
	_assert_eq(String(empty_snapshot["auto_link_text"]), "Auto-link: On", "NODE-21 auto-link status is informational")

	var scene_root = Node2D.new()
	scene_root.name = "SelectionScene"
	root.add_child(scene_root)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "SelectedHexTileMap"
	selected_layer.hex_map = HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	var selected_stack = HexLayerStackResource.minimal_runtime_template()
	selected_layer.layer_stack_resource = selected_stack
	selected_layer.display_tile_set_resource = TileSet.new()
	scene_root.add_child(selected_layer)
	await process_frame

	var selected_snapshot = workspace.set_selected_hex_tile_map_node(selected_layer, "test.selected_hex_tile_map")
	_assert_true(bool(selected_snapshot["selected"]), "NODE-21 selected HexTileMap is recorded")
	_assert_eq(selected_snapshot["selected_node"], selected_layer, "NODE-21 selected node is the HexTileMapLayer")
	_assert_true(String(selected_snapshot["status_text"]).contains("SelectedHexTileMap"), "NODE-21 selected status names the node")
	_assert_eq(session.current_selected_hex_tile_map_layer(), selected_layer, "NODE-21 session stores selected HexTileMap")
	_assert_eq(session.current_target_layer(), selected_layer, "NODE-21 auto-link publishes selected node as target")
	_assert_eq(workspace.edit_tool().target_layer(), selected_layer, "NODE-21 workspace applies selected node to edit tool")
	_assert_eq(workspace.workspace_asset_context().layer_stack, selected_stack, "NODE-21 selected node layer stack enters workspace context")
	_assert_eq(workspace.workspace_asset_context().level_document, null, "NODE-21 runtime map is not mislabeled as Level Document")
	_assert_eq(String(selected_snapshot["level_document_status"]), "Missing", "NODE-21 missing unique document is visible")
	_assert_eq(String(selected_snapshot["layer_stack_status"]), "Linked", "NODE-21 selected node layer stack is visible")
	_assert_true(bool(selected_snapshot["runtime_initial_map_present"]), "NODE-21 runtime initial map is visible as node state")
	_assert_eq(String(selected_snapshot["display_tile_set_status"]), "Linked", "NODE-21 selected node display TileSet is visible")
	_assert_eq(String(selected_snapshot["tile_catalog_status"]), "No Tile Catalog linked to node", "NODE-21 missing shared catalog is not silently filled")
	_assert_eq(
		(workspace.resources_screen_snapshot()["selected_hex_tile_map"] as Dictionary)["selected_node"],
		selected_layer,
		"TAB-50 Resources screen shows selected HexTileMap node"
	)
	_assert_true(recorder.keys.has("selected_hex_tile_map_layer"), "NODE-21 session emits selected node change")
	_assert_true(recorder.keys.has("target_layer"), "NODE-21 auto-link emits target change")

	var display_layer = selected_layer.display_tile_map_layer()
	var internal_snapshot = workspace.set_selected_hex_tile_map_node(display_layer, "test.selected_internal_layer")
	_assert_eq(internal_snapshot["selected_node"], selected_layer, "NODE-21 internal display layer maps back to selected HexTileMap")

	var invalid_node = Node2D.new()
	invalid_node.name = "NotAHexTileMap"
	scene_root.add_child(invalid_node)
	var cleared_snapshot = workspace.set_selected_hex_tile_map_node(invalid_node, "test.invalid_selection")
	_assert_true(not bool(cleared_snapshot["selected"]), "NODE-21 non-HexTileMap selection clears selected node")
	_assert_eq(String(cleared_snapshot["status_text"]), "No HexTileMap selected", "NODE-21 clear state keeps exact empty text")
	_assert_eq(session.current_selected_hex_tile_map_layer(), null, "NODE-21 session clears selected node")
	_assert_eq(session.current_target_layer(), null, "NODE-21 auto-link clears target when no HexTileMap is selected")
	_assert_eq(workspace.edit_tool().target_layer(), null, "NODE-21 edit target clears with no selected HexTileMap")
	_assert_eq(workspace.workspace_asset_context().layer_stack, null, "NODE-21 selected-node layer stack clears with no selected HexTileMap")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _test_workspace_create_missing_unique_resources_for_selected_hex_tile_map() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var empty_missing_snapshot = workspace.missing_unique_resources_snapshot()
	_assert_true(not bool(empty_missing_snapshot["can_create"]), "FB-02 missing resource create is disabled before HexTileMap selection")
	_assert_eq(
		String(empty_missing_snapshot["choose_directory_button_tooltip"]),
		"Select a HexTileMap node before choosing a save directory.",
		"FB-02 disabled missing resource directory action explains missing selection"
	)
	_assert_eq(
		String(empty_missing_snapshot["create_button_tooltip"]),
		"Select a HexTileMap node before creating missing resources.",
		"FB-02 disabled missing resource create action explains missing selection"
	)

	var scene_root = Node2D.new()
	scene_root.name = "MissingResourcesScene"
	root.add_child(scene_root)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "Missing Resource Map"
	selected_layer.hex_map = HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	scene_root.add_child(selected_layer)
	await process_frame

	workspace.set_selected_hex_tile_map_node(selected_layer, "test.node22.select")
	var missing_snapshot = workspace.missing_unique_resources_snapshot()
	_assert_true(not bool(missing_snapshot["can_create"]), "NODE-22 create is unavailable without save directory")
	_assert_eq(
		String(missing_snapshot["choose_directory_button_tooltip"]),
		"Choose a project directory for the selected HexTileMap resources.",
		"FB-02 enabled missing resource directory action names its state change"
	)
	_assert_eq(
		String(missing_snapshot["create_button_tooltip"]),
		"Choose a save directory before creating missing resources.",
		"FB-02 disabled missing resource create action explains missing directory"
	)
	_assert_eq(int(missing_snapshot["missing_count"]), 2, "NODE-22 selected node reports missing unique resources")
	_assert_true(
		(missing_snapshot["missing_resource_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT),
		"NODE-22 missing list includes Level Document"
	)
	_assert_true(
		(missing_snapshot["missing_resource_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK),
		"NODE-22 missing list includes Layer Stack"
	)
	_assert_eq(String(missing_snapshot["resource_prefix"]), "Missing_Resource_Map", "NODE-22 prefix defaults to safe selected node name")
	_assert_eq(
		int((missing_snapshot["dialog_config"] as Dictionary).get("file_mode", -1)),
		EditorFileDialog.FILE_MODE_OPEN_DIR,
		"NODE-22 save directory uses folder picker config"
	)

	var save_dir = _test_resource_dir("node22_missing_unique_resources")
	var planned_snapshot = workspace.missing_unique_resources_snapshot(save_dir)
	_assert_eq(
		String(planned_snapshot["create_button_tooltip"]),
		"Create Level Document and Layer Stack resources in the selected directory.",
		"FB-02 ready missing resource create action names its state change"
	)
	var planned_paths = planned_snapshot["paths"] as Dictionary
	_assert_eq(
		String(planned_paths[HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT]),
		"%s/Missing_Resource_Map_document.tres" % save_dir,
		"NODE-22 document path uses selected node prefix"
	)
	_assert_eq(
		String(planned_paths[HexMapWorkspaceAssetContext.SLOT_LAYER_STACK]),
		"%s/Missing_Resource_Map_layer_stack.tres" % save_dir,
		"NODE-22 layer stack path uses selected node prefix"
	)

	var result = workspace.create_missing_selected_hex_tile_map_resources(save_dir)
	_assert_true(bool(result["ok"]), "NODE-22 creates missing selected-node resources")
	_assert_true(
		(result["created_resource_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT),
		"NODE-22 creates missing Level Document"
	)
	_assert_true(
		(result["created_resource_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK),
		"NODE-22 creates missing Layer Stack"
	)
	var document_path := String(planned_paths[HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT])
	var stack_path := String(planned_paths[HexMapWorkspaceAssetContext.SLOT_LAYER_STACK])
	_assert_true(ResourceLoader.exists(document_path), "NODE-22 saved document exists")
	_assert_true(ResourceLoader.exists(stack_path), "NODE-22 saved layer stack exists")
	_assert_true(selected_layer.level_document_resource is HexMapDocumentResource, "NODE-22 assigns created document to selected node")
	_assert_true(selected_layer.layer_stack_resource is HexLayerStackResource, "NODE-22 assigns created layer stack to selected node")
	_assert_eq(selected_layer.level_document_resource.resource_path, document_path, "NODE-22 node document reference uses saved path")
	_assert_eq(selected_layer.layer_stack_resource.resource_path, stack_path, "NODE-22 node layer stack reference uses saved path")
	_assert_eq(workspace.workspace_asset_context().level_document, selected_layer.level_document_resource, "NODE-22 workspace context shows created document")
	_assert_eq(workspace.workspace_asset_context().layer_stack, selected_layer.layer_stack_resource, "NODE-22 workspace context shows created layer stack")
	_assert_eq(session.current_document(), selected_layer.level_document_resource, "NODE-22 session document follows created document")
	_assert_eq(workspace.workspace_asset_context().tile_catalog, null, "NODE-22 does not silently create shared Tile Catalog")
	_assert_true(not bool(result["shared_resources_created"]), "NODE-22 result states no shared resources were created")
	var after_snapshot = result["after"] as Dictionary
	_assert_eq(int(after_snapshot["missing_count"]), 0, "NODE-22 after snapshot has no missing unique resources")
	_assert_eq(String(workspace.selected_hex_tile_map_snapshot()["level_document_status"]), "Linked", "NODE-22 selected-node summary shows linked document")

	var repeat_result = workspace.create_missing_selected_hex_tile_map_resources(save_dir)
	_assert_true(bool(repeat_result["ok"]), "NODE-22 repeat create is a no-op when resources already exist")
	_assert_eq((repeat_result["created_resource_ids"] as PackedStringArray).size(), 0, "NODE-22 repeat create does not overwrite existing unique resources")

	var existing_stack = HexLayerStackResource.minimal_runtime_template()
	var partial_layer = HexTileMapLayer.new()
	partial_layer.name = "PartialResources"
	partial_layer.layer_stack_resource = existing_stack
	scene_root.add_child(partial_layer)
	await process_frame
	var partial_dir = _test_resource_dir("node22_partial_unique_resources")
	workspace.set_selected_hex_tile_map_node(partial_layer, "test.node22.partial")
	var partial_result = workspace.create_missing_selected_hex_tile_map_resources(partial_dir, "PartialMap")
	_assert_true(bool(partial_result["ok"]), "NODE-22 creates only missing unique resources for partially configured node")
	_assert_true(
		(partial_result["created_resource_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT),
		"NODE-22 partial flow creates missing document"
	)
	_assert_true(
		not (partial_result["created_resource_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK),
		"NODE-22 partial flow preserves existing layer stack"
	)
	_assert_eq(partial_layer.layer_stack_resource, existing_stack, "NODE-22 existing layer stack reference is preserved")

	workspace.clear_selected_hex_tile_map_layer("test.node22.clear")
	var blocked_result = workspace.create_missing_selected_hex_tile_map_resources(save_dir, "NoSelection")
	_assert_true(not bool(blocked_result["ok"]), "NODE-22 no selected HexTileMap blocks creation")
	_assert_eq(int(blocked_result["error"]), ERR_DOES_NOT_EXIST, "NODE-22 no selected HexTileMap returns missing target error")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _test_workspace_asset_selection_writes_back_to_selected_hex_tile_map() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var scene_root = Node2D.new()
	scene_root.name = "WritebackScene"
	root.add_child(scene_root)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "WritebackHexTileMap"
	scene_root.add_child(selected_layer)
	await process_frame
	workspace.set_selected_hex_tile_map_node(selected_layer, "test.node23.select")

	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	workspace.workspace_asset_context().set_level_document(document)
	_assert_eq(selected_layer.level_document_resource, document, "NODE-23 Document slot writes to selected HexTileMap")
	_assert_eq(session.current_document(), document, "NODE-23 Document write-back updates session document")
	var writeback = workspace.selected_hex_tile_map_writeback_snapshot()
	var relationships = writeback["relationships"] as Dictionary
	var document_relationship = relationships[HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT] as Dictionary
	_assert_eq(String(document_relationship["status"]), "linked", "NODE-23 Document relationship is visible as linked")
	_assert_true(bool(document_relationship["matches"]), "NODE-23 Document relationship reports node/workspace match")

	var stack = HexLayerStackResource.minimal_runtime_template()
	workspace.workspace_asset_context().set_layer_stack(stack)
	_assert_eq(selected_layer.layer_stack_resource, stack, "NODE-23 Layer Stack slot writes to selected HexTileMap")
	_assert_eq(workspace.edit_tool().layer_stack_resource(), stack, "NODE-23 Layer Stack write-back updates edit tool")
	writeback = workspace.selected_hex_tile_map_writeback_snapshot()
	relationships = writeback["relationships"] as Dictionary
	var stack_relationship = relationships[HexMapWorkspaceAssetContext.SLOT_LAYER_STACK] as Dictionary
	_assert_eq(String(stack_relationship["status"]), "linked", "NODE-23 Layer Stack relationship is visible as linked")

	var catalog = HexTileCatalogResource.new()
	var object_database = HexObjectDatabaseResource.new()
	var label_database = HexLabelDatabaseResource.new()
	workspace.workspace_asset_context().set_tile_catalog(catalog)
	workspace.workspace_asset_context().set_object_database(object_database)
	workspace.workspace_asset_context().set_label_database(label_database)
	writeback = workspace.selected_hex_tile_map_writeback_snapshot()
	relationships = writeback["relationships"] as Dictionary
	var catalog_relationship = relationships[HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG] as Dictionary
	var object_relationship = relationships[HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE] as Dictionary
	var label_relationship = relationships[HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE] as Dictionary
	_assert_eq(String(catalog_relationship["policy"]), "shared_context", "NODE-23 Tile Catalog remains shared context")
	_assert_eq(String(object_relationship["policy"]), "shared_context", "NODE-23 Object Database remains shared context")
	_assert_eq(String(label_relationship["policy"]), "shared_context", "NODE-23 Label Database remains shared context")
	_assert_eq(catalog_relationship["node_resource"], null, "NODE-23 Tile Catalog is not copied onto the node")
	_assert_eq(object_relationship["node_resource"], null, "NODE-23 Object Database is not copied onto the node")
	_assert_eq(label_relationship["node_resource"], null, "NODE-23 Label Database is not copied onto the node")
	_assert_eq(selected_layer.level_document_resource.dependencies.size(), 0, "NODE-23 shared resources are not silently embedded into document dependencies")

	session.set_auto_link_selected_hex_tile_map(false, "test.node23.disable_auto_link")
	var blocked_document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	workspace.workspace_asset_context().set_level_document(blocked_document)
	_assert_eq(selected_layer.level_document_resource, document, "NODE-23 auto-link OFF blocks node-owned write-back")
	writeback = workspace.selected_hex_tile_map_writeback_snapshot()
	_assert_true(not bool(writeback["can_writeback"]), "NODE-23 write-back snapshot blocks when auto-link is OFF")
	_assert_eq(String(writeback["blocked_reason"]), "Auto-link is off.", "NODE-23 auto-link OFF reason is visible")

	workspace.clear_selected_hex_tile_map_layer("test.node23.clear")
	var no_selection_result = workspace.apply_workspace_asset_context_to_selected_hex_tile_map(
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
		"test.node23.no_selection"
	)
	_assert_true(not bool(no_selection_result["ok"]), "NODE-23 no selected HexTileMap blocks explicit write-back")
	_assert_eq(String(no_selection_result["blocked_reason"]), "No HexTileMap selected", "NODE-23 no selected reason is visible")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _test_workspace_tab_content_query_contract_lists_expected_components_and_slots() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var expected_tabs = PackedStringArray([
		"Resources",
		"Generate",
		"Paint",
		"Catalog",
		"Layers",
		"Validate",
		"QA",
		"Export",
		"Settings",
	])
	var expected_contract := {
		"Resources": {
			"components": PackedStringArray(["resources_context_panel", "document_asset_panel", "missing_unique_resources_panel"]),
			"slots": PackedStringArray([
				HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
				HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
				HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE,
				HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE,
				HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
				HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE,
			]),
		},
		"Generate": {
			"components": PackedStringArray(["generation_panel"]),
			"slots": PackedStringArray(),
		},
		"Paint": {
			"components": PackedStringArray(["brush_palette"]),
			"slots": PackedStringArray(),
		},
		"Catalog": {
			"components": PackedStringArray(["catalog_detail_panel", "catalog_asset_panel"]),
			"slots": PackedStringArray([HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG]),
		},
		"Layers": {
			"components": PackedStringArray(["layer_stack_role_panel", "layer_stack_asset_panel"]),
			"slots": PackedStringArray([HexMapWorkspaceAssetContext.SLOT_LAYER_STACK]),
		},
		"Validate": {
			"components": PackedStringArray(["validation_asset_panel", "validation_issue_navigator"]),
			"slots": PackedStringArray([
				HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
				HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE,
			]),
		},
		"QA": {
			"components": PackedStringArray(["qa_seed_lab_panel", "qa_asset_panel"]),
			"slots": PackedStringArray([
				HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE,
				HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE,
				HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
			]),
		},
		"Export": {
			"components": PackedStringArray(["export_purpose_panel", "export_asset_panel", "export_destination_panel"]),
			"slots": PackedStringArray([
				HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
				HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE,
			]),
		},
		"Settings": {
			"components": PackedStringArray(["settings_preferences_panel", "sample_settings_panel"]),
			"slots": PackedStringArray(),
		},
	}

	_assert_eq(workspace.workspace_tab_names(), expected_tabs, "TEST-41 workspace tab query exposes expected UX tabs")
	var expected_component_row_count := 0
	for tab_name in expected_tabs:
		var contract = expected_contract[tab_name] as Dictionary
		var expected_components = contract["components"] as PackedStringArray
		var expected_slots = contract["slots"] as PackedStringArray
		expected_component_row_count += expected_components.size()
		_assert_eq(workspace.tab_component_ids(tab_name), expected_components, "TEST-41 %s component ids match contract" % tab_name)
		_assert_eq(workspace.components_for_tab(tab_name).size(), expected_components.size(), "TEST-41 %s component row count matches contract" % tab_name)
		_assert_eq(workspace.tab_asset_slot_ids(tab_name), expected_slots, "TEST-41 %s asset slot ids match contract" % tab_name)
		_assert_eq(workspace.asset_slot_count(tab_name), expected_slots.size(), "TEST-41 %s asset slot count matches contract" % tab_name)
		_assert_true(workspace.tab_has_scroll_container(tab_name), "TEST-41 %s has workspace scroll root" % tab_name)
		_assert_eq(workspace.tab_scroll_root_class(tab_name), "ScrollContainer", "TEST-41 %s root class is ScrollContainer" % tab_name)
		_assert_eq(workspace.tab_content_root_class(tab_name), "VBoxContainer", "TEST-41 %s content class is VBoxContainer" % tab_name)
		for component_id in expected_components:
			_assert_true(workspace.tab_has_component(tab_name, String(component_id)), "TEST-41 %s has component %s" % [tab_name, component_id])
		for slot_id in expected_slots:
			_assert_true(workspace.tab_asset_slot_ids(tab_name).has(String(slot_id)), "TEST-41 %s has asset slot %s" % [tab_name, slot_id])

	_assert_eq(workspace.component_rows().size(), expected_component_row_count, "TEST-41 component registry row count matches tab contract")
	for row in workspace.component_rows():
		var tab_name := String(row.get("tab", ""))
		var component_id := String(row.get("component_id", ""))
		var component_class := String(row.get("component_class", ""))
		var responsibility := String(row.get("responsibility", ""))
		var source_owner := String(row.get("source_owner", ""))
		var row_slot_ids := PackedStringArray(row.get("asset_slot_ids", PackedStringArray()))
		_assert_true(expected_tabs.has(tab_name), "TEST-41 component row tab is registered")
		_assert_true(component_id != "", "TEST-41 component row has stable component id")
		_assert_true(component_class != "", "TEST-41 component row has component class")
		_assert_true(responsibility != "", "TEST-41 component row has responsibility")
		_assert_true(source_owner != "", "TEST-41 component row has source owner")
		_assert_true(workspace.tab_component_ids(tab_name).has(component_id), "TEST-41 component row is mounted in tab query")
		for slot_id in row_slot_ids:
			_assert_true(
				HexMapWorkspaceAssetContext.asset_slot_ids().has(String(slot_id)),
				"TEST-41 component row asset slot id is known: %s" % slot_id
			)

	_assert_true(not workspace.tab_has_component("Paint", "document_asset_panel"), "TEST-41 Paint tab excludes Document setup panel")
	var resources_contract = expected_contract["Resources"] as Dictionary
	_assert_eq(
		workspace.tab_component_ids("Document"),
		resources_contract["components"],
		"TAB-50 legacy Document tab query aliases Resources components"
	)
	_assert_eq(
		workspace.tab_asset_slot_ids("Document"),
		resources_contract["slots"],
		"TAB-50 legacy Document tab query aliases Resources asset slots"
	)
	_assert_true(workspace.select_workspace_tab("Document"), "TAB-50 legacy Document tab selection aliases Resources tab")
	_assert_eq(workspace.current_workspace_tab_name(), "Resources", "TAB-50 legacy Document selection lands on Resources tab")
	_assert_eq(workspace.tab_component_ids("MissingTab"), PackedStringArray(), "TEST-41 missing tab has no component ids")
	_assert_eq(workspace.tab_asset_slot_ids("MissingTab"), PackedStringArray(), "TEST-41 missing tab has no asset slot ids")
	_assert_eq(workspace.asset_slot_count("MissingTab"), 0, "TEST-41 missing tab has zero asset slots")

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
	_assert_eq(workspace.current_workspace_tab_name(), "Resources", "workspace starts on normal project resources tab")
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
	_assert_eq(dismiss_workspace.current_workspace_tab_name(), "Resources", "dismissing sample CTA keeps normal project tab")
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
	var export_profile = Resource.new()

	context.set_level_document(document)
	context.set_tile_catalog(catalog)
	context.set_object_database(object_database)
	context.set_label_database(label_database)
	context.set_layer_stack(layer_stack)
	context.set_movement_profile(movement_profile)
	context.set_validation_rule_suite(validation_suite)
	context.set_generation_profile(generation_profile)
	context.set_export_profile(export_profile)

	var slot_ids = HexMapWorkspaceAssetContext.asset_slot_ids()
	_assert_true(slot_ids.has("tile_catalog"), "workspace asset context exposes tile catalog slot id")
	_assert_true(slot_ids.has("object_database"), "workspace asset context exposes object database slot id")
	_assert_true(slot_ids.has("label_database"), "workspace asset context exposes label database slot id")
	_assert_true(slot_ids.has("layer_stack"), "workspace asset context exposes layer stack slot id")
	_assert_true(slot_ids.has("movement_profile"), "workspace asset context exposes movement profile slot id")
	_assert_true(slot_ids.has("validation_rule_suite"), "workspace asset context exposes validation suite slot id")
	_assert_true(slot_ids.has("generation_profile"), "workspace asset context exposes generation profile slot id")
	_assert_true(slot_ids.has("export_profile"), "workspace asset context exposes export profile slot id")

	var snapshot = context.snapshot()
	_assert_eq(snapshot["level_document"], document, "workspace asset context holds level document")
	_assert_eq(snapshot["tile_catalog"], catalog, "workspace asset context holds tile catalog")
	_assert_eq(snapshot["object_database"], object_database, "workspace asset context holds object database")
	_assert_eq(snapshot["label_database"], label_database, "workspace asset context holds label database")
	_assert_eq(snapshot["layer_stack"], layer_stack, "workspace asset context holds layer stack")
	_assert_eq(snapshot["movement_profile"], movement_profile, "workspace asset context holds movement profile")
	_assert_eq(snapshot["validation_rule_suite"], validation_suite, "workspace asset context holds validation suite")
	_assert_eq(snapshot["generation_profile"], generation_profile, "workspace asset context holds generation profile")
	_assert_eq(snapshot["export_profile"], export_profile, "workspace asset context holds export profile")

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
	_assert_eq(String(snapshot["tab"]), "Resources", "TAB-50 document snapshot now represents Resources tab")
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("document_asset_panel"),
		"TAB-50 Resources screen exposes resource asset component"
	)
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("resources_context_panel"),
		"TAB-50 Resources screen exposes context component"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT),
		"TAB-50 Resources screen exposes level document slot"
	)
	_assert_true(
		PackedStringArray(snapshot["dependency_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG),
		"Document screen exposes catalog dependency slot"
	)
	_assert_true(
		PackedStringArray(snapshot["dependency_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK),
		"TAB-50 Resources screen exposes layer stack dependency slot"
	)
	var resources_selected = snapshot["selected_hex_tile_map"] as Dictionary
	_assert_eq(String(resources_selected["status_text"]), "No HexTileMap selected", "TAB-50 Resources screen shows selected HexTileMap state")
	var resource_groups = snapshot["resource_groups"] as Array
	var groups_by_id := {}
	for group in resource_groups:
		groups_by_id[String(group["group_id"])] = group
	_assert_true(groups_by_id.has("unique"), "TAB-50 Resources screen exposes UniqueResource group")
	_assert_true(groups_by_id.has("shared"), "TAB-50 Resources screen exposes SharedResource group")
	_assert_true(groups_by_id.has("optional"), "TAB-50 Resources screen exposes OptionalResource group")
	_assert_true(
		String((groups_by_id["unique"] as Dictionary)["tooltip"]).contains("Level Document"),
		"TAB-50 UniqueResource tooltip explains resource purpose"
	)
	_assert_true(
		((groups_by_id["optional"] as Dictionary)["slot_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE),
		"TAB-57 Resources optional group includes Movement Profile"
	)
	_assert_eq(String(snapshot["create_missing_resources_button_text"]), "Create Missing Resources", "TAB-50 Resources screen keeps Create Missing Resources")
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
		PackedStringArray(snapshot["component_ids"]).has("catalog_detail_panel"),
		"TAB-52 Catalog screen exposes entry detail component"
	)
	_assert_true(bool(snapshot["detail_component_present"]), "TAB-52 Catalog screen reports detail component presence")
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG),
		"Catalog screen exposes tile catalog slot"
	)
	_assert_true(not bool(snapshot["sample_candidates_visible"]), "Catalog screen hides sample catalog candidates while sample mode is OFF")
	_assert_eq(workspace.workspace_asset_context().tile_catalog, null, "Catalog screen starts without sample catalog")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "Catalog screen does not inject generation sample catalog")
	var missing_detail = snapshot["entry_detail"] as Dictionary
	_assert_true(not bool(missing_detail["preview_available"]), "TAB-52 Catalog screen starts with unavailable preview")
	_assert_eq(
		String(missing_detail["preview_unavailable_reason"]),
		"No Tile Catalog selected.",
		"TAB-52 Catalog screen explains missing catalog preview state"
	)

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
	_assert_true(not bool(snapshot["raw_coordinate_controls_primary"]), "TAB-52 Catalog source/atlas fields are metadata, not primary inputs")
	_assert_true(
		not PackedStringArray(snapshot["primary_input_fields"]).has("source_id"),
		"TAB-52 Catalog primary inputs do not expose raw source id"
	)
	_assert_true(
		PackedStringArray(snapshot["metadata_fields"]).has("atlas_coords"),
		"TAB-52 Catalog keeps atlas coordinates as metadata"
	)
	var entry_rows = snapshot["entry_rows"] as Array
	_assert_eq(entry_rows.size(), 2, "TAB-52 Catalog screen exposes entry rows")
	var atlas_detail = workspace.catalog_entry_detail("terrain.floor")
	_assert_eq(String(atlas_detail["meaning"]), "terrain.floor", "TAB-52 Catalog atlas detail exposes entry meaning")
	_assert_eq(String(atlas_detail["type_label"]), "Tile", "TAB-52 Catalog atlas detail has human type label")
	_assert_true(bool(atlas_detail["preview_available"]), "TAB-52 Catalog atlas detail has tile preview")
	_assert_eq(String(atlas_detail["preview_kind"]), "tile", "TAB-52 Catalog atlas detail reports tile preview kind")
	_assert_true(String(atlas_detail["preview_text"]).contains("Tile source 0"), "TAB-52 Catalog atlas preview describes tile source")
	var atlas_metadata = atlas_detail["metadata"] as Dictionary
	_assert_eq(int(atlas_metadata["source_id"]), 0, "TAB-52 Catalog atlas source id is metadata")
	_assert_eq(atlas_metadata["atlas_coords"], Vector2i.ZERO, "TAB-52 Catalog atlas coords are metadata")
	_assert_true(not bool(atlas_detail["raw_coordinate_controls_primary"]), "TAB-52 Catalog atlas detail does not make raw coordinates primary")
	var scene_detail = workspace.catalog_entry_detail("object.spawn")
	_assert_eq(String(scene_detail["type_label"]), "Scene", "TAB-52 Catalog scene detail has human type label")
	_assert_true(bool(scene_detail["preview_available"]), "TAB-52 Catalog scene detail has scene preview")
	_assert_eq(String(scene_detail["preview_kind"]), "scene", "TAB-52 Catalog scene detail reports scene preview kind")
	var validation = workspace.validate_tile_catalog()
	_assert_true(validation is HexMapValidationResult, "Catalog screen validate returns validation result")
	_assert_eq(validation.issue_count(), 0, "Catalog screen validates project catalog with selected TileSet and PackedScene")

	var placeholder_entry := HexTileCatalogEntry.new()
	placeholder_entry.key = "placeholder.todo"
	placeholder_entry.display_name = "Unassigned Tile"
	placeholder_entry.entry_type = HexTileCatalogEntry.TYPE_PLACEHOLDER
	catalog.add_entry(placeholder_entry)
	var placeholder_detail = workspace.catalog_entry_detail("placeholder.todo")
	_assert_eq(String(placeholder_detail["meaning"]), "Unassigned Tile", "TAB-52 Catalog placeholder detail exposes display name meaning")
	_assert_true(not bool(placeholder_detail["preview_available"]), "TAB-52 Catalog placeholder preview is unavailable")
	_assert_eq(
		String(placeholder_detail["preview_unavailable_reason"]),
		"Placeholder entry has no preview.",
		"TAB-52 Catalog placeholder explains preview absence"
	)

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
		PackedStringArray(snapshot["component_ids"]).has("layer_stack_role_panel"),
		"TAB-53 Layers screen exposes role editor component"
	)
	_assert_true(bool(snapshot["role_component_present"]), "TAB-53 Layers snapshot confirms role editor component")
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK),
		"Layers screen exposes layer stack slot"
	)
	for required_role in [
		HexLayerStackResource.ROLE_TERRAIN,
		HexLayerStackResource.ROLE_OVERLAY,
		HexLayerStackResource.ROLE_OBJECT,
		HexLayerStackResource.ROLE_DEBUG,
		HexLayerStackResource.ROLE_COLLISION,
		HexLayerStackResource.ROLE_NAVIGATION,
	]:
		_assert_true(
			PackedStringArray(snapshot["required_role_names"]).has(required_role),
			"TAB-53 Layers required role is visible: %s" % required_role
		)
	var initial_relationship = snapshot["relationship"] as Dictionary
	_assert_eq(initial_relationship["status"], "no_selected_hex_tile_map", "TAB-53 Layers starts with selected node empty state")
	var initial_counts = snapshot["role_status_counts"] as Dictionary
	_assert_eq(initial_counts["total"], 0, "TAB-53 Layers does not fake role rows before a project stack is selected")
	var initial_actions = snapshot["layer_actions"] as Dictionary
	_assert_true(not bool(initial_actions["create_missing_layers"]), "TAB-53 Create Missing Layers starts unavailable")
	_assert_true(not bool(initial_actions["apply_document"]), "TAB-53 Apply Document starts unavailable")
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

	workspace.set_selected_hex_tile_map_layer(layer)
	workspace.workspace_asset_context().set_layer_stack(duplicated_stack)
	var writeback_result = workspace.apply_workspace_asset_context_to_selected_hex_tile_map(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK)
	_assert_true(bool(writeback_result["ok"]), "TAB-53 Layers writes project stack back to selected HexTileMap")
	_assert_eq(layer.layer_stack_resource, duplicated_stack, "TAB-53 selected HexTileMap owns the active Layer Stack")

	var pick_result = workspace.pick_layer_stack_target_root(scene_root)
	_assert_true(bool(pick_result["ok"]), "Layers screen picks target from scene root")
	_assert_eq(pick_result["target_layer"], layer, "Layers screen resolves scene HexTileMapLayer target")

	var document := _sample_editor_document()
	var document_result = workspace.set_layer_stack_document(document)
	_assert_true(bool(document_result["ok"]), "Layers screen accepts document for layer stack actions")
	snapshot = workspace.layer_stack_screen_snapshot()
	var relationship = snapshot["relationship"] as Dictionary
	_assert_eq(relationship["status"], "linked", "TAB-53 Layers shows selected node and stack are linked")
	_assert_true(bool(relationship["target_matches_selected"]), "TAB-53 Layers target matches selected HexTileMap")
	var action_state = snapshot["layer_actions"] as Dictionary
	_assert_true(bool(action_state["create_missing_layers"]), "TAB-53 Layers exposes Create Missing Layers when role nodes are missing")
	_assert_true(bool(action_state["apply_document"]), "TAB-53 Layers exposes Apply Document when target and document are ready")
	var status_counts = snapshot["role_status_counts"] as Dictionary
	_assert_eq(status_counts["total"], 7, "TAB-53 Layers counts standard stack role rows")
	_assert_true(int(status_counts["missing"]) > 0, "TAB-53 Layers counts missing child role layers")
	var terrain_row = _layer_stack_row_for_role(snapshot["role_rows"], HexLayerStackResource.ROLE_TERRAIN)
	_assert_eq(terrain_row["status"], "missing", "Layers screen reports missing terrain role before create")
	_assert_true(bool(terrain_row["visible"]), "TAB-53 terrain row shows visibility")
	_assert_eq(terrain_row["locked"], false, "TAB-53 terrain row shows locked state")
	_assert_eq(terrain_row["writable"], "document", "TAB-53 terrain row shows writable source")
	var collision_row = _layer_stack_row_for_role(snapshot["role_rows"], HexLayerStackResource.ROLE_COLLISION)
	_assert_eq(collision_row["visible"], false, "TAB-53 collision row shows hidden visibility state")
	for role_name in [
		HexLayerStackResource.ROLE_OVERLAY,
		HexLayerStackResource.ROLE_OBJECT,
		HexLayerStackResource.ROLE_DEBUG,
		HexLayerStackResource.ROLE_COLLISION,
		HexLayerStackResource.ROLE_NAVIGATION,
	]:
		var role_row = _layer_stack_row_for_role(snapshot["role_rows"], role_name)
		_assert_eq(role_row["role"], role_name, "TAB-53 Layers shows role row: %s" % role_name)
		_assert_true(["missing", "ok"].has(role_row["status"]), "TAB-53 Layers row has readable status: %s" % role_name)
	_assert_eq(
		String((snapshot["target_status"] as Dictionary).get("target_class", "")),
		"HexTileMapLayer",
		"Layers screen target status names HexTileMapLayer"
	)

	var create_layers_result = workspace.create_missing_layer_stack_layers()
	_assert_true(bool(create_layers_result["ok"]), "Layers screen creates missing target layers")
	terrain_row = _layer_stack_row_for_role(create_layers_result["role_rows"], HexLayerStackResource.ROLE_TERRAIN)
	_assert_eq(terrain_row["status"], "ok", "Layers screen reports created terrain role")
	snapshot = workspace.layer_stack_screen_snapshot()
	status_counts = snapshot["role_status_counts"] as Dictionary
	_assert_eq(status_counts["missing"], 0, "TAB-53 Layers reports no missing roles after creating child layers")
	action_state = snapshot["layer_actions"] as Dictionary
	_assert_true(not bool(action_state["create_missing_layers"]), "TAB-53 Create Missing Layers disables after all child layers exist")
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
	_assert_eq(String(snapshot["tab"]), "Resources", "TAB-51 Object/Label resources are managed from Resources")
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("document_asset_panel"),
		"TAB-51 Object/Label resources use Resources asset component"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE),
		"TAB-51 Resources exposes object database slot"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE),
		"TAB-51 Resources exposes label database slot"
	)
	_assert_true(not workspace.tab_has_component("Paint", "object_label_asset_panel"), "TAB-51 Paint does not duplicate Object/Label resource rows")
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
		workspace.tab_asset_slot_snapshot("Resources", HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE).get("current_source", ""),
		HexMapEditorAssetSlotState.SOURCE_PROJECT,
		"TAB-51 Resources marks created object database as project asset"
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
	var paint_screen = workspace.paint_brush_screen_snapshot()
	_assert_eq(PackedStringArray(paint_screen["asset_slot_ids"]), PackedStringArray(), "TAB-51 Paint brush screen does not expose ResourcePicker asset rows")
	var picker_rows = paint_screen["resource_picker_rows_visible"] as Dictionary
	_assert_true(not bool(picker_rows["object_database"]), "TAB-51 Paint hides Object Database ResourcePicker row")
	_assert_true(not bool(picker_rows["label_database"]), "TAB-51 Paint hides Label Database ResourcePicker row")
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
	_assert_true(not bool(controls["raw_overlay_item_key"]), "Paint brush hides raw overlay item key control")
	_assert_true(not bool(controls["raw_object_id"]), "Paint brush hides raw object id control")
	_assert_true(not bool(controls["raw_object_variant"]), "Paint brush hides raw object variant control")
	_assert_true(not bool(controls["raw_spawn_condition"]), "Paint brush hides raw spawn condition control")
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
	_assert_eq(cta["target_tab"], "Resources", "TAB-51 Paint brush missing object points to Resources")
	_assert_eq(cta["target_component_id"], "document_asset_panel", "TAB-51 Paint brush missing object points to Resources asset panel")
	_assert_eq(cta["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE, "Paint brush missing object points to object database slot")
	paint_screen = workspace.paint_brush_screen_snapshot()
	picker_rows = paint_screen["resource_picker_rows_visible"] as Dictionary
	_assert_true(not bool(picker_rows["object_database"]), "TAB-51 Paint object mode still hides Object Database ResourcePicker row")

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
	_assert_eq(cta["target_tab"], "Resources", "TAB-51 Paint brush missing label points to Resources")
	_assert_eq(cta["target_component_id"], "document_asset_panel", "TAB-51 Paint brush missing label points to Resources asset panel")
	_assert_eq(cta["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE, "Paint brush missing label points to label database slot")
	paint_screen = workspace.paint_brush_screen_snapshot()
	picker_rows = paint_screen["resource_picker_rows_visible"] as Dictionary
	_assert_true(not bool(picker_rows["label_database"]), "TAB-51 Paint label mode still hides Label Database ResourcePicker row")

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


func _test_validate_asset_screen_reports_missing_project_assets_without_samples() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var snapshot = workspace.validate_screen_snapshot()
	_assert_eq(snapshot["purpose_text"], "Validate workspace assets and the active Level Document.", "TAB-54 Validate screen states purpose")
	_assert_true(String(snapshot["target_summary"]).contains("Level Document missing"), "TAB-54 Validate screen summarizes target readiness")
	_assert_true(bool(snapshot["navigator_component_present"]), "TAB-54 Validate snapshot confirms issue navigator component")
	_assert_eq(snapshot["empty_state_text"], "Run validation to list workspace issues.", "TAB-54 Validate screen has pre-run empty state")
	_assert_true(not bool(snapshot["resource_row_validate_buttons_present"]), "TAB-54 Validate keeps row-level Validate buttons absent")
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("validation_asset_panel"),
		"Validate screen exposes validation asset panel"
	)
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("validation_issue_navigator"),
		"Validate screen exposes issue navigator"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE),
		"Validate screen exposes validation suite asset slot"
	)
	_assert_true(not bool(snapshot["sample_candidates_visible"]), "Validate screen starts with sample mode OFF")

	var validate_result = workspace.run_validate_screen()
	_assert_true(bool(validate_result["ok"]), "Validate screen runs workspace validation")
	var result = validate_result["result"] as HexMapValidationResult
	_assert_true(result is HexMapValidationResult, "Validate screen returns validation result")
	_assert_eq(result.error_count(), 7, "Validate screen reports missing project assets as errors")
	var rows = validate_result["issue_rows"] as Array
	var document_row = _validation_issue_row_for_rule(rows, "workspace.level_document_missing")
	_assert_eq(document_row["target_tab"], "Resources", "missing document points to Resources tab")
	_assert_eq(document_row["target_component_id"], "document_asset_panel", "missing document points to document panel")
	_assert_eq(document_row["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "missing document points to level document slot")
	_assert_eq(document_row["destination_tab"], "Resources", "TAB-54 missing document route selects Resources")
	_assert_eq(document_row["focus_type"], "asset_slot", "TAB-54 missing document route focuses asset slot")
	_assert_eq(document_row["suggested_action"], "Select or create Level Document.", "TAB-54 missing document route suggests concrete action")

	var catalog_row = _validation_issue_row_for_rule(rows, "workspace.tile_catalog_missing")
	_assert_eq(catalog_row["target_tab"], "Catalog", "missing catalog points to Catalog tab")
	_assert_eq(catalog_row["target_component_id"], "catalog_asset_panel", "missing catalog points to catalog panel")
	_assert_eq(catalog_row["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "missing catalog points to tile catalog slot")
	_assert_eq(catalog_row["destination_tab"], "Catalog", "TAB-54 missing catalog route selects Catalog")
	_assert_true(String(catalog_row["focus_target"]) != "", "TAB-54 missing catalog row exposes focus target")
	_assert_true(String(catalog_row["fix_suggestion"]) != "", "TAB-54 missing catalog row exposes fix suggestion")

	var object_row = _validation_issue_row_for_rule(rows, "workspace.object_database_missing")
	_assert_eq(object_row["target_tab"], "Resources", "TAB-51 missing object database points to Resources tab")
	_assert_eq(object_row["target_component_id"], "document_asset_panel", "TAB-51 missing object database points to Resources asset panel")
	_assert_eq(object_row["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE, "missing object database points to object database slot")

	var label_row = _validation_issue_row_for_rule(rows, "workspace.label_database_missing")
	_assert_eq(label_row["target_tab"], "Resources", "TAB-51 missing label database points to Resources tab")
	_assert_eq(label_row["target_component_id"], "document_asset_panel", "TAB-51 missing label database points to Resources asset panel")
	_assert_eq(label_row["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE, "missing label database points to label database slot")

	var layer_row = _validation_issue_row_for_rule(rows, "workspace.layer_stack_missing")
	_assert_eq(layer_row["target_tab"], "Layers", "missing layer stack points to Layers tab")
	_assert_eq(layer_row["target_component_id"], "layer_stack_asset_panel", "missing layer stack points to layer stack panel")
	_assert_eq(layer_row["destination_tab"], "Layers", "TAB-54 missing layer stack route selects Layers")

	var suite_row = _validation_issue_row_for_rule(rows, "workspace.validation_suite_missing")
	_assert_eq(suite_row["target_tab"], "Validate", "missing validation suite points to Validate tab")
	_assert_eq(suite_row["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE, "missing validation suite points to validation suite slot")

	var qa_row = _validation_issue_row_for_rule(rows, "workspace.generation_profile_missing")
	_assert_eq(qa_row["target_tab"], "QA", "missing generation profile points to QA tab")
	_assert_eq(qa_row["target_component_id"], "qa_asset_panel", "missing generation profile points to QA panel")
	_assert_eq(qa_row["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE, "missing generation profile points to generation profile slot")

	var selection = workspace.select_validate_issue(int(document_row["index"]))
	_assert_true(bool(selection["ok"]), "TAB-54 Validate issue selection succeeds")
	_assert_eq(selection["selected_tab"], "Resources", "TAB-54 selecting document issue moves to Resources")
	_assert_eq((selection["navigation"] as Dictionary)["target_component_id"], "document_asset_panel", "TAB-54 selection records component target")
	snapshot = workspace.validate_screen_snapshot()
	_assert_eq((snapshot["selected_issue_row"] as Dictionary)["rule_id"], "workspace.level_document_missing", "TAB-54 snapshot stores selected issue")
	selection = workspace.select_validate_issue(int(catalog_row["index"]))
	_assert_eq(selection["selected_tab"], "Catalog", "TAB-54 selecting catalog issue moves to Catalog")
	selection = workspace.select_validate_issue(int(layer_row["index"]))
	_assert_eq(selection["selected_tab"], "Layers", "TAB-54 selecting layer issue moves to Layers")
	var invalid_selection = workspace.select_validate_issue(999)
	_assert_true(not bool(invalid_selection["ok"]), "TAB-54 invalid issue selection is rejected")

	var cell_document := _sample_editor_document()
	(cell_document.object_placements[0] as HexMapDocumentObjectPlacementResource).cell = Vector3i(1, 0, 0)
	workspace.workspace_asset_context().set_level_document(cell_document)
	var cell_validate_result = workspace.run_validate_screen()
	var cell_rows = cell_validate_result["issue_rows"] as Array
	var wall_row = _validation_issue_row_for_rule(cell_rows, "document.object_on_wall")
	_assert_eq(wall_row["destination_tab"], "Paint", "TAB-54 cell-scoped issue routes to Paint")
	_assert_eq(wall_row["focus_type"], "cell", "TAB-54 cell-scoped issue records cell focus")
	_assert_true(String(wall_row["suggested_action"]).contains("Paint"), "TAB-54 cell-scoped issue suggests Paint inspection")
	selection = workspace.select_validate_issue(int(wall_row["index"]))
	_assert_eq(selection["selected_tab"], "Paint", "TAB-54 selecting cell issue moves to Paint")

	snapshot = workspace.validate_screen_snapshot()
	_assert_true((snapshot["issue_rows"] as Array).size() >= rows.size(), "Validate screen snapshot keeps last issue rows")
	_assert_eq(workspace.workspace_asset_context().tile_catalog, null, "Validate screen does not inject sample catalog")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "Validate screen does not inject generation sample catalog")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Validate screen actions do not enable sample mode")

	workspace.queue_free()
	await process_frame


func _test_qa_asset_screen_manages_profiles_and_score_context_without_samples() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var snapshot = workspace.qa_screen_snapshot()
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("qa_asset_panel"),
		"QA screen exposes QA asset panel"
	)
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("qa_seed_lab_panel"),
		"TAB-55 QA screen exposes Seed Lab panel"
	)
	_assert_true(bool(snapshot["seed_lab_component_present"]), "TAB-55 QA snapshot confirms Seed Lab component")
	_assert_eq(snapshot["purpose_text"], "Compare generated seeds and promote one result to the Level Document.", "TAB-55 QA screen states purpose")
	_assert_true(String(snapshot["generate_role_text"]).contains("Generate previews one candidate"), "TAB-55 QA distinguishes Generate and QA roles")
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE),
		"QA screen exposes generation profile slot"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE),
		"QA screen exposes validation suite slot"
	)
	_assert_true(not bool(snapshot["sample_candidates_visible"]), "QA screen starts with sample mode OFF")

	var output_dir = _test_resource_dir("screen26_qa")
	var profile_path = "%s/generation_profile.tres" % output_dir
	var profile_result = workspace.create_generation_profile(profile_path)
	_assert_true(bool(profile_result["ok"]), "QA screen creates project Generation Profile")
	_assert_true(FileAccess.file_exists(profile_path), "QA screen writes project Generation Profile")
	var profile = profile_result["resource"] as Resource
	_assert_true(profile is Resource, "QA screen create returns generation profile resource")
	_assert_eq(workspace.workspace_asset_context().generation_profile, profile, "created generation profile enters workspace context")
	_assert_eq(
		workspace.tab_asset_slot_snapshot("QA", HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE).get("current_source", ""),
		HexMapEditorAssetSlotState.SOURCE_PROJECT,
		"QA screen marks generation profile as project asset"
	)

	var suite_path = "%s/validation_suite.tres" % output_dir
	var suite_result = workspace.create_validation_rule_suite(suite_path)
	_assert_true(bool(suite_result["ok"]), "QA screen creates project Validation Rule Suite")
	_assert_true(FileAccess.file_exists(suite_path), "QA screen writes project Validation Rule Suite")
	var suite = suite_result["resource"] as Resource
	_assert_true(suite is Resource, "QA screen create returns validation suite resource")
	_assert_eq(workspace.workspace_asset_context().validation_rule_suite, suite, "created validation suite enters workspace context")

	var score_context = workspace.qa_score_table_context()
	_assert_true(bool((score_context["generation_profile"] as Dictionary).get("selected", false)), "QA score context reports selected generation profile")
	_assert_true(bool((score_context["validation_rule_suite"] as Dictionary).get("selected", false)), "QA score context reports selected validation suite")
	_assert_eq(
		String((score_context["generation_profile"] as Dictionary).get("resource_path", "")),
		profile_path,
		"QA score context reports generation profile path"
	)
	_assert_eq(
		String((score_context["validation_rule_suite"] as Dictionary).get("resource_path", "")),
		suite_path,
		"QA score context reports validation suite path"
	)

	var profile_open = workspace.open_generation_profile()
	_assert_true(bool(profile_open["ok"]), "QA screen opens selected Generation Profile")
	var profile_save_as_path = "%s/generation_profile_saved_as.tres" % output_dir
	var profile_save = workspace.save_generation_profile_as(profile_save_as_path)
	_assert_true(bool(profile_save["ok"]), "QA screen saves Generation Profile as project resource")
	_assert_true(FileAccess.file_exists(profile_save_as_path), "QA screen Save As writes generation profile")

	var suite_open = workspace.open_validation_rule_suite()
	_assert_true(bool(suite_open["ok"]), "QA screen opens selected Validation Rule Suite")
	var suite_save_as_path = "%s/validation_suite_saved_as.tres" % output_dir
	var suite_save = workspace.save_validation_rule_suite_as(suite_save_as_path)
	_assert_true(bool(suite_save["ok"]), "QA screen saves Validation Rule Suite as project resource")
	_assert_true(FileAccess.file_exists(suite_save_as_path), "QA screen Save As writes validation suite")

	var preset_profile_path = "%s/balanced_generation_profile.tres" % output_dir
	var preset_profile = workspace.duplicate_generation_profile_preset_to_project("balanced", preset_profile_path)
	_assert_true(bool(preset_profile["ok"]), "QA screen duplicates generation preset to project")
	_assert_true(FileAccess.file_exists(preset_profile_path), "QA screen writes duplicated generation preset")
	var duplicated_profile = preset_profile["resource"] as Resource
	_assert_eq(String(duplicated_profile.get_meta("preset_source", "")), "balanced", "duplicated generation profile records preset source")
	_assert_eq(workspace.workspace_asset_context().generation_profile, duplicated_profile, "duplicated generation profile enters workspace context")

	var preset_suite_path = "%s/standard_validation_suite.tres" % output_dir
	var preset_suite = workspace.duplicate_validation_rule_suite_preset_to_project("standard", preset_suite_path)
	_assert_true(bool(preset_suite["ok"]), "QA screen duplicates validation suite preset to project")
	_assert_true(FileAccess.file_exists(preset_suite_path), "QA screen writes duplicated validation suite preset")
	var duplicated_suite = preset_suite["resource"] as Resource
	_assert_eq(String(duplicated_suite.get_meta("preset_source", "")), "standard", "duplicated validation suite records preset source")
	_assert_eq(workspace.workspace_asset_context().validation_rule_suite, duplicated_suite, "duplicated validation suite enters workspace context")

	score_context = workspace.qa_score_table_context()
	_assert_eq(
		String((score_context["generation_profile"] as Dictionary).get("preset_source", "")),
		"balanced",
		"QA score context reports duplicated generation preset"
	)
	_assert_eq(
		String((score_context["validation_rule_suite"] as Dictionary).get("preset_source", "")),
		"standard",
		"QA score context reports duplicated validation preset"
	)
	snapshot = workspace.qa_screen_snapshot()
	var seed_lab = snapshot["seed_lab"] as Dictionary
	_assert_eq(seed_lab["empty_state_text"], "Run Seed Lab to compare generated seeds.", "TAB-55 QA Seed Lab starts with empty state")
	_assert_true(bool(seed_lab["can_run_batch"]), "TAB-55 QA Seed Lab can run through generation dock")
	_assert_true(not bool(seed_lab["can_promote"]), "TAB-55 QA Seed Lab requires selected seed before promotion")

	var dock = workspace.generation_dock()
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._connect_method_option.select(_connect_method_index(HexMapGenerator.CONNECT_DENSE))
	dock._refresh_controls()

	var batch_result = workspace.run_qa_seed_lab(2, {"seeds": [901, 902]})
	_assert_true(bool(batch_result["ok"]), "TAB-55 QA Seed Lab runs batch")
	var score_rows = batch_result["score_rows"] as Array
	_assert_eq(score_rows.size(), 2, "TAB-55 QA Seed Lab records score rows")
	_assert_true(not (batch_result["selected_seed_row"] as Dictionary).is_empty(), "TAB-55 QA Seed Lab selects top row after batch")
	snapshot = workspace.qa_screen_snapshot()
	seed_lab = snapshot["seed_lab"] as Dictionary
	_assert_eq(int(seed_lab["score_row_count"]), 2, "TAB-55 QA snapshot reports score row count")
	_assert_true((snapshot["score_rows"] as Array).size() == 2, "TAB-55 QA screen exposes score rows")
	_assert_true(bool(seed_lab["can_promote"]), "TAB-55 QA Seed Lab can promote selected row")

	var seed_select = workspace.select_qa_seed_row(1)
	_assert_true(bool(seed_select["ok"]), "TAB-55 QA Seed Lab selects score row")
	var selected_seed = int((seed_select["selected_seed_row"] as Dictionary).get("seed", 0))
	var promote_result = workspace.promote_qa_selected_seed_to_document()
	_assert_true(bool(promote_result["ok"]), "TAB-55 QA Seed Lab promotes selected row")
	var promoted_document = promote_result["document"] as HexMapDocumentResource
	_assert_true(promoted_document is HexMapDocumentResource, "TAB-55 promotion creates Level Document")
	_assert_eq(promoted_document.metadata.generation_seed, selected_seed, "TAB-55 promoted document records selected seed")
	_assert_eq(workspace.workspace_asset_context().level_document, promoted_document, "TAB-55 promotion updates Resources Level Document context")
	snapshot = workspace.qa_screen_snapshot()
	_assert_true(bool(snapshot["promotion_updates_resources"]), "TAB-55 QA snapshot reports Resources document update")
	seed_lab = snapshot["seed_lab"] as Dictionary
	_assert_true(bool((seed_lab["promotion_target"] as Dictionary).get("promoted", false)), "TAB-55 promotion target marks promoted document")

	var clear_profile = workspace.clear_generation_profile()
	_assert_true(bool(clear_profile["ok"]), "QA screen clears Generation Profile")
	_assert_eq(workspace.workspace_asset_context().generation_profile, null, "cleared generation profile leaves workspace context")
	var clear_suite = workspace.clear_validation_rule_suite()
	_assert_true(bool(clear_suite["ok"]), "QA screen clears Validation Rule Suite")
	_assert_eq(workspace.workspace_asset_context().validation_rule_suite, null, "cleared validation suite leaves workspace context")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "QA screen actions do not enable sample mode")

	workspace.queue_free()
	await process_frame


func _test_export_asset_screen_requires_user_destination_and_exports_project_document() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var snapshot = workspace.export_screen_snapshot()
	_assert_eq(snapshot["purpose_text"], "Export writes the current Level Document as a runtime HexMapResource handoff.", "TAB-56 Export screen states purpose")
	_assert_true(bool(snapshot["purpose_component_present"]), "TAB-56 Export snapshot confirms purpose panel")
	_assert_eq(snapshot["active_output_type"], "runtime_handoff_resource", "TAB-56 Export uses runtime handoff as active output")
	var output_type = snapshot["output_type"] as Dictionary
	_assert_eq(output_type["label"], "Runtime Handoff Resource", "TAB-56 Export names output type")
	_assert_eq(output_type["source"], "Current Level Document", "TAB-56 Export names source")
	_assert_eq(output_type["target_resource_class"], "HexMapResource", "TAB-56 Export names output resource")
	_assert_true(not bool(output_type["source_ready"]), "TAB-56 Export starts with missing source")
	_assert_true(not bool(output_type["destination_ready"]), "TAB-56 Export starts with missing destination")
	_assert_eq(snapshot["cannot_export_reason"], "Level Document is not selected.", "TAB-56 Export explains blocked export")
	_assert_true(bool(snapshot["use_recent_button_disabled"]), "FB-02 Export use-recent action starts disabled without recent destination")
	_assert_eq(
		String(snapshot["use_recent_button_tooltip"]),
		"No recent Runtime Handoff destinations.",
		"FB-02 disabled Export use-recent action explains missing recent destination"
	)
	_assert_true(bool(snapshot["run_button_disabled"]), "FB-02 Export run action starts disabled")
	_assert_eq(
		String(snapshot["run_button_tooltip"]),
		"Level Document is not selected.",
		"FB-02 disabled Export run action explains missing Level Document"
	)
	_assert_true(not bool(snapshot["unsupported_export_buttons_visible"]), "TAB-56 unsupported export buttons are hidden")
	_assert_true(not bool(snapshot["data_export_button_visible"]), "TAB-56 data export button is hidden")
	_assert_true(not bool(snapshot["package_build_button_visible"]), "TAB-56 package build button is hidden")
	_assert_true(not bool(snapshot["debug_report_export_button_visible"]), "TAB-56 debug report export button is hidden")
	_assert_true(bool(snapshot["experimental_exports_hidden"]), "TAB-56 experimental exports are hidden")
	var modes = snapshot["output_modes"] as Array
	_assert_eq(_export_mode_status(modes, "runtime_handoff_resource"), "available", "TAB-56 runtime handoff is available")
	_assert_eq(_export_mode_status(modes, "data_export_json"), "backlog", "TAB-56 data export is backlog")
	_assert_eq(_export_mode_status(modes, "package_build"), "process", "TAB-56 package build is process")
	_assert_eq(_export_mode_status(modes, "debug_report"), "diagnostic", "TAB-56 debug report is diagnostic")
	_assert_eq(
		snapshot["visible_output_mode_ids"],
		PackedStringArray(["runtime_handoff_resource"]),
		"INFO-72 Export tab visible output is Runtime Handoff only"
	)
	var visible_mode_labels = snapshot["visible_output_mode_labels"] as PackedStringArray
	_assert_true(visible_mode_labels.has("Runtime Handoff"), "INFO-72 Export visible mode names Runtime Handoff")
	_assert_true(not visible_mode_labels.has("Data Export"), "INFO-72 Data Export is classified but not visible")
	_assert_true(not visible_mode_labels.has("Package Build"), "INFO-72 Package Build is classified but not visible")
	_assert_true(not visible_mode_labels.has("Debug Report"), "INFO-72 Debug Report is classified but not visible")
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("export_asset_panel"),
		"Export screen exposes export asset panel"
	)
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("export_purpose_panel"),
		"TAB-56 Export screen exposes purpose panel"
	)
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("export_destination_panel"),
		"Export screen exposes destination panel"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT),
		"Export screen exposes level document slot"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE),
		"Export screen exposes export profile slot"
	)
	_assert_true(not bool((snapshot["destination"] as Dictionary).get("selected", true)), "Export screen starts without destination")
	_assert_true(not bool(snapshot["can_export"]), "Export screen cannot export until configured")
	_assert_true(not bool(snapshot["sample_destination_available"]), "Export screen has no sample destination")
	_assert_true(not bool(snapshot["editable_destination_path_visible"]), "Export screen does not expose editable destination path text")
	_assert_true(not bool(snapshot["sample_candidates_visible"]), "Export screen starts with sample mode OFF")
	var dialog_config = snapshot["destination_dialog_config"] as Dictionary
	_assert_true(bool(dialog_config.get("uses_file_dialog", false)), "Export destination uses FileDialog contract")
	_assert_eq(int(dialog_config.get("file_mode", -1)), EditorFileDialog.FILE_MODE_SAVE_FILE, "Export destination uses Save As dialog mode")
	_assert_true(String(dialog_config.get("current_file", "")).ends_with(".tres"), "Export destination dialog defaults to .tres")
	_assert_true(not bool(dialog_config.get("editable_path_text_visible", true)), "Export destination dialog does not require editable path text")

	var output_dir = _test_resource_dir("screen27_export")
	var profile_path = "%s/export_profile.tres" % output_dir
	var profile_result = workspace.create_export_profile(profile_path)
	_assert_true(bool(profile_result["ok"]), "Export screen creates project Export Profile")
	_assert_true(FileAccess.file_exists(profile_path), "Export screen writes project Export Profile")
	var export_profile = profile_result["resource"] as Resource
	_assert_true(export_profile is Resource, "Export screen create returns export profile resource")
	_assert_eq(workspace.workspace_asset_context().export_profile, export_profile, "created export profile enters workspace context")
	_assert_eq(
		workspace.tab_asset_slot_snapshot("Export", HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE).get("current_source", ""),
		HexMapEditorAssetSlotState.SOURCE_PROJECT,
		"Export screen marks export profile as project asset"
	)

	var profile_open = workspace.open_export_profile()
	_assert_true(bool(profile_open["ok"]), "Export screen opens selected Export Profile")
	var profile_save_as_path = "%s/export_profile_saved_as.tres" % output_dir
	var profile_save = workspace.save_export_profile_as(profile_save_as_path)
	_assert_true(bool(profile_save["ok"]), "Export screen saves Export Profile as project resource")
	_assert_true(FileAccess.file_exists(profile_save_as_path), "Export screen Save As writes export profile")

	var missing_destination = workspace.export_selected_document_to_destination()
	_assert_true(not bool(missing_destination["ok"]), "Export screen refuses export without selected destination")
	_assert_eq(int(missing_destination["error"]), ERR_INVALID_PARAMETER, "Export without destination reports invalid parameter")

	var document := _sample_editor_document()
	workspace.workspace_asset_context().set_level_document(document)
	snapshot = workspace.export_screen_snapshot()
	_assert_true(bool(snapshot["run_button_disabled"]), "FB-02 Export run remains disabled without destination")
	_assert_eq(
		String(snapshot["run_button_tooltip"]),
		"Export destination is not selected.",
		"FB-02 disabled Export run action explains missing destination after document selection"
	)
	var export_path = "%s/runtime_handoff_map.tres" % output_dir
	var destination_result = workspace.select_export_destination(export_path)
	_assert_true(bool(destination_result["ok"]), "Export screen accepts user-selected destination")
	_assert_eq(session.export_saved_path, export_path, "Export destination updates session handoff path")
	_assert_eq(session.recent_export_destinations[0], export_path, "Export destination enters recent list")
	_assert_eq(workspace.edit_tool().export_path(), export_path, "Export destination syncs paint tool handoff path")

	snapshot = workspace.export_screen_snapshot()
	_assert_true(bool(snapshot["can_export"]), "Export screen can export after document and destination are selected")
	_assert_true(not bool(snapshot["run_button_disabled"]), "FB-02 Export run action enables after document and destination")
	_assert_true(String(snapshot["run_button_tooltip"]).contains("Runtime Handoff"), "FB-02 enabled Export run action names its state change")
	_assert_true(not bool(snapshot["use_recent_button_disabled"]), "FB-02 Export use-recent action enables after destination history exists")
	_assert_true(String(snapshot["use_recent_button_tooltip"]).contains(export_path), "FB-02 enabled Export use-recent action names recent destination")
	_assert_true(bool((snapshot["destination"] as Dictionary).get("selected", false)), "Export snapshot reports selected destination")
	output_type = snapshot["output_type"] as Dictionary
	_assert_true(bool(output_type["source_ready"]), "TAB-56 Export source becomes ready")
	_assert_true(bool(output_type["destination_ready"]), "TAB-56 Export destination becomes ready")
	_assert_eq(snapshot["cannot_export_reason"], "", "TAB-56 Export clears blocked reason when ready")

	var export_result = workspace.export_selected_document_to_destination()
	_assert_true(bool(export_result["ok"]), "Export screen writes selected document handoff")
	_assert_true(FileAccess.file_exists(export_path), "Export screen writes selected destination file")
	var loaded = ResourceLoader.load(export_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	_assert_true(loaded is HexMapResource, "Export screen handoff loads as HexMapResource")
	_assert_eq(export_result["resource_class"], "HexMapResource", "Export result reports HexMapResource")
	_assert_eq(export_result["output_type"], "runtime_handoff_resource", "TAB-56 export result reports output type")
	_assert_eq(export_result["purpose_text"], "Runtime handoff HexMapResource", "TAB-56 export result reports purpose")
	var document_summary := HexMapDocumentAdapter.document_summary(document)
	_assert_eq(int(export_result["cell_count"]), int(document_summary["cells"]), "Export result reports document cell count")
	_assert_eq(String((export_result["package_handoff"] as Dictionary).get("path", "")), export_path, "Export result reports package handoff path")
	_assert_eq(String((export_result["runtime_handoff"] as Dictionary).get("resource_class", "")), "HexMapResource", "Export result reports runtime handoff type")

	var next_export_path = "%s/runtime_handoff_next.tres" % output_dir
	var next_destination = workspace.select_export_destination(next_export_path)
	_assert_true(bool(next_destination["ok"]), "Export screen accepts another user-selected destination")
	var recent_result = workspace.select_recent_export_destination(export_path)
	_assert_true(bool(recent_result["ok"]), "Export screen selects previous recent destination")
	_assert_eq(session.export_saved_path, export_path, "Recent destination updates active export path")
	_assert_eq(session.recent_export_destinations[0], export_path, "Recent destination moves to front")

	var clear_profile = workspace.clear_export_profile()
	_assert_true(bool(clear_profile["ok"]), "Export screen clears Export Profile")
	_assert_eq(workspace.workspace_asset_context().export_profile, null, "cleared export profile leaves workspace context")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Export screen actions do not enable sample mode")

	workspace.queue_free()
	await process_frame


func _test_feature_screen_completion_contract_uses_project_assets_with_sample_mode_off() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	_assert_true(not session.show_bundled_samples_in_main_selectors, "TEST-40 starts with sample mode OFF")
	_assert_true(not workspace.generation_dock().main_sample_controls_visible(), "TEST-40 Generate main UI hides sample controls")
	_assert_true(not workspace.edit_tool().main_sample_controls_visible(), "TEST-40 Paint main UI hides sample controls")

	var output_dir = _test_resource_dir("test40_project_asset_contract")
	var document_path = "%s/level_document.tres" % output_dir
	var document_result = workspace.create_level_document(document_path)
	_assert_true(bool(document_result["ok"]), "TEST-40 creates project Level Document")
	var document = document_result["resource"] as HexMapDocumentResource
	_assert_true(document is HexMapDocumentResource, "TEST-40 Level Document uses document resource")

	var catalog_path = "%s/tile_catalog.tres" % output_dir
	var catalog_result = workspace.create_tile_catalog(catalog_path)
	_assert_true(bool(catalog_result["ok"]), "TEST-40 creates project Tile Catalog")
	var catalog = catalog_result["resource"] as HexTileCatalogResource
	_assert_true(catalog is HexTileCatalogResource, "TEST-40 Tile Catalog uses catalog resource")
	var tile_set := _test_catalog_tileset()
	_assert_true(bool(workspace.set_catalog_tile_set(tile_set)["ok"]), "TEST-40 Catalog accepts arbitrary TileSet")
	_assert_eq(catalog.tile_set, tile_set, "TEST-40 Catalog stores arbitrary TileSet selection")

	var layer_stack_path = "%s/layer_stack.tres" % output_dir
	var layer_stack_result = workspace.create_layer_stack(layer_stack_path)
	_assert_true(bool(layer_stack_result["ok"]), "TEST-40 creates project Layer Stack")
	var layer_stack = layer_stack_result["resource"] as HexLayerStackResource
	_assert_true(layer_stack is HexLayerStackResource, "TEST-40 Layer Stack uses layer stack resource")

	var object_db_path = "%s/object_database.tres" % output_dir
	var object_db_result = workspace.create_object_database(object_db_path)
	_assert_true(bool(object_db_result["ok"]), "TEST-40 creates project Object Database")
	var object_database = object_db_result["resource"] as HexObjectDatabaseResource
	_assert_true(object_database is HexObjectDatabaseResource, "TEST-40 Object Database uses object database resource")

	var label_db_path = "%s/label_database.tres" % output_dir
	var label_db_result = workspace.create_label_database(label_db_path)
	_assert_true(bool(label_db_result["ok"]), "TEST-40 creates project Label Database")
	var label_database = label_db_result["resource"] as HexLabelDatabaseResource
	_assert_true(label_database is HexLabelDatabaseResource, "TEST-40 Label Database uses label database resource")

	var validation_suite_path = "%s/validation_suite.tres" % output_dir
	var validation_suite_result = workspace.create_validation_rule_suite(validation_suite_path)
	_assert_true(bool(validation_suite_result["ok"]), "TEST-40 creates project Validation Rule Suite")
	var validation_suite = validation_suite_result["resource"] as Resource
	_assert_true(validation_suite is Resource, "TEST-40 Validation Rule Suite uses Resource")

	var generation_profile_path = "%s/generation_profile.tres" % output_dir
	var generation_profile_result = workspace.create_generation_profile(generation_profile_path)
	_assert_true(bool(generation_profile_result["ok"]), "TEST-40 creates project Generation Profile")
	var generation_profile = generation_profile_result["resource"] as Resource
	_assert_true(generation_profile is Resource, "TEST-40 Generation Profile uses Resource")

	var export_profile_path = "%s/export_profile.tres" % output_dir
	var export_profile_result = workspace.create_export_profile(export_profile_path)
	_assert_true(bool(export_profile_result["ok"]), "TEST-40 creates project Export Profile")
	var export_profile = export_profile_result["resource"] as Resource
	_assert_true(export_profile is Resource, "TEST-40 Export Profile uses Resource")

	_assert_project_asset_slot(
		workspace,
		"Document",
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
		document,
		document_path,
		"TEST-40 Document screen Level Document"
	)
	_assert_project_asset_slot(
		workspace,
		"Catalog",
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		catalog,
		catalog_path,
		"TEST-40 Catalog screen Tile Catalog"
	)
	_assert_project_asset_slot(
		workspace,
		"Layers",
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
		layer_stack,
		layer_stack_path,
		"TEST-40 Layers screen Layer Stack"
	)
	_assert_project_asset_slot(
		workspace,
		"Resources",
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE,
		object_database,
		object_db_path,
		"TAB-51 Resources screen Object Database"
	)
	_assert_project_asset_slot(
		workspace,
		"Resources",
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE,
		label_database,
		label_db_path,
		"TAB-51 Resources screen Label Database"
	)
	_assert_project_asset_slot(
		workspace,
		"Validate",
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE,
		validation_suite,
		validation_suite_path,
		"TEST-40 Validate screen Validation Rule Suite"
	)
	_assert_project_asset_slot(
		workspace,
		"QA",
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE,
		generation_profile,
		generation_profile_path,
		"TEST-40 QA screen Generation Profile"
	)
	_assert_project_asset_slot(
		workspace,
		"Export",
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
		document,
		document_path,
		"TEST-40 Export screen Level Document"
	)
	_assert_project_asset_slot(
		workspace,
		"Export",
		HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE,
		export_profile,
		export_profile_path,
		"TEST-40 Export screen Export Profile"
	)
	_assert_eq(workspace.generation_dock().tile_catalog(), catalog, "TEST-40 Generate consumes project catalog, not sample fallback")
	_assert_eq(workspace.edit_tool().tile_catalog(), catalog, "TEST-40 Paint consumes project catalog, not sample fallback")

	var export_path = "%s/runtime_handoff.tres" % output_dir
	var destination_result = workspace.select_export_destination(export_path)
	_assert_true(bool(destination_result["ok"]), "TEST-40 selects user export destination")
	var export_snapshot = workspace.export_screen_snapshot()
	var destination = export_snapshot["destination"] as Dictionary
	_assert_true(bool(destination.get("selected", false)), "TEST-40 Export destination is selected")
	_assert_eq(String(destination.get("path", "")), export_path, "TEST-40 Export destination uses user project path")
	_assert_true(not _is_bundled_sample_asset_path(String(destination.get("path", ""))), "TEST-40 Export destination is not a bundled sample path")

	_assert_true(not session.show_bundled_samples_in_main_selectors, "TEST-40 project asset contract keeps sample mode OFF")
	_assert_true(not workspace.generation_dock().main_sample_controls_visible(), "TEST-40 Generate sample controls remain hidden")
	_assert_true(not workspace.edit_tool().main_sample_controls_visible(), "TEST-40 Paint sample controls remain hidden")

	workspace.queue_free()
	await process_frame


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


func _test_workspace_sample_settings_panel_controls_sample_mode_sources() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var panel = workspace.sample_settings_panel()
	_assert_true(panel is HexMapSampleSettingsPanel, "workspace exposes sample settings panel")
	var settings_snapshot = workspace.settings_screen_snapshot()
	_assert_true(workspace.tab_has_component("Settings", "settings_preferences_panel"), "TAB-57 Settings exposes preferences/debug purpose panel")
	_assert_eq(settings_snapshot["asset_slot_ids"], PackedStringArray(), "TAB-57 Settings has no production asset slot ids")
	_assert_true(not bool(settings_snapshot["production_asset_selection_present"]), "TAB-57 Settings has no production asset selection")
	_assert_eq(String(settings_snapshot["movement_profile_slot_owner"]), "Resources", "TAB-57 Movement Profile belongs to Resources")
	_assert_true(
		(settings_snapshot["resources_tab_asset_slot_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE),
		"TAB-57 Resources exposes Movement Profile"
	)
	_assert_true(bool(settings_snapshot["sample_learning_controls_present"]), "TAB-57 Settings keeps sample learning controls")
	_assert_true(bool(settings_snapshot["debug_numeric_fallback_isolated"]), "TAB-57 debug numeric fallback is isolated in Settings controls")
	_assert_true(bool(settings_snapshot["sample_actions_work_or_removed"]), "TAB-57 sample actions are functional or removed")
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
	_assert_true(
		not bool(snapshot["debug_numeric_tile_fallback_enabled"]),
		"debug numeric fallback is off by default"
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
	_assert_true(bool(workspace.catalog_screen_snapshot()["sample_candidates_visible"]), "sample mode ON exposes Catalog learning candidates")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "SAMPLE-41 sample mode ON does not inject Generate sample catalog")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "SAMPLE-41 sample mode ON does not inject Paint sample catalog")

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

	panel.set_debug_numeric_tile_fallback_enabled(true)
	snapshot = panel.snapshot()
	settings_snapshot = workspace.settings_screen_snapshot()
	_assert_true(bool(snapshot["debug_numeric_tile_fallback_enabled"]), "Settings can enable explicit debug numeric fallback")
	_assert_true(bool(settings_snapshot["debug_numeric_tile_fallback_enabled"]), "TAB-57 Settings snapshot mirrors debug numeric fallback")
	panel.set_debug_numeric_tile_fallback_enabled(false)
	settings_snapshot = workspace.settings_screen_snapshot()
	_assert_true(not session.debug_numeric_tile_fallback_enabled, "Settings can disable debug numeric fallback")
	_assert_true(not bool(settings_snapshot["debug_numeric_tile_fallback_enabled"]), "TAB-57 Settings snapshot disables debug numeric fallback")

	workspace.queue_free()
	await process_frame


func _test_sample_learning_package_contract_keeps_bundled_assets_opt_in() -> void:
	var sample_catalog_path := "res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres"
	var sample_texture_path := HexMapTileAdapter.SAMPLE_TILE_ATLAS_PATH
	var sample_scene_path := "res://addons/hex_map_kit/assets/sample_spawn_marker.tscn"
	_assert_true(ResourceLoader.exists(sample_catalog_path), "PKG-70 sample catalog exists for package learning")
	_assert_true(ResourceLoader.exists(sample_texture_path), "PKG-70 sample tile texture exists for package learning")
	_assert_true(ResourceLoader.exists(sample_scene_path), "PKG-70 sample object scene exists for package learning")

	var sample_catalog = ResourceLoader.load(sample_catalog_path, "HexTileCatalogResource", ResourceLoader.CACHE_MODE_IGNORE) as HexTileCatalogResource
	_assert_true(sample_catalog is HexTileCatalogResource, "PKG-70 sample catalog loads as tile catalog")
	_assert_true(sample_catalog.tile_set is TileSet, "PKG-70 sample catalog owns TileSet")
	_assert_true(sample_catalog.has_key("terrain.floor"), "PKG-70 sample catalog exposes floor learning key")
	_assert_true(sample_catalog.has_key("terrain.wall"), "PKG-70 sample catalog exposes wall learning key")
	var texture = ResourceLoader.load(sample_texture_path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
	_assert_true(texture is Texture2D, "PKG-70 sample tile texture loads")
	var sample_scene = ResourceLoader.load(sample_scene_path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
	_assert_true(sample_scene is PackedScene, "PKG-70 sample object scene loads")
	var scene_instance = sample_scene.instantiate()
	_assert_true(scene_instance is Node, "PKG-70 sample object scene instantiates")
	scene_instance.free()

	var scene_entry = sample_catalog.entry_for_key("object.spawn_marker")
	_assert_true(scene_entry != null, "PKG-70 sample catalog includes object scene entry")
	_assert_eq(
		(scene_entry.get("scene") as PackedScene).resource_path,
		sample_scene_path,
		"PKG-70 sample scene entry points to packaged scene"
	)

	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var panel = workspace.sample_settings_panel()
	var snapshot = panel.snapshot()
	_assert_true(_sample_asset_rows_have_path(snapshot["sample_assets"] as Array, sample_catalog_path), "PKG-70 sample settings list catalog")
	_assert_true(_sample_asset_rows_have_path(snapshot["sample_assets"] as Array, sample_texture_path), "PKG-70 sample settings list tile texture")
	_assert_true(_sample_asset_rows_have_path(snapshot["sample_assets"] as Array, sample_scene_path), "PKG-70 sample settings list object scene")
	_assert_true(not bool(snapshot["show_bundled_samples_in_main_selectors"]), "PKG-70 sample mode starts OFF")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "PKG-70 sample mode OFF does not inject Generate sample catalog")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "PKG-70 sample mode OFF does not inject Paint sample catalog")

	panel.set_show_bundled_samples_in_main_selectors(true)
	_assert_true(bool(workspace.catalog_screen_snapshot()["sample_candidates_visible"]), "PKG-70 sample mode ON exposes Catalog learning candidates")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "SAMPLE-41 PKG-70 sample mode ON does not inject Generate sample catalog")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "SAMPLE-41 PKG-70 sample mode ON does not inject Paint sample catalog")

	var project_catalog = HexTileCatalogResource.new()
	session.set_workspace_asset(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, project_catalog, "pkg70.project_catalog")
	_assert_eq(workspace.generation_dock().tile_catalog(), project_catalog, "PKG-70 project catalog stays primary in Generate")
	_assert_eq(workspace.edit_tool().tile_catalog(), project_catalog, "PKG-70 project catalog stays primary in Paint")

	workspace.queue_free()
	await process_frame


func _sample_asset_rows_have_path(rows: Array, path: String) -> bool:
	for row in rows:
		if String((row as Dictionary).get("path", "")) == path:
			return true
	return false


func _test_clean_project_package_contract_uses_project_assets_without_samples() -> void:
	var config = ConfigFile.new()
	_assert_eq(config.load("res://addons/hex_map_kit/plugin.cfg"), OK, "PKG-71 plugin config loads in clean project contract")
	var script_path = "res://addons/hex_map_kit/%s" % config.get_value("plugin", "script", "")
	_assert_true(load(script_path) != null, "PKG-71 plugin script loads in clean project contract")

	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	_assert_true(not session.show_bundled_samples_in_main_selectors, "PKG-71 clean project starts with sample mode OFF")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "PKG-71 clean project has no Generate sample injection")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "PKG-71 clean project has no Paint sample injection")

	var initial_validation = workspace.run_validate_screen()
	_assert_true(bool(initial_validation["ok"]), "PKG-71 clean project validation runs before asset selection")
	var initial_rows = initial_validation["issue_rows"] as Array
	_assert_true(
		not _validation_issue_row_for_rule(initial_rows, "workspace.level_document_missing").is_empty(),
		"PKG-71 clean project reports missing document before selection"
	)
	_assert_true(
		not _validation_issue_row_for_rule(initial_rows, "workspace.tile_catalog_missing").is_empty(),
		"PKG-71 clean project reports missing catalog before selection"
	)
	_assert_true(
		not _validation_issue_row_for_rule(initial_rows, "workspace.object_database_missing").is_empty(),
		"PKG-71 clean project reports missing object database before selection"
	)

	var output_dir = _test_resource_dir("pkg71_clean_project")
	var document_path = "%s/clean_level_document.tres" % output_dir
	var document_result = workspace.create_level_document(document_path)
	_assert_true(bool(document_result["ok"]), "PKG-71 creates clean project Level Document")
	var document = document_result["resource"] as HexMapDocumentResource
	_assert_true(document is HexMapDocumentResource, "PKG-71 Level Document is project resource")

	var catalog_path = "%s/clean_tile_catalog.tres" % output_dir
	var catalog_result = workspace.create_tile_catalog(catalog_path)
	_assert_true(bool(catalog_result["ok"]), "PKG-71 creates clean project Tile Catalog")
	var catalog = catalog_result["resource"] as HexTileCatalogResource
	_assert_true(catalog is HexTileCatalogResource, "PKG-71 Tile Catalog is project resource")
	var tile_set := _test_catalog_tileset()
	_assert_true(bool(workspace.set_catalog_tile_set(tile_set)["ok"]), "PKG-71 assigns user TileSet")
	_assert_eq(catalog.tile_set, tile_set, "PKG-71 catalog stores user TileSet")
	_assert_true(
		bool(workspace.create_catalog_atlas_entry_from_tileset("terrain.clean_floor", tile_set, 0, Vector2i.ZERO)["ok"]),
		"PKG-71 creates catalog entry from user TileSet"
	)

	var object_db_path = "%s/clean_object_database.tres" % output_dir
	var object_db_result = workspace.create_object_database(object_db_path)
	_assert_true(bool(object_db_result["ok"]), "PKG-71 creates clean project Object Database")
	var object_database = object_db_result["resource"] as HexObjectDatabaseResource
	_assert_true(object_database is HexObjectDatabaseResource, "PKG-71 Object Database is project resource")

	var marker := Node2D.new()
	marker.name = "CleanProjectObject"
	var scene := PackedScene.new()
	_assert_eq(scene.pack(marker), OK, "PKG-71 packs user object scene")
	marker.free()
	var scene_path = "%s/clean_project_object.tscn" % output_dir
	_assert_eq(ResourceSaver.save(scene, scene_path), OK, "PKG-71 saves user object scene")
	scene.resource_path = scene_path
	var definition_result = workspace.create_object_definition_from_packed_scene("object.clean_project", scene, "Clean Project Object")
	_assert_true(bool(definition_result["ok"]), "PKG-71 creates object definition from user PackedScene")
	var object_definition = definition_result["definition"] as HexObjectDefinitionResource
	_assert_true(object_definition is HexObjectDefinitionResource, "PKG-71 object definition is typed")
	_assert_eq(object_definition.scene, scene, "PKG-71 object definition stores user scene")

	_assert_project_asset_slot(
		workspace,
		"Document",
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
		document,
		document_path,
		"PKG-71 clean project Document slot"
	)
	_assert_project_asset_slot(
		workspace,
		"Catalog",
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		catalog,
		catalog_path,
		"PKG-71 clean project Catalog slot"
	)
	_assert_project_asset_slot(
		workspace,
		"Resources",
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE,
		object_database,
		object_db_path,
		"TAB-51 PKG-71 clean project Object Database slot"
	)
	_assert_eq(workspace.generation_dock().tile_catalog(), catalog, "PKG-71 Generate uses project catalog after selection")
	_assert_eq(workspace.edit_tool().tile_catalog(), catalog, "PKG-71 Paint uses project catalog after selection")

	var after_selection = workspace.run_validate_screen()
	var after_result = after_selection["result"] as HexMapValidationResult
	_assert_true(after_result is HexMapValidationResult, "PKG-71 clean project validation returns result after selection")
	_assert_true(
		not _validation_result_has_rule(after_result, "workspace.level_document_missing"),
		"PKG-71 selected document clears missing document validation"
	)
	_assert_true(
		not _validation_result_has_rule(after_result, "workspace.tile_catalog_missing"),
		"PKG-71 selected catalog clears missing catalog validation"
	)
	_assert_true(
		not _validation_result_has_rule(after_result, "workspace.object_database_missing"),
		"PKG-71 selected object database clears missing object validation"
	)
	_assert_true(not session.show_bundled_samples_in_main_selectors, "PKG-71 clean project flow keeps sample mode OFF")

	workspace.queue_free()
	await process_frame


func _test_debug_numeric_fallback_quarantine_requires_settings_opt_in() -> void:
	var session = HexMapEditorSessionState.new()
	var panel = HexMapSampleSettingsPanel.new()
	panel.set_editor_session_state(session)
	root.add_child(panel)
	await process_frame

	var data = HexMapData.rectangle(1, 1)
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_tile_override(document, HexVector.zero(), {
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 8,
		"atlas_coords": Vector2i(4, 5),
	})
	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	var image = Image.create(384, 384, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture = ImageTexture.create_from_image(image)
	HexMapTileAdapter.configure_atlas_tile_set(
		layer.tile_set,
		texture,
		true,
		Vector2i(64, 64),
		8,
		[Vector2i(4, 5)]
	)
	root.add_child(layer)
	var tool = await _new_ready_edit_tool()
	tool.set_editor_session_state(session)
	tool.set_document(document)
	tool.set_target_layer(layer)

	_assert_true(not session.debug_numeric_tile_fallback_enabled, "numeric fallback quarantine starts disabled")
	_assert_true(tool._apply_document_to_target(), "normal apply completes without numeric fallback")
	_assert_eq(layer.get_cell_source_id(Vector2i.ZERO), -1, "normal apply does not silently fill missing catalog through numeric fallback")
	var validation = HexMapDocumentValidator.validate_document(document)
	_assert_true(
		_validation_result_has_rule(validation, HexMapDocumentValidator.RULE_TILE_ASSIGNMENT_MISSING),
		"missing catalog assignment remains a validation issue"
	)

	panel.set_debug_numeric_tile_fallback_enabled(true)
	_assert_true(session.debug_numeric_tile_fallback_enabled, "debug fallback requires explicit Settings opt-in")
	_assert_true(tool._apply_document_to_target(), "debug apply completes with explicit numeric fallback")
	_assert_eq(layer.get_cell_source_id(Vector2i.ZERO), 8, "debug opt-in applies numeric fallback source")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(4, 5), "debug opt-in applies numeric fallback atlas")

	panel.queue_free()
	layer.queue_free()
	tool.queue_free()
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
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_WARNING, "SAMPLE-41 explicit sample application warns before production use")


func _test_asset_slot_state_model_contract_covers_sample_visibility_and_project_duplicates() -> void:
	var slot = HexMapEditorAssetSlotState.new()
	slot.configure("tile_catalog", "Tile Catalog", &"HexTileCatalogResource", true)
	var snapshot = slot.snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_NOT_SELECTED, "TEST-42 required asset missing is not selected")
	_assert_true(String(snapshot["validation_messages"][0]).contains("required"), "TEST-42 required asset missing reports validation message")

	var sample_catalog = HexTileCatalogResource.new()
	slot.set_sample_source(
		sample_catalog,
		"res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres",
		"Bundled Sample Catalog"
	)
	snapshot = slot.snapshot()
	_assert_true(bool(snapshot["allows_sample"]), "TEST-42 slot allows explicit sample source")
	_assert_true(bool(snapshot["sample_available"]), "TEST-42 slot reports sample candidate availability")
	_assert_true(not bool(snapshot["selected"]), "TEST-42 sample candidate is not selected by default")
	_assert_eq(snapshot["current_source"], HexMapEditorAssetSlotState.SOURCE_NONE, "TEST-42 sample candidate does not become current source")

	slot.set_selected_resource(HexMapDocumentResource.new(), "res://project/level_document.tres")
	snapshot = slot.snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_INVALID, "TEST-42 invalid type reports invalid state")
	_assert_true(not bool(snapshot["type_matches"]), "TEST-42 invalid type exposes failed type match")
	_assert_eq(snapshot["current_source"], HexMapEditorAssetSlotState.SOURCE_PROJECT, "TEST-42 invalid project selection still records project source")

	var project_catalog = HexTileCatalogResource.new()
	slot.set_selected_resource(project_catalog, "res://project/tile_catalog.tres")
	snapshot = slot.snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_SELECTED, "TEST-42 selected project asset reports selected state")
	_assert_eq(snapshot["current_source"], HexMapEditorAssetSlotState.SOURCE_PROJECT, "TEST-42 selected project asset records project source")
	_assert_eq(snapshot["current_resource"], project_catalog, "TEST-42 selected project asset records resource")

	_assert_true(slot.apply_sample_source(), "TEST-42 explicit sample action can select sample")
	snapshot = slot.snapshot()
	_assert_eq(snapshot["current_source"], HexMapEditorAssetSlotState.SOURCE_SAMPLE, "TEST-42 explicit sample action records sample source")
	_assert_eq(snapshot["current_resource"], sample_catalog, "TEST-42 explicit sample action records sample resource")

	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	_assert_true(not bool(workspace.catalog_screen_snapshot()["sample_candidates_visible"]), "TEST-42 sample mode OFF hides Catalog sample candidates")
	_assert_true(not bool(workspace.validate_screen_snapshot()["sample_candidates_visible"]), "TEST-42 sample mode OFF hides Validate sample candidates")
	_assert_true(not bool(workspace.qa_screen_snapshot()["sample_candidates_visible"]), "TEST-42 sample mode OFF hides QA sample candidates")
	_assert_true(not bool(workspace.export_screen_snapshot()["sample_candidates_visible"]), "TEST-42 sample mode OFF hides Export sample candidates")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "TEST-42 sample mode OFF hides Generate sample fallback")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "TEST-42 sample mode OFF hides Paint sample fallback")

	var panel = workspace.sample_settings_panel()
	panel.set_show_bundled_samples_in_main_selectors(true)
	_assert_true(bool(panel.snapshot()["show_bundled_samples_in_main_selectors"]), "TEST-42 sample mode ON records Settings flag")
	_assert_true(bool(workspace.catalog_screen_snapshot()["sample_candidates_visible"]), "TEST-42 sample mode ON shows Catalog learning candidates")
	_assert_true(bool(workspace.validate_screen_snapshot()["sample_candidates_visible"]), "TEST-42 sample mode ON shows Validate learning candidates")
	_assert_true(bool(workspace.qa_screen_snapshot()["sample_candidates_visible"]), "TEST-42 sample mode ON shows QA learning candidates")
	_assert_true(bool(workspace.export_screen_snapshot()["sample_candidates_visible"]), "TEST-42 sample mode ON shows Export learning candidates")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "SAMPLE-41 sample mode ON does not auto-use Generate sample fallback")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "SAMPLE-41 sample mode ON does not auto-use Paint sample fallback")

	var direct_sample_catalog = ResourceLoader.load(
		"res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres",
		"HexTileCatalogResource",
		ResourceLoader.CACHE_MODE_IGNORE
	) as HexTileCatalogResource
	session.set_workspace_asset(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, direct_sample_catalog, "test.direct_sample_catalog")
	var direct_sample_slot = workspace.tab_asset_slot_snapshot("Catalog", HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG)
	_assert_eq(String(direct_sample_slot["current_source"]), HexMapEditorAssetSlotState.SOURCE_SAMPLE, "SAMPLE-41 direct bundled sample selection is SOURCE_SAMPLE")
	_assert_eq(String(direct_sample_slot["status"]), HexMapEditorAssetSlotState.STATUS_WARNING, "SAMPLE-41 direct bundled sample selection warns")
	_assert_true(
		String((direct_sample_slot["validation_messages"] as Array)[0]).contains("Duplicate"),
		"SAMPLE-41 direct bundled sample warning points to project duplicate"
	)
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "SAMPLE-41 direct bundled sample selection is not Generate source")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "SAMPLE-41 direct bundled sample selection is not Paint source")

	var output_dir = _test_resource_dir("test42_asset_slot_state")
	var catalog_path = "%s/duplicated_sample_catalog.tres" % output_dir
	var duplicate_result = panel.duplicate_sample_catalog_to_project(catalog_path)
	_assert_true(bool(duplicate_result["ok"]), "TEST-42 duplicate sample to project succeeds")
	var duplicated_catalog = duplicate_result["catalog"] as HexTileCatalogResource
	_assert_true(duplicated_catalog is HexTileCatalogResource, "TEST-42 duplicate returns catalog resource")
	_assert_true(bool(duplicated_catalog.metadata.get("project_copy", false)), "TEST-42 duplicate marks project copy metadata")
	_assert_eq(
		String(duplicated_catalog.metadata.get("duplicated_from_sample", "")),
		"res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres",
		"TEST-42 duplicate records source sample metadata"
	)
	_assert_eq(session.current_workspace_asset_context().tile_catalog, duplicated_catalog, "TEST-42 duplicate enters workspace context")
	_assert_project_asset_slot(
		workspace,
		"Catalog",
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		duplicated_catalog,
		catalog_path,
		"TEST-42 duplicated sample Catalog slot"
	)
	_assert_eq(workspace.generation_dock().tile_catalog(), duplicated_catalog, "TEST-42 duplicated project catalog is primary for Generate")
	_assert_eq(workspace.edit_tool().tile_catalog(), duplicated_catalog, "TEST-42 duplicated project catalog is primary for Paint")

	workspace.queue_free()
	await process_frame


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
	_assert_eq(String(snapshot["picker_base_type"]), "HexObjectDatabaseResource", "ASSET-30 asset slot state exposes strict picker base type")
	_assert_true(not bool(snapshot["uses_generic_resource_filter"]), "ASSET-30 typed asset slot does not use generic Resource filter")
	var layout = control.slot_layout_snapshot()
	_assert_true(bool(layout["compact_row"]), "asset slot control uses compact row layout")
	_assert_eq(layout["status_text"], "Missing", "asset slot compact row keeps missing state visible")
	_assert_true(not bool(layout["details_visible"]), "asset slot details start collapsed")
	_assert_eq(String(layout["details_button_text"]), "", "FB-02 asset slot removes visible Details button text")
	_assert_true(not bool(layout["details_button_visible"]), "FB-02 asset slot Details button is not visible")
	_assert_true(String(layout["status_tooltip"]).contains("Type: HexObjectDatabaseResource"), "asset slot compact status tooltip includes type")
	_assert_true(String(layout["status_tooltip"]).contains("Pick: HexObjectDatabaseResource"), "ASSET-30 asset slot tooltip says what type to pick")
	if bool(layout["resource_picker_visible"]):
		_assert_eq(String(layout["resource_picker_base_type"]), "HexObjectDatabaseResource", "ASSET-30 EditorResourcePicker uses strict base type")
	var action_texts = layout["action_button_texts"] as PackedStringArray
	_assert_true(action_texts.has("Create New..."), "ASSET-31 asset slot keeps implemented Create New action")
	_assert_true(action_texts.has("Sample Object DB"), "ASSET-31 asset slot keeps explicit sample action")
	_assert_true(not action_texts.has("Select..."), "ASSET-31 asset slot removes redundant Select button")
	_assert_true(not action_texts.has("Open"), "ASSET-31 asset slot removes unimplemented Open button")
	_assert_true(not action_texts.has("Clear"), "ASSET-31 asset slot delegates Clear to ResourcePicker")
	_assert_true(not action_texts.has("Validate"), "ASSET-31 asset slot removes row-level Validate button")
	_assert_true(not _has_button_text(control, "Select..."), "ASSET-31 visible Select button is absent")
	_assert_true(not _has_button_text(control, "Open"), "ASSET-31 visible Open button is absent")
	_assert_true(not _has_button_text(control, "Clear"), "ASSET-31 visible Clear button is absent")
	_assert_true(not _has_button_text(control, "Validate"), "ASSET-31 visible Validate button is absent")
	_assert_true(not _has_button_text(control, "Details"), "FB-02 visible Details button is absent")
	_assert_true(String(layout["current_detail_text"]).contains("Current: Not selected"), "asset slot details keep current selection text")

	var database = HexObjectDatabaseResource.new()
	control.set_selected_resource(database, "res://project/object_database.tres")
	snapshot = control.slot_state_snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_SELECTED, "asset slot control records selected state")
	_assert_eq(snapshot["current_resource"], database, "asset slot control records selected resource")
	_assert_eq(snapshot["current_path"], "res://project/object_database.tres", "asset slot control records selected path")
	layout = control.slot_layout_snapshot()
	_assert_eq(layout["status_text"], "OK", "asset slot compact row reports selected state")
	_assert_true(String(layout["status_tooltip"]).contains("res://project/object_database.tres"), "asset slot compact tooltip carries selected path")

	control.mark_invalid(["Object database is missing required definitions."])
	snapshot = control.slot_state_snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_INVALID, "asset slot control can expose invalid state")
	_assert_eq(
		snapshot["validation_messages"][0],
		"Object database is missing required definitions.",
		"asset slot control exposes validation messages"
	)
	layout = control.slot_layout_snapshot()
	_assert_eq(layout["status_text"], "Invalid", "asset slot compact row reports invalid state")
	_assert_true(String(layout["message_detail_text"]).contains("Object database is missing"), "asset slot details keep validation messages")
	control.set_details_visible(true)
	layout = control.slot_layout_snapshot()
	_assert_true(bool(layout["details_visible"]), "asset slot details can expand without private node access")

	_assert_true(control.apply_sample_source(), "asset slot control applies sample only through explicit action")
	snapshot = control.slot_state_snapshot()
	_assert_eq(snapshot["current_source"], HexMapEditorAssetSlotState.SOURCE_SAMPLE, "asset slot control records explicit sample source")
	_assert_eq(snapshot["current_path"], "res://addons/hex_map_kit/assets/sample_object_db.tres", "asset slot control records sample path after explicit action")
	layout = control.slot_layout_snapshot()
	_assert_eq(layout["status_text"], "Warn", "SAMPLE-41 asset slot compact row warns after explicit sample selection")
	_assert_true(String(layout["status_tooltip"]).contains("Source: sample"), "asset slot compact tooltip records sample source")

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


func _test_file_dialog_lifecycle_helper_attaches_without_reparenting() -> void:
	var first_parent := Control.new()
	first_parent.name = "DialogParentA"
	var second_parent := Control.new()
	second_parent.name = "DialogParentB"
	root.add_child(first_parent)
	root.add_child(second_parent)
	await process_frame

	var dialog := Control.new()
	dialog.name = "DialogLifecycleSubject"
	var initial_snapshot = HexMapEditorPathSelector.dialog_lifecycle_snapshot(dialog)
	_assert_true(bool(initial_snapshot["valid"]), "FileDialog lifecycle snapshot accepts a dialog node")
	_assert_true(not bool(initial_snapshot["has_parent"]), "new dialog node starts without a parent")

	_assert_true(
		HexMapEditorPathSelector.attach_dialog(dialog, first_parent),
		"FileDialog lifecycle helper attaches unparented dialog node"
	)
	var attached_snapshot = HexMapEditorPathSelector.dialog_lifecycle_snapshot(dialog)
	_assert_true(bool(attached_snapshot["has_parent"]), "FileDialog lifecycle snapshot records attached parent")
	_assert_eq(attached_snapshot["parent"], first_parent, "FileDialog lifecycle helper uses the requested parent")
	_assert_true(bool(attached_snapshot["inside_tree"]), "attached dialog node is inside the test scene tree")
	_assert_eq(first_parent.get_child_count(), 1, "FileDialog attach adds the dialog node once")

	_assert_true(
		HexMapEditorPathSelector.attach_dialog(dialog, second_parent),
		"FileDialog lifecycle helper accepts already attached dialog node without reparenting"
	)
	var reattach_snapshot = HexMapEditorPathSelector.dialog_lifecycle_snapshot(dialog)
	_assert_eq(reattach_snapshot["parent"], first_parent, "FileDialog lifecycle helper does not reparent an attached dialog node")
	_assert_eq(first_parent.get_child_count(), 1, "FileDialog lifecycle helper does not double-add dialog node to original parent")
	_assert_eq(second_parent.get_child_count(), 0, "FileDialog lifecycle helper does not add attached dialog node to second parent")

	dialog.queue_free()
	first_parent.queue_free()
	second_parent.queue_free()
	await process_frame


func _test_workspace_asset_slots_use_strict_resource_type_filters() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var typed_expectations: Array[Dictionary] = [
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "type": "HexMapDocumentResource"},
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "type": "HexTileCatalogResource"},
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE, "type": "HexObjectDatabaseResource"},
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE, "type": "HexLabelDatabaseResource"},
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_LAYER_STACK, "type": "HexLayerStackResource"},
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE, "type": "HexMovementProfileResource"},
		{"tab": "Catalog", "slot": HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "type": "HexTileCatalogResource"},
		{"tab": "Layers", "slot": HexMapWorkspaceAssetContext.SLOT_LAYER_STACK, "type": "HexLayerStackResource"},
		{"tab": "Validate", "slot": HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "type": "HexMapDocumentResource"},
		{"tab": "QA", "slot": HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "type": "HexMapDocumentResource"},
		{"tab": "Export", "slot": HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "type": "HexMapDocumentResource"},
	]
	for expectation in typed_expectations:
		var tab_name := String(expectation["tab"])
		var slot_id := String(expectation["slot"])
		var expected_type := String(expectation["type"])
		var snapshot = workspace.tab_asset_slot_snapshot(tab_name, slot_id)
		var layout = workspace.tab_asset_slot_layout_snapshot(tab_name, slot_id)
		_assert_eq(String(snapshot["required_type"]), expected_type, "ASSET-30 %s/%s uses strict required type" % [tab_name, slot_id])
		_assert_eq(String(snapshot["picker_base_type"]), expected_type, "ASSET-30 %s/%s picker base type is strict" % [tab_name, slot_id])
		_assert_true(not bool(snapshot["uses_generic_resource_filter"]), "ASSET-30 %s/%s does not use generic Resource" % [tab_name, slot_id])
		_assert_true(String(layout["status_tooltip"]).contains("Pick: %s" % expected_type), "ASSET-30 %s/%s tooltip says what to pick" % [tab_name, slot_id])
		if bool(layout.get("resource_picker_visible", false)):
			_assert_eq(String(layout["resource_picker_base_type"]), expected_type, "ASSET-30 %s/%s EditorResourcePicker base type is strict" % [tab_name, slot_id])

	var flexible_expectations: Array[Dictionary] = [
		{"tab": "Validate", "slot": HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE},
		{"tab": "QA", "slot": HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE},
		{"tab": "QA", "slot": HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE},
		{"tab": "Export", "slot": HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE},
	]
	for expectation in flexible_expectations:
		var tab_name := String(expectation["tab"])
		var slot_id := String(expectation["slot"])
		var snapshot = workspace.tab_asset_slot_snapshot(tab_name, slot_id)
		var layout = workspace.tab_asset_slot_layout_snapshot(tab_name, slot_id)
		_assert_eq(String(snapshot["required_type"]), "Resource", "ASSET-30 %s/%s remains flexible Resource by policy" % [tab_name, slot_id])
		_assert_true(bool(snapshot["uses_generic_resource_filter"]), "ASSET-30 %s/%s reports generic Resource filter" % [tab_name, slot_id])
		_assert_true(bool(snapshot["generic_resource_filter_allowed"]), "ASSET-30 %s/%s documents why generic Resource is allowed" % [tab_name, slot_id])
		_assert_true(String(snapshot["type_filter_reason"]).contains("no concrete"), "ASSET-30 %s/%s flexible reason is explicit" % [tab_name, slot_id])
		_assert_true(String(layout["status_tooltip"]).contains("Flexible Resource slot"), "ASSET-30 %s/%s tooltip carries flexible reason" % [tab_name, slot_id])

	workspace.queue_free()
	await process_frame


func _test_workspace_resource_purpose_tooltips_cover_resource_rows() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var expectations: Array[Dictionary] = [
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT},
		{"tab": "Catalog", "slot": HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG},
		{"tab": "Layers", "slot": HexMapWorkspaceAssetContext.SLOT_LAYER_STACK},
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE},
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE},
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE},
		{"tab": "QA", "slot": HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE},
		{"tab": "Validate", "slot": HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE},
		{"tab": "Export", "slot": HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE},
	]
	for expectation in expectations:
		var tab_name := String(expectation["tab"])
		var slot_id := String(expectation["slot"])
		var layout = workspace.tab_asset_slot_layout_snapshot(tab_name, slot_id)
		var tooltip := String(layout["status_tooltip"])
		var purpose := HexMapWorkspaceAssetResourceFactory.resource_purpose(slot_id)
		var expected_type := HexMapWorkspaceAssetResourceFactory.resource_type_name(slot_id)
		_assert_true(tooltip.contains("Pick: %s" % expected_type), "INFO-70 %s/%s tooltip explains pick type" % [tab_name, slot_id])
		_assert_true(tooltip.contains("Type: %s" % expected_type), "INFO-70 %s/%s tooltip includes type" % [tab_name, slot_id])
		_assert_true(tooltip.contains("Purpose: %s" % purpose), "INFO-70 %s/%s tooltip includes purpose" % [tab_name, slot_id])
		_assert_true(not String(layout["status_text"]).contains(purpose), "INFO-70 %s/%s keeps long purpose out of visible row text" % [tab_name, slot_id])
		var filter_reason := HexMapWorkspaceAssetResourceFactory.type_filter_reason(slot_id)
		if filter_reason != "":
			_assert_true(tooltip.contains("Filter: %s" % filter_reason), "INFO-70 %s/%s tooltip includes flexible filter reason" % [tab_name, slot_id])

	var catalog_snapshot = workspace.catalog_screen_snapshot()
	var tile_set_tooltip := String(catalog_snapshot["tile_set_tooltip"])
	_assert_true(tile_set_tooltip.contains("Pick: TileSet"), "INFO-70 Catalog TileSet tooltip explains pick type")
	_assert_true(tile_set_tooltip.contains("Type: TileSet"), "INFO-70 Catalog TileSet tooltip includes type")
	_assert_true(
		tile_set_tooltip.contains("Purpose: %s" % HexMapWorkspaceAssetResourceFactory.tile_set_purpose()),
		"INFO-70 Catalog TileSet tooltip includes purpose"
	)

	workspace.queue_free()
	await process_frame


func _test_workspace_tab_purpose_empty_states_route_to_project_actions() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var snapshots := {
		"Resources": workspace.resources_screen_snapshot(),
		"Paint": workspace.paint_brush_screen_snapshot(),
		"Catalog": workspace.catalog_screen_snapshot(),
		"Layers": workspace.layer_stack_screen_snapshot(),
		"Validate": workspace.validate_screen_snapshot(),
		"QA": workspace.qa_screen_snapshot(),
		"Export": workspace.export_screen_snapshot(),
		"Settings": workspace.settings_screen_snapshot(),
	}
	var production_tabs := PackedStringArray([
		"Resources",
		"Paint",
		"Catalog",
		"Layers",
		"Validate",
		"QA",
		"Export",
	])
	for tab_name in snapshots.keys():
		var snapshot = snapshots[tab_name] as Dictionary
		var empty_state = snapshot["empty_state"] as Dictionary
		var purpose := String(snapshot["purpose_text"])
		var empty_text := String(empty_state["empty_state_text"])
		var actions = empty_state["next_actions"] as PackedStringArray
		var help_tooltip := String(empty_state["help_tooltip"])
		_assert_true(purpose != "", "INFO-71 %s states tab purpose" % tab_name)
		_assert_eq(String(empty_state["purpose_text"]), purpose, "INFO-71 %s empty state mirrors purpose" % tab_name)
		_assert_eq(String(snapshot["empty_state_text"]), empty_text, "INFO-71 %s snapshot exposes empty text" % tab_name)
		_assert_true(empty_text != "", "INFO-71 %s has first-run empty-state text" % tab_name)
		_assert_true(actions.size() >= 1 and actions.size() <= 2, "INFO-71 %s has one or two next actions" % tab_name)
		_assert_eq(int(empty_state["next_action_count"]), actions.size(), "INFO-71 %s reports action count" % tab_name)
		_assert_true(help_tooltip != "", "INFO-71 %s keeps detailed help in tooltip" % tab_name)
		_assert_true(bool(empty_state["detail_help_in_tooltip"]), "INFO-71 %s detailed help stays out of primary text" % tab_name)
		_assert_true(not empty_text.contains(help_tooltip), "INFO-71 %s primary empty text does not inline tooltip detail" % tab_name)
		if production_tabs.has(String(tab_name)):
			var primary_text := ("%s %s" % [empty_text, " ".join(actions)]).to_lower()
			_assert_true(not primary_text.contains("sample"), "INFO-71 %s primary empty state does not use samples" % tab_name)
			_assert_true(not primary_text.contains("bundled"), "INFO-71 %s primary empty state does not use bundled assets" % tab_name)

	var resource_actions = (snapshots["Resources"] as Dictionary)["empty_state"]["next_actions"] as PackedStringArray
	_assert_true(resource_actions.has("Select a HexTileMap node"), "INFO-71 Resources next action points to node selection")
	var catalog_actions = (snapshots["Catalog"] as Dictionary)["empty_state"]["next_actions"] as PackedStringArray
	_assert_true(catalog_actions.has("Select or create a Tile Catalog"), "INFO-71 Catalog next action points to project catalog")
	var paint_actions = (snapshots["Paint"] as Dictionary)["empty_state"]["next_actions"] as PackedStringArray
	_assert_true(
		paint_actions.has("Select or create Level Document") or paint_actions.has("Select or create Tile Catalog"),
		"INFO-71 Paint next action points to project setup"
	)
	var export_actions = (snapshots["Export"] as Dictionary)["empty_state"]["next_actions"] as PackedStringArray
	_assert_true(export_actions.has("Select Level Document"), "INFO-71 Export next action includes document selection")
	_assert_true(export_actions.has("Choose Runtime Handoff destination"), "INFO-71 Export next action includes destination selection")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "INFO-71 empty states do not enable sample selector visibility")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "INFO-71 empty states do not inject generation sample catalog")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "INFO-71 empty states do not inject paint sample catalog")

	workspace.queue_free()
	await process_frame


func _test_workspace_asset_slot_actions_remove_redundant_buttons() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	for tab_name in workspace.workspace_tab_names():
		for slot_id in workspace.tab_asset_slot_ids(tab_name):
			var layout = workspace.tab_asset_slot_layout_snapshot(tab_name, String(slot_id))
			var action_texts = layout.get("action_button_texts", PackedStringArray()) as PackedStringArray
			_assert_true(not action_texts.has("Select..."), "ASSET-31 %s/%s removes Select action" % [tab_name, slot_id])
			_assert_true(not action_texts.has("Open"), "ASSET-31 %s/%s removes Open action" % [tab_name, slot_id])
			_assert_true(not action_texts.has("Clear"), "ASSET-31 %s/%s removes Clear action" % [tab_name, slot_id])
			_assert_true(not action_texts.has("Validate"), "ASSET-31 %s/%s removes Validate action" % [tab_name, slot_id])
			_assert_true(action_texts.has("Create New..."), "ASSET-31 %s/%s keeps Create New action" % [tab_name, slot_id])
			_assert_eq(String(layout.get("details_button_text", "")), "", "FB-02 %s/%s removes Details button text" % [tab_name, slot_id])
			_assert_true(not bool(layout.get("details_button_visible", false)), "FB-02 %s/%s hides Details button" % [tab_name, slot_id])

	workspace.queue_free()
	await process_frame


func _test_workspace_asset_remaining_actions_are_wired_or_deleted() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var output_dir = _test_resource_dir("asset32_remaining_actions")
	var catalog_path = "%s/action_catalog.tres" % output_dir
	var create_result = workspace.press_asset_slot_action(
		"Catalog",
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		HexMapEditorAssetSlotControl.ACTION_CREATE_NEW,
		{"path": catalog_path}
	)
	_assert_true(bool(create_result["ok"]), "ASSET-32 Create New button path succeeds")
	_assert_eq(int(create_result["error"]), OK, "ASSET-32 Create New button path reports OK")
	_assert_true(ResourceLoader.exists(catalog_path), "ASSET-32 Create New button path writes project resource")
	var created_catalog = workspace.workspace_asset_context().tile_catalog
	_assert_true(created_catalog is HexTileCatalogResource, "ASSET-32 Create New button path assigns Catalog context")
	_assert_eq(create_result["context_resource"], created_catalog, "ASSET-32 Create New button path returns context resource")
	var after_create = create_result["after"] as Dictionary
	_assert_eq(after_create["current_resource"], created_catalog, "ASSET-32 Create New button path refreshes row state")
	_assert_eq(String(after_create["current_source"]), HexMapEditorAssetSlotState.SOURCE_PROJECT, "ASSET-32 Create New button path records project source")
	_assert_eq(String(after_create["current_path"]), catalog_path, "ASSET-32 Create New button path records selected path")

	var panel = workspace.sample_settings_panel()
	_assert_true(not _has_button_text(panel, "Open"), "ASSET-32 Settings sample Open action is removed until functional")
	_assert_eq(Array(panel.snapshot()["sample_assets"]).size(), 3, "ASSET-32 Settings sample rows remain visible as learning assets")

	var sample_catalog = HexTileCatalogResource.new()
	var sample_state = HexMapEditorAssetSlotState.new()
	sample_state.configure(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "Tile Catalog", &"HexTileCatalogResource", true)
	sample_state.set_sample_source(sample_catalog, "res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres", "Bundled Sample Catalog")
	var sample_control = HexMapEditorAssetSlotControl.new()
	root.add_child(sample_control)
	sample_control.set_slot_state(sample_state)
	var sample_recorder = AssetSampleActionRecorder.new()
	sample_control.sample_requested.connect(Callable(sample_recorder, "record"))
	await process_frame

	var sample_result = sample_control.press_action(HexMapEditorAssetSlotControl.ACTION_APPLY_SAMPLE)
	_assert_true(bool(sample_result["ok"]), "ASSET-32 sample action button path succeeds")
	_assert_eq(sample_recorder.slots.size(), 1, "ASSET-32 sample action button path emits sample signal")
	_assert_eq(sample_recorder.slots[0], HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "ASSET-32 sample action signal includes slot id")
	var after_sample = sample_result["after"] as Dictionary
	_assert_eq(after_sample["current_resource"], sample_catalog, "ASSET-32 sample action button path selects sample resource")
	_assert_eq(String(after_sample["current_source"]), HexMapEditorAssetSlotState.SOURCE_SAMPLE, "ASSET-32 sample action button path records sample source")

	sample_control.queue_free()
	workspace.queue_free()
	await process_frame


func _test_sample_settings_duplicate_button_creates_project_catalog() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var panel = workspace.sample_settings_panel()
	_assert_true(_has_button_text(panel, "Duplicate To Project"), "SAMPLE-40 Settings shows functional duplicate action")
	_assert_true(not _has_button_text(panel, "Open"), "SAMPLE-40 Settings keeps Open removed without focus/preview target")
	var row_actions = panel.sample_action_rows_snapshot()
	_assert_eq(row_actions.size(), 3, "SAMPLE-40 sample action snapshot covers sample rows")
	_assert_true(
		(row_actions[0]["action_button_texts"] as PackedStringArray).has("Duplicate To Project"),
		"SAMPLE-40 catalog row exposes duplicate action"
	)
	_assert_eq(
		(row_actions[1]["action_button_texts"] as PackedStringArray).size(),
		0,
		"SAMPLE-40 tile texture row has no standalone duplicate action"
	)
	_assert_eq(
		(row_actions[2]["action_button_texts"] as PackedStringArray).size(),
		0,
		"SAMPLE-40 object scene row has no standalone duplicate action"
	)

	var output_dir = _test_resource_dir("sample40_settings_duplicate")
	var catalog_path = "%s/settings_sample_catalog.tres" % output_dir
	var result = panel.press_sample_action(
		HexMapSampleSettingsPanel.SAMPLE_CATALOG_ID,
		HexMapSampleSettingsPanel.ACTION_DUPLICATE_TO_PROJECT,
		{"path": catalog_path}
	)
	_assert_true(bool(result["ok"]), "SAMPLE-40 duplicate button path succeeds")
	_assert_eq(int(result["error"]), OK, "SAMPLE-40 duplicate button path reports OK")
	_assert_true(FileAccess.file_exists(String(result["catalog_path"])), "SAMPLE-40 duplicate button writes catalog")
	_assert_true(FileAccess.file_exists(String(result["texture_path"])), "SAMPLE-40 duplicate button copies texture")
	_assert_true(FileAccess.file_exists(String(result["scene_path"])), "SAMPLE-40 duplicate button copies scene")
	_assert_true(not _is_bundled_sample_asset_path(String(result["catalog_path"])), "SAMPLE-40 duplicate catalog is project-owned")
	_assert_true(not _is_bundled_sample_asset_path(String(result["texture_path"])), "SAMPLE-40 duplicate texture is project-owned")
	_assert_true(not _is_bundled_sample_asset_path(String(result["scene_path"])), "SAMPLE-40 duplicate scene is project-owned")

	var catalog = result["catalog"] as HexTileCatalogResource
	_assert_true(catalog is HexTileCatalogResource, "SAMPLE-40 duplicate returns catalog")
	_assert_eq(workspace.workspace_asset_context().tile_catalog, catalog, "SAMPLE-40 duplicate assigns workspace Catalog context")
	_assert_project_asset_slot(
		workspace,
		"Catalog",
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		catalog,
		catalog_path,
		"SAMPLE-40 duplicated sample Catalog slot"
	)
	_assert_eq(workspace.generation_dock().tile_catalog(), catalog, "SAMPLE-40 duplicate updates Generate catalog")
	_assert_eq(workspace.edit_tool().tile_catalog(), catalog, "SAMPLE-40 duplicate updates Paint catalog")
	var snapshot = panel.snapshot()
	var last_action = snapshot["last_sample_action"] as Dictionary
	_assert_true(bool(last_action["ok"]), "SAMPLE-40 panel snapshot records successful duplicate")
	_assert_eq(String(last_action["slot_id"]), HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "SAMPLE-40 panel snapshot records affected slot")
	_assert_true(String(snapshot["sample_status_text"]).contains(catalog_path), "SAMPLE-40 panel status shows changed catalog path")

	workspace.queue_free()
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
		HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE: "Resource",
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
	_assert_true(tool._object_variant_option != null, "map edit tool exposes object variant selector")
	_assert_true(tool._object_spawn_condition_edit != null, "map edit tool exposes object spawn condition control")
	_assert_true(tool._object_spawn_condition_option != null, "map edit tool exposes object spawn condition selector")
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
	_assert_true(plugin_source.contains("selection_changed"), "NODE-21 plugin listens for Scene Tree selection changes")
	_assert_true(plugin_source.contains("set_selected_hex_tile_map_node"), "NODE-21 plugin publishes selection into workspace")
	_assert_true(plugin_source.contains("HexTileMapLayer"), "NODE-21 plugin resolves selected HexTileMap nodes")
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
	var session = HexMapEditorSessionState.new()
	session.set_debug_numeric_tile_fallback_enabled(true, "test.debug_plain_target")
	var tool = await _new_ready_edit_tool()
	tool.set_editor_session_state(session)
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
	var session = HexMapEditorSessionState.new()
	session.set_debug_numeric_tile_fallback_enabled(true, "test.debug_plain_target")
	var tool = await _new_ready_edit_tool()
	tool.set_editor_session_state(session)
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
	var session = HexMapEditorSessionState.new()
	session.set_debug_numeric_tile_fallback_enabled(true, "test.debug_plain_target")
	var tool = await _new_ready_edit_tool()
	tool.set_editor_session_state(session)
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
	var session = HexMapEditorSessionState.new()
	session.set_debug_numeric_tile_fallback_enabled(true, "test.debug_plain_target")
	var tool = await _new_ready_edit_tool()
	tool.set_editor_session_state(session)
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
	door.set_meta("variant_options", ["closed", "open"])
	door.set_meta("spawn_condition_options", ["always", "on_interact"])
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
	var authoring_snapshot = tool.authoring_field_source_snapshot()
	_assert_true(bool((authoring_snapshot["object_variant"] as Dictionary).get("selector_visible", false)), "object variant uses selector")
	_assert_true(not bool((authoring_snapshot["object_variant"] as Dictionary).get("raw_text_visible", true)), "object variant raw text is hidden")
	_assert_true(
		PackedStringArray((authoring_snapshot["object_variant"] as Dictionary).get("options", PackedStringArray())).has("open"),
		"object variant selector uses definition enum options"
	)
	_assert_true(bool((authoring_snapshot["spawn_condition"] as Dictionary).get("selector_visible", false)), "spawn condition uses selector")
	_assert_true(not bool((authoring_snapshot["spawn_condition"] as Dictionary).get("raw_text_visible", true)), "spawn condition raw text is hidden")
	_assert_true(
		PackedStringArray((authoring_snapshot["spawn_condition"] as Dictionary).get("options", PackedStringArray())).has("on_interact"),
		"spawn condition selector uses definition enum options"
	)

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
	tool._object_variant_option.select(2)
	tool._on_object_variant_option_selected(2)
	tool._object_spawn_condition_option.select(2)
	tool._on_object_spawn_condition_option_selected(2)
	var properties = tool._object_payload["properties"]
	_assert_eq(properties["locked"], false, "typed bool editor updates placement property")
	_assert_eq(properties["health"], 12, "typed int editor updates placement property")
	_assert_eq(properties["speed"], 2.25, "typed float editor updates placement property")
	_assert_eq(properties["label"], "South", "typed string editor updates placement property")
	_assert_eq(properties["state"], "open", "typed enum editor updates placement property")
	_assert_eq(tool._object_payload["variant"], "open", "object variant selector updates payload")
	_assert_eq(tool._object_payload["spawn_condition"], "on_interact", "spawn condition selector updates payload")

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
	var session = HexMapEditorSessionState.new()
	session.set_debug_numeric_tile_fallback_enabled(true, "test.debug_plain_target")
	var tool = await _new_ready_edit_tool()
	tool.set_editor_session_state(session)
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
	_assert_true(not _control_row_visible(tool._overlay_item_key_edit), "overlay tile mode hides raw item key control")
	_assert_true(_control_row_visible(tool._overlay_item_key_option), "overlay tile mode shows item key selector")
	_assert_true(not _control_row_visible(tool._object_id_edit), "overlay tile mode hides object payload controls")

	tool.set_edit_mode(HexMapEditTool.EditMode.OBJECT)
	_assert_true(_control_row_visible(tool._object_catalog_option), "object mode shows object catalog key control")
	_assert_true(not _control_row_visible(tool._object_id_edit), "object mode hides raw object id control")
	_assert_true(_control_row_visible(tool._object_definition_tree), "object mode shows object definition list")
	_assert_true(_control_row_visible(tool._object_property_editor), "object mode shows typed object property editor")
	_assert_true(not _control_row_visible(tool._object_properties_edit), "object mode hides raw object properties text")
	_assert_true(_control_row_visible(tool._object_rotation_spin), "object mode shows object rotation control")
	_assert_true(not _control_row_visible(tool._object_variant_edit), "object mode hides raw object variant control")
	_assert_true(_control_row_visible(tool._object_variant_option), "object mode shows object variant selector")
	_assert_true(not _control_row_visible(tool._object_spawn_condition_edit), "object mode hides raw spawn condition control")
	_assert_true(_control_row_visible(tool._object_spawn_condition_option), "object mode shows spawn condition selector")
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


func _test_distribution_editor_file_dialogs_use_lifecycle_helper_contract() -> void:
	var editor = HexDistEditor.new()
	root.add_child(editor)
	await process_frame

	var save_config := editor.save_new_dialog_config()
	_assert_true(bool(save_config.get("uses_file_dialog", false)), "distribution Save New uses FileDialog contract")
	_assert_eq(int(save_config["file_mode"]), EditorFileDialog.FILE_MODE_SAVE_FILE, "distribution Save New dialog uses Save File mode")
	_assert_eq(String(save_config["current_file"]), "hex_dist.tres", "distribution Save New dialog uses default .tres file name")
	_assert_true(PackedStringArray(save_config["filters"]).has("*.tres ; Hex Distribution"), "distribution Save New dialog filters Hex Distribution resources")

	var load_config := editor.load_dialog_config()
	_assert_true(bool(load_config.get("uses_file_dialog", false)), "distribution Load uses FileDialog contract")
	_assert_eq(int(load_config["file_mode"]), EditorFileDialog.FILE_MODE_OPEN_FILE, "distribution Load dialog uses Open File mode")
	_assert_true(PackedStringArray(load_config["filters"]).has("*.tres ; Hex Distribution"), "distribution Load dialog filters Hex Distribution resources")

	_assert_eq(editor.save_new_dialog(), null, "distribution Save New dialog is not instantiated outside editor popup context")
	_assert_eq(editor.load_dialog(), null, "distribution Load dialog is not instantiated outside editor popup context")
	editor.queue_free()
	await process_frame


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
	await _wait_for_progress_status(dock, "Validating generated document", "Generate validation progress")
	await _wait_for_progress_status(dock, "Applying generated result", "Generate apply progress")
	await _wait_for_generation(dock, "Generate button generation")
	var ready_status = dock.generation_status()
	_assert_true(not ready_status["running"], "generation dock clears running state after Generate")
	_assert_true(not ready_status["cancel_requested"], "generation dock clears cancel request after Generate")
	_assert_eq(ready_status["progress"], 1.0, "generation dock reports completed progress")
	_assert_eq(ready_status["status"], "Ready", "generation dock reports ready status")
	_assert_eq(String(ready_status["step"]), HexMapGenDock.PROGRESS_STEP_COMPLETE, "PERF-61 generation status exposes complete step")
	var progress_snapshot = dock.generation_progress_snapshot()
	_assert_eq(String(progress_snapshot["current_step_text"]), "Ready", "PERF-61 progress snapshot exposes current step text")
	_assert_true(bool(progress_snapshot["progress_bar_visible"]), "PERF-61 progress snapshot exposes visible ProgressBar")
	_assert_true(not bool(progress_snapshot["cancel_available"]), "PERF-61 cancel is unavailable after synchronous apply/finalize")
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

	var layer = TileMapLayer.new()
	root.add_child(layer)
	await process_frame
	dock._current_data = HexMapData.rectangle(2, 1)
	dock._current_orientation = HexMapResource.ORIENTATION_FLAT_TOP
	dock._set_editor_selected_tile_map_layer_for_test(layer)
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(layer), "PERF-61 tile setting progress test configures display tiles")
	_assert_true(dock._apply_tile_settings_to_current_layer(), "PERF-61 tile setting apply succeeds")
	progress_snapshot = dock.generation_progress_snapshot()
	_assert_true(bool(progress_snapshot["visible"]), "PERF-61 tile setting apply shows inline progress")
	_assert_eq(String(progress_snapshot["status"]), "Tile settings applied", "PERF-61 tile setting apply reports completion")
	_assert_eq(String(progress_snapshot["step"]), HexMapGenDock.PROGRESS_STEP_COMPLETE, "PERF-61 tile setting completion uses complete step")
	_assert_true(not bool(progress_snapshot["cancel_available"]), "PERF-61 tile setting apply is not cancellable")
	_assert_eq(_window_child_count(dock), 0, "PERF-61 tile setting apply does not create modal busy window")

	var apply_count_before := int(dock.tile_settings_apply_debounce_snapshot()["apply_count"])
	dock._tile_settings_apply_debounce_sec = 0.01
	dock._on_tile_setting_changed(66.0)
	dock._on_tile_setting_changed(67.0)
	var debounce_snapshot = dock.tile_settings_apply_debounce_snapshot()
	_assert_true(bool(debounce_snapshot["pending"]), "PERF-62 repeated tile setting changes leave one pending apply")
	_assert_eq(int(debounce_snapshot["apply_count"]), apply_count_before, "PERF-62 pending debounced apply does not run immediately")
	_assert_eq(
		String((debounce_snapshot["progress"] as Dictionary)["status"]),
		"Tile settings update queued",
		"PERF-62 pending debounced apply reports queued progress"
	)
	await _wait_for_tile_settings_apply_count(dock, apply_count_before + 1, "PERF-62 debounced tile settings")
	debounce_snapshot = dock.tile_settings_apply_debounce_snapshot()
	_assert_true(not bool(debounce_snapshot["pending"]), "PERF-62 debounced tile setting apply clears pending state")
	_assert_eq(int(debounce_snapshot["apply_count"]), apply_count_before + 1, "PERF-62 repeated tile settings coalesce to one apply")
	_assert_eq(
		String((debounce_snapshot["progress"] as Dictionary)["status"]),
		"Tile settings applied",
		"PERF-62 debounced apply finishes through progress UI"
	)

	layer.queue_free()
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
	dock._tile_settings_apply_debounce_sec = 0.01
	var apply_count_before := int(dock.tile_settings_apply_debounce_snapshot()["apply_count"])
	dock._floor_atlas_x_spin.value = 1
	dock._wall_atlas_x_spin.value = 0
	_assert_true(bool(dock.tile_settings_apply_debounce_snapshot()["pending"]), "PERF-62 SpinBox changes queue debounced tile apply")
	await _wait_for_tile_settings_apply_count(dock, apply_count_before + 1, "target TileMapLayer debounced SpinBox apply")

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
	dock._tile_settings_apply_debounce_sec = 0.01
	var apply_count_before := int(dock.tile_settings_apply_debounce_snapshot()["apply_count"])
	dock._tile_width_spin.value = 96
	_assert_true(bool(dock.tile_settings_apply_debounce_snapshot()["pending"]), "PERF-62 TileSet size change queues debounced tile apply")
	await _wait_for_tile_settings_apply_count(dock, apply_count_before + 1, "shared TileSet debounced size apply")

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


func _test_generation_dock_output_target_preview_and_selected_document() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var scene_root = Node2D.new()
	scene_root.name = "OutputTargetScene"
	root.add_child(scene_root)
	var layer = HexTileMapLayer.new()
	layer.name = "OutputTargetHexTileMap"
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	layer.level_document_resource = document
	scene_root.add_child(layer)
	await process_frame

	workspace.set_selected_hex_tile_map_node(layer, "test.node24.select")
	var dock = workspace.generation_dock()
	dock.refresh_tile_layer_options(scene_root)
	dock._tile_layer_option.select(1)
	dock._on_tile_layer_target_selected(1)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._seed_spin.set_value_no_signal(2401)
	dock._refresh_controls()

	var initial_output = dock.output_target_snapshot()
	_assert_true(dock._output_target_option != null, "NODE-24 Generate exposes Output target option")
	_assert_eq(String(initial_output["mode"]), HexMapGenDock.OUTPUT_TARGET_PREVIEW_ONLY, "NODE-24 preview only is the default output target")
	_assert_eq(String(initial_output["label"]), "Preview only", "NODE-24 preview target label is visible")
	_assert_true(not bool(initial_output["generated_document_present"]), "NODE-24 starts without generated output")

	_assert_true(await dock._generate_map(), "NODE-24 preview output generation succeeds")
	_assert_true(layer.hex_map is HexMapResource, "NODE-24 preview writes runtime HexTileMap map")
	_assert_eq(layer.display_used_cell_count(), 2, "NODE-24 preview updates selected HexTileMap display")
	_assert_eq(HexMapDocumentAdapter.document_summary(document)["cells"], 1, "NODE-24 preview leaves Level Document unchanged")
	_assert_eq(layer.level_document_resource, document, "NODE-24 preview keeps selected node document reference")
	var preview_output = dock.output_target_snapshot()
	_assert_true(bool(preview_output["generated_document_present"]), "NODE-24 preview snapshot records generated output")
	_assert_true(not bool((preview_output["document_generation_metadata"] as Dictionary)["present"]), "NODE-24 preview does not mark document generated")

	dock.set_output_target_mode(HexMapGenDock.OUTPUT_TARGET_SELECTED_DOCUMENT)
	var ready_output = dock.output_target_snapshot()
	_assert_eq(String(ready_output["label"]), "Apply to selected Document", "NODE-24 selected document output target is visible")
	_assert_true(bool(ready_output["can_apply_selected_document"]), "NODE-24 selected document output can apply when node/document/generated output exist")
	var apply_result = dock.apply_current_generation_to_selected_document()
	_assert_true(bool(apply_result["ok"]), "NODE-24 applies current generation to selected document")
	_assert_eq(HexMapDocumentAdapter.document_summary(document)["cells"], 2, "NODE-24 apply replaces selected Level Document terrain")
	_assert_eq(workspace.workspace_asset_context().level_document, document, "NODE-24 apply updates workspace Level Document relationship")
	_assert_eq(session.current_document(), document, "NODE-24 apply updates session current document")
	var metadata = (dock.output_target_snapshot()["document_generation_metadata"] as Dictionary)
	_assert_true(bool(metadata["present"]), "NODE-24 apply records generated metadata on document")
	_assert_eq(String(metadata["generation_source"]), "hex_map_gen_dock", "NODE-24 apply records Generate as metadata source")
	_assert_eq(String(metadata["generation_output_target"]), HexMapGenDock.OUTPUT_TARGET_SELECTED_DOCUMENT, "NODE-24 apply records output target metadata")
	_assert_eq(int(metadata["generation_seed"]), 2401, "NODE-24 apply records generation seed metadata")
	_assert_true((metadata["generation_snapshot"] as Dictionary).has("rect_width"), "NODE-24 apply records generation snapshot metadata")

	var writeback = workspace.selected_hex_tile_map_writeback_snapshot()
	var relationships = writeback["relationships"] as Dictionary
	var document_relationship = relationships[HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT] as Dictionary
	_assert_eq(String(document_relationship["status"]), "linked", "NODE-24 Resources relationship remains linked after apply")
	var relationship_metadata = document_relationship["generation_metadata"] as Dictionary
	_assert_true(bool(relationship_metadata["present"]), "NODE-24 Resources relationship exposes generated metadata")
	_assert_eq(String(relationship_metadata["generation_output_target"]), HexMapGenDock.OUTPUT_TARGET_SELECTED_DOCUMENT, "NODE-24 Resources relationship classifies generated output target")

	workspace.clear_selected_hex_tile_map_layer("test.node24.clear")
	var blocked = dock.apply_current_generation_to_selected_document()
	_assert_true(not bool(blocked["ok"]), "NODE-24 apply blocks without selected HexTileMap")
	_assert_eq(String(blocked["blocked_reason"]), "No HexTileMap selected", "NODE-24 no selected node reason is visible")
	_assert_eq(String(dock.output_target_snapshot()["blocked_reason"]), "No HexTileMap selected", "NODE-24 output target snapshot keeps no-selection reason")

	scene_root.queue_free()
	workspace.queue_free()
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
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE, HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE, HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE:
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
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE, HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE, HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE:
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
