@tool
class_name HexMapEditorPathSelector
extends RefCounted

const IMAGE_FILTERS := ["*.png, *.jpg, *.jpeg, *.webp ; Image atlas"]
const TRES_FILTERS := ["*.tres ; Godot resource"]


static func new_dialog(file_mode: int, filters: Array) -> EditorFileDialog:
	var dialog := EditorFileDialog.new()
	dialog.file_mode = file_mode
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	for filter in filters:
		dialog.add_filter(filter)
	return dialog


static func popup_dialog(dialog: EditorFileDialog, ratio: float = 0.5) -> bool:
	if dialog == null or not Engine.is_editor_hint():
		return false
	var base_control = EditorInterface.get_base_control()
	if base_control == null:
		return false
	base_control.add_child(dialog)
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
