@tool
class_name HexMapEditorAssetSlotControl
extends VBoxContainer

const HexMapEditorAssetSlotState = preload("res://addons/hex_map_kit/editor/hex_map_editor_asset_slot_state.gd")
const HexMapEditorPathSelector = preload("res://addons/hex_map_kit/editor/hex_map_editor_path_selector.gd")
const HexMapWorkspaceAssetResourceFactory = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_resource_factory.gd")

signal select_requested(slot_id: String)
signal create_requested(slot_id: String)
signal create_path_selected(slot_id: String, path: String)
signal open_requested(slot_id: String, resource: Resource, path: String)
signal validate_requested(slot_id: String)
signal clear_requested(slot_id: String)
signal sample_requested(slot_id: String)
signal slot_state_changed(snapshot: Dictionary)

var _state: HexMapEditorAssetSlotState = HexMapEditorAssetSlotState.new()
var _title_label: Label
var _current_label: Label
var _type_label: Label
var _status_label: Label
var _messages_label: Label
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


func set_selected_resource(resource: Resource, path: String = "") -> void:
	_state.set_selected_resource(resource, path)
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


func _build_ui() -> void:
	if _title_label != null:
		return
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_title_label = Label.new()
	add_child(_title_label)

	_current_label = Label.new()
	_current_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_current_label)

	_type_label = Label.new()
	add_child(_type_label)

	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_status_label)

	_messages_label = Label.new()
	_messages_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_messages_label)

	if _can_use_editor_resource_picker():
		_resource_picker = EditorResourcePicker.new()
		_resource_picker.resource_changed.connect(_on_resource_changed)
		add_child(_resource_picker)

	var actions = HBoxContainer.new()
	add_child(actions)

	_select_button = Button.new()
	_select_button.text = "Select..."
	_select_button.pressed.connect(_on_select_pressed)
	actions.add_child(_select_button)

	_create_button = Button.new()
	_create_button.text = "Create New..."
	_create_button.pressed.connect(_on_create_pressed)
	actions.add_child(_create_button)

	_open_button = Button.new()
	_open_button.text = "Open"
	_open_button.pressed.connect(_on_open_pressed)
	actions.add_child(_open_button)

	_clear_button = Button.new()
	_clear_button.text = "Clear"
	_clear_button.pressed.connect(_on_clear_pressed)
	actions.add_child(_clear_button)

	_validate_button = Button.new()
	_validate_button.text = "Validate"
	_validate_button.pressed.connect(_on_validate_pressed)
	actions.add_child(_validate_button)

	_sample_button = Button.new()
	_sample_button.text = "Learn With Sample"
	_sample_button.pressed.connect(_on_sample_pressed)
	actions.add_child(_sample_button)


func _refresh() -> void:
	if _title_label == null:
		return
	var snapshot := _state.snapshot()
	_title_label.text = String(snapshot.get("display_name", ""))
	_current_label.text = "Current: %s" % String(snapshot.get("current_display", "Not selected"))
	_type_label.text = "Type: %s" % String(snapshot.get("required_type", ""))
	_status_label.text = "Status: %s" % String(snapshot.get("status_label", ""))
	_messages_label.text = "\n".join(snapshot.get("validation_messages", []))
	if _resource_picker != null:
		_resource_picker.base_type = String(snapshot.get("required_type", ""))
	_open_button.disabled = not bool(snapshot.get("selected", false))
	_clear_button.disabled = not bool(snapshot.get("selected", false))
	_create_button.visible = bool(snapshot.get("allows_create_new", false))
	_sample_button.visible = bool(snapshot.get("allows_sample", false)) and bool(snapshot.get("sample_available", false))
	if _sample_button.visible:
		_sample_button.text = String(snapshot.get("sample_display", "Learn With Sample"))
	slot_state_changed.emit(snapshot)


func _sync_picker() -> void:
	if _resource_picker == null:
		return
	_resource_picker.base_type = String(_state.required_type)
	_resource_picker.edited_resource = _state.current_resource


func _on_state_changed() -> void:
	_sync_picker()
	_refresh()


func _on_resource_changed(resource: Resource) -> void:
	var path := resource.resource_path if resource != null else ""
	_state.set_selected_resource(resource, path)


func _on_select_pressed() -> void:
	select_requested.emit(_state.slot_id)


func _on_create_pressed() -> void:
	create_requested.emit(_state.slot_id)
	popup_create_new_dialog()


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
	if _state.apply_sample_source():
		sample_requested.emit(_state.slot_id)


func _can_use_editor_resource_picker() -> bool:
	return Engine.is_editor_hint() and ClassDB.class_exists("EditorResourcePicker")
