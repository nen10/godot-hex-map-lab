extends SceneTree

const HexUILayoutMetricEvaluator = preload("res://addons/hex_map_kit/editor/testing/hex_ui_layout_metric_evaluator.gd")
const HexUILayoutSnapshotCollector = preload("res://addons/hex_map_kit/editor/testing/hex_ui_layout_snapshot_collector.gd")
const HexUIStateScenarioBuilder = preload("res://addons/hex_map_kit/editor/testing/hex_ui_state_scenario_builder.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await _test_workspace_metric_gate_writes_reports()
	_finish()


func _test_workspace_metric_gate_writes_reports() -> void:
	var output_dir := _metric_output_dir()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var run_report := await _collect_run_report()
	var json_path := "%s/workspace_layout_metrics.json" % output_dir
	var markdown_path := "%s/workspace_layout_metrics.md" % output_dir
	_write_text(json_path, JSON.stringify(run_report, "\t"))
	_write_text(markdown_path, _markdown_report(run_report))
	_assert_true(FileAccess.file_exists(json_path), "metric JSON report is written")
	_assert_true(FileAccess.file_exists(markdown_path), "metric Markdown report is written")
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(json_path))
	_assert_true(parsed is Dictionary, "metric JSON report parses")
	_assert_eq(int(run_report["total_p0_failures"]), 0, "P0 metric gate has zero failures; see %s" % markdown_path)


func _collect_run_report() -> Dictionary:
	var records: Array[Dictionary] = []
	var total_p0_failures := 0
	var total_p1_issues := 0
	var scenarios := [
		{
			"scenario_id": HexUIStateScenarioBuilder.SCENARIO_NO_SELECTED,
			"viewport_size": Vector2i(640, 480),
		},
		{
			"scenario_id": HexUIStateScenarioBuilder.SCENARIO_SELECTED_NO_RESOURCES,
			"viewport_size": Vector2i(960, 720),
		},
		{
			"scenario_id": HexUIStateScenarioBuilder.SCENARIO_SELECTED_WITH_RESOURCES,
			"viewport_size": Vector2i(960, 720),
		},
	]
	for scenario_config in scenarios:
		var scenario_id := String(scenario_config["scenario_id"])
		var viewport_size := scenario_config["viewport_size"] as Vector2i
		var scenario := HexUIStateScenarioBuilder.create_workspace_scenario(scenario_id, viewport_size)
		root.add_child(scenario["root"])
		await process_frame
		HexUIStateScenarioBuilder.apply_workspace_state(scenario)
		await process_frame
		var snapshot := HexUILayoutSnapshotCollector.collect(scenario["workspace"] as Control, {
			"scenario_id": scenario["scenario_id"],
			"viewport_size": scenario["viewport_size"],
		})
		var options := {
			"expected_state_id": scenario_id,
			"require_scroll": true,
			"production_mode": true,
		}
		var p0_report := HexUILayoutMetricEvaluator.evaluate_p0(snapshot, options)
		var p1_report := HexUILayoutMetricEvaluator.evaluate_p1(snapshot, options)
		total_p0_failures += int(p0_report["failure_count"])
		total_p1_issues += int(p1_report["issue_count"])
		records.append({
			"scenario_id": scenario_id,
			"viewport_size": _vector2i_dict(viewport_size),
			"control_count": int(snapshot["control_count"]),
			"p0": p0_report,
			"p1": p1_report,
		})
		HexUIStateScenarioBuilder.free_workspace_scenario(scenario)
		await process_frame
	return {
		"schema": "hex_ui_metric_run_report.v1",
		"run_id": _test_run_id(),
		"total_p0_failures": total_p0_failures,
		"total_p1_issues": total_p1_issues,
		"records": records,
	}


func _markdown_report(report: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append("# Workspace UI Metric Report")
	lines.append("")
	lines.append("- run_id: `%s`" % String(report["run_id"]))
	lines.append("- total_p0_failures: `%d`" % int(report["total_p0_failures"]))
	lines.append("- total_p1_issues: `%d`" % int(report["total_p1_issues"]))
	lines.append("")
	lines.append("| scenario | viewport | controls | P0 failures | P1 issues |")
	lines.append("|---|---:|---:|---:|---:|")
	for record in report["records"] as Array:
		var entry := record as Dictionary
		var viewport := entry["viewport_size"] as Dictionary
		lines.append("| `%s` | %dx%d | %d | %d | %d |" % [
			String(entry["scenario_id"]),
			int(viewport["x"]),
			int(viewport["y"]),
			int(entry["control_count"]),
			int((entry["p0"] as Dictionary)["failure_count"]),
			int((entry["p1"] as Dictionary)["issue_count"]),
		])
	lines.append("")
	lines.append("## P0 Failures")
	var found_failure := false
	for record in report["records"] as Array:
		var entry := record as Dictionary
		var p0 := entry["p0"] as Dictionary
		for failure in p0["failures"] as Array:
			found_failure = true
			var item := failure as Dictionary
			lines.append("- `%s` `%s` %s: %s" % [
				String(entry["scenario_id"]),
				String(item.get("category", "")),
				String(item.get("path", "")),
				String(item.get("message", "")),
			])
	if not found_failure:
		lines.append("- none")
	lines.append("")
	lines.append("## P1 Issues")
	var found_issue := false
	for record in report["records"] as Array:
		var entry := record as Dictionary
		var p1 := entry["p1"] as Dictionary
		for issue in p1["issues"] as Array:
			found_issue = true
			var item := issue as Dictionary
			lines.append("- `%s` `%s` %s: %s" % [
				String(entry["scenario_id"]),
				String(item.get("category", "")),
				String(item.get("path", "")),
				String(item.get("message", "")),
			])
	if not found_issue:
		lines.append("- none")
	var text := ""
	for line in lines:
		text += "%s\n" % line
	return text


func _write_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_failures.append("Cannot write %s: error %s" % [path, str(FileAccess.get_open_error())])
		return
	file.store_string(text)
	file.close()


func _metric_output_dir() -> String:
	return "res://.godot_user/ui-metrics/%s" % _safe_path_part(_test_run_id())


func _test_run_id() -> String:
	var run_id := OS.get_environment("HEX_MAP_TEST_RUN_ID")
	return "manual" if run_id.is_empty() else run_id


func _safe_path_part(value: String) -> String:
	var result := ""
	for index in value.length():
		var character := value[index]
		if character.is_valid_identifier() or character.is_valid_int() or character in ["-", "_"]:
			result += character
		else:
			result += "_"
	return result


func _vector2i_dict(value: Vector2i) -> Dictionary:
	return {
		"x": value.x,
		"y": value.y,
	}


func _finish() -> void:
	if _failures.is_empty():
		print("test_workspace_layout_metric_gate.gd: all tests passed")
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
