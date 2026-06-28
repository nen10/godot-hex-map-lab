extends SceneTree

const HexMapWorkspace = preload("res://addons/hex_map_kit/editor/hex_map_workspace.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")

const TASK_ID := "REPAIR-10_BUILD_GENERATE_VIEWPORT_AND_GRAPH_RECOVERY"
const VIEWPORT_SIZE := Vector2i(1280, 780)

var _artifact_dir := ""
var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_artifact_dir = _output_dir()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_artifact_dir))
	root.size = VIEWPORT_SIZE

	var scene_root := Node2D.new()
	scene_root.name = "ProbeSceneRoot"
	root.add_child(scene_root)

	var target_layer := HexTileMapLayer.new()
	target_layer.name = "ProbeBuildHexMapLayer"
	scene_root.add_child(target_layer)

	var workspace := HexMapWorkspace.new()
	workspace.name = "ProbeWorkspace"
	workspace.visible = false
	root.add_child(workspace)
	await process_frame

	workspace.set_selected_hex_tile_map_node(target_layer, "probe.repair10.selected_layer")
	var button = workspace.build_screen().find_child("Build Generate Button", true, false) as Button
	if button != null:
		button.emit_signal("pressed")
	var progress_snapshot := workspace.generation_screen_snapshot()
	await _wait_for_build_screen_idle(workspace.build_screen())
	await process_frame

	var snapshot := workspace.generation_screen_snapshot()
	var apply_report := snapshot.get("viewport_apply_report", {}) as Dictionary
	var raster_report := _capture_viewport_png()
	var report := {
		"schema": "hex_map_repair10_build_generate_viewport_probe.v1",
		"task_id": TASK_ID,
		"viewport_size": _vector2i_dict(VIEWPORT_SIZE),
		"artifact_dir": ProjectSettings.globalize_path(_artifact_dir),
		"button_found": button != null,
		"progress_popup_visible_after_press": bool(progress_snapshot.get("run_progress_popup_visible", false)),
		"progress_cancel_location": String(progress_snapshot.get("cancel_button_location", "")),
		"run_busy_after_press": bool(progress_snapshot.get("run_busy", false)),
		"selected_layer_name": target_layer.name,
		"selected_layer_path": str(target_layer.get_path()) if target_layer.is_inside_tree() else "",
		"selected_layer_inside_tree": target_layer.is_inside_tree(),
		"selected_layer_display_used_cell_count": target_layer.display_used_cell_count(),
		"selected_layer_display_status": target_layer.display_layer_status(),
		"snapshot": _sanitize_for_json(snapshot),
		"viewport_apply_report": _sanitize_for_json(apply_report),
		"viewport_projection_ok": bool(apply_report.get("projection_ok", false)),
		"viewport_preview_visible": bool(snapshot.get("viewport_preview_visible", false)),
		"preview_commit_state": String(snapshot.get("preview_commit_state", "")),
		"node_thumbnail_secondary": bool(snapshot.get("node_thumbnail_secondary", false)),
		"raster_capture": raster_report,
	}
	_validate_report(report)

	_write_text("%s/build_generate_viewport_probe.json" % _artifact_dir, JSON.stringify(report, "\t"))

	workspace.queue_free()
	scene_root.queue_free()
	await process_frame
	_finish(report)


func _validate_report(report: Dictionary) -> void:
	if not bool(report.get("button_found", false)):
		_failures.append("Build Generate button was not found.")
	if not bool(report.get("progress_popup_visible_after_press", false)):
		_failures.append("Build Generate did not show the progress popup immediately.")
	if String(report.get("progress_cancel_location", "")) != "popup":
		_failures.append("Build Generate cancel action was not hosted by the progress popup.")
	if not bool(report.get("selected_layer_inside_tree", false)):
		_failures.append("Selected target layer is not inside the scene tree.")
	if int(report.get("selected_layer_display_used_cell_count", 0)) <= 0:
		_failures.append("Selected target layer has no display cells after Generate.")
	if not bool(report.get("viewport_projection_ok", false)):
		_failures.append("Viewport projection report is not ok.")
	if not bool(report.get("viewport_preview_visible", false)):
		_failures.append("Build snapshot does not report a visible viewport preview.")
	if String(report.get("preview_commit_state", "")) != "preview_pending":
		_failures.append("Generate did not leave a pending Apply/Revert preview.")
	if not bool(report.get("node_thumbnail_secondary", false)):
		_failures.append("Build snapshot does not mark node thumbnail as secondary.")


