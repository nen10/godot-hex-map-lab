class_name HexMapGenStateEvaluator
extends RefCounted

const DEFAULT_EMPTY_MASK_REASON := "Placement Mask query result is empty."
const DEFAULT_EMPTY_ADJACENCY_RULES_REASON := "Adjacency Rules has no valid rules."


static func evaluate_control_state(state: Dictionary) -> Dictionary:
	var symmetric := bool(state.get("symmetric", false))
	var overlay := bool(state.get("overlay", false))
	var generation_running := bool(state.get("generation_running", false))
	var overlay_adjacency := bool(state.get("overlay_adjacency_enabled", false))
	var overlay_item_limit := bool(state.get("overlay_item_limit_enabled", false))
	var simple_shape := int(state.get("simple_shape", -1))
	var shape_rectangle := int(state.get("shape_rectangle", 1))
	var shape_hexagon := int(state.get("shape_hexagon", 0))

	return {
		"symmetric": symmetric,
		"overlay": overlay,
		"shape_symmetric_row_visible": symmetric,
		"shape_simple_row_visible": not symmetric,
		"rect_row_visible": not symmetric and simple_shape == shape_rectangle,
		"hex_row_visible": not symmetric and simple_shape == shape_hexagon,
		"radius_row_visible": symmetric,
		"sym_options_visible": symmetric and not overlay_adjacency,
		"probability_label": "  Initial Probability" if symmetric else "  Probability / Cell",
		"torus_connectivity_visible": symmetric,
		"torus_connectivity_disabled": not symmetric or generation_running,
		"overlay_controls_visible": overlay,
		"generate_button_text": "Overlay Generation" if overlay else "Primary Generation",
		"deductor_label_text": "Overlay Deductor" if overlay else "Passage Generator",
		"generator_label_text": "Overlay Generator" if overlay else "Wall Generator",
		"overlay_adjacency_visible": overlay,
		"overlay_adjacency_disabled": (not overlay or overlay_item_limit) or generation_running,
		"overlay_item_limit_visible": overlay,
		"overlay_item_limit_disabled": (not overlay or overlay_adjacency) or generation_running,
		"overlay_item_limit_spin_visible": false,
		"overlay_item_name_row_visible": overlay and symmetric,
		"overlay_item_pool_visible": overlay and not symmetric,
		"overlay_add_item_visible": overlay and not symmetric,
		"overlay_mask_visible": overlay,
		"overlay_deductor_floor_visible": overlay and symmetric and not overlay_adjacency,
		"overlay_reference_visible": overlay_adjacency,
		"wall_probability_row_visible": not overlay or not (overlay_item_limit or overlay_adjacency),
	}


static func generation_block_reason(
	state: Dictionary,
	empty_mask_reason: String = DEFAULT_EMPTY_MASK_REASON,
	empty_adjacency_rules_reason: String = DEFAULT_EMPTY_ADJACENCY_RULES_REASON
) -> String:
	if bool(state.get("generation_running", false)) or not bool(state.get("overlay_mode", false)):
		return ""
	if bool(state.get("mask_query_enabled", false)) and int(state.get("mask_candidate_count", 0)) <= 0:
		return empty_mask_reason
	if bool(state.get("overlay_adjacency_enabled", false)) and int(state.get("adjacency_rule_count", 0)) <= 0:
		return empty_adjacency_rules_reason
	return ""

