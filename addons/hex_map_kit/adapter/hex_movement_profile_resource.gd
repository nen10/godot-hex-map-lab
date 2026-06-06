@tool
class_name HexMovementProfileResource
extends Resource

const HexMovementProfileScript = preload("res://addons/hex_map_kit/core/hex_movement_profile.gd")

@export var profile_id: String = "default"
@export var display_name: String = "Default Movement"
@export var default_passable: bool = true
@export var default_cost: float = 1.0
@export var wall_passable: bool = false
@export var wall_cost: float = 1.0
@export var terrain_costs: Dictionary = {}
@export var blocker_keys: PackedStringArray = PackedStringArray()
@export var blocker_tags: PackedStringArray = PackedStringArray(["blocking"])


func to_profile():
	var profile = HexMovementProfileScript.new()
	profile.profile_id = profile_id
	profile.display_name = display_name
	profile.default_passable = default_passable
	profile.default_cost = default_cost
	profile.wall_passable = wall_passable
	profile.wall_cost = wall_cost
	profile.terrain_costs = terrain_costs.duplicate(true)
	profile.blocker_keys = blocker_keys.duplicate()
	profile.blocker_tags = blocker_tags.duplicate()
	return profile


func cell_state(kind: String = HexMovementProfileScript.KIND_FLOOR, catalog_key: String = "", tags: PackedStringArray = PackedStringArray()) -> Dictionary:
	return to_profile().cell_state(kind, catalog_key, tags)
