@tool
class_name HexGenerationGraphResource
extends Resource

const HexGenerationGraph = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")

@export var graph_id := "build_graph"
@export var ownership_semantics := "embed"
@export var graph_model: Dictionary = HexGenerationGraph.new_graph():
	set(value):
		graph_model = _normalized_graph(value)


func to_graph_model() -> Dictionary:
	return _normalized_graph(graph_model)


func validation_result() -> Dictionary:
	return HexGenerationGraph.validate(to_graph_model())


func is_configured() -> bool:
	var model := to_graph_model()
	return not (model.get("nodes", {}) as Dictionary).is_empty()


static func _normalized_graph(graph: Dictionary) -> Dictionary:
	var result := HexGenerationGraph.new_graph()
	if graph.has("nodes") and graph["nodes"] is Dictionary:
		result["nodes"] = (graph["nodes"] as Dictionary).duplicate(true)
	if graph.has("edges") and graph["edges"] is Array:
		result["edges"] = (graph["edges"] as Array).duplicate(true)
	return result
