class_name HexAdjacencyRuleSet
extends Resource

@export_multiline var rules_text := "default=0.0"


static func parse_rules_text(text: String, fallback_probability: float = 0.0) -> Dictionary:
	return parse_rules_text_report(text, fallback_probability)["rules"]


static func parse_rules_text_report(text: String, fallback_probability: float = 0.0) -> Dictionary:
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
	var used_fallback := false
	if rules.is_empty():
		rules["default"] = clampf(fallback_probability, 0.0, 1.0)
		used_fallback = true
	return {
		"rules": rules,
		"invalid_entries": invalid_entries,
		"used_fallback": used_fallback,
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


func to_probability_rules(fallback_probability: float = 0.0) -> Dictionary:
	return parse_rules_text(rules_text, fallback_probability)
