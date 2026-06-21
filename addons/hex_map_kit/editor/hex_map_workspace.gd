@tool
class_name HexMapWorkspace
extends VBoxContainer

const HexMapEditorSessionState = preload("res://addons/hex_map_kit/editor/hex_map_editor_session_state.gd")
const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapDocumentDependencyService = preload("res://addons/hex_map_kit/adapter/hex_map_document_dependency_service.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapDocumentValidator = preload("res://addons/hex_map_kit/adapter/hex_map_document_validator.gd")
const HexMapValidationResult = preload("res://addons/hex_map_kit/adapter/hex_map_validation_result.gd")
const HexLayerStackResource = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd")
const HexLabelDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_label_database_resource.gd")
const HexLabelDefinitionResource = preload("res://addons/hex_map_kit/adapter/hex_label_definition_resource.gd")
const HexGenerationProfileResource = preload("res://addons/hex_map_kit/adapter/hex_generation_profile_resource.gd")
const HexObjectDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_object_database_resource.gd")
const HexObjectDefinitionResource = preload("res://addons/hex_map_kit/adapter/hex_object_definition_resource.gd")
const HexExportProfileResource = preload("res://addons/hex_map_kit/adapter/hex_export_profile_resource.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")
const HexValidationRuleSuiteResource = preload("res://addons/hex_map_kit/adapter/hex_validation_rule_suite_resource.gd")
const HexGenerationGraphResource = preload("res://addons/hex_map_kit/adapter/hex_generation_graph_resource.gd")
const HexMapEditorPathSelector = preload("res://addons/hex_map_kit/editor/hex_map_editor_path_selector.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")
const HexMapGenDock = preload("res://addons/hex_map_kit/editor/hex_map_gen_dock.gd")
const HexMapEditTool = preload("res://addons/hex_map_kit/editor/hex_map_edit_tool.gd")
const HexMapCatalogEditorComponent = preload("res://addons/hex_map_kit/editor/hex_map_catalog_editor_component.gd")
const HexMapSampleSettingsPanel = preload("res://addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd")
const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")
const HexMapWorkspaceAssetPanel = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_panel.gd")
const HexMapWorkspaceAssetResourceFactory = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_resource_factory.gd")
const HexMapWorkspaceBindingService = preload("res://addons/hex_map_kit/editor/hex_map_workspace_binding_service.gd")
const HexMapWorkspaceComponentRegistry = preload("res://addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd")
const HexMapGraphInstantiator = preload("res://addons/hex_map_kit/editor/hex_map_graph_instantiator.gd")
const HexMapResourcesScreen = preload("res://addons/hex_map_kit/editor/hex_map_resources_screen.gd")
const HexMapCatalogScreen = preload("res://addons/hex_map_kit/editor/hex_map_catalog_screen.gd")
const HexMapLayersScreen = preload("res://addons/hex_map_kit/editor/hex_map_layers_screen.gd")
const HexMapValidateScreen = preload("res://addons/hex_map_kit/editor/hex_map_validate_screen.gd")
const HexMapQAScreen = preload("res://addons/hex_map_kit/editor/hex_map_qa_screen.gd")
const HexMapExportScreen = preload("res://addons/hex_map_kit/editor/hex_map_export_screen.gd")
const HexMapPaintScreen = preload("res://addons/hex_map_kit/editor/hex_map_paint_screen.gd")
const HexMapSettingsScreen = preload("res://addons/hex_map_kit/editor/hex_map_settings_screen.gd")
const HexMapBuildScreen = preload("res://addons/hex_map_kit/editor/hex_map_build_screen.gd")
const HexMapPreviewThumbnail = preload("res://addons/hex_map_kit/editor/hex_map_preview_thumbnail.gd")
const HexTileCatalogPreviewControl = preload("res://addons/hex_map_kit/editor/hex_tile_catalog_preview_control.gd")
const HexMapValidationDashboard = preload("res://addons/hex_map_kit/editor/hex_map_validation_dashboard.gd")
const HexMapValidationWorkflowState = preload("res://addons/hex_map_kit/editor/hex_map_validation_workflow_state.gd")
const HexMapExportWorkflowState = preload("res://addons/hex_map_kit/editor/hex_map_export_workflow_state.gd")
const HexMapSampleLearningState = preload("res://addons/hex_map_kit/editor/hex_map_sample_learning_state.gd")
const HexMapWorkspaceRootState = preload("res://addons/hex_map_kit/editor/hex_map_workspace_root_state.gd")
const HexMapWorkspaceDispatcher = preload("res://addons/hex_map_kit/editor/hex_map_workspace_dispatcher.gd")

const LAYER_ROLE_WRITABLE_SOURCES := ["document", "target", "generated", "readonly"]

var _editor_session_state: HexMapEditorSessionState = null
var _tabs: TabContainer
var _sample_learning_cta: HBoxContainer
var _learn_samples_button: Button
var _dismiss_samples_button: Button
var _selected_hex_tile_map_context: HBoxContainer
var _selected_hex_tile_map_status_label: Label
var _selected_hex_tile_map_auto_link_label: Label
var _resources_context_panel: VBoxContainer
var _resources_context_status_label: Label
var _resources_shelf_status_label: Label
var _resources_readiness_label: Label
var _resources_context_next_actions_label: Label
var _resources_source_badges_label: Label
var _resources_group_labels: Dictionary = {}
var _catalog_detail_panel: VBoxContainer
var _catalog_board_status_label: Label
var _catalog_board_grid: GridContainer
var _catalog_empty_cta_label: Label
var _catalog_detail_status_label: Label
var _catalog_detail_entry_label: Label
var _catalog_detail_preview_control: HexTileCatalogPreviewControl
var _catalog_detail_preview_badge_label: Label
var _selected_catalog_entry_key := ""
var _layer_stack_role_panel: VBoxContainer
var _layer_stack_visual_status_label: Label
var _layer_stack_visual_stack: VBoxContainer
var _layer_stack_visual_empty_cta_label: Label
var _layer_stack_role_status_label: Label
var _layer_stack_role_relationship_label: Label
var _layer_stack_role_tree_summary_label: Label
var _layer_stack_role_rows_label: Label
var _layer_stack_role_editor_summary_label: Label
var _layer_stack_role_editor_role_option: OptionButton
var _layer_stack_role_editor_visible_check: CheckBox
var _layer_stack_role_editor_locked_check: CheckBox
var _layer_stack_role_editor_z_index_spin: SpinBox
var _layer_stack_role_editor_writable_option: OptionButton
var _selected_layer_stack_editor_role := ""
var _updating_layer_role_editor_controls := false
var _missing_unique_resources_panel: VBoxContainer
var _missing_unique_resources_status_label: Label
var _missing_unique_resources_save_directory_label: Label
var _missing_unique_resources_prefix_edit: LineEdit
var _missing_unique_resources_choose_directory_button: Button
var _missing_unique_resources_create_button: Button
var _resources_save_all_button: Button
var _missing_unique_resources_save_directory := ""
var _build_screen: HexMapBuildScreen
var _generation_dock: HexMapGenDock
var _pending_graph_load_overwrite := false
var _last_graph_load_result: Dictionary = {}
var _edit_tool: HexMapEditTool
var _sample_settings_panel: HexMapSampleSettingsPanel
var _validation_issue_navigator: VBoxContainer
var _validation_run_button: Button
var _validation_issue_status_label: Label
var _validation_issue_selected_label: Label
var _validation_issue_rows_label: Label
var _selected_validate_issue_index := -1
var _selected_validate_issue_row: Dictionary = {}
var _selected_validate_issue_navigation: Dictionary = {}
var _qa_seed_lab_panel: VBoxContainer
var _qa_seed_lab_status_label: Label
var _qa_seed_lab_selected_label: Label
var _qa_seed_lab_selected_thumbnail: HexMapPreviewThumbnail
var _qa_seed_lab_score_tree: Tree
var _qa_seed_lab_rows_label: Label
var _qa_selected_seed_row: Dictionary = {}
var _qa_promoted_document: HexMapDocumentResource = null
var _export_purpose_panel: VBoxContainer
var _export_purpose_status_label: Label
var _export_runtime_handoff_summary_label: Label
var _export_purpose_card_buttons: Dictionary = {}
var _export_purpose_mode_label: Label
var _export_purpose_backlog_label: Label
var _export_secondary_action_buttons: Dictionary = {}
var _export_destination_panel: VBoxContainer
var _export_destination_label: Label
var _export_recent_destinations_label: Label
var _export_choose_destination_button: Button
var _export_use_recent_button: Button
var _export_run_button: Button
var _settings_preferences_panel: VBoxContainer
var _settings_preferences_status_label: Label
var _settings_preferences_debug_label: Label
var _settings_preferences_resource_label: Label
var _asset_panels: Dictionary = {}
var _tab_components: Dictionary = {}
var _tab_pages: Dictionary = {}
var _tab_scroll_roots: Dictionary = {}
var _last_workspace_validation_result: HexMapValidationResult = null
var _last_export_action_result: Dictionary = {}
var _validation_workflow_state: HexMapValidationWorkflowState = HexMapValidationWorkflowState.new()
var _last_validation_progress_state: Dictionary = {}
var _export_workflow_state: HexMapExportWorkflowState = HexMapExportWorkflowState.new()
var _workspace_root_state: HexMapWorkspaceRootState = HexMapWorkspaceRootState.new()
var _hydrating_document_dependencies := false
var _last_document_dependency_hydration := {}


func _ready() -> void:
	name = "Hex Map Workspace"
	_build_ui()


func set_editor_session_state(session: HexMapEditorSessionState) -> void:
	if _editor_session_state != null and _editor_session_state.changed.is_connected(_on_session_state_changed):
		_editor_session_state.changed.disconnect(_on_session_state_changed)
	_editor_session_state = session
	_connect_session_state()
	if _generation_dock != null:
		_generation_dock.set_editor_session_state(_ensure_session_state())
	if _build_screen != null:
		_build_screen.set_workspace_asset_context(workspace_asset_context())
	if _edit_tool != null:
		_edit_tool.set_editor_session_state(_ensure_session_state())
	if _sample_settings_panel != null:
		_sample_settings_panel.set_editor_session_state(_ensure_session_state())
	_refresh_sample_learning_cta()
	_refresh_selected_hex_tile_map_context()
	_sync_workspace_asset_context()


func editor_session_state() -> HexMapEditorSessionState:
	return _ensure_session_state()


func set_workspace_asset_context(context: HexMapWorkspaceAssetContext) -> void:
	_ensure_session_state().set_workspace_asset_context(context, "workspace.set_asset_context")
	_sync_workspace_asset_context()


func workspace_asset_context() -> HexMapWorkspaceAssetContext:
	return _ensure_session_state().current_workspace_asset_context()


func hydrate_workspace_context_from_document_dependencies(document: HexMapDocumentResource = null) -> Dictionary:
	return _hydrate_workspace_context_from_document_dependencies(document)


func workspace_asset_context_for_tab(tab_name: String) -> HexMapWorkspaceAssetContext:
	var actual_tab := _canonical_tab_name(tab_name)
	if not HexMapWorkspaceComponentRegistry.tab_names().has(actual_tab):
		return null
	return workspace_asset_context()


func generation_dock() -> HexMapGenDock:
	return _generation_dock


func build_screen() -> HexMapBuildScreen:
	return _build_screen


func edit_tool() -> HexMapEditTool:
	return _edit_tool


func sample_settings_panel() -> HexMapSampleSettingsPanel:
	return _sample_settings_panel


func settings_screen_snapshot() -> Dictionary:
	var sample_snapshot := {}
	if _sample_settings_panel != null:
		sample_snapshot = _sample_settings_panel.snapshot()
	var sample_state := _workspace_sample_state_snapshot(sample_snapshot)
	var settings_slot_ids := tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_SETTINGS)
	var resources_slot_ids := tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_DOCUMENT)
	var empty_state := _settings_tab_empty_state()
	var screen_role := HexMapSettingsScreen.screen_contract()
	var settings_groups := HexMapSettingsScreen.settings_group_rows(sample_snapshot)
	var settings_group_ids := _settings_group_ids(settings_groups)
	var boolean_controls = sample_snapshot.get("boolean_controls", []) as Array
	return {
		"tab": HexMapWorkspaceComponentRegistry.TAB_SETTINGS,
		"screen_role_source": String(screen_role.get("screen_role_source", "")),
		"screen_script": String(screen_role.get("screen_script", "")),
		"workflow_owner": String(screen_role.get("workflow_owner", "Settings")),
		"user_task": String(screen_role.get("user_task", "")),
		"owned_sections": screen_role.get("owns", PackedStringArray()),
		"delegates": screen_role.get("delegates", {}),
		"component_ids": tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_SETTINGS),
		"asset_slot_ids": settings_slot_ids,
		"purpose_text": String(empty_state.get("purpose_text", "")),
		"empty_state": empty_state,
		"empty_state_text": String(empty_state.get("empty_state_text", "")),
		"sample_learning_controls_present": _sample_settings_panel != null,
		"sample_state": sample_state,
		"sample_view_state": sample_state.get("view_state", {}),
		"sample_detail_drawer": sample_snapshot.get("sample_detail_drawer", {}),
		"sample_detail_rows": sample_snapshot.get("sample_detail_rows", []),
		"sample_detail_visible": bool(sample_snapshot.get("sample_detail_visible", false)),
		"mounted_sample_detail_text": String(sample_snapshot.get("mounted_sample_detail_text", "")),
		"settings_groups": settings_groups,
		"settings_group_ids": settings_group_ids,
		"settings_groups_separated": _settings_groups_separated(settings_groups),
		"sample_learning_group_present": settings_group_ids.has(HexMapSettingsScreen.GROUP_SAMPLE_LEARNING),
		"debug_group_present": settings_group_ids.has(HexMapSettingsScreen.GROUP_DEBUG),
		"project_defaults_group_present": settings_group_ids.has(HexMapSettingsScreen.GROUP_PROJECT_DEFAULTS),
		"ui_preferences_group_present": settings_group_ids.has(HexMapSettingsScreen.GROUP_UI_PREFERENCES),
		"sample_settings_groups": sample_snapshot.get("settings_groups", []),
		"boolean_controls": boolean_controls,
		"boolean_control_count": boolean_controls.size(),
		"boolean_controls_use_checkboxes": _settings_boolean_controls_use_type(boolean_controls, "CheckBox"),
		"boolean_controls_have_tooltips": _settings_boolean_controls_have_tooltips(boolean_controls),
		"sample_asset_count": (sample_snapshot.get("sample_assets", []) as Array).size(),
		"sample_actions_work_or_removed": _settings_sample_actions_work_or_removed(sample_snapshot),
		"debug_numeric_fallback_isolated": _sample_settings_panel != null and settings_slot_ids.is_empty(),
		"debug_numeric_tile_fallback_enabled": bool(sample_snapshot.get("debug_numeric_tile_fallback_enabled", false)),
		"settings_debug_label_visible": _settings_preferences_debug_label != null and _settings_preferences_debug_label.visible,
		"settings_debug_label_text": _settings_preferences_debug_label.text if _settings_preferences_debug_label != null else "",
		"boolean_state_text_visible": false,
		"debug_payload_visible_in_normal_ui": false,
		"sample_asset_paths_visible": bool(sample_snapshot.get("sample_asset_paths_visible", false)),
		"sample_status_path_visible": bool(sample_snapshot.get("sample_status_path_visible", false)),
		"production_asset_selection_present": not settings_slot_ids.is_empty(),
		"movement_profile_slot_owner": HexMapWorkspaceComponentRegistry.TAB_DOCUMENT \
			if resources_slot_ids.has(HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE) else "",
		"resources_tab_asset_slot_ids": resources_slot_ids,
	}


func validation_workflow_state_snapshot(running: bool = false) -> Dictionary:
	_sync_validation_workflow_state(running)
	return _validation_workflow_state.to_state_snapshot()


func export_workflow_state_snapshot(exporting: bool = false) -> Dictionary:
	_sync_export_workflow_state(exporting)
	return _export_workflow_state.to_state_snapshot()


func sample_learning_state_snapshot() -> Dictionary:
	return _workspace_sample_state_snapshot(_sample_settings_panel.snapshot() if _sample_settings_panel != null else {})


func workspace_root_state_snapshot() -> Dictionary:
	_sync_workspace_root_state()
	return _workspace_root_state.to_state_snapshot()


func workspace_root_view_state() -> Dictionary:
	_sync_workspace_root_state()
	return _workspace_root_state.to_view_state()


func workspace_state_debug_report_text() -> String:
	_sync_workspace_root_state()
	return _workspace_root_state.debug_report_text()


func dispatch_workspace_event(event_id: String, payload: Dictionary = {}) -> Dictionary:
	return HexMapWorkspaceDispatcher.dispatch(self, event_id, payload)


func generation_screen_snapshot() -> Dictionary:
	if _build_screen != null:
		var build_snapshot := _build_screen.build_screen_snapshot()
		var legacy_view_state: Dictionary = _generation_dock.generation_run_view_state() if _generation_dock != null else {}
		var legacy_generation_state: Dictionary = _generation_dock.generation_status() if _generation_dock != null else {}
		var legacy_progress_state: Dictionary = _generation_dock.generation_progress_snapshot() if _generation_dock != null else {}
		var legacy_output_target: Dictionary = _generation_dock.output_target_snapshot() if _generation_dock != null else {}
		var legacy_layout_snapshot: Dictionary = _generation_dock.generation_layout_snapshot() if _generation_dock != null else {}
		build_snapshot["tab"] = HexMapWorkspaceComponentRegistry.TAB_GENERATE
		build_snapshot["component_ids"] = tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_GENERATE)
		build_snapshot["asset_slot_ids"] = tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_GENERATE)
		build_snapshot["purpose_text"] = "Build a generation graph and inspect node outputs."
		var build_context_chips := _work_tab_context_chips(HexMapWorkspaceComponentRegistry.TAB_GENERATE)
		build_snapshot["context_chips"] = build_context_chips
		build_snapshot["context_chips_visible"] = true
		build_snapshot["context_chips_text"] = _join_text(build_context_chips, " ")
		build_snapshot["context_chips_detail_target"] = HexMapWorkspaceComponentRegistry.TAB_DOCUMENT
		build_snapshot["global_map_chip_duplicated"] = false
		build_snapshot["resource_row_primary"] = false
		build_snapshot["empty_state"] = _tab_empty_state(
			HexMapWorkspaceComponentRegistry.TAB_GENERATE,
			"Build a generation graph and inspect node outputs.",
			"",
			PackedStringArray(),
			"Build is the generation graph work surface. Simple generation remains a secondary entry."
		)
		build_snapshot["empty_state_text"] = ""
		build_snapshot["empty_state_visible"] = false
		build_snapshot["unexplained_empty_area_visible"] = false
		build_snapshot["empty_area_explained"] = true
		build_snapshot["generation_state"] = legacy_generation_state
		build_snapshot["progress_state"] = legacy_progress_state
		build_snapshot["output_target"] = legacy_output_target
		build_snapshot["candidate_preview"] = legacy_output_target.get("candidate_preview", {})
		build_snapshot["layout"] = legacy_layout_snapshot
		build_snapshot["layout_sections"] = legacy_layout_snapshot.get("sections", [])
		build_snapshot["generate_layout_section_ids"] = legacy_layout_snapshot.get("section_ids", PackedStringArray())
		build_snapshot["result_summary"] = _generation_result_summary(
			legacy_view_state,
			legacy_generation_state,
			legacy_progress_state,
			legacy_output_target
		)
		build_snapshot["legacy_view_state"] = legacy_view_state
		build_snapshot["graph_load_result"] = _last_graph_load_result.duplicate(true)
		build_snapshot["view_state"] = {
			"state_source": "HexMapBuildScreen",
			"state_id": "graph_canvas_ready",
			"status_text": String(build_snapshot.get("status_text", "")),
			"component_ids": build_snapshot["component_ids"],
			"asset_slot_ids": build_snapshot["asset_slot_ids"],
		}
		return build_snapshot
	var view_state: Dictionary = _generation_dock.generation_run_view_state() if _generation_dock != null else {}
	var generation_state: Dictionary = _generation_dock.generation_status() if _generation_dock != null else {}
	var progress_state: Dictionary = _generation_dock.generation_progress_snapshot() if _generation_dock != null else {}
	var output_target: Dictionary = _generation_dock.output_target_snapshot() if _generation_dock != null else {}
	var layout_snapshot: Dictionary = _generation_dock.generation_layout_snapshot() if _generation_dock != null else {}
	var empty_text := String(view_state.get("block_reason", ""))
	var actions := PackedStringArray()
	if empty_text != "":
		actions.append("Configure generation inputs")
	var empty_state := _tab_empty_state(
		HexMapWorkspaceComponentRegistry.TAB_GENERATE,
		"Generate a candidate Level Document from configured map settings.",
		empty_text,
		actions,
		"Generate previews and applies one candidate. QA compares multiple seeds before promotion."
	)
	return {
		"tab": HexMapWorkspaceComponentRegistry.TAB_GENERATE,
		"component_ids": tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_GENERATE),
		"asset_slot_ids": tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_GENERATE),
		"context_chips": _work_tab_context_chips(HexMapWorkspaceComponentRegistry.TAB_GENERATE),
		"context_chips_visible": true,
		"context_chips_text": _join_text(_work_tab_context_chips(HexMapWorkspaceComponentRegistry.TAB_GENERATE), " "),
		"context_chips_detail_target": HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"global_map_chip_duplicated": false,
		"resource_row_primary": false,
		"purpose_text": String(empty_state.get("purpose_text", "")),
		"empty_state": empty_state,
		"empty_state_text": String(empty_state.get("empty_state_text", "")),
		"empty_state_visible": bool(empty_state.get("visible", false)),
		"unexplained_empty_area_visible": false,
		"empty_area_explained": empty_text != "" or not bool(empty_state.get("visible", false)),
		"generation_state": generation_state,
		"progress_state": progress_state,
		"output_target": output_target,
		"candidate_preview": output_target.get("candidate_preview", {}),
		"layout": layout_snapshot,
		"layout_sections": layout_snapshot.get("sections", []),
		"generate_layout_section_ids": layout_snapshot.get("section_ids", PackedStringArray()),
		"result_summary": _generation_result_summary(view_state, generation_state, progress_state, output_target),
		"view_state": view_state,
	}


func _generation_result_summary(
	view_state: Dictionary,
	generation_state: Dictionary,
	progress_state: Dictionary,
	output_target: Dictionary
) -> Dictionary:
	var visible_text := String(output_target.get("visible_status_text", ""))
	if visible_text == "":
		visible_text = "Preview: none | Document: waiting for preview | Save: waiting for preview"
	var block_reason := String(view_state.get("block_reason", ""))
	var apply_reason := String(output_target.get("blocked_reason", ""))
	var save_result = output_target.get("save_result", {}) as Dictionary
	return {
		"visible": true,
		"visible_text": visible_text,
		"run_status": String(generation_state.get("status", "")),
		"run_progress_visible": bool(progress_state.get("visible", false)),
		"block_reason_visible": block_reason != "",
		"block_reason": block_reason,
		"preview_result_state": String(output_target.get("preview_result_state", "empty")),
		"apply_result_state": String(output_target.get("document_result_state", "waiting_for_preview")),
		"document_result_state": String(output_target.get("document_result_state", "waiting_for_preview")),
		"save_result_state": String(output_target.get("save_result_state", "waiting_for_preview")),
		"save_available": bool(output_target.get("save_available", false)),
		"last_save_ok": bool(save_result.get("ok", false)),
		"apply_block_reason_visible": apply_reason != "",
		"apply_block_reason": apply_reason,
		"output_target_label": String(output_target.get("label", "")),
	}


func current_workspace_tab_name() -> String:
	if _tabs == null or _tabs.get_tab_count() == 0:
		return ""
	return _tabs.get_tab_title(_tabs.current_tab)


func select_workspace_tab(tab_name: String) -> bool:
	if _tabs == null:
		return false
	var actual_tab := _canonical_tab_name(tab_name)
	for index in range(_tabs.get_tab_count()):
		if _tabs.get_tab_title(index) == actual_tab:
			_tabs.current_tab = index
			return true
	return false


func open_sample_learning_cta() -> void:
	_ensure_session_state().dismiss_sample_learning_cta("workspace.sample_learning_cta.open")
	select_workspace_tab(HexMapWorkspaceComponentRegistry.TAB_SETTINGS)
	_refresh_sample_learning_cta()


func dismiss_sample_learning_cta() -> void:
	_ensure_session_state().dismiss_sample_learning_cta("workspace.sample_learning_cta.dismiss")
	_refresh_sample_learning_cta()


func sample_learning_cta_visible() -> bool:
	return _sample_learning_cta != null and _sample_learning_cta.visible


func sample_learning_cta_snapshot() -> Dictionary:
	var session := _ensure_session_state()
	var sample_state := sample_learning_state_snapshot()
	return {
		"visible": sample_learning_cta_visible(),
		"dismissed": session.sample_learning_cta_dismissed,
		"selected_tab": current_workspace_tab_name(),
		"learn_label": _learn_samples_button.text if _learn_samples_button != null else "",
		"sample_state": sample_state,
		"view_state": sample_state.get("view_state", {}),
	}


func _workspace_sample_state_snapshot(sample_snapshot: Dictionary) -> Dictionary:
	var state := HexMapSampleLearningState.new()
	state.update_from_context({
		"show_samples": bool(sample_snapshot.get("show_bundled_samples_in_main_selectors", false)),
		"learning_cta_visible": sample_learning_cta_visible(),
		"last_sample_action": sample_snapshot.get("last_sample_action", {}),
		"sample_source_selected_slots": _sample_source_selected_slots(),
	})
	return state.to_state_snapshot()


func _sample_source_selected_slots() -> PackedStringArray:
	var slots := PackedStringArray()
	var context := workspace_asset_context()
	for slot_id in HexMapWorkspaceAssetContext.asset_slot_ids():
		if context.asset_source(slot_id) == HexMapWorkspaceAssetContext.SOURCE_SAMPLE:
			slots.append(slot_id)
	return slots


func _sync_validation_workflow_state(running: bool = false) -> void:
	if _validation_workflow_state == null:
		_validation_workflow_state = HexMapValidationWorkflowState.new()
	var issue_count := 0
	var error_count := 0
	var warning_count := 0
	if _last_workspace_validation_result != null:
		issue_count = _last_workspace_validation_result.issue_count()
		error_count = _last_workspace_validation_result.error_count()
		warning_count = _last_workspace_validation_result.warning_count()
	_validation_workflow_state.update_from_context({
		"running": running,
		"result_present": _last_workspace_validation_result != null,
		"issue_count": issue_count,
		"error_count": error_count,
		"warning_count": warning_count,
		"selected_issue_index": _selected_validate_issue_index,
		"selected_issue_row": _selected_validate_issue_row,
		"selected_issue_navigation": _selected_validate_issue_navigation,
		"focus_applied": _selected_validate_issue_index >= 0 and not _selected_validate_issue_navigation.is_empty(),
		"progress_state": _validation_progress_state_for_workflow(running),
	})


func _validation_progress_state_for_workflow(running: bool) -> Dictionary:
	if _last_validation_progress_state.is_empty():
		return {
			"phase": "",
			"phase_text": "",
			"step": 0,
			"steps": 0,
			"progress": 0.0,
			"event_count": 0,
			"running": running,
			"visible": running,
			"cells": 0,
			"tile_entries": 0,
			"objects": 0,
			"dependencies": 0,
			"errors": 0,
			"warnings": 0,
		}
	var progress_state := _last_validation_progress_state.duplicate(true)
	progress_state["running"] = running
	progress_state["visible"] = running or _last_workspace_validation_result != null
	return progress_state


func _begin_workspace_validation_progress() -> void:
	_store_validation_progress_state({
		"phase": "workspace_assets",
		"phase_text": "Checking workspace assets",
		"step": 0,
		"steps": 1,
		"progress": 0.0,
		"event_count": 1,
	}, true)


func _finish_workspace_validation_progress() -> void:
	var state := _last_validation_progress_state.duplicate(true)
	if state.is_empty():
		state = {
			"phase": "complete",
			"phase_text": "Validation complete",
			"step": 1,
			"steps": 1,
			"progress": 1.0,
			"event_count": 1,
		}
	if String(state.get("phase", "")) != "complete" or float(state.get("progress", 0.0)) < 1.0:
		state["event_count"] = int(state.get("event_count", 0)) + 1
	state["phase"] = "complete"
	state["phase_text"] = "Validation complete"
	state["progress"] = 1.0
	state["steps"] = max(1, int(state.get("steps", 1)))
	state["step"] = int(state["steps"])
	_store_validation_progress_state(state, false)


func _on_validation_progress(status: Dictionary) -> void:
	_store_validation_progress_state(status, true)


func _store_validation_progress_state(status: Dictionary, running: bool) -> void:
	var progress_state := status.duplicate(true)
	progress_state["phase"] = String(progress_state.get("phase", ""))
	progress_state["phase_text"] = String(progress_state.get("phase_text", ""))
	progress_state["step"] = int(progress_state.get("step", 0))
	progress_state["steps"] = int(progress_state.get("steps", 0))
	progress_state["progress"] = clampf(float(progress_state.get("progress", 0.0)), 0.0, 1.0)
	progress_state["event_count"] = int(progress_state.get("event_count", 0))
	progress_state["running"] = running
	progress_state["visible"] = bool(progress_state.get("visible", true))
	progress_state["cells"] = int(progress_state.get("cells", 0))
	progress_state["tile_entries"] = int(progress_state.get("tile_entries", 0))
	progress_state["objects"] = int(progress_state.get("objects", 0))
	progress_state["dependencies"] = int(progress_state.get("dependencies", 0))
	progress_state["errors"] = int(progress_state.get("errors", 0))
	progress_state["warnings"] = int(progress_state.get("warnings", 0))
	_last_validation_progress_state = progress_state


func _sync_export_workflow_state(exporting: bool = false) -> void:
	if _export_workflow_state == null:
		_export_workflow_state = HexMapExportWorkflowState.new()
	var context := workspace_asset_context()
	var destination := _export_destination_context()
	var output_type := _export_output_type_context(context, destination)
	var purpose_context := _export_purpose_context(context, destination)
	var purpose_cards := HexMapExportScreen.purpose_cards(purpose_context)
	var secondary_actions := HexMapExportScreen.secondary_actions(purpose_context)
	var can_export := context.level_document != null and _ensure_session_state().export_saved_path != ""
	_export_workflow_state.update_from_context({
		"destination": destination,
		"output_type": output_type,
		"purpose_cards": purpose_cards,
		"secondary_actions": secondary_actions,
		"last_result": _last_export_action_result,
		"can_export": can_export,
		"exporting": exporting,
		"block_reason": _export_cannot_export_reason(context, destination),
	})


func _sync_workspace_root_state() -> void:
	if _workspace_root_state == null:
		_workspace_root_state = HexMapWorkspaceRootState.new()
	_workspace_root_state.update_from_context({
		"current_tab": current_workspace_tab_name(),
		"tab_names": workspace_tab_names(),
		"screen_snapshots": _workspace_root_screen_snapshots(),
	})


func _workspace_root_screen_snapshots() -> Dictionary:
	return {
		HexMapWorkspaceComponentRegistry.TAB_DOCUMENT: resources_screen_snapshot(),
		HexMapWorkspaceComponentRegistry.TAB_GENERATE: generation_screen_snapshot(),
		HexMapWorkspaceComponentRegistry.TAB_PAINT: paint_brush_screen_snapshot(),
		HexMapWorkspaceComponentRegistry.TAB_CATALOG: catalog_screen_snapshot(),
		HexMapWorkspaceComponentRegistry.TAB_LAYERS: layer_stack_screen_snapshot(),
		HexMapWorkspaceComponentRegistry.TAB_VALIDATE: validate_screen_snapshot(),
		HexMapWorkspaceComponentRegistry.TAB_QA: qa_screen_snapshot(),
		HexMapWorkspaceComponentRegistry.TAB_EXPORT: export_screen_snapshot(),
		HexMapWorkspaceComponentRegistry.TAB_SETTINGS: settings_screen_snapshot(),
	}


func workspace_screen_role_contracts() -> Dictionary:
	return {
		HexMapWorkspaceComponentRegistry.TAB_DOCUMENT: HexMapResourcesScreen.screen_contract(),
		HexMapWorkspaceComponentRegistry.TAB_GENERATE: HexMapBuildScreen.screen_contract(),
		HexMapWorkspaceComponentRegistry.TAB_PAINT: HexMapPaintScreen.screen_contract(),
		HexMapWorkspaceComponentRegistry.TAB_CATALOG: HexMapCatalogScreen.screen_contract(),
		HexMapWorkspaceComponentRegistry.TAB_LAYERS: HexMapLayersScreen.screen_contract(),
		HexMapWorkspaceComponentRegistry.TAB_VALIDATE: HexMapValidateScreen.screen_contract(),
		HexMapWorkspaceComponentRegistry.TAB_QA: HexMapQAScreen.screen_contract(),
		HexMapWorkspaceComponentRegistry.TAB_EXPORT: HexMapExportScreen.screen_contract(),
		HexMapWorkspaceComponentRegistry.TAB_SETTINGS: HexMapSettingsScreen.screen_contract(),
	}


func screen_role_contract_for_tab(tab_name: String) -> Dictionary:
	var actual_tab := _canonical_tab_name(tab_name)
	return workspace_screen_role_contracts().get(actual_tab, {}) as Dictionary


func set_selected_hex_tile_map_node(node: Node, reason: String = "workspace.selected_hex_tile_map") -> Dictionary:
	return set_selected_hex_tile_map_layer(HexMapWorkspaceBindingService.resolve_hex_tile_map_layer(node), reason)


func set_selected_hex_tile_map_layer(layer: Node, reason: String = "workspace.selected_hex_tile_map") -> Dictionary:
	var hex_layer := layer as HexTileMapLayer
	var session := _ensure_session_state()
	session.set_selected_hex_tile_map_layer(hex_layer, reason)
	if session.selected_hex_tile_map_auto_link_enabled():
		_apply_selected_hex_tile_map_to_edit_tool()
	_sync_selected_hex_tile_map_resources()
	_refresh_selected_hex_tile_map_context()
	return selected_hex_tile_map_snapshot()


func clear_selected_hex_tile_map_layer(reason: String = "workspace.selected_hex_tile_map.clear") -> Dictionary:
	return set_selected_hex_tile_map_layer(null, reason)


func ensure_build_graph_context(reason: String = "workspace.build_graph_context", options: Dictionary = {}) -> Dictionary:
	var session := _ensure_session_state()
	var hex_layer := session.current_selected_hex_tile_map_layer() as HexTileMapLayer
	var created_layer := false
	if hex_layer == null:
		hex_layer = _create_build_context_hex_tile_map_layer()
		created_layer = true
		session.set_selected_hex_tile_map_layer(hex_layer, reason)
		if session.selected_hex_tile_map_auto_link_enabled():
			_apply_selected_hex_tile_map_to_edit_tool()
	if _build_screen == null:
		return {
			"ok": false,
			"blocked_reason": "Build screen is unavailable.",
			"created_layer": created_layer,
			"selected_layer": hex_layer,
		}
	var build_options := options.duplicate(true)
	var build_result := _build_screen.ensure_graph_context_for_hex_tile_map_layer(hex_layer, build_options)
	_sync_selected_hex_tile_map_resources()
	if hex_layer.level_document_resource != null:
		session.set_document(
			hex_layer.level_document_resource,
			"workspace.build_graph_context",
			hex_layer.level_document_resource.resource_path,
			reason
		)
	_refresh_selected_hex_tile_map_context()
	_refresh_missing_unique_resources_panel()
	build_result["created_layer"] = created_layer
	build_result["selected_layer"] = hex_layer
	build_result["selected_snapshot"] = selected_hex_tile_map_snapshot()
	build_result["generation_snapshot"] = generation_screen_snapshot()
	return build_result


