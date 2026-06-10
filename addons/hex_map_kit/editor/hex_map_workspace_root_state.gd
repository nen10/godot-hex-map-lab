@tool
class_name HexMapWorkspaceRootState
extends RefCounted

const STATE_EMPTY := "empty"
const STATE_READY := "ready"
const STATE_SCREEN_BLOCKED := "screen_blocked"
const STATE_SCREEN_BUSY := "screen_busy"

var state_id := STATE_EMPTY
var active_state_ids := PackedStringArray([STATE_EMPTY])
var current_tab := ""
var tab_names := PackedStringArray()
var screen_snapshots := {}
var screen_view_states := {}
var screen_state_ids := {}


func update_from_context(context: Dictionary) -> void:
	current_tab = String(context.get("current_tab", ""))
	tab_names = _packed_string_array_from_value(context.get("tab_names", PackedStringArray()))
	screen_snapshots = _duplicate_dictionary(context.get("screen_snapshots", {}))
	screen_view_states = _derive_screen_view_states(screen_snapshots)
	screen_state_ids = _derive_screen_state_ids(screen_view_states)
	active_state_ids = _derive_active_state_ids()
	state_id = _derive_primary_state_id(active_state_ids)


func to_state_snapshot() -> Dictionary:
	return {
		"state_id": state_id,
		"state_source": "HexMapWorkspaceRootState",
		"active_state_ids": active_state_ids,
		"current_tab": current_tab,
		"tab_names": tab_names,
		"screen_snapshots": _duplicate_dictionary(screen_snapshots),
		"screen_view_states": _duplicate_dictionary(screen_view_states),
		"screen_state_ids": _duplicate_dictionary(screen_state_ids),
		"current_view_state": _current_screen_view_state(),
		"view_state": to_view_state(),
	}


func to_view_state() -> Dictionary:
	var current_view := _current_screen_view_state()
	return {
		"state_id": state_id,
		"state_source": "HexMapWorkspaceRootState",
		"active_state_ids": active_state_ids,
		"current_tab": current_tab,
		"tab_names": tab_names,
		"current_screen_state_id": String(current_view.get("state_id", "")),
		"current_screen_state_source": String(current_view.get("state_source", "")),
		"current_status_text": String(current_view.get("status_text", "")),
		"screen_state_ids": _duplicate_dictionary(screen_state_ids),
		"screen_view_states": _duplicate_dictionary(screen_view_states),
		"current_view_state": current_view,
		"debug_report_available": true,
	}


func debug_report_text(snapshot: Dictionary = {}) -> String:
	var state := snapshot if not snapshot.is_empty() else to_state_snapshot()
	var tabs := _packed_string_array_from_value(state.get("tab_names", PackedStringArray()))
	var ids := _dictionary_value(state.get("screen_state_ids", {}))
	var current_view := _dictionary_value(state.get("current_view_state", {}))
	var lines := PackedStringArray()
	lines.append("Hex Map Workspace State Debug Report")
	lines.append("state_source: %s" % String(state.get("state_source", "")))
	lines.append("state_id: %s" % String(state.get("state_id", "")))
	lines.append("current_tab: %s" % String(state.get("current_tab", "")))
	lines.append("tabs: %s" % ", ".join(tabs))
	lines.append("screen_state_ids:")
	for tab_name in tabs:
		lines.append("- %s: %s" % [tab_name, String(ids.get(tab_name, ""))])
	lines.append("current_view_state:")
	lines.append("- state_source: %s" % String(current_view.get("state_source", "")))
	lines.append("- state_id: %s" % String(current_view.get("state_id", "")))
	lines.append("- status_text: %s" % String(current_view.get("status_text", "")))
	return "\n".join(lines)


func _derive_screen_view_states(screens: Dictionary) -> Dictionary:
	var result := {}
	for tab_name in tab_names:
		var screen = screens.get(tab_name, {})
		result[tab_name] = _screen_view_state(tab_name, screen if screen is Dictionary else {})
	for key in screens.keys():
		var tab_name := String(key)
		if tab_name == "" or result.has(tab_name):
			continue
		var screen = screens.get(key, {})
		result[tab_name] = _screen_view_state(tab_name, screen if screen is Dictionary else {})
	return result


