@tool
class_name HexAdjacencyRulePresets
extends RefCounted

const HexAdjacencyRuleSet = preload("res://addons/hex_map_kit/adapter/hex_adjacency_rule_set.gd")
const HexMapAssetLibrary = preload("res://addons/hex_map_kit/editor/hex_map_asset_library.gd")

const KIND := "adjacency_rules"
const PRESET_DIR := "res://addons/hex_map_kit/assets/adjacency_rules_presets"
const LEGACY_PRESET_DIR := "res://addons/hex_map_kit/assets/adjacency_rule_presets"
const FILE_FILTERS := ["*.tres ; Hex Adjacency Rule Set"]


static func list_presets() -> Array:
	return HexMapAssetLibrary.list(KIND)


static func load(path: String) -> HexAdjacencyRuleSet:
	var resource = HexMapAssetLibrary.load(path)
	if resource is HexAdjacencyRuleSet:
		return resource as HexAdjacencyRuleSet
	return null


static func save(rule_set: HexAdjacencyRuleSet, name_or_project_path: String) -> int:
	return int(save_with_result(rule_set, name_or_project_path).get("error", FAILED))


static func save_with_result(rule_set: HexAdjacencyRuleSet, name_or_project_path: String) -> Dictionary:
	return HexMapAssetLibrary.save(rule_set, KIND, name_or_project_path)


static func duplicate_to_project(path: String, name: String = "") -> Dictionary:
	return HexMapAssetLibrary.duplicate_to_project(path, KIND, name)


static func preset_path_for_name(display_name: String) -> String:
	return HexMapAssetLibrary.project_path_for_name(KIND, display_name)


static func project_dir() -> String:
	return HexMapAssetLibrary.project_dir(KIND)


static func display_name_for(rule_set: HexAdjacencyRuleSet, path: String = "") -> String:
	return HexMapAssetLibrary.display_name_for(rule_set, path)
