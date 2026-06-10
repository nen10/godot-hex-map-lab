@tool
class_name HexMapDialogLifecycleState
extends RefCounted

const STATE_CLOSED := "closed"
const STATE_OPENING := "opening"
const STATE_WAITING_USER := "waiting_user"
const STATE_COMMITTED := "committed"
const STATE_CANCELLED := "cancelled"

var state_id := STATE_CLOSED
var active_state_ids := PackedStringArray([STATE_CLOSED])
var valid := false
var has_parent := false
var inside_tree := false
var opening := false
var committed := false
var cancelled := false
var result := {}


func update_from_context(context: Dictionary) -> void:
	valid = bool(context.get("valid", false))
	has_parent = bool(context.get("has_parent", false))
	inside_tree = bool(context.get("inside_tree", false))
	opening = bool(context.get("opening", false))
	committed = bool(context.get("committed", false))
	cancelled = bool(context.get("cancelled", false))
	result = (context.get("result", {}) as Dictionary).duplicate(true)
	active_state_ids = _derive_active_state_ids()
	state_id = _derive_primary_state_id(active_state_ids)


func to_state_snapshot() -> Dictionary:
	return {
		"state_id": state_id,
		"state_source": "HexMapDialogLifecycleState",
		"active_state_ids": active_state_ids,
		"valid": valid,
		"has_parent": has_parent,
		"inside_tree": inside_tree,
		"opening": opening,
		"committed": committed,
		"cancelled": cancelled,
		"result": result.duplicate(true),
		"view_state": to_view_state(),
	}


func to_view_state() -> Dictionary:
	return {
		"state_id": state_id,
		"state_source": "HexMapDialogLifecycleState",
		"active_state_ids": active_state_ids,
		"status_text": _status_text(),
		"waiting_user": state_id == STATE_WAITING_USER,
		"closed": state_id == STATE_CLOSED,
		"committed": committed,
		"cancelled": cancelled,
		"result": result.duplicate(true),
	}


func _derive_active_state_ids() -> PackedStringArray:
	var states := PackedStringArray()
	if committed:
		states.append(STATE_COMMITTED)
	elif cancelled:
		states.append(STATE_CANCELLED)
	elif inside_tree:
		states.append(STATE_WAITING_USER)
	elif opening:
		states.append(STATE_OPENING)
	else:
		states.append(STATE_CLOSED)
	return states


func _derive_primary_state_id(states: PackedStringArray) -> String:
	for candidate in [
		STATE_COMMITTED,
		STATE_CANCELLED,
		STATE_WAITING_USER,
		STATE_OPENING,
		STATE_CLOSED,
	]:
		if states.has(candidate):
			return candidate
	return STATE_CLOSED


func _status_text() -> String:
	match state_id:
		STATE_OPENING:
			return "Dialog opening."
		STATE_WAITING_USER:
			return "Waiting for dialog selection."
		STATE_COMMITTED:
			return "Dialog committed."
		STATE_CANCELLED:
			return "Dialog cancelled."
	return "Dialog closed."
