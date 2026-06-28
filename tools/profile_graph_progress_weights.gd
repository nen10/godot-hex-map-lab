extends SceneTree

const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexOverlayData = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexGenerationNodeTypes = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const HexGenerationPorts = preload("res://addons/hex_map_kit/generation/hex_generation_ports.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexOverlayResource = preload("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapDocumentTerrainLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_terrain_layer_resource.gd")
const HexMapDocumentOverlayLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_overlay_layer_resource.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")

const SCHEMA := "hex_map_graph_progress_profile.v1"
const DEFAULT_RUN_ID_PREFIX := "graph-progress"


class ProgressRecorder:
	var events: Array = []

	func record(status: Dictionary) -> void:
		events.append(status.duplicate(true))


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var run_id := _run_id()
	var output_dir := "res://.godot_user/perf/graph-progress/%s" % run_id
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))

	var cases := _profile_cases()
	var results: Array = []
	for profile_case in cases:
		var result := await _measure_case(profile_case as Dictionary)
		results.append(result)
		print("%s median=%.3fms" % [String(result.get("id", "")), float(result.get("median_ms", 0.0))])

	var report := {
		"schema": SCHEMA,
		"run_id": run_id,
		"godot_version": Engine.get_version_info(),
		"case_count": results.size(),
		"results": results,
		"summary": _summary(results),
	}
	var json_path := "%s/graph_progress_profile.json" % output_dir
	var md_path := "%s/graph_progress_profile.md" % output_dir
	_write_text(json_path, JSON.stringify(report, "\t"))
	_write_text(md_path, _markdown_report(report))
	print("Wrote %s" % ProjectSettings.globalize_path(json_path))
	print("Wrote %s" % ProjectSettings.globalize_path(md_path))
	quit(0)


func _run_id() -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--run-id="):
			return _safe_path_part(arg.substr("--run-id=".length()))
	return "%s-%d" % [DEFAULT_RUN_ID_PREFIX, Time.get_unix_time_from_system()]


func _profile_cases() -> Array:
	return [
		{"id": "shape_rectangle_40", "group": "shape", "repetitions": 5, "side": 40},
		{"id": "shape_hexagon_radius_40", "group": "shape", "repetitions": 3, "radius": 40},
		{"id": "wall_random_side_40_p35", "group": "wall_field", "repetitions": 3, "side": 40, "wall_probability": 0.35},
		{"id": "wall_random_side_81_p35", "group": "wall_field", "repetitions": 2, "side": 81, "wall_probability": 0.35},
		{"id": "wall_markov_radius_20_p35", "group": "wall_field", "repetitions": 2, "radius": 20, "wall_probability": 0.35},
		{"id": "wall_markov_radius_40_p35", "group": "wall_field", "repetitions": 1, "radius": 40, "wall_probability": 0.35},
		{"id": "connect_dense_side_40_p35", "group": "connectivity", "repetitions": 2, "side": 40, "wall_probability": 0.35, "method": "dense"},
		{"id": "connect_dense_side_40_p65", "group": "connectivity", "repetitions": 2, "side": 40, "wall_probability": 0.65, "method": "dense"},
		{"id": "connect_dense_side_81_p45", "group": "connectivity", "repetitions": 1, "side": 81, "wall_probability": 0.45, "method": "dense"},
		{"id": "connect_sparse_side_40_p65", "group": "connectivity", "repetitions": 2, "side": 40, "wall_probability": 0.65, "method": "sparse"},
		{"id": "connect_sparse_side_81_p45", "group": "connectivity", "repetitions": 1, "side": 81, "wall_probability": 0.45, "method": "sparse"},
		{"id": "connect_terminal_side_81_p45", "group": "connectivity", "repetitions": 1, "side": 81, "wall_probability": 0.45, "method": "terminal"},
		{"id": "item_random_side_40", "group": "item_generator", "repetitions": 3, "side": 40, "mode": "weighted"},
		{"id": "item_limited_side_40", "group": "item_generator", "repetitions": 3, "side": 40, "mode": "limited"},
		{"id": "item_adjacency_side_40_r1", "group": "item_generator", "repetitions": 2, "side": 40, "mode": "adjacency_rules", "neighbor_radius": 1},
		{"id": "item_adjacency_side_40_r3_generated_ref", "group": "item_generator", "repetitions": 2, "side": 40, "mode": "adjacency_rules", "neighbor_radius": 3, "include_generated_reference": true},
		{"id": "item_adjacency_side_81_r2", "group": "item_generator", "repetitions": 1, "side": 81, "mode": "adjacency_rules", "neighbor_radius": 2},
		{"id": "filter_floor_side_81", "group": "filter", "repetitions": 3, "side": 81, "filter_target": "floor"},
		{"id": "filter_distance_side_81", "group": "filter", "repetitions": 3, "side": 81, "filter_target": "floor", "distance": 8},
		{"id": "compose_overlay_side_81", "group": "compose", "repetitions": 3, "side": 81},
		{"id": "result_terrain_3_overlays_side_81", "group": "result", "repetitions": 3, "side": 81, "overlay_count": 3},
		{"id": "apply_map_side_25", "group": "visual_apply", "repetitions": 2, "side": 25, "loop": false},
		{"id": "apply_map_side_50", "group": "visual_apply", "repetitions": 2, "side": 50, "loop": false},
		{"id": "apply_map_side_75", "group": "visual_apply", "repetitions": 1, "side": 75, "loop": false},
		{"id": "apply_map_side_81", "group": "visual_apply", "repetitions": 1, "side": 81, "loop": false},
		{"id": "apply_map_side_81_loop_toric", "group": "visual_apply", "repetitions": 1, "side": 81, "loop": true},
		{"id": "apply_document_terrain_3_overlays_side_40", "group": "visual_apply", "repetitions": 1, "side": 40, "document_overlays": 3},
		{"id": "apply_document_terrain_3_overlays_side_81", "group": "visual_apply", "repetitions": 1, "side": 81, "document_overlays": 3},
	]


