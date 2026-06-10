extends SceneTree

const HexUILayoutMetricEvaluator = preload("res://addons/hex_map_kit/editor/testing/hex_ui_layout_metric_evaluator.gd")
const HexUILayoutSnapshotCollector = preload("res://addons/hex_map_kit/editor/testing/hex_ui_layout_snapshot_collector.gd")
const HexUIStateScenarioBuilder = preload("res://addons/hex_map_kit/editor/testing/hex_ui_state_scenario_builder.gd")
const REPORT_SCHEMA := "hex_ui_layout_metric_report.v1"
const P0_SCHEMA := "hex_ui_layout_p0_gate_report.v1"
const P1_SCHEMA := "hex_ui_layout_p1_gate_report.v1"
const REQUIRED_CATEGORIES := [
	"text_truncation",
	"resource_row_geometry",
	"scroll_reachability",
	"dead_area",
	"debug_leakage",
	"no_op_action",
	"picker_specificity",
	"state_contradiction",
]
const P0_CATEGORIES := [
	"no_op_action",
	"scroll_reachability",
	"state_contradiction",
	"sample_fallback_production",
	"debug_leakage",
	"picker_specificity",
	"unreachable_primary_action",
]
const P1_CATEGORIES := [
	"resource_row_geometry",
	"text_truncation",
	"dead_area",
	"disabled_action_without_tooltip",
	"summary_only_task_tab",
]

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_synthetic_snapshot_reports_required_warn_categories()
	_test_report_serializes_to_json()
	_test_p0_gate_reports_required_fail_categories()
	_test_p0_gate_clean_snapshot_passes()
	_test_p0_report_serializes_to_json()
	_test_p1_gate_reports_required_issue_categories()
	_test_p1_gate_clean_snapshot_passes()
	_test_p1_report_serializes_to_json()
	await _test_runtime_workspace_snapshot_is_warn_only()
	_finish()


func _test_synthetic_snapshot_reports_required_warn_categories() -> void:
	var report := HexUILayoutMetricEvaluator.evaluate(_synthetic_risk_snapshot(), {
		"expected_state_id": "no_selected_hex_tile_map",
		"require_scroll": true,
	})
	_assert_eq(String(report["schema"]), REPORT_SCHEMA, "metric report schema")
	_assert_true(int(report["warning_count"]) >= REQUIRED_CATEGORIES.size(), "metric report has warnings")
	for category in REQUIRED_CATEGORIES:
		_assert_true(_category_count(report, String(category)) > 0, "metric report category %s" % category)
	for warning in report["warnings"] as Array:
		_assert_eq(String((warning as Dictionary).get("severity", "")), "warn", "all metric findings are warn severity")


func _test_report_serializes_to_json() -> void:
	var report := HexUILayoutMetricEvaluator.evaluate(_synthetic_risk_snapshot(), {
		"expected_state_id": "no_selected_hex_tile_map",
	})
	var json_text := HexUILayoutMetricEvaluator.report_to_json(report)
	var parsed = JSON.parse_string(json_text)
	_assert_true(parsed is Dictionary, "metric report serializes to JSON dictionary")
	_assert_eq(String((parsed as Dictionary).get("schema", "")), REPORT_SCHEMA, "serialized report schema survives")


func _test_p0_gate_reports_required_fail_categories() -> void:
	var report := HexUILayoutMetricEvaluator.evaluate_p0(_synthetic_p0_risk_snapshot(), {
		"expected_state_id": "no_selected_hex_tile_map",
		"require_scroll": true,
		"production_mode": true,
	})
	_assert_eq(String(report["schema"]), P0_SCHEMA, "P0 report schema")
	_assert_eq(bool(report["passed"]), false, "P0 report fails risk snapshot")
	_assert_true(int(report["failure_count"]) >= P0_CATEGORIES.size(), "P0 report has failures")
	for category in P0_CATEGORIES:
		_assert_true(_category_count(report, String(category)) > 0, "P0 report category %s" % category)
	for failure in report["failures"] as Array:
		_assert_eq(String((failure as Dictionary).get("severity", "")), "p0", "P0 finding severity")


