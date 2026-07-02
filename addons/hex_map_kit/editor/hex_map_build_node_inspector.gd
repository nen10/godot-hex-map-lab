@tool
class_name HexMapBuildNodeInspector
extends VBoxContainer

signal node_params_changed(node_id: String, params: Dictionary)
signal promote_requested(node_id: String, role: String)

const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const HexGenerationPortsScript = preload("res://addons/hex_map_kit/generation/hex_generation_ports.gd")
const HexMapGeneratorScript = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexAdjacencyRuleSetScript = preload("res://addons/hex_map_kit/adapter/hex_adjacency_rule_set.gd")
const HexAdjacencyRulePresetsScript = preload("res://addons/hex_map_kit/editor/hex_adjacency_rule_presets.gd")
const HexMapEditorPathSelectorScript = preload("res://addons/hex_map_kit/editor/hex_map_editor_path_selector.gd")

# Markov reference-frame direction id whose generation step is +q. The Hex Panel
# pins every reference-count preview to this direction so the ">" arrow always
# points at +q regardless of reference count.
const MARKOV_REFERENCE_FRAME_GENERATION_DIRECTION_ID := 4
const MARKOV_WEIGHT_SPIN_FONT_SIZE := 20
const MARKOV_WEIGHT_SPIN_MINIMUM_SIZE := Vector2(76, 34)
const ADJACENCY_PROBABILITY_SPIN_MINIMUM_SIZE := Vector2(32, 28)
const ADJACENCY_PATTERN_HOVER_TINT := Color(0.5, 0.5, 0.5)
const ADJACENCY_PATTERN_HOVER_TINT_WEIGHT := 0.6
# Adjacency Rules layout.
# The window is freely resizable; the pattern cards simply reflow to fit the
# current width, and the scroll area fills whatever space is left. These values
# only define one fixed card footprint and the *initial* window size.
const ADJACENCY_PATTERN_CARD_SIZE := Vector2i(120, 168)
const ADJACENCY_PATTERN_GAP := 6
# How many cards the window tries to show per row when it first opens.
const ADJACENCY_RULES_DEFAULT_COLUMNS := 10
# Extra space added to the initial size for window chrome, the scroll bar, and
# the header/footer controls. Only affects the size on open, not the min size.
const ADJACENCY_RULES_DEFAULT_CHROME := Vector2i(60, 380)

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
	if key == "placement_method":
		_refresh_item_pool_editor_rows()
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
		if key == "item_pool":
			var control = entry.get("control", null) as Control
			if control != null:
				control.visible = bool(visibility.get(key, true))


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
		var new_entry := {"name": "entry_%d" % entries.size()}
		if _item_pool_placement_method() == "limited":
			new_entry["limit"] = 1
		else:
			new_entry["weight"] = 1.0
		entries.append(new_entry)
		_params["item_pool"] = entries
		_commit_item_pool()
		_refresh_item_pool_rows(container, entries)
	)
	container.add_child(add_button)
	_refresh_item_pool_rows(container, entries)
	return container


func _item_pool_placement_method() -> String:
	return String(_params.get("placement_method", _params.get("mode", "weighted")))


func _refresh_item_pool_editor_rows() -> void:
	var entry = _param_controls.get("item_pool", null)
	if not entry is Dictionary:
		return
	var container = (entry as Dictionary).get("control", null)
	if not container is VBoxContainer:
		return
	var entries: Array = _params.get("item_pool", [])
	if not entries is Array:
		entries = []
	_refresh_item_pool_rows(container, entries)


