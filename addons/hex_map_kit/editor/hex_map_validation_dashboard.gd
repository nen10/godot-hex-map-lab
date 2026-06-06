@tool
class_name HexMapValidationDashboard
extends VBoxContainer

signal validate_requested
signal issue_selected(issue: Dictionary, index: int)

var _validate_button: Button
var _summary_label: Label
var _issue_list: ItemList
var _result = null
var _summary: Dictionary = {}
var _issue_rows: Array[Dictionary] = []
var _selected_issue: Dictionary = {}


func _ready() -> void:
	_build_ui()
	clear_result()


func set_validate_enabled(enabled: bool, reason: String = "") -> void:
	_build_ui()
	if _validate_button == null:
		return
	_validate_button.disabled = not enabled
	_validate_button.tooltip_text = "" if enabled else reason


func clear_result(message: String = "Not validated.") -> void:
	_result = null
	_summary = {
		"issues": 0,
		"errors": 0,
		"warnings": 0,
		"infos": 0,
		"groups": 0,
		"message": message,
	}
	_issue_rows.clear()
	_selected_issue.clear()
	_refresh_view()


func set_validation_result(result) -> void:
	_build_ui()
	_result = result
	_issue_rows = _rows_from_result(result)
	_summary = {
		"issues": _issue_rows.size(),
		"errors": result.error_count() if result != null and result.has_method("error_count") else 0,
		"warnings": result.warning_count() if result != null and result.has_method("warning_count") else 0,
		"infos": result.info_count() if result != null and result.has_method("info_count") else 0,
		"groups": _group_keys(_issue_rows).size(),
		"message": "Validation complete.",
	}
	_selected_issue.clear()
	_refresh_view()


func validation_summary() -> Dictionary:
	return _summary.duplicate(true)


func issue_rows() -> Array[Dictionary]:
	return _issue_rows.duplicate(true)


func selected_issue() -> Dictionary:
	return _selected_issue.duplicate(true)


func select_issue(index: int) -> bool:
	_build_ui()
	if index < 0 or index >= _issue_rows.size():
		return false
	if _issue_list != null:
		_issue_list.select(index)
	_on_issue_selected(index)
	return true


func _build_ui() -> void:
	if _validate_button != null:
		return
	var title = Label.new()
	title.text = "Validation"
	add_child(title)

	var action_row = HBoxContainer.new()
	add_child(action_row)
	_validate_button = Button.new()
	_validate_button.text = "Validate"
	_validate_button.pressed.connect(_on_validate_pressed)
	action_row.add_child(_validate_button)

	_summary_label = Label.new()
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_row.add_child(_summary_label)

	_issue_list = ItemList.new()
	_issue_list.custom_minimum_size = Vector2(0, 88)
	_issue_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_issue_list.item_selected.connect(_on_issue_selected)
	add_child(_issue_list)


func _refresh_view() -> void:
	if _summary_label != null:
		_summary_label.text = "%s issues=%d errors=%d warnings=%d groups=%d" % [
			String(_summary.get("message", "")),
			int(_summary.get("issues", 0)),
			int(_summary.get("errors", 0)),
			int(_summary.get("warnings", 0)),
			int(_summary.get("groups", 0)),
		]
	if _issue_list == null:
		return
	_issue_list.clear()
	for row in _issue_rows:
		_issue_list.add_item(String(row.get("label", "")))
		var index = _issue_list.item_count - 1
		_issue_list.set_item_metadata(index, row.get("issue", {}).duplicate(true))


func _rows_from_result(result) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	if result == null:
		return rows
	var issues = result.get("issues") if result is Object else []
	if not issues is Array:
		return rows
	for issue_value in issues:
		if not issue_value is Dictionary:
			continue
		var issue := (issue_value as Dictionary).duplicate(true)
		var group_key = _issue_group_key(issue)
		rows.append({
			"group_key": group_key,
			"severity": String(issue.get("severity", "")),
			"scope": String(issue.get("scope", "")),
			"rule_id": String(issue.get("rule_id", "")),
			"cell": issue.get("cell", Vector3i.ZERO),
			"label": _issue_label(issue, group_key),
			"issue": issue,
		})
	rows.sort_custom(Callable(HexMapValidationDashboard, "_sort_issue_rows"))
	return rows


static func _sort_issue_rows(a: Dictionary, b: Dictionary) -> bool:
	var a_key = "%s|%s|%s|%s" % [
		_severity_sort_prefix(String(a.get("severity", ""))),
		String(a.get("scope", "")),
		String(a.get("rule_id", "")),
		str(a.get("cell", Vector3i.ZERO)),
	]
	var b_key = "%s|%s|%s|%s" % [
		_severity_sort_prefix(String(b.get("severity", ""))),
		String(b.get("scope", "")),
		String(b.get("rule_id", "")),
		str(b.get("cell", Vector3i.ZERO)),
	]
	return a_key < b_key


static func _severity_sort_prefix(severity: String) -> String:
	match severity:
		"error":
			return "0-error"
		"warning":
			return "1-warning"
		"info":
			return "2-info"
		_:
			return "3-%s" % severity


func _group_keys(rows: Array[Dictionary]) -> Dictionary:
	var groups := {}
	for row in rows:
		groups[String(row.get("group_key", ""))] = true
	return groups


func _issue_group_key(issue: Dictionary) -> String:
	return "%s/%s/%s" % [
		String(issue.get("severity", "")),
		String(issue.get("scope", "")),
		String(issue.get("rule_id", "")),
	]


func _issue_label(issue: Dictionary, group_key: String) -> String:
	var cell_text = ""
	var cell = issue.get("cell", null)
	if cell is Vector3i:
		cell_text = " cell=(%d,%d,%d)" % [cell.x, cell.y, cell.z]
	var message = String(issue.get("message", ""))
	return "%s%s %s" % [group_key, cell_text, message]


func _on_validate_pressed() -> void:
	validate_requested.emit()


func _on_issue_selected(index: int) -> void:
	if index < 0 or index >= _issue_rows.size():
		return
	_selected_issue = (_issue_rows[index].get("issue", {}) as Dictionary).duplicate(true)
	issue_selected.emit(_selected_issue.duplicate(true), index)
