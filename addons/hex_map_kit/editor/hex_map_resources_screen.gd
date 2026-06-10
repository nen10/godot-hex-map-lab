@tool
class_name HexMapResourcesScreen
extends RefCounted

const TAB_NAME := "Resources"
const WORKFLOW_OWNER := "Resources"
const USER_TASK := "Manage selected HexTileMap context, Level Document, and shared project resources."
const SCREEN_SCRIPT := "hex_map_resources_screen.gd"


static func screen_contract() -> Dictionary:
	return {
		"screen_role_source": "HexMapResourcesScreen",
		"screen_script": SCREEN_SCRIPT,
		"tab": TAB_NAME,
		"workflow_owner": WORKFLOW_OWNER,
		"user_task": USER_TASK,
		"owns": PackedStringArray([
			"selected_hex_tile_map_context",
			"level_document",
			"document_dependencies",
			"missing_unique_resources",
		]),
		"delegates": {},
	}


static func ownership_fields() -> Dictionary:
	return {
		"document_workflow_owner": WORKFLOW_OWNER,
		"document_management_visible": true,
		"paint_document_management_visible": false,
	}
