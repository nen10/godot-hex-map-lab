@tool
class_name HexMapEditorAssetSlotControl
extends VBoxContainer

const HexMapEditorAssetSlotState = preload("res://addons/hex_map_kit/editor/hex_map_editor_asset_slot_state.gd")
const HexMapEditorPathSelector = preload("res://addons/hex_map_kit/editor/hex_map_editor_path_selector.gd")
const HexMapWorkspaceAssetResourceFactory = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_resource_factory.gd")

const ACTION_CREATE_NEW := "create_new"
const ACTION_APPLY_SAMPLE := "apply_sample"

signal select_requested(slot_id: String)
signal create_requested(slot_id: String)
signal create_path_selected(slot_id: String, path: String)
signal open_requested(slot_id: String, resource: Resource, path: String)
signal validate_requested(slot_id: String)
signal clear_requested(slot_id: String)
signal sample_requested(slot_id: String)
signal slot_state_changed(snapshot: Dictionary)

var _state: HexMapEditorAssetSlotState = HexMapEditorAssetSlotState.new()
var _compact_row: HBoxContainer
var _title_label: Label
var _current_label: Label
var _type_label: Label
var _status_label: Label
var _messages_label: Label
var _details_button: Button
var _details_container: VBoxContainer
var _actions_container: HBoxContainer
var _resource_picker
var _select_button: Button
var _create_button: Button
var _open_button: Button
var _clear_button: Button
var _validate_button: Button
var _sample_button: Button


func _init() -> void:
	_state.changed.connect(_on_state_changed)


func _ready() -> void:
	_build_ui()
	_refresh()


func set_slot_state(state: HexMapEditorAssetSlotState) -> void:
	if _state != null and _state.changed.is_connected(_on_state_changed):
		_state.changed.disconnect(_on_state_changed)
	_state = state if state != null else HexMapEditorAssetSlotState.new()
	_state.changed.connect(_on_state_changed)
	_build_ui()
	_sync_picker()
	_refresh()


func slot_state() -> HexMapEditorAssetSlotState:
	return _state


func configure(
	slot_id: String,
	display_name: String,
	required_type: StringName = &"",
	is_required: bool = true
) -> void:
	_state.configure(slot_id, display_name, required_type, is_required)
	_sync_picker()
	_refresh()


func set_selected_resource(
	resource: Resource,
	path: String = "",
	source: String = HexMapEditorAssetSlotState.SOURCE_PROJECT
) -> void:
	_state.set_selected_resource(resource, path, source)
	_sync_picker()


func clear_selection() -> void:
	_state.clear_selection()
	_sync_picker()


func mark_warning(messages: Array = []) -> void:
	_state.mark_warning(messages)


func mark_invalid(messages: Array = []) -> void:
	_state.mark_invalid(messages)


func set_sample_source(resource: Resource, path: String = "", label: String = "Learn with sample") -> void:
	_state.set_sample_source(resource, path, label)


func apply_sample_source() -> bool:
	var ok := _state.apply_sample_source()
	_sync_picker()
	return ok


func slot_state_snapshot() -> Dictionary:
	return _state.snapshot()


func slot_layout_snapshot() -> Dictionary:
	var view_state := _state.view_state()
	return {
		"compact_row": _compact_row != null,
		"details_visible": _details_container != null and _details_container.visible,
		"details_button_text": _details_button.text if _details_button != null else "",
		"details_button_visible": _details_button != null and _details_button.visible,
		"status_text": _status_label.text if _status_label != null else "",
		"status_tooltip": _status_label.tooltip_text if _status_label != null else "",
		"title_text": _title_label.text if _title_label != null else "",
		"title_tooltip": _title_label.tooltip_text if _title_label != null else "",
		"current_detail_text": _current_label.text if _current_label != null else "",
		"type_detail_text": _type_label.text if _type_label != null else "",
		"message_detail_text": _messages_label.text if _messages_label != null else "",
		"resource_picker_visible": _resource_picker != null,
		"resource_picker_base_type": _resource_picker.base_type if _resource_picker != null else "",
		"resource_picker_tooltip": _resource_picker.tooltip_text if _resource_picker != null else "",
		"actions_visible": _actions_container != null and _actions_container.visible,
		"action_button_texts": _visible_action_button_texts(),
		"status_kind": String(view_state.get("status_kind", "")),
		"status_icon": String(view_state.get("status_icon", "")),
		"view_state": view_state,
	}


func set_details_visible(visible: bool) -> void:
	if _details_button != null:
		_details_button.set_pressed_no_signal(visible)
	if _details_container != null:
		_details_container.visible = visible


func default_create_file_name() -> String:
	return HexMapWorkspaceAssetResourceFactory.default_file_name(_state.slot_id)


