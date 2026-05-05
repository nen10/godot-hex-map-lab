@tool
class_name HexMapGenDock
extends Control

const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexRandomizer = preload("res://addons/hex_map_kit/core/hex_randomizer.gd")

const GENERATE_SIMPLE := 0
const GENERATE_SYMMETRIC := 1

const SHAPE_HEXAGON := 0
const SHAPE_RECTANGLE := 1
const SHAPE_TORUS := 2

const GENERATE_NAMES := ["Simple", "Hex-inward Markov mesh model"]
const SHAPE_NAMES_SIMPLE := ["Hexagon", "Rectangle"]
const SHAPE_NAMES_SYMMETRIC := ["Hexagon", "Square", "Torus"]
const TORIC_SIZE_OPTIONS := [7, 9, 11, 13]

var _generate_option: OptionButton
var _shape_simple_row: HBoxContainer
var _shape_option_simple: OptionButton
var _shape_symmetric_row: HBoxContainer
var _shape_option_symmetric: OptionButton
var _size_container: VBoxContainer

var _rect_row: HBoxContainer
var _rect_width_spin: SpinBox
var _rect_height_spin: SpinBox

var _hex_row: HBoxContainer
var _hex_radius_spin: SpinBox

var _radius_row: HBoxContainer
var _gen_radius_spin: SpinBox

var _wall_prob_slider: HSlider
var _wall_prob_label: Label
var _seed_spin: SpinBox
var _seed_random_button: Button

var _connectivity_check: CheckButton

var _sym_options_container: VBoxContainer
var _dist_option: OptionButton
var _dist_edit_button: Button
var _current_dist_file := ""
var _current_distribution = null

var _tile_orientation_option: OptionButton
var _tile_width_spin: SpinBox
var _tile_height_spin: SpinBox
var _floor_source_spin: SpinBox
var _floor_atlas_x_spin: SpinBox
var _floor_atlas_y_spin: SpinBox
var _wall_source_spin: SpinBox
var _wall_atlas_x_spin: SpinBox
var _wall_atlas_y_spin: SpinBox
var _sample_tiles_button: Button

var _generate_button: Button
var _save_button: Button
var _apply_layer_button: Button
var _generate_apply_button: Button
var _stats_label: Label

var _current_data = null
var _current_orientation := HexMapResource.ORIENTATION_FLAT_TOP


func _ready() -> void:
	custom_minimum_size = Vector2(260, 220)
	_build_ui()
	_refresh_controls()
	_generate_map()


