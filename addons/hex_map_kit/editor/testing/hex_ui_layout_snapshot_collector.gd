@tool
class_name HexUILayoutSnapshotCollector
extends RefCounted


static func collect(root: Control, options: Dictionary = {}) -> Dictionary:
	var scenario_id := String(options.get("scenario_id", "unspecified"))
	var default_viewport_size := root.size if root != null else Vector2.ZERO
	var viewport_size: Vector2 = options.get("viewport_size", default_viewport_size)
	var controls: Array[Dictionary] = []
	if root != null:
		root.force_update_transform()
		_collect_visible_controls(root, root, controls)
	return {
		"schema": "hex_ui_layout_snapshot.v1",
		"scenario_id": scenario_id,
		"viewport_size": _vector2_dict(viewport_size),
		"root_class": root.get_class() if root != null else "",
		"root_name": root.name if root != null else "",
		"control_count": controls.size(),
		"controls": controls,
	}


static func snapshot_to_json(snapshot: Dictionary) -> String:
	return JSON.stringify(snapshot, "\t")


static func _collect_visible_controls(root: Control, node: Node, controls: Array[Dictionary]) -> void:
	if node is Control:
		var control := node as Control
		if control.is_visible_in_tree():
			controls.append(_control_snapshot(root, control))
	for child in node.get_children():
		_collect_visible_controls(root, child, controls)


static func _control_snapshot(root: Control, control: Control) -> Dictionary:
	var rect := control.get_global_rect()
	var minimum := control.get_combined_minimum_size()
	return {
		"path": _control_path(root, control),
		"name": control.name,
		"class": control.get_class(),
		"script": _script_path(control),
		"visible": control.is_visible_in_tree(),
		"rect": _rect2_dict(rect),
		"minimum_size": _vector2_dict(minimum),
		"text": _control_text(control),
		"base_type": _control_base_type(control),
		"tooltip": control.tooltip_text,
		"scroll_parent": _scroll_parent_path(root, control),
		"metadata": _metadata(control),
	}


static func _control_path(root: Control, control: Control) -> String:
	if root == control:
		return "."
	return str(root.get_path_to(control))


static func _script_path(control: Control) -> String:
	var script = control.get_script()
	if script is Resource:
		return String((script as Resource).resource_path)
	return ""


static func _control_text(control: Control) -> String:
	if control is Label:
		return (control as Label).text
	if control is Button:
		return (control as Button).text
	if control is LineEdit:
		return (control as LineEdit).text
	if control is TextEdit:
		return (control as TextEdit).text
	if control is OptionButton:
		var option := control as OptionButton
		if option.selected >= 0 and option.selected < option.item_count:
			return option.get_item_text(option.selected)
	return ""


static func _control_base_type(control: Control) -> String:
	if control.get_class() != "EditorResourcePicker":
		return ""
	var value = control.get("base_type")
	return "" if value == null else String(value)


static func _scroll_parent_path(root: Control, control: Control) -> String:
	var current := control.get_parent()
	while current != null:
		if current is ScrollContainer:
			return _control_path(root, current as Control)
		current = current.get_parent()
	return ""


static func _metadata(control: Control) -> Dictionary:
	var result := {}
	for key in control.get_meta_list():
		result[String(key)] = _jsonable(control.get_meta(key))
	return result


static func _jsonable(value: Variant) -> Variant:
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
			return value
		TYPE_VECTOR2:
			return _vector2_dict(value)
		TYPE_VECTOR2I:
			return {"x": value.x, "y": value.y}
		TYPE_RECT2:
			return _rect2_dict(value)
		TYPE_PACKED_STRING_ARRAY:
			var array: Array[String] = []
			for entry in value:
				array.append(String(entry))
			return array
		TYPE_ARRAY:
			var array: Array = []
			for entry in value:
				array.append(_jsonable(entry))
			return array
		TYPE_DICTIONARY:
			var dict := {}
			for key in value.keys():
				dict[String(key)] = _jsonable(value[key])
			return dict
		TYPE_OBJECT:
			if value == null:
				return null
			return {"object_class": (value as Object).get_class()}
		_:
			return str(value)


static func _vector2_dict(value: Vector2) -> Dictionary:
	return {
		"x": value.x,
		"y": value.y,
	}


static func _rect2_dict(value: Rect2) -> Dictionary:
	return {
		"x": value.position.x,
		"y": value.position.y,
		"w": value.size.x,
		"h": value.size.y,
	}
