extends Node2D

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexPoint = preload("res://addons/hex_map_kit/core/hex_point.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")

const HEX_SIZE := 38.0
const FLAT_ORIGIN := Vector2(260.0, 270.0)
const POINTY_ORIGIN := Vector2(760.0, 270.0)
const SINGLE_ORIGIN := Vector2(510.0, 300.0)
const DIRECTION_NAMES := ["Q", "-R", "S", "-Q", "R", "-S"]
const DIRECTION_COLORS := [
	Color(0.92, 0.36, 0.28),
	Color(0.93, 0.62, 0.20),
	Color(0.76, 0.74, 0.26),
	Color(0.25, 0.65, 0.42),
	Color(0.20, 0.52, 0.82),
	Color(0.58, 0.38, 0.78),
]

enum ViewMode {
	BOTH,
	FLAT,
	POINTY,
	PARITY,
	CUSTOM,
}

const VIEW_MODE_COUNT := 5

var _view_mode := ViewMode.BOTH
var _custom_flat_top := true
var _custom_q := 0
var _custom_s := 0
var _custom_r := 0
var _label_nodes: Array[Label] = []
var _button_nodes: Array[Button] = []
var _control_nodes: Array[CanvasItem] = []
var _orientation_option: OptionButton
var _q_spin: SpinBox
var _s_spin: SpinBox
var _r_spin: SpinBox


func _ready() -> void:
	_build_buttons()
	_build_custom_controls()
	_set_control_visibility()
	_rebuild_labels()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if key_event.keycode == KEY_TAB or key_event.keycode == KEY_SPACE:
		_set_view_mode((_view_mode + 1) % VIEW_MODE_COUNT)


func _draw() -> void:
	match _view_mode:
		ViewMode.FLAT:
			_draw_panel(SINGLE_ORIGIN, true, "flat-top")
		ViewMode.POINTY:
			_draw_panel(SINGLE_ORIGIN, false, "pointy-top")
		ViewMode.PARITY:
			_draw_offset_parity_panel(FLAT_ORIGIN, HexPoint.from_cube(0, 0, 0), "flat offset R even")
			_draw_offset_parity_panel(POINTY_ORIGIN, HexPoint.from_cube(0, 0, 1), "flat offset R odd")
		ViewMode.CUSTOM:
			var title = "custom flat-top" if _custom_flat_top else "custom pointy-top"
			_draw_point_panel(SINGLE_ORIGIN, _custom_center(), _custom_flat_top, title)
		_:
			_draw_panel(FLAT_ORIGIN, true, "flat-top")
			_draw_panel(POINTY_ORIGIN, false, "pointy-top")


