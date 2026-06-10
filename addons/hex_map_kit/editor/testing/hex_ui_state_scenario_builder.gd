@tool
class_name HexUIStateScenarioBuilder
extends RefCounted

const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexLayerStackResource = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")
const HexObjectDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_object_database_resource.gd")
const HexLabelDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_label_database_resource.gd")
const HexMovementProfileResource = preload("res://addons/hex_map_kit/adapter/hex_movement_profile_resource.gd")
const HexGenerationProfileResource = preload("res://addons/hex_map_kit/adapter/hex_generation_profile_resource.gd")
const HexExportProfileResource = preload("res://addons/hex_map_kit/adapter/hex_export_profile_resource.gd")
const HexValidationRuleSuiteResource = preload("res://addons/hex_map_kit/adapter/hex_validation_rule_suite_resource.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")
const HexMapEditorSessionState = preload("res://addons/hex_map_kit/editor/hex_map_editor_session_state.gd")
const HexMapWorkspace = preload("res://addons/hex_map_kit/editor/hex_map_workspace.gd")
const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")

const SCENARIO_NO_SELECTED := "no_selected_hex_tile_map"
const SCENARIO_SELECTED_NO_RESOURCES := "selected_hex_tile_map_no_resources"
const SCENARIO_SELECTED_WITH_RESOURCES := "selected_hex_tile_map_with_shared_resources"


static func create_workspace_scenario(
	scenario_id: String,
	viewport_size: Vector2i = Vector2i(960, 720)
) -> Dictionary:
	var scenario_root := Control.new()
	scenario_root.name = "UILayoutScenarioRoot"
	scenario_root.size = Vector2(viewport_size)
	scenario_root.custom_minimum_size = Vector2(viewport_size)

	var session := HexMapEditorSessionState.new()
	var workspace := HexMapWorkspace.new()
	workspace.name = "Hex Map Workspace"
	workspace.size = Vector2(viewport_size)
	workspace.custom_minimum_size = Vector2(viewport_size)
	workspace.set_editor_session_state(session)
	scenario_root.add_child(workspace)

	return {
		"scenario_id": scenario_id,
		"viewport_size": viewport_size,
		"root": scenario_root,
		"workspace": workspace,
		"session": session,
		"nodes": [],
	}


static func apply_workspace_state(scenario: Dictionary) -> void:
	var scenario_id := String(scenario.get("scenario_id", ""))
	var workspace := scenario.get("workspace", null) as HexMapWorkspace
	if workspace == null:
		return
	match scenario_id:
		SCENARIO_NO_SELECTED:
			workspace.clear_selected_hex_tile_map_layer("ui_layout_scenario.no_selected")
		SCENARIO_SELECTED_NO_RESOURCES:
			var empty_layer := _ensure_layer(scenario, "SelectedNoResources")
			workspace.set_selected_hex_tile_map_layer(empty_layer, "ui_layout_scenario.no_resources")
		SCENARIO_SELECTED_WITH_RESOURCES:
			var ready_layer := _ensure_layer(scenario, "SelectedWithResources")
			var context := _resource_context()
			ready_layer.level_document_resource = context.level_document
			ready_layer.layer_stack_resource = context.layer_stack
			workspace.set_workspace_asset_context(context)
			workspace.set_selected_hex_tile_map_layer(ready_layer, "ui_layout_scenario.with_resources")
		_:
			workspace.clear_selected_hex_tile_map_layer("ui_layout_scenario.unknown")


static func free_workspace_scenario(scenario: Dictionary) -> void:
	var root := scenario.get("root", null) as Node
	if root != null:
		root.queue_free()


static func _ensure_layer(scenario: Dictionary, name: String) -> HexTileMapLayer:
	var nodes = scenario.get("nodes", []) as Array
	for node in nodes:
		if node is HexTileMapLayer:
			return node as HexTileMapLayer
	var layer := HexTileMapLayer.new()
	layer.name = name
	var root := scenario.get("root", null) as Node
	if root != null:
		root.add_child(layer)
	nodes.append(layer)
	scenario["nodes"] = nodes
	return layer


static func _resource_context() -> HexMapWorkspaceAssetContext:
	var context := HexMapWorkspaceAssetContext.new()
	context.set_level_document(HexMapDocumentResource.new())
	context.set_tile_catalog(HexTileCatalogResource.new())
	context.set_object_database(HexObjectDatabaseResource.new())
	context.set_label_database(HexLabelDatabaseResource.new())
	context.set_layer_stack(HexLayerStackResource.new())
	context.set_movement_profile(HexMovementProfileResource.new())
	context.set_generation_profile(HexGenerationProfileResource.new())
	context.set_validation_rule_suite(HexValidationRuleSuiteResource.new())
	context.set_export_profile(HexExportProfileResource.new())
	return context
