class_name HexPoint
extends RefCounted

const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")

var q: int
var r: int


func _init(p_q: int = 0, p_r: int = 0) -> void:
	q = p_q
	r = p_r


static func from_cube(p_q: int, p_s: int, p_r: int):
	return _new(p_q - p_s, p_r - p_s)


static func from_offset(x: int, y: int):
	return _new(x + HexVectorScript._trunc_div(y + HexVectorScript._abs_int(y) % 2, 2), y)


func key() -> String:
	return "%d,%d" % [q, r]


func is_equal(other) -> bool:
	return q == other.q and r == other.r


func coordinate_align() -> int:
	return r - 2 * q


func add_vector(vector):
	return from_cube(q + vector.q, vector.s, r + vector.r)


func subtract_vector(vector):
	return from_cube(q - vector.q, -vector.s, r - vector.r)


func vector_from(other):
	return HexVectorScript.apply_basis(q - other.q, 0, r - other.r)


func vector_to(other):
	return HexVectorScript.apply_basis(other.q - q, 0, other.r - r)


func l1_distance_to(other) -> int:
	return vector_from(other).l1_norm()


func l2_distance_to(other) -> float:
	return vector_from(other).l2_norm()


func to_offset() -> Vector2i:
	var rem := HexVectorScript._abs_int(r) % 2
	var x := q - HexVectorScript._trunc_div(r + rem, 2)
	return Vector2i(x, r)


func to_cell() -> Vector3i:
	var offset := to_offset()
	return Vector3i(offset.x, offset.y, -coordinate_align())


func relative_cell(origin_z_order: int) -> Vector3i:
	var offset := to_offset()
	return Vector3i(offset.x, offset.y, origin_z_order - coordinate_align())


func debug_string() -> String:
	return "(Q:%d, R:%d)" % [q, r]


static func _new(p_q: int, p_r: int):
	return load("res://addons/hex_map_kit/core/hex_point.gd").new(p_q, p_r)
