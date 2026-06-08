@tool
class_name HexMapWorkspaceComponentRegistry
extends RefCounted

const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")

const TAB_DOCUMENT := "Document"
const TAB_GENERATE := "Generate"
const TAB_PAINT := "Paint"
const TAB_CATALOG := "Catalog"
const TAB_LAYERS := "Layers"
const TAB_VALIDATE := "Validate"
const TAB_QA := "QA"
const TAB_EXPORT := "Export"
const TAB_SETTINGS := "Settings"


static func tab_names() -> PackedStringArray:
	return PackedStringArray([
		TAB_DOCUMENT,
		TAB_GENERATE,
		TAB_PAINT,
		TAB_CATALOG,
		TAB_LAYERS,
		TAB_VALIDATE,
		TAB_QA,
		TAB_EXPORT,
		TAB_SETTINGS,
	])


static func component_rows() -> Array[Dictionary]:
	return [
		_component(
			TAB_DOCUMENT,
			"document_asset_panel",
			"HexMapWorkspaceAssetPanel",
			"DocumentHeader",
			"document",
			PackedStringArray([
				HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
				HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
				HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE,
				HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE,
				HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
			])
		),
		_component(
			TAB_DOCUMENT,
			"missing_unique_resources_panel",
			"VBoxContainer",
			"SelectedHexTileMapMissingResources",
			"document"
		),
		_component(TAB_GENERATE, "generation_panel", "HexMapGenDock", "GenerationPanel", "generate"),
		_component(TAB_PAINT, "brush_palette", "HexMapEditTool", "BrushPalette", "paint"),
		_component(
			TAB_PAINT,
			"object_label_asset_panel",
			"HexMapWorkspaceAssetPanel",
			"ObjectLabelPanel",
			"paint",
			PackedStringArray([
				HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE,
				HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE,
			])
		),
		_component(
			TAB_CATALOG,
			"catalog_asset_panel",
			"HexMapWorkspaceAssetPanel",
			"CatalogPanel",
			"catalog",
			PackedStringArray([HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG])
		),
		_component(
			TAB_LAYERS,
			"layer_stack_asset_panel",
			"HexMapWorkspaceAssetPanel",
			"LayerStackPanel",
			"layers",
			PackedStringArray([HexMapWorkspaceAssetContext.SLOT_LAYER_STACK])
		),
		_component(
			TAB_VALIDATE,
			"validation_asset_panel",
			"HexMapWorkspaceAssetPanel",
			"ValidationPanel",
			"validate",
			PackedStringArray([
				HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
				HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE,
			])
		),
		_component(TAB_VALIDATE, "validation_issue_navigator", "VBoxContainer", "ValidationIssueNavigator", "validate"),
		_component(
			TAB_QA,
			"qa_asset_panel",
			"HexMapWorkspaceAssetPanel",
			"SeedLabPanel",
			"qa",
			PackedStringArray([
				HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE,
				HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE,
				HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
			])
		),
		_component(
			TAB_EXPORT,
			"export_asset_panel",
			"HexMapWorkspaceAssetPanel",
			"ExportPanel",
			"export",
			PackedStringArray([
				HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
				HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE,
			])
		),
		_component(TAB_EXPORT, "export_destination_panel", "VBoxContainer", "ExportDestinationPanel", "export"),
		_component(
			TAB_SETTINGS,
			"settings_project_defaults_panel",
			"HexMapWorkspaceAssetPanel",
			"ProjectDefaultsPanel",
			"settings",
			PackedStringArray([HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE])
		),
		_component(TAB_SETTINGS, "sample_settings_panel", "HexMapSampleSettingsPanel", "SampleSettingsPanel", "settings"),
	]


static func component_for_responsibility(responsibility: String) -> Dictionary:
	for row in component_rows():
		if String(row.get("responsibility", "")) == responsibility:
			return row.duplicate(true)
	return {}


static func component_for_tab(tab_name: String) -> Dictionary:
	for row in component_rows():
		if String(row.get("tab", "")) == tab_name:
			return row.duplicate(true)
	return {}


static func components_for_tab(tab_name: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row in component_rows():
		if String(row.get("tab", "")) == tab_name:
			result.append(row.duplicate(true))
	return result


static func component_ids_for_tab(tab_name: String) -> PackedStringArray:
	var result := PackedStringArray()
	for row in components_for_tab(tab_name):
		result.append(String(row.get("component_id", "")))
	return result


static func asset_slot_ids_for_tab(tab_name: String) -> PackedStringArray:
	var result := PackedStringArray()
	for row in components_for_tab(tab_name):
		var row_slot_ids = row.get("asset_slot_ids", PackedStringArray())
		for slot_id in row_slot_ids:
			var text := String(slot_id)
			if text != "" and not result.has(text):
				result.append(text)
	return result


static func _component(
	tab_name: String,
	component_id: String,
	component_class: String,
	responsibility: String,
	source_owner: String,
	asset_slot_ids: PackedStringArray = PackedStringArray()
) -> Dictionary:
	return {
		"tab": tab_name,
		"component_id": component_id,
		"component_class": component_class,
		"responsibility": responsibility,
		"source_owner": source_owner,
		"asset_slot_ids": asset_slot_ids.duplicate(),
	}
