@tool
class_name HexGenerationGraphResource
extends Resource

const HexGenerationGraph = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")

@export var display_name := ""
@export var graph_id := "build_graph"
@export var ownership_semantics := "embed"
@export_file("*.tres") var semantics_reference_path := ""
@export var nodes: Array = []:
	set(value):
		nodes = _normalized_nodes(value)
@export var edges: Array = []:
	set(value):
		edges = _normalized_edges(value)
@export var promote_targets: Array = []:
	set(value):
		promote_targets = _normalized_promote_targets(value)
@export var graph_settings: Dictionary = {}:
	set(value):
		graph_settings = HexGenerationGraph.normalized_settings(value)
@export var semantics_snapshot: Dictionary = {}:
	set(value):
		semantics_snapshot = value.duplicate(true)

var graph_model: Dictionary = HexGenerationGraph.new_graph():
	set(value):
		set_from_dict(value)
	get:
		return to_dict()


func to_graph_model() -> Dictionary:
	return to_dict()


func to_dict() -> Dictionary:
	var result := HexGenerationGraph.new_graph()
	result["settings"] = HexGenerationGraph.normalized_settings(graph_settings)
	for node_entry in nodes:
		var node = node_entry as Dictionary
		HexGenerationGraph.add_node(
			result,
			String(node.get("id", "")),
			String(node.get("type", "")),
			node.get("params", {}) as Dictionary,
			node.get("resource_refs", {}) as Dictionary
		)
	for edge_entry in edges:
		var edge = edge_entry as Dictionary
		HexGenerationGraph.add_edge(
			result,
			String(edge.get("from_node", "")),
			String(edge.get("to_node", "")),
			String(edge.get("to_port", "")),
			String(edge.get("from_port", "out")),
			String(edge.get("adaptation", ""))
		)
	return _normalized_graph(result)


func set_from_dict(graph: Dictionary) -> void:
	var normalized := _normalized_graph(graph)
	graph_settings = HexGenerationGraph.normalized_settings(normalized.get("settings", {}))
	nodes = _nodes_from_graph(normalized)
	edges = _normalized_edges(normalized.get("edges", []) as Array)


static func from_dict(graph: Dictionary) -> HexGenerationGraphResource:
	var resource = load("res://addons/hex_map_kit/adapter/hex_generation_graph_resource.gd").new()
	resource.set_from_dict(graph)
	return resource


func validation_result() -> Dictionary:
	return HexGenerationGraph.validate(to_graph_model())


func is_configured() -> bool:
	var model := to_graph_model()
	return not (model.get("nodes", {}) as Dictionary).is_empty()


static func _normalized_graph(graph: Dictionary) -> Dictionary:
	var result := HexGenerationGraph.new_graph()
	result["settings"] = HexGenerationGraph.normalized_settings(graph.get("settings", {}))
	if graph.has("nodes") and graph["nodes"] is Dictionary:
		result["nodes"] = (graph["nodes"] as Dictionary).duplicate(true)
	if graph.has("edges") and graph["edges"] is Array:
		result["edges"] = (graph["edges"] as Array).duplicate(true)
	return result


static func _nodes_from_graph(graph: Dictionary) -> Array:
	var result: Array = []
	var node_ids := (graph.get("nodes", {}) as Dictionary).keys()
	node_ids.sort()
	for node_id in node_ids:
		var node = (graph["nodes"] as Dictionary)[node_id] as Dictionary
		result.append({
			"id": String(node.get("id", node_id)),
			"type": String(node.get("type", "")),
			"params": (node.get("params", {}) as Dictionary).duplicate(true),
			"resource_refs": (node.get("resource_refs", {}) as Dictionary).duplicate(true),
		})
	return result


static func _normalized_nodes(value) -> Array:
	var result: Array = []
	if not value is Array:
		return result
	for raw_node in value:
		if not raw_node is Dictionary:
			continue
		var node = raw_node as Dictionary
		var node_id := String(node.get("id", "")).strip_edges()
		if node_id == "":
			continue
		result.append({
			"id": node_id,
			"type": String(node.get("type", "")),
			"params": (node.get("params", {}) as Dictionary).duplicate(true),
			"resource_refs": (node.get("resource_refs", {}) as Dictionary).duplicate(true),
		})
	return result


static func _normalized_edges(value) -> Array:
	var result: Array = []
	if not value is Array:
		return result
	for raw_edge in value:
		if not raw_edge is Dictionary:
			continue
		var edge = raw_edge as Dictionary
		var from_node := String(edge.get("from_node", "")).strip_edges()
		var to_node := String(edge.get("to_node", "")).strip_edges()
		var to_port := String(edge.get("to_port", "")).strip_edges()
		if from_node == "" or to_node == "" or to_port == "":
			continue
		var normalized := {
			"from_node": from_node,
			"from_port": String(edge.get("from_port", "out")),
			"to_node": to_node,
			"to_port": to_port,
		}
		var adaptation := String(edge.get("adaptation", "")).strip_edges()
		if adaptation != "":
			normalized["adaptation"] = adaptation
		result.append(normalized)
	return result


static func _normalized_promote_targets(value) -> Array:
	var result: Array = []
	if not value is Array:
		return result
	for raw_target in value:
		if not raw_target is Dictionary:
			continue
		var target = raw_target as Dictionary
		var node_id := String(target.get("node_id", "")).strip_edges()
		var role := String(target.get("role", "")).strip_edges()
		if node_id == "" or role == "":
			continue
		result.append({
			"node_id": node_id,
			"role": role,
		})
	return result
