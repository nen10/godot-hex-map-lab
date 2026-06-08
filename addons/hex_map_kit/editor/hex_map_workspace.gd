@tool
class_name HexMapWorkspace
extends VBoxContainer

const HexMapEditorSessionState = preload("res://addons/hex_map_kit/editor/hex_map_editor_session_state.gd")
const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapDocumentValidator = preload("res://addons/hex_map_kit/adapter/hex_map_document_validator.gd")
const HexMapValidationResult = preload("res://addons/hex_map_kit/adapter/hex_map_validation_result.gd")
const HexLayerStackResource = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd")
const HexLabelDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_label_database_resource.gd")
const HexLabelDefinitionResource = preload("res://addons/hex_map_kit/adapter/hex_label_definition_resource.gd")
const HexObjectDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_object_database_resource.gd")
const HexObjectDefinitionResource = preload("res://addons/hex_map_kit/adapter/hex_object_definition_resource.gd")
const HexTileCatalogEntry = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_entry.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")
const HexTileCatalogValidator = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_validator.gd")
const HexMapEditorPathSelector = preload("res://addons/hex_map_kit/editor/hex_map_editor_path_selector.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")
const HexMapGenDock = preload("res://addons/hex_map_kit/editor/hex_map_gen_dock.gd")
const HexMapEditTool = preload("res://addons/hex_map_kit/editor/hex_map_edit_tool.gd")
const HexMapSampleSettingsPanel = preload("res://addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd")
const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")
const HexMapWorkspaceAssetPanel = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_panel.gd")
const HexMapWorkspaceAssetResourceFactory = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_resource_factory.gd")
const HexMapWorkspaceComponentRegistry = preload("res://addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd")

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
var _resources_group_labels: Dictionary = {}
var _missing_unique_resources_panel: VBoxContainer
var _missing_unique_resources_status_label: Label
var _missing_unique_resources_save_directory_label: Label
var _missing_unique_resources_prefix_edit: LineEdit
var _missing_unique_resources_choose_directory_button: Button
var _missing_unique_resources_create_button: Button
var _missing_unique_resources_save_directory := ""
var _generation_dock: HexMapGenDock
var _edit_tool: HexMapEditTool
var _sample_settings_panel: HexMapSampleSettingsPanel
var _export_destination_panel: VBoxContainer
var _export_destination_label: Label
var _export_recent_destinations_label: Label
var _export_choose_destination_button: Button
var _export_use_recent_button: Button
var _export_run_button: Button
var _asset_panels: Dictionary = {}
var _tab_components: Dictionary = {}
var _tab_pages: Dictionary = {}
var _tab_scroll_roots: Dictionary = {}
var _last_workspace_validation_result: HexMapValidationResult = null


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


func workspace_asset_context_for_tab(tab_name: String) -> HexMapWorkspaceAssetContext:
	var actual_tab := _canonical_tab_name(tab_name)
	if not HexMapWorkspaceComponentRegistry.tab_names().has(actual_tab):
		return null
	return workspace_asset_context()


func generation_dock() -> HexMapGenDock:
	return _generation_dock


func edit_tool() -> HexMapEditTool:
	return _edit_tool


func sample_settings_panel() -> HexMapSampleSettingsPanel:
	return _sample_settings_panel


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
	return {
		"visible": sample_learning_cta_visible(),
		"dismissed": session.sample_learning_cta_dismissed,
		"selected_tab": current_workspace_tab_name(),
		"learn_label": _learn_samples_button.text if _learn_samples_button != null else "",
	}


func set_selected_hex_tile_map_node(node: Node, reason: String = "workspace.selected_hex_tile_map") -> Dictionary:
	return set_selected_hex_tile_map_layer(_hex_tile_map_layer_from_node(node), reason)


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


func selected_hex_tile_map_snapshot() -> Dictionary:
	var session := _ensure_session_state()
	var layer := session.current_selected_hex_tile_map_layer()
	var hex_layer := layer as HexTileMapLayer
	var selected := hex_layer != null
	var context := workspace_asset_context()
	var level_document := hex_layer.level_document_resource if selected else context.level_document
	var layer_stack := hex_layer.layer_stack_resource if selected else null
	var runtime_map := hex_layer.hex_map if selected else null
	var display_tile_set := hex_layer.display_tile_set_resource if selected else null
	if selected and display_tile_set == null:
		display_tile_set = hex_layer.display_tile_set()
	return {
		"selected": selected,
		"selected_node": hex_layer,
		"node_name": hex_layer.name if selected else "",
		"node_path": _node_display_path(hex_layer),
		"status_text": _selected_hex_tile_map_status_text(hex_layer),
		"auto_link": session.selected_hex_tile_map_auto_link_enabled(),
		"auto_link_text": "Auto-link: On" if session.selected_hex_tile_map_auto_link_enabled() else "Auto-link: Off",
		"target_layer": session.current_target_layer(),
		"target_matches_selected": selected and session.current_target_layer() == hex_layer,
		"level_document": level_document,
		"level_document_status": "Missing" if selected and level_document == null else ("Linked" if level_document != null else "Unavailable"),
		"runtime_initial_map": runtime_map,
		"runtime_initial_map_present": runtime_map != null,
		"layer_stack": layer_stack,
		"layer_stack_status": "Linked" if layer_stack != null else ("Missing" if selected else "Unavailable"),
		"display_tile_set": display_tile_set,
		"display_tile_set_status": "Linked" if display_tile_set != null else ("Missing" if selected else "Unavailable"),
		"tile_catalog": context.tile_catalog,
		"tile_catalog_status": "Shared project resource" if context.tile_catalog != null else "No Tile Catalog linked to node",
		"writeback": selected_hex_tile_map_writeback_snapshot(),
	}