func _build_ui() -> void:
	var root = VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	root.add_child(_build_section_label("Hex Map Kit"))

	_generate_option = OptionButton.new()
	for name in GENERATE_NAMES:
		_generate_option.add_item(name)
	_generate_option.item_selected.connect(_on_generate_changed)
	root.add_child(_wrap_labeled("Generator", _generate_option))

	_shape_option_simple = OptionButton.new()
	for name in SHAPE_NAMES_SIMPLE:
		_shape_option_simple.add_item(name)
	_shape_option_simple.item_selected.connect(_on_shape_changed)
	_shape_simple_row = HBoxContainer.new()
	_shape_simple_row.visible = false
	root.add_child(_shape_simple_row)
	_shape_simple_row.add_child(_wrap_labeled("Shape", _shape_option_simple))

	_shape_option_symmetric = OptionButton.new()
	for name in SHAPE_NAMES_SYMMETRIC:
		_shape_option_symmetric.add_item(name)
	_shape_option_symmetric.item_selected.connect(_on_option_changed)
	_shape_symmetric_row = HBoxContainer.new()
	_shape_symmetric_row.visible = false
	root.add_child(_shape_symmetric_row)
	_shape_symmetric_row.add_child(_wrap_labeled("Shape", _shape_option_symmetric))

	root.add_child(_build_separator())
	_size_container = VBoxContainer.new()
	root.add_child(_size_container)
	_build_rectangle_size_controls()
	_build_hexagon_size_controls()
	_build_gen_radius_controls()

	root.add_child(_build_separator())
	root.add_child(_build_wall_probability_controls())
	root.add_child(_build_seed_controls())

	root.add_child(_build_separator())
	_connectivity_check = CheckButton.new()
	_connectivity_check.text = "Restore Connectivity"
	_connectivity_check.button_pressed = true
	_connectivity_check.toggled.connect(_on_option_changed)
	root.add_child(_connectivity_check)

	_sym_options_container = VBoxContainer.new()
	_sym_options_container.visible = false
	root.add_child(_sym_options_container)

	var dist_row = HBoxContainer.new()
	var dist_label = Label.new()
	dist_label.text = "  Dist"
	dist_row.add_child(dist_label)
	_dist_option = OptionButton.new()
	_refill_dist_options()
	_dist_option.select(0)
	_dist_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dist_option.item_selected.connect(_on_dist_changed)
	dist_row.add_child(_dist_option)

	_dist_edit_button = Button.new()
	_dist_edit_button.text = "Edit"
	_dist_edit_button.pressed.connect(_on_dist_edit_pressed)
	dist_row.add_child(_dist_edit_button)
	_sym_options_container.add_child(dist_row)

	root.add_child(_build_separator())
	root.add_child(_build_tile_layer_controls())

	root.add_child(_build_separator())
	_stats_label = Label.new()
	_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stats_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	root.add_child(_stats_label)

	root.add_child(_build_separator())
	var button_row = HBoxContainer.new()

	_apply_layer_button = Button.new()
	_apply_layer_button.text = "Apply Layer"
	_apply_layer_button.pressed.connect(_on_apply_layer_pressed)
	button_row.add_child(_apply_layer_button)

	_generate_button = Button.new()
	_generate_button.text = "Generate"
	_generate_button.pressed.connect(_on_generate_pressed)
	button_row.add_child(_generate_button)

	_save_button = Button.new()
	_save_button.text = "Save .tres"
	_save_button.pressed.connect(_on_save_pressed)
	button_row.add_child(_save_button)

	_generate_apply_button = Button.new()
	_generate_apply_button.text = "Generate & Apply"
	_generate_apply_button.pressed.connect(_on_generate_apply_pressed)
	button_row.add_child(_generate_apply_button)

	root.add_child(button_row)


func _build_rectangle_size_controls() -> void:
	_rect_row = HBoxContainer.new()
	var wl = Label.new()
	wl.text = "Width"
	_rect_row.add_child(wl)
	_rect_width_spin = SpinBox.new()
	_rect_width_spin.min_value = 1
	_rect_width_spin.max_value = 20
	_rect_width_spin.value = 8
	_rect_width_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rect_width_spin.value_changed.connect(_on_option_changed)
	_rect_row.add_child(_rect_width_spin)
	var hl = Label.new()
	hl.text = "Height"
	_rect_row.add_child(hl)
	_rect_height_spin = SpinBox.new()
	_rect_height_spin.min_value = 1
	_rect_height_spin.max_value = 20
	_rect_height_spin.value = 6
	_rect_height_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rect_height_spin.value_changed.connect(_on_option_changed)
	_rect_row.add_child(_rect_height_spin)
	_size_container.add_child(_rect_row)


func _build_hexagon_size_controls() -> void:
	_hex_row = HBoxContainer.new()
	var label = Label.new()
	label.text = "Radius"
	_hex_row.add_child(label)
	_hex_radius_spin = SpinBox.new()
	_hex_radius_spin.min_value = 1
	_hex_radius_spin.max_value = 15
	_hex_radius_spin.value = 3
	_hex_radius_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hex_radius_spin.value_changed.connect(_on_option_changed)
	_hex_row.add_child(_hex_radius_spin)
	_hex_row.visible = false
	_size_container.add_child(_hex_row)


func _build_gen_radius_controls() -> void:
	_radius_row = HBoxContainer.new()
	var label = Label.new()
	label.text = "Generation Radius"
	_radius_row.add_child(label)
	_gen_radius_spin = SpinBox.new()
	_gen_radius_spin.min_value = 1
	_gen_radius_spin.max_value = 15
	_gen_radius_spin.value = 3
	_gen_radius_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_gen_radius_spin.value_changed.connect(_on_option_changed)
	_radius_row.add_child(_gen_radius_spin)
	_radius_row.visible = false
	_size_container.add_child(_radius_row)


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


