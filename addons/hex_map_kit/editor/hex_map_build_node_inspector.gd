@tool
class_name HexMapBuildNodeInspector
extends VBoxContainer

signal node_params_changed(node_id: String, params: Dictionary)
signal promote_requested(node_id: String, role: String)

const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const HexGenerationPortsScript = preload("res://addons/hex_map_kit/generation/hex_generation_ports.gd")
const HexMapGeneratorScript = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")

# Markov reference-frame direction id whose generation step is +q. The Hex Panel
# pins every reference-count preview to this direction so the ">" arrow always
# points at +q regardless of reference count.
const MARKOV_REFERENCE_FRAME_GENERATION_DIRECTION_ID := 4
const MARKOV_WEIGHT_SPIN_FONT_SIZE := 20
const MARKOV_WEIGHT_SPIN_MINIMUM_SIZE := Vector2(76, 34)
const ADJACENCY_PROBABILITY_SPIN_MINIMUM_SIZE := Vector2(78, 30)
const ADJACENCY_PATTERN_HOVER_TINT := Color(0.5, 0.5, 0.5)
const ADJACENCY_PATTERN_HOVER_TINT_WEIGHT := 0.6

var _node_id := ""
var _node_type := ""
var _last_built_node_id := ""
var _params: Dictionary = {}
var _resource_refs: Dictionary = {}
var _output_type := ""
var _preview_available := false
var _promote_enabled := false
var _connection_warnings: Array[Dictionary] = []
var _effective_flat_top := true
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
	_migrate_params()
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
	_ensure_params_for_changed_value(key, value)
	_refresh_param_controls()
	node_params_changed.emit(_node_id, _params.duplicate(true))


func set_promote_enabled(enabled: bool) -> void:
	_promote_enabled = enabled
	if _promote_button != null:
		_promote_button.disabled = not _promote_enabled or _output_type == "" or (not _preview_available and _output_type != HexGenerationPortsScript.RESULT)


func set_effective_flat_top(flat_top: bool) -> void:
	_effective_flat_top = flat_top
	if _node_type == HexGenerationNodeTypesScript.NODE_REGION_FILTER or _node_type == HexGenerationNodeTypesScript.NODE_TERRAIN_FILTER:
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
	for role in ["terrain", "overlay", "object", "result"]:
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
	_promote_button.disabled = not _promote_enabled or _output_type == "" or (not _preview_available and _output_type != HexGenerationPortsScript.RESULT)


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
		var control
		if key == "item_pool":
			control = _build_item_pool_editor()
		elif key == "shift_offset":
			control = _build_shift_hex_pad()
		elif key == "custom_distribution":
			control = _build_markov_distribution_editor()
		elif key == "probability_rules":
			control = _build_adjacency_rules_editor()
		else:
			control = _create_param_control(key, _params.get(key, _param_default(key, _node_type)))
		_params_container.add_child(row)
		if control != null:
			if key == "item_pool":
				_params_container.add_child(control)
				control.visible = bool(visibility.get(key, true))
			else:
				row.add_child(control)
			_param_controls[key] = {"row": row, "control": control}
		
		row.visible = bool(visibility.get(key, true))


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
		if String(opt.get("value", "")) == str(current_value):
			selected_index = i
	if selected_index >= 0:
		control.select(selected_index)
	elif options.size() > 0:
		control.select(0)
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


func _build_item_pool_editor() -> VBoxContainer:
	var container := VBoxContainer.new()
	container.name = "ItemPoolEditor"
	var entries: Array = _params.get("item_pool", [])
	if not entries is Array:
		entries = []
	var add_button := Button.new()
	add_button.text = "+ Add"
	add_button.pressed.connect(func():
		var new_entry := {"name": "entry_%d" % entries.size(), "weight": 1.0}
		entries.append(new_entry)
		_params["item_pool"] = entries
		_commit_item_pool()
		_refresh_item_pool_rows(container, entries)
	)
	container.add_child(add_button)
	_refresh_item_pool_rows(container, entries)
	return container


