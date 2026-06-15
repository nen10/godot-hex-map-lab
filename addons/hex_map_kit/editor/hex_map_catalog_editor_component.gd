@tool
class_name HexMapCatalogEditorComponent
extends RefCounted

const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")
const HexMapValidationResult = preload("res://addons/hex_map_kit/adapter/hex_map_validation_result.gd")
const HexTileCatalogEntry = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_entry.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")
const HexTileCatalogValidator = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_validator.gd")
const HexTileCatalogPreviewControl = preload("res://addons/hex_map_kit/editor/hex_tile_catalog_preview_control.gd")

const SCREEN_SCRIPT := "hex_map_catalog_editor_component.gd"
const SCREEN_ROLE_SOURCE := "HexMapCatalogEditorComponent"
const TAB_NAME := "Catalog"


static func component_owner_rows() -> Array[Dictionary]:
	return [
		_component_owner("catalog_entry_list", "HexMapCatalogEditorComponent", "CatalogEntryList"),
		_component_owner("catalog_entry_detail", "HexMapCatalogEditorComponent", "CatalogEntryDetail"),
		_component_owner("catalog_entry_preview", "HexMapCatalogEditorComponent", "CatalogEntryPreview"),
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


static func visual_board(
	catalog: HexTileCatalogResource,
	selected_key: String = "",
	source: String = HexMapWorkspaceAssetContext.SOURCE_NONE,
	source_badge: String = ""
) -> Dictionary:
	var cards := entry_cards(catalog, source, source_badge)
	var actual_selected_key := selected_key.strip_edges()
	if actual_selected_key == "" and not cards.is_empty():
		actual_selected_key = String(cards[0].get("key", ""))
	for index in range(cards.size()):
		cards[index]["selected"] = String(cards[index].get("key", "")) == actual_selected_key
	var empty_cta := catalog_board_empty_cta(catalog, cards)
	return {
		"surface_id": "catalog_visual_board",
		"visible": true,
		"primary": true,
		"cards": cards,
		"card_count": cards.size(),
		"card_keys": _card_keys(cards),
		"tile_card_count": _card_count_for_kind(cards, "tile"),
		"object_card_count": _card_count_for_kind(cards, "object"),
		"tile_object_unified": _card_count_for_kind(cards, "tile") > 0 and _card_count_for_kind(cards, "object") > 0,
		"selected_key": actual_selected_key,
		"raw_source_id_visible": false,
		"raw_atlas_coords_visible": false,
		"raw_metadata_in_tooltip": true,
		"sample_tutorial_source_separated": source == HexMapWorkspaceAssetContext.SOURCE_SAMPLE,
		"production_cards_count": 0 if source == HexMapWorkspaceAssetContext.SOURCE_SAMPLE else cards.size(),
		"tutorial_cards_count": cards.size() if source == HexMapWorkspaceAssetContext.SOURCE_SAMPLE else 0,
		"source_group": _board_source_group(source),
		"source_badge": source_badge,
		"empty_cta": empty_cta,
	}


static func entry_cards(
	catalog: HexTileCatalogResource,
	source: String = HexMapWorkspaceAssetContext.SOURCE_NONE,
	source_badge: String = ""
) -> Array[Dictionary]:
	if catalog == null:
		return []
	var cards: Array[Dictionary] = []
	for entry in catalog.entries:
		var detail := entry_detail_from_entry(catalog, entry)
		cards.append(_entry_card_from_detail(detail, source, source_badge))
	return cards


static func catalog_board_empty_cta(catalog: HexTileCatalogResource, cards: Array) -> Dictionary:
	var visible := catalog == null or cards.is_empty()
	return {
		"visible": visible,
		"actions": PackedStringArray([
			"Create Catalog",
			"Choose Catalog",
			"Open sample",
		]) if visible else PackedStringArray(),
		"primary_action": "Create Catalog" if visible else "",
	}


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
		"preview_render_kind": String(preview.get("render_kind", "")),
		"preview_text": String(preview.get("text", "")),
		"preview_unavailable_reason": String(preview.get("unavailable_reason", "")),
		"preview_badge": preview.get("badge", {}),
		"preview_badge_text": String(preview.get("badge_text", "")),
		"preview_badge_tooltip": String(preview.get("badge_tooltip", "")),
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
			"render_kind": HexTileCatalogPreviewControl.RENDER_UNAVAILABLE,
			"text": "",
			"unavailable_reason": reason,
			"badge": _preview_badge(false, reason),
			"badge_text": "Preview unavailable",
			"badge_tooltip": reason,
			"sample_source": false,
		},
		"preview_available": false,
		"preview_kind": "none",
		"preview_render_kind": HexTileCatalogPreviewControl.RENDER_UNAVAILABLE,
		"preview_text": "",
		"preview_unavailable_reason": reason,
		"preview_badge": _preview_badge(false, reason),
		"preview_badge_text": "Preview unavailable",
		"preview_badge_tooltip": reason,
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
			var source = catalog.tile_set.get_source(source_id)
			if not source is TileSetAtlasSource:
				return preview_unavailable("tile", "TileSet source %d is not an atlas source." % source_id)
			var atlas_source := source as TileSetAtlasSource
			var atlas_coords: Vector2i = entry_value(entry, "atlas_coords", Vector2i.ZERO)
			if not atlas_source.has_tile(atlas_coords):
				return preview_unavailable("tile", "Atlas tile %s is missing." % atlas_text(atlas_coords))
			return atlas_preview(catalog.tile_set, atlas_source, entry)
		HexTileCatalogEntry.TYPE_SCENE:
			var scene = entry_value(entry, "scene", null)
			if not scene is PackedScene:
				return preview_unavailable("scene", "PackedScene is not assigned.")
			return scene_preview(entry)
		HexTileCatalogEntry.TYPE_PLACEHOLDER:
			return preview_unavailable("placeholder", "Placeholder entry has no preview.")
	return preview_unavailable("invalid", "Entry type is not recognized.")


