@tool
class_name HexGenerationGraphNormalizer
extends RefCounted

const HexGenerationGraphScript = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const HexGenerationPortsScript = preload("res://addons/hex_map_kit/generation/hex_generation_ports.gd")


static func normalize_graph(legacy: Dictionary) -> Dictionary:
	var graph := _normalized_input_graph(legacy)
	var result := HexGenerationGraphScript.new_graph()
	result["settings"] = HexGenerationGraphScript.normalized_settings(graph.get("settings", {}))
	var state := {
		"terrain": {},
		"selection": {},
		"overlay": {},
		"result": {},
	}
	var node_ids := (graph.get("nodes", {}) as Dictionary).keys()
	node_ids.sort()
	for node_id in node_ids:
		var text_id := String(node_id)
		if _is_terminal_terrain_node(graph, text_id):
			_ensure_terrain_generation_node(graph, result, state, text_id)
	for node_id in node_ids:
		var text_id := String(node_id)
		var node_type := _node_type(graph, text_id)
		match node_type:
			HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR:
				_ensure_item_generation_node(graph, result, state, text_id)
			HexGenerationNodeTypesScript.NODE_SET_OPERATION:
				_ensure_set_operation_node(graph, result, state, text_id)
			HexGenerationNodeTypesScript.NODE_RESULT:
				_ensure_result_node(graph, result, state, text_id)
	return result


static func _normalized_input_graph(graph: Dictionary) -> Dictionary:
	var result := HexGenerationGraphScript.new_graph()
	result["settings"] = HexGenerationGraphScript.normalized_settings(graph.get("settings", {}))
	if graph.has("nodes") and graph["nodes"] is Dictionary:
		result["nodes"] = (graph["nodes"] as Dictionary).duplicate(true)
	if graph.has("edges") and graph["edges"] is Array:
		result["edges"] = (graph["edges"] as Array).duplicate(true)
	return result


static func _ensure_terrain_generation_node(legacy: Dictionary, result: Dictionary, state: Dictionary, legacy_node_id: String) -> String:
	var terrain_map := state["terrain"] as Dictionary
	if terrain_map.has(legacy_node_id):
		return String(terrain_map[legacy_node_id])
	var chain := _terrain_chain(legacy, legacy_node_id)
	var params := _terrain_params_from_chain(chain)
	var resource_refs := _resource_refs_from_chain(chain)
	HexGenerationGraphScript.add_node(
		result,
		legacy_node_id,
		HexGenerationNodeTypesScript.NODE_TERRAIN_GENERATION,
		params,
		resource_refs
	)
	terrain_map[legacy_node_id] = legacy_node_id
	_add_terrain_terminal_edges(legacy, result, state, legacy_node_id, chain)
	return legacy_node_id


static func _terrain_chain(legacy: Dictionary, terrain_node_id: String) -> Array:
	var chain: Array = []
	var current_id := terrain_node_id
	while current_id != "":
		var node := _node(legacy, current_id)
		if node.is_empty():
			break
		chain.push_front({
			"id": current_id,
			"node": node,
		})
		var node_type := String(node.get("type", ""))
		if node_type == HexGenerationNodeTypesScript.NODE_WALL_FIELD \
				or node_type == HexGenerationNodeTypesScript.NODE_CONNECTIVITY:
			current_id = _single_incoming_from(legacy, current_id, "in")
		else:
			break
	return chain


static func _terrain_params_from_chain(chain: Array) -> Dictionary:
	var params := {
		"base_mode": "shape",
		"wall_method": "none",
		"connectivity_method": "none",
	}
	for entry in chain:
		var node = (entry as Dictionary).get("node", {}) as Dictionary
		var node_params = (node.get("params", {}) as Dictionary).duplicate(true)
		match String(node.get("type", "")):
			HexGenerationNodeTypesScript.NODE_SOURCE:
				params.merge(_source_base_params(node_params), true)
			HexGenerationNodeTypesScript.NODE_SHAPE:
				params.merge(node_params, true)
				params["base_mode"] = "shape"
			HexGenerationNodeTypesScript.NODE_WALL_FIELD:
				params.merge(node_params, true)
				params["wall_method"] = String(node_params.get("wall_method", node_params.get("mode", "random_probability")))
				if node_params.has("seed"):
					params["wall_seed"] = int(node_params.get("seed", 0))
			HexGenerationNodeTypesScript.NODE_CONNECTIVITY:
				params.merge(node_params, true)
				params["connectivity_method"] = String(node_params.get("method", node_params.get("mode", "dense")))
				if node_params.has("seed"):
					params["connectivity_seed"] = int(node_params.get("seed", 0))
	return params


static func _source_base_params(params: Dictionary) -> Dictionary:
	var result := params.duplicate(true)
	match String(params.get("kind", "provided")):
		"document_terrain":
			result["base_mode"] = "document_terrain"
		"map_resource":
			result["base_mode"] = "map_resource"
		"result_terrain":
			result["base_mode"] = "result_terrain"
		_:
			result["base_mode"] = "map_resource"
	return result