func _refresh_item_pool_rows(container: VBoxContainer, entries: Array) -> void:
	for i in range(container.get_child_count() - 1, -1, -1):
		var child = container.get_child(i)
		if child is Button:
			continue
		container.remove_child(child)
		child.queue_free()
	for i in range(entries.size()):
		var entry = entries[i] as Dictionary
		var row := HBoxContainer.new()
		row.name = "ItemPoolRow_%d" % i
		var name_edit := LineEdit.new()
		name_edit.text = String(entry.get("name", ""))
		name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_edit.text_changed.connect(func(new_text: String):
			entry["name"] = new_text
			_commit_item_pool()
		)
		row.add_child(name_edit)
		var weight_label := Label.new()
		weight_label.text = "weight:"
		row.add_child(weight_label)
		var weight_spin := SpinBox.new()
		weight_spin.min_value = 0.0
		weight_spin.max_value = 1.0
		weight_spin.step = 0.05
		weight_spin.value = clampf(float(entry.get("weight", 1.0)), 0.0, 1.0)
		weight_spin.value_changed.connect(func(v: float):
			entry["weight"] = v
			_commit_item_pool()
		)
		row.add_child(weight_spin)
		var remove_button := Button.new()
		remove_button.text = "-"
		var row_index := i
		remove_button.pressed.connect(func():
			entries.remove_at(row_index)
			_params["item_pool"] = entries
			_commit_item_pool()
			_refresh_item_pool_rows(container, entries)
		)
		row.add_child(remove_button)
		container.add_child(row)
		container.move_child(row, container.get_child_count() - 1)


func _commit_item_pool() -> void:
	if _node_id == "":
		return
	node_params_changed.emit(_node_id, _params.duplicate(true))


func _build_shift_hex_pad() -> VBoxContainer:
	var container := VBoxContainer.new()
	container.name = "ShiftHexPad"
	var panel := HexCellButtonPanel.new()
	panel.name = "ShiftHexCellPanel"
	panel.cell_pressed.connect(_on_shift_cell_pressed)
	panel.custom_minimum_size = Vector2(160, 140)
	container.add_child(panel)
	var info_row := HBoxContainer.new()
	var offset_label := Label.new()
	offset_label.name = "ShiftOffsetLabel"
	_refresh_shift_offset_label(offset_label)
	info_row.add_child(offset_label)
	var reset_button := Button.new()
	reset_button.text = "Reset"
	reset_button.pressed.connect(func():
		_params["shift_q"] = 0
		_params["shift_r"] = 0
		_params["shift_s"] = 0
		_refresh_shift_offset_label(offset_label)
		_refresh_shift_hex_panel(panel)
		_commit_shift_params()
	)
	info_row.add_child(reset_button)
	container.add_child(info_row)
	_refresh_shift_hex_panel(panel)
	return container


func _refresh_shift_hex_panel(panel: HexCellButtonPanel) -> void:
	var sq := int(_params.get("shift_q", 0))
	var sr := int(_params.get("shift_r", 0))
	var ss := int(_params.get("shift_s", 0))
	var offset_vec := HexVector.new()
	offset_vec.q = sq
	offset_vec.r = sr
	offset_vec.s = ss
	var direction_labels := {}
	var direction_metadata := {}
	var pressable := {}
	for direction in HexVector.directions():
		var key = direction.key()
		direction_labels[key] = _hex_direction_short_label(direction)
		direction_metadata[key] = {"direction": direction}
		pressable[key] = true
	direction_labels[HexVector.zero().key()] = "(%d,%d,%d)" % [sq, sr, ss]
	panel.configure({
		"shape_kind": "directions",
		"flat_top": _effective_flat_top,
		"cell_radius": 14.0,
		"cell_gap": 1.0,
		"padding": Vector2(6, 6),
		"center_cell": HexVector.zero(),
		"pressable_cells": pressable,
		"label_by_cell": direction_labels,
		"metadata_by_cell": direction_metadata,
	})


func _on_shift_cell_pressed(entry: Dictionary) -> void:
	var metadata: Dictionary = entry.get("metadata", {})
	var direction = metadata.get("direction", null)
	if direction == null:
		return
	var sq := int(_params.get("shift_q", 0))
	var sr := int(_params.get("shift_r", 0))
	var ss := int(_params.get("shift_s", 0))
	var current := HexVector.new()
	current.q = sq
	current.r = sr
	current.s = ss
	var moved = current.add(direction)
	_params["shift_q"] = moved.q
	_params["shift_r"] = moved.r
	_params["shift_s"] = moved.s
	_commit_shift_params()
	if _param_controls.has("shift_offset"):
		var entry_ctrl = _param_controls["shift_offset"] as Dictionary
		var container = entry_ctrl.get("control", null) as VBoxContainer
		if container != null:
			for child in container.get_children():
				if child is HexCellButtonPanel:
					_refresh_shift_hex_panel(child as HexCellButtonPanel)
					break
			var label = _find_shift_offset_label(container)
			if label != null:
				_refresh_shift_offset_label(label)


func _refresh_shift_offset_label(label: Label) -> void:
	var sq := int(_params.get("shift_q", 0))
	var sr := int(_params.get("shift_r", 0))
	var ss := int(_params.get("shift_s", 0))
	label.text = "offset: (%d, %d, %d)" % [sq, sr, ss]


