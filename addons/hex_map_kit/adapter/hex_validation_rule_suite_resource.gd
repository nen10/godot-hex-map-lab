@tool
class_name HexValidationRuleSuiteResource
extends Resource

@export var suite_id: String = "project_validation"
@export var display_name: String = "Project Validation Suite"
@export var enabled_rule_ids: PackedStringArray = PackedStringArray()
@export var disabled_rule_ids: PackedStringArray = PackedStringArray()
@export var severity_overrides: Dictionary = {}
@export var metadata: Dictionary = {}


func rule_enabled(rule_id: String) -> bool:
	if rule_id == "":
		return false
	if disabled_rule_ids.has(rule_id):
		return false
	if enabled_rule_ids.is_empty():
		return true
	return enabled_rule_ids.has(rule_id)
