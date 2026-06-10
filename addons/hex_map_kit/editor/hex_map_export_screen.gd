@tool
class_name HexMapExportScreen
extends RefCounted

const TAB_NAME := "Export"
const WORKFLOW_OWNER := "Export"
const USER_TASK := "Choose a runtime handoff destination and export the Level Document."
const SCREEN_SCRIPT := "hex_map_export_screen.gd"


static func screen_contract() -> Dictionary:
	return {
		"screen_role_source": "HexMapExportScreen",
		"screen_script": SCREEN_SCRIPT,
		"tab": TAB_NAME,
		"workflow_owner": WORKFLOW_OWNER,
		"user_task": USER_TASK,
		"owns": PackedStringArray([
			"export_profile",
			"runtime_handoff_type",
			"output_destination",
			"export_result_state",
		]),
		"delegates": {
			"source_document": "Resources",
			"package_build": "Release Process",
			"debug_report": "Diagnostics",
		},
	}


static func ownership_fields() -> Dictionary:
	return {
		"export_workflow_owner": WORKFLOW_OWNER,
		"export_management_visible": true,
		"destination_output_type_owner": WORKFLOW_OWNER,
		"destination_controls_visible": true,
		"output_type_controls_visible": true,
		"paint_export_management_visible": false,
	}
