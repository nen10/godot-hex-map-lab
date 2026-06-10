@tool
class_name HexMapPaintScreen
extends RefCounted

const TAB_NAME := "Paint"
const WORKFLOW_OWNER := "Paint"
const USER_TASK := "Paint cells with the active brush on the active Level Document and layer target."
const SCREEN_SCRIPT := "hex_map_paint_screen.gd"


static func screen_contract() -> Dictionary:
	return {
		"screen_role_source": "HexMapPaintScreen",
		"screen_script": SCREEN_SCRIPT,
		"tab": TAB_NAME,
		"workflow_owner": WORKFLOW_OWNER,
		"user_task": USER_TASK,
		"owns": PackedStringArray([
			"active_brush",
			"target_layer_summary",
			"selected_cell",
			"last_edit",
			"viewport_paint_input",
		]),
		"delegates": {
			"catalog_entry_management": "Catalog",
			"document_management": "Resources",
			"layer_management": "Layers",
			"export_management": "Export",
			"validation": "Validate",
		},
	}


static func delegated_ownership(
	document_management_visible: bool = false,
	layer_management_visible: bool = false,
	export_management_visible: bool = false,
	validation_dashboard_visible: bool = false
) -> Dictionary:
	return {
		"document_workflow_owner": "Resources",
		"document_management_visible": document_management_visible,
		"layer_workflow_owner": "Layers",
		"layer_management_visible": layer_management_visible,
		"export_workflow_owner": "Export",
		"export_management_visible": export_management_visible,
		"paint_non_paint_management_visible": document_management_visible or layer_management_visible or export_management_visible,
		"validation_workflow_owner": "Validate",
		"validation_dashboard_visible": validation_dashboard_visible,
	}


static func catalog_ownership(catalog_entry_management_visible: bool = false) -> Dictionary:
	return {
		"catalog_entry_workflow_owner": "Catalog",
		"catalog_entry_management_visible": catalog_entry_management_visible,
		"paint_consumes_catalog_key": true,
	}
