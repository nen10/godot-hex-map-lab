@tool
class_name HexMapValidateScreen
extends RefCounted

const TAB_NAME := "Validate"
const WORKFLOW_OWNER := "Validate"
const USER_TASK := "Run document validation and navigate issues to the responsible screen."
const SCREEN_SCRIPT := "hex_map_validate_screen.gd"


static func screen_contract() -> Dictionary:
	return {
		"screen_role_source": "HexMapValidateScreen",
		"screen_script": SCREEN_SCRIPT,
		"tab": TAB_NAME,
		"workflow_owner": WORKFLOW_OWNER,
		"user_task": USER_TASK,
		"owns": PackedStringArray([
			"validation_run",
			"issue_navigator",
			"issue_focus",
			"validation_rule_suite",
		]),
		"delegates": {},
	}


static func ownership_fields() -> Dictionary:
	return {
		"validation_workflow_owner": WORKFLOW_OWNER,
	}
