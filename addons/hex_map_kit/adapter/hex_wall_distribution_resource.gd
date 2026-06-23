@tool
class_name HexWallDistributionResource
extends Resource

# Custom Markov Mesh wall distribution.
# `weights[i]` is the wall probability (0..1) for the reference-condition bitmask `i`,
# where bit `k` is set when the k-th reference neighbor is a wall.
# Mirrors the 8-entry 2x2x2 distribution used by HexRandomizer presets, but user-editable.
@export var weights: Array = []


func is_configured() -> bool:
	return not weights.is_empty()


func prob(ref_conditions: Array) -> float:
	var index := 0
	for i in range(ref_conditions.size()):
		if bool(ref_conditions[i]):
			index |= (1 << i)
	if index < 0 or index >= weights.size():
		return 0.0
	return clampf(float(weights[index]), 0.0, 1.0)
