@tool
class_name HexMapGenDock
extends Control

signal generation_finished(cancelled: bool)

const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapDocumentValidator = preload("res://addons/hex_map_kit/adapter/hex_map_document_validator.gd")
const HexMapDocumentTerrainLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_terrain_layer_resource.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")
const HexOverlayData = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexOverlayResource = preload("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd")
const HexOverlayTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_overlay_tile_adapter.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")
const HexAdjacencyRuleSet = preload("res://addons/hex_map_kit/adapter/hex_adjacency_rule_set.gd")
const HexAdjacencyRuleEditor = preload("res://addons/hex_map_kit/editor/hex_adjacency_rule_editor.gd")
const HexCellButtonPanel = preload("res://addons/hex_map_kit/editor/hex_cell_button_panel.gd")
const HexMapEditorPathSelector = preload("res://addons/hex_map_kit/editor/hex_map_editor_path_selector.gd")
const HexMapEditorSessionState = preload("res://addons/hex_map_kit/editor/hex_map_editor_session_state.gd")
const HexMapGenStateEvaluator = preload("res://addons/hex_map_kit/editor/hex_map_gen_state_evaluator.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexToricCoordinate = preload("res://addons/hex_map_kit/core/hex_toric_coordinate.gd")
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
const OVERLAY_DEFAULT_ITEM_NAME := "Item1"
const APPLY_WRITE_POLICIES := [
	HexOverlayData.APPLY_CLEAR_AND_WRITE,
	HexOverlayData.APPLY_ADD_ITEM,
]
const APPLY_WRITE_POLICY_NAMES := [
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
const MAPDATA_SOURCE_MAP := "map"
const MAPDATA_SOURCE_OVERLAY := "overlay"
const QUERY_ROW_OPERATION_AND := "and"
const QUERY_ROW_OPERATION_OR := "or"
const QUERY_ROW_MATCH_CONTAIN := "contain"
const QUERY_ROW_MATCH_EXCLUDE := "exclude"
const QUERY_ROW_OPERATION_NAMES := ["AND", "OR"]
const QUERY_ROW_OPERATIONS := [QUERY_ROW_OPERATION_AND, QUERY_ROW_OPERATION_OR]
const QUERY_ROW_MATCH_NAMES := ["Contain", "Exclude"]
const QUERY_ROW_MATCHES := [QUERY_ROW_MATCH_CONTAIN, QUERY_ROW_MATCH_EXCLUDE]
const GENERATION_BLOCK_EMPTY_MASK := "Placement Mask query result is empty."
const GENERATION_BLOCK_EMPTY_ADJACENCY_RULES := "Adjacency Rules has no valid rules."
const GENERATION_BLOCK_STATUS_PREFIX := "Blocked: "
const QUERY_HEX_CELL_DEFAULT_RADIUS := 12.0
const QUERY_HEX_CELL_DEFAULT_GAP := 1.0
const QUERY_HEX_CELL_DEFAULT_PADDING := 2.0
const QUERY_KIND_MASK := "mask"
const QUERY_KIND_REFERENCE := "reference"
const QUERY_KIND_DEDUCTOR_FLOOR := "deductor_floor"
const SAMPLE_TILE_CATALOG_PATH := "res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres"
const CATALOG_FALLBACK_LABEL := "Advanced numeric fallback"

var _generator_row: HBoxContainer
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

var _prob_bar_label: Label
var _wall_prob_slider: HSlider
var _wall_prob_label: Label
var _wall_prob_row: Control
var _seed_spin: SpinBox
var _seed_random_button: Button

var _deductor_row: HBoxContainer
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
var _tile_catalog: HexTileCatalogResource
var _floor_catalog_option: OptionButton
var _wall_catalog_option: OptionButton
var _floor_source_spin: SpinBox
var _floor_atlas_x_spin: SpinBox
var _floor_atlas_y_spin: SpinBox
var _wall_source_spin: SpinBox
var _wall_atlas_x_spin: SpinBox
var _wall_atlas_y_spin: SpinBox
var _atlas_image_button: Button
var _sample_tiles_button: Button
var _current_atlas_image_path := ""

var _deductor_label: Label
var _generator_label: Label

var _overlay_mode_check: CheckButton
var _overlay_controls_container: VBoxContainer
var _overlay_item_name_edit: LineEdit
var _overlay_item_limit_check: CheckButton
var _overlay_item_limit_spin: SpinBox
var _overlay_item_pool_container: VBoxContainer
var _overlay_add_item_button: Button
var _overlay_item_pool_rows: Array[Dictionary] = []
var _source_registry_container: VBoxContainer
var _source_registry_list: VBoxContainer
var _source_registry_status_label: Label
var _source_load_button: Button
var _mapdata_sources: Array[Dictionary] = []
var _next_mapdata_source_id := 1
var _last_overlay_stack_source_count := 0
var _overlay_mask_container: VBoxContainer
var _overlay_mask_query_container: VBoxContainer
var _overlay_mask_add_source_option: OptionButton
var _overlay_mask_add_button: Button
var _query_cell_radius_spin: SpinBox
var _query_cell_gap_spin: SpinBox
var _query_cell_padding_spin: SpinBox
var _overlay_mask_crop_check: CheckButton
var _overlay_mask_count_label: Label
var _overlay_mask_query_rows: Array[Dictionary] = []
var _overlay_deductor_floor_container: VBoxContainer
var _overlay_deductor_floor_query_container: VBoxContainer
var _overlay_deductor_floor_add_source_option: OptionButton
var _overlay_deductor_floor_add_button: Button
var _overlay_deductor_floor_status_label: Label
var _overlay_deductor_floor_query_rows: Array[Dictionary] = []
var _overlay_adjacency_check: CheckButton
var _overlay_reference_container: VBoxContainer
var _overlay_reference_query_container: VBoxContainer
var _overlay_reference_add_source_option: OptionButton
var _overlay_reference_add_button: Button
var _overlay_reference_query_rows: Array[Dictionary] = []
var _overlay_generated_reference_check: CheckButton
var _overlay_neighbor_radius_spin: SpinBox
var _overlay_adjacency_rules_edit: LineEdit
var _overlay_adjacency_rules_edit_button: Button
var _overlay_adjacency_rules_status_label: Label
var _apply_write_policy_option: OptionButton
var _overlay_existing_policy_option: OptionButton
var _generate_history_check: CheckButton
var _generate_history_dir_button: Button
var _generate_history_dir_label: Label
var _generate_history_dir := ""

var _generate_button: Button
var _save_button: Button
var _apply_layer_button: Button
var _stats_label: Label
var _generation_progress_container: HBoxContainer
var _generation_progress_status_label: Label
var _generation_progress_bar: ProgressBar
var _generation_progress_cancel_button: Button

var _current_data = null
var _current_orientation := HexMapResource.ORIENTATION_FLAT_TOP
var _query_hex_cell_radius := QUERY_HEX_CELL_DEFAULT_RADIUS
var _query_hex_cell_gap := QUERY_HEX_CELL_DEFAULT_GAP
var _query_hex_cell_padding := QUERY_HEX_CELL_DEFAULT_PADDING
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
var _editor_session_state: HexMapEditorSessionState = null
var _last_generation_validation_result = null
var _last_generation_validation_summary: Dictionary = {}
var _generation_event_order := 0
var _last_generation_validation_capture_order := 0
var _last_generation_apply_order := 0
var _last_batch_generation_results: Array[Dictionary] = []
var _last_promoted_generation_document = null


func _ready() -> void:
	set_process(true)
	custom_minimum_size = Vector2(260, 220)
	_build_ui()
	refresh_tile_layer_options()
	_refresh_controls()
	_update_stats()


func set_editor_session_state(session: HexMapEditorSessionState) -> void:
	_editor_session_state = session
	if _editor_session_state == null:
		return
	var session_target = _editor_session_state.current_target_layer()
	if session_target != null and _tile_layer_option != null:
		_select_tile_layer_target(session_target)


func editor_session_state() -> HexMapEditorSessionState:
	return _editor_session_state


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
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var root = VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(root)

	root.add_child(_build_section_label("Hex Map Kit"))


	var target_row = HBoxContainer.new()
	target_row.add_child(_build_small_label("Target Layer"))
	_tile_layer_option = OptionButton.new()
	_tile_layer_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tile_layer_option.item_selected.connect(_on_tile_layer_target_selected)
	target_row.add_child(_tile_layer_option)
	_tile_layer_refresh_button = Button.new()
	_tile_layer_refresh_button.text = "Refresh"
	_tile_layer_refresh_button.pressed.connect(_on_tile_layer_refresh_pressed)
	target_row.add_child(_tile_layer_refresh_button)
	root.add_child(target_row)

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


	var generate_methods = HBoxContainer.new()
	var generator_labels = VBoxContainer.new()
	var generate_method_rows = VBoxContainer.new()
	generator_labels.size_flags_vertical = Control.SIZE_EXPAND_FILL
	generate_method_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	generate_methods.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_deductor_label = Label.new()
	_deductor_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_deductor_label.text = "Passage Generator" # "Passage Generator / Overlay Deductor"
	generator_labels.add_child(_deductor_label)
	_generator_label = Label.new()
	_generator_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_generator_label.text = "Wall Generator" # "Wall Generator / Overlay Generator"
	generator_labels.add_child(_generator_label)
	generate_methods.add_child(generator_labels)

	_deductor_row = HBoxContainer.new()

	_connect_method_option = OptionButton.new()
	for name in CONNECT_METHOD_NAMES:
		_connect_method_option.add_item(name)
	_connect_method_option.select(0)
	_connect_method_option.item_selected.connect(_on_option_changed)

	_torus_connectivity_check = CheckButton.new()
	_torus_connectivity_check.text = "Toric Passage"
	_torus_connectivity_check.button_pressed = false
	_torus_connectivity_check.toggled.connect(_on_torus_connectivity_toggled)

	_deductor_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_deductor_row.add_child(_connect_method_option)
	_deductor_row.add_child(spacer)
	_deductor_row.add_child(_torus_connectivity_check)
	generate_method_rows.add_child(_deductor_row)

	_generator_row = HBoxContainer.new()

	_generate_option = OptionButton.new()
	for name in GENERATE_NAMES:
		_generate_option.add_item(name)
	_generate_option.item_selected.connect(_on_generate_changed)
	_generate_option.select(1)

	_overlay_mode_check = CheckButton.new()
	_overlay_mode_check.text = "Overlay"
	_overlay_mode_check.button_pressed = false
	_overlay_mode_check.toggled.connect(_on_overlay_mode_toggled)

	_generator_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var spacer2 = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_generator_row.add_child(_generate_option)
	_generator_row.add_child(spacer2)
	_generator_row.add_child(_overlay_mode_check)
	generate_method_rows.add_child(_generator_row)
	generate_methods.add_child(generate_method_rows)

	root.add_child(generate_methods)

	root.add_child(_build_seed_controls())
	root.add_child(_build_generation_progress_controls())

	var mode_row = HBoxContainer.new()

	_overlay_adjacency_check = CheckButton.new()
	_overlay_adjacency_check.text = " Adjacency Rules"
	_overlay_adjacency_check.button_pressed = false
	_overlay_adjacency_check.toggled.connect(_on_overlay_adjacency_toggled)

	var limit_row = HBoxContainer.new()
	_overlay_item_limit_check = CheckButton.new()
	_overlay_item_limit_check.text = " Generate Combination"
	_overlay_item_limit_check.toggled.connect(_on_overlay_item_limit_toggled)
	limit_row.add_child(_overlay_item_limit_check)

	_overlay_item_limit_spin = _new_int_spin(1, 0, 1048576)
	_overlay_item_limit_spin.value_changed.connect(_on_option_changed)
	_overlay_item_limit_spin.visible = false
	limit_row.add_child(_overlay_item_limit_spin)

	mode_row.add_child(_overlay_adjacency_check)
	mode_row.add_child(limit_row)
	root.add_child(mode_row)

	_wall_prob_row = _build_wall_probability_controls()
	root.add_child(_wall_prob_row)

	_sym_options_container = VBoxContainer.new()
	_sym_options_container.visible = false

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
	root.add_child(_sym_options_container)

	root.add_child(_build_overlay_adjacency_controls())

	root.add_child(_build_apply_write_controls())

	root.add_child(_build_separator())

	var button_row = HBoxContainer.new()

	_apply_layer_button = Button.new()
	_apply_layer_button.text = "Apply Layer"
	_apply_layer_button.pressed.connect(_on_apply_layer_pressed)
	button_row.add_child(_apply_layer_button)

	_save_button = Button.new()
	_save_button.text = "Save As .tres"
	_save_button.pressed.connect(_on_save_pressed)
	button_row.add_child(_save_button)

	root.add_child(button_row)

	_stats_label = Label.new()
	_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stats_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	root.add_child(_stats_label)

	root.add_child(_build_overlay_controls())



	root.add_child(_build_separator())
	root.add_child(_build_tile_layer_controls())


func _build_overlay_controls() -> Control:
	var box = VBoxContainer.new()

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

	_overlay_controls_container.add_child(_build_section_label("Overlay Items"))
	_overlay_item_pool_container = VBoxContainer.new()
	_overlay_controls_container.add_child(_overlay_item_pool_container)
	_add_overlay_item_pool_row(OVERLAY_DEFAULT_ITEM_NAME, 1.0)

	_overlay_add_item_button = Button.new()
	_overlay_add_item_button.text = "Add Item"
	_overlay_add_item_button.pressed.connect(_on_overlay_add_item_pressed)
	_overlay_controls_container.add_child(_overlay_add_item_button)

	_overlay_controls_container.add_child(_build_separator())

	_overlay_controls_container.add_child(_build_source_registry_controls())

	_overlay_controls_container.add_child(_build_separator())

	_overlay_controls_container.add_child(_build_query_cell_settings_controls())

	_overlay_controls_container.add_child(_build_separator())

	_overlay_controls_container.add_child(_build_overlay_mask_controls())

	_overlay_controls_container.add_child(_build_overlay_deductor_floor_controls())

	_overlay_existing_policy_option = OptionButton.new()
	for policy_name in OVERLAY_EXISTING_POLICY_NAMES:
		_overlay_existing_policy_option.add_item(policy_name)
	_overlay_existing_policy_option.select(0)
	_overlay_existing_policy_option.item_selected.connect(_on_option_changed)
	_overlay_controls_container.add_child(_wrap_labeled("Existing Item", _overlay_existing_policy_option))

	return box


func _build_apply_write_controls() -> Control:
	_apply_write_policy_option = OptionButton.new()
	for policy_name in APPLY_WRITE_POLICY_NAMES:
		_apply_write_policy_option.add_item(policy_name)
	_apply_write_policy_option.select(0)
	_apply_write_policy_option.item_selected.connect(_on_option_changed)
	return _wrap_labeled("Apply Write", _apply_write_policy_option)


func _build_source_registry_controls() -> Control:
	_source_registry_container = VBoxContainer.new()
	_source_registry_container.add_child(_build_section_label("Source Registry"))

	var row = HBoxContainer.new()
	_source_load_button = Button.new()
	_source_load_button.text = "Browse .tres"
	_source_load_button.pressed.connect(_on_source_load_pressed)
	row.add_child(_source_load_button)

	_generate_history_dir_label = Label.new()
	_generate_history_dir_label.text = "History: off"
	_generate_history_dir_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_generate_history_dir_label)
	_source_registry_container.add_child(row)

	_source_registry_list = VBoxContainer.new()
	_source_registry_container.add_child(_source_registry_list)
	_source_registry_status_label = Label.new()
	_source_registry_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_source_registry_status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_source_registry_container.add_child(_source_registry_status_label)
	return _source_registry_container


func _build_query_cell_settings_controls() -> Control:
	var row = HBoxContainer.new()
	row.add_child(_build_small_label("Query Cell"))
	row.add_child(_build_small_label("Cell Radius"))
	_query_cell_radius_spin = _new_int_spin(int(_query_hex_cell_radius), 6, 32)
	_query_cell_radius_spin.value_changed.connect(_on_query_cell_radius_changed)
	row.add_child(_query_cell_radius_spin)
	row.add_child(_build_small_label("Gap"))
	_query_cell_gap_spin = _new_int_spin(int(_query_hex_cell_gap), 0, 12)
	_query_cell_gap_spin.value_changed.connect(_on_query_cell_gap_changed)
	row.add_child(_query_cell_gap_spin)
	row.add_child(_build_small_label("Padding"))
	_query_cell_padding_spin = _new_int_spin(int(_query_hex_cell_padding), 0, 16)
	_query_cell_padding_spin.value_changed.connect(_on_query_cell_padding_changed)
	row.add_child(_query_cell_padding_spin)
	return row


func _build_overlay_mask_controls() -> Control:
	_overlay_mask_container = VBoxContainer.new()
	_overlay_mask_container.add_child(_build_section_label("Placement Mask"))
	_overlay_mask_container.add_child(_build_query_row_controls(QUERY_KIND_MASK))
	return _overlay_mask_container


func _build_overlay_deductor_floor_controls() -> Control:
	_overlay_deductor_floor_container = VBoxContainer.new()
	_overlay_deductor_floor_container.visible = false
	_overlay_deductor_floor_container.add_child(_build_section_label("Deductor Floor Source"))
	_overlay_deductor_floor_container.add_child(_build_query_row_controls(QUERY_KIND_DEDUCTOR_FLOOR))
	_overlay_deductor_floor_status_label = Label.new()
	_overlay_deductor_floor_status_label.text = "Default: generated complement"
	_overlay_deductor_floor_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_overlay_deductor_floor_status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_overlay_deductor_floor_container.add_child(_overlay_deductor_floor_status_label)
	return _overlay_deductor_floor_container


func _build_overlay_adjacency_controls() -> Control:
	var box = VBoxContainer.new()

	_overlay_reference_container = VBoxContainer.new()
	_overlay_reference_container.visible = false
	box.add_child(_overlay_reference_container)
	_overlay_reference_container.add_child(_build_section_label("Adjacency Items"))
	_overlay_reference_container.add_child(_build_query_row_controls(QUERY_KIND_REFERENCE))

	_overlay_generated_reference_check = CheckButton.new()
	_overlay_generated_reference_check.text = "Generated Item Reference"
	_overlay_generated_reference_check.tooltip_text = "Use generated target item cells as additional adjacency reference while this generation runs."
	_overlay_generated_reference_check.toggled.connect(_on_option_changed)
	_overlay_reference_container.add_child(_overlay_generated_reference_check)

	_overlay_neighbor_radius_spin = _new_int_spin(1, 1, 16)
	_overlay_neighbor_radius_spin.value_changed.connect(_on_option_changed)
	_overlay_reference_container.add_child(_wrap_labeled("Neighbor Radius", _overlay_neighbor_radius_spin))

	_overlay_adjacency_rules_edit = LineEdit.new()
	_overlay_adjacency_rules_edit.text = "default=0.0"
	_overlay_adjacency_rules_edit.placeholder_text = "default=0.2;1=0.8;2,1=0.4"
	_overlay_adjacency_rules_edit.text_changed.connect(_on_adjacency_rules_text_changed)
	var rules_row = HBoxContainer.new()
	rules_row.add_child(_build_small_label("Adjacency Rules"))
	_overlay_adjacency_rules_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rules_row.add_child(_overlay_adjacency_rules_edit)
	_overlay_adjacency_rules_edit_button = Button.new()
	_overlay_adjacency_rules_edit_button.text = "Edit"
	_overlay_adjacency_rules_edit_button.pressed.connect(_on_adjacency_rules_edit_pressed)
	rules_row.add_child(_overlay_adjacency_rules_edit_button)
	_overlay_reference_container.add_child(rules_row)

	_overlay_adjacency_rules_status_label = Label.new()
	_overlay_adjacency_rules_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_overlay_adjacency_rules_status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_overlay_reference_container.add_child(_overlay_adjacency_rules_status_label)
	_refresh_adjacency_rules_status()
	return box


func _build_query_row_controls(mask_query) -> Control:
	var query_kind = _query_kind_from_value(mask_query)
	var box = VBoxContainer.new()
	var add_row = HBoxContainer.new()
	var option = OptionButton.new()
	_configure_scrollable_option(option)
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_row.add_child(option)
	var add_button = Button.new()
	add_button.text = "Add Row"
	add_button.pressed.connect(_on_query_add_row_pressed.bind(query_kind))
	add_row.add_child(add_button)
	box.add_child(add_row)

	var rows = VBoxContainer.new()
	box.add_child(rows)

	if query_kind == QUERY_KIND_MASK:
		_overlay_mask_add_source_option = option
		_overlay_mask_add_button = add_button
		_overlay_mask_query_container = rows

		var crop_row = HBoxContainer.new()
		_overlay_mask_crop_check = CheckButton.new()
		_overlay_mask_crop_check.text = "Crop"
		_overlay_mask_crop_check.toggled.connect(_on_mask_crop_toggled)
		crop_row.add_child(_overlay_mask_crop_check)
		_overlay_mask_count_label = Label.new()
		_overlay_mask_count_label.text = "Cells: 0"
		crop_row.add_child(_overlay_mask_count_label)
		box.add_child(crop_row)
	elif query_kind == QUERY_KIND_REFERENCE:
		_overlay_reference_add_source_option = option
		_overlay_reference_add_button = add_button
		_overlay_reference_query_container = rows
	else:
		_overlay_deductor_floor_add_source_option = option
		_overlay_deductor_floor_add_button = add_button
		_overlay_deductor_floor_query_container = rows

	_refresh_source_item_options()
	return box


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
	_rect_width_spin.value_changed.connect(_on_shape_size_changed)
	_rect_row.add_child(_rect_width_spin)
	var hl = Label.new()
	hl.text = "Height"
	_rect_row.add_child(hl)
	_rect_height_spin = SpinBox.new()
	_rect_height_spin.min_value = 1
	_rect_height_spin.max_value = 511
	_rect_height_spin.value = 24
	_rect_height_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rect_height_spin.value_changed.connect(_on_shape_size_changed)
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
	_hex_radius_spin.value_changed.connect(_on_shape_size_changed)
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
	_gen_radius_spin.value_changed.connect(_on_shape_size_changed)
	_radius_row.add_child(_gen_radius_spin)
	_radius_row.visible = false
	_size_container.add_child(_radius_row)


func _build_wall_probability_controls() -> Control:
	var row = HBoxContainer.new()
	_prob_bar_label = Label.new()
	_prob_bar_label.text = "  Placement Probability (Non-Ref.)"
	row.add_child(_prob_bar_label)

	_wall_prob_slider = HSlider.new()
	_wall_prob_slider.min_value = 0.0
	_wall_prob_slider.max_value = 1.0
	_wall_prob_slider.step = 0.01
	_wall_prob_slider.value = 0.45
	_wall_prob_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_wall_prob_slider.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_wall_prob_slider.value_changed.connect(_on_wall_prob_changed)
	row.add_child(_wall_prob_slider)

	_wall_prob_label = Label.new()
	_wall_prob_label.text = "0.45"
	_wall_prob_label.custom_minimum_size = Vector2(40, 0)
	row.add_child(_wall_prob_label)
	return row


func _build_seed_controls() -> Control:
	var row = HBoxContainer.new()

	_generate_button = Button.new()
	_generate_button.text = "Primary Generation"
	_generate_button.pressed.connect(_on_generate_pressed)
	row.add_child(_generate_button)

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

	_generate_history_check = CheckButton.new()
	_generate_history_check.text = "History"
	_generate_history_check.toggled.connect(_on_generate_history_toggled)
	row.add_child(_generate_history_check)

	_generate_history_dir_button = Button.new()
	_generate_history_dir_button.text = "History Dir"
	_generate_history_dir_button.pressed.connect(_on_generate_history_dir_pressed)
	row.add_child(_generate_history_dir_button)
	return row


func _build_tile_layer_controls() -> Control:
	var box = VBoxContainer.new()
	box.add_child(_build_section_label("Tile Settings"))

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

	var catalog_row = HBoxContainer.new()
	_floor_catalog_option = _new_catalog_option("floor")
	_floor_catalog_option.item_selected.connect(_on_floor_catalog_selected)
	catalog_row.add_child(_wrap_labeled("Floor Catalog", _floor_catalog_option))
	_wall_catalog_option = _new_catalog_option("wall")
	_wall_catalog_option.item_selected.connect(_on_wall_catalog_selected)
	catalog_row.add_child(_wrap_labeled("Wall Catalog", _wall_catalog_option))
	box.add_child(catalog_row)

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
	_atlas_image_button.text = "Browse Atlas Image"
	_atlas_image_button.pressed.connect(_on_atlas_image_pressed)
	atlas_row.add_child(_atlas_image_button)

	_sample_tiles_button = Button.new()
	_sample_tiles_button.text = "Use Sample Tiles"
	_sample_tiles_button.pressed.connect(_on_sample_tiles_pressed)
	atlas_row.add_child(_sample_tiles_button)
	box.add_child(atlas_row)

	return box


func _build_generation_progress_controls() -> Control:
	_generation_progress_container = HBoxContainer.new()
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
	_generation_progress_bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
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


func _new_catalog_option(tag: String, selected_key: String = "") -> OptionButton:
	var option = OptionButton.new()
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_populate_catalog_option(option, tag, selected_key)
	return option


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


func _configure_scrollable_option(option: OptionButton) -> void:
	var popup = option.get_popup()
	if popup != null:
		popup.max_size = Vector2i(420, 260)


func set_tile_catalog(catalog: HexTileCatalogResource) -> void:
	_tile_catalog = catalog
	_refresh_catalog_options()


func tile_catalog() -> HexTileCatalogResource:
	return _ensure_tile_catalog()


func _ensure_tile_catalog() -> HexTileCatalogResource:
	if _tile_catalog == null:
		_tile_catalog = load(SAMPLE_TILE_CATALOG_PATH) as HexTileCatalogResource
	return _tile_catalog


func _refresh_catalog_options() -> void:
	_populate_catalog_option(_floor_catalog_option, "floor", _catalog_key_from_option(_floor_catalog_option))
	_populate_catalog_option(_wall_catalog_option, "wall", _catalog_key_from_option(_wall_catalog_option))
	for item_row in _overlay_item_pool_rows:
		_populate_catalog_option(
			item_row.get("catalog_option", null),
			"overlay",
			_catalog_key_from_option(item_row.get("catalog_option", null))
		)


func _populate_catalog_option(option: OptionButton, tag: String, selected_key: String = "") -> void:
	if option == null:
		return
	option.clear()
	option.add_item(CATALOG_FALLBACK_LABEL)
	option.set_item_metadata(0, "")
	var selected_index := 0
	var catalog = _ensure_tile_catalog()
	if catalog != null:
		for entry in catalog.entries_with_tag(tag):
			if entry == null:
				continue
			var key = String(entry.get("key"))
			if key == "":
				continue
			var label = String(entry.get("display_name"))
			if label == "":
				label = key
			else:
				label = "%s (%s)" % [label, key]
			option.add_item(label)
			var index = option.item_count - 1
			option.set_item_metadata(index, key)
			if key == selected_key:
				selected_index = index
	option.select(selected_index)


func _catalog_key_from_option(option: OptionButton, index: int = -1) -> String:
	if option == null or option.item_count <= 0:
		return ""
	var selected_index = option.selected if index < 0 else index
	if selected_index < 0 or selected_index >= option.item_count:
		return ""
	return String(option.get_item_metadata(selected_index))


func _select_catalog_option_by_key(option: OptionButton, key: String) -> void:
	if option == null:
		return
	for index in range(option.item_count):
		if String(option.get_item_metadata(index)) == key:
			option.select(index)
			return
	option.select(0)


func _catalog_tile_config(key: String, fallback: Dictionary = {}) -> Dictionary:
	return HexMapTileAdapter.tile_config_from_catalog(_ensure_tile_catalog(), key, fallback)


func _floor_tile_fallback() -> Dictionary:
	return HexMapTileAdapter.tile_config(
		int(_floor_source_spin.value),
		Vector2i(int(_floor_atlas_x_spin.value), int(_floor_atlas_y_spin.value))
	)


func _wall_tile_fallback() -> Dictionary:
	return HexMapTileAdapter.tile_config(
		int(_wall_source_spin.value),
		Vector2i(int(_wall_atlas_x_spin.value), int(_wall_atlas_y_spin.value))
	)


func _apply_catalog_config_to_spins(
	config: Dictionary,
	source_spin: SpinBox,
	atlas_x_spin: SpinBox,
	atlas_y_spin: SpinBox
) -> bool:
	if int(config.get("source_id", -1)) < 0:
		return false
	source_spin.set_value_no_signal(int(config.get("source_id", 0)))
	var atlas = config.get("atlas_coords", Vector2i.ZERO)
	atlas_x_spin.set_value_no_signal(int(atlas.x))
	atlas_y_spin.set_value_no_signal(int(atlas.y))
	return true


func _build_section_label(text: String) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	label.add_theme_font_size_override("font_size", 20)
	return label


func _build_separator() -> HSeparator:
	var sep = HSeparator.new()
	sep.custom_minimum_size = Vector2(0, 4)
	return sep


func load_mapdata_source(path: String) -> int:
	if not ResourceLoader.exists(path):
		return -1
	var resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	return register_mapdata_source(resource, path)


func register_mapdata_source(resource: Resource, path: String = "") -> int:
	if resource == null:
		return -1
	var source_type = ""
	var data = null
	if resource is HexMapResource:
		source_type = MAPDATA_SOURCE_MAP
		data = resource.to_map_data()
	elif resource is HexOverlayResource:
		source_type = MAPDATA_SOURCE_OVERLAY
		data = resource.to_overlay_data()
	else:
		push_error("Unsupported mapdata source resource: %s" % resource)
		return -1

	var normalized_path = String(path)
	if normalized_path != "":
		for index in range(_mapdata_sources.size()):
			if String(_mapdata_sources[index].get("resource_path", "")) == normalized_path:
				_mapdata_sources[index]["resource"] = resource
				_mapdata_sources[index]["resource_type"] = source_type
				_mapdata_sources[index]["data"] = data
				_mapdata_sources[index]["item_keys"] = data.item_keys()
				_mapdata_sources[index]["display_name"] = _unique_source_display_name(
					_source_base_display_name(normalized_path),
					index
				)
				_refresh_source_registry_ui()
				_refresh_source_item_options()
				return int(_mapdata_sources[index]["id"])

	var entry := {
		"id": _next_mapdata_source_id,
		"display_name": _unique_source_display_name(_source_base_display_name(normalized_path), -1),
		"resource_path": normalized_path,
		"resource_type": source_type,
		"resource": resource,
		"data": data,
		"item_keys": data.item_keys(),
	}
	_next_mapdata_source_id += 1
	_mapdata_sources.append(entry)
	_refresh_source_registry_ui()
	_refresh_source_item_options()
	return int(entry["id"])


func clear_mapdata_source(source_id: int) -> void:
	for index in range(_mapdata_sources.size()):
		if int(_mapdata_sources[index].get("id", -1)) == source_id:
			_mapdata_sources.remove_at(index)
			_remove_query_rows_for_source(source_id)
			_reset_mask_crop_if_enabled()
			_refresh_source_registry_ui()
			_refresh_source_item_options()
			_refresh_mask_crop_count()
			return


func reload_mapdata_source(source_id: int) -> bool:
	var entry = _source_entry_by_id(source_id)
	if entry.is_empty():
		return false
	var path = String(entry.get("resource_path", ""))
	if path == "":
		return false
	return load_mapdata_source(path) >= 0


func _source_base_display_name(path: String) -> String:
	if path == "":
		return "Source%d" % _next_mapdata_source_id
	var filename = path.get_file()
	return filename if filename != "" else path


func _unique_source_display_name(base_name: String, existing_index: int) -> String:
	var used := {}
	for index in range(_mapdata_sources.size()):
		if index == existing_index:
			continue
		used[String(_mapdata_sources[index].get("display_name", ""))] = true
	if not used.has(base_name):
		return base_name
	var suffix := 2
	while used.has("%s (%d)" % [base_name, suffix]):
		suffix += 1
	return "%s (%d)" % [base_name, suffix]


func _source_entry_by_id(source_id: int) -> Dictionary:
	for entry in _mapdata_sources:
		if int(entry.get("id", -1)) == source_id:
			return entry
	return {}


func _refresh_source_registry_ui() -> void:
	if _source_registry_list == null:
		return
	for child in _source_registry_list.get_children():
		child.queue_free()
	for entry in _mapdata_sources:
		var box = VBoxContainer.new()
		var row = HBoxContainer.new()
		var label = Label.new()
		label.text = "%s [%s]" % [
			String(entry.get("display_name", "")),
			String(entry.get("resource_type", "")),
		]
		label.tooltip_text = String(entry.get("resource_path", ""))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)

		var reload_button = Button.new()
		reload_button.text = "Reload"
		reload_button.pressed.connect(_on_source_reload_pressed.bind(int(entry["id"])))
		row.add_child(reload_button)

		var clear_button = Button.new()
		clear_button.text = "Clear"
		clear_button.pressed.connect(_on_source_clear_pressed.bind(int(entry["id"])))
		row.add_child(clear_button)
		box.add_child(row)

		var details = Label.new()
		details.text = _source_entry_details_text(entry)
		details.tooltip_text = String(entry.get("resource_path", ""))
		details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		details.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
		box.add_child(details)
		_source_registry_list.add_child(box)
	if _mapdata_sources.is_empty():
		_set_source_registry_status("No mapdata sources loaded.")
	else:
		_set_source_registry_status("Sources: %d" % _mapdata_sources.size())


