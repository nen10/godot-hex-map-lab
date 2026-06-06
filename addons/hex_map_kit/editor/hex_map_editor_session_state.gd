@tool
class_name HexMapEditorSessionState
extends RefCounted

signal changed(key: String)

var target_layer: Node = null
var document: Resource = null
var document_source: String = ""
var document_path: String = ""
var import_map_path: String = ""
var export_path: String = ""
var last_reason: String = ""


func set_target_layer(layer: Node, reason: String = "") -> void:
	if target_layer == layer and last_reason == reason:
		return
	target_layer = layer
	last_reason = reason
	changed.emit("target_layer")


func current_target_layer() -> Node:
	return target_layer if target_layer != null and is_instance_valid(target_layer) else null


func set_document(value: Resource, source: String = "", path: String = "", reason: String = "") -> void:
	document = value
	document_source = source
	if path != "":
		document_path = path
	last_reason = reason
	changed.emit("document")


func current_document() -> Resource:
	return document


func set_document_path(path: String, reason: String = "") -> void:
	document_path = path
	last_reason = reason
	changed.emit("document_path")


func set_import_map_path(path: String, reason: String = "") -> void:
	import_map_path = path
	last_reason = reason
	changed.emit("import_map_path")


func set_export_path(path: String, reason: String = "") -> void:
	export_path = path
	last_reason = reason
	changed.emit("export_path")


func snapshot() -> Dictionary:
	return {
		"target_layer": current_target_layer(),
		"document": document,
		"document_source": document_source,
		"document_path": document_path,
		"import_map_path": import_map_path,
		"export_path": export_path,
		"last_reason": last_reason,
	}