func selected_hex_tile_map_writeback_snapshot() -> Dictionary:
	var session := _ensure_session_state()
	var layer := session.current_selected_hex_tile_map_layer()
	var hex_layer := layer as HexTileMapLayer
	var selected := hex_layer != null
	var context := workspace_asset_context()
	var blocked_reason := ""
	if not selected:
		blocked_reason = "No HexTileMap selected"
	elif not session.selected_hex_tile_map_auto_link_enabled():
		blocked_reason = "Auto-link is off."
	return {
		"selected": selected,
		"auto_link": session.selected_hex_tile_map_auto_link_enabled(),
		"can_writeback": selected and blocked_reason == "",
		"blocked_reason": blocked_reason,
		"relationships": {
			HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT: _node_owned_relationship(
				context.level_document,
				hex_layer.level_document_resource if selected else null,
				"Selected HexTileMap Level Document"
			),
			HexMapWorkspaceAssetContext.SLOT_LAYER_STACK: _node_owned_relationship(
				context.layer_stack,
				hex_layer.layer_stack_resource if selected else null,
				"Selected HexTileMap Layer Stack"
			),
			HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG: _shared_context_relationship(context.tile_catalog, "Shared Tile Catalog"),
			HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE: _shared_context_relationship(context.object_database, "Shared Object Database"),
			HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE: _shared_context_relationship(context.label_database, "Shared Label Database"),
		},
	}


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
	return {
		"selected": selected,
		"selected_node": hex_layer,
		"status_text": _selected_hex_tile_map_status_text(hex_layer),
		"save_directory": directory,
		"resource_prefix": prefix,
		"missing_resource_ids": missing_ids,
		"missing_count": missing_ids.size(),
		"can_create": selected and directory != "" and prefix != "" and not missing_ids.is_empty(),
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
	result["after"] = missing_unique_resources_snapshot(directory, prefix)
	return result


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


func document_screen_snapshot() -> Dictionary:
	return resources_screen_snapshot()


func resources_screen_snapshot() -> Dictionary:
	var context := workspace_asset_context()
	var document := context.level_document
	var document_slot := tab_asset_slot_snapshot(
		HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT
	)
	return {
		"tab": HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"component_ids": tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_DOCUMENT),
		"asset_slot_ids": tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_DOCUMENT),
		"dependency_slot_ids": PackedStringArray([
			HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
			HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE,
			HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE,
			HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
		]),
		"level_document": document,
		"document_slot": document_slot,
		"summary": HexMapDocumentAdapter.document_summary(document),
		"saved_path": document.resource_path if document != null else "",
		"saved_status": "saved" if document != null and document.resource_path != "" else "unsaved",
		"dirty": false,
		"selected_hex_tile_map": selected_hex_tile_map_snapshot(),
		"resource_groups": resource_group_rows(),
		"create_missing_resources_available": _missing_unique_resources_create_button != null,
		"create_missing_resources_button_text": _missing_unique_resources_create_button.text if _missing_unique_resources_create_button != null else "",
	}


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
			]),
			"Project assets used when object or label workflows are enabled."
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
	return result


func validate_level_document():
	return HexMapDocumentValidator.validate_document(
		workspace_asset_context().level_document,
		_document_validation_options()
	)


func validate_screen_snapshot() -> Dictionary:
	var context := workspace_asset_context()
	return {
		"tab": HexMapWorkspaceComponentRegistry.TAB_VALIDATE,
		"component_ids": tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_VALIDATE),
		"asset_slot_ids": tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_VALIDATE),
		"level_document": context.level_document,
		"tile_catalog": context.tile_catalog,
		"object_database": context.object_database,
		"label_database": context.label_database,
		"layer_stack": context.layer_stack,
		"validation_rule_suite": context.validation_rule_suite,
		"generation_profile": context.generation_profile,
		"last_result": _last_workspace_validation_result,
		"issue_rows": validate_screen_issue_rows(_last_workspace_validation_result),
		"sample_candidates_visible": _ensure_session_state().show_bundled_samples_in_main_selectors,
	}


func run_validate_screen() -> Dictionary:
	_last_workspace_validation_result = validate_workspace_assets()
	return {
		"ok": true,
		"result": _last_workspace_validation_result,
		"issue_rows": validate_screen_issue_rows(_last_workspace_validation_result),
	}


