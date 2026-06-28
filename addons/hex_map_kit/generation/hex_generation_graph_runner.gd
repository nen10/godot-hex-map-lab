@tool
class_name HexGenerationGraphRunner
extends RefCounted

const HexGenerationGraphScript = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const HexMapDataScript = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexOverlayDataScript = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")

const PROGRESS_MODEL_ESTIMATED_WORK := "estimated_work"
const PROGRESS_FALLBACK_CELLS := 64
const PROGRESS_MIN_NODE_WORK := 0.25
const PROGRESS_SOURCE_WORK_PER_CELL := 0.001
const PROGRESS_SHAPE_RECT_WORK_PER_CELL := 0.004
const PROGRESS_SHAPE_HEX_WORK_PER_CELL := 0.018
const PROGRESS_WALL_RANDOM_WORK_PER_CELL := 0.003
const PROGRESS_WALL_MARKOV_WORK_PER_CELL := 0.064
const PROGRESS_CONNECT_DENSE_WORK_PER_CELL := 0.075
const PROGRESS_CONNECT_SPARSE_WORK_PER_CELL := 0.115
const PROGRESS_CONNECT_TERMINAL_WORK_PER_CELL := 0.023
const PROGRESS_CONNECT_NONE_WORK_PER_CELL := 0.001
const PROGRESS_ITEM_RANDOM_WORK_PER_CELL := 0.006
const PROGRESS_ITEM_LIMITED_WORK_PER_CELL := 0.004
const PROGRESS_ITEM_ADJACENCY_WORK_PER_CELL_AREA := 0.006
const PROGRESS_FILTER_SIMPLE_WORK_PER_CELL := 0.002
const PROGRESS_FILTER_DISTANCE_WORK_PER_CELL := 0.006
const PROGRESS_COMPOSE_WORK_PER_CELL := 0.006
const PROGRESS_SET_OPERATION_WORK_PER_CELL := 0.002
const PROGRESS_RESULT_WORK_PER_TERRAIN_CELL := 0.002
const PROGRESS_RESULT_WORK_PER_OVERLAY := 2.0
const PROGRESS_UNKNOWN_WORK_PER_CELL := 0.004


class GraphProgressRelay:
	var original_progress_callback: Callable = Callable()
	var node_id := ""
	var node_type := ""
	var node_title := ""
	var node_mode := ""
	var node_index := 0
	var node_total := 1
	var progress_start := 0.0
	var progress_end := 1.0
	var node_work := 1.0
	var total_work := 1.0

	func _init(
		p_original_progress_callback: Callable,
		p_node_id: String,
		p_node_type: String,
		p_node_title: String,
		p_node_mode: String,
		p_node_index: int,
		p_node_total: int,
		p_progress_range: Dictionary
	) -> void:
		original_progress_callback = p_original_progress_callback
		node_id = p_node_id
		node_type = p_node_type
		node_title = p_node_title
		node_mode = p_node_mode
		node_index = p_node_index
		node_total = max(1, p_node_total)
		progress_start = clampf(float(p_progress_range.get("start", 0.0)), 0.0, 1.0)
		progress_end = clampf(float(p_progress_range.get("end", 1.0)), 0.0, 1.0)
		node_work = maxf(float(p_progress_range.get("work", 1.0)), 0.25)
		total_work = maxf(float(p_progress_range.get("total_work", node_work)), node_work)

	func progress(status: Dictionary) -> void:
		if not original_progress_callback.is_valid():
			return
		original_progress_callback.call(mapped_status(status))

	func mapped_status(status: Dictionary) -> Dictionary:
		var result := status.duplicate(true)
		var core_progress := clampf(float(result.get("progress", 0.0)), 0.0, 1.0)
		var graph_progress := clampf(
			progress_start + core_progress * (progress_end - progress_start),
			0.0,
			1.0
		)
		result["progress_model"] = "estimated_work"
		result["progress"] = graph_progress
		result["graph_progress"] = graph_progress
		result["core_progress"] = core_progress
		result["local_progress"] = core_progress
		result["node"] = node_id
		result["node_id"] = node_id
		result["node_type"] = node_type
		result["node_title"] = node_title
		result["node_mode"] = node_mode
		result["graph_node_index"] = node_index
		result["graph_node_total"] = node_total
		result["node_index"] = node_index
		result["node_total"] = node_total
		result["node_progress_start"] = progress_start
		result["node_progress_end"] = progress_end
		result["estimated_work"] = node_work
		result["total_estimated_work"] = total_work
		if result.has("steps"):
			result["core_steps"] = int(result.get("steps", 0))
		if result.has("total_steps"):
			result["core_total_steps"] = int(result.get("total_steps", 0))
		result["graph_steps"] = node_index
		result["graph_total_steps"] = node_total
		return result


