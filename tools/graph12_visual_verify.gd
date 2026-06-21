extends SceneTree

const HexMapBuildScreen = preload("res://addons/hex_map_kit/editor/hex_map_build_screen.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")

const TASK_ID := "GRAPH-12_VERTICAL_SLICE_THREE_NODE_CHAIN"
const VIEWPORT_SIZE := Vector2i(1180, 760)

var _failures: Array[String] = []
var _artifact_dir := ""


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_artifact_dir = _output_dir()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_artifact_dir))
	root.size = VIEWPORT_SIZE

	var context := HexMapWorkspaceAssetContext.new()
	context.set_level_document(HexMapDocumentResource.new())

	var screen := HexMapBuildScreen.new()
	screen.name = "Graph12VisualBuildScreen"
	screen.size = Vector2(VIEWPORT_SIZE)
	screen.custom_minimum_size = Vector2(VIEWPORT_SIZE)
	screen.set_workspace_asset_context(context)
	root.add_child(screen)
	await process_frame

	var run_report := screen.build_vertical_slice_chain_and_preview()
	await process_frame
	var snapshot := screen.build_screen_snapshot()
	var promote_report := screen.promote_selected_output("overlay")
	await process_frame

	var layout_snapshot := _collect_layout_snapshot(screen)
	var raster_report := _capture_viewport_png()

	var document_report := _document_report(context.level_document)
	var canvas := snapshot.get("canvas", {}) as Dictionary
	var report := {
		"schema": "hex_map_graph12_visual_verification.v1",
		"task_id": TASK_ID,
		"viewport_size": _vector2i_dict(VIEWPORT_SIZE),
		"artifact_dir": ProjectSettings.globalize_path(_artifact_dir),
		"run_ok": bool(run_report.get("ok", false)),
		"node_count": int(canvas.get("node_count", 0)),
		"connection_count": int(canvas.get("connection_count", 0)),
		"selected_node_id": String(canvas.get("selected_node_id", "")),
		"preview_available": bool(snapshot.get("preview_available", false)),
		"promote_available": bool(snapshot.get("promote_available", false)),
		"promote_ok": bool(promote_report.get("ok", false)),
		"document": document_report,
		"layout": _layout_report(layout_snapshot),
		"raster_capture": raster_report,
	}
	_validate_report(report)

	var json_path := "%s/graph12_visual_verification.json" % _artifact_dir
	var markdown_path := "%s/graph12_visual_verification.md" % _artifact_dir
	_write_text(json_path, JSON.stringify(report, "\t"))
	_write_text(markdown_path, _markdown_report(report))

	screen.queue_free()
	await process_frame
	_finish(report)


func _validate_report(report: Dictionary) -> void:
	if not bool(report.get("run_ok", false)):
		_failures.append("Vertical slice graph did not run.")
	if not bool(report.get("preview_available", false)):
		_failures.append("Selected weighted item output preview is unavailable.")
	if not bool(report.get("promote_available", false)):
		_failures.append("Promote action is unavailable with a Level Document context.")
	if not bool(report.get("promote_ok", false)):
		_failures.append("Selected output did not promote to overlay.")
	var document := report.get("document", {}) as Dictionary
	if int(document.get("overlay_layers", 0)) <= 0:
		_failures.append("Promote did not create a document overlay layer.")
	if int(document.get("generated_overlay_cells", 0)) <= 0:
		_failures.append("Promoted overlay layer has no generated item cells.")
	if int(report.get("node_count", 0)) < 5:
		_failures.append("Vertical slice canvas does not expose five graph nodes.")
	if int(report.get("connection_count", 0)) < 4:
		_failures.append("Vertical slice canvas does not expose four graph connections.")
	var layout := report.get("layout", {}) as Dictionary
	if int(layout.get("control_count", 0)) <= 0:
		_failures.append("Headless layout snapshot has no visible controls.")
	if not bool(layout.get("has_graph_canvas", false)):
		_failures.append("Build Graph Canvas is not visible in the layout snapshot.")
	if not bool(layout.get("has_apply_button", false)):
		_failures.append("Build Apply Button is not visible in the layout snapshot.")
	if not bool(layout.get("has_revert_button", false)):
		_failures.append("Build Revert Button is not visible in the layout snapshot.")
	if not bool(layout.get("has_inspector", false)):
		_failures.append("Build Node Inspector is not visible in the layout snapshot.")
	if not bool(layout.get("has_generate_action", false)):
		_failures.append("Generate action is not visible in the layout snapshot.")