func _source_entry_details_text(entry: Dictionary) -> String:
	var path = String(entry.get("resource_path", ""))
	if path == "":
		path = "(session source)"
	return "Path: %s  |  %s" % [path, _source_entry_item_counts_text(entry)]


func _source_entry_item_counts_text(entry: Dictionary) -> String:
	var data = entry.get("data", null)
	if data == null:
		return "no data"
	var parts: Array = []
	for item_key in entry.get("item_keys", []):
		parts.append("%s: %d" % [String(item_key), data.item_cells(String(item_key)).size()])
	return ", ".join(parts) if not parts.is_empty() else "no items"


func _set_source_registry_status(text: String) -> void:
	if _source_registry_status_label != null:
		_source_registry_status_label.text = text


func _query_kind_from_value(value) -> String:
	if value is bool:
		return QUERY_KIND_MASK if bool(value) else QUERY_KIND_REFERENCE
	return String(value)


func _query_rows_for_kind(query_kind: String) -> Array:
	match query_kind:
		QUERY_KIND_MASK:
			return _overlay_mask_query_rows
		QUERY_KIND_DEDUCTOR_FLOOR:
			return _overlay_deductor_floor_query_rows
		QUERY_KIND_REFERENCE, _:
			return _overlay_reference_query_rows


func _query_container_for_kind(query_kind: String) -> VBoxContainer:
	match query_kind:
		QUERY_KIND_MASK:
			return _overlay_mask_query_container
		QUERY_KIND_DEDUCTOR_FLOOR:
			return _overlay_deductor_floor_query_container
		QUERY_KIND_REFERENCE, _:
			return _overlay_reference_query_container


