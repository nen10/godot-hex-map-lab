@tool
class_name HexMapDocumentInspector
extends VBoxContainer

const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")

var _document_summary_label: Label
var _validation_summary_label: Label
var _document_summary: Dictionary = {}
var _validation_summary: Dictionary = {}


func _ready() -> void:
	_build_ui()
	clear()


func clear() -> void:
	_document_summary = document_summary(null)
	_validation_summary = validation_summary_from_result(null, {"document_present": false})
	_refresh_view()


func set_document_state(
	document,
	source: String = "",
	path: String = "",
	unsaved_target_document: bool = false
) -> void:
	_document_summary = document_summary(document)
	_document_summary["present"] = document != null
	_document_summary["source"] = source
	_document_summary["path"] = path
	_document_summary["unsaved_target_document"] = unsaved_target_document
	_refresh_view()


func set_validation_summary(summary: Dictionary) -> void:
	_validation_summary = summary.duplicate(true)
	_refresh_view()


func inspector_summary() -> Dictionary:
	return {
		"document": _document_summary.duplicate(true),
		"validation": _validation_summary.duplicate(true),
	}


static func document_summary(document) -> Dictionary:
	if document == null:
		return {
			"cell_count": 0,
			"wall_count": 0,
			"object_count": 0,
			"label_count": 0,
			"zone_count": 0,
		}
	var summary = HexMapDocumentAdapter.document_summary(document)
	return {
		"cell_count": int(summary.get("cells", 0)),
		"wall_count": int(summary.get("walls", 0)),
		"object_count": int(summary.get("objects", 0)),
		"label_count": int(summary.get("labels", 0)),
		"zone_count": int(summary.get("zones", 0)),
	}


static func validation_summary_from_result(result, base: Dictionary = {}) -> Dictionary:
	var summary = base.duplicate(true)
	if result == null:
		summary["issues"] = 0
		summary["errors"] = 0
		summary["warnings"] = 0
		summary["infos"] = 0
		return summary
	summary["issues"] = result.issue_count() if result.has_method("issue_count") else 0
	summary["errors"] = result.error_count() if result.has_method("error_count") else 0
	summary["warnings"] = result.warning_count() if result.has_method("warning_count") else 0
	summary["infos"] = result.info_count() if result.has_method("info_count") else 0
	return summary


static func validation_issue_report_rows(result, limit: int = 8) -> Array[String]:
	var rows: Array[String] = []
	if result == null:
		return rows
	var issues = result.get("issues") if result is Object else []
	if not issues is Array:
		return rows
	for issue in issues:
		if rows.size() >= limit:
			break
		if not issue is Dictionary:
			continue
		rows.append(validation_issue_report_row(issue as Dictionary))
	return rows


static func validation_issue_report_row(issue: Dictionary) -> String:
	var cell_text = ""
	var cell = issue.get("cell", null)
	if cell is Vector3i:
		cell_text = " cell=(%d,%d,%d)" % [cell.x, cell.y, cell.z]
	return "%s/%s/%s%s %s" % [
		String(issue.get("severity", "")),
		String(issue.get("scope", "")),
		String(issue.get("rule_id", "")),
		cell_text,
		String(issue.get("message", "")),
	]


func _build_ui() -> void:
	if _document_summary_label != null:
		return
	var title = Label.new()
	title.text = "Document Inspector"
	add_child(title)

	_document_summary_label = Label.new()
	_document_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_document_summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(_document_summary_label)

	_validation_summary_label = Label.new()
	_validation_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_validation_summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(_validation_summary_label)


func _refresh_view() -> void:
	if _document_summary_label != null:
		var path = String(_document_summary.get("path", ""))
		_document_summary_label.text = "Document summary: cells=%d walls=%d objects=%d labels=%d source=%s path=%s%s" % [
			int(_document_summary.get("cell_count", 0)),
			int(_document_summary.get("wall_count", 0)),
			int(_document_summary.get("object_count", 0)),
			int(_document_summary.get("label_count", 0)),
			String(_document_summary.get("source", "")),
			path if path != "" else "(unsaved)",
			" unsaved-target" if bool(_document_summary.get("unsaved_target_document", false)) else "",
		]
	if _validation_summary_label != null:
		_validation_summary_label.text = "Validation summary: issues=%d errors=%d warnings=%d infos=%d" % [
			int(_validation_summary.get("issues", 0)),
			int(_validation_summary.get("errors", 0)),
			int(_validation_summary.get("warnings", 0)),
			int(_validation_summary.get("infos", 0)),
		]