func _refresh_item_pool_rows(container: VBoxContainer, entries: Array) -> void:
	for i in range(container.get_child_count() - 1, -1, -1):
		var child = container.get_child(i)
		if child is Button:
			continue
		container.remove_child(child)
		child.queue_free()
	var limited := _item_pool_placement_method() == "limited"
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
		var value_label := Label.new()
		value_label.name = "ItemPoolValueLabel_%d" % i
		value_label.text = "count:" if limited else "weight:"
		row.add_child(value_label)
		var value_spin := SpinBox.new()
		value_spin.name = "ItemPoolValueSpin_%d" % i
		if limited:
			value_spin.min_value = 0
			value_spin.max_value = 999
			value_spin.step = 1
			value_spin.value = maxi(0, int(entry.get("limit", 0)))
			value_spin.value_changed.connect(func(v: float):
				entry["limit"] = int(v)
				_commit_item_pool()
			)
		else:
			value_spin.min_value = 0.0
			value_spin.max_value = 1.0
			value_spin.step = 0.05
			value_spin.value = clampf(float(entry.get("weight", 1.0)), 0.0, 1.0)
			value_spin.value_changed.connect(func(v: float):
				entry["weight"] = v
				_commit_item_pool()
			)
		row.add_child(value_spin)
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


func _probability_fill(probability: float, with_color: Color = Color.WHITE) -> Color:
	var shade := clampf(probability, 0.0, 1.0)
	return Color(1.0 - shade * (1.0 - with_color.r), 1.0 - shade * (1.0 - with_color.g), 1.0 - shade * (1.0 - with_color.b))


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
	var dialog_size := _adjacency_rules_dialog_size()
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var help := Label.new()
	help.text = "Toggle cells:\n    black = reference present\n    white = absent.\nCenter color: generation probability."
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(help)
	var name_edit := LineEdit.new()
	name_edit.name = "AdjacencyRuleSetName"
	name_edit.text = _adjacency_rule_set_name()
	name_edit.placeholder_text = "Rule set name"
	body.add_child(_labeled_control("Rule set name", name_edit))
	var patterns: Array = _adjacency_patterns()
	var default_spin := SpinBox.new()
	default_spin.name = "AdjacencyDefaultProbability"
	default_spin.min_value = 0.0
	default_spin.max_value = 1.0
	default_spin.step = 0.05
	default_spin.value = _adjacency_default_probability()
	var status_label := Label.new()
	status_label.name = "AdjacencyRulesStatus"
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	var preset_box := VBoxContainer.new()
	preset_box.name = "AdjacencyPresetRow"
	preset_box.add_theme_constant_override("separation", 4)
	var preset_select_row := HBoxContainer.new()
	preset_select_row.name = "AdjacencyPresetSelectRow"
	var preset_actions_row := HBoxContainer.new()
	preset_actions_row.name = "AdjacencyPresetActionsRow"
	var preset_label := Label.new()
	preset_label.text = "Preset"
	preset_label.custom_minimum_size = Vector2(160, 0)
	preset_select_row.add_child(preset_label)
	var preset_option := OptionButton.new()
	preset_option.name = "AdjacencyPresetOption"
	preset_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preset_select_row.add_child(preset_option)
	var preset_actions_spacer := Control.new()
	preset_actions_spacer.custom_minimum_size = Vector2(160, 0)
	preset_actions_row.add_child(preset_actions_spacer)
	preset_box.add_child(preset_select_row)
	preset_box.add_child(preset_actions_row)
	var preset_paths: Array = []
	var refresh_presets := func():
		preset_paths.clear()
		preset_option.clear()
		var presets := HexAdjacencyRulePresetsScript.list_presets()
		if presets.is_empty():
			preset_option.add_item("(no saved presets)")
			preset_option.set_item_disabled(0, true)
			return
		preset_option.add_item("Select preset to load...")
		preset_paths.append("")
		for preset in presets:
			preset_option.add_item(String((preset as Dictionary).get("name", "")))
			preset_paths.append(String((preset as Dictionary).get("path", "")))
	body.add_child(preset_box)
	var patterns_scroll := ScrollContainer.new()
	patterns_scroll.name = "AdjacencyRulesPatternScroll"
	# Reserve at least one full row of cards. Fixing the scroll's minimum WIDTH to
	# a row also forces the HFlowContainer to lay out horizontally from the very
	# first frame; otherwise the dialog measures the cards stacked in one narrow
	# column at popup time and opens at a wrong (huge) size in the editor.
	patterns_scroll.custom_minimum_size = Vector2(
		float(_adjacency_pattern_row_width(ADJACENCY_RULES_DEFAULT_COLUMNS)),
		float(ADJACENCY_PATTERN_CARD_SIZE.y)
	)
	patterns_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	patterns_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	patterns_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var patterns_box := HFlowContainer.new()
	patterns_box.name = "AdjacencyRulesPatternList"
	patterns_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	patterns_box.add_theme_constant_override("h_separation", ADJACENCY_PATTERN_GAP)
	patterns_box.add_theme_constant_override("v_separation", ADJACENCY_PATTERN_GAP)
	patterns_scroll.add_child(patterns_box)
	body.add_child(patterns_scroll)
	var rebuild := func(): pass
	rebuild = func():
		for child in patterns_box.get_children():
			patterns_box.remove_child(child)
			child.queue_free()
		for pattern_index in range(patterns.size()):
			patterns_box.add_child(_adjacency_pattern_row(patterns, pattern_index, rebuild))
	var current_rule_set := func():
		return HexAdjacencyRuleSetScript.from_dialog_dict(
			_adjacency_rules_dict_from_window_patterns(patterns, float(default_spin.value) if default_spin != null else _adjacency_default_probability()),
			name_edit.text.strip_edges()
		)
	var apply_rule_set_to_window := func(rule_set, source_path: String = ""):
		if rule_set == null:
			status_label.text = "Could not load adjacency rule set."
			push_error("Could not load adjacency rule set: %s" % source_path)
			return
		name_edit.text = HexAdjacencyRulePresetsScript.display_name_for(rule_set, source_path)
		default_spin.value = clampf(float(rule_set.default_probability), 0.0, 1.0)
		patterns.clear()
		var next_patterns: Array = (rule_set.to_dialog_dict().get("rules", []) as Array).duplicate(true)
		if next_patterns.is_empty():
			next_patterns.append({"directions": [], "probability": 0.5})
		patterns.append_array(next_patterns)
		rebuild.call()
		status_label.text = "Loaded: %s" % name_edit.text
	var save_rule_set_to_path := func(path: String):
		var rule_set = current_rule_set.call()
		if rule_set.display_name.strip_edges() == "":
			rule_set.display_name = path.get_file().get_basename().capitalize()
			name_edit.text = rule_set.display_name
		var error := HexAdjacencyRulePresetsScript.save(rule_set, path)
		if error != OK:
			status_label.text = "Save failed: %s (%d)" % [path, error]
			push_error("Failed to save adjacency rule set: %d" % error)
			return
		_scan_editor_filesystem()
		refresh_presets.call()
		for index in range(preset_paths.size()):
			if String(preset_paths[index]) == path:
				preset_option.select(index)
				break
		var saved_rule_count := (rule_set.to_dialog_dict().get("rules", []) as Array).size()
		status_label.text = "Saved preset \"%s\" (%d patterns) → %s" % [rule_set.display_name, saved_rule_count, path]
	var load_file_button := Button.new()
	load_file_button.name = "LoadAdjacencyRuleSetFile"
	load_file_button.text = "Load File..."
	load_file_button.pressed.connect(func():
		var file_dialog: EditorFileDialog = HexMapEditorPathSelectorScript.new_dialog(
			EditorFileDialog.FILE_MODE_OPEN_FILE,
			HexAdjacencyRulePresetsScript.FILE_FILTERS
		)
		if file_dialog == null:
			status_label.text = "File dialogs are only available in the editor."
			return
		file_dialog.file_selected.connect(func(path: String):
			apply_rule_set_to_window.call(HexAdjacencyRulePresetsScript.load(path), path)
		)
		HexMapEditorPathSelectorScript.popup_dialog(file_dialog)
	)
	var load_preset_button := Button.new()
	load_preset_button.name = "LoadAdjacencyPreset"
	load_preset_button.text = "Load"
	load_preset_button.pressed.connect(func():
		var selected := preset_option.selected
		if selected < 0 or selected >= preset_paths.size():
			status_label.text = "No preset selected."
			return
		var path := String(preset_paths[selected])
		if path == "":
			status_label.text = "No preset selected."
			return
		apply_rule_set_to_window.call(HexAdjacencyRulePresetsScript.load(path), path)
	)
	# Selecting a preset from the dropdown loads it into the window immediately,
	# so "read a saved rule set into the editor" is a single intentional click.
	# select() called programmatically (refresh/save) does not emit item_selected,
	# so this never clobbers the initial window content or a freshly saved set.
	preset_option.item_selected.connect(func(index: int):
		if index < 0 or index >= preset_paths.size():
			return
		var path := String(preset_paths[index])
		if path == "":
			return
		apply_rule_set_to_window.call(HexAdjacencyRulePresetsScript.load(path), path)
	)
	preset_actions_row.add_child(load_preset_button)
	preset_actions_row.add_child(load_file_button)
	var save_file_button := Button.new()
	save_file_button.name = "SaveAdjacencyRuleSetFile"
	save_file_button.text = "Save File..."
	save_file_button.pressed.connect(func():
		var file_dialog: EditorFileDialog = HexMapEditorPathSelectorScript.new_dialog(
			EditorFileDialog.FILE_MODE_SAVE_FILE,
			HexAdjacencyRulePresetsScript.FILE_FILTERS
		)
		if file_dialog == null:
			status_label.text = "File dialogs are only available in the editor."
			return
		var base_name := name_edit.text.strip_edges().to_snake_case()
		file_dialog.current_file = ("%s.tres" % base_name) if base_name != "" else "adjacency_rules.tres"
		file_dialog.file_selected.connect(save_rule_set_to_path)
		HexMapEditorPathSelectorScript.popup_dialog(file_dialog)
	)
	preset_actions_row.add_child(save_file_button)
	var save_preset_button := Button.new()
	save_preset_button.name = "SaveAdjacencyPreset"
	save_preset_button.text = "Save Preset"
	save_preset_button.tooltip_text = "Save under the addon adjacency rule preset folder so it appears in this Preset list."
	save_preset_button.pressed.connect(func():
		var display_name := name_edit.text.strip_edges()
		if display_name == "":
			status_label.text = "Enter a rule set name before saving a preset."
			name_edit.grab_focus()
			return
		save_rule_set_to_path.call(HexAdjacencyRulePresetsScript.preset_path_for_name(display_name))
	)
	preset_actions_row.add_child(save_preset_button)
	refresh_presets.call()
	rebuild.call()
	var add_button := Button.new()
	add_button.name = "AddAdjacencyPattern"
	add_button.text = "Add Pattern"
	add_button.pressed.connect(func():
		patterns.append({"directions": [], "probability": 0.5})
		rebuild.call()
	)
	body.add_child(add_button)
	body.add_child(_labeled_control("Default probability", default_spin))
	body.add_child(status_label)
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
			"name": name_edit.text.strip_edges(),
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
	# Parent this large editor window to the editor's base control. If it stays
	# under the node inspector, Godot embeds/clamps it to the dock rect (observed
	# around 658x440), regardless of _adjacency_rules_dialog_size().
	var dialog_host: Node = self
	if Engine.is_editor_hint() and EditorInterface.get_base_control() != null:
		dialog_host = EditorInterface.get_base_control()
	dialog_host.add_child(dialog)
	if dialog_host != self:
		tree_exiting.connect(func():
			if is_instance_valid(dialog):
				dialog.queue_free()
		, CONNECT_ONE_SHOT)
	# AcceptDialog keeps wrap_controls on so it lays out / clips its child
	# correctly. That also means the window can never open smaller than the
	# child's minimum size, so we keep that minimum small (compact help text +
	# a short scroll area) and let _adjacency_rules_dialog_size() drive the size.
	dialog.unresizable = false
	dialog.popup_centered(dialog_size)
	dialog.size = dialog_size
	# AcceptDialog measures the flow grid before it gets its real width, so the
	# first size can be a stale tall value. Re-apply the intended size after the
	# layout settles so the window opens at _adjacency_rules_dialog_size().
	dialog.set_deferred("size", dialog_size)


