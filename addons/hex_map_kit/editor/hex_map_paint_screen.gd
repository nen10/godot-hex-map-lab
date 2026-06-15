@tool
class_name HexMapPaintScreen
extends RefCounted

const TAB_NAME := "Paint"
const WORKFLOW_OWNER := "Paint"
const USER_TASK := "Paint cells with the active brush on the active Level Document and layer target."
const SCREEN_SCRIPT := "hex_map_paint_screen.gd"
const SHAPE_SINGLE := "single"
const SHAPE_LINE := "line"
const SHAPE_DISC := "disc"
const SHAPE_FLOOD := "flood"


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


static func context_chips(view_state: Dictionary) -> Array:
	var layer_name := String(view_state.get("active_layer_name", ""))
	var layer_role := String(view_state.get("active_layer_role", ""))
	var brush_mode := String(view_state.get("brush_mode_label", view_state.get("brush_mode", "")))
	var brush_key := String(view_state.get("brush_key", ""))
	return [
		{
			"id": "layer",
			"label": "Layer",
			"value": "%s%s" % [
				layer_role if layer_role != "" else "active",
				" / %s" % layer_name if layer_name != "" else "",
			],
			"ready": bool(view_state.get("target_ready", false)),
		},
		{
			"id": "brush",
			"label": "Brush",
			"value": "%s%s" % [
				brush_mode if brush_mode != "" else "brush",
				" / %s" % brush_key if brush_key != "" else "",
			],
			"ready": bool(view_state.get("brush_ready", false)),
		},
	]


static func brush_palette(brush: Dictionary) -> Dictionary:
	var modes := [
		{"id": "terrain", "label": "Terrain"},
		{"id": "overlay", "label": "Overlay"},
		{"id": "object", "label": "Object"},
		{"id": "label", "label": "Label"},
	]
	var active_mode := String(brush.get("mode", "shape"))
	return {
		"surface_id": "paint_brush_palette",
		"visible": true,
		"active_mode": active_mode,
		"active_label": String(brush.get("mode_label", active_mode)),
		"active_brush_key": String(brush.get("brush_key", "")),
		"ready": bool(brush.get("ready", false)),
		"modes": modes,
		"mode_count": modes.size(),
		"uses_catalog_key": bool(brush.get("paint_consumes_catalog_key", true)),
	}


static func shape_controls(active_shape_mode: String = SHAPE_SINGLE) -> Dictionary:
	var active := active_shape_mode if shape_mode_ids().has(active_shape_mode) else SHAPE_SINGLE
	return {
		"surface_id": "paint_shape_controls",
		"visible": true,
		"active": active,
		"modes": shape_mode_ids(),
		"mode_labels": {
			SHAPE_SINGLE: "Single",
			SHAPE_LINE: "Line",
			SHAPE_DISC: "Disc",
			SHAPE_FLOOD: "Flood",
		},
	}


static func empty_cta(view_state: Dictionary) -> Dictionary:
	var visible := not bool(view_state.get("document_present", false))
	return {
		"visible": visible,
		"primary_action": "Create Level Document",
		"secondary_action": "Choose Level Document",
		"target_tab": "Resources",
		"reason": "missing_level_document" if visible else "",
	}


static func shape_mode_ids() -> PackedStringArray:
	return PackedStringArray([SHAPE_SINGLE, SHAPE_LINE, SHAPE_DISC, SHAPE_FLOOD])
