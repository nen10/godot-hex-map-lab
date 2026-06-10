@tool
class_name HexMapCatalogScreen
extends RefCounted

const TAB_NAME := "Catalog"
const WORKFLOW_OWNER := "Catalog"
const USER_TASK := "Manage catalog entries, previews, tags, and catalog validation."
const SCREEN_SCRIPT := "hex_map_catalog_screen.gd"


static func screen_contract() -> Dictionary:
	return {
		"screen_role_source": "HexMapCatalogScreen",
		"screen_script": SCREEN_SCRIPT,
		"tab": TAB_NAME,
		"workflow_owner": WORKFLOW_OWNER,
		"user_task": USER_TASK,
		"owns": PackedStringArray([
			"tile_catalog",
			"catalog_entry_list",
			"catalog_entry_detail",
			"catalog_entry_validation",
		]),
		"delegates": {},
	}


static func ownership_fields() -> Dictionary:
	return {
		"catalog_entry_workflow_owner": WORKFLOW_OWNER,
		"catalog_entry_management_visible": true,
		"paint_catalog_entry_management_visible": false,
	}
