@tool
class_name HexGenerationNodeTypes
extends RefCounted

const HexGenerationPortsScript = preload("res://addons/hex_map_kit/generation/hex_generation_ports.gd")
const HexMapDataScript = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGeneratorScript = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexOverlayDataScript = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexMapResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexOverlayResourceScript = preload("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd")
const HexMapDocumentResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapDocumentTerrainLayerResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_terrain_layer_resource.gd")
const HexMapDocumentOverlayLayerResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_overlay_layer_resource.gd")
const HexGenerationResultResourceScript = preload("res://addons/hex_map_kit/adapter/hex_generation_result_resource.gd")

const NODE_SOURCE := "source"
const NODE_SHAPE := "shape"
const NODE_WALL_FIELD := "wall_field"
const NODE_CONNECTIVITY := "connectivity"
const NODE_REGION_FILTER := "region_filter"
const NODE_ITEM_GENERATOR := "item_generator"
const NODE_COMPOSE := "compose"

const PORT_OUT := "out"


static func registry() -> Dictionary:
	return {
		NODE_SOURCE: {
			"inputs": {},
			"output": "",
			"run_method": "_run_source",
		},
		NODE_SHAPE: {
			"inputs": {},
			"output": HexGenerationPortsScript.TERRAIN,
			"run_method": "_run_shape",
		},
		NODE_WALL_FIELD: {
			"inputs": {
				"in": {
					"accepts": [HexGenerationPortsScript.TERRAIN],
					"required": true,
				},
			},
			"output": HexGenerationPortsScript.TERRAIN,
			"run_method": "_run_wall_field",
		},
		NODE_CONNECTIVITY: {
			"inputs": {
				"in": {
					"accepts": [HexGenerationPortsScript.TERRAIN],
					"required": true,
				},
				"terminals": {
					"accepts": [HexGenerationPortsScript.SELECTION],
					"required": false,
				},
			},
			"output": HexGenerationPortsScript.TERRAIN,
			"run_method": "_run_connectivity",
		},
		NODE_REGION_FILTER: {
			"inputs": {
				"in": {
					"accepts": [HexGenerationPortsScript.TERRAIN, HexGenerationPortsScript.OVERLAY],
					"required": true,
				},
			},
			"output": HexGenerationPortsScript.SELECTION,
			"run_method": "_run_region_filter",
		},
		NODE_ITEM_GENERATOR: {
			"inputs": {
				"scope": {
					"accepts": [HexGenerationPortsScript.SELECTION],
					"required": true,
				},
			},
			"output": HexGenerationPortsScript.OVERLAY,
			"run_method": "_run_item_generator",
		},
		NODE_COMPOSE: {
			"inputs": {
				"base": {
					"accepts": [HexGenerationPortsScript.OVERLAY],
					"required": true,
				},
				"add": {
					"accepts": [HexGenerationPortsScript.OVERLAY],
					"required": true,
				},
			},
			"output": HexGenerationPortsScript.OVERLAY,
			"run_method": "_run_compose",
		},
	}


static func has_type(node_type: String) -> bool:
	return registry().has(node_type)


static func input_definitions(node_type: String) -> Dictionary:
	return registry().get(node_type, {}).get("inputs", {})


static func input_definition(node_type: String, port_name: String) -> Dictionary:
	return input_definitions(node_type).get(port_name, {})


static func output_type_for_node(node: Dictionary) -> String:
	var node_type = String(node.get("type", ""))
	if node_type == NODE_SOURCE:
		return _source_output_type(node.get("params", {}))
	return String(registry().get(node_type, {}).get("output", ""))


static func run_node(node: Dictionary, inputs: Dictionary, context: Dictionary):
	var node_type = String(node.get("type", ""))
	var params = node.get("params", {})
	var resource_refs = node.get("resource_refs", {})
	match node_type:
		NODE_SOURCE:
			return _run_source(inputs, params, context, resource_refs)
		NODE_SHAPE:
			return _run_shape(inputs, params, context, resource_refs)
		NODE_WALL_FIELD:
			return _run_wall_field(inputs, params, context, resource_refs)
		NODE_CONNECTIVITY:
			return _run_connectivity(inputs, params, context, resource_refs)
		NODE_REGION_FILTER:
			return _run_region_filter(inputs, params, context, resource_refs)
		NODE_ITEM_GENERATOR:
			return _run_item_generator(inputs, params, context, resource_refs)
		NODE_COMPOSE:
			return _run_compose(inputs, params, context, resource_refs)
		_:
			return null


