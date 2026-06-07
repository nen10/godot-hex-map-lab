class_name HexTileCatalogValidator
extends RefCounted

const HexMapValidationResultScript = preload("res://addons/hex_map_kit/adapter/hex_map_validation_result.gd")
const HexTileCatalogEntryScript = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_entry.gd")

const RULE_CATALOG_MISSING := "catalog.missing"
const RULE_TILE_SET_MISSING := "catalog.tile_set_missing"
const RULE_ENTRY_MISSING := "catalog.entry_missing"
const RULE_ENTRY_KEY_MISSING := "catalog.entry_key_missing"
const RULE_ENTRY_KEY_DUPLICATE := "catalog.entry_key_duplicate"
const RULE_ENTRY_TYPE_INVALID := "catalog.entry_type_invalid"
const RULE_SOURCE_MISSING := "catalog.source_missing"
const RULE_SOURCE_TYPE_MISMATCH := "catalog.source_type_mismatch"
const RULE_ATLAS_COORDS_INVALID := "catalog.atlas_coords_invalid"
const RULE_ALTERNATIVE_TILE_INVALID := "catalog.alternative_tile_invalid"
const RULE_SCENE_MISSING := "catalog.scene_missing"


static func validate_catalog(catalog, tile_set: TileSet = null):
	var result = HexMapValidationResultScript.new()
	var active_tile_set = tile_set if tile_set != null else _catalog_tile_set(catalog)
	result.summary = {
		"catalog_id": String(catalog.get("catalog_id")) if catalog != null else "",
		"entries": catalog.entries.size() if catalog != null else 0,
		"tile_set_present": active_tile_set != null,
		"errors": 0,
		"warnings": 0,
	}
	if catalog == null:
		result.add_error(RULE_CATALOG_MISSING, "Tile catalog is missing.", HexMapValidationResultScript.SCOPE_DEPENDENCY)
		_update_counts(result)
		return result

	if active_tile_set == null:
		result.add_error(RULE_TILE_SET_MISSING, "TileSet is missing for catalog validation.", HexMapValidationResultScript.SCOPE_DEPENDENCY)

	var seen_keys := {}
	for index in range(catalog.entries.size()):
		var entry = catalog.entries[index]
		if entry == null:
			result.add_warning(
				RULE_ENTRY_MISSING,
				"Catalog entry is missing.",
				HexMapValidationResultScript.SCOPE_DEPENDENCY,
				{"metadata": {"entry_index": index}}
			)
			continue
		_validate_entry(result, entry, active_tile_set, seen_keys, index)

	_update_counts(result)
	return result


static func catalog_key_tags_and_custom_data(catalog, key: String, tile_set: TileSet = null) -> Dictionary:
	if catalog == null:
		return {"tags": PackedStringArray(), "custom_data": {}}
	var active_tile_set = tile_set if tile_set != null else _catalog_tile_set(catalog)
	return entry_tags_and_custom_data(active_tile_set, catalog.entry_for_key(key))


static func entry_tags_and_custom_data(tile_set: TileSet, entry) -> Dictionary:
	var tags := PackedStringArray()
	if entry != null:
		tags = entry.tags
	return {
		"tags": tags,
		"custom_data": _entry_custom_data(tile_set, entry),
	}


static func _validate_entry(result, entry, tile_set: TileSet, seen_keys: Dictionary, index: int) -> void:
	var entry_key = String(entry.get("key"))
	var details = {"metadata": _entry_metadata(entry, index)}
	if entry_key == "":
		result.add_error(
			RULE_ENTRY_KEY_MISSING,
			"Catalog entry key is missing.",
			HexMapValidationResultScript.SCOPE_DEPENDENCY,
			details
		)
	elif seen_keys.has(entry_key):
		result.add_warning(
			RULE_ENTRY_KEY_DUPLICATE,
			"Catalog entry key is duplicated: %s." % entry_key,
			HexMapValidationResultScript.SCOPE_DEPENDENCY,
			details
		)
	else:
		seen_keys[entry_key] = true

	var entry_type = String(entry.get("entry_type"))
	if entry_type not in [
		HexTileCatalogEntryScript.TYPE_ATLAS,
		HexTileCatalogEntryScript.TYPE_SCENE,
		HexTileCatalogEntryScript.TYPE_PLACEHOLDER,
	]:
		result.add_error(
			RULE_ENTRY_TYPE_INVALID,
			"Catalog entry type is invalid: %s." % entry_type,
			HexMapValidationResultScript.SCOPE_DEPENDENCY,
			details
		)
		return

	if entry_type == HexTileCatalogEntryScript.TYPE_ATLAS:
		_validate_atlas_entry(result, entry, tile_set, details)
	elif entry_type == HexTileCatalogEntryScript.TYPE_SCENE:
		_validate_scene_entry(result, entry, tile_set, details)


