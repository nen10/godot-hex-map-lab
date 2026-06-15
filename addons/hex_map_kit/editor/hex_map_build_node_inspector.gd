@tool
class_name HexMapBuildNodeInspector
extends VBoxContainer

signal node_params_changed(node_id: String, params: Dictionary)
signal promote_requested(node_id: String, role: String)

const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const HexGenerationPortsScript = preload("res://addons/hex_map_kit/generation/hex_generation_ports.gd")

var _node_id := ""
var _node_type := ""
var _params: Dictionary = {}
var _resource_refs: Dictionary = {}
var _output_type := ""
var _preview_available := false
var _promote_enabled := false
var _header_label: Label
var _params_label: Label
var _resource_ref_label: Label
var _promote_button: Button
var _role_option: OptionButton


func _ready() -> void:
	if get_child_count() == 0:
		_build_ui()
	_refresh_ui()


func inspect_node(node: Dictionary, output_type: String = "", preview_snapshot: Dictionary = {}) -> void:
	_node_id = String(node.get("id", ""))
	_node_type = String(node.get("type", ""))
	_params = (node.get("params", {}) as Dictionary).duplicate(true)
	_resource_refs = (node.get("resource_refs", {}) as Dictionary).duplicate()
	_output_type = output_type
	_preview_available = bool(preview_snapshot.get("available", false))
	_refresh_ui()


func clear_inspector() -> void:
	_node_id = ""
	_node_type = ""
	_params = {}
	_resource_refs = {}
	_output_type = ""
	_preview_available = false
	_refresh_ui()


func set_param(key: String, value: Variant) -> void:
	if _node_id == "":
		return
	_params[key] = value
	_refresh_ui()
	node_params_changed.emit(_node_id, _params.duplicate(true))


func set_promote_enabled(enabled: bool) -> void:
	_promote_enabled = enabled
	_refresh_ui()


func inspector_snapshot() -> Dictionary:
	return {
		"component": "HexMapBuildNodeInspector",
		"node_id": _node_id,
		"node_type": _node_type,
		"param_fields": PackedStringArray(_param_keys_for_type(_node_type)),
		"param_values": _params.duplicate(true),
		"resource_ref_fields": PackedStringArray(_resource_ref_fields_for_type(_node_type)),
		"selected_output_type": _output_type,
		"preview_available": _preview_available,
		"promote_button_present": _promote_button != null,
		"promote_enabled": _promote_button != null and not _promote_button.disabled,
		"resource_ref_binding_present": not _resource_ref_fields_for_type(_node_type).is_empty(),
	}


func _build_ui() -> void:
	name = "Build Node Inspector"
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_header_label = Label.new()
	_header_label.name = "Selected Node Header"
	add_child(_header_label)

	_params_label = Label.new()
	_params_label.name = "Selected Node Params"
	_params_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_params_label)

	_resource_ref_label = Label.new()
	_resource_ref_label.name = "Selected Node Resource Refs"
	_resource_ref_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_resource_ref_label)

	var action_row := HBoxContainer.new()
	action_row.name = "Selected Node Actions"
	_role_option = OptionButton.new()
	for role in ["terrain", "overlay", "object"]:
		_role_option.add_item(role.capitalize())
		_role_option.set_item_metadata(_role_option.item_count - 1, role)
	action_row.add_child(_role_option)
	_promote_button = Button.new()
	_promote_button.text = "Promote output to Layer"
	_promote_button.pressed.connect(_on_promote_pressed)
	action_row.add_child(_promote_button)
	add_child(action_row)


func _refresh_ui() -> void:
	if _header_label == null:
		return
	if _node_id == "":
		_header_label.text = "No node selected"
		_params_label.text = ""
		_resource_ref_label.text = ""
		_promote_button.disabled = true
		return
	_header_label.text = "%s | Output: %s" % [_node_id, _output_type if _output_type != "" else "none"]
	_params_label.text = "Params: %s" % ", ".join(_param_summary_parts())
	var refs := _resource_ref_fields_for_type(_node_type)
	_resource_ref_label.text = "Resource refs: %s" % (", ".join(refs) if not refs.is_empty() else "none")
	_promote_button.disabled = not _promote_enabled or _output_type == "" or not _preview_available


func _param_summary_parts() -> Array[String]:
	var result: Array[String] = []
	for key in _param_keys_for_type(_node_type):
		result.append("%s=%s" % [String(key), str(_params.get(String(key), ""))])
	return result


func _param_keys_for_type(node_type: String) -> Array:
	match node_type:
		HexGenerationNodeTypesScript.NODE_SOURCE:
			return ["kind", "source_key", "output_type"]
		HexGenerationNodeTypesScript.NODE_SHAPE:
			return ["shape", "width", "height", "size", "radius", "toric"]
		HexGenerationNodeTypesScript.NODE_WALL_FIELD:
			return ["wall_probability", "seed"]
		HexGenerationNodeTypesScript.NODE_CONNECTIVITY:
			return ["method", "seed"]
		HexGenerationNodeTypesScript.NODE_REGION_FILTER:
			return ["mode", "item_key", "selectors", "op"]
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR:
			return ["mode", "placement_probability", "item_pool", "seed"]
		HexGenerationNodeTypesScript.NODE_COMPOSE:
			return ["write_policy", "existing_policy"]
	return []


func _resource_ref_fields_for_type(node_type: String) -> Array:
	match node_type:
		HexGenerationNodeTypesScript.NODE_SOURCE:
			return ["map", "overlay", "document", "result"]
	return []


func _on_promote_pressed() -> void:
	if _node_id == "" or _role_option == null:
		return
	promote_requested.emit(_node_id, String(_role_option.get_item_metadata(_role_option.selected)))
