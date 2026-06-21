class_name HexMapDocumentAdapter
extends RefCounted

const HexMapDocumentResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapDocumentLabelPlacementResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_label_placement_resource.gd")
const HexMapDocumentObjectPlacementResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_object_placement_resource.gd")
const HexMapDocumentOverlayLayerResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_overlay_layer_resource.gd")
const HexMapDocumentTerrainLayerResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_terrain_layer_resource.gd")
const HexMapValidationResultScript = preload("res://addons/hex_map_kit/adapter/hex_map_validation_result.gd")
const HexMapResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexOverlayResourceScript = preload("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd")
const HexMapTileAdapterScript = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexMapDataScript = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")

const KIND_FLOOR := "floor"
const KIND_WALL := "wall"
const KIND_OVERLAY := "overlay"


static func from_map_resource(resource: HexMapResourceScript):
	var document = HexMapDocumentResourceScript.new()
	if resource != null:
		var terrain_layer = HexMapDocumentTerrainLayerResourceScript.new()
		terrain_layer.map = HexMapResourceScript.from_map_data(resource.to_map_data(), resource.orientation)
		document.terrain_layers.append(terrain_layer)
	return document


static func to_map_resource(document):
	var data = _document_map_data(document)
	if data == null:
		return HexMapResourceScript.from_map_data(HexMapDataScript.from_cells([]))
	return HexMapResourceScript.from_map_data(data, _document_orientation(document))


static func duplicate_document(document):
	var copy = HexMapDocumentResourceScript.new()
	if document != null:
		copy.terrain_layers = _duplicate_resources(document.terrain_layers)
		copy.overlay_layers = _duplicate_resources(document.overlay_layers)
		copy.object_placements = _duplicate_resources(document.object_placements)
		copy.label_placements = _duplicate_resources(document.label_placements)
		copy.zones = _duplicate_resources(document.zones)
		copy.dependencies = _duplicate_resources(document.dependencies)
		if document.metadata != null:
			copy.metadata = document.metadata.duplicate(true)
	return copy


static func document_summary(document) -> Dictionary:
	var data = _document_map_data(document)
	var cell_count = data.cells.size() if data != null else 0
	var wall_count = data.walls.size() if data != null else 0
	return {
		"cells": cell_count,
		"walls": wall_count,
		"floors": max(0, cell_count - wall_count),
		"objects": _document_object_count(document),
		"labels": _document_label_count(document),
		"zones": document.zones.size() if document != null else 0,
		"warnings": _baseline_warning_count(document),
		"dependencies": document.dependencies.size() if document != null else 0,
		"terrain_layers": document.terrain_layers.size() if document != null else 0,
		"overlay_layers": document.overlay_layers.size() if document != null else 0,
	}


static func document_tile_entries(document) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if document == null:
		return result
	for layer in document.terrain_layers:
		if layer == null:
			continue
		for raw_entry in layer.get("tile_assignments"):
			if raw_entry is Dictionary:
				result.append((raw_entry as Dictionary).duplicate(true))
	for layer in document.overlay_layers:
		if layer == null:
			continue
		for raw_entry in layer.get("tile_assignments"):
			if not raw_entry is Dictionary:
				continue
			var entry: Dictionary = (raw_entry as Dictionary).duplicate(true)
			entry["kind"] = KIND_OVERLAY
			if String(entry.get("item_key", "")) == "":
				entry["item_key"] = String(layer.get("item_key"))
			result.append(entry)
	return result


static func document_object_entries(document) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if document == null:
		return result
	for placement in document.object_placements:
		if placement is Resource:
			result.append(_object_placement_entry(placement as Resource))
	return result


static func document_label_entries(document) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if document == null:
		return result
	for placement in document.label_placements:
		if placement is Resource:
			result.append(_label_placement_entry(placement as Resource))
	return result


static func replace_cell_payloads(document, hex, tile_entries: Array, object_entries: Array, label_entries: Array) -> void:
	if document == null:
		return
	var normalized = _normalize_hex(hex)
	_remove_cell_display_payloads(document, normalized)
	for raw_entry in tile_entries:
		if raw_entry is Dictionary:
			set_tile_override(document, normalized, raw_entry as Dictionary)
	for raw_entry in object_entries:
		if raw_entry is Dictionary:
			set_object(document, normalized, raw_entry as Dictionary)
	for raw_entry in label_entries:
		if raw_entry is Dictionary:
			set_label(document, normalized, raw_entry as Dictionary)


