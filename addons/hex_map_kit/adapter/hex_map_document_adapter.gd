class_name HexMapDocumentAdapter
extends RefCounted

const HexMapDocumentResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapDocumentLabelPlacementResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_label_placement_resource.gd")
const HexMapDocumentObjectPlacementResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_object_placement_resource.gd")
const HexMapDocumentOverlayLayerResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_overlay_layer_resource.gd")
const HexMapDocumentTerrainLayerResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_terrain_layer_resource.gd")
const HexMapValidationResultScript = preload("res://addons/hex_map_kit/adapter/hex_map_validation_result.gd")
const HexMapResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexMapTileAdapterScript = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexMapDataScript = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")

const KIND_FLOOR := "floor"
const KIND_WALL := "wall"
const KIND_OVERLAY := "overlay"


static func from_map_resource(resource: HexMapResourceScript):
	var document = HexMapDocumentResourceScript.new()
	if resource != null:
		document.map = HexMapResourceScript.from_map_data(resource.to_map_data(), resource.orientation)
	return document


static func to_map_resource(document):
	if document == null or document.map == null:
		return HexMapResourceScript.from_map_data(HexMapDataScript.from_cells([]))
	return HexMapResourceScript.from_map_data(document.map.to_map_data(), document.map.orientation)


static func duplicate_document(document):
	var copy = HexMapDocumentResourceScript.new()
	copy.version = int(document.version) if document != null else 1
	if document != null and document.map != null:
		copy.map = HexMapResourceScript.from_map_data(document.map.to_map_data(), document.map.orientation)
	copy.tile_overrides = _duplicate_entries(document.tile_overrides if document != null else [])
	copy.objects = _duplicate_entries(document.objects if document != null else [])
	copy.labels = _duplicate_entries(document.labels if document != null else [])
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


static func migrate_v1_to_v2(document):
	if document != null and document.has_method("is_v2") and document.is_v2():
		return duplicate_document(document)

	var source_version = int(document.version) if document != null else 0
	var migrated = duplicate_document(document)
	migrated.ensure_v2_defaults()
	migrated.metadata.custom_properties["source_version"] = source_version
	migrated.metadata.custom_properties["migration"] = "v1_to_v2"

	migrated.terrain_layers.clear()
	migrated.overlay_layers.clear()
	migrated.object_placements.clear()
	migrated.label_placements.clear()

	if migrated.map != null:
		var terrain_layer = HexMapDocumentTerrainLayerResourceScript.new()
		terrain_layer.map = HexMapResourceScript.from_map_data(
			migrated.map.to_map_data(),
			migrated.map.orientation
		)
		terrain_layer.tile_assignments = _v1_terrain_tile_assignments(migrated.tile_overrides)
		migrated.terrain_layers.append(terrain_layer)

	for overlay_layer in _v1_overlay_layers(migrated.tile_overrides):
		migrated.overlay_layers.append(overlay_layer)

	for entry in migrated.objects:
		migrated.object_placements.append(_v1_object_placement(entry))

	for entry in migrated.labels:
		migrated.label_placements.append(_v1_label_placement(entry))

	return migrated


