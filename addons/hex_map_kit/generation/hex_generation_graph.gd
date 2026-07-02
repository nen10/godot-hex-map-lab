@tool
class_name HexGenerationGraph
extends RefCounted

const HexGenerationPortsScript = preload("res://addons/hex_map_kit/generation/hex_generation_ports.gd")
const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")


static func new_graph() -> Dictionary:
	return {
		"nodes": {},
		"edges": [],
		"settings": _default_settings(),
	}


static func add_node(
	graph: Dictionary,
	node_id: String,
	node_type: String,
	params: Dictionary = {},
	resource_refs: Dictionary = {}
) -> Dictionary:
	_ensure_graph_shape(graph)
	var node = {
		"id": node_id,
		"type": node_type,
		"params": params.duplicate(true),
		"resource_refs": resource_refs.duplicate(),
	}
	graph["nodes"][node_id] = node
	return node


static func add_edge(
	graph: Dictionary,
	from_node: String,
	to_node: String,
	to_port: String,
	from_port: String = HexGenerationNodeTypesScript.PORT_OUT,
	adaptation: String = ""
) -> Dictionary:
	_ensure_graph_shape(graph)
	var edge = {
		"from_node": from_node,
		"from_port": from_port,
		"to_node": to_node,
		"to_port": to_port,
	}
	if adaptation != "":
		edge["adaptation"] = adaptation
	graph["edges"].append(edge)
	return edge


static func would_create_cycle(graph: Dictionary, from_node: String, to_node: String) -> bool:
	_ensure_graph_shape(graph)
	var probe := graph.duplicate(true)
	_ensure_graph_shape(probe)
	probe["edges"].append({
		"from_node": from_node,
		"from_port": HexGenerationNodeTypesScript.PORT_OUT,
		"to_node": to_node,
		"to_port": "__cycle_probe__",
	})
	return not bool(topological_order(probe).get("ok", false))


static func validate(graph: Dictionary) -> Dictionary:
	_ensure_graph_shape(graph)
	var errors: Array = []
	var nodes: Dictionary = graph["nodes"]
	var edges: Array = graph["edges"]

	for node_id in nodes.keys():
		var node = nodes[node_id]
		var node_type = String(node.get("type", ""))
		if not HexGenerationNodeTypesScript.has_type(node_type):
			errors.append(_error("unknown_node_type", node_id, {}, "Unknown generation node type '%s'." % node_type))
			continue
		var output_type = HexGenerationNodeTypesScript.output_type_for_node(node)
		if output_type != "" and not HexGenerationPortsScript.is_valid(output_type):
			errors.append(_error("invalid_output_type", node_id, {}, "Node output type '%s' is not a graph port type." % output_type))

	var incoming_by_node := {}
	for node_id in nodes.keys():
		incoming_by_node[node_id] = {}

	for edge in edges:
		var from_node = String(edge.get("from_node", ""))
		var from_port = String(edge.get("from_port", HexGenerationNodeTypesScript.PORT_OUT))
		var to_node = String(edge.get("to_node", ""))
		var to_port = String(edge.get("to_port", ""))
		if not nodes.has(from_node) or not nodes.has(to_node):
			errors.append(_error("dangling_edge", to_node, edge, "Edge endpoint does not exist."))
			continue
		if from_port != HexGenerationNodeTypesScript.PORT_OUT:
			errors.append(_error("unknown_output_port", from_node, edge, "Unknown output port '%s'." % from_port))
			continue
		var to_type = String(nodes[to_node].get("type", ""))
		var input_def = HexGenerationNodeTypesScript.input_definition(to_type, to_port)
		if input_def.is_empty():
			errors.append(_error("unknown_input_port", to_node, edge, "Unknown input port '%s'." % to_port))
			continue
		var output_type = HexGenerationNodeTypesScript.output_type_for_node(nodes[from_node])
		var untyped_input := bool(input_def.get("untyped", false)) \
			or HexGenerationNodeTypesScript.is_consolidated_type(to_type)
		if not untyped_input and not HexGenerationPortsScript.compatible(output_type, input_def.get("accepts", [])):
			errors.append(_error(
				"type_mismatch",
				to_node,
				edge,
				"Cannot connect %s.%s (%s) to %s.%s (%s)." % [
					from_node,
					from_port,
					output_type,
					to_node,
					to_port,
					str(HexGenerationPortsScript.normalize_accepts(input_def.get("accepts", []))),
				]
			))
			continue
		if incoming_by_node[to_node].has(to_port):
			errors.append(_error(
				"duplicate_input_edge",
				to_node,
				edge,
				"Input port '%s' on node '%s' already has a connection." % [to_port, to_node]
			))
			continue
		incoming_by_node[to_node][to_port] = edge

	for node_id in nodes.keys():
		var node_type = String(nodes[node_id].get("type", ""))
		if not HexGenerationNodeTypesScript.has_type(node_type):
			continue
		for port_name in HexGenerationNodeTypesScript.input_definitions(node_type).keys():
			var input_def: Dictionary = HexGenerationNodeTypesScript.input_definition(node_type, String(port_name))
			if bool(input_def.get("required", true)) and not incoming_by_node[node_id].has(port_name):
				errors.append(_error("missing_required_input", node_id, {}, "Node '%s' requires input port '%s'." % [node_id, port_name]))
		if node_type == HexGenerationNodeTypesScript.NODE_SET_OPERATION and incoming_by_node[node_id].size() < 2:
			errors.append(_error(
				"missing_required_input",
				node_id,
				{},
				"Set Operation node '%s' requires at least two inputs." % node_id
			))

	var topo = topological_order(graph)
	if not bool(topo.get("ok", false)):
		for node_id in topo.get("cycle_nodes", []):
			errors.append(_error("cycle", String(node_id), {}, "Graph contains a cycle touching node '%s'." % String(node_id)))

	return {
		"ok": errors.is_empty(),
		"errors": errors,
	}


