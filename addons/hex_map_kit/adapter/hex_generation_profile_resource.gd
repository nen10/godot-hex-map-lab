@tool
class_name HexGenerationProfileResource
extends Resource

@export var profile_id: String = "project_generation"
@export var display_name: String = "Project Generation Profile"
@export var generator_id: String = "default"
@export var default_seed: int = 0
@export var parameters: Dictionary = {}
@export var metadata: Dictionary = {}


func parameter_value(key: String, default_value: Variant = null) -> Variant:
	if key == "":
		return default_value
	return parameters.get(key, default_value)