static func _resource_refs_from_chain(chain: Array) -> Dictionary:
	var result := {}
	for entry in chain:
		var node = (entry as Dictionary).get("node", {}) as Dictionary
		var refs = node.get("resource_refs", {}) as Dictionary
		for key in refs.keys():
			result[key] = refs[key]
	return result


static func _add_terrain_terminal_edges(legacy: Dictionary, result: Dictionary, state: Dictionary, terrain_node_id: String, chain: Array) -> void:
	for entry in chain:
		var node_id := String((entry as Dictionary).get("id", ""))
		if _node_type(legacy, node_id) != HexGenerationNodeTypesScript.NODE_CONNECTIVITY:
			continue
		for edge in _incoming_edges(legacy, node_id, "terminals"):
			var source := _selection_source(legacy, result, state, String((edge as Dictionary).get("from_node", "")))
			var source_node := String(source.get("node", ""))
			if source_node == "":
				continue
			HexGenerationGraphScript.add_edge(
				result,
				source_node,
				terrain_node_id,
				"terminals",
				HexGenerationNodeTypesScript.PORT_OUT,
				String(source.get("adaptation", ""))
			)


static func _ensure_item_generation_node(legacy: Dictionary, result: Dictionary, state: Dictionary, legacy_node_id: String) -> String:
	var overlay_map := state["overlay"] as Dictionary
	if overlay_map.has(legacy_node_id):
		return String(overlay_map[legacy_node_id])
	var node := _node(legacy, legacy_node_id)
	HexGenerationGraphScript.add_node(
		result,
		legacy_node_id,
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATION,
		(node.get("params", {}) as Dictionary).duplicate(true),
		(node.get("resource_refs", {}) as Dictionary).duplicate(true)
	)
	overlay_map[legacy_node_id] = legacy_node_id
	for edge in _incoming_edges(legacy, legacy_node_id, "scope"):
		var source := _selection_source(legacy, result, state, String((edge as Dictionary).get("from_node", "")))
		var source_node := String(source.get("node", ""))
		if source_node == "":
			continue
		HexGenerationGraphScript.add_edge(
			result,
			source_node,
			legacy_node_id,
			"domain",
			HexGenerationNodeTypesScript.PORT_OUT,
			String(source.get("adaptation", ""))
		)
	return legacy_node_id


static func _ensure_set_operation_node(legacy: Dictionary, result: Dictionary, state: Dictionary, legacy_node_id: String) -> String:
	var selection_map := state["selection"] as Dictionary
	if selection_map.has(legacy_node_id):
		return String(selection_map[legacy_node_id])
	var node := _node(legacy, legacy_node_id)
	HexGenerationGraphScript.add_node(
		result,
		legacy_node_id,
		HexGenerationNodeTypesScript.NODE_SET_OPERATION,
		(node.get("params", {}) as Dictionary).duplicate(true),
		(node.get("resource_refs", {}) as Dictionary).duplicate(true)
	)
	selection_map[legacy_node_id] = legacy_node_id
	var input_index := 0
	for edge in _ordered_set_operation_edges(legacy, legacy_node_id):
		var source := _selection_source(legacy, result, state, String((edge as Dictionary).get("from_node", "")))
		var source_node := String(source.get("node", ""))
		if source_node == "":
			continue
		HexGenerationGraphScript.add_edge(
			result,
			source_node,
			legacy_node_id,
			"in_%d" % input_index,
			HexGenerationNodeTypesScript.PORT_OUT,
			String(source.get("adaptation", ""))
		)
		input_index += 1
	return legacy_node_id


static func _selection_source(legacy: Dictionary, result: Dictionary, state: Dictionary, legacy_node_id: String) -> Dictionary:
	var node_type := _node_type(legacy, legacy_node_id)
	match node_type:
		HexGenerationNodeTypesScript.NODE_REGION_FILTER, HexGenerationNodeTypesScript.NODE_TERRAIN_FILTER, HexGenerationNodeTypesScript.NODE_OVERLAY_FILTER:
			var input_id := _single_incoming_from(legacy, legacy_node_id, "in")
			var upstream := _output_source(legacy, result, state, input_id)
			upstream["adaptation"] = _adaptation_for_filter(_node(legacy, legacy_node_id).get("params", {}) as Dictionary)
			return upstream
		HexGenerationNodeTypesScript.NODE_SET_OPERATION:
			return {
				"node": _ensure_set_operation_node(legacy, result, state, legacy_node_id),
				"adaptation": "",
			}
		_:
			return _output_source(legacy, result, state, legacy_node_id)


static func _output_source(legacy: Dictionary, result: Dictionary, state: Dictionary, legacy_node_id: String) -> Dictionary:
	var node := _node(legacy, legacy_node_id)
	if node.is_empty():
		return {"node": "", "adaptation": ""}
	var output_type := HexGenerationNodeTypesScript.output_type_for_node(node)
	match output_type:
		HexGenerationPortsScript.TERRAIN:
			return {
				"node": _ensure_terrain_generation_node(legacy, result, state, legacy_node_id),
				"adaptation": "floor",
			}
		HexGenerationPortsScript.OVERLAY:
			return {
				"node": _ensure_item_generation_node(legacy, result, state, legacy_node_id),
				"adaptation": "cells",
			}
		HexGenerationPortsScript.SELECTION:
			return {
				"node": _ensure_set_operation_node(legacy, result, state, legacy_node_id),
				"adaptation": "",
			}
		_:
			return {"node": "", "adaptation": ""}


