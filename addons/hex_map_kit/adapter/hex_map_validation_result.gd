@tool
class_name HexMapValidationResult
extends Resource

const SEVERITY_ERROR := "error"
const SEVERITY_WARNING := "warning"
const SEVERITY_INFO := "info"

const SCOPE_DOCUMENT := "document"
const SCOPE_LAYER := "layer"
const SCOPE_CELL := "cell"
const SCOPE_OBJECT := "object"
const SCOPE_DEPENDENCY := "dependency"

@export var summary: Dictionary = {}
@export var issues: Array[Dictionary] = []


func add_issue(
	severity: String,
	rule_id: String,
	message: String,
	scope: String = SCOPE_DOCUMENT,
	details: Dictionary = {}
) -> void:
	var issue := {
		"severity": severity,
		"rule_id": rule_id,
		"message": message,
		"scope": scope,
		"cell": details.get("cell", Vector3i.ZERO),
		"object_id": String(details.get("object_id", "")),
		"dependency_resource_path": String(details.get("dependency_resource_path", "")),
		"metadata": details.get("metadata", {}).duplicate(true),
	}
	issues.append(issue)


func add_error(rule_id: String, message: String, scope: String = SCOPE_DOCUMENT, details: Dictionary = {}) -> void:
	add_issue(SEVERITY_ERROR, rule_id, message, scope, details)


func add_warning(rule_id: String, message: String, scope: String = SCOPE_DOCUMENT, details: Dictionary = {}) -> void:
	add_issue(SEVERITY_WARNING, rule_id, message, scope, details)


func add_info(rule_id: String, message: String, scope: String = SCOPE_DOCUMENT, details: Dictionary = {}) -> void:
	add_issue(SEVERITY_INFO, rule_id, message, scope, details)


func issue_count(severity: String = "") -> int:
	if severity == "":
		return issues.size()
	var count := 0
	for issue in issues:
		if String(issue.get("severity", "")) == severity:
			count += 1
	return count


func error_count() -> int:
	return issue_count(SEVERITY_ERROR)


func warning_count() -> int:
	return issue_count(SEVERITY_WARNING)


func info_count() -> int:
	return issue_count(SEVERITY_INFO)


func to_dictionary() -> Dictionary:
	return {
		"summary": summary.duplicate(true),
		"issues": issues.duplicate(true),
		"errors": error_count(),
		"warnings": warning_count(),
		"infos": info_count(),
	}
