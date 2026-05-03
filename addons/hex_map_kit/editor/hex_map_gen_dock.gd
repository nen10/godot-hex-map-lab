@tool
class_name HexMapGenDock
extends Control

const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")

const SHAPE_RECTANGLE := 0
const SHAPE_HEXAGON := 1
const SHAPE_TORUS := 2

const SHAPE_NAMES := ["Rectangle", "Hexagon", "Torus"]
const TORIC_SIZE_OPTIONS := [7, 9, 11, 13]

var _shape_option: OptionButton
var _size_container: VBoxContainer
var _rect_width_label: Label
var _rect_width_spin: SpinBox
var _rect_height_label: Label
var _rect_height_spin: SpinBox
var _hex_radius_label: Label
var _hex_radius_spin: SpinBox
var _torus_size_option: OptionButton
var _torus_size_label: Label

var _wall_prob_slider: HSlider
var _wall_prob_label: Label
var _seed_spin: SpinBox
var _seed_random_button: Button
var _connectivity_check: CheckButton
var _symmetric_check: CheckButton

var _generate_button: Button
var _save_button: Button
var _stats_label: Label

var _current_data = null


func _ready() -> void:
	custom_minimum_size = Vector2(260, 180)
	_build_ui()
	_refresh_controls()
	_generate_map()


func _build_ui() -> void:
	var root = VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	root.add_child(_build_section_label("Hex Map Kit"))

	_shape_option = OptionButton.new()
	for name in SHAPE_NAMES:
		_shape_option.add_item(name)
	_shape_option.item_selected.connect(_on_shape_changed)
	root.add_child(_wrap_labeled("Shape", _shape_option))

	root.add_child(_build_separator())
	_size_container = VBoxContainer.new()
	root.add_child(_size_container)
	_build_rectangle_size_controls()
	_build_hexagon_size_controls()
	_build_torus_size_controls()

	root.add_child(_build_separator())
	root.add_child(_build_wall_probability_controls())
	root.add_child(_build_seed_controls())

	root.add_child(_build_separator())
	_connectivity_check = CheckButton.new()
	_connectivity_check.text = "Restore Connectivity"
	_connectivity_check.button_pressed = true
	_connectivity_check.toggled.connect(_on_option_changed)
	root.add_child(_connectivity_check)

	_symmetric_check = CheckButton.new()
	_symmetric_check.text = "Symmetric Gen (odd N only)"
	_symmetric_check.button_pressed = false
	_symmetric_check.disabled = true
	_symmetric_check.toggled.connect(_on_option_changed)
	root.add_child(_symmetric_check)

	root.add_child(_build_separator())
	_stats_label = Label.new()
	_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stats_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	root.add_child(_stats_label)

	root.add_child(_build_separator())
	var button_row = HBoxContainer.new()
	_generate_button = Button.new()
	_generate_button.text = "Generate"
	_generate_button.pressed.connect(_on_generate_pressed)
	button_row.add_child(_generate_button)

	_save_button = Button.new()
	_save_button.text = "Save .tres"
	_save_button.pressed.connect(_on_save_pressed)
	button_row.add_child(_save_button)
	root.add_child(button_row)


func _build_rectangle_size_controls() -> void:
	var row = HBoxContainer.new()
	_rect_width_label = Label.new()
	_rect_width_label.text = "Width"
	row.add_child(_rect_width_label)
	_rect_width_spin = SpinBox.new()
	_rect_width_spin.min_value = 1
	_rect_width_spin.max_value = 64
	_rect_width_spin.value = 8
	_rect_width_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rect_width_spin.value_changed.connect(_on_option_changed)
	row.add_child(_rect_width_spin)
	_rect_height_label = Label.new()
	_rect_height_label.text = "Height"
	row.add_child(_rect_height_label)
	_rect_height_spin = SpinBox.new()
	_rect_height_spin.min_value = 1
	_rect_height_spin.max_value = 64
	_rect_height_spin.value = 6
	_rect_height_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rect_height_spin.value_changed.connect(_on_option_changed)
	row.add_child(_rect_height_spin)
	_size_container.add_child(row)


func _build_hexagon_size_controls() -> void:
	var row = HBoxContainer.new()
	_hex_radius_label = Label.new()
	_hex_radius_label.text = "Radius"
	row.add_child(_hex_radius_label)
	_hex_radius_spin = SpinBox.new()
	_hex_radius_spin.min_value = 1
	_hex_radius_spin.max_value = 20
	_hex_radius_spin.value = 3
	_hex_radius_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hex_radius_spin.value_changed.connect(_on_option_changed)
	row.add_child(_hex_radius_spin)
	row.visible = false
	_size_container.add_child(row)


func _build_torus_size_controls() -> void:
	var row = HBoxContainer.new()
	_torus_size_label = Label.new()
	_torus_size_label.text = "Size (odd)"
	row.add_child(_torus_size_label)
	_torus_size_option = OptionButton.new()
	for size in TORIC_SIZE_OPTIONS:
		_torus_size_option.add_item(str(size))
	_torus_size_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_torus_size_option.item_selected.connect(_on_option_changed)
	row.add_child(_torus_size_option)
	row.visible = false
	_size_container.add_child(row)


