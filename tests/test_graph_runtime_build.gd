extends SceneTree

const HexGenerationGraph = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexGenerationGraphRunner = preload("res://addons/hex_map_kit/generation/hex_generation_graph_runner.gd")
const HexMapGraphBuilder = preload("res://addons/hex_map_kit/generation/hex_map_graph_builder.gd")
const HexRuntimeGraphBuildSample = preload("res://examples/basic_runtime/runtime_graph_build_sample.gd")
const HexGenerationResultResource = preload("res://addons/hex_map_kit/adapter/hex_generation_result_resource.gd")
const HexGenerationGraphResource = preload("res://addons/hex_map_kit/adapter/hex_generation_graph_resource.gd")
const HexAdjacencyRuleSet = preload("res://addons/hex_map_kit/adapter/hex_adjacency_rule_set.gd")
const HexItemPoolResource = preload("res://addons/hex_map_kit/adapter/hex_item_pool_resource.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexOverlayData = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexWallDistributionResource = preload("res://addons/hex_map_kit/adapter/hex_wall_distribution_resource.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_same_seed_reproducible()
	_test_different_seed_changes_map()
	_test_saved_embed_graph_builds_without_external_reference()
	_test_reference_semantics_path_resolves_runtime_context()
	_test_unresolved_semantics_returns_error()
	_test_runtime_build_normalizes_legacy_graph_resource()
	_test_runtime_parity_inline_consolidated_graph()
	_test_runtime_parity_reference_asset_consolidated_graph()
	_test_runtime_path_has_no_editor_import()
	await _test_layer_build_from_graph_applies_map()

	if _failures.is_empty():
		print("test_graph_runtime_build.gd: all tests passed")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _test_same_seed_reproducible() -> void:
	var resource := _random_wall_graph_resource()
	var first := HexMapGraphBuilder.build(resource, {"seed": 41})
	var second := HexMapGraphBuilder.build(resource, {"seed": 41})
	_assert_true(bool(first["ok"]), "RUNTIME-50 first graph build succeeds")
	_assert_true(bool(second["ok"]), "RUNTIME-50 second graph build succeeds")
	_assert_eq(_map_signature(first["map_data"]), _map_signature(second["map_data"]), "RUNTIME-50 same graph and seed reproduce the same map")


func _test_different_seed_changes_map() -> void:
	var resource := _random_wall_graph_resource()
	var first := HexMapGraphBuilder.build(resource, {"seed": 51})
	var second := HexMapGraphBuilder.build(resource, {"seed": 52})
	_assert_true(bool(first["ok"]), "RUNTIME-50 seed A build succeeds")
	_assert_true(bool(second["ok"]), "RUNTIME-50 seed B build succeeds")
	_assert_true(_map_signature(first["map_data"]) != _map_signature(second["map_data"]), "RUNTIME-50 different seeds change random map walls")


func _test_saved_embed_graph_builds_without_external_reference() -> void:
	var resource := _random_wall_graph_resource()
	var path := _test_resource_path("runtime_embed_graph.tres")
	_assert_eq(ResourceSaver.save(resource, path), OK, "RUNTIME-50 embedded graph resource saves")
	var loaded = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	_assert_true(loaded is HexGenerationGraphResource, "RUNTIME-50 saved graph resource reloads")
	var result := HexMapGraphBuilder.build(loaded, {"seed": 63})
	_assert_true(bool(result["ok"]), "RUNTIME-50 saved embed graph builds without external .tres semantics")
	_assert_eq(String(result["semantics_source"]), "embed", "RUNTIME-50 saved graph uses embedded semantics")
	_assert_true(result["map_data"] is HexMapData, "RUNTIME-50 saved graph returns map data")

	var sample_result := HexRuntimeGraphBuildSample.build_random_map(63)
	_assert_true(bool(sample_result["ok"]), "RUNTIME-50 runtime sample builds a map")
	_assert_true(sample_result["map_data"] is HexMapData, "RUNTIME-50 runtime sample returns map data")


func _test_reference_semantics_path_resolves_runtime_context() -> void:
	var map_resource = HexMapResource.from_map_data(HexMapData.rectangle(3, 2))
	var path := _test_resource_path("runtime_reference_map.tres")
	_assert_eq(ResourceSaver.save(map_resource, path), OK, "RUNTIME-50 reference semantics resource saves")
	var graph_resource := _source_context_graph_resource()
	graph_resource.ownership_semantics = "reference"
	graph_resource.semantics_snapshot = {}
	graph_resource.semantics_reference_path = path

	var result := HexMapGraphBuilder.build(graph_resource, {"seed": 0})
	_assert_true(bool(result["ok"]), "RUNTIME-50 reference semantics path builds")
	_assert_eq(String(result["semantics_source"]), "reference", "RUNTIME-50 reference semantics source is reported")
	_assert_eq((result["map_data"] as HexMapData).cells.size(), 6, "RUNTIME-50 reference semantics supplies map data to Source node")


func _test_unresolved_semantics_returns_error() -> void:
	var graph_resource := _source_context_graph_resource()
	graph_resource.ownership_semantics = "reference"
	graph_resource.semantics_snapshot = {}
	graph_resource.semantics_reference_path = "res://missing_runtime_semantics.tres"

	var result := HexMapGraphBuilder.build(graph_resource, {"seed": 0})
	_assert_true(not bool(result["ok"]), "RUNTIME-50 unresolved semantics returns ok=false")
	_assert_eq(String((result["errors"] as Array)[0]["code"]), "semantics_unresolved", "RUNTIME-50 unresolved semantics is reported as an error")


func _test_runtime_build_normalizes_legacy_graph_resource() -> void:
	var resource := _legacy_runtime_result_graph_resource()
	var legacy_graph := resource.to_dict()
	var legacy_report := HexGenerationGraphRunner.run_with_report(legacy_graph, {"seed": 93})
	var runtime_result := HexMapGraphBuilder.build(resource, {"seed": 93})
	_assert_true(bool(legacy_report.get("ok", false)), "GQM-15 direct legacy runtime graph runs")
	_assert_true(bool(runtime_result.get("ok", false)), "GQM-15 runtime Map Build accepts legacy graph resource")
	var normalization_report := runtime_result.get("normalization_report", {}) as Dictionary
	_assert_true(bool(normalization_report.get("normalized", false)), "GQM-15 runtime result reports legacy normalization")
	_assert_true(String(runtime_result.get("status_text", "")).contains("normalized"), "GQM-15 runtime status mentions normalization")
	if bool(legacy_report.get("ok", false)) and bool(runtime_result.get("ok", false)):
		var legacy_result = (legacy_report["cache"] as Dictionary).get("result", null) as HexGenerationResultResource
		_assert_true(legacy_result is HexGenerationResultResource, "GQM-15 legacy runtime graph produces Result resource")
		if legacy_result is HexGenerationResultResource and legacy_result.primary_map != null:
			_assert_eq(
				_map_signature(runtime_result.get("map_data", null)),
				_map_signature(legacy_result.primary_map.to_map_data()),
				"GQM-15 runtime normalized terrain matches direct legacy Result substrate"
			)


func _test_runtime_parity_inline_consolidated_graph() -> void:
	var resource := _consolidated_runtime_parity_graph_resource(false)
	_assert_runtime_parity(resource, 91, "GQM-16 inline/embed consolidated graph")


func _test_runtime_parity_reference_asset_consolidated_graph() -> void:
	var resource := _consolidated_runtime_parity_graph_resource(true)
	_assert_runtime_parity(resource, 92, "GQM-16 reference asset consolidated graph")


func _test_runtime_path_has_no_editor_import() -> void:
	for path in [
		"res://addons/hex_map_kit/generation/hex_map_graph_builder.gd",
		"res://examples/basic_runtime/runtime_graph_build_sample.gd",
	]:
		var source := FileAccess.get_file_as_string(path)
		_assert_true(source.find("res://addons/hex_map_kit/editor") == -1, "RUNTIME-50 runtime file has no editor import: %s" % path)


func _test_layer_build_from_graph_applies_map() -> void:
	var layer := HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame

	var resource := _random_wall_graph_resource()
	var ok := layer.build_from_graph(resource, 77)
	_assert_true(ok, "RUNTIME-50 HexTileMapLayer.build_from_graph succeeds")
	_assert_eq(layer.generation_graph_resource, resource, "RUNTIME-50 layer keeps the graph resource reference")
	_assert_true(bool(layer.last_graph_build_result().get("ok", false)), "RUNTIME-50 layer exposes last graph build result")
	var applied = layer.to_map_resource().to_map_data()
	_assert_true(applied.cells.size() > 0, "RUNTIME-50 layer applies generated map cells")
	if layer.last_graph_build_result().has("map_data"):
		_assert_eq(_map_signature(applied), _map_signature(layer.last_graph_build_result()["map_data"]), "RUNTIME-50 applied layer map matches builder map")

	layer.queue_free()
	await process_frame


func _random_wall_graph_resource() -> HexGenerationGraphResource:
	var graph := HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle",
		"width": 12,
		"height": 8,
	})
	HexGenerationGraph.add_node(graph, "walls", "wall_field", {
		"wall_probability": 0.48,
	})
	HexGenerationGraph.add_edge(graph, "shape", "walls", "in")
	var resource := HexGenerationGraphResource.from_dict(graph)
	resource.graph_id = "runtime_wall_graph"
	resource.ownership_semantics = "embed"
	resource.semantics_snapshot = {"embed": true}
	resource.promote_targets = [{"node_id": "walls", "role": "terrain"}]
	return resource


