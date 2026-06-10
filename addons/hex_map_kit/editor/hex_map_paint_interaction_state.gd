@tool
class_name HexMapPaintInteractionState
extends RefCounted

const STATE_NO_TARGET := "no_target"
const STATE_TARGET_BLOCKED := "target_blocked"
const STATE_NO_DOCUMENT := "no_document"
const STATE_MISSING_ASSET := "missing_asset"
const STATE_READY := "ready"
const STATE_HOVERING_CELL := "hovering_cell"
const STATE_SELECTED_CELL := "selected_cell"
const STATE_APPLIED_DIRTY := "applied_dirty"
const STATE_VALIDATION_FOCUS := "validation_focus"

var state_id := STATE_NO_TARGET
var active_state_ids := PackedStringArray()
var target := {}
var document := {}
var brush := {}
var hovered_cell := {}
var selected_cell := {}
var last_apply := {}
var validation_focus := {}
var missing_asset := {}


func update_from_context(context: Dictionary) -> void:
	target = (context.get("target", {}) as Dictionary).duplicate(true)
	document = (context.get("document", {}) as Dictionary).duplicate(true)
	brush = (context.get("brush", {}) as Dictionary).duplicate(true)
	hovered_cell = (context.get("hovered_cell", {}) as Dictionary).duplicate(true)
	selected_cell = (context.get("selected_cell", {}) as Dictionary).duplicate(true)
	last_apply = (context.get("last_apply", {}) as Dictionary).duplicate(true)
	validation_focus = (context.get("validation_focus", {}) as Dictionary).duplicate(true)
	missing_asset = (context.get("missing_asset", {}) as Dictionary).duplicate(true)
	active_state_ids = _derive_active_state_ids()
	state_id = _derive_primary_state_id(active_state_ids)


func to_state_snapshot() -> Dictionary:
	return {
		"state_id": state_id,
		"state_source": "HexMapPaintInteractionState",
		"active_state_ids": active_state_ids,
		"target": target.duplicate(true),
		"document": document.duplicate(true),
		"brush": brush.duplicate(true),
		"hovered_cell": hovered_cell.duplicate(true),
		"selected_cell": selected_cell.duplicate(true),
		"last_apply": last_apply.duplicate(true),
		"validation_focus": validation_focus.duplicate(true),
		"missing_asset": missing_asset.duplicate(true),
		"view_state": to_view_state(),
	}


func to_view_state() -> Dictionary:
	return {
		"state_id": state_id,
		"state_source": "HexMapPaintInteractionState",
		"active_state_ids": active_state_ids,
		"can_paint": _can_paint(),
		"blocked": not _can_paint(),
		"status_text": _status_text(),
		"target": target.duplicate(true),
		"target_ready": bool(target.get("ready", false)),
		"active_layer": target.get("node", null),
		"active_layer_name": String(target.get("name", "")),
		"active_layer_path": String(target.get("path", "")),
		"active_layer_class": String(target.get("class", "")),
		"active_layer_role": String(target.get("role", "")),
		"target_message": String(target.get("message", "")),
		"document": document.duplicate(true),
		"document_present": bool(document.get("present", false)),
		"document_resource": document.get("resource", null),
		"document_status": String(document.get("status", "none")),
		"document_path": String(document.get("path", "")),
		"document_dirty": bool(document.get("dirty", false)),
		"brush": brush.duplicate(true),
		"brush_ready": bool(brush.get("ready", false)),
		"brush_mode": String(brush.get("mode", "")),
		"brush_mode_label": String(brush.get("mode_label", "")),
		"brush_key": String(brush.get("brush_key", "")),
		"hovered_cell": hovered_cell.duplicate(true),
		"hovered_cell_key": String(hovered_cell.get("cell_key", "")),
		"selected_cell": selected_cell.duplicate(true),
		"selected_cell_key": String(selected_cell.get("cell_key", "")),
		"last_apply": last_apply.duplicate(true),
		"last_apply_summary": String(last_apply.get("summary", "none")),
		"last_apply_message": String(last_apply.get("message", "none")),
		"validation_focus": validation_focus.duplicate(true),
		"missing_asset": missing_asset.duplicate(true),
	}


