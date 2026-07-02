@tool
class_name HexMapBuildNodePalette
extends VBoxContainer

signal node_type_requested(node_type: String)
signal node_template_requested(node_type: String, params: Dictionary)

const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const HexMapBuildGraphCanvasScript = preload("res://addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd")

var _buttons: Dictionary = {}


func _ready() -> void:
	if get_child_count() == 0:
		build_palette()


func build_palette() -> void:
	name = "Build Node Add Row"
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_buttons.clear()
	var title := Label.new()
	title.text = "Add Node"
	title.add_theme_font_size_override("font_size", 18)
	add_child(title)
	for group in _palette_groups():
		_add_group(group)


func request_node_type(node_type: String) -> void:
	if not _buttons.has(node_type):
		return
	node_type_requested.emit(node_type)


func palette_snapshot() -> Dictionary:
	var groups: Array[Dictionary] = []
	for group in _palette_groups():
		groups.append({
			"id": String(group.get("id", "")),
			"label": String(group.get("label", "")),
			"buttons": _entry_labels(group.get("entries", []) as Array),
		})
	return {
		"component": "HexMapBuildNodePalette",
		"node_types": PackedStringArray(_buttons.keys()),
		"button_count": _entry_count(),
		"layout": "bottom_grouped_row",
		"group_ids": _group_ids(groups),
		"groups": groups,
		"compose_primary": false,
	}


func _on_node_button_pressed(node_type: String) -> void:
	node_type_requested.emit(node_type)


func _on_node_template_button_pressed(node_type: String, params: Dictionary) -> void:
	node_template_requested.emit(node_type, params.duplicate(true))


func _add_group(group: Dictionary) -> void:
	var row := HBoxContainer.new()
	row.name = "Build Node Add %s Group" % String(group.get("label", "Group"))
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var label := Label.new()
	label.text = "%s:" % String(group.get("label", "Group"))
	label.add_theme_font_size_override("font_size", 18)
	row.add_child(label)
	for entry in group.get("entries", []) as Array:
		var entry_dict := entry as Dictionary
		var node_type := String(entry_dict.get("node_type", ""))
		var params := (entry_dict.get("params", {}) as Dictionary).duplicate(true)
		var button := Button.new()
		button.text = String(entry_dict.get("label", HexMapBuildGraphCanvasScript.title_for_node_type(node_type)))
		button.tooltip_text = String(entry_dict.get("tooltip", "Add %s node" % button.text))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 18)
		if params.is_empty():
			button.pressed.connect(_on_node_button_pressed.bind(node_type))
		else:
			button.pressed.connect(_on_node_template_button_pressed.bind(node_type, params))
		row.add_child(button)
		_buttons[String(entry_dict.get("id", node_type))] = button
	add_child(row)


func _palette_groups() -> Array[Dictionary]:
	return [
		{
			"id": "consolidated",
			"label": "Add",
			"entries": [
				{"label": "Terrain Generation", "node_type": HexGenerationNodeTypesScript.NODE_TERRAIN_GENERATION},
				{"label": "Item Generation", "node_type": HexGenerationNodeTypesScript.NODE_ITEM_GENERATION},
				{"label": "Set Operation", "node_type": HexGenerationNodeTypesScript.NODE_SET_OPERATION},
				{"label": "Result", "node_type": HexGenerationNodeTypesScript.NODE_RESULT},
			],
		},
	]


func _entry_labels(entries: Array) -> PackedStringArray:
	var result := PackedStringArray()
	for entry in entries:
		result.append(String((entry as Dictionary).get("label", "")))
	return result


func _group_ids(groups: Array) -> PackedStringArray:
	var result := PackedStringArray()
	for group in groups:
		result.append(String((group as Dictionary).get("id", "")))
	return result


func _entry_count() -> int:
	var count := 0
	for group in _palette_groups():
		count += (group.get("entries", []) as Array).size()
	return count
