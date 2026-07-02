@tool
class_name HexGenerationNodeTypes
extends RefCounted

const HexGenerationPortsScript = preload("res://addons/hex_map_kit/generation/hex_generation_ports.gd")
const HexGenerationAdaptationScript = preload("res://addons/hex_map_kit/generation/hex_generation_adaptation.gd")
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
const HexItemPoolResourceScript = preload("res://addons/hex_map_kit/adapter/hex_item_pool_resource.gd")
const HexWallDistributionResourceScript = preload("res://addons/hex_map_kit/adapter/hex_wall_distribution_resource.gd")

const NODE_TERRAIN_GENERATION := "terrain_generation"
const NODE_ITEM_GENERATION := "item_generation"
const NODE_SOURCE := "source"
const NODE_SHAPE := "shape"
const NODE_WALL_FIELD := "wall_field"
const NODE_CONNECTIVITY := "connectivity"
const NODE_REGION_FILTER := "region_filter"
const NODE_TERRAIN_FILTER := "terrain_filter"
const NODE_OVERLAY_FILTER := "overlay_filter"
const NODE_ITEM_GENERATOR := "item_generator"
const NODE_COMPOSE := "compose"
const NODE_SET_OPERATION := "set_operation"
const NODE_RESULT := "result"

const PORT_OUT := "out"
const RESULT_TERRAIN_PORT := "terrain"
const RESULT_OVERLAY_PORT_PREFIX := "overlay_"
const RESULT_OVERLAY_PORT_COUNT := 3
const DEFAULT_RECTANGLE_WIDTH := 6
const DEFAULT_RECTANGLE_HEIGHT := 4
const DEFAULT_SQUARE_SIZE := 3
const DEFAULT_HEXAGON_RADIUS := 2


static func result_overlay_port_names() -> Array:
	var result: Array = []
	for index in range(RESULT_OVERLAY_PORT_COUNT):
		result.append("%s%d" % [RESULT_OVERLAY_PORT_PREFIX, index])
	return result


static func is_result_overlay_port(port_name: String) -> bool:
	return result_overlay_port_names().has(port_name)


