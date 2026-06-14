@tool
class_name HexMapWorkspaceDispatcher
extends RefCounted

enum HexMapWorkspaceEvent {
	SELECT_TAB,
	RUN_VALIDATION,
	SELECT_VALIDATION_ISSUE,
	SELECT_EXPORT_DESTINATION,
	CLEAR_EXPORT_DESTINATION,
	OPEN_SAMPLE_LEARNING,
	DISMISS_SAMPLE_LEARNING,
}

const EVENT_SELECT_TAB := "select_tab"
const EVENT_RUN_VALIDATION := "run_validation"
const EVENT_SELECT_VALIDATION_ISSUE := "select_validation_issue"
const EVENT_SELECT_EXPORT_DESTINATION := "select_export_destination"
const EVENT_CLEAR_EXPORT_DESTINATION := "clear_export_destination"
const EVENT_OPEN_SAMPLE_LEARNING := "open_sample_learning"
const EVENT_DISMISS_SAMPLE_LEARNING := "dismiss_sample_learning"

const EVENT_BY_ID := {
	EVENT_SELECT_TAB: HexMapWorkspaceEvent.SELECT_TAB,
	EVENT_RUN_VALIDATION: HexMapWorkspaceEvent.RUN_VALIDATION,
	EVENT_SELECT_VALIDATION_ISSUE: HexMapWorkspaceEvent.SELECT_VALIDATION_ISSUE,
	EVENT_SELECT_EXPORT_DESTINATION: HexMapWorkspaceEvent.SELECT_EXPORT_DESTINATION,
	EVENT_CLEAR_EXPORT_DESTINATION: HexMapWorkspaceEvent.CLEAR_EXPORT_DESTINATION,
	EVENT_OPEN_SAMPLE_LEARNING: HexMapWorkspaceEvent.OPEN_SAMPLE_LEARNING,
	EVENT_DISMISS_SAMPLE_LEARNING: HexMapWorkspaceEvent.DISMISS_SAMPLE_LEARNING,
}

const EVENT_DESCRIPTORS := {
	HexMapWorkspaceEvent.SELECT_TAB: {
		"id": EVENT_SELECT_TAB,
		"ui_state_update": {
			"root_state": true,
			"view_state": true,
			"screen": true,
		},
	},
	HexMapWorkspaceEvent.RUN_VALIDATION: {
		"id": EVENT_RUN_VALIDATION,
		"ui_state_update": {
			"root_state": true,
			"view_state": true,
			"validate_screen": true,
		},
	},
	HexMapWorkspaceEvent.SELECT_VALIDATION_ISSUE: {
		"id": EVENT_SELECT_VALIDATION_ISSUE,
		"ui_state_update": {
			"root_state": true,
			"view_state": true,
			"validate_screen": true,
		},
	},
	HexMapWorkspaceEvent.SELECT_EXPORT_DESTINATION: {
		"id": EVENT_SELECT_EXPORT_DESTINATION,
		"ui_state_update": {
			"root_state": true,
			"view_state": true,
			"export_screen": true,
		},
	},
	HexMapWorkspaceEvent.CLEAR_EXPORT_DESTINATION: {
		"id": EVENT_CLEAR_EXPORT_DESTINATION,
		"ui_state_update": {
			"root_state": true,
			"view_state": true,
			"export_screen": true,
		},
	},
	HexMapWorkspaceEvent.OPEN_SAMPLE_LEARNING: {
		"id": EVENT_OPEN_SAMPLE_LEARNING,
		"ui_state_update": {
			"root_state": true,
			"view_state": true,
			"settings_screen": true,
		},
	},
	HexMapWorkspaceEvent.DISMISS_SAMPLE_LEARNING: {
		"id": EVENT_DISMISS_SAMPLE_LEARNING,
		"ui_state_update": {
			"root_state": true,
			"view_state": true,
			"settings_screen": true,
		},
	},
}


