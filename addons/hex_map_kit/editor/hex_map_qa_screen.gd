@tool
class_name HexMapQAScreen
extends RefCounted

const HexMapPreviewThumbnail = preload("res://addons/hex_map_kit/editor/hex_map_preview_thumbnail.gd")

const TAB_NAME := "QA"
const WORKFLOW_OWNER := "QA"
const USER_TASK := "Compare generated seed candidates and promote one result to the Level Document."
const SCREEN_SCRIPT := "hex_map_qa_screen.gd"


static func screen_contract() -> Dictionary:
	return {
		"screen_role_source": "HexMapQAScreen",
		"screen_script": SCREEN_SCRIPT,
		"tab": TAB_NAME,
		"workflow_owner": WORKFLOW_OWNER,
		"user_task": USER_TASK,
		"owns": PackedStringArray([
			"generation_profile",
			"seed_lab",
			"score_table",
			"promote_selected_seed",
		]),
		"delegates": {
			"generate_candidate": "Generate",
			"promote_target": "Resources",
		},
	}


static func ownership_fields() -> Dictionary:
	return {
		"qa_workflow_owner": WORKFLOW_OWNER,
	}


static func component_owner_rows() -> Array[Dictionary]:
	return [
		_component_owner("qa_seed_lab_panel", "VBoxContainer", "SeedLabPanel"),
		_component_owner("qa_asset_panel", "HexMapWorkspaceAssetPanel", "SeedLabPanel"),
	]


static func build_seed_lab_panel() -> Dictionary:
	var panel := _panel("QA Seed Lab Panel", "qa_seed_lab_panel", "build_seed_lab_panel")
	var title := Label.new()
	title.text = "Seed Lab"
	panel.add_child(title)

	var status_label := _wrapped_label()
	panel.add_child(status_label)

	var selected_label := _wrapped_label()
	panel.add_child(selected_label)

	var selected_thumbnail := HexMapPreviewThumbnail.new()
	selected_thumbnail.name = "QA Selected Seed Thumbnail"
	panel.add_child(selected_thumbnail)

	var score_tree := Tree.new()
	score_tree.name = "QA Score Table"
	score_tree.hide_root = true
	score_tree.columns = 7
	score_tree.set_column_titles_visible(true)
	score_tree.set_column_title(0, "rank")
	score_tree.set_column_title(1, "seed")
	score_tree.set_column_title(2, "score")
	score_tree.set_column_title(3, "validation")
	score_tree.set_column_title(4, "selected")
	score_tree.set_column_title(5, "preview")
	score_tree.set_column_title(6, "promotion")
	score_tree.custom_minimum_size = Vector2(0, 120)
	score_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(score_tree)

	var rows_label := _wrapped_label()
	panel.add_child(rows_label)

	return {
		"root": panel,
		"status_label": status_label,
		"selected_label": selected_label,
		"selected_thumbnail": selected_thumbnail,
		"score_tree": score_tree,
		"rows_label": rows_label,
	}


static func _component_owner(component_id: String, component_class: String, responsibility: String) -> Dictionary:
	return {
		"tab": TAB_NAME,
		"component_id": component_id,
		"component_class": component_class,
		"responsibility": responsibility,
		"screen_script": SCREEN_SCRIPT,
		"screen_role_source": "HexMapQAScreen",
	}


static func _panel(node_name: String, component_id: String, builder_id: String) -> VBoxContainer:
	var panel := VBoxContainer.new()
	panel.name = node_name
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.set_meta("hex_workspace_component_id", component_id)
	panel.set_meta("hex_workspace_screen_script", SCREEN_SCRIPT)
	panel.set_meta("hex_workspace_screen_role_source", "HexMapQAScreen")
	panel.set_meta("hex_workspace_builder", builder_id)
	return panel


static func _wrapped_label() -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label