func _measure_case(profile_case: Dictionary) -> Dictionary:
	var repetitions := int(profile_case.get("repetitions", 1))
	var times: Array = []
	var summaries: Array = []
	for index in range(repetitions):
		var run := await _execute_case(profile_case, index)
		times.append(int(run.get("elapsed_usec", 0)))
		summaries.append(run.get("summary", {}))
	times.sort()
	var median_usec := int(times[int(floor(float(times.size() - 1) / 2.0))])
	var min_usec := int(times[0])
	var max_usec := int(times[times.size() - 1])
	return {
		"id": String(profile_case.get("id", "")),
		"group": String(profile_case.get("group", "")),
		"params": _case_params(profile_case),
		"repetitions": repetitions,
		"times_usec": times,
		"median_usec": median_usec,
		"median_ms": float(median_usec) / 1000.0,
		"min_ms": float(min_usec) / 1000.0,
		"max_ms": float(max_usec) / 1000.0,
		"last_summary": summaries[summaries.size() - 1] if not summaries.is_empty() else {},
	}


func _execute_case(profile_case: Dictionary, iteration: int) -> Dictionary:
	var id := String(profile_case.get("id", ""))
	if id == "shape_rectangle_40":
		return _time_callable(func():
			return HexGenerationNodeTypes.run_node(
				{"type": HexGenerationNodeTypes.NODE_SHAPE, "params": {"shape": "rectangle", "width": 40, "height": 40}},
				{},
				{}
			)
		)
	if id == "shape_hexagon_radius_40":
		return _time_callable(func():
			return HexGenerationNodeTypes.run_node(
				{"type": HexGenerationNodeTypes.NODE_SHAPE, "params": {"shape": "hexagon", "radius": 40}},
				{},
				{}
			)
		)
	if ["wall_random_side_40_p35", "wall_random_side_81_p35"].has(id):
		return _run_wall_random_case(profile_case)
	if ["wall_markov_radius_20_p35", "wall_markov_radius_40_p35"].has(id):
		return _run_markov_wall_case(profile_case)
	if [
		"connect_dense_side_40_p35",
		"connect_dense_side_40_p65",
		"connect_dense_side_81_p45",
		"connect_sparse_side_40_p65",
		"connect_sparse_side_81_p45",
		"connect_terminal_side_81_p45",
	].has(id):
		return _run_connectivity_case(profile_case, iteration)
	if [
		"item_random_side_40",
		"item_limited_side_40",
		"item_adjacency_side_40_r1",
		"item_adjacency_side_40_r3_generated_ref",
		"item_adjacency_side_81_r2",
	].has(id):
		return _run_item_case(profile_case, iteration)
	if ["filter_floor_side_81", "filter_distance_side_81"].has(id):
		return _run_filter_case(profile_case)
	if id == "compose_overlay_side_81":
		return _run_compose_case(profile_case)
	if id == "result_terrain_3_overlays_side_81":
		return _run_result_case(profile_case)
	if ["apply_map_side_25", "apply_map_side_50", "apply_map_side_75", "apply_map_side_81", "apply_map_side_81_loop_toric"].has(id):
		return await _run_apply_map_case(profile_case, iteration)
	if ["apply_document_terrain_3_overlays_side_40", "apply_document_terrain_3_overlays_side_81"].has(id):
		return await _run_apply_document_case(profile_case, iteration)
	return {"elapsed_usec": 0, "summary": {"unknown_case": id}}


