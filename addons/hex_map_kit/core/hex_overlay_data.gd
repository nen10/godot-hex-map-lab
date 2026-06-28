class_name HexOverlayData
extends RefCounted

const HexMapDataScript = preload("res://addons/hex_map_kit/core/hex_map_data.gd")

const ITEM_QUERY_OR := "or"
const ITEM_QUERY_AND := "and"
const APPLY_CLEAR_AND_WRITE := "clear_and_write"
const APPLY_ADD_ITEM := "add_item"
const EXISTING_MERGE := "merge_existing"
const EXISTING_REPLACE := "replace_existing"
const EXISTING_SKIP := "skip_existing"

var cells: Array = []
var items: Dictionary = {}
var cyclic_size: int = 0


func _init(p_cells: Array = [], p_items: Dictionary = {}, p_cyclic_size: int = 0) -> void:
	cells = HexMapDataScript.unique_points(p_cells)
	cyclic_size = p_cyclic_size
	for item_key in p_items.keys():
		set_item_cells(String(item_key), p_items[item_key])


static func from_cells(p_cells: Array, p_items: Dictionary = {}, p_cyclic_size: int = 0):
	return load("res://addons/hex_map_kit/core/hex_overlay_data.gd").new(
		p_cells,
		p_items,
		p_cyclic_size
	)


static func from_item_cells(
	p_cells: Array,
	item_key: String,
	item_points: Array,
	p_cyclic_size: int = 0
):
	var data = load("res://addons/hex_map_kit/core/hex_overlay_data.gd").new(
		p_cells,
		{},
		p_cyclic_size
	)
	data.set_item_cells(item_key, item_points)
	return data


static func item_selector(source, item_key: String) -> Dictionary:
	return {
		"source": source,
		"item_key": item_key,
	}


static func query_item_cells(selectors: Array, operation: String = ITEM_QUERY_OR) -> Array:
	if selectors.is_empty():
		return []

	var selector_sets: Array = []
	for selector in selectors:
		selector_sets.append(_selector_item_set(selector))

	if operation == ITEM_QUERY_AND:
		return _intersect_selector_sets(selector_sets)
	return _union_selector_sets(selector_sets)


static func query_item_set(selectors: Array, operation: String = ITEM_QUERY_OR) -> Dictionary:
	return HexMapDataScript.make_set(query_item_cells(selectors, operation))


func cell_set() -> Dictionary:
	return HexMapDataScript.make_set(cells)


func item_keys() -> Array:
	var result = items.keys()
	result.sort()
	return result


func item_cells(item_key: String) -> Array:
	return items.get(item_key, []).duplicate()


func item_set(item_key: String) -> Dictionary:
	return HexMapDataScript.make_set(item_cells(item_key))


func set_item_cells(item_key: String, item_points: Array) -> void:
	var allowed = cell_set()
	var filtered = HexMapDataScript.filter_points(item_points, allowed)
	if filtered.is_empty():
		items.erase(item_key)
	else:
		items[item_key] = filtered


func add_item_cell(item_key: String, point) -> void:
	if not cell_set().has(point.key()):
		return
	var current = item_cells(item_key)
	current.append(point)
	set_item_cells(item_key, current)


func add_item_cells(item_key: String, item_points: Array) -> void:
	var current = item_cells(item_key)
	current.append_array(item_points)
	set_item_cells(item_key, current)


func apply_overlay(
	overlay,
	write_policy: String = APPLY_ADD_ITEM,
	existing_policy: String = EXISTING_MERGE
) -> void:
	if overlay == null:
		return
	var normalized_existing_policy := _normalize_existing_policy(existing_policy)
	if write_policy == APPLY_CLEAR_AND_WRITE:
		cells = overlay.cells.duplicate()
		items.clear()
	else:
		cells = HexMapDataScript.unique_points(cells + overlay.cells)

	for item_key in overlay.item_keys():
		var points = overlay.item_cells(item_key)
		if normalized_existing_policy == EXISTING_MERGE:
			add_item_cells(item_key, points)
			continue
		for point in points:
			if normalized_existing_policy == EXISTING_SKIP and not items_at(point).is_empty():
				continue
			if normalized_existing_policy == EXISTING_REPLACE:
				remove_items_at(point)
			add_item_cell(item_key, point)


func duplicate_data():
	return load("res://addons/hex_map_kit/core/hex_overlay_data.gd").from_cells(
		cells,
		items,
		cyclic_size
	)


func remove_items_at(point) -> void:
	for item_key in item_keys():
		var kept: Array = []
		for item_point in item_cells(item_key):
			if item_point.key() == point.key():
				continue
			kept.append(item_point)
		set_item_cells(item_key, kept)


func has_item(point, item_key: String) -> bool:
	return item_set(item_key).has(point.key())


func items_at(point) -> Array:
	var result: Array = []
	var key = point.key()
	for item_key in item_keys():
		if item_set(item_key).has(key):
			result.append(item_key)
	return result


func occupied_cells() -> Array:
	var result: Array = []
	var seen := {}
	for item_key in item_keys():
		for point in item_cells(item_key):
			var key = point.key()
			if seen.has(key):
				continue
			seen[key] = true
			result.append(point)
	return result


static func _normalize_existing_policy(policy: String) -> String:
	match policy:
		EXISTING_REPLACE, "replace":
			return EXISTING_REPLACE
		EXISTING_SKIP, "skip":
			return EXISTING_SKIP
		EXISTING_MERGE, "merge":
			return EXISTING_MERGE
		_:
			return EXISTING_MERGE


static func _selector_item_set(selector) -> Dictionary:
	if not selector is Dictionary:
		return {}
	var source = selector.get("source", null)
	if source == null or not source.has_method("item_cells"):
		return {}

	var item_keys: Array = []
	if selector.has("item_key"):
		item_keys.append(String(selector["item_key"]))
	elif selector.has("item_keys"):
		for item_key in selector["item_keys"]:
			item_keys.append(String(item_key))

	var result := {}
	for item_key in item_keys:
		for point in source.item_cells(item_key):
			result[point.key()] = point
	return result


static func _union_selector_sets(selector_sets: Array) -> Array:
	var result_set := {}
	for selector_set in selector_sets:
		for key in selector_set.keys():
			result_set[key] = selector_set[key]
	return result_set.values()


static func _intersect_selector_sets(selector_sets: Array) -> Array:
	if selector_sets.is_empty():
		return []
	var result_set: Dictionary = selector_sets[0].duplicate()
	for selector_set_index in range(1, selector_sets.size()):
		var selector_set: Dictionary = selector_sets[selector_set_index]
		for key in result_set.keys():
			if not selector_set.has(key):
				result_set.erase(key)
	return result_set.values()
