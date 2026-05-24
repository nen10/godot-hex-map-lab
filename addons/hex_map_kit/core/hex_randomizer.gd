class_name HexRandomizer
extends RefCounted

const DISTRIBUTION_2X2X2_BASE_000 := [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
const DISTRIBUTION_2X2X2_BASE_113 := [1.0, 5.0, 4.0, 6.0, 5.0, 7.0, 6.0, 7.0]
const DISTRIBUTION_2X2X2_BASE_200 := [5.0, 3.0, 3.0, 5.0, 3.0, 7.0, 5.0, 1.0]
const DISTRIBUTION_2X2X2_BASE_240 := [5.0, 5.0, 4.0, 6.0, 5.0, 7.0, 6.0, 2.0]
const DISTRIBUTION_2X2X2_BASE_340 := [6.0, 5.0, 4.0, 6.0, 5.0, 7.0, 6.0, 2.0]
const DISTRIBUTION_2X2X2_BASE_440 := [6.5, 5.0, 4.0, 6.0, 5.0, 7.0, 6.0, 2.0]
const DISTRIBUTION_2X2X2_BASE_740 := [7.5, 5.0, 4.0, 6.0, 5.0, 7.0, 6.0, 2.0]
const DISTRIBUTION_2X2X2_BASE_888 := [8.0, 8.0, 8.0, 8.0, 8.0, 8.0, 8.0, 8.0]

const DISTRIBUTION_2X2_BASE_000 := [0.0, 0.0, 0.0, 0.0]
const DISTRIBUTION_2X2_BASE_700 := [7.0, 5.0, 3.0, 1.0]
const DISTRIBUTION_2X2_BASE_888 := [8.0, 8.0, 8.0, 8.0]

const DISTRIBUTION_2_BASE_000 := [0.0, 0.0]
const DISTRIBUTION_2_BASE_500 := [5.0, 2.0]
const DISTRIBUTION_2_BASE_888 := [8.0, 8.0]

const PRESETS := {
	"Ilands": 11,
	"Maze": 20,
	"Discrete": 24,
}


static func distribution3(distribution_id: int) -> Array:
	match distribution_id:
		0:
			return DISTRIBUTION_2X2X2_BASE_000
		11:
			return DISTRIBUTION_2X2X2_BASE_113
		20:
			return DISTRIBUTION_2X2X2_BASE_200
		24:
			return DISTRIBUTION_2X2X2_BASE_240
		34:
			return DISTRIBUTION_2X2X2_BASE_340
		44:
			return DISTRIBUTION_2X2X2_BASE_440
		74:
			return DISTRIBUTION_2X2X2_BASE_740
		88:
			return DISTRIBUTION_2X2X2_BASE_888
		_:
			return DISTRIBUTION_2X2X2_BASE_200


static func distribution2(distribution_id: int) -> Array:
	match distribution_id:
		0:
			return DISTRIBUTION_2X2_BASE_000
		70:
			return DISTRIBUTION_2X2_BASE_700
		88:
			return DISTRIBUTION_2X2_BASE_888
		_:
			return DISTRIBUTION_2X2_BASE_700


static func distribution1(distribution_id: int) -> Array:
	match distribution_id:
		0:
			return DISTRIBUTION_2_BASE_000
		50:
			return DISTRIBUTION_2_BASE_500
		88:
			return DISTRIBUTION_2_BASE_888
		_:
			return DISTRIBUTION_2_BASE_500


static func prob_from_distribution(ref_conditions: Array, distribution_id: int) -> float:
	var state := 0
	for index in range(ref_conditions.size()):
		if ref_conditions[index]:
			state += 1 << index

	match ref_conditions.size():
		3:
			return distribution3(distribution_id)[state] / 8.0
		2:
			return distribution2(distribution_id)[state] / 8.0
		1:
			return distribution1(distribution_id)[state] / 8.0
		_:
			return -1.0


static func prob_from_arrays(ref_conditions: Array, d3: Array, d2: Array, d1: Array) -> float:
	var state := 0
	for index in range(ref_conditions.size()):
		if ref_conditions[index]:
			state += 1 << index

	match ref_conditions.size():
		3:
			return d3[state] / 8.0
		2:
			return d2[state] / 8.0
		1:
			return d1[state] / 8.0
		_:
			return -1.0


static func get_preset_names() -> Array:
	return PRESETS.keys()


static func get_preset_id(name: String) -> int:
	return PRESETS.get(name, 20)


static func one_of(rng: RandomNumberGenerator, count: int) -> int:
	assert(count > 0)
	return rng.randi_range(0, count - 1)


static func pattern3(rng: RandomNumberGenerator) -> Array:
	match one_of(rng, 6):
		0:
			return [1, 2, 0]
		1:
			return [2, 0, 1]
		2:
			return [0, 1, 2]
		3:
			return [2, 1, 0]
		4:
			return [0, 2, 1]
		_:
			return [1, 0, 2]


static func pattern2(rng: RandomNumberGenerator, start: int) -> Array:
	if one_of(rng, 2) == 0:
		return [start, start + 1]
	return [start + 1, start]