func _run_wall_random_case(profile_case: Dictionary) -> Dictionary:
	var side := int(profile_case.get("side", 40))
	var data = HexMapData.square(side, false)
	var recorder := ProgressRecorder.new()
	var options := _interrupt_options(recorder)
	var wall_probability := float(profile_case.get("wall_probability", 0.35))
	var run := _time_callable(func():
		return HexGenerationNodeTypes.run_node(
			{"type": HexGenerationNodeTypes.NODE_WALL_FIELD, "params": {"wall_method": "random_probability", "wall_probability": wall_probability}},
			{"in": data},
			{"interrupt_options": options, "seed": 6202}
		)
	)
	run["summary"] = _merge_dicts(run["summary"], {
		"input_cells": data.cells.size(),
		"progress_events": recorder.events.size(),
		"last_phase": _last_phase(recorder.events),
	})
	return run


func _run_markov_wall_case(profile_case: Dictionary) -> Dictionary:
	var radius := int(profile_case.get("radius", 20))
	var recorder := ProgressRecorder.new()
	var options := _interrupt_options(recorder)
	var wall_probability := float(profile_case.get("wall_probability", 0.35))
	var run := _time_callable(func():
		return HexMapGenerator.generate_symmetric_toric_walls_interruptible(
			radius,
			wall_probability,
			6202,
			20,
			[],
			null,
			options
		)
	)
	run["summary"] = _merge_dicts(run["summary"], {
		"radius": radius,
		"canvas_side": radius * 2 + 1,
		"canvas_cells": (radius * 2 + 1) * (radius * 2 + 1),
		"progress_events": recorder.events.size(),
		"last_phase": _last_phase(recorder.events),
	})
	return run


func _run_connectivity_case(profile_case: Dictionary, iteration: int) -> Dictionary:
	var side := int(profile_case.get("side", 40))
	var wall_probability := float(profile_case.get("wall_probability", 0.45))
	var method := String(profile_case.get("method", "dense"))
	var source = _wall_data(side, wall_probability, 7300 + iteration)
	var recorder := ProgressRecorder.new()
	var options := _interrupt_options(recorder)
	var run := _time_callable(func():
		var data = HexMapData.from_cells(source.cells, source.walls, source.cyclic_size)
		match method:
			"sparse":
				HexGenerationNodeTypes.run_node(
					{"type": HexGenerationNodeTypes.NODE_CONNECTIVITY, "params": {"method": "sparse"}},
					{"in": data},
					{"interrupt_options": options, "seed": 811}
				)
			"terminal":
				var terminals := [data.cells[0], data.cells[data.cells.size() - 1]] if data.cells.size() >= 2 else []
				HexGenerationNodeTypes.run_node(
					{"type": HexGenerationNodeTypes.NODE_CONNECTIVITY, "params": {"method": "terminal", "terminals": terminals}},
					{"in": data},
					{"interrupt_options": options, "seed": 811}
				)
			_:
				HexGenerationNodeTypes.run_node(
					{"type": HexGenerationNodeTypes.NODE_CONNECTIVITY, "params": {"method": "dense"}},
					{"in": data},
					{"interrupt_options": options, "seed": 811}
				)
	)
	run["summary"] = _merge_dicts(run["summary"], {
		"input_cells": source.cells.size(),
		"input_walls": source.walls.size(),
		"method": method,
		"progress_events": recorder.events.size(),
		"last_phase": _last_phase(recorder.events),
	})
	return run


