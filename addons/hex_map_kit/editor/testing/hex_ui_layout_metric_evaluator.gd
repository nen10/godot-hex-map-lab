@tool
class_name HexUILayoutMetricEvaluator
extends RefCounted

const SCHEMA := "hex_ui_layout_metric_report.v1"
const P0_SCHEMA := "hex_ui_layout_p0_gate_report.v1"
const SEVERITY_WARN := "warn"
const SEVERITY_P0 := "p0"

const CATEGORY_TEXT_TRUNCATION := "text_truncation"
const CATEGORY_RESOURCE_ROW_GEOMETRY := "resource_row_geometry"
const CATEGORY_SCROLL_REACHABILITY := "scroll_reachability"
const CATEGORY_DEAD_AREA := "dead_area"
const CATEGORY_DEBUG_LEAKAGE := "debug_leakage"
const CATEGORY_NO_OP_ACTION := "no_op_action"
const CATEGORY_PICKER_SPECIFICITY := "picker_specificity"
const CATEGORY_STATE_CONTRADICTION := "state_contradiction"
const CATEGORY_SAMPLE_FALLBACK_PRODUCTION := "sample_fallback_production"
const CATEGORY_UNREACHABLE_PRIMARY_ACTION := "unreachable_primary_action"

const REQUIRED_CATEGORIES := [
	CATEGORY_TEXT_TRUNCATION,
	CATEGORY_RESOURCE_ROW_GEOMETRY,
	CATEGORY_SCROLL_REACHABILITY,
	CATEGORY_DEAD_AREA,
	CATEGORY_DEBUG_LEAKAGE,
	CATEGORY_NO_OP_ACTION,
	CATEGORY_PICKER_SPECIFICITY,
	CATEGORY_STATE_CONTRADICTION,
]

const P0_CATEGORIES := [
	CATEGORY_NO_OP_ACTION,
	CATEGORY_SCROLL_REACHABILITY,
	CATEGORY_STATE_CONTRADICTION,
	CATEGORY_SAMPLE_FALLBACK_PRODUCTION,
	CATEGORY_DEBUG_LEAKAGE,
	CATEGORY_PICKER_SPECIFICITY,
	CATEGORY_UNREACHABLE_PRIMARY_ACTION,
]

const P0_PROMOTED_WARN_CATEGORIES := [
	CATEGORY_NO_OP_ACTION,
	CATEGORY_SCROLL_REACHABILITY,
	CATEGORY_STATE_CONTRADICTION,
	CATEGORY_DEBUG_LEAKAGE,
	CATEGORY_PICKER_SPECIFICITY,
]

const DEBUG_TEXT_PATTERNS := [
	"debug",
	"raw",
	"json",
	"private",
	"fallback",
	"mirror",
	"node path",
	"source id",
	"atlas source",
	"atlas coord",
	"res://",
	"/root/",
]

const PLACEHOLDER_ACTION_TEXT := [
	"details",
	"open",
	"select",
	"validate",
	"link",
	"node",
	"sample",
	"clear",
]


static func evaluate(snapshot: Dictionary, options: Dictionary = {}) -> Dictionary:
	var controls := _controls(snapshot)
	var warnings: Array[Dictionary] = []
	_evaluate_text_truncation(controls, warnings, options)
	_evaluate_resource_rows(controls, warnings, options)
	_evaluate_scroll_reachability(controls, warnings, options)
	_evaluate_dead_area(snapshot, controls, warnings, options)
	_evaluate_debug_leakage(controls, warnings)
	_evaluate_no_op_actions(controls, warnings)
	_evaluate_picker_specificity(controls, warnings)
	_evaluate_state_contradictions(controls, warnings, options)
	return {
		"schema": SCHEMA,
		"snapshot_schema": String(snapshot.get("schema", "")),
		"scenario_id": String(snapshot.get("scenario_id", "unspecified")),
		"severity": SEVERITY_WARN,
		"warning_count": warnings.size(),
		"category_counts": _category_counts(warnings),
		"warnings": warnings,
	}


static func report_to_json(report: Dictionary) -> String:
	return JSON.stringify(report, "\t")


static func evaluate_p0(snapshot: Dictionary, options: Dictionary = {}) -> Dictionary:
	var warning_report := evaluate(snapshot, options)
	var controls := _controls(snapshot)
	var failures: Array[Dictionary] = []
	for warning in warning_report["warnings"] as Array:
		var entry := warning as Dictionary
		var category := String(entry.get("category", ""))
		if P0_PROMOTED_WARN_CATEGORIES.has(category):
			_add_failure(
				failures,
				category,
				String(entry.get("path", "")),
				String(entry.get("message", "")),
				String(entry.get("evidence", ""))
			)
	_evaluate_sample_fallback_production(controls, failures, options)
	_evaluate_unreachable_primary_actions(controls, failures)
	return {
		"schema": P0_SCHEMA,
		"snapshot_schema": String(snapshot.get("schema", "")),
		"scenario_id": String(snapshot.get("scenario_id", "unspecified")),
		"passed": failures.is_empty(),
		"failure_count": failures.size(),
		"category_counts": _category_counts(failures),
		"failures": failures,
		"warning_report": warning_report,
	}


