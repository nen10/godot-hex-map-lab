@tool
class_name HexMapExportScreen
extends RefCounted

const TAB_NAME := "Export"
const WORKFLOW_OWNER := "Export"
const USER_TASK := "Choose a runtime handoff destination and export the Level Document."
const SCREEN_SCRIPT := "hex_map_export_screen.gd"


static func screen_contract() -> Dictionary:
	return {
		"screen_role_source": "HexMapExportScreen",
		"screen_script": SCREEN_SCRIPT,
		"tab": TAB_NAME,
		"workflow_owner": WORKFLOW_OWNER,
		"user_task": USER_TASK,
		"owns": PackedStringArray([
			"export_profile",
			"runtime_handoff_type",
			"output_destination",
			"export_result_state",
		]),
		"delegates": {
			"source_document": "Resources",
			"package_build": "Release Process",
			"debug_report": "Diagnostics",
		},
	}


static func ownership_fields() -> Dictionary:
	return {
		"export_workflow_owner": WORKFLOW_OWNER,
		"export_management_visible": true,
		"destination_output_type_owner": WORKFLOW_OWNER,
		"destination_controls_visible": true,
		"output_type_controls_visible": true,
		"paint_export_management_visible": false,
	}


static func component_owner_rows() -> Array[Dictionary]:
	return [
		_component_owner("export_purpose_panel", "VBoxContainer", "ExportPurposePanel"),
		_component_owner("export_asset_panel", "HexMapWorkspaceAssetPanel", "ExportPanel"),
		_component_owner("export_destination_panel", "VBoxContainer", "ExportDestinationPanel"),
	]


static func build_export_purpose_panel() -> Dictionary:
	var panel := _panel("Export Purpose Panel", "export_purpose_panel", "build_export_purpose_panel")
	var title := Label.new()
	title.text = "Runtime Handoff"
	panel.add_child(title)

	var status_label := _wrapped_label()
	panel.add_child(status_label)

	var mode_label := _wrapped_label()
	panel.add_child(mode_label)

	var backlog_label := _wrapped_label()
	panel.add_child(backlog_label)

	return {
		"root": panel,
		"status_label": status_label,
		"mode_label": mode_label,
		"backlog_label": backlog_label,
	}


static func build_export_destination_panel() -> Dictionary:
	var panel := _panel(
		"Export Destination Panel",
		"export_destination_panel",
		"build_export_destination_panel"
	)
	var title := Label.new()
	title.text = "Runtime Handoff Destination"
	panel.add_child(title)

	var destination_label := _wrapped_label()
	panel.add_child(destination_label)

	var recent_destinations_label := _wrapped_label()
	panel.add_child(recent_destinations_label)

	var actions := HBoxContainer.new()
	var choose_destination_button := Button.new()
	choose_destination_button.text = "Choose Destination..."
	actions.add_child(choose_destination_button)

	var use_recent_button := Button.new()
	use_recent_button.text = "Use Recent"
	actions.add_child(use_recent_button)

	var run_button := Button.new()
	run_button.text = "Create Runtime Handoff"
	actions.add_child(run_button)
	panel.add_child(actions)

	return {
		"root": panel,
		"destination_label": destination_label,
		"recent_destinations_label": recent_destinations_label,
		"choose_destination_button": choose_destination_button,
		"use_recent_button": use_recent_button,
		"run_button": run_button,
	}


static func _component_owner(component_id: String, component_class: String, responsibility: String) -> Dictionary:
	return {
		"tab": TAB_NAME,
		"component_id": component_id,
		"component_class": component_class,
		"responsibility": responsibility,
		"screen_script": SCREEN_SCRIPT,
		"screen_role_source": "HexMapExportScreen",
	}


static func _panel(node_name: String, component_id: String, builder_id: String) -> VBoxContainer:
	var panel := VBoxContainer.new()
	panel.name = node_name
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.set_meta("hex_workspace_component_id", component_id)
	panel.set_meta("hex_workspace_screen_script", SCREEN_SCRIPT)
	panel.set_meta("hex_workspace_screen_role_source", "HexMapExportScreen")
	panel.set_meta("hex_workspace_builder", builder_id)
	return panel


static func _wrapped_label() -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label
