extends SceneTree

const HexGenerationGraph = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexGenerationGraphRunner = preload("res://addons/hex_map_kit/generation/hex_generation_graph_runner.gd")
const HexGenerationGraphResource = preload("res://addons/hex_map_kit/adapter/hex_generation_graph_resource.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run()


func _run() -> void:
	_test_graph_resource_to_from_dict_roundtrip()
	_test_graph_resource_graph_settings_roundtrip()
	_test_graph_resource_result_overlay_ports_roundtrip()
	_test_graph_resource_save_load_roundtrip()

	if _failures.is_empty():
		print("test_generation_graph_resource.gd: all tests passed")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _test_graph_resource_to_from_dict_roundtrip() -> void:
	var graph := _sample_graph()
	var resource = HexGenerationGraphResource.from_dict(graph)
	resource.graph_id = "graph14_roundtrip"
	resource.promote_targets = [{"node_id": "connect", "role": "terrain"}]
	resource.semantics_snapshot = {"embed": true, "catalog": {"source": "self"}}

	_assert_graph_eq(resource.to_dict(), graph, "GRAPH-14 resource converts back to Dictionary graph")
	var second = HexGenerationGraphResource.from_dict(resource.to_dict())
	_assert_graph_eq(second.to_dict(), graph, "GRAPH-14 from_dict(to_dict(g)) is symmetric")

	var report = HexGenerationGraphRunner.run_with_report(second.to_dict())
	_assert_true(bool(report["ok"]), "GRAPH-14 resource Dictionary output runs through GRAPH-10 runner")


func _test_graph_resource_save_load_roundtrip() -> void:
	var graph := _sample_graph()
	var resource = HexGenerationGraphResource.from_dict(graph)
	resource.graph_id = "graph14_save_load"
	resource.promote_targets = [{"node_id": "connect", "role": "terrain"}]
	resource.semantics_snapshot = {"embed": true, "document_role": "generated"}

	var path := _test_resource_path("graph14_generation_graph.tres")
	_assert_eq(ResourceSaver.save(resource, path), OK, "GRAPH-14 graph resource saves")
	var loaded = ResourceLoader.load(path)
	_assert_true(loaded is HexGenerationGraphResource, "GRAPH-14 graph resource reloads")
	_assert_graph_eq((loaded as HexGenerationGraphResource).to_dict(), graph, "GRAPH-14 save/load preserves graph")
	_assert_eq(String((loaded as HexGenerationGraphResource).graph_id), "graph14_save_load", "GRAPH-14 save/load preserves graph id")
	_assert_eq((loaded as HexGenerationGraphResource).promote_targets.size(), 1, "GRAPH-14 save/load preserves promote target")
	_assert_true(bool((loaded as HexGenerationGraphResource).semantics_snapshot.get("embed", false)), "GRAPH-14 save/load preserves embed snapshot")


func _test_graph_resource_graph_settings_roundtrip() -> void:
	var graph := _sample_graph()
	graph["settings"] = {
		"seed": 314,
		"orientation": HexMapResource.ORIENTATION_POINTY_TOP,
	}
	var resource = HexGenerationGraphResource.from_dict(graph)
	var roundtrip = resource.to_dict()
	_assert_eq(int((roundtrip["settings"] as Dictionary).get("seed", -1)), 314, "REPAIR-13 graph settings preserve base seed")
	_assert_eq(int((roundtrip["settings"] as Dictionary).get("orientation", -1)), HexMapResource.ORIENTATION_POINTY_TOP, "REPAIR-13 graph settings preserve orientation")

	var path := _test_resource_path("repair13_generation_graph_settings.tres")
	_assert_eq(ResourceSaver.save(resource, path), OK, "REPAIR-13 graph settings resource saves")
	var loaded = ResourceLoader.load(path)
	_assert_true(loaded is HexGenerationGraphResource, "REPAIR-13 graph settings resource reloads")
	_assert_eq(int((loaded as HexGenerationGraphResource).graph_settings.get("seed", -1)), 314, "REPAIR-13 save/load keeps base seed")
	_assert_eq(int((loaded as HexGenerationGraphResource).graph_settings.get("orientation", -1)), HexMapResource.ORIENTATION_POINTY_TOP, "REPAIR-13 save/load keeps orientation")


func _test_graph_resource_result_overlay_ports_roundtrip() -> void:
	var graph := _sample_result_graph()
	var resource = HexGenerationGraphResource.from_dict(graph)
	resource.graph_id = "repair11_result_overlay_ports"
	resource.promote_targets = [{"node_id": "result", "role": "result"}]

	var roundtrip = resource.to_dict()
	_assert_graph_eq(roundtrip, graph, "REPAIR-11 Result overlay ports convert through resource")
	var path := _test_resource_path("repair11_result_overlay_ports.tres")
	_assert_eq(ResourceSaver.save(resource, path), OK, "REPAIR-11 Result overlay port graph saves")
	var loaded = ResourceLoader.load(path)
	_assert_true(loaded is HexGenerationGraphResource, "REPAIR-11 Result overlay port graph reloads")
	_assert_graph_eq((loaded as HexGenerationGraphResource).to_dict(), graph, "REPAIR-11 save/load preserves numbered Result overlay ports")
	_assert_eq(String(((loaded as HexGenerationGraphResource).promote_targets[0] as Dictionary).get("role", "")), "result", "REPAIR-11 save/load keeps Result promote role")


func _sample_graph() -> Dictionary:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle",
		"width": 7,
		"height": 4,
		"toric": false,
	})
	HexGenerationGraph.add_node(graph, "walls", "wall_field", {
		"wall_probability": 0.35,
		"seed": 23,
	})
	HexGenerationGraph.add_node(graph, "connect", "connectivity", {
		"method": "dense",
		"seed": 41,
	})
	HexGenerationGraph.add_edge(graph, "shape", "walls", "in")
	HexGenerationGraph.add_edge(graph, "walls", "connect", "in")
	return graph


