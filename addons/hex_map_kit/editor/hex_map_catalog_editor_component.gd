@tool
class_name HexMapCatalogEditorComponent
extends RefCounted

const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")
const HexMapValidationResult = preload("res://addons/hex_map_kit/adapter/hex_map_validation_result.gd")
const HexTileCatalogEntry = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_entry.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")
const HexTileCatalogValidator = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_validator.gd")

const SCREEN_SCRIPT := "hex_map_catalog_editor_component.gd"
const SCREEN_ROLE_SOURCE := "HexMapCatalogEditorComponent"
const TAB_NAME := "Catalog"


static func component_owner_rows() -> Array[Dictionary]:
	return [
		_component_owner("catalog_entry_list", "HexMapCatalogEditorComponent", "CatalogEntryList"),
		_component_owner("catalog_entry_detail", "HexMapCatalogEditorComponent", "CatalogEntryDetail"),
		_component_owner("catalog_entry_create", "HexMapCatalogEditorComponent", "CatalogEntryCreateActions"),
		_component_owner("catalog_entry_validate", "HexMapCatalogEditorComponent", "CatalogEntryValidation"),
	]


static func validation_result(catalog: HexTileCatalogResource):
	return HexTileCatalogValidator.validate_catalog(catalog)


static func validation_status(catalog: HexTileCatalogResource) -> Dictionary:
	if catalog == null:
		return {
			"available": false,
			"status_text": "No Tile Catalog selected.",
			"errors": 0,
			"warnings": 0,
			"issue_count": 0,
		}
	var result: HexMapValidationResult = validation_result(catalog)
	return {
		"available": true,
		"status_text": "Catalog OK" if result.issue_count() == 0 else "Catalog issues: %d" % result.issue_count(),
		"errors": result.error_count(),
		"warnings": result.warning_count(),
		"issue_count": result.issue_count(),
	}


static func validation_summary(catalog: HexTileCatalogResource, validation = null) -> Dictionary:
	var result = validation if validation != null else validation_result(catalog)
	if result == null:
		return {}
	return {
		"errors": result.error_count(),
		"warnings": result.warning_count(),
		"issues": result.issue_count(),
		"entries": int(result.summary.get("entries", 0)),
		"tile_set_present": bool(result.summary.get("tile_set_present", false)),
	}


static func status_by_entry_index(validation) -> Dictionary:
	var statuses := {}
	if validation == null:
		return statuses
	for issue in validation.issues:
		if not issue is Dictionary:
			continue
		var metadata = issue.get("metadata", {})
		if not metadata is Dictionary or not metadata.has("entry_index"):
			continue
		var entry_index := int(metadata.get("entry_index", -1))
		if entry_index < 0:
			continue
		var severity := String(issue.get("severity", ""))
		if severity == HexMapValidationResult.SEVERITY_ERROR:
			statuses[entry_index] = "error"
		elif not statuses.has(entry_index):
			statuses[entry_index] = "warning"
	return statuses


static func entry_rows(catalog: HexTileCatalogResource) -> Array[Dictionary]:
	if catalog == null:
		return []
	var rows: Array[Dictionary] = []
	for entry in catalog.entries:
		rows.append(entry_detail_from_entry(catalog, entry))
	return rows


static func paint_entry_rows(catalog: HexTileCatalogResource, validation = null) -> Array[Dictionary]:
	if catalog == null:
		return []
	var status_by_index := status_by_entry_index(validation)
	var rows: Array[Dictionary] = []
	for index in range(catalog.entries.size()):
		var entry = catalog.entries[index]
		if entry == null:
			rows.append({
				"key": "<missing>",
				"type": "",
				"preview": "",
				"tags": "",
				"status": String(status_by_index.get(index, "warning")),
			})
			continue
		rows.append({
			"key": String(entry.get("key")),
			"type": String(entry.get("entry_type")),
			"preview": paint_preview_text(entry),
			"tags": paint_tags_text(entry),
			"status": String(status_by_index.get(index, "ok")),
		})
	return rows


static func entry_detail(catalog: HexTileCatalogResource, entry_key: String = "") -> Dictionary:
	if catalog == null:
		return missing_entry_detail("No Tile Catalog selected.")
	if catalog.entries.is_empty():
		return missing_entry_detail("No catalog entries yet.")
	var selected_key := entry_key.strip_edges()
	var entry = null
	if selected_key != "":
		entry = catalog.entry_for_key(selected_key)
	else:
		entry = catalog.entries[0]
	if entry == null:
		return missing_entry_detail("Catalog entry is missing: %s." % selected_key)
	return entry_detail_from_entry(catalog, entry)


