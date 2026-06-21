@tool
class_name HexGenerationNodeTypes
extends RefCounted

const HexGenerationPortsScript = preload("res://addons/hex_map_kit/generation/hex_generation_ports.gd")
const HexMapDataScript = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGeneratorScript = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexOverlayDataScript = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexMapResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexOverlayResourceScript = preload("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd")
const HexMapDocumentResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapDocumentTerrainLayerResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_terrain_layer_resource.gd")
const HexMapDocumentOverlayLayerResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_overlay_layer_resource.gd")
const HexGenerationResultResourceScript = preload("res://addons/hex_map_kit/adapter/hex_generation_result_resource.gd")
const HexAdjacencyRuleSetScript = preload("res://addons/hex_map_kit/adapter/hex_adjacency_rule_set.gd")

const NODE_SOURCE := "source"
const NODE_SHAPE := "shape"
const NODE_WALL_FIELD := "wall_field"
const NODE_CONNECTIVITY := "connectivity"
const NODE_REGION_FILTER := "region_filter"
const NODE_ITEM_GENERATOR := "item_generator"
const NODE_COMPOSE := "compose"
const NODE_SET_OPERATION := "set_operation"
const NODE_RESULT := "result"

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
		NODE_SET_OPERATION: {
			"inputs": {
				"a": {
					"accepts": [HexGenerationPortsScript.SELECTION],
					"required": true,
				},
				"b": {
					"accepts": [HexGenerationPortsScript.SELECTION],
					"required": false,
				},
			},
			"output": HexGenerationPortsScript.SELECTION,
			"run_method": "_run_set_operation",
		},
		NODE_RESULT: {
			"inputs": {
				"terrain": {
					"accepts": [HexGenerationPortsScript.TERRAIN],
					"required": false,
				},
				"overlay": {
					"accepts": [HexGenerationPortsScript.OVERLAY],
					"required": false,
				},
			},
			"output": HexGenerationPortsScript.RESULT,
			"run_method": "_run_result",
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
		NODE_SET_OPERATION:
			return _run_set_operation(inputs, params, context, resource_refs)
		NODE_RESULT:
			return _run_result(inputs, params, context, resource_refs)
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
	var mode = String(params.get("wall_method", params.get("mode", "random_probability")))
	match mode:
		"markov_mesh":
			var max_extent := 0
			for cell in data.cells:
				max_extent = max(max_extent, abs(int(cell.q)), abs(int(cell.r)))
			var radius := max(1, max_extent)
			var symmetric_result = HexMapGeneratorScript.generate_symmetric_toric_walls_interruptible(
				radius,
				clampf(float(params.get("wall_probability", 0.3)), 0.0, 1.0),
				_seed(params, context),
				int(params.get("distribution_id", 20)),
				_points_param(params, "protected_floor"),
				null,
				_interrupt_options(context)
			)
			var wall_set := {}
			for wall in symmetric_result["walls"]:
				wall_set[wall.key()] = true
			var filtered_walls: Array = []
			for cell in data.cells:
				if wall_set.has(cell.key()):
					filtered_walls.append(cell)
			data.set_walls(filtered_walls)
		"random_probability", _:
			var wall_result = HexMapGeneratorScript.generate_random_walls_interruptible(
				data.cells,
				clampf(float(params.get("wall_probability", 0.0)), 0.0, 1.0),
				_seed(params, context),
				_points_param(params, "protected_floor"),
				_interrupt_options(context)
			)
			data.set_walls(wall_result["walls"])
	return data


static func _run_connectivity(inputs: Dictionary, params: Dictionary, context: Dictionary, _resource_refs: Dictionary):
	var data = _clone_terrain(inputs.get("in", null))
	var terminals = inputs.get("terminals", _points_param(params, "terminals"))
	var method = String(params.get("method", params.get("mode", "dense")))
	var seed = _seed(params, context, 101)
	match method:
		"none":
			pass
		"sparse":
			HexMapGeneratorScript.restore_connectivity_by(HexMapGeneratorScript.CONNECT_SPARSE, data, terminals, seed, _interrupt_options(context))
		"terminal":
			HexMapGeneratorScript.restore_terminal_connectivity(data, terminals, seed)
		"dense", "default", _:
			HexMapGeneratorScript.restore_connectivity(data, seed, _interrupt_options(context))
	return data


static func _run_region_filter(inputs: Dictionary, params: Dictionary, _context: Dictionary, _resource_refs: Dictionary) -> Array:
	var source = inputs.get("in", null)
	if source == null:
		return []
	var filter_target = String(params.get("filter_target", params.get("mode", "floor")))
	var selection: Array = []
	if source is HexOverlayDataScript:
		if filter_target == "item_key":
			var item_key = String(params.get("item_key", ""))
			if item_key != "":
				selection = HexMapDataScript.unique_points(source.item_cells(item_key))
		else:
			selection = source.occupied_cells()
	elif source.has_method("item_cells"):
		if filter_target == "item_key":
			var item_key = String(params.get("item_key", ""))
			if item_key != "":
				selection = HexMapDataScript.unique_points(source.item_cells(item_key))
		else:
			var item_key = _terrain_item_key(filter_target)
			selection = HexMapDataScript.unique_points(source.item_cells(item_key))
	selection = _apply_shift(selection, params)
	return _filter_by_distance_params(selection, params)


static func _run_item_generator(inputs: Dictionary, params: Dictionary, context: Dictionary, _resource_refs: Dictionary):
	var cells = HexMapDataScript.unique_points(inputs.get("scope", []))
	var mode = String(params.get("placement_method", params.get("mode", "weighted")))
	var item_pool = params.get("item_pool", [])
	var blocked = _points_param(params, "blocked")
	match mode:
		"limited":
			return HexMapGeneratorScript.generate_limited_items_interruptible(
				cells,
				item_pool,
				_seed(params, context),
				blocked,
				_interrupt_options(context)
			)["data"]
		"adjacency_rules":
			var rules_text = String(params.get("probability_rules", "default=0.5"))
			var parse_result := HexAdjacencyRuleSetScript.parse_rules_text_report(rules_text)
			var rules = parse_result.get("rules", {}) as Dictionary
			var neighbor_radius := clampi(int(params.get("neighbor_radius", 1)), 1, 16)
			var include_ref := bool(params.get("include_generated_reference", false))
			var cyclic_size := _compute_cyclic_size(cells)
			return HexMapGeneratorScript.generate_toric_adjacency_items_interruptible(
				cells,
				String(params.get("item_name", "item")),
				cells,
				rules,
				_seed(params, context),
				blocked,
				cyclic_size,
				neighbor_radius,
				_interrupt_options(context),
				include_ref
			)["data"]
		_:
			return HexMapGeneratorScript.generate_random_items_interruptible(
				cells,
				clampf(float(params.get("placement_probability", 1.0)), 0.0, 1.0),
				item_pool,
				_seed(params, context),
				blocked,
				_interrupt_options(context)
			)["data"]


static func _run_compose(inputs: Dictionary, params: Dictionary, _context: Dictionary, _resource_refs: Dictionary):
	var base = _clone_overlay(inputs.get("base", null))
	var add = _clone_overlay(inputs.get("add", null))
	base.apply_overlay(
		add,
		String(params.get("write_policy", HexOverlayDataScript.APPLY_ADD_ITEM)),
		String(params.get("existing_policy", HexOverlayDataScript.EXISTING_MERGE))
	)
	return base


static func _run_set_operation(inputs: Dictionary, params: Dictionary, _context: Dictionary, _resource_refs: Dictionary) -> Array:
	var a: Array = inputs.get("a", [])
	var b: Array = inputs.get("b", [])
	var operation = String(params.get("operation", "union"))
	match operation:
		"intersection":
			if b.is_empty():
				return a.duplicate()
			return _intersect_selections(a, b)
		"difference":
			if b.is_empty():
				return a.duplicate()
			return _difference_selections(a, b)
		"union", _:
			if b.is_empty():
				return a.duplicate()
			return HexMapDataScript.unique_points(a + b)


static func _intersect_selections(a: Array, b: Array) -> Array:
	var b_set := HexMapDataScript.make_set(b)
	var result: Array = []
	for point in a:
		if b_set.has(point.key()):
			result.append(point)
	return result


static func _difference_selections(a: Array, b: Array) -> Array:
	return HexMapDataScript.points_except(a, b)


static func _run_result(inputs: Dictionary, params: Dictionary, _context: Dictionary, _resource_refs: Dictionary):
	var result = HexGenerationResultResourceScript.new()
	result.status = "generated"
	var orientation_val := int(params.get("orientation", 0))
	var terrain_input = inputs.get("terrain", null)
	if terrain_input is HexMapDataScript:
		result.primary_map = HexMapResourceScript.from_map_data(terrain_input as HexMapDataScript, orientation_val)
	var overlay_input = inputs.get("overlay", null)
	if overlay_input is HexOverlayDataScript:
		result.overlay_map = HexOverlayResourceScript.from_overlay_data(overlay_input as HexOverlayDataScript, orientation_val)
	return result


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


static func _interrupt_options(context: Dictionary) -> Dictionary:
	var options = context.get("interrupt_options", {})
	return options if options is Dictionary else {}


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


static func _compute_cyclic_size(cells: Array) -> int:
	var max_extent := 0
	for cell in cells:
		max_extent = max(max_extent, abs(int(cell.q)), abs(int(cell.r)), abs(int(cell.s)))
	return max_extent * 2 + 1


static func _apply_shift(points: Array, params: Dictionary) -> Array:
	var sq := int(params.get("shift_q", 0))
	var sr := int(params.get("shift_r", 0))
	var ss := int(params.get("shift_s", 0))
	if sq == 0 and sr == 0 and ss == 0:
		return points
	var shift_vec := HexVectorScript.new()
	shift_vec.q = sq
	shift_vec.r = sr
	shift_vec.s = ss
	var result: Array = []
	for point in points:
		result.append(point.add(shift_vec))
	return HexMapDataScript.unique_points(result)
