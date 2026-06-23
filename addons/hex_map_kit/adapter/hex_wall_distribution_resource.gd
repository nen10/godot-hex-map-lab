@tool
class_name HexWallDistributionResource
extends Resource

# Custom Markov Mesh wall distribution.
# Weights are stored per reference-neighbor count, because cell scanning can see
# 3, 2, 1, or 0 already-generated neighbors. For a given reference count `n`,
# `weights_by_count[n][bitmask]` is the wall probability weight (0..8,
# probability = weight / 8), where bit `k` is set when reference neighbor `k`
# is a wall. This mirrors HexRandomizer's per-count distribution tables but is
# user-editable, and is independent from the built-in presets.
@export var weights_by_count: Dictionary = {}


static func reference_state_count(reference_count: int) -> int:
	return 1 << max(0, reference_count)


func is_configured() -> bool:
	return not weights_by_count.is_empty()


func prob(ref_conditions: Array) -> float:
	var reference_count := ref_conditions.size()
	var weights = _weights_for_count(reference_count)
	if weights.is_empty():
		return 0.0
	var index := 0
	for i in range(reference_count):
		if bool(ref_conditions[i]):
			index |= (1 << i)
	if index < 0 or index >= weights.size():
		return 0.0
	return clampf(float(weights[index]) / 8.0, 0.0, 1.0)


func _weights_for_count(reference_count: int) -> Array:
	var key := str(reference_count)
	if weights_by_count.has(key) and weights_by_count[key] is Array:
		return weights_by_count[key] as Array
	if weights_by_count.has(reference_count) and weights_by_count[reference_count] is Array:
		return weights_by_count[reference_count] as Array
	return []
