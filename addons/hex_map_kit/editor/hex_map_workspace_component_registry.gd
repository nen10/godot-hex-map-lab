@tool
class_name HexMapWorkspaceComponentRegistry
extends RefCounted

const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")

const TAB_RESOURCES := "Resources"
const TAB_DOCUMENT := TAB_RESOURCES
const TAB_DOCUMENT_LEGACY := "Document"
const TAB_GENERATE := "Generate"
const TAB_PAINT := "Paint"
const TAB_CATALOG := "Catalog"
const TAB_LAYERS := "Layers"
const TAB_VALIDATE := "Validate"
const TAB_QA := "QA"
const TAB_EXPORT := "Export"
const TAB_SETTINGS := "Settings"

const SCREEN_RESOURCES := "hex_map_resources_screen.gd"
const SCREEN_GENERATE := "hex_map_gen_dock.gd"
const SCREEN_PAINT := "hex_map_paint_screen.gd"
const SCREEN_CATALOG := "hex_map_catalog_screen.gd"
const SCREEN_LAYERS := "hex_map_layers_screen.gd"
const SCREEN_VALIDATE := "hex_map_validate_screen.gd"
const SCREEN_QA := "hex_map_qa_screen.gd"
const SCREEN_EXPORT := "hex_map_export_screen.gd"
const SCREEN_SETTINGS := "hex_map_settings_screen.gd"


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
		_component(TAB_DOCUMENT, "resources_context_panel", "VBoxContainer", "ResourcesContextPanel", "resources"),
		_component(
			TAB_DOCUMENT,
			"document_asset_panel",
			"HexMapWorkspaceAssetPanel",
			"ResourcesAssetPanel",
			"resources",
			PackedStringArray([
				HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
				HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
				HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE,
				HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE,
				HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
				HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE,
			])
		),
		_component(
			TAB_DOCUMENT,
			"missing_unique_resources_panel",
			"VBoxContainer",
			"SelectedHexTileMapMissingResources",
			"resources"
		),
		_component(TAB_GENERATE, "generation_panel", "HexMapGenDock", "GenerationPanel", "generate"),
		_component(TAB_PAINT, "brush_palette", "HexMapEditTool", "BrushPalette", "paint"),
		_component(TAB_CATALOG, "catalog_detail_panel", "VBoxContainer", "CatalogDetailPanel", "catalog"),
		_component(
			TAB_CATALOG,
			"catalog_asset_panel",
			"HexMapWorkspaceAssetPanel",
			"CatalogPanel",
			"catalog",
			PackedStringArray([HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG])
		),
		_component(TAB_LAYERS, "layer_stack_role_panel", "VBoxContainer", "LayerStackRolePanel", "layers"),
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
		_component(TAB_QA, "qa_seed_lab_panel", "VBoxContainer", "SeedLabPanel", "qa"),
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
		_component(TAB_EXPORT, "export_purpose_panel", "VBoxContainer", "ExportPurposePanel", "export"),
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
		_component(TAB_SETTINGS, "settings_preferences_panel", "VBoxContainer", "SettingsPreferencesPanel", "settings"),
		_component(TAB_SETTINGS, "sample_settings_panel", "HexMapSampleSettingsPanel", "SampleSettingsPanel", "settings"),
	]


static func component_for_responsibility(responsibility: String) -> Dictionary:
	for row in component_rows():
		if String(row.get("responsibility", "")) == responsibility:
			return row.duplicate(true)
	return {}


static func component_for_tab(tab_name: String) -> Dictionary:
	var actual_tab := canonical_tab_name(tab_name)
	for row in component_rows():
		if String(row.get("tab", "")) == actual_tab:
			return row.duplicate(true)
	return {}


static func components_for_tab(tab_name: String) -> Array[Dictionary]:
	var actual_tab := canonical_tab_name(tab_name)
	var result: Array[Dictionary] = []
	for row in component_rows():
		if String(row.get("tab", "")) == actual_tab:
			result.append(row.duplicate(true))
	return result


static func component_for_tab_and_id(tab_name: String, component_id: String) -> Dictionary:
	var actual_tab := canonical_tab_name(tab_name)
	for row in components_for_tab(actual_tab):
		if String(row.get("component_id", "")) == component_id:
			return row.duplicate(true)
	return {}


static func component_owner_rows() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row in component_rows():
		result.append({
			"tab": String(row.get("tab", "")),
			"component_id": String(row.get("component_id", "")),
			"component_class": String(row.get("component_class", "")),
			"screen_script": String(row.get("screen_script", "")),
			"screen_role_source": String(row.get("screen_role_source", "")),
		})
	return result


static func component_owner_for(tab_name: String, component_id: String) -> Dictionary:
	var row := component_for_tab_and_id(tab_name, component_id)
	if row.is_empty():
		return {}
	return {
		"tab": String(row.get("tab", "")),
		"component_id": String(row.get("component_id", "")),
		"component_class": String(row.get("component_class", "")),
		"screen_script": String(row.get("screen_script", "")),
		"screen_role_source": String(row.get("screen_role_source", "")),
	}


static func canonical_tab_name(tab_name: String) -> String:
	return TAB_RESOURCES if tab_name == TAB_DOCUMENT_LEGACY else tab_name


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
	var actual_tab := canonical_tab_name(tab_name)
	return {
		"tab": actual_tab,
		"component_id": component_id,
		"component_class": component_class,
		"responsibility": responsibility,
		"source_owner": source_owner,
		"asset_slot_ids": asset_slot_ids.duplicate(),
		"screen_script": screen_script_for_tab(actual_tab),
		"screen_role_source": screen_role_source_for_tab(actual_tab),
	}


static func screen_script_for_tab(tab_name: String) -> String:
	match canonical_tab_name(tab_name):
		TAB_DOCUMENT:
			return SCREEN_RESOURCES
		TAB_GENERATE:
			return SCREEN_GENERATE
		TAB_PAINT:
			return SCREEN_PAINT
		TAB_CATALOG:
			return SCREEN_CATALOG
		TAB_LAYERS:
			return SCREEN_LAYERS
		TAB_VALIDATE:
			return SCREEN_VALIDATE
		TAB_QA:
			return SCREEN_QA
		TAB_EXPORT:
			return SCREEN_EXPORT
		TAB_SETTINGS:
			return SCREEN_SETTINGS
	return ""


static func screen_role_source_for_tab(tab_name: String) -> String:
	match canonical_tab_name(tab_name):
		TAB_DOCUMENT:
			return "HexMapResourcesScreen"
		TAB_GENERATE:
			return "HexMapGenDock"
		TAB_PAINT:
			return "HexMapPaintScreen"
		TAB_CATALOG:
			return "HexMapCatalogScreen"
		TAB_LAYERS:
			return "HexMapLayersScreen"
		TAB_VALIDATE:
			return "HexMapValidateScreen"
		TAB_QA:
			return "HexMapQAScreen"
		TAB_EXPORT:
			return "HexMapExportScreen"
		TAB_SETTINGS:
			return "HexMapSettingsScreen"
	return ""
