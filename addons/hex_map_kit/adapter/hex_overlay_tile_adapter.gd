class_name HexOverlayTileAdapter
extends RefCounted

const HexMapTileAdapterScript = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")


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


static func item_tiles_from_catalog(
	catalog,
	item_catalog_keys: Dictionary,
	fallback_item_tiles: Dictionary = {}
) -> Dictionary:
	var result := fallback_item_tiles.duplicate(true)
	for item_key in item_catalog_keys.keys():
		var key = String(item_key)
		var fallback = result.get(key, {})
		var config = HexMapTileAdapterScript.tile_config_from_catalog(
			catalog,
			String(item_catalog_keys[item_key]),
			fallback
		)
		if int(config.get("source_id", -1)) >= 0:
			result[key] = config
	return result


static func apply_to_tile_map_layer_with_catalog(
	layer,
	data,
	catalog,
	item_catalog_keys: Dictionary,
	fallback_item_tiles: Dictionary = {},
	clear_layer: bool = true,
	flat_top: bool = true,
	item_order: Array = []
) -> void:
	apply_to_tile_map_layer(
		layer,
		data,
		item_tiles_from_catalog(catalog, item_catalog_keys, fallback_item_tiles),
		clear_layer,
		flat_top,
		item_order
	)


static func to_tile_entries(
	data,
	item_tiles: Dictionary,
	flat_top: bool = true,
	item_order: Array = []
) -> Array:
	var ordered_items = item_order.duplicate()
	if ordered_items.is_empty():
		ordered_items = data.item_keys()

	var entries: Array = []
	for item_index in range(ordered_items.size()):
		var item_key = String(ordered_items[item_index])
		if not item_tiles.has(item_key):
			continue
		var config: Dictionary = item_tiles[item_key]
		for cell in data.item_cells(item_key):
			entries.append({
				"vector": cell,
				"item_key": item_key,
				"map_cell": HexMapTileAdapterScript.vector_to_map_cell(cell, flat_top),
				"sort_z": HexMapTileAdapterScript.vector_to_sort_z(cell),
				"priority": item_index,
				"source_id": int(config.get("source_id", -1)),
				"atlas_coords": config.get("atlas_coords", Vector2i.ZERO),
				"alternative_tile": int(config.get("alternative_tile", 0)),
			})

	entries.sort_custom(_compare_entries)
	return entries


static func apply_to_tile_map_layer(
	layer,
	data,
	item_tiles: Dictionary,
	clear_layer: bool = true,
	flat_top: bool = true,
	item_order: Array = []
) -> void:
	if clear_layer and layer.has_method("clear"):
		layer.clear()

	for entry in to_tile_entries(data, item_tiles, flat_top, item_order):
		if int(entry["source_id"]) < 0:
			continue
		layer.set_cell(
			entry["map_cell"],
			entry["source_id"],
			entry["atlas_coords"],
			entry["alternative_tile"]
		)


static func _compare_entries(left: Dictionary, right: Dictionary) -> bool:
	var left_cell: Vector2i = left["map_cell"]
	var right_cell: Vector2i = right["map_cell"]
	if left_cell.y != right_cell.y:
		return left_cell.y < right_cell.y
	if left_cell.x != right_cell.x:
		return left_cell.x < right_cell.x
	if int(left["sort_z"]) != int(right["sort_z"]):
		return int(left["sort_z"]) < int(right["sort_z"])
	return int(left["priority"]) < int(right["priority"])
