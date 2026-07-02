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
const HexGenerationResultResource = preload("res://addons/hex_map_kit/adapter/hex_generation_result_resource.gd")
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
	_test_overlay_to_region_filter_returns_occupied_cells()
	_test_result_requires_terrain_and_rejects_result_input()
	_test_duplicate_input_edge_is_rejected()
	_test_result_keeps_multiple_overlays_in_port_order()
	_test_structured_adjacency_rules_and_custom_markov_distribution()
	_test_square_markov_mesh_missing_size_uses_visible_default()
	_test_connectivity_toric_passage_owns_wrap_topology()
	_test_item_generator_limited_places_exact_counts()

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
		"filter_target": "floor",
	})
	HexGenerationGraph.add_node(graph, "items", "item_generator", {
		"placement_method": "weighted",
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
		"filter_target": "wall",
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
		"filter_target": "item_key",
		"item_key": "door",
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


func _test_overlay_to_region_filter_returns_occupied_cells() -> void:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle", "width": 4, "height": 3,
	})
	HexGenerationGraph.add_node(graph, "floor_filter", "region_filter", {
		"filter_target": "floor",
	})
	HexGenerationGraph.add_node(graph, "items", "item_generator", {
		"placement_method": "weighted",
		"placement_probability": 1.0, "seed": 99,
		"item_pool": [{"name": "chest", "weight": 1.0}],
	})
	HexGenerationGraph.add_node(graph, "overlay_filter", "region_filter", {
		"filter_target": "floor",
	})
	HexGenerationGraph.add_edge(graph, "shape", "floor_filter", "in")
	HexGenerationGraph.add_edge(graph, "floor_filter", "items", "scope")
	HexGenerationGraph.add_edge(graph, "items", "overlay_filter", "in")
	var cache = HexGenerationGraphRunner.run(graph)
	var overlay_selection = cache["overlay_filter"] as Array
	var overlay = cache["items"]
	_assert_true(overlay_selection.size() > 0, "overlay region filter returns occupied cells")
	_assert_eq(overlay_selection.size(), overlay.occupied_cells().size(), "overlay filter_target=floor falls back to occupied_cells()")


func _test_result_requires_terrain_and_rejects_result_input() -> void:
	var missing = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(missing, "overlay_source", "source", {
		"kind": "provided",
		"data": HexOverlayData.from_item_cells([_cell(0, 0)], "spawn", [_cell(0, 0)]),
		"output_type": HexGenerationPorts.OVERLAY,
	})
	HexGenerationGraph.add_node(missing, "result", "result")
	HexGenerationGraph.add_edge(missing, "overlay_source", "result", "overlay_0")
	var validation = HexGenerationGraph.validate(missing)
	_assert_false(validation["ok"], "REPAIR-11 Result without terrain is invalid")
	_assert_true(_has_error(validation, "missing_required_input"), "REPAIR-11 missing Result terrain reports missing_required_input")

	var result_to_result = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(result_to_result, "shape", "shape", {"shape": "rectangle", "width": 2, "height": 2})
	HexGenerationGraph.add_node(result_to_result, "result_a", "result")
	HexGenerationGraph.add_node(result_to_result, "result_b", "result")
	HexGenerationGraph.add_edge(result_to_result, "shape", "result_a", "terrain")
	HexGenerationGraph.add_edge(result_to_result, "result_a", "result_b", "terrain")
	validation = HexGenerationGraph.validate(result_to_result)
	_assert_false(validation["ok"], "REPAIR-11 Result output cannot feed Result terrain")
	_assert_true(_has_error(validation, "type_mismatch"), "REPAIR-11 Result->Result terrain reports type_mismatch")

	var result_to_overlay = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(result_to_overlay, "shape", "shape", {"shape": "rectangle", "width": 2, "height": 2})
	HexGenerationGraph.add_node(result_to_overlay, "result_a", "result")
	HexGenerationGraph.add_node(result_to_overlay, "result_b", "result")
	HexGenerationGraph.add_edge(result_to_overlay, "shape", "result_a", "terrain")
	HexGenerationGraph.add_edge(result_to_overlay, "shape", "result_b", "terrain")
	HexGenerationGraph.add_edge(result_to_overlay, "result_a", "result_b", "overlay_0")
	validation = HexGenerationGraph.validate(result_to_overlay)
	_assert_false(validation["ok"], "REPAIR-11 Result output cannot feed Result overlay slot")
	_assert_true(_has_error(validation, "type_mismatch"), "REPAIR-11 Result->Result overlay reports type_mismatch")


