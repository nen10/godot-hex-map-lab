@tool
class_name HexMapEditorSessionState
extends RefCounted

const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")

signal changed(key: String)

var target_layer: Node = null
var document: Resource = null
var document_source: String = ""
var document_saved_path: String = ""
var import_map: Resource = null
var import_map_saved_path: String = ""
var export_saved_path: String = ""
var workspace_asset_context: HexMapWorkspaceAssetContext = HexMapWorkspaceAssetContext.new()
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
		"workspace_asset_context": context,
		"workspace_asset_context_snapshot": context.snapshot(),
		"last_reason": last_reason,
	}


func _connect_workspace_asset_context() -> void:
	if workspace_asset_context != null and not workspace_asset_context.asset_changed.is_connected(_on_workspace_asset_context_changed):
		workspace_asset_context.asset_changed.connect(_on_workspace_asset_context_changed)


func _on_workspace_asset_context_changed(slot_id: String) -> void:
	changed.emit("workspace_asset_context.%s" % slot_id)