static func validation_result_for_document(document):
	var result = HexMapValidationResultScript.new()
	result.summary = document_summary(document)
	if document == null:
		result.add_error(
			"document.missing",
			"Document is missing.",
			HexMapValidationResultScript.SCOPE_DOCUMENT
		)
		result.summary["errors"] = result.error_count()
		result.summary["warnings"] = result.warning_count()
		return result

	if _document_map_data(document) == null:
		result.add_warning(
			"document.map_missing",
			"Document has no map or terrain layer map.",
			HexMapValidationResultScript.SCOPE_DOCUMENT
		)
	if document.dependencies.is_empty():
		result.add_warning(
			"document.dependencies_empty",
			"Document has no dependency records.",
			HexMapValidationResultScript.SCOPE_DEPENDENCY
		)
	result.summary["errors"] = result.error_count()
	result.summary["warnings"] = result.warning_count()
	return result


static func copy_document_state(target, source) -> void:
	if target == null or source == null:
		return
	target.terrain_layers = _duplicate_resources(source.terrain_layers)
	target.overlay_layers = _duplicate_resources(source.overlay_layers)
	target.object_placements = _duplicate_resources(source.object_placements)
	target.label_placements = _duplicate_resources(source.label_placements)
	target.zones = _duplicate_resources(source.zones)
	target.dependencies = _duplicate_resources(source.dependencies)
	target.metadata = source.metadata.duplicate(true) if source.metadata != null else null


static func apply_to_tile_map_layer(document, layer, options: Dictionary = {}) -> Dictionary:
	var data = _document_map_data(document)
	if data == null or layer == null:
		return {
			"ok": false,
			"error": ERR_INVALID_PARAMETER,
			"cancelled": false,
			"blocked_reason": "Missing document map data or TileMap target.",
		}
	var flat_top = _document_orientation(document) == HexMapResourceScript.ORIENTATION_FLAT_TOP
	var tile_catalog = options.get("tile_catalog", null)
	var floor_catalog_key = String(options.get("floor_catalog_key", ""))
	if floor_catalog_key == "":
		floor_catalog_key = _document_default_terrain_key(document, "default_floor_key")
	var wall_catalog_key = String(options.get("wall_catalog_key", ""))
	if wall_catalog_key == "":
		wall_catalog_key = _document_default_terrain_key(document, "default_wall_key")
	var debug_numeric_fallback = bool(options.get("debug_numeric_fallback_enabled", false))
	var floor_config = HexMapTileAdapterScript.tile_config_from_catalog(tile_catalog, floor_catalog_key)
	var wall_config = HexMapTileAdapterScript.tile_config_from_catalog(tile_catalog, wall_catalog_key)
	if debug_numeric_fallback and int(floor_config.get("source_id", -1)) < 0:
		floor_config = HexMapTileAdapterScript.tile_config(
			int(options.get("floor_source_id", 0)),
			options.get("floor_atlas_coords", Vector2i.ZERO),
			int(options.get("floor_alternative_tile", 0))
		)
	if debug_numeric_fallback and int(wall_config.get("source_id", -1)) < 0:
		wall_config = HexMapTileAdapterScript.tile_config(
			int(options.get("wall_source_id", 0)),
			options.get("wall_atlas_coords", Vector2i(1, 0)),
			int(options.get("wall_alternative_tile", 0))
		)
	var apply_report := HexMapTileAdapterScript.apply_to_tile_map_layer_chunked(
		layer,
		data,
		int(floor_config.get("source_id", -1)),
		floor_config.get("atlas_coords", Vector2i.ZERO),
		int(wall_config.get("source_id", -1)),
		wall_config.get("atlas_coords", Vector2i(1, 0)),
		bool(options.get("clear_layer", true)),
		flat_top,
		int(floor_config.get("alternative_tile", 0)),
		int(wall_config.get("alternative_tile", 0)),
		options
	)
	if bool(apply_report.get("cancelled", false)):
		return apply_report
	var cell_set = data.cell_set()
	var wall_set = data.wall_set()
	var override_entries_processed := 0
	for entry in document_tile_entries(document):
		var hex = _hex_from_component(entry.get("cell", Vector3i.ZERO))
		if not cell_set.has(hex.key()):
			continue
		var entry_kind = String(entry.get("kind", KIND_FLOOR))
		if entry_kind == KIND_OVERLAY:
			continue
		var is_wall = wall_set.has(hex.key())
		if entry_kind == KIND_FLOOR and is_wall:
			continue
		if entry_kind == KIND_WALL and not is_wall:
			continue
		_apply_tile_override(layer, _resolve_catalog_tile_entry(entry, tile_catalog, debug_numeric_fallback), flat_top)
		override_entries_processed += 1
	apply_report["override_entries_processed"] = override_entries_processed
	return apply_report