func _test_duplicate_input_edge_is_rejected() -> void:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {"shape": "rectangle", "width": 2, "height": 2})
	HexGenerationGraph.add_node(graph, "floor_filter", "region_filter", {"filter_target": "floor"})
	HexGenerationGraph.add_node(graph, "items_a", "item_generator", {
		"placement_method": "weighted",
		"placement_probability": 1.0,
		"item_pool": [{"name": "spawn", "weight": 1.0}],
	})
	HexGenerationGraph.add_node(graph, "items_b", "item_generator", {
		"placement_method": "weighted",
		"placement_probability": 1.0,
		"item_pool": [{"name": "loot", "weight": 1.0}],
	})
	HexGenerationGraph.add_node(graph, "result", "result")
	HexGenerationGraph.add_edge(graph, "shape", "floor_filter", "in")
	HexGenerationGraph.add_edge(graph, "floor_filter", "items_a", "scope")
	HexGenerationGraph.add_edge(graph, "floor_filter", "items_b", "scope")
	HexGenerationGraph.add_edge(graph, "shape", "result", "terrain")
	HexGenerationGraph.add_edge(graph, "items_a", "result", "overlay_0")
	HexGenerationGraph.add_edge(graph, "items_b", "result", "overlay_0")
	var validation = HexGenerationGraph.validate(graph)
	_assert_false(validation["ok"], "REPAIR-11 duplicate input port graph is invalid")
	_assert_true(_has_error(validation, "duplicate_input_edge"), "REPAIR-11 duplicate input port reports duplicate_input_edge")


func _test_result_keeps_multiple_overlays_in_port_order() -> void:
	var graph = HexGenerationGraph.new_graph()
	var terrain = HexMapData.rectangle(2, 2)
	var overlay_0 = HexOverlayData.from_item_cells([_cell(0, 0), _cell(1, 0)], "spawn", [_cell(0, 0)])
	var overlay_1 = HexOverlayData.from_item_cells([_cell(0, 0), _cell(1, 0)], "spawn", [_cell(0, 0)])
	overlay_1.add_item_cell("loot", _cell(1, 0))
	HexGenerationGraph.add_node(graph, "terrain_source", "source", {
		"kind": "provided",
		"data": terrain,
		"output_type": HexGenerationPorts.TERRAIN,
	})
	HexGenerationGraph.add_node(graph, "overlay_zero_source", "source", {
		"kind": "provided",
		"data": overlay_0,
		"output_type": HexGenerationPorts.OVERLAY,
	})
	HexGenerationGraph.add_node(graph, "overlay_one_source", "source", {
		"kind": "provided",
		"data": overlay_1,
		"output_type": HexGenerationPorts.OVERLAY,
	})
	HexGenerationGraph.add_node(graph, "result", "result")
	HexGenerationGraph.add_edge(graph, "terrain_source", "result", "terrain")
	HexGenerationGraph.add_edge(graph, "overlay_one_source", "result", "overlay_1")
	HexGenerationGraph.add_edge(graph, "overlay_zero_source", "result", "overlay_0")

	var report = HexGenerationGraphRunner.run_with_report(graph)
	_assert_true(bool(report["ok"]), "REPAIR-11 multi-overlay Result graph runs")
	var result = (report["cache"] as Dictionary)["result"] as HexGenerationResultResource
	_assert_true(result is HexGenerationResultResource, "REPAIR-11 Result node outputs HexGenerationResultResource")
	_assert_eq(result.overlay_maps.size(), 2, "REPAIR-11 Result stores both overlay maps")
	_assert_eq(result.overlay_map, result.overlay_maps[0], "REPAIR-11 legacy overlay_map mirrors first overlay")
	_assert_eq(result.overlay_maps[0].to_overlay_data().item_keys(), ["spawn"], "REPAIR-11 overlay_0 remains first despite reversed edge insertion")
	_assert_eq(result.overlay_maps[1].to_overlay_data().item_keys(), ["loot", "spawn"], "REPAIR-11 overlay_1 remains second")
	var overlay_inputs = result.metadata.get("overlay_inputs", []) as Array
	_assert_eq(String((overlay_inputs[0] as Dictionary)["port"]), "overlay_0", "REPAIR-11 overlay metadata starts at overlay_0")
	_assert_true(bool((overlay_inputs[0] as Dictionary)["present"]), "REPAIR-11 overlay_0 metadata is present")
	_assert_true(bool((overlay_inputs[1] as Dictionary)["present"]), "REPAIR-11 overlay_1 metadata is present")
	var conflicts = result.metadata.get("overlay_conflicts", []) as Array
	_assert_eq(conflicts.size(), 1, "REPAIR-11 same item/cell across overlays records one conflict")
	_assert_eq((conflicts[0] as Dictionary).get("ports", []), ["overlay_0", "overlay_1"], "REPAIR-11 conflict records both overlay ports")