func _derive_active_state_ids() -> PackedStringArray:
	var states := PackedStringArray()
	var target_present := bool(target.get("present", false))
	var target_ready := bool(target.get("ready", false))
	var document_present := bool(document.get("present", false))
	var brush_ready := bool(brush.get("ready", false))
	if not target_present:
		states.append(STATE_NO_TARGET)
	elif not target_ready:
		states.append(STATE_TARGET_BLOCKED)
	if not document_present:
		states.append(STATE_NO_DOCUMENT)
	if not missing_asset.is_empty() or not brush_ready:
		states.append(STATE_MISSING_ASSET)
	if target_present and target_ready and document_present and brush_ready:
		states.append(STATE_READY)
	if bool(hovered_cell.get("present", false)):
		states.append(STATE_HOVERING_CELL)
	if bool(selected_cell.get("present", false)):
		states.append(STATE_SELECTED_CELL)
	if _has_apply_or_dirty_state():
		states.append(STATE_APPLIED_DIRTY)
	if bool(validation_focus.get("focused", false)):
		states.append(STATE_VALIDATION_FOCUS)
	return states


func _derive_primary_state_id(states: PackedStringArray) -> String:
	for candidate in [
		STATE_NO_TARGET,
		STATE_NO_DOCUMENT,
		STATE_TARGET_BLOCKED,
		STATE_MISSING_ASSET,
		STATE_VALIDATION_FOCUS,
		STATE_APPLIED_DIRTY,
		STATE_SELECTED_CELL,
		STATE_HOVERING_CELL,
		STATE_READY,
	]:
		if states.has(candidate):
			return candidate
	return STATE_READY


func _can_paint() -> bool:
	return bool(target.get("ready", false)) \
		and bool(document.get("present", false)) \
		and bool(brush.get("ready", false))


func _has_apply_or_dirty_state() -> bool:
	return bool(document.get("dirty", false)) \
		or bool(last_apply.get("present", false)) \
		or bool(last_apply.get("applied", false)) \
		or bool(last_apply.get("document_changed", false)) \
		or bool(last_apply.get("target_applied", false)) \
		or bool(last_apply.get("display_changed", false))


func _status_text() -> String:
	if active_state_ids.has(STATE_NO_TARGET):
		return "No editable target layer."
	if active_state_ids.has(STATE_NO_DOCUMENT):
		return "No document selected."
	if active_state_ids.has(STATE_TARGET_BLOCKED):
		return String(target.get("message", "Target is not ready."))
	if active_state_ids.has(STATE_MISSING_ASSET):
		return _missing_asset_status_text()
	if active_state_ids.has(STATE_VALIDATION_FOCUS):
		return "Validation focus: %s" % String(validation_focus.get("focus_target", "issue"))
	if active_state_ids.has(STATE_APPLIED_DIRTY):
		return String(last_apply.get("summary", "Paint edit applied."))
	if active_state_ids.has(STATE_SELECTED_CELL):
		return "Selected %s." % String(selected_cell.get("cell_key", "cell"))
	if active_state_ids.has(STATE_HOVERING_CELL):
		return "Hovering %s." % String(hovered_cell.get("cell_key", "cell"))
	return "Ready to paint."


func _missing_asset_status_text() -> String:
	var reason := String(missing_asset.get("reason", "missing_asset"))
	match reason:
		"missing_tile_catalog":
			return "Choose a Tile Catalog before painting."
		"missing_catalog_key":
			return "Choose a catalog brush key before painting."
		"missing_object_database":
			return "Choose an Object Database before painting objects."
		"missing_object_definition":
			return "Choose an object definition before painting objects."
		"missing_label_database":
			return "Choose a Label Database before painting labels."
		"missing_label_definition":
			return "Choose a label definition before painting labels."
	return "Choose the missing Paint asset before painting."
