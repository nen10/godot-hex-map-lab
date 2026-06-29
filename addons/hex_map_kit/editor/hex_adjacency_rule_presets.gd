@tool
class_name HexAdjacencyRulePresets
extends RefCounted

const HexAdjacencyRuleSet = preload("res://addons/hex_map_kit/adapter/hex_adjacency_rule_set.gd")

const PRESET_DIR := "res://addons/hex_map_kit/assets/adjacency_rule_presets"
const FILE_FILTERS := ["*.tres ; Hex Adjacency Rule Set"]


static func list_presets() -> Array:
	var result: Array = []
	for path in _find_rule_set_paths(PRESET_DIR):
		var resource = _load_resource(path)
		if not resource is HexAdjacencyRuleSet:
			continue
		var rule_set := resource as HexAdjacencyRuleSet
		result.append({
			"name": display_name_for(rule_set, path),
			"path": path,
		})
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return String(a.get("name", "")).casecmp_to(String(b.get("name", ""))) < 0
	)
	return result


static func load(path: String) -> HexAdjacencyRuleSet:
	var resource = _load_resource(path)
	if resource is HexAdjacencyRuleSet:
		return resource as HexAdjacencyRuleSet
	return null


static func save(rule_set: HexAdjacencyRuleSet, path: String) -> int:
	if rule_set == null or path == "":
		return ERR_INVALID_PARAMETER
	_ensure_parent_dir(path)
	return ResourceSaver.save(rule_set, path)


static func preset_path_for_name(display_name: String) -> String:
	var file_name := _safe_file_name(display_name)
	if file_name == "":
		file_name = "adjacency_rules"
	return "%s/%s.tres" % [PRESET_DIR, file_name]


static func display_name_for(rule_set: HexAdjacencyRuleSet, path: String = "") -> String:
	if rule_set != null and rule_set.display_name.strip_edges() != "":
		return rule_set.display_name.strip_edges()
	var basename := path.get_file().get_basename()
	if basename == "":
		return "Unnamed adjacency rules"
	return basename.capitalize()


static func _find_rule_set_paths(base_path: String) -> Array:
	var result: Array = []
	var dir := DirAccess.open(base_path)
	if dir == null:
		return result
	dir.list_dir_begin()
	while true:
		var entry := dir.get_next()
		if entry == "":
			break
		if entry.begins_with("."):
			continue
		var path := "%s/%s" % [base_path, entry]
		if dir.current_is_dir():
			result.append_array(_find_rule_set_paths(path))
		elif entry.get_extension().to_lower() == "tres":
			result.append(path)
	dir.list_dir_end()
	return result


static func _load_resource(path: String):
	if path == "":
		return null
	return ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)


static func _ensure_parent_dir(path: String) -> void:
	var parent_dir := path.get_base_dir()
	if parent_dir == "":
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(parent_dir))


static func _safe_file_name(display_name: String) -> String:
	var text := display_name.strip_edges().to_snake_case()
	var result := ""
	for index in range(text.length()):
		var code := text.unicode_at(index)
		var character := text.substr(index, 1)
		var is_ascii_letter := (code >= 65 and code <= 90) or (code >= 97 and code <= 122)
		var is_digit := code >= 48 and code <= 57
		if is_ascii_letter or is_digit or character == "_" or character == "-":
			result += character
		elif character == " ":
			result += "_"
	return result.strip_edges().trim_prefix("_").trim_suffix("_")
