@tool
class_name HexGenerationPreset
extends RefCounted

const HexGenerationGraphScript = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")

const NODE_TERRAIN := "terrain"
const NODE_PATTERN_B := "pattern_b"
const NODE_SEEDS_A := "seeds_a"
const NODE_SEEDS_B := "seeds_b"
const NODE_MASK_1 := "mask_1"
const NODE_DOMAIN_ITEMS := "domain_items"
const NODE_ITEMS := "items"
const NODE_RESULT := "result"
const PROMOTE_ROLE_RESULT := "result"


static func from_profile(profile_res = null) -> Dictionary:
	return simple_template_graph(profile_res)


static func simple_template_graph(profile_res = null) -> Dictionary:
	var options := _profile_options(profile_res)
	var graph := HexGenerationGraphScript.new_graph()
	HexGenerationGraphScript.add_node(
		graph,
		NODE_TERRAIN,
		HexGenerationNodeTypesScript.NODE_TERRAIN_GENERATION,
		_terrain_params(options)
	)
	HexGenerationGraphScript.add_node(
		graph,
		NODE_RESULT,
		HexGenerationNodeTypesScript.NODE_RESULT,
		{
			"orientation": 0,
		}
	)
	HexGenerationGraphScript.add_edge(graph, NODE_TERRAIN, NODE_RESULT, "in_0")
	return graph


static func basic_template_graph() -> Dictionary:
	var graph := HexGenerationGraphScript.new_graph()
	HexGenerationGraphScript.add_node(
		graph,
		NODE_TERRAIN,
		HexGenerationNodeTypesScript.NODE_TERRAIN_GENERATION,
		{
			"display_name": "terrain",
			"base_mode": "shape",
			"shape": "rectangle",
			"width": 12,
			"height": 8,
			"wall_method": "random_probability",
			"wall_probability": 0.18,
			"wall_seed": 17,
			"connectivity_method": "dense",
			"connectivity_seed": 41,
			"toric_passage": false,
		}
	)
	HexGenerationGraphScript.add_node(
		graph,
		NODE_PATTERN_B,
		HexGenerationNodeTypesScript.NODE_TERRAIN_GENERATION,
		{
			"display_name": "pattern_b",
			"base_mode": "shape",
			"shape": "rectangle",
			"width": 12,
			"height": 8,
			"wall_method": "random_probability",
			"wall_probability": 0.32,
			"wall_seed": 211,
			"connectivity_method": "none",
			"toric_passage": false,
		}
	)
	HexGenerationGraphScript.add_node(
		graph,
		NODE_SEEDS_A,
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATION,
		{
			"display_name": "seeds_a",
			"source_mode": "result_substrate_floor",
			"placement_method": "weighted",
			"placement_probability": 0.35,
			"item_pool": [{"name": "seed_a", "weight": 1.0, "limit": 1, "display_name": "Seed A"}],
			"seed": 301,
		}
	)
	HexGenerationGraphScript.add_node(
		graph,
		NODE_SEEDS_B,
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATION,
		{
			"display_name": "seeds_b",
			"source_mode": "result_substrate_floor",
			"placement_method": "weighted",
			"placement_probability": 0.25,
			"item_pool": [{"name": "seed_b", "weight": 1.0, "limit": 1, "display_name": "Seed B"}],
			"seed": 307,
		}
	)
	HexGenerationGraphScript.add_node(
		graph,
		NODE_MASK_1,
		HexGenerationNodeTypesScript.NODE_SET_OPERATION,
		{
			"display_name": "mask_1",
			"operation": "union",
		}
	)
	HexGenerationGraphScript.add_node(
		graph,
		NODE_DOMAIN_ITEMS,
		HexGenerationNodeTypesScript.NODE_SET_OPERATION,
		{
			"display_name": "domain_items",
			"operation": "intersection",
		}
	)
	HexGenerationGraphScript.add_node(
		graph,
		NODE_ITEMS,
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATION,
		{
			"display_name": "items",
			"source_mode": "result_substrate_floor",
			"placement_method": "weighted",
			"placement_probability": 1.0,
			"item_pool": [{"name": "item", "weight": 1.0, "limit": 1, "display_name": "Item"}],
			"seed": 401,
		}
	)
	HexGenerationGraphScript.add_node(
		graph,
		NODE_RESULT,
		HexGenerationNodeTypesScript.NODE_RESULT,
		{
			"display_name": "result",
			"orientation": 0,
		}
	)
	HexGenerationGraphScript.add_edge(graph, NODE_PATTERN_B, NODE_SEEDS_A, "domain", "out", "floor")
	HexGenerationGraphScript.add_edge(graph, NODE_PATTERN_B, NODE_SEEDS_B, "domain", "out", "floor")
	HexGenerationGraphScript.add_edge(graph, NODE_SEEDS_A, NODE_MASK_1, "in_0", "out", "cells")
	HexGenerationGraphScript.add_edge(graph, NODE_SEEDS_B, NODE_MASK_1, "in_1", "out", "cells")
	HexGenerationGraphScript.add_edge(graph, NODE_TERRAIN, NODE_DOMAIN_ITEMS, "in_0", "out", "floor")
	HexGenerationGraphScript.add_edge(graph, NODE_MASK_1, NODE_DOMAIN_ITEMS, "in_1")
	HexGenerationGraphScript.add_edge(graph, NODE_DOMAIN_ITEMS, NODE_ITEMS, "domain")
	HexGenerationGraphScript.add_edge(graph, NODE_TERRAIN, NODE_RESULT, "in_0")
	HexGenerationGraphScript.add_edge(graph, NODE_ITEMS, NODE_RESULT, "in_1")
	return graph