func load_generation_graph_resource(
	graph_resource: HexGenerationGraphResource,
	overwrite_selected: bool = false,
	reason: String = "workspace.load_generation_graph"
) -> Dictionary:
	var session := _ensure_session_state()
	var selected_layer := session.current_selected_hex_tile_map_layer() as HexTileMapLayer
	var result: Dictionary
	if overwrite_selected and selected_layer != null:
		result = HexMapGraphInstantiator.overwrite_selected_layer(graph_resource, selected_layer)
	else:
		result = HexMapGraphInstantiator.instantiate_new_layer(
			graph_resource,
			_build_context_node_parent(),
			{"base_name": "LoadedGraphHexMapLayer"}
		)
	if not bool(result.get("ok", false)):
		_last_graph_load_result = result.duplicate(true)
		return _last_graph_load_result.duplicate(true)

	var loaded_layer := result.get("layer", null) as HexTileMapLayer
	session.set_selected_hex_tile_map_layer(loaded_layer, reason)
	if session.selected_hex_tile_map_auto_link_enabled():
		_apply_selected_hex_tile_map_to_edit_tool()
	if loaded_layer.level_document_resource != null:
		workspace_asset_context().set_level_document(
			loaded_layer.level_document_resource,
			HexMapWorkspaceAssetContext.SOURCE_PROJECT,
			"Selected Node"
		)
		session.set_document(
			loaded_layer.level_document_resource,
			"workspace.load_generation_graph",
			loaded_layer.level_document_resource.resource_path,
			reason
		)
	if loaded_layer.layer_stack_resource != null:
		workspace_asset_context().set_layer_stack(
			loaded_layer.layer_stack_resource,
			HexMapWorkspaceAssetContext.SOURCE_PROJECT,
			"Selected Node"
		)

	var screen_load_result := {}
	if _build_screen != null:
		_build_screen.set_workspace_asset_context(workspace_asset_context())
		screen_load_result = _build_screen.load_graph_resource(
			loaded_layer.generation_graph_resource,
			{"run": false}
		)
	result["screen_load_result"] = screen_load_result
	_sync_selected_hex_tile_map_resources()
	_refresh_selected_hex_tile_map_context()
	_refresh_missing_unique_resources_panel()
	result["selected_snapshot"] = selected_hex_tile_map_snapshot()
	result["generation_snapshot"] = generation_screen_snapshot()
	_last_graph_load_result = result.duplicate(true)
	return _last_graph_load_result.duplicate(true)


func load_generation_graph_path(
	path: String,
	overwrite_selected: bool = false,
	reason: String = "workspace.load_generation_graph_path"
) -> Dictionary:
	if path == "" or not ResourceLoader.exists(path):
		_last_graph_load_result = {
			"ok": false,
			"mode": "load_path",
			"blocked_reason": "Generation Graph resource path does not exist.",
			"path": path,
		}
		return _last_graph_load_result.duplicate(true)
	var resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if not resource is HexGenerationGraphResource:
		_last_graph_load_result = {
			"ok": false,
			"mode": "load_path",
			"blocked_reason": "Selected resource is not a HexGenerationGraphResource.",
			"path": path,
		}
		return _last_graph_load_result.duplicate(true)
	var result := load_generation_graph_resource(resource, overwrite_selected, reason)
	result["path"] = path
	_last_graph_load_result = result.duplicate(true)
	return _last_graph_load_result.duplicate(true)


func last_generation_graph_load_result() -> Dictionary:
	return _last_graph_load_result.duplicate(true)


func selected_hex_tile_map_snapshot() -> Dictionary:
	var session := _ensure_session_state()
	var layer := session.current_selected_hex_tile_map_layer()
	var hex_layer := layer as HexTileMapLayer
	var selected := hex_layer != null
	var display_name := _node_display_name(hex_layer)
	var context := workspace_asset_context()
	var level_document := hex_layer.level_document_resource if selected else context.level_document
	var layer_stack := hex_layer.layer_stack_resource if selected else null
	var runtime_display_snapshot := hex_layer.hex_map if selected else null
	var display_tile_set := hex_layer.display_tile_set_resource if selected else null
	if selected and display_tile_set == null:
		display_tile_set = hex_layer.display_tile_set()
	var writeback := selected_hex_tile_map_writeback_snapshot()
	var binding_state := selected_hex_tile_map_binding_state_snapshot(writeback)
	return {
		"selected": selected,
		"selected_node": hex_layer,
		"node_name": hex_layer.name if selected else "",
		"display_name": display_name,
		"node_path": _node_display_path(hex_layer),
		"node_path_visible": false,
		"status_text": _selected_hex_tile_map_status_text(hex_layer),
		"auto_link": session.selected_hex_tile_map_auto_link_enabled(),
		"auto_link_text": "Auto-link: On" if session.selected_hex_tile_map_auto_link_enabled() else "Auto-link: Off",
		"target_layer": session.current_target_layer(),
		"target_matches_selected": selected and session.current_target_layer() == hex_layer,
		"level_document": level_document,
		"level_document_status": "Missing" if selected and level_document == null else ("Linked" if level_document != null else "Unavailable"),
		"authoring_source": "Level Document",
		"authoring_source_resource": level_document,
		"hex_map_is_authoring_source": false,
		"runtime_display_snapshot": runtime_display_snapshot,
		"runtime_display_snapshot_present": runtime_display_snapshot != null,
		"runtime_display_snapshot_role": "Runtime display snapshot",
		"layer_stack": layer_stack,
		"layer_stack_status": "Linked" if layer_stack != null else ("Missing" if selected else "Unavailable"),
		"generation_graph": hex_layer.generation_graph_resource if selected else null,
		"generation_graph_status": "Linked" if selected and hex_layer.generation_graph_resource != null else ("Missing" if selected else "Unavailable"),
		"display_tile_set": display_tile_set,
		"display_tile_set_status": "Linked" if display_tile_set != null else ("Missing" if selected else "Unavailable"),
		"tile_catalog": context.tile_catalog,
		"tile_catalog_status": "Shared project resource" if context.tile_catalog != null else "No Tile Catalog linked to node",
		"writeback": writeback,
		"binding_state": binding_state,
	}


func selected_hex_tile_map_binding_state_snapshot(writeback_snapshot: Dictionary = {}) -> Dictionary:
	var session := _ensure_session_state()
	var layer := session.current_selected_hex_tile_map_layer() as HexTileMapLayer
	var writeback := writeback_snapshot
	if writeback.is_empty():
		writeback = selected_hex_tile_map_writeback_snapshot()
	return HexMapWorkspaceBindingService.selection_binding_state(
		layer,
		session.current_target_layer(),
		session.selected_hex_tile_map_auto_link_enabled(),
		workspace_asset_context(),
		writeback,
		_last_document_dependency_hydration
	)


func selected_hex_tile_map_writeback_snapshot() -> Dictionary:
	var session := _ensure_session_state()
	return HexMapWorkspaceBindingService.selected_writeback_snapshot(
		session.current_selected_hex_tile_map_layer() as HexTileMapLayer,
		session.selected_hex_tile_map_auto_link_enabled(),
		workspace_asset_context()
	)


func apply_workspace_asset_context_to_selected_hex_tile_map(
	slot_id: String = "",
	reason: String = "workspace.asset_context.writeback"
) -> Dictionary:
	if slot_id == "":
		var results := {}
		for owned_slot_id in [
			HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
			HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
		]:
			results[owned_slot_id] = _apply_workspace_asset_change_to_selected_node(String(owned_slot_id), reason)
		return {
			"ok": true,
			"slot_id": slot_id,
			"results": results,
			"snapshot": selected_hex_tile_map_writeback_snapshot(),
		}
	return _apply_workspace_asset_change_to_selected_node(slot_id, reason)


func missing_unique_resources_dialog_config() -> Dictionary:
	return {
		"uses_file_dialog": true,
		"file_mode": EditorFileDialog.FILE_MODE_OPEN_DIR,
		"access": EditorFileDialog.ACCESS_RESOURCES,
		"resource_prefix_editable": true,
	}


func set_missing_unique_resources_save_directory(path: String) -> void:
	_missing_unique_resources_save_directory = _normalized_resource_directory(path)
	_refresh_missing_unique_resources_panel()


func set_missing_unique_resources_prefix(prefix: String) -> void:
	if _missing_unique_resources_prefix_edit != null:
		_missing_unique_resources_prefix_edit.text = _safe_resource_prefix(prefix)
	_refresh_missing_unique_resources_panel()


func missing_unique_resources_snapshot(save_directory: String = "", resource_prefix: String = "") -> Dictionary:
	var session := _ensure_session_state()
	var layer := session.current_selected_hex_tile_map_layer()
	var hex_layer := layer as HexTileMapLayer
	var selected := hex_layer != null
	var directory := _normalized_resource_directory(save_directory)
	if directory == "":
		directory = _missing_unique_resources_save_directory
	var prefix := _safe_resource_prefix(resource_prefix)
	if prefix == "":
		prefix = _missing_unique_resources_prefix()
	var missing_ids := _missing_unique_resource_ids(hex_layer)
	var paths := _missing_unique_resource_paths(directory, prefix)
	var can_create := selected and directory != "" and prefix != "" and not missing_ids.is_empty()
	return {
		"selected": selected,
		"selected_node": hex_layer,
		"status_text": _selected_hex_tile_map_status_text(hex_layer),
		"save_directory": directory,
		"resource_prefix": prefix,
		"missing_resource_ids": missing_ids,
		"missing_count": missing_ids.size(),
		"can_create": can_create,
		"choose_directory_button_tooltip": _missing_unique_resources_choose_directory_button_tooltip(selected),
		"create_button_tooltip": _missing_unique_resources_create_button_tooltip(selected, directory, prefix, missing_ids),
		"paths": paths,
		"dialog_config": missing_unique_resources_dialog_config(),
		"shared_resources_created": false,
		"level_document": hex_layer.level_document_resource if selected else null,
		"layer_stack": hex_layer.layer_stack_resource if selected else null,
	}


func create_missing_selected_hex_tile_map_resources(
	save_directory: String = "",
	resource_prefix: String = ""
) -> Dictionary:
	var before := missing_unique_resources_snapshot(save_directory, resource_prefix)
	var hex_layer := before.get("selected_node", null) as HexTileMapLayer
	if hex_layer == null:
		return _missing_unique_resources_result(false, ERR_DOES_NOT_EXIST, before, {}, "No HexTileMap selected")
	var directory := String(before.get("save_directory", ""))
	var prefix := String(before.get("resource_prefix", ""))
	if directory == "" or prefix == "":
		return _missing_unique_resources_result(false, ERR_INVALID_PARAMETER, before, {}, "Choose a save directory and prefix.")
	var missing_ids := PackedStringArray(before.get("missing_resource_ids", PackedStringArray()))
	if missing_ids.is_empty():
		return _missing_unique_resources_result(true, OK, before, {}, "Selected HexTileMap unique resources are already configured.")

	var paths := before.get("paths", {}) as Dictionary
	var created := {}
	var errors := {}
	var created_ids := PackedStringArray()

	if missing_ids.has(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT):
		var document := hex_layer.to_document_resource()
		document.resource_name = "%s Document" % prefix
		var path := String(paths.get(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, ""))
		var error := _save_resource_if_missing(document, path)
		if error == OK:
			document.resource_path = path
			hex_layer.level_document_resource = document
			created[HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT] = document
			created_ids.append(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT)
		else:
			errors[HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT] = error

	if missing_ids.has(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK):
		var stack = HexLayerStackResource.standard_template() as HexLayerStackResource
		stack.resource_name = "%s Layer Stack" % prefix
		var path := String(paths.get(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK, ""))
		var error := _save_resource_if_missing(stack, path)
		if error == OK:
			stack.resource_path = path
			hex_layer.layer_stack_resource = stack
			created[HexMapWorkspaceAssetContext.SLOT_LAYER_STACK] = stack
			created_ids.append(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK)
		else:
			errors[HexMapWorkspaceAssetContext.SLOT_LAYER_STACK] = error

	_sync_selected_hex_tile_map_resources()
	var dependency_sync := _sync_workspace_shared_resources_to_selected_document_dependencies(
		"workspace.create_missing_unique_resources"
	)
	if created.has(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT):
		_ensure_session_state().set_document(
			created[HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT] as Resource,
			"workspace.selected_hex_tile_map",
			String(paths.get(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "")),
			"workspace.create_missing_unique_resources"
		)
	if _edit_tool != null and created.has(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK):
		_edit_tool.set_layer_stack_resource(created[HexMapWorkspaceAssetContext.SLOT_LAYER_STACK] as HexLayerStackResource, false)
	_refresh_selected_hex_tile_map_context()
	_refresh_missing_unique_resources_panel()

	var ok := errors.is_empty()
	var result := _missing_unique_resources_result(
		ok,
		OK if ok else ERR_CANT_CREATE,
		before,
		created,
		"Created missing resources." if ok else "Could not create all missing resources."
	)
	result["created_resource_ids"] = created_ids
	result["errors"] = errors
	result["shared_dependency_sync"] = dependency_sync
	result["document_dependency_snapshot"] = _document_dependency_hydration_snapshot(workspace_asset_context().level_document)
	result["after"] = missing_unique_resources_snapshot(directory, prefix)
	return result


func save_all_workspace_resources() -> Dictionary:
	var context := workspace_asset_context()
	var saved_slot_ids := PackedStringArray()
	var failed_slot_ids := PackedStringArray()
	for slot_id in [
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE,
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE,
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
		HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE,
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE,
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE,
		HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE,
	]:
		var actual_slot_id := String(slot_id)
		var resource := context.asset_for_slot(actual_slot_id)
		if resource == null or resource.resource_path == "":
			continue
		var error := ResourceSaver.save(resource, resource.resource_path)
		if error == OK:
			saved_slot_ids.append(actual_slot_id)
		else:
			failed_slot_ids.append(actual_slot_id)
	_refresh_resources_context_panel()
	_refresh_missing_unique_resources_panel()
	return {
		"ok": failed_slot_ids.is_empty(),
		"saved_slot_ids": saved_slot_ids,
		"failed_slot_ids": failed_slot_ids,
		"saved_count": saved_slot_ids.size(),
	}


func viewport_input_enabled() -> bool:
	return _edit_tool != null and _edit_tool.viewport_input_enabled()


func forward_canvas_gui_input(event: InputEvent) -> bool:
	if _edit_tool == null:
		return false
	var consumed := _edit_tool.forward_canvas_gui_input(event)
	if consumed:
		select_workspace_tab(HexMapWorkspaceComponentRegistry.TAB_PAINT)
	return consumed


func workspace_tab_names() -> PackedStringArray:
	if _tabs == null:
		return HexMapWorkspaceComponentRegistry.tab_names()
	var names := PackedStringArray()
	for index in range(_tabs.get_tab_count()):
		names.append(_tabs.get_tab_title(index))
	return names


func component_rows() -> Array[Dictionary]:
	return HexMapWorkspaceComponentRegistry.component_rows()


func component_for_responsibility(responsibility: String) -> Dictionary:
	return HexMapWorkspaceComponentRegistry.component_for_responsibility(responsibility)


func component_owner_rows() -> Array[Dictionary]:
	return HexMapWorkspaceComponentRegistry.component_owner_rows()


func component_owner_for(tab_name: String, component_id: String) -> Dictionary:
	return HexMapWorkspaceComponentRegistry.component_owner_for(_canonical_tab_name(tab_name), component_id)


func mounted_component_owner_for(tab_name: String, component_id: String) -> Dictionary:
	var components = _tab_components.get(_canonical_tab_name(tab_name), {})
	if not components is Dictionary or not components.has(component_id):
		return {}
	var node = components[component_id] as Node
	if node == null:
		return {}
	return {
		"tab": _canonical_tab_name(tab_name),
		"component_id": component_id,
		"screen_script": String(node.get_meta("hex_workspace_screen_script", "")),
		"screen_role_source": String(node.get_meta("hex_workspace_screen_role_source", "")),
		"builder": String(node.get_meta("hex_workspace_builder", "")),
	}


func components_for_tab(tab_name: String) -> Array[Dictionary]:
	return HexMapWorkspaceComponentRegistry.components_for_tab(_canonical_tab_name(tab_name))


func tab_component_ids(tab_name: String) -> PackedStringArray:
	var result := PackedStringArray()
	var actual_tab := _canonical_tab_name(tab_name)
	var registry_ids := HexMapWorkspaceComponentRegistry.component_ids_for_tab(actual_tab)
	var components = _tab_components.get(actual_tab, {})
	for component_id in registry_ids:
		if components is Dictionary and components.has(component_id):
			result.append(component_id)
	if components is Dictionary:
		for component_id in components.keys():
			var text := String(component_id)
			if text != "" and not result.has(text):
				result.append(text)
	return result


func tab_has_component(tab_name: String, component_id: String = "") -> bool:
	var components = _tab_components.get(_canonical_tab_name(tab_name), {})
	if not components is Dictionary:
		return false
	if component_id == "":
		return not components.is_empty()
	return components.has(component_id)


func tab_has_scroll_container(tab_name: String) -> bool:
	return _tab_scroll_roots.get(_canonical_tab_name(tab_name), null) is ScrollContainer


func tab_scroll_root_class(tab_name: String) -> String:
	var root = _tab_scroll_roots.get(_canonical_tab_name(tab_name), null) as Control
	return root.get_class() if root != null else ""


func tab_content_root_class(tab_name: String) -> String:
	var content = _tab_pages.get(_canonical_tab_name(tab_name), null) as Control
	return content.get_class() if content != null else ""


func asset_slot_count(tab_name: String) -> int:
	var panel = _asset_panels.get(_canonical_tab_name(tab_name), null) as HexMapWorkspaceAssetPanel
	if panel == null:
		return 0
	return panel.asset_slot_count()


func tab_asset_slot_ids(tab_name: String) -> PackedStringArray:
	var actual_tab := _canonical_tab_name(tab_name)
	var panel = _asset_panels.get(actual_tab, null) as HexMapWorkspaceAssetPanel
	if panel == null:
		return HexMapWorkspaceComponentRegistry.asset_slot_ids_for_tab(actual_tab)
	return panel.asset_slot_ids()


func tab_asset_slot_snapshot(tab_name: String, slot_id: String) -> Dictionary:
	var panel = _asset_panels.get(_canonical_tab_name(tab_name), null) as HexMapWorkspaceAssetPanel
	if panel == null:
		return {}
	return panel.asset_slot_snapshot(slot_id)


func tab_asset_slot_layout_snapshot(tab_name: String, slot_id: String) -> Dictionary:
	var panel = _asset_panels.get(_canonical_tab_name(tab_name), null) as HexMapWorkspaceAssetPanel
	if panel == null:
		return {}
	return panel.asset_slot_layout_snapshot(slot_id)


func tab_empty_state_snapshot(tab_name: String) -> Dictionary:
	var actual_tab := _canonical_tab_name(tab_name)
	match actual_tab:
		HexMapWorkspaceComponentRegistry.TAB_DOCUMENT:
			return _resources_tab_empty_state()
		HexMapWorkspaceComponentRegistry.TAB_PAINT:
			return _paint_tab_empty_state()
		HexMapWorkspaceComponentRegistry.TAB_CATALOG:
			return _catalog_tab_empty_state()
		HexMapWorkspaceComponentRegistry.TAB_LAYERS:
			return _layers_tab_empty_state()
		HexMapWorkspaceComponentRegistry.TAB_VALIDATE:
			return _validate_tab_empty_state()
		HexMapWorkspaceComponentRegistry.TAB_QA:
			return _qa_tab_empty_state()
		HexMapWorkspaceComponentRegistry.TAB_EXPORT:
			return _export_tab_empty_state()
		HexMapWorkspaceComponentRegistry.TAB_SETTINGS:
			return _settings_tab_empty_state()
	return _tab_empty_state(actual_tab, "", "", PackedStringArray(), "")


func press_asset_slot_action(
	tab_name: String,
	slot_id: String,
	action_id: String,
	options: Dictionary = {}
) -> Dictionary:
	var actual_tab := _canonical_tab_name(tab_name)
	var panel = _asset_panels.get(actual_tab, null) as HexMapWorkspaceAssetPanel
	if panel == null:
		return {
			"ok": false,
			"error": ERR_DOES_NOT_EXIST,
			"tab": actual_tab,
			"slot_id": slot_id,
			"action_id": action_id,
		}
	var result := panel.press_asset_slot_action(slot_id, action_id, options)
	result["tab"] = actual_tab
	return result


func _tab_empty_state(
	tab_name: String,
	purpose_text: String,
	empty_state_text: String,
	next_actions: PackedStringArray,
	help_tooltip: String
) -> Dictionary:
	return {
		"tab": tab_name,
		"purpose_text": purpose_text,
		"empty_state_text": empty_state_text,
		"visible": empty_state_text.strip_edges() != "",
		"next_actions": next_actions.duplicate(),
		"next_action_count": next_actions.size(),
		"help_tooltip": help_tooltip,
		"detail_help_in_tooltip": help_tooltip.strip_edges() != "" and not empty_state_text.contains(help_tooltip),
	}


func _resources_tab_empty_state() -> Dictionary:
	var context := workspace_asset_context()
	var selected := bool(selected_hex_tile_map_snapshot().get("selected", false))
	var text := ""
	var actions := PackedStringArray()
	if not selected:
		text = "No HexTileMap selected."
		actions.append("Select a HexTileMap node")
	elif context.level_document == null or context.layer_stack == null:
		text = "Selected HexTileMap needs project resources."
		actions.append("Create Missing Resources")
		actions.append("Choose project assets")
	return _tab_empty_state(
		HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"Manage selected HexTileMap project resources.",
		text,
		actions,
		"Resources owns project assets. Bundled samples stay in Settings and must be duplicated before production use."
	)


func _catalog_tab_empty_state(entry_rows: Array = [], entry_detail: Dictionary = {}) -> Dictionary:
	var catalog := workspace_asset_context().tile_catalog
	var text := ""
	var actions := PackedStringArray()
	if catalog == null:
		text = "No Tile Catalog selected."
		actions.append("Select or create a Tile Catalog")
	elif catalog.tile_set == null:
		text = "Tile Catalog has no TileSet."
		actions.append("Assign a TileSet")
	elif entry_rows.is_empty():
		text = "No catalog entries yet."
		actions.append("Create a tile or scene entry")
	elif not bool(entry_detail.get("preview_available", true)):
		text = String(entry_detail.get("preview_unavailable_reason", "Selected entry has no preview."))
		actions.append("Fix the selected Catalog entry")
	return _tab_empty_state(
		HexMapWorkspaceComponentRegistry.TAB_CATALOG,
		"Build the Tile Catalog used by Generate and Paint.",
		text,
		actions,
		"Choose a project Tile Catalog and TileSet. Samples are learning sources only, not automatic catalog defaults."
	)


func _layers_tab_empty_state(role_rows: Array = [], relationship: Dictionary = {}) -> Dictionary:
	var stack := workspace_asset_context().layer_stack
	var text := ""
	var actions := PackedStringArray()
	if stack == null:
		text = "No Layer Stack selected."
		actions.append("Select or create a Layer Stack")
		actions.append("Select a HexTileMap target")
	elif not bool(relationship.get("target_matches_selected", false)):
		text = String(relationship.get("message", "Layer Stack needs a selected HexTileMap target."))
		actions.append("Select a HexTileMap target")
	elif role_rows.is_empty():
		text = "No role rows until a Layer Stack is selected."
		actions.append("Create missing role layers")
	return _tab_empty_state(
		HexMapWorkspaceComponentRegistry.TAB_LAYERS,
		"Connect Layer Stack roles to the selected HexTileMap.",
		text,
		actions,
		"Layer roles are project structure. Bundled samples do not create production layers."
	)


func _paint_tab_empty_state() -> Dictionary:
	var brush := _edit_tool.paint_brush_snapshot() if _edit_tool != null else {}
	var paint_workspace := _edit_tool.paint_workspace_snapshot() if _edit_tool != null else {}
	var cta = brush.get("missing_asset_cta", {}) as Dictionary
	var text := ""
	var actions := PackedStringArray()
	if not bool(brush.get("ready", false)):
		var slot_id := String(cta.get("target_slot_id", ""))
		var reason := String(cta.get("reason", ""))
		text = _paint_empty_state_reason(reason)
		if slot_id != "":
			actions.append("Select or create %s" % _resource_group_slot_label(slot_id))
		else:
			actions.append("Choose a paint brush target")
	elif paint_workspace.get("active_document", null) == null:
		text = "No active Level Document."
		actions.append("Select or create Level Document")
	elif not bool(paint_workspace.get("target_ready", false)):
		text = String(paint_workspace.get("target_message", "No editable HexTileMap target."))
		actions.append("Select a HexTileMap target")
	return _tab_empty_state(
		HexMapWorkspaceComponentRegistry.TAB_PAINT,
		"Paint terrain, overlays, objects, and labels into the active document.",
		text,
		actions,
		"Paint reads project resources from Resources and Catalog. Bundled samples are not auto-used for production painting."
	)


func _paint_empty_state_reason(reason: String) -> String:
	match reason:
		"missing_tile_catalog":
			return "No Tile Catalog selected."
		"missing_catalog_key":
			return "No Catalog brush selected."
		"missing_object_database":
			return "No Object Database selected."
		"missing_object_definition":
			return "No Object Definition selected."
		"missing_label_database":
			return "No Label Database selected."
		"missing_label_definition":
			return "No Label Definition selected."
	return "Paint brush is not ready."


func _validate_tab_empty_state(issue_rows: Array = []) -> Dictionary:
	var actions := PackedStringArray()
	if _last_workspace_validation_result == null:
		actions.append("Run validation")
	elif issue_rows.is_empty():
		actions.append("Review validation summary")
	return _tab_empty_state(
		HexMapWorkspaceComponentRegistry.TAB_VALIDATE,
		"Validate workspace assets and the active Level Document.",
		_validate_empty_state_text(issue_rows),
		actions,
		"Validation reports missing project assets and routes each issue to the owning tab. Samples are not selected to satisfy missing project resources."
	)


func _qa_tab_empty_state(seed_lab: Dictionary = {}) -> Dictionary:
	var score_rows = seed_lab.get("score_rows", []) as Array
	var text := ""
	var actions := PackedStringArray()
	if score_rows.is_empty():
		text = "Run Seed Lab to compare generated seeds."
		if workspace_asset_context().generation_profile == null:
			actions.append("Select or duplicate Generation Profile")
		actions.append("Run Seed Lab")
	return _tab_empty_state(
		HexMapWorkspaceComponentRegistry.TAB_QA,
		"Compare generated seeds and promote one result to the Level Document.",
		text,
		actions,
		"QA compares generated candidates against project validation settings. Bundled samples do not become QA defaults."
	)


func _export_tab_empty_state(context: HexMapWorkspaceAssetContext = null, destination: Dictionary = {}) -> Dictionary:
	var actual_context := context if context != null else workspace_asset_context()
	var actual_destination := destination if not destination.is_empty() else _export_destination_context()
	var text := ""
	var actions := PackedStringArray()
	if actual_context.level_document == null or not bool(actual_destination.get("selected", false)):
		text = _export_cannot_export_reason(actual_context, actual_destination)
		if actual_context.level_document == null:
			actions.append("Select Level Document")
		if not bool(actual_destination.get("selected", false)):
			actions.append("Choose Runtime Handoff destination")
	return _tab_empty_state(
		HexMapWorkspaceComponentRegistry.TAB_EXPORT,
		"Export writes the current Level Document as a runtime HexMapResource handoff.",
		text,
		actions,
		"Export uses a project document and a user-selected Runtime Handoff destination. Samples are not Runtime Handoff destinations."
	)


func _settings_tab_empty_state() -> Dictionary:
	return _tab_empty_state(
		HexMapWorkspaceComponentRegistry.TAB_SETTINGS,
		_settings_purpose_text(),
		"Settings holds sample learning and explicit debug opt-ins.",
		PackedStringArray(["Duplicate samples to project before production"]),
		"Production asset selection lives in Resources; sample actions here are learning and duplication tools."
	)


func _empty_state_inline_text(empty_state: Dictionary) -> String:
	var text := String(empty_state.get("empty_state_text", ""))
	var actions = empty_state.get("next_actions", PackedStringArray()) as PackedStringArray
	if text == "" or actions.is_empty():
		return text
	return "%s Next: %s." % [text, _join_text(actions, " / ")]


func document_screen_snapshot() -> Dictionary:
	return resources_screen_snapshot()


func resources_screen_snapshot() -> Dictionary:
	var context := workspace_asset_context()
	var screen_role := HexMapResourcesScreen.screen_contract()
	var ownership := HexMapResourcesScreen.ownership_fields()
	var document := context.level_document
	var selected_snapshot := selected_hex_tile_map_snapshot()
	var missing_snapshot := missing_unique_resources_snapshot()
	var groups := resource_group_rows()
	var source_badge_rows := _resource_source_badge_rows(groups, selected_snapshot)
	var next_actions := _resources_next_actions(selected_snapshot, missing_snapshot)
	var resource_shelf := _resources_shelf_snapshot(selected_snapshot, missing_snapshot, groups, source_badge_rows)
	var document_slot := tab_asset_slot_snapshot(
		HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT
	)
	var empty_state := _resources_tab_empty_state()
	return {
		"tab": HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"screen_role": screen_role,
		"screen_script": String(screen_role.get("screen_script", "")),
		"screen_role_source": String(screen_role.get("screen_role_source", "")),
		"workflow_owner": String(screen_role.get("workflow_owner", "")),
		"component_ids": tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_DOCUMENT),
		"asset_slot_ids": tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_DOCUMENT),
		"purpose_text": String(empty_state.get("purpose_text", "")),
		"first_surface": "resource_shelf",
		"empty_state": empty_state,
		"empty_state_text": String(empty_state.get("empty_state_text", "")),
		"dependency_slot_ids": PackedStringArray([
			HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
			HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE,
			HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE,
			HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
			HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE,
		]),
		"level_document": document,
		"document_slot": document_slot,
		"summary": HexMapDocumentAdapter.document_summary(document),
		"saved_path": document.resource_path if document != null else "",
		"saved_status": "saved" if document != null and document.resource_path != "" else "unsaved",
		"dirty": false,
		"document_workflow_owner": String(ownership.get("document_workflow_owner", "Resources")),
		"document_management_visible": bool(ownership.get("document_management_visible", true)),
		"document_save_dependency_dirty_owner": String(screen_role.get("workflow_owner", "Resources")),
		"document_save_available": document != null,
		"document_save_as_available": document != null,
		"dependency_hydration_visible": true,
		"dirty_state_visible": true,
		"paint_document_management_visible": bool(ownership.get("paint_document_management_visible", false)),
		"asset_source_snapshot": context.source_snapshot(),
		"dependency_hydration": _document_dependency_hydration_snapshot(document),
		"last_dependency_hydration": _last_document_dependency_hydration.duplicate(true),
		"selected_hex_tile_map": selected_snapshot,
		"selected_hex_tile_map_summary": _selected_hex_tile_map_summary(selected_snapshot, missing_snapshot),
		"context_chips": resource_shelf.get("context_chips", PackedStringArray()),
		"context_chips_visible": bool(resource_shelf.get("context_chips_visible", true)),
		"context_chips_text": String(resource_shelf.get("context_chips_text", "")),
		"resources_shelf": resource_shelf,
		"resource_shelf": resource_shelf,
		"resource_shelf_primary": bool(resource_shelf.get("primary", false)),
		"resource_shelf_cards": resource_shelf.get("group_cards", []),
		"resource_shelf_group_ids": resource_shelf.get("group_ids", PackedStringArray()),
		"resource_shelf_selected_hex_tile_map_chip": String(resource_shelf.get("selected_hex_tile_map_chip_text", "")),
		"resources_visual_summary": resource_shelf,
		"resources_readiness_rows": [],
		"mounted_resources_readiness_text": _resources_readiness_label.text if _resources_readiness_label != null else "",
		"resources_readiness_label_visible": false,
		"resources_next_actions_label_visible": false,
		"resources_source_badges_label_visible": false,
		"resource_rows_primary": false,
		"resource_groups": groups,
		"source_badge_rows": source_badge_rows,
		"source_badge_explanations": _resource_source_badge_explanations(),
		"missing_unique_resources": missing_snapshot,
		"next_actions": next_actions,
		"clear_next_actions_beyond_resource_rows": false,
		"create_missing_resources_cta": resource_shelf.get("create_missing_resources_cta", {}),
		"create_missing_resources_primary_cta": true,
		"create_missing_resources_available": _missing_unique_resources_create_button != null,
		"create_missing_resources_button_text": _missing_unique_resources_create_button.text if _missing_unique_resources_create_button != null else "",
		"save_all_cta": resource_shelf.get("save_all_cta", {}),
		"save_all_button_text": _resources_save_all_button.text if _resources_save_all_button != null else "",
	}


func _selected_hex_tile_map_summary(selected_snapshot: Dictionary, missing_snapshot: Dictionary) -> Dictionary:
	var selected := bool(selected_snapshot.get("selected", false))
	var missing_count := int(missing_snapshot.get("missing_count", 0))
	var display_name := String(selected_snapshot.get("display_name", ""))
	var visible_text := "No HexTileMap selected"
	if selected:
		var document_state := String(selected_snapshot.get("level_document_status", "Missing"))
		var layer_stack_state := String(selected_snapshot.get("layer_stack_status", "Missing"))
		visible_text = "%s | Level Document: %s | Layer Stack: %s" % [
			display_name,
			document_state,
			layer_stack_state,
		]
		if missing_count > 0:
			visible_text += " | Missing: %d" % missing_count
	return {
		"visible": true,
		"visible_text": visible_text,
		"display_name": display_name,
		"selected": selected,
		"node_path_visible": false,
		"node_path": String(selected_snapshot.get("node_path", "")),
		"missing_unique_count": missing_count,
		"level_document_status": String(selected_snapshot.get("level_document_status", "")),
		"layer_stack_status": String(selected_snapshot.get("layer_stack_status", "")),
		"tile_catalog_status": String(selected_snapshot.get("tile_catalog_status", "")),
	}


func _resources_next_actions(selected_snapshot: Dictionary, missing_snapshot: Dictionary) -> PackedStringArray:
	var actions := PackedStringArray()
	if not bool(selected_snapshot.get("selected", false)):
		actions.append("Select a HexTileMap node")
		return actions
	var missing_ids = missing_snapshot.get("missing_resource_ids", PackedStringArray()) as PackedStringArray
	if missing_ids != null and not missing_ids.is_empty():
		actions.append("Choose a save folder")
		actions.append("Create Missing Resources")
	var writeback = selected_snapshot.get("writeback", {}) as Dictionary
	if String(writeback.get("blocked_reason", "")) == "":
		actions.append("Review source badges")
	return actions


func _resources_shelf_snapshot(
	selected_snapshot: Dictionary,
	missing_snapshot: Dictionary,
	groups: Array,
	source_badge_rows: Array
) -> Dictionary:
	var selected := bool(selected_snapshot.get("selected", false))
	var selected_name := String(selected_snapshot.get("display_name", ""))
	if selected_name == "":
		selected_name = "None"
	var group_cards: Array[Dictionary] = []
	for group in groups:
		if not group is Dictionary:
			continue
		group_cards.append(_resource_shelf_group_card(group as Dictionary, source_badge_rows))
	var context_chips := PackedStringArray(["Selected HexTileMap: %s" % selected_name])
	var missing_count := int(missing_snapshot.get("missing_count", 0))
	return {
		"surface_id": "resource_shelf",
		"visible": true,
		"primary": true,
		"context_chips": context_chips,
		"context_chips_visible": true,
		"context_chips_text": _join_text(context_chips, " "),
		"selected_hex_tile_map_chip_text": context_chips[0],
		"global_map_chip_duplicated": false,
		"group_cards": group_cards,
		"group_ids": _resource_shelf_group_ids(group_cards),
		"unique_card": _resource_shelf_card_for_group(group_cards, "unique"),
		"shared_card": _resource_shelf_card_for_group(group_cards, "shared"),
		"optional_card": _resource_shelf_card_for_group(group_cards, "optional"),
		"card_count": group_cards.size(),
		"resource_rows_primary": false,
		"readiness_label_visible": false,
		"next_actions_label_visible": false,
		"source_badges_label_visible": false,
		"create_missing_resources_cta": {
			"visible": true,
			"primary": true,
			"text": "Create Missing Resources",
			"enabled": selected and missing_count > 0,
			"missing_count": missing_count,
		},
		"save_all_cta": {
			"visible": true,
			"text": "Save All",
			"enabled": _workspace_has_saveable_resources(),
		},
		"empty_cta": {
			"visible": not selected,
			"primary_action": "Select a HexTileMap node",
			"secondary_actions": PackedStringArray(["Create Level Document", "Choose Tile Catalog"]) if not selected else PackedStringArray(),
		},
		"primary_path_text_visible": false,
	}


