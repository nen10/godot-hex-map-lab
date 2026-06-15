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
			"errors": validation.get("errors", []),
			"cache": {},
		}

	var topo = HexGenerationGraphScript.topological_order(graph)
	if not bool(topo.get("ok", false)):
		return {
			"ok": false,
			"errors": [],
			"cache": {},
		}

	var cache := {}
	var incoming = HexGenerationGraphScript.incoming_edges_by_node(graph)
	for node_id in topo["order"]:
		var node: Dictionary = graph["nodes"][node_id]
		var inputs := {}
		for port_name in incoming[node_id].keys():
			var edge: Dictionary = incoming[node_id][port_name]
			inputs[port_name] = cache.get(String(edge.get("from_node", "")), null)
		cache[node_id] = HexGenerationNodeTypesScript.run_node(node, inputs, context)

	return {
		"ok": true,
		"errors": [],
		"cache": cache,
	}

