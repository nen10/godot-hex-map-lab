@tool
class_name HexMapWorkspaceAssetContext
extends Resource

const HexLayerStackResource = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd")
const HexLabelDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_label_database_resource.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMovementProfileResource = preload("res://addons/hex_map_kit/adapter/hex_movement_profile_resource.gd")
const HexObjectDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_object_database_resource.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")

signal asset_changed(slot_id: String)

const SLOT_LEVEL_DOCUMENT := "level_document"
const SLOT_TILE_CATALOG := "tile_catalog"
const SLOT_LAYER_STACK := "layer_stack"
const SLOT_OBJECT_DATABASE := "object_database"
const SLOT_LABEL_DATABASE := "label_database"
const SLOT_MOVEMENT_PROFILE := "movement_profile"
const SLOT_VALIDATION_RULE_SUITE := "validation_rule_suite"
const SLOT_GENERATION_PROFILE := "generation_profile"
const SLOT_EXPORT_PROFILE := "export_profile"

const SOURCE_NONE := "none"
const SOURCE_PROJECT := "project"
const SOURCE_SAMPLE := "sample"
const SOURCE_DOCUMENT_DEPENDENCY := "document_dependency"

const SOURCE_BADGE_NONE := "Missing"
const SOURCE_BADGE_PROJECT := "Project"
const SOURCE_BADGE_SAMPLE := "Sample Learning"
const SOURCE_BADGE_DOCUMENT_DEPENDENCY := "Document Dependency"

@export var level_document: HexMapDocumentResource
@export var tile_catalog: HexTileCatalogResource
@export var layer_stack: HexLayerStackResource
@export var object_database: HexObjectDatabaseResource
@export var label_database: HexLabelDatabaseResource
@export var movement_profile: HexMovementProfileResource
@export var validation_rule_suite: Resource
@export var generation_profile: Resource
@export var export_profile: Resource

var _asset_sources := {}
var _asset_source_badges := {}


static func asset_slot_ids() -> PackedStringArray:
	return PackedStringArray([
		SLOT_LEVEL_DOCUMENT,
		SLOT_TILE_CATALOG,
		SLOT_LAYER_STACK,
		SLOT_OBJECT_DATABASE,
		SLOT_LABEL_DATABASE,
		SLOT_MOVEMENT_PROFILE,
		SLOT_VALIDATION_RULE_SUITE,
		SLOT_GENERATION_PROFILE,
		SLOT_EXPORT_PROFILE,
	])


func set_level_document(resource: HexMapDocumentResource, source: String = SOURCE_PROJECT, source_badge: String = "") -> void:
	_assign_asset(SLOT_LEVEL_DOCUMENT, resource, source, source_badge)


func set_tile_catalog(resource: HexTileCatalogResource, source: String = SOURCE_PROJECT, source_badge: String = "") -> void:
	_assign_asset(SLOT_TILE_CATALOG, resource, source, source_badge)


func set_layer_stack(resource: HexLayerStackResource, source: String = SOURCE_PROJECT, source_badge: String = "") -> void:
	_assign_asset(SLOT_LAYER_STACK, resource, source, source_badge)


func set_object_database(resource: HexObjectDatabaseResource, source: String = SOURCE_PROJECT, source_badge: String = "") -> void:
	_assign_asset(SLOT_OBJECT_DATABASE, resource, source, source_badge)


func set_label_database(resource: HexLabelDatabaseResource, source: String = SOURCE_PROJECT, source_badge: String = "") -> void:
	_assign_asset(SLOT_LABEL_DATABASE, resource, source, source_badge)


func set_movement_profile(resource: HexMovementProfileResource, source: String = SOURCE_PROJECT, source_badge: String = "") -> void:
	_assign_asset(SLOT_MOVEMENT_PROFILE, resource, source, source_badge)


func set_validation_rule_suite(resource: Resource, source: String = SOURCE_PROJECT, source_badge: String = "") -> void:
	_assign_asset(SLOT_VALIDATION_RULE_SUITE, resource, source, source_badge)


func set_generation_profile(resource: Resource, source: String = SOURCE_PROJECT, source_badge: String = "") -> void:
	_assign_asset(SLOT_GENERATION_PROFILE, resource, source, source_badge)


func set_export_profile(resource: Resource, source: String = SOURCE_PROJECT, source_badge: String = "") -> void:
	_assign_asset(SLOT_EXPORT_PROFILE, resource, source, source_badge)


