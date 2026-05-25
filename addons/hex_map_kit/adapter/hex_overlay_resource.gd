class_name HexOverlayResource
extends Resource

const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexOverlayDataScript = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexMapResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")

@export var cells: Array[Vector3i] = []
@export var item_keys: PackedStringArray = PackedStringArray()
@export var item_cells: Array = []
@export var cyclic_size: int = 0
@export_enum("flat-top", "pointy-top") var orientation: int = HexMapResourceScript.ORIENTATION_FLAT_TOP


static func from_overlay_data(data, p_orientation: int = HexMapResourceScript.ORIENTATION_FLAT_TOP):
	var resource = load("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd").new()
	resource.set_from_overlay_data(data, p_orientation)
	return resource


func set_from_overlay_data(data, p_orientation: int = HexMapResourceScript.ORIENTATION_FLAT_TOP) -> void:
	cells = _vectors_to_components(data.cells)
	item_keys = PackedStringArray()
	item_cells = []
	for item_key in data.item_keys():
		item_keys.append(item_key)
		item_cells.append(_vectors_to_components(data.item_cells(item_key)))
	cyclic_size = data.cyclic_size
	orientation = HexMapResourceScript.normalize_orientation(p_orientation)


func to_overlay_data():
	var items := {}
	for index in range(item_keys.size()):
		items[String(item_keys[index])] = _components_to_vectors(item_cells[index])
	return HexOverlayDataScript.from_cells(
		_components_to_vectors(cells),
		items,
		cyclic_size
	)


func is_flat_top() -> bool:
	return orientation == HexMapResourceScript.ORIENTATION_FLAT_TOP


static func _vectors_to_components(vectors: Array) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	for vector in vectors:
		result.append(Vector3i(vector.q, vector.s, vector.r))
	return result


static func _components_to_vectors(components: Array) -> Array:
	var result: Array = []
	for component in components:
		result.append(HexVectorScript.apply_basis(component.x, component.y, component.z))
	return result