func create_dialog_config() -> Dictionary:
	return HexMapWorkspaceAssetResourceFactory.save_dialog_config(_state.slot_id)


func create_new_dialog() -> EditorFileDialog:
	var dialog = HexMapWorkspaceAssetResourceFactory.new_save_dialog(_state.slot_id)
	if dialog == null:
		return null
	dialog.file_selected.connect(_on_create_file_selected)
	return dialog


func popup_create_new_dialog() -> bool:
	var dialog := create_new_dialog()
	if dialog == null:
		return false
	return HexMapEditorPathSelector.popup_dialog(dialog)


func select_create_path(path: String) -> void:
	_on_create_file_selected(path)


func press_action(action_id: String, options: Dictionary = {}) -> Dictionary:
	var before := _state.snapshot()
	var result := {
		"ok": false,
		"error": ERR_INVALID_PARAMETER,
		"action_id": action_id,
		"slot_id": _state.slot_id,
		"before": before,
		"after": before,
	}
	match action_id:
		ACTION_CREATE_NEW:
			if not bool(before.get("allows_create_new", false)):
				result["error"] = ERR_UNAVAILABLE
				_state.record_operation_result(
					ACTION_CREATE_NEW,
					false,
					ERR_UNAVAILABLE,
					"Create New is unavailable."
				)
				return result
			var path := String(options.get("path", ""))
			create_requested.emit(_state.slot_id)
			if path != "":
				_on_create_file_selected(path)
				result["ok"] = true
				result["error"] = OK
				result["path"] = path
			else:
				var dialog_opened := popup_create_new_dialog()
				result["ok"] = dialog_opened
				result["error"] = OK if dialog_opened else ERR_UNAVAILABLE
			result["after"] = _state.snapshot()
			_state.record_operation_result(
				ACTION_CREATE_NEW,
				bool(result["ok"]),
				int(result["error"]),
				"Create New action completed." if bool(result["ok"]) else "Create New action did not open.",
				String(result.get("path", ""))
			)
			result["after"] = _state.snapshot()
			return result
		ACTION_APPLY_SAMPLE:
			if not (bool(before.get("allows_sample", false)) and bool(before.get("sample_available", false))):
				result["error"] = ERR_UNAVAILABLE
				_state.record_operation_result(
					ACTION_APPLY_SAMPLE,
					false,
					ERR_UNAVAILABLE,
					"Sample source is unavailable."
				)
				return result
			var applied := _state.apply_sample_source()
			_sync_picker()
			if applied:
				sample_requested.emit(_state.slot_id)
			var after := _state.snapshot()
			result["after"] = after
			result["ok"] = after.get("current_resource", null) == before.get("sample_resource", null)
			result["error"] = OK if bool(result["ok"]) else ERR_UNAVAILABLE
			return result
		_:
			return result


func _build_ui() -> void:
	if _title_label != null:
		return
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_compact_row = HBoxContainer.new()
	_compact_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(_compact_row)

	_title_label = Label.new()
	_title_label.custom_minimum_size = Vector2(132, 0)
	_title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_compact_row.add_child(_title_label)

	if _can_use_editor_resource_picker():
		_resource_picker = EditorResourcePicker.new()
		_resource_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_resource_picker.resource_changed.connect(_on_resource_changed)
		_compact_row.add_child(_resource_picker)

	_status_label = Label.new()
	_status_label.custom_minimum_size = Vector2(72, 0)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_compact_row.add_child(_status_label)

	_details_container = VBoxContainer.new()
	_details_container.visible = false
	add_child(_details_container)

	_current_label = Label.new()
	_current_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_details_container.add_child(_current_label)

	_type_label = Label.new()
	_details_container.add_child(_type_label)

	_messages_label = Label.new()
	_messages_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_details_container.add_child(_messages_label)

	_actions_container = HBoxContainer.new()
	add_child(_actions_container)

	_create_button = Button.new()
	_create_button.text = "Create New..."
	_create_button.pressed.connect(_on_create_pressed)
	_actions_container.add_child(_create_button)

	_sample_button = Button.new()
	_sample_button.text = "Learn With Sample"
	_sample_button.pressed.connect(_on_sample_pressed)
	_actions_container.add_child(_sample_button)