func _resource_shelf_group_card(group: Dictionary, source_badge_rows: Array) -> Dictionary:
	var group_id := String(group.get("group_id", ""))
	var slots: Array[Dictionary] = []
	var slot_rows = group.get("slot_status_rows", []) as Array
	for row in slot_rows:
		if not row is Dictionary:
			continue
		var slot_id := String((row as Dictionary).get("slot_id", ""))
		var source_row := _source_badge_row_for_slot(source_badge_rows, slot_id)
		slots.append({
			"slot_id": slot_id,
			"label": String((row as Dictionary).get("label", "")),
			"present": bool((row as Dictionary).get("present", false)),
			"status_badge": "Ready" if bool((row as Dictionary).get("present", false)) else "Missing",
			"source_badge": String((row as Dictionary).get("source_badge", source_row.get("source_badge", "Missing"))),
			"tooltip": String(source_row.get("tooltip", "")),
		})
	var missing_count := int(group.get("missing_count", 0))
	return {
		"group_id": group_id,
		"title": _resource_shelf_group_title(group_id, String(group.get("label", ""))),
		"status_badge": "Ready" if missing_count == 0 else "Missing: %d" % missing_count,
		"ready_count": int(group.get("ready_count", 0)),
		"missing_count": missing_count,
		"slot_cards": slots,
		"slot_labels": group.get("slot_labels", PackedStringArray()),
		"tooltip": String(group.get("tooltip", "")),
		"visible_text": "%s | %s" % [
			_resource_shelf_group_title(group_id, String(group.get("label", ""))),
			String(group.get("status_text", "")),
		],
		"primary_path_text_visible": false,
	}


func _resource_shelf_group_title(group_id: String, fallback: String) -> String:
	match group_id:
		"unique":
			return "Unique to this map"
		"shared":
			return "Shared project assets"
		"optional":
			return "Optional"
	return fallback


func _source_badge_row_for_slot(rows: Array, slot_id: String) -> Dictionary:
	for row in rows:
		if row is Dictionary and String((row as Dictionary).get("slot_id", "")) == slot_id:
			return row as Dictionary
	return {}


func _resource_shelf_group_ids(cards: Array) -> PackedStringArray:
	var ids := PackedStringArray()
	for card in cards:
		if card is Dictionary:
			ids.append(String((card as Dictionary).get("group_id", "")))
	return ids


func _resource_shelf_card_for_group(cards: Array, group_id: String) -> Dictionary:
	for card in cards:
		if card is Dictionary and String((card as Dictionary).get("group_id", "")) == group_id:
			return card as Dictionary
	return {}


func _workspace_has_saveable_resources() -> bool:
	var context := workspace_asset_context()
	for slot_id in [
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE,
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE,
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
		HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE,
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE,
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE,
		HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE,
	]:
		var resource := context.asset_for_slot(String(slot_id))
		if resource != null and resource.resource_path != "":
			return true
	return false


func _work_tab_context_chips(tab_name: String) -> PackedStringArray:
	match HexMapWorkspaceComponentRegistry.canonical_tab_name(tab_name):
		HexMapWorkspaceComponentRegistry.TAB_GENERATE:
			return PackedStringArray([
				_resource_context_chip(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "Catalog"),
				"Target: generated terrain",
				"Graph: %s" % ("Ready" if _selected_hex_tile_map_has_graph_resource() else "New"),
			])
		HexMapWorkspaceComponentRegistry.TAB_CATALOG:
			return PackedStringArray([
				_resource_context_chip(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "Catalog"),
			])
		HexMapWorkspaceComponentRegistry.TAB_LAYERS:
			return PackedStringArray([
				_resource_context_chip(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK, "Layer Stack"),
				"Target: %s" % _selected_hex_tile_map_target_label(),
			])
		HexMapWorkspaceComponentRegistry.TAB_VALIDATE:
			return PackedStringArray([
				_resource_context_chip(HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE, "Suite"),
				"Issues: %d" % (_last_workspace_validation_result.issue_count() if _last_workspace_validation_result != null else 0),
			])
		HexMapWorkspaceComponentRegistry.TAB_QA:
			return PackedStringArray([
				_resource_context_chip(HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE, "Profile"),
				_resource_context_chip(HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE, "Suite"),
				_resource_context_chip(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "Promotion"),
			])
		HexMapWorkspaceComponentRegistry.TAB_EXPORT:
			return PackedStringArray([
				_resource_context_chip(HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE, "Profile"),
				_resource_context_chip(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "Source"),
			])
	return PackedStringArray()


func _resource_context_chip(slot_id: String, label: String) -> String:
	var resource := workspace_asset_context().asset_for_slot(slot_id)
	var value := "Missing"
	if resource != null:
		value = resource.resource_name if resource.resource_name != "" else "Linked"
	return "%s: %s" % [label, value]


func _selected_hex_tile_map_has_graph_resource() -> bool:
	var selected := _ensure_session_state().current_selected_hex_tile_map_layer()
	return selected is HexTileMapLayer and (selected as HexTileMapLayer).generation_graph_resource != null


func _selected_hex_tile_map_target_label() -> String:
	var selected := _ensure_session_state().current_selected_hex_tile_map_layer()
	if selected is HexTileMapLayer:
		return selected.name if selected.name != "" else "HexTileMap"
	return "None"


func _resource_source_badge_rows(groups: Array, selected_snapshot: Dictionary) -> Array[Dictionary]:
	var context := workspace_asset_context()
	var source_snapshot := context.source_snapshot()
	var selected := bool(selected_snapshot.get("selected", false))
	var binding_state = selected_snapshot.get("binding_state", {}) as Dictionary
	var manual_override_slot_ids := PackedStringArray(binding_state.get("manual_override_slot_ids", PackedStringArray()))
	var hydrated_slot_ids := PackedStringArray(binding_state.get("hydrated_dependency_slot_ids", PackedStringArray()))
	var rows: Array[Dictionary] = []
	var included := {}
	for group in groups:
		var slot_ids = (group as Dictionary).get("slot_ids", PackedStringArray()) as PackedStringArray
		for slot_id_value in slot_ids:
			var slot_id := String(slot_id_value)
			if included.has(slot_id):
				continue
			included[slot_id] = true
			var source = source_snapshot.get(slot_id, {}) as Dictionary
			var resource := context.asset_for_slot(slot_id)
			var badge := _resource_source_badge_for_slot(
				slot_id,
				resource,
				source,
				manual_override_slot_ids,
				hydrated_slot_ids,
				selected
			)
			var label := _resource_group_slot_label(slot_id)
			rows.append({
				"slot_id": slot_id,
				"label": label,
				"source_badge": badge,
				"source": String(source.get("source", HexMapWorkspaceAssetContext.SOURCE_NONE)),
				"resource": resource,
				"selected": resource != null,
				"visible_text": "%s: %s" % [label, badge],
				"tooltip": _resource_source_badge_tooltip(slot_id, badge, resource),
			})
	return rows


func _resource_source_badge_for_slot(
	slot_id: String,
	resource: Resource,
	source: Dictionary,
	manual_override_slot_ids: PackedStringArray,
	hydrated_slot_ids: PackedStringArray,
	selected: bool
) -> String:
	if resource == null:
		return "Missing"
	if selected and HexMapWorkspaceBindingService.node_owned_slot_ids().has(slot_id):
		return "Node"
	if manual_override_slot_ids.has(slot_id):
		return "Manual Override"
	if hydrated_slot_ids.has(slot_id):
		return HexMapDocumentDependencyService.SOURCE_BADGE_DOCUMENT_DEPENDENCY
	var source_id := String(source.get("source", HexMapWorkspaceAssetContext.SOURCE_NONE))
	if source_id == HexMapWorkspaceAssetContext.SOURCE_SAMPLE:
		return HexMapWorkspaceAssetContext.SOURCE_BADGE_SAMPLE
	if source_id == HexMapWorkspaceAssetContext.SOURCE_DOCUMENT_DEPENDENCY:
		return HexMapDocumentDependencyService.SOURCE_BADGE_DOCUMENT_DEPENDENCY
	if source_id == HexMapWorkspaceAssetContext.SOURCE_PROJECT:
		return HexMapWorkspaceAssetContext.SOURCE_BADGE_PROJECT
	return HexMapWorkspaceAssetContext.SOURCE_BADGE_NONE


func _resource_source_badge_tooltip(slot_id: String, badge: String, resource: Resource) -> String:
	var lines := PackedStringArray()
	lines.append("%s: %s" % [_resource_group_slot_label(slot_id), _resource_source_badge_explanations().get(badge, badge)])
	if resource != null and resource.resource_path != "":
		lines.append("Path: %s" % resource.resource_path)
	return "\n".join(lines)


func _resource_source_badge_explanations() -> Dictionary:
	return {
		"Node": "Owned by the selected HexTileMap node.",
		HexMapDocumentDependencyService.SOURCE_BADGE_DOCUMENT_DEPENDENCY: "Hydrated from the selected Level Document dependencies.",
		"Manual Override": "Workspace selection intentionally overrides the selected document dependency.",
		HexMapWorkspaceAssetContext.SOURCE_BADGE_SAMPLE: "Learning/sample asset; duplicate before production use.",
		HexMapWorkspaceAssetContext.SOURCE_BADGE_PROJECT: "Selected project resource.",
		HexMapWorkspaceAssetContext.SOURCE_BADGE_NONE: "No resource selected.",
	}


func _source_badge_rows_text(rows: Array) -> String:
	var parts := PackedStringArray()
	for row in rows:
		if not row is Dictionary:
			continue
		parts.append(String((row as Dictionary).get("visible_text", "")))
	return _join_text(parts, " | ")


func _resource_shelf_slot_cards_text(rows: Array) -> String:
	var parts := PackedStringArray()
	for row in rows:
		if not row is Dictionary:
			continue
		parts.append("%s: %s" % [
			String((row as Dictionary).get("label", "")),
			String((row as Dictionary).get("source_badge", "")),
		])
	return _join_text(parts, " | ")


func _resources_next_actions_text(actions: PackedStringArray) -> String:
	if actions.is_empty():
		return "Next: Review resource rows."
	return "Next: %s." % _join_text(actions, " / ")


func _readiness_rows_text(rows: Array) -> String:
	var parts := PackedStringArray()
	for row in rows:
		if not row is Dictionary:
			continue
		var text := String((row as Dictionary).get("visible_text", ""))
		if text != "":
			parts.append(text)
	return _join_text(parts, " | ")


func resource_group_rows() -> Array[Dictionary]:
	return [
		_resource_group_row(
			"unique",
			"Unique Resources",
			PackedStringArray([
				HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
				HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
			]),
			"Owned by the selected HexTileMap node and created per map."
		),
		_resource_group_row(
			"shared",
			"Shared Resources",
			PackedStringArray([
				HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
			]),
			"Project assets shared by Generate, Paint, Validate, QA, and Export."
		),
		_resource_group_row(
			"optional",
			"Optional Resources",
			PackedStringArray([
				HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE,
				HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE,
				HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE,
			]),
			"Project assets used when object, label, or movement-validation workflows are enabled."
		),
	]


func create_level_document(path: String) -> Dictionary:
	var panel := _document_asset_panel()
	if panel == null:
		return _document_action_result(false, ERR_UNAVAILABLE, path)
	var result := panel.create_asset_for_slot(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, path)
	_sync_session_document_from_result(result, "workspace.document.create")
	return result


func save_level_document_as(path: String) -> Dictionary:
	var panel := _document_asset_panel()
	if panel == null:
		return _document_action_result(false, ERR_UNAVAILABLE, path)
	var result := panel.save_asset_slot_as(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, path)
	_sync_session_document_from_result(result, "workspace.document.save_as")
	return result


func open_level_document() -> Dictionary:
	var panel := _document_asset_panel()
	if panel == null:
		return _document_action_result(false, ERR_UNAVAILABLE, "")
	var result := panel.open_asset_slot(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT)
	_sync_session_document_from_result(result, "workspace.document.open")
	return result


func clear_level_document() -> Dictionary:
	var panel := _document_asset_panel()
	if panel == null:
		return _document_action_result(false, ERR_UNAVAILABLE, "")
	var result := panel.clear_asset_slot(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT)
	_ensure_session_state().set_document(null, "", "", "workspace.document.clear")
	_ensure_session_state().set_document_saved_path("", "workspace.document.clear")
	_hydrate_workspace_context_from_document_dependencies(null)
	return result


func validate_level_document():
	var options := _document_validation_options()
	options["progress_callback"] = Callable(self, "_on_validation_progress")
	return HexMapDocumentValidator.validate_document(
		workspace_asset_context().level_document,
		options
	)


func validate_screen_snapshot() -> Dictionary:
	var context := workspace_asset_context()
	var screen_role := HexMapValidateScreen.screen_contract()
	var ownership := HexMapValidateScreen.ownership_fields()
	var issue_rows := validate_screen_issue_rows(_last_workspace_validation_result)
	var empty_state := _validate_tab_empty_state(issue_rows)
	var validation_state := validation_workflow_state_snapshot()
	var validation_progress_state := validation_state.get("progress_state", {}) as Dictionary
	var issue_table := _validate_issue_table(issue_rows)
	return {
		"tab": HexMapWorkspaceComponentRegistry.TAB_VALIDATE,
		"screen_role": screen_role,
		"screen_script": String(screen_role.get("screen_script", "")),
		"screen_role_source": String(screen_role.get("screen_role_source", "")),
		"workflow_owner": String(screen_role.get("workflow_owner", "")),
		"component_ids": tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_VALIDATE),
		"asset_slot_ids": tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_VALIDATE),
		"purpose_text": String(empty_state.get("purpose_text", "")),
		"empty_state": empty_state,
		"context_chips": _work_tab_context_chips(HexMapWorkspaceComponentRegistry.TAB_VALIDATE),
		"context_chips_visible": true,
		"context_chips_text": _join_text(_work_tab_context_chips(HexMapWorkspaceComponentRegistry.TAB_VALIDATE), " "),
		"context_chips_detail_target": HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"global_map_chip_duplicated": false,
		"resource_row_primary": false,
		"validation_state": validation_state,
		"view_state": validation_state.get("view_state", {}),
		"validation_progress_state": validation_progress_state,
		"validation_progress_visible": bool(validation_progress_state.get("visible", false)),
		"validation_progress_phase": String(validation_progress_state.get("phase", "")),
		"validation_progress_phase_text": String(validation_progress_state.get("phase_text", "")),
		"target_summary": _validate_target_summary(context),
		"level_document": context.level_document,
		"tile_catalog": context.tile_catalog,
		"object_database": context.object_database,
		"label_database": context.label_database,
		"layer_stack": context.layer_stack,
		"validation_rule_suite": context.validation_rule_suite,
		"validation_rule_suite_context": _profile_resource_context(
			context,
			HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE
		),
		"validation_rule_suite_slot": tab_asset_slot_snapshot(
			HexMapWorkspaceComponentRegistry.TAB_VALIDATE,
			HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE
		),
		"generation_profile": context.generation_profile,
		"navigator_component_present": tab_has_component(HexMapWorkspaceComponentRegistry.TAB_VALIDATE, "validation_issue_navigator"),
		"validation_workflow_owner": String(ownership.get("validation_workflow_owner", "Validate")),
		"workflow_validate_action_visible": _validation_run_button != null,
		"workflow_validate_button_text": _validation_run_button.text if _validation_run_button != null else "",
		"issue_navigator_visible": _validation_issue_navigator != null,
		"issue_list_visible": true,
		"severity_scope_focus_visible": true,
		"severity_visible": true,
		"scope_visible": true,
		"focus_action_visible": true,
		"issue_click_routes_focus": true,
		"slot_level_validate_buttons_present": false,
		"paint_validation_dashboard_visible": false,
		"last_result": _last_workspace_validation_result,
		"issue_rows": issue_rows,
		"issue_table": issue_table,
		"issue_table_columns": issue_table.get("columns", PackedStringArray()),
		"issue_table_rows_text": String(issue_table.get("rows_text", "")),
		"mounted_issue_table_text": _validation_issue_rows_label.text if _validation_issue_rows_label != null else "",
		"issue_count": issue_rows.size(),
		"error_count": _last_workspace_validation_result.error_count() if _last_workspace_validation_result != null else 0,
		"warning_count": _last_workspace_validation_result.warning_count() if _last_workspace_validation_result != null else 0,
		"selected_issue_index": _selected_validate_issue_index,
		"selected_issue_row": _selected_validate_issue_row.duplicate(true),
		"selected_issue_navigation": _selected_validate_issue_navigation.duplicate(true),
		"empty_state_text": String(empty_state.get("empty_state_text", "")),
		"resource_row_validate_buttons_present": false,
		"sample_candidates_visible": _ensure_session_state().show_bundled_samples_in_main_selectors,
	}


func _on_validate_screen_run_pressed() -> void:
	run_validate_screen()


func run_validate_screen() -> Dictionary:
	_begin_workspace_validation_progress()
	_sync_validation_workflow_state(true)
	_last_workspace_validation_result = validate_workspace_assets()
	_finish_workspace_validation_progress()
	_selected_validate_issue_index = -1
	_selected_validate_issue_row.clear()
	_selected_validate_issue_navigation.clear()
	var rows := validate_screen_issue_rows(_last_workspace_validation_result)
	var issue_table := _validate_issue_table(rows)
	_refresh_validation_issue_navigator()
	var validation_state := validation_workflow_state_snapshot()
	var validation_progress_state := validation_state.get("progress_state", {}) as Dictionary
	return {
		"ok": true,
		"result": _last_workspace_validation_result,
		"issue_rows": rows,
		"issue_table": issue_table,
		"validation_state": validation_state,
		"view_state": validation_state.get("view_state", {}),
		"validation_progress_state": validation_progress_state,
		"validation_progress_visible": bool(validation_progress_state.get("visible", false)),
		"validation_progress_phase": String(validation_progress_state.get("phase", "")),
		"validation_progress_phase_text": String(validation_progress_state.get("phase_text", "")),
	}


func validate_workspace_assets() -> HexMapValidationResult:
	var context := workspace_asset_context()
	var result := HexMapValidationResult.new()
	result.summary = {
		"workspace_assets": 5,
		"errors": 0,
		"warnings": 0,
		"infos": 0,
	}
	_add_missing_asset_issue(
		result,
		context.level_document == null,
		"workspace.level_document_missing",
		"Level Document is not selected.",
		HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"document_asset_panel",
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT
	)
	_add_missing_asset_issue(
		result,
		context.tile_catalog == null,
		"workspace.tile_catalog_missing",
		"Tile Catalog is not selected.",
		HexMapWorkspaceComponentRegistry.TAB_CATALOG,
		"catalog_asset_panel",
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG
	)
	_add_missing_asset_issue(
		result,
		context.object_database == null,
		"workspace.object_database_missing",
		"Object Database is not selected.",
		HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"document_asset_panel",
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE
	)
	_add_missing_asset_issue(
		result,
		context.label_database == null,
		"workspace.label_database_missing",
		"Label Database is not selected.",
		HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"document_asset_panel",
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE
	)
	_add_missing_asset_issue(
		result,
		context.layer_stack == null,
		"workspace.layer_stack_missing",
		"Layer Stack is not selected.",
		HexMapWorkspaceComponentRegistry.TAB_LAYERS,
		"layer_stack_asset_panel",
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK
	)
	if context.level_document != null:
		var document_options := _document_validation_options()
		document_options["progress_callback"] = Callable(self, "_on_validation_progress")
		var document_result = HexMapDocumentValidator.validate_document(context.level_document, document_options)
		for issue in document_result.issues:
			if issue is Dictionary:
				result.issues.append((issue as Dictionary).duplicate(true))
		if document_result.summary.has("validation_progress"):
			result.summary["document_validation_progress"] = (
				document_result.summary.get("validation_progress", {}) as Dictionary
			).duplicate(true)
	_update_workspace_validation_counts(result)
	if not _last_validation_progress_state.is_empty():
		result.summary["validation_progress"] = _last_validation_progress_state.duplicate(true)
	return result


func validate_screen_issue_rows(result: HexMapValidationResult) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	if result == null:
		return rows
	var issue_index := 0
	for issue in result.issues:
		if not issue is Dictionary:
			continue
		var metadata = (issue as Dictionary).get("metadata", {})
		var route: Dictionary = metadata if metadata is Dictionary else {}
		var row := {
			"index": issue_index,
			"severity": String((issue as Dictionary).get("severity", "")),
			"severity_label": HexMapValidationDashboard.issue_severity_label(issue as Dictionary),
			"domain": HexMapValidationDashboard.issue_domain(issue as Dictionary),
			"scope": String((issue as Dictionary).get("scope", "")),
			"rule_id": String((issue as Dictionary).get("rule_id", "")),
			"message": String((issue as Dictionary).get("message", "")),
			"focus_target": HexMapValidationDashboard.issue_focus_target(issue as Dictionary),
			"fix_suggestion": HexMapValidationDashboard.issue_fix_suggestion(issue as Dictionary),
			"target_tab": String(route.get("target_tab", "")),
			"target_component_id": String(route.get("target_component_id", "")),
			"target_slot_id": String(route.get("target_slot_id", "")),
		}
		var navigation := _validate_issue_navigation(row, issue as Dictionary)
		row["destination_tab"] = String(navigation.get("target_tab", ""))
		row["destination_component_id"] = String(navigation.get("target_component_id", ""))
		row["destination_slot_id"] = String(navigation.get("target_slot_id", ""))
		row["focus_type"] = String(navigation.get("focus_type", ""))
		row["suggested_action"] = String(navigation.get("suggested_action", ""))
		row["target_text"] = _validate_issue_target_text(row)
		row["suggestion"] = String(row.get("fix_suggestion", ""))
		row["available_actions"] = _validate_issue_available_actions(navigation)
		row["action_count"] = (row["available_actions"] as Array).size()
		row["real_actions_only"] = _validate_issue_actions_are_real(row["available_actions"] as Array)
		rows.append(row)
		issue_index += 1
	return rows


func _validate_issue_table(issue_rows: Array) -> Dictionary:
	var action_count := 0
	var real_actions_only := true
	for row in issue_rows:
		if not row is Dictionary:
			continue
		var actions = (row as Dictionary).get("available_actions", []) as Array
		action_count += actions.size()
		if not _validate_issue_actions_are_real(actions):
			real_actions_only = false
	return {
		"surface_id": "validate_issue_table",
		"visible": true,
		"columns": PackedStringArray(["severity", "domain", "scope", "target", "suggestion", "actions"]),
		"rows": issue_rows,
		"row_count": issue_rows.size(),
		"action_count": action_count,
		"real_actions_only": real_actions_only,
		"rows_text": _validate_issue_table_rows_text(issue_rows),
		"primary_path_text_visible": false,
	}


func _validate_issue_target_text(row: Dictionary) -> String:
	var focus_target := String(row.get("focus_target", ""))
	if focus_target != "":
		return focus_target
	var destination_tab := String(row.get("destination_tab", ""))
	var destination_slot := String(row.get("destination_slot_id", ""))
	if destination_tab != "" and destination_slot != "":
		return "%s %s" % [destination_tab, destination_slot]
	if destination_tab != "":
		return destination_tab
	return String(row.get("rule_id", ""))


func _validate_issue_available_actions(navigation: Dictionary) -> Array[Dictionary]:
	var target_tab := String(navigation.get("target_tab", ""))
	if target_tab == "":
		return []
	return [{
		"id": "focus_issue",
		"label": "Focus in %s" % target_tab,
		"target_tab": target_tab,
		"target_component_id": String(navigation.get("target_component_id", "")),
		"target_slot_id": String(navigation.get("target_slot_id", "")),
		"focus_type": String(navigation.get("focus_type", "")),
		"action": "select_validate_issue",
		"real": true,
	}]


func _validate_issue_actions_are_real(actions: Array) -> bool:
	for action in actions:
		if not action is Dictionary:
			return false
		if String((action as Dictionary).get("id", "")) == "":
			return false
		if String((action as Dictionary).get("target_tab", "")) == "":
			return false
		if not bool((action as Dictionary).get("real", false)):
			return false
	return true


func select_validate_issue(index: int) -> Dictionary:
	var rows := validate_screen_issue_rows(_last_workspace_validation_result)
	if index < 0 or index >= rows.size():
		_selected_validate_issue_index = -1
		_selected_validate_issue_row.clear()
		_selected_validate_issue_navigation.clear()
		_refresh_validation_issue_navigator()
		var validation_state := validation_workflow_state_snapshot()
		return {
			"ok": false,
			"error": ERR_DOES_NOT_EXIST,
			"selected_tab": current_workspace_tab_name(),
			"validation_state": validation_state,
			"view_state": validation_state.get("view_state", {}),
		}
	var issue := _validate_issue_at_index(index)
	var row := (rows[index] as Dictionary).duplicate(true)
	var navigation := _validate_issue_navigation(row, issue)
	_selected_validate_issue_index = index
	_selected_validate_issue_row = row
	_selected_validate_issue_navigation = navigation
	var target_tab := String(navigation.get("target_tab", ""))
	if target_tab != "":
		select_workspace_tab(target_tab)
	_refresh_validation_issue_navigator()
	var validation_state := validation_workflow_state_snapshot()
	return {
		"ok": true,
		"error": OK,
		"issue_row": row.duplicate(true),
		"navigation": navigation.duplicate(true),
		"selected_tab": current_workspace_tab_name(),
		"validation_state": validation_state,
		"view_state": validation_state.get("view_state", {}),
	}


func _validate_issue_at_index(index: int) -> Dictionary:
	if _last_workspace_validation_result == null:
		return {}
	var row_index := 0
	for issue in _last_workspace_validation_result.issues:
		if not issue is Dictionary:
			continue
		if row_index == index:
			return (issue as Dictionary).duplicate(true)
		row_index += 1
	return {}


func _validate_issue_navigation(row: Dictionary, issue: Dictionary) -> Dictionary:
	var metadata = issue.get("metadata", {})
	var route: Dictionary = metadata if metadata is Dictionary else {}
	var target_tab := String(row.get("target_tab", route.get("target_tab", "")))
	var target_component_id := String(row.get("target_component_id", route.get("target_component_id", "")))
	var target_slot_id := String(row.get("target_slot_id", route.get("target_slot_id", "")))
	var focus_type := "asset_slot" if target_slot_id != "" else "none"
	if target_tab == "":
		var catalog_key := String(route.get("catalog_key", ""))
		var entry_key := String(route.get("entry_key", ""))
		if route.has("entry_index") or catalog_key != "" or entry_key != "":
			target_tab = HexMapWorkspaceComponentRegistry.TAB_CATALOG
			target_component_id = "catalog_detail_panel"
			focus_type = "catalog_entry"
	if target_tab == "":
		var cell = issue.get("cell", null)
		var scope := String(issue.get("scope", ""))
		if cell is Vector3i or scope == "cell" or scope == "object":
			target_tab = HexMapWorkspaceComponentRegistry.TAB_PAINT
			target_component_id = "brush_palette"
			focus_type = "cell"
	if target_tab == "":
		var dependency_path := String(issue.get("dependency_resource_path", ""))
		var dependency_id := String(route.get("dependency_id", ""))
		var dependency_kind := String(route.get("kind", ""))
		if dependency_path != "" or dependency_id != "" or dependency_kind != "":
			target_tab = _validate_dependency_target_tab(dependency_kind)
			target_component_id = _validate_dependency_target_component(dependency_kind)
			focus_type = "resource"
	if target_tab == "":
		target_tab = HexMapWorkspaceComponentRegistry.TAB_VALIDATE
		target_component_id = "validation_issue_navigator"
	return {
		"target_tab": target_tab,
		"target_component_id": target_component_id,
		"target_slot_id": target_slot_id,
		"focus_type": focus_type,
		"focus_target": String(row.get("focus_target", "")),
		"fix_suggestion": String(row.get("fix_suggestion", "")),
		"suggested_action": _validate_issue_suggested_action(row, issue, target_tab, target_slot_id, focus_type),
	}


func _validate_dependency_target_tab(kind: String) -> String:
	match kind:
		"tile_catalog", "tile_set":
			return HexMapWorkspaceComponentRegistry.TAB_CATALOG
		"object_database", "scene":
			return HexMapWorkspaceComponentRegistry.TAB_DOCUMENT
		"layer_stack":
			return HexMapWorkspaceComponentRegistry.TAB_LAYERS
		"generation_profile":
			return HexMapWorkspaceComponentRegistry.TAB_QA
		_:
			return HexMapWorkspaceComponentRegistry.TAB_DOCUMENT


func _validate_dependency_target_component(kind: String) -> String:
	match kind:
		"tile_catalog", "tile_set":
			return "catalog_detail_panel"
		"layer_stack":
			return "layer_stack_role_panel"
		"generation_profile":
			return "qa_asset_panel"
		_:
			return "document_asset_panel"


func _validate_issue_suggested_action(
	row: Dictionary,
	_issue: Dictionary,
	target_tab: String,
	target_slot_id: String,
	focus_type: String
) -> String:
	if target_slot_id != "":
		return "Select or create %s." % _resource_group_slot_label(target_slot_id)
	match focus_type:
		"catalog_entry":
			return "Open the Catalog issue target and fix the referenced entry."
		"cell":
			return "Open Paint and inspect the referenced cell."
		"resource":
			return "Open the referenced resource owner and assign the missing dependency."
		_:
			var fix := String(row.get("fix_suggestion", ""))
			return fix if fix != "" else "Review this issue in %s." % target_tab


func _validate_target_summary(context: HexMapWorkspaceAssetContext) -> String:
	var document_text := "Level Document linked" if context.level_document != null else "Level Document missing"
	var catalog_text := "Tile Catalog linked" if context.tile_catalog != null else "Tile Catalog missing"
	var suite_text := "Validation Suite linked" if context.validation_rule_suite != null else "Validation Suite missing"
	return "%s | %s | %s" % [document_text, catalog_text, suite_text]


func _validate_empty_state_text(issue_rows: Array) -> String:
	if _last_workspace_validation_result == null:
		return "Run validation to list workspace issues."
	if issue_rows.is_empty():
		return "Validation passed."
	return ""


func catalog_screen_snapshot() -> Dictionary:
	var context := workspace_asset_context()
	var screen_role := HexMapCatalogScreen.screen_contract()
	var ownership := HexMapCatalogScreen.ownership_fields()
	var catalog := context.tile_catalog
	var catalog_slot := tab_asset_slot_snapshot(
		HexMapWorkspaceComponentRegistry.TAB_CATALOG,
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG
	)
	var entry_rows := catalog_entry_rows()
	var entry_detail := catalog_entry_detail(_selected_catalog_entry_key)
	var validation_status := _catalog_validation_status(catalog)
	var empty_state := _catalog_tab_empty_state(entry_rows, entry_detail)
	var catalog_source := context.asset_source(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG)
	var catalog_source_badge := context.asset_source_badge(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG)
	var catalog_board := HexMapCatalogEditorComponent.visual_board(
		catalog,
		_selected_catalog_entry_key,
		catalog_source,
		catalog_source_badge
	)
	return {
		"tab": HexMapWorkspaceComponentRegistry.TAB_CATALOG,
		"screen_role": screen_role,
		"screen_script": String(screen_role.get("screen_script", "")),
		"screen_role_source": String(screen_role.get("screen_role_source", "")),
		"workflow_owner": String(screen_role.get("workflow_owner", "")),
		"component_ids": tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_CATALOG),
		"catalog_editor_component_owner": HexMapCatalogEditorComponent.SCREEN_ROLE_SOURCE,
		"catalog_component_owner_rows": catalog_editor_component_owner_rows(),
		"asset_slot_ids": tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_CATALOG),
		"purpose_text": String(empty_state.get("purpose_text", "")),
		"first_surface": "catalog_visual_board",
		"empty_state": empty_state,
		"empty_state_text": String(empty_state.get("empty_state_text", "")),
		"tile_catalog": catalog,
		"catalog_context_chips": PackedStringArray([
			"Catalog: %s" % _catalog_display_name(catalog),
		]),
		"context_chips": _work_tab_context_chips(HexMapWorkspaceComponentRegistry.TAB_CATALOG),
		"context_chips_visible": true,
		"context_chips_text": _join_text(_work_tab_context_chips(HexMapWorkspaceComponentRegistry.TAB_CATALOG), " "),
		"context_chips_detail_target": HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"global_map_chip_duplicated": false,
		"resource_row_primary": false,
		"catalog_source": catalog_source,
		"catalog_source_badge": catalog_source_badge,
		"catalog_slot": catalog_slot,
		"catalog_board": catalog_board,
		"catalog_board_primary": bool(catalog_board.get("primary", false)),
		"catalog_board_visible": bool(catalog_board.get("visible", false)),
		"catalog_board_cards": catalog_board.get("cards", []),
		"catalog_board_card_ids": catalog_board.get("card_keys", PackedStringArray()),
		"catalog_board_card_count": int(catalog_board.get("card_count", 0)),
		"catalog_board_tile_count": int(catalog_board.get("tile_card_count", 0)),
		"catalog_board_object_count": int(catalog_board.get("object_card_count", 0)),
		"tile_object_unified_board": bool(catalog_board.get("tile_object_unified", false)),
		"catalog_board_empty_cta": catalog_board.get("empty_cta", {}),
		"catalog_board_raw_source_id_visible": bool(catalog_board.get("raw_source_id_visible", false)),
		"catalog_board_raw_atlas_coords_visible": bool(catalog_board.get("raw_atlas_coords_visible", false)),
		"catalog_board_raw_metadata_in_tooltip": bool(catalog_board.get("raw_metadata_in_tooltip", false)),
		"sample_tutorial_source_separated": bool(catalog_board.get("sample_tutorial_source_separated", false)),
		"catalog_board_source_group": String(catalog_board.get("source_group", "")),
		"catalog_board_production_cards": int(catalog_board.get("production_cards_count", 0)),
		"catalog_board_tutorial_cards": int(catalog_board.get("tutorial_cards_count", 0)),
		"tile_set": catalog.tile_set if catalog != null else null,
		"tile_set_present": catalog != null and catalog.tile_set != null,
		"tile_set_tooltip": _catalog_tile_set_tooltip(),
		"detail_component_present": tab_has_component(HexMapWorkspaceComponentRegistry.TAB_CATALOG, "catalog_detail_panel"),
		"entry_count": catalog.entries.size() if catalog != null else 0,
		"entry_keys": catalog.keys() if catalog != null else PackedStringArray(),
		"entry_rows": entry_rows,
		"entry_detail": entry_detail,
		"selected_entry_key": String(entry_detail.get("key", "")),
		"entry_preview": entry_detail.get("preview", {}),
		"entry_preview_badge": entry_detail.get("preview_badge", {}),
		"mounted_preview_present": _catalog_detail_preview_control != null,
		"mounted_preview_snapshot": _catalog_detail_preview_control.preview_snapshot() if _catalog_detail_preview_control != null else HexTileCatalogPreviewControl.unavailable_preview("not_mounted"),
		"mounted_preview_badge_text": _catalog_detail_preview_badge_label.text if _catalog_detail_preview_badge_label != null else "",
		"mounted_preview_badge_tooltip": _catalog_detail_preview_badge_label.tooltip_text if _catalog_detail_preview_badge_label != null else "",
		"selected_entry": entry_detail,
		"catalog_entry_workflow_owner": String(ownership.get("catalog_entry_workflow_owner", "Catalog")),
		"entry_list_visible": true,
		"entry_detail_visible": true,
		"tile_preview_visible": bool(entry_detail.get("preview_available", false)) \
			and String(entry_detail.get("preview_kind", "")) == "tile",
		"scene_preview_visible": bool(entry_detail.get("preview_available", false)) \
			and String(entry_detail.get("preview_kind", "")) == "scene",
		"tags_status_visible": true,
		"create_edit_entry_available": catalog != null and catalog.tile_set != null,
		"create_atlas_entry_available": catalog != null and catalog.tile_set != null,
		"create_scene_entry_available": catalog != null,
		"validate_catalog_available": catalog != null,
		"catalog_validation_status": validation_status,
		"paint_catalog_entry_management_visible": bool(ownership.get("paint_catalog_entry_management_visible", false)),
		"primary_input_fields": PackedStringArray([
			"catalog_resource",
			"tile_set",
			"entry_list",
			"entry_detail",
			"create_from_selected_tile",
			"create_from_selected_scene",
		]),
		"metadata_fields": PackedStringArray([
			"source_id",
			"atlas_coords",
			"alternative_tile",
		]),
		"raw_coordinate_controls_primary": false,
		"sample_candidates_visible": _ensure_session_state().show_bundled_samples_in_main_selectors,
	}


func _catalog_validation_status(catalog: HexTileCatalogResource) -> Dictionary:
	return HexMapCatalogEditorComponent.validation_status(catalog)


func catalog_editor_component_owner_rows() -> Array[Dictionary]:
	return HexMapCatalogEditorComponent.component_owner_rows()


func catalog_entry_rows() -> Array[Dictionary]:
	var catalog := workspace_asset_context().tile_catalog
	return HexMapCatalogEditorComponent.entry_rows(catalog)


