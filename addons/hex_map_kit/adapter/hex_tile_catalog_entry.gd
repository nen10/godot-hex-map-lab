@tool
class_name HexTileCatalogEntry
extends Resource

const TYPE_ATLAS := "atlas"
const TYPE_SCENE := "scene"
const TYPE_PLACEHOLDER := "placeholder"

@export var key: String = ""
@export var display_name: String = ""
@export_enum("atlas", "scene", "placeholder") var entry_type: String = TYPE_ATLAS
@export var source_id: int = 0
@export var atlas_coords: Vector2i = Vector2i.ZERO
@export var alternative_tile: int = 0
@export var scene: PackedScene
@export var tags: PackedStringArray = PackedStringArray()
@export var metadata: Dictionary = {}


func is_atlas_tile() -> bool:
	return entry_type == TYPE_ATLAS


func is_scene_tile() -> bool:
	return entry_type == TYPE_SCENE


func is_placeholder() -> bool:
	return entry_type == TYPE_PLACEHOLDER


func has_tag(tag: String) -> bool:
	return tags.has(tag)
