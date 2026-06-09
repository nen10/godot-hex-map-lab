@tool
class_name HexMapEditorAssetSlotState
extends RefCounted

signal changed

const STATUS_NOT_SELECTED := "not_selected"
const STATUS_SELECTED := "selected"
const STATUS_INVALID := "invalid"
const STATUS_WARNING := "warning"
const STATUS_KIND_OK := "ok"
const STATUS_KIND_MISSING := "missing"
const STATUS_KIND_OPTIONAL := "optional"
const STATUS_KIND_WARNING := "warning"
const STATUS_KIND_ERROR := "error"

const SOURCE_NONE := "none"
const SOURCE_PROJECT := "project"
const SOURCE_SAMPLE := "sample"
const SOURCE_DOCUMENT_DEPENDENCY := "document_dependency"
const BUNDLED_SAMPLE_PATH_PREFIX := "res://addons/hex_map_kit/assets/"
const SOURCE_BADGE_NONE := "Missing"
const SOURCE_BADGE_PROJECT := "Project"
const SOURCE_BADGE_SAMPLE := "Sample Learning"
const SOURCE_BADGE_DOCUMENT_DEPENDENCY := "Document Dependency"

var slot_id := ""
var display_name := ""
var required_type: StringName = &""
var purpose := ""
var type_filter_reason := ""
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
var _last_operation_result: Dictionary = {}


func configure(
	p_slot_id: String,
	p_display_name: String,
	p_required_type: StringName = &"",
	p_is_required: bool = true,
	p_purpose: String = "",
	p_type_filter_reason: String = ""
) -> HexMapEditorAssetSlotState:
	slot_id = p_slot_id
	display_name = p_display_name
	required_type = p_required_type
	is_required = p_is_required
	purpose = p_purpose
	type_filter_reason = p_type_filter_reason
	_recompute_status()
	changed.emit()
	return self


func set_usage_metadata(p_purpose: String = "", p_type_filter_reason: String = "") -> void:
	purpose = p_purpose
	type_filter_reason = p_type_filter_reason
	changed.emit()


func set_selected_resource(resource: Resource, path: String = "", source: String = SOURCE_PROJECT) -> void:
	current_resource = resource
	current_path = path
	if current_path == "" and current_resource != null:
		current_path = current_resource.resource_path
	var actual_source := _classified_source(current_resource, current_path, source)
	current_source = actual_source if current_resource != null or current_path != "" else SOURCE_NONE
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
		record_operation_result(
			"apply_sample",
			false,
			ERR_UNAVAILABLE,
			"No sample source is available."
		)
		return false
	set_selected_resource(sample_resource, sample_path, SOURCE_SAMPLE)
	record_operation_result(
		"apply_sample",
		true,
		OK,
		"Sample source selected.",
		sample_path
	)
	return true


func record_operation_result(
	action_id: String,
	ok: bool,
	error: int = OK,
	message: String = "",
	path: String = ""
) -> void:
	_last_operation_result = {
		"action_id": action_id,
		"ok": ok,
		"error": error,
		"message": message,
		"path": path,
	}
	changed.emit()


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


func config_snapshot() -> Dictionary:
	return {
		"slot_id": slot_id,
		"display_name": display_name,
		"required_type": String(required_type),
		"expected_type": expected_type_name(),
		"picker_base_type": picker_base_type(),
		"uses_generic_resource_filter": uses_generic_resource_filter(),
		"generic_resource_filter_allowed": generic_resource_filter_allowed(),
		"type_filter_reason": type_filter_reason,
		"purpose": purpose,
		"is_required": is_required,
		"allows_create_new": allows_create_new,
		"allows_sample": allows_sample,
	}


func runtime_snapshot() -> Dictionary:
	return {
		"current_resource": current_resource,
		"current_path": current_path,
		"current_source": current_source,
		"current_source_badge": current_source_badge(),
		"selected": has_current_selection(),
		"current_display": current_display_text(),
	}


func validation_snapshot() -> Dictionary:
	return {
		"status": validation_status,
		"status_label": status_label(),
		"status_kind": status_kind(),
		"messages": validation_messages.duplicate(),
		"type_matches": type_matches(),
		"selected": has_current_selection(),
		"required": is_required,
	}


func sample_snapshot() -> Dictionary:
	return {
		"available": has_sample_source(),
		"allowed": allows_sample,
		"resource": sample_resource,
		"path": sample_path,
		"label": sample_label,
		"display": sample_display_text(),
	}


func operation_snapshot() -> Dictionary:
	if _last_operation_result.is_empty():
		return {
			"present": false,
			"action_id": "",
			"ok": false,
			"error": OK,
			"message": "",
			"path": "",
		}
	var result := _last_operation_result.duplicate(true)
	result["present"] = true
	return result


