@tool
class_name HexMapBuildNodeInspector
extends VBoxContainer

signal node_params_changed(node_id: String, params: Dictionary)
signal promote_requested(node_id: String, role: String)

const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const HexGenerationPortsScript = preload("res://addons/hex_map_kit/generation/hex_generation_ports.gd")

var _node_id := ""
var _node_type := ""
var _last_built_node_id := ""
var _params: Dictionary = {}
var _resource_refs: Dictionary = {}
var _output_type := ""
var _preview_available := false
var _promote_enabled := false
var _connection_warnings: Array[Dictionary] = []
var _header_label: Label
var _warning_label: Label
var _params_container: VBoxContainer
var _param_controls: Dictionary = {}
var _resource_ref_label: Label
var _promote_button: Button
var _role_option: OptionButton


func _ready() -> void:
	if get_child_count() == 0:
		_build_ui()
	_refresh_ui()


func inspect_node(node: Dictionary, output_type: String = "", preview_snapshot: Dictionary = {}, connection_warnings: Array[Dictionary] = []) -> void:
	_node_id = String(node.get("id", ""))
	_node_type = String(node.get("type", ""))
	_params = (node.get("params", {}) as Dictionary).duplicate(true)
	_resource_refs = (node.get("resource_refs", {}) as Dictionary).duplicate()
	_output_type = output_type
	_preview_available = bool(preview_snapshot.get("available", false))
	_connection_warnings = connection_warnings.duplicate(true)
	_refresh_ui()


func clear_inspector() -> void:
	_node_id = ""
	_node_type = ""
	_params = {}
	_resource_refs = {}
	_output_type = ""
	_preview_available = false
	_connection_warnings.clear()
	_refresh_ui()


func set_param(key: String, value: Variant) -> void:
	if _node_id == "":
		return
	_params[key] = value
	_refresh_param_controls()
	node_params_changed.emit(_node_id, _params.duplicate(true))


func set_promote_enabled(enabled: bool) -> void:
	_promote_enabled = enabled
	if _promote_button != null:
		_promote_button.disabled = not _promote_enabled or _output_type == "" or not _preview_available


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
		"connection_warnings": _connection_warnings.duplicate(true),
	}


func _build_ui() -> void:
	name = "Build Node Inspector"
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	_header_label = Label.new()
	_header_label.name = "Selected Node Header"
	add_child(_header_label)

	_warning_label = Label.new()
	_warning_label.name = "Node Connection Warnings"
	_warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_warning_label)

	_params_container = VBoxContainer.new()
	_params_container.name = "Node Param Controls"
	add_child(_params_container)

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
		_warning_label.text = ""
		_warning_label.visible = false
		_clear_param_controls()
		_resource_ref_label.text = ""
		_promote_button.disabled = true
		_last_built_node_id = ""
		return
	_header_label.text = "%s | Output: %s" % [_node_id, _output_type if _output_type != "" else "none"]
	_refresh_warnings()
	if _node_id != _last_built_node_id:
		_build_param_controls()
		_last_built_node_id = _node_id
	_refresh_param_controls()
	var refs := _resource_ref_fields_for_type(_node_type)
	_resource_ref_label.text = "Resource refs: %s" % (", ".join(refs) if not refs.is_empty() else "none")
	_promote_button.disabled = not _promote_enabled or _output_type == "" or not _preview_available


func _refresh_warnings() -> void:
	if _warning_label == null:
		return
	var lines: Array[String] = []
	for warning in _connection_warnings:
		var text := String(warning.get("text", ""))
		if text != "":
			lines.append(text)
	if lines.is_empty():
		_warning_label.text = ""
		_warning_label.visible = false
	else:
		_warning_label.text = "\n".join(lines)
		_warning_label.visible = true


func _clear_param_controls() -> void:
	for child in _params_container.get_children():
		_params_container.remove_child(child)
		child.queue_free()
	_param_controls.clear()