func _legacy_runtime_result_graph_resource() -> HexGenerationGraphResource:
	var graph := HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle",
		"width": 6,
		"height": 4,
	})
	HexGenerationGraph.add_node(graph, "walls", "wall_field", {
		"wall_method": "random_probability",
		"wall_probability": 0.0,
		"seed": 31,
	})
	HexGenerationGraph.add_node(graph, "connect", "connectivity", {
		"method": "dense",
		"seed": 37,
	})
	HexGenerationGraph.add_node(graph, "result", "result")
	HexGenerationGraph.add_edge(graph, "shape", "walls", "in")
	HexGenerationGraph.add_edge(graph, "walls", "connect", "in")
	HexGenerationGraph.add_edge(graph, "connect", "result", "terrain")
	var resource := HexGenerationGraphResource.from_dict(graph)
	resource.graph_id = "gqm15_legacy_runtime_graph"
	resource.ownership_semantics = "embed"
	resource.semantics_snapshot = {"embed": true}
	resource.promote_targets = [{"node_id": "connect", "role": "terrain"}]
	return resource


func _consolidated_runtime_parity_graph_resource(reference_assets: bool) -> HexGenerationGraphResource:
	var terrain_params := {
		"base_mode": "shape",
		"shape": "square",
		"size": 4,
		"wall_method": "markov_mesh",
		"wall_probability": 0.0,
		"distribution_mode": "custom",
		"custom_distribution": _zero_custom_distribution(),
		"wall_seed": 3,
		"connectivity_method": "none",
	}
	var seed_params := {
		"placement_method": "weighted",
		"placement_probability": 1.0,
		"seed": 5,
		"item_pool": [{"name": "seed", "weight": 1.0, "limit": 4}],
	}
	var item_params := {
		"placement_method": "adjacency_rules",
		"item_name": "gem",
		"probability_rules": {"default": 1.0, "rules": []},
		"neighbor_radius": 1,
		"include_generated_reference": false,
		"seed": 7,
	}
	if reference_assets:
		terrain_params["distribution_mode"] = "preset"
		terrain_params["custom_distribution"] = _full_custom_distribution()
		terrain_params["distribution_asset_path"] = _save_wall_distribution_resource("runtime_parity_distribution.tres", _zero_custom_distribution())
		seed_params["item_pool"] = [{"name": "inline_seed", "weight": 1.0, "limit": 1}]
		seed_params["item_pool_asset_path"] = _save_item_pool_resource("runtime_parity_pool.tres", [{"name": "seed", "weight": 1.0, "limit": 4}])
		item_params["probability_rules"] = {"default": 0.0, "rules": []}
		item_params["rules_asset_path"] = _save_adjacency_rule_resource("runtime_parity_rules.tres", "default=1.0")

	var graph := HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "terrain", "terrain_generation", terrain_params)
	HexGenerationGraph.add_node(graph, "seed_items", "item_generation", seed_params)
	HexGenerationGraph.add_node(graph, "domain", "set_operation", {"operation": "intersection", "display_name": "item_domain"})
	HexGenerationGraph.add_node(graph, "items", "item_generation", item_params)
	HexGenerationGraph.add_node(graph, "result", "result")
	HexGenerationGraph.add_edge(graph, "terrain", "seed_items", "domain", "out", "floor")
	HexGenerationGraph.add_edge(graph, "terrain", "domain", "in_0", "out", "floor")
	HexGenerationGraph.add_edge(graph, "seed_items", "domain", "in_1", "out", "cells")
	HexGenerationGraph.add_edge(graph, "domain", "items", "domain")
	HexGenerationGraph.add_edge(graph, "terrain", "result", "in_0")
	HexGenerationGraph.add_edge(graph, "items", "result", "in_1")
	var resource := HexGenerationGraphResource.from_dict(graph)
	resource.graph_id = "gqm16_reference_parity" if reference_assets else "gqm16_inline_parity"
	resource.ownership_semantics = "embed"
	resource.semantics_snapshot = {"embed": true}
	resource.promote_targets = [
		{"node_id": "terrain", "role": "terrain"},
		{"node_id": "items", "role": "overlay"},
	]
	return resource