static func set_wall(document, hex, wall: bool) -> void:
	var map_resource = _document_map_resource(document)
	if document == null or map_resource == null:
		return
	var data = map_resource.to_map_data()
	var normalized = _normalize_hex(hex)
	var cell_set = data.cell_set()
	if not cell_set.has(normalized.key()):
		return
	var wall_set = data.wall_set()
	if wall and not wall_set.has(normalized.key()):
		var walls = data.walls.duplicate()
		walls.append(cell_set[normalized.key()])
		data.set_walls(walls)
	elif not wall and wall_set.has(normalized.key()):
		data.set_walls(HexMapDataScript.points_except(data.walls, [normalized]))
	map_resource.set_from_map_data(data, map_resource.orientation)


static func set_cell_exists(document, hex, exists: bool) -> void:
	if document == null:
		return
	_ensure_map(document)
	var map_resource = _document_map_resource(document)
	if map_resource == null:
		return
	var data = map_resource.to_map_data()
	var normalized = _normalize_hex(hex)
	var cell_set = data.cell_set()
	if exists and not cell_set.has(normalized.key()):
		var cells = data.cells.duplicate()
		cells.append(normalized)
		data = HexMapDataScript.from_cells(cells, data.walls, data.cyclic_size)
	elif not exists and cell_set.has(normalized.key()):
		var cells_without = HexMapDataScript.points_except(data.cells, [normalized])
		var walls_without = HexMapDataScript.points_except(data.walls, [normalized])
		data = HexMapDataScript.from_cells(cells_without, walls_without, data.cyclic_size)
		_remove_cell_payloads(document, normalized)
	map_resource.set_from_map_data(data, map_resource.orientation)


static func set_tile_override(document, hex, payload: Dictionary) -> void:
	if document == null:
		return
	var entry = _tile_override_entry(hex, payload)
	if int(entry.get("source_id", 0)) < 0:
		_remove_tile_assignment(document, entry)
		return
	_replace_tile_assignment(document, entry)


static func set_object(document, hex, payload: Dictionary) -> void:
	if document == null:
		return
	var object_id = String(payload.get("object_id", ""))
	var cell = _component_from_hex(hex)
	if object_id == "":
		_remove_object_placement(document, cell)
		return
	_replace_object_placement(document, cell, payload)


static func set_label(document, hex, payload: Dictionary) -> void:
	if document == null:
		return
	var label_id = String(payload.get("label_id", ""))
	var text = String(payload.get("text", ""))
	var cell = _component_from_hex(hex)
	if label_id == "" and text == "":
		_remove_label_placement(document, cell)
		return
	_replace_label_placement(document, cell, payload)


static func _ensure_map(document) -> void:
	if _document_map_resource(document) == null:
		var terrain_layer = _ensure_terrain_layer(document)
		terrain_layer.map = HexMapResourceScript.from_map_data(HexMapDataScript.from_cells([]))


static func _document_default_terrain_key(document, field_name: String) -> String:
	if document == null:
		return ""
	for layer in document.terrain_layers:
		if layer == null:
			continue
		var value = String(layer.get(field_name))
		if value != "":
			return value
	return ""


static func _tile_override_entry(hex, payload: Dictionary) -> Dictionary:
	return {
		"cell": _component_from_hex(hex),
		"kind": String(payload.get("kind", KIND_FLOOR)),
		"item_key": String(payload.get("item_key", "")),
		"catalog_key": String(payload.get("catalog_key", "")),
		"source_id": int(payload.get("source_id", 0)),
		"atlas_coords": payload.get("atlas_coords", Vector2i.ZERO),
		"alternative_tile": int(payload.get("alternative_tile", 0)),
	}


static func _apply_tile_override(layer, entry: Dictionary, flat_top: bool) -> void:
	var hex = _hex_from_component(entry.get("cell", Vector3i.ZERO))
	var map_cell = HexMapTileAdapterScript.vector_to_map_cell(hex, flat_top)
	var source_id = int(entry.get("source_id", -1))
	if source_id < 0:
		return
	layer.set_cell(
		map_cell,
		source_id,
		entry.get("atlas_coords", Vector2i.ZERO),
		int(entry.get("alternative_tile", 0))
	)


