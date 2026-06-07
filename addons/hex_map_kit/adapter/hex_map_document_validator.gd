class_name HexMapDocumentValidator
extends RefCounted

const HexMapDocumentAdapterScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapDocumentDependencyResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_dependency_resource.gd")
const HexGameplayLayerDataScript = preload("res://addons/hex_map_kit/adapter/hex_gameplay_layer_data.gd")
const HexMapValidationResultScript = preload("res://addons/hex_map_kit/adapter/hex_map_validation_result.gd")
const HexTileCatalogResourceScript = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")
const HexObjectDatabaseResourceScript = preload("res://addons/hex_map_kit/adapter/hex_object_database_resource.gd")
const HexLabelDatabaseResourceScript = preload("res://addons/hex_map_kit/adapter/hex_label_database_resource.gd")
const HexTileCatalogEntryScript = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_entry.gd")
const HexGridScript = preload("res://addons/hex_map_kit/core/hex_grid.gd")
const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")

const RULE_PAYLOAD_OUTSIDE_MAP := "document.payload_outside_map"
const RULE_ORPHAN_PAYLOAD := "document.orphan_payload"
const RULE_CATALOG_MISSING := "document.catalog_missing"
const RULE_TILE_ASSIGNMENT_MISSING := "document.tile_assignment_missing"
const RULE_TILE_MISSING := "document.tile_missing"
const RULE_DEPENDENCY_MISSING := "document.dependency_missing"
const RULE_DEPENDENCY_TYPE_MISMATCH := "document.dependency_type_mismatch"
const RULE_OBJECT_ON_WALL := "document.object_on_wall"
const RULE_OBJECT_SCENE_MISSING := "document.object_scene_missing"
const RULE_OBJECT_DUPLICATE_UNIQUE := "document.object_duplicate_unique"
const RULE_PROFILE_REACHABILITY := "movement.profile_reachability"


static func validate_document(document, options: Dictionary = {}):
	var result = HexMapValidationResultScript.new()
	var map_resource = HexMapDocumentAdapterScript.to_map_resource(document)
	var data = map_resource.to_map_data() if map_resource != null else null
	result.summary = {
		"cells": data.cells.size() if data != null else 0,
		"tile_entries": HexMapDocumentAdapterScript.document_tile_entries(document).size(),
		"objects": HexMapDocumentAdapterScript.document_object_entries(document).size(),
		"dependencies": document.dependencies.size() if document != null else 0,
		"errors": 0,
		"warnings": 0,
	}
	if data == null:
		result.add_error(
			"document.map_missing",
			"Document map is missing.",
			HexMapValidationResultScript.SCOPE_DOCUMENT
		)
		_update_counts(result)
		return result

	var cell_set = data.cell_set()
	var wall_set = data.wall_set()
	_validate_terrain_defaults(result, document, cell_set, wall_set, options)
	_validate_tile_entries(result, document, cell_set, options)
	_validate_object_entries(result, document, cell_set, wall_set, options)
	_validate_label_entries(result, document, cell_set)
	_validate_dependencies(result, document)
	_validate_profile_reachability(result, document, data, options)
	_update_counts(result)
	return result


static func _validate_tile_entries(result, document, cell_set: Dictionary, options: Dictionary) -> void:
	var catalog = options.get("tile_catalog", null)
	var tile_set = options.get("tile_set", null)
	for entry in HexMapDocumentAdapterScript.document_tile_entries(document):
		var cell = entry.get("cell", Vector3i.ZERO)
		var hex = _hex_from_component(cell)
		if not cell_set.has(hex.key()):
			result.add_error(
				RULE_PAYLOAD_OUTSIDE_MAP,
				"Tile payload is outside the document map.",
				HexMapValidationResultScript.SCOPE_CELL,
				{"cell": cell, "metadata": {"kind": String(entry.get("kind", ""))}}
			)
		_validate_catalog_tile_entry(result, entry, catalog, tile_set)