func _capture_viewport_png() -> Dictionary:
	if DisplayServer.get_name() == "headless":
		return {
			"status": "skipped",
			"reason": "Godot --headless uses the headless display driver; this verification records visual Control layout instead.",
			"png_path": "",
		}
	var png_path := "%s/build_screen_after_promote.png" % _artifact_dir
	var texture := root.get_texture()
	if texture == null:
		return {
			"status": "not_available",
			"reason": "root viewport texture is null under headless display",
			"png_path": "",
		}
	var image := texture.get_image()
	if image == null or image.get_width() <= 0 or image.get_height() <= 0:
		return {
			"status": "not_available",
			"reason": "root viewport image is empty under headless display",
			"png_path": "",
		}
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
	var total_samples := 0
	var non_background_samples := 0
	var colors := {}
	for y in range(0, height, step_y):
		for x in range(0, width, step_x):
			total_samples += 1
			var pixel := image.get_pixel(x, y)
			if pixel.a > 0.05 and pixel.get_luminance() > 0.03:
				non_background_samples += 1
			var bucket := "%02x%02x%02x" % [
				int(clamp(pixel.r * 15.0, 0.0, 15.0)),
				int(clamp(pixel.g * 15.0, 0.0, 15.0)),
				int(clamp(pixel.b * 15.0, 0.0, 15.0)),
			]
			colors[bucket] = true
	return {
		"width": width,
		"height": height,
		"sample_count": total_samples,
		"non_background_samples": non_background_samples,
		"approx_distinct_colors": colors.size(),
	}


func _document_report(document: HexMapDocumentResource) -> Dictionary:
	var generated_overlay_cells := 0
	if document != null:
		for layer in document.overlay_layers:
			if layer != null and String(layer.metadata.get("writable_source", "")) == "generated":
				var overlay = layer.overlay.to_overlay_data()
				for item_key in overlay.item_keys():
					generated_overlay_cells += overlay.item_cells(String(item_key)).size()
	return {
		"overlay_layers": document.overlay_layers.size() if document != null else 0,
		"terrain_layers": document.terrain_layers.size() if document != null else 0,
		"object_placements": document.object_placements.size() if document != null else 0,
		"generated_overlay_cells": generated_overlay_cells,
	}


func _layout_report(snapshot: Dictionary) -> Dictionary:
	var controls = snapshot.get("controls", []) as Array
	return {
		"control_count": int(snapshot.get("control_count", 0)),
		"has_graph_canvas": _has_control_name(controls, "Build Graph Canvas"),
		"has_node_palette": _has_control_name(controls, "Build Node Palette"),
		"has_apply_button": _has_control_name(controls, "Build Apply Button"),
		"has_revert_button": _has_control_name(controls, "Build Revert Button"),
		"has_inspector": _has_control_script(controls, "hex_map_build_node_inspector.gd"),
		"has_generate_action": _has_control_name(controls, "Build Generate Button"),
		"graph_canvas_rect": _rect_for_control_name(controls, "Build Graph Canvas"),
		"inspector_rect": _rect_for_control_script(controls, "hex_map_build_node_inspector.gd"),
	}


func _collect_layout_snapshot(root_control: Control) -> Dictionary:
	var controls: Array[Dictionary] = []
	if root_control != null:
		root_control.force_update_transform()
		_collect_visible_controls(root_control, root_control, controls)
	return {
		"schema": "hex_map_graph12_visual_layout_snapshot.v1",
		"task_id": TASK_ID,
		"viewport_size": _vector2i_dict(VIEWPORT_SIZE),
		"control_count": controls.size(),
		"controls": controls,
	}


func _collect_visible_controls(root_control: Control, node: Node, controls: Array[Dictionary]) -> void:
	if node is Control:
		var control := node as Control
		if control.is_visible_in_tree():
			controls.append(_control_snapshot(root_control, control))
	for child in node.get_children():
		_collect_visible_controls(root_control, child, controls)


func _control_snapshot(root_control: Control, control: Control) -> Dictionary:
	var rect := control.get_global_rect()
	return {
		"path": "." if control == root_control else str(root_control.get_path_to(control)),
		"name": control.name,
		"class": control.get_class(),
		"script": _script_path(control),
		"rect": _rect2_dict(rect),
		"text": _control_text(control),
	}


func _script_path(control: Control) -> String:
	var script = control.get_script()
	if script is Resource:
		return String((script as Resource).resource_path)
	return ""