func _find_shift_offset_label(container: VBoxContainer) -> Label:
	for child in container.get_children():
		if child is HBoxContainer:
			for sub in (child as HBoxContainer).get_children():
				if sub is Label and sub.name == "ShiftOffsetLabel":
					return sub as Label
	return null


func _commit_shift_params() -> void:
	if _node_id == "":
		return
	node_params_changed.emit(_node_id, _params.duplicate(true))


func _build_markov_distribution_editor() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "MarkovDistributionEditor"
	var summary := Label.new()
	summary.name = "MarkovDistributionSummary"
	var values = _params.get("custom_distribution", {})
	summary.text = "custom distribution: %s" % ("configured" if values is Dictionary and not (values as Dictionary).is_empty() else "preset")
	row.add_child(summary)
	var button := Button.new()
	button.name = "OpenMarkovDistributionEditor"
	button.text = "Edit Distribution"
	button.pressed.connect(func():
		_open_markov_distribution_dialog(summary)
	)
	row.add_child(button)
	return row

func _build_row_by_refcount(refcount: int, weights: Array) -> Dictionary:
	var row_box := HBoxContainer.new()
	row_box.add_theme_constant_override("separation", 16)

	var spin_list: Array[SpinBox] = []
	var states: int = 1 << refcount

	for index in range(states):
		var state_box := VBoxContainer.new()
		state_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		state_box.add_theme_constant_override("separation", 4)

		var panel := _markov_state_panel(refcount, index, float(weights[index]))
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		state_box.add_child(panel)

		var spin := SpinBox.new()
		spin.min_value = 0.0
		spin.max_value = 8.0
		spin.step = 0.5
		spin.value = float(weights[index])
		_configure_numeric_spinbox(spin, MARKOV_WEIGHT_SPIN_FONT_SIZE, MARKOV_WEIGHT_SPIN_MINIMUM_SIZE)
		spin.value_changed.connect(func(value: float):
			_refresh_markov_panel_weight(panel, value)
		)

		state_box.add_child(_spinbox_value_centered_row(spin))

		row_box.add_child(state_box)
		spin_list.append(spin)

	return {"row": row_box, "spins": spin_list}


func _configure_numeric_spinbox(spin: SpinBox, font_size: int, minimum_size: Vector2) -> void:
	spin.custom_minimum_size = minimum_size
	spin.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	spin.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	spin.add_theme_font_size_override("font_size", font_size)
	var line_edit := spin.get_line_edit()
	line_edit.custom_minimum_size.x = maxf(0.0, minimum_size.x - 20.0)
	line_edit.add_theme_font_size_override("font_size", font_size)
	line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER


func _spinbox_value_centered_row(spin: SpinBox) -> HBoxContainer:
	var spin_row := HBoxContainer.new()
	spin_row.add_theme_constant_override("separation", 0)
	spin_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var left_spacer := Control.new()
	left_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spin_row.add_child(left_spacer)
	spin_row.add_child(spin)

	# A SpinBox includes a right-side spinner area. The visual value box is the
	# LineEdit, so mirror that spinner width on the left to make the row center
	# equal the value-box center (and therefore align with the HexCellButton
	# center above it).
	var update_spacer := func():
		var le := spin.get_line_edit()
		var spinner_w := spin.size.x - le.size.x
		left_spacer.custom_minimum_size.x = maxf(0.0, spinner_w)
	spin.resized.connect(update_spacer)
	spin.get_line_edit().resized.connect(update_spacer)
	update_spacer.call_deferred()
	return spin_row


func _open_markov_distribution_dialog(summary_label: Label = null) -> void:
	var dialog := AcceptDialog.new()
	dialog.name = "Markov Distribution Window"
	dialog.title = "Markov Mesh Distribution"
	var body := VBoxContainer.new()
	var help := Label.new()
	help.text = "Set wall probability weight (0..8). Blue > marks the fixed generation step; 0/1/2 are the reference bit order."
	body.add_child(help)
	var current := _markov_distribution_values_by_count()
	var spins_by_count := {}

	var row_0 := _build_row_by_refcount(0, current["0"] as Array)
	var row_1 := _build_row_by_refcount(1, current["1"] as Array)
	var row_2 := _build_row_by_refcount(2, current["2"] as Array)
	var row_3 := _build_row_by_refcount(3, current["3"] as Array)

	var count_label := Label.new()
	count_label.text = "main cases"
	body.add_child(count_label)
	body.add_child(row_3["row"])

	var count_label_2 := Label.new()
	count_label_2.text = "edge cases (0, 1, 2 references)"
	body.add_child(count_label_2)
	body.add_child(row_0["row"])
	body.add_child(row_1["row"])
	body.add_child(row_2["row"])

	spins_by_count["0"] = row_0["spins"]
	spins_by_count["1"] = row_1["spins"]
	spins_by_count["2"] = row_2["spins"]
	spins_by_count["3"] = row_3["spins"]

	dialog.add_child(body)
	dialog.confirmed.connect(func():
		var values := {}
		for count in [0, 1, 2, 3]:
			var key := str(count)
			var count_values: Array = []
			for spin in (spins_by_count[key] as Array):
				count_values.append(clampf(float((spin as SpinBox).value), 0.0, 8.0))
			values[key] = count_values
		_params["custom_distribution"] = values
		if summary_label != null:
			summary_label.text = "custom distribution: configured"
		if _node_id != "":
			node_params_changed.emit(_node_id, _params.duplicate(true))
		dialog.queue_free()
	)
	dialog.canceled.connect(func():
		dialog.queue_free()
	)
	add_child(dialog)
	dialog.popup_centered(Vector2i(760, 620))


