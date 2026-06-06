@tool
class_name HexTileCatalogEntry
extends Resource

const TYPE_ATLAS := "atlas"
const TYPE_SCENE := "scene"
const TYPE_FALLBACK := "fallback"

@export var key: String = ""
@export var display_name: String = ""
@export_enum("atlas", "scene", "fallback") var entry_type: String = TYPE_ATLAS
@export var source_id: int = 0
@export var atlas_coords: Vector2i = Vector2i.ZERO
@export var alternative_tile: int = 0
@export var scene_path: String = ""
@export var tags: PackedStringArray = PackedStringArray()
@export var fallback_source_id: int = -1
@export var fallback_atlas_coords: Vector2i = Vector2i.ZERO
@export var fallback_alternative_tile: int = 0
@export var metadata: Dictionary = {}


func is_atlas_tile() -> bool:
	return entry_type == TYPE_ATLAS


func is_scene_tile() -> bool:
	return entry_type == TYPE_SCENE


func has_tag(tag: String) -> bool:
	return tags.has(tag)


func effective_source_id() -> int:
	return source_id if source_id >= 0 else fallback_source_id


func effective_atlas_coords() -> Vector2i:
	return atlas_coords if source_id >= 0 else fallback_atlas_coords


func effective_alternative_tile() -> int:
	return alternative_tile if source_id >= 0 else fallback_alternative_tile
