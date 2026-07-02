@tool
class_name HexMapAssetLibrary
extends RefCounted

const ASSET_ROOT_SETTING := "hex_map_kit/asset_root"
const DEFAULT_ASSET_ROOT := "res://hex_map"
const BUNDLED_ASSET_ROOT := "res://addons/hex_map_kit/assets"
const SOURCE_BUNDLED := "bundled"
const SOURCE_PROJECT := "project"

const _BUNDLED_DIR_ALIASES := {
	"adjacency_rules": ["res://addons/hex_map_kit/assets/adjacency_rule_presets"],
}


static func list(kind: String) -> Array:
	var result: Array = []
	var seen_paths := {}
	for bundled_dir in bundled_dirs(kind):
		for path in _find_resource_paths(bundled_dir):
			if seen_paths.has(path):
				continue
			seen_paths[path] = true
			var resource = load(path)
			if resource == null:
				continue
			result.append({
				"name": display_name_for(resource, path),
				"path": path,
				"source": SOURCE_BUNDLED,
			})
	for path in _find_resource_paths(project_dir(kind)):
		if seen_paths.has(path):
			continue
		seen_paths[path] = true
		var resource = load(path)
		if resource == null:
			continue
		result.append({
			"name": display_name_for(resource, path),
			"path": path,
			"source": SOURCE_PROJECT,
		})
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var name_compare := String(a.get("name", "")).casecmp_to(String(b.get("name", "")))
		if name_compare != 0:
			return name_compare < 0
		var source_compare := String(a.get("source", "")).casecmp_to(String(b.get("source", "")))
		if source_compare != 0:
			return source_compare < 0
		return String(a.get("path", "")).casecmp_to(String(b.get("path", ""))) < 0
	)
	return result


static func load(path: String):
	if String(path).strip_edges() == "":
		return null
	return ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)


static func save(resource: Resource, kind: String, name: String) -> Dictionary:
	if resource == null or _normalized_kind(kind) == "" or String(name).strip_edges() == "":
		return _save_result(ERR_INVALID_PARAMETER, "", resource)
	var path := project_path_for_name(kind, name)
	if _is_bundled_path(path, kind):
		return _save_result(ERR_FILE_CANT_WRITE, path, resource)
	if not _is_project_kind_path(path, kind):
		return _save_result(ERR_INVALID_PARAMETER, path, resource)
	_ensure_parent_dir(path)
	var display_name := display_name_from_name_or_path(name)
	if display_name != "":
		_set_display_name_if_blank(resource, display_name)
	var error := ResourceSaver.save(resource, path)
	return _save_result(error, path, resource)


static func duplicate_to_project(path: String, kind: String, name: String = "") -> Dictionary:
	if String(path).strip_edges() == "" or _normalized_kind(kind) == "":
		return _save_result(ERR_INVALID_PARAMETER, "", null)
	var source = load(path)
	if not source is Resource:
		return _save_result(ERR_FILE_CANT_OPEN, "", null)
	var duplicated = (source as Resource).duplicate(true)
	if not duplicated is Resource:
		return _save_result(ERR_INVALID_PARAMETER, "", null)
	var save_name := String(name).strip_edges()
	if save_name == "":
		save_name = display_name_for(duplicated as Resource, path)
	_set_display_name(duplicated as Resource, save_name)
	return save(duplicated as Resource, kind, save_name)


static func bundled_dir(kind: String) -> String:
	return "%s/%s_presets" % [BUNDLED_ASSET_ROOT, _normalized_kind(kind)]


static func bundled_dirs(kind: String) -> Array:
	var result: Array = [bundled_dir(kind)]
	var aliases: Array = _BUNDLED_DIR_ALIASES.get(_normalized_kind(kind), [])
	for alias_path in aliases:
		if not result.has(String(alias_path)):
			result.append(String(alias_path))
	return result


static func project_dir(kind: String) -> String:
	return "%s/%s" % [_asset_root(), _normalized_kind(kind)]


