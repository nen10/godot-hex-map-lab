@tool
class_name HexMapEditorSessionState
extends RefCounted

signal changed(key: String)

var target_layer: Node = null
var document: Resource = null
var document_source: String = ""
var document_saved_path: String = ""
var import_map: Resource = null
var import_map_saved_path: String = ""
var export_saved_path: String = ""
var last_reason: String = ""


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


func snapshot() -> Dictionary:
	return {
		"target_layer": current_target_layer(),
		"document": document,
		"document_source": document_source,
		"document_saved_path": document_saved_path,
		"import_map": import_map,
		"import_map_saved_path": import_map_saved_path,
		"export_saved_path": export_saved_path,
		"last_reason": last_reason,
	}
