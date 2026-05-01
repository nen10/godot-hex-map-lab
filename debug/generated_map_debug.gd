extends Node2D

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexGrid = preload("res://addons/hex_map_kit/core/hex_grid.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexMapDebug = preload("res://addons/hex_map_kit/core/hex_map_debug.gd")
const HexToricCoordinate = preload("res://addons/hex_map_kit/core/hex_toric_coordinate.gd")
const HexToricMapSplitRule = preload("res://addons/hex_map_kit/core/hex_toric_map_split_rule.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")

const HEX_SIZE := 24.0
const MAP_ORIGIN := Vector2(520.0, 350.0)
const RECTANGLE_WIDTH := 8
const RECTANGLE_HEIGHT := 6
const HEXAGON_RADIUS := 3
const TORIC_SIZE_PATTERNS := [7, 8, 9, 11, 13]
const WALL_PROBABILITIES := [0.25, 0.45, 0.65]
const SHAPE_NAMES := ["Rectangle", "Hexagon", "Torus"]
const FLOOR_COLOR := Color(0.78, 0.84, 0.78)
const WALL_COLOR := Color(0.26, 0.28, 0.31)
const PROTECTED_COLOR := Color(0.92, 0.78, 0.35)
const OUTLINE_COLOR := Color(0.12, 0.13, 0.14)
const PATH_COLOR := Color(0.12, 0.48, 0.88, 0.90)
const PATH_START_COLOR := Color(0.12, 0.62, 0.42)
const PATH_GOAL_COLOR := Color(0.88, 0.24, 0.24)
const SYMMETRY_OUTER_PHASE_COLORS := [
	Color(0.95, 0.28, 0.18, 0.48),
	Color(0.96, 0.52, 0.18, 0.48),
	Color(0.91, 0.70, 0.18, 0.48),
]
const SYMMETRY_OUTER_WAVE_COLOR := Color(0.94, 0.43, 0.22, 0.34)
const SYMMETRY_OUTER_PHASE2_BOUNDARY_COLOR := Color(0.98, 0.22, 0.70, 0.58)
const SYMMETRY_OUTER_PHASE2_TRIANGLE_COLOR := Color(0.98, 0.12, 0.58, 0.84)
const SYMMETRY_OUTER_PHASE2_PAIR_COLOR := Color(0.98, 0.78, 0.10, 0.88)
const SYMMETRY_REFERENCE_OUTER_MOD_COLOR := Color(1.00, 0.88, 0.10, 0.92)
const SYMMETRY_REFERENCE_OUTER_WAVE_COLOR := Color(0.18, 0.94, 0.92, 0.88)
const SYMMETRY_REFERENCE_BORDER_INITIAL_COLOR := Color(1.00, 0.40, 0.18, 0.88)
const SYMMETRY_REFERENCE_BORDER_EDGE_COLOR := Color(0.34, 0.92, 0.26, 0.88)
const SYMMETRY_OUTER_DUMMY_COLOR := Color(0.62, 0.42, 0.88, 0.34)
const SYMMETRY_BORDER_COLOR := Color(0.96, 0.86, 0.24, 0.52)
const SYMMETRY_BORDER_MOVED_COLOR := Color(0.18, 0.72, 0.76, 0.54)
const SYMMETRY_INNER_ARC_COLOR := Color(0.20, 0.46, 0.88, 0.42)
const SYMMETRY_CENTER_COLOR := Color(0.98, 0.96, 0.92, 0.78)
const SPLIT_COLORS := [
	Color(0.92, 0.33, 0.28, 0.42),
	Color(0.96, 0.58, 0.16, 0.42),
	Color(0.92, 0.78, 0.20, 0.42),
	Color(0.25, 0.66, 0.38, 0.42),
	Color(0.18, 0.62, 0.70, 0.42),
	Color(0.20, 0.44, 0.82, 0.42),
	Color(0.46, 0.32, 0.78, 0.42),
	Color(0.72, 0.30, 0.62, 0.42),
	Color(0.96, 0.95, 0.90, 0.50),
]

enum ShapeMode {
	RECTANGLE,
	HEXAGON,
	TORUS,
}

const SHAPE_RECTANGLE := ShapeMode.RECTANGLE
const SHAPE_HEXAGON := ShapeMode.HEXAGON
const SHAPE_TORUS := ShapeMode.TORUS

var _shape_mode := ShapeMode.RECTANGLE
var _seed := 1201
var _wall_probability := 0.45
var _ensure_connected := true
var _flat_top := true
var _show_path := true
var _show_split := true
var _show_symmetry_regions := false
var _center_toric_domain := false
var _unfold_toric_domain := false
var _use_symmetric_toric_generation := false
var _toric_size_index := 0
var _map_data
var _split_rule = null
var _path_points: Array = []
var _shape_buttons: Array[Button] = []
var _summary_label: Label
var _orientation_option: OptionButton
var _probability_option: OptionButton
var _connected_check: CheckButton
var _path_check: CheckButton
var _split_check: CheckButton
var _symmetry_check: CheckButton
var _domain_check: CheckButton
var _unfold_check: CheckButton
var _symmetric_generation_check: CheckButton
var _toric_size_option: OptionButton


func _ready() -> void:
	_build_controls()
	_generate_map()


func configure_for_test(
	shape_mode: int,
	seed: int,
	wall_probability: float,
	ensure_connected: bool,
	flat_top: bool,
	toric_size_index: int = -1,
	unfold_toric_domain: bool = false,
	show_symmetry_regions: bool = false,
	use_symmetric_toric_generation: bool = false,
	center_toric_domain: bool = false
) -> void:
	_shape_mode = shape_mode
	_seed = seed
	_wall_probability = wall_probability
	_ensure_connected = ensure_connected
	_flat_top = flat_top
	if toric_size_index >= 0:
		_toric_size_index = clampi(toric_size_index, 0, TORIC_SIZE_PATTERNS.size() - 1)
	_unfold_toric_domain = unfold_toric_domain
	_show_symmetry_regions = show_symmetry_regions
	_use_symmetric_toric_generation = use_symmetric_toric_generation
	_center_toric_domain = center_toric_domain
	_sync_controls()
	_generate_map()


func get_current_map_data():
	return _map_data


func get_current_path() -> Array:
	return _path_points


func get_split_index(point) -> int:
	if _split_rule == null:
		return -1
	return _split_rule.split_index_for(point)


func get_display_vector(point):
	return _display_vector(point)


func get_display_vectors(point) -> Array:
	return _display_vectors(point)


func get_toric_size() -> int:
	return _toric_size()


func uses_symmetric_toric_generation() -> bool:
	return _uses_symmetric_toric_generation()


func get_symmetry_region_tags() -> Dictionary:
	if _split_rule == null:
		return {}
	return _split_rule.symmetry_generation_tags()


func get_symmetry_region_tag(point) -> Dictionary:
	return get_symmetry_region_tags().get(point.key(), {})


func get_phase2_outer_mod_tiling_groups() -> Array:
	var result: Array = []
	if _split_rule == null:
		return result
	for group in _split_rule.symmetry_phase2_outer_mod_groups():
		result.append(_compact_toric_group_vectors(group["points"]))
	return result


func get_unity_reference_tiling_groups() -> Array:
	var result: Array = []
	if _split_rule == null:
		return result
	for group in _split_rule.symmetry_unity_reference_groups():
		result.append(_compact_toric_group_vectors(group["sources"]))
	return result


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	match key_event.keycode:
		KEY_SPACE:
			_seed += 1
			_generate_map()
		KEY_TAB:
			_set_shape_mode((_shape_mode + 1) % SHAPE_NAMES.size())
		KEY_R:
			_set_connected(not _ensure_connected)
		KEY_O:
			_set_orientation(1 if _flat_top else 0)
		KEY_P:
			_set_path_visible(not _show_path)
		KEY_S:
			_set_split_visible(not _show_split)
		KEY_Y:
			_set_symmetry_visible(not _show_symmetry_regions)
		KEY_D:
			_set_domain_centered(not _center_toric_domain)
		KEY_U:
			_set_unfold_visible(not _unfold_toric_domain)
		KEY_N:
			_set_toric_size_index((_toric_size_index + 1) % TORIC_SIZE_PATTERNS.size())
		KEY_G:
			_set_symmetric_generation(not _use_symmetric_toric_generation)


func _draw() -> void:
	_draw_map()
	_draw_header()


func _build_controls() -> void:
	_add_shape_button("Rect", ShapeMode.RECTANGLE, Vector2(24.0, 20.0))
	_add_shape_button("Hex", ShapeMode.HEXAGON, Vector2(108.0, 20.0))
	_add_shape_button("Torus", ShapeMode.TORUS, Vector2(192.0, 20.0))

	_orientation_option = OptionButton.new()
	_orientation_option.position = Vector2(296.0, 20.0)
	_orientation_option.size = Vector2(122.0, 32.0)
	_orientation_option.add_item("flat-top")
	_orientation_option.add_item("pointy-top")
	_orientation_option.item_selected.connect(_set_orientation)
	add_child(_orientation_option)

	_connected_check = CheckButton.new()
	_connected_check.text = "Connected"
	_connected_check.position = Vector2(436.0, 18.0)
	_connected_check.size = Vector2(132.0, 36.0)
	_connected_check.button_pressed = _ensure_connected
	_connected_check.toggled.connect(_set_connected)
	add_child(_connected_check)

	_path_check = CheckButton.new()
	_path_check.text = "Path"
	_path_check.position = Vector2(568.0, 18.0)
	_path_check.size = Vector2(86.0, 36.0)
	_path_check.button_pressed = _show_path
	_path_check.toggled.connect(_set_path_visible)
	add_child(_path_check)

	_split_check = CheckButton.new()
	_split_check.text = "9-Split"
	_split_check.position = Vector2(878.0, 18.0)
	_split_check.size = Vector2(86.0, 36.0)
	_split_check.button_pressed = _show_split
	_split_check.toggled.connect(_set_split_visible)
	add_child(_split_check)

	_symmetry_check = CheckButton.new()
	_symmetry_check.text = "Sym Region"
	_symmetry_check.position = Vector2(768.0, 54.0)
	_symmetry_check.size = Vector2(110.0, 36.0)
	_symmetry_check.button_pressed = _show_symmetry_regions
	_symmetry_check.toggled.connect(_set_symmetry_visible)
	add_child(_symmetry_check)

	_domain_check = CheckButton.new()
	_domain_check.text = "Centered"
	_domain_check.position = Vector2(878.0, 54.0)
	_domain_check.size = Vector2(128.0, 36.0)
	_domain_check.button_pressed = _center_toric_domain
	_domain_check.toggled.connect(_set_domain_centered)
	add_child(_domain_check)

	_unfold_check = CheckButton.new()
	_unfold_check.text = "Unfold"
	_unfold_check.position = Vector2(878.0, 90.0)
	_unfold_check.size = Vector2(104.0, 36.0)
	_unfold_check.button_pressed = _unfold_toric_domain
	_unfold_check.toggled.connect(_set_unfold_visible)
	add_child(_unfold_check)

	_symmetric_generation_check = CheckButton.new()
	_symmetric_generation_check.text = "Sym Gen"
	_symmetric_generation_check.position = Vector2(768.0, 90.0)
	_symmetric_generation_check.size = Vector2(110.0, 36.0)
	_symmetric_generation_check.button_pressed = _use_symmetric_toric_generation
	_symmetric_generation_check.toggled.connect(_set_symmetric_generation)
	add_child(_symmetric_generation_check)

	_probability_option = OptionButton.new()
	_probability_option.position = Vector2(668.0, 20.0)
	_probability_option.size = Vector2(96.0, 32.0)
	for probability in WALL_PROBABILITIES:
		_probability_option.add_item("%.2f" % probability)
	_probability_option.select(1)
	_probability_option.item_selected.connect(_set_probability_index)
	add_child(_probability_option)

	var next_seed_button = Button.new()
	next_seed_button.text = "New Seed"
	next_seed_button.position = Vector2(782.0, 20.0)
	next_seed_button.size = Vector2(96.0, 32.0)
	next_seed_button.pressed.connect(_next_seed)
	add_child(next_seed_button)

	_toric_size_option = OptionButton.new()
	_toric_size_option.position = Vector2(668.0, 54.0)
	_toric_size_option.size = Vector2(96.0, 32.0)
	for toric_size in TORIC_SIZE_PATTERNS:
		_toric_size_option.add_item("N=%d" % toric_size)
	_toric_size_option.item_selected.connect(_set_toric_size_index)
	add_child(_toric_size_option)

	_summary_label = Label.new()
	_summary_label.position = Vector2(24.0, 606.0)
	_summary_label.size = Vector2(960.0, 52.0)
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_summary_label)
	_sync_controls()


