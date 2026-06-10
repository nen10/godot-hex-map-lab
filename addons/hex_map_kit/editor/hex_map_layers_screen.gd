@tool
class_name HexMapLayersScreen
extends RefCounted

const TAB_NAME := "Layers"
const WORKFLOW_OWNER := "Layers"
const USER_TASK := "Manage Layer Stack roles, templates, visibility, and layer application."
const SCREEN_SCRIPT := "hex_map_layers_screen.gd"


static func screen_contract() -> Dictionary:
	return {
		"screen_role_source": "HexMapLayersScreen",
		"screen_script": SCREEN_SCRIPT,
		"tab": TAB_NAME,
		"workflow_owner": WORKFLOW_OWNER,
		"user_task": USER_TASK,
		"owns": PackedStringArray([
			"layer_stack",
			"layer_roles",
			"layer_templates",
			"layer_apply",
		]),
		"delegates": {},
	}


static func ownership_fields() -> Dictionary:
	return {
		"layer_workflow_owner": WORKFLOW_OWNER,
		"layer_management_visible": true,
		"paint_layer_management_visible": false,
	}


static func component_owner_rows() -> Array[Dictionary]:
	return [
		_component_owner("layer_stack_role_panel", "VBoxContainer", "LayerStackRolePanel"),
		_component_owner("layer_stack_asset_panel", "HexMapWorkspaceAssetPanel", "LayerStackPanel"),
	]


static func build_layer_stack_role_panel() -> Dictionary:
	var panel := _panel("Layer Stack Role Panel", "layer_stack_role_panel", "build_layer_stack_role_panel")
	var title := Label.new()
	title.text = "Layer Stack Roles"
	panel.add_child(title)

	var status_label := _wrapped_label()
	panel.add_child(status_label)

	var relationship_label := _wrapped_label()
	panel.add_child(relationship_label)

	var role_tree_summary_label := _wrapped_label()
	role_tree_summary_label.name = "Layer Role Tree Summary"
	panel.add_child(role_tree_summary_label)

	var rows_label := _wrapped_label()
	panel.add_child(rows_label)

	var editor_title := Label.new()
	editor_title.text = "Role Editor"
	panel.add_child(editor_title)

	var editor_summary_label := _wrapped_label()
	editor_summary_label.name = "Layer Role Editor Summary"
	panel.add_child(editor_summary_label)

	var role_option := OptionButton.new()
	role_option.name = "Layer Role Selector"
	panel.add_child(_labeled_row("Role", role_option))

	var toggle_row := HBoxContainer.new()
	var visible_check := CheckBox.new()
	visible_check.text = "Visible"
	visible_check.name = "Layer Role Visible"
	toggle_row.add_child(visible_check)
	var locked_check := CheckBox.new()
	locked_check.text = "Locked"
	locked_check.name = "Layer Role Locked"
	toggle_row.add_child(locked_check)
	panel.add_child(toggle_row)

	var z_index_spin := SpinBox.new()
	z_index_spin.name = "Layer Role Z Index"
	z_index_spin.min_value = -4096
	z_index_spin.max_value = 4096
	z_index_spin.step = 1
	z_index_spin.allow_lesser = true
	z_index_spin.allow_greater = true
	panel.add_child(_labeled_row("Z Index", z_index_spin))

	var writable_option := OptionButton.new()
	writable_option.name = "Layer Role Writable Source"
	panel.add_child(_labeled_row("Writable", writable_option))

	return {
		"root": panel,
		"status_label": status_label,
		"relationship_label": relationship_label,
		"role_tree_summary_label": role_tree_summary_label,
		"rows_label": rows_label,
		"editor_summary_label": editor_summary_label,
		"role_option": role_option,
		"visible_check": visible_check,
		"locked_check": locked_check,
		"z_index_spin": z_index_spin,
		"writable_option": writable_option,
	}


static func _component_owner(component_id: String, component_class: String, responsibility: String) -> Dictionary:
	return {
		"tab": TAB_NAME,
		"component_id": component_id,
		"component_class": component_class,
		"responsibility": responsibility,
		"screen_script": SCREEN_SCRIPT,
		"screen_role_source": "HexMapLayersScreen",
	}


static func _panel(node_name: String, component_id: String, builder_id: String) -> VBoxContainer:
	var panel := VBoxContainer.new()
	panel.name = node_name
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.set_meta("hex_workspace_component_id", component_id)
	panel.set_meta("hex_workspace_screen_script", SCREEN_SCRIPT)
	panel.set_meta("hex_workspace_screen_role_source", "HexMapLayersScreen")
	panel.set_meta("hex_workspace_builder", builder_id)
	return panel


static func _wrapped_label() -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


static func _labeled_row(label_text: String, control: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(96, 0)
	row.add_child(label)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	return row
