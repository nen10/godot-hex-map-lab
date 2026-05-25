@tool
class_name HexMapGenDock
extends Control

signal generation_finished(cancelled: bool)

const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexOverlayData = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexOverlayResource = preload("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd")
const HexOverlayTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_overlay_tile_adapter.gd")
const HexAdjacencyRuleSet = preload("res://addons/hex_map_kit/adapter/hex_adjacency_rule_set.gd")
const HexAdjacencyRuleEditor = preload("res://addons/hex_map_kit/editor/hex_adjacency_rule_editor.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexRandomizer = preload("res://addons/hex_map_kit/core/hex_randomizer.gd")

const GENERATE_SIMPLE := 0
const GENERATE_SYMMETRIC := 1

const SHAPE_HEXAGON := 0
const SHAPE_RECTANGLE := 1
const SHAPE_TORUS := 2

const GENERATE_NAMES := ["Uniform Distribution", "Markov Mesh"]
const SHAPE_NAMES_SIMPLE := ["Hexagon", "Rect"]
const SHAPE_NAMES_SYMMETRIC := ["Hexagon", "Square"]
const TORIC_SIZE_OPTIONS := [7, 9, 11, 13]

const CONNECT_METHOD_NAMES := ["Sparse", "Dense", "None"]
const CONNECT_METHOD_VALUES := [
	HexMapGenerator.CONNECT_SPARSE,
	HexMapGenerator.CONNECT_DENSE,
	HexMapGenerator.CONNECT_NONE,
]
const GENERATION_PROGRESS_START := 0.1
const GENERATION_PROGRESS_SCALE := 0.8
const GENERATION_PROGRESS_UPDATE := 0.95
const GENERATION_PROGRESS_MIN_VISIBLE_SEC := 0.8
const TILE_TARGET_AUTO_INDEX := 0
const TILE_TARGET_LAYER_INDEX_OFFSET := 1
const TILE_TARGET_AUTO_LABEL := "Auto: Selected / first scene layer"
const TILE_TARGET_ADD_LAYER_LABEL := "Add new layer..."
const NEW_TILE_LAYER_BASE_NAME := "HexMapLayer"
const OVERLAY_DEFAULT_ITEM_NAME := "OverlayItem"
const OVERLAY_WRITE_POLICIES := [
	HexOverlayData.APPLY_CLEAR_AND_WRITE,
	HexOverlayData.APPLY_ADD_ITEM,
]
const OVERLAY_WRITE_POLICY_NAMES := [
	"Clear And Write",
	"Add Item",
]
const OVERLAY_EXISTING_POLICIES := [
	HexOverlayData.EXISTING_MERGE,
	HexOverlayData.EXISTING_REPLACE,
	HexOverlayData.EXISTING_SKIP,
]
const OVERLAY_EXISTING_POLICY_NAMES := [
	"Merge Existing",
	"Replace Existing",
	"Skip Existing",
]
const OVERLAY_QUERY_OPERATIONS := [
	HexOverlayData.ITEM_QUERY_OR,
	HexOverlayData.ITEM_QUERY_AND,
]
const OVERLAY_QUERY_OPERATION_NAMES := [
	"Any Item",
	"All Items",
]

var _generate_option: OptionButton
var _shape_simple_row: HBoxContainer
var _shape_option_simple: OptionButton
var _shape_symmetric_row: HBoxContainer
var _shape_option_symmetric: OptionButton
var _size_container: HBoxContainer

var _rect_row: HBoxContainer
var _rect_width_spin: SpinBox
var _rect_height_spin: SpinBox

var _hex_row: HBoxContainer
var _hex_radius_spin: SpinBox

var _radius_row: HBoxContainer
var _gen_radius_spin: SpinBox

var _wall_prob_slider: HSlider
var _wall_prob_label: Label
var _wall_prob_row: Control
var _seed_spin: SpinBox
var _seed_random_button: Button

var _connect_method_option: OptionButton
var _torus_connectivity_check: CheckButton

var _sym_options_container: VBoxContainer
var _dist_option: OptionButton
var _dist_edit_button: Button
var _current_dist_file := ""
var _current_distribution = null

var _tile_layer_option: OptionButton
var _tile_layer_refresh_button: Button
var _tile_layer_nodes: Array[Node] = []
var _tile_layer_scan_root: Node = null
var _test_selected_tile_map_layer: Node = null
var _tile_orientation_option: OptionButton
var _tile_width_spin: SpinBox
var _tile_height_spin: SpinBox
var _floor_source_spin: SpinBox
var _floor_atlas_x_spin: SpinBox
var _floor_atlas_y_spin: SpinBox
var _wall_source_spin: SpinBox
var _wall_atlas_x_spin: SpinBox
var _wall_atlas_y_spin: SpinBox
var _atlas_image_button: Button
var _sample_tiles_button: Button
var _current_atlas_image_path := ""

var _overlay_mode_check: CheckButton
var _overlay_controls_container: VBoxContainer
var _overlay_item_name_edit: LineEdit
var _overlay_item_limit_check: CheckButton
var _overlay_item_limit_spin: SpinBox
var _overlay_item_pool_container: VBoxContainer
var _overlay_add_item_button: Button
var _overlay_item_pool_rows: Array[Dictionary] = []
var _overlay_mask_container: VBoxContainer
var _overlay_mask_primary_check: CheckButton
var _overlay_mask_primary_items_edit: LineEdit
var _overlay_mask_overlay_check: CheckButton
var _overlay_mask_overlay_items_edit: LineEdit
var _overlay_mask_operation_option: OptionButton
var _overlay_adjacency_check: CheckButton
var _overlay_reference_container: VBoxContainer
var _overlay_reference_primary_check: CheckButton
var _overlay_reference_primary_items_edit: LineEdit
var _overlay_reference_overlay_check: CheckButton
var _overlay_reference_overlay_items_edit: LineEdit
var _overlay_reference_operation_option: OptionButton
var _overlay_neighbor_radius_spin: SpinBox
var _overlay_adjacency_rules_edit: LineEdit
var _overlay_adjacency_rules_edit_button: Button
var _overlay_write_policy_option: OptionButton
var _overlay_existing_policy_option: OptionButton

var _generate_button: Button
var _save_button: Button
var _apply_layer_button: Button
var _stats_label: Label
var _generation_progress_container: VBoxContainer
var _generation_progress_status_label: Label
var _generation_progress_bar: ProgressBar
var _generation_progress_cancel_button: Button

var _current_data = null
var _current_orientation := HexMapResource.ORIENTATION_FLAT_TOP
var _generation_running := false
var _generation_cancel_requested := false
var _generation_progress := 0.0
var _generation_status := "Ready"
var _last_generation_cancelled := false
var _generation_thread: Thread
var _generation_mutex := Mutex.new()
var _generation_id := 0
var _generation_chunk_size := 1
var _generation_progress_delay_usec := 0
var _generation_core_progress_event_count := 0
var _generation_cancel_poll_count := 0
var _generation_last_core_progress := 0.0
var _generation_progress_hide_token := 0
var _generation_progress_scheduled_hide_token := 0
var _generation_progress_visible_started_msec := 0
var _generation_progress_hide_after_msec := 0
var _suppress_tile_settings_apply := false
var _current_overlay_data = null


func _ready() -> void:
	set_process(true)
	custom_minimum_size = Vector2(260, 220)
	_build_ui()
	refresh_tile_layer_options()
	_refresh_controls()
	_update_stats()


func _process(_delta: float) -> void:
	_process_generation_progress_hide_timer()


func _exit_tree() -> void:
	_generation_progress_hide_token += 1
	_generation_progress_hide_after_msec = 0
	if _generation_running:
		_set_generation_cancel_requested(true)
	if _generation_thread != null:
		_generation_thread.wait_to_finish()
		_generation_thread = null
	_hide_generation_progress_controls()


func _build_ui() -> void:
	var root = VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	root.add_child(_build_section_label("Hex Map Kit"))

	_size_container = HBoxContainer.new()
	root.add_child(_size_container)

	_shape_option_simple = OptionButton.new()
	for name in SHAPE_NAMES_SIMPLE:
		_shape_option_simple.add_item(name)
	_shape_option_simple.item_selected.connect(_on_shape_changed)
	_shape_option_simple.select(1)
	_shape_simple_row = HBoxContainer.new()
	_shape_simple_row.visible = false
	_size_container.add_child(_shape_simple_row)
	_shape_simple_row.add_child(_wrap_labeled("Shape", _shape_option_simple))

	_shape_option_symmetric = OptionButton.new()
	for name in SHAPE_NAMES_SYMMETRIC:
		_shape_option_symmetric.add_item(name)
	_shape_option_symmetric.item_selected.connect(_on_symmetric_shape_changed)
	_shape_option_symmetric.select(1)
	_shape_symmetric_row = HBoxContainer.new()
	_shape_symmetric_row.visible = false
	_size_container.add_child(_shape_symmetric_row)
	_shape_symmetric_row.add_child(_wrap_labeled("Shape", _shape_option_symmetric))


	_build_rectangle_size_controls()
	_build_hexagon_size_controls()
	_build_gen_radius_controls()

	_torus_connectivity_check = CheckButton.new()
	_torus_connectivity_check.text = "Toric Connection"
	_torus_connectivity_check.button_pressed = false
	_torus_connectivity_check.toggled.connect(_on_torus_connectivity_toggled)
	_size_container.add_child(_torus_connectivity_check)

	_connect_method_option = OptionButton.new()
	for name in CONNECT_METHOD_NAMES:
		_connect_method_option.add_item(name)
	_connect_method_option.select(0)
	_connect_method_option.item_selected.connect(_on_option_changed)
	root.add_child(_wrap_labeled("Passage Generator / Overlay Deductor", _connect_method_option))

	_generate_option = OptionButton.new()
	for name in GENERATE_NAMES:
		_generate_option.add_item(name)
	_generate_option.item_selected.connect(_on_generate_changed)
	_generate_option.select(1)
	root.add_child(_wrap_labeled("Wall Generator / Overlay Generator", _generate_option))
	root.add_child(_build_overlay_controls())

	_sym_options_container = VBoxContainer.new()
	_sym_options_container.visible = false
	root.add_child(_sym_options_container)

	var dist_row = HBoxContainer.new()
	var dist_label = Label.new()
	dist_label.text = "  Markov Mesh Rule Set"
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

	_wall_prob_row = _build_wall_probability_controls()
	root.add_child(_wall_prob_row)
	root.add_child(_build_seed_controls())

	root.add_child(_build_separator())
	root.add_child(_build_generation_progress_controls())
	var button_row = HBoxContainer.new()

	_generate_button = Button.new()
	_generate_button.text = "Primary Generation"
	_generate_button.pressed.connect(_on_generate_pressed)
	button_row.add_child(_generate_button)

	_apply_layer_button = Button.new()
	_apply_layer_button.text = "Apply Layer"
	_apply_layer_button.pressed.connect(_on_apply_layer_pressed)
	button_row.add_child(_apply_layer_button)

	_save_button = Button.new()
	_save_button.text = "Save .tres"
	_save_button.pressed.connect(_on_save_pressed)
	button_row.add_child(_save_button)

	root.add_child(button_row)

	_stats_label = Label.new()
	_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stats_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	root.add_child(_stats_label)

	root.add_child(_build_separator())
	root.add_child(_build_tile_layer_controls())


func _build_overlay_controls() -> Control:
	var box = VBoxContainer.new()

	_overlay_mode_check = CheckButton.new()
	_overlay_mode_check.text = "Overlay"
	_overlay_mode_check.button_pressed = false
	_overlay_mode_check.toggled.connect(_on_overlay_mode_toggled)
	box.add_child(_overlay_mode_check)

	_overlay_controls_container = VBoxContainer.new()
	_overlay_controls_container.visible = false
	box.add_child(_overlay_controls_container)

	var item_row = HBoxContainer.new()
	item_row.add_child(_build_small_label("Target Item"))
	_overlay_item_name_edit = LineEdit.new()
	_overlay_item_name_edit.text = OVERLAY_DEFAULT_ITEM_NAME
	_overlay_item_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_overlay_item_name_edit.text_changed.connect(_on_option_changed)
	item_row.add_child(_overlay_item_name_edit)
	_overlay_controls_container.add_child(item_row)

	var limit_row = HBoxContainer.new()
	_overlay_item_limit_check = CheckButton.new()
	_overlay_item_limit_check.text = "Item Num Limit"
	_overlay_item_limit_check.toggled.connect(_on_overlay_item_limit_toggled)
	limit_row.add_child(_overlay_item_limit_check)
	_overlay_item_limit_spin = _new_int_spin(1, 0, 1048576)
	_overlay_item_limit_spin.value_changed.connect(_on_option_changed)
	_overlay_item_limit_spin.visible = false
	limit_row.add_child(_overlay_item_limit_spin)
	_overlay_controls_container.add_child(limit_row)

	_overlay_item_pool_container = VBoxContainer.new()
	_overlay_controls_container.add_child(_overlay_item_pool_container)
	_add_overlay_item_pool_row(OVERLAY_DEFAULT_ITEM_NAME, 1.0)

	_overlay_add_item_button = Button.new()
	_overlay_add_item_button.text = "Add Item"
	_overlay_add_item_button.pressed.connect(_on_overlay_add_item_pressed)
	_overlay_controls_container.add_child(_overlay_add_item_button)

	_overlay_controls_container.add_child(_build_overlay_mask_controls())
	_overlay_controls_container.add_child(_build_overlay_adjacency_controls())

	_overlay_write_policy_option = OptionButton.new()
	for policy_name in OVERLAY_WRITE_POLICY_NAMES:
		_overlay_write_policy_option.add_item(policy_name)
	_overlay_write_policy_option.select(0)
	_overlay_write_policy_option.item_selected.connect(_on_option_changed)
	_overlay_controls_container.add_child(_wrap_labeled("Apply Write", _overlay_write_policy_option))

	_overlay_existing_policy_option = OptionButton.new()
	for policy_name in OVERLAY_EXISTING_POLICY_NAMES:
		_overlay_existing_policy_option.add_item(policy_name)
	_overlay_existing_policy_option.select(0)
	_overlay_existing_policy_option.item_selected.connect(_on_option_changed)
	_overlay_controls_container.add_child(_wrap_labeled("Existing Item", _overlay_existing_policy_option))

	return box


func _build_overlay_mask_controls() -> Control:
	_overlay_mask_container = VBoxContainer.new()
	_overlay_mask_container.add_child(_build_small_label("Placement Mask"))

	var primary_row = HBoxContainer.new()
	_overlay_mask_primary_check = CheckButton.new()
	_overlay_mask_primary_check.text = "Primary"
	_overlay_mask_primary_check.button_pressed = true
	_overlay_mask_primary_check.toggled.connect(_on_option_changed)
	primary_row.add_child(_overlay_mask_primary_check)
	_overlay_mask_primary_items_edit = LineEdit.new()
	_overlay_mask_primary_items_edit.text = "Floor"
	_overlay_mask_primary_items_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_overlay_mask_primary_items_edit.text_changed.connect(_on_option_changed)
	primary_row.add_child(_overlay_mask_primary_items_edit)
	_overlay_mask_container.add_child(primary_row)

	var overlay_row = HBoxContainer.new()
	_overlay_mask_overlay_check = CheckButton.new()
	_overlay_mask_overlay_check.text = "Overlay"
	_overlay_mask_overlay_check.button_pressed = false
	_overlay_mask_overlay_check.toggled.connect(_on_option_changed)
	overlay_row.add_child(_overlay_mask_overlay_check)
	_overlay_mask_overlay_items_edit = LineEdit.new()
	_overlay_mask_overlay_items_edit.text = ""
	_overlay_mask_overlay_items_edit.placeholder_text = "ItemA, ItemB"
	_overlay_mask_overlay_items_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_overlay_mask_overlay_items_edit.text_changed.connect(_on_option_changed)
	overlay_row.add_child(_overlay_mask_overlay_items_edit)
	_overlay_mask_container.add_child(overlay_row)

	_overlay_mask_operation_option = _new_query_operation_option()
	_overlay_mask_container.add_child(_wrap_labeled("Mask Set", _overlay_mask_operation_option))
	return _overlay_mask_container


func _build_overlay_adjacency_controls() -> Control:
	var box = VBoxContainer.new()
	_overlay_adjacency_check = CheckButton.new()
	_overlay_adjacency_check.text = "Enable Adjacency Reference"
	_overlay_adjacency_check.button_pressed = false
	_overlay_adjacency_check.toggled.connect(_on_overlay_adjacency_toggled)
	box.add_child(_overlay_adjacency_check)

	_overlay_reference_container = VBoxContainer.new()
	_overlay_reference_container.visible = false
	box.add_child(_overlay_reference_container)
	_overlay_reference_container.add_child(_build_small_label("Reference Items"))

	var primary_row = HBoxContainer.new()
	_overlay_reference_primary_check = CheckButton.new()
	_overlay_reference_primary_check.text = "Primary"
	_overlay_reference_primary_check.button_pressed = true
	_overlay_reference_primary_check.toggled.connect(_on_option_changed)
	primary_row.add_child(_overlay_reference_primary_check)
	_overlay_reference_primary_items_edit = LineEdit.new()
	_overlay_reference_primary_items_edit.text = "Wall"
	_overlay_reference_primary_items_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_overlay_reference_primary_items_edit.text_changed.connect(_on_option_changed)
	primary_row.add_child(_overlay_reference_primary_items_edit)
	_overlay_reference_container.add_child(primary_row)

	var overlay_row = HBoxContainer.new()
	_overlay_reference_overlay_check = CheckButton.new()
	_overlay_reference_overlay_check.text = "Overlay"
	_overlay_reference_overlay_check.button_pressed = false
	_overlay_reference_overlay_check.toggled.connect(_on_option_changed)
	overlay_row.add_child(_overlay_reference_overlay_check)
	_overlay_reference_overlay_items_edit = LineEdit.new()
	_overlay_reference_overlay_items_edit.text = ""
	_overlay_reference_overlay_items_edit.placeholder_text = "ItemA, ItemB"
	_overlay_reference_overlay_items_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_overlay_reference_overlay_items_edit.text_changed.connect(_on_option_changed)
	overlay_row.add_child(_overlay_reference_overlay_items_edit)
	_overlay_reference_container.add_child(overlay_row)

	_overlay_reference_operation_option = _new_query_operation_option()
	_overlay_reference_container.add_child(_wrap_labeled("Reference Set", _overlay_reference_operation_option))

	_overlay_neighbor_radius_spin = _new_int_spin(1, 1, 16)
	_overlay_neighbor_radius_spin.value_changed.connect(_on_option_changed)
	_overlay_reference_container.add_child(_wrap_labeled("Neighbor Radius", _overlay_neighbor_radius_spin))

	_overlay_adjacency_rules_edit = LineEdit.new()
	_overlay_adjacency_rules_edit.text = "default=0.0"
	_overlay_adjacency_rules_edit.placeholder_text = "default=0.2;1=0.8;2,1=0.4"
	_overlay_adjacency_rules_edit.text_changed.connect(_on_option_changed)
	var rules_row = HBoxContainer.new()
	rules_row.add_child(_build_small_label("Adjacency Rules"))
	_overlay_adjacency_rules_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rules_row.add_child(_overlay_adjacency_rules_edit)
	_overlay_adjacency_rules_edit_button = Button.new()
	_overlay_adjacency_rules_edit_button.text = "Edit"
	_overlay_adjacency_rules_edit_button.pressed.connect(_on_adjacency_rules_edit_pressed)
	rules_row.add_child(_overlay_adjacency_rules_edit_button)
	_overlay_reference_container.add_child(rules_row)
	return box


func _new_query_operation_option() -> OptionButton:
	var option = OptionButton.new()
	for operation_name in OVERLAY_QUERY_OPERATION_NAMES:
		option.add_item(operation_name)
	option.select(0)
	option.item_selected.connect(_on_option_changed)
	return option


func _build_rectangle_size_controls() -> void:
	_rect_row = HBoxContainer.new()
	var wl = Label.new()
	wl.text = "Width"
	_rect_row.add_child(wl)
	_rect_width_spin = SpinBox.new()
	_rect_width_spin.min_value = 1
	_rect_width_spin.max_value = 511
	_rect_width_spin.value = 32
	_rect_width_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rect_width_spin.value_changed.connect(_on_option_changed)
	_rect_row.add_child(_rect_width_spin)
	var hl = Label.new()
	hl.text = "Height"
	_rect_row.add_child(hl)
	_rect_height_spin = SpinBox.new()
	_rect_height_spin.min_value = 1
	_rect_height_spin.max_value = 511
	_rect_height_spin.value = 24
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
	_hex_radius_spin.max_value = 255
	_hex_radius_spin.value = 15
	_hex_radius_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hex_radius_spin.value_changed.connect(_on_option_changed)
	_hex_row.add_child(_hex_radius_spin)
	_hex_row.visible = false
	_size_container.add_child(_hex_row)


func _build_gen_radius_controls() -> void:
	_radius_row = HBoxContainer.new()
	var label = Label.new()
	label.text = "Radius"
	_radius_row.add_child(label)
	_gen_radius_spin = SpinBox.new()
	_gen_radius_spin.min_value = 1
	_gen_radius_spin.max_value = 255
	_gen_radius_spin.value = 15
	_gen_radius_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_gen_radius_spin.value_changed.connect(_on_option_changed)
	_radius_row.add_child(_gen_radius_spin)
	_radius_row.visible = false
	_size_container.add_child(_radius_row)


func _build_wall_probability_controls() -> Control:
	var row = HBoxContainer.new()
	var label = Label.new()
	label.text = "  Placement Probability (Non-Ref.)"
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

	var target_row = HBoxContainer.new()
	target_row.add_child(_build_small_label("Output Target"))
	_tile_layer_option = OptionButton.new()
	_tile_layer_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tile_layer_option.item_selected.connect(_on_tile_layer_target_selected)
	target_row.add_child(_tile_layer_option)
	_tile_layer_refresh_button = Button.new()
	_tile_layer_refresh_button.text = "Refresh"
	_tile_layer_refresh_button.pressed.connect(_on_tile_layer_refresh_pressed)
	target_row.add_child(_tile_layer_refresh_button)
	box.add_child(target_row)

	_tile_orientation_option = OptionButton.new()
	_tile_orientation_option.add_item("flat-top / Vertical Offset")
	_tile_orientation_option.add_item("pointy-top / Horizontal Offset")
	_tile_orientation_option.select(0)
	_tile_orientation_option.item_selected.connect(_on_tile_orientation_changed)
	box.add_child(_wrap_labeled("Orientation", _tile_orientation_option))

	var size_row = HBoxContainer.new()
	size_row.add_child(_build_small_label("Tile Size"))
	_tile_width_spin = _new_int_spin(64, 1, 512)
	_tile_width_spin.value_changed.connect(_on_tile_setting_changed)
	_tile_height_spin = _new_int_spin(57, 1, 512)
	_tile_height_spin.value_changed.connect(_on_tile_setting_changed)
	size_row.add_child(_tile_width_spin)
	size_row.add_child(_tile_height_spin)
	box.add_child(size_row)

	var floor_row = HBoxContainer.new()
	floor_row.add_child(_build_small_label("Floor"))
	_floor_source_spin = _new_int_spin(0, 0, 1024)
	_floor_source_spin.value_changed.connect(_on_tile_setting_changed)
	_floor_atlas_x_spin = _new_int_spin(0, 0, 4096)
	_floor_atlas_x_spin.value_changed.connect(_on_tile_setting_changed)
	_floor_atlas_y_spin = _new_int_spin(0, 0, 4096)
	_floor_atlas_y_spin.value_changed.connect(_on_tile_setting_changed)
	floor_row.add_child(_floor_source_spin)
	floor_row.add_child(_floor_atlas_x_spin)
	floor_row.add_child(_floor_atlas_y_spin)
	box.add_child(floor_row)

	var wall_row = HBoxContainer.new()
	wall_row.add_child(_build_small_label("Wall"))
	_wall_source_spin = _new_int_spin(0, 0, 1024)
	_wall_source_spin.value_changed.connect(_on_tile_setting_changed)
	_wall_atlas_x_spin = _new_int_spin(1, 0, 4096)
	_wall_atlas_x_spin.value_changed.connect(_on_tile_setting_changed)
	_wall_atlas_y_spin = _new_int_spin(0, 0, 4096)
	_wall_atlas_y_spin.value_changed.connect(_on_tile_setting_changed)
	wall_row.add_child(_wall_source_spin)
	wall_row.add_child(_wall_atlas_x_spin)
	wall_row.add_child(_wall_atlas_y_spin)
	box.add_child(wall_row)

	var atlas_row = HBoxContainer.new()
	_atlas_image_button = Button.new()
	_atlas_image_button.text = "Select Atlas Image"
	_atlas_image_button.pressed.connect(_on_atlas_image_pressed)
	atlas_row.add_child(_atlas_image_button)

	_sample_tiles_button = Button.new()
	_sample_tiles_button.text = "Use Sample Tiles"
	_sample_tiles_button.pressed.connect(_on_sample_tiles_pressed)
	atlas_row.add_child(_sample_tiles_button)
	box.add_child(atlas_row)

	return box


func _build_generation_progress_controls() -> Control:
	_generation_progress_container = VBoxContainer.new()
	_generation_progress_container.visible = false

	_generation_progress_status_label = Label.new()
	_generation_progress_status_label.text = "Ready"
	_generation_progress_container.add_child(_generation_progress_status_label)

	_generation_progress_bar = ProgressBar.new()
	_generation_progress_bar.min_value = 0.0
	_generation_progress_bar.max_value = 1.0
	_generation_progress_bar.step = 0.01
	_generation_progress_bar.value = 0.0
	_generation_progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_generation_progress_container.add_child(_generation_progress_bar)

	var cancel_row = HBoxContainer.new()
	_generation_progress_cancel_button = Button.new()
	_generation_progress_cancel_button.text = "Cancel"
	_generation_progress_cancel_button.disabled = true
	_generation_progress_cancel_button.pressed.connect(_on_cancel_generation_pressed)
	cancel_row.add_child(_generation_progress_cancel_button)
	_generation_progress_container.add_child(cancel_row)

	return _generation_progress_container


func _new_int_spin(value: int, min_value: int, max_value: int) -> SpinBox:
	var spin = SpinBox.new()
	spin.min_value = min_value
	spin.max_value = max_value
	spin.step = 1
	spin.value = value
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return spin


func _new_float_spin(value: float, min_value: float, max_value: float, step: float = 0.1) -> SpinBox:
	var spin = SpinBox.new()
	spin.min_value = min_value
	spin.max_value = max_value
	spin.step = step
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


func _add_overlay_item_pool_row(item_name: String = "", amount: float = 1.0) -> void:
	if _overlay_item_pool_container == null:
		return

	var row = HBoxContainer.new()
	var name_edit = LineEdit.new()
	name_edit.text = item_name if item_name != "" else "Item%d" % (_overlay_item_pool_rows.size() + 1)
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_edit.text_changed.connect(_on_option_changed)
	row.add_child(name_edit)

	var amount_label = Label.new()
	amount_label.text = "Weight"
	row.add_child(amount_label)

	var amount_spin = _new_float_spin(amount, 0.0, 1048576.0, 0.1)
	amount_spin.value_changed.connect(_on_option_changed)
	row.add_child(amount_spin)

	var tile_label = Label.new()
	tile_label.text = "Tile"
	row.add_child(tile_label)
	var tile_source_spin = _new_int_spin(0, 0, 1024)
	tile_source_spin.value_changed.connect(_on_option_changed)
	row.add_child(tile_source_spin)
	var tile_atlas_x_spin = _new_int_spin(1, 0, 4096)
	tile_atlas_x_spin.value_changed.connect(_on_option_changed)
	row.add_child(tile_atlas_x_spin)
	var tile_atlas_y_spin = _new_int_spin(0, 0, 4096)
	tile_atlas_y_spin.value_changed.connect(_on_option_changed)
	row.add_child(tile_atlas_y_spin)

	var remove_button = Button.new()
	remove_button.text = "-"
	remove_button.pressed.connect(_on_overlay_remove_item_pressed.bind(row))
	row.add_child(remove_button)

	_overlay_item_pool_container.add_child(row)
	_overlay_item_pool_rows.append({
		"row": row,
		"name": name_edit,
		"amount_label": amount_label,
		"amount": amount_spin,
		"tile_source": tile_source_spin,
		"tile_atlas_x": tile_atlas_x_spin,
		"tile_atlas_y": tile_atlas_y_spin,
		"remove": remove_button,
	})
	_refresh_overlay_item_pool_rows()


func _remove_overlay_item_pool_row(row: HBoxContainer) -> void:
	if _overlay_item_pool_rows.size() <= 1:
		return
	for index in range(_overlay_item_pool_rows.size()):
		if _overlay_item_pool_rows[index]["row"] == row:
			_overlay_item_pool_rows.remove_at(index)
			row.queue_free()
			break
	_refresh_overlay_item_pool_rows()


func _refresh_overlay_item_pool_rows() -> void:
	var limited = _overlay_item_limit_enabled()
	for item_row in _overlay_item_pool_rows:
		var amount_label: Label = item_row["amount_label"]
		amount_label.text = "Limit" if limited else "Weight"
		var amount_spin: SpinBox = item_row["amount"]
		amount_spin.step = 1.0 if limited else 0.1
		if limited:
			amount_spin.value = int(amount_spin.value)
		var remove_button: Button = item_row["remove"]
		remove_button.disabled = _overlay_item_pool_rows.size() <= 1 or _generation_running


func _on_overlay_add_item_pressed() -> void:
	_add_overlay_item_pool_row("", 1.0)


func _on_overlay_remove_item_pressed(row: HBoxContainer) -> void:
	_remove_overlay_item_pool_row(row)


func _on_generate_changed(_index: int) -> void:
	if _generate_option.selected == GENERATE_SIMPLE \
		and _overlay_adjacency_check != null \
		and _overlay_adjacency_check.button_pressed:
		_overlay_adjacency_check.set_pressed_no_signal(false)
	_refresh_controls()


func _on_shape_changed(_index: int) -> void:
	_refresh_controls()


func _on_symmetric_shape_changed(index: int) -> void:
	if index == SHAPE_HEXAGON and _torus_connectivity_check != null:
		_torus_connectivity_check.set_pressed_no_signal(false)
	_refresh_controls()


func _on_torus_connectivity_toggled(enabled: bool) -> void:
	if enabled and _shape_option_symmetric != null:
		_shape_option_symmetric.select(SHAPE_RECTANGLE)
	_refresh_controls()


func _on_wall_prob_changed(value: float) -> void:
	_wall_prob_label.text = "%.2f" % value


func _on_overlay_mode_toggled(_enabled: bool) -> void:
	_refresh_controls()


func _on_overlay_item_limit_toggled(_enabled: bool) -> void:
	_refresh_controls()


func _on_overlay_adjacency_toggled(enabled: bool) -> void:
	if enabled and _generate_option != null:
		_generate_option.select(GENERATE_SYMMETRIC)
	_refresh_controls()


func _on_adjacency_rules_edit_pressed() -> void:
	var editor = HexAdjacencyRuleEditor.new(
		_overlay_adjacency_rules_edit.text,
		Callable(self, "_on_adjacency_rule_editor_apply"),
		Callable(self, "_on_adjacency_rule_editor_cancel")
	)
	if Engine.is_editor_hint():
		EditorInterface.get_base_control().add_child(editor)
	else:
		add_child(editor)
	editor.popup_centered_ratio(0.4)


func _on_adjacency_rule_editor_apply(rules_text: String) -> void:
	_overlay_adjacency_rules_edit.text = rules_text


func _on_adjacency_rule_editor_cancel() -> void:
	pass


func _on_option_changed(_v = null) -> void:
	pass


func _on_seed_randomize() -> void:
	_seed_spin.value = randi() % 100000


func _on_tile_layer_refresh_pressed() -> void:
	refresh_tile_layer_options()


func _on_tile_layer_target_selected(index: int) -> void:
	if index == _add_tile_layer_option_index():
		var layer = add_new_tile_map_layer()
		if layer == null:
			refresh_tile_layer_options(_tile_layer_scan_root)


func _on_tile_orientation_changed(_index: int) -> void:
	var previous_orientation = _current_orientation
	_current_orientation = _tile_settings_orientation()
	if previous_orientation != _current_orientation:
		_swap_tile_size_controls()
	_apply_tile_settings_to_current_layer()


func _on_tile_setting_changed(_value: float) -> void:
	if _suppress_tile_settings_apply:
		return
	_apply_tile_settings_to_current_layer()


func _on_generate_pressed() -> void:
	_generate_map(true)


func _on_cancel_generation_pressed() -> void:
	request_generation_cancel()


func _on_sample_tiles_pressed() -> void:
	var layer = _find_editor_selected_tile_map_layer()
	if layer == null:
		push_error("No selected TileMapLayer found in the scene. Select one first.")
		return
	if setup_sample_tiles_on_tile_map_layer(layer):
		print("Configured sample hex tiles on TileMapLayer: %s" % layer.name)


func _on_atlas_image_pressed() -> void:
	var layer = _find_editor_selected_tile_map_layer()
	if layer == null:
		push_error("No selected TileMapLayer found in the scene. Select one first.")
		return

	var dialog = EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.add_filter("*.png, *.jpg, *.jpeg, *.webp", "Image atlas")
	dialog.file_selected.connect(_on_atlas_image_selected.bind(layer))
	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_centered_ratio(0.5)


func _on_atlas_image_selected(path: String, layer) -> void:
	if setup_atlas_tiles_on_tile_map_layer(
		layer,
		path,
		int(_floor_source_spin.value),
		_tile_settings_tile_size(),
		Vector2i(int(_floor_atlas_x_spin.value), int(_floor_atlas_y_spin.value)),
		Vector2i(int(_wall_atlas_x_spin.value), int(_wall_atlas_y_spin.value))
	):
		print("Configured hex atlas on TileMapLayer: %s" % layer.name)


func _on_save_pressed() -> void:
	var resource = current_resource()
	if resource == null:
		return

	var dialog = EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.add_filter("*.tres", "Hex Map Resource")
	dialog.current_file = "hex_map.tres"
	dialog.file_selected.connect(_on_save_file_selected.bind(resource))
	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_centered_ratio(0.5)


func _on_save_file_selected(path: String, resource: Resource) -> void:
	var error = ResourceSaver.save(resource, path)
	if error == OK:
		EditorInterface.get_resource_filesystem().scan()
		print("Hex Map saved to: %s" % path)
	else:
		push_error("Failed to save hex map: %d" % error)


func _on_apply_layer_pressed() -> void:
	if _overlay_mode_enabled():
		if _current_overlay_data == null:
			return
	else:
		if _current_data == null:
			return

	var layer = _find_target_tile_map_layer()
	if layer == null:
		push_error("No TileMapLayer found in the scene. Add one first.")
		return

	if _overlay_mode_enabled():
		apply_current_overlay_data_to_tile_map_layer(layer)
	else:
		apply_current_data_to_tile_map_layer(layer)
	print("Applied hex map to TileMapLayer: %s" % layer.name)


func _apply_tile_settings_to_current_layer() -> bool:
	if _overlay_mode_enabled() and _current_overlay_data == null:
		return false
	if not _overlay_mode_enabled() and _current_data == null:
		return false
	var layer = _find_editor_selected_tile_map_layer()
	if layer == null:
		return false
	if _overlay_mode_enabled():
		return apply_current_overlay_data_to_tile_map_layer(layer)
	return apply_current_data_to_tile_map_layer(layer)


func apply_current_overlay_data_to_tile_map_layer(layer) -> bool:
	if _current_overlay_data == null or layer == null:
		return false

	_current_orientation = _tile_settings_orientation()
	var flat_top := _tile_settings_flat_top()
	if layer is TileMapLayer:
		_ensure_unique_tile_set_for_layer(layer)
		HexMapTileAdapter.configure_hex_tile_set(
			layer.tile_set,
			flat_top,
			_tile_settings_tile_size()
		)

	HexOverlayTileAdapter.apply_to_tile_map_layer(
		layer,
		_current_overlay_data,
		_overlay_item_tile_configs(),
		true,
		flat_top,
		_current_overlay_data.item_keys()
	)
	return true


func _overlay_item_tile_configs() -> Dictionary:
	var result := {}
	if _current_overlay_data == null:
		return result
	var fallback_config = HexOverlayTileAdapter.tile_config(
		int(_wall_source_spin.value),
		Vector2i(int(_wall_atlas_x_spin.value), int(_wall_atlas_y_spin.value))
	)
	for index in range(_overlay_item_pool_rows.size()):
		var item_row = _overlay_item_pool_rows[index]
		var tile_source_spin: SpinBox = item_row["tile_source"]
		var tile_atlas_x_spin: SpinBox = item_row["tile_atlas_x"]
		var tile_atlas_y_spin: SpinBox = item_row["tile_atlas_y"]
		result[_overlay_item_pool_row_name(item_row, index)] = HexOverlayTileAdapter.tile_config(
			int(tile_source_spin.value),
			Vector2i(
				int(tile_atlas_x_spin.value),
				int(tile_atlas_y_spin.value)
			)
		)
	for item_key in _current_overlay_data.item_keys():
		if not result.has(item_key):
			result[item_key] = fallback_config
	return result


func _find_target_tile_map_layer_and_apply_current() -> bool:
	var layer = _find_target_tile_map_layer()
	if layer == null:
		return false
	if _overlay_mode_enabled() and _current_overlay_data != null:
		return apply_current_overlay_data_to_tile_map_layer(layer)
	if _current_data != null:
		return apply_current_data_to_tile_map_layer(layer)
	return false


func refresh_tile_layer_options(root_node: Node = null) -> void:
	if _tile_layer_option == null:
		return

	var previous_node = selected_tile_map_layer()
	var scan_root = root_node
	if scan_root != null:
		_tile_layer_scan_root = scan_root
	elif _tile_layer_scan_root != null and is_instance_valid(_tile_layer_scan_root):
		scan_root = _tile_layer_scan_root
	elif Engine.is_editor_hint():
		scan_root = EditorInterface.get_edited_scene_root()
		_tile_layer_scan_root = scan_root

	_tile_layer_nodes.clear()
	_tile_layer_option.clear()
	_tile_layer_option.add_item(TILE_TARGET_AUTO_LABEL)
	if scan_root != null:
		_collect_tile_map_layers_recursive(scan_root, _tile_layer_nodes)

	var name_counts = _tile_layer_name_counts()
	for node in _tile_layer_nodes:
		_tile_layer_option.add_item(_tile_layer_display_name(node, scan_root, name_counts))
	_tile_layer_option.add_item(TILE_TARGET_ADD_LAYER_LABEL)

	var selected_index = TILE_TARGET_AUTO_INDEX
	if previous_node != null and is_instance_valid(previous_node):
		var node_index = _tile_layer_nodes.find(previous_node)
		if node_index >= 0:
			selected_index = node_index + TILE_TARGET_LAYER_INDEX_OFFSET
	_tile_layer_option.select(selected_index)


func selected_tile_map_layer():
	if _tile_layer_option == null:
		return null
	var node_index = _tile_layer_option.selected - TILE_TARGET_LAYER_INDEX_OFFSET
	if node_index < 0 or node_index >= _tile_layer_nodes.size():
		return null
	var node = _tile_layer_nodes[node_index]
	return node if is_instance_valid(node) else null


func generation_status() -> Dictionary:
	return {
		"running": _generation_running,
		"cancel_requested": _is_generation_cancel_requested(),
		"progress": _generation_progress,
		"status": _generation_status,
	}


func request_generation_cancel() -> void:
	if not _generation_running:
		return
	_set_generation_cancel_requested(true)
	_set_generation_progress(_generation_progress, "Cancel requested")
	_set_generation_progress_cancel_enabled(false)


func apply_current_data_to_tile_map_layer(layer) -> bool:
	if _current_data == null or layer == null:
		return false

	_current_orientation = _tile_settings_orientation()
	var flat_top := _tile_settings_flat_top()
	if layer is TileMapLayer:
		_ensure_unique_tile_set_for_layer(layer)
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
	var ok = setup_atlas_tiles_on_tile_map_layer(
		layer,
		HexMapTileAdapter.SAMPLE_TILE_ATLAS_PATH,
		0,
		HexMapTileAdapter.SAMPLE_TILE_SIZE,
		Vector2i(0, 0),
		Vector2i(1, 0)
	)
	return ok


func setup_atlas_tiles_on_tile_map_layer(
	layer,
	atlas_path: String,
	source_id: int = 0,
	tile_size: Vector2i = HexMapTileAdapter.SAMPLE_TILE_SIZE,
	floor_atlas_coords: Vector2i = Vector2i(0, 0),
	wall_atlas_coords: Vector2i = Vector2i(1, 0)
) -> bool:
	if not layer is TileMapLayer:
		return false

	_current_orientation = _tile_settings_orientation()
	_ensure_unique_tile_set_for_layer(layer)

	var texture := HexMapTileAdapter.load_tile_texture(atlas_path)
	var ok = HexMapTileAdapter.configure_atlas_tile_set(
		layer.tile_set,
		texture,
		_tile_settings_flat_top(),
		tile_size,
		source_id,
		[floor_atlas_coords, wall_atlas_coords]
	)
	if not ok:
		return false

	_suppress_tile_settings_apply = true
	_current_atlas_image_path = atlas_path
	_tile_width_spin.value = tile_size.x
	_tile_height_spin.value = tile_size.y
	_floor_source_spin.value = source_id
	_floor_atlas_x_spin.value = floor_atlas_coords.x
	_floor_atlas_y_spin.value = floor_atlas_coords.y
	_wall_source_spin.value = source_id
	_wall_atlas_x_spin.value = wall_atlas_coords.x
	_wall_atlas_y_spin.value = wall_atlas_coords.y
	_suppress_tile_settings_apply = false
	return true


func current_resource() -> Resource:
	_current_orientation = _tile_settings_orientation()
	if _overlay_mode_enabled() and _current_overlay_data != null:
		return HexOverlayResource.from_overlay_data(_current_overlay_data, _current_orientation)
	if _current_data == null:
		return null
	return HexMapResource.from_map_data(_current_data, _current_orientation)


func _overlay_mode_enabled() -> bool:
	return _overlay_mode_check != null and _overlay_mode_check.button_pressed


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


func _swap_tile_size_controls() -> void:
	if _tile_width_spin == null or _tile_height_spin == null:
		return
	_suppress_tile_settings_apply = true
	var width = _tile_width_spin.value
	_tile_width_spin.value = _tile_height_spin.value
	_tile_height_spin.value = width
	_suppress_tile_settings_apply = false


func _find_target_tile_map_layer():
	var selected_layer = selected_tile_map_layer()
	if selected_layer != null:
		return selected_layer

	var editor_selected_layer = _find_editor_selected_tile_map_layer()
	if editor_selected_layer != null:
		return editor_selected_layer

	var root = _tile_layer_scan_root
	if (root == null or not is_instance_valid(root)) and Engine.is_editor_hint():
		root = EditorInterface.get_edited_scene_root()
	if root == null:
		return null
	return _find_tile_map_layer_recursive(root)


func _find_editor_selected_tile_map_layer():
	if _test_selected_tile_map_layer != null and is_instance_valid(_test_selected_tile_map_layer):
		return _test_selected_tile_map_layer
	if not Engine.is_editor_hint():
		return null

	var selection = EditorInterface.get_selection()
	var selected = selection.get_selected_nodes()
	for node in selected:
		if node is TileMapLayer:
			return node
	return null


func _set_editor_selected_tile_map_layer_for_test(layer: Node) -> void:
	_test_selected_tile_map_layer = layer


func add_new_tile_map_layer(root_node: Node = null):
	var root = root_node
	if root == null:
		root = _tile_layer_scan_root
	if (root == null or not is_instance_valid(root)) and Engine.is_editor_hint():
		root = EditorInterface.get_edited_scene_root()
	if root == null:
		push_error("No edited scene root found. Open a scene first.")
		return null

	var layer = TileMapLayer.new()
	layer.name = _unique_tile_layer_name(root, NEW_TILE_LAYER_BASE_NAME)
	if Engine.is_editor_hint():
		var undo_redo = EditorInterface.get_editor_undo_redo()
		undo_redo.create_action("Add HexMapLayer")
		undo_redo.add_do_method(root, "add_child", layer)
		undo_redo.add_do_method(layer, "set_owner", root)
		undo_redo.add_do_reference(layer)
		undo_redo.add_undo_method(root, "remove_child", layer)
		undo_redo.commit_action()
	else:
		root.add_child(layer)
		layer.owner = root

	_tile_layer_scan_root = root
	refresh_tile_layer_options(root)
	_select_tile_layer_target(layer)
	_select_editor_node(layer)
	return layer


func _select_editor_node(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	if Engine.is_editor_hint():
		var selection = EditorInterface.get_selection()
		selection.clear()
		selection.add_node(node)
	else:
		_test_selected_tile_map_layer = node


func _select_tile_layer_target(layer: Node) -> void:
	var node_index = _tile_layer_nodes.find(layer)
	if node_index >= 0:
		_tile_layer_option.select(node_index + TILE_TARGET_LAYER_INDEX_OFFSET)


func _add_tile_layer_option_index() -> int:
	return _tile_layer_nodes.size() + TILE_TARGET_LAYER_INDEX_OFFSET


func _unique_tile_layer_name(root: Node, base_name: String) -> String:
	var names := {}
	for child in root.get_children():
		names[String(child.name)] = true
	if not names.has(base_name):
		return base_name
	var suffix := 2
	while names.has("%s%d" % [base_name, suffix]):
		suffix += 1
	return "%s%d" % [base_name, suffix]


func _find_tile_map_layer_recursive(node: Node):
	if node is TileMapLayer:
		return node
	for child in node.get_children():
		var found = _find_tile_map_layer_recursive(child)
		if found:
			return found
	return null


func _collect_tile_map_layers_recursive(node: Node, result: Array[Node]) -> void:
	if node is TileMapLayer:
		result.append(node)
	for child in node.get_children():
		_collect_tile_map_layers_recursive(child, result)


func _tile_layer_name_counts() -> Dictionary:
	var counts := {}
	for node in _tile_layer_nodes:
		var key = String(node.name)
		counts[key] = int(counts.get(key, 0)) + 1
	return counts


func _tile_layer_display_name(node: Node, root_node: Node, name_counts: Dictionary) -> String:
	if node == null:
		return ""
	var node_name = String(node.name)
	if int(name_counts.get(node_name, 0)) <= 1:
		return node_name
	if root_node != null and is_instance_valid(root_node) and _is_ancestor_of(root_node, node):
		return String(root_node.get_path_to(node))
	return node.name


func _is_ancestor_of(ancestor: Node, node: Node) -> bool:
	var current = node
	while current != null:
		if current == ancestor:
			return true
		current = current.get_parent()
	return false


func _ensure_unique_tile_set_for_layer(layer: TileMapLayer) -> void:
	if layer.tile_set == null:
		layer.tile_set = TileSet.new()
		return
	if _tile_set_is_used_by_another_layer(layer):
		layer.tile_set = layer.tile_set.duplicate(true)


func _tile_set_is_used_by_another_layer(layer: TileMapLayer) -> bool:
	var root = _tile_layer_scan_root
	if root == null or not is_instance_valid(root) or not _is_ancestor_of(root, layer):
		if Engine.is_editor_hint():
			root = EditorInterface.get_edited_scene_root()
	if root == null or not is_instance_valid(root) or not _is_ancestor_of(root, layer):
		root = layer.get_parent()
	if root == null:
		return false
	return _tile_set_is_used_by_another_layer_recursive(root, layer, layer.tile_set)


func _tile_set_is_used_by_another_layer_recursive(node: Node, layer: TileMapLayer, tile_set: TileSet) -> bool:
	if node is TileMapLayer and node != layer and node.tile_set == tile_set:
		return true
	for child in node.get_children():
		if _tile_set_is_used_by_another_layer_recursive(child, layer, tile_set):
			return true
	return false


func _refresh_controls() -> void:
	var symmetric = _uses_symmetric_generation()
	var overlay = _overlay_mode_enabled()
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
	if _torus_connectivity_check != null:
		_torus_connectivity_check.visible = symmetric
		_torus_connectivity_check.disabled = not symmetric or _generation_running
	if _overlay_controls_container != null:
		_overlay_controls_container.visible = overlay
	if _generate_button != null:
		_generate_button.text = "Overlay Generation" if overlay else "Primary Generation"
	if _overlay_item_limit_check != null:
		_overlay_item_limit_check.visible = overlay and not symmetric
	if _overlay_item_limit_spin != null:
		_overlay_item_limit_spin.visible = false
	if _overlay_item_name_edit != null:
		var item_name_row = _overlay_item_name_edit.get_parent()
		if item_name_row is Control:
			item_name_row.visible = overlay and symmetric
	if _overlay_item_pool_container != null:
		_overlay_item_pool_container.visible = overlay and not symmetric
	if _overlay_add_item_button != null:
		_overlay_add_item_button.visible = overlay and not symmetric
	if _overlay_mask_container != null:
		_overlay_mask_container.visible = overlay
	if _overlay_adjacency_check != null:
		_overlay_adjacency_check.visible = overlay
		_overlay_adjacency_check.disabled = not overlay or _generation_running
	if _overlay_reference_container != null:
		_overlay_reference_container.visible = overlay \
			and symmetric \
			and _overlay_adjacency_check != null \
			and _overlay_adjacency_check.button_pressed
	if _wall_prob_row != null:
		_wall_prob_row.visible = not _overlay_item_limit_enabled()
	_refresh_overlay_item_pool_rows()


func _uses_symmetric_generation() -> bool:
	return _generate_option.selected == GENERATE_SYMMETRIC


func _generate_map(show_progress: bool = false) -> bool:
	if _generation_running:
		return false
	var snapshot = _create_generation_snapshot()
	_begin_generation(int(snapshot["generation_id"]), show_progress)
	await get_tree().process_frame

	if _is_generation_cancel_requested():
		_finish_generation(true)
		return false

	_set_generation_progress(GENERATION_PROGRESS_START, "Preparing")
	await get_tree().process_frame

	if _is_generation_cancel_requested():
		_finish_generation(true)
		return false

	_generation_thread = Thread.new()
	var error = _generation_thread.start(Callable(self, "_generation_thread_main").bind(snapshot))
	if error != OK:
		_generation_thread = null
		push_error("Failed to start map generation thread: %d" % error)
		_set_generation_progress(_generation_progress, "Failed")
		_finish_generation(true)
		return false

	await generation_finished
	if _last_generation_cancelled:
		return false

	_find_target_tile_map_layer_and_apply_current()
	return true


func _create_generation_snapshot() -> Dictionary:
	var symmetric = _uses_symmetric_generation()
	var shape = _shape_option_symmetric.selected if symmetric else _shape_option_simple.selected
	var connect_toric = symmetric \
		and shape == SHAPE_RECTANGLE \
		and _torus_connectivity_check.button_pressed
	var dist_id = 0
	if _dist_option.selected >= 0 and _dist_option.selected < _dist_option.item_count:
		dist_id = HexRandomizer.get_preset_id(_dist_option.get_item_text(_dist_option.selected))
	var overlay_limit_enabled = _overlay_item_limit_enabled()
	_generation_id += 1
	var snapshot := {
		"generation_id": _generation_id,
		"shape": shape,
		"symmetric": symmetric,
		"wall_probability": float(_wall_prob_slider.value),
		"seed": int(_seed_spin.value),
		"connect_method": CONNECT_METHOD_VALUES[_connect_method_option.selected],
		"connect_toric": connect_toric,
		"protected_floor": [HexVector.zero()],
		"distribution_id": dist_id,
		"custom_distribution": _current_distribution,
		"hex_radius": int(_hex_radius_spin.value),
		"rect_width": int(_rect_width_spin.value),
		"rect_height": int(_rect_height_spin.value),
		"generation_radius": int(_gen_radius_spin.value),
		"chunk_size": _generation_chunk_size,
		"progress_delay_usec": _generation_progress_delay_usec,
		"overlay_mode": _overlay_mode_enabled(),
		"overlay_item_name": _overlay_item_name(),
		"overlay_item_limit_enabled": overlay_limit_enabled,
		"overlay_item_limit": int(_overlay_item_limit_spin.value),
		"overlay_item_pool": _overlay_item_pool(overlay_limit_enabled),
		"overlay_write_policy": _overlay_write_policy(),
		"overlay_existing_policy": _overlay_existing_policy(),
		"overlay_adjacency_enabled": _overlay_adjacency_enabled(),
		"overlay_neighbor_radius": _overlay_neighbor_radius(),
		"overlay_adjacency_rules": _overlay_adjacency_rules(),
	}
	if bool(snapshot["overlay_mode"]):
		snapshot["overlay_candidate_cells"] = _overlay_mask_cells_for_snapshot(snapshot)
		snapshot["overlay_reference_cells"] = _overlay_reference_cells_for_snapshot()
		snapshot["overlay_cyclic_size"] = _overlay_cyclic_size_for_snapshot()
	return snapshot


func _generation_thread_main(snapshot: Dictionary) -> Dictionary:
	var generation_id = int(snapshot["generation_id"])
	var interrupt_options := {
		"chunk_size": int(snapshot["chunk_size"]),
		"progress_callback": Callable(self, "_generation_progress_from_thread").bind(generation_id),
		"cancel_callback": Callable(self, "_generation_cancel_from_thread").bind(generation_id),
	}
	var data = _generate_data_from_snapshot(snapshot, interrupt_options)
	var result := {
		"generation_id": generation_id,
		"data": data,
		"cancelled": bool(interrupt_options.get("cancelled", false)),
		"overlay_mode": bool(snapshot.get("overlay_mode", false)),
		"overlay_write_policy": String(snapshot.get(
			"overlay_write_policy",
			HexOverlayData.APPLY_CLEAR_AND_WRITE
		)),
		"overlay_existing_policy": String(snapshot.get(
			"overlay_existing_policy",
			HexOverlayData.EXISTING_MERGE
		)),
	}
	call_deferred("_complete_generation_from_thread", generation_id)
	return result


func _overlay_item_name() -> String:
	if _overlay_item_name_edit == null:
		return OVERLAY_DEFAULT_ITEM_NAME
	var item_name = _overlay_item_name_edit.text.strip_edges()
	if item_name == "":
		return OVERLAY_DEFAULT_ITEM_NAME
	return item_name


func _overlay_item_limit_enabled() -> bool:
	return _overlay_mode_enabled() \
		and _generate_option != null \
		and _generate_option.selected == GENERATE_SIMPLE \
		and _overlay_item_limit_check != null \
		and _overlay_item_limit_check.button_pressed


func _overlay_item_pool(limit_enabled: bool) -> Array:
	var result: Array = []
	for index in range(_overlay_item_pool_rows.size()):
		var item_row = _overlay_item_pool_rows[index]
		var item_name = _overlay_item_pool_row_name(item_row, index)
		var amount_spin: SpinBox = item_row["amount"]
		if limit_enabled:
			result.append({
				"name": item_name,
				"limit": int(amount_spin.value),
			})
		else:
			result.append({
				"name": item_name,
				"weight": float(amount_spin.value),
			})
	if result.is_empty():
		if limit_enabled:
			result.append({
				"name": _overlay_item_name(),
				"limit": int(_overlay_item_limit_spin.value),
			})
		else:
			result.append({
				"name": _overlay_item_name(),
				"weight": 1.0,
			})
	return result


func _overlay_item_pool_row_name(item_row: Dictionary, index: int) -> String:
	var name_edit: LineEdit = item_row["name"]
	var item_name = name_edit.text.strip_edges()
	if item_name == "":
		return "Item%d" % (index + 1)
	return item_name


func _parse_item_key_list(text: String, default_keys: Array = []) -> Array:
	var result: Array = []
	for raw_key in text.split(",", false):
		var key = String(raw_key).strip_edges()
		if key != "":
			result.append(key)
	if result.is_empty():
		for key in default_keys:
			result.append(String(key))
	return result


func _overlay_query_operation(option: OptionButton) -> String:
	if option == null:
		return HexOverlayData.ITEM_QUERY_OR
	var index = clampi(option.selected, 0, OVERLAY_QUERY_OPERATIONS.size() - 1)
	return OVERLAY_QUERY_OPERATIONS[index]


func _overlay_query_cells(
	primary_enabled: bool,
	primary_items_text: String,
	primary_default_items: Array,
	overlay_enabled: bool,
	overlay_items_text: String,
	operation: String
) -> Array:
	var selectors: Array = []
	if primary_enabled and _current_data != null:
		for item_key in _parse_item_key_list(primary_items_text, primary_default_items):
			selectors.append(HexOverlayData.item_selector(_current_data, item_key))
	if overlay_enabled and _current_overlay_data != null:
		for item_key in _parse_item_key_list(overlay_items_text, _current_overlay_data.item_keys()):
			selectors.append(HexOverlayData.item_selector(_current_overlay_data, item_key))
	if selectors.is_empty():
		return []
	return HexOverlayData.query_item_cells(selectors, operation)


func _overlay_mask_cells_for_snapshot(snapshot: Dictionary) -> Array:
	var query_cells = _overlay_query_cells(
		_overlay_mask_primary_check == null or _overlay_mask_primary_check.button_pressed,
		"Floor" if _overlay_mask_primary_items_edit == null else _overlay_mask_primary_items_edit.text,
		["Floor"],
		_overlay_mask_overlay_check != null and _overlay_mask_overlay_check.button_pressed,
		"" if _overlay_mask_overlay_items_edit == null else _overlay_mask_overlay_items_edit.text,
		_overlay_query_operation(_overlay_mask_operation_option)
	)
	if not query_cells.is_empty():
		return query_cells
	return _overlay_candidate_cells_for_snapshot(snapshot)


func _overlay_reference_cells_for_snapshot() -> Array:
	return _overlay_query_cells(
		_overlay_reference_primary_check == null or _overlay_reference_primary_check.button_pressed,
		"Wall" if _overlay_reference_primary_items_edit == null else _overlay_reference_primary_items_edit.text,
		["Wall"],
		_overlay_reference_overlay_check != null and _overlay_reference_overlay_check.button_pressed,
		"" if _overlay_reference_overlay_items_edit == null else _overlay_reference_overlay_items_edit.text,
		_overlay_query_operation(_overlay_reference_operation_option)
	)


func _overlay_adjacency_enabled() -> bool:
	return _overlay_mode_enabled() \
		and _generate_option != null \
		and _generate_option.selected == GENERATE_SYMMETRIC \
		and _overlay_adjacency_check != null \
		and _overlay_adjacency_check.button_pressed


func _overlay_neighbor_radius() -> int:
	if _overlay_neighbor_radius_spin == null:
		return 1
	return max(1, int(_overlay_neighbor_radius_spin.value))


func _overlay_adjacency_rules() -> Dictionary:
	var text = ""
	if _overlay_adjacency_rules_edit != null:
		text = _overlay_adjacency_rules_edit.text
	return HexAdjacencyRuleSet.parse_rules_text(text, float(_wall_prob_slider.value))


func _overlay_write_policy() -> String:
	if _overlay_write_policy_option == null:
		return HexOverlayData.APPLY_CLEAR_AND_WRITE
	var index = clampi(_overlay_write_policy_option.selected, 0, OVERLAY_WRITE_POLICIES.size() - 1)
	return OVERLAY_WRITE_POLICIES[index]


func _overlay_existing_policy() -> String:
	if _overlay_existing_policy_option == null:
		return HexOverlayData.EXISTING_MERGE
	var index = clampi(_overlay_existing_policy_option.selected, 0, OVERLAY_EXISTING_POLICIES.size() - 1)
	return OVERLAY_EXISTING_POLICIES[index]


func _overlay_cyclic_size_for_snapshot() -> int:
	if _current_data != null:
		return int(_current_data.cyclic_size)
	return 0


func _overlay_candidate_cells_for_snapshot(snapshot: Dictionary) -> Array:
	if _current_data != null:
		var floor_cells = _current_data.floor_cells()
		if not floor_cells.is_empty():
			return floor_cells

	var shape = int(snapshot["shape"])
	if bool(snapshot["symmetric"]):
		var radius = int(snapshot["generation_radius"])
		if shape == SHAPE_HEXAGON:
			return HexMapData.hexagon(radius).cells
		return HexMapData.square(radius * 2 + 1, bool(snapshot.get("connect_toric", false))).cells

	match shape:
		SHAPE_HEXAGON:
			return HexMapData.hexagon(int(snapshot["hex_radius"])).cells
		SHAPE_RECTANGLE:
			return HexMapData.rectangle(
				int(snapshot["rect_width"]),
				int(snapshot["rect_height"])
			).cells
		SHAPE_TORUS, _:
			var radius = int(snapshot["generation_radius"])
			return HexMapData.square(radius * 2 + 1, true).cells


func _generate_overlay_data_from_snapshot(snapshot: Dictionary, interrupt_options: Dictionary):
	var item_name = String(snapshot.get("overlay_item_name", OVERLAY_DEFAULT_ITEM_NAME))
	var candidates: Array = snapshot.get("overlay_candidate_cells", [])
	var seed = int(snapshot["seed"])
	var item_pool: Array = snapshot.get("overlay_item_pool", [{"name": item_name, "weight": 1.0}])
	var data = null

	if bool(snapshot.get("overlay_item_limit_enabled", false)):
		data = HexMapGenerator.generate_limited_items_interruptible(
			candidates,
			item_pool,
			seed,
			[],
			interrupt_options
		)["data"]
	elif bool(snapshot.get("overlay_adjacency_enabled", false)):
		data = HexMapGenerator.generate_toric_adjacency_items_interruptible(
			candidates,
			item_name,
			snapshot.get("overlay_reference_cells", []),
			snapshot.get("overlay_adjacency_rules", {}),
			seed,
			[],
			int(snapshot.get("overlay_cyclic_size", 0)),
			int(snapshot.get("overlay_neighbor_radius", 1)),
			interrupt_options
		)["data"]
	elif bool(snapshot["symmetric"]):
		data = HexMapGenerator.generate_symmetric_toric_items_interruptible(
			int(snapshot["generation_radius"]),
			item_name,
			candidates,
			float(snapshot["wall_probability"]),
			seed,
			int(snapshot["distribution_id"]),
			[],
			snapshot["custom_distribution"],
			interrupt_options
		)["data"]
	else:
		data = HexMapGenerator.generate_random_items_interruptible(
			candidates,
			float(snapshot["wall_probability"]),
			item_pool,
			seed,
			[],
			interrupt_options
		)["data"]

	if data != null \
		and bool(snapshot["symmetric"]) \
		and not bool(snapshot.get("overlay_adjacency_enabled", false)):
		HexMapGenerator.deduct_items_for_connectivity(
			data,
			item_name,
			candidates,
			int(snapshot["connect_method"]),
			seed,
			interrupt_options
		)
	if data != null and int(data.cyclic_size) == 0:
		data.cyclic_size = int(snapshot.get("overlay_cyclic_size", 0))
	return data


func _generate_data_from_snapshot(snapshot: Dictionary, interrupt_options: Dictionary):
	if bool(snapshot.get("overlay_mode", false)):
		return _generate_overlay_data_from_snapshot(snapshot, interrupt_options)

	var shape = int(snapshot["shape"])
	var symmetric = bool(snapshot["symmetric"])
	var wall_prob = float(snapshot["wall_probability"])
	var seed = int(snapshot["seed"])
	var connect_method = int(snapshot["connect_method"])
	var connect_toric = bool(snapshot.get("connect_toric", false))
	var protected = snapshot["protected_floor"]
	var dist_id = int(snapshot["distribution_id"])
	var custom_distribution = snapshot["custom_distribution"]

	match shape:
		SHAPE_HEXAGON:
			if symmetric:
				return HexMapGenerator.generate_symmetric_hexagon(
					int(snapshot["generation_radius"]),
					wall_prob,
					seed,
					connect_method,
					protected,
					dist_id,
					[],
					custom_distribution,
					interrupt_options
				)
			else:
				return HexMapGenerator.generate_hexagon(
					int(snapshot["hex_radius"]),
					wall_prob,
					seed,
					connect_method,
					protected,
					interrupt_options
				)
		SHAPE_RECTANGLE:
			if symmetric:
				return HexMapGenerator.generate_symmetric_square(
					int(snapshot["generation_radius"]),
					wall_prob,
					seed,
					connect_method,
					protected,
					dist_id,
					[],
					connect_toric,
					custom_distribution,
					interrupt_options
				)
			else:
				return HexMapGenerator.generate_rectangle(
					int(snapshot["rect_width"]),
					int(snapshot["rect_height"]),
					wall_prob,
					seed,
					connect_method,
					false,
					protected,
					interrupt_options
				)
		SHAPE_TORUS, _:
			var fallback_connect_toric = true if shape == SHAPE_TORUS else connect_toric
			return HexMapGenerator.generate_symmetric_square(
				int(snapshot["generation_radius"]),
				wall_prob,
				seed,
				connect_method,
				protected,
				dist_id,
				[],
				fallback_connect_toric,
				custom_distribution,
				interrupt_options
			)
	return null


func _generation_progress_from_thread(status: Dictionary, generation_id: int) -> void:
	var progress = float(status.get("progress", 0.0))
	var delay_usec := 0
	_generation_mutex.lock()
	_generation_core_progress_event_count += 1
	_generation_last_core_progress = progress
	delay_usec = _generation_progress_delay_usec
	_generation_mutex.unlock()
	call_deferred("_apply_generation_core_progress", generation_id, status.duplicate(true))
	if delay_usec > 0:
		OS.delay_usec(delay_usec)


func _generation_cancel_from_thread(_status: Dictionary, _generation_id_from_thread: int) -> bool:
	_generation_mutex.lock()
	_generation_cancel_poll_count += 1
	var requested = _generation_cancel_requested
	_generation_mutex.unlock()
	return requested


func _apply_generation_core_progress(generation_id: int, status: Dictionary) -> void:
	if generation_id != _generation_id or not _generation_running:
		return
	var core_progress = float(status.get("progress", 0.0))
	var mapped_progress = GENERATION_PROGRESS_START + core_progress * GENERATION_PROGRESS_SCALE
	_set_generation_progress(mapped_progress, "Generating")


func _complete_generation_from_thread(generation_id: int) -> void:
	if _generation_thread == null:
		return
	var result = _generation_thread.wait_to_finish()
	_generation_thread = null
	if generation_id != _generation_id or not _generation_running:
		return

	var cancelled := true
	var data = null
	if result is Dictionary:
		cancelled = bool(result.get("cancelled", false)) or _is_generation_cancel_requested()
		data = result.get("data", null)
	else:
		push_error("Map generation thread returned an invalid result.")

	if not cancelled and data != null:
		_set_generation_progress(GENERATION_PROGRESS_UPDATE, "Updating")
		if bool(result.get("overlay_mode", false)):
			var write_policy = String(result.get(
				"overlay_write_policy",
				HexOverlayData.APPLY_CLEAR_AND_WRITE
			))
			var existing_policy = String(result.get(
				"overlay_existing_policy",
				HexOverlayData.EXISTING_MERGE
			))
			if _current_overlay_data != null and write_policy == HexOverlayData.APPLY_ADD_ITEM:
				_current_overlay_data.apply_overlay(data, write_policy, existing_policy)
			else:
				_current_overlay_data = data
		else:
			_current_data = data
		_update_stats()
	_finish_generation(cancelled)


func _begin_generation(_generation_id_from_snapshot: int, show_progress: bool = false) -> void:
	_generation_mutex.lock()
	_generation_cancel_requested = false
	_generation_core_progress_event_count = 0
	_generation_cancel_poll_count = 0
	_generation_last_core_progress = 0.0
	_generation_mutex.unlock()
	_generation_progress_hide_token += 1
	_generation_progress_hide_after_msec = 0
	_generation_running = true
	_last_generation_cancelled = false
	_set_generation_controls_disabled(true)
	_set_generation_progress(0.0, "Preparing")
	if show_progress:
		_show_generation_progress_controls()
	else:
		_hide_generation_progress_controls()


func _finish_generation(cancelled: bool) -> void:
	_generation_running = false
	_last_generation_cancelled = cancelled
	if cancelled:
		_set_generation_progress(_generation_progress, "Cancelled")
	else:
		_set_generation_progress(1.0, "Ready")
	_set_generation_cancel_requested(false)
	_set_generation_controls_disabled(false)
	if _generation_progress_container != null and _generation_progress_container.visible:
		if cancelled:
			_hide_generation_progress_controls()
		else:
			_finish_generation_progress_controls_success()
	generation_finished.emit(cancelled)


func _set_generation_progress(progress: float, status: String) -> void:
	_generation_progress = clampf(progress, 0.0, 1.0)
	_generation_status = status
	if _generation_progress_bar != null:
		_generation_progress_bar.value = _generation_progress
	if _generation_progress_status_label != null:
		_generation_progress_status_label.text = _generation_status


func _set_generation_cancel_requested(requested: bool) -> void:
	_generation_mutex.lock()
	_generation_cancel_requested = requested
	_generation_mutex.unlock()


func _is_generation_cancel_requested() -> bool:
	_generation_mutex.lock()
	var requested = _generation_cancel_requested
	_generation_mutex.unlock()
	return requested


func _show_generation_progress_controls() -> void:
	if _generation_progress_container == null:
		return
	_generation_progress_hide_token += 1
	_generation_progress_hide_after_msec = 0
	_generation_progress_container.visible = true
	_generation_progress_visible_started_msec = Time.get_ticks_msec()
	_set_generation_progress_cancel_enabled(true)
	_set_generation_progress(_generation_progress, _generation_status)


func _finish_generation_progress_controls_success() -> void:
	if _generation_progress_container == null or not _generation_progress_container.visible:
		return
	_set_generation_progress_cancel_enabled(false)
	_set_generation_progress(1.0, "Ready")

	_generation_progress_hide_token += 1
	var hide_token = _generation_progress_hide_token
	_generation_progress_scheduled_hide_token = hide_token
	var elapsed_sec = float(Time.get_ticks_msec() - _generation_progress_visible_started_msec) / 1000.0
	var wait_sec = maxf(GENERATION_PROGRESS_MIN_VISIBLE_SEC - elapsed_sec, 0.0)
	if wait_sec <= 0.0:
		_hide_generation_progress_controls_if_current(hide_token)
		return
	_generation_progress_hide_after_msec = Time.get_ticks_msec() \
		+ int(ceil(wait_sec * 1000.0))


func _process_generation_progress_hide_timer() -> void:
	var now = Time.get_ticks_msec()
	if _generation_progress_hide_after_msec > 0 \
		and now >= _generation_progress_hide_after_msec:
		var hide_token = _generation_progress_scheduled_hide_token
		_generation_progress_hide_after_msec = 0
		_hide_generation_progress_controls_if_current(hide_token)


func _hide_generation_progress_controls_if_current(hide_token: int) -> void:
	if hide_token != _generation_progress_hide_token:
		return
	if _generation_running:
		return
	_hide_generation_progress_controls()


func _hide_generation_progress_controls() -> void:
	_generation_progress_hide_after_msec = 0
	_generation_progress_visible_started_msec = 0
	if _generation_progress_container != null:
		_generation_progress_container.visible = false
	_set_generation_progress_cancel_enabled(false)


func _set_generation_progress_cancel_enabled(enabled: bool) -> void:
	if _generation_progress_cancel_button != null:
		_generation_progress_cancel_button.disabled = not enabled


func _set_generation_controls_disabled(disabled: bool) -> void:
	for control in [
		_generate_option,
		_shape_option_simple,
		_shape_option_symmetric,
		_rect_width_spin,
		_rect_height_spin,
		_hex_radius_spin,
		_gen_radius_spin,
		_wall_prob_slider,
		_seed_spin,
		_seed_random_button,
		_connect_method_option,
		_torus_connectivity_check,
		_dist_option,
		_dist_edit_button,
		_overlay_mode_check,
		_overlay_item_name_edit,
		_overlay_item_limit_check,
		_overlay_item_limit_spin,
		_overlay_add_item_button,
		_overlay_mask_primary_check,
		_overlay_mask_primary_items_edit,
		_overlay_mask_overlay_check,
		_overlay_mask_overlay_items_edit,
		_overlay_mask_operation_option,
		_overlay_adjacency_check,
		_overlay_reference_primary_check,
		_overlay_reference_primary_items_edit,
		_overlay_reference_overlay_check,
		_overlay_reference_overlay_items_edit,
		_overlay_reference_operation_option,
		_overlay_neighbor_radius_spin,
		_overlay_adjacency_rules_edit,
		_overlay_adjacency_rules_edit_button,
		_overlay_write_policy_option,
		_overlay_existing_policy_option,
		_generate_button,
	]:
		_set_control_disabled(control, disabled)
	for item_row in _overlay_item_pool_rows:
		_set_control_disabled(item_row["name"], disabled)
		_set_control_disabled(item_row["amount"], disabled)
		_set_control_disabled(item_row["tile_source"], disabled)
		_set_control_disabled(item_row["tile_atlas_x"], disabled)
		_set_control_disabled(item_row["tile_atlas_y"], disabled)
		_set_control_disabled(item_row["remove"], disabled)
	if _torus_connectivity_check != null:
		_torus_connectivity_check.disabled = disabled or not _uses_symmetric_generation()
	_refresh_overlay_item_pool_rows()


func _set_control_disabled(control: Control, disabled: bool) -> void:
	if control == null:
		return
	if control is BaseButton:
		control.disabled = disabled
	elif control is SpinBox:
		control.editable = not disabled
	elif control is LineEdit:
		control.editable = not disabled
	elif control is Slider:
		control.editable = not disabled


func _update_stats() -> void:
	if _overlay_mode_enabled() and _current_overlay_data != null:
		var item_parts: Array = []
		for item_key in _current_overlay_data.item_keys():
			item_parts.append("%s=%d" % [item_key, _current_overlay_data.item_cells(item_key).size()])
		_stats_label.text = "%s  seed=%d  cells=%d  occupied=%d  %s" % [
			_shape_string(),
			int(_seed_spin.value),
			_current_overlay_data.cells.size(),
			_current_overlay_data.occupied_cells().size(),
			", ".join(item_parts),
		]
		return
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
			if _shape_option_symmetric.selected == SHAPE_RECTANGLE \
				and _torus_connectivity_check != null \
				and _torus_connectivity_check.button_pressed:
				return "Torus"
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


func _refill_dist_options() -> void:
	_dist_option.clear()
	for preset_name in HexRandomizer.get_preset_names():
		_dist_option.add_item(preset_name)
	if _current_dist_file != "":
		_dist_option.add_item(_current_dist_file)
		_dist_option.select(_dist_option.item_count - 1)