static func _validate_terrain_defaults(
	result,
	document,
	cell_set: Dictionary,
	wall_set: Dictionary,
	options: Dictionary
) -> void:
	var floor_count := max(0, cell_set.size() - wall_set.size())
	var wall_count := wall_set.size()
	if floor_count > 0:
		_validate_catalog_key(
			result,
			_default_terrain_key(document, "default_floor_key"),
			options.get("tile_catalog", null),
			options.get("tile_set", null),
			{
				"metadata": {
					"kind": HexMapDocumentAdapterScript.KIND_FLOOR,
					"role": "default_floor",
				},
			}
		)
	if wall_count > 0:
		_validate_catalog_key(
			result,
			_default_terrain_key(document, "default_wall_key"),
			options.get("tile_catalog", null),
			options.get("tile_set", null),
			{
				"metadata": {
					"kind": HexMapDocumentAdapterScript.KIND_WALL,
					"role": "default_wall",
				},
			}
		)


static func _validate_catalog_tile_entry(result, entry: Dictionary, catalog, tile_set: TileSet) -> void:
	var catalog_key = String(entry.get("catalog_key", ""))
	var kind = String(entry.get("kind", ""))
	if catalog_key == "" and kind == HexMapDocumentAdapterScript.KIND_OVERLAY:
		catalog_key = String(entry.get("item_key", ""))
	var details = {
		"cell": entry.get("cell", Vector3i.ZERO),
		"metadata": {
			"kind": kind,
			"catalog_key": catalog_key,
		},
	}
	_validate_catalog_key(result, catalog_key, catalog, tile_set, details)


static func _validate_catalog_key(
	result,
	catalog_key: String,
	catalog,
	tile_set: TileSet,
	details: Dictionary
) -> void:
	if catalog_key == "":
		result.add_error(
			RULE_TILE_ASSIGNMENT_MISSING,
			"Tile catalog key assignment is missing.",
			HexMapValidationResultScript.SCOPE_DEPENDENCY,
			details
		)
		return
	if catalog == null:
		result.add_error(
			RULE_CATALOG_MISSING,
			"Tile catalog is missing for document catalog key: %s." % catalog_key,
			HexMapValidationResultScript.SCOPE_DEPENDENCY,
			details
		)
		return
	if not catalog.has_method("entry_for_key") or catalog.entry_for_key(catalog_key) == null:
		result.add_error(
			RULE_TILE_MISSING,
			"Catalog tile key is missing: %s." % catalog_key,
			HexMapValidationResultScript.SCOPE_DEPENDENCY,
			details
		)
		return
	var catalog_entry = catalog.entry_for_key(catalog_key)
	var active_tile_set = tile_set if tile_set != null else _catalog_tile_set(catalog)
	if active_tile_set == null:
		result.add_error(
			RULE_TILE_MISSING,
			"TileSet is missing for catalog tile key: %s." % catalog_key,
			HexMapValidationResultScript.SCOPE_DEPENDENCY,
			details
		)
		return
	_validate_catalog_entry_tile(result, catalog_entry, active_tile_set, details)


static func _default_terrain_key(document, field_name: String) -> String:
	if document == null:
		return ""
	for layer in document.terrain_layers:
		if layer == null:
			continue
		var value = String(layer.get(field_name))
		if value != "":
			return value
	return ""