static func run(graph: Dictionary, context: Dictionary = {}) -> Dictionary:
	return run_with_report(graph, context)["cache"]


static func run_with_report(graph: Dictionary, context: Dictionary = {}) -> Dictionary:
	var validation = HexGenerationGraphScript.validate(graph)
	if not bool(validation.get("ok", false)):
		return {
			"ok": false,
			"cancelled": false,
			"errors": validation.get("errors", []),
			"cache": {},
			"partial_cache": {},
			"recomputed_node_ids": PackedStringArray(),
			"reused_node_ids": PackedStringArray(),
		}

	var topo = HexGenerationGraphScript.topological_order(graph)
	if not bool(topo.get("ok", false)):
		return {
			"ok": false,
			"cancelled": false,
			"errors": [],
			"cache": {},
			"partial_cache": {},
			"recomputed_node_ids": PackedStringArray(),
			"reused_node_ids": PackedStringArray(),
		}

	var previous_cache = context.get("previous_cache", {}) as Dictionary
	var dirty_set := _dirty_set(context.get("dirty_node_ids", []))
	var cache := {}
	var incoming = HexGenerationGraphScript.incoming_edges_by_node(graph)
	var recomputed_node_ids := PackedStringArray()
	var reused_node_ids := PackedStringArray()
	var recomputed_set := {}
	var order: Array = topo["order"]
	var interrupt_options = context.get("interrupt_options", {}) as Dictionary
	var progress_plan := _progress_plan(graph, order, context)
	for order_index in range(order.size()):
		var node_id = String(order[order_index])
		var node: Dictionary = graph["nodes"][node_id]
		var progress_range := _progress_range_for_node(progress_plan, node_id)
		if _cancel_requested(interrupt_options, node, node_id, order_index, order.size(), progress_range):
			return _cancelled_report(node_id, cache, previous_cache, recomputed_node_ids, reused_node_ids)
		var inputs := {}
		var upstream_changed := false
		for port_name in incoming[node_id].keys():
			var edge: Dictionary = incoming[node_id][port_name]
			var from_node := String(edge.get("from_node", ""))
			inputs[port_name] = cache.get(String(edge.get("from_node", "")), null)
			if recomputed_set.has(from_node):
				upstream_changed = true
		var should_recompute = not previous_cache.has(node_id) \
				or dirty_set.has(node_id) \
				or upstream_changed
		if should_recompute:
			_emit_progress(interrupt_options, "graph_node_start", node, node_id, order_index, order.size(), progress_range)
			var original_progress_callback = interrupt_options.get("progress_callback", Callable())
			var relay = _install_progress_relay(
				interrupt_options,
				original_progress_callback,
				node,
				node_id,
				order_index,
				order.size(),
				progress_range
			)
			cache[node_id] = HexGenerationNodeTypesScript.run_node(node, inputs, context)
			_restore_progress_callback(interrupt_options, original_progress_callback, relay != null)
			recomputed_node_ids.append(node_id)
			recomputed_set[node_id] = true
			if bool(interrupt_options.get("cancelled", false)):
				return _cancelled_report(node_id, cache, previous_cache, recomputed_node_ids, reused_node_ids)
			_emit_progress(interrupt_options, "graph_node_complete", node, node_id, order_index + 1, order.size(), progress_range)
		else:
			cache[node_id] = previous_cache[node_id]
			reused_node_ids.append(node_id)
			_emit_progress(interrupt_options, "graph_node_reused", node, node_id, order_index + 1, order.size(), progress_range)

	return {
		"ok": true,
		"cancelled": false,
		"errors": [],
		"cache": cache,
		"partial_cache": {},
		"recomputed_node_ids": recomputed_node_ids,
		"reused_node_ids": reused_node_ids,
	}


