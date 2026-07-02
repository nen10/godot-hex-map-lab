extends SceneTree

const HexMapBuildGraphCanvas = preload("res://addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd")
const NT = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const Schema = preload("res://addons/hex_map_kit/generation/hex_generation_param_schema.gd")


func _init() -> void:
	_run.call_deferred()


func _capture(name: String) -> void:
	await process_frame
	await process_frame
	await process_frame
	var img := get_root().get_texture().get_image()
	var dir := "res://.godot_user/visual-verification/GQM-12"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	img.save_png("%s/%s.png" % [dir, name])
	print("saved %s/%s.png" % [dir, name])


func _run() -> void:
	get_root().size = Vector2i(1100, 800)
	var canvas = HexMapBuildGraphCanvas.new()
	get_root().add_child(canvas)
	await process_frame
	canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.size = Vector2(1100, 800)
	await process_frame

	var tg = canvas.add_graph_node(NT.NODE_TERRAIN_GENERATION, Vector2(30, 60), "terrain")
	var ig_a = canvas.add_graph_node(NT.NODE_ITEM_GENERATION, Vector2(30, 300), "treasure")
	var ig_b = canvas.add_graph_node(NT.NODE_ITEM_GENERATION, Vector2(30, 520), "doors")
	var result = canvas.add_graph_node(NT.NODE_RESULT, Vector2(560, 120), "result")
	canvas.request_connection(tg, 0, ig_a, canvas._slot_for_input_name(ig_a, "domain"))
	canvas.request_connection(tg, 0, ig_b, canvas._slot_for_input_name(ig_b, "domain"))
	canvas.request_connection(tg, 0, result, canvas._slot_for_input_name(result, "in_0"))
	canvas.request_connection(ig_a, 0, result, canvas._slot_for_input_name(result, "in_1"))
	canvas.request_connection(ig_b, 0, result, canvas._slot_for_input_name(result, "in_2"))
	var report = canvas.run_graph()
	print("run ok=%s" % str(report.get("ok", false)))
	canvas.select_graph_node(result)
	await _capture("result_stack_rows")
	quit()