static func registry() -> Dictionary:
	var result_inputs := {}
	return {
		NODE_TERRAIN_GENERATION: {
			"inputs": {
				"terminals": {
					"accepts": HexGenerationPortsScript.ALL,
					"required": false,
					"untyped": true,
				},
			},
			"output": HexGenerationPortsScript.TERRAIN,
			"run_method": "_run_terrain_generation",
			"title": "Terrain Generation",
		},
		NODE_ITEM_GENERATION: {
			"inputs": {
				"domain": {
					"accepts": HexGenerationPortsScript.ALL,
					"required": false,
					"untyped": true,
				},
			},
			"output": HexGenerationPortsScript.OVERLAY,
			"run_method": "_run_item_generation",
			"title": "Item Generation",
		},
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
		NODE_TERRAIN_FILTER: {
			"inputs": {
				"in": {
					"accepts": [HexGenerationPortsScript.TERRAIN],
					"required": true,
				},
			},
			"output": HexGenerationPortsScript.SELECTION,
			"run_method": "_run_region_filter",
		},
		NODE_OVERLAY_FILTER: {
			"inputs": {
				"in": {
					"accepts": [HexGenerationPortsScript.OVERLAY],
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
			"inputs": {},
			"output": HexGenerationPortsScript.SELECTION,
			"run_method": "_run_set_operation",
			"title": "Set Operation",
		},
		NODE_RESULT: {
			"inputs": result_inputs,
			"output": HexGenerationPortsScript.RESULT,
			"run_method": "_run_result",
			"title": "Result",
		},
	}


static func has_type(node_type: String) -> bool:
	return registry().has(node_type)


static func input_definitions(node_type: String) -> Dictionary:
	return registry().get(node_type, {}).get("inputs", {})


static func input_definition(node_type: String, port_name: String) -> Dictionary:
	var definitions := input_definitions(node_type)
	if definitions.has(port_name):
		return definitions[port_name]
	if is_variadic_input_port(node_type, port_name):
		return {
			"accepts": HexGenerationPortsScript.ALL,
			"required": false,
			"untyped": true,
			"variadic": true,
		}
	return {}


static func is_consolidated_type(node_type: String) -> bool:
	return [
		NODE_TERRAIN_GENERATION,
		NODE_ITEM_GENERATION,
		NODE_SET_OPERATION,
		NODE_RESULT,
	].has(node_type)


static func is_variadic_input_port(node_type: String, port_name: String) -> bool:
	match node_type:
		NODE_SET_OPERATION:
			return port_name.begins_with("in_") or port_name == "a" or port_name == "b"
		NODE_RESULT:
			return port_name.begins_with("in_") \
				or port_name == RESULT_TERRAIN_PORT \
				or is_result_overlay_port(port_name)
		_:
			return false


static func output_type_for_node(node: Dictionary) -> String:
	var node_type = String(node.get("type", ""))
	if node_type == NODE_SOURCE:
		return _source_output_type(node.get("params", {}))
	return String(registry().get(node_type, {}).get("output", ""))


static func run_node(node: Dictionary, inputs: Dictionary, context: Dictionary):
	var node_type = String(node.get("type", ""))
	var params = _resolved_asset_reference_params(node_type, node.get("params", {}), context)
	var resource_refs = node.get("resource_refs", {})
	match node_type:
		NODE_TERRAIN_GENERATION:
			return _run_terrain_generation(inputs, params, context, resource_refs)
		NODE_ITEM_GENERATION:
			return _run_item_generation(inputs, params, context, resource_refs)
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
		NODE_TERRAIN_FILTER:
			return _run_region_filter(inputs, params, context, resource_refs)
		NODE_OVERLAY_FILTER:
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


static func _run_terrain_generation(inputs: Dictionary, params: Dictionary, context: Dictionary, resource_refs: Dictionary):
	var terrain
	var base_mode := String(params.get("base_mode", "shape"))
	match base_mode:
		"document_terrain", "map_resource", "result_terrain":
			terrain = _run_source({}, _source_params_for_base_mode(base_mode, params), context, resource_refs)
		"shape", _:
			terrain = _run_shape({}, params, context, resource_refs)

	var wall_method := String(params.get("wall_method", "none"))
	if wall_method != "none":
		var wall_params := params.duplicate(true)
		wall_params["wall_method"] = wall_method
		if params.has("wall_seed"):
			wall_params["seed"] = int(params.get("wall_seed", 0))
		terrain = _run_wall_field({"in": terrain}, wall_params, context, resource_refs)

	var connectivity_method := String(params.get("connectivity_method", params.get("method", "none")))
	if connectivity_method != "none" or bool(params.get("toric_passage", false)):
		var connectivity_params := params.duplicate(true)
		connectivity_params["method"] = connectivity_method
		if params.has("connectivity_seed"):
			connectivity_params["seed"] = int(params.get("connectivity_seed", 0))
		var connectivity_inputs := {"in": terrain}
		if inputs.has("terminals"):
			connectivity_inputs["terminals"] = inputs["terminals"]
		terrain = _run_connectivity(connectivity_inputs, connectivity_params, context, resource_refs)
	return terrain


static func _run_item_generation(inputs: Dictionary, params: Dictionary, context: Dictionary, resource_refs: Dictionary):
	var domain: Array = []
	if inputs.has("domain"):
		domain = HexMapDataScript.unique_points(inputs.get("domain", []))
	elif String(params.get("source_mode", "none")) == "document_overlay":
		var overlay = _run_source({}, _source_params_for_base_mode("document_overlay", params), context, resource_refs)
		domain = HexGenerationAdaptationScript.adapt_to_selection(
			overlay,
			String(params.get("source_adaptation", params.get("adaptation", "")))
		)
	else:
		domain = _default_item_domain_from_result_substrate(context)
	return _run_item_generator({"scope": domain}, params, context, resource_refs)


static func _source_params_for_base_mode(mode: String, params: Dictionary) -> Dictionary:
	var result := params.duplicate(true)
	match mode:
		"document_overlay":
			result["kind"] = "document_overlay"
		"document_terrain":
			result["kind"] = "document_terrain"
		"map_resource":
			result["kind"] = "map_resource"
		"result_terrain":
			result["kind"] = "result_terrain"
		_:
			result["kind"] = String(params.get("kind", "provided"))
	return result


static func _default_item_domain_from_result_substrate(context: Dictionary) -> Array:
	var graph = context.get("__graph", null)
	var cache = context.get("__cache", null)
	if not graph is Dictionary or not cache is Dictionary:
		return []
	var node_id := String(context.get("__node_id", ""))
	var result_ids := _result_ids_for_item_generation(graph as Dictionary, node_id)
	if result_ids.is_empty():
		result_ids = _result_node_ids(graph as Dictionary)
	for result_id in result_ids:
		var substrate_node_id := _result_substrate_terrain_generation_node_id(graph as Dictionary, String(result_id))
		if substrate_node_id == "":
			continue
		if not (cache as Dictionary).has(substrate_node_id):
			continue
		return HexGenerationAdaptationScript.adapt_to_selection((cache as Dictionary)[substrate_node_id], HexGenerationAdaptationScript.ADAPT_FLOOR)
	return []


static func _result_ids_for_item_generation(graph: Dictionary, item_node_id: String) -> Array:
	var result: Array = []
	for edge in graph.get("edges", []) as Array:
		if String((edge as Dictionary).get("from_node", "")) != item_node_id:
			continue
		var to_node := String((edge as Dictionary).get("to_node", ""))
		var node = (graph.get("nodes", {}) as Dictionary).get(to_node, {}) as Dictionary
		if String(node.get("type", "")) == NODE_RESULT and not result.has(to_node):
			result.append(to_node)
	return result


static func _result_node_ids(graph: Dictionary) -> Array:
	var result: Array = []
	var nodes = graph.get("nodes", {}) as Dictionary
	for node_id in nodes.keys():
		var node = nodes[node_id] as Dictionary
		if String(node.get("type", "")) == NODE_RESULT:
			result.append(String(node_id))
	result.sort()
	return result


static func _result_substrate_terrain_generation_node_id(graph: Dictionary, result_node_id: String) -> String:
	var nodes = graph.get("nodes", {}) as Dictionary
	for edge in graph.get("edges", []) as Array:
		var edge_dict := edge as Dictionary
		if String(edge_dict.get("to_node", "")) != result_node_id:
			continue
		var from_node_id := String(edge_dict.get("from_node", ""))
		var from_node = nodes.get(from_node_id, {}) as Dictionary
		if String(from_node.get("type", "")) == NODE_TERRAIN_GENERATION:
			return from_node_id
	return ""


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
			return HexMapDataScript.square(max(1, int(params.get("size", DEFAULT_SQUARE_SIZE))))
		"hexagon":
			return HexMapDataScript.hexagon(max(0, int(params.get("radius", DEFAULT_HEXAGON_RADIUS))))
		"rectangle", _:
			return HexMapDataScript.rectangle(
				max(1, int(params.get("width", DEFAULT_RECTANGLE_WIDTH))),
				max(1, int(params.get("height", DEFAULT_RECTANGLE_HEIGHT)))
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
			var custom_distribution = _custom_wall_distribution(params)
			var symmetric_result = HexMapGeneratorScript.generate_symmetric_toric_walls_interruptible(
				radius,
				clampf(float(params.get("wall_probability", 0.3)), 0.0, 1.0),
				_seed(params, context),
				int(params.get("distribution_id", 20)),
				_points_param(params, "protected_floor"),
				custom_distribution,
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
	if bool(params.get("toric_passage", false)):
		var toric_size := _toric_passage_cyclic_size(data.cells)
		if toric_size > 0:
			data.cyclic_size = toric_size
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
			var rules = _probability_rules_param(params.get("probability_rules", "default=0.5"))
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
	var selections := _ordered_set_operation_inputs(inputs)
	if selections.is_empty():
		return []
	var first: Array = selections[0]
	var operation = String(params.get("operation", "union"))
	match operation:
		"intersection":
			var intersection := first.duplicate()
			for index in range(1, selections.size()):
				intersection = _intersect_selections(intersection, selections[index])
			return intersection
		"difference":
			var difference := first.duplicate()
			for index in range(1, selections.size()):
				difference = _difference_selections(difference, selections[index])
			return difference
		"union", _:
			var union := first.duplicate()
			for index in range(1, selections.size()):
				union.append_array(selections[index])
			return HexMapDataScript.unique_points(union)


static func _ordered_set_operation_inputs(inputs: Dictionary) -> Array:
	var indexed: Array = []
	for port_name in inputs.keys():
		var port := String(port_name)
		if port.begins_with("in_"):
			indexed.append({
				"index": int(port.substr(3)),
				"selection": _selection_from_input(inputs[port_name]),
			})
	indexed.sort_custom(func(a, b): return int((a as Dictionary)["index"]) < int((b as Dictionary)["index"]))
	var result: Array = []
	for entry in indexed:
		result.append((entry as Dictionary)["selection"])
	if result.is_empty() and inputs.has("a"):
		result.append(_selection_from_input(inputs.get("a", [])))
		if inputs.has("b"):
			result.append(_selection_from_input(inputs.get("b", [])))
	return result


static func _selection_from_input(value) -> Array:
	if value is Array:
		return HexMapDataScript.unique_points(value as Array)
	return []


static func _intersect_selections(a: Array, b: Array) -> Array:
	var b_set := HexMapDataScript.make_set(b)
	var result: Array = []
	for point in a:
		if b_set.has(point.key()):
			result.append(point)
	return result


static func _difference_selections(a: Array, b: Array) -> Array:
	return HexMapDataScript.points_except(a, b)


static func _run_result(inputs: Dictionary, params: Dictionary, context: Dictionary, _resource_refs: Dictionary):
	var result = HexGenerationResultResourceScript.new()
	result.status = "generated"
	var orientation_val := int(context.get("orientation", params.get("orientation", 0)))
	result.overlay_maps.clear()
	var overlay_inputs: Array = []
	var overlay_sources: Array = []
	var terrain_inputs: Array = []
	var unused_inputs: Array = []
	var substrate_set := false
	var stacked_overlay = null
	var ordered_inputs := _ordered_result_inputs(inputs, context)
	for input_entry in ordered_inputs:
		var port_name := String((input_entry as Dictionary).get("port", ""))
		var from_node := String((input_entry as Dictionary).get("from_node", ""))
		var value = (input_entry as Dictionary).get("value", null)
		if value is HexMapDataScript:
			var terrain_data := value as HexMapDataScript
			if not substrate_set:
				result.primary_map = HexMapResourceScript.from_map_data(terrain_data, orientation_val)
				substrate_set = true
				terrain_inputs.append({
					"port": port_name,
					"from_node": from_node,
					"role": "substrate",
					"cell_count": terrain_data.cells.size(),
					"wall_count": terrain_data.walls.size(),
				})
			else:
				unused_inputs.append(_unused_result_input(port_name, from_node, "terrain", "extra_terrain"))
				terrain_inputs.append({
					"port": port_name,
					"from_node": from_node,
					"role": "unused",
					"cell_count": terrain_data.cells.size(),
					"wall_count": terrain_data.walls.size(),
				})
		elif value is HexOverlayDataScript:
			var overlay_data := value as HexOverlayDataScript
			var write_policy := _result_write_policy_for_port(
				params,
				port_name,
				String((input_entry as Dictionary).get("write_policy", ""))
			)
			var overlay_index: int = result.overlay_maps.size()
			result.overlay_maps.append(HexOverlayResourceScript.from_overlay_data(overlay_data, orientation_val))
			if stacked_overlay == null:
				stacked_overlay = overlay_data.duplicate_data()
			else:
				_apply_result_overlay_policy(stacked_overlay, overlay_data, write_policy)
			overlay_sources.append({
				"port": port_name,
				"from_node": from_node,
				"data": overlay_data,
				"write_policy": write_policy,
			})
			overlay_inputs.append({
				"port": port_name,
				"from_node": from_node,
				"overlay_index": overlay_index,
				"present": true,
				"write_policy": write_policy,
				"item_count": _overlay_data_item_count(overlay_data),
			})
		else:
			unused_inputs.append(_unused_result_input(port_name, from_node, HexGenerationAdaptationScript.producer_kind(value), "not_result_material"))
	result.overlay_map = result.overlay_maps[0] if result.overlay_maps.size() > 0 else null
	result.metadata = {
		"terrain_present": result.primary_map != null,
		"terrain_inputs": terrain_inputs,
		"overlay_inputs": overlay_inputs,
		"overlay_count": result.overlay_maps.size(),
		"overlay_stack_item_count": _overlay_data_item_count(stacked_overlay) if stacked_overlay != null else 0,
		"overlay_stack_cells": _overlay_stack_cells(stacked_overlay) if stacked_overlay != null else [],
		"unused_inputs": unused_inputs,
		"overlay_conflicts": _overlay_conflicts(overlay_sources),
	}
	return result


static func _ordered_result_inputs(inputs: Dictionary, context: Dictionary) -> Array:
	var graph = context.get("__graph", null)
	var node_id := String(context.get("__node_id", ""))
	var result: Array = []
	if graph is Dictionary and node_id != "":
		for edge in (graph as Dictionary).get("edges", []) as Array:
			var edge_dict := edge as Dictionary
			if String(edge_dict.get("to_node", "")) != node_id:
				continue
			var port_name := String(edge_dict.get("to_port", ""))
			if not inputs.has(port_name):
				continue
			result.append({
				"port": port_name,
				"from_node": String(edge_dict.get("from_node", "")),
				"write_policy": String(edge_dict.get("write_policy", "")),
				"value": inputs[port_name],
			})
		return result
	var ports := inputs.keys()
	ports.sort()
	for port_name in ports:
		result.append({
			"port": String(port_name),
			"from_node": "",
			"write_policy": "",
			"value": inputs[port_name],
		})
	return result


static func _result_write_policy_for_port(params: Dictionary, port_name: String, edge_policy: String = "") -> String:
	var normalized_edge := _normalize_result_write_policy(edge_policy)
	if edge_policy.strip_edges() != "":
		return normalized_edge
	var policies = params.get("result_write_policies", {})
	if policies is Dictionary:
		return _normalize_result_write_policy(String((policies as Dictionary).get(port_name, HexOverlayDataScript.APPLY_ADD_ITEM)))
	return HexOverlayDataScript.APPLY_ADD_ITEM


static func _normalize_result_write_policy(write_policy: String) -> String:
	match write_policy.strip_edges():
		"replace_item":
			return "replace_item"
		"add_replace":
			return "add_replace"
		_:
			return HexOverlayDataScript.APPLY_ADD_ITEM


static func _apply_result_overlay_policy(base: HexOverlayDataScript, incoming: HexOverlayDataScript, write_policy: String) -> void:
	match _normalize_result_write_policy(write_policy):
		"replace_item":
			base.apply_overlay(incoming, HexOverlayDataScript.APPLY_ADD_ITEM, HexOverlayDataScript.EXISTING_REPLACE)
		"add_replace":
			base.apply_overlay(incoming, HexOverlayDataScript.APPLY_ADD_ITEM, HexOverlayDataScript.EXISTING_SKIP)
		_:
			base.apply_overlay(incoming, HexOverlayDataScript.APPLY_ADD_ITEM, HexOverlayDataScript.EXISTING_MERGE)


static func _unused_result_input(port_name: String, from_node: String, producer_kind: String, reason: String) -> Dictionary:
	return {
		"port": port_name,
		"from_node": from_node,
		"producer_kind": producer_kind,
		"reason": reason,
	}


static func _overlay_data_item_count(data: HexOverlayDataScript) -> int:
	var count := 0
	for item_key in data.item_keys():
		count += data.item_cells(String(item_key)).size()
	return count


static func _overlay_stack_cells(data: HexOverlayDataScript) -> Array:
	var by_cell := {}
	for item_key in data.item_keys():
		var item_text := String(item_key)
		for cell in data.item_cells(item_text):
			var cell_key := String(cell.key())
			if not by_cell.has(cell_key):
				by_cell[cell_key] = {
					"cell_key": cell_key,
					"items": [],
				}
			var entry = by_cell[cell_key] as Dictionary
			var items = entry.get("items", []) as Array
			if not items.has(item_text):
				items.append(item_text)
			items.sort()
			entry["items"] = items
	var result: Array = []
	var keys := by_cell.keys()
	keys.sort()
	for key in keys:
		result.append((by_cell[key] as Dictionary).duplicate(true))
	return result


static func _overlay_conflicts(overlay_sources: Array) -> Array:
	var by_item_cell := {}
	for source in overlay_sources:
		var entry = source as Dictionary
		var port := String(entry.get("port", ""))
		var data = entry.get("data", null)
		if not data is HexOverlayDataScript:
			continue
		for item_key in data.item_keys():
			var item_text := String(item_key)
			for cell in data.item_cells(item_text):
				var key := "%s|%s" % [item_text, cell.key()]
				if not by_item_cell.has(key):
					by_item_cell[key] = {
						"item_key": item_text,
						"cell_key": cell.key(),
						"ports": [],
					}
				var conflict = by_item_cell[key] as Dictionary
				var ports = conflict.get("ports", []) as Array
				if not ports.has(port):
					ports.append(port)
				conflict["ports"] = ports
	var result: Array = []
	var keys := by_item_cell.keys()
	keys.sort()
	for key in keys:
		var conflict = by_item_cell[key] as Dictionary
		var ports = conflict.get("ports", []) as Array
		if ports.size() <= 1:
			continue
		ports.sort()
		result.append({
			"item_key": String(conflict.get("item_key", "")),
			"cell_key": String(conflict.get("cell_key", "")),
			"ports": ports.duplicate(),
		})
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


static func _resolved_asset_reference_params(node_type: String, params_value, context: Dictionary) -> Dictionary:
	var result := (params_value as Dictionary).duplicate(true) if params_value is Dictionary else {}
	match node_type:
		NODE_TERRAIN_GENERATION:
			_resolve_distribution_asset_path(result, context)
		NODE_ITEM_GENERATION:
			_resolve_rules_asset_path(result, context)
			_resolve_item_pool_asset_path(result, context)
	return result


static func _resolve_distribution_asset_path(params: Dictionary, context: Dictionary) -> void:
	var path := _asset_reference_path(params, "distribution_asset_path")
	if path == "":
		return
	var resource = _load_asset_reference(path, "distribution_asset_path", "wall_distributions", context)
	if resource is HexWallDistributionResourceScript:
		params["custom_distribution_resource"] = resource
		params["distribution_mode"] = "custom"
		return
	if resource != null:
		_warn_asset_reference_type(
			context,
			"distribution_asset_path",
			path,
			"wall_distributions",
			"HexWallDistributionResource",
			resource
		)


static func _resolve_rules_asset_path(params: Dictionary, context: Dictionary) -> void:
	var path := _asset_reference_path(params, "rules_asset_path")
	if path == "":
		return
	var resource = _load_asset_reference(path, "rules_asset_path", "adjacency_rules", context)
	if resource is HexAdjacencyRuleSetScript:
		params["probability_rules"] = _probability_rules_from_adjacency_resource(resource as HexAdjacencyRuleSetScript)
		return
	if resource != null:
		_warn_asset_reference_type(
			context,
			"rules_asset_path",
			path,
			"adjacency_rules",
			"HexAdjacencyRuleSet",
			resource
		)


static func _resolve_item_pool_asset_path(params: Dictionary, context: Dictionary) -> void:
	var path := _asset_reference_path(params, "item_pool_asset_path")
	if path == "":
		return
	var resource = _load_asset_reference(path, "item_pool_asset_path", "item_pools", context)
	if resource is HexItemPoolResourceScript:
		params["item_pool"] = (resource as HexItemPoolResourceScript).entries.duplicate(true)
		return
	if resource != null:
		_warn_asset_reference_type(
			context,
			"item_pool_asset_path",
			path,
			"item_pools",
			"HexItemPoolResource",
			resource
		)


static func _asset_reference_path(params: Dictionary, key: String) -> String:
	return String(params.get(key, "")).strip_edges()


static func _load_asset_reference(path: String, param_key: String, asset_kind: String, context: Dictionary):
	if not ResourceLoader.exists(path):
		_append_asset_reference_warning(
			context,
			"asset_reference_unresolved",
			param_key,
			path,
			asset_kind,
			"",
			"Asset reference '%s' does not exist. Falling back to inline values for %s." % [path, param_key]
		)
		return null
	var resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if resource == null:
		_append_asset_reference_warning(
			context,
			"asset_reference_unresolved",
			param_key,
			path,
			asset_kind,
			"",
			"Asset reference '%s' could not be loaded. Falling back to inline values for %s." % [path, param_key]
		)
	return resource


static func _warn_asset_reference_type(
	context: Dictionary,
	param_key: String,
	path: String,
	asset_kind: String,
	expected_type: String,
	resource
) -> void:
	_append_asset_reference_warning(
		context,
		"asset_reference_type_mismatch",
		param_key,
		path,
		asset_kind,
		expected_type,
		"Asset reference '%s' is not a %s. Falling back to inline values for %s." % [path, expected_type, param_key],
		_actual_resource_type(resource)
	)


static func _append_asset_reference_warning(
	context: Dictionary,
	code: String,
	param_key: String,
	path: String,
	asset_kind: String,
	expected_type: String,
	message: String,
	actual_type: String = ""
) -> void:
	var warning := {
		"code": code,
		"node": String(context.get("__node_id", "")),
		"param": param_key,
		"path": path,
		"asset_kind": asset_kind,
		"expected_type": expected_type,
		"actual_type": actual_type,
		"message": message,
	}
	if context.has("__warnings") and context["__warnings"] is Array:
		(context["__warnings"] as Array).append(warning)
		return
	push_warning(message)


static func _actual_resource_type(resource) -> String:
	if resource == null:
		return "<null>"
	if resource is Resource:
		var script = (resource as Resource).get_script()
		if script != null and script is Script:
			var script_path := String((script as Script).resource_path)
			if script_path != "":
				return script_path
	return resource.get_class() if resource is Object else str(typeof(resource))


static func _probability_rules_from_adjacency_resource(resource: HexAdjacencyRuleSetScript) -> Dictionary:
	if resource.has_pattern_data() or float(resource.default_probability) != 0.0:
		var rules: Array = []
		for raw_pattern in resource.patterns:
			if not raw_pattern is Dictionary:
				continue
			var pattern := raw_pattern as Dictionary
			var directions = pattern.get("directions", [])
			rules.append({
				"directions": directions.duplicate() if directions is Array else [],
				"component_sizes": _component_sizes_from_direction_keys(directions if directions is Array else []),
				"probability": clampf(float(pattern.get("probability", 0.5)), 0.0, 1.0),
			})
		return {
			"default": clampf(float(resource.default_probability), 0.0, 1.0),
			"rules": rules,
		}
	return resource.to_probability_rules()


static func _component_sizes_from_direction_keys(direction_keys: Array) -> Array:
	var cells: Array = []
	for direction in HexVectorScript.directions():
		if direction_keys.has(direction.key()):
			cells.append(direction)
	var remaining := {}
	for cell in cells:
		remaining[cell.key()] = cell
	var sizes: Array = []
	for cell in cells:
		if not remaining.has(cell.key()):
			continue
		var size := 0
		var stack: Array = [cell]
		remaining.erase(cell.key())
		while not stack.is_empty():
			var current = stack.pop_back()
			size += 1
			for other in cells:
				if not remaining.has(other.key()):
					continue
				if _hex_points_adjacent(current, other):
					remaining.erase(other.key())
					stack.append(other)
		sizes.append(size)
	sizes.sort()
	return sizes


static func _hex_points_adjacent(a, b) -> bool:
	var delta = a.subtract(b)
	for direction in HexVectorScript.directions():
		if delta.key() == direction.key():
			return true
	return false


static func _custom_wall_distribution(params: Dictionary):
	if String(params.get("distribution_mode", "preset")) != "custom":
		return null
	var resource = params.get("custom_distribution_resource", null)
	if resource != null and resource.has_method("prob"):
		return resource
	var values = params.get("custom_distribution", [])
	if values is Dictionary and not (values as Dictionary).is_empty():
		var inline_resource = HexWallDistributionResourceScript.new()
		inline_resource.weights_by_count = _normalize_custom_distribution_dict(values as Dictionary)
		return inline_resource
	if values is Array and not (values as Array).is_empty():
		var inline_resource = HexWallDistributionResourceScript.new()
		inline_resource.weights_by_count = {"3": _normalize_distribution_weights(values as Array, 8)}
		return inline_resource
	return null


static func _normalize_custom_distribution_dict(values: Dictionary) -> Dictionary:
	var result := {}
	for count in [0, 1, 2, 3]:
		var key := str(count)
		var raw = values.get(key, values.get(count, []))
		result[key] = _normalize_distribution_weights(raw if raw is Array else [], HexWallDistributionResourceScript.reference_state_count(count))
	return result


static func _normalize_distribution_weights(values: Array, expected_size: int) -> Array:
	var result: Array = []
	for index in range(expected_size):
		var value = values[index] if index < values.size() else 0.0
		result.append(clampf(float(value), 0.0, 8.0))
	return result


static func _probability_rules_param(value) -> Dictionary:
	if value is Dictionary:
		var result := {}
		var data := value as Dictionary
		if data.has("default"):
			result["default"] = clampf(float(data.get("default", 0.0)), 0.0, 1.0)
		for key in data.keys():
			if ["default", "name", "rules"].has(key):
				continue
			result[key] = clampf(float(data[key]), 0.0, 1.0)
		for raw_rule in data.get("rules", []) as Array:
			if not raw_rule is Dictionary:
				continue
			var rule := raw_rule as Dictionary
			var key = _rule_key(rule)
			result[key] = clampf(float(rule.get("probability", 0.0)), 0.0, 1.0)
		return result
	var parse_result := _parse_probability_rules_text_report(String(value))
	return parse_result.get("rules", {}) as Dictionary


static func _rule_key(rule: Dictionary):
	if rule.has("component_sizes") and rule["component_sizes"] is Array:
		var sizes: Array = []
		for value in (rule["component_sizes"] as Array):
			sizes.append(int(value))
		sizes.sort()
		var parts: Array[String] = []
		for size in sizes:
			parts.append(str(size))
		return "components:%s" % ",".join(parts)
	return Vector2i(int(rule.get("count", 0)), int(rule.get("components", 0)))


static func _parse_probability_rules_text_report(text: String) -> Dictionary:
	var rules := {}
	var invalid_entries: Array[String] = []
	for raw_entry in text.split(";", false):
		var entry = String(raw_entry).strip_edges()
		if entry == "":
			continue
		var pair = entry.split("=", false, 1)
		if pair.size() != 2:
			invalid_entries.append(entry)
			continue
		var key_text = String(pair[0]).strip_edges()
		var value_text = String(pair[1]).strip_edges()
		if key_text == "" or not value_text.is_valid_float():
			invalid_entries.append(entry)
			continue
		var key = _probability_rule_key_from_text(key_text)
		if key == null:
			invalid_entries.append(entry)
			continue
		rules[key] = clampf(float(value_text), 0.0, 1.0)
	return {
		"rules": rules,
		"invalid_entries": invalid_entries,
	}


static func _probability_rule_key_from_text(key_text: String):
	if key_text == "default":
		return "default"
	if key_text.is_valid_int():
		return int(key_text)
	if key_text.count(",") == 1:
		var parts = key_text.split(",", false, 1)
		if parts.size() == 2 \
				and String(parts[0]).strip_edges().is_valid_int() \
				and String(parts[1]).strip_edges().is_valid_int():
			return Vector2i(
				int(String(parts[0]).strip_edges()),
				int(String(parts[1]).strip_edges())
			)
	return null


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


static func _toric_passage_cyclic_size(cells: Array) -> int:
	# Toric wrap is only defined on a full size x size square cell set
	# (core asserts width == height for toric maps).
	var count := cells.size()
	if count <= 0:
		return 0
	var side := int(round(sqrt(float(count))))
	if side * side != count:
		return 0
	var cell_keys := {}
	for cell in cells:
		cell_keys[cell.key()] = true
	for square_cell in HexMapDataScript.square(side).cells:
		if not cell_keys.has(square_cell.key()):
			return 0
	return side


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