func _add_shape_button(text: String, mode: int, position: Vector2) -> void:
	var button = Button.new()
	button.text = text
	button.position = position
	button.size = Vector2(72.0, 32.0)
	button.toggle_mode = true
	button.button_pressed = mode == _shape_mode
	button.pressed.connect(_set_shape_mode.bind(mode))
	add_child(button)
	_shape_buttons.append(button)


func _set_shape_mode(mode: int) -> void:
	_shape_mode = mode
	_sync_controls()
	_generate_map()


func _set_orientation(index: int) -> void:
	_flat_top = index == 0
	_sync_controls()
	queue_redraw()


func _set_connected(value: bool) -> void:
	_ensure_connected = value
	_sync_controls()
	_generate_map()


func _set_probability_index(index: int) -> void:
	_wall_probability = WALL_PROBABILITIES[index]
	_generate_map()


func _next_seed() -> void:
	_seed += 1
	_generate_map()


func _set_path_visible(value: bool) -> void:
	_show_path = value
	_sync_controls()
	_update_summary()
	queue_redraw()


func _set_split_visible(value: bool) -> void:
	_show_split = value
	_sync_controls()
	_update_summary()
	queue_redraw()


func _set_symmetry_visible(value: bool) -> void:
	_show_symmetry_regions = value
	_sync_controls()
	_update_summary()
	queue_redraw()