static func estimated_work_for_node(node: Dictionary, input_estimates: Dictionary = {}, context: Dictionary = {}) -> float:
	var output_cells := _estimated_output_cells(node, input_estimates, context)
	return maxf(_estimated_node_work(node, input_estimates, context, output_cells), PROGRESS_MIN_NODE_WORK)


static func _dirty_set(values) -> Dictionary:
	var result := {}
	if values is PackedStringArray:
		for value in values:
			result[String(value)] = true
	elif values is Array:
		for value in values:
			result[String(value)] = true
	return result


static func _cancel_requested(
	interrupt_options: Dictionary,
	node: Dictionary,
	node_id: String,
	step: int,
	total: int,
	progress_range: Dictionary
) -> bool:
	if interrupt_options.is_empty():
		return false
	if bool(interrupt_options.get("cancelled", false)):
		return true
	var status := _progress_status("graph_node_start", node, node_id, step, total, progress_range)
	var cancel_callback = interrupt_options.get("cancel_callback", Callable())
	if cancel_callback is Callable and (cancel_callback as Callable).is_valid() and bool((cancel_callback as Callable).call(status)):
		interrupt_options["cancelled"] = true
		return true
	return false


static func _emit_progress(
	interrupt_options: Dictionary,
	phase: String,
	node: Dictionary,
	node_id: String,
	step: int,
	total: int,
	progress_range: Dictionary
) -> void:
	if interrupt_options.is_empty():
		return
	var status := _progress_status(phase, node, node_id, step, total, progress_range)
	for key in status.keys():
		interrupt_options[key] = status[key]
	var progress_callback = interrupt_options.get("progress_callback", Callable())
	if progress_callback is Callable and (progress_callback as Callable).is_valid():
		(progress_callback as Callable).call(status)


static func _progress_status(
	phase: String,
	node: Dictionary,
	node_id: String,
	step: int,
	total: int,
	progress_range: Dictionary
) -> Dictionary:
	var safe_total = max(1, total)
	var node_type := String(node.get("type", ""))
	var node_progress := 0.0 if phase == "graph_node_start" else 1.0
	var progress_start := clampf(float(progress_range.get("start", 0.0)), 0.0, 1.0)
	var progress_end := clampf(float(progress_range.get("end", 1.0)), 0.0, 1.0)
	var graph_progress := progress_start if phase == "graph_node_start" else progress_end
	return {
		"phase": phase,
		"node": node_id,
		"node_id": node_id,
		"node_type": node_type,
		"node_title": HexGenerationNodeTypesScript.registry().get(node_type, {}).get("title", _node_title(node_type)),
		"node_mode": _node_mode(node),
		"steps": step,
		"total_steps": safe_total,
		"node_index": clampi(step, 0, safe_total),
		"node_total": safe_total,
		"graph_node_index": clampi(step, 0, safe_total),
		"graph_node_total": safe_total,
		"progress": graph_progress,
		"graph_progress": graph_progress,
		"core_progress": node_progress,
		"local_progress": node_progress,
		"node_progress_start": progress_start,
		"node_progress_end": progress_end,
		"estimated_work": maxf(float(progress_range.get("work", 1.0)), PROGRESS_MIN_NODE_WORK),
		"total_estimated_work": maxf(float(progress_range.get("total_work", 1.0)), PROGRESS_MIN_NODE_WORK),
		"progress_model": PROGRESS_MODEL_ESTIMATED_WORK,
		"cancelled": false,
	}