func validate_workspace_assets() -> HexMapValidationResult:
	var context := workspace_asset_context()
	var result := HexMapValidationResult.new()
	result.summary = {
		"workspace_assets": 7,
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
	_add_missing_asset_issue(
		result,
		context.validation_rule_suite == null,
		"workspace.validation_suite_missing",
		"Validation Rule Suite is not selected.",
		HexMapWorkspaceComponentRegistry.TAB_VALIDATE,
		"validation_asset_panel",
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE
	)
	_add_missing_asset_issue(
		result,
		context.generation_profile == null,
		"workspace.generation_profile_missing",
		"Generation Profile is not selected.",
		HexMapWorkspaceComponentRegistry.TAB_QA,
		"qa_asset_panel",
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE
	)
	if context.level_document != null:
		var document_result = HexMapDocumentValidator.validate_document(context.level_document, _document_validation_options())
		for issue in document_result.issues:
			if issue is Dictionary:
				result.issues.append((issue as Dictionary).duplicate(true))
	_update_workspace_validation_counts(result)
	return result


func validate_screen_issue_rows(result: HexMapValidationResult) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	if result == null:
		return rows
	for issue in result.issues:
		if not issue is Dictionary:
			continue
		var metadata = (issue as Dictionary).get("metadata", {})
		var route: Dictionary = metadata if metadata is Dictionary else {}
		rows.append({
			"severity": String((issue as Dictionary).get("severity", "")),
			"rule_id": String((issue as Dictionary).get("rule_id", "")),
			"message": String((issue as Dictionary).get("message", "")),
			"target_tab": String(route.get("target_tab", "")),
			"target_component_id": String(route.get("target_component_id", "")),
			"target_slot_id": String(route.get("target_slot_id", "")),
		})
	return rows


func catalog_screen_snapshot() -> Dictionary:
	var context := workspace_asset_context()
	var catalog := context.tile_catalog
	var catalog_slot := tab_asset_slot_snapshot(
		HexMapWorkspaceComponentRegistry.TAB_CATALOG,
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG
	)
	return {
		"tab": HexMapWorkspaceComponentRegistry.TAB_CATALOG,
		"component_ids": tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_CATALOG),
		"asset_slot_ids": tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_CATALOG),
		"tile_catalog": catalog,
		"catalog_slot": catalog_slot,
		"tile_set": catalog.tile_set if catalog != null else null,
		"tile_set_present": catalog != null and catalog.tile_set != null,
		"entry_count": catalog.entries.size() if catalog != null else 0,
		"entry_keys": catalog.keys() if catalog != null else PackedStringArray(),
		"sample_candidates_visible": _ensure_session_state().show_bundled_samples_in_main_selectors,
	}


func create_tile_catalog(path: String) -> Dictionary:
	var panel := _catalog_asset_panel()
	if panel == null:
		return _catalog_action_result(false, ERR_UNAVAILABLE, path)
	return panel.create_asset_for_slot(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, path)


func save_tile_catalog_as(path: String) -> Dictionary:
	var panel := _catalog_asset_panel()
	if panel == null:
		return _catalog_action_result(false, ERR_UNAVAILABLE, path)
	return panel.save_asset_slot_as(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, path)


func open_tile_catalog() -> Dictionary:
	var panel := _catalog_asset_panel()
	if panel == null:
		return _catalog_action_result(false, ERR_UNAVAILABLE, "")
	return panel.open_asset_slot(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG)


func clear_tile_catalog() -> Dictionary:
	var panel := _catalog_asset_panel()
	if panel == null:
		return _catalog_action_result(false, ERR_UNAVAILABLE, "")
	return panel.clear_asset_slot(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG)


func set_catalog_tile_set(tile_set: TileSet) -> Dictionary:
	var catalog := workspace_asset_context().tile_catalog
	if catalog == null or tile_set == null:
		return _catalog_action_result(false, ERR_INVALID_PARAMETER, "")
	catalog.tile_set = tile_set
	_sync_workspace_asset_context()
	return {
		"ok": true,
		"error": OK,
		"slot_id": HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		"resource": catalog,
		"tile_set": tile_set,
	}


func create_catalog_atlas_entry_from_tileset(
	key: String,
	tile_set: TileSet,
	source_id: int,
	atlas_coords: Vector2i,
	alternative_tile: int = 0
) -> Dictionary:
	var catalog := workspace_asset_context().tile_catalog
	var entry_key := key.strip_edges()
	if catalog == null or tile_set == null or entry_key == "":
		return _catalog_action_result(false, ERR_INVALID_PARAMETER, "")
	catalog.tile_set = tile_set
	var entry := HexTileCatalogEntry.new()
	entry.key = entry_key
	entry.display_name = entry_key
	entry.entry_type = HexTileCatalogEntry.TYPE_ATLAS
	entry.source_id = source_id
	entry.atlas_coords = atlas_coords
	entry.alternative_tile = alternative_tile
	catalog.add_entry(entry)
	_sync_workspace_asset_context()
	return {
		"ok": true,
		"error": OK,
		"slot_id": HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		"resource": catalog,
		"entry": entry,
	}


func create_catalog_scene_entry_from_packed_scene(
	key: String,
	scene: PackedScene,
	source_id: int = 1,
	scene_tile_id: int = 1
) -> Dictionary:
	var catalog := workspace_asset_context().tile_catalog
	var entry_key := key.strip_edges()
	if catalog == null or scene == null or entry_key == "":
		return _catalog_action_result(false, ERR_INVALID_PARAMETER, "")
	if catalog.tile_set == null:
		catalog.tile_set = TileSet.new()
	var scene_source = null
	if catalog.tile_set.has_source(source_id):
		scene_source = catalog.tile_set.get_source(source_id) as TileSetScenesCollectionSource
	if scene_source == null:
		scene_source = TileSetScenesCollectionSource.new()
		catalog.tile_set.add_source(scene_source, source_id)
	if not scene_source.has_scene_tile_id(scene_tile_id):
		scene_source.create_scene_tile(scene, scene_tile_id)
	var entry := HexTileCatalogEntry.new()
	entry.key = entry_key
	entry.display_name = entry_key
	entry.entry_type = HexTileCatalogEntry.TYPE_SCENE
	entry.source_id = source_id
	entry.atlas_coords = Vector2i(scene_tile_id, 0)
	entry.scene = scene
	catalog.add_entry(entry)
	_sync_workspace_asset_context()
	return {
		"ok": true,
		"error": OK,
		"slot_id": HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		"resource": catalog,
		"entry": entry,
	}


