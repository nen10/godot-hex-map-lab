extends SceneTree

const DEFAULT_KEY_THRESHOLD := 0.18


func _initialize() -> void:
	var options = _parse_args(OS.get_cmdline_user_args())
	if options.is_empty():
		_print_usage()
		quit(2)
		return

	var ok = _process_asset(options)
	quit(0 if ok else 1)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var result := {}
	var index := 0
	while index < args.size():
		var key := String(args[index])
		if not key.begins_with("--"):
			index += 1
			continue
		if index + 1 >= args.size():
			return {}
		result[key.trim_prefix("--")] = String(args[index + 1])
		index += 2

	for required in ["source", "out", "tile-width", "tile-height", "count"]:
		if not result.has(required):
			return {}
	return result


func _print_usage() -> void:
	print("Usage: godot --headless --path . --script tools/process_generated_tactics_assets.gd -- --source <png> --out <res://out.png> --tile-width <w> --tile-height <h> --count <n>")


func _process_asset(options: Dictionary) -> bool:
	var source_path := String(options["source"])
	var output_path := String(options["out"])
	var tile_width := int(options["tile-width"])
	var tile_height := int(options["tile-height"])
	var count := int(options["count"])
	var fill := float(options.get("fill", "0.98"))
	var threshold := float(options.get("threshold", str(DEFAULT_KEY_THRESHOLD)))

	var source := Image.new()
	var error := source.load(source_path)
	if error != OK:
		push_error("Failed to load source image: %s error=%d" % [source_path, error])
		return false
	source.convert(Image.FORMAT_RGBA8)
	_apply_chroma_key(source, threshold)

	var boxes = _find_subject_boxes(source, count)
	if boxes.size() != count:
		push_error("Expected %d subject boxes, got %d" % [count, boxes.size()])
		return false

	var atlas := Image.create(tile_width * count, tile_height, false, Image.FORMAT_RGBA8)
	atlas.fill(Color(0, 0, 0, 0))

	for i in range(count):
		var box: Rect2i = boxes[i]
		var tile := source.get_region(box)
		var scale = minf(float(tile_width) / float(box.size.x), float(tile_height) / float(box.size.y)) * fill
		var next_width = max(1, roundi(float(box.size.x) * scale))
		var next_height = max(1, roundi(float(box.size.y) * scale))
		tile.resize(next_width, next_height, Image.INTERPOLATE_LANCZOS)
		var dst := Vector2i(
			i * tile_width + int(floor(float(tile_width - next_width) * 0.5)),
			int(floor(float(tile_height - next_height) * 0.5))
		)
		atlas.blit_rect(tile, Rect2i(Vector2i.ZERO, Vector2i(next_width, next_height)), dst)

	var actual_output = output_path
	if output_path.begins_with("res://") or output_path.begins_with("user://"):
		actual_output = ProjectSettings.globalize_path(output_path)
	error = atlas.save_png(actual_output)
	if error != OK:
		push_error("Failed to save atlas: %s error=%d" % [actual_output, error])
		return false
	var alpha_stats = _alpha_stats(atlas)
	print("Saved tactics atlas: %s size=%dx%d transparent=%d opaque=%d" % [
		output_path,
		atlas.get_width(),
		atlas.get_height(),
		int(alpha_stats["transparent"]),
		int(alpha_stats["opaque"]),
	])
	return true


func _apply_chroma_key(image: Image, threshold: float) -> void:
	var key := image.get_pixel(0, 0)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color := image.get_pixel(x, y)
			if _is_key_color(color, key, threshold):
				color.a = 0.0
			else:
				color.a = 1.0
			image.set_pixel(x, y, color)


func _is_key_color(color: Color, key: Color, threshold: float) -> bool:
	var distance = maxf(
		absf(color.r - key.r),
		maxf(absf(color.g - key.g), absf(color.b - key.b))
	)
	if distance <= threshold:
		return true
	return color.r > 0.75 and color.b > 0.75 and color.g < 0.35


func _find_subject_boxes(image: Image, expected_count: int) -> Array[Rect2i]:
	var groups = _column_groups(image)
	if groups.size() == expected_count:
		return _boxes_for_groups(image, groups)
	return _boxes_by_even_split(image, expected_count)


func _column_groups(image: Image) -> Array[Vector2i]:
	var min_pixels = max(4, int(image.get_height() * 0.01))
	var groups: Array[Vector2i] = []
	var in_group := false
	var start := 0
	for x in range(image.get_width()):
		var count := 0
		for y in range(image.get_height()):
			if image.get_pixel(x, y).a > 0.05:
				count += 1
		if count >= min_pixels and not in_group:
			start = x
			in_group = true
		elif count < min_pixels and in_group:
			groups.append(Vector2i(start, x - 1))
			in_group = false
	if in_group:
		groups.append(Vector2i(start, image.get_width() - 1))
	return groups


func _boxes_for_groups(image: Image, groups: Array[Vector2i]) -> Array[Rect2i]:
	var boxes: Array[Rect2i] = []
	for group in groups:
		boxes.append(_subject_box_for_x_range(image, group.x, group.y))
	return boxes


func _boxes_by_even_split(image: Image, expected_count: int) -> Array[Rect2i]:
	var overall = _subject_box_for_x_range(image, 0, image.get_width() - 1)
	var boxes: Array[Rect2i] = []
	var step = float(overall.size.x) / float(expected_count)
	for i in range(expected_count):
		var start = overall.position.x + int(floor(step * float(i)))
		var end = overall.position.x + int(ceil(step * float(i + 1))) - 1
		boxes.append(_subject_box_for_x_range(image, start, end))
	return boxes


func _subject_box_for_x_range(image: Image, x_start: int, x_end: int) -> Rect2i:
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(image.get_height()):
		for x in range(max(0, x_start), min(image.get_width() - 1, x_end) + 1):
			if image.get_pixel(x, y).a <= 0.05:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	if max_x < min_x or max_y < min_y:
		return Rect2i(Vector2i(max(0, x_start), 0), Vector2i(1, 1))
	var padding := 4
	min_x = maxi(0, min_x - padding)
	min_y = maxi(0, min_y - padding)
	max_x = mini(image.get_width() - 1, max_x + padding)
	max_y = mini(image.get_height() - 1, max_y + padding)
	return Rect2i(Vector2i(min_x, min_y), Vector2i(max_x - min_x + 1, max_y - min_y + 1))


func _alpha_stats(image: Image) -> Dictionary:
	var transparent := 0
	var opaque := 0
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a <= 0.05:
				transparent += 1
			elif image.get_pixel(x, y).a >= 0.95:
				opaque += 1
	return {
		"transparent": transparent,
		"opaque": opaque,
	}
