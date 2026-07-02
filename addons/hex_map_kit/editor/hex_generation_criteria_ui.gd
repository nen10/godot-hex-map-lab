@tool
class_name HexGenerationCriteriaUi
extends RefCounted

const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const HexGenerationParamSchemaScript = preload("res://addons/hex_map_kit/generation/hex_generation_param_schema.gd")
const HexMapAssetLibraryScript = preload("res://addons/hex_map_kit/editor/hex_map_asset_library.gd")
const HexAdjacencyRuleSetScript = preload("res://addons/hex_map_kit/adapter/hex_adjacency_rule_set.gd")
const HexWallDistributionResourceScript = preload("res://addons/hex_map_kit/adapter/hex_wall_distribution_resource.gd")
const HexItemPoolResourceScript = preload("res://addons/hex_map_kit/adapter/hex_item_pool_resource.gd")

const EDITOR_DISTRIBUTION := "distribution"
const EDITOR_RULES := "rules"
const EDITOR_ITEM_POOL := "item_pool"

const PATH_DISTRIBUTION := "distribution_asset_path"
const PATH_RULES := "rules_asset_path"
const PATH_ITEM_POOL := "item_pool_asset_path"

const CHIP_MENU_OPEN_EDITOR := 1
const CHIP_MENU_SAVE_AS_ASSET := 2
const CHIP_MENU_DETACH_TO_INLINE := 3
const CHIP_MENU_LOAD_ASSET_BASE := 1000