func validate_tile_catalog():
	return HexTileCatalogValidator.validate_catalog(workspace_asset_context().tile_catalog)


func layer_stack_screen_snapshot() -> Dictionary:
	var context := workspace_asset_context()
	var stack := context.layer_stack
	var stack_slot := tab_asset_slot_snapshot(
		HexMapWorkspaceComponentRegistry.TAB_LAYERS,
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK
	)
	var target_status := _edit_tool.target_readiness_status() if _edit_tool != null else {}
	var role_rows := _edit_tool.layer_stack_rows() if _edit_tool != null else []
	return {
		"tab": HexMapWorkspaceComponentRegistry.TAB_LAYERS,
		"component_ids": tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_LAYERS),
		"asset_slot_ids": tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_LAYERS),
		"layer_stack": stack,
		"layer_stack_slot": stack_slot,
		"stack_id": stack.stack_id if stack != null else "",
		"display_name": stack.display_name if stack != null else "",
		"role_count": stack.layers.size() if stack != null else 0,
		"role_names": stack.role_names() if stack != null else PackedStringArray(),
		"role_rows": role_rows,
		"target_status": target_status,
		"target_layer": _edit_tool.target_layer() if _edit_tool != null else null,
		"template_candidates": PackedStringArray(["standard", "minimal"]),
		"sample_template_present": false,
	}


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
	return {
		"ok": _edit_tool.target_layer() != null,
		"error": OK if _edit_tool.target_layer() != null else ERR_DOES_NOT_EXIST,
		"target_layer": _edit_tool.target_layer(),
		"target_status": _edit_tool.target_readiness_status(),
		"role_rows": _edit_tool.layer_stack_rows(),
	}


func set_layer_stack_document(document: HexMapDocumentResource) -> Dictionary:
	if _edit_tool == null or document == null:
		return _layer_stack_action_result(false, ERR_INVALID_PARAMETER, "")
	_edit_tool.set_document(document)
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
	var paint_workspace := _edit_tool.paint_workspace_snapshot() if _edit_tool != null else {}
	return {
		"tab": HexMapWorkspaceComponentRegistry.TAB_PAINT,
		"component_ids": tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_PAINT),
		"asset_slot_ids": tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_PAINT),
		"brush": _edit_tool.paint_brush_snapshot() if _edit_tool != null else {},
		"workspace": paint_workspace,
		"active_document": paint_workspace.get("active_document", null),
		"active_document_status": String(paint_workspace.get("active_document_status", "none")),
		"active_layer": paint_workspace.get("active_layer", null),
		"active_layer_name": String(paint_workspace.get("active_layer_name", "")),
		"selected_cell": paint_workspace.get("selected_cell", {}),
		"last_edit": paint_workspace.get("last_edit", {}),
		"last_edit_summary": String(paint_workspace.get("last_edit_summary", "none")),
		"last_edit_message": String(paint_workspace.get("last_edit_message", "none")),
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
	return {
		"tab": HexMapWorkspaceComponentRegistry.TAB_QA,
		"component_ids": tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_QA),
		"asset_slot_ids": tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_QA),
		"generation_profile": context.generation_profile,
		"validation_rule_suite": context.validation_rule_suite,
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
		"sample_candidates_visible": _ensure_session_state().show_bundled_samples_in_main_selectors,
	}


func qa_score_table_context() -> Dictionary:
	var context := workspace_asset_context()
	return {
		"generation_profile": _qa_resource_context(context.generation_profile),
		"validation_rule_suite": _qa_resource_context(context.validation_rule_suite),
		"score_rows": _generation_dock.generation_batch_score_table("score", true) if _generation_dock != null else [],
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
	var context := workspace_asset_context()
	return {
		"tab": HexMapWorkspaceComponentRegistry.TAB_EXPORT,
		"component_ids": tab_component_ids(HexMapWorkspaceComponentRegistry.TAB_EXPORT),
		"asset_slot_ids": tab_asset_slot_ids(HexMapWorkspaceComponentRegistry.TAB_EXPORT),
		"level_document": context.level_document,
		"export_profile": context.export_profile,
		"level_document_slot": tab_asset_slot_snapshot(
			HexMapWorkspaceComponentRegistry.TAB_EXPORT,
			HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT
		),
		"export_profile_slot": tab_asset_slot_snapshot(
			HexMapWorkspaceComponentRegistry.TAB_EXPORT,
			HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE
		),
		"destination": _export_destination_context(),
		"destination_dialog_config": export_destination_dialog_config(),
		"can_export": context.level_document != null and _ensure_session_state().export_saved_path != "",
		"package_handoff": _export_handoff_context(_ensure_session_state().export_saved_path, null),
		"runtime_handoff": _export_handoff_context(_ensure_session_state().export_saved_path, null),
		"sample_candidates_visible": _ensure_session_state().show_bundled_samples_in_main_selectors,
		"sample_destination_available": false,
		"editable_destination_path_visible": false,
	}


func export_destination_dialog_config() -> Dictionary:
	return {
		"uses_file_dialog": true,
		"file_mode": EditorFileDialog.FILE_MODE_SAVE_FILE,
		"filters": HexMapEditorPathSelector.TRES_FILTERS.duplicate(),
		"current_file": "hex_map_export.tres",
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
	_refresh_export_destination_panel()
	return _export_action_result(true, OK, "")


func export_selected_document_to_destination(path: String = "") -> Dictionary:
	if path.strip_edges() != "":
		var select_result := select_export_destination(path)
		if not bool(select_result.get("ok", false)):
			return select_result
	var actual_path := HexMapWorkspaceAssetResourceFactory.normalized_resource_path(_ensure_session_state().export_saved_path)
	if actual_path == "":
		return _export_action_result(false, ERR_INVALID_PARAMETER, actual_path)
	var document := workspace_asset_context().level_document
	if document == null:
		return _export_action_result(false, ERR_DOES_NOT_EXIST, actual_path)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(actual_path.get_base_dir()))
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
	result["export_profile"] = workspace_asset_context().export_profile
	result["package_handoff"] = _export_handoff_context(actual_path, map_resource)
	result["runtime_handoff"] = _export_handoff_context(actual_path, map_resource)
	_refresh_export_destination_panel()
	return result


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
		]
	)
	_mount_missing_unique_resources_panel()
	_mount_asset_panel(
		HexMapWorkspaceComponentRegistry.TAB_CATALOG,
		"catalog_asset_panel",
		"Catalog Assets",
		[
			_slot_row(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "Tile Catalog"),
		]
	)
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
			_slot_row(HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE, "Validation Rule Suite"),
		]
	)
	_mount_asset_panel(
		HexMapWorkspaceComponentRegistry.TAB_QA,
		"qa_asset_panel",
		"QA Assets",
		[
			_slot_row(HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE, "Generation Profile"),
			_slot_row(HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE, "Validation Rule Suite"),
			_slot_row(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "Promotion Target Document", false),
		]
	)
	_mount_asset_panel(
		HexMapWorkspaceComponentRegistry.TAB_EXPORT,
		"export_asset_panel",
		"Export Assets",
		[
			_slot_row(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "Level Document"),
			_slot_row(HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE, "Export Profile", false),
		]
	)
	_mount_asset_panel(
		HexMapWorkspaceComponentRegistry.TAB_SETTINGS,
		"settings_project_defaults_panel",
		"Project Defaults",
		[
			_slot_row(HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE, "Movement Profile", false),
		]
	)