static func _validate_atlas_entry(result, entry, tile_set: TileSet, details: Dictionary) -> void:
	if tile_set == null:
		return
	var source_id = int(entry.get("source_id"))
	if not _tile_set_has_source(tile_set, source_id):
		result.add_error(
			RULE_SOURCE_MISSING,
			"Catalog atlas source is missing: %d." % source_id,
			HexMapValidationResultScript.SCOPE_DEPENDENCY,
			details
		)
		return

	var source = tile_set.get_source(source_id)
	if not source is TileSetAtlasSource:
		result.add_error(
			RULE_SOURCE_TYPE_MISMATCH,
			"Catalog atlas entry source is not a TileSetAtlasSource.",
			HexMapValidationResultScript.SCOPE_DEPENDENCY,
			details
		)
		return

	var atlas_source = source as TileSetAtlasSource
	var atlas_coords: Vector2i = entry.get("atlas_coords")
	if not atlas_source.has_tile(atlas_coords):
		result.add_error(
			RULE_ATLAS_COORDS_INVALID,
			"Catalog atlas coordinates are not present in the source.",
			HexMapValidationResultScript.SCOPE_DEPENDENCY,
			details
		)
		return

	var alternative_tile = int(entry.get("alternative_tile"))
	if alternative_tile != 0 and atlas_source.has_method("has_alternative_tile"):
		if not atlas_source.has_alternative_tile(atlas_coords, alternative_tile):
			result.add_error(
				RULE_ALTERNATIVE_TILE_INVALID,
				"Catalog alternative tile is not present in the source.",
				HexMapValidationResultScript.SCOPE_DEPENDENCY,
				details
			)


static func _validate_scene_entry(result, entry, tile_set: TileSet, details: Dictionary) -> void:
	var scene = entry.get("scene")
	if not scene is PackedScene:
		result.add_error(
			RULE_SCENE_MISSING,
			"Catalog scene resource is missing.",
			HexMapValidationResultScript.SCOPE_DEPENDENCY,
			details
		)

	if tile_set == null:
		return

	var source_id = int(entry.get("source_id"))
	if not _tile_set_has_source(tile_set, source_id):
		result.add_error(
			RULE_SOURCE_MISSING,
			"Catalog scene source is missing: %d." % source_id,
			HexMapValidationResultScript.SCOPE_DEPENDENCY,
			details
		)
		return

	var source = tile_set.get_source(source_id)
	if not source is TileSetScenesCollectionSource:
		result.add_error(
			RULE_SOURCE_TYPE_MISMATCH,
			"Catalog scene entry source is not a TileSetScenesCollectionSource.",
			HexMapValidationResultScript.SCOPE_DEPENDENCY,
			details
		)
		return

	var scene_source = source as TileSetScenesCollectionSource
	var scene_tile_id = _scene_tile_id(entry)
	if scene_tile_id >= 0 and scene_source.has_method("has_scene_tile"):
		if not scene_source.has_scene_tile(scene_tile_id):
			result.add_error(
				RULE_ATLAS_COORDS_INVALID,
				"Catalog scene tile id is not present in the source.",
				HexMapValidationResultScript.SCOPE_DEPENDENCY,
				details
			)


static func _entry_custom_data(tile_set: TileSet, entry) -> Dictionary:
	var result := {}
	if tile_set == null or entry == null:
		return result
	if not entry.has_method("is_atlas_tile") or not entry.is_atlas_tile():
		return result
	var source_id = int(entry.get("source_id"))
	if not _tile_set_has_source(tile_set, source_id):
		return result
	var source = tile_set.get_source(source_id)
	if not source is TileSetAtlasSource:
		return result
	var atlas_source = source as TileSetAtlasSource
	var atlas_coords: Vector2i = entry.get("atlas_coords")
	if not atlas_source.has_tile(atlas_coords):
		return result
	var alternative_tile = int(entry.get("alternative_tile"))
	if alternative_tile != 0 and atlas_source.has_method("has_alternative_tile"):
		if not atlas_source.has_alternative_tile(atlas_coords, alternative_tile):
			return result
	var tile_data = atlas_source.get_tile_data(atlas_coords, alternative_tile)
	if tile_data == null:
		return result
	for layer_index in range(tile_set.get_custom_data_layers_count()):
		var layer_name = tile_set.get_custom_data_layer_name(layer_index)
		if layer_name == "":
			continue
		result[layer_name] = tile_data.get_custom_data(layer_name)
	return result


static func _tile_set_has_source(tile_set: TileSet, source_id: int) -> bool:
	return tile_set != null and source_id >= 0 and tile_set.has_source(source_id)


static func _catalog_tile_set(catalog) -> TileSet:
	if catalog == null:
		return null
	var resource = catalog.get("tile_set")
	return resource if resource is TileSet else null


static func _scene_tile_id(entry) -> int:
	var coords: Vector2i = entry.get("atlas_coords")
	return coords.x


static func _entry_metadata(entry, index: int) -> Dictionary:
	return {
		"entry_index": index,
		"entry_key": String(entry.get("key")),
		"entry_type": String(entry.get("entry_type")),
		"source_id": int(entry.get("source_id")),
		"atlas_coords": entry.get("atlas_coords"),
		"alternative_tile": int(entry.get("alternative_tile")),
		"scene_present": entry.get("scene") is PackedScene,
	}


static func _update_counts(result) -> void:
	result.summary["errors"] = result.error_count()
	result.summary["warnings"] = result.warning_count()
