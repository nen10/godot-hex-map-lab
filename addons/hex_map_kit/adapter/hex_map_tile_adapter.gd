class_name HexMapTileAdapter
extends RefCounted

const KIND_FLOOR := "floor"
const KIND_WALL := "wall"
const SAMPLE_TILE_ATLAS_PATH := "res://addons/hex_map_kit/assets/sample_hex_tiles.png"
const SAMPLE_TILE_SIZE := Vector2i(64, 57)

const HexPointScript = preload("res://addons/hex_map_kit/core/hex_point.gd")


static func tile_config(
	source_id: int,
	atlas_coords: Vector2i = Vector2i.ZERO,
	alternative_tile: int = 0
) -> Dictionary:
	return {
		"source_id": source_id,
		"atlas_coords": atlas_coords,
		"alternative_tile": alternative_tile,
	}


static func tile_config_from_catalog(catalog, catalog_key: String) -> Dictionary:
	var config := tile_config(-1)
	if catalog == null or catalog_key == "" or not catalog.has_method("entry_for_key"):
		return config
	var entry = catalog.entry_for_key(catalog_key)
	if entry == null:
		return config
	var entry_type = String(entry.get("entry_type"))
	config["catalog_key"] = catalog_key
	config["entry_type"] = entry_type
	config["scene"] = entry.get("scene")
	if entry_type not in ["atlas", "scene"]:
		return config
	config["source_id"] = int(entry.get("source_id"))
	config["atlas_coords"] = entry.get("atlas_coords")
	config["alternative_tile"] = int(entry.get("alternative_tile"))
	return config


static func vector_to_map_cell(vector, flat_top: bool = true) -> Vector2i:
	var axial := vector_to_display_axial(vector)
	if flat_top:
		return Vector2i(axial.x, axial.y + _floor_div2(axial.x))
	return Vector2i(axial.x + _floor_div2(axial.y), axial.y)


static func map_cell_to_vector(map_cell: Vector2i, flat_top: bool = true):
	var axial: Vector2i
	if flat_top:
		axial = Vector2i(map_cell.x, map_cell.y - _floor_div2(map_cell.x))
	else:
		axial = Vector2i(map_cell.x - _floor_div2(map_cell.y), map_cell.y)
	return load("res://addons/hex_map_kit/core/hex_vector.gd").apply_basis(
		axial.x + axial.y,
		0,
		axial.y
	)


static func vector_to_sort_z(vector) -> int:
	return _vector_to_point(vector).to_cell().z


static func vector_to_display_axial(vector) -> Vector2i:
	return Vector2i(vector.q - vector.r, vector.r - vector.s)


static func to_tile_entries(
	data,
	include_floors: bool = true,
	include_walls: bool = true,
	flat_top: bool = true
) -> Array:
	var wall_set = data.wall_set()
	var entries: Array = []

	for cell in data.cells:
		var is_wall = wall_set.has(cell.key())
		var kind = KIND_WALL if is_wall else KIND_FLOOR
		if is_wall and not include_walls:
			continue
		if not is_wall and not include_floors:
			continue

		entries.append({
			"vector": cell,
			"kind": kind,
			"map_cell": vector_to_map_cell(cell, flat_top),
			"sort_z": vector_to_sort_z(cell),
		})

	entries.sort_custom(_compare_entries)
	return entries


static func apply_to_tile_map_layer(
	layer,
	data,
	floor_source_id: int = 0,
	floor_atlas_coords: Vector2i = Vector2i.ZERO,
	wall_source_id: int = 0,
	wall_atlas_coords: Vector2i = Vector2i(1, 0),
	clear_layer: bool = true,
	flat_top: bool = true,
	floor_alternative_tile: int = 0,
	wall_alternative_tile: int = 0
) -> Dictionary:
	return apply_to_tile_map_layer_chunked(
		layer,
		data,
		floor_source_id,
		floor_atlas_coords,
		wall_source_id,
		wall_atlas_coords,
		clear_layer,
		flat_top,
		floor_alternative_tile,
		wall_alternative_tile
	)