func _screen_view_state(tab_name: String, screen: Dictionary) -> Dictionary:
	var direct := _direct_view_state(screen)
	var result := direct.duplicate(true)
	var empty_state := _dictionary_value(screen.get("empty_state", {}))
	var empty_text := String(screen.get("empty_state_text", empty_state.get("empty_state_text", "")))
	var purpose_text := String(screen.get("purpose_text", empty_state.get("purpose_text", "")))
	if result.is_empty():
		var synthesized_state := STATE_EMPTY if empty_text != "" else STATE_READY
		result = {
			"state_id": synthesized_state,
			"state_source": "HexMapWorkspaceRootState",
			"active_state_ids": PackedStringArray([synthesized_state]),
			"status_text": empty_text if empty_text != "" else purpose_text,
		}
	if not result.has("state_id"):
		result["state_id"] = STATE_READY
	if not result.has("state_source"):
		result["state_source"] = "HexMapWorkspaceRootState"
	if not result.has("active_state_ids"):
		result["active_state_ids"] = PackedStringArray([String(result.get("state_id", STATE_READY))])
	if not result.has("status_text"):
		result["status_text"] = empty_text if empty_text != "" else purpose_text
	result["tab"] = tab_name
	result["purpose_text"] = purpose_text
	result["empty_state_text"] = empty_text
	result["component_ids"] = _packed_string_array_from_value(screen.get("component_ids", PackedStringArray()))
	result["asset_slot_ids"] = _packed_string_array_from_value(screen.get("asset_slot_ids", PackedStringArray()))
	return result


func _direct_view_state(screen: Dictionary) -> Dictionary:
	var view = screen.get("view_state", {})
	if view is Dictionary and not (view as Dictionary).is_empty():
		return (view as Dictionary).duplicate(true)
	view = screen.get("sample_view_state", {})
	if view is Dictionary and not (view as Dictionary).is_empty():
		return (view as Dictionary).duplicate(true)
	for state_key in ["validation_state", "export_state", "sample_state", "interaction_state", "generation_state"]:
		var state = screen.get(state_key, {})
		if state is Dictionary:
			var nested = (state as Dictionary).get("view_state", {})
			if nested is Dictionary and not (nested as Dictionary).is_empty():
				return (nested as Dictionary).duplicate(true)
	return {}


func _derive_screen_state_ids(view_states: Dictionary) -> Dictionary:
	var result := {}
	for key in view_states.keys():
		var view = view_states[key]
		result[String(key)] = String((view as Dictionary).get("state_id", "")) if view is Dictionary else ""
	return result


func _current_screen_view_state() -> Dictionary:
	var view = screen_view_states.get(current_tab, {})
	if view is Dictionary:
		return (view as Dictionary).duplicate(true)
	return {}


func _derive_active_state_ids() -> PackedStringArray:
	var states := PackedStringArray()
	if tab_names.is_empty() or screen_view_states.is_empty():
		states.append(STATE_EMPTY)
		return states
	states.append(STATE_READY)
	var current_view := _current_screen_view_state()
	var current_state := String(current_view.get("state_id", ""))
	if bool(current_view.get("running", false)) \
		or bool(current_view.get("exporting", false)) \
		or current_state.ends_with("ing"):
		states.append(STATE_SCREEN_BUSY)
	if bool(current_view.get("blocked", false)) \
		or current_state.begins_with("no_") \
		or current_state.begins_with("missing") \
		or current_state == "failed" \
		or current_state == "error":
		states.append(STATE_SCREEN_BLOCKED)
	return states


func _derive_primary_state_id(states: PackedStringArray) -> String:
	for candidate in [
		STATE_EMPTY,
		STATE_SCREEN_BUSY,
		STATE_SCREEN_BLOCKED,
		STATE_READY,
	]:
		if states.has(candidate):
			return candidate
	return STATE_EMPTY


func _duplicate_dictionary(value) -> Dictionary:
	var source := _dictionary_value(value)
	var result := {}
	for key in source.keys():
		var entry = source[key]
		if entry is Dictionary:
			result[key] = (entry as Dictionary).duplicate(true)
		elif entry is Array:
			result[key] = (entry as Array).duplicate(true)
		else:
			result[key] = entry
	return result


func _dictionary_value(value) -> Dictionary:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	return {}


func _packed_string_array_from_value(value) -> PackedStringArray:
	if value is PackedStringArray:
		return value
	var result := PackedStringArray()
	if value is Array:
		for entry in value:
			result.append(String(entry))
	return result
