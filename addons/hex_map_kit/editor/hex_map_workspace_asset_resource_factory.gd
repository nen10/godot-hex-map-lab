@tool
class_name HexMapWorkspaceAssetResourceFactory
extends RefCounted

const HexLayerStackResource = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd")
const HexLabelDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_label_database_resource.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapEditorPathSelector = preload("res://addons/hex_map_kit/editor/hex_map_editor_path_selector.gd")
const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")
const HexMovementProfileResource = preload("res://addons/hex_map_kit/adapter/hex_movement_profile_resource.gd")
const HexObjectDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_object_database_resource.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")


static func create_resource_for_slot(slot_id: String) -> Resource:
	match slot_id:
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT:
			var document = HexMapDocumentResource.new()
			document.resource_name = "Hex Map Document"
			return document
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG:
			var catalog = HexTileCatalogResource.new()
			catalog.catalog_id = "project_tile_catalog"
			catalog.display_name = "Project Tile Catalog"
			return catalog
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE:
			var object_database = HexObjectDatabaseResource.new()
			object_database.resource_name = "Project Object Database"
			return object_database
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE:
			var label_database = HexLabelDatabaseResource.new()
			label_database.resource_name = "Project Label Database"
			return label_database
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK:
			var stack = HexLayerStackResource.standard_template()
			stack.resource_name = "Project Layer Stack"
			return stack
		HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE:
			var movement_profile = HexMovementProfileResource.new()
			movement_profile.profile_id = "project_movement"
			movement_profile.display_name = "Project Movement"
			return movement_profile
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE:
			var validation_suite = Resource.new()
			validation_suite.resource_name = "Project Validation Suite"
			return validation_suite
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE:
			var generation_profile = Resource.new()
			generation_profile.resource_name = "Project Generation Profile"
			return generation_profile
		HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE:
			var export_profile = Resource.new()
			export_profile.resource_name = "Project Export Profile"
			return export_profile
	return null


static func default_file_name(slot_id: String) -> String:
	match slot_id:
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT:
			return "hex_map_document.tres"
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG:
			return "tile_catalog.tres"
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE:
			return "object_database.tres"
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE:
			return "label_database.tres"
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK:
			return "layer_stack.tres"
		HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE:
			return "movement_profile.tres"
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE:
			return "validation_suite.tres"
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE:
			return "generation_profile.tres"
		HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE:
			return "export_profile.tres"
	return "project_asset.tres"


static func resource_type_name(slot_id: String) -> String:
	match slot_id:
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT:
			return "HexMapDocumentResource"
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG:
			return "HexTileCatalogResource"
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE:
			return "HexObjectDatabaseResource"
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE:
			return "HexLabelDatabaseResource"
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK:
			return "HexLayerStackResource"
		HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE:
			return "HexMovementProfileResource"
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE:
			return "Resource"
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE:
			return "Resource"
		HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE:
			return "Resource"
	return ""


static func resource_purpose(slot_id: String) -> String:
	match slot_id:
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT:
			return "Stores canonical map terrain, overlays, objects, labels, zones, and generation metadata."
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG:
			return "Maps logical terrain and overlay keys to TileSet atlas tiles or scene tiles."
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE:
			return "Defines placeable object ids, scenes, previews, tags, and placement schema."
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE:
			return "Defines label ids, display text defaults, and label metadata used by paint/edit tools."
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK:
			return "Defines selected HexTileMap child layer roles and display/write behavior."
		HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE:
			return "Defines traversal costs, passability, and movement validation behavior."
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE:
			return "Stores project validation preset data until a dedicated Validation Rule Suite class exists."
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE:
			return "Stores project generation preset data until a dedicated Generation Profile class exists."
		HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE:
			return "Stores project export preset data until a dedicated Export Profile class exists."
	return ""


static func type_filter_reason(slot_id: String) -> String:
	match slot_id:
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE:
			return "Flexible Resource slot: no concrete Validation Rule Suite Resource class exists yet."
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE:
			return "Flexible Resource slot: no concrete Generation Profile Resource class exists yet."
		HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE:
			return "Flexible Resource slot: no concrete Export Profile Resource class exists yet."
	return ""


static func save_dialog_config(slot_id: String) -> Dictionary:
	return {
		"file_mode": EditorFileDialog.FILE_MODE_SAVE_FILE,
		"filters": HexMapEditorPathSelector.TRES_FILTERS.duplicate(),
		"current_file": default_file_name(slot_id),
	}


static func new_save_dialog(slot_id: String) -> EditorFileDialog:
	if not Engine.is_editor_hint():
		return null
	var dialog = HexMapEditorPathSelector.new_dialog(
		EditorFileDialog.FILE_MODE_SAVE_FILE,
		HexMapEditorPathSelector.TRES_FILTERS
	)
	dialog.current_file = default_file_name(slot_id)
	return dialog


static func create_and_save_for_slot(
	slot_id: String,
	path: String,
	context: HexMapWorkspaceAssetContext = null
) -> Dictionary:
	var resource := create_resource_for_slot(slot_id)
	var actual_path := normalized_resource_path(path)
	if resource == null or actual_path == "":
		return {
			"ok": false,
			"error": ERR_INVALID_PARAMETER,
			"slot_id": slot_id,
			"path": actual_path,
			"resource": resource,
		}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(actual_path.get_base_dir()))
	var error := ResourceSaver.save(resource, actual_path)
	if error == OK:
		resource.resource_path = actual_path
		if context != null:
			context.set_asset(slot_id, resource)
	return {
		"ok": error == OK,
		"error": error,
		"slot_id": slot_id,
		"path": actual_path,
		"resource": resource,
	}


static func normalized_resource_path(path: String) -> String:
	var result := path.strip_edges()
	if result == "":
		return ""
	if result.get_extension().to_lower() != "tres":
		result = "%s.tres" % result.trim_suffix(".")
	return result
