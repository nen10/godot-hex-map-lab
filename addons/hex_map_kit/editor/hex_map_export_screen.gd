@tool
class_name HexMapExportScreen
extends RefCounted

const TAB_NAME := "Export"
const WORKFLOW_OWNER := "Export"
const USER_TASK := "Choose a runtime handoff destination and export the Level Document."
const SCREEN_SCRIPT := "hex_map_export_screen.gd"
const PURPOSE_RUNTIME_MAP := "runtime_map_resource"
const PURPOSE_RUNTIME_SCENE := "runtime_scene"
const PURPOSE_GENERATION_GRAPH := "generation_graph_resource"
const SECONDARY_DEBUG_REPORT := "debug_report"
const SECONDARY_JSON_SNAPSHOT := "json_snapshot"
const SECONDARY_PACKAGE_BUILD := "package_build"


static func screen_contract() -> Dictionary:
	return {
		"screen_role_source": "HexMapExportScreen",
		"screen_script": SCREEN_SCRIPT,
		"tab": TAB_NAME,
		"workflow_owner": WORKFLOW_OWNER,
		"user_task": USER_TASK,
		"owns": PackedStringArray([
			"export_profile",
			"runtime_handoff_cards",
			"runtime_handoff_type",
			"runtime_scene",
			"generation_graph_resource",
			"output_destination",
			"export_result_state",
		]),
		"delegates": {
			"source_document": "Resources",
			"package_build": "Release Process",
			"debug_report": "Diagnostics",
		},
	}


static func purpose_cards(context: Dictionary = {}) -> Array[Dictionary]:
	var source_ready := bool(context.get("source_ready", false))
	var destination_ready := bool(context.get("destination_ready", false))
	var graph_ready := bool(context.get("graph_ready", false))
	var block_reason := String(context.get("block_reason", ""))
	var handoff_ready := source_ready and destination_ready
	var graph_block_reason := block_reason
	if graph_block_reason == "" and not graph_ready:
		graph_block_reason = "Generation Graph is not linked to the selected HexTileMapLayer."
	return [
		_purpose_card(
			PURPOSE_RUNTIME_MAP,
			"Runtime Map Resource (.tres)",
			"Export .tres",
			"HexMapResource",
			"Loadable runtime map data for HexTileMapLayer and scripts.",
			handoff_ready,
			block_reason,
			true,
			"data"
		),
		_purpose_card(
			PURPOSE_RUNTIME_SCENE,
			"Runtime Scene (.tscn)",
			"Create Scene",
			"PackedScene",
			"Loadable HexTileMapLayer node tree with the runtime map attached.",
			handoff_ready,
			block_reason,
			false,
			"scene"
		),
		_purpose_card(
			PURPOSE_GENERATION_GRAPH,
			"Generation Graph (.tres)",
			"Export Graph",
			"HexGenerationGraphResource",
			"Self-contained graph resource for the runtime Map Build API.",
			handoff_ready and graph_ready,
			graph_block_reason,
			false,
			"graph"
		),
	]


static func secondary_actions(context: Dictionary = {}) -> Array[Dictionary]:
	var source_ready := bool(context.get("source_ready", false))
	return [
		_secondary_action(
			SECONDARY_DEBUG_REPORT,
			"Debug Report",
			"Copy Report",
			true,
			"",
			"Diagnostic report for support and implementation review."
		),
		_secondary_action(
			SECONDARY_JSON_SNAPSHOT,
			"JSON Snapshot",
			"Export JSON",
			source_ready,
			"Level Document is not selected." if not source_ready else "",
			"Serializable Export screen state snapshot for debugging."
		),
		_secondary_action(
			SECONDARY_PACKAGE_BUILD,
			"Package",
			"Package",
			false,
			"Package build is process-only. Use the release/package process.",
			"Addon package creation is not a workspace Export output."
		),
	]


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

	var runtime_handoff_summary_label := _wrapped_label()
	runtime_handoff_summary_label.name = "Runtime Handoff Summary"
	panel.add_child(runtime_handoff_summary_label)

	var purpose_cards_container := GridContainer.new()
	purpose_cards_container.name = "Runtime Handoff Purpose Cards"
	purpose_cards_container.columns = 1
	purpose_cards_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var purpose_card_buttons := {}
	for card in purpose_cards():
		var button := _card_button(card)
		purpose_cards_container.add_child(button)
		purpose_card_buttons[String(card.get("id", ""))] = button
	panel.add_child(purpose_cards_container)

	var mode_label := _wrapped_label()
	panel.add_child(mode_label)

	var backlog_label := _wrapped_label()
	panel.add_child(backlog_label)

	var secondary_actions_container := HBoxContainer.new()
	secondary_actions_container.name = "Export Secondary Actions"
	secondary_actions_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var secondary_action_buttons := {}
	for action in secondary_actions():
		var button := _secondary_button(action)
		secondary_actions_container.add_child(button)
		secondary_action_buttons[String(action.get("id", ""))] = button
	panel.add_child(secondary_actions_container)

	return {
		"root": panel,
		"status_label": status_label,
		"runtime_handoff_summary_label": runtime_handoff_summary_label,
		"purpose_card_buttons": purpose_card_buttons,
		"mode_label": mode_label,
		"backlog_label": backlog_label,
		"secondary_action_buttons": secondary_action_buttons,
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


static func _purpose_card(
	id: String,
	title: String,
	action_label: String,
	target_resource_class: String,
	purpose: String,
	enabled: bool,
	disabled_reason: String,
	primary: bool,
	card_shape: String
) -> Dictionary:
	return {
		"id": id,
		"title": title,
		"action_label": action_label,
		"target_resource_class": target_resource_class,
		"purpose": purpose,
		"enabled": enabled,
		"disabled_reason": disabled_reason if not enabled else "",
		"primary": primary,
		"card_shape": card_shape,
		"destination_required": true,
		"godot_handoff": true,
		"gameplay_framework": false,
		"visible": true,
	}


static func _secondary_action(
	id: String,
	label: String,
	action_label: String,
	enabled: bool,
	disabled_reason: String,
	purpose: String
) -> Dictionary:
	return {
		"id": id,
		"label": label,
		"action_label": action_label,
		"enabled": enabled,
		"disabled_reason": disabled_reason if not enabled else "",
		"tooltip": disabled_reason if disabled_reason != "" else purpose,
		"purpose": purpose,
		"visible": true,
		"process_only": id == SECONDARY_PACKAGE_BUILD,
	}


static func _card_button(card: Dictionary) -> Button:
	var button := Button.new()
	button.name = String(card.get("title", "Export Purpose"))
	button.text = "%s\n%s" % [
		String(card.get("title", "")),
		String(card.get("action_label", "")),
	]
	button.disabled = not bool(card.get("enabled", false))
	button.tooltip_text = String(card.get("disabled_reason", ""))
	if button.tooltip_text == "":
		button.tooltip_text = String(card.get("purpose", ""))
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.set_meta("hex_export_purpose_card_id", String(card.get("id", "")))
	button.set_meta("hex_export_card_shape", String(card.get("card_shape", "")))
	return button


static func _secondary_button(action: Dictionary) -> Button:
	var button := Button.new()
	button.name = String(action.get("label", "Export Secondary Action"))
	button.text = String(action.get("action_label", ""))
	button.disabled = not bool(action.get("enabled", false))
	button.tooltip_text = String(action.get("tooltip", ""))
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.set_meta("hex_export_secondary_action_id", String(action.get("id", "")))
	return button


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
