@tool
class_name HexMapWorkspaceComponentRegistry
extends RefCounted

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
		_component(TAB_DOCUMENT, "document_header", "HexMapDocumentHeader", "DocumentHeader", "edit"),
		_component(TAB_GENERATE, "generation_panel", "HexMapGenerationPanel", "GenerationPanel", "generate"),
		_component(TAB_PAINT, "brush_palette", "HexMapBrushPalette", "BrushPalette", "edit"),
		_component(TAB_CATALOG, "catalog_panel", "HexMapCatalogPanel", "CatalogPanel", "edit"),
		_component(TAB_LAYERS, "layer_stack_panel", "HexMapLayerStackPanel", "LayerStackPanel", "edit"),
		_component(TAB_VALIDATE, "validation_panel", "HexMapValidationPanel", "ValidationPanel", "edit"),
		_component(TAB_QA, "seed_lab_panel", "HexMapSeedLabPanel", "SeedLabPanel", "generate"),
		_component(TAB_EXPORT, "export_panel", "HexMapExportPanel", "ExportPanel", "edit"),
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


static func _component(
	tab_name: String,
	component_id: String,
	component_class: String,
	responsibility: String,
	source_owner: String
) -> Dictionary:
	return {
		"tab": tab_name,
		"component_id": component_id,
		"component_class": component_class,
		"responsibility": responsibility,
		"source_owner": source_owner,
	}
