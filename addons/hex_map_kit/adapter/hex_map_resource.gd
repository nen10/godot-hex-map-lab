@tool
class_name HexMapResource
extends Resource

const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexMapDataScript = preload("res://addons/hex_map_kit/core/hex_map_data.gd")

const ORIENTATION_FLAT_TOP := 0
const ORIENTATION_POINTY_TOP := 1

@export var cells: Array[Vector3i] = []
@export var walls: Array[Vector3i] = []
@export var cyclic_size: int = 0
@export_enum("flat-top", "pointy-top") var orientation: int = ORIENTATION_FLAT_TOP


static func from_map_data(data, p_orientation: int = ORIENTATION_FLAT_TOP):
	var resource = load("res://addons/hex_map_kit/adapter/hex_map_resource.gd").new()
	resource.set_from_map_data(data, p_orientation)
	return resource


func set_from_map_data(data, p_orientation: int = ORIENTATION_FLAT_TOP) -> void:
	cells = _vectors_to_components(data.cells)
	walls = _vectors_to_components(data.walls)
	cyclic_size = data.cyclic_size
	orientation = normalize_orientation(p_orientation)


func is_flat_top() -> bool:
	return orientation == ORIENTATION_FLAT_TOP


func to_map_data():
	return HexMapDataScript.from_cells(
		_components_to_vectors(cells),
		_components_to_vectors(walls),
		cyclic_size
	)


static func normalize_orientation(value: int) -> int:
	return ORIENTATION_POINTY_TOP if value == ORIENTATION_POINTY_TOP else ORIENTATION_FLAT_TOP


static func _vectors_to_components(vectors: Array) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	for vector in vectors:
		result.append(Vector3i(vector.q, vector.s, vector.r))
	return result


static func _components_to_vectors(components: Array[Vector3i]) -> Array:
	var result: Array = []
	for component in components:
		result.append(HexVectorScript.apply_basis(component.x, component.y, component.z))
	return result