func catalog_entry_detail(entry_key: String = "") -> Dictionary:
	var catalog := workspace_asset_context().tile_catalog
	return HexMapCatalogEditorComponent.entry_detail(catalog, entry_key)


func _catalog_display_name(catalog: HexTileCatalogResource) -> String:
	if catalog == null:
		return "Missing"
	var display_name := String(catalog.display_name)
	if display_name != "":
		return display_name
	var catalog_id := String(catalog.catalog_id)
	return catalog_id if catalog_id != "" else "Unnamed Catalog"


func select_catalog_entry(entry_key: String) -> Dictionary:
	_selected_catalog_entry_key = entry_key.strip_edges()
	var detail := catalog_entry_detail(_selected_catalog_entry_key)
	_refresh_catalog_detail_panel()
	return detail


func create_tile_catalog(path: String) -> Dictionary:
	var panel := _catalog_asset_panel()
	if panel == null:
		return _catalog_action_result(false, ERR_UNAVAILABLE, path)
	var result := panel.create_asset_for_slot(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, path)
	_refresh_catalog_detail_panel()
	return result


func save_tile_catalog_as(path: String) -> Dictionary:
	var panel := _catalog_asset_panel()
	if panel == null:
		return _catalog_action_result(false, ERR_UNAVAILABLE, path)
	var result := panel.save_asset_slot_as(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, path)
	_refresh_catalog_detail_panel()
	return result


func open_tile_catalog() -> Dictionary:
	var panel := _catalog_asset_panel()
	if panel == null:
		return _catalog_action_result(false, ERR_UNAVAILABLE, "")
	var result := panel.open_asset_slot(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG)
	_refresh_catalog_detail_panel()
	return result


func clear_tile_catalog() -> Dictionary:
	var panel := _catalog_asset_panel()
	if panel == null:
		return _catalog_action_result(false, ERR_UNAVAILABLE, "")
	var result := panel.clear_asset_slot(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG)
	_refresh_catalog_detail_panel()
	return result


func set_catalog_tile_set(tile_set: TileSet) -> Dictionary:
	var catalog := workspace_asset_context().tile_catalog
	var result := HexMapCatalogEditorComponent.set_tile_set(catalog, tile_set)
	if bool(result.get("ok", false)):
		_sync_workspace_asset_context()
	_refresh_catalog_detail_panel()
	return result


func create_catalog_atlas_entry_from_tileset(
	key: String,
	tile_set: TileSet,
	source_id: int,
	atlas_coords: Vector2i,
	alternative_tile: int = 0
) -> Dictionary:
	var catalog := workspace_asset_context().tile_catalog
	var result := HexMapCatalogEditorComponent.create_atlas_entry(
		catalog,
		key,
		tile_set,
		source_id,
		atlas_coords,
		alternative_tile
	)
	if bool(result.get("ok", false)):
		_sync_workspace_asset_context()
	_refresh_catalog_detail_panel()
	return result


func create_catalog_scene_entry_from_packed_scene(
	key: String,
	scene: PackedScene,
	source_id: int = 1,
	scene_tile_id: int = 1
) -> Dictionary:
	var catalog := workspace_asset_context().tile_catalog
	var result := HexMapCatalogEditorComponent.create_scene_entry(catalog, key, scene, source_id, scene_tile_id)
	if bool(result.get("ok", false)):
		_sync_workspace_asset_context()
	_refresh_catalog_detail_panel()
	return result


func validate_tile_catalog():
	return HexMapCatalogEditorComponent.validation_result(workspace_asset_context().tile_catalog)


func layer_stack_screen_snapshot() -> Dictionary:
	var context := workspace_asset_context()
	var screen_role := HexMapLayersScreen.screen_contract()
	var ownership := HexMapLayersScreen.ownership_fields()
	var stack := context.layer_stack
	var stack_slot := tab_asset_slot_snapshot(
		HexMapWorkspaceComponentRegistry.TAB_LAYERS,
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK
	)
	var target_status := _edit_tool.target_readiness_status() if _edit_tool != null else {}
	var role_rows: Array = []
	if _edit_tool != null and stack != null:
		for row in _edit_tool.layer_stack_rows():
			role_rows.append(row)
	var role_status_counts := _layer_stack_role_status_counts(role_rows)
	var relationship := _layer_stack_relationship_snapshot(stack)
	var empty_state := _layers_tab_empty_state(role_rows, relationship)
	var role_tree_summary := _layer_role_tree_summary(role_rows, role_status_counts, relationship)
	var role_editor := _layer_role_editor_snapshot(role_rows, relationship)
	var role_stack_visual := HexMapLayersScreen.role_stack_visual(
		role_rows,
		role_status_counts,
		relationship,
		String(role_editor.get("selected_role", ""))
	)
	var layer_context_chips := _work_tab_context_chips(HexMapWorkspaceComponentRegistry.TAB_LAYERS)
	return {
		"tab": HexMapWorkspaceComponentRegistry.TAB_LAYERS,
		"screen_role": screen_role,
		"screen_script": String(screen_role.get("screen_script", "")),
		"screen_role_source": String(screen_role.get("screen_role_source", "")),
		"workflow_owner": String(screen_role.get("workflow_owner", "")),
		"component_ids": tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_LAYERS),
		"asset_slot_ids": tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_LAYERS),
		"purpose_text": String(empty_state.get("purpose_text", "")),
		"first_surface": "layer_role_stack_visual",
		"empty_state": empty_state,
		"empty_state_text": String(empty_state.get("empty_state_text", "")),
		"layer_stack": stack,
		"layer_context_chips": layer_context_chips,
		"context_chips": layer_context_chips,
		"context_chips_visible": true,
		"context_chips_text": _join_text(layer_context_chips, " "),
		"context_chips_detail_target": HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"global_map_chip_duplicated": false,
		"resource_row_primary": false,
		"layer_stack_slot": stack_slot,
		"role_component_present": tab_has_component(HexMapWorkspaceComponentRegistry.TAB_LAYERS, "layer_stack_role_panel"),
		"role_stack_visual_component_present": tab_has_component(HexMapWorkspaceComponentRegistry.TAB_LAYERS, "layer_role_stack_visual"),
		"stack_id": stack.stack_id if stack != null else "",
		"display_name": stack.display_name if stack != null else "",
		"role_count": stack.layers.size() if stack != null else 0,
		"role_names": stack.role_names() if stack != null else PackedStringArray(),
		"required_role_names": _layer_stack_required_role_names(),
		"role_rows": role_rows,
		"role_status_counts": role_status_counts,
		"role_stack_visual": role_stack_visual,
		"layer_role_stack_visual": role_stack_visual,
		"role_stack_visual_primary": bool(role_stack_visual.get("primary", false)),
		"role_stack_visual_rows": role_stack_visual.get("role_cards", []),
		"role_stack_visual_role_count": int(role_stack_visual.get("role_count", 0)),
		"role_stack_visual_role_names": role_stack_visual.get("role_names", PackedStringArray()),
		"role_stack_visual_empty_cta": role_stack_visual.get("empty_cta", {}),
		"role_stack_visual_chip_types": role_stack_visual.get("chip_types", {}),
		"role_stack_chips_visible": bool(role_stack_visual.get("chips_visible", false)),
		"role_stack_toggles_visible": bool(role_stack_visual.get("toggles_visible", false)),
		"writable_source_visible": bool(role_stack_visual.get("writable_source_visible", false)),
		"role_stack_resource_reference_text_visible": bool(role_stack_visual.get("resource_reference_text_visible", false)),
		"role_tree_summary": role_tree_summary,
		"role_tree_rows_text": String(role_tree_summary.get("role_rows_text", "")),
		"mounted_role_tree_summary_text": _layer_stack_role_tree_summary_label.text if _layer_stack_role_tree_summary_label != null else "",
		"role_editor": role_editor,
		"selected_role": String(role_editor.get("selected_role", "")),
		"role_editor_controls": role_editor.get("controls", {}),
		"mounted_role_editor_text": _layer_stack_role_editor_summary_label.text if _layer_stack_role_editor_summary_label != null else "",
		"target_status": target_status,
		"target_layer": _edit_tool.target_layer() if _edit_tool != null else null,
		"selected_hex_tile_map": selected_hex_tile_map_snapshot(),
		"relationship": relationship,
		"layer_actions": _layer_stack_action_availability(stack, target_status, role_status_counts),
		"template_candidates": PackedStringArray(["standard", "minimal"]),
		"sample_template_present": false,
		"layer_workflow_owner": String(ownership.get("layer_workflow_owner", "Layers")),
		"layer_management_visible": bool(ownership.get("layer_management_visible", true)),
		"role_actions_owner": String(screen_role.get("workflow_owner", "Layers")),
		"role_list_visible": true,
		"template_controls_visible": true,
		"paint_layer_management_visible": bool(ownership.get("paint_layer_management_visible", false)),
	}


func _layer_stack_required_role_names() -> PackedStringArray:
	return PackedStringArray([
		HexLayerStackResource.ROLE_TERRAIN,
		HexLayerStackResource.ROLE_OVERLAY,
		HexLayerStackResource.ROLE_OBJECT,
		HexLayerStackResource.ROLE_DEBUG,
		HexLayerStackResource.ROLE_COLLISION,
		HexLayerStackResource.ROLE_NAVIGATION,
	])


func _layer_stack_role_status_counts(role_rows: Array) -> Dictionary:
	var counts := {
		"total": role_rows.size(),
		"ok": 0,
		"missing": 0,
		"visible": 0,
		"hidden": 0,
		"locked": 0,
		"writable": 0,
	}
	for row in role_rows:
		if not row is Dictionary:
			continue
		var status := String((row as Dictionary).get("status", ""))
		if status == "ok":
			counts["ok"] = int(counts["ok"]) + 1
		elif status == "missing":
			counts["missing"] = int(counts["missing"]) + 1
		if bool((row as Dictionary).get("visible", false)):
			counts["visible"] = int(counts["visible"]) + 1
		else:
			counts["hidden"] = int(counts["hidden"]) + 1
		if bool((row as Dictionary).get("locked", false)):
			counts["locked"] = int(counts["locked"]) + 1
		if String((row as Dictionary).get("writable", "")) != "" and not bool((row as Dictionary).get("locked", false)):
			counts["writable"] = int(counts["writable"]) + 1
	return counts


func _layer_stack_relationship_snapshot(stack: HexLayerStackResource) -> Dictionary:
	var selected_snapshot := selected_hex_tile_map_snapshot()
	var selected := bool(selected_snapshot.get("selected", false))
	var selected_node = selected_snapshot.get("selected_node", null) as HexTileMapLayer
	var target = _edit_tool.target_layer() if _edit_tool != null else null
	var writeback = selected_snapshot.get("writeback", {}) as Dictionary
	var relationships = writeback.get("relationships", {}) as Dictionary
	var node_relationship = relationships.get(
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
		HexMapWorkspaceBindingService.relationship_for_slot(
			selected_node,
			workspace_asset_context(),
			HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
			"Selected HexTileMap Layer Stack"
		)
	) as Dictionary
	var status := String(node_relationship.get("status", "missing"))
	var message := "Layer Stack is linked to the selected HexTileMap."
	if not selected:
		status = "no_selected_hex_tile_map"
		message = "Select a HexTileMap node to target layer role actions."
	elif stack == null:
		status = "missing_layer_stack"
		message = "Create or select a Layer Stack for this HexTileMap."
	elif target == null:
		status = "no_target_hex_tile_map"
		message = "Select a HexTileMap target before creating or applying child layers."
	elif target != selected_node:
		status = "target_mismatch"
		message = "Layer target differs from the selected HexTileMap."
	elif status == "workspace_pending_node_writeback":
		message = "Layer Stack is selected in the workspace and ready to write to the selected HexTileMap."
	elif status == "node_only":
		message = "Selected HexTileMap has a Layer Stack that is not in the workspace context."
	elif status == "different":
		message = "Workspace Layer Stack differs from the selected HexTileMap."
	elif status == "missing":
		message = "Create or select a Layer Stack for this HexTileMap."
	return {
		"status": status,
		"message": message,
		"selected_node": selected_node,
		"selected_node_name": selected_node.name if selected_node != null else "",
		"selected_node_path": String(selected_snapshot.get("node_path", "")),
		"target_layer": target,
		"target_node_name": target.name if target != null else "",
		"target_matches_selected": selected and target == selected_node,
		"layer_stack": stack,
		"node_layer_stack": node_relationship.get("node_resource", null),
		"workspace_layer_stack": node_relationship.get("workspace_resource", null),
		"relationship": node_relationship,
	}


func _layer_stack_action_availability(
	stack: HexLayerStackResource,
	target_status: Dictionary,
	role_status_counts: Dictionary
) -> Dictionary:
	var target_is_hex := bool(target_status.get("is_hex_tile_map_layer", false))
	var document_present := bool(target_status.get("document_present", false))
	var missing_count := int(role_status_counts.get("missing", 0))
	var ok_count := int(role_status_counts.get("ok", 0))
	var blocked_reason := ""
	if stack == null:
		blocked_reason = "Layer Stack is not selected."
	elif not target_is_hex:
		blocked_reason = "Target HexTileMap is not selected."
	return {
		"create_missing_layers": stack != null and target_is_hex and missing_count > 0,
		"apply_document": stack != null and target_is_hex and document_present,
		"clear_role": stack != null and target_is_hex and ok_count > 0,
		"blocked_reason": blocked_reason,
	}


func _layer_role_tree_summary(
	role_rows: Array,
	counts: Dictionary,
	relationship: Dictionary
) -> Dictionary:
	var visible_text := "Relationship: %s | Roles: %d | Missing: %d | Writable: %d" % [
		String(relationship.get("status", "")),
		int(counts.get("total", 0)),
		int(counts.get("missing", 0)),
		int(counts.get("writable", 0)),
	]
	return {
		"surface_id": "layer_role_tree",
		"visible": true,
		"relationship_status": String(relationship.get("status", "")),
		"relationship_text": String(relationship.get("message", "")),
		"role_count": int(counts.get("total", 0)),
		"missing_count": int(counts.get("missing", 0)),
		"writable_count": int(counts.get("writable", 0)),
		"locked_count": int(counts.get("locked", 0)),
		"visible_text": visible_text,
		"role_rows": role_rows,
		"role_rows_text": _layer_stack_role_rows_text(role_rows),
		"primary_path_text_visible": false,
	}


func _layer_role_editor_snapshot(role_rows: Array, relationship: Dictionary) -> Dictionary:
	var selected_role := _normalized_layer_stack_editor_role(role_rows)
	var row := _layer_stack_row_for_role(role_rows, selected_role)
	var target_role_layer = _target_role_layer_for_role(selected_role)
	var target_status := "missing"
	if target_role_layer != null:
		target_status = "reflected"
	elif selected_role == "":
		target_status = "no_role"
	var visible := bool(row.get("visible", false)) if not row.is_empty() else false
	var locked := bool(row.get("locked", false)) if not row.is_empty() else false
	var z_index := int(row.get("z_index", 0)) if not row.is_empty() else 0
	var writable := String(row.get("writable", "document")) if not row.is_empty() else "document"
	var visible_text := "Role: %s | Status: %s | Visible: %s | Locked: %s | Z: %d | Writable: %s | Target: %s" % [
		selected_role if selected_role != "" else "none",
		String(row.get("status", "unavailable")) if not row.is_empty() else String(relationship.get("status", "")),
		_bool_label(visible),
		_bool_label(locked),
		z_index,
		writable,
		target_status,
	]
	return {
		"surface_id": "layer_role_editor",
		"visible": true,
		"editable": selected_role != "" and not row.is_empty(),
		"selected_role": selected_role,
		"role_row": row,
		"visible_value": visible,
		"locked_value": locked,
		"z_index_value": z_index,
		"writable_source": writable,
		"writable_source_options": PackedStringArray(LAYER_ROLE_WRITABLE_SOURCES),
		"target_reflection_status": target_status,
		"target_reflected": target_role_layer != null,
		"target_role_layer": target_role_layer,
		"target_node_name": target_role_layer.name if target_role_layer != null else "",
		"target_visible": bool(target_role_layer.visible) if target_role_layer is CanvasItem else false,
		"target_z_index": int(target_role_layer.z_index) if target_role_layer is CanvasItem else 0,
		"target_locked": bool(target_role_layer.get_meta("hex_layer_stack_locked", false)) if target_role_layer != null else false,
		"target_writable_source": String(target_role_layer.get_meta("hex_layer_stack_writable_source", "")) if target_role_layer != null else "",
		"visible_text": visible_text,
		"controls": {
			"role": "OptionButton",
			"visible": "CheckBox",
			"locked": "CheckBox",
			"z_index": "SpinBox",
			"writable_source": "OptionButton",
		},
		"primary_path_text_visible": false,
	}


func _normalized_layer_stack_editor_role(role_rows: Array) -> String:
	var roles := PackedStringArray()
	for row in role_rows:
		if row is Dictionary:
			var role := String((row as Dictionary).get("role", ""))
			if role != "":
				roles.append(role)
	if roles.has(_selected_layer_stack_editor_role):
		return _selected_layer_stack_editor_role
	_selected_layer_stack_editor_role = roles[0] if roles.size() > 0 else ""
	return _selected_layer_stack_editor_role


func _layer_stack_row_for_role(role_rows: Array, role: String) -> Dictionary:
	for row in role_rows:
		if row is Dictionary and String((row as Dictionary).get("role", "")) == role:
			return row as Dictionary
	return {}


func _target_role_layer_for_role(role: String):
	if role == "" or _edit_tool == null:
		return null
	var target = _edit_tool.target_layer()
	if not target is HexTileMapLayer:
		return null
	return (target as HexTileMapLayer).layer_for_stack_role(role)


func create_layer_stack(path: String) -> Dictionary:
	var panel := _layer_stack_asset_panel()
	if panel == null:
		return _layer_stack_action_result(false, ERR_UNAVAILABLE, path)
	var result := panel.create_asset_for_slot(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK, path)
	_sync_layer_stack_from_result(result)
	return result


func save_layer_stack_as(path: String) -> Dictionary:
	var panel := _layer_stack_asset_panel()
	if panel == null:
		return _layer_stack_action_result(false, ERR_UNAVAILABLE, path)
	var result := panel.save_asset_slot_as(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK, path)
	_sync_layer_stack_from_result(result)
	return result


func open_layer_stack() -> Dictionary:
	var panel := _layer_stack_asset_panel()
	if panel == null:
		return _layer_stack_action_result(false, ERR_UNAVAILABLE, "")
	var result := panel.open_asset_slot(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK)
	_sync_layer_stack_from_result(result)
	return result


func clear_layer_stack() -> Dictionary:
	var panel := _layer_stack_asset_panel()
	if panel == null:
		return _layer_stack_action_result(false, ERR_UNAVAILABLE, "")
	var result := panel.clear_asset_slot(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK)
	if _edit_tool != null:
		_edit_tool.set_layer_stack_resource(null, false)
	_refresh_layer_stack_role_panel()
	return result


func duplicate_layer_stack_template_to_project(template_id: String, path: String) -> Dictionary:
	var stack := _layer_stack_template(template_id)
	var actual_path := HexMapWorkspaceAssetResourceFactory.normalized_resource_path(path)
	if stack == null or actual_path == "":
		return _layer_stack_action_result(false, ERR_INVALID_PARAMETER, actual_path)
	stack.resource_name = "Project %s" % stack.display_name
	stack.metadata["template_source"] = template_id
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(actual_path.get_base_dir()))
	var error := ResourceSaver.save(stack, actual_path)
	if error == OK:
		stack.resource_path = actual_path
		workspace_asset_context().set_layer_stack(stack)
		_sync_workspace_asset_context()
	_refresh_layer_stack_role_panel()
	return {
		"ok": error == OK,
		"error": error,
		"slot_id": HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
		"path": actual_path,
		"resource": stack,
		"template_id": template_id,
	}


func pick_layer_stack_target_root(scene_root: Node) -> Dictionary:
	if _edit_tool == null or scene_root == null:
		return _layer_stack_action_result(false, ERR_INVALID_PARAMETER, "")
	_edit_tool.refresh_target_layer_options(scene_root)
	_refresh_layer_stack_role_panel()
	return {
		"ok": _edit_tool.target_layer() != null,
		"error": OK if _edit_tool.target_layer() != null else ERR_DOES_NOT_EXIST,
		"target_layer": _edit_tool.target_layer(),
		"target_status": _edit_tool.target_readiness_status(),
		"role_rows": _edit_tool.layer_stack_rows(),
	}


func set_layer_stack_target_layer(layer: Node) -> Dictionary:
	if _edit_tool == null:
		return _layer_stack_action_result(false, ERR_UNAVAILABLE, "")
	_edit_tool.set_target_layer(layer)
	_refresh_layer_stack_role_panel()
	return {
		"ok": _edit_tool.target_layer() != null,
		"error": OK if _edit_tool.target_layer() != null else ERR_DOES_NOT_EXIST,
		"target_layer": _edit_tool.target_layer(),
		"target_status": _edit_tool.target_readiness_status(),
		"role_rows": _edit_tool.layer_stack_rows(),
	}


func select_layer_stack_role(role: String) -> Dictionary:
	var selected_role := role.strip_edges()
	if selected_role == "":
		return _layer_stack_role_edit_result(false, ERR_INVALID_PARAMETER, selected_role, false, null)
	var stack := workspace_asset_context().layer_stack
	if stack == null or stack.first_layer_for_role(selected_role) == null:
		return _layer_stack_role_edit_result(false, ERR_DOES_NOT_EXIST, selected_role, false, null)
	_selected_layer_stack_editor_role = selected_role
	_refresh_layer_stack_role_panel()
	var target_role_layer = _target_role_layer_for_role(selected_role)
	return _layer_stack_role_edit_result(true, OK, selected_role, target_role_layer != null, target_role_layer)


func update_layer_stack_role_properties(role: String, properties: Dictionary) -> Dictionary:
	var selected_role := role.strip_edges()
	if selected_role == "":
		selected_role = _selected_layer_stack_editor_role
	if selected_role == "":
		return _layer_stack_role_edit_result(false, ERR_INVALID_PARAMETER, selected_role, false, null)
	var stack := workspace_asset_context().layer_stack
	if stack == null:
		return _layer_stack_role_edit_result(false, ERR_DOES_NOT_EXIST, selected_role, false, null)
	var entry = stack.first_layer_for_role(selected_role)
	if entry == null:
		return _layer_stack_role_edit_result(false, ERR_DOES_NOT_EXIST, selected_role, false, null)
	var metadata = entry.get("metadata")
	var next_metadata := (metadata as Dictionary).duplicate(true) if metadata is Dictionary else {}
	if properties.has("visible"):
		entry.set("visible", bool(properties.get("visible")))
	if properties.has("z_index"):
		entry.set("z_index", int(properties.get("z_index")))
	if properties.has("locked"):
		next_metadata["locked"] = bool(properties.get("locked"))
	var writable_key := "writable_source" if properties.has("writable_source") else "writable"
	if properties.has(writable_key):
		var writable_source := _normalized_layer_stack_writable_source(properties.get(writable_key))
		if writable_source == "":
			return _layer_stack_role_edit_result(false, ERR_INVALID_PARAMETER, selected_role, false, null)
		next_metadata["writable_source"] = writable_source
	entry.set("metadata", next_metadata)
	if entry.has_method("emit_changed"):
		entry.emit_changed()
	if stack.has_method("emit_changed"):
		stack.emit_changed()
	_selected_layer_stack_editor_role = selected_role
	if _edit_tool != null:
		_edit_tool.set_layer_stack_resource(stack, false)
	var target_role_layer = _target_role_layer_for_role(selected_role)
	var reflected := false
	if target_role_layer != null:
		_apply_layer_stack_entry_state_to_target_layer(entry, target_role_layer)
		reflected = true
	_refresh_layer_stack_role_panel()
	return _layer_stack_role_edit_result(true, OK, selected_role, reflected, target_role_layer)


func _layer_stack_role_edit_result(ok: bool, error: int, role: String, reflected: bool, target_role_layer) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"slot_id": HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
		"role": role,
		"role_rows": _edit_tool.layer_stack_rows() if _edit_tool != null else [],
		"role_editor": (layer_stack_screen_snapshot().get("role_editor", {}) as Dictionary) if ok else {},
		"target_reflected": reflected,
		"target_role_layer": target_role_layer,
	}


func _normalized_layer_stack_writable_source(source) -> String:
	var value := String(source).strip_edges()
	if value == "":
		return "document"
	var options := PackedStringArray(LAYER_ROLE_WRITABLE_SOURCES)
	return value if options.has(value) else ""


func _apply_layer_stack_entry_state_to_target_layer(entry: Resource, target_role_layer: Node) -> void:
	if entry == null or target_role_layer == null:
		return
	if target_role_layer is CanvasItem:
		var canvas_item := target_role_layer as CanvasItem
		canvas_item.visible = bool(entry.get("visible"))
		canvas_item.z_index = int(entry.get("z_index"))
	var metadata = entry.get("metadata")
	var locked := bool((metadata as Dictionary).get("locked", false)) if metadata is Dictionary else false
	var writable_source := String((metadata as Dictionary).get("writable_source", "document")) if metadata is Dictionary else "document"
	target_role_layer.set_meta("hex_layer_stack_role", String(entry.get("role")))
	target_role_layer.set_meta("hex_layer_stack_locked", locked)
	target_role_layer.set_meta("hex_layer_stack_writable_source", writable_source)


func set_layer_stack_document(document: HexMapDocumentResource) -> Dictionary:
	if _edit_tool == null or document == null:
		return _layer_stack_action_result(false, ERR_INVALID_PARAMETER, "")
	_edit_tool.set_document(document)
	_refresh_layer_stack_role_panel()
	return {
		"ok": true,
		"error": OK,
		"document": document,
		"target_status": _edit_tool.target_readiness_status(),
	}


func create_missing_layer_stack_layers() -> Dictionary:
	if _edit_tool == null:
		return _layer_stack_action_result(false, ERR_UNAVAILABLE, "")
	var ok := _edit_tool.create_missing_layer_stack_layers()
	_refresh_layer_stack_role_panel()
	return {
		"ok": ok,
		"error": OK if ok else ERR_UNAVAILABLE,
		"role_rows": _edit_tool.layer_stack_rows(),
		"target_status": _edit_tool.target_readiness_status(),
	}


func apply_layer_stack_document_to_target() -> Dictionary:
	if _edit_tool == null:
		return _layer_stack_action_result(false, ERR_UNAVAILABLE, "")
	var ok := _edit_tool.apply_layer_stack_document_to_target()
	_refresh_layer_stack_role_panel()
	return {
		"ok": ok,
		"error": OK if ok else ERR_UNAVAILABLE,
		"role_rows": _edit_tool.layer_stack_rows(),
		"target_status": _edit_tool.target_readiness_status(),
	}


func clear_layer_stack_role(role: String) -> Dictionary:
	if _edit_tool == null:
		return _layer_stack_action_result(false, ERR_UNAVAILABLE, "")
	var ok := _edit_tool.clear_layer_stack_role(role)
	_refresh_layer_stack_role_panel()
	return {
		"ok": ok,
		"error": OK if ok else ERR_UNAVAILABLE,
		"role": role,
		"role_rows": _edit_tool.layer_stack_rows(),
		"target_status": _edit_tool.target_readiness_status(),
	}


func object_label_screen_snapshot() -> Dictionary:
	var context := workspace_asset_context()
	var object_database := context.object_database
	var label_database := context.label_database
	var object_slot := tab_asset_slot_snapshot(
		HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE
	)
	var label_slot := tab_asset_slot_snapshot(
		HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE
	)
	return {
		"tab": HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"component_ids": tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_DOCUMENT),
		"asset_slot_ids": tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_DOCUMENT),
		"object_database": object_database,
		"label_database": label_database,
		"object_database_slot": object_slot,
		"label_database_slot": label_slot,
		"object_definition_count": object_database.definitions.size() if object_database != null else 0,
		"object_definition_ids": object_database.definition_ids() if object_database != null else PackedStringArray(),
		"object_definition_rows": _edit_tool.object_definition_rows() if _edit_tool != null else [],
		"selected_object_definition_id": _edit_tool.selected_object_definition_id() if _edit_tool != null else "",
		"object_payload": _edit_tool.object_placement_payload_snapshot() if _edit_tool != null else {},
		"label_definition_count": label_database.definitions.size() if label_database != null else 0,
		"label_definition_ids": label_database.definition_ids() if label_database != null else PackedStringArray(),
		"label_definition_rows": _edit_tool.label_definition_rows() if _edit_tool != null else [],
		"selected_label_definition_id": _edit_tool.selected_label_definition_id() if _edit_tool != null else "",
		"label_payload": _edit_tool.label_placement_payload_snapshot() if _edit_tool != null else {},
		"sample_object_scene_assigned": false,
	}


func create_object_database(path: String) -> Dictionary:
	var panel := _object_label_asset_panel()
	if panel == null:
		return _object_database_action_result(false, ERR_UNAVAILABLE, path)
	var result := panel.create_asset_for_slot(HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE, path)
	_sync_object_database_from_result(result)
	return result


func save_object_database_as(path: String) -> Dictionary:
	var panel := _object_label_asset_panel()
	if panel == null:
		return _object_database_action_result(false, ERR_UNAVAILABLE, path)
	var result := panel.save_asset_slot_as(HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE, path)
	_sync_object_database_from_result(result)
	return result


func open_object_database() -> Dictionary:
	var panel := _object_label_asset_panel()
	if panel == null:
		return _object_database_action_result(false, ERR_UNAVAILABLE, "")
	var result := panel.open_asset_slot(HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE)
	_sync_object_database_from_result(result)
	return result


func clear_object_database() -> Dictionary:
	var panel := _object_label_asset_panel()
	if panel == null:
		return _object_database_action_result(false, ERR_UNAVAILABLE, "")
	var result := panel.clear_asset_slot(HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE)
	if _edit_tool != null:
		_edit_tool.set_object_database(null, false)
	return result


func create_label_database(path: String) -> Dictionary:
	var panel := _object_label_asset_panel()
	if panel == null:
		return _label_database_action_result(false, ERR_UNAVAILABLE, path)
	var result := panel.create_asset_for_slot(HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE, path)
	_sync_label_database_from_result(result)
	return result


func save_label_database_as(path: String) -> Dictionary:
	var panel := _object_label_asset_panel()
	if panel == null:
		return _label_database_action_result(false, ERR_UNAVAILABLE, path)
	var result := panel.save_asset_slot_as(HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE, path)
	_sync_label_database_from_result(result)
	return result


func open_label_database() -> Dictionary:
	var panel := _object_label_asset_panel()
	if panel == null:
		return _label_database_action_result(false, ERR_UNAVAILABLE, "")
	var result := panel.open_asset_slot(HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE)
	_sync_label_database_from_result(result)
	return result


func clear_label_database() -> Dictionary:
	var panel := _object_label_asset_panel()
	if panel == null:
		return _label_database_action_result(false, ERR_UNAVAILABLE, "")
	var result := panel.clear_asset_slot(HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE)
	if _edit_tool != null:
		_edit_tool.set_label_database(null, false)
	return result


func create_object_definition_from_packed_scene(
	definition_id: String,
	scene: PackedScene,
	display_name: String = "",
	preview_texture: Texture2D = null
) -> Dictionary:
	var database := workspace_asset_context().object_database
	var object_id := definition_id.strip_edges()
	if database == null or scene == null or object_id == "":
		return _object_definition_action_result(false, ERR_INVALID_PARAMETER, object_id, null)
	var definition := HexObjectDefinitionResource.new()
	definition.id = object_id
	definition.display_name = display_name if display_name != "" else object_id
	definition.scene = scene
	definition.preview_texture = preview_texture
	definition.tags = PackedStringArray(["object"])
	database.add_definition(definition)
	if _edit_tool != null:
		_edit_tool.set_object_database(database, false)
		_edit_tool.select_object_definition_id(object_id)
	return _object_definition_action_result(true, OK, object_id, definition)


func select_object_definition(definition_id: String) -> Dictionary:
	if _edit_tool == null:
		return _object_definition_action_result(false, ERR_UNAVAILABLE, definition_id, null)
	var ok := _edit_tool.select_object_definition_id(definition_id)
	return {
		"ok": ok,
		"error": OK if ok else ERR_DOES_NOT_EXIST,
		"definition_id": definition_id,
		"payload": _edit_tool.object_placement_payload_snapshot(),
	}


func create_label_definition(
	label_id: String,
	display_name: String = "",
	default_text: String = "",
	style_key: String = ""
) -> Dictionary:
	var database := workspace_asset_context().label_database
	var definition_id := label_id.strip_edges()
	if database == null or definition_id == "":
		return _label_definition_action_result(false, ERR_INVALID_PARAMETER, definition_id, null)
	var definition := HexLabelDefinitionResource.new()
	definition.label_id = definition_id
	definition.display_name = display_name if display_name != "" else definition_id
	definition.default_text = default_text
	definition.style_key = style_key
	definition.tags = PackedStringArray(["label"])
	database.add_definition(definition)
	if _edit_tool != null:
		_edit_tool.set_label_database(database, false)
		_edit_tool.select_label_definition_id(definition_id)
	return _label_definition_action_result(true, OK, definition_id, definition)


func select_label_definition(label_id: String) -> Dictionary:
	if _edit_tool == null:
		return _label_definition_action_result(false, ERR_UNAVAILABLE, label_id, null)
	var ok := _edit_tool.select_label_definition_id(label_id)
	return {
		"ok": ok,
		"error": OK if ok else ERR_DOES_NOT_EXIST,
		"label_id": label_id,
		"payload": _edit_tool.label_placement_payload_snapshot(),
	}


