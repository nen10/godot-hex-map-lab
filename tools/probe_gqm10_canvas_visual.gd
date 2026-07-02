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
	var dir := "res://.godot_user/visual-verification/GQM-10"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	img.save_png("%s/%s.png" % [dir, name])
	print("saved %s/%s.png size=%s" % [dir, name, str(img.get_size())])


func _run() -> void:
	get_root().size = Vector2i(1480, 940)
	var canvas = HexMapBuildGraphCanvas.new()
	get_root().add_child(canvas)
	await process_frame
	canvas.custom_minimum_size = Vector2(1480, 940)
	canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.size = Vector2(1480, 940)
	canvas.zoom = 0.85
	await process_frame

	var tg_map = canvas.add_graph_node(NT.NODE_TERRAIN_GENERATION, Vector2(40, 60), "terrain")
	var tg_pat = canvas.add_graph_node(NT.NODE_TERRAIN_GENERATION, Vector2(40, 520), "pattern_b")
	var ig_a = canvas.add_graph_node(NT.NODE_ITEM_GENERATION, Vector2(420, 470), "seeds_a")
	var ig_b = canvas.add_graph_node(NT.NODE_ITEM_GENERATION, Vector2(420, 700), "seeds_b")
	var so_union = canvas.add_graph_node(NT.NODE_SET_OPERATION, Vector2(760, 560), "mask_1")
	var so_inter = canvas.add_graph_node(NT.NODE_SET_OPERATION, Vector2(760, 220), "domain_items")
	var ig_items = canvas.add_graph_node(NT.NODE_ITEM_GENERATION, Vector2(1000, 260), "items")
	var result = canvas.add_graph_node(NT.NODE_RESULT, Vector2(1240, 40), "result")

	var report := {}
	report["e1"] = canvas.request_connection(tg_pat, 0, ig_a, canvas._slot_for_input_name(ig_a, "domain"))
	report["e2"] = canvas.request_connection(tg_pat, 0, ig_b, canvas._slot_for_input_name(ig_b, "domain"))
	report["e3"] = canvas.request_connection(ig_a, 0, so_union, canvas._slot_for_input_name(so_union, "in_0"))
	report["e4"] = canvas.request_connection(ig_b, 0, so_union, canvas._slot_for_input_name(so_union, "in_1"))
	report["e5"] = canvas.request_connection(tg_map, 0, so_inter, canvas._slot_for_input_name(so_inter, "in_0"))
	report["e6"] = canvas.request_connection(so_union, 0, so_inter, canvas._slot_for_input_name(so_inter, "in_1"))
	report["e7"] = canvas.request_connection(so_inter, 0, ig_items, canvas._slot_for_input_name(ig_items, "domain"))
	report["e8"] = canvas.request_connection(tg_map, 0, result, canvas._slot_for_input_name(result, "in_0"))
	report["e9"] = canvas.request_connection(ig_items, 0, result, canvas._slot_for_input_name(result, "in_1"))
	for key in report.keys():
		if not bool((report[key] as Dictionary).get("ok", false)):
			print("CONNECTION FAILED %s: %s" % [key, str(report[key])])

	var run_report = canvas.run_graph()
	print("run ok=%s" % str(run_report.get("ok", false)))
	await process_frame
	canvas.scroll_offset = Vector2(0, 0)
	await _capture("basic_form_consolidated_canvas")

	var rejected = canvas.request_connection(so_inter, 0, tg_map, canvas._slot_for_input_name(tg_map, "terminals"))
	print("cycle rejected=%s reason=%s" % [str(not bool(rejected.get("ok", true))), str(rejected.get("reason", ""))])
	quit()