func _query_add_source_option_for_kind(query_kind: String) -> OptionButton:
	match query_kind:
		QUERY_KIND_MASK:
			return _overlay_mask_add_source_option
		QUERY_KIND_DEDUCTOR_FLOOR:
			return _overlay_deductor_floor_add_source_option
		QUERY_KIND_REFERENCE, _:
			return _overlay_reference_add_source_option


func _refresh_source_item_options() -> void:
	_refresh_source_add_option(_overlay_mask_add_source_option, -1)
	_refresh_source_add_option(_overlay_reference_add_source_option, -1)
	_refresh_source_add_option(_overlay_deductor_floor_add_source_option, -1)
	for row in _overlay_mask_query_rows:
		_refresh_query_row_source_option(row)
	for row in _overlay_deductor_floor_query_rows:
		_refresh_query_row_source_option(row)
	for row in _overlay_reference_query_rows:
		_refresh_query_row_source_option(row)
	_refresh_query_row_order(true)
	_refresh_query_row_order(QUERY_KIND_DEDUCTOR_FLOOR)
	_refresh_query_row_order(false)


func _refresh_source_add_option(option: OptionButton, selected_source_id: int) -> void:
	if option == null:
		return
	option.clear()
	var selected_index := 0
	for entry in _mapdata_sources:
		var item_keys: Array = entry.get("item_keys", [])
		if item_keys.is_empty():
			continue
		var index = option.item_count
		option.add_item(String(entry.get("display_name", "")))
		option.set_item_metadata(index, {"source_id": int(entry["id"])})
		if int(entry["id"]) == selected_source_id:
			selected_index = index
	option.disabled = option.item_count == 0
	if option.item_count > 0:
		option.select(clampi(selected_index, 0, option.item_count - 1))


func _refresh_query_row_source_option(row: Dictionary) -> void:
	var source_id = int(row.get("source_id", -1))
	var entry = _source_entry_by_id(source_id)
	var source_label: Label = row.get("source_label", null)
	if source_label != null:
		source_label.text = String(entry.get("display_name", "(missing source)")) if not entry.is_empty() else "(missing source)"
		source_label.tooltip_text = String(entry.get("resource_path", ""))

	var option: OptionButton = row.get("source_item", null)
	if option == null:
		return
	option.clear()
	var selected_item_key = String(row.get("item_key", ""))
	var selected_index := 0
	if not entry.is_empty():
		for item_key in entry.get("item_keys", []):
			var index = option.item_count
			option.add_item(String(item_key))
			option.set_item_metadata(index, {
				"source_id": source_id,
				"item_key": String(item_key),
			})
			if String(item_key) == selected_item_key:
				selected_index = index
	option.disabled = option.item_count == 0
	if option.item_count > 0:
		option.select(clampi(selected_index, 0, option.item_count - 1))
		var metadata = option.get_item_metadata(option.selected)
		if metadata is Dictionary:
			row["source_id"] = int(metadata["source_id"])
			row["item_key"] = String(metadata["item_key"])


func _on_source_load_pressed() -> void:
	var dialog = HexMapEditorPathSelector.new_dialog(
		EditorFileDialog.FILE_MODE_OPEN_FILE,
		HexMapEditorPathSelector.TRES_FILTERS
	)
	dialog.file_selected.connect(_on_source_file_selected)
	if not HexMapEditorPathSelector.popup_dialog(dialog):
		_set_source_registry_status("Source browse is available in the editor.")


func _on_source_file_selected(path: String) -> void:
	if load_mapdata_source(path) < 0:
		_set_source_registry_status("Failed to load mapdata source: %s" % path)
		push_warning("Failed to load mapdata source: %s" % path)


func _on_source_reload_pressed(source_id: int) -> void:
	if not reload_mapdata_source(source_id):
		_set_source_registry_status("Failed to reload mapdata source: %d" % source_id)
		push_warning("Failed to reload mapdata source: %d" % source_id)


func _on_source_clear_pressed(source_id: int) -> void:
	clear_mapdata_source(source_id)


func _on_query_add_row_pressed(mask_query) -> void:
	var query_kind = _query_kind_from_value(mask_query)
	var option = _query_add_source_option_for_kind(query_kind)
	if option == null or option.item_count == 0:
		return
	var metadata = option.get_item_metadata(option.selected)
	if not metadata is Dictionary:
		return
	var source_id = int(metadata["source_id"])
	var source_entry = _source_entry_by_id(source_id)
	var item_keys: Array = source_entry.get("item_keys", [])
	if item_keys.is_empty():
		return
	_add_query_row(
		query_kind,
		source_id,
		String(item_keys[0])
	)


func _add_query_row(
	mask_query,
	source_id: int,
	item_key: String,
	operation: String = QUERY_ROW_OPERATION_OR,
	match: String = QUERY_ROW_MATCH_CONTAIN
) -> Dictionary:
	var query_kind = _query_kind_from_value(mask_query)
	var container = _query_container_for_kind(query_kind)
	if container == null:
		return {}

	var row_control = VBoxContainer.new()
	var top_row = HBoxContainer.new()
	row_control.add_child(top_row)
	var operation_option = OptionButton.new()
	for name in QUERY_ROW_OPERATION_NAMES:
		operation_option.add_item(name)
	operation_option.select(max(0, QUERY_ROW_OPERATIONS.find(operation)))
	top_row.add_child(operation_option)

	var match_option = OptionButton.new()
	for name in QUERY_ROW_MATCH_NAMES:
		match_option.add_item(name)
	match_option.select(max(0, QUERY_ROW_MATCHES.find(match)))
	top_row.add_child(match_option)

	var source_label = Label.new()
	source_label.custom_minimum_size = Vector2(96, 0)
	top_row.add_child(source_label)

	var source_item_option = OptionButton.new()
	_configure_scrollable_option(source_item_option)
	source_item_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(source_item_option)

	var offset_label = Label.new()
	offset_label.text = "0,0,0"
	top_row.add_child(offset_label)

	var row := {
		"row": row_control,
		"operation": operation_option,
		"match": match_option,
		"source_label": source_label,
		"source_item": source_item_option,
		"source_id": source_id,
		"item_key": item_key,
		"offset": HexVector.zero(),
		"offset_label": offset_label,
		"query_kind": query_kind,
		"mask_query": query_kind == QUERY_KIND_MASK,
	}

	operation_option.item_selected.connect(_on_query_row_changed.bind(row, query_kind))
	match_option.item_selected.connect(_on_query_row_changed.bind(row, query_kind))
	source_item_option.item_selected.connect(_on_query_row_source_selected.bind(row, query_kind))

	var offset_control = _build_query_offset_control(row, query_kind)
	top_row.add_child(offset_control)

	var move_buttons = VBoxContainer.new()
	var up_button = Button.new()
	up_button.text = "^"
	up_button.tooltip_text = "Move row up"
	up_button.pressed.connect(_on_query_row_move_pressed.bind(row, query_kind, -1))
	move_buttons.add_child(up_button)
	row["up"] = up_button

	var down_button = Button.new()
	down_button.text = "v"
	down_button.tooltip_text = "Move row down"
	down_button.pressed.connect(_on_query_row_move_pressed.bind(row, query_kind, 1))
	move_buttons.add_child(down_button)
	row["down"] = down_button
	top_row.add_child(move_buttons)

	var remove_button = Button.new()
	remove_button.text = "-"
	remove_button.pressed.connect(_on_query_row_remove_pressed.bind(row, query_kind))
	top_row.add_child(remove_button)
	row["remove"] = remove_button

	_query_rows_for_kind(query_kind).append(row)
	container.add_child(row_control)
	_refresh_query_row_source_option(row)
	_refresh_query_row_order(query_kind)
	_on_query_row_edited(query_kind)
	return row


func _build_query_offset_control(row: Dictionary, mask_query) -> Control:
	var query_kind = _query_kind_from_value(mask_query)
	var panel = HexCellButtonPanel.new()
	panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	panel.cell_pressed.connect(_on_query_offset_cell_pressed.bind(row, query_kind))
	row["offset_panel"] = panel
	_refresh_query_offset_panel(row)
	return panel


func _refresh_query_offset_panel(row: Dictionary) -> void:
	var panel: HexCellButtonPanel = row.get("offset_panel", null)
	if panel == null:
		return
	var offset = row.get("offset", HexVector.zero())
	panel.configure({
		"shape_kind": "directions",
		"flat_top": _tile_settings_flat_top(),
		"cell_radius": _query_hex_cell_radius,
		"cell_gap": _query_hex_cell_gap,
		"padding": Vector2(_query_hex_cell_padding, _query_hex_cell_padding),
		"center_cell": HexVector.zero(),
		"pressable_cells": _query_direction_pressable_cells(),
		"label_by_cell": _query_direction_label_map(offset),
		"tooltip_by_cell": _query_direction_tooltip_map(offset),
		"metadata_by_cell": _query_direction_metadata_map(),
	})


