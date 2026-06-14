class_name HexDebugOverlayRenderer
extends RefCounted

const DEFAULT_PATH_OUTLINE_WIDTH := 4.0
const DEFAULT_PATH_MARKER_RADIUS := 5.0
const DEFAULT_LOOP_OUTLINE_COLOR := Color(0.18, 0.44, 0.82, 0.26)
const DEFAULT_PATH_START_COLOR := Color(0.12, 0.62, 0.42)
const DEFAULT_PATH_END_COLOR := Color(0.88, 0.24, 0.24)
const DEFAULT_HEX_HIGHLIGHT_WIDTH := 2.5
const DEFAULT_HEX_FILL_OUTLINE_WIDTH := 1.5
const RANGE_OUTLINE_ALPHA := 0.72


func draw_debug_overlay(canvas: Node2D, state: Dictionary) -> void:
	if canvas == null or not is_instance_valid(canvas):
		return
	var movement_range_overlay = state.get("movement_range_overlay", {})
	var highlights = state.get("highlights", {})
	var display_path = state.get("display_path", [])
	var path_color = _coerce_color(state.get("path_color", Color(0.12, 0.48, 0.88, 0.90)))
	var flat_top = bool(state.get("flat_top", true))
	var hex_size = float(state.get("hex_size", 24.0))

	var visual_hexes_for_draw = state.get("visual_hexes_for_draw")
	if not (visual_hexes_for_draw is Callable) or not (visual_hexes_for_draw as Callable).is_valid():
		return
	var display_center_for_hex = state.get("display_center_for_hex")
	if not (display_center_for_hex is Callable) or not (display_center_for_hex as Callable).is_valid():
		return

	draw_loop_cell_outlines(canvas, state)
	_draw_movement_range_overlay(canvas, movement_range_overlay, visual_hexes_for_draw, display_center_for_hex, flat_top, hex_size)
	_draw_highlights(canvas, highlights, visual_hexes_for_draw, display_center_for_hex, flat_top, hex_size)
	_draw_path(canvas, display_path, path_color, display_center_for_hex)


func draw_loop_cell_outlines(canvas: Node2D, state: Dictionary) -> void:
	if canvas == null or not is_instance_valid(canvas):
		return
	if not bool(state.get("loop_display_enabled", false)):
		return
	if not bool(state.get("uses_toric_visuals", false)):
		return
	var loop_cells = state.get("loop_cells", null)
	if loop_cells == null or not loop_cells is Array or loop_cells.is_empty():
		return
	var loop_display_margin = int(state.get("loop_display_margin", 1))
	var visual_hexes_for_draw = state.get("visual_hexes_for_draw")
	if not (visual_hexes_for_draw is Callable) or not (visual_hexes_for_draw as Callable).is_valid():
		return
	var visual_representatives_for_cell = state.get("visual_representatives_for_cell")
	if not (visual_representatives_for_cell is Callable) or not (visual_representatives_for_cell as Callable).is_valid():
		return
	var display_center_for_hex = state.get("display_center_for_hex")
	if not (display_center_for_hex is Callable) or not (display_center_for_hex as Callable).is_valid():
		return
	var flat_top = bool(state.get("flat_top", true))
	var hex_size = float(state.get("hex_size", 24.0))
	var loop_display_rect = state.get("loop_display_rect", Rect2())
	if not loop_cells is Array:
		return

	for raw_hex in loop_cells:
		var canonical = _coerce_hex(raw_hex)
		if canonical == null:
			continue
		var raw_visual_hexes = visual_representatives_for_cell.call(canonical, loop_display_rect, loop_display_margin)
		if not raw_visual_hexes is Array:
			continue
		for raw_visual_hex in raw_visual_hexes:
			var visual_hex = _coerce_hex(raw_visual_hex)
			if visual_hex == null:
				continue
			if visual_hex.key() == canonical.key():
				continue
			var center = display_center_for_hex.call(visual_hex)
			draw_hex_highlight(canvas, center, DEFAULT_LOOP_OUTLINE_COLOR, flat_top, hex_size)