func set_asset(slot_id: String, resource: Resource, source: String = SOURCE_PROJECT, source_badge: String = "") -> void:
	match slot_id:
		SLOT_LEVEL_DOCUMENT:
			set_level_document(resource as HexMapDocumentResource, source, source_badge)
		SLOT_TILE_CATALOG:
			set_tile_catalog(resource as HexTileCatalogResource, source, source_badge)
		SLOT_LAYER_STACK:
			set_layer_stack(resource as HexLayerStackResource, source, source_badge)
		SLOT_OBJECT_DATABASE:
			set_object_database(resource as HexObjectDatabaseResource, source, source_badge)
		SLOT_LABEL_DATABASE:
			set_label_database(resource as HexLabelDatabaseResource, source, source_badge)
		SLOT_MOVEMENT_PROFILE:
			set_movement_profile(resource as HexMovementProfileResource, source, source_badge)
		SLOT_VALIDATION_RULE_SUITE:
			set_validation_rule_suite(resource, source, source_badge)
		SLOT_GENERATION_PROFILE:
			set_generation_profile(resource, source, source_badge)
		SLOT_EXPORT_PROFILE:
			set_export_profile(resource, source, source_badge)


func asset_for_slot(slot_id: String) -> Resource:
	match slot_id:
		SLOT_LEVEL_DOCUMENT:
			return level_document
		SLOT_TILE_CATALOG:
			return tile_catalog
		SLOT_LAYER_STACK:
			return layer_stack
		SLOT_OBJECT_DATABASE:
			return object_database
		SLOT_LABEL_DATABASE:
			return label_database
		SLOT_MOVEMENT_PROFILE:
			return movement_profile
		SLOT_VALIDATION_RULE_SUITE:
			return validation_rule_suite
		SLOT_GENERATION_PROFILE:
			return generation_profile
		SLOT_EXPORT_PROFILE:
			return export_profile
	return null


func has_asset(slot_id: String) -> bool:
	return asset_for_slot(slot_id) != null


func asset_source(slot_id: String) -> String:
	if asset_for_slot(slot_id) == null:
		return SOURCE_NONE
	return String(_asset_sources.get(slot_id, SOURCE_PROJECT))


func asset_source_badge(slot_id: String) -> String:
	if asset_for_slot(slot_id) == null:
		return SOURCE_BADGE_NONE
	var badge := String(_asset_source_badges.get(slot_id, ""))
	return badge if badge != "" else source_badge_for_source(asset_source(slot_id))


func source_snapshot() -> Dictionary:
	var result := {}
	for slot_id in asset_slot_ids():
		result[slot_id] = {
			"source": asset_source(slot_id),
			"source_badge": asset_source_badge(slot_id),
			"resource": asset_for_slot(slot_id),
			"selected": asset_for_slot(slot_id) != null,
		}
	return result


func snapshot() -> Dictionary:
	var result := {}
	for slot_id in asset_slot_ids():
		result[slot_id] = asset_for_slot(slot_id)
	return result


static func source_badge_for_source(source: String) -> String:
	match source:
		SOURCE_PROJECT:
			return SOURCE_BADGE_PROJECT
		SOURCE_SAMPLE:
			return SOURCE_BADGE_SAMPLE
		SOURCE_DOCUMENT_DEPENDENCY:
			return SOURCE_BADGE_DOCUMENT_DEPENDENCY
	return SOURCE_BADGE_NONE


func _assign_asset(slot_id: String, resource: Resource, source: String = SOURCE_PROJECT, source_badge: String = "") -> void:
	var next_source := source if resource != null else SOURCE_NONE
	var next_badge := source_badge if source_badge != "" else source_badge_for_source(next_source)
	if asset_for_slot(slot_id) == resource and asset_source(slot_id) == next_source and asset_source_badge(slot_id) == next_badge:
		return
	match slot_id:
		SLOT_LEVEL_DOCUMENT:
			level_document = resource as HexMapDocumentResource
		SLOT_TILE_CATALOG:
			tile_catalog = resource as HexTileCatalogResource
		SLOT_LAYER_STACK:
			layer_stack = resource as HexLayerStackResource
		SLOT_OBJECT_DATABASE:
			object_database = resource as HexObjectDatabaseResource
		SLOT_LABEL_DATABASE:
			label_database = resource as HexLabelDatabaseResource
		SLOT_MOVEMENT_PROFILE:
			movement_profile = resource as HexMovementProfileResource
		SLOT_VALIDATION_RULE_SUITE:
			validation_rule_suite = resource
		SLOT_GENERATION_PROFILE:
			generation_profile = resource
		SLOT_EXPORT_PROFILE:
			export_profile = resource
	var assigned_resource := asset_for_slot(slot_id)
	if assigned_resource == null:
		_asset_sources.erase(slot_id)
		_asset_source_badges.erase(slot_id)
	else:
		_asset_sources[slot_id] = next_source
		_asset_source_badges[slot_id] = next_badge
	asset_changed.emit(slot_id)