func _refresh_all_query_offset_panels() -> void:
	for query_row in _overlay_mask_query_rows + _overlay_deductor_floor_query_rows + _overlay_reference_query_rows:
		_refresh_query_offset_panel(query_row)


func _on_query_cell_radius_changed(value: float) -> void:
	_query_hex_cell_radius = clampf(value, 6.0, 32.0)
	_sync_query_cell_setting_spins()
	_refresh_all_query_offset_panels()


func _on_query_cell_gap_changed(value: float) -> void:
	_query_hex_cell_gap = clampf(value, 0.0, 12.0)
	_sync_query_cell_setting_spins()
	_refresh_all_query_offset_panels()


func _on_query_cell_padding_changed(value: float) -> void:
	_query_hex_cell_padding = clampf(value, 0.0, 16.0)
	_sync_query_cell_setting_spins()
	_refresh_all_query_offset_panels()


func _sync_query_cell_setting_spins() -> void:
	if _query_cell_radius_spin != null:
		_query_cell_radius_spin.set_value_no_signal(_query_hex_cell_radius)
	if _query_cell_gap_spin != null:
		_query_cell_gap_spin.set_value_no_signal(_query_hex_cell_gap)
	if _query_cell_padding_spin != null:
		_query_cell_padding_spin.set_value_no_signal(_query_hex_cell_padding)


func _query_direction_label(direction_index: int) -> String:
	return ["+Q", "-R", "+S", "-Q", "+R", "-S"][direction_index]


func _query_direction_pressable_cells() -> Dictionary:
	var result := {}
	for direction in HexVector.directions():
		result[direction.key()] = true
	return result


func _query_direction_label_map(offset) -> Dictionary:
	var result := {HexVector.zero().key(): offset.key()}
	for direction_index in range(HexVector.directions().size()):
		var direction = HexVector.directions()[direction_index]
		result[direction.key()] = _query_direction_label(direction_index)
	return result


func _query_direction_tooltip_map(offset) -> Dictionary:
	var result := {HexVector.zero().key(): "Current offset %s" % offset.key()}
	for direction_index in range(HexVector.directions().size()):
		var direction = HexVector.directions()[direction_index]
		result[direction.key()] = "Offset %s" % _query_direction_label(direction_index)
	return result


func _query_direction_metadata_map() -> Dictionary:
	var result := {}
	for direction_index in range(HexVector.directions().size()):
		var direction = HexVector.directions()[direction_index]
		result[direction.key()] = {
			"direction_index": direction_index,
			"direction": direction,
		}
	return result


func _on_query_row_changed(_index: int, row: Dictionary, mask_query) -> void:
	var query_kind = _query_kind_from_value(mask_query)
	var operation_option: OptionButton = row["operation"]
	row["operation_value"] = QUERY_ROW_OPERATIONS[clampi(operation_option.selected, 0, QUERY_ROW_OPERATIONS.size() - 1)]
	var match_option: OptionButton = row["match"]
	row["match_value"] = QUERY_ROW_MATCHES[clampi(match_option.selected, 0, QUERY_ROW_MATCHES.size() - 1)]
	_on_query_row_edited(query_kind)


func _on_query_row_source_selected(index: int, row: Dictionary, mask_query) -> void:
	var query_kind = _query_kind_from_value(mask_query)
	var option: OptionButton = row["source_item"]
	var metadata = option.get_item_metadata(index)
	if metadata is Dictionary:
		row["source_id"] = int(metadata["source_id"])
		row["item_key"] = String(metadata["item_key"])
	_on_query_row_edited(query_kind)


func _on_query_offset_cell_pressed(entry: Dictionary, row: Dictionary, mask_query) -> void:
	var metadata: Dictionary = entry.get("metadata", {})
	var direction = metadata.get("direction", null)
	if direction == null:
		return
	var query_kind = _query_kind_from_value(mask_query)
	var offset = row.get("offset", HexVector.zero())
	offset = offset.add(direction)
	row["offset"] = offset
	var label: Label = row["offset_label"]
	label.text = offset.key()
	_refresh_query_offset_panel(row)
	_on_query_row_edited(query_kind)


func _on_query_row_move_pressed(row: Dictionary, mask_query, delta: int) -> void:
	var query_kind = _query_kind_from_value(mask_query)
	var rows = _query_rows_for_kind(query_kind)
	var index = rows.find(row)
	if index < 0:
		return
	var target = index + delta
	if target < 0 or target >= rows.size():
		return
	rows.remove_at(index)
	rows.insert(target, row)
	var container = _query_container_for_kind(query_kind)
	container.move_child(row["row"], target)
	_refresh_query_row_order(query_kind)
	_on_query_row_edited(query_kind)


func _on_query_row_remove_pressed(row: Dictionary, mask_query) -> void:
	var query_kind = _query_kind_from_value(mask_query)
	var rows = _query_rows_for_kind(query_kind)
	var index = rows.find(row)
	if index >= 0:
		rows.remove_at(index)
	var control: Control = row["row"]
	control.queue_free()
	_refresh_query_row_order(query_kind)
	_on_query_row_edited(query_kind)


func _remove_query_rows_for_source(source_id: int) -> void:
	for query_kind in [QUERY_KIND_MASK, QUERY_KIND_DEDUCTOR_FLOOR, QUERY_KIND_REFERENCE]:
		var rows = _query_rows_for_kind(query_kind)
		for index in range(rows.size() - 1, -1, -1):
			if int(rows[index].get("source_id", -1)) == source_id:
				var control: Control = rows[index]["row"]
				rows.remove_at(index)
				control.queue_free()
		_refresh_query_row_order(query_kind)


func _refresh_query_row_order(mask_query) -> void:
	var query_kind = _query_kind_from_value(mask_query)
	var rows = _query_rows_for_kind(query_kind)
	for index in range(rows.size()):
		var operation_option: OptionButton = rows[index]["operation"]
		operation_option.disabled = _generation_running or index == 0
		var up_button: Button = rows[index]["up"]
		var down_button: Button = rows[index]["down"]
		up_button.disabled = _generation_running or index == 0
		down_button.disabled = _generation_running or index == rows.size() - 1


func _on_query_row_edited(mask_query) -> void:
	var query_kind = _query_kind_from_value(mask_query)
	if query_kind == QUERY_KIND_MASK:
		_reset_mask_crop_if_enabled()
		_refresh_mask_crop_count()
	elif query_kind == QUERY_KIND_DEDUCTOR_FLOOR:
		_refresh_deductor_floor_status()
	_refresh_generation_block_state()


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
	var catalog_option = _new_catalog_option("overlay")
	row.add_child(catalog_option)
	var tile_source_spin = _new_int_spin(0, 0, 1024)
	tile_source_spin.value_changed.connect(_on_option_changed)
	row.add_child(tile_source_spin)
	var tile_atlas_x_spin = _new_int_spin(1, 0, 4096)
	tile_atlas_x_spin.value_changed.connect(_on_option_changed)
	row.add_child(tile_atlas_x_spin)
	var tile_atlas_y_spin = _new_int_spin(0, 0, 4096)
	tile_atlas_y_spin.value_changed.connect(_on_option_changed)
	row.add_child(tile_atlas_y_spin)

	var copy_floor_button = Button.new()
	copy_floor_button.text = "Floor Tile"
	copy_floor_button.tooltip_text = "Copy current Floor tile settings"
	row.add_child(copy_floor_button)

	var copy_wall_button = Button.new()
	copy_wall_button.text = "Wall Tile"
	copy_wall_button.tooltip_text = "Copy current Wall tile settings"
	row.add_child(copy_wall_button)

	var remove_button = Button.new()
	remove_button.text = "-"
	remove_button.pressed.connect(_on_overlay_remove_item_pressed.bind(row))
	row.add_child(remove_button)

	_overlay_item_pool_container.add_child(row)
	var entry := {
		"row": row,
		"name": name_edit,
		"amount_label": amount_label,
		"amount": amount_spin,
		"catalog_option": catalog_option,
		"tile_source": tile_source_spin,
		"tile_atlas_x": tile_atlas_x_spin,
		"tile_atlas_y": tile_atlas_y_spin,
		"copy_floor": copy_floor_button,
		"copy_wall": copy_wall_button,
		"remove": remove_button,
	}
	_overlay_item_pool_rows.append(entry)
	catalog_option.item_selected.connect(_on_overlay_item_catalog_selected.bind(entry))
	copy_floor_button.pressed.connect(_on_overlay_item_tile_copy_pressed.bind(entry, false))
	copy_wall_button.pressed.connect(_on_overlay_item_tile_copy_pressed.bind(entry, true))
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
		var copy_floor_button: Button = item_row["copy_floor"]
		copy_floor_button.disabled = _generation_running
		var copy_wall_button: Button = item_row["copy_wall"]
		copy_wall_button.disabled = _generation_running


func _on_overlay_item_catalog_selected(index: int, item_row: Dictionary) -> void:
	var catalog_option: OptionButton = item_row.get("catalog_option", null)
	var key = _catalog_key_from_option(catalog_option, index)
	if key == "":
		return
	var source_spin: SpinBox = item_row["tile_source"]
	var atlas_x_spin: SpinBox = item_row["tile_atlas_x"]
	var atlas_y_spin: SpinBox = item_row["tile_atlas_y"]
	var fallback = HexOverlayTileAdapter.tile_config(
		int(source_spin.value),
		Vector2i(
			int(atlas_x_spin.value),
			int(atlas_y_spin.value)
		)
	)
	var config = _catalog_tile_config(key, fallback)
	if _apply_catalog_config_to_spins(
		config,
		source_spin,
		atlas_x_spin,
		atlas_y_spin
	):
		_on_option_changed(0)


func _on_overlay_add_item_pressed() -> void:
	_add_overlay_item_pool_row("", 1.0)


func _on_overlay_remove_item_pressed(row: HBoxContainer) -> void:
	_remove_overlay_item_pool_row(row)


func _on_overlay_item_tile_copy_pressed(item_row: Dictionary, wall_tile: bool) -> void:
	var source_spin: SpinBox = item_row["tile_source"]
	var atlas_x_spin: SpinBox = item_row["tile_atlas_x"]
	var atlas_y_spin: SpinBox = item_row["tile_atlas_y"]
	if wall_tile:
		source_spin.set_value_no_signal(int(_wall_source_spin.value))
		atlas_x_spin.set_value_no_signal(int(_wall_atlas_x_spin.value))
		atlas_y_spin.set_value_no_signal(int(_wall_atlas_y_spin.value))
		_select_catalog_option_by_key(item_row.get("catalog_option", null), _catalog_key_from_option(_wall_catalog_option))
	else:
		source_spin.set_value_no_signal(int(_floor_source_spin.value))
		atlas_x_spin.set_value_no_signal(int(_floor_atlas_x_spin.value))
		atlas_y_spin.set_value_no_signal(int(_floor_atlas_y_spin.value))
		_select_catalog_option_by_key(item_row.get("catalog_option", null), _catalog_key_from_option(_floor_catalog_option))
	_on_option_changed(0)


func _on_generate_changed(_index: int) -> void:
	if _generate_option.selected == GENERATE_SIMPLE \
		and _overlay_adjacency_check != null \
		and _overlay_adjacency_check.button_pressed:
		_overlay_adjacency_check.set_pressed_no_signal(false)
	if _generate_option.selected == GENERATE_SYMMETRIC \
		and _overlay_item_limit_check != null \
		and _overlay_item_limit_check.button_pressed:
		_overlay_item_limit_check.set_pressed_no_signal(false)
	_refresh_controls()


func _on_shape_changed(_index: int) -> void:
	_reset_mask_crop_if_enabled()
	_refresh_controls()


func _on_symmetric_shape_changed(index: int) -> void:
	_reset_mask_crop_if_enabled()
	if index == SHAPE_HEXAGON and _torus_connectivity_check != null:
		_torus_connectivity_check.set_pressed_no_signal(false)
	_refresh_controls()


func _on_torus_connectivity_toggled(enabled: bool) -> void:
	_reset_mask_crop_if_enabled()
	if enabled and _shape_option_symmetric != null:
		_shape_option_symmetric.select(SHAPE_RECTANGLE)
	_refresh_controls()


func _on_shape_size_changed(_value: float) -> void:
	_reset_mask_crop_if_enabled()
	_refresh_mask_crop_count()
	_refresh_controls()


func _on_wall_prob_changed(value: float) -> void:
	_wall_prob_label.text = "%.2f" % value


func _on_overlay_mode_toggled(_enabled: bool) -> void:
	_refresh_controls()


func _on_overlay_adjacency_toggled(enabled: bool) -> void:
	if enabled and _generate_option != null:
		_generate_option.select(GENERATE_SYMMETRIC)
	_refresh_controls()


func _on_overlay_item_limit_toggled(enabled: bool) -> void:
	if enabled and _generate_option != null:
		_generate_option.select(GENERATE_SIMPLE)
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
	_refresh_adjacency_rules_status()
	_on_option_changed(rules_text)


func _on_adjacency_rule_editor_cancel() -> void:
	pass


func _on_adjacency_rules_text_changed(text: String) -> void:
	_refresh_adjacency_rules_status()
	_on_option_changed(text)


func _refresh_adjacency_rules_status() -> void:
	if _overlay_adjacency_rules_status_label == null:
		return
	var text = _overlay_adjacency_rules_edit.text if _overlay_adjacency_rules_edit != null else ""
	var report = HexAdjacencyRuleSet.parse_rules_text_report(text)
	_overlay_adjacency_rules_status_label.text = _adjacency_rule_status_text(report)


func _adjacency_rule_status_text(report: Dictionary) -> String:
	var rules: Dictionary = report.get("rules", {})
	var invalid_entries: Array = report.get("invalid_entries", [])
	var text = "Rules: %d" % rules.size()
	if not invalid_entries.is_empty():
		text += "  Invalid: %s" % ", ".join(invalid_entries)
	return text


func _on_option_changed(_v = null) -> void:
	_refresh_generation_block_state()


func _on_mask_crop_toggled(_enabled: bool) -> void:
	_refresh_mask_crop_count()


func _on_generate_history_toggled(enabled: bool) -> void:
	if enabled and _generate_history_dir == "":
		_on_generate_history_dir_pressed()
		return
	_refresh_generate_history_label()


func _on_generate_history_dir_pressed() -> void:
	var dialog = HexMapEditorPathSelector.new_dialog(
		EditorFileDialog.FILE_MODE_OPEN_DIR,
		[]
	)
	dialog.dir_selected.connect(_on_generate_history_dir_selected)
	dialog.canceled.connect(_on_generate_history_dir_cancelled)
	if not HexMapEditorPathSelector.popup_dialog(dialog):
		_set_source_registry_status("History directory selection is available in the editor.")


