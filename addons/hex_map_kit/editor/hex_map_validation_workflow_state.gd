@tool
class_name HexMapValidationWorkflowState
extends RefCounted

const STATE_NOT_RUN := "not_run"
const STATE_RUNNING := "running"
const STATE_CLEAN := "clean"
const STATE_WARNING := "warning"
const STATE_ERROR := "error"
const STATE_ISSUE_SELECTED := "issue_selected"
const STATE_FOCUS_APPLIED := "focus_applied"

var state_id := STATE_NOT_RUN
var active_state_ids := PackedStringArray([STATE_NOT_RUN])
var result_present := false
var running := false
var issue_count := 0
var error_count := 0
var warning_count := 0
var selected_issue_index := -1
var selected_issue_row := {}
var selected_issue_navigation := {}
var focus_applied := false


func update_from_context(context: Dictionary) -> void:
	running = bool(context.get("running", false))
	result_present = bool(context.get("result_present", false))
	issue_count = int(context.get("issue_count", 0))
	error_count = int(context.get("error_count", 0))
	warning_count = int(context.get("warning_count", 0))
	selected_issue_index = int(context.get("selected_issue_index", -1))
	selected_issue_row = (context.get("selected_issue_row", {}) as Dictionary).duplicate(true)
	selected_issue_navigation = (context.get("selected_issue_navigation", {}) as Dictionary).duplicate(true)
	focus_applied = bool(context.get("focus_applied", false))
	active_state_ids = _derive_active_state_ids()
	state_id = _derive_primary_state_id(active_state_ids)


func to_state_snapshot() -> Dictionary:
	return {
		"state_id": state_id,
		"state_source": "HexMapValidationWorkflowState",
		"active_state_ids": active_state_ids,
		"running": running,
		"result_present": result_present,
		"issue_count": issue_count,
		"error_count": error_count,
		"warning_count": warning_count,
		"selected_issue_index": selected_issue_index,
		"selected_issue_row": selected_issue_row.duplicate(true),
		"selected_issue_navigation": selected_issue_navigation.duplicate(true),
		"focus_applied": focus_applied,
		"view_state": to_view_state(),
	}


func to_view_state() -> Dictionary:
	return {
		"state_id": state_id,
		"state_source": "HexMapValidationWorkflowState",
		"active_state_ids": active_state_ids,
		"running": running,
		"status_text": _status_text(),
		"run_button_disabled": running,
		"result_present": result_present,
		"issue_count": issue_count,
		"error_count": error_count,
		"warning_count": warning_count,
		"selected_issue_index": selected_issue_index,
		"selected_issue_row": selected_issue_row.duplicate(true),
		"selected_issue_navigation": selected_issue_navigation.duplicate(true),
		"focus_applied": focus_applied,
	}


func _derive_active_state_ids() -> PackedStringArray:
	var states := PackedStringArray()
	if running:
		states.append(STATE_RUNNING)
		return states
	if not result_present:
		states.append(STATE_NOT_RUN)
		return states
	if error_count > 0:
		states.append(STATE_ERROR)
	elif warning_count > 0:
		states.append(STATE_WARNING)
	else:
		states.append(STATE_CLEAN)
	if selected_issue_index >= 0:
		states.append(STATE_ISSUE_SELECTED)
	if focus_applied:
		states.append(STATE_FOCUS_APPLIED)
	return states


func _derive_primary_state_id(states: PackedStringArray) -> String:
	for candidate in [
		STATE_RUNNING,
		STATE_NOT_RUN,
		STATE_FOCUS_APPLIED,
		STATE_ISSUE_SELECTED,
		STATE_ERROR,
		STATE_WARNING,
		STATE_CLEAN,
	]:
		if states.has(candidate):
			return candidate
	return STATE_NOT_RUN


func _status_text() -> String:
	if state_id == STATE_RUNNING:
		return "Validation running."
	if state_id == STATE_NOT_RUN:
		return "Run validation to list workspace issues."
	if state_id == STATE_FOCUS_APPLIED:
		return "Validation issue focus applied."
	if state_id == STATE_ISSUE_SELECTED:
		return "Validation issue selected."
	if active_state_ids.has(STATE_ERROR):
		return "Validation found %d error(s)." % error_count
	if active_state_ids.has(STATE_WARNING):
		return "Validation found %d warning(s)." % warning_count
	return "Validation passed."