static func chip_states(node_type: String, params: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not HexGenerationNodeTypesScript.is_consolidated_type(node_type):
		return result
	var added := {}
	for entry in HexGenerationParamSchemaScript.schema_for(node_type, params):
		if not bool(entry.get("visible_when", true)):
			continue
		if bool(entry.get("hidden", false)):
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


static func criteria_save_name(editor_key: String, node_display_name: String, node_id: String = "") -> String:
	var display_name := node_display_name.strip_edges()
	if display_name == "":
		display_name = node_id.strip_edges()
	match editor_key:
		EDITOR_DISTRIBUTION:
			return "%s Distribution" % display_name
		EDITOR_RULES:
			return "%s Rules" % display_name
		EDITOR_ITEM_POOL:
			return "%s Pool" % display_name
	return "%s Criteria" % display_name


static func resource_from_params(editor_key: String, params: Dictionary, display_name: String) -> Resource:
	match editor_key:
		EDITOR_DISTRIBUTION:
			var distribution := HexWallDistributionResourceScript.new()
			distribution.display_name = display_name
			if String(params.get("distribution_mode", "")) == "preset":
				var preset = HexWallDistributionResourceScript.from_preset(int(params.get("distribution_id", 20)))
				distribution.weights_by_count = preset.weights_by_count.duplicate(true)
			else:
				distribution.weights_by_count = _distribution_values_from_params(params)
			return distribution
		EDITOR_RULES:
			var rules := HexAdjacencyRuleSetScript.from_dialog_dict(_probability_rules_from_params(params), display_name)
			rules.display_name = display_name
			return rules
		EDITOR_ITEM_POOL:
			var pool := HexItemPoolResourceScript.new()
			pool.display_name = display_name
			var entries = params.get("item_pool", [])
			pool.entries = entries.duplicate(true) if entries is Array else []
			return pool
	return null


static func params_after_asset_load(editor_key: String, params: Dictionary, resource, path: String) -> Dictionary:
	var result := params.duplicate(true)
	match editor_key:
		EDITOR_DISTRIBUTION:
			if not resource is HexWallDistributionResourceScript:
				return {}
			result["custom_distribution"] = (resource as HexWallDistributionResourceScript).weights_by_count.duplicate(true)
			result["distribution_mode"] = "custom"
			result[PATH_DISTRIBUTION] = path
		EDITOR_RULES:
			if not resource is HexAdjacencyRuleSetScript:
				return {}
			var dialog_dict := (resource as HexAdjacencyRuleSetScript).to_dialog_dict()
			result["probability_rules"] = {
				"name": HexMapAssetLibraryScript.display_name_for(resource, path),
				"default": dialog_dict.get("default", 0.5),
				"rules": (dialog_dict.get("rules", []) as Array).duplicate(true),
			}
			result[PATH_RULES] = path
		EDITOR_ITEM_POOL:
			if not resource is HexItemPoolResourceScript:
				return {}
			result["item_pool"] = (resource as HexItemPoolResourceScript).entries.duplicate(true)
			result[PATH_ITEM_POOL] = path
		_:
			return {}
	return result


static func params_after_detach(editor_key: String, params: Dictionary) -> Dictionary:
	var result := params.duplicate(true)
	var path_key := path_key_for_editor(editor_key)
	if path_key != "":
		result[path_key] = ""
	return result


static func save_current_as_asset(editor_key: String, params: Dictionary, display_name: String) -> Dictionary:
	var resource := resource_from_params(editor_key, params, display_name)
	if resource == null:
		return {"error": ERR_INVALID_PARAMETER, "path": "", "entry": {}, "params": params.duplicate(true)}
	var save_result := HexMapAssetLibraryScript.save(
		resource,
		asset_kind_for_editor(editor_key),
		display_name
	)
	var error := int(save_result.get("error", FAILED))
	var next_params := params.duplicate(true)
	if error == OK:
		var path_key := path_key_for_editor(editor_key)
		if path_key != "":
			next_params[path_key] = String(save_result.get("path", ""))
	save_result["params"] = next_params
	return save_result


static func populate_chip_menu(popup: PopupMenu, editor_key: String, params: Dictionary) -> void:
	if popup == null:
		return
	popup.clear()
	popup.add_item("Open editor...", CHIP_MENU_OPEN_EDITOR)
	popup.add_separator()
	popup.add_item("Load from asset...", -1)
	popup.set_item_disabled(popup.item_count - 1, true)
	var asset_kind := asset_kind_for_editor(editor_key)
	var next_id := CHIP_MENU_LOAD_ASSET_BASE
	var asset_count := 0
	for asset in HexMapAssetLibraryScript.list(asset_kind):
		var asset_dict := asset as Dictionary
		var label := String(asset_dict.get("name", ""))
		var source := String(asset_dict.get("source", ""))
		if source != "":
			label = "%s [%s]" % [label, source]
		popup.add_item(label, next_id)
		popup.set_item_metadata(popup.item_count - 1, String(asset_dict.get("path", "")))
		next_id += 1
		asset_count += 1
	if asset_count == 0:
		popup.add_item("(no saved assets)", -1)
		popup.set_item_disabled(popup.item_count - 1, true)
	popup.add_separator()
	popup.add_item("Save as asset...", CHIP_MENU_SAVE_AS_ASSET)
	popup.add_item("Detach to inline", CHIP_MENU_DETACH_TO_INLINE)
	var path_key := path_key_for_editor(editor_key)
	if path_key == "" or String(params.get(path_key, "")).strip_edges() == "":
		popup.set_item_disabled(popup.item_count - 1, true)


static func menu_item_path(popup: PopupMenu, id: int) -> String:
	if popup == null:
		return ""
	for index in range(popup.item_count):
		if popup.get_item_id(index) == id:
			return String(popup.get_item_metadata(index))
	return ""


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
		var options = entry.get("options", []) as Array
		var default_id = entry.get("default", 20)
		if options.is_empty():
			var id_entry = (HexGenerationParamSchemaScript.declarations(
				HexGenerationNodeTypesScript.NODE_TERRAIN_GENERATION
			) as Dictionary).get("distribution_id", {}) as Dictionary
			options = id_entry.get("options", []) as Array
			default_id = id_entry.get("default", default_id)
		var current_id = params.get("distribution_id", default_id)
		for option in options:
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


static func _distribution_values_from_params(params: Dictionary) -> Dictionary:
	var values = params.get("custom_distribution", {})
	var result := {}
	for count in [0, 1, 2, 3]:
		var key := str(count)
		var size: int = 1 << count
		var raw = (values as Dictionary).get(key, []) if values is Dictionary else []
		if raw is Array and (raw as Array).size() >= size:
			result[key] = (raw as Array).slice(0, size)
		else:
			result[key] = _markov_default_weights(count)
	return result


static func _markov_default_weights(reference_count: int) -> Array:
	match reference_count:
		3:
			return [5.0, 3.0, 3.0, 5.0, 3.0, 7.0, 5.0, 1.0]
		2:
			return [7.0, 5.0, 3.0, 1.0]
		1:
			return [5.0, 2.0]
		0, _:
			return [0.0]


static func _probability_rules_from_params(params: Dictionary) -> Dictionary:
	var value = params.get("probability_rules", {})
	if value is Dictionary:
		return {
			"default": clampf(float((value as Dictionary).get("default", 0.5)), 0.0, 1.0),
			"rules": ((value as Dictionary).get("rules", []) as Array).duplicate(true),
		}
	return {
		"default": 0.5,
		"rules": [],
	}


static func _values_equal(a, b) -> bool:
	if typeof(a) == typeof(b):
		return a == b
	return str(a) == str(b)