func _on_generate_history_dir_selected(path: String) -> void:
	_generate_history_dir = path
	if _generate_history_check != null:
		_generate_history_check.set_pressed_no_signal(true)
	_refresh_generate_history_label()


func _on_generate_history_dir_cancelled() -> void:
	if _generate_history_dir == "" and _generate_history_check != null:
		_generate_history_check.set_pressed_no_signal(false)
	_refresh_generate_history_label()


func _refresh_generate_history_label() -> void:
	if _generate_history_dir_label == null:
		return
	if _generate_history_check == null or not _generate_history_check.button_pressed:
		_generate_history_dir_label.text = "History: off"
	elif _generate_history_dir == "":
		_generate_history_dir_label.text = "History: choose directory"
	else:
		_generate_history_dir_label.text = "History: %s" % _generate_history_dir


func _on_seed_randomize() -> void:
	_seed_spin.value = randi() % 100000


func _on_tile_layer_refresh_pressed() -> void:
	refresh_tile_layer_options()


func _on_tile_layer_target_selected(index: int) -> void:
	if index == _add_tile_layer_option_index():
		var layer = add_new_tile_map_layer()
		if layer == null:
			refresh_tile_layer_options(_tile_layer_scan_root)
	_publish_session_target("generate.target_selected")


func _on_tile_orientation_changed(_index: int) -> void:
	var previous_orientation = _current_orientation
	_current_orientation = _tile_settings_orientation()
	if previous_orientation != _current_orientation:
		_swap_tile_size_controls()
		_refresh_all_query_offset_panels()
	_apply_tile_settings_to_current_layer()


func _on_tile_setting_changed(_value: float) -> void:
	if _suppress_tile_settings_apply:
		return
	_apply_tile_settings_to_current_layer()


func _on_floor_catalog_selected(index: int) -> void:
	var key = _catalog_key_from_option(_floor_catalog_option, index)
	if key == "":
		return
	if _apply_catalog_config_to_spins(
		_catalog_tile_config(key, _floor_tile_fallback()),
		_floor_source_spin,
		_floor_atlas_x_spin,
		_floor_atlas_y_spin
	):
		_apply_tile_settings_to_current_layer()


func _on_wall_catalog_selected(index: int) -> void:
	var key = _catalog_key_from_option(_wall_catalog_option, index)
	if key == "":
		return
	if _apply_catalog_config_to_spins(
		_catalog_tile_config(key, _wall_tile_fallback()),
		_wall_source_spin,
		_wall_atlas_x_spin,
		_wall_atlas_y_spin
	):
		_apply_tile_settings_to_current_layer()


func _on_generate_pressed() -> void:
	_generate_map(true)


func _on_cancel_generation_pressed() -> void:
	request_generation_cancel()


func _on_sample_tiles_pressed() -> void:
	var layer = _find_editor_selected_tile_map_layer()
	if layer == null:
		push_error("No selected TileMapLayer or HexTileMapLayer found in the scene. Select one first.")
		return
	if setup_sample_tiles_on_tile_map_layer(layer):
		print("Configured sample hex tiles on target layer: %s" % layer.name)


func _on_atlas_image_pressed() -> void:
	var layer = _find_editor_selected_tile_map_layer()
	if layer == null:
		push_error("No selected TileMapLayer or HexTileMapLayer found in the scene. Select one first.")
		return

	var dialog = HexMapEditorPathSelector.new_dialog(
		EditorFileDialog.FILE_MODE_OPEN_FILE,
		HexMapEditorPathSelector.IMAGE_FILTERS
	)
	dialog.file_selected.connect(_on_atlas_image_selected.bind(layer))
	if not HexMapEditorPathSelector.popup_dialog(dialog):
		push_error("Atlas image browse is available in the editor.")


func _on_atlas_image_selected(path: String, layer) -> void:
	if setup_atlas_tiles_on_tile_map_layer(
		layer,
		path,
		int(_floor_source_spin.value),
		_tile_settings_tile_size(),
		Vector2i(int(_floor_atlas_x_spin.value), int(_floor_atlas_y_spin.value)),
		Vector2i(int(_wall_atlas_x_spin.value), int(_wall_atlas_y_spin.value))
	):
		print("Configured hex atlas on target layer: %s" % layer.name)


func _on_save_pressed() -> void:
	var resource = _resource_for_save_button()
	if resource == null:
		return

	var dialog = HexMapEditorPathSelector.new_dialog(
		EditorFileDialog.FILE_MODE_SAVE_FILE,
		HexMapEditorPathSelector.TRES_FILTERS
	)
	dialog.current_file = "hex_map.tres"
	dialog.file_selected.connect(_on_save_file_selected.bind(resource))
	if not HexMapEditorPathSelector.popup_dialog(dialog):
		push_error("Save As is available in the editor.")


func _on_save_file_selected(path: String, resource: Resource) -> void:
	var error = ResourceSaver.save(resource, path)
	if error == OK:
		EditorInterface.get_resource_filesystem().scan()
		print("Hex Map saved to: %s" % path)
	else:
		push_error("Failed to save hex map: %d" % error)


func _on_apply_layer_pressed() -> void:
	if not _overlay_mode_enabled():
		if _current_data == null:
			return
	else:
		if _overlay_mask_crop_enabled():
			if _overlay_crop_result_data() == null:
				return
		elif not _apply_overlay_source_stack_to_current():
			return

	var layer = _find_target_tile_map_layer()
	if layer == null:
		push_error("No TileMapLayer or HexTileMapLayer found in the scene. Add one first.")
		return

	if _overlay_mode_enabled():
		if _overlay_mask_crop_enabled():
			_apply_crop_result_to_tile_map_layer(layer)
		else:
			apply_current_overlay_data_to_tile_map_layer(layer)
	else:
		apply_current_data_to_tile_map_layer(layer)
	_publish_session_target("generate.apply_layer")
	print("Applied hex map to target layer: %s" % layer.name)


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
	if layer is HexTileMapLayer:
		var hex_layer := layer as HexTileMapLayer
		hex_layer.flat_top = flat_top
		hex_layer.ensure_display_tiles(
			_tile_settings_tile_size(),
			int(_floor_source_spin.value),
			Vector2i(int(_floor_atlas_x_spin.value), int(_floor_atlas_y_spin.value)),
			int(_wall_source_spin.value),
			Vector2i(int(_wall_atlas_x_spin.value), int(_wall_atlas_y_spin.value))
		)
		return hex_layer.apply_overlay_data(
			_current_overlay_data,
			_overlay_item_tile_configs(),
			_apply_write_clears_layer(),
			_current_overlay_data.item_keys()
		)
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
		_apply_write_clears_layer(),
		flat_top,
		_current_overlay_data.item_keys()
	)
	return true


func _apply_crop_result_to_tile_map_layer(layer) -> bool:
	if layer == null:
		return false
	var data = _overlay_crop_result_data()
	_apply_overlay_data_to_current(data, _apply_write_policy(), _overlay_existing_policy())
	return apply_current_overlay_data_to_tile_map_layer(layer)


func _overlay_source_stack_data():
	var overlay_sources: Array = []
	for entry in _mapdata_sources:
		if String(entry.get("resource_type", "")) == MAPDATA_SOURCE_OVERLAY:
			overlay_sources.append(entry)
	_last_overlay_stack_source_count = overlay_sources.size()
	if overlay_sources.is_empty():
		var message = "No HexOverlayData source found in Source Registry."
		_set_source_registry_status(message)
		push_warning(message)
		return null

	var first_data = overlay_sources[0].get("data", null)
	if first_data == null:
		return null
	var result = first_data.duplicate_data()
	var base_cyclic_size = int(result.cyclic_size)
	var existing_policy = _overlay_existing_policy()
	for index in range(1, overlay_sources.size()):
		var data = overlay_sources[index].get("data", null)
		if data == null:
			continue
		if int(data.cyclic_size) != base_cyclic_size:
			push_warning("Overlay source cyclic_size differs from first source: %s" % overlay_sources[index].get("display_name", ""))
		result.apply_overlay(data, HexOverlayData.APPLY_ADD_ITEM, existing_policy)
	return result


func _apply_overlay_source_stack_to_current() -> bool:
	var stack = _overlay_source_stack_data()
	if stack == null:
		return false
	var write_policy = _apply_write_policy()
	var existing_policy = _overlay_existing_policy()
	_apply_overlay_data_to_current(stack, write_policy, existing_policy)
	_update_stats()
	_set_source_registry_status(
		"Stacked %d overlay source(s); items=%d; occupied=%d; write=%s; existing=%s" % [
			_last_overlay_stack_source_count,
			_current_overlay_data.item_keys().size(),
			_current_overlay_data.occupied_cells().size(),
			write_policy,
			existing_policy,
		]
	)
	return true


func _apply_overlay_data_to_current(data, write_policy: String, existing_policy: String) -> void:
	if data == null:
		return
	if _current_overlay_data != null and write_policy == HexOverlayData.APPLY_ADD_ITEM:
		_current_overlay_data.apply_overlay(data, HexOverlayData.APPLY_ADD_ITEM, existing_policy)
	else:
		_current_overlay_data = data


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
		var item_name = _overlay_item_pool_row_name(item_row, index)
		var fallback = HexOverlayTileAdapter.tile_config(
			int(tile_source_spin.value),
			Vector2i(
				int(tile_atlas_x_spin.value),
				int(tile_atlas_y_spin.value)
			)
		)
		var catalog_key = _catalog_key_from_option(item_row.get("catalog_option", null))
		result[item_name] = _catalog_tile_config(catalog_key, fallback) if catalog_key != "" else fallback
	for item_key in _current_overlay_data.item_keys():
		if not result.has(item_key):
			result[item_key] = fallback_config
	return result


func _find_target_tile_map_layer_and_apply_current() -> bool:
	var layer = _find_target_tile_map_layer()
	if layer == null:
		return false
	if _overlay_mode_enabled() and _current_overlay_data != null:
		_last_generation_apply_order = _next_generation_event_order()
		_last_generation_validation_summary["apply_order"] = _last_generation_apply_order
		return apply_current_overlay_data_to_tile_map_layer(layer)
	if _current_data != null:
		_last_generation_apply_order = _next_generation_event_order()
		_last_generation_validation_summary["apply_order"] = _last_generation_apply_order
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
	_tile_layer_nodes = _prioritized_tile_layer_nodes(_tile_layer_nodes)

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
	_publish_session_target("generate.refresh_targets")


func selected_tile_map_layer():
	if _tile_layer_option == null:
		return null
	var node_index = _tile_layer_option.selected - TILE_TARGET_LAYER_INDEX_OFFSET
	if node_index < 0 or node_index >= _tile_layer_nodes.size():
		return null
	var node = _tile_layer_nodes[node_index]
	return node if is_instance_valid(node) else null


func _publish_session_target(reason: String) -> void:
	if _editor_session_state == null:
		return
	var layer = selected_tile_map_layer()
	if layer == null:
		layer = _find_editor_selected_tile_map_layer()
	_editor_session_state.set_target_layer(layer, reason)


func generation_status() -> Dictionary:
	return {
		"running": _generation_running,
		"cancel_requested": _is_generation_cancel_requested(),
		"progress": _generation_progress,
		"status": _generation_status,
	}


func generation_validation_summary() -> Dictionary:
	if _last_generation_validation_summary.is_empty():
		return _validation_summary_from_result(null)
	return _last_generation_validation_summary.duplicate(true)


func generation_validation_result():
	return _last_generation_validation_result


func validate_generation_document(document, options: Dictionary = {}):
	var result = HexMapDocumentValidator.validate_document(document, options)
	_capture_generation_validation_result(result, document != null)
	return result


func run_generation_batch(seed_count: int, options: Dictionary = {}) -> Array[Dictionary]:
	var seeds = _batch_seed_list(seed_count, options)
	_last_batch_generation_results.clear()
	if seeds.is_empty():
		return []

	var base_snapshot = options.get("snapshot", {})
	if not base_snapshot is Dictionary or (base_snapshot as Dictionary).is_empty():
		base_snapshot = _create_generation_snapshot()
	else:
		base_snapshot = (base_snapshot as Dictionary).duplicate(true)

	var rows: Array[Dictionary] = []
	for index in range(seeds.size()):
		var snapshot: Dictionary = (base_snapshot as Dictionary).duplicate(true)
		snapshot["seed"] = int(seeds[index])
		snapshot["generation_id"] = int(snapshot.get("generation_id", _generation_id)) + index
		var block_reason = _generation_block_reason_for_snapshot(snapshot)
		if block_reason != "":
			rows.append(_batch_blocked_row(index, snapshot, block_reason))
			continue
		var data = _generate_data_from_snapshot(snapshot, {})
		rows.append(_batch_result_row(index, snapshot, data, options))

	_last_batch_generation_results = _duplicate_batch_rows(rows)
	return generation_batch_results()


func generation_batch_results() -> Array[Dictionary]:
	return _duplicate_batch_rows(_last_batch_generation_results)


func generation_batch_score_table(sort_key: String = "score", descending: bool = true) -> Array[Dictionary]:
	var rows = generation_batch_results()
	for left_index in range(rows.size()):
		var best_index = left_index
		for right_index in range(left_index + 1, rows.size()):
			if _batch_row_sorts_before(rows[right_index], rows[best_index], sort_key, descending):
				best_index = right_index
		if best_index != left_index:
			var temp = rows[left_index]
			rows[left_index] = rows[best_index]
			rows[best_index] = temp
	for index in range(rows.size()):
		rows[index]["rank"] = index + 1
	return rows


func promoted_generation_document():
	return _last_promoted_generation_document


func promote_generation_batch_row(row: Dictionary, options: Dictionary = {}):
	if row.is_empty():
		return null
	var promote_options = options.duplicate(true)
	if row.has("snapshot") and row["snapshot"] is Dictionary:
		promote_options["snapshot"] = (row["snapshot"] as Dictionary).duplicate(true)
	promote_options["score_row"] = row.duplicate(true)
	return promote_generation_seed_to_document(int(row.get("seed", 0)), promote_options)


func promote_generation_seed_to_document(seed: int, options: Dictionary = {}):
	var snapshot = _promotion_snapshot_for_seed(seed, options)
	var block_reason = _generation_block_reason_for_snapshot(snapshot)
	if block_reason != "":
		push_warning(block_reason)
		return null
	var data = _generate_data_from_snapshot(snapshot, {})
	if data == null:
		return null
	var overlay_mode = bool(snapshot.get("overlay_mode", false))
	var document = _generated_document_snapshot_for_data(
		_current_data if overlay_mode else data,
		data if overlay_mode else null
	)
	if document == null:
		return null
	var validation_result = HexMapDocumentValidator.validate_document(document)
	var validation_summary = _batch_validation_summary(validation_result, true)
	_attach_generation_metadata(document, snapshot, seed, validation_summary, options)
	_last_promoted_generation_document = document
	return document