func _test_p0_gate_clean_snapshot_passes() -> void:
	var report := HexUILayoutMetricEvaluator.evaluate_p0(_synthetic_p0_clean_snapshot(), {
		"expected_state_id": "ready",
		"require_scroll": true,
		"production_mode": true,
	})
	_assert_eq(String(report["schema"]), P0_SCHEMA, "clean P0 report schema")
	_assert_eq(bool(report["passed"]), true, "clean P0 report passes")
	_assert_eq(int(report["failure_count"]), 0, "clean P0 report has no failures")


func _test_p0_report_serializes_to_json() -> void:
	var report := HexUILayoutMetricEvaluator.evaluate_p0(_synthetic_p0_risk_snapshot(), {
		"expected_state_id": "no_selected_hex_tile_map",
	})
	var json_text := HexUILayoutMetricEvaluator.p0_report_to_json(report)
	var parsed = JSON.parse_string(json_text)
	_assert_true(parsed is Dictionary, "P0 report serializes to JSON dictionary")
	_assert_eq(String((parsed as Dictionary).get("schema", "")), P0_SCHEMA, "serialized P0 report schema survives")


func _test_p1_gate_reports_required_issue_categories() -> void:
	var report := HexUILayoutMetricEvaluator.evaluate_p1(_synthetic_p1_risk_snapshot(), {
		"expected_state_id": "ready",
		"require_scroll": true,
	})
	_assert_eq(String(report["schema"]), P1_SCHEMA, "P1 report schema")
	_assert_eq(bool(report["passed"]), false, "P1 report fails risk snapshot")
	_assert_true(int(report["issue_count"]) >= P1_CATEGORIES.size(), "P1 report has issues")
	for category in P1_CATEGORIES:
		_assert_true(_category_count(report, String(category)) > 0, "P1 report category %s" % category)
	for issue in report["issues"] as Array:
		_assert_eq(String((issue as Dictionary).get("severity", "")), "p1", "P1 issue severity")


func _test_p1_gate_clean_snapshot_passes() -> void:
	var report := HexUILayoutMetricEvaluator.evaluate_p1(_synthetic_p1_clean_snapshot(), {
		"expected_state_id": "ready",
		"require_scroll": true,
	})
	_assert_eq(String(report["schema"]), P1_SCHEMA, "clean P1 report schema")
	_assert_eq(bool(report["passed"]), true, "clean P1 report passes")
	_assert_eq(int(report["issue_count"]), 0, "clean P1 report has no issues")


func _test_p1_report_serializes_to_json() -> void:
	var report := HexUILayoutMetricEvaluator.evaluate_p1(_synthetic_p1_risk_snapshot(), {
		"expected_state_id": "ready",
	})
	var json_text := HexUILayoutMetricEvaluator.p1_report_to_json(report)
	var parsed = JSON.parse_string(json_text)
	_assert_true(parsed is Dictionary, "P1 report serializes to JSON dictionary")
	_assert_eq(String((parsed as Dictionary).get("schema", "")), P1_SCHEMA, "serialized P1 report schema survives")


func _test_runtime_workspace_snapshot_is_warn_only() -> void:
	var scenario := HexUIStateScenarioBuilder.create_workspace_scenario(
		HexUIStateScenarioBuilder.SCENARIO_SELECTED_WITH_RESOURCES,
		Vector2i(960, 720)
	)
	root.add_child(scenario["root"])
	await process_frame
	HexUIStateScenarioBuilder.apply_workspace_state(scenario)
	await process_frame
	var snapshot := HexUILayoutSnapshotCollector.collect(scenario["workspace"] as Control, {
		"scenario_id": scenario["scenario_id"],
		"viewport_size": scenario["viewport_size"],
	})
	var report := HexUILayoutMetricEvaluator.evaluate(snapshot, {
		"expected_state_id": scenario["scenario_id"],
	})
	_assert_eq(String(report["severity"]), "warn", "runtime report is warn-only")
	_assert_true(int(report["warning_count"]) >= 0, "runtime report warning count is nonnegative")
	for warning in report["warnings"] as Array:
		_assert_eq(String((warning as Dictionary).get("severity", "")), "warn", "runtime finding is warn severity")
	HexUIStateScenarioBuilder.free_workspace_scenario(scenario)
	await process_frame