func _run_item_case(profile_case: Dictionary, iteration: int) -> Dictionary:
	var side := int(profile_case.get("side", 40))
	var mode := String(profile_case.get("mode", "weighted"))
	var cells = HexMapData.square(side, false).cells
	var recorder := ProgressRecorder.new()
	var options := _interrupt_options(recorder)
	var params := {"placement_method": mode}
	if mode == "limited":
		params["item_pool"] = [{"name": "loot", "count": max(1, int(cells.size() / 20))}]
	elif mode == "adjacency_rules":
		params["item_name"] = "moss"
		params["neighbor_radius"] = int(profile_case.get("neighbor_radius", 1))
		params["include_generated_reference"] = bool(profile_case.get("include_generated_reference", false))
		params["probability_rules"] = {
			"default": 0.0,
			"rules": [{"count": 1, "components": 1, "probability": 0.35}],
		}
	else:
		params["placement_probability"] = 0.35
		params["item_pool"] = [{"name": "loot", "weight": 1.0}, {"name": "trap", "weight": 0.35}]
	var run := _time_callable(func():
		return HexGenerationNodeTypes.run_node(
			{"type": HexGenerationNodeTypes.NODE_ITEM_GENERATOR, "params": params},
			{"scope": cells},
			{"interrupt_options": options, "seed": 9000 + iteration}
		)
	)
	run["summary"] = _merge_dicts(run["summary"], {
		"scope_cells": cells.size(),
		"mode": mode,
		"neighbor_radius": int(params.get("neighbor_radius", 0)),
		"include_generated_reference": bool(params.get("include_generated_reference", false)),
		"progress_events": recorder.events.size(),
		"last_phase": _last_phase(recorder.events),
	})
	return run


func _run_filter_case(profile_case: Dictionary) -> Dictionary:
	var side := int(profile_case.get("side", 81))
	var source = _wall_data(side, 0.35, 777)
	var params := {"filter_target": String(profile_case.get("filter_target", "floor"))}
	if profile_case.has("distance"):
		params["origin_points"] = [source.cells[0]]
		params["distance"] = int(profile_case.get("distance", 8))
	var run := _time_callable(func():
		return HexGenerationNodeTypes.run_node(
			{"type": HexGenerationNodeTypes.NODE_TERRAIN_FILTER, "params": params},
			{"in": source},
			{}
		)
	)
	run["summary"] = _merge_dicts(run["summary"], {"input_cells": source.cells.size(), "input_walls": source.walls.size()})
	return run


func _run_compose_case(profile_case: Dictionary) -> Dictionary:
	var side := int(profile_case.get("side", 81))
	var cells = HexMapData.square(side, false).cells
	var base = _overlay_for_cells(cells, "loot", 5)
	var add = _overlay_for_cells(cells, "trap", 7)
	var run := _time_callable(func():
		return HexGenerationNodeTypes.run_node(
			{"type": HexGenerationNodeTypes.NODE_COMPOSE, "params": {}},
			{"base": base, "add": add},
			{}
		)
	)
	run["summary"] = _merge_dicts(run["summary"], {"input_cells": cells.size(), "base_items": base.occupied_cells().size(), "add_items": add.occupied_cells().size()})
	return run


func _run_result_case(profile_case: Dictionary) -> Dictionary:
	var side := int(profile_case.get("side", 81))
	var overlay_count := int(profile_case.get("overlay_count", 3))
	var terrain = _wall_data(side, 0.35, 888)
	var inputs := {HexGenerationNodeTypes.RESULT_TERRAIN_PORT: terrain}
	for index in range(overlay_count):
		inputs["%s%d" % [HexGenerationNodeTypes.RESULT_OVERLAY_PORT_PREFIX, index]] = _overlay_for_cells(terrain.cells, "item_%d" % index, 4 + index)
	var run := _time_callable(func():
		return HexGenerationNodeTypes.run_node(
			{"type": HexGenerationNodeTypes.NODE_RESULT, "params": {}},
			inputs,
			{}
		)
	)
	run["summary"] = _merge_dicts(run["summary"], {"terrain_cells": terrain.cells.size(), "terrain_walls": terrain.walls.size(), "overlay_count": overlay_count})
	return run


