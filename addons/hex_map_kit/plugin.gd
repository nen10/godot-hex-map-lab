@tool
extends EditorPlugin

var _dock: Control
var _edit_tool: Control
var _inspector_plugin: EditorInspectorPlugin


func _enter_tree() -> void:
	_dock = preload("res://addons/hex_map_kit/editor/hex_map_gen_dock.gd").new()
	add_control_to_dock(DOCK_SLOT_LEFT_BL, _dock)

	_edit_tool = preload("res://addons/hex_map_kit/editor/hex_map_edit_tool.gd").new()
	_edit_tool.name = "Hex Map Edit"
	if _edit_tool.has_method("set_undo_redo"):
		_edit_tool.set_undo_redo(EditorInterface.get_editor_undo_redo())
	add_control_to_dock(DOCK_SLOT_LEFT_BL, _edit_tool)

	_inspector_plugin = preload("res://addons/hex_map_kit/editor/hex_map_resource_inspector.gd").new()
	add_inspector_plugin(_inspector_plugin)


func _exit_tree() -> void:
	if _dock:
		remove_control_from_docks(_dock)
		_dock.queue_free()
		_dock = null

	if _edit_tool:
		remove_control_from_docks(_edit_tool)
		_edit_tool.queue_free()
		_edit_tool = null

	if _inspector_plugin:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null


func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if _edit_tool != null and _edit_tool.has_method("forward_canvas_gui_input"):
		return _edit_tool.forward_canvas_gui_input(event)
	return false