func _draw_panel(origin: Vector2, flat_top: bool, title: String) -> void:
	var directions = HexVector.directions()
	_draw_hex(origin, flat_top, Color(0.34, 0.36, 0.38), Color(0.92, 0.92, 0.90))

	for index in range(directions.size()):
		var local = HexMapTileAdapter.hex_to_local(directions[index], HEX_SIZE, flat_top)
		var position = origin + local
		draw_line(origin, position, Color(0.28, 0.28, 0.30), 2.0)
		_draw_hex(position, flat_top, DIRECTION_COLORS[index], Color(0.10, 0.10, 0.12))

	var font = ThemeDB.fallback_font
	draw_string(font, origin + Vector2(-58.0, -152.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 26, Color(0.08, 0.08, 0.08))
	draw_string(font, origin + Vector2(-38.0, 6.0), "0", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color(1.0, 1.0, 1.0))


func _draw_point_panel(origin: Vector2, center, flat_top: bool, title: String) -> void:
	var directions = HexVector.directions()
	var center_local = _point_to_local(center, flat_top)
	_draw_hex(origin, flat_top, Color(0.34, 0.36, 0.38), Color(0.92, 0.92, 0.90))

	for index in range(directions.size()):
		var neighbor = center.add_vector(directions[index])
		var local = _point_to_local(neighbor, flat_top) - center_local
		var position = origin + local
		draw_line(origin, position, Color(0.28, 0.28, 0.30), 2.0)
		_draw_hex(position, flat_top, DIRECTION_COLORS[index], Color(0.10, 0.10, 0.12))

	var font = ThemeDB.fallback_font
	var cell = center.to_offset()
	draw_string(font, origin + Vector2(-108.0, -152.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 24, Color(0.08, 0.08, 0.08))
	draw_string(font, origin + Vector2(-108.0, -120.0), "q/s/r (%d, %d, %d)" % [_custom_q, _custom_s, _custom_r], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color(0.18, 0.18, 0.18))
	draw_string(font, origin + Vector2(-108.0, -98.0), "point (%d, %d), cell %s" % [center.q, center.r, str(cell)], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color(0.18, 0.18, 0.18))
	draw_string(font, origin + Vector2(-38.0, 6.0), "0", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color(1.0, 1.0, 1.0))


func _draw_offset_parity_panel(origin: Vector2, center, title: String) -> void:
	var directions = HexVector.directions()
	var center_local = _flat_offset_point_to_local(center)
	_draw_hex(origin, true, Color(0.34, 0.36, 0.38), Color(0.92, 0.92, 0.90))

	for index in range(directions.size()):
		var neighbor = center.add_vector(directions[index])
		var local = _flat_offset_point_to_local(neighbor) - center_local
		var position = origin + local
		draw_line(origin, position, Color(0.28, 0.28, 0.30), 2.0)
		_draw_hex(position, true, DIRECTION_COLORS[index], Color(0.10, 0.10, 0.12))

	var font = ThemeDB.fallback_font
	var cell = center.to_offset()
	draw_string(font, origin + Vector2(-98.0, -152.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 24, Color(0.08, 0.08, 0.08))
	draw_string(font, origin + Vector2(-86.0, -120.0), "cell %s" % str(cell), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color(0.18, 0.18, 0.18))
	draw_string(font, origin + Vector2(-38.0, 6.0), "0", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color(1.0, 1.0, 1.0))


func _draw_hex(center: Vector2, flat_top: bool, fill: Color, stroke: Color) -> void:
	var points: PackedVector2Array = []
	var rotation = 0.0 if flat_top else 30.0
	for index in range(6):
		var angle = deg_to_rad(rotation + 60.0 * float(index))
		points.append(center + Vector2(cos(angle), sin(angle)) * HEX_SIZE)

	draw_colored_polygon(points, fill)
	var outline = points
	outline.append(points[0])
	draw_polyline(outline, stroke, 2.0)


func _rebuild_labels() -> void:
	for label in _label_nodes:
		label.queue_free()
	_label_nodes.clear()

	match _view_mode:
		ViewMode.FLAT:
			_add_panel_labels(SINGLE_ORIGIN, true)
		ViewMode.POINTY:
			_add_panel_labels(SINGLE_ORIGIN, false)
		ViewMode.PARITY:
			_add_offset_panel_labels(FLAT_ORIGIN, HexPoint.from_cube(0, 0, 0))
			_add_offset_panel_labels(POINTY_ORIGIN, HexPoint.from_cube(0, 0, 1))
		ViewMode.CUSTOM:
			_add_point_panel_labels(SINGLE_ORIGIN, _custom_center(), _custom_flat_top)
		_:
			_add_panel_labels(FLAT_ORIGIN, true)
			_add_panel_labels(POINTY_ORIGIN, false)


func _add_panel_labels(origin: Vector2, flat_top: bool) -> void:
	var directions = HexVector.directions()
	for index in range(directions.size()):
		var local = HexMapTileAdapter.hex_to_local(directions[index], HEX_SIZE, flat_top)
		_add_label(DIRECTION_NAMES[index], origin + local + Vector2(-18.0, -12.0), Color.WHITE)


func _add_offset_panel_labels(origin: Vector2, center) -> void:
	var directions = HexVector.directions()
	var center_local = _flat_offset_point_to_local(center)
	for index in range(directions.size()):
		var neighbor = center.add_vector(directions[index])
		var local = _flat_offset_point_to_local(neighbor) - center_local
		_add_label(DIRECTION_NAMES[index], origin + local + Vector2(-18.0, -12.0), Color.WHITE)


func _add_point_panel_labels(origin: Vector2, center, flat_top: bool) -> void:
	var directions = HexVector.directions()
	var center_local = _point_to_local(center, flat_top)
	for index in range(directions.size()):
		var neighbor = center.add_vector(directions[index])
		var local = _point_to_local(neighbor, flat_top) - center_local
		_add_label(DIRECTION_NAMES[index], origin + local + Vector2(-18.0, -12.0), Color.WHITE)


func _add_label(text: String, position: Vector2, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.position = position
	label.size = Vector2(36.0, 24.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.65))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(label)
	_label_nodes.append(label)


func _build_buttons() -> void:
	_add_mode_button("Both", ViewMode.BOTH, Vector2(24.0, 20.0))
	_add_mode_button("Flat", ViewMode.FLAT, Vector2(108.0, 20.0))
	_add_mode_button("Pointy", ViewMode.POINTY, Vector2(192.0, 20.0))
	_add_mode_button("Parity", ViewMode.PARITY, Vector2(276.0, 20.0))
	_add_mode_button("Custom", ViewMode.CUSTOM, Vector2(360.0, 20.0))


func _add_mode_button(text: String, mode: int, position: Vector2) -> void:
	var button = Button.new()
	button.text = text
	button.position = position
	button.size = Vector2(72.0, 32.0)
	button.toggle_mode = true
	button.button_pressed = mode == _view_mode
	button.pressed.connect(_set_view_mode.bind(mode))
	add_child(button)
	_button_nodes.append(button)


func _set_view_mode(mode: int) -> void:
	_view_mode = mode
	for index in range(_button_nodes.size()):
		_button_nodes[index].button_pressed = index == mode
	_set_control_visibility()
	_rebuild_labels()
	queue_redraw()


func _build_custom_controls() -> void:
	_add_control_label("Orient", Vector2(462.0, 20.0), Vector2(54.0, 32.0))
	_orientation_option = OptionButton.new()
	_orientation_option.position = Vector2(516.0, 20.0)
	_orientation_option.size = Vector2(112.0, 32.0)
	_orientation_option.add_item("flat-top")
	_orientation_option.add_item("pointy-top")
	_orientation_option.item_selected.connect(_set_custom_orientation)
	add_child(_orientation_option)
	_control_nodes.append(_orientation_option)

	_add_control_label("q", Vector2(642.0, 20.0), Vector2(18.0, 32.0))
	_q_spin = _add_center_spin(Vector2(660.0, 20.0), _set_custom_q)
	_add_control_label("s", Vector2(736.0, 20.0), Vector2(18.0, 32.0))
	_s_spin = _add_center_spin(Vector2(754.0, 20.0), _set_custom_s)
	_add_control_label("r", Vector2(830.0, 20.0), Vector2(18.0, 32.0))
	_r_spin = _add_center_spin(Vector2(848.0, 20.0), _set_custom_r)


func _add_control_label(text: String, position: Vector2, size: Vector2) -> void:
	var label = Label.new()
	label.text = text
	label.position = position
	label.size = size
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(label)
	_control_nodes.append(label)


func _add_center_spin(position: Vector2, callback: Callable) -> SpinBox:
	var spin = SpinBox.new()
	spin.position = position
	spin.size = Vector2(64.0, 32.0)
	spin.min_value = -999.0
	spin.max_value = 999.0
	spin.step = 1.0
	spin.value_changed.connect(callback)
	add_child(spin)
	_control_nodes.append(spin)
	return spin


func _set_control_visibility() -> void:
	for node in _control_nodes:
		node.visible = _view_mode == ViewMode.CUSTOM


func _set_custom_orientation(index: int) -> void:
	_custom_flat_top = index == 0
	_set_view_mode(ViewMode.CUSTOM)


func _set_custom_q(value: float) -> void:
	_custom_q = int(value)
	_set_view_mode(ViewMode.CUSTOM)


func _set_custom_s(value: float) -> void:
	_custom_s = int(value)
	_set_view_mode(ViewMode.CUSTOM)


func _set_custom_r(value: float) -> void:
	_custom_r = int(value)
	_set_view_mode(ViewMode.CUSTOM)


func _custom_center():
	return HexPoint.from_cube(_custom_q, _custom_s, _custom_r)


func _point_to_local(point, flat_top: bool) -> Vector2:
	var a = float(point.q - point.r)
	var b = float(point.r)
	var sqrt3 = sqrt(3.0)
	if flat_top:
		return Vector2(
			HEX_SIZE * 1.5 * a,
			HEX_SIZE * sqrt3 * (b + a * 0.5)
		)
	return Vector2(
		HEX_SIZE * sqrt3 * (a + b * 0.5),
		HEX_SIZE * 1.5 * b
	)


func _flat_offset_point_to_local(point) -> Vector2:
	var cell = point.to_offset()
	var offset_point = HexPoint.from_offset(cell.x, cell.y)
	return _point_to_local(offset_point, true)
