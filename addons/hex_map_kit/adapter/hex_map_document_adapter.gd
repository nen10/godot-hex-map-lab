class_name HexMapDocumentAdapter
extends RefCounted

const HexMapDocumentResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
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
	return copy


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


static func _component_from_hex(hex) -> Vector3i:
	var normalized = _normalize_hex(hex)
	return Vector3i(normalized.q, normalized.s, normalized.r)


static func _hex_from_component(component: Vector3i):
	return HexVectorScript.apply_basis(component.x, component.y, component.z)


static func _normalize_hex(hex):
	return HexVectorScript.apply_basis(hex.q, hex.s, hex.r)
