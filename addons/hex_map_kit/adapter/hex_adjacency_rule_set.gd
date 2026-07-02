@tool
class_name HexAdjacencyRuleSet
extends Resource

@export_multiline var rules_text := "default=0.0"
# Human-facing name shown in the Adjacency Rules window preset list.
@export var display_name := ""
# Visual-pattern representation used by the Adjacency Rules window. Each entry is
# { "directions": Array[String], "probability": float }. `directions` holds the
# hex direction keys that are "reference present" in the pattern.
@export var default_probability := 0.0
@export var patterns: Array = []


static func parse_rules_text(text: String) -> Dictionary:
	return parse_rules_text_report(text)["rules"]


static func parse_rules_text_report(text: String) -> Dictionary:
	var rules := {}
	var invalid_entries: Array[String] = []
	for raw_entry in text.split(";", false):
		var entry = String(raw_entry).strip_edges()
		if entry == "":
			continue
		var pair = entry.split("=", false, 1)
		if pair.size() != 2:
			invalid_entries.append(entry)
			continue
		var key_text = String(pair[0]).strip_edges()
		var value_text = String(pair[1]).strip_edges()
		if key_text == "" or not value_text.is_valid_float():
			invalid_entries.append(entry)
			continue
		var key = _normalized_rule_key(key_text)
		if key == null:
			invalid_entries.append(entry)
			continue
		rules[key] = clampf(float(value_text), 0.0, 1.0)
	return {
		"rules": rules,
		"invalid_entries": invalid_entries,
	}


static func _normalized_rule_key(key_text: String) -> Variant:
	if key_text == "default":
		return "default"
	if key_text.is_valid_int():
		return int(key_text)
	if key_text.count(",") == 1:
		var parts = key_text.split(",", false, 1)
		if parts.size() == 2 \
			and String(parts[0]).strip_edges().is_valid_int() \
			and String(parts[1]).strip_edges().is_valid_int():
			return Vector2i(
				int(String(parts[0]).strip_edges()),
				int(String(parts[1]).strip_edges())
			)
	return null


func to_probability_rules() -> Dictionary:
	return parse_rules_text(rules_text)


# --- Visual pattern (Adjacency Rules window) representation -------------------

# Build a rule set resource from the Adjacency Rules window dictionary, which has
# the shape { "default": float, "rules": [ { "directions": Array, "probability": float } ] }.
static func from_dialog_dict(value: Dictionary, name: String = "") -> HexAdjacencyRuleSet:
	var resource = load("res://addons/hex_map_kit/adapter/hex_adjacency_rule_set.gd").new()
	resource.display_name = name
	resource.default_probability = clampf(float(value.get("default", 0.0)), 0.0, 1.0)
	resource.patterns = _normalize_patterns(value.get("rules", []))
	return resource


# Convert back into the Adjacency Rules window dictionary shape.
func to_dialog_dict() -> Dictionary:
	return {
		"default": clampf(default_probability, 0.0, 1.0),
		"rules": _normalize_patterns(patterns),
	}


func has_pattern_data() -> bool:
	return not patterns.is_empty()


static func _normalize_patterns(raw_patterns) -> Array:
	var result: Array = []
	if not raw_patterns is Array:
		return result
	for raw_rule in raw_patterns as Array:
		if not raw_rule is Dictionary:
			continue
		var rule := raw_rule as Dictionary
		var directions: Array = []
		var raw_directions = rule.get("directions", [])
		if raw_directions is Array:
			for direction in raw_directions as Array:
				directions.append(String(direction))
		result.append({
			"directions": directions,
			"probability": clampf(float(rule.get("probability", 0.5)), 0.0, 1.0),
		})
	return result
