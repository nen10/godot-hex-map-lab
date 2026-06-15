class_name HexRuntimeGraphBuildSample
extends RefCounted

const HexGenerationGraph = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexMapGraphBuilder = preload("res://addons/hex_map_kit/generation/hex_map_graph_builder.gd")
const HexGenerationGraphResource = preload("res://addons/hex_map_kit/adapter/hex_generation_graph_resource.gd")


static func build_random_map(seed: int = 0) -> Dictionary:
	var graph_resource := sample_graph_resource()
	return HexMapGraphBuilder.build(graph_resource, {"seed": seed})


static func sample_graph_resource() -> HexGenerationGraphResource:
	var graph := HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle",
		"width": 10,
		"height": 6,
	})
	HexGenerationGraph.add_node(graph, "walls", "wall_field", {
		"wall_probability": 0.35,
	})
	HexGenerationGraph.add_edge(graph, "shape", "walls", "in")

	var resource := HexGenerationGraphResource.from_dict(graph)
	resource.graph_id = "runtime_random_map"
	resource.ownership_semantics = "embed"
	resource.semantics_snapshot = {"embed": true}
	resource.promote_targets = [{"node_id": "walls", "role": "terrain"}]
	return resource