func paint_brush_screen_snapshot() -> Dictionary:
	var screen_role := HexMapPaintScreen.screen_contract()
	var paint_workspace := _edit_tool.paint_workspace_snapshot() if _edit_tool != null else {}
	var interaction_state = paint_workspace.get("interaction_state", {}) as Dictionary
	var view_state = paint_workspace.get("view_state", {}) as Dictionary
	var target_state = view_state.get("target", {}) as Dictionary
	var document_state = view_state.get("document", {}) as Dictionary
	var brush_state = view_state.get("brush", {}) as Dictionary
	var selected_cell_state = view_state.get("selected_cell", paint_workspace.get("selected_cell", {})) as Dictionary
	var last_apply_state = view_state.get("last_apply", {}) as Dictionary
	var paint_affordance_board = paint_workspace.get("paint_affordance_board", {}) as Dictionary
	var empty_state := _paint_tab_empty_state()
	var brush_key := String(brush_state.get("brush_key", ""))
	var brush_summary := "%s%s" % [
		String(brush_state.get("mode_label", brush_state.get("mode", ""))),
		" %s" % brush_key if brush_key != "" else "",
	]
	var target_summary := String(target_state.get("name", ""))
	if target_summary == "":
		target_summary = String(target_state.get("message", "No editable target"))
	var selected_cell_summary := String(selected_cell_state.get("cell_key", ""))
	if selected_cell_summary == "":
		selected_cell_summary = "none"
	var last_apply_summary := String(last_apply_state.get("summary", paint_workspace.get("last_edit_summary", "none")))
	return {
		"tab": HexMapWorkspaceComponentRegistry.TAB_PAINT,
		"screen_role": screen_role,
		"screen_script": String(screen_role.get("screen_script", "")),
		"screen_role_source": String(screen_role.get("screen_role_source", "")),
		"workflow_owner": String(screen_role.get("workflow_owner", "")),
		"component_ids": tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_PAINT),
		"asset_slot_ids": tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_PAINT),
		"first_surface": String(paint_workspace.get("first_surface", "paint_workspace")),
		"paint_workspace_is_primary": bool(paint_workspace.get("paint_workspace_is_primary", true)),
		"resource_row_primary": bool(paint_workspace.get("resource_row_primary", false)),
		"purpose_text": String(empty_state.get("purpose_text", "")),
		"empty_state": empty_state,
		"empty_state_text": String(empty_state.get("empty_state_text", "")),
		"context_chips": paint_workspace.get("context_chips", []),
		"context_chips_visible": bool(paint_workspace.get("context_chips_visible", false)),
		"context_chips_text": String(paint_workspace.get("context_chips_text", "")),
		"context_chips_detail_target": HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"global_map_chip_duplicated": false,
		"brush_palette": paint_workspace.get("brush_palette", {}),
		"brush_palette_visible": bool(paint_workspace.get("brush_palette_visible", false)),
		"brush_shape_controls": paint_workspace.get("brush_shape_controls", {}),
		"brush_shape_controls_visible": bool(paint_workspace.get("brush_shape_controls_visible", false)),
		"brush_shape_mode": String(paint_workspace.get("brush_shape_mode", "")),
		"empty_cta": paint_workspace.get("empty_cta", {}),
		"empty_cta_visible": bool(paint_workspace.get("empty_cta_visible", false)),
		"interaction_state": interaction_state,
		"view_state": view_state,
		"brush": view_state.get("brush", {}),
		"catalog_entry_workflow_owner": String((view_state.get("brush", {}) as Dictionary).get("catalog_entry_workflow_owner", "Catalog")),
		"catalog_entry_management_visible": bool((view_state.get("brush", {}) as Dictionary).get("catalog_entry_management_visible", false)),
		"paint_consumes_catalog_key": bool((view_state.get("brush", {}) as Dictionary).get("paint_consumes_catalog_key", true)),
		"catalog_key_selector_visible": bool((view_state.get("brush", {}) as Dictionary).get("catalog_key_selector_visible", false)),
		"raw_catalog_metadata_controls_primary": bool((view_state.get("brush", {}) as Dictionary).get("raw_catalog_metadata_controls_primary", false)),
		"workspace": paint_workspace,
		"document_workflow_owner": String(paint_workspace.get("document_workflow_owner", "Resources")),
		"document_management_visible": bool(paint_workspace.get("document_management_visible", false)),
		"layer_workflow_owner": String(paint_workspace.get("layer_workflow_owner", "Layers")),
		"layer_management_visible": bool(paint_workspace.get("layer_management_visible", false)),
		"export_workflow_owner": String(paint_workspace.get("export_workflow_owner", "Export")),
		"export_management_visible": bool(paint_workspace.get("export_management_visible", false)),
		"paint_non_paint_management_visible": bool(paint_workspace.get("paint_non_paint_management_visible", false)),
		"validation_workflow_owner": String(paint_workspace.get("validation_workflow_owner", "Validate")),
		"validation_dashboard_visible": bool(paint_workspace.get("validation_dashboard_visible", false)),
		"paint_surface_owner": String(screen_role.get("workflow_owner", "Paint")),
		"paint_surface_visible": bool(paint_workspace.get("paint_surface_visible", false)),
		"paint_workspace_summary_text": String(paint_workspace.get("paint_workspace_summary_text", "")),
		"paint_affordance_visible": bool(paint_workspace.get("paint_affordance_visible", false)),
		"paint_affordance_board": paint_affordance_board,
		"paint_affordance_rows": paint_workspace.get("paint_affordance_rows", []),
		"paint_affordance_rows_text": String(paint_workspace.get("paint_affordance_rows_text", "")),
		"mounted_paint_affordance_text": String(paint_workspace.get("mounted_paint_affordance_text", "")),
		"brush_cursor_feedback": paint_affordance_board.get("cursor", {}),
		"empty_state_visible": String(empty_state.get("empty_state_text", "")) != "",
		"active_brush_visible": bool(paint_workspace.get("active_brush_visible", true)),
		"active_brush_summary": brush_summary,
		"target_layer_summary_visible": bool(paint_workspace.get("target_layer_summary_visible", true)),
		"target_layer_summary": target_summary,
		"selected_cell_summary_visible": bool(paint_workspace.get("selected_cell_summary_visible", true)),
		"selected_cell_summary": selected_cell_summary,
		"last_edit_summary_visible": bool(paint_workspace.get("last_edit_summary_visible", true)),
		"last_edit_surface_summary": last_apply_summary,
		"last_edit_surface_text": String(paint_workspace.get("last_edit_surface_text", "")),
		"viewport_sync": paint_workspace.get("viewport_sync", {}),
		"resource_reference_only": bool(paint_workspace.get("resource_reference_only", false)),
		"viewport_edit_updates_paint_state": bool(paint_workspace.get("viewport_edit_updates_paint_state", false)),
		"paint_context_sections": PackedStringArray(["active_brush", "target_layer", "selected_cell", "last_edit"]),
		"active_document": document_state.get("resource", paint_workspace.get("active_document", null)),
		"active_document_status": String(document_state.get("status", paint_workspace.get("active_document_status", "none"))),
		"active_layer": target_state.get("node", paint_workspace.get("active_layer", null)),
		"active_layer_name": String(target_state.get("name", paint_workspace.get("active_layer_name", ""))),
		"selected_cell": view_state.get("selected_cell", paint_workspace.get("selected_cell", {})),
		"last_edit": paint_workspace.get("last_edit", {}),
		"last_edit_summary": String(view_state.get("last_apply_summary", paint_workspace.get("last_edit_summary", "none"))),
		"last_edit_message": String(view_state.get("last_apply_message", paint_workspace.get("last_edit_message", "none"))),
		"undo_hint": String(paint_workspace.get("undo_hint", "")),
		"resource_picker_rows_visible": paint_workspace.get("resource_picker_rows_visible", {}),
	}


func select_paint_brush_mode(mode_id: String) -> Dictionary:
	if _edit_tool == null:
		return _paint_brush_action_result(false, ERR_UNAVAILABLE, mode_id)
	var ok := _edit_tool.set_paint_brush_mode(mode_id)
	return {
		"ok": ok,
		"error": OK if ok else ERR_INVALID_PARAMETER,
		"mode": mode_id,
		"brush": _edit_tool.paint_brush_snapshot(),
	}


func select_paint_catalog_brush_key(key: String, mode_id: String = "terrain") -> Dictionary:
	if _edit_tool == null:
		return _paint_brush_action_result(false, ERR_UNAVAILABLE, mode_id)
	var ok := _edit_tool.select_catalog_brush_key(key, mode_id)
	return {
		"ok": ok,
		"error": OK if ok else ERR_DOES_NOT_EXIST,
		"mode": mode_id,
		"key": key,
		"brush": _edit_tool.paint_brush_snapshot(),
	}


func qa_screen_snapshot() -> Dictionary:
	var context := workspace_asset_context()
	var screen_role := HexMapQAScreen.screen_contract()
	var ownership := HexMapQAScreen.ownership_fields()
	var seed_lab := qa_seed_lab_context()
	var empty_state := _qa_tab_empty_state(seed_lab)
	var score_row_count := int(seed_lab.get("score_row_count", 0))
	var scored_table = seed_lab.get("scored_table", {}) as Dictionary
	return {
		"tab": HexMapWorkspaceComponentRegistry.TAB_QA,
		"screen_role": screen_role,
		"screen_script": String(screen_role.get("screen_script", "")),
		"screen_role_source": String(screen_role.get("screen_role_source", "")),
		"workflow_owner": String(screen_role.get("workflow_owner", "")),
		"component_ids": tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_QA),
		"asset_slot_ids": tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_QA),
		"purpose_text": String(empty_state.get("purpose_text", "")),
		"empty_state": empty_state,
		"empty_state_text": String(empty_state.get("empty_state_text", "")),
		"context_chips": _work_tab_context_chips(HexMapWorkspaceComponentRegistry.TAB_QA),
		"context_chips_visible": true,
		"context_chips_text": _join_text(_work_tab_context_chips(HexMapWorkspaceComponentRegistry.TAB_QA), " "),
		"context_chips_detail_target": HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"global_map_chip_duplicated": false,
		"resource_row_primary": false,
		"generate_role_text": "Generate previews one candidate; QA compares seed batches and adopts a winner.",
		"seed_lab_component_present": tab_has_component(HexMapWorkspaceComponentRegistry.TAB_QA, "qa_seed_lab_panel"),
		"qa_workflow_owner": String(ownership.get("qa_workflow_owner", "QA")),
		"generation_profile": context.generation_profile,
		"generation_profile_context": _profile_resource_context(
			context,
			HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE
		),
		"generation_profile_used": context.generation_profile != null,
		"generation_profile_context_visible": true,
		"validation_rule_suite": context.validation_rule_suite,
		"validation_rule_suite_context": _profile_resource_context(
			context,
			HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE
		),
		"promotion_target_document": context.level_document,
		"generation_profile_slot": tab_asset_slot_snapshot(
			HexMapWorkspaceComponentRegistry.TAB_QA,
			HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE
		),
		"validation_rule_suite_slot": tab_asset_slot_snapshot(
			HexMapWorkspaceComponentRegistry.TAB_QA,
			HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE
		),
		"score_table_context": qa_score_table_context(),
		"seed_lab": seed_lab,
		"scored_table": scored_table,
		"score_rows": seed_lab.get("score_rows", []),
		"score_row_previews": seed_lab.get("score_row_previews", []),
		"score_table_visible": true,
		"score_table_columns": scored_table.get("columns", PackedStringArray()),
		"score_table_row_count": score_row_count,
		"score_table_rows_text": String(scored_table.get("rows_text", "")),
		"mounted_score_table_present": _qa_seed_lab_score_tree != null,
		"mounted_score_tree_row_count": _qa_mounted_score_tree_row_count(),
		"mounted_score_table_rows_text": _qa_seed_lab_rows_label.text if _qa_seed_lab_rows_label != null else "",
		"selected_seed_row": _qa_selected_seed_row.duplicate(true),
		"selected_seed_preview": seed_lab.get("selected_seed_preview", {}),
		"selected_seed_visible": true,
		"selected_seed_available": not _qa_selected_seed_row.is_empty(),
		"promoted_document": _qa_promoted_document,
		"promote_target_visible": true,
		"promote_to_document_available": bool(seed_lab.get("can_promote", false)),
		"promotion_updates_resources": context.level_document != null and context.level_document == _qa_promoted_document,
		"document_source_of_truth": "Level Document",
		"draft_context_boundary_visible": true,
		"draft_context_text": "Generate previews candidates; QA compares score rows and promotes one selected seed to the Level Document.",
		"generate_candidate_boundary": "Generate preview candidate",
		"qa_promotion_boundary": "Promote selected QA seed to Level Document",
		"resource_reference_only": false,
		"sample_candidates_visible": _ensure_session_state().show_bundled_samples_in_main_selectors,
	}


func qa_score_table_context() -> Dictionary:
	var context := workspace_asset_context()
	var generation_profile_context := _profile_resource_context(
		context,
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE
	)
	var validation_rule_suite_context := _profile_resource_context(
		context,
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE
	)
	var score_rows := _qa_score_rows()
	var scored_table := _qa_scored_table(score_rows)
	return {
		"generation_profile": generation_profile_context,
		"validation_rule_suite": validation_rule_suite_context,
		"score_rows": score_rows,
		"score_row_previews": _qa_score_row_previews(score_rows),
		"scored_table": scored_table,
		"score_table_columns": scored_table.get("columns", PackedStringArray()),
		"score_table_rows_text": String(scored_table.get("rows_text", "")),
		"score_table_visible": true,
		"generation_profile_used": context.generation_profile != null,
		"generation_profile_source": String(generation_profile_context.get("source_badge", "")),
	}


func qa_seed_lab_context() -> Dictionary:
	var context := workspace_asset_context()
	var score_rows := _qa_score_rows()
	var scored_table := _qa_scored_table(score_rows)
	var generation_profile_context := _profile_resource_context(
		context,
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE
	)
	var validation_rule_suite_context := _profile_resource_context(
		context,
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE
	)
	return {
		"generation_profile": generation_profile_context,
		"validation_rule_suite": validation_rule_suite_context,
		"score_rows": score_rows,
		"score_row_previews": _qa_score_row_previews(score_rows),
		"scored_table": scored_table,
		"score_table_columns": scored_table.get("columns", PackedStringArray()),
		"score_table_rows_text": String(scored_table.get("rows_text", "")),
		"score_table_visible": true,
		"score_row_count": score_rows.size(),
		"selected_seed_row": _qa_selected_seed_row.duplicate(true),
		"selected_seed_preview": _qa_selected_preview_snapshot(),
		"selected_seed_visible": true,
		"selected_seed": int(_qa_selected_seed_row.get("seed", 0)) if not _qa_selected_seed_row.is_empty() else 0,
		"selected_score": float(_qa_selected_seed_row.get("score", 0.0)) if not _qa_selected_seed_row.is_empty() else 0.0,
		"selected_generation_result_id": String(_qa_selected_seed_row.get("generation_result_id", "")),
		"selected_result_scope": _qa_selected_result_scope(),
		"selected_replay_available": bool(_qa_selected_seed_row.get("replay_available", false)),
		"can_run_batch": _generation_dock != null,
		"can_promote": _generation_dock != null and not _qa_selected_seed_row.is_empty(),
		"promotion_target": _qa_promotion_target_context(context),
		"promote_target_visible": true,
		"promoted_document": _qa_promoted_document,
		"document_source_of_truth": "Level Document",
		"draft_context_boundary_visible": true,
		"draft_context_text": "Generate previews candidates; QA compares score rows and promotes one selected seed to the Level Document.",
		"empty_state_text": "Run Seed Lab to compare generated seeds." if score_rows.is_empty() else "",
	}


func _qa_score_rows() -> Array:
	var rows: Array = []
	if _generation_dock == null:
		return rows
	for row in _generation_dock.generation_batch_score_table("score", true):
		rows.append(row)
	return rows


func _qa_selected_result_scope() -> Dictionary:
	var value = _qa_selected_seed_row.get("result_scope", {})
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}


func _qa_score_row_previews(rows: Array) -> Array:
	var previews: Array = []
	for row in rows:
		if row is Dictionary:
			var preview = (row as Dictionary).get("preview", {})
			if preview is Dictionary:
				previews.append((preview as Dictionary).duplicate(true))
			else:
				previews.append(HexMapPreviewThumbnail.unavailable_preview("row_has_no_preview"))
	return previews


func _qa_scored_table(score_rows: Array) -> Dictionary:
	var table_rows := _qa_scored_table_rows(score_rows)
	return {
		"surface_id": "qa_scored_table",
		"visible": true,
		"columns": PackedStringArray(["rank", "seed", "score", "validation", "selected", "preview", "promotion"]),
		"rows": table_rows,
		"row_count": table_rows.size(),
		"selected_row_index": _qa_scored_table_state_index(table_rows, "selected", true),
		"promoted_row_index": _qa_scored_table_state_index(table_rows, "promoted", true),
		"preview_available_count": _qa_scored_table_preview_count(table_rows),
		"rows_text": _qa_scored_table_rows_text(table_rows),
	}


func _qa_scored_table_rows(score_rows: Array) -> Array[Dictionary]:
	var table_rows: Array[Dictionary] = []
	var promoted_seed := _qa_promoted_seed()
	for row in score_rows:
		if not row is Dictionary:
			continue
		var score_row := (row as Dictionary)
		var preview = score_row.get("preview", {}) as Dictionary
		var result_scope = score_row.get("result_scope", {}) as Dictionary
		var seed := int(score_row.get("seed", 0))
		var selected := _qa_score_row_matches(score_row, _qa_selected_seed_row)
		var promoted := promoted_seed != 0 and promoted_seed == seed
		var promotion_state := "promoted" if promoted else ("ready to promote" if selected else "select to promote")
		table_rows.append({
			"rank": int(score_row.get("rank", table_rows.size() + 1)),
			"seed": seed,
			"score": float(score_row.get("score", 0.0)),
			"score_text": "%.2f" % float(score_row.get("score", 0.0)),
			"status": String(score_row.get("status", "")),
			"cells": int(score_row.get("cells", 0)),
			"validation": _qa_score_row_validation_text(score_row),
			"validation_errors": int(score_row.get("validation_errors", 0)),
			"validation_warnings": int(score_row.get("validation_warnings", 0)),
			"selected": selected,
			"selected_state": "selected" if selected else "not selected",
			"preview": preview.duplicate(true),
			"preview_available": bool(preview.get("available", false)),
			"preview_text": _qa_score_row_preview_text(score_row),
			"generation_result_id": String(score_row.get("generation_result_id", "")),
			"result_resource_present": score_row.get("generation_result", null) != null,
			"replay_available": bool(score_row.get("replay_available", false)),
			"result_scope": result_scope.duplicate(true),
			"promotion_state": promotion_state,
			"promotion_available": selected and _generation_dock != null and not promoted,
			"promoted": promoted,
			"source_index": int(score_row.get("index", -1)),
		})
	return table_rows


func _qa_score_row_matches(left: Dictionary, right: Dictionary) -> bool:
	if left.is_empty() or right.is_empty():
		return false
	var left_index := int(left.get("index", -1))
	var right_index := int(right.get("index", -2))
	if left_index >= 0 and right_index >= 0:
		return left_index == right_index
	if int(left.get("seed", 0)) != int(right.get("seed", 0)):
		return false
	return is_equal_approx(float(left.get("score", 0.0)), float(right.get("score", 0.0)))


func _qa_promoted_seed() -> int:
	if _qa_promoted_document == null or _qa_promoted_document.metadata == null:
		return 0
	return int(_qa_promoted_document.metadata.generation_seed)


func _qa_score_row_validation_text(row: Dictionary) -> String:
	var summary = row.get("validation_summary", {})
	if summary is Dictionary:
		return "%dE/%dW" % [
			int((summary as Dictionary).get("errors", row.get("validation_errors", 0))),
			int((summary as Dictionary).get("warnings", row.get("validation_warnings", 0))),
		]
	return "%dE/%dW" % [
		int(row.get("validation_errors", 0)),
		int(row.get("validation_warnings", 0)),
	]


func _qa_score_row_preview_text(row: Dictionary) -> String:
	var preview = row.get("preview", {}) as Dictionary
	if preview.is_empty() or not bool(preview.get("available", false)):
		var reason := String(preview.get("reason", "no preview"))
		return reason if reason != "" else "no preview"
	var source_kind := String(preview.get("source_kind", "preview"))
	var cell_count := int(preview.get("cell_count", row.get("cells", 0)))
	if cell_count > 0:
		return "%s %d cells" % [source_kind, cell_count]
	return source_kind


func _qa_scored_table_state_index(rows: Array, key: String, expected: bool) -> int:
	for index in range(rows.size()):
		var row = rows[index]
		if row is Dictionary and bool((row as Dictionary).get(key, false)) == expected:
			return index
	return -1


func _qa_scored_table_preview_count(rows: Array) -> int:
	var count := 0
	for row in rows:
		if row is Dictionary and bool((row as Dictionary).get("preview_available", false)):
			count += 1
	return count


func _qa_selected_preview_snapshot() -> Dictionary:
	if _qa_selected_seed_row.is_empty():
		return HexMapPreviewThumbnail.unavailable_preview("no_selected_seed", {
			"source_context": "qa_selected_seed",
		})
	var preview = _qa_selected_seed_row.get("preview", {}) as Dictionary
	if preview.is_empty():
		return HexMapPreviewThumbnail.unavailable_preview("selected_seed_has_no_preview", {
			"source_context": "qa_selected_seed",
			"seed": int(_qa_selected_seed_row.get("seed", 0)),
		})
	var result := preview.duplicate(true)
	result["source_context"] = "qa_selected_seed"
	return result


func run_qa_seed_lab(seed_count: int, options: Dictionary = {}) -> Dictionary:
	if _generation_dock == null:
		return {
			"ok": false,
			"error": ERR_UNAVAILABLE,
			"score_rows": [],
	}
	_generation_dock.run_generation_batch(seed_count, options)
	var rows := _qa_score_rows()
	_qa_selected_seed_row.clear()
	if not rows.is_empty():
		_qa_selected_seed_row = (rows[0] as Dictionary).duplicate(true)
	_refresh_qa_seed_lab_panel()
	var seed_lab := qa_seed_lab_context()
	return {
		"ok": true,
		"error": OK,
		"score_rows": rows,
		"selected_seed_row": _qa_selected_seed_row.duplicate(true),
		"scored_table": seed_lab.get("scored_table", {}),
		"seed_lab": seed_lab,
	}


func select_qa_seed_row(index: int) -> Dictionary:
	var rows := _qa_score_rows()
	if index < 0 or index >= rows.size():
		_qa_selected_seed_row.clear()
		_refresh_qa_seed_lab_panel()
		return {
			"ok": false,
			"error": ERR_DOES_NOT_EXIST,
			"selected_seed_row": {},
		}
	_qa_selected_seed_row = (rows[index] as Dictionary).duplicate(true)
	_refresh_qa_seed_lab_panel()
	var seed_lab := qa_seed_lab_context()
	return {
		"ok": true,
		"error": OK,
		"selected_seed_row": _qa_selected_seed_row.duplicate(true),
		"scored_table": seed_lab.get("scored_table", {}),
	}


func promote_qa_selected_seed_to_document() -> Dictionary:
	if _generation_dock == null or _qa_selected_seed_row.is_empty():
		return {
			"ok": false,
			"error": ERR_UNAVAILABLE,
			"document": null,
			"seed_lab": qa_seed_lab_context(),
		}
	var document = _generation_dock.promote_generation_batch_row(_qa_selected_seed_row) as HexMapDocumentResource
	if document == null:
		return {
			"ok": false,
			"error": ERR_CANT_CREATE,
			"document": null,
			"seed_lab": qa_seed_lab_context(),
		}
	_qa_promoted_document = document
	workspace_asset_context().set_level_document(document)
	_ensure_session_state().set_document(document, "workspace.qa.seed_lab", document.resource_path, "workspace.qa.promote_seed")
	_ensure_session_state().set_document_saved_path(document.resource_path, "workspace.qa.promote_seed")
	var writeback := {}
	if bool(selected_hex_tile_map_writeback_snapshot().get("can_writeback", false)):
		writeback = _apply_workspace_asset_change_to_selected_node(
			HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
			"workspace.qa.promote_seed"
		)
	_sync_workspace_asset_context()
	_refresh_selected_hex_tile_map_context()
	_refresh_qa_seed_lab_panel()
	return {
		"ok": true,
		"error": OK,
		"document": document,
		"selected_seed_row": _qa_selected_seed_row.duplicate(true),
		"writeback": writeback,
		"seed_lab": qa_seed_lab_context(),
	}


func create_generation_profile(path: String) -> Dictionary:
	var panel := _qa_asset_panel()
	if panel == null:
		return _generation_profile_action_result(false, ERR_UNAVAILABLE, path)
	var result := panel.create_asset_for_slot(HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE, path)
	_sync_generation_profile_from_result(result)
	return result


func save_generation_profile_as(path: String) -> Dictionary:
	var panel := _qa_asset_panel()
	if panel == null:
		return _generation_profile_action_result(false, ERR_UNAVAILABLE, path)
	var result := panel.save_asset_slot_as(HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE, path)
	_sync_generation_profile_from_result(result)
	return result


func open_generation_profile() -> Dictionary:
	var panel := _qa_asset_panel()
	if panel == null:
		return _generation_profile_action_result(false, ERR_UNAVAILABLE, "")
	var result := panel.open_asset_slot(HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE)
	_sync_generation_profile_from_result(result)
	return result


func clear_generation_profile() -> Dictionary:
	var panel := _qa_asset_panel()
	if panel == null:
		return _generation_profile_action_result(false, ERR_UNAVAILABLE, "")
	return panel.clear_asset_slot(HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE)


func create_validation_rule_suite(path: String) -> Dictionary:
	var panel := _qa_asset_panel()
	if panel == null:
		return _validation_suite_action_result(false, ERR_UNAVAILABLE, path)
	var result := panel.create_asset_for_slot(HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE, path)
	_sync_validation_suite_from_result(result)
	return result


func save_validation_rule_suite_as(path: String) -> Dictionary:
	var panel := _qa_asset_panel()
	if panel == null:
		return _validation_suite_action_result(false, ERR_UNAVAILABLE, path)
	var result := panel.save_asset_slot_as(HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE, path)
	_sync_validation_suite_from_result(result)
	return result


func open_validation_rule_suite() -> Dictionary:
	var panel := _qa_asset_panel()
	if panel == null:
		return _validation_suite_action_result(false, ERR_UNAVAILABLE, "")
	var result := panel.open_asset_slot(HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE)
	_sync_validation_suite_from_result(result)
	return result


func clear_validation_rule_suite() -> Dictionary:
	var panel := _qa_asset_panel()
	if panel == null:
		return _validation_suite_action_result(false, ERR_UNAVAILABLE, "")
	return panel.clear_asset_slot(HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE)


func duplicate_generation_profile_preset_to_project(preset_id: String, path: String) -> Dictionary:
	var profile := _generation_profile_preset(preset_id)
	return _save_qa_preset_resource(
		profile,
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE,
		preset_id,
		path
	)


func duplicate_validation_rule_suite_preset_to_project(preset_id: String, path: String) -> Dictionary:
	var suite := _validation_rule_suite_preset(preset_id)
	return _save_qa_preset_resource(
		suite,
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE,
		preset_id,
		path
	)


func export_screen_snapshot() -> Dictionary:
	var session := _ensure_session_state()
	var context := workspace_asset_context()
	var screen_role := HexMapExportScreen.screen_contract()
	var ownership := HexMapExportScreen.ownership_fields()
	var destination := _export_destination_context()
	var output_type := _export_output_type_context(context, destination)
	var empty_state := _export_tab_empty_state(context, destination)
	var purpose_context := _export_purpose_context(context, destination)
	var purpose_cards := HexMapExportScreen.purpose_cards(purpose_context)
	var secondary_actions := HexMapExportScreen.secondary_actions(purpose_context)
	var output_modes := _export_output_modes()
	var visible_output_mode_ids := _export_purpose_card_ids(purpose_cards)
	var visible_output_mode_labels := _export_purpose_card_titles(purpose_cards)
	var can_export := context.level_document != null and session.export_saved_path != ""
	var export_state := export_workflow_state_snapshot()
	var export_view_state = export_state.get("view_state", {}) as Dictionary
	var runtime_handoff_summary := _export_runtime_handoff_summary(
		context,
		destination,
		output_type,
		export_state,
		can_export
	)
	return {
		"tab": HexMapWorkspaceComponentRegistry.TAB_EXPORT,
		"screen_role": screen_role,
		"screen_script": String(screen_role.get("screen_script", "")),
		"screen_role_source": String(screen_role.get("screen_role_source", "")),
		"workflow_owner": String(screen_role.get("workflow_owner", "")),
		"component_ids": tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_EXPORT),
		"asset_slot_ids": tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_EXPORT),
		"purpose_text": String(empty_state.get("purpose_text", "")),
		"empty_state": empty_state,
		"empty_state_text": String(empty_state.get("empty_state_text", "")),
		"context_chips": _work_tab_context_chips(HexMapWorkspaceComponentRegistry.TAB_EXPORT),
		"context_chips_visible": true,
		"context_chips_text": _join_text(_work_tab_context_chips(HexMapWorkspaceComponentRegistry.TAB_EXPORT), " "),
		"context_chips_detail_target": HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"global_map_chip_duplicated": false,
		"resource_row_primary": false,
		"export_state": export_state,
		"view_state": export_view_state,
		"purpose_component_present": tab_has_component(HexMapWorkspaceComponentRegistry.TAB_EXPORT, "export_purpose_panel"),
		"active_output_type": String(output_type.get("id", "runtime_handoff_resource")),
		"active_output_type_visible": true,
		"output_type": output_type,
		"purpose_cards": purpose_cards,
		"purpose_card_ids": _export_purpose_card_ids(purpose_cards),
		"primary_purpose_id": HexMapExportScreen.PURPOSE_RUNTIME_MAP,
		"secondary_actions": secondary_actions,
		"secondary_action_ids": _export_secondary_action_ids(secondary_actions),
		"output_modes": output_modes,
		"visible_output_mode_ids": visible_output_mode_ids,
		"visible_output_mode_labels": visible_output_mode_labels,
		"normal_export_action_count": purpose_cards.size(),
		"export_type_taxonomy_visible": true,
		"runtime_handoff_purpose": String(output_type.get("result_purpose_text", "")),
		"runtime_handoff_result_usage": String(output_type.get("result_usage", "")),
		"runtime_handoff_summary": runtime_handoff_summary,
		"runtime_handoff_readiness_rows": runtime_handoff_summary.get("readiness_rows", []),
		"mounted_runtime_handoff_summary_text": _export_runtime_handoff_summary_label.text if _export_runtime_handoff_summary_label != null else "",
		"package_support_boundary": String(output_type.get("package_support_boundary", "")),
		"debug_export_boundary": String(output_type.get("debug_report_boundary", "")),
		"level_document": context.level_document,
		"export_profile": context.export_profile,
		"export_profile_context": _profile_resource_context(
			context,
			HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE
		),
		"level_document_slot": tab_asset_slot_snapshot(
			HexMapWorkspaceComponentRegistry.TAB_EXPORT,
			HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT
		),
		"export_profile_slot": tab_asset_slot_snapshot(
			HexMapWorkspaceComponentRegistry.TAB_EXPORT,
			HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE
		),
		"destination": destination,
		"output_destination_visible": true,
		"output_destination_purpose": String(output_type.get("destination_purpose", "")),
		"destination_dialog_config": export_destination_dialog_config(),
		"can_export": can_export,
		"cannot_export_reason": _export_cannot_export_reason(context, destination),
		"use_recent_button_disabled": session.recent_export_destinations.is_empty(),
		"use_recent_button_tooltip": _export_use_recent_button_tooltip(session),
		"run_button_disabled": not can_export,
		"run_button_tooltip": _export_run_button_tooltip(context, destination),
		"runtime_scene_handoff": _export_scene_handoff_context(destination),
		"generation_graph_handoff": _export_graph_handoff_context(destination),
		"package_handoff": _export_handoff_context(session.export_saved_path, null),
		"runtime_handoff": _export_handoff_context(session.export_saved_path, null),
		"export_result_state_visible": true,
		"export_result_state": String(export_state.get("state_id", "")),
		"export_result_status_text": String(export_view_state.get("status_text", "")),
		"export_result_state_source": String(output_type.get("result_state_source", "")),
		"unsupported_export_buttons_visible": false,
		"data_export_button_visible": false,
		"json_snapshot_export_button_visible": true,
		"package_build_button_visible": true,
		"package_build_button_disabled": true,
		"package_build_tooltip": _export_secondary_action_tooltip(
			secondary_actions,
			HexMapExportScreen.SECONDARY_PACKAGE_BUILD
		),
		"debug_report_export_button_visible": true,
		"experimental_exports_hidden": true,
		"sample_candidates_visible": session.show_bundled_samples_in_main_selectors,
		"sample_destination_available": false,
		"editable_destination_path_visible": false,
		"export_workflow_owner": String(ownership.get("export_workflow_owner", "Export")),
		"export_management_visible": bool(ownership.get("export_management_visible", true)),
		"destination_output_type_owner": String(ownership.get("destination_output_type_owner", "Export")),
		"destination_controls_visible": bool(ownership.get("destination_controls_visible", true)),
		"output_type_controls_visible": bool(ownership.get("output_type_controls_visible", true)),
		"paint_export_management_visible": bool(ownership.get("paint_export_management_visible", false)),
		"resource_reference_only": false,
	}


func export_destination_dialog_config() -> Dictionary:
	var extension := _active_export_file_extension(workspace_asset_context())
	return {
		"uses_file_dialog": true,
		"file_mode": EditorFileDialog.FILE_MODE_SAVE_FILE,
		"filters": HexMapEditorPathSelector.TRES_FILTERS.duplicate(),
		"current_file": "hex_map_runtime_handoff%s" % extension,
		"editable_path_text_visible": false,
	}


func create_export_profile(path: String) -> Dictionary:
	var panel := _export_asset_panel()
	if panel == null:
		return _export_profile_action_result(false, ERR_UNAVAILABLE, path)
	var result := panel.create_asset_for_slot(HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE, path)
	_sync_export_profile_from_result(result)
	return result


func save_export_profile_as(path: String) -> Dictionary:
	var panel := _export_asset_panel()
	if panel == null:
		return _export_profile_action_result(false, ERR_UNAVAILABLE, path)
	var result := panel.save_asset_slot_as(HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE, path)
	_sync_export_profile_from_result(result)
	return result


func open_export_profile() -> Dictionary:
	var panel := _export_asset_panel()
	if panel == null:
		return _export_profile_action_result(false, ERR_UNAVAILABLE, "")
	var result := panel.open_asset_slot(HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE)
	_sync_export_profile_from_result(result)
	return result


func clear_export_profile() -> Dictionary:
	var panel := _export_asset_panel()
	if panel == null:
		return _export_profile_action_result(false, ERR_UNAVAILABLE, "")
	return panel.clear_asset_slot(HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE)


func select_export_destination(path: String) -> Dictionary:
	var actual_path := HexMapWorkspaceAssetResourceFactory.normalized_resource_path(path)
	if actual_path == "":
		return _export_action_result(false, ERR_INVALID_PARAMETER, actual_path)
	_ensure_session_state().record_export_destination(actual_path, "workspace.export.destination")
	if _edit_tool != null:
		_edit_tool.set_export_path(actual_path)
	_refresh_export_purpose_panel()
	_refresh_export_destination_panel()
	return _export_action_result(true, OK, actual_path)


func select_recent_export_destination(path: String) -> Dictionary:
	var actual_path := HexMapWorkspaceAssetResourceFactory.normalized_resource_path(path)
	if not _ensure_session_state().recent_export_destinations.has(actual_path):
		return _export_action_result(false, ERR_DOES_NOT_EXIST, actual_path)
	return select_export_destination(actual_path)


func clear_export_destination() -> Dictionary:
	_ensure_session_state().set_export_saved_path("", "workspace.export.destination.clear")
	if _edit_tool != null:
		_edit_tool.set_export_path("")
	_refresh_export_purpose_panel()
	_refresh_export_destination_panel()
	return _export_action_result(true, OK, "")


func export_selected_document_to_destination(path: String = "") -> Dictionary:
	if path.strip_edges() != "":
		var select_result := select_export_destination(path)
		if not bool(select_result.get("ok", false)):
			_last_export_action_result = select_result.duplicate(true)
			var export_state := export_workflow_state_snapshot()
			select_result["export_state"] = export_state
			select_result["view_state"] = export_state.get("view_state", {})
			return select_result
	var actual_path := HexMapWorkspaceAssetResourceFactory.normalized_resource_path(_ensure_session_state().export_saved_path)
	if actual_path == "":
		var result := _export_action_result(false, ERR_INVALID_PARAMETER, actual_path)
		_last_export_action_result = result.duplicate(true)
		var export_state := export_workflow_state_snapshot()
		result["export_state"] = export_state
		result["view_state"] = export_state.get("view_state", {})
		return result
	var document := workspace_asset_context().level_document
	if document == null:
		var result := _export_action_result(false, ERR_DOES_NOT_EXIST, actual_path)
		_last_export_action_result = result.duplicate(true)
		var export_state := export_workflow_state_snapshot()
		result["export_state"] = export_state
		result["view_state"] = export_state.get("view_state", {})
		return result
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(actual_path.get_base_dir()))
	_sync_export_workflow_state(true)
	var context := workspace_asset_context()
	var export_options := _active_export_options(context)
	var profile_selected := not export_options.is_empty()
	var output_type_id := _export_output_type_id(export_options)
	var map_resource = HexMapDocumentAdapter.to_map_resource(document)
	var error := ResourceSaver.save(map_resource, actual_path)
	var result := _export_action_result(error == OK, error, actual_path)
	if error == OK:
		map_resource.resource_path = actual_path
		_ensure_session_state().record_export_destination(actual_path, "workspace.export.run")
		if _edit_tool != null:
			_edit_tool.set_export_path(actual_path)
	var data = map_resource.to_map_data() if map_resource != null else null
	result["resource"] = map_resource
	result["resource_class"] = "HexMapResource"
	result["cell_count"] = data.cells.size() if data != null else 0
	result["wall_count"] = data.walls.size() if data != null else 0
	result["export_profile"] = context.export_profile
	result["export_options"] = export_options.duplicate(true)
	result["output_type"] = output_type_id
	result["file_extension"] = _export_file_extension(export_options)
	result["purpose_text"] = "Runtime handoff HexMapResource"
	result["package_handoff"] = _export_handoff_context(actual_path, map_resource)
	var include_runtime_queries := _export_include_flag(
		export_options,
		"include_runtime_queries",
		true
	)
	result["include_metadata"] = _export_include_flag(export_options, "include_metadata", true)
	result["include_validation_summary"] = _export_include_flag(
		export_options,
		"include_validation_summary",
		false
	)
	result["include_runtime_queries"] = include_runtime_queries
	result["include_debug_report"] = _export_include_flag(export_options, "include_debug_report", false)
	result["runtime_handoff"] = _export_handoff_context(
		actual_path if include_runtime_queries else "",
		map_resource if include_runtime_queries else null
	)
	if profile_selected and bool(result["include_validation_summary"]):
		var validation_result = HexMapDocumentValidator.validate_document(document, _document_validation_options())
		result["validation_summary"] = validation_result.summary.duplicate(true)
	if profile_selected and bool(result["include_debug_report"]):
		result["debug_report"] = workspace_state_debug_report_text()
	_last_export_action_result = result.duplicate(true)
	var export_state := export_workflow_state_snapshot()
	result["export_state"] = export_state
	result["view_state"] = export_state.get("view_state", {})
	_refresh_export_purpose_panel()
	_refresh_export_destination_panel()
	return result


