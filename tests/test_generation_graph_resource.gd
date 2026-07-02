extends SceneTree

const HexGenerationGraph = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexGenerationGraphRunner = preload("res://addons/hex_map_kit/generation/hex_generation_graph_runner.gd")
const HexAdjacencyRulePresets = preload("res://addons/hex_map_kit/editor/hex_adjacency_rule_presets.gd")
const HexAdjacencyRuleSet = preload("res://addons/hex_map_kit/adapter/hex_adjacency_rule_set.gd")
const HexGenerationGraphResource = preload("res://addons/hex_map_kit/adapter/hex_generation_graph_resource.gd")
const HexItemPoolResource = preload("res://addons/hex_map_kit/adapter/hex_item_pool_resource.gd")
const HexMapAssetLibrary = preload("res://addons/hex_map_kit/editor/hex_map_asset_library.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexRandomizer = preload("res://addons/hex_map_kit/core/hex_randomizer.gd")
const HexWallDistributionResource = preload("res://addons/hex_map_kit/adapter/hex_wall_distribution_resource.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run()


func _run() -> void:
	_test_asset_library_two_tier_service()
	_test_graph_resource_to_from_dict_roundtrip()
	_test_graph_resource_graph_settings_roundtrip()
	_test_graph_resource_result_overlay_ports_roundtrip()
	_test_graph_resource_save_load_roundtrip()
	_test_graph_resource_v5_params_save_load_roundtrip()
	_test_item_pool_resource_save_load_roundtrip()
	_test_wall_distribution_resource_save_load_roundtrip()
	_test_wall_distribution_from_preset_matches_builtin()

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


func _test_asset_library_two_tier_service() -> void:
	var had_setting := ProjectSettings.has_setting(HexMapAssetLibrary.ASSET_ROOT_SETTING)
	var previous_setting = ProjectSettings.get_setting(HexMapAssetLibrary.ASSET_ROOT_SETTING) if had_setting else HexMapAssetLibrary.DEFAULT_ASSET_ROOT
	var root_a := _test_run_dir("gqm02_asset_root_a")
	var root_b := _test_run_dir("gqm02_asset_root_b")
	ProjectSettings.set_setting(HexMapAssetLibrary.ASSET_ROOT_SETTING, root_a)

	var bundled_entries := HexMapAssetLibrary.list("adjacency_rules")
	var bundled_entry := _first_entry_by_source(bundled_entries, HexMapAssetLibrary.SOURCE_BUNDLED)
	_assert_true(not bundled_entry.is_empty(), "GQM-02 asset library lists bundled adjacency rule presets")

	var project_rules = HexAdjacencyRuleSet.from_dialog_dict({
		"default": 0.25,
		"rules": [{"directions": ["1,0,0"], "probability": 0.75}],
	}, "Project Rules")
	var save_result := HexMapAssetLibrary.save(project_rules, "adjacency_rules", "Project Rules")
	var project_path := String(save_result.get("path", ""))
	_assert_eq(int(save_result.get("error", FAILED)), OK, "GQM-02 asset library saves project asset")
	_assert_true(project_path.begins_with("%s/adjacency_rules/" % root_a), "GQM-02 asset library saves under configured project root")

	var mixed_entries := HexMapAssetLibrary.list("adjacency_rules")
	_assert_true(not _find_entry(mixed_entries, project_path, HexMapAssetLibrary.SOURCE_PROJECT).is_empty(), "GQM-02 asset library lists project asset with source")
	_assert_true(not _first_entry_by_source(mixed_entries, HexMapAssetLibrary.SOURCE_BUNDLED).is_empty(), "GQM-02 asset library keeps bundled source in integrated list")

	var bundled_path := String(bundled_entry.get("path", ""))
	var bundled_write := HexMapAssetLibrary.save(project_rules, "adjacency_rules", bundled_path)
	_assert_true(int(bundled_write.get("error", OK)) != OK, "GQM-02 asset library rejects bundled write target")

	ProjectSettings.set_setting(HexMapAssetLibrary.ASSET_ROOT_SETTING, root_b)
	var redirected_rules = HexAdjacencyRuleSet.from_dialog_dict({"default": 0.4, "rules": []}, "Redirected Rules")
	var redirected_result := HexMapAssetLibrary.save(redirected_rules, "adjacency_rules", "Redirected Rules")
	var redirected_path := String(redirected_result.get("path", ""))
	_assert_eq(int(redirected_result.get("error", FAILED)), OK, "GQM-02 asset library saves after root setting change")
	_assert_true(redirected_path.begins_with("%s/adjacency_rules/" % root_b), "GQM-02 asset library reflects changed project root")
	var redirected_entries := HexMapAssetLibrary.list("adjacency_rules")
	_assert_true(_find_entry(redirected_entries, project_path, HexMapAssetLibrary.SOURCE_PROJECT).is_empty(), "GQM-02 asset library stops listing previous project root after setting change")
	_assert_true(not _find_entry(redirected_entries, redirected_path, HexMapAssetLibrary.SOURCE_PROJECT).is_empty(), "GQM-02 asset library lists project asset from changed root")

	var duplicate_result := HexMapAssetLibrary.duplicate_to_project(bundled_path, "adjacency_rules", "Duplicated Rule")
	var duplicate_path := String(duplicate_result.get("path", ""))
	_assert_eq(int(duplicate_result.get("error", FAILED)), OK, "GQM-02 asset library duplicates bundled preset to project")
	_assert_true(duplicate_path.begins_with("%s/adjacency_rules/" % root_b), "GQM-02 duplicate lands in project layer")
	_assert_true(HexMapAssetLibrary.load(duplicate_path) is HexAdjacencyRuleSet, "GQM-02 duplicated adjacency rule set loads")

	var wrapper_path := HexAdjacencyRulePresets.preset_path_for_name("Wrapper Rules")
	var wrapper_rules = HexAdjacencyRuleSet.from_dialog_dict({"default": 0.15, "rules": []}, "Wrapper Rules")
	_assert_true(wrapper_path.begins_with("%s/adjacency_rules/" % root_b), "GQM-02 adjacency preset wrapper resolves project path")
	_assert_eq(HexAdjacencyRulePresets.save(wrapper_rules, wrapper_path), OK, "GQM-02 adjacency preset wrapper saves through asset library")
	_assert_true(HexAdjacencyRulePresets.load(wrapper_path) is HexAdjacencyRuleSet, "GQM-02 adjacency preset wrapper loads saved project asset")

	ProjectSettings.set_setting(HexMapAssetLibrary.ASSET_ROOT_SETTING, previous_setting)


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


func _test_graph_resource_v5_params_save_load_roundtrip() -> void:
	var graph := _sample_v5_graph()
	var resource = HexGenerationGraphResource.from_dict(graph)
	resource.graph_id = "gqm02_v5_roundtrip"
	resource.promote_targets = [{"node_id": "items", "role": "overlay"}]
	resource.semantics_snapshot = {"criteria_assets": "inline"}

	var path := _test_resource_path("gqm02_v5_generation_graph.tres")
	_assert_eq(ResourceSaver.save(resource, path), OK, "GQM-02 V5 graph resource saves")
	var loaded = ResourceLoader.load(path)
	_assert_true(loaded is HexGenerationGraphResource, "GQM-02 V5 graph resource reloads")
	var loaded_graph := (loaded as HexGenerationGraphResource).to_dict()
	_assert_graph_eq(loaded_graph, graph, "GQM-02 V5 save/load preserves graph params")
	var loaded_nodes := loaded_graph.get("nodes", {}) as Dictionary
	var connect_params := (loaded_nodes.get("connect", {}) as Dictionary).get("params", {}) as Dictionary
	_assert_true(bool(connect_params.get("toric_passage", false)), "GQM-02 V5 save/load preserves toric_passage")
	var wall_params := (loaded_nodes.get("walls", {}) as Dictionary).get("params", {}) as Dictionary
	_assert_dict_eq(wall_params.get("custom_distribution", {}) as Dictionary, _v5_custom_distribution(), "GQM-02 V5 save/load preserves custom_distribution dict")
	var item_params := (loaded_nodes.get("items", {}) as Dictionary).get("params", {}) as Dictionary
	_assert_dict_eq(item_params.get("probability_rules", {}) as Dictionary, _v5_probability_rules(), "GQM-02 V5 save/load preserves structured probability_rules")
	var item_pool := item_params.get("item_pool", []) as Array
	_assert_eq(int((item_pool[0] as Dictionary).get("limit", -1)), 3, "GQM-02 V5 save/load preserves item_pool limit")


func _test_item_pool_resource_save_load_roundtrip() -> void:
	var resource := HexItemPoolResource.new()
	resource.display_name = "Treasure Pool"
	resource.entries = [
		{"name": "coin", "weight": 0.75, "limit": 3},
		{"name": "key", "weight": 0.25, "limit": 1},
	]
	var path := _test_resource_path("gqm02_item_pool.tres")
	_assert_eq(ResourceSaver.save(resource, path), OK, "GQM-02 item pool resource saves")
	var loaded = ResourceLoader.load(path)
	_assert_true(loaded is HexItemPoolResource, "GQM-02 item pool resource reloads")
	_assert_eq(String((loaded as HexItemPoolResource).display_name), "Treasure Pool", "GQM-02 item pool preserves display_name")
	_assert_eq((loaded as HexItemPoolResource).entries.size(), 2, "GQM-02 item pool preserves entry count")
	_assert_eq(String(((loaded as HexItemPoolResource).entries[0] as Dictionary).get("name", "")), "coin", "GQM-02 item pool preserves entry name")
	_assert_eq(float(((loaded as HexItemPoolResource).entries[0] as Dictionary).get("weight", -1.0)), 0.75, "GQM-02 item pool preserves weight")
	_assert_eq(int(((loaded as HexItemPoolResource).entries[0] as Dictionary).get("limit", -1)), 3, "GQM-02 item pool preserves limit")


func _test_wall_distribution_resource_save_load_roundtrip() -> void:
	var resource = HexWallDistributionResource.from_preset(11)
	resource.display_name = "Ilands Custom"
	var path := _test_resource_path("gqm02_wall_distribution.tres")
	_assert_eq(ResourceSaver.save(resource, path), OK, "GQM-02 wall distribution resource saves")
	var loaded = ResourceLoader.load(path)
	_assert_true(loaded is HexWallDistributionResource, "GQM-02 wall distribution resource reloads")
	_assert_eq(String((loaded as HexWallDistributionResource).display_name), "Ilands Custom", "GQM-02 wall distribution preserves display_name")
	_assert_dict_eq((loaded as HexWallDistributionResource).weights_by_count, resource.weights_by_count, "GQM-02 wall distribution preserves weights_by_count")


func _test_wall_distribution_from_preset_matches_builtin() -> void:
	for distribution_id in [11, 20, 24]:
		var resource = HexWallDistributionResource.from_preset(distribution_id)
		_assert_array_float_eq((resource.weights_by_count.get("1", []) as Array), HexRandomizer.distribution1(distribution_id), "GQM-02 from_preset %d count 1" % distribution_id)
		_assert_array_float_eq((resource.weights_by_count.get("2", []) as Array), HexRandomizer.distribution2(distribution_id), "GQM-02 from_preset %d count 2" % distribution_id)
		_assert_array_float_eq((resource.weights_by_count.get("3", []) as Array), HexRandomizer.distribution3(distribution_id), "GQM-02 from_preset %d count 3" % distribution_id)
		_assert_array_float_eq((resource.weights_by_count.get("0", []) as Array), [0.0], "GQM-02 from_preset %d count 0" % distribution_id)


func _sample_graph() -> Dictionary:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle",
		"width": 7,
		"height": 4,
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


func _sample_v5_graph() -> Dictionary:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle",
		"width": 5,
		"height": 4,
	})
	HexGenerationGraph.add_node(graph, "walls", "wall_field", {
		"wall_method": "markov_mesh",
		"distribution_mode": "custom",
		"distribution_id": 24,
		"custom_distribution": _v5_custom_distribution(),
		"seed": 12,
	})
	HexGenerationGraph.add_node(graph, "connect", "connectivity", {
		"method": "sparse",
		"toric_passage": true,
		"seed": 34,
	})
	HexGenerationGraph.add_node(graph, "items", "item_generator", {
		"placement_method": "limited",
		"placement_probability": 0.9,
		"item_pool": [
			{"name": "ore", "weight": 0.6, "limit": 3},
			{"name": "relic", "weight": 0.4, "limit": 1},
		],
		"probability_rules": _v5_probability_rules(),
		"neighbor_radius": 2,
		"include_generated_reference": true,
		"seed": 56,
	})
	HexGenerationGraph.add_edge(graph, "shape", "walls", "in")
	HexGenerationGraph.add_edge(graph, "walls", "connect", "in")
	HexGenerationGraph.add_edge(graph, "connect", "items", "scope")
	return graph