static func promote_targets_for_profile(_profile_res = null) -> Array:
	return [{
		"node_id": NODE_RESULT,
		"role": PROMOTE_ROLE_RESULT,
	}]


static func default_selected_node_id() -> String:
	return NODE_RESULT


static func default_promote_role() -> String:
	return PROMOTE_ROLE_RESULT


static func _profile_options(profile_res) -> Dictionary:
	var defaults := {
		"shape_id": "rectangle",
		"width": 8,
		"height": 6,
		"radius": 3,
		"wall_probability": 0.18,
		"connectivity_mode": "dense",
		"seed": 0,
	}
	if profile_res == null:
		return defaults
	if profile_res.has_method("generation_options"):
		var options = profile_res.call("generation_options")
		if options is Dictionary:
			var option_dict := (options as Dictionary).duplicate(true)
			for key in defaults.keys():
				if not option_dict.has(key):
					option_dict[key] = defaults[key]
			return option_dict
	return defaults


static func _shape_params(options: Dictionary) -> Dictionary:
	var shape_id := String(options.get("shape_id", "rectangle"))
	match shape_id:
		"hexagon":
			return {
				"shape": "hexagon",
				"radius": max(0, int(options.get("radius", 3))),
			}
		"square":
			return {
				"shape": "square",
				"size": max(1, int(options.get("radius", options.get("width", 6)))),
			}
		"rectangle", _:
			return {
				"shape": "rectangle",
				"width": max(1, int(options.get("width", 8))),
				"height": max(1, int(options.get("height", 6))),
			}


static func _terrain_params(options: Dictionary) -> Dictionary:
	var params := _shape_params(options)
	params["base_mode"] = "shape"
	params["wall_method"] = "random_probability"
	params["wall_probability"] = clampf(float(options.get("wall_probability", 0.18)), 0.0, 1.0)
	params["wall_seed"] = int(options.get("seed", 0))
	params["connectivity_method"] = String(options.get("connectivity_mode", "dense"))
	params["connectivity_seed"] = int(options.get("seed", 0)) + 101
	return params
