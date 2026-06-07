@tool
class_name HexMapEditorSessionState
extends RefCounted

const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")

const MAX_RECENT_EXPORT_DESTINATIONS := 8

signal changed(key: String)

var target_layer: Node = null
var document: Resource = null
var document_source: String = ""
var document_saved_path: String = ""
var import_map: Resource = null
var import_map_saved_path: String = ""
var export_saved_path: String = ""
var recent_export_destinations: PackedStringArray = PackedStringArray()
var workspace_asset_context: HexMapWorkspaceAssetContext = HexMapWorkspaceAssetContext.new()
var show_bundled_samples_in_main_selectors := false
var use_bundled_sample_assets_for_scratch_documents := false
var auto_create_project_copy_when_applying_sample := false
var sample_learning_cta_dismissed := false
var last_reason: String = ""


func _init() -> void:
	_connect_workspace_asset_context()


func set_target_layer(layer: Node, reason: String = "") -> void:
	if target_layer == layer and last_reason == reason:
		return
	target_layer = layer
	last_reason = reason
	changed.emit("target_layer")


func current_target_layer() -> Node:
	return target_layer if target_layer != null and is_instance_valid(target_layer) else null


func set_document(value: Resource, source: String = "", saved_path: String = "", reason: String = "") -> void:
	document = value
	document_source = source
	if saved_path != "":
		document_saved_path = saved_path
	last_reason = reason
	changed.emit("document")


func current_document() -> Resource:
	return document


func set_document_saved_path(path: String, reason: String = "") -> void:
	document_saved_path = path
	last_reason = reason
	changed.emit("document_saved_path")


func set_import_map(value: Resource, saved_path: String = "", reason: String = "") -> void:
	import_map = value
	if saved_path != "":
		import_map_saved_path = saved_path
	last_reason = reason
	changed.emit("import_map")


func current_import_map() -> Resource:
	return import_map


func set_import_map_saved_path(path: String, reason: String = "") -> void:
	import_map_saved_path = path
	last_reason = reason
	changed.emit("import_map_saved_path")


func set_export_saved_path(path: String, reason: String = "") -> void:
	export_saved_path = path
	last_reason = reason
	changed.emit("export_saved_path")


func record_export_destination(path: String, reason: String = "") -> void:
	var actual_path := path.strip_edges()
	if actual_path == "":
		return
	set_export_saved_path(actual_path, reason)
	var next_recent := PackedStringArray([actual_path])
	for existing in recent_export_destinations:
		var text := String(existing)
		if text != "" and text != actual_path and next_recent.size() < MAX_RECENT_EXPORT_DESTINATIONS:
			next_recent.append(text)
	recent_export_destinations = next_recent
	last_reason = reason
	changed.emit("recent_export_destinations")


func set_workspace_asset_context(context: HexMapWorkspaceAssetContext, reason: String = "") -> void:
	var next_context := context if context != null else HexMapWorkspaceAssetContext.new()
	if workspace_asset_context == next_context:
		return
	if workspace_asset_context != null and workspace_asset_context.asset_changed.is_connected(_on_workspace_asset_context_changed):
		workspace_asset_context.asset_changed.disconnect(_on_workspace_asset_context_changed)
	workspace_asset_context = next_context
	_connect_workspace_asset_context()
	last_reason = reason
	changed.emit("workspace_asset_context")


func current_workspace_asset_context() -> HexMapWorkspaceAssetContext:
	if workspace_asset_context == null:
		workspace_asset_context = HexMapWorkspaceAssetContext.new()
		_connect_workspace_asset_context()
	return workspace_asset_context


func set_workspace_asset(slot_id: String, resource: Resource, reason: String = "") -> void:
	last_reason = reason
	current_workspace_asset_context().set_asset(slot_id, resource)


func set_show_bundled_samples_in_main_selectors(enabled: bool, reason: String = "") -> void:
	if show_bundled_samples_in_main_selectors == enabled:
		return
	show_bundled_samples_in_main_selectors = enabled
	last_reason = reason
	changed.emit("sample_settings.show_bundled_samples_in_main_selectors")


func bundled_samples_visible_in_main_selectors() -> bool:
	return show_bundled_samples_in_main_selectors


func set_use_bundled_sample_assets_for_scratch_documents(enabled: bool, reason: String = "") -> void:
	if use_bundled_sample_assets_for_scratch_documents == enabled:
		return
	use_bundled_sample_assets_for_scratch_documents = enabled
	last_reason = reason
	changed.emit("sample_settings.use_bundled_sample_assets_for_scratch_documents")


func set_auto_create_project_copy_when_applying_sample(enabled: bool, reason: String = "") -> void:
	if auto_create_project_copy_when_applying_sample == enabled:
		return
	auto_create_project_copy_when_applying_sample = enabled
	last_reason = reason
	changed.emit("sample_settings.auto_create_project_copy_when_applying_sample")


func set_sample_learning_cta_dismissed(dismissed: bool, reason: String = "") -> void:
	if sample_learning_cta_dismissed == dismissed:
		return
	sample_learning_cta_dismissed = dismissed
	last_reason = reason
	changed.emit("sample_settings.sample_learning_cta_dismissed")


func dismiss_sample_learning_cta(reason: String = "") -> void:
	set_sample_learning_cta_dismissed(true, reason)


func sample_learning_cta_visible() -> bool:
	return not sample_learning_cta_dismissed


func snapshot() -> Dictionary:
	var context := current_workspace_asset_context()
	return {
		"target_layer": current_target_layer(),
		"document": document,
		"document_source": document_source,
		"document_saved_path": document_saved_path,
		"import_map": import_map,
		"import_map_saved_path": import_map_saved_path,
		"export_saved_path": export_saved_path,
		"recent_export_destinations": recent_export_destinations.duplicate(),
		"workspace_asset_context": context,
		"workspace_asset_context_snapshot": context.snapshot(),
		"show_bundled_samples_in_main_selectors": show_bundled_samples_in_main_selectors,
		"use_bundled_sample_assets_for_scratch_documents": use_bundled_sample_assets_for_scratch_documents,
		"auto_create_project_copy_when_applying_sample": auto_create_project_copy_when_applying_sample,
		"sample_learning_cta_dismissed": sample_learning_cta_dismissed,
		"sample_learning_cta_visible": sample_learning_cta_visible(),
		"last_reason": last_reason,
	}


func _connect_workspace_asset_context() -> void:
	if workspace_asset_context != null and not workspace_asset_context.asset_changed.is_connected(_on_workspace_asset_context_changed):
		workspace_asset_context.asset_changed.connect(_on_workspace_asset_context_changed)


func _on_workspace_asset_context_changed(slot_id: String) -> void:
	changed.emit("workspace_asset_context.%s" % slot_id)
