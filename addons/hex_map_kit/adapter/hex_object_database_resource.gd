@tool
class_name HexObjectDatabaseResource
extends Resource

const HexObjectDefinitionScript = preload("res://addons/hex_map_kit/adapter/hex_object_definition_resource.gd")

@export var version: int = 2
@export var objects: Array = []
@export var definitions: Array[Resource] = []
@export var metadata: Dictionary = {}


func ensure_v2_defaults() -> void:
	if version < 2:
		version = 2
	if definitions.is_empty() and not objects.is_empty():
		for entry in objects:
			var definition = HexObjectDefinitionScript.from_value(entry)
			if definition == null:
				continue
			if String(definition.get("id")) == "":
				continue
			definitions.append(definition)
	if not definitions.is_empty():
		_sync_legacy_objects()


func add_definition(definition_value: Variant):
	var definition = HexObjectDefinitionScript.from_value(definition_value)
	if definition == null:
		return null
	if String(definition.get("id")) == "":
		return null
	ensure_v2_defaults()
	for index in range(definitions.size()):
		var existing = definitions[index]
		if existing == null:
			continue
		if String(existing.get("id")) == String(definition.get("id")):
			definitions[index] = definition
			_sync_legacy_objects()
			return definition
	definitions.append(definition)
	_sync_legacy_objects()
	return definition


func definition_for_id(object_id: String):
	if object_id == "":
		return null
	ensure_v2_defaults()
	for definition in definitions:
		if definition == null:
			continue
		if String(definition.get("id")) == object_id:
			return definition
	return _legacy_definition_for_id(object_id)


func has_definition(object_id: String) -> bool:
	return definition_for_id(object_id) != null


func definition_ids() -> PackedStringArray:
	ensure_v2_defaults()
	var result := PackedStringArray()
	for definition in definitions:
		if definition == null:
			continue
		var definition_id = String(definition.get("id"))
		if definition_id != "":
			result.append(definition_id)
	return result


func definitions_with_tag(tag: String) -> Array[Resource]:
	ensure_v2_defaults()
	var result: Array[Resource] = []
	for definition in definitions:
		if definition == null:
			continue
		if definition.has_method("has_tag") and definition.has_tag(tag):
			result.append(definition)
	return result


func legacy_objects() -> Array:
	ensure_v2_defaults()
	return objects.duplicate(true)


func _legacy_definition_for_id(object_id: String):
	for entry in objects:
		var definition = HexObjectDefinitionScript.from_value(entry)
		if definition == null:
			continue
		if String(definition.get("id")) == object_id:
			return definition
	return null


func _sync_legacy_objects() -> void:
	var migrated: Array = []
	for definition in definitions:
		if definition == null:
			continue
		var normalized = HexObjectDefinitionScript.from_value(definition)
		if normalized == null:
			continue
		if normalized.has_method("to_dictionary"):
			migrated.append(normalized.to_dictionary())
	objects = migrated