func press_export_purpose_action(purpose_id: String, path: String = "") -> Dictionary:
	match purpose_id:
		HexMapExportScreen.PURPOSE_RUNTIME_MAP:
			return export_selected_document_to_destination(path)
		HexMapExportScreen.PURPOSE_RUNTIME_SCENE:
			return export_runtime_scene_to_destination(path)
		HexMapExportScreen.PURPOSE_GENERATION_GRAPH:
			return export_generation_graph_to_destination(path)
	return _finalize_export_action_result(
		_export_action_result(false, ERR_INVALID_PARAMETER, _export_path_for_purpose(purpose_id, path))
	)


func press_export_secondary_action(action_id: String, path: String = "") -> Dictionary:
	match action_id:
		HexMapExportScreen.SECONDARY_DEBUG_REPORT:
			return copy_export_debug_report()
		HexMapExportScreen.SECONDARY_JSON_SNAPSHOT:
			return export_json_snapshot_to_destination(path)
		HexMapExportScreen.SECONDARY_PACKAGE_BUILD:
			var result := _export_action_result(
				false,
				ERR_UNAVAILABLE,
				_export_path_for_purpose(action_id, path)
			)
			result["disabled_reason"] = _export_secondary_action_tooltip(
				HexMapExportScreen.secondary_actions(_export_purpose_context(
					workspace_asset_context(),
					_export_destination_context()
				)),
				HexMapExportScreen.SECONDARY_PACKAGE_BUILD
			)
			result["process_only"] = true
			return _finalize_export_action_result(result)
	return _finalize_export_action_result(
		_export_action_result(false, ERR_INVALID_PARAMETER, _export_path_for_purpose(action_id, path))
	)


func export_runtime_scene_to_destination(path: String = "") -> Dictionary:
	var actual_path := _export_path_for_purpose(HexMapExportScreen.PURPOSE_RUNTIME_SCENE, path)
	if actual_path == "":
		return _finalize_export_action_result(_export_action_result(false, ERR_INVALID_PARAMETER, actual_path))
	var document := workspace_asset_context().level_document
	if document == null:
		return _finalize_export_action_result(_export_action_result(false, ERR_DOES_NOT_EXIST, actual_path))

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(actual_path.get_base_dir()))
	_sync_export_workflow_state(true)
	var layer := HexTileMapLayer.new()
	layer.name = "RuntimeHexMapLayer"
	layer.level_document_resource = document
	layer.hex_map = HexMapDocumentAdapter.to_map_resource(document)
	var selected_layer := _ensure_session_state().current_selected_hex_tile_map_layer() as HexTileMapLayer
	if selected_layer != null:
		layer.display_tile_set_resource = selected_layer.display_tile_set_resource
		layer.layer_stack_resource = selected_layer.layer_stack_resource
		layer.generation_graph_resource = selected_layer.generation_graph_resource
	var scene := PackedScene.new()
	var error := scene.pack(layer)
	if error == OK:
		error = ResourceSaver.save(scene, actual_path)
	layer.free()

	var result := _export_action_result(error == OK, error, actual_path)
	result["resource"] = scene if error == OK else null
	result["resource_class"] = "PackedScene"
	result["output_type"] = HexMapExportScreen.PURPOSE_RUNTIME_SCENE
	result["purpose_text"] = "Runtime scene handoff"
	result["gameplay_framework"] = false
	result["runtime_scene_handoff"] = {
		"path": actual_path,
		"resource_class": "PackedScene",
		"root_node_type": "HexTileMapLayer",
		"gameplay_framework": false,
	}
	return _finalize_export_action_result(result)


func export_generation_graph_to_destination(path: String = "") -> Dictionary:
	var actual_path := _export_path_for_purpose(HexMapExportScreen.PURPOSE_GENERATION_GRAPH, path)
	if actual_path == "":
		return _finalize_export_action_result(_export_action_result(false, ERR_INVALID_PARAMETER, actual_path))
	var graph := _selected_generation_graph_resource()
	if graph == null:
		var missing_result := _export_action_result(false, ERR_DOES_NOT_EXIST, actual_path)
		missing_result["blocked_reason"] = "Generation Graph is not linked to the selected HexTileMapLayer."
		return _finalize_export_action_result(missing_result)

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(actual_path.get_base_dir()))
	_sync_export_workflow_state(true)
	var graph_copy := HexMapGraphInstantiator.duplicate_graph_for_embed(graph)
	var error := ResourceSaver.save(graph_copy, actual_path)
	var result := _export_action_result(error == OK, error, actual_path)
	if error == OK:
		graph_copy.resource_path = actual_path
	result["resource"] = graph_copy if error == OK else null
	result["resource_class"] = "HexGenerationGraphResource"
	result["output_type"] = HexMapExportScreen.PURPOSE_GENERATION_GRAPH
	result["purpose_text"] = "Generation Graph resource handoff"
	result["ownership_semantics"] = graph_copy.ownership_semantics
	result["semantics_reference_path"] = graph_copy.semantics_reference_path
	result["gameplay_framework"] = false
	result["generation_graph_handoff"] = {
		"path": actual_path,
		"resource_class": "HexGenerationGraphResource",
		"ownership_semantics": graph_copy.ownership_semantics,
		"gameplay_framework": false,
	}
	return _finalize_export_action_result(result)


func copy_export_debug_report() -> Dictionary:
	var report := workspace_state_debug_report_text()
	var result := _export_action_result(report != "", OK if report != "" else ERR_UNAVAILABLE, "")
	result["action_id"] = HexMapExportScreen.SECONDARY_DEBUG_REPORT
	result["debug_report"] = report
	result["copied"] = report != ""
	return _finalize_export_action_result(result)


func export_debug_report_to_destination(path: String = "") -> Dictionary:
	var actual_path := _export_path_for_purpose(HexMapExportScreen.SECONDARY_DEBUG_REPORT, path)
	var report := workspace_state_debug_report_text()
	var result := _write_text_export(
		actual_path,
		report,
		HexMapExportScreen.SECONDARY_DEBUG_REPORT,
		"Debug report"
	)
	return _finalize_export_action_result(result)


func export_json_snapshot_to_destination(path: String = "") -> Dictionary:
	if workspace_asset_context().level_document == null:
		return _finalize_export_action_result(
			_export_action_result(
				false,
				ERR_DOES_NOT_EXIST,
				_export_path_for_purpose(HexMapExportScreen.SECONDARY_JSON_SNAPSHOT, path)
			)
		)
	var actual_path := _export_path_for_purpose(HexMapExportScreen.SECONDARY_JSON_SNAPSHOT, path)
	var payload := _export_json_snapshot_payload()
	var json_text := JSON.stringify(payload, "\t")
	var result := _write_text_export(
		actual_path,
		json_text,
		HexMapExportScreen.SECONDARY_JSON_SNAPSHOT,
		"JSON snapshot"
	)
	result["json_snapshot"] = payload
	return _finalize_export_action_result(result)


func _build_ui() -> void:
	if _tabs != null:
		return
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_mount_sample_learning_cta()
	_mount_selected_hex_tile_map_context()
	_tabs = TabContainer.new()
	_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_tabs)
	for tab_name in HexMapWorkspaceComponentRegistry.tab_names():
		_add_tab_page(String(tab_name))
	_mount_workspace_asset_panels()
	_mount_validation_issue_navigator()
	_mount_export_destination_panel()
	_mount_generation_panel()
	_mount_edit_panel()
	_mount_sample_settings_panel()


func _mount_sample_learning_cta() -> void:
	if _sample_learning_cta != null:
		return
	_sample_learning_cta = HBoxContainer.new()
	_sample_learning_cta.name = "Sample Learning CTA"
	_sample_learning_cta.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_learn_samples_button = Button.new()
	_learn_samples_button.text = "Learn with bundled samples"
	_learn_samples_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_learn_samples_button.pressed.connect(_on_sample_learning_cta_pressed)
	_sample_learning_cta.add_child(_learn_samples_button)

	_dismiss_samples_button = Button.new()
	_dismiss_samples_button.text = "Dismiss"
	_dismiss_samples_button.pressed.connect(_on_sample_learning_cta_dismissed)
	_sample_learning_cta.add_child(_dismiss_samples_button)
	add_child(_sample_learning_cta)
	_refresh_sample_learning_cta()


func _mount_selected_hex_tile_map_context() -> void:
	if _selected_hex_tile_map_context != null:
		return
	_selected_hex_tile_map_context = HBoxContainer.new()
	_selected_hex_tile_map_context.name = "Selected HexTileMap Context"
	_selected_hex_tile_map_context.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_selected_hex_tile_map_status_label = Label.new()
	_selected_hex_tile_map_status_label.name = "Selected HexTileMap Status"
	_selected_hex_tile_map_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_selected_hex_tile_map_status_label.clip_text = true
	_selected_hex_tile_map_context.add_child(_selected_hex_tile_map_status_label)

	_selected_hex_tile_map_auto_link_label = Label.new()
	_selected_hex_tile_map_auto_link_label.name = "Selected HexTileMap Auto Link"
	_selected_hex_tile_map_auto_link_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_selected_hex_tile_map_context.add_child(_selected_hex_tile_map_auto_link_label)

	add_child(_selected_hex_tile_map_context)
	_refresh_selected_hex_tile_map_context()


func _add_tab_page(tab_name: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.name = tab_name
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	_tabs.add_child(scroll)

	var page = VBoxContainer.new()
	page.name = "%s Content" % tab_name
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	scroll.add_child(page)
	_tab_scroll_roots[tab_name] = scroll
	_tab_pages[tab_name] = page
	return page


func _mount_workspace_asset_panels() -> void:
	_mount_resources_context_panel()
	_mount_asset_panel(
		HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"document_asset_panel",
		"Resource Context",
		[
			_slot_row(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "Level Document"),
			_slot_row(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "Tile Catalog"),
			_slot_row(HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE, "Object Database", false),
			_slot_row(HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE, "Label Database", false),
			_slot_row(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK, "Layer Stack", false),
			_slot_row(HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE, "Movement Profile", false),
		]
	)
	_mount_missing_unique_resources_panel()
	_mount_catalog_detail_panel()
	_mount_asset_panel(
		HexMapWorkspaceComponentRegistry.TAB_CATALOG,
		"catalog_asset_panel",
		"Catalog Assets",
		[
			_slot_row(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "Tile Catalog"),
		]
	)
	_mount_layer_stack_role_panel()
	_mount_asset_panel(
		HexMapWorkspaceComponentRegistry.TAB_LAYERS,
		"layer_stack_asset_panel",
		"Layer Assets",
		[
			_slot_row(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK, "Layer Stack"),
		]
	)
	_mount_asset_panel(
		HexMapWorkspaceComponentRegistry.TAB_VALIDATE,
		"validation_asset_panel",
		"Validation Assets",
		[
			_slot_row(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "Level Document"),
			_slot_row(HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE, "Validation Rule Suite", false),
		]
	)
	_mount_qa_seed_lab_panel()
	_mount_asset_panel(
		HexMapWorkspaceComponentRegistry.TAB_QA,
		"qa_asset_panel",
		"QA Assets",
		[
			_slot_row(HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE, "Generation Profile", false),
			_slot_row(HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE, "Validation Rule Suite", false),
			_slot_row(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "Promotion Target Document", false),
		]
	)
	_mount_export_purpose_panel()
	_mount_asset_panel(
		HexMapWorkspaceComponentRegistry.TAB_EXPORT,
		"export_asset_panel",
		"Export Assets",
		[
			_slot_row(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "Level Document"),
			_slot_row(HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE, "Export Profile", false),
		]
	)
	_mount_settings_preferences_panel()


func _mount_resources_context_panel() -> void:
	var page = _tab_pages.get(HexMapWorkspaceComponentRegistry.TAB_DOCUMENT, null)
	if page == null or _resources_context_panel != null:
		return
	var built := HexMapResourcesScreen.build_resources_context_panel(resource_group_rows())
	_resources_context_panel = built.get("root", null) as VBoxContainer
	_resources_context_status_label = built.get("status_label", null) as Label
	_resources_shelf_status_label = built.get("shelf_status_label", null) as Label
	_resources_readiness_label = built.get("readiness_label", null) as Label
	_resources_group_labels = built.get("group_labels", {}) as Dictionary
	_resources_source_badges_label = built.get("source_badges_label", null) as Label
	_resources_context_next_actions_label = built.get("next_actions_label", null) as Label

	(page as Control).add_child(_resources_context_panel)
	_register_tab_component(
		HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"resources_context_panel",
		_resources_context_panel
	)
	_refresh_resources_context_panel()


func _mount_catalog_detail_panel() -> void:
	var page = _tab_pages.get(HexMapWorkspaceComponentRegistry.TAB_CATALOG, null)
	if page == null or _catalog_detail_panel != null:
		return
	var built := HexMapCatalogScreen.build_catalog_detail_panel()
	_catalog_detail_panel = built.get("root", null) as VBoxContainer
	_catalog_board_status_label = built.get("board_status_label", null) as Label
	_catalog_board_grid = built.get("board_grid", null) as GridContainer
	_catalog_empty_cta_label = built.get("empty_cta_label", null) as Label
	_catalog_detail_status_label = built.get("status_label", null) as Label
	_catalog_detail_entry_label = built.get("entry_label", null) as Label
	_catalog_detail_preview_control = built.get("preview_control", null) as HexTileCatalogPreviewControl
	_catalog_detail_preview_badge_label = built.get("preview_badge_label", null) as Label

	(page as Control).add_child(_catalog_detail_panel)
	if _catalog_board_grid != null:
		_register_tab_component(
			HexMapWorkspaceComponentRegistry.TAB_CATALOG,
			"catalog_visual_board",
			_catalog_board_grid
		)
	_register_tab_component(
		HexMapWorkspaceComponentRegistry.TAB_CATALOG,
		"catalog_detail_panel",
		_catalog_detail_panel
	)
	_refresh_catalog_detail_panel()


func _mount_layer_stack_role_panel() -> void:
	var page = _tab_pages.get(HexMapWorkspaceComponentRegistry.TAB_LAYERS, null)
	if page == null or _layer_stack_role_panel != null:
		return
	var built := HexMapLayersScreen.build_layer_stack_role_panel()
	_layer_stack_role_panel = built.get("root", null) as VBoxContainer
	_layer_stack_visual_status_label = built.get("visual_status_label", null) as Label
	_layer_stack_visual_stack = built.get("visual_stack", null) as VBoxContainer
	_layer_stack_visual_empty_cta_label = built.get("empty_cta_label", null) as Label
	_layer_stack_role_status_label = built.get("status_label", null) as Label
	_layer_stack_role_relationship_label = built.get("relationship_label", null) as Label
	_layer_stack_role_tree_summary_label = built.get("role_tree_summary_label", null) as Label
	_layer_stack_role_rows_label = built.get("rows_label", null) as Label
	_layer_stack_role_editor_summary_label = built.get("editor_summary_label", null) as Label
	_layer_stack_role_editor_role_option = built.get("role_option", null) as OptionButton
	_layer_stack_role_editor_visible_check = built.get("visible_check", null) as CheckBox
	_layer_stack_role_editor_locked_check = built.get("locked_check", null) as CheckBox
	_layer_stack_role_editor_z_index_spin = built.get("z_index_spin", null) as SpinBox
	_layer_stack_role_editor_writable_option = built.get("writable_option", null) as OptionButton
	if _layer_stack_role_editor_role_option != null:
		_layer_stack_role_editor_role_option.item_selected.connect(_on_layer_stack_editor_role_selected)
	if _layer_stack_role_editor_visible_check != null:
		_layer_stack_role_editor_visible_check.toggled.connect(_on_layer_stack_editor_visible_toggled)
	if _layer_stack_role_editor_locked_check != null:
		_layer_stack_role_editor_locked_check.toggled.connect(_on_layer_stack_editor_locked_toggled)
	if _layer_stack_role_editor_z_index_spin != null:
		_layer_stack_role_editor_z_index_spin.value_changed.connect(_on_layer_stack_editor_z_index_changed)
	if _layer_stack_role_editor_writable_option != null:
		_layer_stack_role_editor_writable_option.item_selected.connect(_on_layer_stack_editor_writable_selected)

	(page as Control).add_child(_layer_stack_role_panel)
	_register_tab_component(
		HexMapWorkspaceComponentRegistry.TAB_LAYERS,
		"layer_stack_role_panel",
		_layer_stack_role_panel
	)
	if _layer_stack_visual_stack != null:
		_register_tab_component(
			HexMapWorkspaceComponentRegistry.TAB_LAYERS,
			"layer_role_stack_visual",
			_layer_stack_visual_stack
		)
	_refresh_layer_stack_role_panel()


func _mount_asset_panel(
	tab_name: String,
	component_id: String,
	title: String,
	slot_rows: Array[Dictionary]
) -> void:
	var page = _tab_pages.get(tab_name, null)
	if page == null:
		return
	var panel := HexMapWorkspaceAssetPanel.new()
	panel.configure(tab_name, component_id, title, slot_rows)
	panel.set_workspace_asset_context(workspace_asset_context())
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	(page as Control).add_child(panel)
	_asset_panels[tab_name] = panel
	_register_tab_component(tab_name, component_id, panel)


func _mount_missing_unique_resources_panel() -> void:
	var page = _tab_pages.get(HexMapWorkspaceComponentRegistry.TAB_DOCUMENT, null)
	if page == null or _missing_unique_resources_panel != null:
		return
	var built := HexMapResourcesScreen.build_missing_unique_resources_panel()
	_missing_unique_resources_panel = built.get("root", null) as VBoxContainer
	_missing_unique_resources_status_label = built.get("status_label", null) as Label
	_missing_unique_resources_save_directory_label = built.get("save_directory_label", null) as Label
	_missing_unique_resources_choose_directory_button = built.get("choose_directory_button", null) as Button
	_missing_unique_resources_choose_directory_button.pressed.connect(_on_missing_unique_resources_choose_directory_pressed)
	_missing_unique_resources_prefix_edit = built.get("prefix_edit", null) as LineEdit
	_missing_unique_resources_prefix_edit.text_changed.connect(_on_missing_unique_resources_prefix_changed)
	_missing_unique_resources_create_button = built.get("create_button", null) as Button
	_missing_unique_resources_create_button.pressed.connect(_on_create_missing_unique_resources_pressed)
	_resources_save_all_button = built.get("save_all_button", null) as Button
	if _resources_save_all_button != null:
		_resources_save_all_button.pressed.connect(_on_resources_save_all_pressed)

	(page as Control).add_child(_missing_unique_resources_panel)
	_register_tab_component(
		HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"missing_unique_resources_panel",
		_missing_unique_resources_panel
	)
	_refresh_missing_unique_resources_panel()


func _mount_validation_issue_navigator() -> void:
	var page = _tab_pages.get(HexMapWorkspaceComponentRegistry.TAB_VALIDATE, null)
	if page == null or _validation_issue_navigator != null:
		return
	var built := HexMapValidateScreen.build_validation_issue_navigator()
	_validation_issue_navigator = built.get("root", null) as VBoxContainer
	_validation_run_button = built.get("run_button", null) as Button
	_validation_run_button.pressed.connect(_on_validate_screen_run_pressed)
	_validation_issue_status_label = built.get("status_label", null) as Label
	_validation_issue_selected_label = built.get("selected_label", null) as Label
	_validation_issue_rows_label = built.get("rows_label", null) as Label
	(page as Control).add_child(_validation_issue_navigator)
	_register_tab_component(
		HexMapWorkspaceComponentRegistry.TAB_VALIDATE,
		"validation_issue_navigator",
		_validation_issue_navigator
	)
	_refresh_validation_issue_navigator()


func _mount_qa_seed_lab_panel() -> void:
	var page = _tab_pages.get(HexMapWorkspaceComponentRegistry.TAB_QA, null)
	if page == null or _qa_seed_lab_panel != null:
		return
	var built := HexMapQAScreen.build_seed_lab_panel()
	_qa_seed_lab_panel = built.get("root", null) as VBoxContainer
	_qa_seed_lab_status_label = built.get("status_label", null) as Label
	_qa_seed_lab_selected_label = built.get("selected_label", null) as Label
	_qa_seed_lab_selected_thumbnail = built.get("selected_thumbnail", null) as HexMapPreviewThumbnail
	_qa_seed_lab_score_tree = built.get("score_tree", null) as Tree
	_qa_seed_lab_rows_label = built.get("rows_label", null) as Label

	(page as Control).add_child(_qa_seed_lab_panel)
	_register_tab_component(
		HexMapWorkspaceComponentRegistry.TAB_QA,
		"qa_seed_lab_panel",
		_qa_seed_lab_panel
	)
	_refresh_qa_seed_lab_panel()


func _mount_export_purpose_panel() -> void:
	var page = _tab_pages.get(HexMapWorkspaceComponentRegistry.TAB_EXPORT, null)
	if page == null or _export_purpose_panel != null:
		return
	var built := HexMapExportScreen.build_export_purpose_panel()
	_export_purpose_panel = built.get("root", null) as VBoxContainer
	_export_purpose_status_label = built.get("status_label", null) as Label
	_export_runtime_handoff_summary_label = built.get("runtime_handoff_summary_label", null) as Label
	_export_purpose_card_buttons = built.get("purpose_card_buttons", {}) as Dictionary
	_export_purpose_mode_label = built.get("mode_label", null) as Label
	_export_purpose_backlog_label = built.get("backlog_label", null) as Label
	_export_secondary_action_buttons = built.get("secondary_action_buttons", {}) as Dictionary
	for card_id in _export_purpose_card_buttons.keys():
		var button = _export_purpose_card_buttons[card_id] as Button
		if button != null:
			button.pressed.connect(_on_export_purpose_card_pressed.bind(String(card_id)))
	for action_id in _export_secondary_action_buttons.keys():
		var button = _export_secondary_action_buttons[action_id] as Button
		if button != null:
			button.pressed.connect(_on_export_secondary_action_pressed.bind(String(action_id)))

	(page as Control).add_child(_export_purpose_panel)
	_register_tab_component(
		HexMapWorkspaceComponentRegistry.TAB_EXPORT,
		"export_purpose_panel",
		_export_purpose_panel
	)
	_refresh_export_purpose_panel()


func _mount_export_destination_panel() -> void:
	var page = _tab_pages.get(HexMapWorkspaceComponentRegistry.TAB_EXPORT, null)
	if page == null:
		return
	var built := HexMapExportScreen.build_export_destination_panel()
	_export_destination_panel = built.get("root", null) as VBoxContainer
	_export_destination_label = built.get("destination_label", null) as Label
	_export_recent_destinations_label = built.get("recent_destinations_label", null) as Label
	_export_choose_destination_button = built.get("choose_destination_button", null) as Button
	_export_choose_destination_button.pressed.connect(_on_export_choose_destination_pressed)
	_export_use_recent_button = built.get("use_recent_button", null) as Button
	_export_use_recent_button.pressed.connect(_on_export_use_recent_pressed)
	_export_run_button = built.get("run_button", null) as Button
	_export_run_button.pressed.connect(_on_export_run_workspace_pressed)

	(page as Control).add_child(_export_destination_panel)
	_register_tab_component(
		HexMapWorkspaceComponentRegistry.TAB_EXPORT,
		"export_destination_panel",
		_export_destination_panel
	)
	_refresh_export_destination_panel()


func _mount_settings_preferences_panel() -> void:
	var page = _tab_pages.get(HexMapWorkspaceComponentRegistry.TAB_SETTINGS, null)
	if page == null or _settings_preferences_panel != null:
		return
	var built := HexMapSettingsScreen.build_settings_preferences_panel()
	_settings_preferences_panel = built.get("root", null) as VBoxContainer
	_settings_preferences_status_label = built.get("status_label", null) as Label
	_settings_preferences_debug_label = built.get("debug_label", null) as Label
	_settings_preferences_resource_label = built.get("resource_label", null) as Label

	(page as Control).add_child(_settings_preferences_panel)
	_register_tab_component(
		HexMapWorkspaceComponentRegistry.TAB_SETTINGS,
		"settings_preferences_panel",
		_settings_preferences_panel
	)
	_refresh_settings_preferences_panel()


func _slot_row(slot_id: String, display_name: String, required: bool = true) -> Dictionary:
	return {
		"slot_id": slot_id,
		"display_name": display_name,
		"required": required,
		"required_type": HexMapWorkspaceAssetResourceFactory.resource_type_name(slot_id),
		"purpose": HexMapWorkspaceAssetResourceFactory.resource_purpose(slot_id),
		"type_filter_reason": HexMapWorkspaceAssetResourceFactory.type_filter_reason(slot_id),
		"allows_create_new": true,
	}


func _resource_group_row(
	group_id: String,
	label: String,
	slot_ids: PackedStringArray,
	tooltip: String
) -> Dictionary:
	var context := workspace_asset_context()
	var selected_snapshot := selected_hex_tile_map_snapshot()
	var selected := bool(selected_snapshot.get("selected", false))
	var binding_state = selected_snapshot.get("binding_state", {}) as Dictionary
	var manual_override_slot_ids := PackedStringArray(binding_state.get("manual_override_slot_ids", PackedStringArray()))
	var hydrated_slot_ids := PackedStringArray(binding_state.get("hydrated_dependency_slot_ids", PackedStringArray()))
	var source_snapshot := context.source_snapshot()
	var slot_labels := PackedStringArray()
	var missing_labels := PackedStringArray()
	var slot_status_rows: Array[Dictionary] = []
	var tooltip_lines := PackedStringArray()
	tooltip_lines.append(tooltip)
	var ready_count := 0
	for slot_id in slot_ids:
		var actual_slot_id := String(slot_id)
		var text := _resource_group_slot_label(actual_slot_id)
		slot_labels.append(text)
		var resource := context.asset_for_slot(actual_slot_id)
		if resource != null:
			ready_count += 1
		else:
			missing_labels.append(text)
		var source = source_snapshot.get(actual_slot_id, {}) as Dictionary
		var badge := _resource_source_badge_for_slot(
			actual_slot_id,
			resource,
			source,
			manual_override_slot_ids,
			hydrated_slot_ids,
			selected
		)
		slot_status_rows.append({
			"slot_id": actual_slot_id,
			"label": text,
			"present": resource != null,
			"source_badge": badge,
			"status_text": "%s: %s" % [text, badge],
		})
		var purpose := HexMapWorkspaceAssetResourceFactory.resource_purpose(actual_slot_id)
		if purpose != "":
			tooltip_lines.append("%s: %s" % [text, purpose])
	var status_text := "%d/%d ready" % [ready_count, slot_ids.size()]
	if not missing_labels.is_empty():
		status_text += " | Missing: %s" % _join_text(missing_labels, ", ")
	return {
		"group_id": group_id,
		"label": label,
		"slot_ids": slot_ids.duplicate(),
		"slot_labels": slot_labels,
		"slot_status_rows": slot_status_rows,
		"ready_count": ready_count,
		"missing_count": missing_labels.size(),
		"missing_labels": missing_labels,
		"status_text": status_text,
		"tooltip": "\n".join(tooltip_lines),
	}


func _resource_group_slot_label(slot_id: String) -> String:
	match slot_id:
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT:
			return "Level Document"
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK:
			return "Layer Stack"
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG:
			return "Tile Catalog"
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE:
			return "Object Database"
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE:
			return "Label Database"
		HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE:
			return "Movement Profile"
		_:
			return slot_id.capitalize()


func _document_asset_panel() -> HexMapWorkspaceAssetPanel:
	return _asset_panels.get(HexMapWorkspaceComponentRegistry.TAB_DOCUMENT, null) as HexMapWorkspaceAssetPanel


func _catalog_asset_panel() -> HexMapWorkspaceAssetPanel:
	return _asset_panels.get(HexMapWorkspaceComponentRegistry.TAB_CATALOG, null) as HexMapWorkspaceAssetPanel


func _layer_stack_asset_panel() -> HexMapWorkspaceAssetPanel:
	return _asset_panels.get(HexMapWorkspaceComponentRegistry.TAB_LAYERS, null) as HexMapWorkspaceAssetPanel


func _object_label_asset_panel() -> HexMapWorkspaceAssetPanel:
	return _document_asset_panel()


func _qa_asset_panel() -> HexMapWorkspaceAssetPanel:
	return _asset_panels.get(HexMapWorkspaceComponentRegistry.TAB_QA, null) as HexMapWorkspaceAssetPanel


func _export_asset_panel() -> HexMapWorkspaceAssetPanel:
	return _asset_panels.get(HexMapWorkspaceComponentRegistry.TAB_EXPORT, null) as HexMapWorkspaceAssetPanel


func _sync_session_document_from_result(result: Dictionary, reason: String) -> void:
	if not bool(result.get("ok", false)):
		return
	var document = result.get("resource", null) as HexMapDocumentResource
	if document == null:
		return
	var path := String(result.get("path", document.resource_path))
	_ensure_session_state().set_document(document, "workspace.document_asset_screen", path, reason)
	_ensure_session_state().set_document_saved_path(path, reason)
	_hydrate_workspace_context_from_document_dependencies(document)


func _hydrate_workspace_context_from_document_dependencies(document: HexMapDocumentResource = null) -> Dictionary:
	if _hydrating_document_dependencies:
		return _last_document_dependency_hydration.duplicate(true)
	_hydrating_document_dependencies = true
	var result := HexMapWorkspaceBindingService.hydrate_context_from_document_dependencies(
		workspace_asset_context(),
		document
	)
	_hydrating_document_dependencies = false
	_last_document_dependency_hydration = result.duplicate(true)
	_sync_workspace_asset_context()
	return _last_document_dependency_hydration.duplicate(true)


func _document_dependency_hydration_snapshot(document: HexMapDocumentResource = null) -> Dictionary:
	return HexMapWorkspaceBindingService.document_dependency_hydration_snapshot(
		workspace_asset_context(),
		document,
		_last_document_dependency_hydration
	)


func _sync_layer_stack_from_result(result: Dictionary) -> void:
	if not bool(result.get("ok", false)):
		return
	var stack = result.get("resource", null) as HexLayerStackResource
	if stack == null:
		return
	workspace_asset_context().set_layer_stack(stack)
	if _edit_tool != null:
		_edit_tool.set_layer_stack_resource(stack, false)
	_sync_workspace_asset_context()


func _sync_object_database_from_result(result: Dictionary) -> void:
	if not bool(result.get("ok", false)):
		return
	var database = result.get("resource", null) as HexObjectDatabaseResource
	if database == null:
		return
	workspace_asset_context().set_object_database(database)
	if _edit_tool != null:
		_edit_tool.set_object_database(database, false)
	_sync_workspace_asset_context()


func _sync_label_database_from_result(result: Dictionary) -> void:
	if not bool(result.get("ok", false)):
		return
	var database = result.get("resource", null) as HexLabelDatabaseResource
	if database == null:
		return
	workspace_asset_context().set_label_database(database)
	if _edit_tool != null:
		_edit_tool.set_label_database(database, false)
	_sync_workspace_asset_context()


func _sync_generation_profile_from_result(result: Dictionary) -> void:
	if not bool(result.get("ok", false)):
		return
	var resource = result.get("resource", null) as HexGenerationProfileResource
	if resource == null:
		return
	workspace_asset_context().set_generation_profile(resource)
	_sync_workspace_asset_context()


func _sync_validation_suite_from_result(result: Dictionary) -> void:
	if not bool(result.get("ok", false)):
		return
	var resource = result.get("resource", null) as HexValidationRuleSuiteResource
	if resource == null:
		return
	workspace_asset_context().set_validation_rule_suite(resource)
	_sync_workspace_asset_context()


func _sync_export_profile_from_result(result: Dictionary) -> void:
	if not bool(result.get("ok", false)):
		return
	var resource = result.get("resource", null) as HexExportProfileResource
	if resource == null:
		return
	workspace_asset_context().set_export_profile(resource)
	_sync_workspace_asset_context()


func _document_validation_options() -> Dictionary:
	var context := workspace_asset_context()
	var options := {}
	if context.tile_catalog != null:
		options["tile_catalog"] = context.tile_catalog
		if context.tile_catalog.tile_set != null:
			options["tile_set"] = context.tile_catalog.tile_set
	if context.object_database != null:
		options["object_database"] = context.object_database
	if context.movement_profile != null:
		options["movement_profile"] = context.movement_profile
	if context.validation_rule_suite != null:
		options["validation_rule_suite"] = context.validation_rule_suite
	return options


func _add_missing_asset_issue(
	result: HexMapValidationResult,
	missing: bool,
	rule_id: String,
	message: String,
	target_tab: String,
	target_component_id: String,
	target_slot_id: String
) -> void:
	if not missing:
		return
	result.add_error(
		rule_id,
		message,
		HexMapValidationResult.SCOPE_DEPENDENCY,
		{
			"metadata": {
				"target_tab": target_tab,
				"target_component_id": target_component_id,
				"target_slot_id": target_slot_id,
			},
		}
	)


func _update_workspace_validation_counts(result: HexMapValidationResult) -> void:
	if result == null:
		return
	result.summary["errors"] = result.error_count()
	result.summary["warnings"] = result.warning_count()
	result.summary["infos"] = result.info_count()
	result.summary["issues"] = result.issue_count()


func _document_action_result(ok: bool, error: int, path: String) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"slot_id": HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
		"path": path,
		"resource": null,
	}


func _catalog_action_result(ok: bool, error: int, path: String) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"slot_id": HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		"path": path,
		"resource": null,
	}


func _layer_stack_action_result(ok: bool, error: int, path: String) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"slot_id": HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
		"path": path,
		"resource": null,
	}


func _object_database_action_result(ok: bool, error: int, path: String) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"slot_id": HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE,
		"path": path,
		"resource": null,
	}


func _label_database_action_result(ok: bool, error: int, path: String) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"slot_id": HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE,
		"path": path,
		"resource": null,
	}


func _object_definition_action_result(ok: bool, error: int, definition_id: String, definition) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"definition_id": definition_id,
		"definition": definition,
		"payload": _edit_tool.object_placement_payload_snapshot() if _edit_tool != null else {},
	}


func _label_definition_action_result(ok: bool, error: int, label_id: String, definition) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"label_id": label_id,
		"definition": definition,
		"payload": _edit_tool.label_placement_payload_snapshot() if _edit_tool != null else {},
	}


func _paint_brush_action_result(ok: bool, error: int, mode_id: String) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"mode": mode_id,
		"brush": _edit_tool.paint_brush_snapshot() if _edit_tool != null else {},
	}


func _generation_profile_action_result(ok: bool, error: int, path: String) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"slot_id": HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE,
		"path": path,
		"resource": null,
	}


func _validation_suite_action_result(ok: bool, error: int, path: String) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"slot_id": HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE,
		"path": path,
		"resource": null,
	}


func _export_profile_action_result(ok: bool, error: int, path: String) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"slot_id": HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE,
		"path": path,
		"resource": null,
	}


func _export_action_result(ok: bool, error: int, path: String) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"path": path,
		"destination": _export_destination_context(),
	}


func _finalize_export_action_result(result: Dictionary) -> Dictionary:
	_last_export_action_result = result.duplicate(true)
	var export_state := export_workflow_state_snapshot()
	result["export_state"] = export_state
	result["view_state"] = export_state.get("view_state", {})
	_refresh_export_purpose_panel()
	_refresh_export_destination_panel()
	return result


func _write_text_export(path: String, text: String, output_type: String, purpose_text: String) -> Dictionary:
	if path.strip_edges() == "":
		var invalid_result := _export_action_result(false, ERR_INVALID_PARAMETER, path)
		invalid_result["output_type"] = output_type
		invalid_result["purpose_text"] = purpose_text
		return invalid_result
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var file := FileAccess.open(path, FileAccess.WRITE)
	var error := OK
	if file == null:
		error = FileAccess.get_open_error()
	else:
		file.store_string(text)
	var result := _export_action_result(error == OK, error, path)
	result["output_type"] = output_type
	result["purpose_text"] = purpose_text
	result["resource_class"] = "Text"
	result["byte_count"] = text.length()
	return result


func _export_json_snapshot_payload() -> Dictionary:
	var snapshot := export_screen_snapshot()
	return {
		"tab": String(snapshot.get("tab", "")),
		"screen_role_source": String(snapshot.get("screen_role_source", "")),
		"handoff_boundary": "godot_loadable_map",
		"gameplay_framework": false,
		"purpose_cards": _duplicate_dictionary_array(snapshot.get("purpose_cards", []) as Array),
		"secondary_actions": _duplicate_dictionary_array(snapshot.get("secondary_actions", []) as Array),
		"purpose_card_ids": PackedStringArray(snapshot.get("purpose_card_ids", PackedStringArray())),
		"secondary_action_ids": PackedStringArray(snapshot.get("secondary_action_ids", PackedStringArray())),
		"destination": (snapshot.get("destination", {}) as Dictionary).duplicate(true),
		"export_state": _export_state_json_payload(snapshot.get("export_state", {}) as Dictionary),
	}


