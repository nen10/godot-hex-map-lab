class_name HexEditorWorkflowExample
extends Node

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexLayerStackResource = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd")
const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapDocumentDependencyResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_dependency_resource.gd")
const HexMapDocumentLabelPlacementResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_label_placement_resource.gd")
const HexMapDocumentObjectPlacementResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_object_placement_resource.gd")
const HexMapDocumentOverlayLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_overlay_layer_resource.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapDocumentTerrainLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_terrain_layer_resource.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")

const SAMPLE_CATALOG_PATH := "res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres"
const BASIC_RUNTIME_SCENE_PATH := "res://examples/basic_runtime/runtime_query_example.tscn"
const BASIC_RUNTIME_SCRIPT_PATH := "res://examples/basic_runtime/runtime_query_sample.gd"
const EDITOR_WORKFLOW_SCENE_PATH := "res://examples/editor_workflow/editor_workflow_example.tscn"

var sample_document: HexMapDocumentResource
var last_summary: Dictionary = {}


func _ready() -> void:
	sample_document = build_authoring_document()
	last_summary = workflow_summary(sample_document)


static func example_paths() -> Dictionary:
	return {
		"sample_catalog": SAMPLE_CATALOG_PATH,
		"basic_runtime_scene": BASIC_RUNTIME_SCENE_PATH,
		"basic_runtime_script": BASIC_RUNTIME_SCRIPT_PATH,
		"editor_workflow_scene": EDITOR_WORKFLOW_SCENE_PATH,
	}


static func loadable_example_paths() -> Array[String]:
	return [
		SAMPLE_CATALOG_PATH,
		BASIC_RUNTIME_SCENE_PATH,
		BASIC_RUNTIME_SCRIPT_PATH,
		EDITOR_WORKFLOW_SCENE_PATH,
	]


static func build_authoring_document() -> HexMapDocumentResource:
	var data = HexMapData.rectangle(3, 2)
	data.set_walls([HexVector.q_axis()])

	var document = HexMapDocumentResource.new()
	document.metadata.document_id = "editor-workflow-example"
	document.metadata.display_name = "Editor Workflow Example"
	document.metadata.custom_properties = {
		"default_catalog": SAMPLE_CATALOG_PATH,
		"workflow": "generate-edit-validate-runtime",
	}
	document.dependencies.append(_catalog_dependency())

	var terrain_layer = HexMapDocumentTerrainLayerResource.new()
	terrain_layer.layer_id = "terrain"
	terrain_layer.display_name = "Terrain"
	terrain_layer.map = HexMapResource.from_map_data(data)
	terrain_layer.default_floor_key = "terrain.floor"
	terrain_layer.default_wall_key = "terrain.wall"
	terrain_layer.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"catalog_key": "terrain.floor",
	})
	terrain_layer.tile_assignments.append({
		"cell": Vector3i(1, 0, 0),
		"kind": HexMapDocumentAdapter.KIND_WALL,
		"catalog_key": "terrain.wall",
	})
	document.terrain_layers.append(terrain_layer)

	var overlay_layer = HexMapDocumentOverlayLayerResource.new()
	overlay_layer.layer_id = "treasure_overlay"
	overlay_layer.display_name = "Treasure Overlay"
	overlay_layer.item_key = "Treasure"
	overlay_layer.catalog_key = "overlay.treasure"
	overlay_layer.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"item_key": "Treasure",
		"catalog_key": "overlay.treasure",
	})
	document.overlay_layers.append(overlay_layer)

	var placement = HexMapDocumentObjectPlacementResource.new()
	placement.placement_id = "spawn_marker"
	placement.object_id = "spawn"
	placement.cell = Vector3i.ZERO
	placement.properties = {"team": "player"}
	document.object_placements.append(placement)

	var label = HexMapDocumentLabelPlacementResource.new()
	label.label_id = "start_label"
	label.cell = Vector3i.ZERO
	label.text = "Start"
	document.label_placements.append(label)
	return document


static func workflow_summary(document: HexMapDocumentResource = null) -> Dictionary:
	var target = document if document != null else build_authoring_document()
	var summary = HexMapDocumentAdapter.document_summary(target)
	var layer_stack = HexLayerStackResource.standard_template()
	return {
		"summary": summary,
		"layer_roles": Array(layer_stack.role_names()),
		"dependency_resource_paths": _dependency_resource_paths(target),
		"example_paths": example_paths(),
	}


static func _catalog_dependency() -> HexMapDocumentDependencyResource:
	var dependency = HexMapDocumentDependencyResource.new()
	dependency.dependency_id = "sample_catalog"
	dependency.kind = HexMapDocumentDependencyResource.KIND_TILE_CATALOG
	dependency.resource = load(SAMPLE_CATALOG_PATH)
	dependency.role = "default_catalog"
	dependency.required = true
	return dependency


static func _dependency_resource_paths(document: HexMapDocumentResource) -> Array[String]:
	var result: Array[String] = []
	for dependency in document.dependencies:
		if dependency == null:
			continue
		var path := ""
		var resource = dependency.get("resource")
		if resource is Resource:
			path = (resource as Resource).resource_path
		if path != "":
			result.append(path)
	result.sort()
	return result