static func dispatch(workspace, event_id: String, payload: Dictionary = {}) -> Dictionary:
	var event_type := _resolve_event_type(event_id)
	if event_type == -1:
		return _event_result(
			workspace,
			false,
			ERR_INVALID_PARAMETER,
			event_id,
			payload,
			{"message": "Unknown workspace event.", "requested_event_id": event_id},
			{"event_routing": {"status": "unknown", "requested_event_id": event_id}},
			{"root_state": false, "view_state": false}
		)
	if workspace == null:
		return _event_result(
			workspace,
			false,
			ERR_UNAVAILABLE,
			event_id,
			payload,
			{"message": "Workspace is not available.", "requested_event_id": event_id},
			{"workspace_guard": {"status": "unavailable"}},
			{"root_state": false, "view_state": false}
		)
	var action: Dictionary = {}
	match event_type:
		HexMapWorkspaceEvent.SELECT_TAB:
			action = _handle_select_tab(workspace, payload)
		HexMapWorkspaceEvent.RUN_VALIDATION:
			action = _handle_run_validation(workspace, payload)
		HexMapWorkspaceEvent.SELECT_VALIDATION_ISSUE:
			action = _handle_select_validation_issue(workspace, payload)
		HexMapWorkspaceEvent.SELECT_EXPORT_DESTINATION:
			action = _handle_select_export_destination(workspace, payload)
		HexMapWorkspaceEvent.CLEAR_EXPORT_DESTINATION:
			action = _handle_clear_export_destination(workspace, payload)
		HexMapWorkspaceEvent.OPEN_SAMPLE_LEARNING:
			action = _handle_open_sample_learning(workspace, payload)
		HexMapWorkspaceEvent.DISMISS_SAMPLE_LEARNING:
			action = _handle_dismiss_sample_learning(workspace, payload)
		_:
			return _event_result(
				workspace,
				false,
				ERR_INVALID_PARAMETER,
				event_id,
				payload,
				{"message": "Unknown workspace event.", "requested_event_id": event_id},
				{"event_routing": {"status": "unknown", "requested_event_id": event_id}},
				{"root_state": false, "view_state": false}
			)
	return _event_result(
		workspace,
		bool(action.get("ok", false)),
		int(action.get("error", FAILED)),
		event_id,
		payload,
		_clone_dictionary(action.get("reducer_result", {}) as Dictionary),
		_clone_dictionary(action.get("side_effects", {}) as Dictionary),
		_clone_dictionary(_merge_ui_state_updates(
			EVENT_DESCRIPTORS.get(event_type, {})["ui_state_update"] as Dictionary,
			action.get("ui_state_update", {}) as Dictionary
		))
	)


static func _handle_select_tab(workspace, payload: Dictionary) -> Dictionary:
	var tab_name := String(payload.get("tab", payload.get("tab_name", "")))
	var previous_tab: String = workspace.current_workspace_tab_name()
	var ok: bool = workspace.select_workspace_tab(tab_name)
	var selected_tab: String = workspace.current_workspace_tab_name()
	var error: int = OK if ok else ERR_DOES_NOT_EXIST
	return {
		"ok": ok,
		"error": error,
		"reducer_result": {
			"selected_tab": selected_tab,
			"previous_tab": previous_tab,
			"requested_tab": tab_name,
		},
		"side_effects": {
			"tab_change": {
				"status": "applied" if ok else "rejected",
				"requested_tab": tab_name,
				"previous_tab": previous_tab,
				"selected_tab": selected_tab,
			},
		},
		"ui_state_update": {
			"root_state": true,
			"view_state": true,
			"selected_tab": selected_tab,
		},
	}


static func _handle_run_validation(workspace, payload: Dictionary) -> Dictionary:
	var action: Dictionary = workspace.run_validate_screen()
	var rows: Array = action.get("issue_rows", []) as Array
	var validation_state: Dictionary = action.get("validation_state", {}) as Dictionary
	var ok := bool(action.get("ok", false))
	return {
		"ok": ok,
		"error": int(action.get("error", OK if ok else FAILED)),
		"reducer_result": (action as Dictionary).duplicate(true),
		"side_effects": {
			"validation": {
				"requested": true,
				"completed": ok,
				"issue_count": rows.size(),
				"validation_state": _clone_dictionary(validation_state),
			},
		},
		"ui_state_update": {
			"validate_screen": true,
			"view_state": true,
			"root_state": true,
			"validation_screen_tab": String(workspace.current_workspace_tab_name()),
		},
	}


static func _handle_select_validation_issue(workspace, payload: Dictionary) -> Dictionary:
	var index: int = int(payload.get("index", -1))
	var action: Dictionary = workspace.select_validate_issue(index)
	var ok := bool(action.get("ok", false))
	var navigation: Dictionary = action.get("navigation", {}) as Dictionary
	var destination_tab: String = String(navigation.get("target_tab", ""))
	var has_target_tab: bool = destination_tab != ""
	return {
		"ok": ok,
		"error": int(action.get("error", OK if ok else ERR_DOES_NOT_EXIST)),
		"reducer_result": (action as Dictionary).duplicate(true),
		"side_effects": {
			"validation_issue_focus": {
				"requested_index": index,
				"focused": ok,
				"target_tab": destination_tab,
				"targeted": has_target_tab,
			},
		},
		"ui_state_update": {
			"validate_screen": true,
			"view_state": true,
			"root_state": true,
			"selected_tab": workspace.current_workspace_tab_name(),
		},
	}