static func _install_progress_relay(
	interrupt_options: Dictionary,
	original_progress_callback,
	node: Dictionary,
	node_id: String,
	node_index: int,
	node_total: int,
	progress_range: Dictionary
):
	if interrupt_options.is_empty():
		return null
	if not original_progress_callback is Callable or not (original_progress_callback as Callable).is_valid():
		return null
	var node_type := String(node.get("type", ""))
	var relay := GraphProgressRelay.new(
		original_progress_callback as Callable,
		node_id,
		node_type,
		String(HexGenerationNodeTypesScript.registry().get(node_type, {}).get("title", _node_title(node_type))),
		_node_mode(node),
		node_index,
		node_total,
		progress_range
	)
	interrupt_options["progress_callback"] = Callable(relay, "progress")
	return relay


static func _restore_progress_callback(interrupt_options: Dictionary, original_progress_callback, installed: bool) -> void:
	if interrupt_options.is_empty() or not installed:
		return
	if original_progress_callback is Callable and (original_progress_callback as Callable).is_valid():
		interrupt_options["progress_callback"] = original_progress_callback
	else:
		interrupt_options.erase("progress_callback")


static func _progress_plan(graph: Dictionary, order: Array, context: Dictionary) -> Dictionary:
	var incoming = HexGenerationGraphScript.incoming_edges_by_node(graph)
	var output_estimates := {}
	var node_estimates := {}
	var node_work := {}
	var total_work := 0.0
	for raw_node_id in order:
		var node_id := String(raw_node_id)
		var node: Dictionary = graph["nodes"][node_id]
		var input_estimates := {}
		var incoming_ports = incoming.get(node_id, {}) as Dictionary
		for port_name in incoming_ports.keys():
			var edge: Dictionary = incoming_ports[port_name]
			var from_node := String(edge.get("from_node", ""))
			input_estimates[String(port_name)] = output_estimates.get(from_node, _fallback_estimate())
		var output_cells := _estimated_output_cells(node, input_estimates, context)
		var work := maxf(_estimated_node_work(node, input_estimates, context, output_cells), PROGRESS_MIN_NODE_WORK)
		node_work[node_id] = work
		output_estimates[node_id] = {
			"cells": output_cells,
			"node_type": String(node.get("type", "")),
			"node_mode": _node_mode(node),
		}
		node_estimates[node_id] = {
			"cells": output_cells,
			"work": work,
			"node_type": String(node.get("type", "")),
			"node_mode": _node_mode(node),
		}
		total_work += work
	total_work = maxf(total_work, PROGRESS_MIN_NODE_WORK)

	var ranges := {}
	var cursor := 0.0
	for raw_node_id in order:
		var node_id := String(raw_node_id)
		var work := float(node_work.get(node_id, PROGRESS_MIN_NODE_WORK))
		ranges[node_id] = {
			"start": clampf(cursor / total_work, 0.0, 1.0),
			"end": clampf((cursor + work) / total_work, 0.0, 1.0),
			"work": work,
			"total_work": total_work,
			"estimate": (node_estimates.get(node_id, {}) as Dictionary).duplicate(true),
		}
		cursor += work
	return {
		"model": PROGRESS_MODEL_ESTIMATED_WORK,
		"ranges": ranges,
		"estimates": node_estimates,
		"total_work": total_work,
	}


static func _progress_range_for_node(progress_plan: Dictionary, node_id: String) -> Dictionary:
	var ranges = progress_plan.get("ranges", {}) as Dictionary
	if ranges.has(node_id) and ranges[node_id] is Dictionary:
		return (ranges[node_id] as Dictionary).duplicate(true)
	return {
		"start": 0.0,
		"end": 1.0,
		"work": 1.0,
		"total_work": 1.0,
	}