func _set_domain_centered(value: bool) -> void:
	_center_toric_domain = value
	_sync_controls()
	_update_summary()
	queue_redraw()


func _set_unfold_visible(value: bool) -> void:
	_unfold_toric_domain = value
	_sync_controls()
	_update_summary()
	queue_redraw()


func _set_symmetric_generation(value: bool) -> void:
	_use_symmetric_toric_generation = value
	_sync_controls()
	_generate_map()


func _set_toric_size_index(index: int) -> void:
	_toric_size_index = clampi(index, 0, TORIC_SIZE_PATTERNS.size() - 1)
	_sync_controls()
	_generate_map()


func _sync_controls() -> void:
	for index in range(_shape_buttons.size()):
		_shape_buttons[index].button_pressed = index == _shape_mode
	if _orientation_option != null:
		_orientation_option.select(0 if _flat_top else 1)
	if _connected_check != null:
		_connected_check.button_pressed = _ensure_connected
	if _path_check != null:
		_path_check.button_pressed = _show_path
	if _split_check != null:
		_split_check.button_pressed = _show_split
		_split_check.visible = _shape_mode == ShapeMode.TORUS
		_split_check.disabled = _shape_mode == ShapeMode.TORUS and _toric_size() % 2 == 0
	if _symmetry_check != null:
		_symmetry_check.button_pressed = _show_symmetry_regions
		_symmetry_check.visible = _shape_mode == ShapeMode.TORUS
		_symmetry_check.disabled = _shape_mode == ShapeMode.TORUS and _toric_size() % 2 == 0
	if _domain_check != null:
		_domain_check.button_pressed = _center_toric_domain
		_domain_check.visible = _shape_mode == ShapeMode.TORUS
	if _unfold_check != null:
		_unfold_check.button_pressed = _unfold_toric_domain
		_unfold_check.visible = _shape_mode == ShapeMode.TORUS
	if _symmetric_generation_check != null:
		_symmetric_generation_check.button_pressed = _use_symmetric_toric_generation
		_symmetric_generation_check.visible = _shape_mode == ShapeMode.TORUS
		_symmetric_generation_check.disabled = _shape_mode == ShapeMode.TORUS and _toric_size() % 2 == 0
	if _toric_size_option != null:
		_toric_size_option.select(_toric_size_index)
		_toric_size_option.visible = _shape_mode == ShapeMode.TORUS
	if _probability_option != null:
		var selected_index = 0
		for index in range(WALL_PROBABILITIES.size()):
			if is_equal_approx(WALL_PROBABILITIES[index], _wall_probability):
				selected_index = index
		_probability_option.select(selected_index)