func _test_structured_adjacency_rules_and_custom_markov_distribution() -> void:
	var adjacency_graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(adjacency_graph, "shape", "shape", {"shape": "rectangle", "width": 3, "height": 2})
	HexGenerationGraph.add_node(adjacency_graph, "filter", "terrain_filter", {"filter_target": "floor"})
	HexGenerationGraph.add_node(adjacency_graph, "items", "item_generator", {
		"placement_method": "adjacency_rules",
		"item_name": "gem",
		"probability_rules": {
			"default": 1.0,
			"rules": [{"component_sizes": [2], "probability": 1.0}],
		},
		"neighbor_radius": 1,
	})
	HexGenerationGraph.add_edge(adjacency_graph, "shape", "filter", "in")
	HexGenerationGraph.add_edge(adjacency_graph, "filter", "items", "scope")
	var adjacency_cache = HexGenerationGraphRunner.run(adjacency_graph)
	var overlay = adjacency_cache["items"] as HexOverlayData
	_assert_eq(overlay.item_cells("gem").size(), 6, "REPAIR-17 structured adjacency rules (default applied) are accepted by the runner")

	var gated_graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(gated_graph, "shape", "shape", {"shape": "rectangle", "width": 3, "height": 2})
	HexGenerationGraph.add_node(gated_graph, "filter", "terrain_filter", {"filter_target": "floor"})
	HexGenerationGraph.add_node(gated_graph, "items", "item_generator", {
		"placement_method": "adjacency_rules",
		"item_name": "gem",
		"probability_rules": {"default": 0.0, "rules": []},
		"neighbor_radius": 1,
	})
	HexGenerationGraph.add_edge(gated_graph, "shape", "filter", "in")
	HexGenerationGraph.add_edge(gated_graph, "filter", "items", "scope")
	var gated_overlay = HexGenerationGraphRunner.run(gated_graph)["items"] as HexOverlayData
	_assert_eq(gated_overlay.item_cells("gem").size(), 0, "REPAIR-17 structured default gates placement (multiset/default path is evaluated)")

	var wall_graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(wall_graph, "shape", "shape", {"shape": "rectangle", "width": 4, "height": 4})
	HexGenerationGraph.add_node(wall_graph, "walls", "wall_field", {
		"wall_method": "markov_mesh",
		"distribution_mode": "custom",
		"wall_probability": 0.0,
		"custom_distribution": {
			"0": [0.0],
			"1": [0.0, 0.0],
			"2": [0.0, 0.0, 0.0, 0.0],
			"3": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
		},
		"seed": 1,
	})
	HexGenerationGraph.add_edge(wall_graph, "shape", "walls", "in")
	var wall_cache = HexGenerationGraphRunner.run(wall_graph)
	var terrain = wall_cache["walls"] as HexMapData
	var custom_wall_count: int = terrain.walls.size()
	# An all-zero custom distribution suppresses every reference-driven Markov draw.
	# Only the structural center seed (intentional fixed-probability density feedback)
	# may remain, so the custom path must leave at most that single wall.
	_assert_true(custom_wall_count <= 1, "REPAIR-18 custom Markov distribution (mode=custom) suppresses reference-driven walls")

	var preset_graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(preset_graph, "shape", "shape", {"shape": "rectangle", "width": 4, "height": 4})
	HexGenerationGraph.add_node(preset_graph, "walls", "wall_field", {
		"wall_method": "markov_mesh",
		"distribution_mode": "preset",
		"custom_distribution": {"3": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]},
		"distribution_id": 20,
		"seed": 1,
	})
	HexGenerationGraph.add_edge(preset_graph, "shape", "walls", "in")
	var preset_terrain = HexGenerationGraphRunner.run(preset_graph)["walls"] as HexMapData
	_assert_true(preset_terrain.walls.size() > 0, "REPAIR-18 preset mode ignores custom distribution and uses preset")


