@tool
class_name HexMapWorkspaceAssetPanel
extends VBoxContainer

const HexMapEditorAssetSlotControl = preload("res://addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd")
const HexMapEditorAssetSlotState = preload("res://addons/hex_map_kit/editor/hex_map_editor_asset_slot_state.gd")
const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")
const HexMapWorkspaceAssetResourceFactory = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_resource_factory.gd")

var tab_name := ""
var component_id := ""
var panel_title := ""
var _context: HexMapWorkspaceAssetContext = null
var _slot_rows: Array[Dictionary] = []
var _slot_controls: Dictionary = {}
var _syncing := false
var _title_label: Label


func configure(
	p_tab_name: String,
	p_component_id: String,
	p_panel_title: String,
	p_slot_rows: Array[Dictionary]
) -> void:
	tab_name = p_tab_name
	component_id = p_component_id
	panel_title = p_panel_title
	_slot_rows = p_slot_rows.duplicate(true)
	_build_ui()
	_sync_slots_from_context()


func set_workspace_asset_context(context: HexMapWorkspaceAssetContext) -> void:
	if _context != null and _context.asset_changed.is_connected(_on_context_asset_changed):
		_context.asset_changed.disconnect(_on_context_asset_changed)
	_context = context
	if _context != null and not _context.asset_changed.is_connected(_on_context_asset_changed):
		_context.asset_changed.connect(_on_context_asset_changed)
	_sync_slots_from_context()


func asset_slot_count() -> int:
	return _slot_rows.size()


func asset_slot_ids() -> PackedStringArray:
	var result := PackedStringArray()
	for row in _slot_rows:
		result.append(String(row.get("slot_id", "")))
	return result


func has_asset_slot(slot_id: String) -> bool:
	return _slot_controls.has(slot_id)


func asset_slot_snapshot(slot_id: String) -> Dictionary:
	var control = _slot_controls.get(slot_id, null) as HexMapEditorAssetSlotControl
	if control == null:
		return {}
	return control.slot_state_snapshot()


func _build_ui() -> void:
	if _title_label != null:
		return
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	_title_label = Label.new()
	_title_label.text = panel_title
	add_child(_title_label)

	for row in _slot_rows:
		var slot_id := String(row.get("slot_id", ""))
		if slot_id == "":
			continue
		var state := HexMapEditorAssetSlotState.new()
		state.configure(
			slot_id,
			String(row.get("display_name", slot_id)),
			StringName(row.get("required_type", HexMapWorkspaceAssetResourceFactory.resource_type_name(slot_id))),
			bool(row.get("required", true))
		)
		state.allows_create_new = bool(row.get("allows_create_new", true))
		var control := HexMapEditorAssetSlotControl.new()
		control.set_slot_state(state)
		control.create_path_selected.connect(_on_create_path_selected)
		control.clear_requested.connect(_on_clear_requested)
		control.slot_state_changed.connect(_on_slot_state_changed)
		add_child(control)
		_slot_controls[slot_id] = control


func _sync_slots_from_context() -> void:
	if _slot_controls.is_empty():
		return
	_syncing = true
	for slot_id in _slot_controls.keys():
		var control = _slot_controls[slot_id] as HexMapEditorAssetSlotControl
		if control == null:
			continue
		var resource := _context.asset_for_slot(slot_id) if _context != null else null
		if resource == null:
			control.clear_selection()
		else:
			control.set_selected_resource(resource, resource.resource_path)
	_syncing = false


func _on_create_path_selected(slot_id: String, path: String) -> void:
	HexMapWorkspaceAssetResourceFactory.create_and_save_for_slot(slot_id, path, _context)
	_sync_slots_from_context()


func _on_clear_requested(slot_id: String) -> void:
	if _context != null:
		_context.set_asset(slot_id, null)


func _on_slot_state_changed(snapshot: Dictionary) -> void:
	if _syncing or _context == null:
		return
	var slot_id := String(snapshot.get("slot_id", ""))
	if slot_id == "":
		return
	var resource = snapshot.get("current_resource", null) as Resource
	if _context.asset_for_slot(slot_id) != resource:
		_context.set_asset(slot_id, resource)


func _on_context_asset_changed(_slot_id: String) -> void:
	_sync_slots_from_context()