static func p0_report_to_json(report: Dictionary) -> String:
	return JSON.stringify(report, "\t")


static func _evaluate_text_truncation(
	controls: Array,
	warnings: Array[Dictionary],
	options: Dictionary
) -> void:
	var tolerance := float(options.get("truncation_tolerance", 1.0))
	for control in controls:
		var entry := control as Dictionary
		var text := String(entry.get("text", ""))
		if text.strip_edges().is_empty():
			continue
		var rect := _rect(entry.get("rect", {}))
		var minimum := _vector2(entry.get("minimum_size", {}))
		if rect.size.x + tolerance < minimum.x:
			_add_warning(
				warnings,
				CATEGORY_TEXT_TRUNCATION,
				_path(entry),
				"Visible text control is narrower than its combined minimum width.",
				"%s rect_w=%.2f min_w=%.2f" % [text, rect.size.x, minimum.x]
			)


static func _evaluate_resource_rows(
	controls: Array,
	warnings: Array[Dictionary],
	options: Dictionary
) -> void:
	var min_width := float(options.get("min_resource_row_width", 180.0))
	var max_lines := int(options.get("max_resource_row_lines", 2))
	for control in controls:
		var entry := control as Dictionary
		var metadata := _metadata(entry)
		if String(metadata.get("hex_metric_role", "")) != "resource_row":
			continue
		var rect := _rect(entry.get("rect", {}))
		var line_count := int(metadata.get("line_count", 1))
		if rect.size.x < min_width:
			_add_warning(
				warnings,
				CATEGORY_RESOURCE_ROW_GEOMETRY,
				_path(entry),
				"Resource row is narrower than the minimum usable width.",
				"width=%.2f min=%.2f" % [rect.size.x, min_width]
			)
		if line_count > max_lines:
			_add_warning(
				warnings,
				CATEGORY_RESOURCE_ROW_GEOMETRY,
				_path(entry),
				"Resource row uses more lines than compact layout allows.",
				"lines=%d max=%d" % [line_count, max_lines]
			)


static func _evaluate_scroll_reachability(
	controls: Array,
	warnings: Array[Dictionary],
	options: Dictionary
) -> void:
	if not bool(options.get("require_scroll", true)):
		return
	if _has_scroll_evidence(controls):
		return
	_add_warning(
		warnings,
		CATEGORY_SCROLL_REACHABILITY,
		".",
		"Snapshot has no visible ScrollContainer evidence.",
		"require_scroll=true"
	)


static func _evaluate_dead_area(
	snapshot: Dictionary,
	controls: Array,
	warnings: Array[Dictionary],
	options: Dictionary
) -> void:
	var threshold := float(options.get("max_dead_area_ratio", 0.55))
	var viewport := _vector2(snapshot.get("viewport_size", {}))
	var viewport_area = maxf(1.0, viewport.x * viewport.y)
	var has_bounds := false
	var bounds := Rect2()
	for control in controls:
		var entry := control as Dictionary
		if _path(entry) == ".":
			continue
		var rect := _rect(entry.get("rect", {}))
		if rect.size.x <= 0.0 or rect.size.y <= 0.0:
			continue
		if not has_bounds:
			bounds = rect
			has_bounds = true
		else:
			bounds = bounds.merge(rect)
	var occupied_area := 0.0 if not has_bounds else bounds.size.x * bounds.size.y
	var dead_area_ratio = clampf(1.0 - (occupied_area / viewport_area), 0.0, 1.0)
	if dead_area_ratio > threshold:
		_add_warning(
			warnings,
			CATEGORY_DEAD_AREA,
			".",
			"Visible controls occupy too little of the viewport.",
			"dead_area_ratio=%.3f threshold=%.3f" % [dead_area_ratio, threshold]
		)


static func _evaluate_debug_leakage(controls: Array, warnings: Array[Dictionary]) -> void:
	for control in controls:
		var entry := control as Dictionary
		var text := String(entry.get("text", ""))
		if text.strip_edges().is_empty():
			continue
		var lower := text.to_lower()
		for pattern in DEBUG_TEXT_PATTERNS:
			if lower.find(String(pattern)) >= 0:
				_add_warning(
					warnings,
					CATEGORY_DEBUG_LEAKAGE,
					_path(entry),
					"Visible text contains debug/internal wording.",
					text
				)
				break


static func _evaluate_no_op_actions(controls: Array, warnings: Array[Dictionary]) -> void:
	for control in controls:
		var entry := control as Dictionary
		if String(entry.get("class", "")) != "Button":
			continue
		var metadata := _metadata(entry)
		var action_state := String(metadata.get("hex_metric_action", ""))
		var text := String(entry.get("text", ""))
		if action_state == "noop":
			_add_warning(
				warnings,
				CATEGORY_NO_OP_ACTION,
				_path(entry),
				"Visible button is marked as a no-op action.",
				text
			)
			continue
		if bool(metadata.get("action_bound", false)):
			continue
		var normalized := text.strip_edges().to_lower().trim_suffix("...").strip_edges()
		if PLACEHOLDER_ACTION_TEXT.has(normalized):
			_add_warning(
				warnings,
				CATEGORY_NO_OP_ACTION,
				_path(entry),
				"Visible button uses placeholder-like action text without binding evidence.",
				text
			)


