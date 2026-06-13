@tool
class_name HexGenerationProfileResource
extends Resource

@export var profile_id: String = "project_generation"
@export var display_name: String = "Project Generation Profile"
@export var generator_id: String = "default"
@export var default_seed: int = 0
@export var seed_policy: String = "profile_default"
@export var shape_id: String = "rectangle"
@export var width: int = 12
@export var height: int = 8
@export var radius: int = 4
@export var wall_probability: float = 0.18
@export var connectivity_mode: String = "dense"
@export var overlay_policy: String = "none"
@export var validation_mode: String = "validate_after_generation"
@export var parameters: Dictionary = {}
@export var metadata: Dictionary = {}


func parameter_value(key: String, default_value: Variant = null) -> Variant:
	if key == "":
		return default_value
	return parameters.get(key, default_value)


func generation_options() -> Dictionary:
	return {
		"generator_id": generator_id,
		"seed": default_seed,
		"seed_policy": seed_policy,
		"shape_id": shape_id,
		"width": max(1, width),
		"height": max(1, height),
		"radius": max(1, radius),
		"wall_probability": clampf(wall_probability, 0.0, 1.0),
		"connectivity_mode": connectivity_mode,
		"overlay_policy": overlay_policy,
		"validation_mode": validation_mode,
		"parameters": parameters.duplicate(true),
	}


func behavior_schema() -> Dictionary:
	return {
		"kind": "generation_profile",
		"profile_id": profile_id,
		"display_name": display_name,
		"generator_id": generator_id,
		"default_seed": default_seed,
		"seed_policy": seed_policy,
		"shape": {
			"shape_id": shape_id,
			"width": max(1, width),
			"height": max(1, height),
			"radius": max(1, radius),
		},
		"terrain": {
			"wall_probability": clampf(wall_probability, 0.0, 1.0),
			"connectivity_mode": connectivity_mode,
		},
		"overlay_policy": overlay_policy,
		"validation_mode": validation_mode,
		"parameters": parameters.duplicate(true),
	}