func _build_param_controls() -> void:
	_clear_param_controls()
	var keys := _param_keys_for_type(_node_type)
	var visibility := _param_visibility_for_type(_node_type, _params)
	for key in keys:
		var row := HBoxContainer.new()
		row.name = "ParamRow_%s" % key
		var label := Label.new()
		label.text = key
		label.custom_minimum_size = Vector2(120, 0)
		row.add_child(label)
		var control := _create_param_control(key, _params.get(key, _param_default(key, _node_type)))
		if control != null:
			row.add_child(control)
			_param_controls[key] = {"row": row, "control": control}
		_params_container.add_child(row)
		var visible_flag := bool(visibility.get(key, true))
		row.visible = visible_flag


func _refresh_param_controls() -> void:
	var visibility := _param_visibility_for_type(_node_type, _params)
	for key in _param_controls.keys():
		var entry = _param_controls[key] as Dictionary
		var row = entry.get("row", null) as Control
		if row != null:
			row.visible = bool(visibility.get(key, true))


func _create_param_control(key: String, current_value) -> Control:
	match _param_control_type(_node_type, key):
		"option":
			return _build_option_control(key, current_value)
		"spin_float":
			return _build_spin_float_control(key, current_value)
		"spin_int":
			return _build_spin_int_control(key, current_value)
		"check":
			return _build_check_control(key, current_value)
		"line_edit":
			return _build_line_edit_control(key, current_value)
		_:
			return null


func _build_option_control(key: String, current_value) -> OptionButton:
	var options := _param_options(_node_type, key)
	var control := OptionButton.new()
	var selected_index := -1
	for i in options.size():
		var opt = options[i] as Dictionary
		control.add_item(String(opt.get("label", "")))
		control.set_item_metadata(i, opt.get("value", ""))
		if String(opt.get("value", "")) == String(current_value):
			selected_index = i
	if selected_index >= 0:
		control.select(selected_index)
	elif options.size() > 0:
		control.select(0)
		var first_value = options[0].get("value", null)
		if first_value != null:
			call_deferred("set_param", key, first_value)
	control.item_selected.connect(func(idx: int):
		var value = control.get_item_metadata(idx)
		if value != null:
			set_param(key, value)
	)
	return control


func _build_spin_float_control(key: String, current_value) -> SpinBox:
	var control := SpinBox.new()
	control.step = float(_param_step(_node_type, key, 0.05))
	control.min_value = float(_param_min(_node_type, key, 0.0))
	control.max_value = float(_param_max(_node_type, key, 1.0))
	control.value = clampf(float(current_value), float(control.min_value), float(control.max_value))
	control.value_changed.connect(func(v: float):
		set_param(key, v)
	)
	return control


func _build_spin_int_control(key: String, current_value) -> SpinBox:
	var control := SpinBox.new()
	control.step = float(_param_step(_node_type, key, 1))
	control.min_value = float(_param_min(_node_type, key, 0))
	control.max_value = float(_param_max(_node_type, key, 999999))
	control.value = clampi(int(current_value), int(control.min_value), int(control.max_value))
	control.value_changed.connect(func(v: float):
		set_param(key, int(v))
	)
	return control


func _build_check_control(key: String, current_value) -> CheckBox:
	var control := CheckBox.new()
	control.text = "Enable"
	control.button_pressed = bool(current_value)
	control.toggled.connect(func(on: bool):
		set_param(key, on)
	)
	return control


func _build_line_edit_control(key: String, current_value) -> LineEdit:
	var control := LineEdit.new()
	control.text = str(current_value) if current_value != null else ""
	control.text_changed.connect(func(new_text: String):
		set_param(key, new_text)
	)
	return control


func _param_control_type(node_type: String, key: String) -> String:
	match key:
		"shape", "method", "mode", "kind", "write_policy", "existing_policy", "op", "output_type":
			return "option"
		"wall_probability", "placement_probability":
			return "spin_float"
		"width", "height", "size", "radius", "seed":
			return "spin_int"
		"toric":
			return "check"
		"source_key", "item_key", "selectors", "item_pool":
			return "line_edit"
		_:
			return ""