func _synthetic_risk_snapshot() -> Dictionary:
	var controls := [
		_control(".", "Root", "Control", 0, 0, 1000, 800, 0, 0, "", {}, "", ""),
		_control("TruncatedLabel", "TruncatedLabel", "Label", 10, 10, 80, 16, 180, 16, "Resource readiness summary", {}, "", ""),
		_control("ResourceRow", "ResourceRow", "HBoxContainer", 10, 40, 90, 24, 220, 24, "", {
			"hex_metric_role": "resource_row",
			"line_count": 3,
		}, "", ""),
		_control("DebugLabel", "DebugLabel", "Label", 10, 75, 120, 16, 120, 16, "Debug raw JSON fallback res://asset.tres", {}, "", ""),
		_control("NoOpButton", "NoOpButton", "Button", 10, 105, 80, 24, 80, 24, "Details", {
			"hex_metric_action": "noop",
		}, "", ""),
		_control("ResourcePicker", "ResourcePicker", "EditorResourcePicker", 10, 140, 120, 28, 180, 28, "", {}, "Resource", ""),
		_control("Contradiction", "Contradiction", "Label", 10, 175, 120, 16, 120, 16, "Ready", {
			"hex_metric_state_id": "ready",
		}, "", ""),
	]
	return {
		"schema": "hex_ui_layout_snapshot.v1",
		"scenario_id": "synthetic_risk_snapshot",
		"viewport_size": {"x": 1000, "y": 800},
		"root_class": "Control",
		"root_name": "Root",
		"control_count": controls.size(),
		"controls": controls,
	}


func _synthetic_p0_risk_snapshot() -> Dictionary:
	var snapshot := _synthetic_risk_snapshot()
	var controls := snapshot["controls"] as Array
	controls.append(_control("SampleSource", "SampleSource", "Label", 10, 210, 160, 16, 160, 16, "Bundled sample selected", {
		"hex_metric_source": "sample",
		"hex_metric_production_required": true,
	}, "", ""))
	controls.append(_control("PrimaryAction", "PrimaryAction", "Button", 10, 240, 120, 24, 120, 24, "Apply", {
		"hex_metric_primary_action": true,
		"action_reachable": false,
		"action_bound": true,
	}, "", ""))
	snapshot["control_count"] = controls.size()
	return snapshot


func _synthetic_p0_clean_snapshot() -> Dictionary:
	var controls := [
		_control(".", "Root", "Control", 0, 0, 640, 480, 0, 0, "", {}, "", ""),
		_control("Scroll", "Scroll", "ScrollContainer", 0, 0, 640, 480, 0, 0, "", {}, "", ""),
		_control("ReadyLabel", "ReadyLabel", "Label", 12, 12, 160, 24, 120, 24, "Ready", {
			"hex_metric_state_id": "ready",
		}, "", "Scroll"),
		_control("PrimaryAction", "PrimaryAction", "Button", 12, 48, 120, 24, 120, 24, "Apply", {
			"hex_metric_primary_action": true,
			"action_reachable": true,
			"action_bound": true,
		}, "", "Scroll"),
		_control("ConcretePicker", "ConcretePicker", "EditorResourcePicker", 12, 84, 220, 28, 180, 28, "", {}, "HexMapDocumentResource", "Scroll"),
	]
	return {
		"schema": "hex_ui_layout_snapshot.v1",
		"scenario_id": "synthetic_p0_clean_snapshot",
		"viewport_size": {"x": 640, "y": 480},
		"root_class": "Control",
		"root_name": "Root",
		"control_count": controls.size(),
		"controls": controls,
	}


