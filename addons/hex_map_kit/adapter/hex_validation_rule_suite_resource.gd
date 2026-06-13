@tool
class_name HexValidationRuleSuiteResource
extends Resource

@export var suite_id: String = "project_validation"
@export var display_name: String = "Project Validation Suite"
@export var enabled_rule_ids: PackedStringArray = PackedStringArray()
@export var disabled_rule_ids: PackedStringArray = PackedStringArray()
@export var severity_overrides: Dictionary = {}
@export var rule_parameters: Dictionary = {}
@export var validation_targets: PackedStringArray = PackedStringArray(["document", "dependencies", "catalog"])
@export var fail_fast: bool = false
@export var metadata: Dictionary = {}


func rule_enabled(rule_id: String) -> bool:
	if rule_id == "":
		return false
	if disabled_rule_ids.has(rule_id):
		return false
	if enabled_rule_ids.is_empty():
		return true
	return enabled_rule_ids.has(rule_id)


func rule_severity(rule_id: String, default_severity: String = "error") -> String:
	if rule_id == "":
		return default_severity
	return String(severity_overrides.get(rule_id, default_severity))


func rule_parameter(rule_id: String, key: String, default_value: Variant = null) -> Variant:
	if rule_id == "" or key == "":
		return default_value
	var rule_values = rule_parameters.get(rule_id, {})
	if rule_values is Dictionary:
		return (rule_values as Dictionary).get(key, default_value)
	return default_value


func behavior_schema() -> Dictionary:
	return {
		"kind": "validation_rule_suite",
		"suite_id": suite_id,
		"display_name": display_name,
		"default_rule_enabled": enabled_rule_ids.is_empty(),
		"enabled_rule_ids": enabled_rule_ids.duplicate(),
		"disabled_rule_ids": disabled_rule_ids.duplicate(),
		"severity_overrides": severity_overrides.duplicate(true),
		"rule_parameters": rule_parameters.duplicate(true),
		"validation_targets": validation_targets.duplicate(),
		"fail_fast": fail_fast,
	}
