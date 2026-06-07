@tool
class_name HexObjectDatabaseResource
extends Resource

const HexObjectDefinitionScript = preload("res://addons/hex_map_kit/adapter/hex_object_definition_resource.gd")

@export var definitions: Array[Resource] = []
@export var metadata: Dictionary = {}


func add_definition(definition: HexObjectDefinitionScript):
	if definition == null:
		return null
	if String(definition.get("id")) == "":
		return null
	for index in range(definitions.size()):
		var existing = definitions[index]
		if existing == null:
			continue
		if String(existing.get("id")) == String(definition.get("id")):
			definitions[index] = definition
			return definition
	definitions.append(definition)
	return definition


func definition_for_id(object_id: String):
	if object_id == "":
		return null
	for definition in definitions:
		if definition == null:
			continue
		if String(definition.get("id")) == object_id:
			return definition
	return null


func has_definition(object_id: String) -> bool:
	return definition_for_id(object_id) != null


func definition_ids() -> PackedStringArray:
	var result := PackedStringArray()
	for definition in definitions:
		if definition == null:
			continue
		var definition_id = String(definition.get("id"))
		if definition_id != "":
			result.append(definition_id)
	return result


func definitions_with_tag(tag: String) -> Array[Resource]:
	var result: Array[Resource] = []
	for definition in definitions:
		if definition == null:
			continue
		if definition.has_method("has_tag") and definition.has_tag(tag):
			result.append(definition)
	return result
