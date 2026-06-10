@tool
class_name HexMapGenResultControls
extends RefCounted

const SCREEN_SCRIPT := "hex_map_gen_result_controls.gd"
const SCREEN_ROLE_SOURCE := "HexMapGenResultControls"


static func component_owner_rows() -> Array[Dictionary]:
	return [
		_component_owner("generate_seed_lab", "VBoxContainer", "GenerateSeedLab", "build_seed_lab_controls"),
		_component_owner("generate_result_summary", "Label", "GenerateResultSummary", "build_result_summary_label"),
	]


static func build_seed_lab_controls() -> Dictionary:
	var root := _component_root("generate_seed_lab", "Generate Seed Lab", "build_seed_lab_controls")
	root.add_child(_section_label("Seed Lab"))

	var action_row := HBoxContainer.new()
	var count_label := Label.new()
	count_label.text = "Seeds"
	action_row.add_child(count_label)

	var count_spin := SpinBox.new()
	count_spin.min_value = 1
	count_spin.max_value = 100
	count_spin.value = 3
	count_spin.step = 1
	action_row.add_child(count_spin)

	var run_button := Button.new()
	run_button.text = "Run Batch"
	action_row.add_child(run_button)

	var promote_button := Button.new()
	promote_button.text = "Promote to Document"
	action_row.add_child(promote_button)
	root.add_child(action_row)

	var score_tree := Tree.new()
	score_tree.hide_root = true
	score_tree.columns = 6
	score_tree.set_column_titles_visible(true)
	score_tree.set_column_title(0, "rank")
	score_tree.set_column_title(1, "seed")
	score_tree.set_column_title(2, "score")
	score_tree.set_column_title(3, "status")
	score_tree.set_column_title(4, "cells")
	score_tree.set_column_title(5, "validation")
	score_tree.custom_minimum_size = Vector2(0, 120)
	score_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(score_tree)

	var preview_label := _wrapped_label()
	root.add_child(preview_label)

	var status_label := _wrapped_label()
	root.add_child(status_label)

	return {
		"root": root,
		"count_spin": count_spin,
		"run_button": run_button,
		"promote_button": promote_button,
		"score_tree": score_tree,
		"preview_label": preview_label,
		"status_label": status_label,
	}


static func build_result_summary_label() -> Dictionary:
	var label := Label.new()
	label.name = "Generate Result Summary"
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	label.set_meta("hex_generate_component_id", "generate_result_summary")
	label.set_meta("hex_generate_component_script", SCREEN_SCRIPT)
	label.set_meta("hex_generate_component_role_source", SCREEN_ROLE_SOURCE)
	label.set_meta("hex_generate_component_builder", "build_result_summary_label")
	return {
		"root": label,
		"stats_label": label,
	}


static func _component_root(component_id: String, node_name: String, builder_id: String) -> VBoxContainer:
	var root := VBoxContainer.new()
	root.name = node_name
	root.set_meta("hex_generate_component_id", component_id)
	root.set_meta("hex_generate_component_script", SCREEN_SCRIPT)
	root.set_meta("hex_generate_component_role_source", SCREEN_ROLE_SOURCE)
	root.set_meta("hex_generate_component_builder", builder_id)
	return root


static func _section_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	return label


static func _wrapped_label() -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


static func _component_owner(
	component_id: String,
	component_class: String,
	responsibility: String,
	builder_id: String
) -> Dictionary:
	return {
		"component_id": component_id,
		"component_class": component_class,
		"responsibility": responsibility,
		"screen_script": SCREEN_SCRIPT,
		"screen_role_source": SCREEN_ROLE_SOURCE,
		"builder": builder_id,
	}