func _build_wall_probability_controls() -> Control:
	var row = HBoxContainer.new()
	var label = Label.new()
	label.text = "Wall Prob"
	row.add_child(label)

	_wall_prob_slider = HSlider.new()
	_wall_prob_slider.min_value = 0.0
	_wall_prob_slider.max_value = 1.0
	_wall_prob_slider.step = 0.01
	_wall_prob_slider.value = 0.45
	_wall_prob_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_wall_prob_slider.value_changed.connect(_on_wall_prob_changed)
	row.add_child(_wall_prob_slider)

	_wall_prob_label = Label.new()
	_wall_prob_label.text = "0.45"
	_wall_prob_label.custom_minimum_size = Vector2(40, 0)
	row.add_child(_wall_prob_label)
	return row


func _build_seed_controls() -> Control:
	var row = HBoxContainer.new()
	var label = Label.new()
	label.text = "Seed"
	row.add_child(label)

	_seed_spin = SpinBox.new()
	_seed_spin.min_value = 0
	_seed_spin.max_value = 999999
	_seed_spin.value = 1201
	_seed_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_seed_spin.value_changed.connect(_on_option_changed)
	row.add_child(_seed_spin)

	_seed_random_button = Button.new()
	_seed_random_button.text = "Rand"
	_seed_random_button.pressed.connect(_on_seed_randomize)
	row.add_child(_seed_random_button)
	return row


func _wrap_labeled(label_text: String, control: Control) -> Control:
	var row = HBoxContainer.new()
	var label = Label.new()
	label.text = label_text
	row.add_child(label)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	return row


func _build_section_label(text: String) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	label.add_theme_font_size_override("font_size", 16)
	return label


func _build_separator() -> HSeparator:
	var sep = HSeparator.new()
	sep.custom_minimum_size = Vector2(0, 4)
	return sep


func _on_shape_changed(_index: int) -> void:
	_refresh_controls()
	_generate_map()


func _on_wall_prob_changed(value: float) -> void:
	_wall_prob_label.text = "%.2f" % value
	if _connectivity_check.button_pressed:
		return
	_generate_map()


func _on_option_changed(_v = null) -> void:
	_generate_map()


func _on_seed_randomize() -> void:
	_seed_spin.value = randi() % 100000
	_generate_map()


func _on_generate_pressed() -> void:
	_generate_map()


func _on_save_pressed() -> void:
	if _current_data == null:
		return

	var resource = HexMapResource.from_map_data(_current_data)
	var dialog = EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.add_filter("*.tres", "Hex Map Resource")
	dialog.current_file = "hex_map.tres"
	dialog.file_selected.connect(_on_save_file_selected.bind(resource))
	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_centered_ratio(0.5)


func _on_save_file_selected(path: String, resource: HexMapResource) -> void:
	var error = ResourceSaver.save(resource, path)
	if error == OK:
		EditorInterface.get_resource_filesystem().scan()
		print("Hex Map saved to: %s" % path)
	else:
		push_error("Failed to save hex map: %d" % error)


func _refresh_controls() -> void:
	var shape = _shape_option.selected
	var is_torus = shape == SHAPE_TORUS

	_size_container.get_child(0).visible = shape == SHAPE_RECTANGLE
	_size_container.get_child(1).visible = shape == SHAPE_HEXAGON
	_size_container.get_child(2).visible = is_torus

	_symmetric_check.disabled = not is_torus
	if not is_torus:
		_symmetric_check.button_pressed = false


func _uses_symmetric_generation() -> bool:
	return _shape_option.selected == SHAPE_TORUS \
		and _symmetric_check.button_pressed \
		and _torus_size() % 2 == 1


func _generate_map() -> void:
	var shape = _shape_option.selected
	var wall_prob = _wall_prob_slider.value
	var seed = int(_seed_spin.value)
	var connected = _connectivity_check.button_pressed
	var protected = [HexVector.zero()]

	match shape:
		SHAPE_HEXAGON:
			_current_data = HexMapGenerator.generate_hexagon(
				_hex_radius_spin.value,
				wall_prob,
				seed,
				connected,
				protected
			)
		SHAPE_TORUS:
			if _uses_symmetric_generation():
				_current_data = HexMapGenerator.generate_symmetric_square(
					(_torus_size() - 1) / 2,
					wall_prob,
					seed,
					connected,
					protected,
					20,
					[],
					true
				)
			else:
				_current_data = HexMapGenerator.generate_toric_square(
					_torus_size(),
					wall_prob,
					seed,
					connected,
					protected
				)
		_:
			_current_data = HexMapGenerator.generate_rectangle(
				int(_rect_width_spin.value),
				int(_rect_height_spin.value),
				wall_prob,
				seed,
				connected,
				false,
				protected
			)

	_update_stats()


func _update_stats() -> void:
	if _current_data == null:
		_stats_label.text = "No map data"
		return

	var connected = HexMapGenerator.is_floor_connected(_current_data)
	var mode = _generation_mode_string()
	_stats_label.text = "%s  seed=%d  wall_prob=%.2f  cells=%d  walls=%d  floors=%d  connected=%s%s" % [
		SHAPE_NAMES[_shape_option.selected],
		int(_seed_spin.value),
		_wall_prob_slider.value,
		_current_data.cells.size(),
		_current_data.walls.size(),
		_current_data.floor_cells().size(),
		"yes" if connected else "no",
		"  %s" % mode if mode != "" else "",
	]


func _generation_mode_string() -> String:
	if _uses_symmetric_generation():
		return "sym-gen"
	if _shape_option.selected == SHAPE_TORUS and _symmetric_check.button_pressed:
		return "sym-gen(odd-only)"
	return ""


func _torus_size() -> int:
	if _shape_option.selected != SHAPE_TORUS:
		return TORIC_SIZE_OPTIONS[0]
	return TORIC_SIZE_OPTIONS[_torus_size_option.selected]