static func _estimated_output_cells(node: Dictionary, input_estimates: Dictionary, context: Dictionary) -> int:
	var params := _node_params(node)
	match String(node.get("type", "")):
		HexGenerationNodeTypesScript.NODE_SOURCE:
			return _estimate_source_cells(params, node.get("resource_refs", {}), context)
		HexGenerationNodeTypesScript.NODE_SHAPE:
			return _estimate_shape_cells(params)
		HexGenerationNodeTypesScript.NODE_WALL_FIELD, HexGenerationNodeTypesScript.NODE_CONNECTIVITY:
			return _input_cells(input_estimates, "in", _fallback_cells(context))
		HexGenerationNodeTypesScript.NODE_REGION_FILTER, HexGenerationNodeTypesScript.NODE_TERRAIN_FILTER, HexGenerationNodeTypesScript.NODE_OVERLAY_FILTER:
			return _input_cells(input_estimates, "in", _fallback_cells(context))
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR:
			return _input_cells(input_estimates, "scope", _fallback_cells(context))
		HexGenerationNodeTypesScript.NODE_COMPOSE:
			return max(
				_input_cells(input_estimates, "base", _fallback_cells(context)),
				_input_cells(input_estimates, "add", _fallback_cells(context))
			)
		HexGenerationNodeTypesScript.NODE_SET_OPERATION:
			return max(
				_input_cells(input_estimates, "a", _fallback_cells(context)),
				_input_cells(input_estimates, "b", 0)
			)
		HexGenerationNodeTypesScript.NODE_RESULT:
			return _input_cells(input_estimates, HexGenerationNodeTypesScript.RESULT_TERRAIN_PORT, _fallback_cells(context))
		_:
			return _fallback_cells(context)


static func _estimated_node_work(
	node: Dictionary,
	input_estimates: Dictionary,
	context: Dictionary,
	output_cells: int
) -> float:
	var params := _node_params(node)
	var cells := max(1, output_cells)
	match String(node.get("type", "")):
		HexGenerationNodeTypesScript.NODE_SOURCE:
			return float(cells) * PROGRESS_SOURCE_WORK_PER_CELL
		HexGenerationNodeTypesScript.NODE_SHAPE:
			return float(cells) * _shape_work_per_cell(params)
		HexGenerationNodeTypesScript.NODE_WALL_FIELD:
			var wall_mode := String(params.get("wall_method", params.get("mode", "random_probability")))
			if wall_mode == "markov_mesh":
				return float(cells) * PROGRESS_WALL_MARKOV_WORK_PER_CELL
			return float(cells) * PROGRESS_WALL_RANDOM_WORK_PER_CELL
		HexGenerationNodeTypesScript.NODE_CONNECTIVITY:
			var method := String(params.get("method", params.get("mode", "dense")))
			match method:
				"sparse":
					return float(cells) * PROGRESS_CONNECT_SPARSE_WORK_PER_CELL
				"terminal":
					return float(cells) * PROGRESS_CONNECT_TERMINAL_WORK_PER_CELL
				"none":
					return float(cells) * PROGRESS_CONNECT_NONE_WORK_PER_CELL
				"dense", "default", _:
					return float(cells) * PROGRESS_CONNECT_DENSE_WORK_PER_CELL
		HexGenerationNodeTypesScript.NODE_REGION_FILTER, HexGenerationNodeTypesScript.NODE_TERRAIN_FILTER, HexGenerationNodeTypesScript.NODE_OVERLAY_FILTER:
			var per_cell := PROGRESS_FILTER_DISTANCE_WORK_PER_CELL if _uses_distance_filter(params) else PROGRESS_FILTER_SIMPLE_WORK_PER_CELL
			return float(cells) * per_cell
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR:
			var placement_method := String(params.get("placement_method", params.get("mode", "weighted")))
			match placement_method:
				"limited":
					return float(cells) * PROGRESS_ITEM_LIMITED_WORK_PER_CELL
				"adjacency_rules":
					var radius := clampi(int(params.get("neighbor_radius", 1)), 1, 16)
					var neighbor_area := 3 * radius * (radius + 1)
					var component_multiplier := 1.25 if _rules_need_component_sizes(params.get("probability_rules", {})) else 1.0
					return float(cells * neighbor_area) * PROGRESS_ITEM_ADJACENCY_WORK_PER_CELL_AREA * component_multiplier
				"weighted", "random", _:
					return float(cells) * PROGRESS_ITEM_RANDOM_WORK_PER_CELL
		HexGenerationNodeTypesScript.NODE_COMPOSE:
			var base_cells := _input_cells(input_estimates, "base", cells)
			var add_cells := _input_cells(input_estimates, "add", cells)
			return float(base_cells + add_cells) * PROGRESS_COMPOSE_WORK_PER_CELL
		HexGenerationNodeTypesScript.NODE_SET_OPERATION:
			return float(cells) * PROGRESS_SET_OPERATION_WORK_PER_CELL
		HexGenerationNodeTypesScript.NODE_RESULT:
			return float(cells) * PROGRESS_RESULT_WORK_PER_TERRAIN_CELL \
				+ float(_result_overlay_input_count(input_estimates)) * PROGRESS_RESULT_WORK_PER_OVERLAY
		_:
			return float(cells) * PROGRESS_UNKNOWN_WORK_PER_CELL