func _adjacency_rules_dialog_size() -> Vector2i:
	return Vector2i(
		_adjacency_pattern_row_width(ADJACENCY_RULES_DEFAULT_COLUMNS) + ADJACENCY_RULES_DEFAULT_CHROME.x + 600,
		(ADJACENCY_PATTERN_CARD_SIZE.y + ADJACENCY_RULES_DEFAULT_CHROME.y) * 2 + 40
	)


func _adjacency_pattern_row_width(columns: int) -> int:
	return ADJACENCY_PATTERN_CARD_SIZE.x * columns + ADJACENCY_PATTERN_GAP * maxi(0, columns - 1)


func _adjacency_pattern_row(patterns: Array, pattern_index: int, rebuild: Callable) -> VBoxContainer:
	var row := VBoxContainer.new()
	row.name = "AdjacencyPatternCard_%d" % pattern_index
	row.custom_minimum_size = Vector2(ADJACENCY_PATTERN_CARD_SIZE)
	row.size = Vector2(ADJACENCY_PATTERN_CARD_SIZE)
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row.add_theme_constant_override("separation", 0)
	var pattern := patterns[pattern_index] as Dictionary
	var present := {}
	for key in (pattern.get("directions", []) as Array):
		present[String(key)] = true
	var panel := HexCellButtonPanel.new()
	panel.name = "AdjacencyPatternPanel_%d" % pattern_index
	# The panel fills the preview area; the hex content is bottom-aligned inside
	# it so it sits right above the label. The hex/label spacing is controlled by
	# the card VBox separation, not by panel sizing.
	panel.custom_minimum_size = Vector2.ZERO
	var labels := {}
	var metadata := {}
	var pressable := {}
	var toggle_cells := {}
	var presence_fill := Color(0.0, 0.1, 0.2)

	for direction in HexVector.directions():
		var key: String = direction.key()
		labels[key] = ""
		metadata[key] = {
			"direction": key,
			"toggle_on_fill": presence_fill,
			"toggle_off_fill": Color.WHITE,
			"fill_color": presence_fill if present.has(key) else Color.WHITE,
			"hover_tint_color": ADJACENCY_PATTERN_HOVER_TINT,
			"hover_tint_weight": ADJACENCY_PATTERN_HOVER_TINT_WEIGHT,
			"hover_fill_enabled": true,
		}
		pressable[key] = true
		toggle_cells[key] = present.has(key)
	var center_key: String = HexVector.zero().key()
	var probability := float(pattern.get("probability", 0.5))
	var probability_fill := _probability_fill(probability, Color(1.0, 0.35, 0.0))
	labels[center_key] = "%.2f" % probability
	metadata[center_key] = {
		"fill_color": probability_fill,
		"label_color": _contrasting_label_color(probability_fill),
		"hover_fill_enabled": false,
	}
	panel.configure({
		"shape_kind": "directions",
		"flat_top": _effective_flat_top,
		"cell_radius": 12.0,
		"cell_gap": 0.0,
		"padding": Vector2(0, 0),
		"center_cell": HexVector.zero(),
		"pressable_cells": pressable,
		"toggle_cells": toggle_cells,
		"label_by_cell": labels,
		"metadata_by_cell": metadata,
		"show_labels": false,
		"report_natural_minimum": false,
		"vertical_alignment": HexCellButtonPanel.ContentAlign.END,
	})
	var components_label := Label.new()
	components_label.name = "AdjacencyPatternComponentsLabel_%d" % pattern_index
	components_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	components_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Never let the components text widen the card; clip instead.
	components_label.clip_text = true
	components_label.custom_minimum_size = Vector2(0, 0)
	_refresh_adjacency_pattern_components_label(components_label, pattern)
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
		_refresh_adjacency_pattern_components_label(components_label, patterns[pattern_index] as Dictionary)
	)
	var preview_area := Control.new()
	preview_area.name = "AdjacencyPatternPreviewArea_%d" % pattern_index
	preview_area.custom_minimum_size = Vector2(float(ADJACENCY_PATTERN_CARD_SIZE.x), 80.0)
	preview_area.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 0.0
	panel.offset_top = 0.0
	panel.offset_right = 0.0
	panel.offset_bottom = 0.0
	preview_area.add_child(panel)
	var remove_button := _adjacency_pattern_remove_button(row, patterns, pattern_index, rebuild)
	preview_area.add_child(remove_button)
	row.add_child(preview_area)
	row.add_child(components_label)
	var prob_spin := SpinBox.new()
	prob_spin.name = "AdjacencyPatternProbabilitySpin_%d" % pattern_index
	prob_spin.min_value = 0.0
	prob_spin.max_value = 1.0
	prob_spin.step = 0.05
	prob_spin.value = float(pattern.get("probability", 0.5))
	# Explicitly give the value box a small fixed width so it always fits the
	# card, then centre the value box on the HexCellButton centre using the same
	# spinner-mirroring row as the Markov mesh spins.
	_configure_numeric_spinbox(prob_spin, 20, ADJACENCY_PROBABILITY_SPIN_MINIMUM_SIZE)
	prob_spin.value_changed.connect(func(v: float):
		(patterns[pattern_index] as Dictionary)["probability"] = v
		var next_probability_fill := _probability_fill(v, Color(1.0, 0.35, 0.0))
		panel.update_cell(HexVector.zero(), {
			"label": "%.2f" % v,
			"fill_color": next_probability_fill,
			"label_color": _contrasting_label_color(next_probability_fill),
		})
	)
	row.add_child(_spinbox_value_centered_row(prob_spin))
	return row


