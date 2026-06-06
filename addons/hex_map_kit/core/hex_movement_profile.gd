class_name HexMovementProfile
extends RefCounted

const KIND_FLOOR := "floor"
const KIND_WALL := "wall"
const BLOCKER_WALL := "wall"

var profile_id := "default"
var display_name := "Default Movement"
var default_passable := true
var default_cost := 1.0
var wall_passable := false
var wall_cost := 1.0
var terrain_costs: Dictionary = {}
var blocker_keys: PackedStringArray = PackedStringArray()
var blocker_tags: PackedStringArray = PackedStringArray(["blocking"])


func cell_state(kind: String = KIND_FLOOR, catalog_key: String = "", tags: PackedStringArray = PackedStringArray()) -> Dictionary:
	var blockers := PackedStringArray()
	var passable := default_passable
	var cost := default_cost
	if kind == KIND_WALL:
		passable = wall_passable
		cost = wall_cost
		if not wall_passable:
			blockers.append(BLOCKER_WALL)
	var override_cost = _cost_override(kind, catalog_key, tags)
	if override_cost != null:
		cost = float(override_cost)
	if catalog_key != "" and blocker_keys.has(catalog_key):
		blockers.append(catalog_key)
	for tag in tags:
		if blocker_tags.has(tag):
			blockers.append(tag)
	return {
		"passable": passable and blockers.is_empty(),
		"cost": maxf(0.0, cost),
		"blockers": blockers,
		"kind": kind,
		"catalog_key": catalog_key,
	}


func duplicate_profile():
	var copy = load("res://addons/hex_map_kit/core/hex_movement_profile.gd").new()
	copy.profile_id = profile_id
	copy.display_name = display_name
	copy.default_passable = default_passable
	copy.default_cost = default_cost
	copy.wall_passable = wall_passable
	copy.wall_cost = wall_cost
	copy.terrain_costs = terrain_costs.duplicate(true)
	copy.blocker_keys = blocker_keys.duplicate()
	copy.blocker_tags = blocker_tags.duplicate()
	return copy


func _cost_override(kind: String, catalog_key: String, tags: PackedStringArray):
	if catalog_key != "" and terrain_costs.has(catalog_key):
		return terrain_costs[catalog_key]
	if terrain_costs.has(kind):
		return terrain_costs[kind]
	for tag in tags:
		if terrain_costs.has(tag):
			return terrain_costs[tag]
		if tag.begins_with("cost:"):
			return float(tag.substr(5))
	return null
