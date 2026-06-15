@tool
class_name HexMapBuildNodePalette
extends VBoxContainer

signal node_type_requested(node_type: String)

const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const HexMapBuildGraphCanvasScript = preload("res://addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd")

var _buttons: Dictionary = {}


func _ready() -> void:
	if get_child_count() == 0:
		build_palette()


func build_palette() -> void:
	name = "Build Node Palette"
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_buttons.clear()
	var title := Label.new()
	title.text = "Add Node"
	add_child(title)
	for node_type in HexMapBuildGraphCanvasScript.NODE_TYPE_ORDER:
		var button := Button.new()
		button.text = HexMapBuildGraphCanvasScript.title_for_node_type(String(node_type))
		button.tooltip_text = "Add %s node" % button.text
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_node_button_pressed.bind(String(node_type)))
		add_child(button)
		_buttons[String(node_type)] = button


func request_node_type(node_type: String) -> void:
	if not _buttons.has(node_type):
		return
	node_type_requested.emit(node_type)


func palette_snapshot() -> Dictionary:
	return {
		"component": "HexMapBuildNodePalette",
		"node_types": PackedStringArray(_buttons.keys()),
		"button_count": _buttons.size(),
	}


func _on_node_button_pressed(node_type: String) -> void:
	node_type_requested.emit(node_type)