static func _handle_select_export_destination(workspace, payload: Dictionary) -> Dictionary:
	var destination_path: String = String(payload.get("path", ""))
	var action: Dictionary = workspace.select_export_destination(destination_path)
	var destination: Dictionary = action.get("destination", {}) as Dictionary
	var ok: bool = bool(action.get("ok", false))
	return {
		"ok": ok,
		"error": int(action.get("error", OK if ok else ERR_INVALID_PARAMETER)),
		"reducer_result": (action as Dictionary).duplicate(true),
		"side_effects": {
			"export_destination": {
				"status": "selected" if ok else "rejected",
				"requested_path": destination_path,
				"destination_selected": bool(destination.get("selected", false)),
				"destination_path": String(destination.get("path", "")),
			},
		},
		"ui_state_update": {
			"export_screen": true,
			"view_state": true,
			"root_state": true,
			"export_path": String(action.get("path", "")),
		},
	}


static func _handle_clear_export_destination(workspace, payload: Dictionary) -> Dictionary:
	var action: Dictionary = workspace.clear_export_destination()
	var ok: bool = bool(action.get("ok", false))
	return {
		"ok": ok,
		"error": int(action.get("error", OK if ok else FAILED)),
		"reducer_result": (action as Dictionary).duplicate(true),
		"side_effects": {
			"export_destination": {
				"status": "cleared" if ok else "failed",
				"destination_path": "",
			},
		},
		"ui_state_update": {
			"export_screen": true,
			"view_state": true,
			"root_state": true,
		},
	}


static func _handle_open_sample_learning(workspace, payload: Dictionary) -> Dictionary:
	workspace.open_sample_learning_cta()
	var selected_tab: String = workspace.current_workspace_tab_name()
	var cta_visible: bool = bool(workspace.sample_learning_cta_visible())
	return {
		"ok": true,
		"error": OK,
		"reducer_result": {
			"selected_tab": selected_tab,
			"sample_learning_cta_visible": cta_visible,
			"action": "open",
		},
		"side_effects": {
			"sample_learning": {
				"status": "opened",
				"selected_tab": selected_tab,
			},
		},
		"ui_state_update": {
			"settings_screen": true,
			"view_state": true,
			"root_state": true,
			"selected_tab": selected_tab,
			"sample_learning_cta_visible": cta_visible,
		},
	}


static func _handle_dismiss_sample_learning(workspace, payload: Dictionary) -> Dictionary:
	workspace.dismiss_sample_learning_cta()
	var selected_tab: String = workspace.current_workspace_tab_name()
	var cta_visible: bool = bool(workspace.sample_learning_cta_visible())
	return {
		"ok": true,
		"error": OK,
		"reducer_result": {
			"selected_tab": selected_tab,
			"sample_learning_cta_visible": cta_visible,
			"action": "dismiss",
		},
		"side_effects": {
			"sample_learning": {
				"status": "dismissed",
				"selected_tab": selected_tab,
			},
		},
		"ui_state_update": {
			"settings_screen": true,
			"view_state": true,
			"root_state": true,
			"selected_tab": selected_tab,
			"sample_learning_cta_visible": cta_visible,
		},
	}


static func _event_result(
	workspace,
	ok: bool,
	error: int,
	event_id: String,
	payload: Dictionary,
	reducer_result: Dictionary,
	side_effects: Dictionary,
	ui_state_update: Dictionary
) -> Dictionary:
	var root_state: Dictionary = {}
	var view_state: Dictionary = {}
	if workspace != null and workspace.has_method("workspace_root_state_snapshot"):
		root_state = _clone_dictionary(workspace.workspace_root_state_snapshot())
	if workspace != null and workspace.has_method("workspace_root_view_state"):
		view_state = _clone_dictionary(workspace.workspace_root_view_state())
	var debug_report_proof: String = ""
	if workspace != null and workspace.has_method("workspace_state_debug_report_text"):
		debug_report_proof = String(workspace.workspace_state_debug_report_text())
	return {
		"ok": ok,
		"error": error,
		"event_id": event_id,
		"payload": _clone_dictionary(payload),
		"reducer_result": _clone_dictionary(reducer_result),
		"side_effects": _clone_dictionary(side_effects),
		"ui_state_update": _clone_dictionary(ui_state_update),
		"debug_report_proof": debug_report_proof,
		"root_state": root_state,
		"view_state": view_state,
	}


static func _resolve_event_type(event_id: String) -> int:
	return EVENT_BY_ID.get(event_id, -1)


static func _merge_ui_state_updates(base_update: Dictionary, override_update: Dictionary) -> Dictionary:
	var result: Dictionary = _clone_dictionary(base_update)
	for key in override_update.keys():
		result[key] = override_update[key]
	return result


static func _clone_dictionary(value) -> Dictionary:
	var source: Dictionary = value if value is Dictionary else {}
	var result: Dictionary = {}
	for key in source.keys():
		var entry: Variant = source[key]
		if entry is Dictionary:
			result[key] = _clone_dictionary(entry)
		elif entry is Array:
			result[key] = (entry as Array).duplicate(true)
		else:
			result[key] = entry
	return result