func _source_context_graph_resource() -> HexGenerationGraphResource:
	var graph := HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "input_map", "source", {
		"kind": "context",
		"source_key": "document_terrain",
		"output_type": "terrain",
	})
	var resource := HexGenerationGraphResource.from_dict(graph)
	resource.graph_id = "runtime_source_context_graph"
	resource.promote_targets = [{"node_id": "input_map", "role": "terrain"}]
	return resource


func _assert_runtime_parity(resource: HexGenerationGraphResource, seed: int, message: String) -> void:
	var editor_report := HexGenerationGraphRunner.run_with_report(resource.to_dict(), {"seed": seed})
	var runtime_result := HexMapGraphBuilder.build(resource, {"seed": seed})
	_assert_true(bool(editor_report["ok"]), "%s editor-side runner succeeds" % message)
	_assert_true(bool(runtime_result["ok"]), "%s runtime Map Build succeeds" % message)
	_assert_eq((editor_report.get("warnings", []) as Array).size(), 0, "%s editor-side runner has no warnings" % message)
	_assert_eq((runtime_result.get("warnings", []) as Array).size(), 0, "%s runtime Map Build has no warnings" % message)
	var editor_cache = editor_report["cache"] as Dictionary
	var editor_result = editor_cache["result"] as HexGenerationResultResource
	_assert_true(editor_result is HexGenerationResultResource, "%s editor runner produces Result resource" % message)
	if not (editor_result is HexGenerationResultResource):
		return
	_assert_true(editor_result.primary_map != null, "%s editor Result has a substrate map" % message)
	if editor_result.primary_map == null:
		return
	_assert_eq(_map_signature(runtime_result["map_data"]), _map_signature(editor_result.primary_map.to_map_data()), "%s promoted terrain matches Result substrate" % message)
	var runtime_overlays = runtime_result.get("overlays", []) as Array
	_assert_eq(runtime_overlays.size(), 1, "%s runtime promotes one overlay" % message)
	_assert_eq(editor_result.overlay_maps.size(), 1, "%s editor Result records one overlay" % message)
	if runtime_overlays.size() == 0 or editor_result.overlay_maps.size() == 0:
		return
	var runtime_overlay = (runtime_overlays[0] as Dictionary).get("data", null)
	_assert_true(runtime_overlay is HexOverlayData, "%s runtime promoted overlay is HexOverlayData" % message)
	if runtime_overlay is HexOverlayData:
		_assert_eq(_overlay_signature(runtime_overlay), _overlay_signature(editor_result.overlay_maps[0].to_overlay_data()), "%s promoted overlay matches Result overlay" % message)