func _mount_resources_context_panel() -> void:
	var page = _tab_pages.get(HexMapWorkspaceComponentRegistry.TAB_DOCUMENT, null)
	if page == null or _resources_context_panel != null:
		return
	_resources_context_panel = VBoxContainer.new()
	_resources_context_panel.name = "Resources Context Panel"
	_resources_context_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var title := Label.new()
	title.text = "Selected HexTileMap Resources"
	_resources_context_panel.add_child(title)

	_resources_context_status_label = Label.new()
	_resources_context_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_resources_context_panel.add_child(_resources_context_status_label)

	for group in resource_group_rows():
		var group_id := String(group.get("group_id", ""))
		var label := Label.new()
		var slot_labels = group.get("slot_labels", PackedStringArray()) as PackedStringArray
		label.text = "%s: %s" % [
			String(group.get("label", "")),
			_join_text(slot_labels, ", "),
		]
		label.tooltip_text = String(group.get("tooltip", ""))
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_resources_context_panel.add_child(label)
		_resources_group_labels[group_id] = label

	(page as Control).add_child(_resources_context_panel)
	_register_tab_component(
		HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"resources_context_panel",
		_resources_context_panel
	)
	_refresh_resources_context_panel()


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
	_missing_unique_resources_panel = VBoxContainer.new()
	_missing_unique_resources_panel.name = "Missing Unique Resources Panel"
	_missing_unique_resources_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var title := Label.new()
	title.text = "Missing resources for Selected HexTileMap"
	_missing_unique_resources_panel.add_child(title)

	_missing_unique_resources_status_label = Label.new()
	_missing_unique_resources_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_missing_unique_resources_panel.add_child(_missing_unique_resources_status_label)

	var directory_row := HBoxContainer.new()
	_missing_unique_resources_save_directory_label = Label.new()
	_missing_unique_resources_save_directory_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	directory_row.add_child(_missing_unique_resources_save_directory_label)
	_missing_unique_resources_choose_directory_button = Button.new()
	_missing_unique_resources_choose_directory_button.text = "Choose Folder..."
	_missing_unique_resources_choose_directory_button.pressed.connect(_on_missing_unique_resources_choose_directory_pressed)
	directory_row.add_child(_missing_unique_resources_choose_directory_button)
	_missing_unique_resources_panel.add_child(directory_row)

	var prefix_row := HBoxContainer.new()
	var prefix_label := Label.new()
	prefix_label.text = "Resource prefix"
	prefix_row.add_child(prefix_label)
	_missing_unique_resources_prefix_edit = LineEdit.new()
	_missing_unique_resources_prefix_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_missing_unique_resources_prefix_edit.text_changed.connect(_on_missing_unique_resources_prefix_changed)
	prefix_row.add_child(_missing_unique_resources_prefix_edit)
	_missing_unique_resources_panel.add_child(prefix_row)

	_missing_unique_resources_create_button = Button.new()
	_missing_unique_resources_create_button.text = "Create Missing Resources"
	_missing_unique_resources_create_button.pressed.connect(_on_create_missing_unique_resources_pressed)
	_missing_unique_resources_panel.add_child(_missing_unique_resources_create_button)

	(page as Control).add_child(_missing_unique_resources_panel)
	_register_tab_component(
		HexMapWorkspaceComponentRegistry.TAB_DOCUMENT,
		"missing_unique_resources_panel",
		_missing_unique_resources_panel
	)
	_refresh_missing_unique_resources_panel()


