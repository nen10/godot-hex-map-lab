extends SceneTree
const Inspector = preload("res://addons/hex_map_kit/editor/hex_map_build_node_inspector.gd")
const NT = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")

func _init() -> void:
	_run.call_deferred()

func _capture(name: String) -> void:
	await process_frame
	await process_frame
	var img := get_root().get_texture().get_image()
	var dir := "res://.godot_user/visual-verification/REPAIR-17-18"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	img.save_png("%s/%s.png" % [dir, name])
	print("saved %s/%s.png size=%s" % [dir, name, str(img.get_size())])

func _run() -> void:
	get_root().size = Vector2i(900, 760)
	# Markov distribution window
	var insp_m := Inspector.new()
	get_root().add_child(insp_m)
	await process_frame
	insp_m.inspect_node({"id": "walls", "type": NT.NODE_WALL_FIELD, "params": {"wall_method": "markov_mesh", "distribution_mode": "custom"}, "resource_refs": {}}, "terrain")
	await process_frame
	insp_m._open_markov_distribution_dialog(null)
	await _capture("markov_distribution_window")
	var mw = insp_m.find_child("Markov Distribution Window", true, false)
	if mw != null:
		mw.queue_free()
	await process_frame
	# Adjacency rules window with a couple patterns
	var insp_a := Inspector.new()
	get_root().add_child(insp_a)
	await process_frame
	insp_a.inspect_node({"id": "items", "type": NT.NODE_ITEM_GENERATOR, "params": {"placement_method": "adjacency_rules", "probability_rules": {"default": 0.1, "rules": [{"directions": ["1,-1,0", "1,0,-1"], "probability": 0.8}, {"directions": ["0,1,-1"], "probability": 0.3}]}}, "resource_refs": {}}, "overlay")
	await process_frame
	insp_a._open_adjacency_rules_dialog(null)
	await _capture("adjacency_rules_window")
	quit()