static func project_path_for_name(kind: String, name: String) -> String:
	var text := String(name).strip_edges()
	if text.begins_with("res://"):
		return _normalize_path(text)
	var file_name := _safe_file_name(text)
	if file_name == "":
		file_name = _normalized_kind(kind)
	return "%s/%s.tres" % [project_dir(kind), file_name]


static func display_name_for(resource, path: String = "") -> String:
	if resource is Object and _has_property(resource as Object, "display_name"):
		var display_name := String((resource as Object).get("display_name")).strip_edges()
		if display_name != "":
			return display_name
	var basename := String(path).get_file().get_basename()
	if basename == "":
		return "Unnamed asset"
	return basename.capitalize()


static func display_name_from_name_or_path(name: String) -> String:
	var text := String(name).strip_edges()
	if text.begins_with("res://"):
		return text.get_file().get_basename().capitalize()
	return text


static func _asset_root() -> String:
	var root := DEFAULT_ASSET_ROOT
	if ProjectSettings.has_setting(ASSET_ROOT_SETTING):
		root = String(ProjectSettings.get_setting(ASSET_ROOT_SETTING)).strip_edges()
	if root == "":
		root = DEFAULT_ASSET_ROOT
	return _normalize_path(root)


static func _normalized_kind(kind: String) -> String:
	var result := ""
	for index in range(String(kind).length()):
		var code := String(kind).unicode_at(index)
		var character := String(kind).substr(index, 1)
		var is_ascii_letter := (code >= 65 and code <= 90) or (code >= 97 and code <= 122)
		var is_digit := code >= 48 and code <= 57
		if is_ascii_letter or is_digit or character == "_":
			result += character.to_lower()
	return result.strip_edges().trim_prefix("_").trim_suffix("_")


static func _find_resource_paths(base_path: String) -> Array:
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
			result.append_array(_find_resource_paths(path))
		elif entry.get_extension().to_lower() in ["tres", "res"]:
			result.append(path)
	dir.list_dir_end()
	return result


static func _ensure_parent_dir(path: String) -> void:
	var parent_dir := String(path).get_base_dir()
	if parent_dir == "":
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(parent_dir))


static func _is_bundled_path(path: String, kind: String) -> bool:
	for dir_path in bundled_dirs(kind):
		if _is_same_or_child(path, String(dir_path)):
			return true
	return false


static func _is_project_kind_path(path: String, kind: String) -> bool:
	return _is_same_or_child(path, project_dir(kind))


static func _is_same_or_child(path: String, base_path: String) -> bool:
	var normalized_path := _normalize_path(path)
	var normalized_base := _normalize_path(base_path)
	return normalized_path == normalized_base or normalized_path.begins_with("%s/" % normalized_base)


static func _normalize_path(path: String) -> String:
	var normalized := String(path).strip_edges().replace("\\", "/")
	while normalized.ends_with("/") and normalized.length() > "res://".length():
		normalized = normalized.trim_suffix("/")
	return normalized


static func _save_result(error: int, path: String, resource) -> Dictionary:
	var entry := {}
	if error == OK and resource != null and path != "":
		entry = {
			"name": display_name_for(resource, path),
			"path": path,
			"source": SOURCE_PROJECT,
		}
	return {
		"error": error,
		"path": path,
		"source": SOURCE_PROJECT if error == OK else "",
		"entry": entry,
	}


static func _set_display_name_if_blank(resource: Resource, display_name: String) -> void:
	if display_name.strip_edges() == "":
		return
	if not _has_property(resource, "display_name"):
		return
	if String(resource.get("display_name")).strip_edges() == "":
		resource.set("display_name", display_name.strip_edges())


static func _set_display_name(resource: Resource, display_name: String) -> void:
	if display_name.strip_edges() == "":
		return
	if _has_property(resource, "display_name"):
		resource.set("display_name", display_name.strip_edges())


static func _has_property(object: Object, property_name: String) -> bool:
	for property in object.get_property_list():
		if String((property as Dictionary).get("name", "")) == property_name:
			return true
	return false


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