func _generate_map() -> void:
	var protected_floor = [HexVector.zero()]
	match _shape_mode:
		ShapeMode.HEXAGON:
			_map_data = HexMapGenerator.generate_hexagon(
				HEXAGON_RADIUS,
				_wall_probability,
				_seed,
				_ensure_connected,
				protected_floor
			)
		ShapeMode.TORUS:
			_refresh_split_rule()
			if _uses_symmetric_toric_generation():
				_map_data = HexMapGenerator.generate_symmetric_toric_square(
					_toric_size(),
					_wall_probability,
					_seed,
					_ensure_connected,
					protected_floor
				)
			else:
				_map_data = HexMapGenerator.generate_toric_square(
					_toric_size(),
					_wall_probability,
					_seed,
					_ensure_connected,
					protected_floor
				)
		_:
			_map_data = HexMapGenerator.generate_rectangle(
				RECTANGLE_WIDTH,
				RECTANGLE_HEIGHT,
				_wall_probability,
				_seed,
				_ensure_connected,
				false,
				protected_floor
			)
	_refresh_path()
	_update_summary()
	queue_redraw()


func _update_summary() -> void:
	if _summary_label == null or _map_data == null:
		return
	var connected = HexMapGenerator.is_floor_connected(_map_data)
	_summary_label.text = "%s  seed=%d  wall_prob=%.2f  restore=%s  connected=%s  %s" % [
		SHAPE_NAMES[_shape_mode],
		_seed,
		_wall_probability,
		str(_ensure_connected),
		str(connected),
		HexMapDebug.render_summary(_map_data),
	]
	if _show_path:
		_summary_label.text += "  path=%d" % _path_points.size()
	if _shape_mode == ShapeMode.TORUS and _show_split and _split_rule != null:
		_summary_label.text += "  split=9"
	if _shape_mode == ShapeMode.TORUS and _show_symmetry_regions and _split_rule != null:
		_summary_label.text += "  symmetry=phase%d" % ((int((_toric_size() - 1) / 2) - 1) % 3)
	if _shape_mode == ShapeMode.TORUS and _center_toric_domain:
		_summary_label.text += "  centered"
	if _shape_mode == ShapeMode.TORUS:
		_summary_label.text += "  size=%d" % _toric_size()
	if _shape_mode == ShapeMode.TORUS and _unfold_toric_domain:
		_summary_label.text += "  unfold=on"
	if _shape_mode == ShapeMode.TORUS:
		if _uses_symmetric_toric_generation():
			_summary_label.text += "  mode=symmetric"
		elif _use_symmetric_toric_generation and _toric_size() % 2 == 0:
			_summary_label.text += "  mode=random  sym-gen=odd-only"
		else:
			_summary_label.text += "  mode=random"