func _refresh_adjacency_pattern_components_label(label: Label, pattern: Dictionary) -> void:
	if label == null:
		return
	var directions = pattern.get("directions", [])
	var direction_keys: Array = []
	if directions is Array:
		direction_keys = directions
	label.text = "%s" % _adjacency_component_set_text(direction_keys)


func _adjacency_component_set_text(direction_keys: Array) -> String:
	var sizes := _component_sizes_from_directions(direction_keys)
	if sizes.is_empty():
		return "{}"
	sizes.sort()
	var parts: Array[String] = []
	for index in range(sizes.size() - 1, -1, -1):
		parts.append(str(int(sizes[index])))
	return "{ %s }" % ",".join(parts)


func _adjacency_pattern_remove_button(card: Control, patterns: Array, pattern_index: int, rebuild: Callable) -> Button:
	var remove_button := Button.new()
	remove_button.name = "AdjacencyPatternRemoveButton_%d" % pattern_index
	remove_button.text = "×"
	remove_button.tooltip_text = "Remove pattern"
	remove_button.focus_mode = Control.FOCUS_NONE
	remove_button.flat = true
	# Small hit area in the corner so it does not overlap the hex cell buttons.
	remove_button.custom_minimum_size = Vector2(14, 14)
	# expand_icon lets the Close icon shrink to the small button instead of
	# forcing the button (and its hit area) up to the icon's native size.
	# remove_button.expand_icon = true
	remove_button.anchor_left = 1.0
	remove_button.anchor_top = 0.0
	remove_button.anchor_right = 1.0
	remove_button.anchor_bottom = 0.0
	remove_button.offset_left = -24.0
	remove_button.offset_top = 0.0
	remove_button.offset_right = 0.0
	remove_button.offset_bottom = 14.0
	if has_theme_icon("Close", "EditorIcons"):
		remove_button.icon = get_theme_icon("Close", "EditorIcons")
		remove_button.text = ""
	remove_button.button_down.connect(func():
		_animate_adjacency_remove_button_press(remove_button, true)
	)
	remove_button.button_up.connect(func():
		_animate_adjacency_remove_button_press(remove_button, false)
	)
	remove_button.pressed.connect(func():
		_animate_adjacency_pattern_remove(card, remove_button, func():
			patterns.remove_at(pattern_index)
			rebuild.call()
		)
	)
	return remove_button


