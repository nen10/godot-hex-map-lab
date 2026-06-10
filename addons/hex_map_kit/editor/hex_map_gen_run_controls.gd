@tool
class_name HexMapGenRunControls
extends RefCounted

const SCREEN_SCRIPT := "hex_map_gen_run_controls.gd"
const SCREEN_ROLE_SOURCE := "HexMapGenRunControls"


static func component_owner_rows() -> Array[Dictionary]:
	return [
		_component_owner("generate_run_controls", "HBoxContainer", "GenerateRunControls", "build_run_controls"),
		_component_owner("generate_progress_controls", "HBoxContainer", "GenerateProgressControls", "build_progress_controls"),
	]


static func build_run_controls() -> Dictionary:
	var row := _component_root("generate_run_controls", "Generate Run Controls", "build_run_controls")

	var generate_button := Button.new()
	generate_button.text = "Primary Generation"
	row.add_child(generate_button)

	var label := Label.new()
	label.text = "Seed"
	row.add_child(label)

	var seed_spin := SpinBox.new()
	seed_spin.min_value = 0
	seed_spin.max_value = 999999
	seed_spin.value = 1201
	seed_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(seed_spin)

	var seed_random_button := Button.new()
	seed_random_button.text = "Rand"
	row.add_child(seed_random_button)

	var history_check := CheckButton.new()
	history_check.text = "History"
	row.add_child(history_check)

	var history_dir_button := Button.new()
	history_dir_button.text = "History Dir"
	row.add_child(history_dir_button)

	return {
		"root": row,
		"generate_button": generate_button,
		"seed_spin": seed_spin,
		"seed_random_button": seed_random_button,
		"history_check": history_check,
		"history_dir_button": history_dir_button,
	}


static func build_progress_controls() -> Dictionary:
	var row := _component_root("generate_progress_controls", "Generate Progress Controls", "build_progress_controls")
	row.visible = false

	var status_label := Label.new()
	status_label.text = "Ready"
	row.add_child(status_label)

	var progress_bar := ProgressBar.new()
	progress_bar.min_value = 0.0
	progress_bar.max_value = 1.0
	progress_bar.step = 0.01
	progress_bar.value = 0.0
	progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_child(progress_bar)

	var cancel_row := HBoxContainer.new()
	var cancel_button := Button.new()
	cancel_button.text = "Cancel"
	cancel_button.disabled = true
	cancel_row.add_child(cancel_button)
	row.add_child(cancel_row)

	return {
		"root": row,
		"status_label": status_label,
		"progress_bar": progress_bar,
		"cancel_button": cancel_button,
	}


static func _component_root(component_id: String, node_name: String, builder_id: String) -> HBoxContainer:
	var root := HBoxContainer.new()
	root.name = node_name
	root.set_meta("hex_generate_component_id", component_id)
	root.set_meta("hex_generate_component_script", SCREEN_SCRIPT)
	root.set_meta("hex_generate_component_role_source", SCREEN_ROLE_SOURCE)
	root.set_meta("hex_generate_component_builder", builder_id)
	return root


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