static func _fallback_estimate() -> Dictionary:
	return {
		"cells": PROGRESS_FALLBACK_CELLS,
	}


static func _node_params(node: Dictionary) -> Dictionary:
	var params = node.get("params", {})
	return (params as Dictionary) if params is Dictionary else {}


static func _input_cells(input_estimates: Dictionary, port_name: String, fallback: int) -> int:
	var estimate = input_estimates.get(port_name, {})
	if estimate is Dictionary:
		return max(0, int((estimate as Dictionary).get("cells", fallback)))
	return max(0, fallback)


static func _fallback_cells(context: Dictionary) -> int:
	for key in ["estimated_cells", "cells", "cell_count"]:
		if context.has(key):
			return max(1, int(context.get(key, PROGRESS_FALLBACK_CELLS)))
	return PROGRESS_FALLBACK_CELLS


static func _estimate_source_cells(params: Dictionary, resource_refs, context: Dictionary) -> int:
	var value = params.get("data", params.get("value", null))
	if value == null and params.has("source_key"):
		value = context.get(String(params.get("source_key", "")), null)
	var direct := _cells_from_value(value)
	if direct > 0:
		return direct
	if resource_refs is Dictionary:
		for key in (resource_refs as Dictionary).keys():
			var count := _cells_from_value((resource_refs as Dictionary)[key])
			if count > 0:
				return count
	return _fallback_cells(context)


static func _cells_from_value(value) -> int:
	if value is HexMapDataScript:
		return (value as HexMapDataScript).cells.size()
	if value is HexOverlayDataScript:
		return (value as HexOverlayDataScript).cells.size()
	if value is Array:
		return (value as Array).size()
	return 0


static func _estimate_shape_cells(params: Dictionary) -> int:
	var shape := String(params.get("shape", "rectangle"))
	match shape:
		"square":
			var size := max(1, int(params.get("size", HexGenerationNodeTypesScript.DEFAULT_SQUARE_SIZE)))
			return size * size
		"hexagon":
			var radius := max(0, int(params.get("radius", HexGenerationNodeTypesScript.DEFAULT_HEXAGON_RADIUS)))
			return 3 * radius * (radius + 1) + 1
		"rectangle", _:
			var width := max(1, int(params.get("width", HexGenerationNodeTypesScript.DEFAULT_RECTANGLE_WIDTH)))
			var height := max(1, int(params.get("height", HexGenerationNodeTypesScript.DEFAULT_RECTANGLE_HEIGHT)))
			return width * height


static func _shape_work_per_cell(params: Dictionary) -> float:
	return PROGRESS_SHAPE_HEX_WORK_PER_CELL if String(params.get("shape", "rectangle")) == "hexagon" else PROGRESS_SHAPE_RECT_WORK_PER_CELL


static func _uses_distance_filter(params: Dictionary) -> bool:
	return params.has("within_distance_of") or params.has("origin_points") or params.has("distance") or params.has("max_distance")