static func _resolve_catalog_tile_entry(entry: Dictionary, catalog, debug_numeric_fallback: bool = false) -> Dictionary:
	var resolved = entry.duplicate(true)
	var catalog_key = String(resolved.get("catalog_key", ""))
	if catalog_key == "":
		catalog_key = String(resolved.get("item_key", ""))
	if catalog_key == "":
		if debug_numeric_fallback:
			return resolved
		resolved["source_id"] = -1
		return resolved
	var config = HexMapTileAdapterScript.tile_config_from_catalog(catalog, catalog_key)
	if debug_numeric_fallback and int(config.get("source_id", -1)) < 0:
		return resolved
	resolved["source_id"] = int(config.get("source_id", -1))
	resolved["atlas_coords"] = config.get("atlas_coords", Vector2i.ZERO)
	resolved["alternative_tile"] = int(config.get("alternative_tile", 0))
	resolved["catalog_key"] = catalog_key
	return resolved


static func _remove_cell_payloads(document, hex) -> void:
	var matcher = {"cell": _component_from_hex(hex)}
	_remove_cell_canonical_payloads(document, matcher["cell"])


static func _remove_cell_display_payloads(document, hex) -> void:
	var matcher = {"cell": _component_from_hex(hex)}
	_remove_tile_assignments_for_cell(document, matcher["cell"])
	_remove_object_placement(document, matcher["cell"])
	_remove_label_placement(document, matcher["cell"])


static func _replace_entry(entries: Array, entry: Dictionary, keys: Array) -> void:
	_remove_entry(entries, entry, keys)
	entries.append(entry)


static func _remove_entry(entries: Array, matcher: Dictionary, keys: Array) -> void:
	for index in range(entries.size() - 1, -1, -1):
		var current: Dictionary = entries[index]
		var matches := true
		for key in keys:
			if current.get(key) != matcher.get(key):
				matches = false
				break
		if matches:
			entries.remove_at(index)


