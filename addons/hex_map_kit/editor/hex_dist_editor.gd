@tool
class_name HexDistEditor
extends Window

const HexRandomizer = preload("res://addons/hex_map_kit/core/hex_randomizer.gd")
const HexDistribution = preload("res://addons/hex_map_kit/adapter/hex_distribution.gd")

var root: VBoxContainer

const HEX_SIZE := 16.0
const WALL_FILL := Color(0.1, 0.1, 0.1)
const FLOOR_FILL := Color(0.9, 0.9, 0.9)
const OUTLINE_COLOR := Color(0.67, 0.67, 0.67)
const MAX_RECENT_DISTRIBUTIONS := 8

static var _recent_distribution_paths: Array[String] = []

var _preset_option: OptionButton
var _recent_option: OptionButton
var _pattern_controls: Array[Control] = []
var _d3_spins: Array[SpinBox] = []
var _d2_spins: Array[SpinBox] = []
var _d1_spins: Array[SpinBox] = []
var _apply_callback: Callable
var _cancel_callback: Callable

var _filepath_label: Label
var _save_new_button: Button
var _duplicate_preset_button: Button
var _save_button: Button
var _editing_path: String = ""


func _init(
	p_editing_path: String = "",
	p_apply: Callable = Callable(),
	p_cancel: Callable = Callable()
) -> void:
	title = "Edit Distribution"
	unresizable = false
	wrap_controls = true
	size = Vector2i(680, 560)
	_editing_path = p_editing_path
	_apply_callback = p_apply
	_cancel_callback = p_cancel


func _ready() -> void:
	close_requested.connect(_on_cancel_pressed)
	_build_ui()
	if _editing_path != "":
		_load_from_file(_editing_path)
	else:
		_on_preset_changed(0)


func _build_ui() -> void:
	root = VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var header = VBoxContainer.new()
	var top_row = HBoxContainer.new()
	var preset_label = Label.new()
	preset_label.text = "Preset"
	top_row.add_child(preset_label)

	_preset_option = OptionButton.new()
	for name in HexRandomizer.get_preset_names():
		_preset_option.add_item(name)
	_preset_option.select(0)
	_preset_option.item_selected.connect(_on_preset_changed)
	top_row.add_child(_preset_option)

	_duplicate_preset_button = Button.new()
	_duplicate_preset_button.text = "Duplicate Preset..."
	_duplicate_preset_button.pressed.connect(_on_duplicate_preset_pressed)
	top_row.add_child(_duplicate_preset_button)

	var top_row2 = HBoxContainer.new()
	_filepath_label = Label.new()
	_filepath_label.text = "" if _editing_path == "" else _editing_path
	_filepath_label.mouse_filter = Control.MOUSE_FILTER_PASS
	_filepath_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.9))
	_filepath_label.tooltip_text = _editing_path
	top_row2.add_child(_filepath_label)

	var load_btn = Button.new()
	load_btn.text = "Load .tres"
	load_btn.pressed.connect(_on_load_pressed)
	top_row2.add_child(load_btn)

	var recent_row = HBoxContainer.new()
	var recent_label = Label.new()
	recent_label.text = "Recent"
	recent_row.add_child(recent_label)
	_recent_option = OptionButton.new()
	_recent_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_recent_option.item_selected.connect(_on_recent_selected)
	recent_row.add_child(_recent_option)
	_refresh_recent_options()

	header.add_child(top_row)
	header.add_child(top_row2)
	header.add_child(recent_row)
	root.add_child(header)

	root.add_child(_build_separator())

	var section3 = Label.new()
	section3.text = "3-neighbor (2x2x2 = 8 patterns)"
	section3.add_theme_font_size_override("font_size", 14)
	root.add_child(section3)

	var d3_container = GridContainer.new()
	d3_container.columns = 4
	for state_index in range(8):
		var panel = _build_pattern_panel(3, state_index)
		d3_container.add_child(panel)
	root.add_child(d3_container)

	root.add_child(_build_separator())

	var section2 = Label.new()
	section2.text = "2-neighbor (2x2 = 4 patterns)"
	section2.add_theme_font_size_override("font_size", 14)
	root.add_child(section2)

	var d2_container = GridContainer.new()
	d2_container.columns = 4
	for state_index in range(4):
		var panel = _build_pattern_panel(2, state_index)
		d2_container.add_child(panel)
	root.add_child(d2_container)

	root.add_child(_build_separator())

	var section1 = Label.new()
	section1.text = "1-neighbor (2 patterns)"
	section1.add_theme_font_size_override("font_size", 14)
	root.add_child(section1)

	var d1_container = GridContainer.new()
	d1_container.columns = 4
	for state_index in range(2):
		var panel = _build_pattern_panel(1, state_index)
		d1_container.add_child(panel)
	root.add_child(d1_container)

	root.add_child(_build_separator())

	var button_row = HBoxContainer.new()
	_save_new_button = Button.new()
	_save_new_button.text = "Save New..."
	_save_new_button.pressed.connect(_on_save_new_pressed)
	button_row.add_child(_save_new_button)

	_save_button = Button.new()
	_save_button.text = "Apply"
	_save_button.disabled = _editing_path == ""
	_save_button.pressed.connect(_on_save_pressed)
	button_row.add_child(_save_button)

	var cancel_btn = Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.pressed.connect(_on_cancel_pressed)
	button_row.add_child(cancel_btn)
	root.add_child(button_row)

	_refresh_save_buttons()