func _control_text(control: Control) -> String:
	if control is Label:
		return (control as Label).text
	if control is Button:
		return (control as Button).text
	if control is LineEdit:
		return (control as LineEdit).text
	if control is TextEdit:
		return (control as TextEdit).text
	return ""


func _has_control_name(controls: Array, expected_name: String) -> bool:
	for entry in controls:
		var control := entry as Dictionary
		if String(control.get("name", "")) == expected_name:
			return true
	return false


func _has_control_script(controls: Array, script_name: String) -> bool:
	for entry in controls:
		var control := entry as Dictionary
		if String(control.get("script", "")).ends_with(script_name):
			return true
	return false


func _rect_for_control_name(controls: Array, expected_name: String) -> Dictionary:
	for entry in controls:
		var control := entry as Dictionary
		if String(control.get("name", "")) == expected_name:
			return (control.get("rect", {}) as Dictionary).duplicate(true)
	return {}


func _rect_for_control_script(controls: Array, script_name: String) -> Dictionary:
	for entry in controls:
		var control := entry as Dictionary
		if String(control.get("script", "")).ends_with(script_name):
			return (control.get("rect", {}) as Dictionary).duplicate(true)
	return {}


func _markdown_report(report: Dictionary) -> String:
	var layout := report.get("layout", {}) as Dictionary
	var raster := report.get("raster_capture", {}) as Dictionary
	var document := report.get("document", {}) as Dictionary
	var lines: Array[String] = []
	lines.append("# GRAPH-12 Headless Visual Verification")
	lines.append("")
	lines.append("- task: `%s`" % TASK_ID)
	lines.append("- artifact_dir: `%s`" % String(report.get("artifact_dir", "")))
	lines.append("- png: `%s`" % String(report.get("png_path", "")))
	lines.append("- run_ok: `%s`" % str(report.get("run_ok", false)))
	lines.append("- preview_available: `%s`" % str(report.get("preview_available", false)))
	lines.append("- promote_available: `%s`" % str(report.get("promote_available", false)))
	lines.append("- promote_ok: `%s`" % str(report.get("promote_ok", false)))
	lines.append("- node_count: `%d`" % int(report.get("node_count", 0)))
	lines.append("- connection_count: `%d`" % int(report.get("connection_count", 0)))
	lines.append("- selected_node_id: `%s`" % String(report.get("selected_node_id", "")))
	lines.append("- visible_controls: `%d`" % int(layout.get("control_count", 0)))
	lines.append("- has_graph_canvas: `%s`" % str(layout.get("has_graph_canvas", false)))
	lines.append("- has_node_palette: `%s`" % str(layout.get("has_node_palette", false)))
	lines.append("- has_output_preview: `%s`" % str(layout.get("has_output_preview", false)))
	lines.append("- has_apply_button: `%s`" % str(layout.get("has_apply_button", false)))
	lines.append("- has_revert_button: `%s`" % str(layout.get("has_revert_button", false)))
	lines.append("- has_inspector: `%s`" % str(layout.get("has_inspector", false)))
	lines.append("- has_generate_action: `%s`" % str(layout.get("has_generate_action", false)))
	lines.append("- raster_capture_status: `%s`" % String(raster.get("status", "")))
	lines.append("- raster_png: `%s`" % String(raster.get("png_path", "")))
	lines.append("- document_overlay_layers: `%d`" % int(document.get("overlay_layers", 0)))
	lines.append("- generated_overlay_cells: `%d`" % int(document.get("generated_overlay_cells", 0)))
	lines.append("")
	lines.append("## Criteria")
	lines.append("")
	lines.append("- Shape -> Wall Field -> Connectivity -> Region Filter -> Item Generator runs.")
	lines.append("- Selected weighted item output has a preview before promotion.")
	lines.append("- Promote is enabled with a Level Document context and writes a generated overlay layer.")
	lines.append("- The headless layout snapshot exposes the graph canvas, palette, output preview, inspector, and Generate action.")
	lines.append("- A viewport PNG is saved when the headless renderer exposes a non-empty root viewport texture; this is supplementary, not the completion gate.")
	lines.append("")
	return "\n".join(lines)


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


func _rect2_dict(value: Rect2) -> Dictionary:
	return {
		"x": value.position.x,
		"y": value.position.y,
		"w": value.size.x,
		"h": value.size.y,
	}


func _finish(report: Dictionary) -> void:
	if _failures.is_empty():
		print("%s visual verification passed" % TASK_ID)
		print("artifact_dir=%s" % String(report.get("artifact_dir", "")))
		print("png=%s" % String(report.get("png_path", "")))
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)
