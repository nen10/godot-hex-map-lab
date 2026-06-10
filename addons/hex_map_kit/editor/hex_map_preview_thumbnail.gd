@tool
class_name HexMapPreviewThumbnail
extends Control

const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")

const SOURCE_NONE := "none"
const SOURCE_MAP_DATA := "map_data"
const SOURCE_OVERLAY_DATA := "overlay_data"
const SOURCE_DOCUMENT := "document"
const DEFAULT_BUDGET := 96

var _snapshot := unavailable_preview("empty")


func _ready() -> void:
	custom_minimum_size = Vector2(132, 92)


func set_preview_snapshot(snapshot: Dictionary) -> void:
	_snapshot = snapshot.duplicate(true)
	queue_redraw()


func preview_snapshot() -> Dictionary:
	return _snapshot.duplicate(true)


func clear_preview(reason: String = "empty") -> void:
	set_preview_snapshot(unavailable_preview(reason))


func _draw() -> void:
	if not bool(_snapshot.get("available", false)):
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.16, 0.16, 0.16), false, 1.0)
		return
	var entries = _snapshot.get("entries", []) as Array
	if entries.is_empty():
		return
	var bounds = _snapshot.get("bounds", {}) as Dictionary
	var min_q := int(bounds.get("min_q", 0))
	var max_q := int(bounds.get("max_q", min_q))
	var min_r := int(bounds.get("min_r", 0))
	var max_r := int(bounds.get("max_r", min_r))
	var cols = max(1, max_q - min_q + 1)
	var rows = max(1, max_r - min_r + 1)
	var cell_size = max(3.0, min(size.x / float(cols), size.y / float(rows)))
	var origin = Vector2(
		(size.x - float(cols) * cell_size) * 0.5,
		(size.y - float(rows) * cell_size) * 0.5
	)
	for entry in entries:
		if not entry is Dictionary:
			continue
		var entry_data := entry as Dictionary
		var q := int(entry_data.get("q", 0))
		var r := int(entry_data.get("r", 0))
		var color = entry_data.get("color", Color(0.45, 0.65, 0.85))
		var rect := Rect2(
			origin + Vector2(float(q - min_q) * cell_size, float(r - min_r) * cell_size),
			Vector2(max(2.0, cell_size - 1.0), max(2.0, cell_size - 1.0))
		)
		draw_rect(rect, color, true)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.24, 0.24, 0.24), false, 1.0)


static func unavailable_preview(reason: String = "empty", options: Dictionary = {}) -> Dictionary:
	return {
		"available": false,
		"reason": reason,
		"source_kind": SOURCE_NONE,
		"source_context": String(options.get("source_context", "")),
		"seed": int(options.get("seed", 0)),
		"sample_source": false,
		"budget": int(options.get("budget", DEFAULT_BUDGET)),
		"entry_count": 0,
		"entries": [],
		"bounds": {},
		"truncated": false,
	}


static func preview_from_map_data(data, options: Dictionary = {}) -> Dictionary:
	if data == null:
		return unavailable_preview("no_map_data", options)
	var cells: Array = data.cells
	var walls: Array = data.walls
	var wall_set := HexMapData.make_set(walls)
	var entries := []
	for cell in cells:
		var key = cell.key()
		entries.append(_entry_from_cell(
			cell,
			"wall" if wall_set.has(key) else "floor",
			Color(0.28, 0.36, 0.43) if wall_set.has(key) else Color(0.42, 0.63, 0.36)
		))
	return _preview_from_entries(
		SOURCE_MAP_DATA,
		entries,
		options,
		{
			"cell_count": cells.size(),
			"wall_count": walls.size(),
			"floor_count": max(0, cells.size() - walls.size()),
			"overlay_item_count": 0,
		}
	)


static func preview_from_overlay_data(data, options: Dictionary = {}) -> Dictionary:
	if data == null:
		return unavailable_preview("no_overlay_data", options)
	var cells: Array = data.cells
	var occupied := {}
	var item_total := 0
	for item_key in data.item_keys():
		for cell in data.item_cells(String(item_key)):
			occupied[cell.key()] = String(item_key)
			item_total += 1
	var entries := []
	for cell in cells:
		var key = cell.key()
		var has_item := occupied.has(key)
		entries.append(_entry_from_cell(
			cell,
			"overlay" if has_item else "empty",
			Color(0.64, 0.46, 0.77) if has_item else Color(0.24, 0.28, 0.31)
		))
	return _preview_from_entries(
		SOURCE_OVERLAY_DATA,
		entries,
		options,
		{
			"cell_count": cells.size(),
			"wall_count": 0,
			"floor_count": cells.size(),
			"overlay_item_count": item_total,
		}
	)


static func preview_from_document(document, options: Dictionary = {}) -> Dictionary:
	if document == null or not document is HexMapDocumentResource:
		return unavailable_preview("no_document", options)
	var map_data = null
	for terrain_layer in (document as HexMapDocumentResource).terrain_layers:
		if terrain_layer != null and terrain_layer.get("map") != null:
			map_data = terrain_layer.get("map").to_map_data()
			break
	var preview := preview_from_map_data(map_data, options)
	preview["source_kind"] = SOURCE_DOCUMENT if bool(preview.get("available", false)) else SOURCE_NONE
	return preview


static func _preview_from_entries(
	source_kind: String,
	entries: Array,
	options: Dictionary,
	counts: Dictionary
) -> Dictionary:
	if entries.is_empty():
		return unavailable_preview("no_preview_entries", options)
	var budget = max(1, int(options.get("budget", DEFAULT_BUDGET)))
	var limited := []
	for index in range(min(entries.size(), budget)):
		limited.append((entries[index] as Dictionary).duplicate(true))
	return {
		"available": true,
		"reason": "",
		"source_kind": source_kind,
		"source_context": String(options.get("source_context", "")),
		"seed": int(options.get("seed", 0)),
		"sample_source": false,
		"budget": budget,
		"entry_count": limited.size(),
		"total_entry_count": entries.size(),
		"truncated": entries.size() > budget,
		"entries": limited,
		"bounds": _bounds_for_entries(limited),
		"cell_count": int(counts.get("cell_count", 0)),
		"wall_count": int(counts.get("wall_count", 0)),
		"floor_count": int(counts.get("floor_count", 0)),
		"overlay_item_count": int(counts.get("overlay_item_count", 0)),
	}


static func _entry_from_cell(cell, kind: String, color: Color) -> Dictionary:
	return {
		"cell_key": cell.key(),
		"q": cell.q,
		"r": cell.r,
		"s": cell.s,
		"kind": kind,
		"color": color,
	}


static func _bounds_for_entries(entries: Array) -> Dictionary:
	if entries.is_empty():
		return {}
	var first = entries[0] as Dictionary
	var min_q := int(first.get("q", 0))
	var max_q := min_q
	var min_r := int(first.get("r", 0))
	var max_r := min_r
	for entry in entries:
		var entry_data := entry as Dictionary
		var q := int(entry_data.get("q", 0))
		var r := int(entry_data.get("r", 0))
		min_q = min(min_q, q)
		max_q = max(max_q, q)
		min_r = min(min_r, r)
		max_r = max(max_r, r)
	return {
		"min_q": min_q,
		"max_q": max_q,
		"min_r": min_r,
		"max_r": max_r,
	}