static func entry_detail_from_entry(catalog: HexTileCatalogResource, entry) -> Dictionary:
	if entry == null:
		return missing_entry_detail("Catalog entry resource is missing.")
	var key := String(entry_value(entry, "key", ""))
	var display_name := String(entry_value(entry, "display_name", ""))
	var entry_type := String(entry_value(entry, "entry_type", ""))
	var tags := entry_tags(entry)
	var preview := entry_preview(catalog, entry)
	var meaning := display_name if display_name != "" else key
	if meaning == "":
		meaning = "<unnamed entry>"
	return {
		"present": true,
		"key": key,
		"display_name": display_name,
		"meaning": meaning,
		"type": entry_type,
		"type_label": entry_type_label(entry_type),
		"tags": tags,
		"tag_text": _join_text(tags, ", "),
		"status": entry_status(catalog, entry),
		"preview": preview,
		"preview_available": bool(preview.get("available", false)),
		"preview_kind": String(preview.get("kind", "")),
		"preview_text": String(preview.get("text", "")),
		"preview_unavailable_reason": String(preview.get("unavailable_reason", "")),
		"metadata": {
			"source_id": int(entry_value(entry, "source_id", 0)),
			"atlas_coords": entry_value(entry, "atlas_coords", Vector2i.ZERO),
			"alternative_tile": int(entry_value(entry, "alternative_tile", 0)),
			"scene_resource_path": entry_scene_path(entry),
		},
		"raw_coordinate_controls_primary": false,
	}


static func missing_entry_detail(reason: String) -> Dictionary:
	return {
		"present": false,
		"key": "",
		"display_name": "",
		"meaning": "",
		"type": "",
		"type_label": "None",
		"tags": PackedStringArray(),
		"tag_text": "",
		"status": "missing",
		"preview": {
			"available": false,
			"kind": "none",
			"text": "",
			"unavailable_reason": reason,
		},
		"preview_available": false,
		"preview_kind": "none",
		"preview_text": "",
		"preview_unavailable_reason": reason,
		"metadata": {},
		"raw_coordinate_controls_primary": false,
	}


static func entry_preview(catalog: HexTileCatalogResource, entry) -> Dictionary:
	var entry_type := String(entry_value(entry, "entry_type", ""))
	match entry_type:
		HexTileCatalogEntry.TYPE_ATLAS:
			if catalog == null or catalog.tile_set == null:
				return preview_unavailable("tile", "TileSet is not assigned.")
			var source_id := int(entry_value(entry, "source_id", 0))
			if not catalog.tile_set.has_source(source_id):
				return preview_unavailable("tile", "TileSet source %d is missing." % source_id)
			return {
				"available": true,
				"kind": "tile",
				"text": "Tile source %d at %s" % [
					source_id,
					atlas_text(entry_value(entry, "atlas_coords", Vector2i.ZERO)),
				],
				"unavailable_reason": "",
			}
		HexTileCatalogEntry.TYPE_SCENE:
			var scene = entry_value(entry, "scene", null)
			if not scene is PackedScene:
				return preview_unavailable("scene", "PackedScene is not assigned.")
			return {
				"available": true,
				"kind": "scene",
				"text": "Scene %s" % entry_scene_path(entry),
				"unavailable_reason": "",
			}
		HexTileCatalogEntry.TYPE_PLACEHOLDER:
			return preview_unavailable("placeholder", "Placeholder entry has no preview.")
	return preview_unavailable("invalid", "Entry type is not recognized.")


static func preview_unavailable(kind: String, reason: String) -> Dictionary:
	return {
		"available": false,
		"kind": kind,
		"text": "",
		"unavailable_reason": reason,
	}


static func entry_status(catalog: HexTileCatalogResource, entry) -> String:
	var preview := entry_preview(catalog, entry)
	return "ok" if bool(preview.get("available", false)) else "warning"


static func entry_type_label(entry_type: String) -> String:
	match entry_type:
		HexTileCatalogEntry.TYPE_ATLAS:
			return "Tile"
		HexTileCatalogEntry.TYPE_SCENE:
			return "Scene"
		HexTileCatalogEntry.TYPE_PLACEHOLDER:
			return "Placeholder"
	return "Invalid"


static func entry_tags(entry) -> PackedStringArray:
	var tags = entry_value(entry, "tags", PackedStringArray())
	if tags is PackedStringArray:
		return tags
	if tags is Array:
		var result := PackedStringArray()
		for tag in tags:
			result.append(String(tag))
		return result
	return PackedStringArray()


static func entry_scene_path(entry) -> String:
	var scene = entry_value(entry, "scene", null)
	if scene is PackedScene:
		var path := String((scene as PackedScene).resource_path)
		return path if path != "" else "unsaved PackedScene"
	return ""


static func atlas_text(value) -> String:
	if value is Vector2i:
		return "(%d,%d)" % [value.x, value.y]
	return str(value)


static func entry_value(entry, property: String, fallback = null):
	if entry == null:
		return fallback
	var value = entry.get(property)
	return fallback if value == null else value


