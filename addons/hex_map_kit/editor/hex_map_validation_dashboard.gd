@tool
class_name HexMapValidationDashboard
extends VBoxContainer

signal validate_requested
signal issue_selected(issue: Dictionary, index: int)

var _validate_button: Button
var _summary_label: Label
var _issue_list: ItemList
var _selected_detail_label: Label
var _result = null
var _summary: Dictionary = {}
var _issue_rows: Array[Dictionary] = []
var _selected_issue: Dictionary = {}
var _selected_row: Dictionary = {}


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
		"domains": 0,
		"message": message,
	}
	_issue_rows.clear()
	_selected_issue.clear()
	_selected_row.clear()
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
		"domains": _domain_keys(_issue_rows).size(),
		"message": "Validation complete.",
	}
	_selected_issue.clear()
	_selected_row.clear()
	_refresh_view()


func validation_summary() -> Dictionary:
	return _summary.duplicate(true)


func issue_rows() -> Array[Dictionary]:
	return _issue_rows.duplicate(true)


func selected_issue() -> Dictionary:
	return _selected_issue.duplicate(true)


func selected_issue_row() -> Dictionary:
	return _selected_row.duplicate(true)


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

	_selected_detail_label = Label.new()
	_selected_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_selected_detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(_selected_detail_label)


func _refresh_view() -> void:
	if _summary_label != null:
		_summary_label.text = "%s issues=%d errors=%d warnings=%d domains=%d" % [
			String(_summary.get("message", "")),
			int(_summary.get("issues", 0)),
			int(_summary.get("errors", 0)),
			int(_summary.get("warnings", 0)),
			int(_summary.get("domains", 0)),
		]
	if _issue_list == null:
		return
	_issue_list.clear()
	for row in _issue_rows:
		_issue_list.add_item(String(row.get("label", "")))
		var index = _issue_list.item_count - 1
		_issue_list.set_item_metadata(index, row.duplicate(true))
	if _selected_detail_label != null:
		if _issue_rows.is_empty():
			_selected_detail_label.text = "No validation issues."
		elif _selected_row.is_empty():
			_selected_detail_label.text = "Select an issue to see focus and fix suggestion."
		else:
			_selected_detail_label.text = _selected_detail_text(_selected_row)


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
		var domain = issue_domain(issue)
		var severity_label = issue_severity_label(issue)
		var focus_target = issue_focus_target(issue)
		var fix_suggestion = issue_fix_suggestion(issue)
		rows.append({
			"group_key": group_key,
			"rule_group_key": _issue_rule_group_key(issue),
			"domain": domain,
			"severity": String(issue.get("severity", "")),
			"severity_label": severity_label,
			"scope": String(issue.get("scope", "")),
			"rule_id": String(issue.get("rule_id", "")),
			"cell": issue.get("cell", Vector3i.ZERO),
			"focus_target": focus_target,
			"fix_suggestion": fix_suggestion,
			"label": _issue_label(issue, group_key),
			"issue": issue,
		})
	rows.sort_custom(Callable(HexMapValidationDashboard, "_sort_issue_rows"))
	return rows