func _run_apply_map_case(profile_case: Dictionary, iteration: int) -> Dictionary:
	var side := int(profile_case.get("side", 40))
	var loop_enabled := bool(profile_case.get("loop", false))
	var data = _wall_data(side, 0.35, 10000 + iteration)
	var layer := await _ready_layer("ProfileApplyMap%s" % side)
	layer.loop_display_enabled = loop_enabled
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC if loop_enabled else HexTileMapLayer.LOOP_DISPLAY_NONE
	layer.loop_display_margin = 1
	var recorder := ProgressRecorder.new()
	var options := {
		"chunk_size": 512,
		"apply_reason": String(profile_case.get("id", "apply_map_profile")),
		"progress_callback": Callable(recorder, "record"),
	}
	var start := Time.get_ticks_usec()
	var report := layer.apply_map(HexMapResource.from_map_data(data), options)
	var elapsed := Time.get_ticks_usec() - start
	var summary := {
		"input_cells": data.cells.size(),
		"input_walls": data.walls.size(),
		"display_used_cell_count": layer.display_used_cell_count(),
		"loop_display_enabled": loop_enabled,
		"report": _small_apply_report(report),
		"progress_events": recorder.events.size(),
		"last_phase": _last_phase(recorder.events),
	}
	layer.queue_free()
	await process_frame
	return {"elapsed_usec": elapsed, "summary": summary}


func _run_apply_document_case(profile_case: Dictionary, iteration: int) -> Dictionary:
	var side := int(profile_case.get("side", 40))
	var overlay_count := int(profile_case.get("document_overlays", 3))
	var data = _wall_data(side, 0.35, 11000 + iteration)
	var document = _document_for(data, overlay_count)
	var layer := await _ready_layer("ProfileApplyDocument%s" % side)
	var recorder := ProgressRecorder.new()
	var options := {
		"chunk_size": 512,
		"apply_reason": String(profile_case.get("id", "apply_document_profile")),
		"progress_callback": Callable(recorder, "record"),
	}
	var start := Time.get_ticks_usec()
	var report := layer.apply_document(document, options)
	var elapsed := Time.get_ticks_usec() - start
	var summary := {
		"input_cells": data.cells.size(),
		"input_walls": data.walls.size(),
		"overlay_count": overlay_count,
		"display_used_cell_count": layer.display_used_cell_count(),
		"report": _small_apply_report(report),
		"progress_events": recorder.events.size(),
		"last_phase": _last_phase(recorder.events),
	}
	layer.queue_free()
	await process_frame
	return {"elapsed_usec": elapsed, "summary": summary}


func _time_callable(callable: Callable) -> Dictionary:
	var start := Time.get_ticks_usec()
	var output = callable.call()
	var elapsed := Time.get_ticks_usec() - start
	return {"elapsed_usec": elapsed, "summary": _output_summary(output)}


func _ready_layer(layer_name: String) -> HexTileMapLayer:
	var layer := HexTileMapLayer.new()
	layer.name = layer_name
	root.add_child(layer)
	await process_frame
	layer.ensure_display_tiles()
	return layer


func _interrupt_options(recorder: ProgressRecorder) -> Dictionary:
	return {
		"chunk_size": 128,
		"progress_callback": Callable(recorder, "record"),
	}


func _wall_data(side: int, wall_probability: float, seed: int):
	var data = HexMapData.square(side, false)
	var walls := HexMapGenerator.generate_random_walls(data.cells, wall_probability, seed)
	data.set_walls(walls)
	return data


func _overlay_for_cells(cells: Array, item_key: String, stride: int):
	var item_cells: Array = []
	for index in range(cells.size()):
		if index % max(1, stride) == 0:
			item_cells.append(cells[index])
	return HexOverlayData.from_item_cells(cells, item_key, item_cells)


func _document_for(data, overlay_count: int):
	var document := HexMapDocumentResource.new()
	var terrain_layer := HexMapDocumentTerrainLayerResource.new()
	terrain_layer.layer_id = "generated_terrain"
	terrain_layer.map = HexMapResource.from_map_data(data)
	document.terrain_layers.append(terrain_layer)
	for index in range(overlay_count):
		var overlay_layer := HexMapDocumentOverlayLayerResource.new()
		overlay_layer.layer_id = "generated_overlay_%d" % index
		overlay_layer.display_name = "Generated Overlay %d" % (index + 1)
		overlay_layer.overlay = HexOverlayResource.from_overlay_data(_overlay_for_cells(data.cells, "item_%d" % index, 4 + index))
		document.overlay_layers.append(overlay_layer)
	return document


