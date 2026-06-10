@tool
class_name HexMapLayersScreen
extends RefCounted

const TAB_NAME := "Layers"
const WORKFLOW_OWNER := "Layers"
const USER_TASK := "Manage Layer Stack roles, templates, visibility, and layer application."
const SCREEN_SCRIPT := "hex_map_layers_screen.gd"


static func screen_contract() -> Dictionary:
	return {
		"screen_role_source": "HexMapLayersScreen",
		"screen_script": SCREEN_SCRIPT,
		"tab": TAB_NAME,
		"workflow_owner": WORKFLOW_OWNER,
		"user_task": USER_TASK,
		"owns": PackedStringArray([
			"layer_stack",
			"layer_roles",
			"layer_templates",
			"layer_apply",
		]),
		"delegates": {},
	}


static func ownership_fields() -> Dictionary:
	return {
		"layer_workflow_owner": WORKFLOW_OWNER,
		"layer_management_visible": true,
		"paint_layer_management_visible": false,
	}