func _sample_result_graph() -> Dictionary:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle",
		"width": 4,
		"height": 3,
	})
	HexGenerationGraph.add_node(graph, "filter", "region_filter", {"filter_target": "floor"})
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
	HexGenerationGraph.add_edge(graph, "shape", "filter", "in")
	HexGenerationGraph.add_edge(graph, "filter", "items_a", "scope")
	HexGenerationGraph.add_edge(graph, "filter", "items_b", "scope")
	HexGenerationGraph.add_edge(graph, "shape", "result", "terrain")
	HexGenerationGraph.add_edge(graph, "items_a", "result", "overlay_0")
	HexGenerationGraph.add_edge(graph, "items_b", "result", "overlay_1")
	return graph


func _test_resource_path(file_name: String) -> String:
	var run_id = OS.get_environment("HEX_MAP_TEST_RUN_ID")
	if run_id == "":
		run_id = "manual"
	var path = "res://.godot_user/test-runs/%s/test_generation_graph_resource/%s" % [run_id, file_name]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	return path


func _assert_graph_eq(actual: Dictionary, expected: Dictionary, message: String) -> void:
	_assert_eq((actual.get("nodes", {}) as Dictionary).size(), (expected.get("nodes", {}) as Dictionary).size(), "%s node count" % message)
	_assert_eq((actual.get("edges", []) as Array).size(), (expected.get("edges", []) as Array).size(), "%s edge count" % message)
	for node_id in (expected.get("nodes", {}) as Dictionary).keys():
		var actual_node = (actual["nodes"] as Dictionary).get(node_id, {}) as Dictionary
		var expected_node = (expected["nodes"] as Dictionary)[node_id] as Dictionary
		_assert_eq(String(actual_node.get("type", "")), String(expected_node.get("type", "")), "%s node type %s" % [message, node_id])
		_assert_dict_eq(actual_node.get("params", {}) as Dictionary, expected_node.get("params", {}) as Dictionary, "%s node params %s" % [message, node_id])
	for index in range((expected.get("edges", []) as Array).size()):
		_assert_eq(str((actual["edges"] as Array)[index]), str((expected["edges"] as Array)[index]), "%s edge %d" % [message, index])


func _assert_eq(actual, expected, message: String) -> void:
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_dict_eq(actual: Dictionary, expected: Dictionary, message: String) -> void:
	_assert_eq(actual.size(), expected.size(), "%s key count" % message)
	for key in expected.keys():
		if not actual.has(key):
			_failures.append("%s missing key %s" % [message, str(key)])
			continue
		_assert_eq(actual[key], expected[key], "%s key %s" % [message, str(key)])
