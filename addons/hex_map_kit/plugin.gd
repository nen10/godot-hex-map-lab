@tool
extends EditorPlugin

var _dock: Control
var _inspector_plugin: EditorInspectorPlugin


func _enter_tree() -> void:
	_dock = preload("res://addons/hex_map_kit/editor/hex_map_gen_dock.gd").new()
	add_control_to_dock(DOCK_SLOT_LEFT_BL, _dock)

	_inspector_plugin = preload("res://addons/hex_map_kit/editor/hex_map_resource_inspector.gd").new()
	add_inspector_plugin(_inspector_plugin)


func _exit_tree() -> void:
	if _dock:
		remove_control_from_docks(_dock)
		_dock.queue_free()
		_dock = null

	if _inspector_plugin:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null