static func atlas_preview(tile_set: TileSet, atlas_source: TileSetAtlasSource, entry) -> Dictionary:
	var source_id := int(entry_value(entry, "source_id", 0))
	var atlas_coords: Vector2i = entry_value(entry, "atlas_coords", Vector2i.ZERO)
	var alternative_tile := int(entry_value(entry, "alternative_tile", 0))
	var region_size := atlas_source.texture_region_size
	var region := Rect2(
		Vector2(atlas_coords.x * region_size.x, atlas_coords.y * region_size.y),
		Vector2(region_size)
	)
	var text := "Tile source %d at %s" % [source_id, atlas_text(atlas_coords)]
	var badge := _preview_badge(true, "Atlas tile preview")
	return {
		"available": true,
		"kind": "tile",
		"render_kind": HexTileCatalogPreviewControl.RENDER_ATLAS_TEXTURE_REGION,
		"text": text,
		"unavailable_reason": "",
		"badge": badge,
		"badge_text": String(badge.get("text", "")),
		"badge_tooltip": String(badge.get("tooltip", "")),
		"sample_source": false,
		"tile_set": tile_set,
		"source_id": source_id,
		"atlas_coords": atlas_coords,
		"alternative_tile": alternative_tile,
		"texture": atlas_source.texture,
		"texture_region": region,
		"texture_region_size": region_size,
	}


static func scene_preview(entry) -> Dictionary:
	var scene = entry_value(entry, "scene", null) as PackedScene
	var root_type := _scene_root_type(scene)
	var scene_tile_id := -1
	var atlas_coords = entry_value(entry, "atlas_coords", Vector2i(-1, 0))
	if atlas_coords is Vector2i:
		scene_tile_id = int(atlas_coords.x)
	var text := "Scene %s" % root_type
	var badge := _preview_badge(true, "Scene preview")
	return {
		"available": true,
		"kind": "scene",
		"render_kind": HexTileCatalogPreviewControl.RENDER_SCENE_RESOURCE,
		"text": text,
		"unavailable_reason": "",
		"badge": badge,
		"badge_text": String(badge.get("text", "")),
		"badge_tooltip": String(badge.get("tooltip", "")),
		"sample_source": false,
		"scene": scene,
		"scene_resource_path": entry_scene_path(entry),
		"scene_root_type": root_type,
		"scene_tile_id": scene_tile_id,
	}