func _build_pattern_panel(n_neighbor: int, state_index: int) -> Control:
	var panel = VBoxContainer.new()
	panel.custom_minimum_size = Vector2(140, 100)

	var draw_control = Control.new()
	draw_control.custom_minimum_size = Vector2(140, 72)
	draw_control.draw.connect(_draw_pattern.bind(n_neighbor, state_index, draw_control))
	_pattern_controls.append(draw_control)
	panel.add_child(draw_control)

	var spin = SpinBox.new()
	spin.min_value = 0.0
	spin.max_value = 8.0
	spin.step = 0.5
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spin.value = _initial_value(n_neighbor, state_index)
	spin.value_changed.connect(_on_spin_changed.bind(n_neighbor, state_index))
	panel.add_child(spin)

	match n_neighbor:
		3: _d3_spins.append(spin)
		2: _d2_spins.append(spin)
		1: _d1_spins.append(spin)
	return panel


func _initial_value(n_neighbor: int, state_index: int) -> float:
	if _editing_path != "":
		var dist = load(_editing_path)
		if dist is HexDistribution:
			match n_neighbor:
				3: return dist.distribution_3[state_index]
				2: return dist.distribution_2[state_index]
				1: return dist.distribution_1[state_index]
	var dist_id = HexRandomizer.get_preset_id(_preset_option.get_item_text(_preset_option.selected))
	var dist = HexDistribution.from_preset_id(dist_id)
	match n_neighbor:
		3: return dist.distribution_3[state_index]
		2: return dist.distribution_2[state_index]
		1: return dist.distribution_1[state_index]
	return 0.3


func _draw_pattern(n_neighbor: int, state_index: int, control: Control) -> void:
	var origin = Vector2(70, 36)

	var ref0 = origin + Vector2(-HEX_SIZE * 1.5, -HEX_SIZE * 1.732 / 2)
	var ref1 = origin + Vector2(0, -HEX_SIZE * 1.732)
	var ref2 = origin + Vector2(HEX_SIZE * 1.5, -HEX_SIZE * 1.732 / 2)

	var ref_positions = [ref0, ref1, ref2] if n_neighbor == 3 else [ref1, ref2]
	var is_wall := []
	for i in range(n_neighbor):
		is_wall.append((state_index >> i) & 1 == 1)

	for i in range(n_neighbor):
		_draw_hex(control, ref_positions[i], WALL_FILL if is_wall[i] else FLOOR_FILL)

	_draw_hex(control, origin, _center_color(n_neighbor, state_index))


func _draw_hex(control: Control, center: Vector2, fill: Color) -> void:
	var points: PackedVector2Array = []
	for index in range(6):
		var angle = deg_to_rad(60.0 * float(index))
		points.append(center + Vector2(cos(angle), sin(angle)) * HEX_SIZE)

	control.draw_colored_polygon(points, fill)
	var outline = points
	outline.append(points[0])
	control.draw_polyline(outline, OUTLINE_COLOR, 1.0)


func _build_separator() -> HSeparator:
	var sep = HSeparator.new()
	sep.custom_minimum_size = Vector2(0, 4)
	return sep


func _on_preset_changed(_index: int) -> void:
	_editing_path = ""
	_filepath_label.text = ""
	_refresh_save_buttons()
	_apply_preset(HexRandomizer.get_preset_id(_preset_option.get_item_text(_preset_option.selected)))


func _apply_preset(dist_id: int) -> void:
	var dist = HexDistribution.from_preset_id(dist_id)
	for i in range(_d3_spins.size()):
		_d3_spins[i].set_value_no_signal(dist.distribution_3[i])
	for i in range(_d2_spins.size()):
		_d2_spins[i].set_value_no_signal(dist.distribution_2[i])
	for i in range(_d1_spins.size()):
		_d1_spins[i].set_value_no_signal(dist.distribution_1[i])
	_queue_pattern_redraw()