func debug_report_text() -> String:
	var lines := PackedStringArray()
	lines.append("Hex Map Generate Debug Report")
	lines.append("generation_status: %s" % var_to_str(generation_status()))
	lines.append("validation_summary: %s" % var_to_str(validation_debug_summary()))
	return _join_lines(lines)


func validation_debug_summary() -> Dictionary:
	if _last_generation_validation_result != null:
		return generation_validation_summary()
	return _validation_summary_from_result(_validation_result_for_report())


func _validation_result_for_report():
	if _current_data == null:
		return null
	var document = _generated_document_snapshot()
	return HexMapDocumentValidator.validate_document(document)


func _validation_summary_from_result(result, generated_map_present: bool = false) -> Dictionary:
	if result == null:
		return {
			"generated_map_present": generated_map_present,
			"validated": false,
			"passed": false,
			"capture_order": _last_generation_validation_capture_order,
			"apply_order": _last_generation_apply_order,
			"issues": 0,
			"errors": 0,
			"warnings": 0,
			"infos": 0,
		}
	var error_count = result.error_count() if result.has_method("error_count") else 0
	return {
		"generated_map_present": true,
		"validated": true,
		"passed": error_count == 0,
		"capture_order": _last_generation_validation_capture_order,
		"apply_order": _last_generation_apply_order,
		"issues": result.issue_count() if result.has_method("issue_count") else 0,
		"errors": error_count,
		"warnings": result.warning_count() if result.has_method("warning_count") else 0,
		"infos": result.info_count() if result.has_method("info_count") else 0,
	}


func _capture_generation_validation_result(result, generated_map_present: bool) -> void:
	_last_generation_validation_capture_order = _next_generation_event_order()
	_last_generation_validation_result = result
	_last_generation_validation_summary = _validation_summary_from_result(
		result,
		generated_map_present
	)


func _next_generation_event_order() -> int:
	_generation_event_order += 1
	return _generation_event_order


func _validate_current_generation_result() -> bool:
	var document = _generated_document_snapshot()
	if document == null:
		_capture_generation_validation_result(null, false)
		return false
	validate_generation_document(document)
	return bool(_last_generation_validation_summary.get("passed", false))


func _generated_document_snapshot():
	_current_orientation = _tile_settings_orientation()
	return _generated_document_snapshot_for_data(_current_data, _current_overlay_data)


func _generated_document_snapshot_for_data(primary_data, overlay_data):
	_current_orientation = _tile_settings_orientation()
	var data = primary_data
	if data == null and overlay_data != null:
		data = HexMapData.from_cells(overlay_data.occupied_cells())
	if data == null:
		return null
	var resource = HexMapResource.from_map_data(data, _current_orientation)
	var document = HexMapDocumentAdapter.from_map_resource(resource)
	document.ensure_v2_defaults()
	_ensure_generated_document_terrain_layer(document, data)
	if overlay_data != null:
		for item_key in overlay_data.item_keys():
			for cell in overlay_data.item_cells(item_key):
				HexMapDocumentAdapter.set_tile_override(document, cell, {
					"kind": HexMapDocumentAdapter.KIND_OVERLAY,
					"item_key": item_key,
				})
	return document


func _ensure_generated_document_terrain_layer(document, data) -> void:
	if document == null or data == null:
		return
	for layer in document.terrain_layers:
		if layer != null and layer.get("map") != null:
			return
	var terrain_layer = HexMapDocumentTerrainLayerResource.new()
	terrain_layer.map = HexMapResource.from_map_data(data, _current_orientation)
	document.terrain_layers.append(terrain_layer)


func _batch_seed_list(seed_count: int, options: Dictionary) -> Array[int]:
	var explicit_seeds = options.get("seeds", [])
	var result: Array[int] = []
	if explicit_seeds is Array and not explicit_seeds.is_empty():
		for seed in explicit_seeds:
			result.append(int(seed))
		return result
	var count = max(0, seed_count)
	var start_seed = int(options.get("start_seed", int(_seed_spin.value)))
	for offset in range(count):
		result.append(start_seed + offset)
	return result


func _batch_blocked_row(index: int, snapshot: Dictionary, block_reason: String) -> Dictionary:
	return {
		"index": index,
		"seed": int(snapshot.get("seed", 0)),
		"status": "blocked",
		"block_reason": block_reason,
		"overlay_mode": bool(snapshot.get("overlay_mode", false)),
		"snapshot": snapshot.duplicate(true),
		"generation_snapshot": _metadata_generation_snapshot(snapshot),
		"score": -100000.0,
		"validation_summary": _batch_validation_summary(null, false),
		"validation_errors": 0,
		"validation_warnings": 0,
	}


func _batch_result_row(index: int, snapshot: Dictionary, data, options: Dictionary) -> Dictionary:
	var overlay_mode = bool(snapshot.get("overlay_mode", false))
	var document = _generated_document_snapshot_for_data(_current_data if overlay_mode else data, data if overlay_mode else null)
	var validation_result = HexMapDocumentValidator.validate_document(document)
	var validation_summary = _batch_validation_summary(validation_result, document != null)
	var row: Dictionary = {
		"index": index,
		"seed": int(snapshot.get("seed", 0)),
		"status": "generated" if data != null else "failed",
		"overlay_mode": overlay_mode,
		"snapshot": snapshot.duplicate(true),
		"generation_snapshot": _metadata_generation_snapshot(snapshot),
		"validation_summary": validation_summary,
		"validation_errors": int(validation_summary.get("errors", 0)),
		"validation_warnings": int(validation_summary.get("warnings", 0)),
	}
	if data == null:
		row["score"] = -100000.0
		return row
	if overlay_mode:
		row["cells"] = data.cells.size()
		row["occupied"] = data.occupied_cells().size()
		row["item_counts"] = _overlay_item_counts(data)
	else:
		var floors = data.floor_cells().size()
		var walls = data.walls.size()
		var cells = data.cells.size()
		row["cells"] = cells
		row["walls"] = walls
		row["floors"] = floors
		row["wall_ratio"] = float(walls) / float(cells) if cells > 0 else 0.0
		row["connected"] = HexMapGenerator.is_floor_connected(data)
	row["score"] = _batch_score(row, options)
	return row


func _batch_validation_summary(result, generated_map_present: bool) -> Dictionary:
	if result == null:
		return {
			"generated_map_present": generated_map_present,
			"validated": false,
			"passed": false,
			"issues": 0,
			"errors": 0,
			"warnings": 0,
			"infos": 0,
		}
	var error_count = result.error_count() if result.has_method("error_count") else 0
	return {
		"generated_map_present": generated_map_present,
		"validated": true,
		"passed": error_count == 0,
		"issues": result.issue_count() if result.has_method("issue_count") else 0,
		"errors": error_count,
		"warnings": result.warning_count() if result.has_method("warning_count") else 0,
		"infos": result.info_count() if result.has_method("info_count") else 0,
	}


func _batch_score(row: Dictionary, options: Dictionary) -> float:
	var score = float(options.get("base_score", 1000.0))
	score -= float(row.get("validation_errors", 0)) * 100.0
	score -= float(row.get("validation_warnings", 0)) * 10.0
	if bool(row.get("overlay_mode", false)):
		score += float(row.get("occupied", 0))
	else:
		score += float(row.get("floors", 0))
		score += 100.0 if bool(row.get("connected", false)) else -100.0
		var target_wall_ratio = float(options.get("target_wall_ratio", 0.35))
		score -= abs(float(row.get("wall_ratio", 0.0)) - target_wall_ratio) * 100.0
	return score


func _overlay_item_counts(data) -> Dictionary:
	var result := {}
	if data == null:
		return result
	for item_key in data.item_keys():
		result[item_key] = data.item_cells(item_key).size()
	return result


func _duplicate_batch_rows(rows: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row in rows:
		result.append(row.duplicate(true))
	return result


func _batch_row_sorts_before(left: Dictionary, right: Dictionary, sort_key: String, descending: bool) -> bool:
	var comparison = _compare_batch_values(left.get(sort_key, null), right.get(sort_key, null))
	if comparison == 0:
		return int(left.get("seed", 0)) < int(right.get("seed", 0))
	return comparison > 0 if descending else comparison < 0


func _compare_batch_values(left, right) -> int:
	if left == right:
		return 0
	if _is_batch_numeric_value(left) and _is_batch_numeric_value(right):
		var left_float = float(left)
		var right_float = float(right)
		if left_float < right_float:
			return -1
		if left_float > right_float:
			return 1
		return 0
	var left_text = String(left)
	var right_text = String(right)
	if left_text < right_text:
		return -1
	if left_text > right_text:
		return 1
	return 0


func _is_batch_numeric_value(value) -> bool:
	var value_type = typeof(value)
	return value_type == TYPE_INT or value_type == TYPE_FLOAT or value_type == TYPE_BOOL


func _promotion_snapshot_for_seed(seed: int, options: Dictionary) -> Dictionary:
	var snapshot = options.get("snapshot", {})
	if snapshot is Dictionary and not (snapshot as Dictionary).is_empty():
		snapshot = (snapshot as Dictionary).duplicate(true)
	else:
		snapshot = _create_generation_snapshot()
	snapshot["seed"] = seed
	return snapshot


func _attach_generation_metadata(
	document,
	snapshot: Dictionary,
	seed: int,
	validation_summary: Dictionary,
	options: Dictionary
) -> void:
	document.ensure_v2_defaults()
	document.metadata.generation_seed = seed
	document.metadata.generation_snapshot = _metadata_generation_snapshot(snapshot)
	document.metadata.custom_properties["generation_source"] = "hex_map_gen_dock"
	document.metadata.custom_properties["generation_validation_summary"] = validation_summary.duplicate(true)
	var score_row = options.get("score_row", {})
	if score_row is Dictionary:
		document.metadata.custom_properties["generation_score"] = float((score_row as Dictionary).get("score", 0.0))
		document.metadata.custom_properties["generation_batch_index"] = int((score_row as Dictionary).get("index", -1))


func _metadata_generation_snapshot(snapshot: Dictionary) -> Dictionary:
	var result = snapshot.duplicate(true)
	var custom_distribution = result.get("custom_distribution", null)
	result.erase("custom_distribution")
	if custom_distribution is Resource:
		var distribution_resource = custom_distribution as Resource
		result["custom_distribution_path"] = distribution_resource.resource_path
		result["custom_distribution_class"] = distribution_resource.get_class()
	result.erase("generation_id")
	result.erase("chunk_size")
	result.erase("progress_delay_usec")
	return result


func _join_lines(lines: PackedStringArray) -> String:
	var result := ""
	for index in range(lines.size()):
		if index > 0:
			result += "\n"
		result += lines[index]
	return result


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
	if layer is HexTileMapLayer:
		return _apply_current_data_to_hex_tile_map_layer(layer as HexTileMapLayer)
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
		_apply_write_clears_layer(),
		flat_top
	)
	return true


func _apply_current_data_to_hex_tile_map_layer(layer: HexTileMapLayer) -> bool:
	if layer == null:
		return false
	var flat_top := _tile_settings_flat_top()
	var tile_size := _tile_settings_tile_size()
	var floor_source := int(_floor_source_spin.value)
	var floor_atlas := Vector2i(int(_floor_atlas_x_spin.value), int(_floor_atlas_y_spin.value))
	var wall_source := int(_wall_source_spin.value)
	var wall_atlas := Vector2i(int(_wall_atlas_x_spin.value), int(_wall_atlas_y_spin.value))
	layer.flat_top = flat_top
	var texture := HexMapTileAdapter.load_sample_tile_texture()
	if _current_atlas_image_path != "":
		texture = HexMapTileAdapter.load_tile_texture(_current_atlas_image_path)
	var ok = layer.configure_display_tiles_from_texture(
		texture,
		floor_source,
		wall_source,
		tile_size,
		floor_atlas,
		wall_atlas
	)
	if not ok:
		ok = layer.ensure_display_tiles(
			tile_size,
			floor_source,
			floor_atlas,
			wall_source,
			wall_atlas
		)
	if not ok:
		return false
	layer.hex_map = HexMapResource.from_map_data(_current_data, _current_orientation)
	layer.refresh_loop_display()
	return true


