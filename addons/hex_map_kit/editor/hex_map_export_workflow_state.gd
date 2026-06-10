@tool
class_name HexMapExportWorkflowState
extends RefCounted

const STATE_NO_DESTINATION := "no_destination"
const STATE_READY := "ready"
const STATE_EXPORTING := "exporting"
const STATE_EXPORTED := "exported"
const STATE_FAILED := "failed"

var state_id := STATE_NO_DESTINATION
var active_state_ids := PackedStringArray([STATE_NO_DESTINATION])
var destination := {}
var output_type := {}
var last_result := {}
var can_export := false
var exporting := false
var block_reason := ""


func update_from_context(context: Dictionary) -> void:
	destination = (context.get("destination", {}) as Dictionary).duplicate(true)
	output_type = (context.get("output_type", {}) as Dictionary).duplicate(true)
	last_result = (context.get("last_result", {}) as Dictionary).duplicate(true)
	can_export = bool(context.get("can_export", false))
	exporting = bool(context.get("exporting", false))
	block_reason = String(context.get("block_reason", ""))
	active_state_ids = _derive_active_state_ids()
	state_id = _derive_primary_state_id(active_state_ids)


func to_state_snapshot() -> Dictionary:
	return {
		"state_id": state_id,
		"state_source": "HexMapExportWorkflowState",
		"active_state_ids": active_state_ids,
		"destination": destination.duplicate(true),
		"output_type": output_type.duplicate(true),
		"last_result": last_result.duplicate(true),
		"can_export": can_export,
		"exporting": exporting,
		"block_reason": block_reason,
		"view_state": to_view_state(),
	}


func to_view_state() -> Dictionary:
	return {
		"state_id": state_id,
		"state_source": "HexMapExportWorkflowState",
		"active_state_ids": active_state_ids,
		"can_export": can_export,
		"exporting": exporting,
		"run_button_disabled": not can_export or exporting,
		"run_button_tooltip": block_reason if block_reason != "" else "Create a Runtime Handoff HexMapResource at the selected destination.",
		"status_text": _status_text(),
		"destination": destination.duplicate(true),
		"output_type": output_type.duplicate(true),
		"last_result": last_result.duplicate(true),
		"block_reason": block_reason,
	}


func _derive_active_state_ids() -> PackedStringArray:
	var states := PackedStringArray()
	if exporting:
		states.append(STATE_EXPORTING)
		return states
	if _last_result_matches_destination():
		if bool(last_result.get("ok", false)):
			states.append(STATE_EXPORTED)
		else:
			states.append(STATE_FAILED)
	if not bool(destination.get("selected", false)):
		states.append(STATE_NO_DESTINATION)
	elif can_export:
		states.append(STATE_READY)
	elif states.is_empty():
		states.append(STATE_FAILED)
	return states


func _derive_primary_state_id(states: PackedStringArray) -> String:
	for candidate in [
		STATE_EXPORTING,
		STATE_EXPORTED,
		STATE_FAILED,
		STATE_NO_DESTINATION,
		STATE_READY,
	]:
		if states.has(candidate):
			return candidate
	return STATE_NO_DESTINATION


func _last_result_matches_destination() -> bool:
	if not last_result.has("ok"):
		return false
	var result_path := String(last_result.get("path", ""))
	var destination_path := String(destination.get("path", ""))
	return result_path != "" and result_path == destination_path


func _status_text() -> String:
	match state_id:
		STATE_EXPORTING:
			return "Exporting Runtime Handoff."
		STATE_EXPORTED:
			return "Exported Runtime Handoff."
		STATE_FAILED:
			return "Export failed." if block_reason == "" else block_reason
		STATE_READY:
			return "Ready to export Runtime Handoff."
	return "Choose Runtime Handoff destination."
