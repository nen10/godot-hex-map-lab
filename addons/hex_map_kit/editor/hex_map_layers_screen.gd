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
			"layer_role_stack_visual",
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
		_component_owner("layer_role_stack_visual", "VBoxContainer", "LayerRoleStackVisual"),
	]


static func build_layer_stack_role_panel() -> Dictionary:
	var panel := _panel("Layer Stack Role Panel", "layer_stack_role_panel", "build_layer_stack_role_panel")
	var title := Label.new()
	title.text = "Layer Stack Roles"
	panel.add_child(title)

	var visual_status_label := _wrapped_label()
	visual_status_label.name = "Layer Role Stack Visual Status"
	panel.add_child(visual_status_label)

	var visual_stack := VBoxContainer.new()
	visual_stack.name = "Layer Role Stack Visual"
	visual_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	visual_stack.set_meta("hex_workspace_component_id", "layer_role_stack_visual")
	visual_stack.set_meta("hex_workspace_screen_script", SCREEN_SCRIPT)
	visual_stack.set_meta("hex_workspace_screen_role_source", "HexMapLayersScreen")
	visual_stack.set_meta("hex_workspace_builder", "build_layer_stack_role_panel")
	panel.add_child(visual_stack)

	var empty_cta_label := _wrapped_label()
	empty_cta_label.name = "Layer Role Stack Empty CTA"
	panel.add_child(empty_cta_label)

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
		"visual_status_label": visual_status_label,
		"visual_stack": visual_stack,
		"empty_cta_label": empty_cta_label,
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


static func role_stack_visual(
	role_rows: Array,
	counts: Dictionary = {},
	relationship: Dictionary = {},
	selected_role: String = ""
) -> Dictionary:
	var cards: Array[Dictionary] = []
	var normalized_selected := selected_role.strip_edges()
	for row in role_rows:
		if not row is Dictionary:
			continue
		var card := role_stack_card(row as Dictionary, normalized_selected)
		if normalized_selected == "" and cards.is_empty():
			normalized_selected = String(card.get("role", ""))
			card["selected"] = true
		cards.append(card)
	var empty_cta := role_stack_empty_cta(cards, relationship)
	return {
		"surface_id": "layer_role_stack_visual",
		"visible": true,
		"primary": true,
		"cards": cards,
		"role_cards": cards,
		"role_count": cards.size(),
		"role_names": _role_names(cards),
		"selected_role": normalized_selected,
		"relationship_status": String(relationship.get("status", "")),
		"relationship_text": String(relationship.get("message", "")),
		"ok_count": int(counts.get("ok", _count_cards_with_status(cards, "ok"))),
		"missing_count": int(counts.get("missing", _count_cards_with_status(cards, "missing"))),
		"locked_count": int(counts.get("locked", _count_locked_cards(cards))),
		"writable_sources": _writable_sources(cards),
		"chip_types": _role_stack_chip_types(),
		"chips_visible": not cards.is_empty(),
		"toggles_visible": not cards.is_empty(),
		"writable_source_visible": true,
		"raw_path_text_visible": false,
		"resource_reference_text_visible": false,
		"empty_cta": empty_cta,
	}


static func role_stack_card(row: Dictionary, selected_role: String = "") -> Dictionary:
	var role := String(row.get("role", ""))
	var status := String(row.get("status", "missing"))
	var visible := bool(row.get("visible", false))
	var locked := bool(row.get("locked", false))
	var z_index := int(row.get("z_index", 0))
	var writable_source := String(row.get("writable", "document"))
	var title := role.capitalize() if role != "" else "Role"
	var chip_types := _role_stack_chip_types()
	return {
		"id": "layer_role_%s" % role,
		"role": role,
		"title": title,
		"node": String(row.get("node", "")),
		"status": status,
		"status_chip": "Status: %s" % status,
		"missing": status != "ok",
		"target_reflected": status == "ok",
		"visible": visible,
		"visible_chip": "Visible: %s" % _on_off_label(visible),
		"locked": locked,
		"lock_chip": "Lock: %s" % _on_off_label(locked),
		"z_index": z_index,
		"z_chip": "Z: %d" % z_index,
		"writable_source": writable_source,
		"writable_chip": "Writable: %s" % writable_source,
		"writable_source_label": writable_source.capitalize(),
		"writable_source_purpose": _writable_source_purpose(writable_source),
		"chip_types": chip_types,
		"toggle_controls": PackedStringArray(["visible", "locked"]),
		"has_toggle_controls": true,
		"selected": role != "" and role == selected_role,
		"tooltip": "Role: %s\nNode: %s\n%s\n%s\n%s\n%s" % [
			role,
			String(row.get("node", "")),
			"Status: %s" % status,
			"Visible: %s" % _on_off_label(visible),
			"Lock: %s" % _on_off_label(locked),
			"Writable source: %s - %s" % [writable_source, _writable_source_purpose(writable_source)],
		],
	}


static func role_stack_empty_cta(cards: Array, relationship: Dictionary = {}) -> Dictionary:
	var visible := cards.is_empty()
	var actions := PackedStringArray()
	if visible:
		actions.append("Create Layer Stack")
		actions.append("Choose Layer Stack")
		if String(relationship.get("status", "")) != "linked":
			actions.append("Select HexTileMap target")
	return {
		"visible": visible,
		"actions": actions,
		"primary_action": "Create Layer Stack" if visible else "",
		"relationship_status": String(relationship.get("status", "")),
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


static func _role_stack_chip_types() -> Dictionary:
	return {
		"status": "chip",
		"visible": "toggle",
		"locked": "toggle",
		"z_index": "chip",
		"writable_source": "chip",
	}


static func _role_names(cards: Array) -> PackedStringArray:
	var result := PackedStringArray()
	for card in cards:
		if not card is Dictionary:
			continue
		var role := String((card as Dictionary).get("role", ""))
		if role != "":
			result.append(role)
	return result


static func _writable_sources(cards: Array) -> PackedStringArray:
	var result := PackedStringArray()
	for card in cards:
		if not card is Dictionary:
			continue
		var source := String((card as Dictionary).get("writable_source", ""))
		if source != "" and not result.has(source):
			result.append(source)
	return result


static func _count_cards_with_status(cards: Array, status: String) -> int:
	var count := 0
	for card in cards:
		if card is Dictionary and String((card as Dictionary).get("status", "")) == status:
			count += 1
	return count


static func _count_locked_cards(cards: Array) -> int:
	var count := 0
	for card in cards:
		if card is Dictionary and bool((card as Dictionary).get("locked", false)):
			count += 1
	return count


static func _on_off_label(value: bool) -> String:
	return "on" if value else "off"


static func _writable_source_purpose(source: String) -> String:
	match source:
		"document":
			return "Paint edits use the document source."
		"target":
			return "Edits apply directly to the target role layer."
		"generated":
			return "Build output can promote this role."
		"readonly":
			return "Role is visible for reference only."
	return "Project role source."