static func _validate_catalog_entry_tile(result, entry, tile_set: TileSet, details: Dictionary) -> void:
	var entry_type = String(entry.get("entry_type"))
	if entry_type == HexTileCatalogEntryScript.TYPE_PLACEHOLDER:
		result.add_error(RULE_TILE_MISSING, "Catalog key is a placeholder and has no drawable tile.", HexMapValidationResultScript.SCOPE_DEPENDENCY, details)
		return
	var source_id = int(entry.get("source_id"))
	if not tile_set.has_source(source_id):
		result.add_error(
			RULE_TILE_MISSING,
			"TileSet source is missing for catalog key: %s." % details["metadata"].get("catalog_key", ""),
			HexMapValidationResultScript.SCOPE_DEPENDENCY,
			details
		)
		return
	var source = tile_set.get_source(source_id)
	if entry_type == HexTileCatalogEntryScript.TYPE_ATLAS:
		if not source is TileSetAtlasSource:
			result.add_error(RULE_TILE_MISSING, "Catalog key source is not an atlas source.", HexMapValidationResultScript.SCOPE_DEPENDENCY, details)
			return
		var atlas_source = source as TileSetAtlasSource
		var atlas_coords: Vector2i = entry.get("atlas_coords")
		if not atlas_source.has_tile(atlas_coords):
			result.add_error(RULE_TILE_MISSING, "Catalog atlas tile is missing.", HexMapValidationResultScript.SCOPE_DEPENDENCY, details)
	elif entry_type == HexTileCatalogEntryScript.TYPE_SCENE:
		if not source is TileSetScenesCollectionSource:
			result.add_error(RULE_TILE_MISSING, "Catalog key source is not a scene collection source.", HexMapValidationResultScript.SCOPE_DEPENDENCY, details)
		if not entry.get("scene") is PackedScene:
			result.add_error(RULE_TILE_MISSING, "Catalog scene tile resource is missing.", HexMapValidationResultScript.SCOPE_DEPENDENCY, details)


static func _catalog_tile_set(catalog) -> TileSet:
	if catalog == null:
		return null
	var resource = catalog.get("tile_set")
	return resource if resource is TileSet else null


static func _validate_object_entries(result, document, cell_set: Dictionary, wall_set: Dictionary, options: Dictionary) -> void:
	var object_database = options.get("object_database", null)
	var require_object_scenes = bool(options.get("require_object_scenes", object_database != null))
	var unique_first_cells := {}
	for entry in HexMapDocumentAdapterScript.document_object_entries(document):
		var cell = entry.get("cell", Vector3i.ZERO)
		var hex = _hex_from_component(cell)
		var object_id = String(entry.get("object_id", ""))
		var definition = _object_definition(object_database, object_id)
		var details = {
			"cell": cell,
			"object_id": object_id,
		}
		if not cell_set.has(hex.key()):
			result.add_error(
				RULE_ORPHAN_PAYLOAD,
				"Object payload is not attached to a document map cell.",
				HexMapValidationResultScript.SCOPE_OBJECT,
				details
			)
		elif wall_set.has(hex.key()):
			result.add_error(
				RULE_OBJECT_ON_WALL,
				"Object payload is placed on a wall cell.",
				HexMapValidationResultScript.SCOPE_OBJECT,
				details
			)
		if require_object_scenes:
			var scene = _object_scene(entry, definition)
			if not scene is PackedScene:
				var scene_details = details.duplicate(true)
				scene_details["metadata"] = {"scene_present": false}
				result.add_error(
					RULE_OBJECT_SCENE_MISSING,
					"Object scene resource is missing: %s." % object_id,
					HexMapValidationResultScript.SCOPE_OBJECT,
					scene_details
				)
		if object_id != "" and _object_is_unique(entry, definition):
			if unique_first_cells.has(object_id):
				var duplicate_details = details.duplicate(true)
				duplicate_details["metadata"] = {
					"first_cell": unique_first_cells[object_id],
				}
				result.add_error(
					RULE_OBJECT_DUPLICATE_UNIQUE,
					"Unique object is placed more than once: %s." % object_id,
					HexMapValidationResultScript.SCOPE_OBJECT,
					duplicate_details
				)
			else:
				unique_first_cells[object_id] = cell


static func _object_definition(object_database, object_id: String):
	if object_database == null or object_id == "" or not object_database.has_method("definition_for_id"):
		return null
	return object_database.definition_for_id(object_id)