func _refresh() -> void:
	if _title_label == null:
		return
	var snapshot := _state.snapshot()
	var view_state := snapshot.get("view_state", {}) as Dictionary
	_title_label.text = String(view_state.get("title_text", snapshot.get("display_name", "")))
	_title_label.tooltip_text = String(view_state.get("title_tooltip", ""))
	_current_label.text = String(view_state.get("current_detail_text", "Current: Not selected"))
	_type_label.text = String(view_state.get("type_detail_text", "Type: Resource"))
	_status_label.text = String(view_state.get("status_text", _compact_status_text(snapshot)))
	_status_label.tooltip_text = String(view_state.get("status_tooltip", ""))
	_messages_label.text = String(view_state.get("message_detail_text", ""))
	_messages_label.visible = _messages_label.text != ""
	if _resource_picker != null:
		_resource_picker.base_type = String(view_state.get("resource_picker_base_type", "Resource"))
		_resource_picker.tooltip_text = String(view_state.get("resource_picker_tooltip", ""))
	if _open_button != null:
		_open_button.disabled = not bool(snapshot.get("selected", false))
	if _clear_button != null:
		_clear_button.disabled = not bool(snapshot.get("selected", false))
	if _create_button != null:
		var create_action := _view_action_state(view_state, ACTION_CREATE_NEW)
		_create_button.visible = bool(create_action.get("visible", false))
		_create_button.disabled = not bool(create_action.get("enabled", false))
	if _sample_button != null:
		var sample_action := _view_action_state(view_state, ACTION_APPLY_SAMPLE)
		_sample_button.visible = bool(sample_action.get("visible", false))
		_sample_button.disabled = not bool(sample_action.get("enabled", false))
		if _sample_button.visible:
			_sample_button.text = String(sample_action.get("text", "Learn With Sample"))
	_refresh_actions_visibility()
	slot_state_changed.emit(snapshot)


func _sync_picker() -> void:
	if _resource_picker == null:
		return
	_resource_picker.base_type = _state.picker_base_type()
	_resource_picker.edited_resource = _state.current_resource


func _on_state_changed() -> void:
	_sync_picker()
	_refresh()


func _on_resource_changed(resource: Resource) -> void:
	var path := resource.resource_path if resource != null else ""
	_state.set_selected_resource(resource, path)


func _on_details_toggled(pressed: bool) -> void:
	if _details_container != null:
		_details_container.visible = pressed


func _on_select_pressed() -> void:
	select_requested.emit(_state.slot_id)


func _on_create_pressed() -> void:
	press_action(ACTION_CREATE_NEW)


func _on_open_pressed() -> void:
	open_requested.emit(_state.slot_id, _state.current_resource, _state.current_path)


func _on_create_file_selected(path: String) -> void:
	create_path_selected.emit(_state.slot_id, path)


func _on_clear_pressed() -> void:
	_state.clear_selection()
	clear_requested.emit(_state.slot_id)


func _on_validate_pressed() -> void:
	validate_requested.emit(_state.slot_id)


func _on_sample_pressed() -> void:
	press_action(ACTION_APPLY_SAMPLE)


func _can_use_editor_resource_picker() -> bool:
	return Engine.is_editor_hint() and ClassDB.class_exists("EditorResourcePicker")


func _compact_status_text(snapshot: Dictionary) -> String:
	match String(snapshot.get("status", "")):
		HexMapEditorAssetSlotState.STATUS_SELECTED:
			return "OK"
		HexMapEditorAssetSlotState.STATUS_INVALID:
			return "Invalid"
		HexMapEditorAssetSlotState.STATUS_WARNING:
			return "Warn"
		_:
			return "Missing" if bool(snapshot.get("is_required", true)) else "Optional"


func _detail_text(snapshot: Dictionary) -> String:
	var lines: Array[String] = [
		"Pick: %s" % String(snapshot.get("expected_type", "Resource")),
		"Current: %s" % String(snapshot.get("current_display", "Not selected")),
		"Type: %s" % String(snapshot.get("expected_type", "Resource")),
		"Status: %s" % String(snapshot.get("status_label", "")),
		"Source: %s" % String(snapshot.get("current_source_badge", snapshot.get("current_source", ""))),
	]
	var purpose := String(snapshot.get("purpose", ""))
	if purpose != "":
		lines.append("Purpose: %s" % purpose)
	var type_filter_reason := String(snapshot.get("type_filter_reason", ""))
	if type_filter_reason != "":
		lines.append("Filter: %s" % type_filter_reason)
	var messages = snapshot.get("validation_messages", [])
	for message in messages:
		var text := String(message)
		if text != "":
			lines.append(text)
	return "\n".join(lines)


func _view_action_state(view_state: Dictionary, action_id: String) -> Dictionary:
	var actions = view_state.get("actions", {}) as Dictionary
	if actions == null:
		return {}
	var action = actions.get(action_id, {}) as Dictionary
	return action if action != null else {}


func _visible_action_button_texts() -> PackedStringArray:
	var result := PackedStringArray()
	if _actions_container == null:
		return result
	for child in _actions_container.get_children():
		if child is Button and (child as Button).visible:
			result.append((child as Button).text)
	return result


func _refresh_actions_visibility() -> void:
	if _actions_container == null:
		return
	_actions_container.visible = not _visible_action_button_texts().is_empty()