func _param_options(node_type: String, key: String) -> Array[Dictionary]:
	match key:
		"shape":
			return [
				{"label": "Rectangle", "value": "rectangle"},
				{"label": "Square", "value": "square"},
				{"label": "Hexagon", "value": "hexagon"},
			]
		"method":
			return [
				{"label": "Dense", "value": "dense"},
				{"label": "Sparse", "value": "sparse"},
				{"label": "Terminal", "value": "terminal"},
				{"label": "None", "value": "none"},
			]
		"mode":
			if node_type == HexGenerationNodeTypesScript.NODE_REGION_FILTER:
				return [
					{"label": "Floor", "value": "floor"},
					{"label": "Wall", "value": "wall"},
					{"label": "Any", "value": "any"},
					{"label": "Query", "value": "query"},
				]
			return [
				{"label": "Weighted", "value": "weighted"},
				{"label": "Limited", "value": "limited"},
			]
		"kind":
			return [
				{"label": "Provided", "value": "provided"},
				{"label": "Context", "value": "context"},
				{"label": "Map Resource", "value": "map_resource"},
				{"label": "Overlay Resource", "value": "overlay_resource"},
				{"label": "Document Terrain", "value": "document_terrain"},
				{"label": "Document Overlay", "value": "document_overlay"},
				{"label": "Result Terrain", "value": "result_terrain"},
				{"label": "Result Overlay", "value": "result_overlay"},
			]
		"write_policy":
			return [
				{"label": "Add Item", "value": "add_item"},
				{"label": "Replace Item", "value": "replace_item"},
				{"label": "Add Replace", "value": "add_replace"},
			]
		"existing_policy":
			return [
				{"label": "Merge", "value": "merge"},
				{"label": "Overwrite", "value": "overwrite"},
			]
		"op":
			return [
				{"label": "OR", "value": "or"},
				{"label": "AND", "value": "and"},
				{"label": "NOT", "value": "not"},
			]
		"output_type":
			return [
				{"label": "Terrain", "value": "terrain"},
				{"label": "Overlay", "value": "overlay"},
			]
		_:
			return []


func _param_min(_node_type: String, key: String, fallback: float) -> float:
	match key:
		"wall_probability", "placement_probability":
			return 0.0
		"width", "height", "size", "radius":
			return 1.0
		_:
			return fallback


func _param_max(_node_type: String, key: String, fallback: float) -> float:
	match key:
		"wall_probability", "placement_probability":
			return 1.0
		"width", "height", "size":
			return 256.0
		"radius":
			return 128.0
		"seed":
			return 999999.0
		_:
			return fallback


func _param_step(_node_type: String, key: String, fallback: float) -> float:
	match key:
		"wall_probability", "placement_probability":
			return 0.05
		"width", "height", "size", "radius", "seed":
			return 1.0
		_:
			return fallback


func _param_default(key: String, node_type: String) -> Variant:
	match key:
		"shape":
			return "rectangle"
		"width":
			return 6
		"height":
			return 4
		"size":
			return 3
		"radius":
			return 2
		"toric":
			return false
		"wall_probability":
			return 0.3
		"method":
			return "dense"
		"mode":
			if node_type == HexGenerationNodeTypesScript.NODE_REGION_FILTER:
				return "floor"
			return "weighted"
		"placement_probability":
			return 0.5
		"kind":
			return "provided"
		"output_type":
			return "terrain"
		"write_policy":
			return "add_item"
		"existing_policy":
			return "merge"
		"op":
			return "or"
		_:
			return ""


func _param_visibility_for_type(node_type: String, params: Dictionary) -> Dictionary:
	var result := {}
	match node_type:
		HexGenerationNodeTypesScript.NODE_SHAPE:
			var shape := String(params.get("shape", "rectangle"))
			result["width"] = shape == "rectangle"
			result["height"] = shape == "rectangle"
			result["size"] = shape == "square"
			result["radius"] = shape == "hexagon"
			result["toric"] = shape != "hexagon"
		HexGenerationNodeTypesScript.NODE_REGION_FILTER:
			var mode := String(params.get("mode", "floor"))
			result["item_key"] = mode != "query"
			result["op"] = mode == "query"
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR:
			var mode := String(params.get("mode", "weighted"))
			result["placement_probability"] = mode == "weighted"
		HexGenerationNodeTypesScript.NODE_SOURCE:
			var kind := String(params.get("kind", "provided"))
			result["source_key"] = kind == "provided" or kind == "context"
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
