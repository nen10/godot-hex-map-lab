class_name HexGameplayLayerData
extends RefCounted

const HexMapDocumentAdapterScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMovementProfileResourceScript = preload("res://addons/hex_map_kit/adapter/hex_movement_profile_resource.gd")
const HexMovementProfileScript = preload("res://addons/hex_map_kit/core/hex_movement_profile.gd")
const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")

var profile = null
var cell_states: Dictionary = {}


static func from_map_data(data, movement_profile = null):
	var result = load("res://addons/hex_map_kit/adapter/hex_gameplay_layer_data.gd").new()
	result.profile = _profile_from_value(movement_profile)
	if data == null:
		return result
	var wall_set = data.wall_set()
	for cell in data.cells:
		var kind = HexMovementProfileScript.KIND_WALL if wall_set.has(cell.key()) else HexMovementProfileScript.KIND_FLOOR
		result.cell_states[cell.key()] = _state_for_cell(result.profile, cell, kind)
	return result


static func from_document(document, movement_profile = null, tile_catalog = null):
	var map_resource = HexMapDocumentAdapterScript.to_map_resource(document)
	var data = map_resource.to_map_data() if map_resource != null else null
	var result = from_map_data(data, movement_profile)
	if data == null:
		return result
	for entry in HexMapDocumentAdapterScript.document_tile_entries(document):
		var catalog_key = String(entry.get("catalog_key", ""))
		var cell = _hex_from_entry_cell(entry.get("cell", Vector3i.ZERO))
		if not result.cell_states.has(cell.key()):
			continue
		var kind = String(entry.get("kind", HexMovementProfileScript.KIND_FLOOR))
		var tags = _catalog_tags(tile_catalog, catalog_key)
		result.cell_states[cell.key()] = _state_for_cell(result.profile, cell, kind, catalog_key, tags)
	for object_entry in HexMapDocumentAdapterScript.document_object_entries(document):
		var object_id = String(object_entry.get("object_id", ""))
		var cell = _hex_from_entry_cell(object_entry.get("cell", Vector3i.ZERO))
		if object_id == "" or not result.cell_states.has(cell.key()):
			continue
		if result.profile.get("blocker_keys").has(object_id):
			result.cell_states[cell.key()] = _state_with_blocker(result.cell_states[cell.key()], object_id)
	return result


func has_cell(hex) -> bool:
	return cell_states.has(hex.key())


func state_for_cell(hex) -> Dictionary:
	if not has_cell(hex):
		return {
			"exists": false,
			"passable": false,
			"cost": 0.0,
			"blockers": PackedStringArray(),
			"kind": "",
			"catalog_key": "",
		}
	return (cell_states[hex.key()] as Dictionary).duplicate(true)


func is_passable(hex) -> bool:
	return bool(state_for_cell(hex).get("passable", false))


func movement_cost(hex) -> float:
	return float(state_for_cell(hex).get("cost", 0.0))


func blocker_keys(hex) -> PackedStringArray:
	return state_for_cell(hex).get("blockers", PackedStringArray())


func passable_cells() -> Array:
	var result: Array = []
	for key in cell_states:
		var state = cell_states[key]
		if state is Dictionary and bool(state.get("passable", false)):
			result.append(state.get("cell"))
	return result


func movement_costs() -> Dictionary:
	var result := {}
	for key in cell_states:
		var state = cell_states[key]
		if not (state is Dictionary):
			continue
		if not bool(state.get("passable", false)):
			continue
		result[key] = float(state.get("cost", 1.0))
	return result


static func _profile_from_value(value):
	if value == null:
		return HexMovementProfileResourceScript.new()
	return value


static func _state_for_cell(profile_value, cell, kind: String, catalog_key: String = "", tags: PackedStringArray = PackedStringArray()) -> Dictionary:
	var state = profile_value.cell_state(kind, catalog_key, tags)
	state["cell"] = cell
	state["cell_key"] = cell.key()
	return state


static func _state_with_blocker(state: Dictionary, blocker_key: String) -> Dictionary:
	var copy = state.duplicate(true)
	var blockers: PackedStringArray = copy.get("blockers", PackedStringArray())
	if not blockers.has(blocker_key):
		blockers.append(blocker_key)
	copy["blockers"] = blockers
	copy["passable"] = false
	return copy


static func _hex_from_entry_cell(cell):
	if cell is Vector3i:
		return HexVectorScript.apply_basis(cell.x, cell.y, cell.z)
	if cell is HexVectorScript:
		return HexVectorScript.apply_basis(cell.q, cell.s, cell.r)
	return HexVectorScript.zero()


static func _catalog_tags(tile_catalog, catalog_key: String) -> PackedStringArray:
	if tile_catalog == null or catalog_key == "":
		return PackedStringArray()
	if not tile_catalog.has_method("entry_for_key"):
		return PackedStringArray()
	var entry = tile_catalog.entry_for_key(catalog_key)
	if entry == null:
		return PackedStringArray()
	return entry.get("tags") if entry.get("tags") is PackedStringArray else PackedStringArray()
