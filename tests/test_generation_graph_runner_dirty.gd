extends SceneTree

const HexGenerationGraph = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexGenerationGraphRunner = preload("res://addons/hex_map_kit/generation/hex_generation_graph_runner.gd")

var _failures: Array[String] = []


class InterruptRecorder:
	var progress_events: Array = []
	var cancel_phase_prefix := ""

	func progress(status: Dictionary) -> void:
		progress_events.append(status.duplicate(true))

	func cancel(status: Dictionary) -> bool:
		return cancel_phase_prefix != "" and String(status.get("phase", "")).begins_with(cancel_phase_prefix)


func _init() -> void:
	_run()


func _run() -> void:
	_test_dirty_run_reuses_upstream_cache()
	_test_cancelled_run_keeps_partial_cache_uncommitted()
	_test_weighted_progress_estimator_and_events()

	if _failures.is_empty():
		print("test_generation_graph_runner_dirty.gd: all tests passed")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _test_dirty_run_reuses_upstream_cache() -> void:
	var graph := _three_node_graph()
	var first = HexGenerationGraphRunner.run_with_report(graph)
	_assert_true(bool(first["ok"]), "GRAPH-13 initial runner pass succeeds")
	_assert_packed_eq(first["recomputed_node_ids"], ["shape", "walls", "connect"], "GRAPH-13 initial run computes all nodes")
	_assert_packed_eq(first["reused_node_ids"], [], "GRAPH-13 initial run reuses no cache")

	var second = HexGenerationGraphRunner.run_with_report(graph, {
		"previous_cache": first["cache"],
		"dirty_node_ids": PackedStringArray(["walls"]),
	})
	_assert_true(bool(second["ok"]), "GRAPH-13 dirty runner pass succeeds")
	_assert_packed_eq(second["reused_node_ids"], ["shape"], "GRAPH-13 dirty run reuses clean upstream cache")
	_assert_packed_eq(second["recomputed_node_ids"], ["walls", "connect"], "GRAPH-13 dirty run recomputes dirty node and downstream")

	var third = HexGenerationGraphRunner.run_with_report(graph, {
		"previous_cache": second["cache"],
		"dirty_node_ids": PackedStringArray(["connect"]),
	})
	_assert_true(bool(third["ok"]), "GRAPH-13 downstream-only dirty pass succeeds")
	_assert_packed_eq(third["reused_node_ids"], ["shape", "walls"], "GRAPH-13 downstream dirty run reuses upstream nodes")
	_assert_packed_eq(third["recomputed_node_ids"], ["connect"], "GRAPH-13 downstream dirty run recomputes only requested node")


func _test_cancelled_run_keeps_partial_cache_uncommitted() -> void:
	var graph := _three_node_graph()
	var recorder := InterruptRecorder.new()
	recorder.cancel_phase_prefix = "random_walls"
	var interrupt_options := {
		"chunk_size": 1,
		"progress_callback": Callable(recorder, "progress"),
		"cancel_callback": Callable(recorder, "cancel"),
	}
	var report = HexGenerationGraphRunner.run_with_report(graph, {"interrupt_options": interrupt_options})
	_assert_true(not bool(report["ok"]), "GRAPH-13 cancelled runner pass is not ok")
	_assert_true(bool(report["cancelled"]), "GRAPH-13 runner reports cancellation")
	_assert_true(bool(interrupt_options.get("cancelled", false)), "GRAPH-13 interrupt options record cancellation")
	_assert_true(recorder.progress_events.size() > 0, "GRAPH-13 runner/node run emits progress")
	_assert_true((report["cache"] as Dictionary).is_empty(), "GRAPH-13 committed cache stays empty after cancelled first run")
	_assert_true((report["partial_cache"] as Dictionary).has("walls"), "GRAPH-13 partial cache records in-flight node separately")


func _test_weighted_progress_estimator_and_events() -> void:
	var large_input := {"in": {"cells": 6561}}
	var sparse_work := HexGenerationGraphRunner.estimated_work_for_node({
		"type": "connectivity",
		"params": {"method": "sparse"},
	}, large_input)
	var dense_work := HexGenerationGraphRunner.estimated_work_for_node({
		"type": "connectivity",
		"params": {"method": "dense"},
	}, large_input)
	var random_wall_work := HexGenerationGraphRunner.estimated_work_for_node({
		"type": "wall_field",
		"params": {"wall_method": "random_probability"},
	}, large_input)
	var markov_work := HexGenerationGraphRunner.estimated_work_for_node({
		"type": "wall_field",
		"params": {"wall_method": "markov_mesh"},
	}, large_input)
	var random_item_work := HexGenerationGraphRunner.estimated_work_for_node({
		"type": "item_generator",
		"params": {"placement_method": "weighted"},
	}, {"scope": {"cells": 1600}})
	var adjacency_item_work := HexGenerationGraphRunner.estimated_work_for_node({
		"type": "item_generator",
		"params": {"placement_method": "adjacency_rules", "neighbor_radius": 3},
	}, {"scope": {"cells": 1600}})

	_assert_true(sparse_work > dense_work, "GRAPH-PROGRESS sparse connectivity is weighted above dense connectivity")
	_assert_true(dense_work > markov_work, "GRAPH-PROGRESS dense connectivity remains above Markov mesh for equal cell count")
	_assert_true(markov_work > random_wall_work, "GRAPH-PROGRESS Markov mesh is weighted above random walls")
	_assert_true(adjacency_item_work > random_item_work, "GRAPH-PROGRESS adjacency item generation is weighted above random items")

	var graph := _three_node_graph()
	var recorder := InterruptRecorder.new()
	var report = HexGenerationGraphRunner.run_with_report(graph, {
		"interrupt_options": {
			"chunk_size": 1,
			"progress_callback": Callable(recorder, "progress"),
		},
	})
	_assert_true(bool(report["ok"]), "GRAPH-PROGRESS weighted progress graph run succeeds")
	_assert_true(recorder.progress_events.size() > 0, "GRAPH-PROGRESS weighted progress emits events")
	var previous := -0.001
	var saw_core_event := false
	for event in recorder.progress_events:
		var progress := float((event as Dictionary).get("progress", 0.0))
		_assert_true(progress + 0.0001 >= previous, "GRAPH-PROGRESS emitted progress is monotonic")
		previous = progress
		_assert_eq(String((event as Dictionary).get("progress_model", "")), "estimated_work", "GRAPH-PROGRESS event declares estimated-work model")
		if not String((event as Dictionary).get("phase", "")).begins_with("graph_node_"):
			saw_core_event = true
			_assert_true((event as Dictionary).has("graph_progress"), "GRAPH-PROGRESS core event exposes graph progress")
			_assert_true((event as Dictionary).has("core_progress"), "GRAPH-PROGRESS core event preserves node-local progress")
	_assert_true(saw_core_event, "GRAPH-PROGRESS runner maps core progress events")


func _three_node_graph() -> Dictionary:
	var graph = HexGenerationGraph.new_graph()
	HexGenerationGraph.add_node(graph, "shape", "shape", {
		"shape": "rectangle",
		"width": 8,
		"height": 6,
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


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual, expected, message: String) -> void:
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _assert_packed_eq(actual, expected: Array, message: String) -> void:
	var actual_array: Array = []
	for value in actual:
		actual_array.append(String(value))
	if actual_array.size() != expected.size():
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual_array)])
		return
	for index in range(expected.size()):
		if String(actual_array[index]) != String(expected[index]):
			_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual_array)])
			return
