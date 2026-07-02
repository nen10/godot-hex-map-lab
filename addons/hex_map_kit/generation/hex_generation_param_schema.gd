@tool
class_name HexGenerationParamSchema
extends RefCounted

const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")

const CONTROL_OPTION := "option"
const CONTROL_SPIN_FLOAT := "spin_float"
const CONTROL_SPIN_INT := "spin_int"
const CONTROL_CHECK := "check"
const CONTROL_LINE_EDIT := "line_edit"
const CONTROL_ITEM_POOL := "item_pool"
const CONTROL_CUSTOM_DISTRIBUTION := "custom_distribution"
const CONTROL_PROBABILITY_RULES := "probability_rules"

const ASSET_NONE := ""
const ASSET_ADJACENCY_RULES := "adjacency_rules"
const ASSET_WALL_DISTRIBUTIONS := "wall_distributions"
const ASSET_ITEM_POOLS := "item_pools"


static func declarations(node_type: String) -> Dictionary:
	return _declarations_for(node_type).duplicate(true)


static func schema_for(node_type: String, params: Dictionary) -> Array[Dictionary]:
	var effective_params := default_params(node_type)
	for key in params.keys():
		effective_params[key] = params[key]

	var declarations_by_key := _declarations_for(node_type)
	var result: Array[Dictionary] = []
	for key in _ordered_keys_for(node_type):
		var declaration = declarations_by_key.get(key, {})
		if not declaration is Dictionary:
			continue
		var entry := (declaration as Dictionary).duplicate(true)
		entry["visible_when"] = _condition_matches(entry.get("visible_when", {}), effective_params)
		entry["label"] = _effective_label(entry, effective_params)
		result.append(entry)
	return result


static func default_params(node_type: String) -> Dictionary:
	var result := {}
	var declarations_by_key := _declarations_for(node_type)
	for key in _ordered_keys_for(node_type):
		var declaration = declarations_by_key.get(key, {})
		if declaration is Dictionary and (declaration as Dictionary).has("default"):
			var value = (declaration as Dictionary)["default"]
			result[key] = value.duplicate(true) if value is Array or value is Dictionary else value
	for key in _ordered_keys_for(node_type):
		var declaration = declarations_by_key.get(key, {})
		if declaration is Dictionary:
			_apply_derived_default(result, declaration as Dictionary)
	return result


static func _declarations_for(node_type: String) -> Dictionary:
	match node_type:
		HexGenerationNodeTypesScript.NODE_TERRAIN_GENERATION:
			return _terrain_generation_declarations()
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATION:
			return _item_generation_declarations()
		HexGenerationNodeTypesScript.NODE_SET_OPERATION:
			return _set_operation_declarations()
		HexGenerationNodeTypesScript.NODE_RESULT:
			return _result_declarations()
		_:
			return {}


static func _ordered_keys_for(node_type: String) -> Array[String]:
	match node_type:
		HexGenerationNodeTypesScript.NODE_TERRAIN_GENERATION:
			return [
				"base_mode",
				"shape",
				"width",
				"height",
				"size",
				"radius",
				"layer_id",
				"layer_index",
				"wall_method",
				"wall_probability",
				"distribution_mode",
				"distribution_asset_path",
				"distribution_id",
				"custom_distribution",
				"wall_seed",
				"connectivity_method",
				"toric_passage",
				"connectivity_seed",
			]
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATION:
			return [
				"source_mode",
				"source_adaptation",
				"layer_id",
				"layer_index",
				"placement_method",
				"placement_probability",
				"item_pool",
				"item_pool_asset_path",
				"item_name",
				"probability_rules",
				"rules_asset_path",
				"neighbor_radius",
				"include_generated_reference",
				"seed",
			]
		HexGenerationNodeTypesScript.NODE_SET_OPERATION:
			return ["operation", "display_name"]
		HexGenerationNodeTypesScript.NODE_RESULT:
			return ["orientation"]
		_:
			return []