func _animate_adjacency_remove_button_press(remove_button: Button, pressed: bool) -> void:
	if remove_button == null or not remove_button.is_inside_tree() or remove_button.disabled:
		return
	remove_button.pivot_offset = remove_button.size * 0.5
	var tween := remove_button.create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(remove_button, "scale", Vector2(0.82, 0.82) if pressed else Vector2.ONE, 0.06)
	tween.parallel().tween_property(remove_button, "modulate:a", 0.72 if pressed else 1.0, 0.06)


func _animate_adjacency_pattern_remove(card: Control, remove_button: Button, on_finished: Callable) -> void:
	remove_button.disabled = true
	remove_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if card == null or not card.is_inside_tree():
		on_finished.call()
		return
	card.pivot_offset = card.size * 0.5
	var tween := card.create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(card, "scale", Vector2(0.86, 0.86), 0.12)
	tween.tween_property(card, "modulate:a", 0.0, 0.12)
	tween.tween_property(remove_button, "rotation", deg_to_rad(90.0), 0.12)
	tween.finished.connect(on_finished)


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
		var name := String((value as Dictionary).get("name", "")).strip_edges()
		if name != "":
			return "%s · hex patterns: %d" % [name, rules.size()]
		return "hex patterns: %d" % rules.size()
	return "preset/text rule"


