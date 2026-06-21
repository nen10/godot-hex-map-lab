@tool
class_name HexGenerationPreset
extends RefCounted

const HexGenerationGraphScript = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")

const NODE_SHAPE := "shape"
const NODE_WALLS := "walls"
const NODE_CONNECTIVITY := "connectivity"
const NODE_RESULT := "result"
const PROMOTE_ROLE_RESULT := "result"


static func from_profile(profile_res = null) -> Dictionary:
	var options := _profile_options(profile_res)
	var graph := HexGenerationGraphScript.new_graph()
	HexGenerationGraphScript.add_node(
		graph,
		NODE_SHAPE,
		HexGenerationNodeTypesScript.NODE_SHAPE,
		_shape_params(options)
	)
	HexGenerationGraphScript.add_node(
		graph,
		NODE_WALLS,
		HexGenerationNodeTypesScript.NODE_WALL_FIELD,
		{
			"wall_probability": clampf(float(options.get("wall_probability", 0.18)), 0.0, 1.0),
			"seed": int(options.get("seed", 0)),
		}
	)
	HexGenerationGraphScript.add_node(
		graph,
		NODE_CONNECTIVITY,
		HexGenerationNodeTypesScript.NODE_CONNECTIVITY,
		{
			"method": String(options.get("connectivity_mode", "dense")),
			"seed": int(options.get("seed", 0)) + 101,
		}
	)
	HexGenerationGraphScript.add_node(
		graph,
		NODE_RESULT,
		HexGenerationNodeTypesScript.NODE_RESULT,
		{
			"orientation": 0,
		}
	)
	HexGenerationGraphScript.add_edge(graph, NODE_SHAPE, NODE_WALLS, "in")
	HexGenerationGraphScript.add_edge(graph, NODE_WALLS, NODE_CONNECTIVITY, "in")
	HexGenerationGraphScript.add_edge(graph, NODE_CONNECTIVITY, NODE_RESULT, "terrain")
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
				"toric": false,
			}
		"rectangle", _:
			return {
				"shape": "rectangle",
				"width": max(1, int(options.get("width", 8))),
				"height": max(1, int(options.get("height", 6))),
				"toric": false,
			}