static func apply_to_tile_map_layer_chunked(
	layer,
	data,
	floor_source_id: int = 0,
	floor_atlas_coords: Vector2i = Vector2i.ZERO,
	wall_source_id: int = 0,
	wall_atlas_coords: Vector2i = Vector2i(1, 0),
	clear_layer: bool = true,
	flat_top: bool = true,
	floor_alternative_tile: int = 0,
	wall_alternative_tile: int = 0,
	options: Dictionary = {}
) -> Dictionary:
	var entries := to_tile_entries(data, true, true, flat_top) if data != null else []
	var chunk_size := _apply_chunk_size(options)
	var report := _apply_report(layer, entries.size(), chunk_size, clear_layer, options)
	if layer == null or data == null:
		report["ok"] = false
		report["error"] = ERR_INVALID_PARAMETER
		report["blocked_reason"] = "Missing TileMap target or map data."
		return report
	if clear_layer and layer.has_method("clear"):
		layer.clear()
		report["cleared"] = true
	if _report_apply_progress(options, report, "clear"):
		return _cancel_apply_report(report)

	for entry in entries:
		if entry["kind"] == KIND_WALL:
			if wall_source_id >= 0:
				layer.set_cell(entry["map_cell"], wall_source_id, wall_atlas_coords, wall_alternative_tile)
				report["written_cells"] = int(report["written_cells"]) + 1
		else:
			if floor_source_id >= 0:
				layer.set_cell(entry["map_cell"], floor_source_id, floor_atlas_coords, floor_alternative_tile)
				report["written_cells"] = int(report["written_cells"]) + 1
		report["processed_cells"] = int(report["processed_cells"]) + 1
		if _apply_chunk_due(int(report["processed_cells"]), int(report["total_cells"]), chunk_size):
			if _report_apply_progress(options, report, "tiles"):
				return _cancel_apply_report(report)
	report["ok"] = true
	report["error"] = OK
	report["progress"] = 1.0
	_report_apply_progress(options, report, "complete")
	return report


static func apply_to_tile_map_layer_with_catalog(
	layer,
	data,
	catalog,
	floor_catalog_key: String,
	wall_catalog_key: String,
	options: Dictionary = {}
) -> Dictionary:
	var floor_config = tile_config_from_catalog(catalog, floor_catalog_key)
	var wall_config = tile_config_from_catalog(catalog, wall_catalog_key)
	return apply_to_tile_map_layer(
		layer,
		data,
		int(floor_config.get("source_id", -1)),
		floor_config.get("atlas_coords", Vector2i.ZERO),
		int(wall_config.get("source_id", -1)),
		wall_config.get("atlas_coords", Vector2i(1, 0)),
		bool(options.get("clear_layer", true)),
		bool(options.get("flat_top", true)),
		int(floor_config.get("alternative_tile", 0)),
		int(wall_config.get("alternative_tile", 0))
	)


static func _apply_report(
	layer,
	total_cells: int,
	chunk_size: int,
	clear_layer: bool,
	options: Dictionary
) -> Dictionary:
	return {
		"ok": false,
		"error": OK,
		"cancelled": false,
		"blocked_reason": "",
		"target_scope": _apply_target_scope(layer),
		"apply_reason": String(options.get("apply_reason", "tile_map_apply")),
		"clear_layer": clear_layer,
		"cleared": false,
		"chunked": true,
		"chunk_size": chunk_size,
		"total_cells": total_cells,
		"processed_cells": 0,
		"written_cells": 0,
		"progress": 0.0 if total_cells > 0 else 1.0,
		"progress_event_count": 0,
		"last_phase": "start",
	}


static func _apply_target_scope(layer) -> Dictionary:
	var target_class := "set_cell_target"
	var target_name := ""
	if layer is Object:
		var object := layer as Object
		target_class = object.get_class()
		if object is Node:
			target_name = (object as Node).name
	return {
		"target_kind": "tile_map",
		"target_class": target_class,
		"target_name": target_name,
	}


static func _apply_chunk_size(options: Dictionary) -> int:
	return max(1, int(options.get("chunk_size", options.get("apply_chunk_size", 256))))


static func _apply_chunk_due(processed_cells: int, total_cells: int, chunk_size: int) -> bool:
	return processed_cells >= total_cells or processed_cells % chunk_size == 0