func _build_tile_layer_controls() -> Control:
	var box = VBoxContainer.new()
	box.add_child(_build_section_label("TileMapLayer"))

	_tile_orientation_option = OptionButton.new()
	_tile_orientation_option.add_item("flat-top / Vertical Offset")
	_tile_orientation_option.add_item("pointy-top / Horizontal Offset")
	_tile_orientation_option.select(0)
	_tile_orientation_option.item_selected.connect(_on_tile_orientation_changed)
	box.add_child(_wrap_labeled("Orientation", _tile_orientation_option))

	var size_row = HBoxContainer.new()
	size_row.add_child(_build_small_label("Tile Size"))
	_tile_width_spin = _new_int_spin(64, 1, 512)
	_tile_height_spin = _new_int_spin(57, 1, 512)
	size_row.add_child(_tile_width_spin)
	size_row.add_child(_tile_height_spin)
	box.add_child(size_row)

	var floor_row = HBoxContainer.new()
	floor_row.add_child(_build_small_label("Floor"))
	_floor_source_spin = _new_int_spin(0, 0, 1024)
	_floor_atlas_x_spin = _new_int_spin(0, 0, 4096)
	_floor_atlas_y_spin = _new_int_spin(0, 0, 4096)
	floor_row.add_child(_floor_source_spin)
	floor_row.add_child(_floor_atlas_x_spin)
	floor_row.add_child(_floor_atlas_y_spin)
	box.add_child(floor_row)

	var wall_row = HBoxContainer.new()
	wall_row.add_child(_build_small_label("Wall"))
	_wall_source_spin = _new_int_spin(0, 0, 1024)
	_wall_atlas_x_spin = _new_int_spin(1, 0, 4096)
	_wall_atlas_y_spin = _new_int_spin(0, 0, 4096)
	wall_row.add_child(_wall_source_spin)
	wall_row.add_child(_wall_atlas_x_spin)
	wall_row.add_child(_wall_atlas_y_spin)
	box.add_child(wall_row)

	_sample_tiles_button = Button.new()
	_sample_tiles_button.text = "Use Sample Tiles"
	_sample_tiles_button.pressed.connect(_on_sample_tiles_pressed)
	box.add_child(_sample_tiles_button)

	return box


func _new_int_spin(value: int, min_value: int, max_value: int) -> SpinBox:
	var spin = SpinBox.new()
	spin.min_value = min_value
	spin.max_value = max_value
	spin.step = 1
	spin.value = value
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return spin


func _build_small_label(text: String) -> Label:
	var label = Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(72, 0)
	return label


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


func _on_generate_changed(_index: int) -> void:
	_refresh_controls()
	_generate_map()


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


func _on_tile_orientation_changed(_index: int) -> void:
	_current_orientation = _tile_settings_orientation()


func _on_generate_pressed() -> void:
	_generate_map()


func _on_generate_apply_pressed() -> void:
	var layer = _find_tile_map_layer()
	if layer == null:
		push_error("No TileMapLayer found in the scene. Add one first.")
		return
	generate_and_apply_to_tile_map_layer(layer)
	print("Generated and applied hex map to TileMapLayer: %s" % layer.name)


func _on_sample_tiles_pressed() -> void:
	var layer = _find_tile_map_layer()
	if layer == null:
		push_error("No TileMapLayer found in the scene. Add one first.")
		return
	if setup_sample_tiles_on_tile_map_layer(layer):
		print("Configured sample hex tiles on TileMapLayer: %s" % layer.name)


func _on_save_pressed() -> void:
	if _current_data == null:
		return

	var resource = current_resource()
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


func _on_apply_layer_pressed() -> void:
	if _current_data == null:
		return

	var layer = _find_tile_map_layer()
	if layer == null:
		push_error("No TileMapLayer found in the scene. Add one first.")
		return

	apply_current_data_to_tile_map_layer(layer)
	print("Applied hex map to TileMapLayer: %s" % layer.name)


func generate_and_apply_to_tile_map_layer(layer) -> bool:
	_generate_map()
	return apply_current_data_to_tile_map_layer(layer)