func _markov_distribution_values_by_count() -> Dictionary:
	var values = _params.get("custom_distribution", {})
	var result := {}
	for count in [0, 1, 2, 3]:
		var key := str(count)
		var size: int = 1 << count
		var raw = (values as Dictionary).get(key, []) if values is Dictionary else []
		if raw is Array and (raw as Array).size() >= size:
			result[key] = (raw as Array).slice(0, size)
		else:
			result[key] = _markov_default_weights(count)
	return result


func _markov_default_weights(reference_count: int) -> Array:
	match reference_count:
		3:
			return [5.0, 3.0, 3.0, 5.0, 3.0, 7.0, 5.0, 1.0]
		2:
			return [7.0, 5.0, 3.0, 1.0]
		1:
			return [5.0, 2.0]
		0, _:
			return [0.0]


func _markov_weight_fill(weight: float) -> Color:
	var shade := 1.0 - clampf(weight / 8.0, 0.0, 1.0)
	return Color(shade, shade, shade)


func _refresh_markov_panel_weight(panel: HexCellButtonPanel, weight: float) -> void:
	var fill := _markov_weight_fill(weight)
	panel.update_cell(HexVector.zero(), {
		"label": "%.1f" % weight,
		"fill_color": fill,
		"label_color": _contrasting_label_color(fill),
	})


func _probability_fill(probability: float) -> Color:
	var shade := 1.0 - clampf(probability, 0.0, 1.0)
	return Color(shade, shade, shade)


func _markov_reference_visual_slots(reference_count: int) -> Array:
	if reference_count == 2:
		return [
			{"bit": 0, "cell": HexVector.q_axis().negated()},
			{"bit": 1, "cell": HexVector.r_axis().negated()},
		]
	if reference_count == 1:
		return [
			{"bit": 0, "cell": HexVector.r_axis().negated()},
		]
	var frame := HexMapGeneratorScript.markov_distribution_reference_frame(_markov_reference_frame_direction_id(reference_count), reference_count)
	var cells: Array = frame.get("reference_directions", [])
	var result := []
	for bit in range(min(reference_count, 3)):
		if bit >= cells.size():
			break
		result.append({"bit": bit, "cell": cells[bit]})
	return result


func _markov_reference_frame_direction_id(reference_count: int) -> int:
	# Align every reference-count panel (1/2/3) to a single, fixed generation
	# direction so the Hex Panel reads consistently. The generation arrow (">")
	# points at +q. The 2-reference panel uses the border-start endpoint
	# geometry: bit 0 is directly behind +q, while bit 1 is the non-adjacent
	# toric reference across the border.
	return MARKOV_REFERENCE_FRAME_GENERATION_DIRECTION_ID