static func _duplicate_entries(entries: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in entries:
		result.append(entry.duplicate(true))
	return result


static func _duplicate_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value.duplicate(true)
	return {}


static func _duplicate_resources(entries: Array) -> Array[Resource]:
	var result: Array[Resource] = []
	for entry in entries:
		if entry is Resource:
			result.append(_duplicate_document_resource(entry))
	return result


static func _duplicate_document_resource(entry: Resource) -> Resource:
	if entry is HexMapDocumentTerrainLayerResourceScript:
		return _duplicate_terrain_layer(entry as HexMapDocumentTerrainLayerResourceScript)
	if entry is HexMapDocumentOverlayLayerResourceScript:
		return _duplicate_overlay_layer(entry as HexMapDocumentOverlayLayerResourceScript)
	return entry.duplicate(true)


static func _duplicate_terrain_layer(layer: HexMapDocumentTerrainLayerResourceScript) -> HexMapDocumentTerrainLayerResourceScript:
	var copy = HexMapDocumentTerrainLayerResourceScript.new()
	copy.layer_id = layer.layer_id
	copy.display_name = layer.display_name
	copy.role = layer.role
	copy.default_floor_key = layer.default_floor_key
	copy.default_wall_key = layer.default_wall_key
	copy.tile_assignments = _duplicate_entries(layer.tile_assignments)
	copy.metadata = _duplicate_dictionary(layer.metadata)
	if layer.map != null:
		copy.map = HexMapResourceScript.from_map_data(layer.map.to_map_data(), layer.map.orientation)
	return copy


static func _duplicate_overlay_layer(layer: HexMapDocumentOverlayLayerResourceScript) -> HexMapDocumentOverlayLayerResourceScript:
	var copy = HexMapDocumentOverlayLayerResourceScript.new()
	copy.layer_id = layer.layer_id
	copy.display_name = layer.display_name
	copy.role = layer.role
	copy.item_key = layer.item_key
	copy.catalog_key = layer.catalog_key
	copy.tile_assignments = _duplicate_entries(layer.tile_assignments)
	copy.z_index = layer.z_index
	copy.visible = layer.visible
	copy.metadata = _duplicate_dictionary(layer.metadata)
	if layer.overlay != null:
		copy.overlay = HexOverlayResourceScript.from_overlay_data(layer.overlay.to_overlay_data(), layer.overlay.orientation)
	return copy


static func _document_map_data(document):
	var map_resource = _document_map_resource(document)
	return map_resource.to_map_data() if map_resource != null else null


static func _document_map_resource(document):
	if document == null:
		return null
	for layer in document.terrain_layers:
		if layer != null and layer.get("map") != null:
			return layer.get("map")
	return null


static func _document_orientation(document) -> int:
	var map_resource = _document_map_resource(document)
	return map_resource.orientation if map_resource != null else HexMapResourceScript.ORIENTATION_FLAT_TOP


static func _document_object_count(document) -> int:
	if document == null:
		return 0
	return document.object_placements.size()


static func _document_label_count(document) -> int:
	if document == null:
		return 0
	return document.label_placements.size()


static func _baseline_warning_count(document) -> int:
	if document == null:
		return 0
	var count := 0
	if _document_map_data(document) == null:
		count += 1
	if document.dependencies.is_empty():
		count += 1
	return count


static func _object_placement_entry(placement: Resource) -> Dictionary:
	var rotation_degrees = float(placement.get("rotation_degrees"))
	return {
		"placement_id": String(placement.get("placement_id")),
		"cell": placement.get("cell"),
		"object_id": String(placement.get("object_id")),
		"rotation_degrees": rotation_degrees,
		"rotation": rotation_degrees,
		"variant": String(placement.get("variant")),
		"properties": _duplicate_dictionary(placement.get("properties")),
		"spawn_condition": String(placement.get("spawn_condition")),
		"layer_id": String(placement.get("layer_id")),
		"runtime_enabled": bool(placement.get("runtime_enabled")),
		"metadata": _duplicate_dictionary(placement.get("metadata")),
	}


static func _label_placement_entry(placement: Resource) -> Dictionary:
	return {
		"cell": placement.get("cell"),
		"label_id": String(placement.get("label_id")),
		"text": String(placement.get("text")),
		"style_key": String(placement.get("style_key")),
		"zone_id": String(placement.get("zone_id")),
	}


static func _replace_tile_assignment(document, entry: Dictionary) -> void:
	if String(entry.get("kind", KIND_FLOOR)) == KIND_OVERLAY:
		var overlay_layer = _ensure_overlay_layer(document, String(entry.get("item_key", "")))
		if overlay_layer == null:
			return
		var overlay_entry = entry.duplicate(true)
		overlay_entry.erase("kind")
		_replace_entry(overlay_layer.tile_assignments, overlay_entry, ["cell"])
		return
	var terrain_layer = _ensure_terrain_layer(document)
	if terrain_layer == null:
		return
	_replace_entry(terrain_layer.tile_assignments, entry.duplicate(true), ["cell", "kind", "item_key"])


static func _remove_tile_assignment(document, entry: Dictionary) -> void:
	if String(entry.get("kind", KIND_FLOOR)) == KIND_OVERLAY:
		var item_key = String(entry.get("item_key", ""))
		for layer in document.overlay_layers:
			if layer == null:
				continue
			if item_key != "" and String(layer.get("item_key")) != item_key:
				continue
			_remove_entry(layer.get("tile_assignments"), entry, ["cell"])
		return
	for layer in document.terrain_layers:
		if layer != null:
			_remove_entry(layer.get("tile_assignments"), entry, ["cell", "kind", "item_key"])


static func _ensure_terrain_layer(document):
	for layer in document.terrain_layers:
		if layer is HexMapDocumentTerrainLayerResourceScript:
			return layer
	var layer = HexMapDocumentTerrainLayerResourceScript.new()
	document.terrain_layers.append(layer)
	return layer


static func _ensure_overlay_layer(document, item_key: String):
	for layer in document.overlay_layers:
		if layer is HexMapDocumentOverlayLayerResourceScript and String(layer.get("item_key")) == item_key:
			return layer
	var layer = HexMapDocumentOverlayLayerResourceScript.new()
	layer.item_key = item_key
	if item_key != "":
		layer.layer_id = "overlay_%s" % _safe_id(item_key)
		layer.display_name = item_key
	document.overlay_layers.append(layer)
	return layer


static func _replace_object_placement(document, cell: Vector3i, payload: Dictionary) -> void:
	var placement = _object_placement_for_cell(document, cell)
	if placement == null:
		placement = HexMapDocumentObjectPlacementResourceScript.new()
		document.object_placements.append(placement)
	placement.placement_id = String(payload.get("placement_id", ""))
	placement.cell = cell
	placement.object_id = String(payload.get("object_id", ""))
	placement.rotation_degrees = float(payload.get("rotation_degrees", payload.get("rotation", 0.0)))
	placement.variant = String(payload.get("variant", ""))
	placement.properties = _duplicate_dictionary(payload.get("properties", {}))
	placement.spawn_condition = String(payload.get("spawn_condition", ""))
	placement.layer_id = String(payload.get("layer_id", "objects"))
	placement.runtime_enabled = bool(payload.get("runtime_enabled", true))
	placement.metadata = _duplicate_dictionary(payload.get("metadata", {}))


static func _remove_object_placement(document, cell: Vector3i) -> void:
	var key = _hex_from_component(cell).key()
	for index in range(document.object_placements.size() - 1, -1, -1):
		var placement = document.object_placements[index]
		if placement is Resource and _hex_from_component(placement.get("cell")).key() == key:
				document.object_placements.remove_at(index)


static func _object_placement_for_cell(document, cell: Vector3i):
	var key = _hex_from_component(cell).key()
	for placement in document.object_placements:
		if placement is Resource and _hex_from_component(placement.get("cell")).key() == key:
			return placement
	return null


static func _replace_label_placement(document, cell: Vector3i, payload: Dictionary) -> void:
	var placement = _label_placement_for_cell(document, cell)
	if placement == null:
		placement = HexMapDocumentLabelPlacementResourceScript.new()
		document.label_placements.append(placement)
	placement.cell = cell
	placement.label_id = String(payload.get("label_id", ""))
	placement.text = String(payload.get("text", ""))
	placement.style_key = String(payload.get("style_key", ""))
	placement.zone_id = String(payload.get("zone_id", ""))


static func _remove_label_placement(document, cell: Vector3i) -> void:
	var key = _hex_from_component(cell).key()
	for index in range(document.label_placements.size() - 1, -1, -1):
		var placement = document.label_placements[index]
		if placement is Resource and _hex_from_component(placement.get("cell")).key() == key:
				document.label_placements.remove_at(index)


static func _label_placement_for_cell(document, cell: Vector3i):
	var key = _hex_from_component(cell).key()
	for placement in document.label_placements:
		if placement is Resource and _hex_from_component(placement.get("cell")).key() == key:
			return placement
	return null


static func _remove_cell_canonical_payloads(document, cell: Vector3i) -> void:
	if document == null:
		return
	var key = _hex_from_component(cell).key()
	_remove_tile_assignments_for_cell(document, cell)
	_remove_object_placement(document, cell)
	_remove_label_placement(document, cell)
	for zone_index in range(document.zones.size() - 1, -1, -1):
		var zone = document.zones[zone_index]
		if not zone is Resource:
			continue
		var cells: Array = zone.get("cells")
		for cell_index in range(cells.size() - 1, -1, -1):
			if _hex_from_component(cells[cell_index]).key() == key:
				cells.remove_at(cell_index)
		if cells.is_empty():
				document.zones.remove_at(zone_index)


static func _remove_tile_assignments_for_cell(document, cell: Vector3i) -> void:
	var key = _hex_from_component(cell).key()
	for layer in document.terrain_layers:
		if layer != null:
			_remove_assignment_cells(layer.get("tile_assignments"), key)
	for layer in document.overlay_layers:
		if layer != null:
			_remove_assignment_cells(layer.get("tile_assignments"), key)


static func _remove_assignment_cells(assignments: Array, key: String) -> void:
	for index in range(assignments.size() - 1, -1, -1):
		var entry = assignments[index]
		if entry is Dictionary and _hex_from_component((entry as Dictionary).get("cell", Vector3i.ZERO)).key() == key:
			assignments.remove_at(index)


static func _safe_id(value: String) -> String:
	var result := ""
	for index in range(value.length()):
		var code = value.unicode_at(index)
		if (code >= 48 and code <= 57) \
			or (code >= 65 and code <= 90) \
			or (code >= 97 and code <= 122):
			result += char(code).to_lower()
		else:
			result += "_"
	return "layer" if result == "" else result


static func _component_from_hex(hex) -> Vector3i:
	var normalized = _normalize_hex(hex)
	return Vector3i(normalized.q, normalized.s, normalized.r)


static func _hex_from_component(component: Vector3i):
	return HexVectorScript.apply_basis(component.x, component.y, component.z)


static func _normalize_hex(hex):
	return HexVectorScript.apply_basis(hex.q, hex.s, hex.r)
