extends "res://tests/test_editor_plugin_test_base.gd"

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	await _test_layer_stack_asset_screen_manages_project_stack_without_samples()
	await _test_map_edit_tool_layer_stack_screen_manages_roles()
	_finish("res://tests/test_editor_layer.gd")

func _test_layer_stack_asset_screen_manages_project_stack_without_samples() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var snapshot = workspace.layer_stack_screen_snapshot()
	_assert_eq(String(snapshot["layer_workflow_owner"]), "Layers", "SCREEN-21 Layers owns layer workflow")
	_assert_true(bool(snapshot["layer_management_visible"]), "SCREEN-21 Layers exposes layer management")
	_assert_eq(String(snapshot["role_actions_owner"]), "Layers", "SCREEN-21 Layers owns role actions")
	_assert_true(bool(snapshot["role_list_visible"]), "SCREEN-21 Layers exposes role list")
	_assert_true(bool(snapshot["template_controls_visible"]), "SCREEN-21 Layers exposes template controls")
	_assert_true(not bool(snapshot["paint_layer_management_visible"]), "SCREEN-21 Paint does not own layer management")
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("layer_stack_asset_panel"),
		"Layers screen exposes layer stack asset component"
	)
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("layer_stack_role_panel"),
		"TAB-53 Layers screen exposes role editor component"
	)
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("layer_role_stack_visual"),
		"SCREEN-41 Layers exposes visual role stack component"
	)
	_assert_true(bool(snapshot["role_component_present"]), "TAB-53 Layers snapshot confirms role editor component")
	_assert_true(bool(snapshot["role_stack_visual_component_present"]), "SCREEN-41 visual role stack is mounted")
	_assert_eq(String(snapshot["first_surface"]), "layer_role_stack_visual", "SCREEN-41 visual role stack is the first Layers surface")
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK),
		"Layers screen exposes layer stack slot"
	)
	for required_role in [
		HexLayerStackResource.ROLE_TERRAIN,
		HexLayerStackResource.ROLE_OVERLAY,
		HexLayerStackResource.ROLE_OBJECT,
		HexLayerStackResource.ROLE_DEBUG,
		HexLayerStackResource.ROLE_COLLISION,
		HexLayerStackResource.ROLE_NAVIGATION,
	]:
		_assert_true(
			PackedStringArray(snapshot["required_role_names"]).has(required_role),
			"TAB-53 Layers required role is visible: %s" % required_role
		)
	var initial_relationship = snapshot["relationship"] as Dictionary
	_assert_eq(initial_relationship["status"], "no_selected_hex_tile_map", "TAB-53 Layers starts with selected node empty state")
	var initial_counts = snapshot["role_status_counts"] as Dictionary
	_assert_eq(initial_counts["total"], 0, "TAB-53 Layers does not fake role rows before a project stack is selected")
	var initial_role_tree = snapshot["role_tree_summary"] as Dictionary
	_assert_eq(String(initial_role_tree["surface_id"]), "layer_role_tree", "SCREEN-NEXT-10 Layers exposes role tree summary")
	_assert_eq(String(initial_role_tree["relationship_status"]), "no_selected_hex_tile_map", "SCREEN-NEXT-10 Layers role tree starts with no target")
	_assert_true(not bool(initial_role_tree["primary_path_text_visible"]), "SCREEN-NEXT-10 Layers role tree keeps paths out of primary text")
	_assert_true(String(snapshot["mounted_role_tree_summary_text"]).contains("Roles: 0"), "SCREEN-NEXT-10 mounted Layers role tree starts empty")
	var initial_role_visual = snapshot["role_stack_visual"] as Dictionary
	_assert_eq(String(initial_role_visual["surface_id"]), "layer_role_stack_visual", "SCREEN-41 Layers exposes visual role stack snapshot")
	_assert_true(bool(initial_role_visual["primary"]), "SCREEN-41 role stack visual is the primary Layers surface")
	_assert_eq(int(initial_role_visual["role_count"]), 0, "SCREEN-41 role stack visual starts without fake cards")
	_assert_true(not bool(snapshot["role_stack_chips_visible"]), "SCREEN-41 empty role stack hides chip rows")
	_assert_true(not bool(snapshot["role_stack_toggles_visible"]), "SCREEN-41 empty role stack hides toggle rows")
	_assert_true(bool(snapshot["writable_source_visible"]), "SCREEN-41 writable source column is part of the visual contract")
	var initial_visual_empty_cta = snapshot["role_stack_visual_empty_cta"] as Dictionary
	_assert_true(bool(initial_visual_empty_cta["visible"]), "SCREEN-41 visual role stack shows an empty CTA")
	_assert_true(
		PackedStringArray(initial_visual_empty_cta["actions"]).has("Create Layer Stack"),
		"SCREEN-41 visual role stack empty CTA creates a Layer Stack"
	)
	var initial_actions = snapshot["layer_actions"] as Dictionary
	_assert_true(not bool(initial_actions["create_missing_layers"]), "TAB-53 Create Missing Layers starts unavailable")
	_assert_true(not bool(initial_actions["apply_document"]), "TAB-53 Apply Document starts unavailable")
	_assert_true(PackedStringArray(snapshot["template_candidates"]).has("standard"), "Layers screen exposes standard template candidate")
	_assert_true(PackedStringArray(snapshot["template_candidates"]).has("minimal"), "Layers screen exposes minimal template candidate")
	_assert_true(not bool(snapshot["sample_template_present"]), "Layers screen has no sample template default")
	_assert_eq(workspace.workspace_asset_context().layer_stack, null, "Layers screen starts without selected sample layer stack")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Layers screen starts with sample mode OFF")

	var output_dir = _test_resource_dir("screen22_layer_stack")
	var stack_path = "%s/layer_stack.tres" % output_dir
	var create_result = workspace.create_layer_stack(stack_path)
	_assert_true(bool(create_result["ok"]), "Layers screen creates project Layer Stack")
	_assert_true(FileAccess.file_exists(stack_path), "Layers screen writes project Layer Stack")
	var stack = create_result["resource"] as HexLayerStackResource
	_assert_true(stack is HexLayerStackResource, "Layers screen create returns layer stack resource")
	_assert_eq(workspace.workspace_asset_context().layer_stack, stack, "created layer stack enters workspace context")
	_assert_eq(workspace.edit_tool().layer_stack_resource(), stack, "created layer stack enters edit tool")
	_assert_eq(
		workspace.tab_asset_slot_snapshot("Layers", HexMapWorkspaceAssetContext.SLOT_LAYER_STACK).get("current_source", ""),
		HexMapEditorAssetSlotState.SOURCE_PROJECT,
		"Layers screen marks created layer stack as project asset"
	)
	_assert_true(not String(stack.display_name).to_lower().contains("sample"), "created layer stack is not sample-named")

	var open_result = workspace.open_layer_stack()
	_assert_true(bool(open_result["ok"]), "Layers screen opens selected Layer Stack")
	_assert_eq(open_result["resource"], stack, "Layers screen open returns selected layer stack")

	var save_as_path = "%s/layer_stack_saved_as.tres" % output_dir
	var save_result = workspace.save_layer_stack_as(save_as_path)
	_assert_true(bool(save_result["ok"]), "Layers screen saves Layer Stack as project resource")
	_assert_true(FileAccess.file_exists(save_as_path), "Layers screen Save As writes project layer stack")
	_assert_eq(stack.resource_path, save_as_path, "Layers screen Save As updates stack resource path")

	var template_path = "%s/layer_stack_standard_template_copy.tres" % output_dir
	var duplicate_result = workspace.duplicate_layer_stack_template_to_project("standard", template_path)
	_assert_true(bool(duplicate_result["ok"]), "Layers screen duplicates standard template to project asset")
	_assert_true(FileAccess.file_exists(template_path), "Layers screen writes duplicated project template")
	var duplicated_stack = duplicate_result["resource"] as HexLayerStackResource
	_assert_true(duplicated_stack is HexLayerStackResource, "duplicated template is a layer stack resource")
	_assert_eq(duplicated_stack.metadata.get("template_source", ""), "standard", "duplicated stack records template source")
	_assert_eq(workspace.workspace_asset_context().layer_stack, duplicated_stack, "duplicated template enters workspace context")
	_assert_eq(duplicated_stack.role_names().size(), 7, "duplicated standard template keeps authoring roles")

	var scene_root := Node2D.new()
	scene_root.name = "Screen22SceneRoot"
	var layer := HexTileMapLayer.new()
	layer.name = "AuthoringHexLayer"
	scene_root.add_child(layer)
	root.add_child(scene_root)
	await process_frame

	workspace.set_selected_hex_tile_map_layer(layer)
	workspace.workspace_asset_context().set_layer_stack(duplicated_stack)
	var writeback_result = workspace.apply_workspace_asset_context_to_selected_hex_tile_map(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK)
	_assert_true(bool(writeback_result["ok"]), "TAB-53 Layers writes project stack back to selected HexTileMap")
	_assert_eq(layer.layer_stack_resource, duplicated_stack, "TAB-53 selected HexTileMap owns the active Layer Stack")

	var pick_result = workspace.pick_layer_stack_target_root(scene_root)
	_assert_true(bool(pick_result["ok"]), "Layers screen picks target from scene root")
	_assert_eq(pick_result["target_layer"], layer, "Layers screen resolves scene HexTileMapLayer target")

	var document := _sample_editor_document()
	var document_result = workspace.set_layer_stack_document(document)
	_assert_true(bool(document_result["ok"]), "Layers screen accepts document for layer stack actions")
	snapshot = workspace.layer_stack_screen_snapshot()
	var relationship = snapshot["relationship"] as Dictionary
	_assert_eq(relationship["status"], "linked", "TAB-53 Layers shows selected node and stack are linked")
	_assert_true(bool(relationship["target_matches_selected"]), "TAB-53 Layers target matches selected HexTileMap")
	var action_state = snapshot["layer_actions"] as Dictionary
	_assert_true(bool(action_state["create_missing_layers"]), "TAB-53 Layers exposes Create Missing Layers when role nodes are missing")
	_assert_true(bool(action_state["apply_document"]), "TAB-53 Layers exposes Apply Document when target and document are ready")
	var status_counts = snapshot["role_status_counts"] as Dictionary
	_assert_eq(status_counts["total"], 7, "TAB-53 Layers counts standard stack role rows")
	_assert_true(int(status_counts["missing"]) > 0, "TAB-53 Layers counts missing child role layers")
	var role_stack_visual = snapshot["role_stack_visual"] as Dictionary
	_assert_eq(int(role_stack_visual["role_count"]), 7, "SCREEN-41 visual role stack counts standard role cards")
	_assert_true(bool(snapshot["role_stack_visual_primary"]), "SCREEN-41 visual role stack stays primary after stack selection")
	_assert_true(bool(snapshot["role_stack_chips_visible"]), "SCREEN-41 role stack shows chip state")
	_assert_true(bool(snapshot["role_stack_toggles_visible"]), "SCREEN-41 role stack shows visible/locked toggles")
	_assert_true(
		PackedStringArray(snapshot["role_stack_visual_role_names"]).has(HexLayerStackResource.ROLE_TERRAIN),
		"SCREEN-41 visual role stack includes terrain role"
	)
	_assert_true(
		PackedStringArray(snapshot["role_stack_visual_role_names"]).has(HexLayerStackResource.ROLE_NAVIGATION),
		"SCREEN-41 visual role stack includes navigation role"
	)
	var visual_empty_cta = snapshot["role_stack_visual_empty_cta"] as Dictionary
	_assert_true(not bool(visual_empty_cta["visible"]), "SCREEN-41 populated role stack hides the empty CTA")
	var chip_types = snapshot["role_stack_visual_chip_types"] as Dictionary
	_assert_eq(String(chip_types["visible"]), "toggle", "SCREEN-41 visible state is presented as a toggle")
	_assert_eq(String(chip_types["locked"]), "toggle", "SCREEN-41 lock state is presented as a toggle")
	_assert_eq(String(chip_types["writable_source"]), "chip", "SCREEN-41 writable source is presented as a chip")
	var role_tree = snapshot["role_tree_summary"] as Dictionary
	_assert_eq(int(role_tree["role_count"]), 7, "SCREEN-NEXT-10 Layers role tree counts role rows")
	_assert_true(int(role_tree["missing_count"]) > 0, "SCREEN-NEXT-10 Layers role tree reports missing roles")
	_assert_true(String(role_tree["role_rows_text"]).contains(HexLayerStackResource.ROLE_TERRAIN), "SCREEN-NEXT-10 Layers role tree text includes terrain role")
	_assert_true(String(snapshot["mounted_role_tree_summary_text"]).contains("Roles: 7"), "SCREEN-NEXT-10 mounted Layers role tree shows role count")
	var role_editor = snapshot["role_editor"] as Dictionary
	_assert_eq(String(role_editor["surface_id"]), "layer_role_editor", "LAYER-NEXT-10 Layers exposes role editor summary")
	_assert_eq(String(role_editor["selected_role"]), HexLayerStackResource.ROLE_TERRAIN, "LAYER-NEXT-10 role editor selects first role")
	var role_editor_controls = snapshot["role_editor_controls"] as Dictionary
	_assert_eq(String(role_editor_controls["visible"]), "CheckBox", "LAYER-NEXT-10 visible role editor uses CheckBox")
	_assert_eq(String(role_editor_controls["locked"]), "CheckBox", "LAYER-NEXT-10 locked role editor uses CheckBox")
	_assert_eq(String(role_editor_controls["z_index"]), "SpinBox", "LAYER-NEXT-10 z-index role editor uses SpinBox")
	_assert_eq(String(role_editor_controls["writable_source"]), "OptionButton", "LAYER-NEXT-10 writable role editor uses OptionButton")
	_assert_true(String(snapshot["mounted_role_editor_text"]).contains("Role: terrain"), "LAYER-NEXT-10 mounted role editor names selected role")
	var terrain_row = _layer_stack_row_for_role(snapshot["role_rows"], HexLayerStackResource.ROLE_TERRAIN)
	_assert_eq(terrain_row["status"], "missing", "Layers screen reports missing terrain role before create")
	_assert_true(bool(terrain_row["visible"]), "TAB-53 terrain row shows visibility")
	_assert_eq(terrain_row["locked"], false, "TAB-53 terrain row shows locked state")
	_assert_eq(terrain_row["writable"], "document", "TAB-53 terrain row shows writable source")
	var terrain_visual_card = _layer_stack_row_for_role(snapshot["role_stack_visual_rows"], HexLayerStackResource.ROLE_TERRAIN)
	_assert_eq(String(terrain_visual_card["status"]), "missing", "SCREEN-41 terrain card shows missing status")
	_assert_eq(String(terrain_visual_card["visible_chip"]), "Visible: on", "SCREEN-41 terrain card shows visible chip")
	_assert_eq(String(terrain_visual_card["lock_chip"]), "Lock: off", "SCREEN-41 terrain card shows lock chip")
	_assert_eq(String(terrain_visual_card["writable_source"]), "document", "SCREEN-41 terrain card shows document writable source")
	_assert_eq(String(terrain_visual_card["writable_chip"]), "Writable: document", "SCREEN-41 terrain card shows writable source chip")
	_assert_true(
		PackedStringArray(terrain_visual_card["toggle_controls"]).has("visible"),
		"SCREEN-41 terrain card exposes visible toggle control"
	)
	_assert_true(bool(terrain_visual_card["has_toggle_controls"]), "SCREEN-41 terrain card records toggle controls")
	_assert_true(not bool(snapshot["role_stack_resource_reference_text_visible"]), "SCREEN-41 role stack does not expose Resource path text")
	var select_role_result = workspace.select_layer_stack_role(HexLayerStackResource.ROLE_OVERLAY)
	_assert_true(bool(select_role_result["ok"]), "LAYER-NEXT-10 role editor selects explicit role")
	_assert_eq(
		String((select_role_result["role_editor"] as Dictionary)["selected_role"]),
		HexLayerStackResource.ROLE_OVERLAY,
		"LAYER-NEXT-10 role editor snapshot follows explicit selection"
	)
	var edit_missing_role_result = workspace.update_layer_stack_role_properties(
		HexLayerStackResource.ROLE_TERRAIN,
		{
			"visible": false,
			"locked": true,
			"z_index": 77,
			"writable_source": "target",
		}
	)
	_assert_true(bool(edit_missing_role_result["ok"]), "LAYER-NEXT-10 role editor updates missing role resource state")
	_assert_true(not bool(edit_missing_role_result["target_reflected"]), "LAYER-NEXT-10 missing role edit reports no target reflection")
	terrain_row = _layer_stack_row_for_role(edit_missing_role_result["role_rows"], HexLayerStackResource.ROLE_TERRAIN)
	_assert_eq(terrain_row["visible"], false, "LAYER-NEXT-10 missing role edit updates resource visibility")
	_assert_eq(terrain_row["locked"], true, "LAYER-NEXT-10 missing role edit updates resource locked state")
	_assert_eq(int(terrain_row["z_index"]), 77, "LAYER-NEXT-10 missing role edit updates resource z-index")
	_assert_eq(terrain_row["writable"], "target", "LAYER-NEXT-10 missing role edit updates resource writable source")
	snapshot = workspace.layer_stack_screen_snapshot()
	role_editor = snapshot["role_editor"] as Dictionary
	_assert_eq(String(role_editor["selected_role"]), HexLayerStackResource.ROLE_TERRAIN, "LAYER-NEXT-10 edit selects edited role")
	_assert_eq(String(role_editor["target_reflection_status"]), "missing", "LAYER-NEXT-10 missing role editor shows missing target")
	_assert_true(String(snapshot["mounted_role_editor_text"]).contains("Writable: target"), "LAYER-NEXT-10 mounted role editor shows edited writable source")
	terrain_visual_card = _layer_stack_row_for_role(snapshot["role_stack_visual_rows"], HexLayerStackResource.ROLE_TERRAIN)
	_assert_eq(bool(terrain_visual_card["visible"]), false, "SCREEN-41 terrain visual card follows edited visibility")
	_assert_eq(bool(terrain_visual_card["locked"]), true, "SCREEN-41 terrain visual card follows edited lock state")
	_assert_eq(int(terrain_visual_card["z_index"]), 77, "SCREEN-41 terrain visual card follows edited z-index")
	_assert_eq(String(terrain_visual_card["writable_source"]), "target", "SCREEN-41 terrain visual card follows target writable source")
	_assert_eq(String(terrain_visual_card["visible_chip"]), "Visible: off", "SCREEN-41 terrain visual chip shows hidden state")
	_assert_eq(String(terrain_visual_card["lock_chip"]), "Lock: on", "SCREEN-41 terrain visual chip shows locked state")
	_assert_eq(String(terrain_visual_card["z_chip"]), "Z: 77", "SCREEN-41 terrain visual chip shows z-index")
	var collision_row = _layer_stack_row_for_role(snapshot["role_rows"], HexLayerStackResource.ROLE_COLLISION)
	_assert_eq(collision_row["visible"], false, "TAB-53 collision row shows hidden visibility state")
	for role_name in [
		HexLayerStackResource.ROLE_OVERLAY,
		HexLayerStackResource.ROLE_OBJECT,
		HexLayerStackResource.ROLE_DEBUG,
		HexLayerStackResource.ROLE_COLLISION,
		HexLayerStackResource.ROLE_NAVIGATION,
	]:
		var role_row = _layer_stack_row_for_role(snapshot["role_rows"], role_name)
		_assert_eq(role_row["role"], role_name, "TAB-53 Layers shows role row: %s" % role_name)
		_assert_true(["missing", "ok"].has(role_row["status"]), "TAB-53 Layers row has readable status: %s" % role_name)
	_assert_eq(
		String((snapshot["target_status"] as Dictionary).get("target_class", "")),
		"HexTileMapLayer",
		"Layers screen target status names HexTileMapLayer"
	)

	var create_layers_result = workspace.create_missing_layer_stack_layers()
	_assert_true(bool(create_layers_result["ok"]), "Layers screen creates missing target layers")
	terrain_row = _layer_stack_row_for_role(create_layers_result["role_rows"], HexLayerStackResource.ROLE_TERRAIN)
	_assert_eq(terrain_row["status"], "ok", "Layers screen reports created terrain role")
	snapshot = workspace.layer_stack_screen_snapshot()
	status_counts = snapshot["role_status_counts"] as Dictionary
	_assert_eq(status_counts["missing"], 0, "TAB-53 Layers reports no missing roles after creating child layers")
	terrain_visual_card = _layer_stack_row_for_role(snapshot["role_stack_visual_rows"], HexLayerStackResource.ROLE_TERRAIN)
	_assert_eq(String(terrain_visual_card["status"]), "ok", "SCREEN-41 terrain visual card reflects created target layer")
	_assert_true(bool(terrain_visual_card["target_reflected"]), "SCREEN-41 terrain visual card marks target reflection after create")
	role_tree = snapshot["role_tree_summary"] as Dictionary
	_assert_eq(int(role_tree["missing_count"]), 0, "SCREEN-NEXT-10 Layers role tree reports no missing roles after creation")
	action_state = snapshot["layer_actions"] as Dictionary
	_assert_true(not bool(action_state["create_missing_layers"]), "TAB-53 Create Missing Layers disables after all child layers exist")
	var terrain_node = layer.layer_for_stack_role(HexLayerStackResource.ROLE_TERRAIN) as TileMapLayer
	_assert_true(terrain_node != null, "Layers screen creates terrain target node")
	_assert_eq(terrain_node.visible, false, "LAYER-NEXT-10 created role node reflects edited visibility")
	_assert_eq(terrain_node.z_index, 77, "LAYER-NEXT-10 created role node reflects edited z-index")
	_assert_eq(terrain_node.get_meta("hex_layer_stack_locked", false), true, "LAYER-NEXT-10 created role node reflects locked metadata")
	_assert_eq(String(terrain_node.get_meta("hex_layer_stack_writable_source", "")), "target", "LAYER-NEXT-10 created role node reflects writable metadata")
	var edit_existing_role_result = workspace.update_layer_stack_role_properties(
		HexLayerStackResource.ROLE_TERRAIN,
		{
			"visible": true,
			"locked": false,
			"z_index": 12,
			"writable_source": "generated",
		}
	)
	_assert_true(bool(edit_existing_role_result["ok"]), "LAYER-NEXT-10 role editor updates existing target role")
	_assert_true(bool(edit_existing_role_result["target_reflected"]), "LAYER-NEXT-10 existing role edit reports target reflection")
	_assert_eq(terrain_node.visible, true, "LAYER-NEXT-10 existing role edit reflects visibility to target")
	_assert_eq(terrain_node.z_index, 12, "LAYER-NEXT-10 existing role edit reflects z-index to target")
	_assert_eq(terrain_node.get_meta("hex_layer_stack_locked", true), false, "LAYER-NEXT-10 existing role edit reflects locked metadata")
	_assert_eq(String(terrain_node.get_meta("hex_layer_stack_writable_source", "")), "generated", "LAYER-NEXT-10 existing role edit reflects writable metadata")
	snapshot = workspace.layer_stack_screen_snapshot()
	role_editor = snapshot["role_editor"] as Dictionary
	_assert_eq(bool(role_editor["target_reflected"]), true, "LAYER-NEXT-10 role editor snapshot marks target reflected")
	_assert_eq(int(role_editor["target_z_index"]), 12, "LAYER-NEXT-10 role editor snapshot exposes target z-index")
	_assert_eq(String(role_editor["target_writable_source"]), "generated", "LAYER-NEXT-10 role editor snapshot exposes target writable source")
	terrain_visual_card = _layer_stack_row_for_role(snapshot["role_stack_visual_rows"], HexLayerStackResource.ROLE_TERRAIN)
	_assert_eq(String(terrain_visual_card["writable_source"]), "generated", "SCREEN-41 terrain visual card shows generated writable source")
	_assert_true(
		String(terrain_visual_card["writable_source_purpose"]).contains("Build"),
		"SCREEN-41 generated writable source describes Build promotion"
	)

	var apply_result = workspace.apply_layer_stack_document_to_target()
	_assert_true(bool(apply_result["ok"]), "Layers screen applies document to target stack")
	_assert_true(terrain_node.get_used_cells().size() > 0, "Layers screen populates terrain role from document")

	var clear_role_result = workspace.clear_layer_stack_role(HexLayerStackResource.ROLE_TERRAIN)
	_assert_true(bool(clear_role_result["ok"]), "Layers screen clears selected role")
	_assert_eq(terrain_node.get_used_cells().size(), 0, "Layers screen clear role removes terrain cells")

	var clear_stack_result = workspace.clear_layer_stack()
	_assert_true(bool(clear_stack_result["ok"]), "Layers screen clears Layer Stack selection")
	_assert_eq(workspace.workspace_asset_context().layer_stack, null, "cleared layer stack leaves workspace context")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Layers screen actions do not enable sample mode")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _test_map_edit_tool_layer_stack_screen_manages_roles() -> void:
	var tool = await _new_ready_edit_tool()
	var rows = tool.layer_stack_rows()
	var terrain_row = _layer_stack_row_for_role(rows, HexLayerStackResource.ROLE_TERRAIN)
	_assert_eq(terrain_row["node"], "TerrainTileMapLayer", "layer stack screen lists terrain node")
	_assert_eq(terrain_row["status"], "missing", "layer stack row starts missing without HexTileMapLayer target")
	_assert_eq(terrain_row["writable"], "document", "layer stack row exposes writable source")

	tool._on_layer_stack_template_selected(1)
	_assert_eq(tool.layer_stack_rows().size(), 3, "minimal layer stack template has three roles")
	tool._on_layer_stack_template_selected(0)
	_assert_eq(tool.layer_stack_rows().size(), 7, "standard layer stack template has seven roles")

	var data = HexMapData.rectangle(1, 1)
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame

	tool.set_document(document)
	tool.set_target_layer(layer)
	_assert_true(tool._layer_stack_create_missing_button.disabled == false, "layer stack create action is enabled for HexTileMapLayer document")
	tool._on_create_missing_layers_pressed()
	terrain_row = _layer_stack_row_for_role(tool.layer_stack_rows(), HexLayerStackResource.ROLE_TERRAIN)
	_assert_eq(terrain_row["status"], "ok", "Create Missing Layers creates terrain role layer")
	var terrain_node = layer.layer_for_stack_role(HexLayerStackResource.ROLE_TERRAIN) as TileMapLayer
	_assert_true(terrain_node != null, "terrain role resolves to TileMapLayer after create")

	tool._selected_layer_stack_role = HexLayerStackResource.ROLE_TERRAIN
	tool._on_clear_layer_stack_role_pressed()
	_assert_eq(terrain_node.get_used_cells().size(), 0, "Clear Role clears selected role layer")
	tool._on_apply_layer_stack_document_pressed()
	_assert_true(terrain_node.get_used_cells().size() > 0, "Apply Document repopulates terrain role layer")

	layer.queue_free()
	tool.queue_free()
	await process_frame