func _synthetic_p1_risk_snapshot() -> Dictionary:
	var controls := [
		_control(".", "Root", "Control", 0, 0, 1000, 800, 0, 0, "", {}, "", ""),
		_control("Scroll", "Scroll", "ScrollContainer", 0, 0, 1000, 800, 0, 0, "", {}, "", ""),
		_control("TruncatedLabel", "TruncatedLabel", "Label", 10, 10, 80, 16, 180, 16, "Readiness summary", {}, "", "Scroll"),
		_control("ResourceRow", "ResourceRow", "HBoxContainer", 10, 40, 90, 24, 220, 24, "", {
			"hex_metric_role": "resource_row",
			"line_count": 3,
		}, "", "Scroll"),
		_control("SmallContent", "SmallContent", "PanelContainer", 10, 80, 120, 80, 120, 80, "", {}, "", "Scroll"),
		_control("DisabledAction", "DisabledAction", "Button", 10, 180, 120, 24, 120, 24, "Export", {
			"hex_metric_disabled": true,
			"action_bound": true,
		}, "", "Scroll"),
		_control("SummaryTab", "SummaryTab", "VBoxContainer", 10, 220, 140, 60, 140, 60, "Summary", {
			"hex_metric_tab_role": "task_tab",
			"hex_metric_summary_only": true,
		}, "", "Scroll"),
	]
	return {
		"schema": "hex_ui_layout_snapshot.v1",
		"scenario_id": "synthetic_p1_risk_snapshot",
		"viewport_size": {"x": 1000, "y": 800},
		"root_class": "Control",
		"root_name": "Root",
		"control_count": controls.size(),
		"controls": controls,
	}


func _synthetic_p1_clean_snapshot() -> Dictionary:
	var controls := [
		_control(".", "Root", "Control", 0, 0, 640, 480, 0, 0, "", {}, "", ""),
		_control("Scroll", "Scroll", "ScrollContainer", 0, 0, 640, 480, 0, 0, "", {}, "", ""),
		_control("WorkSurface", "WorkSurface", "PanelContainer", 0, 0, 640, 480, 0, 0, "", {}, "", "Scroll"),
		_control("ReadyLabel", "ReadyLabel", "Label", 12, 12, 180, 24, 120, 24, "Ready", {
			"hex_metric_state_id": "ready",
		}, "", "Scroll"),
		_control("DisabledAction", "DisabledAction", "Button", 12, 48, 120, 24, 120, 24, "Export", {
			"hex_metric_disabled": true,
			"action_bound": true,
		}, "", "Scroll"),
	]
	controls[4]["tooltip"] = "Choose a destination first."
	return {
		"schema": "hex_ui_layout_snapshot.v1",
		"scenario_id": "synthetic_p1_clean_snapshot",
		"viewport_size": {"x": 640, "y": 480},
		"root_class": "Control",
		"root_name": "Root",
		"control_count": controls.size(),
		"controls": controls,
	}


func _control(
	control_path: String,
	control_name: String,
	control_class: String,
	x: float,
	y: float,
	w: float,
	h: float,
	min_w: float,
	min_h: float,
	text: String,
	metadata: Dictionary,
	base_type: String,
	scroll_parent: String
) -> Dictionary:
	return {
		"path": control_path,
		"name": control_name,
		"class": control_class,
		"script": "",
		"visible": true,
		"rect": {"x": x, "y": y, "w": w, "h": h},
		"minimum_size": {"x": min_w, "y": min_h},
		"text": text,
		"base_type": base_type,
		"tooltip": "",
		"scroll_parent": scroll_parent,
		"metadata": metadata,
	}


func _category_count(report: Dictionary, category: String) -> int:
	var counts := report["category_counts"] as Dictionary
	return int(counts.get(category, 0))


func _finish() -> void:
	if _failures.is_empty():
		print("test_workspace_layout_metric_evaluator.gd: all tests passed")
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