func _test_square_markov_mesh_missing_size_uses_visible_default() -> void:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {"shape": "square"})
	HexGenerationGraph.add_node(graph, "walls", "wall_field", {
		"wall_method": "markov_mesh",
		"distribution_mode": "preset",
		"distribution_id": 20,
		"seed": 1,
	})
	HexGenerationGraph.add_edge(graph, "shape", "walls", "in")
	var cache = HexGenerationGraphRunner.run(graph)
	var shape = cache["shape"] as HexMapData
	var terrain = cache["walls"] as HexMapData
	_assert_eq(shape.cells.size(), 9, "Square shape missing size uses inspector-visible default instead of one cell")
	_assert_eq(terrain.cells.size(), 9, "Square Markov Mesh missing size preserves the default square cell set")


func _test_connectivity_toric_passage_owns_wrap_topology() -> void:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "square",
		"size": 3,
	})
	HexGenerationGraph.add_node(graph, "connect", "connectivity", {
		"method": "dense",
		"seed": 7,
		"toric_passage": true,
	})
	HexGenerationGraph.add_edge(graph, "shape", "connect", "in")
	var cache = HexGenerationGraphRunner.run(graph)
	var shape = cache["shape"] as HexMapData
	var terrain = cache["connect"] as HexMapData
	_assert_eq(shape.cyclic_size, 0, "Shape node no longer owns toric topology")
	_assert_eq(terrain.cyclic_size, 3, "Connectivity toric_passage derives wrap topology from the square cell set")

	var flat_graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(flat_graph, "shape", "shape", {
		"shape": "square",
		"size": 3,
	})
	HexGenerationGraph.add_node(flat_graph, "connect", "connectivity", {
		"method": "dense",
		"seed": 7,
	})
	HexGenerationGraph.add_edge(flat_graph, "shape", "connect", "in")
	var flat_terrain = HexGenerationGraphRunner.run(flat_graph)["connect"] as HexMapData
	_assert_eq(flat_terrain.cyclic_size, 0, "Connectivity without toric_passage leaves topology flat")

	var rect_graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(rect_graph, "shape", "shape", {
		"shape": "rectangle",
		"width": 4,
		"height": 3,
	})
	HexGenerationGraph.add_node(rect_graph, "connect", "connectivity", {
		"method": "dense",
		"seed": 7,
		"toric_passage": true,
	})
	HexGenerationGraph.add_edge(rect_graph, "shape", "connect", "in")
	var rect_terrain = HexGenerationGraphRunner.run(rect_graph)["connect"] as HexMapData
	_assert_eq(rect_terrain.cyclic_size, 0, "Connectivity toric_passage refuses wrap on a non-square cell set")


func _test_item_generator_limited_places_exact_counts() -> void:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "square",
		"size": 4,
	})
	HexGenerationGraph.add_node(graph, "floor_filter", "terrain_filter", {
		"filter_target": "floor",
	})
	HexGenerationGraph.add_node(graph, "items", "item_generator", {
		"placement_method": "limited",
		"seed": 5,
		"item_pool": [
			{"name": "chest", "limit": 2},
			{"name": "key", "limit": 1},
		],
	})
	HexGenerationGraph.add_edge(graph, "shape", "floor_filter", "in")
	HexGenerationGraph.add_edge(graph, "floor_filter", "items", "scope")

	var overlay = HexGenerationGraphRunner.run(graph)["items"]
	_assert_true(overlay is HexOverlayData, "limited item generator outputs HexOverlayData")
	_assert_eq(overlay.item_cells("chest").size(), 2, "limited pool entry with limit=2 places exactly two items")
	_assert_eq(overlay.item_cells("key").size(), 1, "limited pool entry with limit=1 places exactly one item")


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