func _markov_state_panel(reference_count: int, state_index: int, weight: float) -> HexCellButtonPanel:
	var panel := HexCellButtonPanel.new()
	var labels := {}
	var metadata := {}
	var pressable := {}
	var frame := HexMapGeneratorScript.markov_distribution_reference_frame(_markov_reference_frame_direction_id(reference_count), reference_count)
	var generation_direction = frame.get("generation_direction", null)
	var shape_cells := [HexVector.zero()]
	if generation_direction != null:
		var generation_key: String = generation_direction.key()
		shape_cells.append(generation_direction)
		labels[generation_key] = ">"
		metadata[generation_key] = {
			"icon_name": "ArrowRight",
			"icon_theme_type": "EditorIcons",
			"icon_only": true,
			"icon_scale": 2.0,
			"icon_orient_to_anchor": true,
			"icon_modulate": Color.WHITE,
		}
		pressable[generation_key] = false
	for slot in _markov_reference_visual_slots(reference_count):
		var i := int((slot as Dictionary).get("bit", 0))
		var direction = (slot as Dictionary).get("cell", null)
		if direction == null:
			continue
		var key: String = direction.key()
		var is_wall := (state_index & (1 << i)) != 0
		var fill := Color.BLACK if is_wall else Color.WHITE
		shape_cells.append(direction)
		labels[key] = str(i)
		metadata[key] = {
			"fill_color": fill,
			"label_color": _contrasting_label_color(fill),
		}
		pressable[key] = false
	var center_key: String = HexVector.zero().key()
	var center_fill := _markov_weight_fill(weight)
	labels[center_key] = "%.1f" % weight
	metadata[center_key] = {
		"fill_color": center_fill,
		"label_color": _contrasting_label_color(center_fill),
	}
	var padding_size := 0.0 if reference_count == 3 else 12.0

	panel.configure({
		"shape_kind": "custom",
		"shape_cells": shape_cells,
		"flat_top": _effective_flat_top,
		"cell_radius": 16.0,
		"cell_gap": 0.0,
		"padding": Vector2(padding_size, padding_size),
		"center_cell": HexVector.zero(),
        "symmetric_about_anchor": true,
		"pressable_cells": pressable,
		"label_by_cell": labels,
		"metadata_by_cell": metadata,
		"show_labels": false,
	})
	return panel


func _contrasting_label_color(fill: Color) -> Color:
	var luminance := fill.r * 0.299 + fill.g * 0.587 + fill.b * 0.114
	return Color(0.08, 0.08, 0.09) if luminance > 0.55 else Color(0.92, 0.94, 0.98)


func _build_adjacency_rules_editor() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "AdjacencyRulesEditor"
	var summary := Label.new()
	summary.name = "AdjacencyRulesSummary"
	summary.text = _adjacency_rules_summary()
	row.add_child(summary)
	var button := Button.new()
	button.name = "OpenAdjacencyRulesEditor"
	button.text = "Edit Rules"
	button.pressed.connect(func():
		_open_adjacency_rules_dialog(summary)
	)
	row.add_child(button)
	return row


func _open_adjacency_rules_dialog(summary_label: Label = null) -> void:
	var dialog := AcceptDialog.new()
	dialog.name = "Adjacency Rules Window"
	dialog.title = "Adjacency Rules"
	var body := VBoxContainer.new()
	var help := Label.new()
	help.text = "Each pattern is a neighbor mask centered on the generated cell. Toggle cells: black = reference present, white = absent. Center darkness = wall probability."
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(help)
	var patterns: Array = _adjacency_patterns()
	var patterns_box := VBoxContainer.new()
	patterns_box.name = "AdjacencyRulesPatternList"
	body.add_child(patterns_box)
	var rebuild := func(): pass
	rebuild = func():
		for child in patterns_box.get_children():
			patterns_box.remove_child(child)
			child.queue_free()
		for pattern_index in range(patterns.size()):
			patterns_box.add_child(_adjacency_pattern_row(patterns, pattern_index, rebuild))
	rebuild.call()
	var add_button := Button.new()
	add_button.name = "AddAdjacencyPattern"
	add_button.text = "Add Pattern"
	add_button.pressed.connect(func():
		patterns.append({"directions": [], "probability": 0.5})
		rebuild.call()
	)
	body.add_child(add_button)
	var default_spin := SpinBox.new()
	default_spin.name = "AdjacencyDefaultProbability"
	default_spin.min_value = 0.0
	default_spin.max_value = 1.0
	default_spin.step = 0.05
	default_spin.value = _adjacency_default_probability()
	body.add_child(_labeled_control("Default probability", default_spin))
	dialog.add_child(body)
	dialog.confirmed.connect(func():
		var rules: Array = []
		for pattern in patterns:
			var directions = (pattern as Dictionary).get("directions", [])
			rules.append({
				"directions": directions,
				"component_sizes": _component_sizes_from_directions(directions if directions is Array else []),
				"probability": float((pattern as Dictionary).get("probability", 0.5)),
			})
		_params["probability_rules"] = {
			"default": clampf(float(default_spin.value), 0.0, 1.0),
			"rules": rules,
		}
		if summary_label != null:
			summary_label.text = _adjacency_rules_summary()
		if _node_id != "":
			node_params_changed.emit(_node_id, _params.duplicate(true))
		dialog.queue_free()
	)
	dialog.canceled.connect(func():
		dialog.queue_free()
	)
	add_child(dialog)
	dialog.popup_centered(Vector2i(560, 640))


