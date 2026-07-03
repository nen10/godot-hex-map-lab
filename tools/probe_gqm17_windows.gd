extends SceneTree

const Inspector = preload("res://addons/hex_map_kit/editor/hex_map_build_node_inspector.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const NT = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const Schema = preload("res://addons/hex_map_kit/generation/hex_generation_param_schema.gd")


func _init() -> void:
	_run.call_deferred()


func _capture(name: String) -> void:
	await process_frame
	await process_frame
	await process_frame
	var img := get_root().get_texture().get_image()
	var dir := "res://.godot_user/visual-verification/GQM-17"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	img.save_png("%s/%s.png" % [dir, name])
	print("saved %s" % name)


func _collect_spinboxes(root: Node) -> Array:
	var result: Array = []
	_collect_spinboxes_into(root, result)
	return result


func _collect_spinboxes_into(root: Node, result: Array) -> void:
	if root is SpinBox:
		result.append(root)
	for child in root.get_children():
		_collect_spinboxes_into(child, result)


func _verify_markov_weight_spins(window: Node) -> bool:
	var spins := _collect_spinboxes(window)
	print("markov weight spin count: %d" % spins.size())
	if spins.is_empty():
		push_error("GQM-17 Markov probe found no weight SpinBox controls.")
		return false

	var ok := true
	for index in range(spins.size()):
		var spin := spins[index] as SpinBox
		print(
			"markov weight spin[%d]: min=%.1f max=%.1f step=%.1f value=%.1f"
			% [index, spin.min_value, spin.max_value, spin.step, spin.value]
		)
		if spin.min_value > 0.0 or spin.max_value < 8.0:
			ok = false

	var first_spin := spins[0] as SpinBox
	first_spin.value = 8.0
	print(
		"markov weight spin[0] after set-to-8: value=%.1f"
		% first_spin.value
	)
	if first_spin.value < 8.0:
		ok = false
	if not ok:
		push_error("GQM-17 Markov weight spin range does not cover 0.0..8.0.")
	return ok


func _run() -> void:
	get_root().size = Vector2i(1200, 860)

	var insp_m := Inspector.new()
	get_root().add_child(insp_m)
	await process_frame
	var terrain_params = Schema.default_params(NT.NODE_TERRAIN_GENERATION)
	terrain_params["wall_method"] = "markov_mesh"
	terrain_params["distribution_mode"] = "custom"
	insp_m.inspect_node({"id": "terrain", "type": NT.NODE_TERRAIN_GENERATION, "params": terrain_params, "resource_refs": {}}, "terrain")
	await process_frame
	insp_m._open_markov_distribution_dialog(null)
	await _capture("markov_window_consolidated")
	var mw = insp_m.find_child("Markov Distribution Window", true, false)
	if mw != null:
		var markov_weight_range_ok := _verify_markov_weight_spins(mw)
		await _capture("markov_window_weight_8_probe")
		if not markov_weight_range_ok:
			quit(1)
			return
		mw.queue_free()
	else:
		push_error("GQM-17 Markov probe could not find the Markov Distribution Window.")
		quit(1)
		return
	insp_m.queue_free()
	await process_frame

	var insp_a := Inspector.new()
	get_root().add_child(insp_a)
	await process_frame
	var item_params = Schema.default_params(NT.NODE_ITEM_GENERATION)
	item_params["placement_method"] = "adjacency_rules"
	var adjacency_directions := HexVector.directions()
	var first_rule_directions := [adjacency_directions[0].key(), adjacency_directions[1].key()]
	var second_rule_directions := [adjacency_directions[2].key()]
	print("adjacency probe rule directions: %s / %s" % [str(first_rule_directions), str(second_rule_directions)])
	item_params["probability_rules"] = {"default": 0.1, "rules": [
		{"directions": first_rule_directions, "probability": 0.8},
		{"directions": second_rule_directions, "probability": 0.3},
	]}
	insp_a.inspect_node({"id": "items", "type": NT.NODE_ITEM_GENERATION, "params": item_params, "resource_refs": {}}, "overlay")
	await process_frame
	insp_a._open_adjacency_rules_dialog(null)
	await _capture("adjacency_window_consolidated")
	var aw = insp_a.find_child("Adjacency Rules Window", true, false)
	if aw != null:
		aw.queue_free()
	insp_a.queue_free()
	await process_frame

	var insp_p := Inspector.new()
	get_root().add_child(insp_p)
	await process_frame
	var pool_params = Schema.default_params(NT.NODE_ITEM_GENERATION)
	pool_params["placement_method"] = "limited"
	pool_params["item_pool"] = [
		{"name": "chest", "weight": 0.5, "limit": 2},
		{"name": "key", "weight": 0.2, "limit": 1},
	]
	insp_p.inspect_node({"id": "loot", "type": NT.NODE_ITEM_GENERATION, "params": pool_params, "resource_refs": {}}, "overlay")
	await _capture("item_pool_limited_rows")

	var snapshot_before = insp_p.inspector_snapshot()
	print("chips before: %s" % str(snapshot_before.get("criteria_chips", [])))
	insp_p.set_param("placement_method", "weighted")
	await process_frame
	var snapshot_after = insp_p.inspector_snapshot()
	print("chips after: %s" % str(snapshot_after.get("criteria_chips", [])))
	await _capture("item_pool_weighted_after_switch")
	quit()