func _output_summary(output) -> Dictionary:
	if output == null:
		return {"output": "null"}
	if output is Dictionary:
		return {
			"output": "dictionary",
			"keys": (output as Dictionary).keys(),
			"walls": (output as Dictionary).get("walls", []).size() if (output as Dictionary).get("walls", []) is Array else 0,
			"progress": float((output as Dictionary).get("progress", 0.0)),
			"cancelled": bool((output as Dictionary).get("cancelled", false)),
		}
	if output is HexMapData:
		return {"output": "terrain", "cells": output.cells.size(), "walls": output.walls.size()}
	if output is HexOverlayData:
		return {"output": "overlay", "cells": output.cells.size(), "occupied": output.occupied_cells().size(), "item_keys": output.item_keys()}
	if output is Array:
		return {"output": "array", "size": (output as Array).size()}
	if output is Resource:
		var metadata := {}
		if output.get("metadata") is Dictionary:
			metadata = output.get("metadata")
		return {"output": output.get_class(), "metadata": metadata}
	return {"output": str(output)}


func _small_apply_report(report: Dictionary) -> Dictionary:
	return {
		"ok": bool(report.get("ok", false)),
		"cancelled": bool(report.get("cancelled", false)),
		"total_cells": int(report.get("total_cells", 0)),
		"processed_cells": int(report.get("processed_cells", 0)),
		"written_cells": int(report.get("written_cells", 0)),
		"chunk_size": int(report.get("chunk_size", 0)),
		"progress_event_count": int(report.get("progress_event_count", 0)),
		"last_phase": String(report.get("last_phase", "")),
	}


func _last_phase(events: Array) -> String:
	if events.is_empty():
		return ""
	return String((events[events.size() - 1] as Dictionary).get("phase", ""))


func _merge_dicts(left: Dictionary, right: Dictionary) -> Dictionary:
	var result := left.duplicate(true)
	for key in right.keys():
		result[key] = right[key]
	return result


func _case_params(profile_case: Dictionary) -> Dictionary:
	var result := profile_case.duplicate(true)
	result.erase("id")
	result.erase("group")
	result.erase("repetitions")
	return result


func _summary(results: Array) -> Dictionary:
	var by_group := {}
	for result in results:
		var row := result as Dictionary
		var group := String(row.get("group", ""))
		if not by_group.has(group):
			by_group[group] = {"count": 0, "max_ms": 0.0, "max_case": ""}
		var group_row := by_group[group] as Dictionary
		group_row["count"] = int(group_row["count"]) + 1
		if float(row.get("median_ms", 0.0)) > float(group_row["max_ms"]):
			group_row["max_ms"] = float(row.get("median_ms", 0.0))
			group_row["max_case"] = String(row.get("id", ""))
	return {"by_group": by_group}


func _markdown_report(report: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append("# Graph Progress Timing Profile")
	lines.append("")
	lines.append("- Schema: `%s`" % String(report.get("schema", "")))
	lines.append("- Run: `%s`" % String(report.get("run_id", "")))
	lines.append("- Cases: %d" % int(report.get("case_count", 0)))
	lines.append("")
	lines.append("| case | group | median ms | min ms | max ms | key params |")
	lines.append("|---|---:|---:|---:|---:|---|")
	for result in report.get("results", []) as Array:
		var row := result as Dictionary
		lines.append("| `%s` | %s | %.3f | %.3f | %.3f | `%s` |" % [
			String(row.get("id", "")),
			String(row.get("group", "")),
			float(row.get("median_ms", 0.0)),
			float(row.get("min_ms", 0.0)),
			float(row.get("max_ms", 0.0)),
			JSON.stringify(row.get("params", {})),
		])
	lines.append("")
	lines.append("## Heaviest By Group")
	lines.append("")
	lines.append("| group | case | median ms |")
	lines.append("|---|---|---:|")
	var by_group := (report.get("summary", {}) as Dictionary).get("by_group", {}) as Dictionary
	var groups := by_group.keys()
	groups.sort()
	for group in groups:
		var entry := by_group[group] as Dictionary
		lines.append("| %s | `%s` | %.3f |" % [
			String(group),
			String(entry.get("max_case", "")),
			float(entry.get("max_ms", 0.0)),
		])
	lines.append("")
	return "\n".join(lines)


func _write_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _safe_path_part(value: String) -> String:
	var result := value.strip_edges()
	for ch in ["/", "\\", ":", " ", "\t", "\n"]:
		result = result.replace(ch, "_")
	return result