func _mount_validation_issue_navigator() -> void:
	var page = _tab_pages.get(HexMapWorkspaceComponentRegistry.TAB_VALIDATE, null)
	if page == null:
		return
	var navigator := VBoxContainer.new()
	navigator.name = "Validation Issue Navigator"
	navigator.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	navigator.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var title := Label.new()
	title.text = "Validation Issues"
	navigator.add_child(title)
	var status := Label.new()
	status.text = "No validation run selected."
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	navigator.add_child(status)
	(page as Control).add_child(navigator)
	_register_tab_component(
		HexMapWorkspaceComponentRegistry.TAB_VALIDATE,
		"validation_issue_navigator",
		navigator
	)


func _mount_export_destination_panel() -> void:
	var page = _tab_pages.get(HexMapWorkspaceComponentRegistry.TAB_EXPORT, null)
	if page == null:
		return
	_export_destination_panel = VBoxContainer.new()
	_export_destination_panel.name = "Export Destination Panel"
	_export_destination_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var title := Label.new()
	title.text = "Export Destination"
	_export_destination_panel.add_child(title)

	_export_destination_label = Label.new()
	_export_destination_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_export_destination_panel.add_child(_export_destination_label)

	_export_recent_destinations_label = Label.new()
	_export_recent_destinations_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_export_destination_panel.add_child(_export_recent_destinations_label)

	var actions := HBoxContainer.new()
	_export_choose_destination_button = Button.new()
	_export_choose_destination_button.text = "Choose Destination..."
	_export_choose_destination_button.pressed.connect(_on_export_choose_destination_pressed)
	actions.add_child(_export_choose_destination_button)

	_export_use_recent_button = Button.new()
	_export_use_recent_button.text = "Use Recent"
	_export_use_recent_button.pressed.connect(_on_export_use_recent_pressed)
	actions.add_child(_export_use_recent_button)

	_export_run_button = Button.new()
	_export_run_button.text = "Export"
	_export_run_button.pressed.connect(_on_export_run_workspace_pressed)
	actions.add_child(_export_run_button)
	_export_destination_panel.add_child(actions)

	(page as Control).add_child(_export_destination_panel)
	_register_tab_component(
		HexMapWorkspaceComponentRegistry.TAB_EXPORT,
		"export_destination_panel",
		_export_destination_panel
	)
	_refresh_export_destination_panel()


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
	var slot_labels := PackedStringArray()
	var tooltip_lines := PackedStringArray()
	tooltip_lines.append(tooltip)
	for slot_id in slot_ids:
		var text := _resource_group_slot_label(String(slot_id))
		slot_labels.append(text)
		var purpose := HexMapWorkspaceAssetResourceFactory.resource_purpose(String(slot_id))
		if purpose != "":
			tooltip_lines.append("%s: %s" % [text, purpose])
	return {
		"group_id": group_id,
		"label": label,
		"slot_ids": slot_ids.duplicate(),
		"slot_labels": slot_labels,
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
	var resource = result.get("resource", null) as Resource
	if resource == null:
		return
	workspace_asset_context().set_generation_profile(resource)
	_sync_workspace_asset_context()


func _sync_validation_suite_from_result(result: Dictionary) -> void:
	if not bool(result.get("ok", false)):
		return
	var resource = result.get("resource", null) as Resource
	if resource == null:
		return
	workspace_asset_context().set_validation_rule_suite(resource)
	_sync_workspace_asset_context()


func _sync_export_profile_from_result(result: Dictionary) -> void:
	if not bool(result.get("ok", false)):
		return
	var resource = result.get("resource", null) as Resource
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


func _qa_resource_context(resource: Resource) -> Dictionary:
	if resource == null:
		return {
			"selected": false,
			"resource_name": "",
			"resource_path": "",
			"preset_source": "",
		}
	return {
		"selected": true,
		"resource_name": resource.resource_name,
		"resource_path": resource.resource_path,
		"preset_source": String(resource.get_meta("preset_source", "")),
	}


func _export_destination_context() -> Dictionary:
	var session := _ensure_session_state()
	var recent: Array[String] = []
	for destination in session.recent_export_destinations:
		recent.append(String(destination))
	return {
		"selected": session.export_saved_path != "",
		"path": session.export_saved_path,
		"recent_destinations": recent,
		"uses_file_dialog": true,
		"editable_path_text_visible": false,
	}


func _export_handoff_context(path: String, resource) -> Dictionary:
	var map_data = resource.to_map_data() if resource != null else null
	return {
		"selected": path != "",
		"path": path,
		"resource_class": "HexMapResource" if path != "" or resource != null else "",
		"cell_count": map_data.cells.size() if map_data != null else 0,
		"wall_count": map_data.walls.size() if map_data != null else 0,
	}


func _generation_profile_preset(preset_id: String) -> Resource:
	var id := preset_id.strip_edges().to_lower()
	if not ["balanced", "sparse", "dense"].has(id):
		return null
	var profile := Resource.new()
	profile.resource_name = "%s Generation Profile" % id.capitalize()
	profile.set_meta("preset_source", id)
	profile.set_meta("profile_kind", "generation")
	return profile


func _validation_rule_suite_preset(preset_id: String) -> Resource:
	var id := preset_id.strip_edges().to_lower()
	if id != "standard":
		return null
	var suite := Resource.new()
	suite.resource_name = "Standard Validation Rule Suite"
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
	_generation_dock = HexMapGenDock.new()
	_generation_dock.set_editor_session_state(_ensure_session_state())
	_generation_dock.set_workspace_asset_context(workspace_asset_context())
	_generation_dock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_generation_dock.size_flags_vertical = Control.SIZE_EXPAND_FILL
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


func _refresh_export_destination_panel() -> void:
	if _export_destination_panel == null:
		return
	var session := _ensure_session_state()
	var destination := session.export_saved_path
	if _export_destination_label != null:
		_export_destination_label.text = "Destination: %s" % ("Not selected" if destination == "" else destination)
	if _export_recent_destinations_label != null:
		_export_recent_destinations_label.text = "Recent destinations: %d" % session.recent_export_destinations.size()
	if _export_use_recent_button != null:
		_export_use_recent_button.disabled = session.recent_export_destinations.is_empty()
	if _export_run_button != null:
		_export_run_button.disabled = workspace_asset_context().level_document == null or destination == ""


func _popup_export_destination_dialog() -> bool:
	if not Engine.is_editor_hint():
		return false
	var dialog := HexMapEditorPathSelector.new_dialog(
		EditorFileDialog.FILE_MODE_SAVE_FILE,
		HexMapEditorPathSelector.TRES_FILTERS
	)
	dialog.current_file = "hex_map_export.tres"
	dialog.file_selected.connect(_on_export_destination_file_selected)
	add_child(dialog)
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


func _popup_missing_unique_resources_directory_dialog() -> bool:
	if not Engine.is_editor_hint():
		return false
	var dialog := HexMapEditorPathSelector.new_dialog(
		EditorFileDialog.FILE_MODE_OPEN_DIR,
		[]
	)
	dialog.dir_selected.connect(_on_missing_unique_resources_directory_selected)
	add_child(dialog)
	return HexMapEditorPathSelector.popup_dialog(dialog)


func _on_missing_unique_resources_choose_directory_pressed() -> void:
	_popup_missing_unique_resources_directory_dialog()


func _on_missing_unique_resources_directory_selected(path: String) -> void:
	set_missing_unique_resources_save_directory(path)


func _on_missing_unique_resources_prefix_changed(_text: String) -> void:
	_refresh_missing_unique_resources_panel()


func _on_create_missing_unique_resources_pressed() -> void:
	create_missing_selected_hex_tile_map_resources(
		_missing_unique_resources_save_directory,
		_missing_unique_resources_prefix()
	)


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
	var hex_layer := layer as HexTileMapLayer
	var context := workspace_asset_context()
	context.set_level_document(hex_layer.level_document_resource if hex_layer != null else null)
	context.set_layer_stack(hex_layer.layer_stack_resource if hex_layer != null else null)


func _apply_workspace_asset_change_to_selected_node(slot_id: String, reason: String) -> Dictionary:
	match slot_id:
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, \
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE, \
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE:
			return _writeback_result(true, OK, slot_id, "shared_context", "Shared project context", "")
	var snapshot := selected_hex_tile_map_writeback_snapshot()
	if not bool(snapshot.get("can_writeback", false)):
		return {
			"ok": false,
			"error": ERR_UNAVAILABLE,
			"slot_id": slot_id,
			"blocked_reason": String(snapshot.get("blocked_reason", "")),
			"policy": _writeback_policy_for_slot(slot_id),
		}
	var hex_layer := _ensure_session_state().current_selected_hex_tile_map_layer() as HexTileMapLayer
	var context := workspace_asset_context()
	match slot_id:
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT:
			var document := context.level_document
			hex_layer.level_document_resource = document
			_ensure_session_state().set_document(
				document,
				"workspace.asset_context",
				document.resource_path if document != null else "",
				reason
			)
			_refresh_selected_hex_tile_map_context()
			return _writeback_result(true, OK, slot_id, "node_owned", "Selected HexTileMap Level Document", "")
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK:
			var stack := context.layer_stack
			hex_layer.layer_stack_resource = stack
			if _edit_tool != null:
				_edit_tool.set_layer_stack_resource(stack, false)
			_refresh_selected_hex_tile_map_context()
			return _writeback_result(true, OK, slot_id, "node_owned", "Selected HexTileMap Layer Stack", "")
	return _writeback_result(false, ERR_INVALID_PARAMETER, slot_id, "unsupported", "", "Unsupported workspace asset slot.")


func _refresh_selected_hex_tile_map_context() -> void:
	if _selected_hex_tile_map_status_label == null or _selected_hex_tile_map_auto_link_label == null:
		return
	var snapshot := selected_hex_tile_map_snapshot()
	_selected_hex_tile_map_status_label.text = String(snapshot.get("status_text", "No HexTileMap selected"))
	_selected_hex_tile_map_status_label.tooltip_text = _selected_hex_tile_map_tooltip(snapshot)
	_selected_hex_tile_map_auto_link_label.text = String(snapshot.get("auto_link_text", "Auto-link: On"))
	_selected_hex_tile_map_auto_link_label.tooltip_text = "Workspace follows the selected HexTileMap node."
	_refresh_resources_context_panel()
	_refresh_missing_unique_resources_panel()


func _refresh_resources_context_panel() -> void:
	if _resources_context_panel == null:
		return
	var snapshot := selected_hex_tile_map_snapshot()
	if _resources_context_status_label != null:
		_resources_context_status_label.text = String(snapshot.get("status_text", "No HexTileMap selected"))
		_resources_context_status_label.tooltip_text = _selected_hex_tile_map_tooltip(snapshot)
	for group in resource_group_rows():
		var group_id := String(group.get("group_id", ""))
		var label = _resources_group_labels.get(group_id, null) as Label
		if label == null:
			continue
		var slot_labels = group.get("slot_labels", PackedStringArray()) as PackedStringArray
		label.text = "%s: %s" % [
			String(group.get("label", "")),
			_join_text(slot_labels, ", "),
		]
		label.tooltip_text = String(group.get("tooltip", ""))


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
	if _missing_unique_resources_create_button != null:
		_missing_unique_resources_create_button.disabled = not bool(snapshot.get("can_create", false))


func _selected_hex_tile_map_status_text(layer: Node) -> String:
	if layer == null or not is_instance_valid(layer):
		return "No HexTileMap selected"
	return "Selected HexTileMap: %s" % _node_display_path(layer)


func _selected_hex_tile_map_tooltip(snapshot: Dictionary) -> String:
	if not bool(snapshot.get("selected", false)):
		return "No HexTileMap selected"
	var writeback = snapshot.get("writeback", {}) as Dictionary
	var blocked_reason := String(writeback.get("blocked_reason", ""))
	var writeback_text := "Write-back: On" if blocked_reason == "" else "Write-back blocked: %s" % blocked_reason
	return "Node: %s\n%s\n%s\nLevel Document: %s\nLayer Stack: %s\nTile Catalog: %s" % [
		String(snapshot.get("node_path", "")),
		String(snapshot.get("auto_link_text", "")),
		writeback_text,
		String(snapshot.get("level_document_status", "")),
		String(snapshot.get("layer_stack_status", "")),
		String(snapshot.get("tile_catalog_status", "")),
	]


func _hex_tile_map_layer_from_node(node: Node) -> HexTileMapLayer:
	if node == null or not is_instance_valid(node):
		return null
	if node is HexTileMapLayer:
		return node as HexTileMapLayer
	if node is TileMapLayer and _is_hex_tile_map_internal_layer(node):
		return node.get_parent() as HexTileMapLayer
	return null


func _is_hex_tile_map_internal_layer(node: Node) -> bool:
	var parent := node.get_parent()
	if not (parent is HexTileMapLayer):
		return false
	return node.name == HexTileMapLayer.BASE_TILE_MAP_NAME \
		or node.name == HexTileMapLayer.LOOP_TILE_MAP_NAME \
		or node.name == HexTileMapLayer.OVERLAY_TILE_MAP_NAME


func _node_display_path(node: Node) -> String:
	if node == null or not is_instance_valid(node):
		return ""
	return str(node.get_path()) if node.is_inside_tree() else node.name


func _node_owned_relationship(workspace_resource: Resource, node_resource: Resource, label: String) -> Dictionary:
	var status := "missing"
	if workspace_resource != null and node_resource != null and workspace_resource == node_resource:
		status = "linked"
	elif workspace_resource != null and node_resource == null:
		status = "workspace_pending_node_writeback"
	elif workspace_resource == null and node_resource != null:
		status = "node_only"
	elif workspace_resource != null and node_resource != workspace_resource:
		status = "different"
	return {
		"policy": "node_owned",
		"label": label,
		"workspace_resource": workspace_resource,
		"node_resource": node_resource,
		"status": status,
		"matches": workspace_resource == node_resource,
		"generation_metadata": _document_generation_metadata_snapshot(node_resource),
	}


func _document_generation_metadata_snapshot(resource: Resource) -> Dictionary:
	var document := resource as HexMapDocumentResource
	if document == null or document.metadata == null:
		return {
			"present": false,
		}
	var custom: Dictionary = document.metadata.custom_properties
	return {
		"present": not document.metadata.generation_snapshot.is_empty() \
			or custom.has("generation_source"),
		"generation_seed": document.metadata.generation_seed,
		"generation_snapshot": document.metadata.generation_snapshot.duplicate(true),
		"generation_source": String(custom.get("generation_source", "")),
		"generation_output_target": String(custom.get("generation_output_target", "")),
		"generation_target_node_path": String(custom.get("generation_target_node_path", "")),
		"generation_target_document_path": String(custom.get("generation_target_document_path", "")),
	}


func _shared_context_relationship(resource: Resource, label: String) -> Dictionary:
	return {
		"policy": "shared_context",
		"label": label,
		"workspace_resource": resource,
		"node_resource": null,
		"status": "selected" if resource != null else "missing",
		"matches": true,
	}


func _writeback_result(
	ok: bool,
	error: int,
	slot_id: String,
	policy: String,
	label: String,
	blocked_reason: String
) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"slot_id": slot_id,
		"policy": policy,
		"label": label,
		"blocked_reason": blocked_reason,
		"snapshot": selected_hex_tile_map_writeback_snapshot(),
	}


func _writeback_policy_for_slot(slot_id: String) -> String:
	match slot_id:
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, HexMapWorkspaceAssetContext.SLOT_LAYER_STACK:
			return "node_owned"
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, \
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE, \
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE:
			return "shared_context"
	return "unsupported"


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
	if _edit_tool != null:
		_edit_tool.set_workspace_asset_context(context)


func _canonical_tab_name(tab_name: String) -> String:
	return HexMapWorkspaceComponentRegistry.canonical_tab_name(tab_name)


func _register_tab_component(tab_name: String, component_id: String, control: Control) -> void:
	if not _tab_components.has(tab_name):
		_tab_components[tab_name] = {}
	_tab_components[tab_name][component_id] = control


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
		_apply_workspace_asset_change_to_selected_node(slot_id, "workspace.asset_context.changed")
		_refresh_selected_hex_tile_map_context()
	_refresh_sample_learning_cta()
	_refresh_export_destination_panel()
