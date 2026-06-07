@tool
class_name HexTileCatalogResource
extends Resource

const HexTileCatalogEntryScript = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_entry.gd")

@export var catalog_id: String = ""
@export var display_name: String = ""
@export var tile_set: TileSet
@export var entries: Array[Resource] = []
@export var metadata: Dictionary = {}


func entry_for_key(key: String):
	if key == "":
		return null
	for entry in entries:
		if entry == null:
			continue
		if String(entry.get("key")) == key:
			return entry
	return null


func has_key(key: String) -> bool:
	return entry_for_key(key) != null


func keys() -> PackedStringArray:
	var result := PackedStringArray()
	for entry in entries:
		if entry == null:
			continue
		var entry_key = String(entry.get("key"))
		if entry_key != "":
			result.append(entry_key)
	return result


func entries_with_tag(tag: String) -> Array[Resource]:
	var result: Array[Resource] = []
	for entry in entries:
		if entry == null:
			continue
		if entry.has_method("has_tag") and entry.has_tag(tag):
			result.append(entry)
	return result


func add_entry(entry: HexTileCatalogEntryScript) -> void:
	if entry != null:
		entries.append(entry)
