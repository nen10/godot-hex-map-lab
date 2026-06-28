extends SceneTree

const HexGenerationGraph = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexGenerationGraphResource = preload("res://addons/hex_map_kit/adapter/hex_generation_graph_resource.gd")
const HexMapBuildScreen = preload("res://addons/hex_map_kit/editor/hex_map_build_screen.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")

const SCHEMA := "hex_map_build_generate_phase_profile.v1"
const DEFAULT_RUN_ID_PREFIX := "build-generate-phases"

var _provider_screen: HexMapBuildScreen
var _provider_layer: HexTileMapLayer


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var run_id := _run_id()
	var output_dir := "res://.godot_user/perf/build-generate/%s" % run_id
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))

	var cases := _profile_cases()
	var results: Array = []
	for profile_case in cases:
		var result := await _measure_case(profile_case as Dictionary)
		results.append(result)
		for pass_result in result.get("passes", []) as Array:
			var pass_row = pass_result as Dictionary
			print("%s/%s total=%.3fms timings=%s" % [
				String(result.get("id", "")),
				String(pass_row.get("pass", "")),
				float(pass_row.get("total_msec", 0.0)),
				JSON.stringify(pass_row.get("timings", {})),
			])

	var report := {
		"schema": SCHEMA,
		"run_id": run_id,
		"godot_version": Engine.get_version_info(),
		"results": results,
	}
	var json_path := "%s/build_generate_phase_profile.json" % output_dir
	var md_path := "%s/build_generate_phase_profile.md" % output_dir
	_write_text(json_path, JSON.stringify(report, "\t"))
	_write_text(md_path, _markdown_report(report))
	print("Wrote %s" % ProjectSettings.globalize_path(json_path))
	print("Wrote %s" % ProjectSettings.globalize_path(md_path))
	quit(0)


func _measure_case(profile_case: Dictionary) -> Dictionary:
	var scene_root := Node2D.new()
	root.add_child(scene_root)
	var layer := HexTileMapLayer.new()
	layer.name = "%sLayer" % String(profile_case.get("id", "BuildGenerate"))
	scene_root.add_child(layer)
	var screen := HexMapBuildScreen.new()
	root.add_child(screen)
	await process_frame

	layer.generation_graph_resource = HexGenerationGraphResource.from_dict(_graph_for_case(profile_case))
	_provider_screen = screen
	_provider_layer = layer
	screen.set_build_context_provider(Callable(self, "_provide_build_context"))

	var first_pass := await _measure_generate_pass(screen, "first")
	await _wait_for_popup_hidden(screen)
	if bool(profile_case.get("force_second_recompute", false)):
		_force_second_recompute(screen)
	var second_pass := await _measure_generate_pass(screen, "second_after_popup_hide")

	scene_root.queue_free()
	screen.queue_free()
	await process_frame

	var second_timings = second_pass.get("timings", {}) as Dictionary
	return {
		"id": String(profile_case.get("id", "")),
		"params": profile_case.duplicate(true),
		"total_msec": float(second_pass.get("total_msec", 0.0)),
		"first_status": String(first_pass.get("first_status", "")),
		"first_popup_visible": bool(first_pass.get("first_popup_visible", false)),
		"final_status": String(second_pass.get("final_status", "")),
		"preview_commit_state": String(second_pass.get("preview_commit_state", "")),
		"viewport_cells": int(second_pass.get("viewport_cells", 0)),
		"timings": second_timings.duplicate(true),
		"passes": [first_pass, second_pass],
	}


func _measure_generate_pass(screen: HexMapBuildScreen, pass_id: String) -> Dictionary:
	var total_start := Time.get_ticks_usec()
	screen._begin_generate_button_run()
	await process_frame
	var first_snapshot := screen.build_screen_snapshot()
	var final_snapshot := await _wait_for_generate_finish(screen)
	var total_msec := float(Time.get_ticks_usec() - total_start) / 1000.0
	return {
		"pass": pass_id,
		"total_msec": total_msec,
		"first_status": String(first_snapshot.get("run_progress_popup_status", "")),
		"first_popup_visible": bool(first_snapshot.get("run_progress_popup_visible", false)),
		"final_status": String(final_snapshot.get("run_progress_popup_status", "")),
		"preview_commit_state": String(final_snapshot.get("preview_commit_state", "")),
		"viewport_cells": int(final_snapshot.get("viewport_preview_cell_count", 0)),
		"timings": (final_snapshot.get("run_phase_timings", {}) as Dictionary).duplicate(true),
	}


func _provide_build_context(request: Dictionary) -> Dictionary:
	var options := request.duplicate(true)
	options["run"] = false
	if not options.has("selected_node_id"):
		options["selected_node_id"] = "result"
	return _provider_screen.ensure_graph_context_for_hex_tile_map_layer(
		_provider_layer,
		options
	)


func _wait_for_generate_finish(screen: HexMapBuildScreen) -> Dictionary:
	var snapshot := screen.build_screen_snapshot()
	var guard := 0
	while bool(snapshot.get("run_busy", false)) and guard < 900:
		await process_frame
		snapshot = screen.build_screen_snapshot()
		guard += 1
	return snapshot


