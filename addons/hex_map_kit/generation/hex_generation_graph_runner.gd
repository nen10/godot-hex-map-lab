@tool
class_name HexGenerationGraphRunner
extends RefCounted

const HexGenerationGraphScript = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")


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
	for order_index in range(order.size()):
		var node_id = String(order[order_index])
		var node: Dictionary = graph["nodes"][node_id]
		if _cancel_requested(interrupt_options, node, node_id, order_index, order.size()):
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
			_emit_progress(interrupt_options, "graph_node_start", node, node_id, order_index, order.size())
			cache[node_id] = HexGenerationNodeTypesScript.run_node(node, inputs, context)
			recomputed_node_ids.append(node_id)
			recomputed_set[node_id] = true
			if bool(interrupt_options.get("cancelled", false)):
				return _cancelled_report(node_id, cache, previous_cache, recomputed_node_ids, reused_node_ids)
			_emit_progress(interrupt_options, "graph_node_complete", node, node_id, order_index + 1, order.size())
		else:
			cache[node_id] = previous_cache[node_id]
			reused_node_ids.append(node_id)
			_emit_progress(interrupt_options, "graph_node_reused", node, node_id, order_index + 1, order.size())

	return {
		"ok": true,
		"cancelled": false,
		"errors": [],
		"cache": cache,
		"partial_cache": {},
		"recomputed_node_ids": recomputed_node_ids,
		"reused_node_ids": reused_node_ids,
	}


static func _dirty_set(values) -> Dictionary:
	var result := {}
	if values is PackedStringArray:
		for value in values:
			result[String(value)] = true
	elif values is Array:
		for value in values:
			result[String(value)] = true
	return result


static func _cancel_requested(interrupt_options: Dictionary, node: Dictionary, node_id: String, step: int, total: int) -> bool:
	if interrupt_options.is_empty():
		return false
	if bool(interrupt_options.get("cancelled", false)):
		return true
	var status := _progress_status("graph_node_start", node, node_id, step, total)
	var cancel_callback = interrupt_options.get("cancel_callback", Callable())
	if cancel_callback is Callable and (cancel_callback as Callable).is_valid() and bool((cancel_callback as Callable).call(status)):
		interrupt_options["cancelled"] = true
		return true
	return false


static func _emit_progress(interrupt_options: Dictionary, phase: String, node: Dictionary, node_id: String, step: int, total: int) -> void:
	if interrupt_options.is_empty():
		return
	var status := _progress_status(phase, node, node_id, step, total)
	for key in status.keys():
		interrupt_options[key] = status[key]
	var progress_callback = interrupt_options.get("progress_callback", Callable())
	if progress_callback is Callable and (progress_callback as Callable).is_valid():
		(progress_callback as Callable).call(status)


static func _progress_status(phase: String, node: Dictionary, node_id: String, step: int, total: int) -> Dictionary:
	var safe_total = max(1, total)
	var node_type := String(node.get("type", ""))
	return {
		"phase": phase,
		"node": node_id,
		"node_id": node_id,
		"node_type": node_type,
		"node_title": HexGenerationNodeTypesScript.registry().get(node_type, {}).get("title", _node_title(node_type)),
		"steps": step,
		"total_steps": safe_total,
		"node_index": clampi(step, 0, safe_total),
		"node_total": safe_total,
		"progress": clampf(float(step) / float(safe_total), 0.0, 1.0),
		"cancelled": false,
	}


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
