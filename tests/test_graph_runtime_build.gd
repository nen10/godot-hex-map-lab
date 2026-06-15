extends SceneTree

const HexGenerationGraph = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexMapGraphBuilder = preload("res://addons/hex_map_kit/generation/hex_map_graph_builder.gd")
const HexRuntimeGraphBuildSample = preload("res://examples/basic_runtime/runtime_graph_build_sample.gd")
const HexGenerationGraphResource = preload("res://addons/hex_map_kit/adapter/hex_generation_graph_resource.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
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


func _map_signature(data) -> String:
	if not data is HexMapData:
		return "<missing>"
	return "%s|%s|%d" % [
		str(HexMapData.sorted_keys(data.cells)),
		str(HexMapData.sorted_keys(data.walls)),
		int(data.cyclic_size),
	]


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