func _wait_for_popup_hidden(screen: HexMapBuildScreen) -> void:
	var snapshot := screen.build_screen_snapshot()
	var guard := 0
	while bool(snapshot.get("run_progress_popup_visible", false)) and guard < 120:
		await process_frame
		snapshot = screen.build_screen_snapshot()
		guard += 1


func _force_second_recompute(screen: HexMapBuildScreen) -> void:
	var canvas = screen.find_child("Build Graph Canvas", true, false)
	if canvas == null or not canvas.has_method("node_params") or not canvas.has_method("set_node_params"):
		return
	var params: Dictionary = canvas.node_params("moss")
	if params.is_empty():
		return
	var rules := params.get("probability_rules", {}) as Dictionary
	var entries := rules.get("rules", []) as Array
	if entries.is_empty() or not entries[0] is Dictionary:
		return
	var first_rule := (entries[0] as Dictionary).duplicate(true)
	first_rule["probability"] = 0.36
	entries[0] = first_rule
	rules["rules"] = entries
	params["probability_rules"] = rules
	canvas.set_node_params("moss", params)


func _graph_for_case(profile_case: Dictionary) -> Dictionary:
	var side := int(profile_case.get("side", 40))
	var neighbor_radius := int(profile_case.get("neighbor_radius", 2))
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle",
		"width": side,
		"height": side,
	})
	HexGenerationGraph.add_node(graph, "floor", "region_filter", {"filter_target": "floor"})
	HexGenerationGraph.add_node(graph, "moss", "item_generator", {
		"placement_method": "adjacency_rules",
		"item_name": "moss",
		"neighbor_radius": neighbor_radius,
		"probability_rules": {
			"default": 0.0,
			"rules": [{"count": 1, "components": 1, "probability": 0.35}],
		},
	})
	HexGenerationGraph.add_node(graph, "loot", "item_generator", {
		"placement_method": "weighted",
		"placement_probability": 0.35,
		"item_pool": [{"name": "loot", "weight": 1.0}],
	})
	HexGenerationGraph.add_node(graph, "result", "result")
	HexGenerationGraph.add_edge(graph, "shape", "floor", "in")
	HexGenerationGraph.add_edge(graph, "floor", "moss", "scope")
	HexGenerationGraph.add_edge(graph, "floor", "loot", "scope")
	HexGenerationGraph.add_edge(graph, "shape", "result", "terrain")
	HexGenerationGraph.add_edge(graph, "moss", "result", "overlay_0")
	HexGenerationGraph.add_edge(graph, "loot", "result", "overlay_1")
	return graph


func _run_id() -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--run-id="):
			return _safe_path_part(arg.substr("--run-id=".length()))
	return "%s-%d" % [DEFAULT_RUN_ID_PREFIX, Time.get_unix_time_from_system()]


func _profile_cases() -> Array:
	var requested_sides := PackedInt32Array()
	var neighbor_radius := 2
	var force_second_recompute := false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--side="):
			var parts := arg.substr("--side=".length()).split(",", false)
			for part in parts:
				var side := int(String(part).strip_edges())
				if side > 0:
					requested_sides.append(side)
		elif arg.begins_with("--neighbor-radius="):
			neighbor_radius = max(0, int(arg.substr("--neighbor-radius=".length())))
		elif arg == "--force-second-recompute":
			force_second_recompute = true
	if requested_sides.is_empty():
		requested_sides.append_array(PackedInt32Array([40, 81]))
	var cases := []
	for side in requested_sides:
		cases.append({
			"id": "build_generate_side%d_adjacency_result" % side,
			"side": side,
			"neighbor_radius": neighbor_radius,
			"force_second_recompute": force_second_recompute,
		})
	return cases


func _safe_path_part(value: String) -> String:
	var result := value.strip_edges()
	for character in ["/", "\\", ":", " ", "\t", "\n"]:
		result = result.replace(character, "-")
	return result if result != "" else DEFAULT_RUN_ID_PREFIX


func _write_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write %s" % path)
		return
	file.store_string(text)
	file.close()


func _markdown_report(report: Dictionary) -> String:
	var lines: Array[String] = [
		"# Build Generate Phase Profile",
		"",
		"| case | pass | total ms | popup present | context | graph prepare | graph run | promote | cached skip | viewport prepare | viewport apply | popup first |",
		"|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|",
	]
	for result in report.get("results", []) as Array:
		var row = result as Dictionary
		for pass_result in row.get("passes", []) as Array:
			var pass_row = pass_result as Dictionary
			var timings = pass_row.get("timings", {}) as Dictionary
			lines.append("| `%s` | `%s` | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %s |" % [
				String(row.get("id", "")),
				String(pass_row.get("pass", "")),
				float(pass_row.get("total_msec", 0.0)),
				float(timings.get("popup_present", 0.0)),
				float(timings.get("context_prepare", 0.0)),
				float(timings.get("graph_prepare", 0.0)),
				float(timings.get("graph_run", 0.0)),
				float(timings.get("preview_promote", 0.0)),
				float(timings.get("preview_cached_skip", 0.0)),
				float(timings.get("viewport_prepare_document", 0.0)),
				float(timings.get("viewport_apply_map", 0.0)),
				String(pass_row.get("first_status", "")),
			])
	return "\n".join(lines) + "\n"