static func _adaptation_for_filter(params: Dictionary) -> String:
	var filter_target := String(params.get("filter_target", params.get("mode", "floor")))
	if filter_target == "item_key":
		return "item:%s" % String(params.get("item_key", ""))
	return filter_target


static func _ensure_result_node(legacy: Dictionary, result: Dictionary, state: Dictionary, legacy_node_id: String) -> String:
	var result_map := state["result"] as Dictionary
	if result_map.has(legacy_node_id):
		return String(result_map[legacy_node_id])
	var node := _node(legacy, legacy_node_id)
	HexGenerationGraphScript.add_node(
		result,
		legacy_node_id,
		HexGenerationNodeTypesScript.NODE_RESULT,
		(node.get("params", {}) as Dictionary).duplicate(true),
		(node.get("resource_refs", {}) as Dictionary).duplicate(true)
	)
	result_map[legacy_node_id] = legacy_node_id
	var input_index := 0
	for edge in _incoming_edges(legacy, legacy_node_id):
		var from_node := String((edge as Dictionary).get("from_node", ""))
		var sources := _result_input_sources(legacy, result, state, from_node)
		for source in sources:
			var source_node := String((source as Dictionary).get("node", ""))
			if source_node == "":
				continue
			HexGenerationGraphScript.add_edge(
				result,
				source_node,
				legacy_node_id,
				"in_%d" % input_index,
				HexGenerationNodeTypesScript.PORT_OUT,
				String((source as Dictionary).get("adaptation", ""))
			)
			input_index += 1
	return legacy_node_id


static func _result_input_sources(legacy: Dictionary, result: Dictionary, state: Dictionary, legacy_node_id: String) -> Array:
	if _node_type(legacy, legacy_node_id) == HexGenerationNodeTypesScript.NODE_COMPOSE:
		var flattened: Array = []
		for port_name in ["base", "add"]:
			var input_id := _single_incoming_from(legacy, legacy_node_id, port_name)
			flattened.append_array(_result_input_sources(legacy, result, state, input_id))
		return flattened
	var source := _output_source(legacy, result, state, legacy_node_id)
	return [source] if String(source.get("node", "")) != "" else []


static func _ordered_set_operation_edges(legacy: Dictionary, node_id: String) -> Array:
	var edges := _incoming_edges(legacy, node_id)
	edges.sort_custom(func(a, b):
		return _set_operation_port_rank(String((a as Dictionary).get("to_port", ""))) < _set_operation_port_rank(String((b as Dictionary).get("to_port", "")))
	)
	return edges


static func _set_operation_port_rank(port_name: String) -> int:
	if port_name == "a":
		return 0
	if port_name == "b":
		return 1
	if port_name.begins_with("in_"):
		return int(port_name.substr(3))
	return 1000


static func _is_terminal_terrain_node(graph: Dictionary, node_id: String) -> bool:
	if HexGenerationNodeTypesScript.output_type_for_node(_node(graph, node_id)) != HexGenerationPortsScript.TERRAIN:
		return false
	var outgoing := _outgoing_edges(graph, node_id)
	if outgoing.is_empty():
		return true
	for edge in outgoing:
		var to_node := String((edge as Dictionary).get("to_node", ""))
		var to_type := _node_type(graph, to_node)
		if to_type != HexGenerationNodeTypesScript.NODE_WALL_FIELD \
				and to_type != HexGenerationNodeTypesScript.NODE_CONNECTIVITY:
			return true
	return false


static func _node(graph: Dictionary, node_id: String) -> Dictionary:
	return (graph.get("nodes", {}) as Dictionary).get(node_id, {}) as Dictionary


static func _node_type(graph: Dictionary, node_id: String) -> String:
	return String(_node(graph, node_id).get("type", ""))


static func _incoming_edges(graph: Dictionary, node_id: String, port_name: String = "") -> Array:
	var result: Array = []
	for edge in graph.get("edges", []) as Array:
		var edge_dict := edge as Dictionary
		if String(edge_dict.get("to_node", "")) != node_id:
			continue
		if port_name != "" and String(edge_dict.get("to_port", "")) != port_name:
			continue
		result.append(edge_dict)
	return result


static func _outgoing_edges(graph: Dictionary, node_id: String) -> Array:
	var result: Array = []
	for edge in graph.get("edges", []) as Array:
		var edge_dict := edge as Dictionary
		if String(edge_dict.get("from_node", "")) == node_id:
			result.append(edge_dict)
	return result


static func _single_incoming_from(graph: Dictionary, node_id: String, port_name: String) -> String:
	for edge in _incoming_edges(graph, node_id, port_name):
		return String((edge as Dictionary).get("from_node", ""))
	return ""