func _apply_write_clears_layer() -> bool:
	return _apply_write_policy() == HexOverlayData.APPLY_CLEAR_AND_WRITE


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
	if not (layer is TileMapLayer or layer is HexTileMapLayer):
		return false

	_current_orientation = _tile_settings_orientation()
	var texture := HexMapTileAdapter.load_tile_texture(atlas_path)
	var ok := false
	if layer is HexTileMapLayer:
		var hex_layer := layer as HexTileMapLayer
		hex_layer.flat_top = _tile_settings_flat_top()
		ok = hex_layer.configure_display_tiles_from_texture(
			texture,
			source_id,
			source_id,
			tile_size,
			floor_atlas_coords,
			wall_atlas_coords
		)
	else:
		_ensure_unique_tile_set_for_layer(layer)
		ok = HexMapTileAdapter.configure_atlas_tile_set(
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


func _resource_for_save_button() -> Resource:
	if not _overlay_mode_enabled():
		return current_resource()
	if _overlay_mask_crop_enabled():
		return HexOverlayResource.from_overlay_data(_overlay_crop_result_data(), _tile_settings_orientation())
	if not _apply_overlay_source_stack_to_current():
		return null
	return current_resource()


func _save_generate_history_data(data, overlay_mode: bool, result: Dictionary) -> void:
	if not _generate_history_enabled():
		return
	var resource: Resource
	if overlay_mode:
		resource = HexOverlayResource.from_overlay_data(data, _tile_settings_orientation())
	else:
		resource = HexMapResource.from_map_data(data, _tile_settings_orientation())
	var path = _unique_history_resource_path(
		String(result.get("history_condition_name", "generation")),
		String(result.get("history_item_name", "map"))
	)
	if path == "":
		return
	var error = ResourceSaver.save(resource, path)
	if error == OK:
		register_mapdata_source(resource, path)
		if Engine.is_editor_hint():
			EditorInterface.get_resource_filesystem().scan()
	else:
		push_error("Failed to save generate history: %d" % error)


func _generate_history_enabled() -> bool:
	return _generate_history_check != null \
		and _generate_history_check.button_pressed \
		and _generate_history_dir != ""


func _unique_history_resource_path(condition_name: String, item_name: String) -> String:
	if _generate_history_dir == "":
		return ""
	_ensure_directory_exists(_generate_history_dir)
	var stem = "%s-%s-%s" % [
		_history_timestamp(),
		_safe_filename_part(condition_name),
		_safe_filename_part(item_name),
	]
	var base_path = _join_resource_path(_generate_history_dir, "%s.tres" % stem)
	if not FileAccess.file_exists(base_path):
		return base_path
	var suffix := 2
	while FileAccess.file_exists(_join_resource_path(_generate_history_dir, "%s-%d.tres" % [stem, suffix])):
		suffix += 1
	return _join_resource_path(_generate_history_dir, "%s-%d.tres" % [stem, suffix])


func _history_timestamp() -> String:
	var dt = Time.get_datetime_dict_from_system()
	return "%04d%02d%02d-%02d%02d%02d" % [
		int(dt["year"]),
		int(dt["month"]),
		int(dt["day"]),
		int(dt["hour"]),
		int(dt["minute"]),
		int(dt["second"]),
	]


func _history_condition_name(snapshot: Dictionary) -> String:
	var prefix = "overlay" if bool(snapshot.get("overlay_mode", false)) else "primary"
	var method = "markov" if bool(snapshot.get("symmetric", false)) else "uniform"
	if bool(snapshot.get("overlay_item_limit_enabled", false)):
		method = "combination"
	if bool(snapshot.get("overlay_adjacency_enabled", false)):
		method = "adjacency"
	return "%s-%s" % [prefix, method]


func _history_item_name(snapshot: Dictionary) -> String:
	if bool(snapshot.get("overlay_mode", false)):
		if bool(snapshot.get("overlay_item_limit_enabled", false)):
			var names: Array = []
			for item in snapshot.get("overlay_item_pool", []):
				names.append(String(item.get("name", "item")))
			return "-".join(names) if not names.is_empty() else "overlay"
		return String(snapshot.get("overlay_item_name", "overlay"))
	return "map"


func _safe_filename_part(value: String) -> String:
	var result := ""
	for index in range(value.length()):
		var code = value.unicode_at(index)
		if (code >= 48 and code <= 57) \
			or (code >= 65 and code <= 90) \
			or (code >= 97 and code <= 122):
			result += char(code).to_lower()
		elif code == 45 or code == 95:
			result += char(code)
		else:
			result += "-"
	result = result.strip_edges()
	return "item" if result == "" else result


func _join_resource_path(directory: String, filename: String) -> String:
	return "%s/%s" % [directory.trim_suffix("/"), filename]


func _ensure_directory_exists(directory: String) -> void:
	if directory.begins_with("res://") or directory.begins_with("user://"):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	else:
		DirAccess.make_dir_recursive_absolute(directory)


func _set_generate_history_directory_for_test(path: String) -> void:
	_generate_history_dir = path
	if _generate_history_check != null:
		_generate_history_check.set_pressed_no_signal(path != "")
	_refresh_generate_history_label()


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
	var candidates: Array[Node] = []
	_collect_tile_map_layers_recursive(root, candidates)
	return _preferred_tile_layer_from_candidates(candidates)


func _find_editor_selected_tile_map_layer():
	if _test_selected_tile_map_layer != null and is_instance_valid(_test_selected_tile_map_layer):
		return _test_selected_tile_map_layer
	if not Engine.is_editor_hint():
		return null

	var selection = EditorInterface.get_selection()
	var selected = selection.get_selected_nodes()
	for node in selected:
		var target = _tile_layer_target_from_node(node)
		if target != null:
			return target
	return null


func _set_editor_selected_tile_map_layer_for_test(layer: Node) -> void:
	_test_selected_tile_map_layer = layer
	_publish_session_target("generate.test_editor_selected_target")


func add_new_tile_map_layer(root_node: Node = null):
	var root = root_node
	if root == null:
		root = _tile_layer_scan_root
	if (root == null or not is_instance_valid(root)) and Engine.is_editor_hint():
		root = EditorInterface.get_edited_scene_root()
	if root == null:
		push_error("No edited scene root found. Open a scene first.")
		return null

	var layer = HexTileMapLayer.new()
	layer.name = _unique_tile_layer_name(root, NEW_TILE_LAYER_BASE_NAME)
	if Engine.is_editor_hint():
		var undo_redo = EditorInterface.get_editor_undo_redo()
		undo_redo.create_action("Add HexTileMapLayer")
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
	_publish_session_target("generate.select_tile_layer_target")


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
	var candidates: Array[Node] = []
	_collect_tile_map_layers_recursive(node, candidates)
	return _preferred_tile_layer_from_candidates(candidates)


func _collect_tile_map_layers_recursive(node: Node, result: Array[Node]) -> void:
	if node is HexTileMapLayer:
		result.append(node)
		return
	if node is TileMapLayer:
		result.append(node)
	for child in node.get_children():
		_collect_tile_map_layers_recursive(child, result)


func _tile_layer_target_from_node(node):
	if node == null or not is_instance_valid(node):
		return null
	if node is HexTileMapLayer:
		return node
	if node is TileMapLayer:
		var parent = node.get_parent()
		if parent is HexTileMapLayer:
			return parent
		return node
	return null


func _preferred_tile_layer_from_candidates(candidates: Array):
	if candidates.is_empty():
		return null
	if _overlay_mode_enabled():
		for node in candidates:
			if node is TileMapLayer and not (node is HexTileMapLayer):
				return node
		return candidates[0]
	for node in candidates:
		if node is HexTileMapLayer:
			return node
	return candidates[0]


func _prioritized_tile_layer_nodes(nodes: Array[Node]) -> Array[Node]:
	var hex_layers: Array[Node] = []
	var other_layers: Array[Node] = []
	for node in nodes:
		if node is HexTileMapLayer:
			hex_layers.append(node)
		else:
			other_layers.append(node)
	return hex_layers + other_layers


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
		return "%s%s" % [node_name, _tile_layer_class_suffix(node)]
	if root_node != null and is_instance_valid(root_node) and _is_ancestor_of(root_node, node):
		return "%s%s" % [String(root_node.get_path_to(node)), _tile_layer_class_suffix(node)]
	return "%s%s" % [node.name, _tile_layer_class_suffix(node)]


func _tile_layer_class_suffix(node: Node) -> String:
	if node is HexTileMapLayer:
		return " (HexTileMapLayer)"
	return ""


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
	var control_state = HexMapGenStateEvaluator.evaluate_control_state({
		"symmetric": _uses_symmetric_generation(),
		"overlay": _overlay_mode_enabled(),
		"generation_running": _generation_running,
		"overlay_adjacency_enabled": _overlay_adjacency_enabled(),
		"overlay_item_limit_enabled": _overlay_item_limit_check != null and _overlay_item_limit_check.button_pressed,
		"simple_shape": _shape_option_simple.selected if _shape_option_simple != null else SHAPE_HEXAGON,
		"shape_rectangle": SHAPE_RECTANGLE,
		"shape_hexagon": SHAPE_HEXAGON,
	})
	_shape_symmetric_row.visible = bool(control_state["shape_symmetric_row_visible"])
	_shape_simple_row.visible = bool(control_state["shape_simple_row_visible"])
	_rect_row.visible = bool(control_state["rect_row_visible"])
	_hex_row.visible = bool(control_state["hex_row_visible"])
	_radius_row.visible = bool(control_state["radius_row_visible"])
	_sym_options_container.visible = bool(control_state["sym_options_visible"])
	_prob_bar_label.text = String(control_state["probability_label"])
	if _torus_connectivity_check != null:
		_torus_connectivity_check.visible = bool(control_state["torus_connectivity_visible"])
		_torus_connectivity_check.disabled = bool(control_state["torus_connectivity_disabled"])
	if _overlay_controls_container != null:
		_overlay_controls_container.visible = bool(control_state["overlay_controls_visible"])
	if _generate_button != null:
		_generate_button.text = String(control_state["generate_button_text"])
	if _deductor_label != null:
		_deductor_label.text = String(control_state["deductor_label_text"])
	if _generator_label != null:
		_generator_label.text = String(control_state["generator_label_text"])
	if _overlay_adjacency_check != null:
		_overlay_adjacency_check.visible = bool(control_state["overlay_adjacency_visible"])
		_overlay_adjacency_check.disabled = bool(control_state["overlay_adjacency_disabled"])
	if _overlay_item_limit_check != null:
		_overlay_item_limit_check.visible = bool(control_state["overlay_item_limit_visible"])
		_overlay_item_limit_check.disabled = bool(control_state["overlay_item_limit_disabled"])
	if _overlay_item_limit_spin != null:
		_overlay_item_limit_spin.visible = bool(control_state["overlay_item_limit_spin_visible"])
	if _overlay_item_name_edit != null:
		var item_name_row = _overlay_item_name_edit.get_parent()
		if item_name_row is Control:
			item_name_row.visible = bool(control_state["overlay_item_name_row_visible"])
	if _overlay_item_pool_container != null:
		_overlay_item_pool_container.visible = bool(control_state["overlay_item_pool_visible"])
	if _overlay_add_item_button != null:
		_overlay_add_item_button.visible = bool(control_state["overlay_add_item_visible"])
	if _overlay_mask_container != null:
		_overlay_mask_container.visible = bool(control_state["overlay_mask_visible"])
	if _overlay_deductor_floor_container != null:
		_overlay_deductor_floor_container.visible = bool(control_state["overlay_deductor_floor_visible"])
	if _overlay_reference_container != null:
		_overlay_reference_container.visible = bool(control_state["overlay_reference_visible"])
	if _wall_prob_row != null:
		_wall_prob_row.visible = bool(control_state["wall_probability_row_visible"])
	_refresh_overlay_item_pool_rows()
	_refresh_adjacency_rules_status()
	_refresh_generation_block_state()


func _uses_symmetric_generation() -> bool:
	return _generate_option.selected == GENERATE_SYMMETRIC


func _current_generation_block_reason() -> String:
	var mask_query_enabled = _query_rows_enabled(QUERY_KIND_MASK)
	var mask_candidate_count = 1
	if mask_query_enabled:
		mask_candidate_count = _evaluate_query_rows(QUERY_KIND_MASK).size()
	var adjacency_rule_count = 1
	if _overlay_adjacency_enabled():
		var text = _overlay_adjacency_rules_edit.text if _overlay_adjacency_rules_edit != null else ""
		var rules: Dictionary = HexAdjacencyRuleSet.parse_rules_text(text)
		adjacency_rule_count = rules.size()
	return HexMapGenStateEvaluator.generation_block_reason(
		{
			"generation_running": _generation_running,
			"overlay_mode": _overlay_mode_enabled(),
			"mask_query_enabled": mask_query_enabled,
			"mask_candidate_count": mask_candidate_count,
			"overlay_adjacency_enabled": _overlay_adjacency_enabled(),
			"adjacency_rule_count": adjacency_rule_count,
		},
		GENERATION_BLOCK_EMPTY_MASK,
		GENERATION_BLOCK_EMPTY_ADJACENCY_RULES
	)


func _generation_block_reason_for_snapshot(snapshot: Dictionary) -> String:
	var candidates: Array = snapshot.get("overlay_candidate_cells", [])
	var rules: Dictionary = snapshot.get("overlay_adjacency_rules", {})
	return HexMapGenStateEvaluator.generation_block_reason(
		{
			"overlay_mode": bool(snapshot.get("overlay_mode", false)),
			"mask_query_enabled": bool(snapshot.get("overlay_mask_query_enabled", false)),
			"mask_candidate_count": candidates.size(),
			"overlay_adjacency_enabled": bool(snapshot.get("overlay_adjacency_enabled", false)),
			"adjacency_rule_count": rules.size(),
		},
		GENERATION_BLOCK_EMPTY_MASK,
		GENERATION_BLOCK_EMPTY_ADJACENCY_RULES
	)


func _generation_block_status(reason: String) -> String:
	return "%s%s" % [GENERATION_BLOCK_STATUS_PREFIX, reason]


func _is_generation_block_status(status: String) -> bool:
	return status.begins_with(GENERATION_BLOCK_STATUS_PREFIX)


func _refresh_generation_block_state() -> void:
	if _generate_button == null:
		return
	if _generation_running:
		_generate_button.disabled = true
		return
	var reason = _current_generation_block_reason()
	_generate_button.disabled = reason != ""
	_generate_button.tooltip_text = reason
	if reason != "":
		_set_generation_progress(0.0, _generation_block_status(reason))
	elif _is_generation_block_status(_generation_status):
		_set_generation_progress(0.0, "Ready")


func _generate_map(show_progress: bool = false) -> bool:
	if _generation_running:
		return false
	var snapshot = _create_generation_snapshot()
	var block_reason = _generation_block_reason_for_snapshot(snapshot)
	if block_reason != "":
		_set_generation_progress(0.0, _generation_block_status(block_reason))
		push_warning(block_reason)
		_refresh_generation_block_state()
		return false
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

	_validate_current_generation_result()
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
		"apply_write_policy": _apply_write_policy(),
		"overlay_existing_policy": _overlay_existing_policy(),
		"overlay_adjacency_enabled": _overlay_adjacency_enabled(),
		"overlay_neighbor_radius": _overlay_neighbor_radius(),
		"overlay_adjacency_rules": _overlay_adjacency_rules(),
	}
	if bool(snapshot["overlay_mode"]):
		snapshot["overlay_shape_universe"] = _overlay_shape_universe()
		snapshot["overlay_mask_query_enabled"] = _query_rows_enabled(QUERY_KIND_MASK)
		snapshot["overlay_deductor_floor_source_enabled"] = _query_rows_enabled(QUERY_KIND_DEDUCTOR_FLOOR)
		snapshot["overlay_candidate_cells"] = _overlay_mask_cells_for_snapshot(snapshot)
		snapshot["overlay_deductor_floor_cells"] = _overlay_deductor_floor_cells_for_snapshot(
			snapshot["overlay_candidate_cells"]
		)
		snapshot["overlay_reference_cells"] = _overlay_reference_cells_for_snapshot()
		snapshot["overlay_generated_reference_enabled"] = _overlay_generated_reference_enabled()
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
		"apply_write_policy": String(snapshot.get(
			"apply_write_policy",
			HexOverlayData.APPLY_CLEAR_AND_WRITE
		)),
		"overlay_existing_policy": String(snapshot.get(
			"overlay_existing_policy",
			HexOverlayData.EXISTING_MERGE
		)),
		"history_condition_name": _history_condition_name(snapshot),
		"history_item_name": _history_item_name(snapshot),
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


func _query_rows_enabled(mask_query) -> bool:
	return not _query_rows_for_kind(_query_kind_from_value(mask_query)).is_empty()