func _on_spin_changed(_value: float, n_neighbor: int, state_index: int) -> void:
	_center_color(n_neighbor, state_index)
	_queue_pattern_redraw()


func _current_distribution() -> HexDistribution:
	var d3: Array[float] = []
	var d2: Array[float] = []
	var d1: Array[float] = []
	for spin in _d3_spins: d3.append(float(spin.value))
	for spin in _d2_spins: d2.append(float(spin.value))
	for spin in _d1_spins: d1.append(float(spin.value))
	return HexDistribution.new(d3, d2, d1)


func _refresh_save_buttons() -> void:
	if _save_button == null:
		return
	_save_button.disabled = _editing_path == ""


static func clear_recent_distributions() -> void:
	_recent_distribution_paths.clear()


static func recent_distribution_paths() -> Array[String]:
	return _recent_distribution_paths.duplicate()


static func remember_recent_distribution(path: String) -> void:
	if path == "":
		return
	_recent_distribution_paths.erase(path)
	_recent_distribution_paths.push_front(path)
	while _recent_distribution_paths.size() > MAX_RECENT_DISTRIBUTIONS:
		_recent_distribution_paths.pop_back()


func save_current_distribution_as(path: String) -> bool:
	return _save_current_distribution_to(path)


func _refresh_recent_options() -> void:
	if _recent_option == null:
		return
	_recent_option.clear()
	var paths = recent_distribution_paths()
	if paths.is_empty():
		_recent_option.add_item("(no recent custom distribution)")
		_recent_option.set_item_disabled(0, true)
		return
	for path in paths:
		_recent_option.add_item(path)


func _set_editing_path(path: String) -> void:
	_editing_path = path
	if _filepath_label != null:
		_filepath_label.text = path
		_filepath_label.tooltip_text = path
	if _preset_option != null and path != "":
		_preset_option.select(-1)
	_refresh_save_buttons()
	_refresh_recent_options()


func _save_current_distribution_to(path: String) -> bool:
	var dist = _current_distribution()
	var error = ResourceSaver.save(dist, path)
	if error != OK:
		push_error("Failed to save distribution: %d" % error)
		return false
	_scan_editor_filesystem()
	remember_recent_distribution(path)
	_set_editing_path(path)
	print("Distribution saved to: %s" % path)
	return true


func _scan_editor_filesystem() -> void:
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()


func _on_duplicate_preset_pressed() -> void:
	_editing_path = ""
	_refresh_save_buttons()
	_on_save_new_pressed()


func _on_save_new_pressed() -> void:
	var dialog = EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.add_filter("*.tres", "Hex Distribution")
	dialog.current_file = "hex_dist.tres"
	dialog.file_selected.connect(_on_save_new_file_selected)
	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_centered_ratio(0.5)


func _on_save_new_file_selected(path: String) -> void:
	save_current_distribution_as(path)


func _on_load_pressed() -> void:
	var dialog = EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.add_filter("*.tres", "Hex Distribution")
	dialog.file_selected.connect(_load_from_file)
	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_centered_ratio(0.5)


func _on_recent_selected(index: int) -> void:
	var paths = recent_distribution_paths()
	if index < 0 or index >= paths.size():
		return
	_load_from_file(paths[index])


func _on_save_pressed() -> void:
	if _editing_path == "":
		return
	if not _save_current_distribution_to(_editing_path):
		return
	if _apply_callback.is_valid():
		_apply_callback.call(_editing_path)
	queue_free()


func _on_cancel_pressed() -> void:
	if _cancel_callback.is_valid():
		_cancel_callback.call()
	queue_free()


func _load_from_file(path: String) -> void:
	var dist = load(path)
	if not dist is HexDistribution:
		return
	for i in range(_d3_spins.size()):
		_d3_spins[i].set_value_no_signal(dist.distribution_3[i])
	for i in range(_d2_spins.size()):
		_d2_spins[i].set_value_no_signal(dist.distribution_2[i])
	for i in range(_d1_spins.size()):
		_d1_spins[i].set_value_no_signal(dist.distribution_1[i])
	remember_recent_distribution(path)
	_set_editing_path(path)
	_queue_pattern_redraw()


func _center_color(n_neighbor: int, state_index: int) -> Color:
	var value: float = 7.0
	match n_neighbor:
		3: value = _d3_spins[state_index].value
		2: value = _d2_spins[state_index].value
		1: value = _d1_spins[state_index].value
	var brightness = 0.9 - value/10
	return Color(brightness, brightness, brightness)

func _queue_pattern_redraw() -> void:
	for control in _pattern_controls:
		control.queue_redraw()