static func _terrain_generation_declarations() -> Dictionary:
	return {
		"base_mode": _entry("base_mode", "Base", CONTROL_OPTION, "shape", {
			"options": [
				_option("Shape", "shape"),
				_option("Document Terrain", "document_terrain"),
				_option("Map Resource", "map_resource"),
				_option("Result Terrain", "result_terrain"),
			],
			"derived_default": {
				"shape": {
					"shape": "rectangle",
					"width": HexGenerationNodeTypesScript.DEFAULT_RECTANGLE_WIDTH,
					"height": HexGenerationNodeTypesScript.DEFAULT_RECTANGLE_HEIGHT,
				},
				"document_terrain": {"layer_index": 0},
				"map_resource": {},
				"result_terrain": {},
			},
			"affects": ["shape", "width", "height", "size", "radius", "layer_id", "layer_index", "toric_passage"],
		}),
		"shape": _entry("shape", "Shape", CONTROL_OPTION, "rectangle", {
			"options": [
				_option("Rectangle", "rectangle"),
				_option("Square", "square"),
				_option("Hexagon", "hexagon"),
			],
			"visible_when": _is("base_mode", "shape"),
			"derived_default": {
				"rectangle": {
					"width": HexGenerationNodeTypesScript.DEFAULT_RECTANGLE_WIDTH,
					"height": HexGenerationNodeTypesScript.DEFAULT_RECTANGLE_HEIGHT,
				},
				"square": {"size": HexGenerationNodeTypesScript.DEFAULT_SQUARE_SIZE},
				"hexagon": {"radius": HexGenerationNodeTypesScript.DEFAULT_HEXAGON_RADIUS},
			},
			"affects": ["width", "height", "size", "radius", "toric_passage"],
		}),
		"width": _entry("width", "Width", CONTROL_SPIN_INT, HexGenerationNodeTypesScript.DEFAULT_RECTANGLE_WIDTH, {
			"min": 1,
			"max": 256,
			"step": 1,
			"visible_when": _all([_is("base_mode", "shape"), _is("shape", "rectangle")]),
		}),
		"height": _entry("height", "Height", CONTROL_SPIN_INT, HexGenerationNodeTypesScript.DEFAULT_RECTANGLE_HEIGHT, {
			"min": 1,
			"max": 256,
			"step": 1,
			"visible_when": _all([_is("base_mode", "shape"), _is("shape", "rectangle")]),
		}),
		"size": _entry("size", "Size", CONTROL_SPIN_INT, HexGenerationNodeTypesScript.DEFAULT_SQUARE_SIZE, {
			"min": 1,
			"max": 256,
			"step": 1,
			"visible_when": _all([_is("base_mode", "shape"), _is("shape", "square")]),
		}),
		"radius": _entry("radius", "Radius", CONTROL_SPIN_INT, HexGenerationNodeTypesScript.DEFAULT_HEXAGON_RADIUS, {
			"min": 1,
			"max": 128,
			"step": 1,
			"visible_when": _all([_is("base_mode", "shape"), _is("shape", "hexagon")]),
		}),
		"layer_id": _entry("layer_id", "Layer ID", CONTROL_LINE_EDIT, "", {
			"visible_when": _is("base_mode", "document_terrain"),
		}),
		"layer_index": _entry("layer_index", "Layer Index", CONTROL_SPIN_INT, 0, {
			"min": 0,
			"max": 999,
			"step": 1,
			"visible_when": _is("base_mode", "document_terrain"),
		}),
		"wall_method": _entry("wall_method", "Wall Method", CONTROL_OPTION, "none", {
			"options": [
				_option("None", "none"),
				_option("Random Probability", "random_probability"),
				_option("Markov Mesh", "markov_mesh"),
			],
			"derived_default": {
				"none": {},
				"random_probability": {"wall_probability": 0.3},
				"markov_mesh": {
					"wall_probability": 0.3,
					"distribution_mode": "preset",
					"distribution_id": 20,
				},
			},
			"affects": ["wall_probability", "distribution_mode", "distribution_asset_path", "distribution_id", "custom_distribution", "wall_seed"],
		}),
		"wall_probability": _entry("wall_probability", "Probability / Cell", CONTROL_SPIN_FLOAT, 0.3, {
			"min": 0.0,
			"max": 1.0,
			"step": 0.05,
			"visible_when": _in("wall_method", ["random_probability", "markov_mesh"]),
			"label_by_mode": {
				"wall_method": {
					"markov_mesh": "Initial Probability",
					"_default": "Probability / Cell",
				},
			},
		}),
		"distribution_mode": _entry("distribution_mode", "Distribution Mode", CONTROL_OPTION, "preset", {
			"options": [
				_option("Preset", "preset"),
				_option("Custom", "custom"),
			],
			"visible_when": _is("wall_method", "markov_mesh"),
			"derived_default": {
				"preset": {"distribution_id": 20},
				"custom": {"custom_distribution": _default_custom_distribution()},
			},
			"affects": ["distribution_id", "custom_distribution"],
		}),
		"distribution_asset_path": _entry("distribution_asset_path", "Distribution Asset Path", CONTROL_LINE_EDIT, "", {
			"visible_when": _is("wall_method", "markov_mesh"),
			"asset_kind": ASSET_WALL_DISTRIBUTIONS,
			"hidden": true,
		}),
		"distribution_id": _entry("distribution_id", "Distribution", CONTROL_OPTION, 20, {
			"options": [
				_option("Ilands", 11),
				_option("Maze", 20),
				_option("Discrete", 24),
			],
			"visible_when": _all([_is("wall_method", "markov_mesh"), _is("distribution_mode", "preset")]),
			"asset_kind": ASSET_WALL_DISTRIBUTIONS,
		}),
		"custom_distribution": _entry("custom_distribution", "Custom Distribution", CONTROL_CUSTOM_DISTRIBUTION, _default_custom_distribution(), {
			"visible_when": _all([_is("wall_method", "markov_mesh"), _is("distribution_mode", "custom")]),
			"asset_kind": ASSET_WALL_DISTRIBUTIONS,
		}),
		"wall_seed": _entry("wall_seed", "Wall Seed", CONTROL_SPIN_INT, 0, {
			"min": 0,
			"max": 999999,
			"step": 1,
			"visible_when": _not(_is("wall_method", "none")),
		}),
		"connectivity_method": _entry("connectivity_method", "Passage Method", CONTROL_OPTION, "none", {
			"options": [
				_option("None", "none"),
				_option("Dense", "dense"),
				_option("Sparse", "sparse"),
				_option("Terminal", "terminal"),
			],
			"derived_default": {
				"none": {},
				"dense": {"connectivity_seed": 0},
				"sparse": {"connectivity_seed": 0},
				"terminal": {"connectivity_seed": 0},
			},
			"affects": ["connectivity_seed"],
		}),
		"toric_passage": _entry("toric_passage", "Toric Passage", CONTROL_CHECK, false, {
			"visible_when": _all([_is("base_mode", "shape"), _is("shape", "square")]),
		}),
		"connectivity_seed": _entry("connectivity_seed", "Passage Seed", CONTROL_SPIN_INT, 0, {
			"min": 0,
			"max": 999999,
			"step": 1,
			"visible_when": _not(_is("connectivity_method", "none")),
		}),
	}


