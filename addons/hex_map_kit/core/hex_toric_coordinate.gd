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


static func centered_vector(point, p_cyclic_size: int):
	var cyclic = apply_cyclic(point, p_cyclic_size)
	return HexVectorScript.apply_basis(
		_center_component(cyclic.q, p_cyclic_size),
		0,
		_center_component(cyclic.r, p_cyclic_size)
	)


static func unfolded_vectors(point, p_cyclic_size: int, max_l1_norm: int = -1) -> Array:
	var centered = centered_vector(point, p_cyclic_size)
	var limit = p_cyclic_size if max_l1_norm < 0 else max_l1_norm
	var result: Array = []
	var seen := {}

	for r_offset in range(-1, 2):
		for q_offset in range(-1, 2):
			var candidate = centered.add(
				HexVectorScript.apply_basis(
					q_offset * p_cyclic_size,
					0,
					r_offset * p_cyclic_size
				)
			)
			if candidate.l1_norm() > limit:
				continue
			var key = candidate.key()
			if seen.has(key):
				continue
			seen[key] = true
			result.append(candidate)

	result.sort_custom(_compare_vectors_by_norm)
	return result


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


static func _center_component(value: int, modulus: int) -> int:
	var half := modulus / 2
	return value - modulus if value > half else value


static func _compare_vectors_by_norm(left, right) -> bool:
	var left_norm = left.l1_norm()
	var right_norm = right.l1_norm()
	if left_norm != right_norm:
		return left_norm < right_norm
	return left.key() < right.key()


static func _new(p_q: int, p_r: int, p_cyclic_size: int):
	return load("res://addons/hex_map_kit/core/hex_toric_coordinate.gd").new(
		p_q,
		p_r,
		p_cyclic_size
	)
