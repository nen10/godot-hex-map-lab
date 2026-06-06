@tool
class_name HexObjectDefinitionResource
extends Resource

const SELF_PATH := "res://addons/hex_map_kit/adapter/hex_object_definition_resource.gd"

@export var id: String = ""
@export var display_name: String = ""
@export var scene_path: String = ""
@export var tags: PackedStringArray = PackedStringArray()
@export var default_properties: Dictionary = {}
@export var preview: String = ""


func object_id() -> String:
	return id


func has_tag(tag: String) -> bool:
	return tags.has(tag)


func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"object_id": id,
		"display_name": display_name,
		"scene_path": scene_path,
		"tags": tags.duplicate(),
		"default_properties": default_properties.duplicate(true),
		"preview": preview,
	}


static func from_dictionary(data: Dictionary):
	var definition = load(SELF_PATH).new()
	definition.id = String(data.get("id", data.get("object_id", "")))
	definition.display_name = String(data.get("display_name", ""))
	definition.scene_path = String(data.get("scene_path", ""))
	definition.tags = _packed_string_array(data.get("tags", PackedStringArray()))
	definition.default_properties = _dictionary_value(data.get("default_properties", data.get("properties", {})))
	definition.preview = String(data.get("preview", data.get("preview_path", "")))
	return definition


static func from_value(value: Variant):
	if value == null:
		return null
	if value is Dictionary:
		return from_dictionary(value)
	if value is Resource:
		if value.get_script() == load(SELF_PATH):
			return value
		return from_dictionary(_resource_dictionary(value))
	return null


static func _resource_dictionary(resource: Resource) -> Dictionary:
	var data := {}
	for key in [
		"id",
		"object_id",
		"display_name",
		"scene_path",
		"tags",
		"default_properties",
		"properties",
		"preview",
		"preview_path",
	]:
		var value = resource.get(key)
		if value != null:
			data[key] = value
	return data


static func _packed_string_array(value: Variant) -> PackedStringArray:
	var result := PackedStringArray()
	if value is PackedStringArray:
		return value.duplicate()
	if value is Array:
		for item in value:
			result.append(String(item))
	elif value is String and value != "":
		result.append(value)
	return result


static func _dictionary_value(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value.duplicate(true)
	return {}
