@tool
class_name HexMapSampleLearningState
extends RefCounted

const STATE_OFF := "off"
const STATE_LEARNING_AVAILABLE := "learning_available"
const STATE_DUPLICATED_TO_PROJECT := "duplicated_to_project"
const STATE_SAMPLE_SOURCE_SELECTED := "sample_source_selected"

var state_id := STATE_OFF
var active_state_ids := PackedStringArray([STATE_OFF])
var show_samples := false
var learning_cta_visible := false
var last_sample_action := {}
var sample_source_selected_slots := PackedStringArray()


func update_from_context(context: Dictionary) -> void:
	show_samples = bool(context.get("show_samples", false))
	learning_cta_visible = bool(context.get("learning_cta_visible", false))
	last_sample_action = (context.get("last_sample_action", {}) as Dictionary).duplicate(true)
	sample_source_selected_slots = PackedStringArray(context.get("sample_source_selected_slots", PackedStringArray()))
	active_state_ids = _derive_active_state_ids()
	state_id = _derive_primary_state_id(active_state_ids)


func to_state_snapshot() -> Dictionary:
	return {
		"state_id": state_id,
		"state_source": "HexMapSampleLearningState",
		"active_state_ids": active_state_ids,
		"show_samples": show_samples,
		"learning_cta_visible": learning_cta_visible,
		"last_sample_action": last_sample_action.duplicate(true),
		"sample_source_selected_slots": sample_source_selected_slots,
		"view_state": to_view_state(),
	}


func to_view_state() -> Dictionary:
	return {
		"state_id": state_id,
		"state_source": "HexMapSampleLearningState",
		"active_state_ids": active_state_ids,
		"status_text": _status_text(),
		"show_samples": show_samples,
		"learning_cta_visible": learning_cta_visible,
		"last_sample_action": last_sample_action.duplicate(true),
		"sample_source_selected_slots": sample_source_selected_slots,
	}


func _derive_active_state_ids() -> PackedStringArray:
	var states := PackedStringArray()
	if show_samples or learning_cta_visible:
		states.append(STATE_LEARNING_AVAILABLE)
	if bool(last_sample_action.get("ok", false)):
		states.append(STATE_DUPLICATED_TO_PROJECT)
	if not sample_source_selected_slots.is_empty():
		states.append(STATE_SAMPLE_SOURCE_SELECTED)
	if states.is_empty():
		states.append(STATE_OFF)
	return states


func _derive_primary_state_id(states: PackedStringArray) -> String:
	for candidate in [
		STATE_SAMPLE_SOURCE_SELECTED,
		STATE_DUPLICATED_TO_PROJECT,
		STATE_LEARNING_AVAILABLE,
		STATE_OFF,
	]:
		if states.has(candidate):
			return candidate
	return STATE_OFF


func _status_text() -> String:
	match state_id:
		STATE_SAMPLE_SOURCE_SELECTED:
			return "Bundled sample source selected explicitly."
		STATE_DUPLICATED_TO_PROJECT:
			return "Bundled sample duplicated to project."
		STATE_LEARNING_AVAILABLE:
			return "Sample learning is available."
	return "Sample learning is off."