func _adjacency_pattern_row(patterns: Array, pattern_index: int, rebuild: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "AdjacencyPatternRow_%d" % pattern_index
	var pattern := patterns[pattern_index] as Dictionary
	var present := {}
	for key in (pattern.get("directions", []) as Array):
		present[String(key)] = true
	var panel := HexCellButtonPanel.new()
	panel.name = "AdjacencyPatternPanel_%d" % pattern_index
	panel.custom_minimum_size = Vector2(120, 110)
	var labels := {}
	var metadata := {}
	var pressable := {}
	var toggle_cells := {}
	for direction in HexVector.directions():
		var key: String = direction.key()
		labels[key] = ""
		metadata[key] = {
			"direction": key,
			"toggle_on_fill": Color.BLACK,
			"toggle_off_fill": Color.WHITE,
			"fill_color": Color.BLACK if present.has(key) else Color.WHITE,
			"hover_tint_color": ADJACENCY_PATTERN_HOVER_TINT,
			"hover_tint_weight": ADJACENCY_PATTERN_HOVER_TINT_WEIGHT,
			"hover_fill_enabled": true,
		}
		pressable[key] = true
		toggle_cells[key] = present.has(key)
	var center_key: String = HexVector.zero().key()
	var probability := float(pattern.get("probability", 0.5))
	var probability_fill := _probability_fill(probability)
	labels[center_key] = "%.2f" % probability
	metadata[center_key] = {
		"fill_color": probability_fill,
		"label_color": _contrasting_label_color(probability_fill),
		"hover_fill_enabled": false,
	}
	panel.configure({
		"shape_kind": "directions",
		"flat_top": _effective_flat_top,
		"cell_radius": 16.0,
		"cell_gap": 0.0,
		"padding": Vector2(4, 4),
		"center_cell": HexVector.zero(),
		"pressable_cells": pressable,
		"toggle_cells": toggle_cells,
		"label_by_cell": labels,
		"metadata_by_cell": metadata,
		"show_labels": true,
	})
	panel.cell_toggled.connect(func(entry: Dictionary, pressed: bool):
		var direction_key = String((entry.get("metadata", {}) as Dictionary).get("direction", ""))
		if direction_key == "":
			return
		var dirs: Array = (patterns[pattern_index] as Dictionary).get("directions", [])
		if not pressed and dirs.has(direction_key):
			dirs.erase(direction_key)
		elif pressed and not dirs.has(direction_key):
			dirs.append(direction_key)
		(patterns[pattern_index] as Dictionary)["directions"] = dirs
	)
	row.add_child(panel)
	var prob_spin := SpinBox.new()
	prob_spin.min_value = 0.0
	prob_spin.max_value = 1.0
	prob_spin.step = 0.05
	prob_spin.value = float(pattern.get("probability", 0.5))
	_configure_numeric_spinbox(prob_spin, 20, ADJACENCY_PROBABILITY_SPIN_MINIMUM_SIZE)
	prob_spin.value_changed.connect(func(v: float):
		(patterns[pattern_index] as Dictionary)["probability"] = v
		var next_probability_fill := _probability_fill(v)
		panel.update_cell(HexVector.zero(), {
			"label": "%.2f" % v,
			"fill_color": next_probability_fill,
			"label_color": _contrasting_label_color(next_probability_fill),
		})
	)
	row.add_child(_labeled_control("Probability", prob_spin))
	var remove_button := Button.new()
	remove_button.text = "Remove"
	remove_button.pressed.connect(func():
		patterns.remove_at(pattern_index)
		rebuild.call()
	)
	row.add_child(remove_button)
	return row


func _component_sizes_from_directions(direction_keys: Array) -> Array:
	var cells: Array = []
	for direction in HexVector.directions():
		if direction_keys.has(direction.key()):
			cells.append(direction)
	var remaining := {}
	for cell in cells:
		remaining[cell.key()] = cell
	var sizes: Array = []
	for cell in cells:
		if not remaining.has(cell.key()):
			continue
		var size := 0
		var stack: Array = [cell]
		remaining.erase(cell.key())
		while not stack.is_empty():
			var current = stack.pop_back()
			size += 1
			for other in cells:
				if not remaining.has(other.key()):
					continue
				if _hex_cells_adjacent(current, other):
					remaining.erase(other.key())
					stack.append(other)
		sizes.append(size)
	sizes.sort()
	return sizes


func _hex_cells_adjacent(a, b) -> bool:
	var delta = a.subtract(b)
	for direction in HexVector.directions():
		if delta.key() == direction.key():
			return true
	return false


func _labeled_control(label_text: String, control: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(160, 0)
	row.add_child(label)
	row.add_child(control)
	return row


func _adjacency_rules_summary() -> String:
	var value = _params.get("probability_rules", {})
	if value is Dictionary:
		var rules = (value as Dictionary).get("rules", []) as Array
		return "hex patterns: %d" % rules.size()
	return "preset/text rule"


func _adjacency_patterns() -> Array:
	var value = _params.get("probability_rules", {})
	if value is Dictionary:
		var rules = (value as Dictionary).get("rules", []) as Array
		if not rules.is_empty():
			return rules.duplicate(true)
	return [{"directions": [], "probability": 0.5}]


func _adjacency_default_probability() -> float:
	var value = _params.get("probability_rules", {})
	if value is Dictionary:
		return clampf(float((value as Dictionary).get("default", 0.0)), 0.0, 1.0)
	return 0.0


func _hex_direction_short_label(direction: HexVector) -> String:
	if direction.q == 1 and direction.r == 0:
		return "+Q"
	if direction.q == 0 and direction.r == -1:
		return "-R"
	if direction.q == -1 and direction.r == 1:
		return "+S"
	if direction.q == -1 and direction.r == 0:
		return "-Q"
	if direction.q == 0 and direction.r == 1:
		return "+R"
	if direction.q == 1 and direction.r == -1:
		return "-S"
	return "?"


func _param_control_type(node_type: String, key: String) -> String:
	match key:
		"shape", "method", "wall_method", "filter_target", "placement_method", "kind", "write_policy", "existing_policy", "op", "output_type", "distribution_id", "distribution_mode", "operation", "orientation":
			return "option"
		"wall_probability", "placement_probability":
			return "spin_float"
		"width", "height", "size", "radius", "seed", "neighbor_radius":
			return "spin_int"
		"toric", "include_generated_reference":
			return "check"
		"source_key", "item_key", "selectors", "probability_rules":
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
		"wall_method":
			return [
				{"label": "Random Probability", "value": "random_probability"},
				{"label": "Markov Mesh", "value": "markov_mesh"},
			]
		"filter_target":
			if node_type == HexGenerationNodeTypesScript.NODE_OVERLAY_FILTER:
				return [
					{"label": "Item Key", "value": "item_key"},
				]
			if node_type == HexGenerationNodeTypesScript.NODE_TERRAIN_FILTER:
				return [
					{"label": "Floor", "value": "floor"},
					{"label": "Wall", "value": "wall"},
					{"label": "Any", "value": "any"},
				]
			return [
				{"label": "Floor", "value": "floor"},
				{"label": "Wall", "value": "wall"},
				{"label": "Any", "value": "any"},
				{"label": "Item Key", "value": "item_key"},
			]
		"placement_method":
			return [
				{"label": "Weighted", "value": "weighted"},
				{"label": "Limited", "value": "limited"},
				{"label": "Adjacency Rules", "value": "adjacency_rules"},
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
		"distribution_id":
			return [
				{"label": "Ilands", "value": "11"},
				{"label": "Maze", "value": "20"},
				{"label": "Discrete", "value": "24"},
			]
		"distribution_mode":
			return [
				{"label": "Preset", "value": "preset"},
				{"label": "Custom", "value": "custom"},
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
		"orientation":
			return [
				{"label": "Flat Top", "value": "0"},
				{"label": "Pointy Top", "value": "1"},
			]
		"operation":
			return [
				{"label": "Union (A ∪ B)", "value": "union"},
				{"label": "Intersection (A ∩ B)", "value": "intersection"},
				{"label": "Difference (A \\ B)", "value": "difference"},
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
		"width", "height", "size", "radius", "seed", "neighbor_radius":
			return 1.0
		_:
			return fallback


func _param_default(key: String, node_type: String) -> Variant:
	match key:
		"shape":
			return "rectangle"
		"width":
			return HexGenerationNodeTypesScript.DEFAULT_RECTANGLE_WIDTH
		"height":
			return HexGenerationNodeTypesScript.DEFAULT_RECTANGLE_HEIGHT
		"size":
			return HexGenerationNodeTypesScript.DEFAULT_SQUARE_SIZE
		"radius":
			return HexGenerationNodeTypesScript.DEFAULT_HEXAGON_RADIUS
		"toric":
			return false
		"wall_probability":
			return 0.3
		"distribution_id":
			return 20
		"wall_method":
			return "random_probability"
		"filter_target":
			return "floor"
		"placement_method":
			return "weighted"
		"placement_probability":
			return 0.5
		"probability_rules":
			return "default=0.5"
		"neighbor_radius":
			return 1
		"include_generated_reference":
			return false
		"operation":
			return "union"
		"orientation":
			return 0
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
		HexGenerationNodeTypesScript.NODE_REGION_FILTER, HexGenerationNodeTypesScript.NODE_TERRAIN_FILTER, HexGenerationNodeTypesScript.NODE_OVERLAY_FILTER:
			var ft := String(params.get("filter_target", params.get("mode", "floor")))
			result["item_key"] = ft == "item_key"
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR:
			var pm := String(params.get("placement_method", params.get("mode", "weighted")))
			result["placement_probability"] = pm == "weighted"
			result["probability_rules"] = pm == "adjacency_rules"
			result["neighbor_radius"] = pm == "adjacency_rules"
			result["include_generated_reference"] = pm == "adjacency_rules"
		HexGenerationNodeTypesScript.NODE_SOURCE:
			var kind := String(params.get("kind", "provided"))
			result["source_key"] = kind == "provided" or kind == "context"
		HexGenerationNodeTypesScript.NODE_WALL_FIELD:
			var wm := String(params.get("wall_method", params.get("mode", "random_probability")))
			var distribution_mode := String(params.get("distribution_mode", "preset"))
			result["wall_probability"] = wm != "markov_mesh"
			result["distribution_mode"] = wm == "markov_mesh"
			result["distribution_id"] = wm == "markov_mesh" and distribution_mode != "custom"
			result["custom_distribution"] = wm == "markov_mesh" and distribution_mode == "custom"
	return result


func _param_keys_for_type(node_type: String) -> Array:
	match node_type:
		HexGenerationNodeTypesScript.NODE_SOURCE:
			return ["kind", "source_key", "output_type"]
		HexGenerationNodeTypesScript.NODE_SHAPE:
			return ["shape", "width", "height", "size", "radius", "toric"]
		HexGenerationNodeTypesScript.NODE_WALL_FIELD:
			return ["wall_method", "wall_probability", "distribution_mode", "distribution_id", "custom_distribution", "seed"]
		HexGenerationNodeTypesScript.NODE_CONNECTIVITY:
			return ["method", "seed"]
		HexGenerationNodeTypesScript.NODE_REGION_FILTER, HexGenerationNodeTypesScript.NODE_TERRAIN_FILTER, HexGenerationNodeTypesScript.NODE_OVERLAY_FILTER:
			return ["filter_target", "item_key", "shift_offset"]
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR:
			return ["placement_method", "placement_probability", "item_pool", "probability_rules", "neighbor_radius", "include_generated_reference", "seed"]
		HexGenerationNodeTypesScript.NODE_COMPOSE:
			return ["write_policy", "existing_policy"]
		HexGenerationNodeTypesScript.NODE_SET_OPERATION:
			return ["operation"]
		HexGenerationNodeTypesScript.NODE_RESULT:
			return ["orientation"]
	return []


func _ensure_params_for_changed_value(key: String, value: Variant) -> void:
	if _node_type != HexGenerationNodeTypesScript.NODE_SHAPE or key != "shape":
		return
	match String(value):
		"square":
			if not _params.has("size"):
				_params["size"] = HexGenerationNodeTypesScript.DEFAULT_SQUARE_SIZE
		"hexagon":
			if not _params.has("radius"):
				_params["radius"] = HexGenerationNodeTypesScript.DEFAULT_HEXAGON_RADIUS
		"rectangle":
			if not _params.has("width"):
				_params["width"] = HexGenerationNodeTypesScript.DEFAULT_RECTANGLE_WIDTH
			if not _params.has("height"):
				_params["height"] = HexGenerationNodeTypesScript.DEFAULT_RECTANGLE_HEIGHT


func _resource_ref_fields_for_type(node_type: String) -> Array:
	match node_type:
		HexGenerationNodeTypesScript.NODE_SOURCE:
			return ["map", "overlay", "document", "result"]
	return []


func _on_promote_pressed() -> void:
	if _node_id == "" or _role_option == null:
		return
	promote_requested.emit(_node_id, String(_role_option.get_item_metadata(_role_option.selected)))


func _migrate_params() -> void:
	if not _params.has("mode"):
		return
	match _node_type:
		HexGenerationNodeTypesScript.NODE_CONNECTIVITY:
			if not _params.has("method"):
				_params["method"] = _params["mode"]
			_params.erase("mode")
		HexGenerationNodeTypesScript.NODE_WALL_FIELD:
			if not _params.has("wall_method"):
				_params["wall_method"] = _params["mode"]
			_params.erase("mode")
		HexGenerationNodeTypesScript.NODE_REGION_FILTER, HexGenerationNodeTypesScript.NODE_TERRAIN_FILTER, HexGenerationNodeTypesScript.NODE_OVERLAY_FILTER:
			if not _params.has("filter_target"):
				_params["filter_target"] = _params["mode"]
			_params.erase("mode")
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR:
			if not _params.has("placement_method"):
				_params["placement_method"] = _params["mode"]
			_params.erase("mode")