static func topological_order(graph: Dictionary) -> Dictionary:
	_ensure_graph_shape(graph)
	var nodes: Dictionary = graph["nodes"]
	var indegree := {}
	var adjacency := {}
	for node_id in nodes.keys():
		indegree[node_id] = 0
		adjacency[node_id] = []
	for edge in graph["edges"]:
		var from_node = String(edge.get("from_node", ""))
		var to_node = String(edge.get("to_node", ""))
		if not nodes.has(from_node) or not nodes.has(to_node):
			continue
		adjacency[from_node].append(to_node)
		indegree[to_node] = int(indegree[to_node]) + 1

	var ready: Array = []
	for node_id in nodes.keys():
		if int(indegree[node_id]) == 0:
			ready.append(node_id)
	ready.sort()

	var order: Array = []
	while not ready.is_empty():
		var node_id = ready.pop_front()
		order.append(node_id)
		var next_nodes: Array = adjacency[node_id]
		next_nodes.sort()
		for next_node in next_nodes:
			indegree[next_node] = int(indegree[next_node]) - 1
			if int(indegree[next_node]) == 0:
				ready.append(next_node)
		ready.sort()

	if order.size() == nodes.size():
		return {
			"ok": true,
			"order": order,
			"cycle_nodes": [],
		}

	var cycle_nodes: Array = []
	for node_id in nodes.keys():
		if not order.has(node_id):
			cycle_nodes.append(node_id)
	cycle_nodes.sort()
	return {
		"ok": false,
		"order": order,
		"cycle_nodes": cycle_nodes,
	}


static func incoming_edges_by_node(graph: Dictionary) -> Dictionary:
	_ensure_graph_shape(graph)
	var result := {}
	for node_id in graph["nodes"].keys():
		result[node_id] = {}
	for edge in graph["edges"]:
		var to_node = String(edge.get("to_node", ""))
		var to_port = String(edge.get("to_port", ""))
		if not result.has(to_node):
			continue
		result[to_node][to_port] = edge
	return result


static func _ensure_graph_shape(graph: Dictionary) -> void:
	if not graph.has("nodes") or not (graph["nodes"] is Dictionary):
		graph["nodes"] = {}
	if not graph.has("edges") or not (graph["edges"] is Array):
		graph["edges"] = []
	if not graph.has("settings") or not (graph["settings"] is Dictionary):
		graph["settings"] = _default_settings()


static func _default_settings() -> Dictionary:
	return {
		"seed": 0,
		"orientation": 0,
	}


static func normalized_settings(settings) -> Dictionary:
	var result := _default_settings()
	if settings is Dictionary:
		if (settings as Dictionary).has("seed"):
			result["seed"] = int((settings as Dictionary)["seed"])
		if (settings as Dictionary).has("orientation"):
			result["orientation"] = int((settings as Dictionary)["orientation"])
	return result


static func _error(code: String, node: String, edge: Dictionary, message: String) -> Dictionary:
	return {
		"code": code,
		"node": node,
		"edge": edge.duplicate(true),
		"message": message,
	}
