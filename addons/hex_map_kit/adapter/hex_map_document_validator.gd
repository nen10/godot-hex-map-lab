class_name HexMapDocumentValidator
extends RefCounted

const HexMapDocumentAdapterScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapDocumentDependencyResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_dependency_resource.gd")
const HexMapValidationResultScript = preload("res://addons/hex_map_kit/adapter/hex_map_validation_result.gd")
const HexTileCatalogEntryScript = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_entry.gd")
const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")

const RULE_PAYLOAD_OUTSIDE_MAP := "document.payload_outside_map"
const RULE_ORPHAN_PAYLOAD := "document.orphan_payload"
const RULE_CATALOG_MISSING := "document.catalog_missing"
const RULE_TILE_MISSING := "document.tile_missing"
const RULE_DEPENDENCY_MISSING := "document.dependency_missing"
const RULE_OBJECT_ON_WALL := "document.object_on_wall"


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
	_validate_tile_entries(result, document, cell_set, options)
	_validate_object_entries(result, document, cell_set, wall_set)
	_validate_label_entries(result, document, cell_set)
	_validate_dependencies(result, document)
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


static func _validate_catalog_tile_entry(result, entry: Dictionary, catalog, tile_set: TileSet) -> void:
	var catalog_key = String(entry.get("catalog_key", ""))
	var kind = String(entry.get("kind", ""))
	if catalog_key == "" and kind == HexMapDocumentAdapterScript.KIND_OVERLAY:
		catalog_key = String(entry.get("item_key", ""))
	if catalog_key == "":
		return
	var details = {
		"cell": entry.get("cell", Vector3i.ZERO),
		"metadata": {
			"kind": kind,
			"catalog_key": catalog_key,
		},
	}
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
	if tile_set == null:
		result.add_error(
			RULE_TILE_MISSING,
			"TileSet is missing for catalog tile key: %s." % catalog_key,
			HexMapValidationResultScript.SCOPE_DEPENDENCY,
			details
		)
		return
	_validate_catalog_entry_tile(result, catalog_entry, tile_set, details)


static func _validate_catalog_entry_tile(result, entry, tile_set: TileSet, details: Dictionary) -> void:
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
	var entry_type = String(entry.get("entry_type"))
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
		var scene_path = String(entry.get("scene_path"))
		if scene_path == "" or not ResourceLoader.exists(scene_path):
			result.add_error(RULE_TILE_MISSING, "Catalog scene tile resource is missing.", HexMapValidationResultScript.SCOPE_DEPENDENCY, details)


static func _validate_object_entries(result, document, cell_set: Dictionary, wall_set: Dictionary) -> void:
	for entry in HexMapDocumentAdapterScript.document_object_entries(document):
		var cell = entry.get("cell", Vector3i.ZERO)
		var hex = _hex_from_component(cell)
		var details = {
			"cell": cell,
			"object_id": String(entry.get("object_id", "")),
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
		var path = String(dependency.get("dependency_path"))
		if required and (path == "" or not ResourceLoader.exists(path)):
			result.add_error(
				RULE_DEPENDENCY_MISSING,
				"Required dependency is missing: %s." % path,
				HexMapValidationResultScript.SCOPE_DEPENDENCY,
				{
					"dependency_path": path,
					"metadata": {
						"kind": String(dependency.get("kind")),
						"dependency_id": String(dependency.get("dependency_id")),
					},
				}
			)


static func _hex_from_component(component: Vector3i):
	return HexVectorScript.apply_basis(component.x, component.y, component.z)


static func _update_counts(result) -> void:
	result.summary["errors"] = result.error_count()
	result.summary["warnings"] = result.warning_count()