func _draw_header() -> void:
	var font = ThemeDB.fallback_font
	draw_string(
		font,
		Vector2(24.0, 92.0),
		"Generated map debug",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		26,
		Color(0.08, 0.08, 0.08)
	)
	draw_string(
		font,
		Vector2(24.0, 122.0),
		"Space: new seed   Tab: shape   R: restore   O: orientation   P: path   S: 9-split   Y: sym-region   D: centered   U: unfold   N: size   G: sym-gen",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		16,
		Color(0.25, 0.25, 0.25)
	)


func _draw_map() -> void:
	if _map_data == null:
		return
	var entries = HexMapTileAdapter.to_tile_entries(_map_data)
	if entries.is_empty():
		return

	var positions: Array = []
	var local_by_key := {}
	var first_position = HexMapTileAdapter.hex_to_local(
		_display_vectors(entries[0]["vector"])[0],
		HEX_SIZE,
		_flat_top
	)
	var min_position = first_position
	var max_position = first_position
	for entry in entries:
		var display_vectors = _display_vectors(entry["vector"])
		for copy_index in range(display_vectors.size()):
			var local = HexMapTileAdapter.hex_to_local(display_vectors[copy_index], HEX_SIZE, _flat_top)
			positions.append({
				"entry": entry,
				"local": local,
				"display_vector": display_vectors[copy_index],
				"duplicate": copy_index > 0,
			})
			if not local_by_key.has(entry["vector"].key()):
				local_by_key[entry["vector"].key()] = local
			min_position.x = minf(min_position.x, local.x)
			min_position.y = minf(min_position.y, local.y)
			max_position.x = maxf(max_position.x, local.x)
			max_position.y = maxf(max_position.y, local.y)
	if _show_symmetry_regions and _shape_mode == ShapeMode.TORUS and _split_rule != null:
		for vector in _symmetry_equivalence_tiling_vectors():
			var local = HexMapTileAdapter.hex_to_local(vector, HEX_SIZE, _flat_top)
			min_position.x = minf(min_position.x, local.x)
			min_position.y = minf(min_position.y, local.y)
			max_position.x = maxf(max_position.x, local.x)
			max_position.y = maxf(max_position.y, local.y)

	var offset = MAP_ORIGIN - (min_position + max_position) * 0.5
	for item in positions:
		var entry: Dictionary = item["entry"]
		var vector = entry["vector"]
		var fill = WALL_COLOR if entry["kind"] == HexMapTileAdapter.KIND_WALL else FLOOR_COLOR
		if vector.is_equal(HexVector.zero()):
			fill = PROTECTED_COLOR
		if item["duplicate"]:
			fill = fill.lerp(Color.WHITE, 0.24)
		_draw_hex(offset + item["local"], _flat_top, fill, OUTLINE_COLOR)

	_draw_split_overlay(offset, positions)
	_draw_symmetry_overlay(offset, positions)
	_draw_path(offset, local_by_key)


