@tool
class_name HexItemPoolResource
extends Resource

@export var display_name := ""
@export var entries: Array = []:
	set(value):
		entries = normalize_entries(value)


static func normalize_entries(value) -> Array:
	var result: Array = []
	if not value is Array:
		return result
	for raw_entry in value as Array:
		if not raw_entry is Dictionary:
			continue
		result.append(normalize_entry(raw_entry as Dictionary))
	return result


static func normalize_entry(entry: Dictionary) -> Dictionary:
	return {
		"name": String(entry.get("name", "")),
		"weight": float(entry.get("weight", 1.0)),
		"limit": int(entry.get("limit", 0)),
	}


func is_configured() -> bool:
	return not entries.is_empty()
