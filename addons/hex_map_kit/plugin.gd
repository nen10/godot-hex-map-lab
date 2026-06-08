@tool
extends EditorPlugin

const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")

var _workspace: Control
var _inspector_plugin: EditorInspectorPlugin
var _editor_session_state


func _enter_tree() -> void:
	_editor_session_state = preload("res://addons/hex_map_kit/editor/hex_map_editor_session_state.gd").new()

	_workspace = preload("res://addons/hex_map_kit/editor/hex_map_workspace.gd").new()
	_workspace.name = "Hex Map Workspace"
	_workspace.set_editor_session_state(_editor_session_state)
	add_control_to_dock(DOCK_SLOT_LEFT_BL, _workspace)

	_inspector_plugin = preload("res://addons/hex_map_kit/editor/hex_map_resource_inspector.gd").new()
	add_inspector_plugin(_inspector_plugin)
	_connect_scene_tree_selection()
	_on_editor_selection_changed()


func _exit_tree() -> void:
	if _workspace:
		_disconnect_scene_tree_selection()
		remove_control_from_docks(_workspace)
		_workspace.queue_free()
		_workspace = null

	if _inspector_plugin:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null
	_editor_session_state = null


func _handles(object: Object) -> bool:
	if _workspace == null or not is_instance_valid(_workspace):
		return false
	if not _workspace.has_method("viewport_input_enabled"):
		return false
	if not _workspace.viewport_input_enabled():
		return false
	return object is CanvasItem


func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if _workspace != null and _workspace.has_method("forward_canvas_gui_input"):
		return _workspace.forward_canvas_gui_input(event)
	return false


func _connect_scene_tree_selection() -> void:
	var selection := get_editor_interface().get_selection()
	if selection != null and not selection.selection_changed.is_connected(_on_editor_selection_changed):
		selection.selection_changed.connect(_on_editor_selection_changed)


func _disconnect_scene_tree_selection() -> void:
	var selection := get_editor_interface().get_selection()
	if selection != null and selection.selection_changed.is_connected(_on_editor_selection_changed):
		selection.selection_changed.disconnect(_on_editor_selection_changed)


func _on_editor_selection_changed() -> void:
	if _workspace == null or not is_instance_valid(_workspace):
		return
	if not _workspace.has_method("set_selected_hex_tile_map_node"):
		return
	_workspace.set_selected_hex_tile_map_node(_selected_hex_tile_map_from_editor_selection(), "plugin.scene_tree_selection")


func _selected_hex_tile_map_from_editor_selection() -> Node:
	var selection := get_editor_interface().get_selection()
	if selection == null or not selection.has_method("get_selected_nodes"):
		return null
	for node in selection.get_selected_nodes():
		var layer := _hex_tile_map_from_node(node)
		if layer != null:
			return layer
	return null


func _hex_tile_map_from_node(node: Node) -> Node:
	if node == null or not is_instance_valid(node):
		return null
	if node is HexTileMapLayer:
		return node
	if node is TileMapLayer:
		var parent := node.get_parent()
		if parent is HexTileMapLayer and (
			node.name == HexTileMapLayer.BASE_TILE_MAP_NAME
			or node.name == HexTileMapLayer.LOOP_TILE_MAP_NAME
			or node.name == HexTileMapLayer.OVERLAY_TILE_MAP_NAME
		):
			return parent
	return null