func _refresh_path() -> void:
	_path_points = []
	if _map_data == null:
		return

	var floors = _map_data.floor_cells()
	if floors.size() <= 1:
		return

	var start = HexVector.zero()
	if not _map_data.has_cell(start) or _map_data.has_wall(start):
		start = floors[0]

	var goal = _farthest_floor_from(start, floors)
	if goal == null or goal.is_equal(start):
		return

	_path_points = HexGrid.shortest_path(start, [goal], floors, _map_data.cyclic_size)


func _farthest_floor_from(start, floors: Array):
	var result = null
	var result_distance = -1
	var result_key = ""
	for floor in floors:
		if floor.is_equal(start):
			continue
		var distance = floor.subtract(start).l1_norm()
		var key = floor.key()
		if distance > result_distance or (distance == result_distance and key > result_key):
			result = floor
			result_distance = distance
			result_key = key
	return result


func _draw_path(map_offset: Vector2, local_by_key: Dictionary) -> void:
	if not _show_path or _path_points.size() <= 1:
		return

	var points := PackedVector2Array()
	for point in _path_points:
		var key = point.key()
		if not local_by_key.has(key):
			continue
		points.append(map_offset + local_by_key[key])

	if points.size() <= 1:
		return

	draw_polyline(points, PATH_COLOR, 6.0, true)
	draw_circle(points[0], 8.0, PATH_START_COLOR)
	draw_circle(points[points.size() - 1], 8.0, PATH_GOAL_COLOR)


func _draw_split_overlay(map_offset: Vector2, positions: Array) -> void:
	if not _show_split or _shape_mode != ShapeMode.TORUS or _split_rule == null:
		return

	for item in positions:
		var entry: Dictionary = item["entry"]
		var split_index = _split_rule.split_index_for(entry["vector"])
		if split_index < 0:
			continue
		_draw_hex(
			map_offset + item["local"],
			_flat_top,
			SPLIT_COLORS[split_index],
			Color.TRANSPARENT
		)


func _draw_symmetry_overlay(map_offset: Vector2, positions: Array) -> void:
	if not _show_symmetry_regions or _shape_mode != ShapeMode.TORUS or _split_rule == null:
		return

	var tags = _split_rule.symmetry_generation_tags()
	for item in positions:
		var entry: Dictionary = item["entry"]
		var tag = tags.get(entry["vector"].key(), null)
		if tag == null:
			continue
		_draw_hex(
			map_offset + item["local"],
			_flat_top,
			_symmetry_color_for_tag(tag),
			Color.TRANSPARENT
		)
		if tag["kind"] == HexToricMapSplitRule.SYMMETRY_KIND_CENTER:
			draw_circle(map_offset + item["local"], 6.0, Color(0.16, 0.14, 0.10, 0.72))
	_draw_phase2_outer_mod_groups(map_offset)
	_draw_unity_reference_groups(map_offset)