static func _object_scene(entry: Dictionary, definition):
	var scene = entry.get("scene", null)
	if scene is PackedScene:
		return scene
	if definition != null:
		var definition_scene = definition.get("scene")
		if definition_scene is PackedScene:
			return definition_scene
	return null


static func _object_is_unique(entry: Dictionary, definition) -> bool:
	var properties = entry.get("properties", {})
	if properties is Dictionary and bool((properties as Dictionary).get("unique", false)):
		return true
	if definition != null:
		var default_properties = definition.get("default_properties")
		if default_properties is Dictionary and bool((default_properties as Dictionary).get("unique", false)):
			return true
		var tags = definition.get("tags")
		if tags is PackedStringArray and tags.has("unique"):
			return true
		if tags is Array and tags.has("unique"):
			return true
	return false


static func _validate_label_entries(result, document, cell_set: Dictionary) -> void:
	for entry in HexMapDocumentAdapterScript.document_label_entries(document):
		var cell = entry.get("cell", Vector3i.ZERO)
		var hex = _hex_from_component(cell)
		if not cell_set.has(hex.key()):
			result.add_error(
				RULE_ORPHAN_PAYLOAD,
				"Label payload is not attached to a document map cell.",
				HexMapValidationResultScript.SCOPE_CELL,
				{"cell": cell, "metadata": {"label_id": String(entry.get("label_id", ""))}}
			)


static func _validate_dependencies(result, document) -> void:
	if document == null:
		return
	for dependency in document.dependencies:
		if not dependency is Resource:
			continue
		var required = bool(dependency.get("required"))
		var dependency_resource = dependency.get("resource")
		var details = {
			"dependency_resource_path": _dependency_resource_path(dependency_resource),
			"metadata": {
				"kind": String(dependency.get("kind")),
				"dependency_id": String(dependency.get("dependency_id")),
				"role": String(dependency.get("role")),
			},
		}
		if dependency_resource == null:
			if required:
				result.add_error(
					RULE_DEPENDENCY_MISSING,
					"Required dependency resource is missing.",
					HexMapValidationResultScript.SCOPE_DEPENDENCY,
					details
				)
			continue
		if not dependency_resource is Resource:
			result.add_error(
				RULE_DEPENDENCY_TYPE_MISMATCH,
				"Dependency value is not a Resource.",
				HexMapValidationResultScript.SCOPE_DEPENDENCY,
				details
			)
			continue
		if not _dependency_kind_matches(String(dependency.get("kind")), dependency_resource):
			result.add_error(
				RULE_DEPENDENCY_TYPE_MISMATCH,
				"Dependency resource type does not match kind: %s." % String(dependency.get("kind")),
				HexMapValidationResultScript.SCOPE_DEPENDENCY,
				details
			)


static func _dependency_kind_matches(kind: String, resource: Resource) -> bool:
	match kind:
		HexMapDocumentDependencyResourceScript.KIND_TILE_SET:
			return resource is TileSet
		HexMapDocumentDependencyResourceScript.KIND_TILE_CATALOG:
			return resource is HexTileCatalogResourceScript
		HexMapDocumentDependencyResourceScript.KIND_OBJECT_DATABASE:
			return resource is HexObjectDatabaseResourceScript
		HexMapDocumentDependencyResourceScript.KIND_LABEL_DATABASE:
			return resource is HexLabelDatabaseResourceScript
		HexMapDocumentDependencyResourceScript.KIND_SCENE:
			return resource is PackedScene
		HexMapDocumentDependencyResourceScript.KIND_SCRIPT:
			return resource is Script
		HexMapDocumentDependencyResourceScript.KIND_OTHER, _:
			return true


static func _dependency_resource_path(resource) -> String:
	if resource == null or not resource is Resource:
		return ""
	return String((resource as Resource).resource_path)