static func document_summary(document) -> Dictionary:
	var data = _document_map_data(document)
	var cell_count = data.cells.size() if data != null else 0
	var wall_count = data.walls.size() if data != null else 0
	return {
		"version": int(document.version) if document != null else 0,
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
	target.version = int(source.version)
	target.map = null
	if source.map != null:
		target.map = HexMapResourceScript.from_map_data(source.map.to_map_data(), source.map.orientation)
	target.tile_overrides = _duplicate_entries(source.tile_overrides)
	target.objects = _duplicate_entries(source.objects)
	target.labels = _duplicate_entries(source.labels)
	target.terrain_layers = _duplicate_resources(source.terrain_layers)
	target.overlay_layers = _duplicate_resources(source.overlay_layers)
	target.object_placements = _duplicate_resources(source.object_placements)
	target.label_placements = _duplicate_resources(source.label_placements)
	target.zones = _duplicate_resources(source.zones)
	target.dependencies = _duplicate_resources(source.dependencies)
	target.metadata = source.metadata.duplicate(true) if source.metadata != null else null


static func apply_to_tile_map_layer(document, layer, options: Dictionary = {}) -> void:
	if document == null or document.map == null or layer == null:
		return
	var flat_top = document.map.is_flat_top()
	HexMapTileAdapterScript.apply_to_tile_map_layer(
		layer,
		document.map.to_map_data(),
		int(options.get("floor_source_id", 0)),
		options.get("floor_atlas_coords", Vector2i.ZERO),
		int(options.get("wall_source_id", 0)),
		options.get("wall_atlas_coords", Vector2i(1, 0)),
		bool(options.get("clear_layer", true)),
		flat_top,
		int(options.get("floor_alternative_tile", 0)),
		int(options.get("wall_alternative_tile", 0))
	)
	var data = document.map.to_map_data()
	var cell_set = data.cell_set()
	var wall_set = data.wall_set()
	for entry in document.tile_overrides:
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
		_apply_tile_override(layer, entry, flat_top)


static func set_wall(document, hex, wall: bool) -> void:
	if document == null or document.map == null:
		return
	var data = document.map.to_map_data()
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
	document.map.set_from_map_data(data, document.map.orientation)


static func set_cell_exists(document, hex, exists: bool) -> void:
	if document == null:
		return
	_ensure_map(document)
	var data = document.map.to_map_data()
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
	document.map.set_from_map_data(data, document.map.orientation)


static func set_tile_override(document, hex, payload: Dictionary) -> void:
	if document == null:
		return
	var entry = _tile_override_entry(hex, payload)
	if int(entry.get("source_id", 0)) < 0:
		_remove_entry(document.tile_overrides, entry, ["cell", "kind", "item_key"])
		return
	_replace_entry(document.tile_overrides, entry, ["cell", "kind", "item_key"])


static func set_object(document, hex, payload: Dictionary) -> void:
	if document == null:
		return
	var object_id = String(payload.get("object_id", ""))
	var cell = _component_from_hex(hex)
	if object_id == "":
		_remove_entry(document.objects, {"cell": cell}, ["cell"])
		return
	var entry := {
		"cell": cell,
		"object_id": object_id,
		"properties": payload.get("properties", {}).duplicate(true),
	}
	_replace_entry(document.objects, entry, ["cell"])


static func set_label(document, hex, payload: Dictionary) -> void:
	if document == null:
		return
	var label_id = String(payload.get("label_id", ""))
	var text = String(payload.get("text", ""))
	var cell = _component_from_hex(hex)
	if label_id == "" and text == "":
		_remove_entry(document.labels, {"cell": cell}, ["cell"])
		return
	var entry := {
		"cell": cell,
		"label_id": label_id,
		"text": text,
	}
	_replace_entry(document.labels, entry, ["cell"])


static func _ensure_map(document) -> void:
	if document.map == null:
		document.map = HexMapResourceScript.from_map_data(HexMapDataScript.from_cells([]))


static func _tile_override_entry(hex, payload: Dictionary) -> Dictionary:
	return {
		"cell": _component_from_hex(hex),
		"kind": String(payload.get("kind", KIND_FLOOR)),
		"item_key": String(payload.get("item_key", "")),
		"source_id": int(payload.get("source_id", 0)),
		"atlas_coords": payload.get("atlas_coords", Vector2i.ZERO),
		"alternative_tile": int(payload.get("alternative_tile", 0)),
	}


static func _apply_tile_override(layer, entry: Dictionary, flat_top: bool) -> void:
	var hex = _hex_from_component(entry.get("cell", Vector3i.ZERO))
	var map_cell = HexMapTileAdapterScript.vector_to_map_cell(hex, flat_top)
	layer.set_cell(
		map_cell,
		int(entry.get("source_id", 0)),
		entry.get("atlas_coords", Vector2i.ZERO),
		int(entry.get("alternative_tile", 0))
	)


static func _remove_cell_payloads(document, hex) -> void:
	var matcher = {"cell": _component_from_hex(hex)}
	_remove_entry(document.tile_overrides, matcher, ["cell"])
	_remove_entry(document.objects, matcher, ["cell"])
	_remove_entry(document.labels, matcher, ["cell"])


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


static func _duplicate_resources(entries: Array) -> Array[Resource]:
	var result: Array[Resource] = []
	for entry in entries:
		if entry is Resource:
			result.append(entry.duplicate(true))
	return result


static func _document_map_data(document):
	if document == null:
		return null
	if document.map != null:
		return document.map.to_map_data()
	for layer in document.terrain_layers:
		if layer != null and layer.get("map") != null:
			return layer.get("map").to_map_data()
	return null


static func _document_object_count(document) -> int:
	if document == null:
		return 0
	return document.object_placements.size() if not document.object_placements.is_empty() else document.objects.size()


static func _document_label_count(document) -> int:
	if document == null:
		return 0
	return document.label_placements.size() if not document.label_placements.is_empty() else document.labels.size()


static func _baseline_warning_count(document) -> int:
	if document == null:
		return 0
	var count := 0
	if _document_map_data(document) == null:
		count += 1
	if document.dependencies.is_empty():
		count += 1
	return count


static func _v1_terrain_tile_assignments(entries: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for raw_entry in entries:
		var entry: Dictionary = raw_entry
		if String(entry.get("kind", KIND_FLOOR)) == KIND_OVERLAY:
			continue
		result.append(_v1_tile_assignment(entry))
	return result


static func _v1_overlay_layers(entries: Array) -> Array[Resource]:
	var grouped := {}
	for raw_entry in entries:
		var entry: Dictionary = raw_entry
		if String(entry.get("kind", KIND_FLOOR)) != KIND_OVERLAY:
			continue
		var item_key = String(entry.get("item_key", "overlay"))
		if item_key == "":
			item_key = "overlay"
		if not grouped.has(item_key):
			grouped[item_key] = []
		grouped[item_key].append(_v1_tile_assignment(entry))

	var layers: Array[Resource] = []
	var item_keys = grouped.keys()
	item_keys.sort()
	for item_key in item_keys:
		var layer = HexMapDocumentOverlayLayerResourceScript.new()
		layer.layer_id = "overlay_%s" % _safe_id(item_key)
		layer.display_name = item_key
		layer.item_key = item_key
		var assignments: Array[Dictionary] = []
		for assignment in grouped[item_key]:
			assignments.append(assignment)
		layer.tile_assignments = assignments
		layers.append(layer)
	return layers


static func _v1_tile_assignment(entry: Dictionary) -> Dictionary:
	return {
		"cell": entry.get("cell", Vector3i.ZERO),
		"kind": String(entry.get("kind", KIND_FLOOR)),
		"item_key": String(entry.get("item_key", "")),
		"source_id": int(entry.get("source_id", 0)),
		"atlas_coords": entry.get("atlas_coords", Vector2i.ZERO),
		"alternative_tile": int(entry.get("alternative_tile", 0)),
	}


static func _v1_object_placement(entry: Dictionary) -> Resource:
	var placement = HexMapDocumentObjectPlacementResourceScript.new()
	placement.cell = entry.get("cell", Vector3i.ZERO)
	placement.object_id = String(entry.get("object_id", ""))
	placement.placement_id = String(entry.get("placement_id", ""))
	placement.variant = String(entry.get("variant", ""))
	placement.rotation_degrees = float(entry.get("rotation_degrees", entry.get("rotation", 0.0)))
	placement.properties = entry.get("properties", {}).duplicate(true)
	placement.spawn_condition = String(entry.get("spawn_condition", ""))
	return placement


static func _v1_label_placement(entry: Dictionary) -> Resource:
	var placement = HexMapDocumentLabelPlacementResourceScript.new()
	placement.cell = entry.get("cell", Vector3i.ZERO)
	placement.label_id = String(entry.get("label_id", ""))
	placement.text = String(entry.get("text", ""))
	placement.style_key = String(entry.get("style_key", ""))
	placement.zone_id = String(entry.get("zone_id", ""))
	return placement


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