static func _item_generation_declarations() -> Dictionary:
	return {
		"source_mode": _entry("source_mode", "Domain Source", CONTROL_OPTION, "result_substrate_floor", {
			"options": [
				_option("Result Terrain Floor", "result_substrate_floor"),
				_option("Document Overlay", "document_overlay"),
			],
			"derived_default": {
				"result_substrate_floor": {"source_adaptation": "floor"},
				"document_overlay": {
					"source_adaptation": "cells",
					"layer_index": 0,
				},
			},
			"affects": ["source_adaptation", "layer_id", "layer_index"],
		}),
		"source_adaptation": _entry("source_adaptation", "Source Adaptation", CONTROL_OPTION, "cells", {
			"options": [
				_option("Cells", "cells"),
				_option("Item Key", "item:item"),
			],
			"visible_when": _is("source_mode", "document_overlay"),
		}),
		"layer_id": _entry("layer_id", "Layer ID", CONTROL_LINE_EDIT, "", {
			"visible_when": _is("source_mode", "document_overlay"),
		}),
		"layer_index": _entry("layer_index", "Layer Index", CONTROL_SPIN_INT, 0, {
			"min": 0,
			"max": 999,
			"step": 1,
			"visible_when": _is("source_mode", "document_overlay"),
		}),
		"placement_method": _entry("placement_method", "Placement Method", CONTROL_OPTION, "weighted", {
			"options": [
				_option("Weighted", "weighted"),
				_option("Limited", "limited"),
				_option("Adjacency Rules", "adjacency_rules"),
			],
			"derived_default": {
				"weighted": {
					"placement_probability": 1.0,
					"item_pool": _default_item_pool(),
				},
				"limited": {"item_pool": _default_item_pool()},
				"adjacency_rules": {
					"item_name": "item",
					"probability_rules": _default_probability_rules(),
					"neighbor_radius": 1,
					"include_generated_reference": false,
				},
			},
			"affects": [
				"placement_probability",
				"item_pool",
				"item_pool_asset_path",
				"item_name",
				"probability_rules",
				"rules_asset_path",
				"neighbor_radius",
				"include_generated_reference",
			],
		}),
		"placement_probability": _entry("placement_probability", "Probability / Cell", CONTROL_SPIN_FLOAT, 1.0, {
			"min": 0.0,
			"max": 1.0,
			"step": 0.05,
			"visible_when": _is("placement_method", "weighted"),
		}),
		"item_pool": _entry("item_pool", "Item Pool", CONTROL_ITEM_POOL, _default_item_pool(), {
			"visible_when": _in("placement_method", ["weighted", "limited"]),
			"asset_kind": ASSET_ITEM_POOLS,
		}),
		"item_pool_asset_path": _entry("item_pool_asset_path", "Item Pool Asset Path", CONTROL_LINE_EDIT, "", {
			"visible_when": _in("placement_method", ["weighted", "limited"]),
			"asset_kind": ASSET_ITEM_POOLS,
			"hidden": true,
		}),
		"item_name": _entry("item_name", "Item Name", CONTROL_LINE_EDIT, "item", {
			"visible_when": _is("placement_method", "adjacency_rules"),
		}),
		"probability_rules": _entry("probability_rules", "Probability Rules", CONTROL_PROBABILITY_RULES, _default_probability_rules(), {
			"visible_when": _is("placement_method", "adjacency_rules"),
			"asset_kind": ASSET_ADJACENCY_RULES,
		}),
		"rules_asset_path": _entry("rules_asset_path", "Rules Asset Path", CONTROL_LINE_EDIT, "", {
			"visible_when": _is("placement_method", "adjacency_rules"),
			"asset_kind": ASSET_ADJACENCY_RULES,
			"hidden": true,
		}),
		"neighbor_radius": _entry("neighbor_radius", "Neighbor Radius", CONTROL_SPIN_INT, 1, {
			"min": 1,
			"max": 16,
			"step": 1,
			"visible_when": _is("placement_method", "adjacency_rules"),
		}),
		"include_generated_reference": _entry("include_generated_reference", "Include Generated Reference", CONTROL_CHECK, false, {
			"visible_when": _is("placement_method", "adjacency_rules"),
		}),
		"seed": _entry("seed", "Seed", CONTROL_SPIN_INT, 0, {
			"min": 0,
			"max": 999999,
			"step": 1,
		}),
	}