static func _sort_issue_rows(a: Dictionary, b: Dictionary) -> bool:
	var a_key = "%s|%s|%s|%s" % [
		_severity_sort_prefix(String(a.get("severity", ""))),
		String(a.get("domain", "")),
		String(a.get("rule_id", "")),
		str(a.get("cell", Vector3i.ZERO)),
	]
	var b_key = "%s|%s|%s|%s" % [
		_severity_sort_prefix(String(b.get("severity", ""))),
		String(b.get("domain", "")),
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


func _domain_keys(rows: Array[Dictionary]) -> Dictionary:
	var domains := {}
	for row in rows:
		domains[String(row.get("domain", ""))] = true
	return domains


func _issue_group_key(issue: Dictionary) -> String:
	return "%s/%s" % [
		issue_domain(issue),
		issue_severity_label(issue),
	]


func _issue_rule_group_key(issue: Dictionary) -> String:
	return "%s/%s/%s" % [
		String(issue.get("severity", "")),
		String(issue.get("scope", "")),
		String(issue.get("rule_id", "")),
	]


func _issue_label(issue: Dictionary, group_key: String) -> String:
	return "%s | %s | %s | %s" % [
		group_key,
		String(issue.get("rule_id", "")),
		issue_focus_target(issue),
		issue_fix_suggestion(issue),
	]


func _selected_detail_text(row: Dictionary) -> String:
	return "%s %s\nFocus: %s\nFix: %s" % [
		String(row.get("severity_label", "")),
		String(row.get("domain", "")),
		String(row.get("focus_target", "")),
		String(row.get("fix_suggestion", "")),
	]


static func issue_domain(issue: Dictionary) -> String:
	var rule_id = String(issue.get("rule_id", ""))
	var scope = String(issue.get("scope", ""))
	var metadata = _issue_metadata(issue)
	if rule_id.begins_with("catalog.") or metadata.has("entry_index") or metadata.has("entry_key"):
		return "Catalog"
	if rule_id.begins_with("movement.") or metadata.has("profile_id"):
		return "Gameplay"
	if rule_id.contains("package"):
		return "Package"
	if scope == "layer" or rule_id.contains(".layer"):
		return "Layer"
	if scope == "object" or rule_id.contains(".object_") or String(issue.get("object_id", "")) != "":
		return "Object"
	if rule_id.contains("catalog") or metadata.has("catalog_key"):
		return "Catalog"
	if scope == "dependency":
		match String(metadata.get("kind", "")):
			"tile_catalog", "tile_set":
				return "Catalog"
			"object_database", "scene":
				return "Object"
			_:
				return "Document"
	return "Document"


static func issue_severity_label(issue: Dictionary) -> String:
	match String(issue.get("severity", "")):
		"error":
			return "Error"
		"warning":
			return "Warning"
		"info":
			return "Info"
		_:
			return "Issue"


static func issue_focus_target(issue: Dictionary) -> String:
	var metadata = _issue_metadata(issue)
	if metadata.has("entry_index"):
		return "Catalog entry #%d" % int(metadata.get("entry_index", -1))
	var entry_key = String(metadata.get("entry_key", ""))
	if entry_key != "":
		return "Catalog entry %s" % entry_key
	var catalog_key = String(metadata.get("catalog_key", ""))
	if catalog_key != "":
		return "Catalog key %s" % catalog_key
	var scope = String(issue.get("scope", ""))
	var cell = issue.get("cell", null)
	if (scope == "cell" or scope == "object") and cell is Vector3i:
		return "Cell (%d,%d,%d)" % [cell.x, cell.y, cell.z]
	var object_id = String(issue.get("object_id", ""))
	if object_id != "":
		return "Object %s" % object_id
	var dependency_path = String(issue.get("dependency_resource_path", ""))
	if dependency_path != "":
		return "Resource %s" % dependency_path
	var dependency_id = String(metadata.get("dependency_id", ""))
	if dependency_id != "":
		return "Dependency %s" % dependency_id
	var role = String(metadata.get("role", ""))
	if role != "":
		return "Dependency role %s" % role
	var kind = String(metadata.get("kind", ""))
	if kind != "":
		return "Dependency kind %s" % kind
	if scope == "layer":
		return "Layer"
	return issue_domain(issue)


static func issue_fix_suggestion(issue: Dictionary) -> String:
	var rule_id = String(issue.get("rule_id", ""))
	if rule_id == "document.map_missing":
		return "Create or open a document with map cells."
	if rule_id == "document.payload_outside_map":
		return "Move the payload inside the map or remove it."
	if rule_id == "document.orphan_payload":
		return "Move the payload onto an existing map cell or remove it."
	if rule_id == "document.catalog_missing":
		return "Select a tile catalog resource for this document."
	if rule_id == "document.tile_assignment_missing":
		return "Assign a catalog key in the Catalog or Paint controls."
	if rule_id == "document.tile_missing":
		return "Fix the catalog entry or TileSet resource for the referenced key."
	if rule_id == "document.dependency_missing":
		return "Assign the required dependency resource."
	if rule_id == "document.dependency_type_mismatch":
		return "Replace the dependency with a resource matching its kind."
	if rule_id == "document.object_on_wall":
		return "Move the object to a floor cell or change the terrain."
	if rule_id == "document.object_scene_missing":
		return "Assign a PackedScene in the Object Database or Object Palette."
	if rule_id == "document.object_duplicate_unique":
		return "Keep one placement for this unique object."
	if rule_id == "movement.profile_reachability":
		return "Adjust blockers, important points, or the movement profile."
	if rule_id.begins_with("catalog."):
		return _catalog_fix_suggestion(rule_id)
	return "Review the issue details and update the referenced asset or document data."


static func _catalog_fix_suggestion(rule_id: String) -> String:
	match rule_id:
		"catalog.missing":
			return "Select or create a tile catalog resource."
		"catalog.tile_set_missing":
			return "Assign a TileSet resource to the catalog."
		"catalog.entry_missing":
			return "Remove the empty row or create a catalog entry."
		"catalog.entry_key_missing":
			return "Give the catalog entry a unique key."
		"catalog.entry_key_duplicate":
			return "Rename one duplicate catalog key."
		"catalog.entry_type_invalid":
			return "Choose atlas, scene, or placeholder as the entry type."
		"catalog.source_missing":
			return "Choose an existing TileSet source for this entry."
		"catalog.source_type_mismatch":
			return "Match the entry type to the TileSet source type."
		"catalog.atlas_coords_invalid":
			return "Choose atlas coordinates that exist in the TileSet source."
		"catalog.alternative_tile_invalid":
			return "Choose an existing alternative tile or reset it to 0."
		"catalog.scene_missing":
			return "Assign a PackedScene resource to this scene entry."
		_:
			return "Fix the catalog entry shown by the focus target."


static func _issue_metadata(issue: Dictionary) -> Dictionary:
	var metadata = issue.get("metadata", {})
	if metadata is Dictionary:
		return (metadata as Dictionary)
	return {}


func _on_validate_pressed() -> void:
	validate_requested.emit()


func _on_issue_selected(index: int) -> void:
	if index < 0 or index >= _issue_rows.size():
		return
	_selected_row = _issue_rows[index].duplicate(true)
	var issue_value = _selected_row.get("issue", {})
	_selected_issue = (issue_value as Dictionary).duplicate(true) if issue_value is Dictionary else {}
	if _selected_detail_label != null:
		_selected_detail_label.text = _selected_detail_text(_selected_row)
	issue_selected.emit(_selected_issue.duplicate(true), index)
