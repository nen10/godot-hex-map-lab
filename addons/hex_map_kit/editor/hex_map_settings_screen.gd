@tool
class_name HexMapSettingsScreen
extends RefCounted

const TAB_NAME := "Settings"
const WORKFLOW_OWNER := "Settings"
const USER_TASK := "Manage workspace preferences, sample learning controls, and debug/report boundaries."
const SCREEN_SCRIPT := "hex_map_settings_screen.gd"

const GROUP_SAMPLE_LEARNING := "sample_learning"
const GROUP_DEBUG := "debug"
const GROUP_PROJECT_DEFAULTS := "project_defaults"
const GROUP_UI_PREFERENCES := "ui_preferences"


static func screen_contract() -> Dictionary:
	return {
		"screen_role_source": "HexMapSettingsScreen",
		"screen_script": SCREEN_SCRIPT,
		"tab": TAB_NAME,
		"workflow_owner": WORKFLOW_OWNER,
		"user_task": USER_TASK,
		"owns": PackedStringArray([
			"workspace_preferences",
			"sample_learning_controls",
			"debug_report_boundary",
		]),
		"delegates": {
			"production_asset_selection": "Resources",
		},
	}


static func ownership_fields() -> Dictionary:
	return {
		"settings_workflow_owner": WORKFLOW_OWNER,
	}


static func component_owner_rows() -> Array[Dictionary]:
	return [
		_component_owner("settings_preferences_panel", "VBoxContainer", "SettingsPreferencesPanel"),
		_component_owner("sample_settings_panel", "HexMapSampleSettingsPanel", "SampleSettingsPanel"),
	]


static func settings_group_rows(sample_snapshot: Dictionary = {}) -> Array[Dictionary]:
	return [
		_settings_group(
			GROUP_SAMPLE_LEARNING,
			"Sample Learning",
			"sample_settings_panel",
			"Bundled samples are visible learning sources only.",
			(sample_snapshot.get("sample_learning_toggle_ids", PackedStringArray()) as PackedStringArray),
			int(sample_snapshot.get("sample_asset_count", 0))
		),
		_settings_group(
			GROUP_DEBUG,
			"Debug",
			"sample_settings_panel",
			"Debug fallback remains an explicit opt-in.",
			(sample_snapshot.get("debug_toggle_ids", PackedStringArray()) as PackedStringArray),
			0
		),
		_settings_group(
			GROUP_PROJECT_DEFAULTS,
			"Project Defaults",
			"settings_preferences_panel",
			"Resources owns production asset defaults.",
			PackedStringArray(),
			0
		),
		_settings_group(
			GROUP_UI_PREFERENCES,
			"UI Preferences",
			"settings_preferences_panel",
			"Editor display preferences are separate from samples and debug.",
			PackedStringArray(),
			0
		),
	]


static func build_settings_preferences_panel() -> Dictionary:
	var panel := _panel(
		"Settings Preferences Panel",
		"settings_preferences_panel",
		"build_settings_preferences_panel"
	)
	var title := Label.new()
	title.text = "Settings"
	panel.add_child(title)

	var status_label := _wrapped_label()
	panel.add_child(status_label)

	var project_defaults_label := _group_label("Project Defaults")
	panel.add_child(project_defaults_label)

	var ui_preferences_label := _group_label("UI Preferences")
	panel.add_child(ui_preferences_label)

	var debug_label := _wrapped_label()
	panel.add_child(debug_label)

	var resource_label := _wrapped_label()
	panel.add_child(resource_label)

	return {
		"root": panel,
		"status_label": status_label,
		"project_defaults_label": project_defaults_label,
		"ui_preferences_label": ui_preferences_label,
		"debug_label": debug_label,
		"resource_label": resource_label,
	}


static func _component_owner(component_id: String, component_class: String, responsibility: String) -> Dictionary:
	return {
		"tab": TAB_NAME,
		"component_id": component_id,
		"component_class": component_class,
		"responsibility": responsibility,
		"screen_script": SCREEN_SCRIPT,
		"screen_role_source": "HexMapSettingsScreen",
	}


static func _settings_group(
	group_id: String,
	title: String,
	component_id: String,
	purpose: String,
	toggle_ids: PackedStringArray,
	item_count: int
) -> Dictionary:
	return {
		"id": group_id,
		"title": title,
		"component_id": component_id,
		"purpose": purpose,
		"toggle_ids": toggle_ids,
		"toggle_count": toggle_ids.size(),
		"item_count": item_count,
		"separated": true,
	}


static func _panel(node_name: String, component_id: String, builder_id: String) -> VBoxContainer:
	var panel := VBoxContainer.new()
	panel.name = node_name
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.set_meta("hex_workspace_component_id", component_id)
	panel.set_meta("hex_workspace_screen_script", SCREEN_SCRIPT)
	panel.set_meta("hex_workspace_screen_role_source", "HexMapSettingsScreen")
	panel.set_meta("hex_workspace_builder", builder_id)
	return panel


static func _group_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 13)
	return label


static func _wrapped_label() -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label