func _v5_custom_distribution() -> Dictionary:
	return {
		"0": [1.0],
		"1": [2.0, 6.0],
		"2": [1.0, 3.0, 5.0, 7.0],
		"3": [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 8.0],
	}


func _v5_probability_rules() -> Dictionary:
	return {
		"name": "Structured Rules",
		"default": 0.2,
		"rules": [
			{
				"directions": ["1,0,0", "0,1,0"],
				"component_sizes": [1, 2],
				"probability": 0.85,
			},
		],
	}


func _test_resource_path(file_name: String) -> String:
	var run_id = OS.get_environment("HEX_MAP_TEST_RUN_ID")
	if run_id == "":
		run_id = "manual"
	var path = "res://.godot_user/test-runs/%s/test_generation_graph_resource/%s" % [run_id, file_name]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	return path


func _test_run_dir(dir_name: String) -> String:
	var run_id = OS.get_environment("HEX_MAP_TEST_RUN_ID")
	if run_id == "":
		run_id = "manual"
	var path = "res://.godot_user/test-runs/%s/test_generation_graph_resource/%s" % [run_id, dir_name]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
	return path


func _first_entry_by_source(entries: Array, source: String) -> Dictionary:
	for raw_entry in entries:
		if not raw_entry is Dictionary:
			continue
		var entry := raw_entry as Dictionary
		if String(entry.get("source", "")) == source:
			return entry
	return {}


func _find_entry(entries: Array, path: String, source: String = "") -> Dictionary:
	for raw_entry in entries:
		if not raw_entry is Dictionary:
			continue
		var entry := raw_entry as Dictionary
		if String(entry.get("path", "")) != path:
			continue
		if source != "" and String(entry.get("source", "")) != source:
			continue
		return entry
	return {}


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


func _assert_array_float_eq(actual: Array, expected: Array, message: String) -> void:
	_assert_eq(actual.size(), expected.size(), "%s size" % message)
	for index in range(min(actual.size(), expected.size())):
		_assert_eq(float(actual[index]), float(expected[index]), "%s index %d" % [message, index])
