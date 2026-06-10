@tool
class_name HexMapGenSourceControls
extends RefCounted

const SCREEN_SCRIPT := "hex_map_gen_source_controls.gd"
const SCREEN_ROLE_SOURCE := "HexMapGenSourceControls"
const LAYOUT_SECTION_PROFILE_SOURCE := "profile_source"


static func component_owner_rows() -> Array[Dictionary]:
	return [
		_component_owner("generate_source_registry", "VBoxContainer", "GenerateSourceRegistry", "build_source_registry_controls", LAYOUT_SECTION_PROFILE_SOURCE),
	]


static func build_source_registry_controls() -> Dictionary:
	var root := _component_root("generate_source_registry", "Generate Source Registry", "build_source_registry_controls")
	root.add_child(_section_label("Source Registry"))

	var row := HBoxContainer.new()
	var source_load_button := Button.new()
	source_load_button.text = "Browse .tres"
	source_load_button.set_meta("hex_generate_action_purpose", "browse_mapdata_source")
	row.add_child(source_load_button)

	var history_dir_label := Label.new()
	history_dir_label.text = "History: off"
	history_dir_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(history_dir_label)
	root.add_child(row)

	var source_list := VBoxContainer.new()
	root.add_child(source_list)

	var status_label := Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	root.add_child(status_label)

	return {
		"root": root,
		"source_load_button": source_load_button,
		"history_dir_label": history_dir_label,
		"source_list": source_list,
		"status_label": status_label,
	}


static func _component_root(component_id: String, node_name: String, builder_id: String) -> VBoxContainer:
	var root := VBoxContainer.new()
	root.name = node_name
	root.set_meta("hex_generate_component_id", component_id)
	root.set_meta("hex_generate_component_script", SCREEN_SCRIPT)
	root.set_meta("hex_generate_component_role_source", SCREEN_ROLE_SOURCE)
	root.set_meta("hex_generate_component_builder", builder_id)
	root.set_meta("hex_generate_layout_section_id", LAYOUT_SECTION_PROFILE_SOURCE)
	return root


static func _section_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
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
