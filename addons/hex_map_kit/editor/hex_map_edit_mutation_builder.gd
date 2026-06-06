class_name HexMapEditMutationBuilder
extends RefCounted

const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")

const MODE_SHAPE := 0
const MODE_WALL_FLOOR := 1
const MODE_FLOOR_TILE := 2
const MODE_WALL_TILE := 3
const MODE_OBJECT := 4
const MODE_LABEL := 5
const MODE_OVERLAY_TILE := 6


static func build_document_edit(
	document,
	hex,
	edit_mode: int,
	tile_payload: Dictionary = {},
	overlay_item_key: String = "",
	object_payload: Dictionary = {},
	label_payload: Dictionary = {},
	mode_names: Array = []
) -> Dictionary:
	if document == null:
		return {}
	var before = HexMapDocumentAdapter.duplicate_document(document)
	var after = HexMapDocumentAdapter.duplicate_document(document)
	apply_mode_to_document(after, hex, edit_mode, tile_payload, overlay_item_key, object_payload, label_payload)
	return {
		"mode": _mode_name(edit_mode, mode_names),
		"hex": _normalized_hex(hex),
		"payload": edit_payload_summary(edit_mode, tile_payload, overlay_item_key, object_payload, label_payload, mode_names),
		"before": before,
		"after": after,
	}


static func build_hex_tile_map_layer_edit_command(
	before: Dictionary,
	hex,
	edit_mode: int,
	tile_payload: Dictionary = {},
	overlay_item_key: String = "",
	object_payload: Dictionary = {},
	label_payload: Dictionary = {},
	mode_names: Array = []
) -> Dictionary:
	if before.is_empty():
		return {}
	var after = before.duplicate(true)
	after["hex"] = _normalized_hex(hex)
	match edit_mode:
		MODE_SHAPE:
			var next_exists = not bool(before.get("exists", false))
			after["exists"] = next_exists
			if not next_exists:
				after["wall"] = false
				after["tile_overrides"] = []
				after["overlay_tiles"] = []
				after["objects"] = []
				after["labels"] = []
		MODE_WALL_FLOOR:
			if not bool(before.get("exists", false)):
				return {}
			after["wall"] = not bool(before.get("wall", false))
		MODE_FLOOR_TILE:
			if not bool(before.get("exists", false)):
				return {}
			var floor_payload = tile_payload.duplicate(true)
			floor_payload["kind"] = HexMapDocumentAdapter.KIND_FLOOR
			after["tile_overrides"] = _replace_state_payload_entry(
				after.get("tile_overrides", []),
				_payload_entry_for_hex(hex, floor_payload),
				["cell", "kind"]
			)
		MODE_WALL_TILE:
			if not bool(before.get("exists", false)):
				return {}
			var wall_payload = tile_payload.duplicate(true)
			wall_payload["kind"] = HexMapDocumentAdapter.KIND_WALL
			after["tile_overrides"] = _replace_state_payload_entry(
				after.get("tile_overrides", []),
				_payload_entry_for_hex(hex, wall_payload),
				["cell", "kind"]
			)
		MODE_OVERLAY_TILE:
			if not bool(before.get("exists", false)):
				return {}
			var overlay_payload = tile_payload.duplicate(true)
			overlay_payload["kind"] = HexMapDocumentAdapter.KIND_OVERLAY
			overlay_payload["item_key"] = overlay_item_key
			after["overlay_tiles"] = _replace_state_payload_entry(
				after.get("overlay_tiles", []),
				_payload_entry_for_hex(hex, overlay_payload),
				["cell", "kind", "item_key"]
			)
		MODE_OBJECT:
			if not bool(before.get("exists", false)):
				return {}
			after["objects"] = _replace_state_payload_entry(
				after.get("objects", []),
				_object_entry_for_hex(hex, object_payload),
				["cell"]
			)
		MODE_LABEL:
			if not bool(before.get("exists", false)):
				return {}
			after["labels"] = _replace_state_payload_entry(
				after.get("labels", []),
				_label_entry_for_hex(hex, label_payload),
				["cell"]
			)
		_:
			return {}
	return {
		"mode": _mode_name(edit_mode, mode_names),
		"hex": _normalized_hex(hex),
		"payload": edit_payload_summary(edit_mode, tile_payload, overlay_item_key, object_payload, label_payload, mode_names),
		"before": before,
		"after": after,
		"snapshot_dirty": true,
	}


static func apply_mode_to_document(
	document,
	hex,
	edit_mode: int,
	tile_payload: Dictionary = {},
	overlay_item_key: String = "",
	object_payload: Dictionary = {},
	label_payload: Dictionary = {}
) -> void:
	match edit_mode:
		MODE_SHAPE:
			var exists = _document_has_cell(document, hex)
			HexMapDocumentAdapter.set_cell_exists(document, hex, not exists)
		MODE_WALL_FLOOR:
			var is_wall = _document_has_wall(document, hex)
			HexMapDocumentAdapter.set_wall(document, hex, not is_wall)
		MODE_FLOOR_TILE:
			var floor_payload = tile_payload.duplicate(true)
			floor_payload["kind"] = HexMapDocumentAdapter.KIND_FLOOR
			HexMapDocumentAdapter.set_tile_override(document, hex, floor_payload)
		MODE_WALL_TILE:
			var wall_payload = tile_payload.duplicate(true)
			wall_payload["kind"] = HexMapDocumentAdapter.KIND_WALL
			HexMapDocumentAdapter.set_tile_override(document, hex, wall_payload)
		MODE_OVERLAY_TILE:
			var overlay_payload = tile_payload.duplicate(true)
			overlay_payload["kind"] = HexMapDocumentAdapter.KIND_OVERLAY
			overlay_payload["item_key"] = overlay_item_key
			HexMapDocumentAdapter.set_tile_override(document, hex, overlay_payload)
		MODE_OBJECT:
			HexMapDocumentAdapter.set_object(document, hex, object_payload)
		MODE_LABEL:
			HexMapDocumentAdapter.set_label(document, hex, label_payload)