static func _evaluate_picker_specificity(controls: Array, warnings: Array[Dictionary]) -> void:
	for control in controls:
		var entry := control as Dictionary
		if String(entry.get("class", "")) != "EditorResourcePicker":
			continue
		var base_type := String(entry.get("base_type", ""))
		if base_type == "" or base_type == "Resource":
			_add_warning(
				warnings,
				CATEGORY_PICKER_SPECIFICITY,
				_path(entry),
				"Required Resource picker is missing a concrete base type.",
				"base_type=%s" % (base_type if base_type != "" else "<empty>")
			)


static func _evaluate_state_contradictions(
	controls: Array,
	warnings: Array[Dictionary],
	options: Dictionary
) -> void:
	var expected_state_id := String(options.get("expected_state_id", ""))
	if expected_state_id.is_empty():
		return
	for control in controls:
		var entry := control as Dictionary
		var metadata := _metadata(entry)
		var control_state_id := String(metadata.get("hex_metric_state_id", ""))
		if control_state_id.is_empty() or control_state_id == expected_state_id:
			continue
		_add_warning(
			warnings,
			CATEGORY_STATE_CONTRADICTION,
			_path(entry),
			"Control state metadata contradicts expected scenario state.",
			"expected=%s actual=%s text=%s" % [
				expected_state_id,
				control_state_id,
				String(entry.get("text", "")),
			]
		)


static func _evaluate_sample_fallback_production(
	controls: Array,
	failures: Array[Dictionary],
	options: Dictionary
) -> void:
	if not bool(options.get("production_mode", true)):
		return
	for control in controls:
		var entry := control as Dictionary
		var metadata := _metadata(entry)
		if String(metadata.get("hex_metric_source", "")) != "sample":
			continue
		if not bool(metadata.get("hex_metric_production_required", false)):
			continue
		_add_failure(
			failures,
			CATEGORY_SAMPLE_FALLBACK_PRODUCTION,
			_path(entry),
			"Sample source is being used as production completion evidence.",
			String(entry.get("text", ""))
		)


static func _evaluate_unreachable_primary_actions(
	controls: Array,
	failures: Array[Dictionary]
) -> void:
	for control in controls:
		var entry := control as Dictionary
		if String(entry.get("class", "")) != "Button":
			continue
		var metadata := _metadata(entry)
		if not bool(metadata.get("hex_metric_primary_action", false)):
			continue
		if bool(metadata.get("action_reachable", true)):
			continue
		_add_failure(
			failures,
			CATEGORY_UNREACHABLE_PRIMARY_ACTION,
			_path(entry),
			"Primary action is visible but unreachable from the current UI state.",
			String(entry.get("text", ""))
		)


static func _add_failure(
	failures: Array[Dictionary],
	category: String,
	path: String,
	message: String,
	evidence: String
) -> void:
	failures.append({
		"category": category,
		"severity": SEVERITY_P0,
		"path": path,
		"message": message,
		"evidence": evidence,
	})


static func _add_warning(
	warnings: Array[Dictionary],
	category: String,
	path: String,
	message: String,
	evidence: String
) -> void:
	warnings.append({
		"category": category,
		"severity": SEVERITY_WARN,
		"path": path,
		"message": message,
		"evidence": evidence,
	})


static func _category_counts(warnings: Array) -> Dictionary:
	var counts := {}
	for warning in warnings:
		var entry := warning as Dictionary
		var category := String(entry.get("category", "unknown"))
		counts[category] = int(counts.get(category, 0)) + 1
	return counts


static func _controls(snapshot: Dictionary) -> Array:
	var value = snapshot.get("controls", [])
	return value if value is Array else []


static func _metadata(control: Dictionary) -> Dictionary:
	var value = control.get("metadata", {})
	return value if value is Dictionary else {}


static func _path(control: Dictionary) -> String:
	return String(control.get("path", ""))


static func _has_scroll_evidence(controls: Array) -> bool:
	for control in controls:
		var entry := control as Dictionary
		if String(entry.get("class", "")) == "ScrollContainer":
			return true
		if String(entry.get("scroll_parent", "")) != "":
			return true
	return false


static func _rect(value: Variant) -> Rect2:
	if value is Rect2:
		return value
	if value is Dictionary:
		var dict := value as Dictionary
		return Rect2(
			float(dict.get("x", 0.0)),
			float(dict.get("y", 0.0)),
			float(dict.get("w", 0.0)),
			float(dict.get("h", 0.0))
		)
	return Rect2()


static func _vector2(value: Variant) -> Vector2:
	if value is Vector2:
		return value
	if value is Vector2i:
		return Vector2(value)
	if value is Dictionary:
		var dict := value as Dictionary
		return Vector2(float(dict.get("x", 0.0)), float(dict.get("y", 0.0)))
	return Vector2.ZERO
