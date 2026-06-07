@tool
class_name HexObjectDefinitionResource
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var scene: PackedScene
@export var tags: PackedStringArray = PackedStringArray()
@export var default_properties: Dictionary = {}
@export var preview_texture: Texture2D


func object_id() -> String:
	return id


func has_tag(tag: String) -> bool:
	return tags.has(tag)


func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
		"scene": scene,
		"tags": tags.duplicate(),
		"default_properties": default_properties.duplicate(true),
		"preview_texture": preview_texture,
	}