func _wait_for_build_screen_idle(screen) -> void:
	for _i in range(240):
		var snapshot: Dictionary = screen.build_screen_snapshot()
		if not bool(snapshot.get("run_busy", false)):
			return
		await process_frame
	_failures.append("Build Generate did not finish within the visual probe budget.")


func _capture_viewport_png() -> Dictionary:
	if DisplayServer.get_name() == "headless":
		return {
			"status": "skipped",
			"reason": "headless display driver",
			"png_path": "",
		}
	var texture := root.get_texture()
	if texture == null:
		return {
			"status": "not_available",
			"reason": "root viewport texture is null",
			"png_path": "",
		}
	var image := texture.get_image()
	if image == null or image.get_width() <= 0 or image.get_height() <= 0:
		return {
			"status": "not_available",
			"reason": "root viewport image is empty",
			"png_path": "",
		}
	var png_path := "%s/build_generate_viewport_probe.png" % _artifact_dir
	var save_error := image.save_png(ProjectSettings.globalize_path(png_path))
	var image_report := _analyze_image(image)
	image_report["status"] = "saved" if save_error == OK else "save_failed"
	image_report["save_error"] = save_error
	image_report["png_path"] = ProjectSettings.globalize_path(png_path) if save_error == OK else ""
	return image_report


func _analyze_image(image: Image) -> Dictionary:
	var width := image.get_width()
	var height := image.get_height()
	var step_x = max(1, width / 80)
	var step_y = max(1, height / 50)
	var sample_count := 0
	var non_background_samples := 0
	for y in range(0, height, step_y):
		for x in range(0, width, step_x):
			sample_count += 1
			var pixel := image.get_pixel(x, y)
			if pixel.a > 0.05 and pixel.get_luminance() > 0.03:
				non_background_samples += 1
	return {
		"width": width,
		"height": height,
		"sample_count": sample_count,
		"non_background_samples": non_background_samples,
	}


func _sanitize_for_json(value):
	if value == null or value is bool or value is int or value is float or value is String:
		return value
	if value is Vector2:
		return {"x": value.x, "y": value.y}
	if value is Vector2i:
		return {"x": value.x, "y": value.y}
	if value is Vector3i:
		return {"x": value.x, "y": value.y, "z": value.z}
	if value is Rect2:
		return {
			"x": value.position.x,
			"y": value.position.y,
			"w": value.size.x,
			"h": value.size.y,
		}
	if value is Color:
		return {"r": value.r, "g": value.g, "b": value.b, "a": value.a}
	if value is PackedStringArray:
		var strings: Array = []
		for item in value:
			strings.append(String(item))
		return strings
	if value is Array:
		var result: Array = []
		for item in value:
			result.append(_sanitize_for_json(item))
		return result
	if value is Dictionary:
		var result := {}
		for key in value.keys():
			result[String(key)] = _sanitize_for_json(value[key])
		return result
	if value is Node:
		var node := value as Node
		return {
			"node_name": node.name,
			"node_path": str(node.get_path()) if node.is_inside_tree() else node.name,
		}
	if value is Resource:
		var resource := value as Resource
		return {
			"resource_class": resource.get_class(),
			"resource_path": resource.resource_path,
			"resource_name": resource.resource_name,
		}
	return str(value)


func _write_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_failures.append("Cannot write %s: error %s" % [path, str(FileAccess.get_open_error())])
		return
	file.store_string(text)
	file.close()


func _output_dir() -> String:
	var run_id := OS.get_environment("HEX_MAP_VISUAL_RUN_ID")
	if run_id.is_empty():
		run_id = Time.get_datetime_string_from_system(false, true).replace(":", "").replace(" ", "_")
	return "res://.godot_user/visual-verification/%s/%s" % [TASK_ID, _safe_path_part(run_id)]


func _safe_path_part(value: String) -> String:
	var result := ""
	for index in value.length():
		var character := value[index]
		if character.is_valid_identifier() or character.is_valid_int() or character in ["-", "_"]:
			result += character
		else:
			result += "_"
	return result


func _vector2i_dict(value: Vector2i) -> Dictionary:
	return {
		"x": value.x,
		"y": value.y,
	}


func _finish(report: Dictionary) -> void:
	if _failures.is_empty():
		print("%s viewport probe passed" % TASK_ID)
		print("artifact_dir=%s" % String(report.get("artifact_dir", "")))
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)