func apply_current_data_to_tile_map_layer(layer) -> bool:
	if _current_data == null or layer == null:
		return false

	_current_orientation = _tile_settings_orientation()
	var flat_top := _tile_settings_flat_top()
	if layer is TileMapLayer:
		if layer.tile_set == null:
			layer.tile_set = TileSet.new()
		HexMapTileAdapter.configure_hex_tile_set(
			layer.tile_set,
			flat_top,
			_tile_settings_tile_size()
		)

	HexMapTileAdapter.apply_to_tile_map_layer(
		layer,
		_current_data,
		int(_floor_source_spin.value),
		Vector2i(int(_floor_atlas_x_spin.value), int(_floor_atlas_y_spin.value)),
		int(_wall_source_spin.value),
		Vector2i(int(_wall_atlas_x_spin.value), int(_wall_atlas_y_spin.value)),
		true,
		flat_top
	)
	return true


func setup_sample_tiles_on_tile_map_layer(layer) -> bool:
	if not layer is TileMapLayer:
		return false

	_current_orientation = _tile_settings_orientation()
	if layer.tile_set == null:
		layer.tile_set = TileSet.new()

	_tile_width_spin.value = HexMapTileAdapter.SAMPLE_TILE_SIZE.x
	_tile_height_spin.value = HexMapTileAdapter.SAMPLE_TILE_SIZE.y
	var ok = HexMapTileAdapter.configure_sample_tile_set(
		layer.tile_set,
		_tile_settings_flat_top(),
		HexMapTileAdapter.SAMPLE_TILE_SIZE
	)
	if not ok:
		return false

	_floor_source_spin.value = 0
	_floor_atlas_x_spin.value = 0
	_floor_atlas_y_spin.value = 0
	_wall_source_spin.value = 0
	_wall_atlas_x_spin.value = 1
	_wall_atlas_y_spin.value = 0
	return true


func current_resource() -> HexMapResource:
	if _current_data == null:
		return null
	_current_orientation = _tile_settings_orientation()
	return HexMapResource.from_map_data(_current_data, _current_orientation)


func _tile_settings_orientation() -> int:
	if _tile_orientation_option == null:
		return _current_orientation
	if _tile_orientation_option.selected == 1:
		return HexMapResource.ORIENTATION_POINTY_TOP
	return HexMapResource.ORIENTATION_FLAT_TOP


func _tile_settings_flat_top() -> bool:
	return _tile_settings_orientation() == HexMapResource.ORIENTATION_FLAT_TOP


func _tile_settings_tile_size() -> Vector2i:
	return Vector2i(int(_tile_width_spin.value), int(_tile_height_spin.value))


func _find_tile_map_layer():
	var selection = EditorInterface.get_selection()
	var selected = selection.get_selected_nodes()
	for node in selected:
		if node is TileMapLayer:
			return node

	var root = EditorInterface.get_edited_scene_root()
	if root == null:
		return null
	return _find_tile_map_layer_recursive(root)


func _find_tile_map_layer_recursive(node: Node):
	if node is TileMapLayer:
		return node
	for child in node.get_children():
		var found = _find_tile_map_layer_recursive(child)
		if found:
			return found
	return null


func _refresh_controls() -> void:
	var gen_method = _generate_option.selected
	match _generate_option.selected:
		GENERATE_SYMMETRIC:
			_shape_symmetric_row.visible = true
			_shape_simple_row.visible = false
			_rect_row.visible = false
			_hex_row.visible = false
			_radius_row.visible = true
			_sym_options_container.visible = true
		GENERATE_SIMPLE, _:
			_shape_symmetric_row.visible = false
			_shape_simple_row.visible = true
			_rect_row.visible = (_shape_option_simple.selected == SHAPE_RECTANGLE)
			_hex_row.visible = (_shape_option_simple.selected == SHAPE_HEXAGON)
			_radius_row.visible = false
			_sym_options_container.visible = false


func _uses_symmetric_generation() -> bool:
	return _generate_option.selected == GENERATE_SYMMETRIC


