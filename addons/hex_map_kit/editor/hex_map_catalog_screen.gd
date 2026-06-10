@tool
class_name HexMapCatalogScreen
extends RefCounted

const HexTileCatalogPreviewControl = preload("res://addons/hex_map_kit/editor/hex_tile_catalog_preview_control.gd")

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


static func component_owner_rows() -> Array[Dictionary]:
	return [
		_component_owner("catalog_detail_panel", "VBoxContainer", "CatalogDetailPanel"),
		_component_owner("catalog_asset_panel", "HexMapWorkspaceAssetPanel", "CatalogPanel"),
	]


static func build_catalog_detail_panel() -> Dictionary:
	var panel := _panel("Catalog Detail Panel", "catalog_detail_panel", "build_catalog_detail_panel")
	var title := Label.new()
	title.text = "Catalog Entries"
	panel.add_child(title)

	var status_label := _wrapped_label()
	panel.add_child(status_label)

	var entry_label := _wrapped_label()
	panel.add_child(entry_label)

	var preview_row := HBoxContainer.new()
	preview_row.name = "Catalog Entry Preview Row"
	preview_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(preview_row)

	var preview_control := HexTileCatalogPreviewControl.new()
	preview_control.name = "Catalog Entry Preview"
	preview_row.add_child(preview_control)

	var badge_label := _wrapped_label()
	badge_label.name = "Catalog Entry Preview Badge"
	badge_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_row.add_child(badge_label)

	return {
		"root": panel,
		"status_label": status_label,
		"entry_label": entry_label,
		"preview_control": preview_control,
		"preview_badge_label": badge_label,
	}


static func _component_owner(component_id: String, component_class: String, responsibility: String) -> Dictionary:
	return {
		"tab": TAB_NAME,
		"component_id": component_id,
		"component_class": component_class,
		"responsibility": responsibility,
		"screen_script": SCREEN_SCRIPT,
		"screen_role_source": "HexMapCatalogScreen",
	}


static func _panel(node_name: String, component_id: String, builder_id: String) -> VBoxContainer:
	var panel := VBoxContainer.new()
	panel.name = node_name
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.set_meta("hex_workspace_component_id", component_id)
	panel.set_meta("hex_workspace_screen_script", SCREEN_SCRIPT)
	panel.set_meta("hex_workspace_screen_role_source", "HexMapCatalogScreen")
	panel.set_meta("hex_workspace_builder", builder_id)
	return panel


static func _wrapped_label() -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label
