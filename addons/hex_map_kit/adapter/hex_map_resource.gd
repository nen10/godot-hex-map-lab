class_name HexMapResource
extends Resource

const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexMapDataScript = preload("res://addons/hex_map_kit/core/hex_map_data.gd")

@export var cells: Array[Vector3i] = []
@export var walls: Array[Vector3i] = []
@export var cyclic_size: int = 0


static func from_map_data(data):
	var resource = load("res://addons/hex_map_kit/adapter/hex_map_resource.gd").new()
	resource.set_from_map_data(data)
	return resource


func set_from_map_data(data) -> void:
	cells = _vectors_to_components(data.cells)
	walls = _vectors_to_components(data.walls)
	cyclic_size = data.cyclic_size


func to_map_data():
	return HexMapDataScript.from_cells(
		_components_to_vectors(cells),
		_components_to_vectors(walls),
		cyclic_size
	)


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
