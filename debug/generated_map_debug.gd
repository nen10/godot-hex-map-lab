extends Node2D

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexGrid = preload("res://addons/hex_map_kit/core/hex_grid.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexMapDebug = preload("res://addons/hex_map_kit/core/hex_map_debug.gd")
const HexToricMapSplitRule = preload("res://addons/hex_map_kit/core/hex_toric_map_split_rule.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")

const HEX_SIZE := 24.0
const MAP_ORIGIN := Vector2(520.0, 350.0)
const RECTANGLE_WIDTH := 8
const RECTANGLE_HEIGHT := 6
const HEXAGON_RADIUS := 3
const TORIC_MAP_UNIT_RADIUS := 3
const TORIC_SIZE := TORIC_MAP_UNIT_RADIUS * 2 + 1
const WALL_PROBABILITIES := [0.25, 0.45, 0.65]
const SHAPE_NAMES := ["Rectangle", "Hexagon", "Toric"]
const FLOOR_COLOR := Color(0.78, 0.84, 0.78)
const WALL_COLOR := Color(0.26, 0.28, 0.31)
const PROTECTED_COLOR := Color(0.92, 0.78, 0.35)
const OUTLINE_COLOR := Color(0.12, 0.13, 0.14)
const PATH_COLOR := Color(0.12, 0.48, 0.88, 0.90)
const PATH_START_COLOR := Color(0.12, 0.62, 0.42)
const PATH_GOAL_COLOR := Color(0.88, 0.24, 0.24)
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
	TORIC_SQUARE,
}

const SHAPE_RECTANGLE := ShapeMode.RECTANGLE
const SHAPE_HEXAGON := ShapeMode.HEXAGON
const SHAPE_TORIC_SQUARE := ShapeMode.TORIC_SQUARE

var _shape_mode := ShapeMode.RECTANGLE
var _seed := 1201
var _wall_probability := 0.45
var _ensure_connected := true
var _flat_top := true
var _show_path := true
var _show_split := true
var _map_data
var _split_rule = HexToricMapSplitRule.new(TORIC_MAP_UNIT_RADIUS)
var _path_points: Array = []
var _shape_buttons: Array[Button] = []
var _summary_label: Label
var _orientation_option: OptionButton
var _probability_option: OptionButton
var _connected_check: CheckButton
var _path_check: CheckButton
var _split_check: CheckButton


func _ready() -> void:
	_build_controls()
	_generate_map()


func configure_for_test(
	shape_mode: int,
	seed: int,
	wall_probability: float,
	ensure_connected: bool,
	flat_top: bool
) -> void:
	_shape_mode = shape_mode
	_seed = seed
	_wall_probability = wall_probability
	_ensure_connected = ensure_connected
	_flat_top = flat_top
	_sync_controls()
	_generate_map()


func get_current_map_data():
	return _map_data


func get_current_path() -> Array:
	return _path_points


func get_split_index(point) -> int:
	return _split_rule.split_index_for(point)


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


func _draw() -> void:
	_draw_map()
	_draw_header()


func _build_controls() -> void:
	_add_shape_button("Rect", ShapeMode.RECTANGLE, Vector2(24.0, 20.0))
	_add_shape_button("Hex", ShapeMode.HEXAGON, Vector2(108.0, 20.0))
	_add_shape_button("Toric", ShapeMode.TORIC_SQUARE, Vector2(192.0, 20.0))

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
	_split_check.text = "Split"
	_split_check.position = Vector2(878.0, 18.0)
	_split_check.size = Vector2(86.0, 36.0)
	_split_check.button_pressed = _show_split
	_split_check.toggled.connect(_set_split_visible)
	add_child(_split_check)

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
		_split_check.visible = _shape_mode == ShapeMode.TORIC_SQUARE
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
		ShapeMode.TORIC_SQUARE:
			_map_data = HexMapGenerator.generate_toric_square(
				TORIC_SIZE,
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
	if _shape_mode == ShapeMode.TORIC_SQUARE and _show_split:
		_summary_label.text += "  split=9"


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
		"Space: new seed   Tab: shape   R: restore   O: orientation   P: path   S: split",
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
	var first_position = HexMapTileAdapter.hex_to_local(entries[0]["vector"], HEX_SIZE, _flat_top)
	var min_position = first_position
	var max_position = first_position
	for entry in entries:
		var local = HexMapTileAdapter.hex_to_local(entry["vector"], HEX_SIZE, _flat_top)
		positions.append({"entry": entry, "local": local})
		local_by_key[entry["vector"].key()] = local
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
		_draw_hex(offset + item["local"], _flat_top, fill, OUTLINE_COLOR)

	_draw_split_overlay(offset, positions)
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
	if not _show_split or _shape_mode != ShapeMode.TORIC_SQUARE:
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
