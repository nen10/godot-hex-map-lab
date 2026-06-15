extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexOverlayData = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexOverlayResource = preload("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapDocumentTerrainLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_terrain_layer_resource.gd")
const HexMapDocumentOverlayLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_overlay_layer_resource.gd")
const HexGenerationPorts = preload("res://addons/hex_map_kit/generation/hex_generation_ports.gd")
const HexGenerationGraph = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexGenerationGraphRunner = preload("res://addons/hex_map_kit/generation/hex_generation_graph_runner.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run()


func _run() -> void:
	_test_port_types_are_declared()
	_test_shape_wall_connectivity_chain_runs_to_connected_terrain()
	_test_filter_to_item_generator_chain_limits_overlay_to_selection()
	_test_source_node_reads_map_resource()
	_test_source_node_reads_document_overlay()
	_test_invalid_edge_type_is_rejected()
	_test_missing_required_input_is_rejected()
	_test_cycle_is_rejected()
	_test_same_graph_and_seed_are_deterministic()
	_test_empty_graph_runs_to_empty_cache()

	if _failures.is_empty():
		print("test_generation_graph.gd: all tests passed")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _test_port_types_are_declared() -> void:
	_assert_eq(HexGenerationPorts.ALL, ["terrain", "selection", "overlay", "result"], "graph declares the four MVP port types")
	_assert_true(HexGenerationPorts.compatible(HexGenerationPorts.TERRAIN, [HexGenerationPorts.TERRAIN]), "terrain accepts terrain")
	_assert_false(HexGenerationPorts.compatible(HexGenerationPorts.TERRAIN, [HexGenerationPorts.SELECTION]), "terrain does not accept selection")


func _test_shape_wall_connectivity_chain_runs_to_connected_terrain() -> void:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle",
		"width": 7,
		"height": 4,
	})
	HexGenerationGraph.add_node(graph, "walls", "wall_field", {
		"wall_probability": 0.42,
		"seed": 23,
		"protected_floor": [_cell(0, 0), _cell(6, 3)],
	})
	HexGenerationGraph.add_node(graph, "connect", "connectivity", {
		"method": "dense",
		"seed": 41,
	})
	HexGenerationGraph.add_edge(graph, "shape", "walls", "in")
	HexGenerationGraph.add_edge(graph, "walls", "connect", "in")

	var report = HexGenerationGraphRunner.run_with_report(graph)
	_assert_true(report["ok"], "terrain graph validates and runs")
	var data = report["cache"]["connect"]
	_assert_true(data is HexMapData, "connectivity node outputs HexMapData")
	_assert_true(data.floor_cells().size() > 0, "terrain output has floor cells")
	_assert_true(HexMapGenerator.is_floor_connected(data), "Shape->Wall->Connectivity produces connected floor")


func _test_filter_to_item_generator_chain_limits_overlay_to_selection() -> void:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle",
		"width": 4,
		"height": 3,
	})
	HexGenerationGraph.add_node(graph, "floor_filter", "region_filter", {
		"mode": "floor",
	})
	HexGenerationGraph.add_node(graph, "items", "item_generator", {
		"mode": "weighted",
		"placement_probability": 1.0,
		"seed": 99,
		"item_pool": [{"name": "spawn", "weight": 1.0}],
	})
	HexGenerationGraph.add_edge(graph, "shape", "floor_filter", "in")
	HexGenerationGraph.add_edge(graph, "floor_filter", "items", "scope")

	var cache = HexGenerationGraphRunner.run(graph)
	var selection: Array = cache["floor_filter"]
	var overlay = cache["items"]
	var selection_set = HexMapData.make_set(selection)
	_assert_true(overlay is HexOverlayData, "item generator outputs HexOverlayData")
	_assert_eq(overlay.item_keys(), ["spawn"], "item generator writes configured item key")
	_assert_eq(overlay.item_cells("spawn").size(), selection.size(), "probability 1.0 places one item per selected cell")
	for cell in overlay.item_cells("spawn"):
		_assert_true(selection_set.has(cell.key()), "item generator writes only inside region filter selection")


func _test_source_node_reads_map_resource() -> void:
	var data = HexMapData.from_cells([_cell(0, 0), _cell(1, 0), _cell(2, 0)], [_cell(1, 0)])
	var map_resource = HexMapResource.from_map_data(data)
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "source", "source", {
		"kind": "map_resource",
	}, {"map": map_resource})
	HexGenerationGraph.add_node(graph, "walls", "region_filter", {
		"mode": "wall",
	})
	HexGenerationGraph.add_edge(graph, "source", "walls", "in")

	var cache = HexGenerationGraphRunner.run(graph)
	_assert_keys_eq(cache["walls"], [_cell(1, 0)], "source node converts HexMapResource into terrain input")


