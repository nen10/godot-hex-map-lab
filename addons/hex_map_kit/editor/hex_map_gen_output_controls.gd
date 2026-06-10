@tool
class_name HexMapGenOutputControls
extends RefCounted

const SCREEN_SCRIPT := "hex_map_gen_output_controls.gd"
const SCREEN_ROLE_SOURCE := "HexMapGenOutputControls"
const LAYOUT_SECTION_APPLY_SAVE := "apply_save"


static func component_owner_rows() -> Array[Dictionary]:
	return [
		_component_owner("generate_output_target", "VBoxContainer", "GenerateOutputTarget", "build_output_target_controls", LAYOUT_SECTION_APPLY_SAVE),
		_component_owner("generate_save_apply_controls", "HBoxContainer", "GenerateSaveApplyControls", "build_save_apply_controls", LAYOUT_SECTION_APPLY_SAVE),
	]


static func build_output_target_controls(modes: Array, labels: Array) -> Dictionary:
	var root := _component_root_vbox("generate_output_target", "Generate Output Target", "build_output_target_controls")

	var row := HBoxContainer.new()
	row.add_child(_small_label("Output target"))
	var output_target_option := OptionButton.new()
	output_target_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for index in range(modes.size()):
		output_target_option.add_item(String(labels[index]))
		output_target_option.set_item_metadata(index, String(modes[index]))
	output_target_option.select(0)
	row.add_child(output_target_option)

	var apply_button := Button.new()
	apply_button.text = "Apply to Document"
	apply_button.set_meta("hex_generate_action_purpose", "apply_to_selected_document")
	row.add_child(apply_button)
	root.add_child(row)

	var status_label := Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	root.add_child(status_label)

	return {
		"root": root,
		"output_target_option": output_target_option,
		"apply_button": apply_button,
		"status_label": status_label,
	}


static func build_save_apply_controls() -> Dictionary:
	var row := _component_root_hbox(
		"generate_save_apply_controls",
		"Generate Save Apply Controls",
		"build_save_apply_controls"
	)

	var apply_layer_button := Button.new()
	apply_layer_button.text = "Advanced Apply"
	apply_layer_button.visible = false
	apply_layer_button.set_meta("hex_generate_action_purpose", "advanced_apply_to_tile_map")
	row.add_child(apply_layer_button)

	var save_button := Button.new()
	save_button.text = "Save As .tres"
	save_button.set_meta("hex_generate_action_purpose", "save_generated_resource_as_tres")
	row.add_child(save_button)

	return {
		"root": row,
		"apply_layer_button": apply_layer_button,
		"save_button": save_button,
	}


static func _component_root_vbox(component_id: String, node_name: String, builder_id: String) -> VBoxContainer:
	var root := VBoxContainer.new()
	_apply_meta(root, component_id, builder_id)
	root.name = node_name
	return root


static func _component_root_hbox(component_id: String, node_name: String, builder_id: String) -> HBoxContainer:
	var root := HBoxContainer.new()
	_apply_meta(root, component_id, builder_id)
	root.name = node_name
	return root


static func _apply_meta(root: Control, component_id: String, builder_id: String) -> void:
	root.set_meta("hex_generate_component_id", component_id)
	root.set_meta("hex_generate_component_script", SCREEN_SCRIPT)
	root.set_meta("hex_generate_component_role_source", SCREEN_ROLE_SOURCE)
	root.set_meta("hex_generate_component_builder", builder_id)
	root.set_meta("hex_generate_layout_section_id", LAYOUT_SECTION_APPLY_SAVE)


static func _small_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	return label


static func _component_owner(
	component_id: String,
	component_class: String,
	responsibility: String,
	builder_id: String,
	layout_section: String
) -> Dictionary:
	return {
		"component_id": component_id,
		"component_class": component_class,
		"responsibility": responsibility,
		"screen_script": SCREEN_SCRIPT,
		"screen_role_source": SCREEN_ROLE_SOURCE,
		"builder": builder_id,
		"layout_section": layout_section,
	}