static func _set_operation_declarations() -> Dictionary:
	return {
		"operation": _entry("operation", "Operation", CONTROL_OPTION, "union", {
			"options": [
				_option("Union", "union"),
				_option("Intersection", "intersection"),
				_option("Difference", "difference"),
			],
		}),
		"display_name": _entry("display_name", "Expression Name", CONTROL_LINE_EDIT, ""),
	}


static func _result_declarations() -> Dictionary:
	return {
		"orientation": _entry("orientation", "Orientation", CONTROL_OPTION, 0, {
			"options": [
				_option("Flat Top", 0),
				_option("Pointy Top", 1),
			],
		}),
	}


static func _entry(key: String, label: String, control: String, default_value: Variant, extra: Dictionary = {}) -> Dictionary:
	var result := {
		"key": key,
		"control": control,
		"options": [],
		"min": null,
		"max": null,
		"step": null,
		"default": default_value.duplicate(true) if default_value is Array or default_value is Dictionary else default_value,
		"visible_when": {},
		"label": label,
		"label_by_mode": {},
		"derived_default": {},
		"affects": [],
		"asset_kind": ASSET_NONE,
		"hidden": false,
	}
	for extra_key in extra.keys():
		var value = extra[extra_key]
		result[extra_key] = value.duplicate(true) if value is Array or value is Dictionary else value
	return result