func _test_source_node_reads_document_overlay() -> void:
	var document = HexMapDocumentResource.new()
	var overlay = HexOverlayData.from_item_cells([_cell(0, 0), _cell(1, 0)], "door", [_cell(1, 0)])
	var overlay_layer = HexMapDocumentOverlayLayerResource.new()
	overlay_layer.layer_id = "object_marks"
	overlay_layer.overlay = HexOverlayResource.from_overlay_data(overlay)
	document.overlay_layers.append(overlay_layer)

	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "source", "source", {
		"kind": "document_overlay",
		"layer_id": "object_marks",
	}, {"document": document})
	HexGenerationGraph.add_node(graph, "door_cells", "region_filter", {
		"mode": "query",
		"selectors": [{"item_key": "door"}],
		"op": HexOverlayData.ITEM_QUERY_OR,
	})
	HexGenerationGraph.add_edge(graph, "source", "door_cells", "in")

	var cache = HexGenerationGraphRunner.run(graph)
	_assert_keys_eq(cache["door_cells"], [_cell(1, 0)], "source node converts document overlay layer into filter input")


func _test_invalid_edge_type_is_rejected() -> void:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {"shape": "rectangle"})
	HexGenerationGraph.add_node(graph, "items", "item_generator", {
		"item_pool": [{"name": "loot", "weight": 1.0}],
	})
	HexGenerationGraph.add_edge(graph, "shape", "items", "scope")
	var validation = HexGenerationGraph.validate(graph)
	_assert_false(validation["ok"], "type-mismatched graph is invalid")
	_assert_true(_has_error(validation, "type_mismatch"), "terrain->selection invalid edge reports type_mismatch")


func _test_missing_required_input_is_rejected() -> void:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "walls", "wall_field", {"wall_probability": 0.5})
	var validation = HexGenerationGraph.validate(graph)
	_assert_false(validation["ok"], "missing input graph is invalid")
	_assert_true(_has_error(validation, "missing_required_input"), "missing wall_field input reports missing_required_input")


func _test_cycle_is_rejected() -> void:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "a", "compose")
	HexGenerationGraph.add_node(graph, "b", "compose")
	HexGenerationGraph.add_edge(graph, "a", "b", "base")
	HexGenerationGraph.add_edge(graph, "b", "a", "base")
	var validation = HexGenerationGraph.validate(graph)
	_assert_false(validation["ok"], "cycle graph is invalid")
	_assert_true(_has_error(validation, "cycle"), "cycle graph reports cycle")


func _test_same_graph_and_seed_are_deterministic() -> void:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle",
		"width": 5,
		"height": 3,
	})
	HexGenerationGraph.add_node(graph, "walls", "wall_field", {
		"wall_probability": 0.35,
		"seed": 7,
	})
	HexGenerationGraph.add_edge(graph, "shape", "walls", "in")
	var a = HexGenerationGraphRunner.run(graph, {"seed": 100})["walls"]
	var b = HexGenerationGraphRunner.run(graph, {"seed": 100})["walls"]
	_assert_keys_eq(a.cells, b.cells, "deterministic graph keeps cells")
	_assert_keys_eq(a.walls, b.walls, "deterministic graph keeps wall output")


func _test_empty_graph_runs_to_empty_cache() -> void:
	var report = HexGenerationGraphRunner.run_with_report(HexGenerationGraph.new_graph())
	_assert_true(report["ok"], "empty graph is valid")
	_assert_eq(report["cache"], {}, "empty graph runs to an empty cache")


func _cell(q: int, r: int):
	return HexVector.apply_basis(q, 0, r)


func _has_error(validation: Dictionary, code: String) -> bool:
	for error in validation.get("errors", []):
		if String(error.get("code", "")) == code:
			return true
	return false


func _keys(points: Array) -> Array:
	var result: Array = []
	for point in points:
		result.append(point.key())
	result.sort()
	return result


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_false(value: bool, message: String) -> void:
	if value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _assert_keys_eq(actual: Array, expected: Array, message: String) -> void:
	var actual_keys = _keys(actual)
	var expected_keys = _keys(expected)
	if actual_keys != expected_keys:
		_failures.append("%s: expected %s, got %s" % [message, str(expected_keys), str(actual_keys)])

