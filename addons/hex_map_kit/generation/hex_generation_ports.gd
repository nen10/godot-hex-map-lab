@tool
class_name HexGenerationPorts
extends RefCounted

const TERRAIN := "terrain"
const SELECTION := "selection"
const OVERLAY := "overlay"
const RESULT := "result"

const ALL := [TERRAIN, SELECTION, OVERLAY, RESULT]


static func is_valid(port_type: String) -> bool:
	return ALL.has(port_type)


static func normalize_accepts(accepts) -> Array:
	var result: Array = []
	if accepts is String:
		result.append(String(accepts))
	elif accepts is PackedStringArray:
		for item in accepts:
			result.append(String(item))
	elif accepts is Array:
		for item in accepts:
			result.append(String(item))
	return result


static func compatible(output_type: String, accepts) -> bool:
	if not is_valid(output_type):
		return false
	return normalize_accepts(accepts).has(output_type)