func _draw_movement_range_overlay(
	canvas: Node2D,
	movement_range_overlay: Dictionary,
	visual_hexes_for_draw: Callable,
	display_center_for_hex: Callable,
	flat_top: bool,
	hex_size: float
) -> void:
	if not movement_range_overlay is Dictionary:
		return
	for key in movement_range_overlay:
		var record = movement_range_overlay[key]
		if not (record is Dictionary):
			continue
		var raw_hex = record.get("hex", null)
		var canonical = _coerce_hex(raw_hex)
		if canonical == null:
			continue
		var color = _coerce_color(record.get("color", Color.WHITE))
		var raw_visual_hexes = visual_hexes_for_draw.call(canonical)
		if not raw_visual_hexes is Array:
			continue
		var visual_hexes: Array = raw_visual_hexes
		var outline = Color(color.r, color.g, color.b, RANGE_OUTLINE_ALPHA)
		for raw_visual_hex in visual_hexes:
			var visual_hex = _coerce_hex(raw_visual_hex)
			if visual_hex == null:
				continue
			var center = display_center_for_hex.call(visual_hex)
			draw_hex_fill(canvas, center, color, outline, flat_top, hex_size)


func _draw_highlights(
	canvas: Node2D,
	highlights: Dictionary,
	visual_hexes_for_draw: Callable,
	display_center_for_hex: Callable,
	flat_top: bool,
	hex_size: float
) -> void:
	if not highlights is Dictionary:
		return
	for key in highlights:
		var entry = highlights[key]
		if not (entry is Dictionary):
			continue
		var raw_hex = entry.get("hex", null)
		var canonical = _coerce_hex(raw_hex)
		if canonical == null:
			continue
		var color = _coerce_color(entry.get("color", Color.WHITE))
		var raw_visual_hexes = visual_hexes_for_draw.call(canonical)
		if not raw_visual_hexes is Array:
			continue
		var visual_hexes: Array = raw_visual_hexes
		for raw_visual_hex in visual_hexes:
			var visual_hex = _coerce_hex(raw_visual_hex)
			if visual_hex == null:
				continue
			var center = display_center_for_hex.call(visual_hex)
			draw_hex_highlight(canvas, center, color, flat_top, hex_size)


func _draw_path(
	canvas: Node2D,
	display_path: Array,
	path_color: Color,
	display_center_for_hex: Callable
) -> void:
	if not display_path is Array:
		return
	if display_path.size() <= 1:
		return
	var points := PackedVector2Array()
	for raw_hex in display_path:
		var hex = _coerce_hex(raw_hex)
		if hex == null:
			continue
		points.append(display_center_for_hex.call(hex))
	if points.is_empty():
		return
	canvas.draw_polyline(points, path_color, DEFAULT_PATH_OUTLINE_WIDTH, true)
	if points.size() > 0 and canvas.has_method("draw_circle"):
		canvas.draw_circle(points[0], DEFAULT_PATH_MARKER_RADIUS, DEFAULT_PATH_START_COLOR)
		canvas.draw_circle(points[points.size() - 1], DEFAULT_PATH_MARKER_RADIUS, DEFAULT_PATH_END_COLOR)


func draw_hex_highlight(
	canvas: Node2D,
	center: Vector2,
	color: Color,
	flat_top: bool,
	hex_size: float
) -> void:
	if center.is_finite() == false:
		return
	var points = _hex_polygon(center, flat_top, hex_size)
	var outline = points
	outline.append(points[0])
	canvas.draw_polyline(outline, color, DEFAULT_HEX_HIGHLIGHT_WIDTH)


func draw_hex_fill(
	canvas: Node2D,
	center: Vector2,
	fill: Color,
	outline_color: Color = Color.TRANSPARENT,
	flat_top: bool = true,
	hex_size: float = 24.0
) -> void:
	if center.is_finite() == false:
		return
	var points = _hex_polygon(center, flat_top, hex_size)
	canvas.draw_colored_polygon(points, fill)
	if outline_color.a <= 0.0:
		return
	var outline = points
	outline.append(points[0])
	canvas.draw_polyline(outline, outline_color, DEFAULT_HEX_FILL_OUTLINE_WIDTH)


func _hex_polygon(center: Vector2, flat_top: bool, hex_size: float) -> PackedVector2Array:
	var points: PackedVector2Array = []
	var rotation = 0.0 if flat_top else 30.0
	for index in range(6):
		var angle = deg_to_rad(rotation + 60.0 * float(index))
		points.append(center + Vector2(cos(angle), sin(angle)) * hex_size)
	return points


func _coerce_color(value: Variant) -> Color:
	if value is Color:
		return value as Color
	if value is Dictionary and value.has("r") and value.has("g") and value.has("b") and value.has("a"):
		return Color(
			float(value.get("r", 1.0)),
			float(value.get("g", 1.0)),
			float(value.get("b", 1.0)),
			float(value.get("a", 1.0))
		)
	return Color.WHITE


func _coerce_hex(raw_hex: Variant) -> HexVector:
	if raw_hex is HexVector:
		return raw_hex as HexVector
	if raw_hex is Vector3i:
		return HexVector.apply_basis(raw_hex.x, raw_hex.y, raw_hex.z)
	return null