func _export_state_json_payload(state: Dictionary) -> Dictionary:
	return {
		"state_id": String(state.get("state_id", "")),
		"state_source": String(state.get("state_source", "")),
		"active_state_ids": PackedStringArray(state.get("active_state_ids", PackedStringArray())),
		"can_export": bool(state.get("can_export", false)),
		"exporting": bool(state.get("exporting", false)),
		"block_reason": String(state.get("block_reason", "")),
	}


func _duplicate_dictionary_array(value: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in value:
		if entry is Dictionary:
			result.append((entry as Dictionary).duplicate(true))
	return result


func _profile_resource_context(context: HexMapWorkspaceAssetContext, slot_id: String) -> Dictionary:
	var resource := context.asset_for_slot(slot_id) if context != null else null
	var required_type := HexMapWorkspaceAssetResourceFactory.resource_type_name(slot_id)
	var source := context.asset_source(slot_id) if context != null else HexMapWorkspaceAssetContext.SOURCE_NONE
	var source_badge := context.asset_source_badge(slot_id) if context != null else HexMapWorkspaceAssetContext.SOURCE_BADGE_NONE
	if resource == null:
		return {
			"selected": false,
			"resource_name": "",
			"resource_path": "",
			"resource_class": "",
			"required_type": required_type,
			"source": source,
			"source_badge": source_badge,
			"status": "optional_missing" if _profile_slot_is_optional(slot_id) else "missing",
			"missing_state": "optional" if _profile_slot_is_optional(slot_id) else "required",
			"preset_source": "",
			"behavior_schema": {},
			"behavior_schema_kind": "",
			"behavior_schema_status": "optional_missing" if _profile_slot_is_optional(slot_id) else "missing",
			"behavior_summary": "",
		}
	var metadata = resource.get("metadata") if resource != null else {}
	var metadata_preset_source := ""
	if metadata is Dictionary:
		metadata_preset_source = String((metadata as Dictionary).get("preset_source", ""))
	var behavior_schema := _profile_behavior_schema(resource)
	return {
		"selected": true,
		"resource_name": resource.resource_name,
		"resource_path": resource.resource_path,
		"resource_class": _resource_class_name(resource),
		"required_type": required_type,
		"source": source,
		"source_badge": source_badge,
		"status": "selected",
		"missing_state": "",
		"preset_source": metadata_preset_source if metadata_preset_source != "" else String(resource.get_meta("preset_source", "")),
		"behavior_schema": behavior_schema,
		"behavior_schema_kind": String(behavior_schema.get("kind", "")),
		"behavior_schema_status": "selected" if not behavior_schema.is_empty() else "unavailable",
		"behavior_summary": _profile_behavior_summary(behavior_schema),
	}


func _profile_slot_is_optional(slot_id: String) -> bool:
	return slot_id == HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE \
		or slot_id == HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE \
		or slot_id == HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE


func _profile_behavior_schema(resource: Resource) -> Dictionary:
	if resource == null or not resource.has_method("behavior_schema"):
		return {}
	var schema = resource.call("behavior_schema")
	return (schema as Dictionary).duplicate(true) if schema is Dictionary else {}


func _profile_behavior_summary(schema: Dictionary) -> String:
	var kind := String(schema.get("kind", ""))
	match kind:
		"validation_rule_suite":
			var enabled = schema.get("enabled_rule_ids", PackedStringArray())
			var disabled = schema.get("disabled_rule_ids", PackedStringArray())
			var targets = schema.get("validation_targets", PackedStringArray())
			var explicit_count := (enabled as PackedStringArray).size() if enabled is PackedStringArray else 0
			var disabled_count := (disabled as PackedStringArray).size() if disabled is PackedStringArray else 0
			var target_count := (targets as PackedStringArray).size() if targets is PackedStringArray else 0
			return "Validation schema: %d explicit rules, %d disabled, %d targets" % [
				explicit_count,
				disabled_count,
				target_count,
			]
		"generation_profile":
			var shape = schema.get("shape", {}) as Dictionary
			var terrain = schema.get("terrain", {}) as Dictionary
			return "Generation schema: %s %dx%d, connectivity %s" % [
				String(shape.get("shape_id", "")),
				int(shape.get("width", 0)),
				int(shape.get("height", 0)),
				String(terrain.get("connectivity_mode", "")),
			]
		"export_profile":
			return "Export schema: %s%s, runtime queries %s" % [
				String(schema.get("output_type", "")),
				String(schema.get("file_extension", "")),
				_bool_label(bool(schema.get("include_runtime_queries", false))),
			]
	return ""


func _resource_class_name(resource: Resource) -> String:
	if resource == null:
		return ""
	var script = resource.get_script()
	if script != null and script.has_method("get_global_name"):
		var global_name = String(script.call("get_global_name"))
		if global_name != "":
			return global_name
	return resource.get_class()


func _qa_promotion_target_context(context: HexMapWorkspaceAssetContext) -> Dictionary:
	var document := context.level_document
	return {
		"document": document,
		"selected": document != null,
		"status": "Level Document linked" if document != null else "No Level Document selected",
		"resource_path": document.resource_path if document != null else "",
		"promoted": document != null and document == _qa_promoted_document,
		"generation_seed": document.metadata.generation_seed if document != null and document.metadata != null else 0,
		"generation_result_id": String(document.metadata.custom_properties.get("generation_result_id", "")) \
			if document != null and document.metadata != null else "",
	}


func _export_destination_context() -> Dictionary:
	var session := _ensure_session_state()
	var recent: Array[String] = []
	for destination in session.recent_export_destinations:
		recent.append(String(destination))
	var output_paths := _export_output_paths(session.export_saved_path)
	return {
		"selected": session.export_saved_path != "",
		"path": session.export_saved_path,
		"output_paths": output_paths,
		"recent_destinations": recent,
		"uses_file_dialog": true,
		"editable_path_text_visible": false,
		"output_type": "runtime_handoff_resource",
		"target_resource_class": "HexMapResource",
	}


func _export_purpose_context(context: HexMapWorkspaceAssetContext, destination: Dictionary) -> Dictionary:
	var selected_snapshot := selected_hex_tile_map_snapshot()
	var graph_resource = selected_snapshot.get("generation_graph", null) as HexGenerationGraphResource
	return {
		"source_ready": context != null and context.level_document != null,
		"destination_ready": bool(destination.get("selected", false)),
		"graph_ready": graph_resource != null,
		"graph_resource": graph_resource,
		"block_reason": _export_cannot_export_reason(context, destination),
	}


func _export_output_paths(base_path: String) -> Dictionary:
	var path := base_path.strip_edges()
	if path == "":
		return {}
	return {
		HexMapExportScreen.PURPOSE_RUNTIME_MAP: path,
		HexMapExportScreen.PURPOSE_RUNTIME_SCENE: _path_with_extension(path, ".tscn"),
		HexMapExportScreen.PURPOSE_GENERATION_GRAPH: _path_with_suffix_and_extension(path, "_graph", ".tres"),
		HexMapExportScreen.SECONDARY_DEBUG_REPORT: _path_with_suffix_and_extension(path, "_debug", ".txt"),
		HexMapExportScreen.SECONDARY_JSON_SNAPSHOT: _path_with_suffix_and_extension(path, "_snapshot", ".json"),
	}


func _export_output_type_context(context: HexMapWorkspaceAssetContext, destination: Dictionary) -> Dictionary:
	var export_options := _active_export_options(context)
	var output_type_id := _export_output_type_id(export_options)
	var file_extension := _export_file_extension(export_options)
	return {
		"id": output_type_id,
		"label": "Runtime Handoff Resource",
		"source": "Current Level Document",
		"target_resource_class": "HexMapResource",
		"file_extension": file_extension,
		"result_purpose_text": "Runtime/API handoff for HexMapResource consumers.",
		"result_usage": "Runtime and scripting use",
		"destination_required": true,
		"destination_purpose": "Project %s path for the runtime handoff resource." % file_extension,
		"result_state_source": "HexMapExportWorkflowState",
		"package_support_boundary": "Package build stays in the developer release process.",
		"debug_report_boundary": "Debug reports stay diagnostic outside production Export.",
		"source_ready": context.level_document != null,
		"destination_ready": bool(destination.get("selected", false)),
		"export_profile_optional": true,
		"export_options": export_options.duplicate(true),
		"include_metadata": _export_include_flag(export_options, "include_metadata", true),
		"include_validation_summary": _export_include_flag(
			export_options,
			"include_validation_summary",
			false
		),
		"include_runtime_queries": _export_include_flag(
			export_options,
			"include_runtime_queries",
			true
		),
		"include_debug_report": _export_include_flag(export_options, "include_debug_report", false),
	}


func _active_export_options(context: HexMapWorkspaceAssetContext) -> Dictionary:
	if context == null or context.export_profile == null:
		return {}
	if not context.export_profile.has_method("export_options"):
		return {}
	var options = context.export_profile.call("export_options")
	return (options as Dictionary).duplicate(true) if options is Dictionary else {}


func _active_export_file_extension(context: HexMapWorkspaceAssetContext) -> String:
	return _export_file_extension(_active_export_options(context))


func _export_output_type_id(options: Dictionary) -> String:
	var value := String(options.get("output_type", "runtime_handoff_resource")).strip_edges()
	return "runtime_handoff_resource" if value == "" else value


func _export_file_extension(options: Dictionary) -> String:
	var value := String(options.get("file_extension", ".tres")).strip_edges()
	if value == "":
		return ".tres"
	return value if value.begins_with(".") else ".%s" % value


func _export_include_flag(options: Dictionary, key: String, default_value: bool) -> bool:
	if not options.has(key):
		return default_value
	return bool(options.get(key, default_value))


func _export_runtime_handoff_summary(
	context: HexMapWorkspaceAssetContext,
	destination: Dictionary,
	output_type: Dictionary,
	export_state: Dictionary,
	can_export: bool
) -> Dictionary:
	var profile_selected := context.export_profile != null
	var export_view_state = export_state.get("view_state", {}) as Dictionary
	var rows: Array[Dictionary] = [
		{
			"id": "source_document",
			"label": "Source",
			"status": "ready" if context.level_document != null else "missing",
			"visible_text": "Source: %s" % ("Level Document ready" if context.level_document != null else "Level Document missing"),
		},
		{
			"id": "destination",
			"label": "Destination",
			"status": "ready" if bool(destination.get("selected", false)) else "missing",
			"visible_text": "Destination: %s" % ("Selected" if bool(destination.get("selected", false)) else "Missing"),
		},
		{
			"id": "export_profile",
			"label": "Export Profile",
			"status": "selected" if profile_selected else "optional",
			"visible_text": "Export Profile: %s" % ("Selected" if profile_selected else "Optional"),
		},
		{
			"id": "output_type",
			"label": "Output",
			"status": "available",
			"visible_text": "Output: %s" % String(output_type.get("label", "Runtime Handoff")),
		},
		{
			"id": "run_action",
			"label": "Action",
			"status": "ready" if can_export else "blocked",
			"visible_text": "Action: %s" % ("Ready" if can_export else "Blocked"),
		},
		{
			"id": "result_state",
			"label": "Result",
			"status": String(export_state.get("state_id", "")),
			"visible_text": "Result: %s" % String(export_view_state.get("status_text", export_state.get("state_id", ""))),
		},
	]
	return {
		"surface_id": "runtime_handoff_summary",
		"visible": true,
		"readiness_rows": rows,
		"visible_text": _readiness_rows_text(rows),
		"destination_path_visible": false,
		"primary_path_text_visible": false,
	}


func _export_output_modes() -> Array[Dictionary]:
	return [
		{
			"id": "runtime_handoff_resource",
			"label": "Runtime Handoff",
			"status": "available",
			"active": true,
			"visible_in_export_tab": true,
			"description": "Writes the current Level Document as a HexMapResource .tres for runtime/API use.",
		},
		{
			"id": "data_export_json",
			"label": "Data Export",
			"status": "backlog",
			"active": false,
			"visible_in_export_tab": false,
			"description": "JSON/external formats are not active Export tab controls.",
		},
		{
			"id": "package_build",
			"label": "Package Build",
			"status": "process",
			"active": false,
			"visible_in_export_tab": false,
			"description": "Addon/package generation stays in the developer release process.",
		},
		{
			"id": "debug_report",
			"label": "Debug Report",
			"status": "diagnostic",
			"active": false,
			"visible_in_export_tab": false,
			"description": "Debug reports remain diagnostic actions outside production Export.",
		},
	]


func _export_visible_output_mode_ids(modes: Array) -> PackedStringArray:
	var ids := PackedStringArray()
	for mode in modes:
		if not mode is Dictionary:
			continue
		if bool((mode as Dictionary).get("visible_in_export_tab", false)):
			ids.append(String((mode as Dictionary).get("id", "")))
	return ids


func _export_visible_output_mode_labels(modes: Array) -> PackedStringArray:
	var labels := PackedStringArray()
	for mode in modes:
		if not mode is Dictionary:
			continue
		if bool((mode as Dictionary).get("visible_in_export_tab", false)):
			labels.append(String((mode as Dictionary).get("label", "")))
	return labels


func _export_purpose_card_ids(cards: Array) -> PackedStringArray:
	var ids := PackedStringArray()
	for card in cards:
		if card is Dictionary and bool((card as Dictionary).get("visible", false)):
			ids.append(String((card as Dictionary).get("id", "")))
	return ids


func _export_purpose_card_titles(cards: Array) -> PackedStringArray:
	var titles := PackedStringArray()
	for card in cards:
		if card is Dictionary and bool((card as Dictionary).get("visible", false)):
			titles.append(String((card as Dictionary).get("title", "")))
	return titles


func _export_secondary_action_ids(actions: Array) -> PackedStringArray:
	var ids := PackedStringArray()
	for action in actions:
		if action is Dictionary and bool((action as Dictionary).get("visible", false)):
			ids.append(String((action as Dictionary).get("id", "")))
	return ids


func _export_secondary_action_tooltip(actions: Array, action_id: String) -> String:
	for action in actions:
		if not action is Dictionary:
			continue
		if String((action as Dictionary).get("id", "")) == action_id:
			return String((action as Dictionary).get("tooltip", ""))
	return ""


func _export_use_recent_button_tooltip(session) -> String:
	if session == null or session.recent_export_destinations.is_empty():
		return "No recent Runtime Handoff destinations."
	return "Use recent Runtime Handoff destination: %s" % String(session.recent_export_destinations[0])


func _export_run_button_tooltip(context: HexMapWorkspaceAssetContext, destination: Dictionary) -> String:
	var reason := _export_cannot_export_reason(context, destination)
	if reason != "":
		return reason
	return "Create a Runtime Handoff HexMapResource at the selected destination."


func _export_cannot_export_reason(context: HexMapWorkspaceAssetContext, destination: Dictionary) -> String:
	if context.level_document == null:
		return "Level Document is not selected."
	if not bool(destination.get("selected", false)):
		return "Export destination is not selected."
	return ""


func _export_handoff_context(path: String, resource) -> Dictionary:
	var map_data = resource.to_map_data() if resource != null else null
	return {
		"selected": path != "",
		"path": path,
		"resource_class": "HexMapResource" if path != "" or resource != null else "",
		"cell_count": map_data.cells.size() if map_data != null else 0,
		"wall_count": map_data.walls.size() if map_data != null else 0,
	}


func _export_scene_handoff_context(destination: Dictionary) -> Dictionary:
	var paths = destination.get("output_paths", {}) as Dictionary
	var path := String(paths.get(HexMapExportScreen.PURPOSE_RUNTIME_SCENE, ""))
	return {
		"selected": path != "",
		"path": path,
		"resource_class": "PackedScene" if path != "" else "",
		"gameplay_framework": false,
	}


func _export_graph_handoff_context(destination: Dictionary) -> Dictionary:
	var paths = destination.get("output_paths", {}) as Dictionary
	var path := String(paths.get(HexMapExportScreen.PURPOSE_GENERATION_GRAPH, ""))
	var graph := _selected_generation_graph_resource()
	return {
		"selected": path != "",
		"path": path,
		"resource_class": "HexGenerationGraphResource" if path != "" else "",
		"graph_ready": graph != null,
		"ownership_semantics": "embed" if graph != null else "",
		"gameplay_framework": false,
	}


func _selected_generation_graph_resource() -> HexGenerationGraphResource:
	var layer := _ensure_session_state().current_selected_hex_tile_map_layer() as HexTileMapLayer
	return layer.generation_graph_resource if layer != null else null


func _export_path_for_purpose(purpose_id: String, path: String = "") -> String:
	var actual_path := path.strip_edges()
	if actual_path != "":
		return _path_for_purpose_extension(purpose_id, actual_path)
	var destination := _export_destination_context()
	var output_paths = destination.get("output_paths", {}) as Dictionary
	return String(output_paths.get(purpose_id, ""))


func _path_for_purpose_extension(purpose_id: String, path: String) -> String:
	match purpose_id:
		HexMapExportScreen.PURPOSE_RUNTIME_SCENE:
			return _path_with_extension(path, ".tscn")
		HexMapExportScreen.PURPOSE_GENERATION_GRAPH:
			return _path_with_extension(path, ".tres")
		HexMapExportScreen.SECONDARY_DEBUG_REPORT:
			return _path_with_extension(path, ".txt")
		HexMapExportScreen.SECONDARY_JSON_SNAPSHOT:
			return _path_with_extension(path, ".json")
	return path


func _path_with_extension(path: String, extension: String) -> String:
	var actual_extension := extension if extension.begins_with(".") else ".%s" % extension
	return "%s%s" % [path.get_basename(), actual_extension]


func _path_with_suffix_and_extension(path: String, suffix: String, extension: String) -> String:
	var actual_extension := extension if extension.begins_with(".") else ".%s" % extension
	return "%s%s%s" % [path.get_basename(), suffix, actual_extension]


func _generation_profile_preset(preset_id: String) -> Resource:
	var id := preset_id.strip_edges().to_lower()
	if not ["balanced", "sparse", "dense"].has(id):
		return null
	var profile := HexGenerationProfileResource.new()
	profile.profile_id = id
	profile.display_name = "%s Generation Profile" % id.capitalize()
	profile.resource_name = "%s Generation Profile" % id.capitalize()
	profile.generator_id = "standard_map"
	profile.seed_policy = "preset_default"
	profile.shape_id = "rectangle"
	profile.width = 12
	profile.height = 8
	profile.wall_probability = 0.18
	profile.connectivity_mode = "dense"
	if id == "sparse":
		profile.wall_probability = 0.08
		profile.connectivity_mode = "sparse"
	elif id == "dense":
		profile.wall_probability = 0.28
		profile.connectivity_mode = "dense"
	profile.metadata = {
		"preset_source": id,
		"profile_kind": "generation",
	}
	profile.set_meta("preset_source", id)
	profile.set_meta("profile_kind", "generation")
	return profile


func _validation_rule_suite_preset(preset_id: String) -> Resource:
	var id := preset_id.strip_edges().to_lower()
	if id != "standard":
		return null
	var suite := HexValidationRuleSuiteResource.new()
	suite.suite_id = id
	suite.display_name = "Standard Validation Rule Suite"
	suite.resource_name = "Standard Validation Rule Suite"
	suite.validation_targets = PackedStringArray(["document", "dependencies", "catalog", "profiles"])
	suite.severity_overrides = {
		"document.object_on_wall": "error",
		"document.orphan_payload": "warning",
		"dependency.type_mismatch": "error",
	}
	suite.metadata = {
		"preset_source": id,
		"profile_kind": "validation",
	}
	suite.set_meta("preset_source", id)
	suite.set_meta("profile_kind", "validation")
	return suite


func _save_qa_preset_resource(resource: Resource, slot_id: String, preset_id: String, path: String) -> Dictionary:
	var actual_path := HexMapWorkspaceAssetResourceFactory.normalized_resource_path(path)
	if resource == null or actual_path == "":
		return {
			"ok": false,
			"error": ERR_INVALID_PARAMETER,
			"slot_id": slot_id,
			"path": actual_path,
			"resource": resource,
			"preset_id": preset_id,
		}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(actual_path.get_base_dir()))
	var error := ResourceSaver.save(resource, actual_path)
	if error == OK:
		resource.resource_path = actual_path
		workspace_asset_context().set_asset(slot_id, resource)
		_sync_workspace_asset_context()
	return {
		"ok": error == OK,
		"error": error,
		"slot_id": slot_id,
		"path": actual_path,
		"resource": resource,
		"preset_id": preset_id,
	}


func _layer_stack_template(template_id: String) -> HexLayerStackResource:
	match template_id.strip_edges().to_lower():
		"standard", "standard_authoring":
			return HexLayerStackResource.standard_template()
		"minimal", "minimal_runtime":
			return HexLayerStackResource.minimal_runtime_template()
	return null


func _mount_generation_panel() -> void:
	var page = _tab_pages.get(HexMapWorkspaceComponentRegistry.TAB_GENERATE, null)
	if page == null:
		return
	_build_screen = HexMapBuildScreen.new()
	_build_screen.set_workspace_asset_context(workspace_asset_context())
	_build_screen.set_build_context_provider(Callable(self, "_provide_build_context_for_screen"))
	_build_screen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_build_screen.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build_screen.load_graph_requested.connect(_on_build_load_graph_requested)
	_build_screen.build_context_requested.connect(_on_build_context_requested)
	(page as Control).add_child(_build_screen)
	_register_tab_component(HexMapWorkspaceComponentRegistry.TAB_GENERATE, "build_graph_screen", _build_screen)

	_generation_dock = HexMapGenDock.new()
	_generation_dock.set_editor_session_state(_ensure_session_state())
	_generation_dock.set_workspace_asset_context(workspace_asset_context())
	_generation_dock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_generation_dock.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_generation_dock.visible = false
	(page as Control).add_child(_generation_dock)
	_register_tab_component(HexMapWorkspaceComponentRegistry.TAB_GENERATE, "generation_panel", _generation_dock)


func _mount_edit_panel() -> void:
	var page = _tab_pages.get(HexMapWorkspaceComponentRegistry.TAB_PAINT, null)
	if page == null:
		return
	_edit_tool = HexMapEditTool.new()
	_edit_tool.set_editor_session_state(_ensure_session_state())
	_edit_tool.set_workspace_asset_context(workspace_asset_context())
	_edit_tool.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_edit_tool.size_flags_vertical = Control.SIZE_EXPAND_FILL
	(page as Control).add_child(_edit_tool)
	_register_tab_component(HexMapWorkspaceComponentRegistry.TAB_PAINT, "brush_palette", _edit_tool)


func _mount_sample_settings_panel() -> void:
	var page = _tab_pages.get(HexMapWorkspaceComponentRegistry.TAB_SETTINGS, null)
	if page == null:
		return
	_sample_settings_panel = HexMapSampleSettingsPanel.new()
	_sample_settings_panel.set_editor_session_state(_ensure_session_state())
	_sample_settings_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sample_settings_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	(page as Control).add_child(_sample_settings_panel)
	_register_tab_component(HexMapWorkspaceComponentRegistry.TAB_SETTINGS, "sample_settings_panel", _sample_settings_panel)
	_refresh_settings_preferences_panel()


func _refresh_export_destination_panel() -> void:
	if _export_destination_panel == null:
		return
	var session := _ensure_session_state()
	var context := workspace_asset_context()
	var destination := session.export_saved_path
	var destination_context := _export_destination_context()
	var empty_state := _export_tab_empty_state(context, destination_context)
	if _export_destination_label != null:
		_export_destination_label.text = _empty_state_inline_text(empty_state) \
			if bool(empty_state.get("visible", false)) else "Destination: %s" % destination
		_export_destination_label.tooltip_text = String(empty_state.get("help_tooltip", ""))
	if _export_recent_destinations_label != null:
		_export_recent_destinations_label.text = "Recent destinations: %d" % session.recent_export_destinations.size()
	if _export_use_recent_button != null:
		_export_use_recent_button.disabled = session.recent_export_destinations.is_empty()
		_export_use_recent_button.tooltip_text = _export_use_recent_button_tooltip(session)
	if _export_run_button != null:
		_export_run_button.disabled = context.level_document == null or destination == ""
		_export_run_button.tooltip_text = _export_run_button_tooltip(context, destination_context)


func _popup_generation_graph_dialog(overwrite_selected: bool) -> bool:
	if not Engine.is_editor_hint():
		return false
	_pending_graph_load_overwrite = overwrite_selected
	var dialog := HexMapEditorPathSelector.new_dialog(
		EditorFileDialog.FILE_MODE_OPEN_FILE,
		HexMapEditorPathSelector.TRES_FILTERS
	)
	dialog.file_selected.connect(_on_generation_graph_file_selected)
	return HexMapEditorPathSelector.popup_dialog(dialog)


func _on_build_load_graph_requested(overwrite_selected: bool) -> void:
	_popup_generation_graph_dialog(overwrite_selected)


func _on_build_context_requested() -> void:
	ensure_build_graph_context("workspace.build_screen.generate")


func _provide_build_context_for_screen(options: Dictionary = {}) -> Dictionary:
	var reason := String(options.get("reason", "workspace.build_screen.generate"))
	return ensure_build_graph_context(reason, options)


func _on_generation_graph_file_selected(path: String) -> void:
	load_generation_graph_path(
		path,
		_pending_graph_load_overwrite,
		"workspace.build_screen.load_graph"
	)


func _popup_export_destination_dialog() -> bool:
	if not Engine.is_editor_hint():
		return false
	var dialog := HexMapEditorPathSelector.new_dialog(
		EditorFileDialog.FILE_MODE_SAVE_FILE,
		HexMapEditorPathSelector.TRES_FILTERS
	)
	dialog.current_file = "hex_map_export.tres"
	dialog.file_selected.connect(_on_export_destination_file_selected)
	return HexMapEditorPathSelector.popup_dialog(dialog)


func _on_export_choose_destination_pressed() -> void:
	_popup_export_destination_dialog()


func _on_export_destination_file_selected(path: String) -> void:
	select_export_destination(path)


func _on_export_use_recent_pressed() -> void:
	var session := _ensure_session_state()
	if session.recent_export_destinations.is_empty():
		return
	select_recent_export_destination(String(session.recent_export_destinations[0]))


func _on_export_run_workspace_pressed() -> void:
	export_selected_document_to_destination()


func _on_export_purpose_card_pressed(purpose_id: String) -> void:
	press_export_purpose_action(purpose_id)


func _on_export_secondary_action_pressed(action_id: String) -> void:
	press_export_secondary_action(action_id)


func _on_catalog_board_card_pressed(entry_key: String) -> void:
	select_catalog_entry(entry_key)


func _popup_missing_unique_resources_directory_dialog() -> bool:
	if not Engine.is_editor_hint():
		return false
	var dialog := HexMapEditorPathSelector.new_dialog(
		EditorFileDialog.FILE_MODE_OPEN_DIR,
		[]
	)
	dialog.dir_selected.connect(_on_missing_unique_resources_directory_selected)
	return HexMapEditorPathSelector.popup_dialog(dialog)


func _on_missing_unique_resources_choose_directory_pressed() -> void:
	_popup_missing_unique_resources_directory_dialog()


func _on_missing_unique_resources_directory_selected(path: String) -> void:
	set_missing_unique_resources_save_directory(path)


func _on_missing_unique_resources_prefix_changed(_text: String) -> void:
	_refresh_missing_unique_resources_panel()


func _on_layer_stack_editor_role_selected(index: int) -> void:
	if _updating_layer_role_editor_controls or _layer_stack_role_editor_role_option == null:
		return
	select_layer_stack_role(String(_layer_stack_role_editor_role_option.get_item_metadata(index)))


func _on_layer_stack_visual_role_pressed(role: String) -> void:
	select_layer_stack_role(role)


func _on_layer_stack_visual_visible_toggled(value: bool, role: String) -> void:
	update_layer_stack_role_properties(role, {"visible": value})


func _on_layer_stack_visual_locked_toggled(value: bool, role: String) -> void:
	update_layer_stack_role_properties(role, {"locked": value})


func _on_layer_stack_editor_visible_toggled(value: bool) -> void:
	if _updating_layer_role_editor_controls:
		return
	update_layer_stack_role_properties(_selected_layer_stack_editor_role, {"visible": value})


func _on_layer_stack_editor_locked_toggled(value: bool) -> void:
	if _updating_layer_role_editor_controls:
		return
	update_layer_stack_role_properties(_selected_layer_stack_editor_role, {"locked": value})


func _on_layer_stack_editor_z_index_changed(value: float) -> void:
	if _updating_layer_role_editor_controls:
		return
	update_layer_stack_role_properties(_selected_layer_stack_editor_role, {"z_index": int(value)})


func _on_layer_stack_editor_writable_selected(index: int) -> void:
	if _updating_layer_role_editor_controls or _layer_stack_role_editor_writable_option == null:
		return
	update_layer_stack_role_properties(
		_selected_layer_stack_editor_role,
		{"writable_source": String(_layer_stack_role_editor_writable_option.get_item_metadata(index))}
	)


func _on_create_missing_unique_resources_pressed() -> void:
	create_missing_selected_hex_tile_map_resources(
		_missing_unique_resources_save_directory,
		_missing_unique_resources_prefix()
	)


func _on_resources_save_all_pressed() -> void:
	save_all_workspace_resources()


func _apply_selected_hex_tile_map_to_edit_tool() -> void:
	if _edit_tool == null:
		return
	var session := _ensure_session_state()
	var layer := session.current_selected_hex_tile_map_layer()
	if _edit_tool.target_layer() == layer:
		return
	_edit_tool.set_target_layer(layer)


func _sync_selected_hex_tile_map_resources() -> void:
	var session := _ensure_session_state()
	var layer := session.current_selected_hex_tile_map_layer()
	HexMapWorkspaceBindingService.sync_node_owned_context_from_layer(
		layer as HexTileMapLayer,
		workspace_asset_context()
	)


func _apply_workspace_asset_change_to_selected_node(slot_id: String, reason: String) -> Dictionary:
	var session := _ensure_session_state()
	var hex_layer := _ensure_session_state().current_selected_hex_tile_map_layer() as HexTileMapLayer
	var context := workspace_asset_context()
	var result := HexMapWorkspaceBindingService.apply_context_slot_to_selected_layer(
		hex_layer,
		session.selected_hex_tile_map_auto_link_enabled(),
		context,
		slot_id
	)
	if not bool(result.get("ok", false)):
		return result
	match slot_id:
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT:
			var document := context.level_document
			_ensure_session_state().set_document(
				document,
				"workspace.asset_context",
				document.resource_path if document != null else "",
				reason
			)
			_refresh_selected_hex_tile_map_context()
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK:
			var stack := context.layer_stack
			if _edit_tool != null:
				_edit_tool.set_layer_stack_resource(stack, false)
			_refresh_selected_hex_tile_map_context()
	result["snapshot"] = selected_hex_tile_map_writeback_snapshot()
	return result


func _sync_workspace_shared_resources_to_selected_document_dependencies(reason: String) -> Dictionary:
	var hex_layer := _ensure_session_state().current_selected_hex_tile_map_layer() as HexTileMapLayer
	var context := workspace_asset_context()
	return HexMapWorkspaceBindingService.sync_shared_context_to_document_dependencies(
		hex_layer,
		context,
		reason
	)


func _refresh_selected_hex_tile_map_context() -> void:
	if _selected_hex_tile_map_status_label == null or _selected_hex_tile_map_auto_link_label == null:
		return
	var snapshot := selected_hex_tile_map_snapshot()
	_selected_hex_tile_map_status_label.text = String(snapshot.get("status_text", "No HexTileMap selected"))
	_selected_hex_tile_map_status_label.tooltip_text = _selected_hex_tile_map_tooltip(snapshot)
	_selected_hex_tile_map_auto_link_label.text = String(snapshot.get("auto_link_text", "Auto-link: On"))
	_selected_hex_tile_map_auto_link_label.tooltip_text = "Workspace follows the selected HexTileMap node."
	_refresh_resources_context_panel()
	_refresh_layer_stack_role_panel()
	_refresh_missing_unique_resources_panel()


func _refresh_resources_context_panel() -> void:
	if _resources_context_panel == null:
		return
	var screen := resources_screen_snapshot()
	var snapshot = screen.get("selected_hex_tile_map", {}) as Dictionary
	var shelf = screen.get("resources_shelf", {}) as Dictionary
	var empty_state := _resources_tab_empty_state()
	if _resources_context_status_label != null:
		_resources_context_status_label.text = String(shelf.get("selected_hex_tile_map_chip_text", "Selected HexTileMap: None"))
		_resources_context_status_label.tooltip_text = String(empty_state.get("help_tooltip", _selected_hex_tile_map_tooltip(snapshot)))
	if _resources_shelf_status_label != null:
		_resources_shelf_status_label.text = "Unique / Shared / Optional"
		_resources_shelf_status_label.tooltip_text = "Resources is the asset shelf. Work tabs show context chips and link details back here."
	if _resources_readiness_label != null:
		_resources_readiness_label.text = ""
		_resources_readiness_label.visible = false
	var group_cards = shelf.get("group_cards", []) as Array
	for card in group_cards:
		if not card is Dictionary:
			continue
		var group_id := String((card as Dictionary).get("group_id", ""))
		var label = _resources_group_labels.get(group_id, null) as Label
		if label == null:
			continue
		label.text = "%s\n%s\n%s" % [
			String((card as Dictionary).get("title", "")),
			String((card as Dictionary).get("status_badge", "")),
			_resource_shelf_slot_cards_text((card as Dictionary).get("slot_cards", []) as Array),
		]
		label.tooltip_text = String((card as Dictionary).get("tooltip", ""))
	if _resources_source_badges_label != null:
		_resources_source_badges_label.text = ""
		_resources_source_badges_label.visible = false
	if _resources_context_next_actions_label != null:
		_resources_context_next_actions_label.text = ""
		_resources_context_next_actions_label.visible = false


func _refresh_catalog_detail_panel() -> void:
	if _catalog_detail_panel == null:
		return
	var snapshot := catalog_screen_snapshot()
	var entry_detail = snapshot.get("entry_detail", {}) as Dictionary
	var empty_state = snapshot.get("empty_state", {}) as Dictionary
	var catalog_board = snapshot.get("catalog_board", {}) as Dictionary
	_refresh_catalog_visual_board(catalog_board)
	if _catalog_detail_status_label != null:
		_catalog_detail_status_label.text = "TileSet: %s | Entries: %d" % [
			"Linked" if bool(snapshot.get("tile_set_present", false)) else "Missing",
			int(snapshot.get("entry_count", 0)),
		]
		_catalog_detail_status_label.tooltip_text = String(snapshot.get("tile_set_tooltip", _catalog_tile_set_tooltip()))
	if _catalog_detail_entry_label != null:
		if bool(entry_detail.get("present", false)):
			var preview_text := String(entry_detail.get("preview_text", ""))
			if preview_text == "":
				preview_text = String(entry_detail.get("preview_badge_text", entry_detail.get("preview_unavailable_reason", "No preview.")))
			_catalog_detail_entry_label.text = "%s | %s | %s" % [
				String(entry_detail.get("meaning", "")),
				String(entry_detail.get("type_label", "")),
				preview_text,
			]
		else:
			_catalog_detail_entry_label.text = _empty_state_inline_text(empty_state) \
				if bool(empty_state.get("visible", false)) else String(entry_detail.get("preview_unavailable_reason", "No catalog entry selected."))
		_catalog_detail_entry_label.tooltip_text = String(entry_detail.get("preview_badge_tooltip", empty_state.get("help_tooltip", "")))
	if _catalog_detail_preview_control != null:
		var preview = entry_detail.get("preview", {})
		if preview is Dictionary:
			_catalog_detail_preview_control.set_preview_snapshot(preview as Dictionary)
		else:
			_catalog_detail_preview_control.clear_preview("no_catalog_entry_preview")
	if _catalog_detail_preview_badge_label != null:
		_catalog_detail_preview_badge_label.text = String(entry_detail.get("preview_badge_text", "Preview unavailable"))
		_catalog_detail_preview_badge_label.tooltip_text = String(entry_detail.get("preview_badge_tooltip", entry_detail.get("preview_unavailable_reason", "")))