func _generate_map() -> void:
	var gen_method = _generate_option.selected
	var shape = 0
	var wall_prob = _wall_prob_slider.value
	var seed = int(_seed_spin.value)
	var connected = _connectivity_check.button_pressed
	var protected = [HexVector.zero()]
	var symmetric = _uses_symmetric_generation()
	var dist_id = HexRandomizer.get_preset_id(_dist_option.get_item_text(_dist_option.selected))


	match _generate_option.selected:
		GENERATE_SYMMETRIC:
			shape = _shape_option_symmetric.selected
			symmetric = true
		GENERATE_SIMPLE, _: 
			shape = _shape_option_simple.selected
			symmetric = false

	match shape:
		SHAPE_HEXAGON:
			if symmetric:
				_current_data = HexMapGenerator.generate_symmetric_hexagon(
					int(_gen_radius_spin.value),
					wall_prob,
					seed,
					connected,
					protected,
					dist_id,
					[],
					_current_distribution
				)
			else:
				_current_data = HexMapGenerator.generate_hexagon(
					_hex_radius_spin.value,
					wall_prob,
					seed,
					connected,
					protected
				)
		SHAPE_RECTANGLE:
			if symmetric:
				_current_data = HexMapGenerator.generate_symmetric_square(
					int(_gen_radius_spin.value),
					wall_prob,
					seed,
					connected,
					protected,
					dist_id,
					[],
					false,
					_current_distribution
				)
			else:
				_current_data = HexMapGenerator.generate_rectangle(
					int(_rect_width_spin.value),
					int(_rect_height_spin.value),
					wall_prob,
					seed,
					connected,
					false,
					protected
				)
		SHAPE_TORUS, _:
			_current_data = HexMapGenerator.generate_symmetric_square(
				int(_gen_radius_spin.value),
				wall_prob,
				seed,
				connected,
				protected,
				dist_id,
				[],
				true,
				_current_distribution
			)

	_update_stats()


func _update_stats() -> void:
	if _current_data == null:
		_stats_label.text = "No map data"
		return

	var is_connected = HexMapGenerator.is_floor_connected(_current_data)
	_stats_label.text = "%s  seed=%d  wall_prob=%.2f  cells=%d  walls=%d  floors=%d  connected=%s%s" % [
		_shape_string(),
		int(_seed_spin.value),
		_wall_prob_slider.value,
		_current_data.cells.size(),
		_current_data.walls.size(),
		_current_data.floor_cells().size(),
		"yes" if is_connected else "no",
		"  %s" % GENERATE_NAMES[_generate_option.selected],
	]

func _shape_string() -> String:
	match _generate_option.selected:
		GENERATE_SIMPLE:
			return SHAPE_NAMES_SIMPLE[_shape_option_simple.selected]
		GENERATE_SYMMETRIC:
			return SHAPE_NAMES_SYMMETRIC[_shape_option_symmetric.selected]
		_:
			return ""


func _on_dist_edit_pressed() -> void:
	var path = _current_dist_file
	if _dist_option.selected >= 0 and _dist_option.selected < HexRandomizer.get_preset_names().size():
		path = ""
	var editor = load("res://addons/hex_map_kit/editor/hex_dist_editor.gd").new(
		path,
		Callable(self, "_on_dist_editor_apply"),
		Callable(self, "_on_dist_editor_cancel")
	)
	EditorInterface.get_base_control().add_child(editor)
	editor.popup_centered_ratio(0.7)


func _on_dist_editor_apply(filepath: String) -> void:
	_current_dist_file = filepath
	_current_distribution = load(filepath)
	_refill_dist_options()
	_generate_map()


func _on_dist_editor_cancel() -> void:
	pass


func _on_dist_changed(idx: int) -> void:
	var preset_count = HexRandomizer.get_preset_names().size()
	if idx >= 0 and idx < preset_count:
		_current_dist_file = ""
		_current_distribution = null
	else:
		# Custom entry selected — keep current distribution
		pass
	_generate_map()


func _refill_dist_options() -> void:
	_dist_option.clear()
	for preset_name in HexRandomizer.get_preset_names():
		_dist_option.add_item(preset_name)
	if _current_dist_file != "":
		_dist_option.add_item(_current_dist_file)
		_dist_option.select(_dist_option.item_count - 1)
