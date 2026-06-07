@tool
class_name HexLabelDatabaseResource
extends Resource

const HexLabelDefinitionScript = preload("res://addons/hex_map_kit/adapter/hex_label_definition_resource.gd")

@export var definitions: Array[Resource] = []
@export var metadata: Dictionary = {}


func add_definition(definition: HexLabelDefinitionScript):
	if definition == null:
		return null
	if String(definition.get("label_id")) == "":
		return null
	for index in range(definitions.size()):
		var existing = definitions[index]
		if existing == null:
			continue
		if String(existing.get("label_id")) == String(definition.get("label_id")):
			definitions[index] = definition
			return definition
	definitions.append(definition)
	return definition


func definition_for_id(label_id: String):
	if label_id == "":
		return null
	for definition in definitions:
		if definition == null:
			continue
		if String(definition.get("label_id")) == label_id:
			return definition
	return null


func has_definition(label_id: String) -> bool:
	return definition_for_id(label_id) != null


func definition_ids() -> PackedStringArray:
	var result := PackedStringArray()
	for definition in definitions:
		if definition == null:
			continue
		var definition_id = String(definition.get("label_id"))
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
