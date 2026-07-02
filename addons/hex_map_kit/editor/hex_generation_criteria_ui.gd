@tool
class_name HexGenerationCriteriaUi
extends RefCounted

const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const HexGenerationParamSchemaScript = preload("res://addons/hex_map_kit/generation/hex_generation_param_schema.gd")
const HexMapAssetLibraryScript = preload("res://addons/hex_map_kit/editor/hex_map_asset_library.gd")

const EDITOR_DISTRIBUTION := "distribution"
const EDITOR_RULES := "rules"
const EDITOR_ITEM_POOL := "item_pool"

const PATH_DISTRIBUTION := "distribution_asset_path"
const PATH_RULES := "rules_asset_path"
const PATH_ITEM_POOL := "item_pool_asset_path"


static func chip_states(node_type: String, params: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not HexGenerationNodeTypesScript.is_consolidated_type(node_type):
		return result
	var added := {}
	for entry in HexGenerationParamSchemaScript.schema_for(node_type, params):
		if not bool(entry.get("visible_when", true)):
			continue
		var state := _state_for_schema_entry(entry, params)
		if state.is_empty():
			continue
		var editor_key := String(state.get("editor_key", ""))
		if editor_key == "" or added.has(editor_key):
			continue
		added[editor_key] = true
		result.append(state)
	return result


static func path_key_for_editor(editor_key: String) -> String:
	match editor_key:
		EDITOR_DISTRIBUTION:
			return PATH_DISTRIBUTION
		EDITOR_RULES:
			return PATH_RULES
		EDITOR_ITEM_POOL:
			return PATH_ITEM_POOL
	return ""


static func asset_kind_for_editor(editor_key: String) -> String:
	match editor_key:
		EDITOR_DISTRIBUTION:
			return HexGenerationParamSchemaScript.ASSET_WALL_DISTRIBUTIONS
		EDITOR_RULES:
			return HexGenerationParamSchemaScript.ASSET_ADJACENCY_RULES
		EDITOR_ITEM_POOL:
			return HexGenerationParamSchemaScript.ASSET_ITEM_POOLS
	return ""


static func display_prefix_for_editor(editor_key: String) -> String:
	match editor_key:
		EDITOR_DISTRIBUTION:
			return "dist"
		EDITOR_RULES:
			return "rules"
		EDITOR_ITEM_POOL:
			return "pool"
	return "asset"


static func _state_for_schema_entry(entry: Dictionary, params: Dictionary) -> Dictionary:
	var asset_kind := String(entry.get("asset_kind", ""))
	if asset_kind == "":
		return {}
	var key := String(entry.get("key", ""))
	match asset_kind:
		HexGenerationParamSchemaScript.ASSET_WALL_DISTRIBUTIONS:
			return _build_state(
				EDITOR_DISTRIBUTION,
				asset_kind,
				PATH_DISTRIBUTION,
				_distribution_inline_name(key, entry, params),
				params
			)
		HexGenerationParamSchemaScript.ASSET_ADJACENCY_RULES:
			return _build_state(EDITOR_RULES, asset_kind, PATH_RULES, "inline", params)
		HexGenerationParamSchemaScript.ASSET_ITEM_POOLS:
			return _build_state(EDITOR_ITEM_POOL, asset_kind, PATH_ITEM_POOL, "inline", params)
	return {}


static func _build_state(
	editor_key: String,
	asset_kind: String,
	path_key: String,
	inline_name: String,
	params: Dictionary
) -> Dictionary:
	var prefix := display_prefix_for_editor(editor_key)
	var path := String(params.get(path_key, "")).strip_edges()
	var referenced := path != ""
	var source_name := inline_name
	var source := "inline"
	if referenced:
		source = "reference"
		source_name = _asset_display_name(path)
	var label := "%s: %s" % [prefix, source_name]
	if referenced:
		label = "%s [ref]" % label
	return {
		"editor_key": editor_key,
		"asset_kind": asset_kind,
		"path_key": path_key,
		"path": path,
		"referenced": referenced,
		"source": source,
		"source_name": source_name,
		"label": label,
	}


static func _distribution_inline_name(key: String, entry: Dictionary, params: Dictionary) -> String:
	if key == "distribution_id" or String(params.get("distribution_mode", "")) == "preset":
		var current_id = params.get("distribution_id", entry.get("default", 20))
		for option in entry.get("options", []) as Array:
			var option_dict := option as Dictionary
			if _values_equal(option_dict.get("value", null), current_id):
				return String(option_dict.get("label", "Distribution"))
		return "Distribution %s" % str(current_id)
	return "inline"


static func _asset_display_name(path: String) -> String:
	var resource = HexMapAssetLibraryScript.load(path)
	if resource != null:
		return HexMapAssetLibraryScript.display_name_for(resource, path)
	var basename := path.get_file().get_basename()
	return basename.capitalize() if basename != "" else "missing asset"


static func _values_equal(a, b) -> bool:
	if typeof(a) == typeof(b):
		return a == b
	return str(a) == str(b)