static func edit_payload_summary(
	edit_mode: int,
	tile_payload: Dictionary = {},
	overlay_item_key: String = "",
	object_payload: Dictionary = {},
	label_payload: Dictionary = {},
	mode_names: Array = []
) -> String:
	match edit_mode:
		MODE_FLOOR_TILE, MODE_WALL_TILE:
			return "%d:%s:%d" % [
				int(tile_payload.get("source_id", 0)),
				_atlas_text(tile_payload.get("atlas_coords", Vector2i.ZERO)),
				int(tile_payload.get("alternative_tile", 0)),
			]
		MODE_OVERLAY_TILE:
			return "overlay=%s %d:%s:%d" % [
				overlay_item_key,
				int(tile_payload.get("source_id", 0)),
				_atlas_text(tile_payload.get("atlas_coords", Vector2i.ZERO)),
				int(tile_payload.get("alternative_tile", 0)),
			]
		MODE_OBJECT:
			return "object=%s rot=%s variant=%s spawn=%s" % [
				String(object_payload.get("object_id", "")),
				str(float(object_payload.get("rotation_degrees", 0.0))),
				String(object_payload.get("variant", "")),
				String(object_payload.get("spawn_condition", "")),
			]
		MODE_LABEL:
			return "label=%s text=%s" % [
				String(label_payload.get("label_id", "")),
				String(label_payload.get("text", "")),
			]
		_:
			return _mode_name(edit_mode, mode_names)


static func _document_has_cell(document, hex) -> bool:
	var map_resource = HexMapDocumentAdapter.to_map_resource(document)
	return map_resource != null and map_resource.to_map_data().has_cell(hex)


static func _document_has_wall(document, hex) -> bool:
	var map_resource = HexMapDocumentAdapter.to_map_resource(document)
	return map_resource != null and map_resource.to_map_data().has_wall(hex)


static func _replace_state_payload_entry(entries_value, entry: Dictionary, keys: Array) -> Array:
	var entries: Array = []
	if entries_value is Array:
		for raw_entry in entries_value:
			if raw_entry is Dictionary:
				entries.append((raw_entry as Dictionary).duplicate(true))
	if _payload_entry_is_empty(entry):
		return _entries_without_match(entries, entry, keys)
	entries = _entries_without_match(entries, entry, keys)
	entries.append(entry)
	return entries


static func _entries_without_match(entries: Array, matcher: Dictionary, keys: Array) -> Array:
	var result: Array = []
	for raw_entry in entries:
		if not raw_entry is Dictionary:
			continue
		var current := raw_entry as Dictionary
		var matches := true
		for key in keys:
			if current.get(key) != matcher.get(key):
				matches = false
				break
		if not matches:
			result.append(current.duplicate(true))
	return result


static func _payload_entry_is_empty(entry: Dictionary) -> bool:
	if entry.has("source_id"):
		return int(entry.get("source_id", 0)) < 0
	if entry.has("object_id"):
		return String(entry.get("object_id", "")) == ""
	if entry.has("label_id") or entry.has("text"):
		return String(entry.get("label_id", "")) == "" and String(entry.get("text", "")) == ""
	return false


static func _payload_entry_for_hex(hex, payload: Dictionary) -> Dictionary:
	var normalized = _normalized_hex(hex)
	return {
		"cell": Vector3i(normalized.q, normalized.s, normalized.r),
		"kind": String(payload.get("kind", HexMapDocumentAdapter.KIND_FLOOR)),
		"item_key": String(payload.get("item_key", "")),
		"source_id": int(payload.get("source_id", 0)),
		"atlas_coords": payload.get("atlas_coords", Vector2i.ZERO),
		"alternative_tile": int(payload.get("alternative_tile", 0)),
	}


static func _object_entry_for_hex(hex, payload: Dictionary) -> Dictionary:
	var normalized = _normalized_hex(hex)
	var rotation_degrees = float(payload.get("rotation_degrees", payload.get("rotation", 0.0)))
	return {
		"cell": Vector3i(normalized.q, normalized.s, normalized.r),
		"object_id": String(payload.get("object_id", "")),
		"rotation_degrees": rotation_degrees,
		"rotation": rotation_degrees,
		"variant": String(payload.get("variant", "")),
		"properties": _object_properties_from_payload(payload),
		"spawn_condition": String(payload.get("spawn_condition", "")),
	}


static func _label_entry_for_hex(hex, payload: Dictionary) -> Dictionary:
	var normalized = _normalized_hex(hex)
	return {
		"cell": Vector3i(normalized.q, normalized.s, normalized.r),
		"label_id": String(payload.get("label_id", "")),
		"text": String(payload.get("text", "")),
	}


static func _object_properties_from_payload(payload: Dictionary) -> Dictionary:
	var properties = payload.get("properties", {})
	if properties is Dictionary:
		return properties.duplicate(true)
	return {}


static func _normalized_hex(hex):
	return HexVector.apply_basis(hex.q, hex.s, hex.r)


static func _mode_name(edit_mode: int, mode_names: Array) -> String:
	if edit_mode >= 0 and edit_mode < mode_names.size():
		return String(mode_names[edit_mode])
	return str(edit_mode)


static func _atlas_text(value) -> String:
	if value is Vector2i:
		return "(%d,%d)" % [value.x, value.y]
	return str(value)