static func _result_overlay_input_count(input_estimates: Dictionary) -> int:
	var count := 0
	for key in input_estimates.keys():
		if String(key).begins_with(HexGenerationNodeTypesScript.RESULT_OVERLAY_PORT_PREFIX):
			count += 1
	return count


static func _rules_need_component_sizes(rules_value) -> bool:
	if rules_value is Dictionary:
		var rules_dict := rules_value as Dictionary
		for key in rules_dict.keys():
			if String(key).begins_with("components:"):
				return true
		for raw_rule in rules_dict.get("rules", []) as Array:
			if raw_rule is Dictionary and (raw_rule as Dictionary).has("component_sizes"):
				return true
	if rules_value is String:
		return String(rules_value).contains("components:")
	return false


static func _node_mode(node: Dictionary) -> String:
	var params := _node_params(node)
	match String(node.get("type", "")):
		HexGenerationNodeTypesScript.NODE_SOURCE:
			return String(params.get("kind", "provided"))
		HexGenerationNodeTypesScript.NODE_SHAPE:
			return String(params.get("shape", "rectangle"))
		HexGenerationNodeTypesScript.NODE_WALL_FIELD:
			return String(params.get("wall_method", params.get("mode", "random_probability")))
		HexGenerationNodeTypesScript.NODE_CONNECTIVITY:
			return String(params.get("method", params.get("mode", "dense")))
		HexGenerationNodeTypesScript.NODE_REGION_FILTER, HexGenerationNodeTypesScript.NODE_TERRAIN_FILTER, HexGenerationNodeTypesScript.NODE_OVERLAY_FILTER:
			return String(params.get("filter_target", params.get("mode", "floor")))
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR:
			return String(params.get("placement_method", params.get("mode", "weighted")))
		HexGenerationNodeTypesScript.NODE_COMPOSE:
			return String(params.get("write_policy", "add_item"))
		HexGenerationNodeTypesScript.NODE_SET_OPERATION:
			return String(params.get("operation", "union"))
		HexGenerationNodeTypesScript.NODE_RESULT:
			return "bundle"
		_:
			return ""


static func _node_title(node_type: String) -> String:
	match node_type:
		HexGenerationNodeTypesScript.NODE_SOURCE:
			return "Source"
		HexGenerationNodeTypesScript.NODE_SHAPE:
			return "Shape"
		HexGenerationNodeTypesScript.NODE_WALL_FIELD:
			return "Wall Field"
		HexGenerationNodeTypesScript.NODE_CONNECTIVITY:
			return "Connectivity"
		HexGenerationNodeTypesScript.NODE_REGION_FILTER:
			return "Region Filter"
		HexGenerationNodeTypesScript.NODE_TERRAIN_FILTER:
			return "Terrain Filter"
		HexGenerationNodeTypesScript.NODE_OVERLAY_FILTER:
			return "Overlay Filter"
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR:
			return "Item Generator"
		HexGenerationNodeTypesScript.NODE_COMPOSE:
			return "Compose"
		HexGenerationNodeTypesScript.NODE_SET_OPERATION:
			return "Set Operation"
		HexGenerationNodeTypesScript.NODE_RESULT:
			return "Result"
		_:
			return node_type.capitalize()


static func _cancelled_report(
	node_id: String,
	partial_cache: Dictionary,
	previous_cache: Dictionary,
	recomputed_node_ids: PackedStringArray,
	reused_node_ids: PackedStringArray
) -> Dictionary:
	return {
		"ok": false,
		"cancelled": true,
		"errors": [{
			"code": "cancelled",
			"node": node_id,
			"edge": {},
			"message": "Graph run cancelled at node '%s'." % node_id,
		}],
		"cache": previous_cache.duplicate(true),
		"partial_cache": partial_cache.duplicate(true),
		"recomputed_node_ids": recomputed_node_ids.duplicate(),
		"reused_node_ids": reused_node_ids.duplicate(),
	}
