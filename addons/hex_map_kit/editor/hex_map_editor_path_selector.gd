@tool
class_name HexMapEditorPathSelector
extends RefCounted

const HexMapDialogLifecycleState = preload("res://addons/hex_map_kit/editor/hex_map_dialog_lifecycle_state.gd")

const IMAGE_FILTERS := ["*.png, *.jpg, *.jpeg, *.webp ; Image atlas"]
const TRES_FILTERS := ["*.tres ; Godot resource"]


static func new_dialog(file_mode: int, filters: Array) -> EditorFileDialog:
	if not Engine.is_editor_hint():
		return null
	var dialog := EditorFileDialog.new()
	dialog.file_mode = file_mode
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	for filter in filters:
		dialog.add_filter(filter)
	return dialog


static func dialog_lifecycle_snapshot(dialog: Node) -> Dictionary:
	var parent := dialog.get_parent() if dialog != null else null
	var state := HexMapDialogLifecycleState.new()
	state.update_from_context({
		"valid": dialog != null,
		"has_parent": parent != null,
		"inside_tree": dialog != null and dialog.is_inside_tree(),
	})
	var dialog_state := state.to_state_snapshot()
	return {
		"valid": dialog != null,
		"has_parent": parent != null,
		"inside_tree": dialog != null and dialog.is_inside_tree(),
		"parent": parent,
		"parent_class": parent.get_class() if parent != null else "",
		"parent_name": parent.name if parent != null else "",
		"file_mode": int(dialog.get("file_mode")) if dialog != null and dialog.get("file_mode") != null else -1,
		"access": int(dialog.get("access")) if dialog != null and dialog.get("access") != null else -1,
		"dialog_state": dialog_state,
		"view_state": dialog_state.get("view_state", {}),
	}


static func attach_dialog(dialog: Node, parent: Node) -> bool:
	if dialog == null or parent == null:
		return false
	var current_parent := dialog.get_parent()
	if current_parent == null:
		parent.add_child(dialog)
		return true
	if current_parent == parent:
		return true
	return dialog.is_inside_tree()


static func popup_dialog(dialog: EditorFileDialog, ratio: float = 0.5) -> bool:
	if dialog == null or not Engine.is_editor_hint():
		return false
	var base_control = EditorInterface.get_base_control()
	if base_control == null:
		return false
	if not attach_dialog(dialog, base_control):
		return false
	dialog.popup_centered_ratio(ratio)
	return true


static func resource_path_text(resource: Resource) -> String:
	if resource == null:
		return "none"
	if resource.resource_path != "":
		return resource.resource_path
	return "(embedded)"


static func tile_set_source_count(tile_set: TileSet) -> int:
	if tile_set == null:
		return 0
	return tile_set.get_source_count()