static func paint_preview_text(entry) -> String:
	var entry_type := String(entry_value(entry, "entry_type", ""))
	if entry_type == HexTileCatalogEntry.TYPE_ATLAS:
		return "tile %d %s alt %d" % [
			int(entry_value(entry, "source_id", 0)),
			atlas_text(entry_value(entry, "atlas_coords", Vector2i.ZERO)),
			int(entry_value(entry, "alternative_tile", 0)),
		]
	if entry_type == HexTileCatalogEntry.TYPE_SCENE:
		var scene = entry_value(entry, "scene", null)
		return "scene" if scene is PackedScene else "missing scene"
	if entry_type == HexTileCatalogEntry.TYPE_PLACEHOLDER:
		return "placeholder"
	return "invalid"


static func paint_tags_text(entry) -> String:
	return ",".join(entry_tags(entry))


static func paint_status_text(catalog: HexTileCatalogResource, validation = null) -> String:
	if catalog == null:
		return "No catalog selected."
	var result = validation if validation != null else validation_result(catalog)
	var label := String(catalog.display_name if catalog.display_name != "" else catalog.catalog_id)
	if label == "":
		label = "unnamed catalog"
	return "%s entries=%d TileSet=%s errors=%d warnings=%d" % [
		label,
		catalog.entries.size(),
		"yes" if catalog.tile_set != null else "no",
		result.error_count() if result != null else 0,
		result.warning_count() if result != null else 0,
	]


static func set_tile_set(catalog: HexTileCatalogResource, tile_set: TileSet) -> Dictionary:
	if catalog == null or tile_set == null:
		return action_result(false, ERR_INVALID_PARAMETER, "")
	catalog.tile_set = tile_set
	return {
		"ok": true,
		"error": OK,
		"slot_id": HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		"resource": catalog,
		"tile_set": tile_set,
	}


static func create_atlas_entry(
	catalog: HexTileCatalogResource,
	key: String,
	tile_set: TileSet,
	source_id: int,
	atlas_coords: Vector2i,
	alternative_tile: int = 0
) -> Dictionary:
	var entry_key := key.strip_edges()
	if catalog == null or tile_set == null or entry_key == "":
		return action_result(false, ERR_INVALID_PARAMETER, "")
	catalog.tile_set = tile_set
	var entry := HexTileCatalogEntry.new()
	entry.key = entry_key
	entry.display_name = entry_key
	entry.entry_type = HexTileCatalogEntry.TYPE_ATLAS
	entry.source_id = source_id
	entry.atlas_coords = atlas_coords
	entry.alternative_tile = alternative_tile
	catalog.add_entry(entry)
	return {
		"ok": true,
		"error": OK,
		"slot_id": HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		"resource": catalog,
		"entry": entry,
	}


static func create_scene_entry(
	catalog: HexTileCatalogResource,
	key: String,
	scene: PackedScene,
	source_id: int = 1,
	scene_tile_id: int = 1
) -> Dictionary:
	var entry_key := key.strip_edges()
	if catalog == null or scene == null or entry_key == "":
		return action_result(false, ERR_INVALID_PARAMETER, "")
	if catalog.tile_set == null:
		catalog.tile_set = TileSet.new()
	var scene_source = null
	if catalog.tile_set.has_source(source_id):
		scene_source = catalog.tile_set.get_source(source_id) as TileSetScenesCollectionSource
	if scene_source == null:
		scene_source = TileSetScenesCollectionSource.new()
		catalog.tile_set.add_source(scene_source, source_id)
	if not scene_source.has_scene_tile_id(scene_tile_id):
		scene_source.create_scene_tile(scene, scene_tile_id)
	var entry := HexTileCatalogEntry.new()
	entry.key = entry_key
	entry.display_name = entry_key
	entry.entry_type = HexTileCatalogEntry.TYPE_SCENE
	entry.source_id = source_id
	entry.atlas_coords = Vector2i(scene_tile_id, 0)
	entry.scene = scene
	catalog.add_entry(entry)
	return {
		"ok": true,
		"error": OK,
		"slot_id": HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		"resource": catalog,
		"entry": entry,
	}


static func action_result(ok: bool, error: int, path: String) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"slot_id": HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		"path": path,
		"resource": null,
	}


static func _component_owner(component_id: String, component_class: String, responsibility: String) -> Dictionary:
	return {
		"tab": TAB_NAME,
		"component_id": component_id,
		"component_class": component_class,
		"responsibility": responsibility,
		"screen_script": SCREEN_SCRIPT,
		"screen_role_source": SCREEN_ROLE_SOURCE,
	}


static func _join_text(values: PackedStringArray, separator: String) -> String:
	var parts: Array[String] = []
	for value in values:
		parts.append(String(value))
	return separator.join(parts)
