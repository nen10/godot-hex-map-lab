extends "res://tests/test_editor_plugin_test_base.gd"

func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await _test_plugin_registration_files()
	await _test_hex_map_workspace_exposes_tabs_and_routes_editing()
	_finish("res://tests/test_editor_plugin.gd")


func _test_plugin_registration_files() -> void:
	var config = ConfigFile.new()
	var error = config.load("res://addons/hex_map_kit/plugin.cfg")
	_assert_eq(error, OK, "plugin.cfg loads")
	_assert_eq(config.get_value("plugin", "name", ""), "Hex Map Kit", "plugin.cfg has addon name")
	var script_path = "res://addons/hex_map_kit/%s" % config.get_value("plugin", "script", "")
	_assert_true(load(script_path) != null, "plugin.cfg script can be loaded")


func _test_hex_map_workspace_exposes_tabs_and_routes_editing() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var expected_tabs = PackedStringArray([
		"Build",
		"Paint",
		"Catalog",
		"Layers",
		"Resources",
		"Validate",
		"QA",
		"Export",
		"Settings",
	])
	_assert_eq(workspace.name, "Hex Map Workspace", "workspace has stable dock name")
	_assert_eq(workspace.workspace_tab_names(), expected_tabs, "workspace exposes UX responsibility tabs")
	for tab_name in expected_tabs:
		_assert_true(workspace.tab_has_scroll_container(tab_name), "%s tab has workspace scroll root" % tab_name)
		_assert_eq(workspace.tab_scroll_root_class(tab_name), "ScrollContainer", "%s tab root is a ScrollContainer" % tab_name)
		_assert_eq(workspace.tab_content_root_class(tab_name), "VBoxContainer", "%s tab keeps vertical content layout" % tab_name)
	_assert_true(
		workspace.component_rows().size() >= expected_tabs.size(),
		"workspace exposes component responsibility map"
	)
	_assert_eq(
		workspace.component_for_responsibility("CatalogPanel").get("tab", ""),
		"Catalog",
		"workspace maps CatalogPanel to Catalog tab"
	)
	_assert_eq(
		workspace.component_for_responsibility("ValidationPanel").get("tab", ""),
		"Validate",
		"workspace maps ValidationPanel to Validate tab"
	)
	_assert_eq(
		workspace.component_for_responsibility("SampleSettingsPanel").get("tab", ""),
		"Settings",
		"workspace maps SampleSettingsPanel to Settings tab"
	)
	_assert_eq(
		workspace.component_for_responsibility("SettingsPreferencesPanel").get("tab", ""),
		"Settings",
		"workspace maps SettingsPreferencesPanel to Settings tab"
	)
	_assert_true(workspace.generation_dock() is HexMapGenDock, "workspace mounts generation component")
	_assert_true(workspace.edit_tool() is HexMapEditTool, "workspace mounts paint/edit component")
	_assert_true(workspace.sample_settings_panel() is HexMapSampleSettingsPanel, "workspace mounts sample settings component")
	_assert_eq(workspace.generation_dock().editor_session_state(), session, "workspace forwards session to generation component")
	_assert_generation_dock_internal_component_contract(workspace.generation_dock())
	_assert_eq(workspace.edit_tool().editor_session_state(), session, "workspace forwards session to paint/edit component")
	_assert_eq(workspace.sample_settings_panel().editor_session_state(), session, "workspace forwards session to sample settings component")
	_assert_true(workspace.tab_has_component("Layers", "layer_stack_role_panel"), "workspace mounts Layers role editor component")
	_assert_true(workspace.tab_has_component("QA", "qa_seed_lab_panel"), "workspace mounts QA Seed Lab component")
	_assert_true(workspace.tab_has_component("Export", "export_purpose_panel"), "workspace mounts Export purpose component")
	_assert_true(workspace.tab_has_component("Settings", "settings_preferences_panel"), "workspace mounts Settings purpose component")
	var asset_tab_expectations := [
		{"tab": "Resources", "component": "document_asset_panel", "count": 6, "slot": "movement_profile"},
		{"tab": "Catalog", "component": "catalog_asset_panel", "count": 1, "slot": "tile_catalog"},
		{"tab": "Layers", "component": "layer_stack_asset_panel", "count": 1, "slot": "layer_stack"},
		{"tab": "Validate", "component": "validation_asset_panel", "count": 2, "slot": "validation_rule_suite"},
		{"tab": "QA", "component": "qa_asset_panel", "count": 3, "slot": "generation_profile"},
		{"tab": "Export", "component": "export_asset_panel", "count": 2, "slot": "export_profile"},
	]
	for expectation in asset_tab_expectations:
		var tab_name := String(expectation["tab"])
		_assert_true(
			workspace.tab_has_component(tab_name, String(expectation["component"])),
			"%s tab has real asset component" % tab_name
		)
		_assert_eq(
			workspace.asset_slot_count(tab_name),
			int(expectation["count"]),
			"%s tab owns expected asset slot count" % tab_name
		)
		_assert_true(
			workspace.tab_asset_slot_ids(tab_name).has(String(expectation["slot"])),
			"%s tab exposes expected asset slot id" % tab_name
		)
	_assert_true(workspace.tab_has_component("Build", "build_graph_screen"), "Build tab keeps graph component")
	_assert_true(workspace.tab_has_component("Generate", "generation_panel"), "Generate alias keeps generation component")
	_assert_true(
		workspace.tab_component_ids("Catalog").has("catalog_asset_panel"),
		"Catalog tab registry exposes catalog asset panel"
	)
	_assert_true(
		workspace.tab_component_ids("Validate").has("validation_issue_navigator"),
		"Validate tab registry exposes issue navigator"
	)
	_assert_true(
		workspace.tab_asset_slot_ids("Catalog").has(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG),
		"Catalog tab registry exposes tile catalog asset slot"
	)
	_assert_true(
		workspace.tab_asset_slot_ids("QA").has(HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE),
		"QA tab registry exposes generation profile asset slot"
	)
	_assert_true(workspace.tab_has_component("Paint", "brush_palette"), "Paint tab keeps paint component")
	_assert_eq(workspace.asset_slot_count("Paint"), 0, "TAB-51 Paint tab no longer owns ResourcePicker asset slots")
	_assert_eq(workspace.tab_asset_slot_ids("Paint"), PackedStringArray(), "TAB-51 Paint tab asset slots live in Resources")
	_assert_true(not workspace.tab_has_component("Paint", "document_asset_panel"), "Paint tab does not own Document setup component")
	_assert_true(workspace.tab_has_component("Settings", "sample_settings_panel"), "Settings tab keeps sample settings component")
	_assert_eq(workspace.asset_slot_count("Settings"), 0, "TAB-57 Settings tab owns no production asset slots")
	_assert_true(not workspace.tab_asset_slot_ids("Settings").has(HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE), "TAB-57 Settings does not expose Movement Profile selection")

	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	root.add_child(layer)
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	session.set_debug_numeric_tile_fallback_enabled(true, "test.tab51_workspace_viewport")
	workspace.edit_tool().set_document(document)
	workspace.edit_tool().set_target_layer(layer)
	_assert_true(workspace.viewport_input_enabled(), "workspace gates viewport input through paint/edit component")
	_assert_eq(workspace.current_workspace_tab_name(), "Build", "TAB-51 workspace starts on Build before viewport edit")
	var canvas_transform = Transform2D(0.0, Vector2(120.0, -40.0))
	workspace.edit_tool().set_viewport_canvas_transform_for_test(canvas_transform)
	var origin_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true))
	var scene_position = layer.to_global(origin_local)
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = canvas_transform * scene_position
	_assert_true(workspace.forward_canvas_gui_input(press), "TAB-51 workspace consumes viewport paint edit")
	_assert_eq(workspace.current_workspace_tab_name(), "Paint", "TAB-51 viewport edit switches to Paint tab")
	var paint_snapshot = workspace.paint_brush_screen_snapshot()
	_assert_eq(paint_snapshot["active_document"], document, "TAB-51 Paint snapshot reports active document")
	_assert_eq(paint_snapshot["active_layer"], layer, "TAB-51 Paint snapshot reports active layer")
	_assert_eq(String(paint_snapshot["document_workflow_owner"]), "Resources", "SCREEN-21 Paint snapshot routes document workflow to Resources")
	_assert_eq(String(paint_snapshot["layer_workflow_owner"]), "Layers", "SCREEN-21 Paint snapshot routes layer workflow to Layers")
	_assert_eq(String(paint_snapshot["export_workflow_owner"]), "Export", "SCREEN-21 Paint snapshot routes export workflow to Export")
	_assert_true(not bool(paint_snapshot["paint_non_paint_management_visible"]), "SCREEN-21 Paint snapshot hides non-paint management controls")
	_assert_eq(String(paint_snapshot["paint_surface_owner"]), "Paint", "SCREEN-22 Paint owns brush surface")
	_assert_true(bool(paint_snapshot["paint_surface_visible"]), "SCREEN-22 Paint surface summary is visible")
	_assert_true(bool(paint_snapshot["active_brush_visible"]), "SCREEN-22 Paint shows active brush state")
	_assert_true(bool(paint_snapshot["target_layer_summary_visible"]), "SCREEN-22 Paint shows target layer summary")
	_assert_true(bool(paint_snapshot["selected_cell_summary_visible"]), "SCREEN-22 Paint shows selected cell summary")
	_assert_true(bool(paint_snapshot["last_edit_summary_visible"]), "SCREEN-22 Paint shows last edit summary")
	_assert_true(bool(paint_snapshot["viewport_edit_updates_paint_state"]), "SCREEN-22 viewport edit updates Paint state")
	_assert_true(not bool(paint_snapshot["resource_reference_only"]), "SCREEN-22 Paint is not resource-reference-only")
	_assert_true(String(paint_snapshot["paint_workspace_summary_text"]).contains("Brush:"), "SCREEN-22 Paint visible summary includes brush")
	_assert_eq(String(paint_snapshot["selected_cell_summary"]), HexVector.zero().key(), "SCREEN-22 Paint selected cell summary updates after viewport edit")
	var selected_cell = paint_snapshot["selected_cell"] as Dictionary
	_assert_true(bool(selected_cell["present"]), "TAB-51 Paint snapshot reports selected/last edited cell")
	_assert_eq(String(selected_cell["cell_key"]), HexVector.zero().key(), "TAB-51 Paint snapshot reports edited cell key")
	var paint_state = paint_snapshot["interaction_state"] as Dictionary
	var paint_view_state = paint_snapshot["view_state"] as Dictionary
	var paint_active_states := PackedStringArray(paint_state["active_state_ids"])
	_assert_eq(String(paint_state["state_source"]), "HexMapPaintInteractionState", "STATE-40 Paint snapshot reports state source")
	_assert_eq(String(paint_state["state_id"]), HexMapPaintInteractionState.STATE_APPLIED_DIRTY, "STATE-40 viewport edit enters applied dirty state")
	_assert_true(paint_active_states.has(HexMapPaintInteractionState.STATE_READY), "STATE-40 viewport edit keeps ready state active")
	_assert_true(paint_active_states.has(HexMapPaintInteractionState.STATE_HOVERING_CELL), "STATE-40 viewport edit exposes hovered cell state")
	_assert_true(paint_active_states.has(HexMapPaintInteractionState.STATE_SELECTED_CELL), "STATE-40 viewport edit exposes selected cell state")
	_assert_true(paint_active_states.has(HexMapPaintInteractionState.STATE_APPLIED_DIRTY), "STATE-40 viewport edit exposes apply/dirty state")
	_assert_eq(paint_view_state["active_layer"], layer, "STATE-40 Paint ViewState renders active layer target")
	_assert_eq(String(paint_view_state["selected_cell_key"]), HexVector.zero().key(), "STATE-40 Paint ViewState renders selected cell")
	_assert_true(bool(paint_view_state["can_paint"]), "STATE-40 Paint ViewState allows painting when target/document/brush are ready")
	_assert_true(
		String(paint_snapshot["last_edit_message"]).contains("document=yes"),
		"TAB-51 Paint snapshot reports last edit detail"
	)
	_assert_true(String(paint_snapshot["undo_hint"]) != "", "TAB-51 Paint snapshot reports undo hint")

	layer.queue_free()
	workspace.queue_free()
	await process_frame
