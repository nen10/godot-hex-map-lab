extends SceneTree

const OUTPUT_PATH := "res://addons/hex_map_kit/assets/sample_hex_tiles.png"
const TILE_SIZE := Vector2i(64, 57)
const ATLAS_SIZE := Vector2i(128, 57)


func _init() -> void:
	var image = Image.create(ATLAS_SIZE.x, ATLAS_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	_draw_tile(image, Rect2i(Vector2i.ZERO, TILE_SIZE), Color(0.24, 0.48, 0.62), Color(0.54, 0.78, 0.88))
	_draw_tile(image, Rect2i(Vector2i(TILE_SIZE.x, 0), TILE_SIZE), Color(0.55, 0.20, 0.38), Color(0.94, 0.36, 0.58))
	var error = image.save_png(ProjectSettings.globalize_path(OUTPUT_PATH))
	if error != OK:
		push_error("Failed to write sample hex tiles: %d" % error)
		quit(1)
		return
	print("Wrote %s" % OUTPUT_PATH)
	quit(0)


func _draw_tile(image: Image, rect: Rect2i, fill: Color, accent: Color) -> void:
	var points = _hex_points(rect)
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			var point = Vector2(float(x) + 0.5, float(y) + 0.5)
			if _point_in_polygon(point, points):
				var stripe = int((x + y) / 8) % 2 == 0
				image.set_pixel(x, y, accent.darkened(0.18) if stripe else fill)
	for index in range(points.size()):
		_draw_line(image, points[index], points[(index + 1) % points.size()], Color(0.08, 0.09, 0.10, 1.0))


func _hex_points(rect: Rect2i) -> Array:
	var left = float(rect.position.x)
	var top = float(rect.position.y)
	var width = float(rect.size.x)
	var height = float(rect.size.y)
	var inset = width * 0.25
	return [
		Vector2(left + inset, top + 1.0),
		Vector2(left + width - inset, top + 1.0),
		Vector2(left + width - 1.0, top + height * 0.5),
		Vector2(left + width - inset, top + height - 2.0),
		Vector2(left + inset, top + height - 2.0),
		Vector2(left + 1.0, top + height * 0.5),
	]


func _point_in_polygon(point: Vector2, polygon: Array) -> bool:
	var inside := false
	var previous := polygon.size() - 1
	for current in range(polygon.size()):
		var a: Vector2 = polygon[current]
		var b: Vector2 = polygon[previous]
		var intersects = ((a.y > point.y) != (b.y > point.y)) \
			and (point.x < (b.x - a.x) * (point.y - a.y) / (b.y - a.y) + a.x)
		if intersects:
			inside = not inside
		previous = current
	return inside


func _draw_line(image: Image, start: Vector2, end: Vector2, color: Color) -> void:
	var steps = int(max(abs(end.x - start.x), abs(end.y - start.y)))
	for step in range(steps + 1):
		var t = float(step) / float(max(steps, 1))
		var point = start.lerp(end, t).round()
		if point.x >= 0 and point.y >= 0 and point.x < image.get_width() and point.y < image.get_height():
			image.set_pixelv(Vector2i(point), color)