func _draw_phase2_outer_mod_groups(map_offset: Vector2) -> void:
	for group in _split_rule.symmetry_phase2_outer_mod_groups():
		var display_vectors = _compact_toric_group_vectors(group["points"])
		var vertices := PackedVector2Array()
		for vector in display_vectors:
			vertices.append(map_offset + HexMapTileAdapter.hex_to_local(vector, HEX_SIZE, _flat_top))
		var color = SYMMETRY_OUTER_PHASE2_TRIANGLE_COLOR
		if group["group"] == HexToricMapSplitRule.SYMMETRY_GROUP_PAIR:
			color = SYMMETRY_OUTER_PHASE2_PAIR_COLOR
		else:
			vertices.append(vertices[0])
		var fill_color = Color(color.r, color.g, color.b, 0.20)
		var outline_color = Color(color.r, color.g, color.b, 0.72)
		for vector in display_vectors:
			_draw_hex(
				map_offset + HexMapTileAdapter.hex_to_local(vector, HEX_SIZE, _flat_top),
				_flat_top,
				fill_color,
				outline_color
			)
		draw_polyline(vertices, color, 3.0, true)


func _draw_unity_reference_groups(map_offset: Vector2) -> void:
	for group in _split_rule.symmetry_unity_reference_groups():
		_draw_symmetry_equivalence_group(
			map_offset,
			_compact_toric_group_vectors(group["sources"]),
			_reference_group_color(group["kind"]),
			2.0
		)


func _draw_symmetry_equivalence_group(
	map_offset: Vector2,
	display_vectors: Array,
	color: Color,
	width: float
) -> void:
	if display_vectors.size() <= 1:
		return

	var vertices := PackedVector2Array()
	for vector in display_vectors:
		vertices.append(map_offset + HexMapTileAdapter.hex_to_local(vector, HEX_SIZE, _flat_top))
	if display_vectors.size() > 2:
		vertices.append(vertices[0])

	var fill_color = Color(color.r, color.g, color.b, 0.14)
	var outline_color = Color(color.r, color.g, color.b, 0.60)
	for vector in display_vectors:
		_draw_hex(
			map_offset + HexMapTileAdapter.hex_to_local(vector, HEX_SIZE, _flat_top),
			_flat_top,
			fill_color,
			outline_color
		)
	draw_polyline(vertices, color, width, true)


func _symmetry_equivalence_tiling_vectors() -> Array:
	var result: Array = []
	if _split_rule == null:
		return result
	for group in _split_rule.symmetry_phase2_outer_mod_groups():
		result.append_array(_compact_toric_group_vectors(group["points"]))
	for group in _split_rule.symmetry_unity_reference_groups():
		result.append_array(_compact_toric_group_vectors(group["sources"]))
	return result


func _compact_toric_group_vectors(vectors: Array) -> Array:
	if vectors.size() <= 1:
		return vectors.duplicate()

	var options: Array = []
	for vector in vectors:
		options.append(_toric_period_copies(vector))

	var best := {
		"score": INF,
		"vectors": [],
	}
	_search_compact_toric_group(options, 0, [], best)
	return best["vectors"]


func _toric_period_copies(vector) -> Array:
	var result: Array = []
	var size = _toric_size()
	for q_offset in range(-1, 2):
		for r_offset in range(-1, 2):
			result.append(vector.add(HexVector.apply_basis(q_offset * size, 0, r_offset * size)))
	return result


func _search_compact_toric_group(options: Array, index: int, current: Array, best: Dictionary) -> void:
	if index >= options.size():
		var score = _toric_group_score(current)
		if score < best["score"]:
			best["score"] = score
			best["vectors"] = current.duplicate()
		return

	for vector in options[index]:
		current.append(vector)
		_search_compact_toric_group(options, index + 1, current, best)
		current.pop_back()


