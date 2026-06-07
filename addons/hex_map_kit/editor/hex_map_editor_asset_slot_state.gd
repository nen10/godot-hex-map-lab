@tool
class_name HexMapEditorAssetSlotState
extends RefCounted

signal changed

const STATUS_NOT_SELECTED := "not_selected"
const STATUS_SELECTED := "selected"
const STATUS_INVALID := "invalid"
const STATUS_WARNING := "warning"

const SOURCE_NONE := "none"
const SOURCE_PROJECT := "project"
const SOURCE_SAMPLE := "sample"

var slot_id := ""
var display_name := ""
var required_type: StringName = &""
var current_resource: Resource = null
var current_path := ""
var current_source := SOURCE_NONE
var is_required := true
var validation_status := STATUS_NOT_SELECTED
var validation_messages: Array[String] = []
var allows_create_new := false
var allows_sample := false
var sample_resource: Resource = null
var sample_path := ""
var sample_label := ""


func configure(
	p_slot_id: String,
	p_display_name: String,
	p_required_type: StringName = &"",
	p_is_required: bool = true
) -> HexMapEditorAssetSlotState:
	slot_id = p_slot_id
	display_name = p_display_name
	required_type = p_required_type
	is_required = p_is_required
	_recompute_status()
	changed.emit()
	return self


func set_selected_resource(resource: Resource, path: String = "", source: String = SOURCE_PROJECT) -> void:
	current_resource = resource
	current_path = path
	if current_path == "" and current_resource != null:
		current_path = current_resource.resource_path
	current_source = source if current_resource != null or current_path != "" else SOURCE_NONE
	_recompute_status()
	changed.emit()


func clear_selection() -> void:
	current_resource = null
	current_path = ""
	current_source = SOURCE_NONE
	_recompute_status()
	changed.emit()


func set_validation(status: String, messages: Array = []) -> void:
	validation_status = _normalized_status(status)
	validation_messages = _string_messages(messages)
	if validation_status == STATUS_SELECTED and not has_current_selection():
		_recompute_status()
	changed.emit()


func mark_warning(messages: Array = []) -> void:
	set_validation(STATUS_WARNING, messages)


func mark_invalid(messages: Array = []) -> void:
	set_validation(STATUS_INVALID, messages)


func set_sample_source(resource: Resource, path: String = "", label: String = "Learn with sample") -> void:
	sample_resource = resource
	sample_path = path
	if sample_path == "" and sample_resource != null:
		sample_path = sample_resource.resource_path
	sample_label = label
	allows_sample = has_sample_source()
	changed.emit()


func clear_sample_source() -> void:
	sample_resource = null
	sample_path = ""
	sample_label = ""
	allows_sample = false
	changed.emit()


func apply_sample_source() -> bool:
	if not has_sample_source():
		return false
	set_selected_resource(sample_resource, sample_path, SOURCE_SAMPLE)
	return true


func has_current_selection() -> bool:
	return current_resource != null or current_path != ""


func has_sample_source() -> bool:
	return sample_resource != null or sample_path != ""


func type_matches() -> bool:
	if current_resource == null:
		return true
	return _resource_matches_required_type(current_resource)


func status_label() -> String:
	match validation_status:
		STATUS_SELECTED:
			return "Selected"
		STATUS_INVALID:
			return "Invalid"
		STATUS_WARNING:
			return "Warning"
		_:
			return "Not selected"


func current_display_text() -> String:
	if current_path != "":
		return current_path
	if current_resource != null:
		var path = current_resource.resource_path
		return path if path != "" else "(embedded)"
	return "Not selected"


func sample_display_text() -> String:
	if not has_sample_source():
		return ""
	if sample_label != "":
		return sample_label
	if sample_path != "":
		return sample_path
	return "(embedded sample)"


func snapshot() -> Dictionary:
	return {
		"slot_id": slot_id,
		"display_name": display_name,
		"required_type": String(required_type),
		"current_resource": current_resource,
		"current_path": current_path,
		"current_source": current_source,
		"is_required": is_required,
		"status": validation_status,
		"status_label": status_label(),
		"validation_messages": validation_messages.duplicate(),
		"allows_create_new": allows_create_new,
		"allows_sample": allows_sample,
		"sample_resource": sample_resource,
		"sample_path": sample_path,
		"sample_label": sample_label,
		"sample_available": has_sample_source(),
		"type_matches": type_matches(),
		"selected": has_current_selection(),
		"current_display": current_display_text(),
		"sample_display": sample_display_text(),
	}


func _recompute_status() -> void:
	validation_messages.clear()
	if not has_current_selection():
		validation_status = STATUS_NOT_SELECTED
		if is_required:
			validation_messages.append("%s is required." % _display_name_or_slot_id())
		return
	if not type_matches():
		validation_status = STATUS_INVALID
		validation_messages.append(
			"Expected %s, got %s." % [
				String(required_type),
				_resource_type_label(current_resource),
			]
		)
		return
	validation_status = STATUS_SELECTED


func _resource_matches_required_type(resource: Resource) -> bool:
	if resource == null or String(required_type) == "":
		return true
	var type_name := String(required_type)
	if type_name == "Resource":
		return true
	if resource.is_class(type_name):
		return true
	var script = resource.get_script()
	if script != null and script.has_method("get_global_name"):
		var global_name = String(script.call("get_global_name"))
		if global_name == type_name:
			return true
	return false


func _resource_type_label(resource: Resource) -> String:
	if resource == null:
		return "none"
	var script = resource.get_script()
	if script != null and script.has_method("get_global_name"):
		var global_name = String(script.call("get_global_name"))
		if global_name != "":
			return global_name
	return resource.get_class()


func _display_name_or_slot_id() -> String:
	return display_name if display_name != "" else slot_id


func _normalized_status(status: String) -> String:
	match status:
		STATUS_SELECTED, STATUS_INVALID, STATUS_WARNING, STATUS_NOT_SELECTED:
			return status
		_:
			return STATUS_INVALID


func _string_messages(messages: Array) -> Array[String]:
	var result: Array[String] = []
	for message in messages:
		var text := String(message)
		if text != "":
			result.append(text)
	return result