func view_state() -> Dictionary:
	var detail_text := detail_tooltip_text()
	var status_kind_value := status_kind()
	var create_visible := allows_create_new
	var sample_visible := allows_sample and has_sample_source()
	var actions := {
		"create_new": {
			"visible": create_visible,
			"enabled": create_visible,
			"text": "Create New...",
			"tooltip": "Create a project %s resource." % expected_type_name(),
		},
		"apply_sample": {
			"visible": sample_visible,
			"enabled": sample_visible,
			"text": sample_display_text() if sample_visible else "Learn With Sample",
			"tooltip": "Use this bundled sample as a learning source.",
		},
	}
	return {
		"state_source": "HexMapEditorAssetSlotState",
		"slot_id": slot_id,
		"title_text": display_name,
		"title_tooltip": detail_text,
		"status_kind": status_kind_value,
		"status_icon": status_icon(status_kind_value),
		"status_text": status_text(status_kind_value),
		"status_tooltip": detail_text,
		"current_detail_text": "Current: %s" % current_display_text(),
		"type_detail_text": "Type: %s" % expected_type_name(),
		"message_detail_text": "\n".join(validation_messages),
		"resource_picker_base_type": picker_base_type(),
		"resource_picker_tooltip": detail_text,
		"actions": actions,
		"actions_visible": create_visible or sample_visible,
		"selected": has_current_selection(),
		"sample_available": has_sample_source(),
		"operation": operation_snapshot(),
	}


func snapshot() -> Dictionary:
	var config := config_snapshot()
	var runtime := runtime_snapshot()
	var validation := validation_snapshot()
	var sample := sample_snapshot()
	var operation := operation_snapshot()
	var view := view_state()
	return {
		"slot_id": slot_id,
		"display_name": display_name,
		"required_type": String(required_type),
		"expected_type": expected_type_name(),
		"picker_base_type": picker_base_type(),
		"uses_generic_resource_filter": uses_generic_resource_filter(),
		"generic_resource_filter_allowed": generic_resource_filter_allowed(),
		"type_filter_reason": type_filter_reason,
		"purpose": purpose,
		"current_resource": current_resource,
		"current_path": current_path,
		"current_source": current_source,
		"current_source_badge": current_source_badge(),
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
		"config": config,
		"runtime": runtime,
		"validation": validation,
		"sample": sample,
		"operation": operation,
		"view_state": view,
	}


func expected_type_name() -> String:
	var text := String(required_type)
	return text if text != "" else "Resource"


func current_source_badge() -> String:
	match current_source:
		SOURCE_PROJECT:
			return SOURCE_BADGE_PROJECT
		SOURCE_SAMPLE:
			return SOURCE_BADGE_SAMPLE
		SOURCE_DOCUMENT_DEPENDENCY:
			return SOURCE_BADGE_DOCUMENT_DEPENDENCY
	return SOURCE_BADGE_NONE


func status_kind() -> String:
	match validation_status:
		STATUS_SELECTED:
			return STATUS_KIND_OK
		STATUS_INVALID:
			return STATUS_KIND_ERROR
		STATUS_WARNING:
			return STATUS_KIND_WARNING
		_:
			return STATUS_KIND_MISSING if is_required else STATUS_KIND_OPTIONAL


func status_text(kind: String = "") -> String:
	var actual_kind := kind if kind != "" else status_kind()
	match actual_kind:
		STATUS_KIND_OK:
			return "OK"
		STATUS_KIND_ERROR:
			return "Invalid"
		STATUS_KIND_WARNING:
			return "Warn"
		STATUS_KIND_OPTIONAL:
			return "Optional"
		_:
			return "Missing"


func status_icon(kind: String = "") -> String:
	var actual_kind := kind if kind != "" else status_kind()
	match actual_kind:
		STATUS_KIND_OK:
			return "check"
		STATUS_KIND_ERROR:
			return "alert"
		STATUS_KIND_WARNING:
			return "warning"
		STATUS_KIND_OPTIONAL:
			return "optional"
		_:
			return "missing"


func detail_tooltip_text() -> String:
	var lines: Array[String] = [
		"Pick: %s" % expected_type_name(),
		"Current: %s" % current_display_text(),
		"Type: %s" % expected_type_name(),
		"Status: %s" % status_label(),
		"Source: %s" % current_source_badge(),
	]
	if purpose != "":
		lines.append("Purpose: %s" % purpose)
	if type_filter_reason != "":
		lines.append("Filter: %s" % type_filter_reason)
	for message in validation_messages:
		var text := String(message)
		if text != "":
			lines.append(text)
	return "\n".join(lines)


func picker_base_type() -> String:
	return expected_type_name()


func uses_generic_resource_filter() -> bool:
	return picker_base_type() == "Resource"


func generic_resource_filter_allowed() -> bool:
	return uses_generic_resource_filter() and type_filter_reason.strip_edges() != ""


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
	if current_source == SOURCE_SAMPLE and _is_bundled_sample_path(current_path):
		validation_status = STATUS_WARNING
		validation_messages.append(
			"%s is a bundled sample. Duplicate it to a project asset before production use." % _display_name_or_slot_id()
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


func _classified_source(resource: Resource, path: String, source: String) -> String:
	if resource == null and path == "":
		return SOURCE_NONE
	if _is_bundled_sample_path(path):
		return SOURCE_SAMPLE
	return source


func _is_bundled_sample_path(path: String) -> bool:
	return path.begins_with(BUNDLED_SAMPLE_PATH_PREFIX)


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