func _adjacency_rule_set_name() -> String:
	var value = _params.get("probability_rules", {})
	if value is Dictionary:
		return String((value as Dictionary).get("name", "")).strip_edges()
	return ""


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


func _adjacency_rules_dict_from_window_patterns(patterns: Array, default_probability: float) -> Dictionary:
	var rules: Array = []
	for pattern in patterns:
		if not pattern is Dictionary:
			continue
		var pattern_dict := pattern as Dictionary
		var directions = pattern_dict.get("directions", [])
		rules.append({
			"directions": directions.duplicate() if directions is Array else [],
			"probability": clampf(float(pattern_dict.get("probability", 0.5)), 0.0, 1.0),
		})
	return {
		"default": clampf(default_probability, 0.0, 1.0),
		"rules": rules,
	}


func _scan_editor_filesystem() -> void:
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()


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
		"toric_passage", "include_generated_reference":
			return "check"
		"source_key", "item_key", "item_name", "selectors", "probability_rules":
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
		"toric_passage":
			return false
		"item_name":
			return "item"
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
		HexGenerationNodeTypesScript.NODE_REGION_FILTER, HexGenerationNodeTypesScript.NODE_TERRAIN_FILTER, HexGenerationNodeTypesScript.NODE_OVERLAY_FILTER:
			var ft := String(params.get("filter_target", params.get("mode", "floor")))
			result["item_key"] = ft == "item_key"
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR:
			var pm := String(params.get("placement_method", params.get("mode", "weighted")))
			result["placement_probability"] = pm == "weighted"
			result["item_name"] = pm == "adjacency_rules"
			result["item_pool"] = pm != "adjacency_rules"
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
			return ["shape", "width", "height", "size", "radius"]
		HexGenerationNodeTypesScript.NODE_WALL_FIELD:
			return ["wall_method", "wall_probability", "distribution_mode", "distribution_id", "custom_distribution", "seed"]
		HexGenerationNodeTypesScript.NODE_CONNECTIVITY:
			return ["method", "toric_passage", "seed"]
		HexGenerationNodeTypesScript.NODE_REGION_FILTER, HexGenerationNodeTypesScript.NODE_TERRAIN_FILTER, HexGenerationNodeTypesScript.NODE_OVERLAY_FILTER:
			return ["filter_target", "item_key", "shift_offset"]
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR:
			return ["placement_method", "placement_probability", "item_name", "item_pool", "probability_rules", "neighbor_radius", "include_generated_reference", "seed"]
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