static func _validate_profile_reachability(result, document, data, options: Dictionary) -> void:
	var movement_profiles = _movement_profiles_from_options(options)
	if movement_profiles.is_empty():
		return
	var important_points = _important_points(document, options, data.cell_set())
	if important_points.size() < 2:
		return

	for movement_profile in movement_profiles:
		var profile_id = _profile_id(movement_profile)
		var gameplay = HexGameplayLayerDataScript.from_document(
			document,
			movement_profile,
			options.get("tile_catalog", null)
		)
		var passable_points: Array = []
		for point in important_points:
			if not gameplay.has_cell(point):
				continue
			if not gameplay.is_passable(point):
				result.add_error(
					RULE_PROFILE_REACHABILITY,
					"Important point is blocked by movement profile: %s." % profile_id,
					HexMapValidationResultScript.SCOPE_CELL,
					{
						"cell": _component_from_hex(point),
						"metadata": {
							"profile_id": profile_id,
							"reason": "blocked",
							"blockers": Array(gameplay.blocker_keys(point)),
						},
					}
				)
				continue
			passable_points.append(point)

		if passable_points.size() < 2:
			continue
		var anchor = passable_points[0]
		var reachable = HexGridScript.make_set(
			HexGridScript.connected_area(anchor, gameplay.passable_cells(), data.cyclic_size)
		)
		for index in range(1, passable_points.size()):
			var point = passable_points[index]
			if reachable.has(point.key()):
				continue
			result.add_error(
				RULE_PROFILE_REACHABILITY,
				"Important point is unreachable by movement profile: %s." % profile_id,
				HexMapValidationResultScript.SCOPE_CELL,
				{
					"cell": _component_from_hex(point),
					"metadata": {
						"profile_id": profile_id,
						"reason": "unreachable",
						"anchor_cell": _component_from_hex(anchor),
					},
				}
			)


static func _movement_profiles_from_options(options: Dictionary) -> Array:
	var result: Array = []
	if options.has("movement_profiles"):
		var profiles = options.get("movement_profiles", [])
		if profiles is Array:
			for profile in profiles:
				if profile != null:
					result.append(profile)
	if options.has("movement_profile") and options.get("movement_profile") != null:
		result.append(options.get("movement_profile"))
	return result


static func _important_points(document, options: Dictionary, cell_set: Dictionary) -> Array:
	var result: Array = []
	var seen := {}
	for point in options.get("important_points", []):
		_append_important_point(result, seen, _hex_from_value(point), cell_set)
	for entry in HexMapDocumentAdapterScript.document_object_entries(document):
		_append_important_point(result, seen, _hex_from_component(entry.get("cell", Vector3i.ZERO)), cell_set)
	for entry in HexMapDocumentAdapterScript.document_label_entries(document):
		_append_important_point(result, seen, _hex_from_component(entry.get("cell", Vector3i.ZERO)), cell_set)
	return result


static func _append_important_point(result: Array, seen: Dictionary, point, cell_set: Dictionary) -> void:
	if point == null:
		return
	var key = point.key()
	if seen.has(key):
		return
	if not cell_set.has(key):
		return
	seen[key] = true
	result.append(cell_set[key])


static func _profile_id(profile) -> String:
	if profile == null:
		return "default"
	var value = profile.get("profile_id")
	if value == null:
		return "default"
	return String(value)


static func _hex_from_value(value):
	if value is Vector3i:
		return _hex_from_component(value)
	if value is HexVectorScript:
		return HexVectorScript.apply_basis(value.q, value.s, value.r)
	return null


static func _hex_from_component(component: Vector3i):
	return HexVectorScript.apply_basis(component.x, component.y, component.z)


static func _component_from_hex(hex) -> Vector3i:
	return Vector3i(hex.q, hex.s, hex.r)


static func _update_counts(result) -> void:
	result.summary["errors"] = result.error_count()
	result.summary["warnings"] = result.warning_count()
