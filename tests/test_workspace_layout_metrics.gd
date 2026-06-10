extends SceneTree

const HexUILayoutSnapshotCollector = preload("res://addons/hex_map_kit/editor/testing/hex_ui_layout_snapshot_collector.gd")
const HexUIStateScenarioBuilder = preload("res://addons/hex_map_kit/editor/testing/hex_ui_state_scenario_builder.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await _test_snapshot_collects_visible_control_fields()
	await _test_snapshot_serializes_to_json()
	await _test_snapshot_collects_multiple_scenarios_and_sizes()
	_finish()


func _test_snapshot_collects_visible_control_fields() -> void:
	var scenario := HexUIStateScenarioBuilder.create_workspace_scenario(
		HexUIStateScenarioBuilder.SCENARIO_NO_SELECTED,
		Vector2i(960, 720)
	)
	root.add_child(scenario["root"])
	await process_frame
	HexUIStateScenarioBuilder.apply_workspace_state(scenario)
	await process_frame
	var workspace = scenario["workspace"] as Control
	var snapshot := HexUILayoutSnapshotCollector.collect(workspace, {
		"scenario_id": scenario["scenario_id"],
		"viewport_size": scenario["viewport_size"],
	})
	var controls = snapshot["controls"] as Array
	_assert_true(controls.size() > 0, "layout snapshot collects visible controls")
	var root_control = controls[0] as Dictionary
	_assert_true(root_control.has("rect"), "control snapshot has rect")
	_assert_true(root_control.has("minimum_size"), "control snapshot has minimum size")
	_assert_true(root_control.has("text"), "control snapshot has text field")
	_assert_true(root_control.has("base_type"), "control snapshot has base_type field")
	_assert_true(root_control.has("tooltip"), "control snapshot has tooltip field")
	_assert_true(root_control.has("scroll_parent"), "control snapshot has scroll parent field")
	_assert_true(root_control.has("metadata"), "control snapshot has metadata field")
	_assert_true(_has_scroll_parent(controls), "at least one visible control records a ScrollContainer parent")
	_assert_true(_has_visible_text(controls, "No HexTileMap selected"), "snapshot captures selected target text")
	HexUIStateScenarioBuilder.free_workspace_scenario(scenario)
	await process_frame


func _test_snapshot_serializes_to_json() -> void:
	var scenario := HexUIStateScenarioBuilder.create_workspace_scenario(
		HexUIStateScenarioBuilder.SCENARIO_SELECTED_NO_RESOURCES,
		Vector2i(800, 560)
	)
	root.add_child(scenario["root"])
	await process_frame
	HexUIStateScenarioBuilder.apply_workspace_state(scenario)
	await process_frame
	var snapshot := HexUILayoutSnapshotCollector.collect(scenario["workspace"] as Control, {
		"scenario_id": scenario["scenario_id"],
		"viewport_size": scenario["viewport_size"],
	})
	var json_text := HexUILayoutSnapshotCollector.snapshot_to_json(snapshot)
	var parsed = JSON.parse_string(json_text)
	_assert_true(parsed is Dictionary, "layout snapshot serializes to JSON dictionary")
	_assert_eq(String((parsed as Dictionary).get("scenario_id", "")), HexUIStateScenarioBuilder.SCENARIO_SELECTED_NO_RESOURCES, "serialized scenario id survives")
	HexUIStateScenarioBuilder.free_workspace_scenario(scenario)
	await process_frame


func _test_snapshot_collects_multiple_scenarios_and_sizes() -> void:
	var scenarios := PackedStringArray([
		HexUIStateScenarioBuilder.SCENARIO_NO_SELECTED,
		HexUIStateScenarioBuilder.SCENARIO_SELECTED_NO_RESOURCES,
		HexUIStateScenarioBuilder.SCENARIO_SELECTED_WITH_RESOURCES,
	])
	var sizes := [
		Vector2i(640, 480),
		Vector2i(960, 720),
	]
	for scenario_id in scenarios:
		for size in sizes:
			var scenario := HexUIStateScenarioBuilder.create_workspace_scenario(String(scenario_id), size)
			root.add_child(scenario["root"])
			await process_frame
			HexUIStateScenarioBuilder.apply_workspace_state(scenario)
			await process_frame
			var snapshot := HexUILayoutSnapshotCollector.collect(scenario["workspace"] as Control, {
				"scenario_id": scenario["scenario_id"],
				"viewport_size": scenario["viewport_size"],
			})
			_assert_eq(String(snapshot["scenario_id"]), String(scenario_id), "snapshot records scenario id")
			_assert_eq(int((snapshot["viewport_size"] as Dictionary)["x"]), size.x, "snapshot records viewport width")
			_assert_true(int(snapshot["control_count"]) > 0, "snapshot records visible controls for %s" % scenario_id)
			HexUIStateScenarioBuilder.free_workspace_scenario(scenario)
			await process_frame


func _has_scroll_parent(controls: Array) -> bool:
	for entry in controls:
		var control = entry as Dictionary
		if String(control.get("scroll_parent", "")) != "":
			return true
	return false


func _has_visible_text(controls: Array, text: String) -> bool:
	for entry in controls:
		var control = entry as Dictionary
		if String(control.get("text", "")).find(text) >= 0:
			return true
	return false


func _finish() -> void:
	if _failures.is_empty():
		print("test_workspace_layout_metrics.gd: all tests passed")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])
