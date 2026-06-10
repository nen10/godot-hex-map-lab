@tool
class_name HexMapValidateScreen
extends RefCounted

const TAB_NAME := "Validate"
const WORKFLOW_OWNER := "Validate"
const USER_TASK := "Run document validation and navigate issues to the responsible screen."
const SCREEN_SCRIPT := "hex_map_validate_screen.gd"


static func screen_contract() -> Dictionary:
	return {
		"screen_role_source": "HexMapValidateScreen",
		"screen_script": SCREEN_SCRIPT,
		"tab": TAB_NAME,
		"workflow_owner": WORKFLOW_OWNER,
		"user_task": USER_TASK,
		"owns": PackedStringArray([
			"validation_run",
			"issue_navigator",
			"issue_focus",
			"validation_rule_suite",
		]),
		"delegates": {},
	}


static func ownership_fields() -> Dictionary:
	return {
		"validation_workflow_owner": WORKFLOW_OWNER,
	}


static func component_owner_rows() -> Array[Dictionary]:
	return [
		_component_owner("validation_asset_panel", "HexMapWorkspaceAssetPanel", "ValidationPanel"),
		_component_owner("validation_issue_navigator", "VBoxContainer", "ValidationIssueNavigator"),
	]


static func build_validation_issue_navigator() -> Dictionary:
	var panel := _panel(
		"Validation Issue Navigator",
		"validation_issue_navigator",
		"build_validation_issue_navigator"
	)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var title := Label.new()
	title.text = "Validation Issues"
	panel.add_child(title)

	var action_row := HBoxContainer.new()
	panel.add_child(action_row)

	var run_button := Button.new()
	run_button.text = "Run Validation"
	action_row.add_child(run_button)

	var status_label := _wrapped_label()
	panel.add_child(status_label)

	var selected_label := _wrapped_label()
	panel.add_child(selected_label)

	var rows_label := _wrapped_label()
	panel.add_child(rows_label)

	return {
		"root": panel,
		"run_button": run_button,
		"status_label": status_label,
		"selected_label": selected_label,
		"rows_label": rows_label,
	}


static func _component_owner(component_id: String, component_class: String, responsibility: String) -> Dictionary:
	return {
		"tab": TAB_NAME,
		"component_id": component_id,
		"component_class": component_class,
		"responsibility": responsibility,
		"screen_script": SCREEN_SCRIPT,
		"screen_role_source": "HexMapValidateScreen",
	}


static func _panel(node_name: String, component_id: String, builder_id: String) -> VBoxContainer:
	var panel := VBoxContainer.new()
	panel.name = node_name
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.set_meta("hex_workspace_component_id", component_id)
	panel.set_meta("hex_workspace_screen_script", SCREEN_SCRIPT)
	panel.set_meta("hex_workspace_screen_role_source", "HexMapValidateScreen")
	panel.set_meta("hex_workspace_builder", builder_id)
	return panel


static func _wrapped_label() -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label