func _map_signature(data) -> String:
	if not data is HexMapData:
		return "<missing>"
	return "%s|%s|%d" % [
		str(HexMapData.sorted_keys(data.cells)),
		str(HexMapData.sorted_keys(data.walls)),
		int(data.cyclic_size),
	]


func _overlay_signature(data) -> String:
	if not data is HexOverlayData:
		return "<missing>"
	var parts: Array = []
	for item_key in (data as HexOverlayData).item_keys():
		parts.append("%s=%s" % [String(item_key), str(HexMapData.sorted_keys((data as HexOverlayData).item_cells(String(item_key))))])
	return "%s|%s|%d" % [
		str(HexMapData.sorted_keys((data as HexOverlayData).cells)),
		";".join(parts),
		int((data as HexOverlayData).cyclic_size),
	]


func _zero_custom_distribution() -> Dictionary:
	return {
		"0": [0.0],
		"1": [0.0, 0.0],
		"2": [0.0, 0.0, 0.0, 0.0],
		"3": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
	}


func _full_custom_distribution() -> Dictionary:
	return {
		"0": [8.0],
		"1": [8.0, 8.0],
		"2": [8.0, 8.0, 8.0, 8.0],
		"3": [8.0, 8.0, 8.0, 8.0, 8.0, 8.0, 8.0, 8.0],
	}


