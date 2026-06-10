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

	return {
		"root": panel,
		"status_label": status_label,
		"relationship_label": relationship_label,
		"role_tree_summary_label": role_tree_summary_label,
		"rows_label": rows_label,
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
