@tool
class_name HexMapResourcesScreen
extends RefCounted

const TAB_NAME := "Resources"
const WORKFLOW_OWNER := "Resources"
const USER_TASK := "Manage selected HexTileMap context, Level Document, and shared project resources."
const SCREEN_SCRIPT := "hex_map_resources_screen.gd"


static func screen_contract() -> Dictionary:
	return {
		"screen_role_source": "HexMapResourcesScreen",
		"screen_script": SCREEN_SCRIPT,
		"tab": TAB_NAME,
		"workflow_owner": WORKFLOW_OWNER,
		"user_task": USER_TASK,
		"owns": PackedStringArray([
			"selected_hex_tile_map_context",
			"resource_shelf",
			"level_document",
			"document_dependencies",
			"missing_unique_resources",
		]),
		"delegates": {},
	}


static func ownership_fields() -> Dictionary:
	return {
		"document_workflow_owner": WORKFLOW_OWNER,
		"document_management_visible": true,
		"paint_document_management_visible": false,
	}


static func component_owner_rows() -> Array[Dictionary]:
	return [
		_component_owner("resources_context_panel", "VBoxContainer", "ResourcesContextPanel"),
		_component_owner("document_asset_panel", "HexMapWorkspaceAssetPanel", "ResourcesAssetPanel"),
		_component_owner("missing_unique_resources_panel", "VBoxContainer", "SelectedHexTileMapMissingResources"),
	]


static func build_resources_context_panel(resource_groups: Array) -> Dictionary:
	var panel := _panel("Resources Context Panel", "resources_context_panel", "build_resources_context_panel")
	var title := Label.new()
	title.text = "Resource Shelf"
	panel.add_child(title)

	var status_label := _wrapped_label()
	status_label.name = "Selected HexTileMap Chip"
	panel.add_child(status_label)

	var shelf_status_label := _wrapped_label()
	shelf_status_label.name = "Resource Shelf Status"
	panel.add_child(shelf_status_label)

	var group_labels := {}
	for group in resource_groups:
		var group_data := group as Dictionary
		var group_id := String(group_data.get("group_id", ""))
		var label := _wrapped_label()
		label.name = "Resource Shelf Card %s" % group_id
		var slot_labels = group_data.get("slot_labels", PackedStringArray()) as PackedStringArray
		label.text = "%s\n%s" % [
			String(group_data.get("label", "")),
			_join_text(slot_labels, ", "),
		]
		label.tooltip_text = String(group_data.get("tooltip", ""))
		panel.add_child(label)
		group_labels[group_id] = label

	return {
		"root": panel,
		"status_label": status_label,
		"shelf_status_label": shelf_status_label,
		"group_labels": group_labels,
	}


static func build_missing_unique_resources_panel() -> Dictionary:
	var panel := _panel(
		"Missing Unique Resources Panel",
		"missing_unique_resources_panel",
		"build_missing_unique_resources_panel"
	)
	var title := Label.new()
	title.text = "Missing resources for Selected HexTileMap"
	panel.add_child(title)

	var status_label := _wrapped_label()
	panel.add_child(status_label)

	var directory_row := HBoxContainer.new()
	var save_directory_label := Label.new()
	save_directory_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	directory_row.add_child(save_directory_label)
	var choose_directory_button := Button.new()
	choose_directory_button.text = "Choose Folder..."
	directory_row.add_child(choose_directory_button)
	panel.add_child(directory_row)

	var prefix_row := HBoxContainer.new()
	var prefix_label := Label.new()
	prefix_label.text = "Resource prefix"
	prefix_row.add_child(prefix_label)
	var prefix_edit := LineEdit.new()
	prefix_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prefix_row.add_child(prefix_edit)
	panel.add_child(prefix_row)

	var primary_row := HBoxContainer.new()
	primary_row.name = "Resources Primary Actions"
	primary_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(primary_row)

	var create_button := Button.new()
	create_button.text = "Create Missing Resources"
	create_button.custom_minimum_size = Vector2(0, 44)
	create_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	primary_row.add_child(create_button)

	var save_all_button := Button.new()
	save_all_button.text = "Save All"
	save_all_button.custom_minimum_size = Vector2(0, 44)
	save_all_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	primary_row.add_child(save_all_button)

	return {
		"root": panel,
		"status_label": status_label,
		"save_directory_label": save_directory_label,
		"choose_directory_button": choose_directory_button,
		"prefix_edit": prefix_edit,
		"create_button": create_button,
		"save_all_button": save_all_button,
	}


static func _component_owner(component_id: String, component_class: String, responsibility: String) -> Dictionary:
	return {
		"tab": TAB_NAME,
		"component_id": component_id,
		"component_class": component_class,
		"responsibility": responsibility,
		"screen_script": SCREEN_SCRIPT,
		"screen_role_source": "HexMapResourcesScreen",
	}


static func _panel(node_name: String, component_id: String, builder_id: String) -> VBoxContainer:
	var panel := VBoxContainer.new()
	panel.name = node_name
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.set_meta("hex_workspace_component_id", component_id)
	panel.set_meta("hex_workspace_screen_script", SCREEN_SCRIPT)
	panel.set_meta("hex_workspace_screen_role_source", "HexMapResourcesScreen")
	panel.set_meta("hex_workspace_builder", builder_id)
	return panel


static func _wrapped_label() -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


static func _join_text(values: PackedStringArray, separator: String) -> String:
	var parts: Array[String] = []
	for value in values:
		parts.append(String(value))
	return separator.join(parts)
