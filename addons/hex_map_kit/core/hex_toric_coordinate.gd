class_name HexToricCoordinate
extends RefCounted

const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")

var q: int
var r: int
var cyclic_size: int


func _init(p_q: int = 0, p_r: int = 0, p_cyclic_size: int = 1) -> void:
	q = p_q
	r = p_r
	cyclic_size = p_cyclic_size


static func apply_cyclic(point, p_cyclic_size: int):
	assert(p_cyclic_size > 0)
	return _new(
		_positive_mod(point.q - point.s, p_cyclic_size),
		_positive_mod(point.r - point.s, p_cyclic_size),
		p_cyclic_size
	)


static func wrap_vector(point, p_cyclic_size: int):
	return apply_cyclic(point, p_cyclic_size).to_vector()


func to_vector():
	return HexVectorScript.apply_basis(q, 0, r)


func axial() -> Vector2i:
	return Vector2i(q, r)


func split(scale: int) -> Vector2i:
	assert(scale > 0)
	return Vector2i(HexVectorScript._trunc_div(q, scale), HexVectorScript._trunc_div(r, scale))


static func _positive_mod(value: int, modulus: int) -> int:
	var result := value % modulus
	if result < 0:
		result += modulus
	return result


static func _new(p_q: int, p_r: int, p_cyclic_size: int):
	return load("res://addons/hex_map_kit/core/hex_toric_coordinate.gd").new(
		p_q,
		p_r,
		p_cyclic_size
	)
