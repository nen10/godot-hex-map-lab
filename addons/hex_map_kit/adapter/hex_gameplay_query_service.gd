class_name HexGameplayQueryService
extends RefCounted

const HexGameplayLayerData = preload("res://addons/hex_map_kit/adapter/hex_gameplay_layer_data.gd")
const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexGrid = preload("res://addons/hex_map_kit/core/hex_grid.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")

var map_data = null
var default_movement_profile = null
var tile_catalog = null
var source_document = null


func _init(
	data = null,
	movement_profile = null,
	catalog = null,
	document = null
) -> void:
	map_data = data
	default_movement_profile = movement_profile
	tile_catalog = catalog
	source_document = document


static func from_map_data(map_data, movement_profile = null, tile_catalog = null):
	var service_script = load("res://addons/hex_map_kit/adapter/hex_gameplay_query_service.gd")
	return service_script.new(map_data, movement_profile, tile_catalog, null)


static func from_document(document, movement_profile = null, tile_catalog = null):
	var map_resource = HexMapDocumentAdapter.to_map_resource(document)
	var data = map_resource.to_map_data() if map_resource != null else null
	var service_script = load("res://addons/hex_map_kit/adapter/hex_gameplay_query_service.gd")
	return service_script.new(data, movement_profile, tile_catalog, document)


func gameplay_layer_data(profile = null) -> HexGameplayLayerData:
	if source_document != null:
		return HexGameplayLayerData.from_document(source_document, _resolve_profile(profile), tile_catalog)
	return HexGameplayLayerData.from_map_data(map_data, _resolve_profile(profile))


func find_path(start, goal) -> Array:
	if map_data == null:
		return []
	var start_hex = _normalized_hex(start)
	var goal_hex = _normalized_hex(goal)
	var floors = map_data.floor_cells()
	return HexGrid.shortest_path(start_hex, [goal_hex], floors, map_data.cyclic_size)


func find_weighted_path(start, goal, movement_profile = null) -> Array:
	if map_data == null:
		return []
	var start_hex = _normalized_hex(start)
	var goal_hex = _normalized_hex(goal)
	var gameplay = gameplay_layer_data(movement_profile)
	return HexGrid.weighted_path(
		start_hex,
		[goal_hex],
		gameplay.passable_cells(),
		gameplay.movement_costs(),
		map_data.cyclic_size
	)


func movement_range(start, movement_budget: float, movement_profile = null) -> Dictionary:
	if map_data == null:
		return {}
	var start_hex = _normalized_hex(start)
	var gameplay = gameplay_layer_data(movement_profile)
	return HexGrid.movement_range(
		start_hex,
		gameplay.passable_cells(),
		movement_budget,
		gameplay.movement_costs(),
		map_data.cyclic_size
	)


func is_map_connected() -> bool:
	if map_data == null:
		return true
	return HexMapGenerator.is_floor_connected(map_data)


func connected_component(hex) -> Array:
	if map_data == null:
		return []
	var start_hex = _normalized_hex(hex)
	return HexGrid.connected_area(start_hex, map_data.floor_cells(), map_data.cyclic_size)


func connected_component_from_local(local_pos: Vector2, local_to_cell_hit: Callable) -> Array:
	if not local_to_cell_hit.is_valid():
		return []
	var hit = local_to_cell_hit.call(local_pos)
	if not (hit is Dictionary):
		return []
	if not bool(hit.get("exists", false)):
		return []
	return connected_component(hit.get("hex"))


func _resolve_profile(profile) -> Variant:
	if profile != null:
		return profile
	return default_movement_profile


func _normalized_hex(value) -> HexVector:
	if value is HexVector:
		return HexVector.apply_basis(value.q, value.s, value.r)
	if value is Vector3i:
		return HexVector.apply_basis(value.x, value.y, value.z)
	return HexVector.zero()