static func _report_apply_progress(options: Dictionary, report: Dictionary, phase: String) -> bool:
	var total_cells := int(report.get("total_cells", 0))
	var processed_cells := int(report.get("processed_cells", 0))
	report["last_phase"] = phase
	report["progress"] = 1.0 if total_cells <= 0 else clampf(float(processed_cells) / float(total_cells), 0.0, 1.0)
	report["progress_event_count"] = int(report.get("progress_event_count", 0)) + 1
	var status := report.duplicate(true)
	status["phase"] = phase
	var progress_callback = options.get("progress_callback", Callable())
	if progress_callback is Callable and progress_callback.is_valid():
		progress_callback.call(status)
	var cancel_callback = options.get("cancel_callback", Callable())
	if cancel_callback is Callable and cancel_callback.is_valid() and bool(cancel_callback.call(status)):
		return true
	return bool(options.get("cancel_requested", false))


static func _cancel_apply_report(report: Dictionary) -> Dictionary:
	report["ok"] = false
	report["error"] = ERR_BUSY
	report["cancelled"] = true
	report["blocked_reason"] = "Apply cancelled."
	return report


static func configure_hex_tile_set(
	tile_set: TileSet,
	flat_top: bool = true,
	tile_size: Vector2i = Vector2i.ZERO
) -> void:
	if tile_set == null:
		return
	tile_set.tile_shape = TileSet.TILE_SHAPE_HEXAGON
	tile_set.tile_layout = TileSet.TILE_LAYOUT_STACKED
	tile_set.tile_offset_axis = TileSet.TILE_OFFSET_AXIS_VERTICAL if flat_top else TileSet.TILE_OFFSET_AXIS_HORIZONTAL
	if tile_size.x > 0 and tile_size.y > 0:
		tile_set.tile_size = tile_size


static func configure_sample_tile_set(
	tile_set: TileSet,
	flat_top: bool = true,
	tile_size: Vector2i = SAMPLE_TILE_SIZE
) -> bool:
	var texture := load_sample_tile_texture()
	return configure_atlas_tile_set(
		tile_set,
		texture,
		flat_top,
		tile_size,
		0,
		[Vector2i(0, 0), Vector2i(1, 0)]
	)


static func configure_atlas_tile_set(
	tile_set: TileSet,
	texture: Texture2D,
	flat_top: bool = true,
	tile_size: Vector2i = SAMPLE_TILE_SIZE,
	source_id: int = 0,
	tile_coords: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0)]
) -> bool:
	if tile_set == null or texture == null:
		return false
	configure_hex_tile_set(tile_set, flat_top, tile_size)
	if tile_set.has_source(source_id):
		tile_set.remove_source(source_id)

	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = tile_size
	tile_set.add_source(source, source_id)
	for coords in tile_coords:
		if not source.has_tile(coords):
			source.create_tile(coords)
	return true


static func load_sample_tile_texture() -> Texture2D:
	return load_tile_texture(SAMPLE_TILE_ATLAS_PATH)


static func load_tile_texture(path: String) -> Texture2D:
	var resource = load(path)
	if resource is Texture2D:
		return resource
	var image := Image.new()
	var error = image.load(ProjectSettings.globalize_path(path))
	if error != OK:
		return null
	return ImageTexture.create_from_image(image)


static func hex_to_local(vector, hex_size: float, flat_top: bool = true) -> Vector2:
	var axial: Vector2i = vector_to_display_axial(vector)
	var q = float(axial.x)
	var r = float(axial.y)
	var sqrt3 = sqrt(3.0)

	if flat_top:
		return Vector2(
			hex_size * 1.5 * q,
			hex_size * sqrt3 * (r + q * 0.5)
		)

	return Vector2(
		hex_size * sqrt3 * (q + r * 0.5),
		hex_size * 1.5 * r
	)


static func _vector_to_point(vector):
	return HexPointScript.from_basis(vector.q, vector.s, vector.r)


static func _floor_div2(value: int) -> int:
	return int(floor(float(value) / 2.0))


static func _compare_entries(left: Dictionary, right: Dictionary) -> bool:
	var left_cell: Vector2i = left["map_cell"]
	var right_cell: Vector2i = right["map_cell"]
	if left_cell.y != right_cell.y:
		return left_cell.y < right_cell.y
	if left_cell.x != right_cell.x:
		return left_cell.x < right_cell.x
	return left["sort_z"] < right["sort_z"]
