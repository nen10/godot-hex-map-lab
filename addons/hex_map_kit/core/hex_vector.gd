class_name HexVector
extends RefCounted

const APPROXIMATE_TERM := 0.5213

var q: int
var s: int
var r: int


func _init(p_q: int = 0, p_s: int = 0, p_r: int = 0) -> void:
	q = p_q
	s = p_s
	r = p_r


static func apply_basis(p_q: int, p_s: int, p_r: int):
	var min_delta := _min_int(p_q - p_s, p_r - p_s)
	var max_delta := _max_int(p_q - p_s, p_r - p_s)
	var slide := p_s
	if min_delta * max_delta > 0:
		slide += min_delta if min_delta > 0 else max_delta
	return _new(p_q - slide, p_s - slide, p_r - slide)


static func zero():
	return apply_basis(0, 0, 0)


static func q_axis():
	return apply_basis(1, 0, 0)


static func s_axis():
	return apply_basis(0, 1, 0)


static func r_axis():
	return apply_basis(0, 0, 1)


static func directions() -> Array:
	return [
		q_axis(),
		r_axis().negated(),
		s_axis(),
		q_axis().negated(),
		r_axis(),
		s_axis().negated(),
	]


func clone():
	return _new(q, s, r)


func key() -> String:
	return "%d,%d,%d" % [q, s, r]


func axial() -> Vector2i:
	return Vector2i(q - s, r - s)


func is_equal(other) -> bool:
	return q == other.q and s == other.s and r == other.r


func l_infinity_norm() -> int:
	return _max_int(_max_int(_abs_int(q), _abs_int(r)), _abs_int(s))


func l1_norm() -> int:
	return _abs_int(q) + _abs_int(s) + _abs_int(r)


func co_norm() -> int:
	return l1_norm() - l_infinity_norm()


func l2_norm() -> float:
	return approximate_l2_norm(float(l1_norm()), float(co_norm()))


static func approximate_l2_norm(l1_norm: float, co_norm: float) -> float:
	if l1_norm == 0.0:
		return 0.0
	var order1 := minf(co_norm, l1_norm - co_norm)
	return l1_norm - (APPROXIMATE_TERM - order1 / (2.0 * l1_norm)) * order1


func add(other):
	return apply_basis(q + other.q, s + other.s, r + other.r)


func subtract(other):
	return apply_basis(q - other.q, s - other.s, r - other.r)


func negated():
	return scaled(-1)


func scaled(amount: int):
	return apply_basis(q * amount, s * amount, r * amount)


func divided(amount: int):
	assert(amount != 0)
	return apply_basis(
		_trunc_div(q, amount),
		_trunc_div(s, amount),
		_trunc_div(r, amount)
	)


func debug_string() -> String:
	return "(Q:%d, S:%d, R:%d)" % [q, s, r]


static func _abs_int(value: int) -> int:
	return -value if value < 0 else value


static func _min_int(left: int, right: int) -> int:
	return left if left < right else right


static func _max_int(left: int, right: int) -> int:
	return left if left > right else right


static func _trunc_div(left: int, right: int) -> int:
	return int(float(left) / float(right))


static func _new(p_q: int, p_s: int, p_r: int):
	return load("res://addons/hex_map_kit/core/hex_vector.gd").new(p_q, p_s, p_r)