static func _apply_derived_default(params: Dictionary, declaration: Dictionary) -> void:
	var derived_default = declaration.get("derived_default", {})
	if not derived_default is Dictionary or (derived_default as Dictionary).is_empty():
		return
	var key := String(declaration.get("key", ""))
	var current_value = params.get(key, declaration.get("default", null))
	if not (derived_default as Dictionary).has(current_value):
		return
	var derived_values = (derived_default as Dictionary)[current_value]
	if not derived_values is Dictionary:
		return
	for derived_key in (derived_values as Dictionary).keys():
		var value = (derived_values as Dictionary)[derived_key]
		params[derived_key] = value.duplicate(true) if value is Array or value is Dictionary else value


static func _option(label: String, value: Variant) -> Dictionary:
	return {
		"label": label,
		"value": value,
	}


static func _is(key: String, value: Variant) -> Dictionary:
	return {
		"key": key,
		"equals": value,
	}


static func _in(key: String, values: Array) -> Dictionary:
	return {
		"key": key,
		"in": values.duplicate(),
	}


static func _all(conditions: Array) -> Dictionary:
	return {"all": conditions.duplicate(true)}


static func _not(condition: Dictionary) -> Dictionary:
	return {"not": condition.duplicate(true)}


static func _condition_matches(condition, params: Dictionary) -> bool:
	if condition is bool:
		return bool(condition)
	if not condition is Dictionary:
		return true
	var condition_dict := condition as Dictionary
	if condition_dict.is_empty():
		return true
	if condition_dict.has("all"):
		for child in condition_dict.get("all", []) as Array:
			if not _condition_matches(child, params):
				return false
		return true
	if condition_dict.has("any"):
		for child in condition_dict.get("any", []) as Array:
			if _condition_matches(child, params):
				return true
		return false
	if condition_dict.has("not"):
		return not _condition_matches(condition_dict["not"], params)
	var key := String(condition_dict.get("key", ""))
	var actual = params.get(key, null)
	if condition_dict.has("equals"):
		return actual == condition_dict["equals"]
	if condition_dict.has("not_equals"):
		return actual != condition_dict["not_equals"]
	if condition_dict.has("in"):
		return (condition_dict.get("in", []) as Array).has(actual)
	return true


static func _effective_label(entry: Dictionary, params: Dictionary) -> String:
	var label_by_mode = entry.get("label_by_mode", {})
	if label_by_mode is Dictionary:
		for mode_key in (label_by_mode as Dictionary).keys():
			var labels = (label_by_mode as Dictionary)[mode_key]
			if not labels is Dictionary:
				continue
			var mode_value := String(params.get(String(mode_key), ""))
			if (labels as Dictionary).has(mode_value):
				return String((labels as Dictionary)[mode_value])
			if (labels as Dictionary).has("_default"):
				return String((labels as Dictionary)["_default"])
	return String(entry.get("label", ""))


static func _default_item_pool() -> Array:
	return [{
		"name": "item",
		"weight": 1.0,
		"limit": 1,
		"display_name": "Item",
	}]


static func _default_probability_rules() -> Dictionary:
	return {
		"default": 0.5,
		"rules": [],
	}


static func _default_custom_distribution() -> Dictionary:
	return {
		"0": [1.0],
		"1": [1.0, 1.0],
		"2": [1.0, 1.0, 1.0, 1.0],
		"3": [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
	}
