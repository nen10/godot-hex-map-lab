class_name HexAdjacencyRuleSet
extends Resource

@export_multiline var rules_text := "default=0.0"


static func parse_rules_text(text: String, fallback_probability: float = 0.0) -> Dictionary:
	var rules := {}
	for raw_entry in text.split(";", false):
		var entry = String(raw_entry).strip_edges()
		if entry == "":
			continue
		var pair = entry.split("=", false, 1)
		if pair.size() != 2:
			continue
		var key_text = String(pair[0]).strip_edges()
		var value_text = String(pair[1]).strip_edges()
		if key_text == "" or not value_text.is_valid_float():
			continue
		var key: Variant = key_text
		if key_text.is_valid_int():
			key = int(key_text)
		rules[key] = clampf(float(value_text), 0.0, 1.0)
	if rules.is_empty():
		rules["default"] = clampf(fallback_probability, 0.0, 1.0)
	return rules


func to_probability_rules(fallback_probability: float = 0.0) -> Dictionary:
	return parse_rules_text(rules_text, fallback_probability)