static func _run_source(_inputs: Dictionary, params: Dictionary, context: Dictionary, resource_refs: Dictionary):
	var kind = String(params.get("kind", "provided"))
	match kind:
		"provided":
			var data = params.get("data", params.get("value", null))
			if data == null and params.has("source_key"):
				data = context.get(String(params["source_key"]), null)
			return _coerce_source_value(data, _source_output_type(params))
		"context":
			return _coerce_source_value(context.get(String(params.get("source_key", "")), null), _source_output_type(params))
		"map_resource":
			return _coerce_terrain(resource_refs.get("map", params.get("resource", null)))
		"overlay_resource":
			return _coerce_overlay(resource_refs.get("overlay", params.get("resource", null)))
		"document_terrain":
			return _document_terrain(resource_refs.get("document", context.get("document", null)), params)
		"document_overlay":
			return _document_overlay(resource_refs.get("document", context.get("document", null)), params)
		"result_terrain":
			var terrain_result = resource_refs.get("result", context.get("result", null))
			return _coerce_terrain(terrain_result.primary_map if terrain_result is HexGenerationResultResourceScript else null)
		"result_overlay":
			var overlay_result = resource_refs.get("result", context.get("result", null))
			return _coerce_overlay(overlay_result.overlay_map if overlay_result is HexGenerationResultResourceScript else null)
		_:
			return _coerce_source_value(params.get("data", null), _source_output_type(params))


static func _run_shape(_inputs: Dictionary, params: Dictionary, _context: Dictionary, _resource_refs: Dictionary):
	var shape = String(params.get("shape", "rectangle"))
	match shape:
		"square":
			return HexMapDataScript.square(max(1, int(params.get("size", 1))), bool(params.get("toric", false)))
		"hexagon":
			return HexMapDataScript.hexagon(max(0, int(params.get("radius", 1))))
		"rectangle", _:
			return HexMapDataScript.rectangle(
				max(1, int(params.get("width", 1))),
				max(1, int(params.get("height", 1))),
				bool(params.get("toric", false))
			)


static func _run_wall_field(inputs: Dictionary, params: Dictionary, context: Dictionary, _resource_refs: Dictionary):
	var data = _clone_terrain(inputs.get("in", null))
	var walls = HexMapGeneratorScript.generate_random_walls(
		data.cells,
		clampf(float(params.get("wall_probability", 0.0)), 0.0, 1.0),
		_seed(params, context),
		_points_param(params, "protected_floor")
	)
	data.set_walls(walls)
	return data


static func _run_connectivity(inputs: Dictionary, params: Dictionary, context: Dictionary, _resource_refs: Dictionary):
	var data = _clone_terrain(inputs.get("in", null))
	var terminals = inputs.get("terminals", _points_param(params, "terminals"))
	var method = String(params.get("method", "dense"))
	var seed = _seed(params, context, 101)
	match method:
		"none":
			pass
		"sparse":
			HexMapGeneratorScript.restore_connectivity_by(HexMapGeneratorScript.CONNECT_SPARSE, data, terminals, seed)
		"terminal":
			HexMapGeneratorScript.restore_terminal_connectivity(data, terminals, seed)
		"dense", "default", _:
			HexMapGeneratorScript.restore_connectivity(data, seed)
	return data


static func _run_region_filter(inputs: Dictionary, params: Dictionary, _context: Dictionary, _resource_refs: Dictionary) -> Array:
	var source = inputs.get("in", null)
	var mode = String(params.get("mode", "floor"))
	var selection: Array = []
	if source != null and source.has_method("item_cells") and mode != "query":
		var item_key = String(params.get("item_key", _terrain_item_key(mode)))
		selection = HexMapDataScript.unique_points(source.item_cells(item_key))
		return _filter_by_distance_params(selection, params)
	if mode == "query":
		var operation = String(params.get("op", params.get("operation", HexOverlayDataScript.ITEM_QUERY_OR)))
		selection = HexOverlayDataScript.query_item_cells(_selectors_for_source(params.get("selectors", []), source), operation)
		return _filter_by_distance_params(selection, params)
	if source is HexOverlayDataScript:
		var overlay_key = String(params.get("item_key", ""))
		selection = source.item_cells(overlay_key) if overlay_key != "" else source.occupied_cells()
		return _filter_by_distance_params(selection, params)
	return []


static func _run_item_generator(inputs: Dictionary, params: Dictionary, context: Dictionary, _resource_refs: Dictionary):
	var cells = HexMapDataScript.unique_points(inputs.get("scope", []))
	var mode = String(params.get("mode", "weighted"))
	var item_pool = params.get("item_pool", [])
	var blocked = _points_param(params, "blocked")
	if mode == "limited":
		return HexMapGeneratorScript.generate_limited_items(cells, item_pool, _seed(params, context), blocked)
	return HexMapGeneratorScript.generate_random_items(
		cells,
		clampf(float(params.get("placement_probability", 1.0)), 0.0, 1.0),
		item_pool,
		_seed(params, context),
		blocked
	)


