@tool
class_name HexMapQAScreen
extends RefCounted

const TAB_NAME := "QA"
const WORKFLOW_OWNER := "QA"
const USER_TASK := "Compare generated seed candidates and promote one result to the Level Document."
const SCREEN_SCRIPT := "hex_map_qa_screen.gd"


static func screen_contract() -> Dictionary:
	return {
		"screen_role_source": "HexMapQAScreen",
		"screen_script": SCREEN_SCRIPT,
		"tab": TAB_NAME,
		"workflow_owner": WORKFLOW_OWNER,
		"user_task": USER_TASK,
		"owns": PackedStringArray([
			"generation_profile",
			"seed_lab",
			"score_table",
			"promote_selected_seed",
		]),
		"delegates": {
			"generate_candidate": "Generate",
			"promote_target": "Resources",
		},
	}


static func ownership_fields() -> Dictionary:
	return {
		"qa_workflow_owner": WORKFLOW_OWNER,
	}