func _save_wall_distribution_resource(file_name: String, weights: Dictionary) -> String:
	var resource := HexWallDistributionResource.new()
	resource.display_name = file_name.get_basename()
	resource.weights_by_count = weights.duplicate(true)
	var path := _test_resource_path(file_name)
	_assert_eq(ResourceSaver.save(resource, path), OK, "GQM-16 runtime wall distribution resource saves")
	return path


func _save_item_pool_resource(file_name: String, entries: Array) -> String:
	var resource := HexItemPoolResource.new()
	resource.display_name = file_name.get_basename()
	resource.entries = entries.duplicate(true)
	var path := _test_resource_path(file_name)
	_assert_eq(ResourceSaver.save(resource, path), OK, "GQM-16 runtime item pool resource saves")
	return path


func _save_adjacency_rule_resource(file_name: String, rules_text: String) -> String:
	var resource := HexAdjacencyRuleSet.new()
	resource.display_name = file_name.get_basename()
	resource.rules_text = rules_text
	var path := _test_resource_path(file_name)
	_assert_eq(ResourceSaver.save(resource, path), OK, "GQM-16 runtime adjacency rule resource saves")
	return path


func _test_resource_path(file_name: String) -> String:
	var run_id = OS.get_environment("HEX_MAP_TEST_RUN_ID")
	if run_id == "":
		run_id = "manual"
	var path = "res://.godot_user/test-runs/%s/test_graph_runtime_build/%s" % [run_id, file_name]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	return path


func _assert_eq(actual, expected, message: String) -> void:
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)
