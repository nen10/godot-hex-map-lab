extends SceneTree

const HexMapBuildGraphCanvas = preload("res://addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd")
const HexMapBuildNodeInspector = preload("res://addons/hex_map_kit/editor/hex_map_build_node_inspector.gd")
const NT = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const Schema = preload("res://addons/hex_map_kit/generation/hex_generation_param_schema.gd")


func _init() -> void:
	_run.call_deferred()


func _capture(name: String) -> void:
	await process_frame
	await process_frame
	await process_frame
	var img := get_root().get_texture().get_image()
	var dir := "res://.godot_user/visual-verification/GQM-11"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	img.save_png("%s/%s.png" % [dir, name])
	print("saved %s/%s.png" % [dir, name])


func _run() -> void:
	get_root().size = Vector2i(1480, 940)
	var split := HSplitContainer.new()
	split.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_root().add_child(split)
	var canvas = HexMapBuildGraphCanvas.new()
	canvas.custom_minimum_size = Vector2(980, 940)
	split.add_child(canvas)
	var inspector = HexMapBuildNodeInspector.new()
	inspector.custom_minimum_size = Vector2(460, 940)
	split.add_child(inspector)
	await process_frame

	var terrain_params = Schema.default_params(NT.NODE_TERRAIN_GENERATION)
	terrain_params["wall_method"] = "markov_mesh"
	terrain_params["distribution_mode"] = "preset"
	terrain_params["distribution_id"] = 20
	var tg = canvas.add_graph_node(NT.NODE_TERRAIN_GENERATION, Vector2(40, 60), "terrain", terrain_params)
	var ig = canvas.add_graph_node(NT.NODE_ITEM_GENERATION, Vector2(420, 60), "items")
	var so = canvas.add_graph_node(NT.NODE_SET_OPERATION, Vector2(40, 420), "mask_1")
	canvas.request_connection(tg, 0, so, canvas._slot_for_input_name(so, "in_0"))
	canvas.request_connection(so, 0, ig, canvas._slot_for_input_name(ig, "domain"))
	canvas.select_graph_node(tg)
	await process_frame

	inspector.inspect_node({"id": "terrain", "type": NT.NODE_TERRAIN_GENERATION, "params": terrain_params, "resource_refs": {}}, "terrain")
	await _capture("terrain_schema_inspector_and_chips")

	var item_params = Schema.default_params(NT.NODE_ITEM_GENERATION)
	inspector.inspect_node({"id": "items", "type": NT.NODE_ITEM_GENERATION, "params": item_params, "resource_refs": {}}, "overlay")
	await _capture("item_generation_weighted_before_morph")

	inspector.set_param("placement_method", "adjacency_rules")
	await _capture("item_generation_adjacency_after_morph")
	quit()