func _evaluate_query_rows(query_kind) -> Array:
	var rows = _query_rows_for_kind(query_kind)
	if rows.is_empty():
		if query_kind == QUERY_KIND_MASK:
			return _overlay_shape_universe()  # Any predicate: 全 cell 通過
		return []
	var universe = _overlay_shape_universe()
	var result: Array = []
	for index in range(rows.size()):
		var row = rows[index]
		var row_cells = _query_row_contain_cells_in_universe(row, universe)
		var match_value = _query_row_match(row)
		if match_value == QUERY_ROW_MATCH_EXCLUDE:
			row_cells = HexMapData.points_except(universe, row_cells)
		var operation_value = _query_row_operation(row)
		if index == 0:
			result = row_cells
		elif operation_value == QUERY_ROW_OPERATION_AND:
			result = _intersect_points(result, row_cells)
		else:
			result = HexMapData.unique_points(result + row_cells)
	return result


func _offset_points(points: Array, offset, cyclic_size: int = 0) -> Array:
	var result: Array = []
	for point in points:
		var moved = point.add(offset)
		if cyclic_size > 0:
			moved = HexToricCoordinate.wrap_vector(moved, cyclic_size)
		result.append(moved)
	return HexMapData.unique_points(result)


func _query_row_contain_cells_in_universe(row: Dictionary, universe: Array) -> Array:
	var entry = _source_entry_by_id(int(row.get("source_id", -1)))
	if entry.is_empty():
		return []
	var data = entry.get("data", null)
	if data == null:
		return []
	var item_cells = data.item_cells(String(row.get("item_key", "")))
	var offset = row.get("offset", HexVector.zero())
	var cyclic_size = int(data.cyclic_size)
	if cyclic_size <= 0:
		var offset_cells = _offset_points(item_cells, offset, 0)
		return HexMapData.filter_points(offset_cells, HexMapData.make_set(universe))

	var wrapped_map := {}
	for u_cell in universe:
		var wk = HexToricCoordinate.wrap_vector(u_cell, cyclic_size).key()
		if not wrapped_map.has(wk):
			wrapped_map[wk] = []
		wrapped_map[wk].append(u_cell)

	var result: Array = []
	var seen := {}
	for item_cell in item_cells:
		var offset_cell = item_cell.add(offset)
		var wk = HexToricCoordinate.wrap_vector(offset_cell, cyclic_size).key()
		if wrapped_map.has(wk):
			for u_cell in wrapped_map[wk]:
				if not seen.has(u_cell.key()):
					seen[u_cell.key()] = true
					result.append(u_cell)
	return result


func _intersect_points(left: Array, right: Array) -> Array:
	var right_set = HexMapData.make_set(right)
	var result: Array = []
	for point in left:
		if right_set.has(point.key()):
			result.append(point)
	return result


func _query_row_operation(row: Dictionary) -> String:
	var option: OptionButton = row.get("operation", null)
	if option == null:
		return QUERY_ROW_OPERATION_OR
	return QUERY_ROW_OPERATIONS[clampi(option.selected, 0, QUERY_ROW_OPERATIONS.size() - 1)]


func _query_row_match(row: Dictionary) -> String:
	var option: OptionButton = row.get("match", null)
	if option == null:
		return QUERY_ROW_MATCH_CONTAIN
	return QUERY_ROW_MATCHES[clampi(option.selected, 0, QUERY_ROW_MATCHES.size() - 1)]


func _overlay_mask_cells_for_snapshot(snapshot: Dictionary) -> Array:
	var query_cells = _evaluate_query_rows(QUERY_KIND_MASK)
	if _query_rows_enabled(QUERY_KIND_MASK) and query_cells.is_empty():
		push_warning(GENERATION_BLOCK_EMPTY_MASK)
	return query_cells


func _overlay_deductor_floor_cells_for_snapshot(default_floor_cells: Array) -> Array:
	if not _query_rows_enabled(QUERY_KIND_DEDUCTOR_FLOOR):
		_set_deductor_floor_status("Default: generated complement")
		return []
	var cells = _evaluate_query_rows(QUERY_KIND_DEDUCTOR_FLOOR)
	if cells.is_empty():
		var message = "Deductor Floor Source query result is empty."
		_set_deductor_floor_status(message)
		push_warning(message)
	else:
		_set_deductor_floor_status("Deductor floor cells: %d" % cells.size())
	return cells


func _refresh_deductor_floor_status() -> void:
	if not _query_rows_enabled(QUERY_KIND_DEDUCTOR_FLOOR):
		_set_deductor_floor_status("Default: generated complement")
		return
	var cells = _evaluate_query_rows(QUERY_KIND_DEDUCTOR_FLOOR)
	_set_deductor_floor_status("Deductor floor cells: %d" % cells.size())


func _set_deductor_floor_status(text: String) -> void:
	if _overlay_deductor_floor_status_label != null:
		_overlay_deductor_floor_status_label.text = text


func _overlay_reference_cells_for_snapshot() -> Array:
	if _query_rows_enabled(QUERY_KIND_REFERENCE):
		return _evaluate_query_rows(QUERY_KIND_REFERENCE)
	return []


func _overlay_adjacency_enabled() -> bool:
	return _overlay_mode_enabled() \
		and _generate_option != null \
		and _generate_option.selected == GENERATE_SYMMETRIC \
		and _overlay_adjacency_check != null \
		and _overlay_adjacency_check.button_pressed


func _overlay_generated_reference_enabled() -> bool:
	return _overlay_adjacency_enabled() \
		and _overlay_generated_reference_check != null \
		and _overlay_generated_reference_check.button_pressed


func _overlay_neighbor_radius() -> int:
	if _overlay_neighbor_radius_spin == null:
		return 1
	return max(1, int(_overlay_neighbor_radius_spin.value))


func _overlay_adjacency_rules() -> Dictionary:
	var text = ""
	if _overlay_adjacency_rules_edit != null:
		text = _overlay_adjacency_rules_edit.text
	var report = HexAdjacencyRuleSet.parse_rules_text_report(text)
	if _overlay_adjacency_rules_status_label != null:
		_overlay_adjacency_rules_status_label.text = _adjacency_rule_status_text(report)
	return report["rules"]


func _apply_write_policy() -> String:
	if _apply_write_policy_option == null:
		return HexOverlayData.APPLY_CLEAR_AND_WRITE
	var index = clampi(_apply_write_policy_option.selected, 0, APPLY_WRITE_POLICIES.size() - 1)
	return APPLY_WRITE_POLICIES[index]


func _overlay_existing_policy() -> String:
	if _overlay_existing_policy_option == null:
		return HexOverlayData.EXISTING_MERGE
	var index = clampi(_overlay_existing_policy_option.selected, 0, OVERLAY_EXISTING_POLICIES.size() - 1)
	return OVERLAY_EXISTING_POLICIES[index]


func _overlay_cyclic_size_for_snapshot() -> int:
	if _uses_symmetric_generation() \
		and _shape_option_symmetric.selected == SHAPE_RECTANGLE \
		and _torus_connectivity_check != null \
		and _torus_connectivity_check.button_pressed:
		return int(_gen_radius_spin.value) * 2 + 1
	return 0


func _overlay_mask_crop_enabled() -> bool:
	return _overlay_mask_crop_check != null and _overlay_mask_crop_check.button_pressed


func _overlay_shape_universe() -> Array:
	var symmetric = _uses_symmetric_generation()
	var shape = _shape_option_symmetric.selected if symmetric else _shape_option_simple.selected
	return _shape_universe_from_values(
		symmetric,
		shape,
		int(_hex_radius_spin.value),
		int(_rect_width_spin.value),
		int(_rect_height_spin.value),
		int(_gen_radius_spin.value)
	)


func _shape_universe_for_snapshot(snapshot: Dictionary) -> Array:
	return _shape_universe_from_values(
		bool(snapshot.get("symmetric", false)),
		int(snapshot.get("shape", SHAPE_RECTANGLE)),
		int(snapshot.get("hex_radius", 1)),
		int(snapshot.get("rect_width", 1)),
		int(snapshot.get("rect_height", 1)),
		int(snapshot.get("generation_radius", 1))
	)


func _shape_universe_from_values(
	symmetric: bool,
	shape: int,
	hex_radius: int,
	rect_width: int,
	rect_height: int,
	generation_radius: int
) -> Array:
	if symmetric:
		var radius = generation_radius
		if shape == SHAPE_HEXAGON:
			return HexMapData.hexagon(radius).cells
		return HexMapData.square(radius * 2 + 1, false).cells
	match shape:
		SHAPE_HEXAGON:
			return HexMapData.hexagon(hex_radius).cells
		SHAPE_RECTANGLE:
			return HexMapData.rectangle(rect_width, rect_height).cells
		SHAPE_TORUS, _:
			var radius = generation_radius
			return HexMapData.square(radius * 2 + 1, false).cells


func _overlay_crop_cyclic_size() -> int:
	if _uses_symmetric_generation() \
		and _shape_option_symmetric.selected == SHAPE_RECTANGLE \
		and _torus_connectivity_check != null \
		and _torus_connectivity_check.button_pressed:
		return int(_gen_radius_spin.value) * 2 + 1
	return 0


func _reset_mask_crop_if_enabled() -> void:
	if _overlay_mask_crop_check != null and _overlay_mask_crop_check.button_pressed:
		_overlay_mask_crop_check.set_pressed_no_signal(false)


func _refresh_mask_crop_count() -> void:
	if _overlay_mask_count_label == null:
		return
	if not _overlay_mask_crop_enabled():
		_overlay_mask_count_label.text = "Cells: 0"
		return
	var crop_data = _overlay_crop_result_data()
	var seen := {}
	for item_key in crop_data.item_keys():
		if item_key == HexMapData.ITEM_ANY:
			continue
		for point in crop_data.item_cells(item_key):
			seen[point.key()] = true
	_overlay_mask_count_label.text = "Cells: %d" % seen.size()


func _overlay_crop_result_data():
	var universe = _overlay_shape_universe()
	var result_cells = _evaluate_query_rows(QUERY_KIND_MASK)
	var result_set = HexMapData.make_set(result_cells)
	var items := {}
	items[HexMapData.ITEM_ANY] = universe
	for row in _overlay_mask_query_rows:
		if _query_row_match(row) != QUERY_ROW_MATCH_CONTAIN:
			continue
		var item_key = _crop_result_item_key(row)
		var cells = _intersect_points(_query_row_contain_cells_in_universe(row, universe), result_cells)
		cells = HexMapData.filter_points(cells, result_set)
		if not cells.is_empty():
			if not items.has(item_key):
				items[item_key] = []
			items[item_key] = HexMapData.unique_points(items[item_key] + cells)
	return HexOverlayData.from_cells(universe, items, _overlay_crop_cyclic_size())


func _crop_result_item_key(row: Dictionary) -> String:
	var entry = _source_entry_by_id(int(row.get("source_id", -1)))
	var source_name = String(entry.get("display_name", "Source"))
	return "%s / %s" % [source_name, String(row.get("item_key", ""))]


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
			interrupt_options,
			bool(snapshot.get("overlay_generated_reference_enabled", false))
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
		var deductor_floor = snapshot.get("overlay_deductor_floor_cells", candidates)
		if not bool(snapshot.get("overlay_deductor_floor_source_enabled", false)):
			deductor_floor = HexMapData.points_except(
				snapshot.get("overlay_shape_universe", _shape_universe_for_snapshot(snapshot)),
				data.occupied_cells()
			)
		HexMapGenerator.deduct_items_for_connectivity(
			data,
			item_name,
			deductor_floor,
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
		_save_generate_history_data(data, bool(result.get("overlay_mode", false)), result)
		if bool(result.get("overlay_mode", false)):
			var write_policy = String(result.get(
				"apply_write_policy",
				HexOverlayData.APPLY_CLEAR_AND_WRITE
			))
			var existing_policy = String(result.get(
				"overlay_existing_policy",
				HexOverlayData.EXISTING_MERGE
			))
			_apply_overlay_data_to_current(data, write_policy, existing_policy)
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
	_last_generation_validation_result = null
	_last_generation_validation_summary = {}
	_generation_event_order = 0
	_last_generation_validation_capture_order = 0
	_last_generation_apply_order = 0
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
	_refresh_generation_block_state()
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
		_tile_orientation_option,
		_tile_width_spin,
		_tile_height_spin,
		_floor_catalog_option,
		_wall_catalog_option,
		_floor_source_spin,
		_floor_atlas_x_spin,
		_floor_atlas_y_spin,
		_wall_source_spin,
		_wall_atlas_x_spin,
		_wall_atlas_y_spin,
		_overlay_mode_check,
		_overlay_item_name_edit,
		_overlay_item_limit_check,
		_overlay_item_limit_spin,
		_overlay_add_item_button,
		_overlay_mask_add_source_option,
		_overlay_mask_add_button,
		_query_cell_radius_spin,
		_query_cell_gap_spin,
		_query_cell_padding_spin,
		_overlay_mask_crop_check,
		_overlay_deductor_floor_add_source_option,
		_overlay_deductor_floor_add_button,
		_overlay_adjacency_check,
		_overlay_reference_add_source_option,
		_overlay_reference_add_button,
		_overlay_generated_reference_check,
		_overlay_neighbor_radius_spin,
		_overlay_adjacency_rules_edit,
		_overlay_adjacency_rules_edit_button,
		_apply_write_policy_option,
		_overlay_existing_policy_option,
		_source_load_button,
		_generate_history_check,
		_generate_history_dir_button,
		_generate_button,
	]:
		_set_control_disabled(control, disabled)
	for item_row in _overlay_item_pool_rows:
		_set_control_disabled(item_row["name"], disabled)
		_set_control_disabled(item_row["amount"], disabled)
		_set_control_disabled(item_row["catalog_option"], disabled)
		_set_control_disabled(item_row["tile_source"], disabled)
		_set_control_disabled(item_row["tile_atlas_x"], disabled)
		_set_control_disabled(item_row["tile_atlas_y"], disabled)
		_set_control_disabled(item_row["copy_floor"], disabled)
		_set_control_disabled(item_row["copy_wall"], disabled)
		_set_control_disabled(item_row["remove"], disabled)
	for query_row in _overlay_mask_query_rows + _overlay_deductor_floor_query_rows + _overlay_reference_query_rows:
		_set_control_disabled(query_row["operation"], disabled)
		_set_control_disabled(query_row["match"], disabled)
		_set_control_disabled(query_row["source_item"], disabled)
		_set_control_disabled(query_row["up"], disabled)
		_set_control_disabled(query_row["down"], disabled)
		_set_control_disabled(query_row["remove"], disabled)
		_set_control_disabled(query_row.get("offset_panel", null), disabled)
	if _torus_connectivity_check != null:
		_torus_connectivity_check.disabled = disabled or not _uses_symmetric_generation()
	_refresh_generation_block_state()
	_refresh_overlay_item_pool_rows()
	_refresh_query_row_order(true)
	_refresh_query_row_order(QUERY_KIND_DEDUCTOR_FLOOR)
	_refresh_query_row_order(false)


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
	elif control is HexCellButtonPanel:
		control.enabled = not disabled
		control.queue_redraw()


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