func _toric_group_score(vectors: Array) -> float:
	var locals: Array = []
	var centroid := Vector2.ZERO
	for vector in vectors:
		var local = HexMapTileAdapter.hex_to_local(vector, HEX_SIZE, _flat_top)
		locals.append(local)
		centroid += local
	centroid /= float(locals.size())

	var max_pair_distance := 0.0
	var total_pair_distance := 0.0
	for left in range(locals.size()):
		for right in range(left + 1, locals.size()):
			var distance = locals[left].distance_to(locals[right])
			max_pair_distance = maxf(max_pair_distance, distance)
			total_pair_distance += distance
	return max_pair_distance * 100000.0 + total_pair_distance * 100.0 + centroid.length()


func _reference_group_color(kind: String) -> Color:
	match kind:
		HexToricMapSplitRule.SYMMETRY_KIND_OUTER_MOD:
			return SYMMETRY_REFERENCE_OUTER_MOD_COLOR
		HexToricMapSplitRule.SYMMETRY_KIND_OUTER_WAVE:
			return SYMMETRY_REFERENCE_OUTER_WAVE_COLOR
		HexToricMapSplitRule.SYMMETRY_KIND_BORDER_INITIAL:
			return SYMMETRY_REFERENCE_BORDER_INITIAL_COLOR
		HexToricMapSplitRule.SYMMETRY_KIND_BORDER_EDGE:
			return SYMMETRY_REFERENCE_BORDER_EDGE_COLOR
		_:
			return Color(1.0, 1.0, 1.0, 0.0)


func _symmetry_color_for_tag(tag: Dictionary) -> Color:
	match tag["kind"]:
		HexToricMapSplitRule.SYMMETRY_KIND_OUTER_MOD:
			return SYMMETRY_OUTER_PHASE_COLORS[tag["phase"]]
		HexToricMapSplitRule.SYMMETRY_KIND_OUTER_WAVE:
			return SYMMETRY_OUTER_WAVE_COLOR
		HexToricMapSplitRule.SYMMETRY_KIND_OUTER_PHASE2_BOUNDARY:
			return SYMMETRY_OUTER_PHASE2_BOUNDARY_COLOR
		HexToricMapSplitRule.SYMMETRY_KIND_OUTER_DUMMY:
			return SYMMETRY_OUTER_DUMMY_COLOR
		HexToricMapSplitRule.SYMMETRY_KIND_BORDER_INITIAL, HexToricMapSplitRule.SYMMETRY_KIND_BORDER_EDGE:
			return SYMMETRY_BORDER_MOVED_COLOR if tag["moved"] else SYMMETRY_BORDER_COLOR
		HexToricMapSplitRule.SYMMETRY_KIND_INNER_ARC:
			return SYMMETRY_INNER_ARC_COLOR
		HexToricMapSplitRule.SYMMETRY_KIND_CENTER:
			return SYMMETRY_CENTER_COLOR
		_:
			return Color(1.0, 1.0, 1.0, 0.0)


func _display_vector(vector):
	return _display_vectors(vector)[0]


func _display_vectors(vector) -> Array:
	if _shape_mode != ShapeMode.TORUS:
		return [vector]
	if _unfold_toric_domain:
		return HexToricCoordinate.unfolded_vectors(vector, _toric_size())
	if not _center_toric_domain:
		return [vector]
	return [HexToricCoordinate.centered_vector(vector, _toric_size())]


func _refresh_split_rule() -> void:
	if _toric_size() % 2 == 0:
		_split_rule = null
		return
	_split_rule = HexToricMapSplitRule.new(int((_toric_size() - 1) / 2))


func _toric_size() -> int:
	return TORIC_SIZE_PATTERNS[_toric_size_index]


func _uses_symmetric_toric_generation() -> bool:
	return _shape_mode == ShapeMode.TORUS \
		and _use_symmetric_toric_generation \
		and _toric_size() % 2 == 1


func _draw_hex(center: Vector2, flat_top: bool, fill: Color, stroke: Color) -> void:
	var points: PackedVector2Array = []
	var rotation = 0.0 if flat_top else 30.0
	for index in range(6):
		var angle = deg_to_rad(rotation + 60.0 * float(index))
		points.append(center + Vector2(cos(angle), sin(angle)) * HEX_SIZE)

	draw_colored_polygon(points, fill)
	var outline = points
	outline.append(points[0])
	draw_polyline(outline, stroke, 1.5)
