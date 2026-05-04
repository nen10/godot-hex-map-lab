class_name HexDistribution
extends Resource

const HexRandomizerScript = preload("res://addons/hex_map_kit/core/hex_randomizer.gd")

@export var distribution_3: Array[float] = []
@export var distribution_2: Array[float] = []
@export var distribution_1: Array[float] = []


func _init(p_d3: Array = [], p_d2: Array = [], p_d1: Array = []) -> void:
	distribution_3 = p_d3
	distribution_2 = p_d2
	distribution_1 = p_d1


func is_valid() -> bool:
	return distribution_3.size() == 8 and distribution_2.size() == 4 and distribution_1.size() == 2


func prob(ref_conditions: Array) -> float:
	return HexRandomizerScript.prob_from_arrays(
		ref_conditions,
		distribution_3,
		distribution_2,
		distribution_1
	)


static func from_preset_id(distribution_id: int) -> HexDistribution:
	return new(
		HexRandomizerScript.distribution3(distribution_id),
		HexRandomizerScript.distribution2(distribution_id),
		HexRandomizerScript.distribution1(distribution_id)
	)


static func recommended() -> HexDistribution:
	return from_preset_id(20)