func _refresh_catalog_visual_board(board: Dictionary) -> void:
	var cards = board.get("cards", []) as Array
	if _catalog_board_status_label != null:
		_catalog_board_status_label.text = "Catalog: %s | Cards: %d" % [
			String(board.get("source_badge", "None")),
			int(board.get("card_count", cards.size())),
		]
		_catalog_board_status_label.tooltip_text = "Catalog board is the primary surface. Raw source and atlas metadata stay in card tooltips."
	if _catalog_empty_cta_label != null:
		var empty_cta = board.get("empty_cta", {}) as Dictionary
		_catalog_empty_cta_label.visible = bool(empty_cta.get("visible", false))
		_catalog_empty_cta_label.text = _catalog_board_empty_cta_text(empty_cta)
	if _catalog_board_grid == null:
		return
	_catalog_board_grid.visible = bool(board.get("visible", true))
	for child in _catalog_board_grid.get_children():
		_catalog_board_grid.remove_child(child)
		child.queue_free()
	for card in cards:
		if not card is Dictionary:
			continue
		_catalog_board_grid.add_child(_catalog_board_card_button(card as Dictionary))


func _catalog_board_card_button(card: Dictionary) -> Button:
	var button := Button.new()
	var key := String(card.get("key", ""))
	button.name = "Catalog Card %s" % key
	button.text = "%s\n%s | %s" % [
		String(card.get("title", key)),
		String(card.get("asset_kind", "")),
		String(card.get("badge_text", "")),
	]
	button.disabled = key == ""
	button.tooltip_text = String(card.get("card_tooltip", ""))
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.set_meta("hex_catalog_entry_key", key)
	button.set_meta("hex_catalog_asset_kind", String(card.get("asset_kind", "")))
	button.pressed.connect(_on_catalog_board_card_pressed.bind(key))
	return button


func _catalog_board_empty_cta_text(empty_cta: Dictionary) -> String:
	if not bool(empty_cta.get("visible", false)):
		return ""
	var actions = empty_cta.get("actions", PackedStringArray()) as PackedStringArray
	if actions.is_empty():
		return ""
	return _join_text(actions, " | ")


func _catalog_tile_set_tooltip() -> String:
	return "Pick: TileSet\nType: TileSet\nPurpose: %s" % HexMapWorkspaceAssetResourceFactory.tile_set_purpose()


func _refresh_layer_stack_role_panel() -> void:
	if _layer_stack_role_panel == null:
		return
	var snapshot := layer_stack_screen_snapshot()
	var counts = snapshot.get("role_status_counts", {}) as Dictionary
	var relationship = snapshot.get("relationship", {}) as Dictionary
	var actions = snapshot.get("layer_actions", {}) as Dictionary
	var empty_state = snapshot.get("empty_state", {}) as Dictionary
	_refresh_layer_stack_visual(snapshot.get("role_stack_visual", {}) as Dictionary)
	if _layer_stack_role_status_label != null:
		_layer_stack_role_status_label.text = "Layer Stack: %s | Roles: %d | Missing: %d | Locked: %d | Writable: %d" % [
			_layer_stack_display_label(snapshot.get("layer_stack", null) as HexLayerStackResource),
			int(counts.get("total", 0)),
			int(counts.get("missing", 0)),
			int(counts.get("locked", 0)),
			int(counts.get("writable", 0)),
		]
	if _layer_stack_role_relationship_label != null:
		_layer_stack_role_relationship_label.text = "%s | Create Missing: %s | Apply Document: %s" % [
			String(relationship.get("message", "")),
			_bool_label(bool(actions.get("create_missing_layers", false))),
			_bool_label(bool(actions.get("apply_document", false))),
		]
	if _layer_stack_role_tree_summary_label != null:
		var role_tree_summary = snapshot.get("role_tree_summary", {}) as Dictionary
		_layer_stack_role_tree_summary_label.text = String(role_tree_summary.get("visible_text", ""))
		_layer_stack_role_tree_summary_label.tooltip_text = String(role_tree_summary.get("relationship_text", ""))
	if _layer_stack_role_rows_label != null:
		var rows = snapshot.get("role_rows", []) as Array
		_layer_stack_role_rows_label.text = _empty_state_inline_text(empty_state) \
			if bool(empty_state.get("visible", false)) else _layer_stack_role_rows_text(rows)
		_layer_stack_role_rows_label.tooltip_text = String(empty_state.get("help_tooltip", ""))
	var role_editor = snapshot.get("role_editor", {}) as Dictionary
	if _layer_stack_role_editor_summary_label != null:
		_layer_stack_role_editor_summary_label.text = String(role_editor.get("visible_text", ""))
		_layer_stack_role_editor_summary_label.tooltip_text = "Edit the selected Layer Stack role properties."
	_refresh_layer_role_editor_controls(snapshot)


func _refresh_layer_stack_visual(visual: Dictionary) -> void:
	var cards = visual.get("role_cards", []) as Array
	if _layer_stack_visual_status_label != null:
		_layer_stack_visual_status_label.text = "Role Stack: %d | Missing: %d | Writable: %s" % [
			int(visual.get("role_count", cards.size())),
			int(visual.get("missing_count", 0)),
			_join_text(visual.get("writable_sources", PackedStringArray()) as PackedStringArray, ", "),
		]
		_layer_stack_visual_status_label.tooltip_text = String(visual.get("relationship_text", ""))
	if _layer_stack_visual_empty_cta_label != null:
		var empty_cta = visual.get("empty_cta", {}) as Dictionary
		_layer_stack_visual_empty_cta_label.visible = bool(empty_cta.get("visible", false))
		_layer_stack_visual_empty_cta_label.text = _layer_stack_visual_empty_cta_text(empty_cta)
	if _layer_stack_visual_stack == null:
		return
	_layer_stack_visual_stack.visible = bool(visual.get("visible", true)) and not cards.is_empty()
	for child in _layer_stack_visual_stack.get_children():
		_layer_stack_visual_stack.remove_child(child)
		child.queue_free()
	for card in cards:
		if not card is Dictionary:
			continue
		_layer_stack_visual_stack.add_child(_layer_stack_visual_card_row(card as Dictionary))


func _layer_stack_visual_card_row(card: Dictionary) -> HBoxContainer:
	var role := String(card.get("role", ""))
	var row := HBoxContainer.new()
	row.name = "Layer Role Card %s" % role
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var role_button := Button.new()
	role_button.name = "Layer Role Select %s" % role
	role_button.text = "%s%s\n%s | %s" % [
		"[selected] " if bool(card.get("selected", false)) else "",
		String(card.get("title", role)),
		String(card.get("status_chip", "")),
		String(card.get("z_chip", "")),
	]
	role_button.disabled = role == ""
	role_button.tooltip_text = String(card.get("tooltip", ""))
	role_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	role_button.set_meta("hex_layer_stack_role", role)
	role_button.pressed.connect(_on_layer_stack_visual_role_pressed.bind(role))
	row.add_child(role_button)

	var visible_check := CheckBox.new()
	visible_check.name = "Layer Role Visible %s" % role
	visible_check.text = "Visible"
	visible_check.button_pressed = bool(card.get("visible", false))
	visible_check.disabled = role == ""
	visible_check.tooltip_text = String(card.get("visible_chip", ""))
	visible_check.toggled.connect(_on_layer_stack_visual_visible_toggled.bind(role))
	row.add_child(visible_check)

	var locked_check := CheckBox.new()
	locked_check.name = "Layer Role Locked %s" % role
	locked_check.text = "Locked"
	locked_check.button_pressed = bool(card.get("locked", false))
	locked_check.disabled = role == ""
	locked_check.tooltip_text = String(card.get("lock_chip", ""))
	locked_check.toggled.connect(_on_layer_stack_visual_locked_toggled.bind(role))
	row.add_child(locked_check)

	var writable_chip := Label.new()
	writable_chip.name = "Layer Role Writable %s" % role
	writable_chip.text = String(card.get("writable_chip", ""))
	writable_chip.tooltip_text = String(card.get("writable_source_purpose", ""))
	row.add_child(writable_chip)
	return row


func _layer_stack_visual_empty_cta_text(empty_cta: Dictionary) -> String:
	if not bool(empty_cta.get("visible", false)):
		return ""
	var actions = empty_cta.get("actions", PackedStringArray()) as PackedStringArray
	if actions.is_empty():
		return "Choose a Layer Stack to build role cards."
	return "Next: %s" % _join_text(actions, " / ")


func _refresh_layer_role_editor_controls(snapshot: Dictionary) -> void:
	_updating_layer_role_editor_controls = true
	var role_rows = snapshot.get("role_rows", []) as Array
	var role_editor = snapshot.get("role_editor", {}) as Dictionary
	var selected_role := String(role_editor.get("selected_role", ""))
	var editable := bool(role_editor.get("editable", false))
	if _layer_stack_role_editor_role_option != null:
		_layer_stack_role_editor_role_option.clear()
		var selected_index := -1
		for row_index in range(role_rows.size()):
			var row = role_rows[row_index]
			if not row is Dictionary:
				continue
			var role := String((row as Dictionary).get("role", ""))
			if role == "":
				continue
			_layer_stack_role_editor_role_option.add_item(role)
			var item_index := _layer_stack_role_editor_role_option.item_count - 1
			_layer_stack_role_editor_role_option.set_item_metadata(item_index, role)
			if role == selected_role:
				selected_index = item_index
		if selected_index >= 0:
			_layer_stack_role_editor_role_option.select(selected_index)
		_layer_stack_role_editor_role_option.disabled = role_rows.is_empty()
	if _layer_stack_role_editor_visible_check != null:
		_layer_stack_role_editor_visible_check.button_pressed = bool(role_editor.get("visible_value", false))
		_layer_stack_role_editor_visible_check.disabled = not editable
	if _layer_stack_role_editor_locked_check != null:
		_layer_stack_role_editor_locked_check.button_pressed = bool(role_editor.get("locked_value", false))
		_layer_stack_role_editor_locked_check.disabled = not editable
	if _layer_stack_role_editor_z_index_spin != null:
		_layer_stack_role_editor_z_index_spin.value = int(role_editor.get("z_index_value", 0))
		_layer_stack_role_editor_z_index_spin.editable = editable
	if _layer_stack_role_editor_writable_option != null:
		_populate_layer_role_writable_source_option(String(role_editor.get("writable_source", "document")), editable)
	_updating_layer_role_editor_controls = false


func _populate_layer_role_writable_source_option(selected_source: String, editable: bool) -> void:
	if _layer_stack_role_editor_writable_option == null:
		return
	_layer_stack_role_editor_writable_option.clear()
	var selected_index := 0
	for source_index in range(LAYER_ROLE_WRITABLE_SOURCES.size()):
		var source := String(LAYER_ROLE_WRITABLE_SOURCES[source_index])
		_layer_stack_role_editor_writable_option.add_item(_layer_role_writable_source_label(source))
		_layer_stack_role_editor_writable_option.set_item_metadata(source_index, source)
		if source == selected_source:
			selected_index = source_index
	_layer_stack_role_editor_writable_option.select(selected_index)
	_layer_stack_role_editor_writable_option.disabled = not editable


func _layer_role_writable_source_label(source: String) -> String:
	match source:
		"document":
			return "Document"
		"target":
			return "Target"
		"generated":
			return "Generated"
		"readonly":
			return "Read Only"
	return source.capitalize()


func _layer_stack_display_label(stack: HexLayerStackResource) -> String:
	if stack == null:
		return "Not selected"
	if stack.display_name != "":
		return stack.display_name
	if stack.stack_id != "":
		return stack.stack_id
	return "Layer Stack"


func _layer_stack_role_rows_text(rows: Array) -> String:
	if rows.is_empty():
		return "No role rows until a Layer Stack is selected."
	var parts := PackedStringArray()
	for row in rows:
		if not row is Dictionary:
			continue
		parts.append("%s:%s visible=%s locked=%s writable=%s" % [
			String((row as Dictionary).get("role", "")),
			String((row as Dictionary).get("status", "")),
			_bool_label(bool((row as Dictionary).get("visible", false))),
			_bool_label(bool((row as Dictionary).get("locked", false))),
			String((row as Dictionary).get("writable", "")),
		])
	return _join_text(parts, " | ")


func _bool_label(value: bool) -> String:
	return "yes" if value else "no"


func _refresh_validation_issue_navigator() -> void:
	if _validation_issue_navigator == null:
		return
	var snapshot := validate_screen_snapshot()
	var empty_state = snapshot.get("empty_state", {}) as Dictionary
	if _validation_issue_status_label != null:
		var issue_count := int(snapshot.get("issue_count", 0))
		var error_count := int(snapshot.get("error_count", 0))
		var empty_text := String(snapshot.get("empty_state_text", ""))
		_validation_issue_status_label.text = _empty_state_inline_text(empty_state) if empty_text != "" else "%s | Issues: %d | Errors: %d" % [
			String(snapshot.get("target_summary", "")),
			issue_count,
			error_count,
		]
		_validation_issue_status_label.tooltip_text = String(empty_state.get("help_tooltip", ""))
	if _validation_issue_selected_label != null:
		var selected_row = snapshot.get("selected_issue_row", {}) as Dictionary
		var navigation = snapshot.get("selected_issue_navigation", {}) as Dictionary
		if selected_row.is_empty():
			_validation_issue_selected_label.text = "Selected issue: none"
		else:
			_validation_issue_selected_label.text = "%s -> %s | %s" % [
				String(selected_row.get("rule_id", "")),
				String(navigation.get("target_tab", "")),
				String(navigation.get("suggested_action", "")),
			]
	if _validation_issue_rows_label != null:
		var issue_table = snapshot.get("issue_table", {}) as Dictionary
		_validation_issue_rows_label.text = String(issue_table.get("rows_text", _validate_issue_rows_text(snapshot.get("issue_rows", []) as Array)))


func _validate_issue_rows_text(rows: Array) -> String:
	return _validate_issue_table_rows_text(rows)


func _validate_issue_table_rows_text(rows: Array) -> String:
	if rows.is_empty():
		return "No validation issues listed."
	var parts := PackedStringArray()
	for row in rows:
		if not row is Dictionary:
			continue
		var actions = (row as Dictionary).get("available_actions", []) as Array
		var action_label := "no action"
		if not actions.is_empty() and actions[0] is Dictionary:
			action_label = String((actions[0] as Dictionary).get("label", ""))
		parts.append("%s | %s | %s | %s | %s | %s" % [
			String((row as Dictionary).get("severity_label", "")),
			String((row as Dictionary).get("domain", "")),
			String((row as Dictionary).get("scope", "")),
			String((row as Dictionary).get("target_text", "")),
			String((row as Dictionary).get("suggestion", "")),
			action_label,
		])
	return _join_text(parts, " | ")


func _refresh_qa_seed_lab_panel() -> void:
	if _qa_seed_lab_panel == null:
		return
	var context := qa_seed_lab_context()
	var empty_state := _qa_tab_empty_state(context)
	if _qa_seed_lab_status_label != null:
		var target = context.get("promotion_target", {}) as Dictionary
		_qa_seed_lab_status_label.text = _empty_state_inline_text(empty_state) if bool(empty_state.get("visible", false)) else "Rows: %d | Profile: %s | Validation: %s | Promotion target: %s" % [
			int(context.get("score_row_count", 0)),
			"selected" if bool((context.get("generation_profile", {}) as Dictionary).get("selected", false)) else "missing",
			"selected" if bool((context.get("validation_rule_suite", {}) as Dictionary).get("selected", false)) else "missing",
			String(target.get("status", "")),
		]
		_qa_seed_lab_status_label.tooltip_text = String(empty_state.get("help_tooltip", ""))
	if _qa_seed_lab_selected_label != null:
		var selected = context.get("selected_seed_row", {}) as Dictionary
		if selected.is_empty():
			_qa_seed_lab_selected_label.text = "Selected seed: none"
		else:
			_qa_seed_lab_selected_label.text = "Selected seed: %d | score=%.2f | validation=%dE/%dW" % [
				int(selected.get("seed", 0)),
				float(selected.get("score", 0.0)),
				int(selected.get("validation_errors", 0)),
				int(selected.get("validation_warnings", 0)),
			]
	if _qa_seed_lab_selected_thumbnail != null:
		_qa_seed_lab_selected_thumbnail.set_preview_snapshot(
			context.get("selected_seed_preview", {}) as Dictionary
		)
	var scored_table = context.get("scored_table", {}) as Dictionary
	if _qa_seed_lab_score_tree != null:
		_refresh_qa_seed_lab_score_tree(scored_table)
	if _qa_seed_lab_rows_label != null:
		_qa_seed_lab_rows_label.text = String(scored_table.get("rows_text", _qa_seed_lab_rows_text(context.get("score_rows", []) as Array)))


func _refresh_qa_seed_lab_score_tree(scored_table: Dictionary) -> void:
	if _qa_seed_lab_score_tree == null:
		return
	_qa_seed_lab_score_tree.clear()
	var root_item := _qa_seed_lab_score_tree.create_item()
	var rows = scored_table.get("rows", []) as Array
	for row in rows:
		if not row is Dictionary:
			continue
		var item := _qa_seed_lab_score_tree.create_item(root_item)
		item.set_text(0, str(int((row as Dictionary).get("rank", 0))))
		item.set_text(1, str(int((row as Dictionary).get("seed", 0))))
		item.set_text(2, String((row as Dictionary).get("score_text", "")))
		item.set_text(3, String((row as Dictionary).get("validation", "")))
		item.set_text(4, String((row as Dictionary).get("selected_state", "")))
		item.set_text(5, String((row as Dictionary).get("preview_text", "")))
		item.set_text(6, String((row as Dictionary).get("promotion_state", "")))


func _qa_mounted_score_tree_row_count() -> int:
	if _qa_seed_lab_score_tree == null:
		return 0
	var root_item := _qa_seed_lab_score_tree.get_root()
	if root_item == null:
		return 0
	var count := 0
	var child := root_item.get_first_child()
	while child != null:
		count += 1
		child = child.get_next()
	return count


func _qa_seed_lab_rows_text(rows: Array) -> String:
	if rows.is_empty():
		return "No seed batch rows."
	return _qa_scored_table_rows_text(_qa_scored_table_rows(rows))


func _qa_scored_table_rows_text(rows: Array) -> String:
	if rows.is_empty():
		return "No seed batch rows."
	var parts := PackedStringArray()
	for row in rows:
		if not row is Dictionary:
			continue
		parts.append("#%d | seed %d | score %s | validation %s | %s | preview %s | promotion %s" % [
			int((row as Dictionary).get("rank", 0)),
			int((row as Dictionary).get("seed", 0)),
			String((row as Dictionary).get("score_text", "")),
			String((row as Dictionary).get("validation", "")),
			String((row as Dictionary).get("selected_state", "")),
			String((row as Dictionary).get("preview_text", "")),
			String((row as Dictionary).get("promotion_state", "")),
		])
	return _join_text(parts, " | ")


func _refresh_settings_preferences_panel() -> void:
	if _settings_preferences_panel == null:
		return
	var snapshot := settings_screen_snapshot()
	var empty_state = snapshot.get("empty_state", {}) as Dictionary
	if _settings_preferences_status_label != null:
		_settings_preferences_status_label.text = String(snapshot.get("purpose_text", _settings_purpose_text()))
		_settings_preferences_status_label.tooltip_text = String(empty_state.get("help_tooltip", ""))
	if _settings_preferences_debug_label != null:
		_settings_preferences_debug_label.text = ""
		_settings_preferences_debug_label.visible = false
		_settings_preferences_debug_label.tooltip_text = "Debug options are controlled by explicit Settings checkboxes and debug report output."
	if _settings_preferences_resource_label != null:
		_settings_preferences_resource_label.text = "Production asset selection: Resources"


func _settings_purpose_text() -> String:
	return "Sample learning controls, explicit debug opt-ins, and editor preferences."


func _settings_sample_actions_work_or_removed(sample_snapshot: Dictionary) -> bool:
	if sample_snapshot.is_empty():
		return false
	var action_rows = sample_snapshot.get("sample_action_rows", []) as Array
	var catalog_duplicate_available := false
	for row in action_rows:
		if not row is Dictionary:
			continue
		var action_texts = (row as Dictionary).get("action_button_texts", PackedStringArray()) as PackedStringArray
		if action_texts.has("Open"):
			return false
		if String((row as Dictionary).get("id", "")) == HexMapSampleSettingsPanel.SAMPLE_CATALOG_ID:
			catalog_duplicate_available = action_texts.has("Duplicate To Project")
	return catalog_duplicate_available


func _settings_group_ids(groups: Array) -> PackedStringArray:
	var ids := PackedStringArray()
	for group in groups:
		if group is Dictionary:
			ids.append(String((group as Dictionary).get("id", "")))
	return ids


func _settings_groups_separated(groups: Array) -> bool:
	for group in groups:
		if not group is Dictionary:
			return false
		if not bool((group as Dictionary).get("separated", false)):
			return false
	return not groups.is_empty()


func _settings_boolean_controls_use_type(rows: Array, control_type: String) -> bool:
	for row in rows:
		if not row is Dictionary:
			return false
		if String((row as Dictionary).get("control_type", "")) != control_type:
			return false
	return not rows.is_empty()


func _settings_boolean_controls_have_tooltips(rows: Array) -> bool:
	for row in rows:
		if not row is Dictionary:
			return false
		if not bool((row as Dictionary).get("has_tooltip", false)):
			return false
	return not rows.is_empty()


func _refresh_export_purpose_panel() -> void:
	if _export_purpose_panel == null:
		return
	var snapshot := export_screen_snapshot()
	var output_type = snapshot.get("output_type", {}) as Dictionary
	var empty_state = snapshot.get("empty_state", {}) as Dictionary
	var purpose_cards = snapshot.get("purpose_cards", []) as Array
	var secondary_actions = snapshot.get("secondary_actions", []) as Array
	if _export_purpose_status_label != null:
		_export_purpose_status_label.text = String(snapshot.get("purpose_text", ""))
		_export_purpose_status_label.tooltip_text = String(empty_state.get("help_tooltip", ""))
	if _export_runtime_handoff_summary_label != null:
		var runtime_handoff_summary = snapshot.get("runtime_handoff_summary", {}) as Dictionary
		_export_runtime_handoff_summary_label.text = String(runtime_handoff_summary.get("visible_text", ""))
		_export_runtime_handoff_summary_label.tooltip_text = "Runtime handoff readiness groups source, destination, profile, output, action, and result state."
	if _export_purpose_mode_label != null:
		_export_purpose_mode_label.text = "%s | Source: %s | Target: %s%s" % [
			String(output_type.get("label", "")),
			String(output_type.get("source", "")),
			String(output_type.get("target_resource_class", "")),
			String(output_type.get("file_extension", "")),
		]
	if _export_purpose_backlog_label != null:
		_export_purpose_backlog_label.text = _export_backlog_modes_text(snapshot.get("output_modes", []) as Array)
	_refresh_export_purpose_card_buttons(purpose_cards)
	_refresh_export_secondary_action_buttons(secondary_actions)


func _refresh_export_purpose_card_buttons(cards: Array) -> void:
	for card in cards:
		if not card is Dictionary:
			continue
		var card_id := String((card as Dictionary).get("id", ""))
		var button = _export_purpose_card_buttons.get(card_id, null) as Button
		if button == null:
			continue
		button.text = "%s\n%s" % [
			String((card as Dictionary).get("title", "")),
			String((card as Dictionary).get("action_label", "")),
		]
		button.disabled = not bool((card as Dictionary).get("enabled", false))
		button.tooltip_text = String((card as Dictionary).get("disabled_reason", ""))
		if button.tooltip_text == "":
			button.tooltip_text = String((card as Dictionary).get("purpose", ""))


func _refresh_export_secondary_action_buttons(actions: Array) -> void:
	for action in actions:
		if not action is Dictionary:
			continue
		var action_id := String((action as Dictionary).get("id", ""))
		var button = _export_secondary_action_buttons.get(action_id, null) as Button
		if button == null:
			continue
		button.text = String((action as Dictionary).get("action_label", ""))
		button.disabled = not bool((action as Dictionary).get("enabled", false))
		button.tooltip_text = String((action as Dictionary).get("tooltip", ""))


func _export_backlog_modes_text(modes: Array) -> String:
	var parts := PackedStringArray()
	for mode in modes:
		if not mode is Dictionary:
			continue
		if not bool((mode as Dictionary).get("visible_in_export_tab", false)):
			continue
		if bool((mode as Dictionary).get("active", false)):
			continue
		parts.append("%s: %s" % [
			String((mode as Dictionary).get("label", "")),
			String((mode as Dictionary).get("status", "")),
		])
	return _join_text(parts, " | ")


func _missing_unique_resources_choose_directory_button_tooltip(selected: bool) -> String:
	if not selected:
		return "Select a HexTileMap node before choosing a save directory."
	return "Choose a project directory for the selected HexTileMap resources."


func _missing_unique_resources_create_button_tooltip(
	selected: bool,
	directory: String,
	prefix: String,
	missing_ids: PackedStringArray
) -> String:
	if not selected:
		return "Select a HexTileMap node before creating missing resources."
	if missing_ids.is_empty():
		return "Selected HexTileMap unique resources are already configured."
	if directory == "":
		return "Choose a save directory before creating missing resources."
	if prefix == "":
		return "Enter a resource prefix before creating missing resources."
	return "Create Level Document and Layer Stack resources in the selected directory."


func _refresh_missing_unique_resources_panel() -> void:
	if _missing_unique_resources_panel == null:
		return
	var snapshot := missing_unique_resources_snapshot(
		_missing_unique_resources_save_directory,
		_missing_unique_resources_prefix()
	)
	var selected := bool(snapshot.get("selected", false))
	var missing_ids := PackedStringArray(snapshot.get("missing_resource_ids", PackedStringArray()))
	if _missing_unique_resources_prefix_edit != null:
		var snapshot_prefix := String(snapshot.get("resource_prefix", ""))
		var current_prefix := _safe_resource_prefix(_missing_unique_resources_prefix_edit.text)
		if current_prefix == "" or (current_prefix == "HexTileMap" and snapshot_prefix != "HexTileMap"):
			_missing_unique_resources_prefix_edit.text = snapshot_prefix
	if _missing_unique_resources_status_label != null:
		if not selected:
			_missing_unique_resources_status_label.text = "No HexTileMap selected"
		elif missing_ids.is_empty():
			_missing_unique_resources_status_label.text = "Selected HexTileMap unique resources are configured."
		else:
			_missing_unique_resources_status_label.text = "Missing: %s" % _join_text(_missing_unique_resource_labels(missing_ids), ", ")
	if _missing_unique_resources_save_directory_label != null:
		var directory := String(snapshot.get("save_directory", ""))
		_missing_unique_resources_save_directory_label.text = "Save directory: %s" % ("Not selected" if directory == "" else directory)
	if _missing_unique_resources_choose_directory_button != null:
		_missing_unique_resources_choose_directory_button.disabled = not selected
		_missing_unique_resources_choose_directory_button.tooltip_text = String(snapshot.get("choose_directory_button_tooltip", ""))
	if _missing_unique_resources_create_button != null:
		_missing_unique_resources_create_button.disabled = not bool(snapshot.get("can_create", false))
		_missing_unique_resources_create_button.tooltip_text = String(snapshot.get("create_button_tooltip", ""))
	if _resources_save_all_button != null:
		var shelf = resources_screen_snapshot().get("resources_shelf", {}) as Dictionary
		var save_all_cta = shelf.get("save_all_cta", {}) as Dictionary
		_resources_save_all_button.disabled = not bool(save_all_cta.get("enabled", false))
		_resources_save_all_button.tooltip_text = "Save all selected project resources that already have paths."


func _selected_hex_tile_map_status_text(layer: Node) -> String:
	if layer == null or not is_instance_valid(layer):
		return "No HexTileMap selected"
	return "Selected HexTileMap: %s" % _node_display_name(layer)


func _selected_hex_tile_map_tooltip(snapshot: Dictionary) -> String:
	if not bool(snapshot.get("selected", false)):
		return "No HexTileMap selected"
	var writeback = snapshot.get("writeback", {}) as Dictionary
	var blocked_reason := String(writeback.get("blocked_reason", ""))
	var writeback_text := "Write-back: On" if blocked_reason == "" else "Write-back blocked: %s" % blocked_reason
	return "Node: %s\n%s\n%s\nAuthoring: %s\nLevel Document: %s\nRuntime snapshot: %s\nLayer Stack: %s\nTile Catalog: %s" % [
		String(snapshot.get("node_path", "")),
		String(snapshot.get("auto_link_text", "")),
		writeback_text,
		String(snapshot.get("authoring_source", "Level Document")),
		String(snapshot.get("level_document_status", "")),
		"Present" if bool(snapshot.get("runtime_display_snapshot_present", false)) else "Missing",
		String(snapshot.get("layer_stack_status", "")),
		String(snapshot.get("tile_catalog_status", "")),
	]


func _node_display_path(node: Node) -> String:
	if node == null or not is_instance_valid(node):
		return ""
	return str(node.get_path()) if node.is_inside_tree() else node.name


func _node_display_name(node: Node) -> String:
	if node == null or not is_instance_valid(node):
		return ""
	return node.name if node.name != "" else "HexTileMap"


func _create_build_context_hex_tile_map_layer() -> HexTileMapLayer:
	var parent := _build_context_node_parent()
	var layer := HexTileMapLayer.new()
	layer.name = _unique_child_name(parent, "BuildHexMapLayer")
	parent.add_child(layer)
	if Engine.is_editor_hint() and parent != self:
		layer.owner = parent
	return layer


func _build_context_node_parent() -> Node:
	if Engine.is_editor_hint():
		var edited_root := EditorInterface.get_edited_scene_root()
		if edited_root != null:
			return edited_root
	return self


func _unique_child_name(parent: Node, base_name: String) -> String:
	var names := {}
	if parent != null:
		for child in parent.get_children():
			names[String(child.name)] = true
	if not names.has(base_name):
		return base_name
	var suffix := 2
	while names.has("%s%d" % [base_name, suffix]):
		suffix += 1
	return "%s%d" % [base_name, suffix]


func _missing_unique_resources_prefix() -> String:
	var layer := _ensure_session_state().current_selected_hex_tile_map_layer()
	var selected_default := "HexTileMap"
	if layer != null and is_instance_valid(layer):
		selected_default = _safe_resource_prefix(layer.name)
	if _missing_unique_resources_prefix_edit != null:
		var text := _safe_resource_prefix(_missing_unique_resources_prefix_edit.text)
		if text != "" and (text != "HexTileMap" or layer == null):
			return text
	return selected_default


func _missing_unique_resource_ids(layer: HexTileMapLayer) -> PackedStringArray:
	var result := PackedStringArray()
	if layer == null:
		return result
	if layer.level_document_resource == null:
		result.append(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT)
	if layer.layer_stack_resource == null:
		result.append(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK)
	return result


func _missing_unique_resource_paths(directory: String, prefix: String) -> Dictionary:
	var result := {}
	var actual_directory := _normalized_resource_directory(directory)
	var actual_prefix := _safe_resource_prefix(prefix)
	if actual_directory == "" or actual_prefix == "":
		return result
	result[HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT] = "%s/%s_document.tres" % [
		actual_directory,
		actual_prefix,
	]
	result[HexMapWorkspaceAssetContext.SLOT_LAYER_STACK] = "%s/%s_layer_stack.tres" % [
		actual_directory,
		actual_prefix,
	]
	return result


func _missing_unique_resource_labels(ids: PackedStringArray) -> PackedStringArray:
	var labels := PackedStringArray()
	for id in ids:
		match String(id):
			HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT:
				labels.append("Level Document")
			HexMapWorkspaceAssetContext.SLOT_LAYER_STACK:
				labels.append("Layer Stack")
			_:
				labels.append(String(id))
	return labels


func _join_text(values: PackedStringArray, separator: String) -> String:
	var result := ""
	for value in values:
		if result != "":
			result += separator
		result += String(value)
	return result


func _missing_unique_resources_result(
	ok: bool,
	error: int,
	before: Dictionary,
	created: Dictionary,
	message: String
) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"message": message,
		"before": before,
		"created_resources": created,
		"created_resource_ids": PackedStringArray(created.keys()),
		"selected_node": before.get("selected_node", null),
		"save_directory": before.get("save_directory", ""),
		"resource_prefix": before.get("resource_prefix", ""),
		"paths": before.get("paths", {}),
		"shared_resources_created": false,
	}


func _save_resource_if_missing(resource: Resource, path: String) -> int:
	if resource == null or path == "":
		return ERR_INVALID_PARAMETER
	if ResourceLoader.exists(path):
		return ERR_ALREADY_EXISTS
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	return ResourceSaver.save(resource, path)


func _normalized_resource_directory(path: String) -> String:
	var result := path.strip_edges()
	while result.ends_with("/") and result.length() > "res://".length():
		result = result.trim_suffix("/")
	return result


func _safe_resource_prefix(value: String) -> String:
	var result := value.strip_edges()
	for token in [" ", "/", "\\", ":", "*", "?", "\"", "<", ">", "|"]:
		result = result.replace(token, "_")
	while result.contains("__"):
		result = result.replace("__", "_")
	while result.begins_with("_"):
		result = result.substr(1)
	while result.ends_with("_"):
		result = result.substr(0, result.length() - 1)
	return result


func _ensure_session_state() -> HexMapEditorSessionState:
	if _editor_session_state == null:
		_editor_session_state = HexMapEditorSessionState.new()
		_connect_session_state()
	return _editor_session_state


func _connect_session_state() -> void:
	if _editor_session_state != null and not _editor_session_state.changed.is_connected(_on_session_state_changed):
		_editor_session_state.changed.connect(_on_session_state_changed)


func _sync_workspace_asset_context() -> void:
	var context := workspace_asset_context()
	for panel in _asset_panels.values():
		if panel is HexMapWorkspaceAssetPanel:
			(panel as HexMapWorkspaceAssetPanel).set_workspace_asset_context(context)
	if _generation_dock != null:
		_generation_dock.set_workspace_asset_context(context)
	if _build_screen != null:
		_build_screen.set_workspace_asset_context(context)
	if _edit_tool != null:
		_edit_tool.set_workspace_asset_context(context)
	_refresh_resources_context_panel()
	_refresh_catalog_detail_panel()
	_refresh_layer_stack_role_panel()
	_refresh_validation_issue_navigator()
	_refresh_qa_seed_lab_panel()
	_refresh_export_purpose_panel()
	_refresh_settings_preferences_panel()
	_refresh_missing_unique_resources_panel()


func _canonical_tab_name(tab_name: String) -> String:
	return HexMapWorkspaceComponentRegistry.canonical_tab_name(tab_name)


func _register_tab_component(tab_name: String, component_id: String, control: Control) -> void:
	var actual_tab := _canonical_tab_name(tab_name)
	_apply_component_owner_metadata(actual_tab, component_id, control)
	if not _tab_components.has(actual_tab):
		_tab_components[actual_tab] = {}
	_tab_components[actual_tab][component_id] = control


func _apply_component_owner_metadata(tab_name: String, component_id: String, control: Control) -> void:
	if control == null:
		return
	var owner := HexMapWorkspaceComponentRegistry.component_owner_for(tab_name, component_id)
	if owner.is_empty():
		return
	control.set_meta("hex_workspace_component_id", component_id)
	control.set_meta("hex_workspace_screen_script", String(owner.get("screen_script", "")))
	control.set_meta("hex_workspace_screen_role_source", String(owner.get("screen_role_source", "")))


func _refresh_sample_learning_cta() -> void:
	if _sample_learning_cta == null:
		return
	_sample_learning_cta.visible = _ensure_session_state().sample_learning_cta_visible()


func _on_sample_learning_cta_pressed() -> void:
	open_sample_learning_cta()


func _on_sample_learning_cta_dismissed() -> void:
	dismiss_sample_learning_cta()


func _on_session_state_changed(_key: String) -> void:
	if _key == "selected_hex_tile_map_layer" or _key == "selected_hex_tile_map.auto_link":
		if _ensure_session_state().selected_hex_tile_map_auto_link_enabled():
			_apply_selected_hex_tile_map_to_edit_tool()
		_sync_selected_hex_tile_map_resources()
		_refresh_selected_hex_tile_map_context()
	elif _key.begins_with("workspace_asset_context."):
		var slot_id := _key.trim_prefix("workspace_asset_context.")
		if slot_id == HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT and not _hydrating_document_dependencies:
			_hydrate_workspace_context_from_document_dependencies(workspace_asset_context().level_document)
		_apply_workspace_asset_change_to_selected_node(slot_id, "workspace.asset_context.changed")
		_refresh_selected_hex_tile_map_context()
	_refresh_sample_learning_cta()
	_refresh_export_destination_panel()
	_refresh_settings_preferences_panel()