static func _run_compose(inputs: Dictionary, params: Dictionary, _context: Dictionary, _resource_refs: Dictionary):
	var base = _clone_overlay(inputs.get("base", null))
	var add = _clone_overlay(inputs.get("add", null))
	base.apply_overlay(
		add,
		String(params.get("write_policy", HexOverlayDataScript.APPLY_ADD_ITEM)),
		String(params.get("existing_policy", HexOverlayDataScript.EXISTING_MERGE))
	)
	return base


static func _source_output_type(params: Dictionary) -> String:
	if params.has("output_type"):
		return String(params["output_type"])
	var kind = String(params.get("kind", "provided"))
	match kind:
		"overlay_resource", "document_overlay", "result_overlay":
			return HexGenerationPortsScript.OVERLAY
		"map_resource", "document_terrain", "result_terrain":
			return HexGenerationPortsScript.TERRAIN
		_:
			return HexGenerationPortsScript.TERRAIN


static func _coerce_source_value(value, output_type: String):
	if output_type == HexGenerationPortsScript.OVERLAY:
		return _coerce_overlay(value)
	return _coerce_terrain(value)


static func _coerce_terrain(value):
	if value == null:
		return HexMapDataScript.from_cells([])
	if value is HexMapDataScript:
		return _clone_terrain(value)
	if value is HexMapResourceScript:
		return value.to_map_data()
	if value is Object and value.has_method("to_map_data"):
		return value.to_map_data()
	return HexMapDataScript.from_cells([])


static func _coerce_overlay(value):
	if value == null:
		return HexOverlayDataScript.from_cells([])
	if value is HexOverlayDataScript:
		return _clone_overlay(value)
	if value is HexOverlayResourceScript:
		return value.to_overlay_data()
	if value is Object and value.has_method("to_overlay_data"):
		return value.to_overlay_data()
	return HexOverlayDataScript.from_cells([])


static func _document_terrain(document, params: Dictionary):
	if not (document is HexMapDocumentResourceScript):
		return HexMapDataScript.from_cells([])
	var layer = _select_layer(document.terrain_layers, params)
	if layer is HexMapDocumentTerrainLayerResourceScript and layer.map != null:
		return layer.map.to_map_data()
	return HexMapDataScript.from_cells([])


static func _document_overlay(document, params: Dictionary):
	if not (document is HexMapDocumentResourceScript):
		return HexOverlayDataScript.from_cells([])
	var layer = _select_layer(document.overlay_layers, params)
	if layer is HexMapDocumentOverlayLayerResourceScript and layer.overlay != null:
		return layer.overlay.to_overlay_data()
	return HexOverlayDataScript.from_cells([])


static func _select_layer(layers: Array, params: Dictionary):
	var layer_id = String(params.get("layer_id", ""))
	if layer_id != "":
		for layer in layers:
			if layer != null and String(layer.get("layer_id")) == layer_id:
				return layer
	var index = int(params.get("layer_index", 0))
	if index >= 0 and index < layers.size():
		return layers[index]
	return null


static func _clone_terrain(data):
	if data is HexMapDataScript:
		return HexMapDataScript.from_cells(data.cells, data.walls, data.cyclic_size)
	return HexMapDataScript.from_cells([])


static func _clone_overlay(data):
	if data is HexOverlayDataScript:
		return data.duplicate_data()
	return HexOverlayDataScript.from_cells([])


static func _selectors_for_source(selectors, source) -> Array:
	var result: Array = []
	if not selectors is Array:
		return result
	for selector in selectors:
		if not selector is Dictionary:
			continue
		var copy = selector.duplicate(true)
		if not copy.has("source") or copy["source"] == "input":
			copy["source"] = source
		result.append(copy)
	return result


static func _terrain_item_key(mode: String) -> String:
	match mode:
		"wall":
			return HexMapDataScript.ITEM_WALL
		"any":
			return HexMapDataScript.ITEM_ANY
		"floor", _:
			return HexMapDataScript.ITEM_FLOOR


static func _seed(params: Dictionary, context: Dictionary, salt: int = 0) -> int:
	return int(context.get("seed", 0)) + int(params.get("seed", 0)) + salt


static func _points_param(params: Dictionary, key: String) -> Array:
	var value = params.get(key, [])
	return value.duplicate() if value is Array else []


static func _filter_by_distance_params(points: Array, params: Dictionary) -> Array:
	if not params.has("within_distance_of") and not params.has("origin_points"):
		return points
	var origins := _points_param(params, "within_distance_of")
	if origins.is_empty():
		origins = _points_param(params, "origin_points")
	if origins.is_empty():
		return []
	var max_distance := int(params.get("max_distance", params.get("distance", 0)))
	var result: Array = []
	for point in points:
		for origin in origins:
			if point.subtract(origin).l1_norm() <= max_distance:
				result.append(point)
				break
	return HexMapDataScript.unique_points(result)