static func preview_unavailable(kind: String, reason: String) -> Dictionary:
	var badge := _preview_badge(false, reason)
	return {
		"available": false,
		"kind": kind,
		"render_kind": HexTileCatalogPreviewControl.RENDER_UNAVAILABLE,
		"text": "",
		"unavailable_reason": reason,
		"badge": badge,
		"badge_text": String(badge.get("text", "")),
		"badge_tooltip": String(badge.get("tooltip", "")),
		"sample_source": false,
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


static func _scene_root_type(scene: PackedScene) -> String:
	if scene == null:
		return "PackedScene"
	if scene.can_instantiate():
		var instance := scene.instantiate()
		if instance != null:
			var result := instance.get_class()
			instance.free()
			return result
	return "PackedScene"


static func _preview_badge(available: bool, tooltip: String) -> Dictionary:
	return {
		"available": available,
		"text": "Preview ready" if available else "Preview unavailable",
		"tone": "ok" if available else "warning",
		"tooltip": tooltip,
	}


static func atlas_text(value) -> String:
	if value is Vector2i:
		return "(%d,%d)" % [value.x, value.y]
	return str(value)


static func _entry_card_from_detail(
	detail: Dictionary,
	source: String,
	source_badge: String
) -> Dictionary:
	var metadata = detail.get("metadata", {}) as Dictionary
	var preview = detail.get("preview", {}) as Dictionary
	var badge = detail.get("preview_badge", {}) as Dictionary
	var asset_kind := _board_asset_kind(String(detail.get("type", "")))
	var raw_tooltip := _raw_metadata_tooltip(metadata)
	return {
		"id": String(detail.get("key", "")),
		"key": String(detail.get("key", "")),
		"title": String(detail.get("meaning", "")),
		"asset_kind": asset_kind,
		"type_label": String(detail.get("type_label", "")),
		"preview": preview.duplicate(true),
		"preview_available": bool(detail.get("preview_available", false)),
		"preview_render_kind": String(detail.get("preview_render_kind", "")),
		"badge_text": String(detail.get("preview_badge_text", "")),
		"badge_tone": String(badge.get("tone", "")),
		"missing": not bool(detail.get("preview_available", false)),
		"missing_badge": not bool(detail.get("preview_available", false)),
		"source_group": _board_source_group(source),
		"source_badge": source_badge,
		"sample_source": source == HexMapWorkspaceAssetContext.SOURCE_SAMPLE,
		"raw_source_id_visible": false,
		"raw_atlas_coords_visible": false,
		"raw_metadata_tooltip": raw_tooltip,
		"card_tooltip": raw_tooltip,
		"selected": false,
	}


static func _board_asset_kind(entry_type: String) -> String:
	match entry_type:
		HexTileCatalogEntry.TYPE_ATLAS:
			return "tile"
		HexTileCatalogEntry.TYPE_SCENE:
			return "object"
		HexTileCatalogEntry.TYPE_PLACEHOLDER:
			return "placeholder"
	return "invalid"


static func _board_source_group(source: String) -> String:
	return "tutorial_sample" if source == HexMapWorkspaceAssetContext.SOURCE_SAMPLE else "production"


static func _raw_metadata_tooltip(metadata: Dictionary) -> String:
	var parts := PackedStringArray()
	if metadata.has("source_id"):
		parts.append("source_id: %d" % int(metadata.get("source_id", 0)))
	if metadata.has("atlas_coords"):
		parts.append("atlas_coords: %s" % atlas_text(metadata.get("atlas_coords", Vector2i.ZERO)))
	if metadata.has("alternative_tile"):
		parts.append("alternative_tile: %d" % int(metadata.get("alternative_tile", 0)))
	var scene_path := String(metadata.get("scene_resource_path", ""))
	if scene_path != "":
		parts.append("scene: %s" % scene_path)
	return "\n".join(parts)


static func _card_keys(cards: Array) -> PackedStringArray:
	var keys := PackedStringArray()
	for card in cards:
		if card is Dictionary:
			keys.append(String((card as Dictionary).get("key", "")))
	return keys


static func _card_count_for_kind(cards: Array, asset_kind: String) -> int:
	var count := 0
	for card in cards:
		if card is Dictionary and String((card as Dictionary).get("asset_kind", "")) == asset_kind:
			count += 1
	return count


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
