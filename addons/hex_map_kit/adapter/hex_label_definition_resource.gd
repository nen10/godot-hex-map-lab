@tool
class_name HexLabelDefinitionResource
extends Resource

@export var label_id: String = ""
@export var display_name: String = ""
@export var default_text: String = ""
@export var style_key: String = ""
@export var tags: PackedStringArray = PackedStringArray()
@export var metadata: Dictionary = {}


func has_tag(tag: String) -> bool:
	return tags.has(tag)


func to_dictionary() -> Dictionary:
	return {
		"label_id": label_id,
		"display_name": display_name,
		"default_text": default_text,
		"style_key": style_key,
		"tags": tags.duplicate(),
		"metadata": metadata.duplicate(true),
	}
