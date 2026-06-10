@tool
class_name HexMapWorkspaceDispatcher
extends RefCounted

const EVENT_SELECT_TAB := "select_tab"
const EVENT_RUN_VALIDATION := "run_validation"
const EVENT_SELECT_VALIDATION_ISSUE := "select_validation_issue"
const EVENT_SELECT_EXPORT_DESTINATION := "select_export_destination"
const EVENT_CLEAR_EXPORT_DESTINATION := "clear_export_destination"
const EVENT_OPEN_SAMPLE_LEARNING := "open_sample_learning"
const EVENT_DISMISS_SAMPLE_LEARNING := "dismiss_sample_learning"


static func dispatch(workspace, event_id: String, payload: Dictionary = {}) -> Dictionary:
	if workspace == null:
		return _event_result(null, false, ERR_UNAVAILABLE, event_id, payload, {
			"message": "Workspace is not available.",
		})
	var action_result := {}
	var ok := false
	var error := OK
	match event_id:
		EVENT_SELECT_TAB:
			var tab_name := String(payload.get("tab", payload.get("tab_name", "")))
			ok = workspace.select_workspace_tab(tab_name)
			error = OK if ok else ERR_DOES_NOT_EXIST
			action_result = {"selected_tab": workspace.current_workspace_tab_name()}
		EVENT_RUN_VALIDATION:
			action_result = workspace.run_validate_screen()
			ok = bool(action_result.get("ok", false))
			error = int(action_result.get("error", OK if ok else FAILED))
		EVENT_SELECT_VALIDATION_ISSUE:
			action_result = workspace.select_validate_issue(int(payload.get("index", -1)))
			ok = bool(action_result.get("ok", false))
			error = int(action_result.get("error", OK if ok else ERR_DOES_NOT_EXIST))
		EVENT_SELECT_EXPORT_DESTINATION:
			action_result = workspace.select_export_destination(String(payload.get("path", "")))
			ok = bool(action_result.get("ok", false))
			error = int(action_result.get("error", OK if ok else ERR_INVALID_PARAMETER))
		EVENT_CLEAR_EXPORT_DESTINATION:
			action_result = workspace.clear_export_destination()
			ok = bool(action_result.get("ok", false))
			error = int(action_result.get("error", OK if ok else FAILED))
		EVENT_OPEN_SAMPLE_LEARNING:
			workspace.open_sample_learning_cta()
			ok = true
			action_result = {
				"selected_tab": workspace.current_workspace_tab_name(),
				"sample_learning_cta_visible": workspace.sample_learning_cta_visible(),
			}
		EVENT_DISMISS_SAMPLE_LEARNING:
			workspace.dismiss_sample_learning_cta()
			ok = true
			action_result = {
				"selected_tab": workspace.current_workspace_tab_name(),
				"sample_learning_cta_visible": workspace.sample_learning_cta_visible(),
			}
		_:
			return _event_result(workspace, false, ERR_INVALID_PARAMETER, event_id, payload, {
				"message": "Unknown workspace event.",
			})
	return _event_result(workspace, ok, error, event_id, payload, action_result)


static func _event_result(
	workspace,
	ok: bool,
	error: int,
	event_id: String,
	payload: Dictionary,
	action_result: Dictionary
) -> Dictionary:
	var root_state := {}
	var view_state := {}
	if workspace != null and workspace.has_method("workspace_root_state_snapshot"):
		root_state = workspace.workspace_root_state_snapshot()
	if workspace != null and workspace.has_method("workspace_root_view_state"):
		view_state = workspace.workspace_root_view_state()
	return {
		"ok": ok,
		"error": error,
		"event_id": event_id,
		"payload": payload.duplicate(true),
		"result": action_result.duplicate(true),
		"root_state": root_state,
		"view_state": view_state,
	}
