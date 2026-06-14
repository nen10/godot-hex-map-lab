extends "res://tests/test_editor_plugin_test_base.gd"

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	await _test_map_edit_tool_mutation_builder_and_viewport_adapter()
	await _test_map_edit_tool_builds_dock_controls()
	await _test_plugin_handles_canvas_item_when_map_edit_ready()
	await _test_editor_session_state_shares_generate_target_and_edit_document()
	await _test_map_edit_tool_auto_target_uses_selected_layer()
	await _test_map_edit_tool_auto_target_maps_hex_internal_layer_selection()
	await _test_map_edit_tool_initializes_document_from_hex_target()
	await _test_map_edit_tool_imports_generated_map_resource()
	await _test_map_edit_tool_path_file_handlers_and_action_states()
	await _test_map_edit_tool_debug_report_copy_includes_reportable_state()
	await _test_map_edit_tool_loads_saves_document_without_losing_typed_payloads()
	await _test_map_edit_tool_click_updates_document_with_undo_redo()
	await _test_map_edit_tool_forward_canvas_gui_input_uses_viewport_transform()
	await _test_map_edit_tool_target_selection_sync_for_explicit_target()
	await _test_map_edit_tool_forward_canvas_gui_input_reports_no_editable_cell()
	await _test_map_edit_tool_target_readiness_reports_plain_tile_map_layer()
	await _test_map_edit_tool_target_readiness_reports_hex_tile_map_layer_loop_state()
	await _test_map_edit_tool_preserves_plain_target_tile_settings_when_redrawing()
	await _test_map_edit_tool_target_atlas_settings_use_target_tileset()
	await _test_map_edit_tool_catalog_selectors_drive_defaults_and_payloads()
	await _test_map_edit_tool_layer_stack_screen_manages_roles()
	await _test_map_edit_tool_reports_missing_catalog_assignment_validation()
	await _test_map_edit_tool_validation_dashboard_groups_and_focuses_cell_issue()
	await _test_map_edit_tool_debug_report_includes_validation_summary_without_status_bloat()
	await _test_map_edit_tool_target_status_reports_tileset_and_overlay_payload()
	await _test_map_edit_tool_last_edit_trace_distinguishes_document_and_redraw()
	await _test_map_edit_tool_last_edit_trace_reports_target_apply_failure()
	await _test_map_edit_tool_persistence_checkpoint_reports_save_and_export_counts()
	await _test_map_edit_tool_local_hit_uses_hex_tile_map_layer()
	await _test_map_edit_tool_hex_target_uses_command_apply_path()
	await _test_map_edit_tool_hex_tile_payload_modes_change_display()
	await _test_map_edit_tool_overlay_tile_payload_changes_hex_display()
	await _test_map_edit_tool_keeps_tile_payloads_per_mode()
	await _test_map_edit_tool_object_and_label_payloads_change_hex_display()
	await _test_map_edit_tool_forward_canvas_gui_input_edits_loop_visual_duplicate()
	await _test_map_edit_tool_undo_redo_preserves_loop_visual_identity()
	await _test_map_edit_tool_mode_specific_payload_controls()
	_finish("res://tests/test_editor_map.gd")

func _test_map_edit_tool_mutation_builder_and_viewport_adapter() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var edit = HexMapEditMutationBuilder.build_document_edit(
		document,
		HexVector.zero(),
		HexMapEditTool.EditMode.WALL_FLOOR,
		{},
		"",
		{},
		{},
		HexMapEditTool.EDIT_MODE_NAMES
	)
	_assert_true(not edit.is_empty(), "mutation builder creates document edit")
	_assert_true(
		not HexMapDocumentAdapter.to_map_resource(edit["before"]).to_map_data().has_wall(HexVector.zero()),
		"mutation builder document edit captures before state"
	)
	_assert_true(
		HexMapDocumentAdapter.to_map_resource(edit["after"]).to_map_data().has_wall(HexVector.zero()),
		"mutation builder document edit captures after state"
	)
	_assert_eq(edit["mode"], "Wall / Floor", "mutation builder stores mode name")

	var tile_payload = {
		"source_id": 2,
		"atlas_coords": Vector2i(3, 4),
		"alternative_tile": 1,
		"catalog_key": "",
	}
	var before_state = {
		"hex": HexVector.zero(),
		"exists": true,
		"wall": false,
		"tile_overrides": [],
		"overlay_tiles": [],
		"objects": [],
		"labels": [],
	}
	var floor_command = HexMapEditMutationBuilder.build_hex_tile_map_layer_edit_command(
		before_state,
		HexVector.zero(),
		HexMapEditTool.EditMode.FLOOR_TILE,
		tile_payload,
		"",
		{},
		{},
		HexMapEditTool.EDIT_MODE_NAMES
	)
	_assert_true(not floor_command.is_empty(), "mutation builder creates HexTileMapLayer command")
	var floor_after: Dictionary = floor_command["after"]
	_assert_eq(floor_after["tile_overrides"].size(), 1, "mutation builder adds floor tile override")
	_assert_eq(floor_after["tile_overrides"][0]["kind"], HexMapDocumentAdapter.KIND_FLOOR, "mutation builder marks floor tile kind")
	_assert_eq(floor_after["tile_overrides"][0]["atlas_coords"], Vector2i(3, 4), "mutation builder keeps tile atlas")
	_assert_eq(floor_command["payload"], "2:(3,4):1", "mutation builder keeps payload summary")

	var missing_state = before_state.duplicate(true)
	missing_state["exists"] = false
	_assert_true(
		HexMapEditMutationBuilder.build_hex_tile_map_layer_edit_command(
			missing_state,
			HexVector.zero(),
			HexMapEditTool.EditMode.WALL_FLOOR,
			tile_payload,
			"",
			{},
			{},
			HexMapEditTool.EDIT_MODE_NAMES
		).is_empty(),
		"mutation builder blocks non-shape edits for missing cells"
	)
	var delete_command = HexMapEditMutationBuilder.build_hex_tile_map_layer_edit_command(
		{
			"hex": HexVector.zero(),
			"exists": true,
			"wall": true,
			"tile_overrides": [{"cell": Vector3i.ZERO, "kind": HexMapDocumentAdapter.KIND_WALL}],
			"overlay_tiles": [{"cell": Vector3i.ZERO, "kind": HexMapDocumentAdapter.KIND_OVERLAY}],
			"objects": [{"cell": Vector3i.ZERO, "object_id": "chest"}],
			"labels": [{"cell": Vector3i.ZERO, "label_id": "area"}],
		},
		HexVector.zero(),
		HexMapEditTool.EditMode.SHAPE,
		{},
		"",
		{},
		{},
		HexMapEditTool.EDIT_MODE_NAMES
	)
	var delete_after: Dictionary = delete_command["after"]
	_assert_true(not bool(delete_after["exists"]), "mutation builder shape delete clears existence")
	_assert_true(not bool(delete_after["wall"]), "mutation builder shape delete clears wall")
	_assert_eq(delete_after["tile_overrides"], [], "mutation builder shape delete clears tile overrides")
	_assert_eq(delete_after["overlay_tiles"], [], "mutation builder shape delete clears overlay tiles")
	_assert_eq(delete_after["objects"], [], "mutation builder shape delete clears objects")
	_assert_eq(delete_after["labels"], [], "mutation builder shape delete clears labels")

	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	_assert_true(HexMapEditViewportInputAdapter.accepts_mouse_press(press), "viewport adapter accepts left press")
	var release = InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	_assert_true(not HexMapEditViewportInputAdapter.accepts_mouse_press(release), "viewport adapter rejects release")
	var right_press = InputEventMouseButton.new()
	right_press.button_index = MOUSE_BUTTON_RIGHT
	right_press.pressed = true
	_assert_true(not HexMapEditViewportInputAdapter.accepts_mouse_press(right_press), "viewport adapter rejects non-left press")
	_assert_true(
		HexMapEditViewportInputAdapter.hit_is_editable({"exists": false}, HexMapEditTool.EditMode.SHAPE, HexMapEditTool.EditMode.SHAPE),
		"viewport adapter allows shape edits for missing cells"
	)
	_assert_true(
		not HexMapEditViewportInputAdapter.hit_is_editable({"exists": false}, HexMapEditTool.EditMode.WALL_FLOOR, HexMapEditTool.EditMode.SHAPE),
		"viewport adapter blocks non-shape edits for missing cells"
	)

	var target = Node2D.new()
	target.position = Vector2(3, 5)
	root.add_child(target)
	var trace = HexMapEditViewportInputAdapter.target_local_trace(Vector2(20, 30), Vector2(13, 17), target)
	_assert_true(bool(trace["ok"]), "viewport adapter resolves target local trace")
	_assert_vec2_approx(trace["local_position"], Vector2(10, 12), "viewport adapter converts scene to local")
	var missing_trace = HexMapEditViewportInputAdapter.target_local_trace(Vector2.ZERO, Vector2.ZERO, null)
	_assert_true(not bool(missing_trace["ok"]), "viewport adapter reports missing target")
	_assert_eq(missing_trace["status"], "No editable target layer.", "viewport adapter keeps missing target status")
	var hit = HexMapEditViewportInputAdapter.local_hit(Vector2.ZERO, null, document, 24.0)
	_assert_vector_eq(hit["hex"], HexVector.zero(), "viewport adapter fallback local hit returns origin")
	_assert_true(bool(hit["exists"]), "viewport adapter fallback local hit records document existence")
	target.queue_free()


func _test_map_edit_tool_builds_dock_controls() -> void:
	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var tile_layer = TileMapLayer.new()
	tile_layer.name = "LegacyPlainLayer"
	scene_root.add_child(tile_layer)
	var hex_layer = HexTileMapLayer.new()
	hex_layer.name = "PaintLayer"
	scene_root.add_child(hex_layer)
	await process_frame

	var tool = await _new_ready_edit_tool()
	tool.refresh_target_layer_options(scene_root)

	_assert_eq(tool.name, "Hex Map Edit", "map edit tool keeps stable standalone component name")
	_assert_true(tool is VBoxContainer, "map edit tool is a VBoxContainer for native child layout")
	_assert_true(tool.get_child_count() > 0, "map edit tool owns dock controls directly as children")
	if tool._can_use_editor_resource_picker():
		_assert_true(tool._document_resource_picker != null, "map edit tool keeps non-primary document resource picker")
	else:
		_assert_true(tool._document_browse_button != null, "map edit tool keeps non-primary document Browse fallback")
	_assert_true(tool._document_new_button != null, "map edit tool keeps non-primary New Document button")
	_assert_eq(tool._document_open_button.text, "Open...", "map edit tool keeps non-primary Open action")
	_assert_eq(tool._document_save_button.text, "Save", "map edit tool keeps non-primary Save action")
	_assert_eq(tool._document_save_as_button.text, "Save As...", "map edit tool keeps non-primary Save As action")
	_assert_eq(tool._document_validate_button.text, "Validate", "map edit tool keeps non-primary header Validate action")
	if tool._can_use_editor_resource_picker():
		_assert_true(tool._import_map_resource_picker != null, "map edit tool keeps non-primary HexMapResource import resource picker")
	else:
		_assert_true(tool._import_map_browse_button != null, "map edit tool keeps non-primary HexMapResource import Browse fallback")
	_assert_true(tool._import_map_browse_button != null, "map edit tool keeps non-primary HexMapResource import browse button")
	_assert_true(tool._import_map_button != null, "map edit tool keeps non-primary HexMapResource import button")
	_assert_true(tool._export_button != null, "map edit tool keeps non-primary map export button")
	_assert_true(tool._export_save_as_button != null, "map edit tool keeps non-primary map export save-as button")
	_assert_true(tool._document_inspector != null, "map edit tool keeps non-primary document inspector")
	_assert_true(tool._validation_dashboard != null, "map edit tool keeps hidden validation dashboard helper")
	_assert_true(tool._validation_dashboard._validate_button != null, "hidden validation dashboard keeps Validate helper button")
	_assert_true(not tool._validation_dashboard.visible, "SCREEN-23 Paint hides validation dashboard helper")
	_assert_true(tool._copy_debug_report_button != null, "map edit tool exposes debug report copy button")
	_assert_eq(tool._mode_option.item_count, HexMapEditTool.EDIT_MODE_NAMES.size(), "map edit tool lists edit modes")
	_assert_true(tool._layer_stack_template_option != null, "map edit tool keeps non-primary layer stack template picker")
	_assert_true(tool._layer_stack_role_tree != null, "map edit tool keeps non-primary layer stack role list")
	_assert_true(tool._layer_stack_create_missing_button != null, "map edit tool keeps non-primary Create Missing Layers")
	_assert_true(tool._layer_stack_apply_document_button != null, "map edit tool keeps non-primary Apply Document layer action")
	_assert_true(tool._layer_stack_clear_role_button != null, "map edit tool keeps non-primary Clear Role layer action")
	var paint_workspace = tool.paint_workspace_snapshot()
	_assert_eq(String(paint_workspace["screen_role_source"]), "HexMapPaintScreen", "ARCH-41 EditTool Paint workspace uses Paint screen script")
	_assert_eq(String(paint_workspace["workflow_owner"]), "Paint", "ARCH-41 EditTool Paint workspace names Paint owner")
	_assert_eq(String(paint_workspace["document_workflow_owner"]), "Resources", "SCREEN-21 edit tool routes document workflow to Resources")
	_assert_eq(String(paint_workspace["layer_workflow_owner"]), "Layers", "SCREEN-21 edit tool routes layer workflow to Layers")
	_assert_eq(String(paint_workspace["export_workflow_owner"]), "Export", "SCREEN-21 edit tool routes export workflow to Export")
	_assert_eq(String(paint_workspace["validation_workflow_owner"]), "Validate", "SCREEN-23 edit tool routes validation workflow to Validate")
	_assert_true(not bool(paint_workspace["document_management_visible"]), "SCREEN-21 edit tool hides document management controls")
	_assert_true(not bool(paint_workspace["layer_management_visible"]), "SCREEN-21 edit tool hides layer management controls")
	_assert_true(not bool(paint_workspace["export_management_visible"]), "SCREEN-21 edit tool hides export management controls")
	_assert_true(not bool(paint_workspace["paint_non_paint_management_visible"]), "SCREEN-21 edit tool hides non-paint management controls")
	_assert_true(not bool(paint_workspace["validation_dashboard_visible"]), "SCREEN-23 edit tool hides validation dashboard controls")
	_assert_true(not _control_row_visible(tool._document_save_button), "SCREEN-21 Paint hides document save row")
	_assert_true(not _control_row_visible(tool._document_save_as_button), "SCREEN-21 Paint hides document Save As row")
	_assert_true(not _control_row_visible(tool._import_map_button), "SCREEN-21 Paint hides import/convert row")
	_assert_true(not _control_row_visible(tool._export_button), "SCREEN-21 Paint hides export run row")
	_assert_true(not _control_row_visible(tool._export_save_as_button), "SCREEN-21 Paint hides export Save As row")
	_assert_true(not tool._layer_stack_role_tree.visible, "SCREEN-21 Paint hides layer role list")
	_assert_true(not _control_row_visible(tool._layer_stack_create_missing_button), "SCREEN-21 Paint hides Create Missing Layers row")
	_assert_true(tool._object_properties_edit != null, "map edit tool exposes object properties payload control")
	_assert_true(tool._object_definition_tree != null, "map edit tool exposes object definition list")
	_assert_true(tool._object_add_definition_button != null, "map edit tool exposes add object definition action")
	_assert_true(tool._object_palette_status_label != null, "map edit tool exposes object palette status")
	_assert_true(tool._object_property_editor != null, "map edit tool exposes typed object property editor")
	_assert_true(tool._object_rotation_spin != null, "map edit tool exposes object rotation control")
	_assert_true(tool._object_variant_edit != null, "map edit tool exposes object variant control")
	_assert_true(tool._object_variant_option != null, "map edit tool exposes object variant selector")
	_assert_true(tool._object_spawn_condition_edit != null, "map edit tool exposes object spawn condition control")
	_assert_true(tool._object_spawn_condition_option != null, "map edit tool exposes object spawn condition selector")
	_assert_true(tool._object_properties_table != null, "map edit tool exposes object property table")
	_assert_true(tool._default_floor_catalog_option != null, "map edit tool exposes default floor catalog control")
	_assert_true(tool._default_wall_catalog_option != null, "map edit tool exposes default wall catalog control")
	_assert_true(tool._tile_catalog_option != null, "map edit tool exposes tile payload catalog control")
	_assert_true(tool._object_catalog_option != null, "map edit tool exposes object catalog control")
	_assert_true(tool._default_tile_read_button != null, "map edit tool exposes default tile read button")
	_assert_true(tool._default_tile_apply_button != null, "map edit tool exposes default tile apply button")
	_assert_true(tool._target_atlas_browse_button != null, "map edit tool exposes target atlas browse button")
	_assert_true(not tool._target_atlas_path_edit.editable, "target atlas path is read-only status text")
	_assert_true(tool._target_sample_option.item_count >= 3, "map edit tool exposes sample atlas presets")
	_assert_true(tool._select_display_layer_button != null, "map edit tool exposes display layer selection")
	_assert_eq(tool._select_display_layer_button.text, "Select Internal TileMapLayer", "display layer button describes internal selection")
	_assert_true(tool._target_option.item_count >= 2, "map edit tool lists target TileMapLayer options")
	_assert_eq(tool.target_layer(), hex_layer, "map edit tool resolves Auto target to first HexTileMapLayer")
	var object_db = HexObjectDatabaseResource.new()
	var label_db = HexLabelDatabaseResource.new()
	tool.set_object_database(object_db)
	tool.set_label_database(label_db)
	_assert_eq(tool.object_database(), object_db, "map edit tool stores object database resource")
	_assert_eq(tool.label_database(), label_db, "map edit tool stores label database resource")

	scene_root.queue_free()
	tool.queue_free()
	await process_frame


func _test_plugin_handles_canvas_item_when_map_edit_ready() -> void:
	var plugin_source = FileAccess.get_file_as_string("res://addons/hex_map_kit/plugin.gd")
	var edit_tool_source = FileAccess.get_file_as_string("res://addons/hex_map_kit/editor/hex_map_edit_tool.gd")
	_assert_true(plugin_source.contains("func _handles(object: Object) -> bool:"), "plugin defines _handles for 2D viewport input")
	_assert_true(plugin_source.contains("hex_map_workspace.gd"), "plugin creates the workspace dock")
	_assert_true(plugin_source.contains("_workspace.name = \"Hex Map Workspace\""), "plugin gives workspace a stable dock name")
	_assert_true(plugin_source.contains("viewport_input_enabled"), "plugin gates viewport input through workspace")
	_assert_true(plugin_source.contains("hex_map_editor_session_state.gd"), "plugin creates shared editor session state")
	_assert_true(plugin_source.contains("set_editor_session_state"), "plugin wires shared editor session state into workspace")
	_assert_true(plugin_source.contains("selection_changed"), "NODE-21 plugin listens for Scene Tree selection changes")
	_assert_true(plugin_source.contains("set_selected_hex_tile_map_node"), "NODE-21 plugin publishes selection into workspace")
	_assert_true(plugin_source.contains("HexTileMapLayer"), "NODE-21 plugin resolves selected HexTileMap nodes")
	_assert_true(plugin_source.contains("object is CanvasItem"), "plugin handles CanvasItem viewport objects")
	_assert_true(not plugin_source.contains("_dock.name = \"Hex Map Generate\""), "plugin no longer registers a separate generation dock")
	_assert_true(
		edit_tool_source.contains("global_canvas_transform"),
		"map edit viewport conversion uses editor viewport global canvas transform"
	)
	_assert_true(
		not plugin_source.contains("get_editor_undo_redo"),
		"plugin does not wire EditorUndoRedoManager into the edit tool"
	)

	var tool = await _new_ready_edit_tool()
	var layer = TileMapLayer.new()
	root.add_child(layer)
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	tool.set_document(document)
	tool.set_target_layer(layer)

	_assert_true(tool.viewport_input_enabled(), "map edit tool enables viewport input when target and document are ready")
	tool.set_document(null)
	_assert_true(not tool.viewport_input_enabled(), "map edit tool disables viewport input without document")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_editor_session_state_shares_generate_target_and_edit_document() -> void:
	var session = HexMapEditorSessionState.new()
	var scene_root = Node2D.new()
	scene_root.name = "SessionSceneRoot"
	root.add_child(scene_root)
	var target_layer = HexTileMapLayer.new()
	target_layer.name = "SessionTarget"
	scene_root.add_child(target_layer)
	await process_frame

	var dock = await _new_ready_dock()
	dock.set_editor_session_state(session)
	dock.refresh_tile_layer_options(scene_root)
	dock._select_tile_layer_target(target_layer)
	_assert_eq(session.current_target_layer(), target_layer, "generation dock publishes selected target to session")

	var tool = await _new_ready_edit_tool()
	tool.set_editor_session_state(session)
	_assert_eq(tool.target_layer(), target_layer, "edit tool consumes session target")
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	tool.set_document(document)
	tool.set_document_path("res://session_document.tres")
	var import_resource = HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	tool.set_import_map_resource(import_resource, "res://session_import_map.tres")
	tool.set_export_path("res://session_export_map.tres")
	_assert_eq(session.current_document(), document, "edit tool publishes document to session")
	_assert_eq(session.document_source, HexMapEditTool.DOCUMENT_SOURCE_PROVIDED, "session records document source")
	_assert_eq(session.document_saved_path, "res://session_document.tres", "session records document saved path")
	_assert_eq(session.current_import_map(), import_resource, "session records import resource")
	_assert_eq(session.import_map_saved_path, "res://session_import_map.tres", "session records import map saved path")
	_assert_eq(session.export_saved_path, "res://session_export_map.tres", "session records export saved path")

	var second_tool = await _new_ready_edit_tool()
	second_tool.set_editor_session_state(session)
	_assert_eq(second_tool.target_layer(), target_layer, "later edit tool consumes existing session target")
	_assert_eq(second_tool.document(), document, "later edit tool consumes existing session document")
	_assert_eq(second_tool.document_path(), "res://session_document.tres", "later edit tool consumes existing document path")
	_assert_eq(
		second_tool.import_map_resource_selection(),
		import_resource,
		"later edit tool consumes existing import resource"
	)

	second_tool.queue_free()
	tool.queue_free()
	dock.queue_free()
	scene_root.queue_free()
	await process_frame


func _test_map_edit_tool_auto_target_uses_selected_layer() -> void:
	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var first_layer = TileMapLayer.new()
	first_layer.name = "FirstLayer"
	first_layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(first_layer.tile_set, true, Vector2i(64, 64))
	scene_root.add_child(first_layer)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "SelectedLayer"
	scene_root.add_child(selected_layer)
	await process_frame
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	selected_layer.apply_map(HexMapDocumentAdapter.to_map_resource(document))
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.refresh_target_layer_options(scene_root)
	tool.set_editor_selected_target_layer_for_test(selected_layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	_assert_eq(tool.target_layer(), selected_layer, "Auto target resolves to the editor-selected layer")
	_assert_true(tool.viewport_input_enabled(), "Auto target enables viewport input for the selected layer")
	var origin_local = selected_layer._tile_map.position + selected_layer.hex_to_display_local(HexVector.zero())
	_assert_true(tool.apply_local_position(origin_local), "Auto target edit applies to the selected layer")
	_assert_eq(selected_layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i(1, 0), "Auto target redraws selected layer")
	_assert_eq(first_layer.get_used_cells().size(), 0, "Auto target does not redraw the first layer when selection exists")
	_assert_eq(tool.last_edit_status()["target_resolution_reason"], "auto editor selection", "Last Edit records Auto selection reason")

	scene_root.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_auto_target_maps_hex_internal_layer_selection() -> void:
	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var hex_layer = HexTileMapLayer.new()
	hex_layer.name = "HexLayer"
	scene_root.add_child(hex_layer)
	await process_frame
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.refresh_target_layer_options(scene_root)

	_assert_eq(tool._target_option.item_count, 2, "target list exposes wrapper HexTileMapLayer only")
	_assert_eq(tool._target_option.get_item_text(1), "HexLayer", "target list labels HexTileMapLayer wrapper")
	tool.set_editor_selected_target_layer_for_test(hex_layer._tile_map)
	_assert_eq(tool.target_layer(), hex_layer, "Auto target maps selected internal TileMapLayer to HexTileMapLayer")
	_assert_eq(tool.last_edit_status().get("target_resolution_reason", ""), "", "fixture has no edit trace yet")
	_assert_true(tool.viewport_input_enabled(), "Auto target remains input-enabled through HexTileMapLayer wrapper")
	_assert_eq(
		tool.target_readiness_status()["target_class"],
		"HexTileMapLayer",
		"internal TileMapLayer selection reports wrapper target readiness"
	)

	scene_root.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_initializes_document_from_hex_target() -> void:
	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var data = HexMapData.rectangle(2, 1)
	var resource = HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_POINTY_TOP)
	var hex_layer = HexTileMapLayer.new()
	hex_layer.name = "RuntimeMap"
	scene_root.add_child(hex_layer)
	await process_frame
	hex_layer.hex_map = resource
	var tool = await _new_ready_edit_tool()
	tool.refresh_target_layer_options(scene_root)
	tool.set_editor_selected_target_layer_for_test(hex_layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	_assert_true(tool.document() != null, "map edit tool creates a document from selected HexTileMapLayer target")
	_assert_eq(tool._document_source, HexMapEditTool.DOCUMENT_SOURCE_TARGET, "target document source is recorded")
	_assert_eq(HexMapDocumentAdapter.to_map_resource(tool.document()).orientation, HexMapResource.ORIENTATION_POINTY_TOP, "target document preserves target map orientation")
	var readiness = tool.target_readiness_status()
	_assert_eq(String(readiness["authoring_source"]), "Level Document", "NODE-21 target readiness names Level Document as authoring source")
	_assert_true(not bool(readiness["target_hex_map_is_authoring_source"]), "NODE-21 target hex_map is not authoring source")
	_assert_true(bool(readiness["target_runtime_display_snapshot_present"]), "NODE-21 target readiness reports runtime display snapshot")
	_assert_true(
		tool._target_status_label.text.contains("authoring=Level Document") and tool._target_status_label.text.contains("runtime_snapshot=yes"),
		"NODE-21 target status text separates authoring source from runtime display snapshot"
	)
	_assert_true(tool.viewport_input_enabled(), "target-derived document enables viewport input")
	var origin_local = hex_layer._tile_map.position + hex_layer.hex_to_display_local(HexVector.zero())
	_assert_true(tool.apply_local_position(origin_local), "target-derived document accepts viewport edit")
	_assert_true(HexMapDocumentAdapter.to_map_resource(tool.document()).to_map_data().has_wall(HexVector.zero()), "target-derived document mutates on edit")
	_assert_true(hex_layer.hex_map.to_map_data().has_wall(HexVector.zero()), "target-derived edit updates HexTileMapLayer resource")
	_assert_true(tool.debug_report_text().contains("document_source: target"), "debug report includes target document source")

	scene_root.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_imports_generated_map_resource() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var resource = HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_POINTY_TOP)
	var tool = await _new_ready_edit_tool()

	var document = tool.import_map_resource(resource)
	var exported = tool.export_map_resource()

	_assert_true(document != null, "map edit tool imports generated HexMapResource into a document")
	_assert_eq(exported.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "map edit tool export preserves orientation")
	_assert_keys_eq(exported.to_map_data().cells, data.cells, "map edit tool export preserves cells")
	_assert_keys_eq(exported.to_map_data().walls, data.walls, "map edit tool export preserves walls")

	var document_path = _test_resource_path("test_map_edit_tool_document.tres")
	var export_path = _test_resource_path("test_map_edit_tool_export.tres")
	var import_path = _test_resource_path("test_map_edit_tool_import_source.tres")
	_save_resource(import_path, resource)
	_assert_true(tool.save_document(document_path), "map edit tool saves document resource")
	_assert_true(tool.export_map_resource_to_path(export_path), "map edit tool saves exported HexMapResource")
	_assert_true(tool.import_map_resource_from_path(import_path), "map edit tool imports HexMapResource from path")
	_assert_true(load(document_path) != null, "map edit tool saved document can be loaded")
	_assert_true(load(export_path) is HexMapResource, "map edit tool exported map can be loaded")

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_path_file_handlers_and_action_states() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var map_resource = HexMapResource.from_map_data(data)
	var document = HexMapDocumentAdapter.from_map_resource(map_resource)
	var document_path = _test_resource_path("test_selector_document.tres")
	var import_path = _test_resource_path("test_selector_import_map.tres")
	var export_path = _test_resource_path("test_selector_export_map.tres")
	_save_resource(document_path, document)
	_save_resource(import_path, map_resource)

	var tool = await _new_ready_edit_tool()
	_assert_true(tool._document_save_button.disabled, "Save is disabled without a document")
	_assert_true(tool._document_save_as_button.disabled, "Save As is disabled without a document")
	_assert_true(tool._document_validate_button.disabled, "header Validate is disabled without a document")
	_assert_true(tool._import_map_button.disabled, "Convert is disabled while resource is empty")
	_assert_true(tool._document_open_button != null and not tool._document_open_button.disabled, "Document Open remains enabled")
	_assert_true(tool._export_button.disabled, "Export is disabled without document")

	tool.new_document()
	_assert_true(tool.document() != null, "New Document creates a document")
	_assert_true(tool._document_label.text.contains("Document: new"), "document header shows new document state")
	_assert_true(tool._document_label.text.contains("Dirty: yes"), "document header marks new document dirty")
	_assert_true(not tool._document_save_as_button.disabled, "Save As is enabled after New Document")

	tool._on_document_file_selected(document_path)
	_assert_true(tool.document() != null, "document file selected handler loads document")
	_assert_eq(tool.document_path(), document_path, "document file selected handler syncs path")
	_assert_eq(tool._document_source, HexMapEditTool.DOCUMENT_SOURCE_LOAD, "document file selected handler records load source")
	_assert_true(tool._document_label.text.contains("Saved: " + document_path), "document header shows saved path")
	_assert_true(tool._document_label.text.contains("Dirty: no"), "document header marks loaded document clean")
	_assert_true(not tool._document_save_button.disabled, "Save is enabled after document load")
	_assert_true(not tool._document_validate_button.disabled, "header Validate is enabled after document load")

	tool._on_import_map_file_selected(import_path)
	_assert_eq(tool.import_map_path(), import_path, "import file selected handler syncs path")
	_assert_true(tool.import_map_resource_selection() is HexMapResource, "import file selected handler stores resource selection")
	_assert_eq(tool._document_source, HexMapEditTool.DOCUMENT_SOURCE_IMPORT, "import file selected handler records import source")
	_assert_true(tool._document_label.text.contains("Document: converted"), "document header shows converted document state")
	_assert_true(tool._document_label.text.contains("Dirty: yes"), "document header marks converted document dirty")
	_assert_true(not tool._export_button.disabled, "Export is enabled after import")

	tool._on_export_file_selected(export_path)
	_assert_eq(tool.export_path(), export_path, "export file selected handler syncs path")
	_assert_true(load(export_path) is HexMapResource, "export file selected handler saves HexMapResource")

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_debug_report_copy_includes_reportable_state() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var layer = TileMapLayer.new()
	layer.name = "ReportLayer"
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	root.add_child(layer)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var origin_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true))

	_assert_true(tool.apply_local_position(origin_local), "debug report fixture records an edit")
	var report = tool.debug_report_text()
	_assert_true(report.contains("Hex Map Edit Debug Report"), "debug report has a stable header")
	_assert_true(report.contains("target_status:"), "debug report includes target status")
	_assert_true(report.contains("last_edit_status:"), "debug report includes raw last edit status")
	_assert_true(report.contains("target_resolution_reason:"), "debug report includes target resolution reason")
	_assert_true(report.contains("ReportLayer"), "debug report includes target path/name context")
	_assert_true(tool.copy_debug_report_to_clipboard(), "copy debug report produces clipboard text")
	_assert_eq(tool._last_copied_debug_report, report, "copy debug report stores the exact generated report")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_loads_saves_document_without_losing_typed_payloads() -> void:
	var document = _sample_editor_document()
	var document_path = _test_resource_path("test_map_edit_document.tres")
	var saved_path = _test_resource_path("test_map_edit_saved_document.tres")
	var export_path = _test_resource_path("test_map_edit_export.tres")
	_save_resource(document_path, document)

	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	_assert_true(
		layer.ensure_display_tiles(
			HexMapTileAdapter.SAMPLE_TILE_SIZE,
			4,
			Vector2i(0, 0),
			5,
			Vector2i(1, 0)
		),
			"canonical document target display tiles are configured"
		)

	var tool = await _new_ready_edit_tool()
	tool.set_target_layer(layer)
	_assert_true(tool.load_document(document_path), "map edit tool loads canonical document from path")
	_assert_eq(layer.hex_map.to_map_data().walls.size(), 1, "canonical document load applies terrain map to HexTileMapLayer")
	var initial_state = layer.display_state_for_hex(HexVector.zero())
	_assert_eq(initial_state["overlay_count"], 1, "canonical document load applies overlay assignment")
	_assert_eq(initial_state["object_count"], 1, "canonical document load applies object placement")
	_assert_eq(initial_state["label_count"], 1, "canonical document load applies label placement")

	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	tool.set_tile_payload(0, Vector2i(2, 0), 0)
	_assert_true(tool.apply_cell(HexVector.zero()), "map edit tool edits loaded canonical document")
	_assert_eq(
		tool.document().terrain_layers[0].tile_assignments[0]["atlas_coords"],
		Vector2i(2, 0),
		"canonical document edit updates typed terrain assignment"
	)

	_assert_true(tool.save_document(saved_path), "map edit tool saves loaded canonical document")
	_assert_true(tool.export_map_resource_to_path(export_path), "map edit tool exports map from loaded canonical document")
	var saved = ResourceLoader.load(saved_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	_assert_true(saved is HexMapDocumentResource, "saved canonical document loads as document resource")
	_assert_eq(saved.terrain_layers.size(), 1, "saved document keeps typed terrain layer")
	_assert_eq(saved.overlay_layers.size(), 1, "saved document keeps typed overlay layer")
	_assert_eq(saved.object_placements.size(), 1, "saved document keeps typed object placement")
	_assert_eq(saved.label_placements.size(), 1, "saved document keeps typed label placement")
	_assert_eq(
		saved.terrain_layers[0].tile_assignments[0]["atlas_coords"],
		Vector2i(2, 0),
		"saved document keeps edited typed terrain assignment"
	)
	var exported = ResourceLoader.load(export_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	_assert_true(exported is HexMapResource, "canonical document export loads as HexMapResource")
	_assert_eq(exported.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "canonical document export preserves orientation")
	_assert_eq(exported.to_map_data().walls.size(), 1, "canonical document export preserves walls")
	var save_status = tool.persistence_status()
	_assert_eq(save_status["cell_count"], 2, "canonical document save status reports cells")
	_assert_eq(save_status["wall_count"], 1, "canonical document save status reports walls")

	tool.queue_free()
	layer.queue_free()
	await process_frame


func _test_map_edit_tool_click_updates_document_with_undo_redo() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	var undo_redo = UndoRedo.new()
	var session = HexMapEditorSessionState.new()
	session.set_debug_numeric_tile_fallback_enabled(true, "test.debug_plain_target")
	var tool = await _new_ready_edit_tool()
	tool.set_editor_session_state(session)
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_undo_redo(undo_redo)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	var origin_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true))
	_assert_true(tool.apply_local_position(origin_local), "map edit tool applies local click to document")
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "map edit tool click toggles wall in document")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "map edit tool click redraws wall tile")

	undo_redo.undo()
	_assert_true(not HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "map edit tool undo restores document")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i.ZERO, "map edit tool undo redraws floor tile")

	undo_redo.redo()
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "map edit tool redo restores document edit")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "map edit tool redo redraws wall tile")

	tool.set_edit_mode(HexMapEditTool.EditMode.SHAPE)
	var added = HexVector.q_axis().scaled(2)
	var added_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(added, true))
	_assert_true(tool.apply_local_position(added_local), "map edit tool shape mode can add a missing cell from local click")
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_cell(added), "map edit tool shape mode adds cell")

	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	tool.set_tile_payload(9, Vector2i(2, 3), 1)
	_assert_true(tool.apply_cell(HexVector.zero()), "map edit tool applies floor tile override")
	var tile_entries = HexMapDocumentAdapter.document_tile_entries(document)
	_assert_eq(tile_entries[0]["source_id"], 9, "map edit tool stores tile assignment source")
	_assert_eq(tile_entries[0]["atlas_coords"], Vector2i(2, 3), "map edit tool stores tile assignment atlas")

	tool.set_edit_mode(HexMapEditTool.EditMode.OBJECT)
	tool.set_object_payload("door", {"locked": true}, 90.0, "iron", "flag:opened")
	var property_row = tool._object_properties_table.get_root().get_first_child()
	_assert_eq(property_row.get_text(0), "locked", "map edit tool object property table shows property key")
	_assert_eq(property_row.get_text(1), "true", "map edit tool object property table shows property value")
	_assert_true(tool.apply_cell(HexVector.zero()), "map edit tool applies object payload")
	var object_entries = HexMapDocumentAdapter.document_object_entries(document)
	_assert_eq(object_entries[0]["object_id"], "door", "map edit tool stores object payload")
	_assert_eq(object_entries[0]["properties"]["locked"], true, "map edit tool stores object properties")
	_assert_eq(document.object_placements[0].object_id, "door", "map edit tool stores typed object placement")
	_assert_eq(document.object_placements[0].rotation_degrees, 90.0, "map edit tool stores typed object rotation")
	_assert_eq(document.object_placements[0].variant, "iron", "map edit tool stores typed object variant")
	_assert_eq(document.object_placements[0].spawn_condition, "flag:opened", "map edit tool stores typed object spawn condition")
	_assert_eq(document.object_placements[0].properties["locked"], true, "map edit tool stores typed object properties")

	undo_redo.undo()
	_assert_eq(document.object_placements.size(), 0, "map edit tool undo removes typed object placement")
	undo_redo.redo()
	_assert_eq(document.object_placements[0].variant, "iron", "map edit tool redo restores object variant")
	_assert_eq(document.object_placements[0].properties["locked"], true, "map edit tool redo restores object properties")

	tool.set_edit_mode(HexMapEditTool.EditMode.LABEL)
	tool.set_label_payload("room", "Entry")
	_assert_true(tool.apply_cell(HexVector.zero()), "map edit tool applies label payload")
	var label_entries = HexMapDocumentAdapter.document_label_entries(document)
	_assert_eq(label_entries[0]["label_id"], "room", "map edit tool stores label payload")
	_assert_eq(label_entries[0]["text"], "Entry", "map edit tool stores label text")

	undo_redo.clear_history()
	undo_redo.free()
	layer.free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_forward_canvas_gui_input_uses_viewport_transform() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var layer = TileMapLayer.new()
	layer.position = Vector2(30.0, 18.0)
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	root.add_child(layer)
	var session = HexMapEditorSessionState.new()
	session.set_debug_numeric_tile_fallback_enabled(true, "test.debug_plain_target")
	var tool = await _new_ready_edit_tool()
	tool.set_editor_session_state(session)
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var canvas_transform = Transform2D(0.0, Vector2(120.0, -40.0))
	tool.set_viewport_canvas_transform_for_test(canvas_transform)
	var origin_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true))
	var scene_position = layer.to_global(origin_local)
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = canvas_transform * scene_position

	_assert_true(tool.forward_canvas_gui_input(press), "map edit tool accepts viewport click through transform bridge")
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "viewport click toggles wall in document")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "viewport click redraws target layer")
	_assert_true(bool(tool.last_edit_status().get("applied", false)), "viewport click records target redraw status")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_target_selection_sync_for_explicit_target() -> void:
	var scene_root = Node2D.new()
	root.add_child(scene_root)
	var first_layer = HexTileMapLayer.new()
	first_layer.name = "FirstLayer"
	scene_root.add_child(first_layer)
	var second_layer = HexTileMapLayer.new()
	second_layer.name = "SecondLayer"
	scene_root.add_child(second_layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.refresh_target_layer_options(scene_root)
	var before_count = tool._target_selection_sync_request_count

	tool._target_option.select(2)
	tool._on_target_selected(2)

	_assert_eq(tool.target_layer(), second_layer, "explicit target selection chooses requested layer")
	_assert_true(
		tool._target_selection_sync_request_count > before_count,
		"explicit target selection requests editor selection sync"
	)
	_assert_eq(tool._last_selection_sync_target, second_layer, "target selection sync records selected layer")
	var before_refresh_count = tool._target_selection_sync_request_count
	tool.refresh_target_layer_options(scene_root)
	_assert_eq(tool.target_layer(), second_layer, "target refresh preserves explicit selected layer")
	_assert_true(
		tool._target_selection_sync_request_count > before_refresh_count,
		"target refresh requests editor selection sync for preserved target"
	)

	scene_root.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_forward_canvas_gui_input_reports_no_editable_cell() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	root.add_child(layer)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var outside_local = layer.map_to_local(Vector2i(20, 20))
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = layer.to_global(outside_local)

	_assert_true(tool.forward_canvas_gui_input(press), "viewport click outside document is consumed by edit tool")
	_assert_eq(tool._status_label.text, "No editable cell.", "viewport click reports no editable cell")
	var origin_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true))
	var valid_press = InputEventMouseButton.new()
	valid_press.button_index = MOUSE_BUTTON_LEFT
	valid_press.pressed = true
	valid_press.position = layer.to_global(origin_local)
	_assert_true(tool.forward_canvas_gui_input(valid_press), "valid viewport click still works after an invalid click")
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "valid click after invalid click edits document")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_target_readiness_reports_plain_tile_map_layer() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	var session = HexMapEditorSessionState.new()
	session.set_debug_numeric_tile_fallback_enabled(true, "test.debug_plain_target")
	var tool = await _new_ready_edit_tool()
	tool.set_editor_session_state(session)
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool._apply_document_to_target()

	var status = tool.target_readiness_status()
	_assert_eq(status["target_class"], "TileMapLayer", "plain target readiness reports TileMapLayer class")
	_assert_true(bool(status["tile_set_present"]), "plain target readiness reports TileSet presence")
	_assert_true(bool(status["ready"]), "plain target readiness is ready with a TileSet")
	_assert_eq(status["used_cell_count"], 2, "plain target readiness reports used cell count")
	_assert_eq(status["floor_atlas_coords"], Vector2i.ZERO, "plain target readiness reports default floor atlas")
	_assert_eq(status["wall_atlas_coords"], Vector2i(1, 0), "plain target readiness reports default wall atlas")
	_assert_true(tool._target_status_label.text.contains("TileMapLayer"), "plain target readiness appears in Dock detail")

	layer.free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_target_readiness_reports_hex_tile_map_layer_loop_state() -> void:
	var resource = HexMapResource.from_map_data(HexMapData.square(3, true))
	var document = HexMapDocumentAdapter.from_map_resource(resource)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.floor_source_id = 4
	layer.floor_atlas_coords = Vector2i(2, 0)
	layer.wall_source_id = 5
	layer.wall_atlas_coords = Vector2i(3, 0)
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	layer.apply_map(resource)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)

	var status = tool.target_readiness_status()
	_assert_eq(status["target_class"], "HexTileMapLayer", "hex target readiness reports HexTileMapLayer class")
	_assert_true(bool(status["is_hex_tile_map_layer"]), "hex target readiness marks HexTileMapLayer")
	_assert_true(bool(status["tile_set_present"]), "hex target readiness reports internal TileSet presence")
	_assert_eq(status["floor_source_id"], 4, "hex target readiness reports floor source id")
	_assert_eq(status["floor_atlas_coords"], Vector2i(2, 0), "hex target readiness reports floor atlas")
	_assert_eq(status["wall_source_id"], 5, "hex target readiness reports wall source id")
	_assert_eq(status["wall_atlas_coords"], Vector2i(3, 0), "hex target readiness reports wall atlas")
	_assert_eq(status["loop_display_mode"], HexTileMapLayer.LOOP_DISPLAY_TORIC, "hex target readiness reports loop mode")
	_assert_true(tool._target_status_label.text.contains("loop=toric"), "hex target readiness appears in Dock detail")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_preserves_plain_target_tile_settings_when_redrawing() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	var image = Image.create(256, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture = ImageTexture.create_from_image(image)
	HexMapTileAdapter.configure_atlas_tile_set(
		layer.tile_set,
		texture,
		true,
		Vector2i(64, 64),
		0,
		[Vector2i(2, 0), Vector2i(3, 0)]
	)
	HexMapTileAdapter.apply_to_tile_map_layer(
		layer,
		data,
		0,
		Vector2i(2, 0),
		0,
		Vector2i(3, 0),
		true,
		true
	)
	root.add_child(layer)
	var session = HexMapEditorSessionState.new()
	session.set_debug_numeric_tile_fallback_enabled(true, "test.debug_plain_target")
	var tool = await _new_ready_edit_tool()
	tool.set_editor_session_state(session)
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	var readiness = tool.target_readiness_status()
	_assert_eq(readiness["floor_atlas_coords"], Vector2i(2, 0), "map edit infers plain target floor atlas")
	_assert_eq(readiness["wall_atlas_coords"], Vector2i(3, 0), "map edit infers plain target wall atlas")
	var origin_map_cell = HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true)
	var origin_local = layer.map_to_local(origin_map_cell)

	_assert_true(tool.apply_local_position(origin_local), "map edit redraws using inferred target tile settings")
	_assert_eq(
		layer.get_cell_atlas_coords(origin_map_cell),
		Vector2i(3, 0),
		"map edit redraw changes clicked floor to target wall atlas"
	)
	var trace = tool.last_edit_status()
	_assert_eq(trace["display_atlas_before"], Vector2i(2, 0), "last edit trace records inferred floor atlas before edit")
	_assert_eq(trace["display_atlas_after"], Vector2i(3, 0), "last edit trace records inferred wall atlas after edit")
	_assert_true(bool(trace["display_changed"]), "last edit trace detects display change with inferred tile settings")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_target_atlas_settings_use_target_tileset() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var hex_layer = HexTileMapLayer.new()
	root.add_child(hex_layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(hex_layer)
	hex_layer.floor_source_id = 0
	hex_layer.floor_atlas_coords = Vector2i.ZERO
	hex_layer.wall_source_id = 0
	hex_layer.wall_atlas_coords = Vector2i(1, 0)

	_assert_true(
		tool._apply_target_atlas_path(
			"res://addons/hex_map_kit/assets/tactics_flat_top_hex_tiles_64x57_10.png",
			Vector2i(64, 57)
		),
		"map edit tool applies sample atlas to target TileSet"
	)
	var tile_set = hex_layer.display_tile_set()
	_assert_true(tile_set.has_source(0), "target atlas setup creates source on HexTileMapLayer TileSet")
	_assert_eq(tile_set.tile_size, Vector2i(64, 57), "target atlas setup stores tile size on Target TileSet")
	_assert_eq(HexMapDocumentAdapter.document_tile_entries(document).size(), 0, "target atlas setup does not write asset data into document tile assignments")
	tool._apply_document_to_target()
	_assert_eq(hex_layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i.ZERO, "target atlas setup draws floor atlas after apply")

	var replacement = TileSet.new()
	_assert_true(tool._apply_target_tile_set(replacement), "map edit tool accepts explicit Target TileSet resource")
	_assert_eq(hex_layer.display_tile_set(), replacement, "explicit Target TileSet is stored on HexTileMapLayer display layer")

	hex_layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_catalog_selectors_drive_defaults_and_payloads() -> void:
	var tool = await _new_ready_edit_tool()
	_assert_true(tool.tile_catalog() != null, "map edit tool loads sample tile catalog")
	_assert_true(tool._catalog_entries_tree != null, "map edit tool keeps non-primary catalog entry list")
	_assert_true(tool._catalog_add_atlas_button != null, "map edit tool keeps non-primary Add Atlas Entry action")
	_assert_true(tool._catalog_add_scene_button != null, "map edit tool keeps non-primary Add Scene Entry action")
	_assert_true(tool._catalog_validate_button != null, "map edit tool keeps non-primary Validate Catalog action")
	_assert_true(not bool(tool.paint_brush_snapshot()["catalog_entry_management_visible"]), "SCREEN-20 Paint hides catalog entry management controls")
	_assert_eq(
		String(tool.paint_brush_snapshot()["catalog_entry_workflow_owner"]),
		"Catalog",
		"SCREEN-20 Paint points catalog editing to Catalog"
	)
	var catalog_rows = tool.catalog_entry_rows()
	_assert_true(catalog_rows.size() >= 3, "catalog screen lists sample catalog entries")
	var floor_row = _catalog_row_for_key(catalog_rows, "terrain.floor")
	_assert_eq(floor_row["type"], HexTileCatalogEntry.TYPE_ATLAS, "catalog row shows atlas entry type")
	_assert_true(String(floor_row["preview"]).begins_with("tile "), "catalog row shows atlas preview")
	_assert_eq(floor_row["status"], "ok", "catalog row shows clean entry status")
	var summary = tool.catalog_validation_summary()
	_assert_eq(summary["errors"], 0, "catalog validation summary starts clean")
	_assert_eq(summary["warnings"], 0, "catalog validation summary starts without warnings")

	var packed_scene = PackedScene.new()
	var scene_root = Node2D.new()
	_assert_eq(packed_scene.pack(scene_root), OK, "test PackedScene packs for catalog scene entry")
	tool._on_catalog_scene_changed(packed_scene)
	var catalog_entry_count = tool.tile_catalog().entries.size()
	tool._on_add_catalog_scene_entry_pressed()
	var scene_entry = tool.tile_catalog().entries[catalog_entry_count]
	_assert_eq(scene_entry.entry_type, HexTileCatalogEntry.TYPE_SCENE, "Add Scene Entry creates scene catalog entry")
	_assert_eq(scene_entry.scene, packed_scene, "scene catalog entry stores PackedScene resource")
	scene_root.free()

	tool._on_add_catalog_atlas_entry_pressed()
	_assert_eq(tool.tile_catalog().entries.size(), catalog_entry_count + 2, "Add Atlas Entry appends catalog entry")
	tool._on_validate_catalog_pressed()
	var updated_rows = tool.catalog_entry_rows()
	var added_scene_row = _catalog_row_for_key(updated_rows, scene_entry.key)
	_assert_eq(added_scene_row["type"], HexTileCatalogEntry.TYPE_SCENE, "catalog rows include newly added scene entry")
	_assert_true(tool._default_floor_catalog_option.item_count >= 2, "map edit tool default floor catalog lists sample entries")
	_assert_true(tool._default_wall_catalog_option.item_count >= 2, "map edit tool default wall catalog lists sample entries")

	tool._select_catalog_option_by_key(tool._default_floor_catalog_option, "terrain.floor")
	tool._on_default_floor_catalog_selected(tool._default_floor_catalog_option.selected)
	tool._select_catalog_option_by_key(tool._default_wall_catalog_option, "terrain.wall")
	tool._on_default_wall_catalog_selected(tool._default_wall_catalog_option.selected)
	var defaults = tool._default_tile_settings_from_controls()
	_assert_eq(defaults["floor_catalog_key"], "terrain.floor", "default floor selector stores catalog key")
	_assert_eq(defaults["floor_atlas_coords"], Vector2i(0, 0), "default floor selector resolves atlas coords")
	_assert_eq(defaults["wall_catalog_key"], "terrain.wall", "default wall selector stores catalog key")
	_assert_eq(defaults["wall_atlas_coords"], Vector2i(1, 0), "default wall selector resolves atlas coords")

	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	tool._select_catalog_option_by_key(tool._tile_catalog_option, "terrain.floor")
	tool._on_tile_catalog_selected(tool._tile_catalog_option.selected)
	_assert_eq(tool._floor_tile_payload["catalog_key"], "terrain.floor", "floor tile payload stores catalog key")
	_assert_eq(tool._floor_tile_payload["atlas_coords"], Vector2i(0, 0), "floor tile payload resolves catalog atlas")
	_assert_true(not _control_row_visible(tool._tile_source_spin), "floor tile mode hides source id paint control")
	_assert_true(not _control_row_visible(tool._tile_atlas_x_spin), "floor tile mode hides atlas coordinate paint controls")
	_assert_true(bool(tool.paint_brush_snapshot()["catalog_key_selector_visible"]), "SCREEN-20 Paint shows catalog key selector for brush selection")
	_assert_true(bool(tool.paint_brush_snapshot()["paint_consumes_catalog_key"]), "SCREEN-20 Paint consumes catalog key after selection")
	_assert_true(
		not bool(tool.paint_brush_snapshot()["raw_catalog_metadata_controls_primary"]),
		"SCREEN-20 Paint keeps raw catalog metadata non-primary after selection"
	)

	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_TILE)
	tool._select_catalog_option_by_key(tool._tile_catalog_option, "terrain.wall")
	tool._on_tile_catalog_selected(tool._tile_catalog_option.selected)
	_assert_eq(tool._wall_tile_payload["catalog_key"], "terrain.wall", "wall tile payload stores catalog key")
	_assert_eq(tool._wall_tile_payload["atlas_coords"], Vector2i(1, 0), "wall tile payload resolves catalog atlas")

	tool.set_edit_mode(HexMapEditTool.EditMode.OVERLAY_TILE)
	tool._select_catalog_option_by_key(tool._tile_catalog_option, "overlay.treasure")
	tool._on_tile_catalog_selected(tool._tile_catalog_option.selected)
	_assert_eq(tool._overlay_tile_payload["catalog_key"], "overlay.treasure", "overlay tile payload stores catalog key")

	tool.set_edit_mode(HexMapEditTool.EditMode.OBJECT)
	tool._select_catalog_option_by_key(tool._object_catalog_option, "object.spawn_marker")
	tool._on_object_catalog_selected(tool._object_catalog_option.selected)
	_assert_eq(tool._object_payload["object_id"], "object.spawn_marker", "object selector stores catalog key as object default")
	_assert_eq(tool._object_id_edit.text, "object.spawn_marker", "object selector updates object id text")
	_assert_true(not _control_row_visible(tool._object_id_edit), "object mode hides raw object id paint control")

	var invalid_catalog = HexTileCatalogResource.new()
	invalid_catalog.catalog_id = "broken"
	invalid_catalog.display_name = "Broken Catalog"
	var invalid_entry = HexTileCatalogEntry.new()
	invalid_entry.key = "broken.scene"
	invalid_entry.display_name = "Broken Scene"
	invalid_entry.entry_type = HexTileCatalogEntry.TYPE_SCENE
	invalid_catalog.add_entry(invalid_entry)
	tool.set_tile_catalog(invalid_catalog)
	tool._on_validate_catalog_pressed()
	var catalog_issue_rows = tool._validation_dashboard.issue_rows()
	var scene_issue_index := -1
	for index in range(catalog_issue_rows.size()):
		if String(catalog_issue_rows[index].get("rule_id", "")) == "catalog.scene_missing":
			scene_issue_index = index
			break
	_assert_true(scene_issue_index >= 0, "validation dashboard lists catalog scene issue")
	var scene_issue_row = catalog_issue_rows[scene_issue_index]
	_assert_eq(scene_issue_row.get("domain", ""), "Catalog", "catalog issue row is grouped by Catalog domain")
	_assert_eq(scene_issue_row.get("severity_label", ""), "Error", "catalog issue row exposes severity label")
	_assert_true(String(scene_issue_row.get("focus_target", "")).contains("Catalog entry"), "catalog issue row exposes entry focus target")
	_assert_true(String(scene_issue_row.get("fix_suggestion", "")).contains("PackedScene"), "catalog issue row exposes fix suggestion")
	_assert_true(tool.select_validation_issue(scene_issue_index), "catalog validation issue can be selected")
	var catalog_focus = tool.validation_focus_status()
	_assert_eq(catalog_focus.get("focus_type", ""), "catalog_entry", "catalog issue selection records catalog focus type")
	_assert_eq(int(catalog_focus.get("catalog_entry_index", -1)), 0, "catalog issue selection records entry index")
	_assert_true(bool(catalog_focus.get("focused", false)), "catalog issue selection focuses catalog row")
	_assert_true(tool._validation_dashboard._selected_detail_label.text.contains("Fix:"), "selected issue detail shows fix suggestion")

	tool.queue_free()
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


func _test_map_edit_tool_reports_missing_catalog_assignment_validation() -> void:
	var data = HexMapData.rectangle(1, 1)
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_tile_override(document, HexVector.zero(), {
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 8,
		"atlas_coords": Vector2i(4, 5),
	})
	var layer = TileMapLayer.new()
	layer.name = "CatalogFallbackLayer"
	root.add_child(layer)
	await process_frame

	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool._validation_dashboard._validate_button.pressed.emit()
	var rows = tool._validation_dashboard.issue_rows()
	var has_missing_assignment := false
	for row in rows:
		if String(row.get("rule_id", "")) == "document.tile_assignment_missing":
			has_missing_assignment = true
	_assert_true(has_missing_assignment, "validation dashboard reports missing catalog assignment")
	var report = tool.debug_report_text()
	_assert_true(not report.contains("catalog_warning_count"), "debug report omits compatibility warning count")
	_assert_true(report.contains("document.tile_assignment_missing"), "debug report includes validation rule id")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_validation_dashboard_groups_and_focuses_cell_issue() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_label(document, HexVector.apply_basis(4, 0, 0), {
		"label_id": "outside",
		"text": "Outside",
	})
	HexMapDocumentAdapter.set_object(document, HexVector.q_axis(), {"object_id": "chest"})
	var hex_layer = HexTileMapLayer.new()
	hex_layer.name = "ValidationLayer"
	root.add_child(hex_layer)
	await process_frame
	hex_layer.apply_map(HexMapDocumentAdapter.to_map_resource(document))

	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(hex_layer)
	tool._validation_dashboard._validate_button.pressed.emit()

	var summary = tool.validation_dashboard_summary()
	_assert_true(int(summary.get("errors", 0)) >= 2, "validation dashboard reports error count")
	_assert_true(int(summary.get("groups", 0)) >= 2, "validation dashboard groups validation rows")
	var inspector_summary = tool.document_inspector_summary()
	_assert_true(int(inspector_summary["validation"].get("errors", 0)) >= 2, "document inspector mirrors validation error count")
	_assert_true(tool._document_inspector._validation_summary_label.text.contains("errors="), "document inspector shows validation summary")
	var rows = tool._validation_dashboard.issue_rows()
	_assert_true(rows.size() >= 2, "validation dashboard exposes issue rows")
	_assert_true(String(rows[0].get("group_key", "")).contains("/"), "validation issue row stores grouped key")
	_assert_true(tool._validation_dashboard._summary_label.text.contains("errors="), "validation summary label includes error count")

	var wall_issue_index := -1
	for index in range(rows.size()):
		if String(rows[index].get("rule_id", "")) == "document.object_on_wall":
			wall_issue_index = index
			break
	_assert_true(wall_issue_index >= 0, "validation dashboard lists object-on-wall issue")
	var wall_row = rows[wall_issue_index]
	_assert_eq(wall_row.get("domain", ""), "Object", "object issue row is grouped by Object domain")
	_assert_eq(wall_row.get("severity_label", ""), "Error", "object issue row exposes severity label")
	_assert_true(String(wall_row.get("focus_target", "")).contains("Cell"), "object issue row exposes cell focus target")
	_assert_true(String(wall_row.get("fix_suggestion", "")).contains("floor"), "object issue row exposes fix suggestion")
	_assert_true(tool.select_validation_issue(wall_issue_index), "validation dashboard selects a cell-scoped issue")
	var selected = tool.selected_validation_issue()
	var focus = tool.validation_focus_status()
	_assert_eq(selected.get("rule_id", ""), "document.object_on_wall", "selected validation issue records rule id")
	_assert_eq(focus.get("domain", ""), "Object", "validation issue focus records domain")
	_assert_eq(focus.get("focus_type", ""), "cell", "validation issue focus records cell focus type")
	_assert_eq(focus.get("cell", Vector3i.ZERO), Vector3i(1, 0, 0), "validation issue focus records selected cell")
	_assert_eq(focus.get("cell_key", ""), HexVector.q_axis().key(), "validation issue focus records cell key")
	_assert_eq(bool(focus.get("focused", false)), true, "validation issue focus marks existing cell focused")
	var paint_state = tool.paint_interaction_state_snapshot()
	var paint_view_state = paint_state["view_state"] as Dictionary
	var paint_active_states := PackedStringArray(paint_state["active_state_ids"])
	_assert_true(paint_active_states.has(HexMapPaintInteractionState.STATE_VALIDATION_FOCUS), "STATE-40 Paint state covers validation focus")
	_assert_eq(String((paint_view_state["validation_focus"] as Dictionary)["focus_type"]), "cell", "STATE-40 Paint ViewState renders validation focus")
	_assert_eq(String(paint_view_state["hovered_cell_key"]), HexVector.q_axis().key(), "STATE-40 Paint ViewState renders focused cell as hovered cell state")
	_assert_true(hex_layer._highlights.has(HexVector.q_axis().key()), "cell-scoped validation issue highlights HexTileMapLayer target")
	_assert_true(tool._validation_dashboard._selected_detail_label.text.contains("Fix:"), "selected cell issue detail shows fix suggestion")

	hex_layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_debug_report_includes_validation_summary_without_status_bloat() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_object(document, HexVector.q_axis(), {"object_id": "chest"})
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.validate_document_now()

	var report = tool.debug_report_text()
	_assert_true(report.contains("validation_summary:"), "edit debug report includes validation summary")
	_assert_true(report.contains("validation_issues:"), "edit debug report includes validation issue rows")
	_assert_true(report.contains("document.object_on_wall"), "edit debug report includes validation rule id")
	_assert_true(
		not tool._target_status_label.text.contains("document.object_on_wall"),
		"target status label does not include validation issue dump"
	)

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_target_status_reports_tileset_and_overlay_payload() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var hex_layer = HexTileMapLayer.new()
	root.add_child(hex_layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(hex_layer)
	tool.set_overlay_tile_payload("Treasure", 4, Vector2i(2, 0), 1)
	_assert_true(
		tool._apply_target_atlas_path(
			"res://addons/hex_map_kit/assets/tactics_flat_top_hex_tiles_64x57_10.png",
			Vector2i(64, 57)
		),
		"target status test configures target atlas"
	)
	var status = tool.target_readiness_status()
	_assert_true(bool(status["tile_set_present"]), "target status reports TileSet presence")
	_assert_true(int(status["tile_set_source_count"]) >= 1, "target status reports source count")
	_assert_eq(status["tile_size"], Vector2i(64, 57), "target status reports tile size")
	_assert_eq(status["overlay_item_key"], "Treasure", "target status reports overlay item key")
	_assert_eq(status["overlay_source_id"], 4, "target status reports overlay payload source")
	_assert_true(status.has("overlay_tile_visible"), "target status reports overlay visibility")
	_assert_true(tool._target_status_label.text.contains("overlay=Treasure"), "target status label includes overlay payload")

	hex_layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_last_edit_trace_distinguishes_document_and_redraw() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	root.add_child(layer)
	var session = HexMapEditorSessionState.new()
	session.set_debug_numeric_tile_fallback_enabled(true, "test.debug_plain_target")
	var tool = await _new_ready_edit_tool()
	tool.set_editor_session_state(session)
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	tool._apply_document_to_target()
	var origin_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true))
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = layer.to_global(origin_local)

	_assert_true(tool.forward_canvas_gui_input(press), "last edit trace accepts viewport click")
	var trace = tool.last_edit_status()
	_assert_true(bool(trace["document_changed"]), "last edit trace records document mutation")
	_assert_true(bool(trace["target_applied"]), "last edit trace records target apply")
	_assert_true(bool(trace["display_changed"]), "last edit trace records display tile change")
	_assert_true(not bool(trace["wall_before"]), "last edit trace records previous floor state")
	_assert_true(bool(trace["wall_after"]), "last edit trace records next wall state")
	_assert_eq(trace["display_atlas_before"], Vector2i.ZERO, "last edit trace records floor atlas before edit")
	_assert_eq(trace["display_atlas_after"], Vector2i(1, 0), "last edit trace records wall atlas after edit")
	_assert_eq(trace["target_used_cells_before"], 2, "last edit trace records used cells before edit")
	_assert_eq(trace["target_used_cells_after"], 2, "last edit trace records used cells after edit")
	_assert_true(tool._last_edit_detail_label.text.contains("document=yes"), "last edit trace appears in Dock detail")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_last_edit_trace_reports_target_apply_failure() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	_assert_true(tool.apply_cell(HexVector.zero()), "last edit trace mutates document without a target")
	var trace = tool.last_edit_status()
	_assert_true(bool(trace["document_changed"]), "target failure trace records document mutation")
	_assert_true(not bool(trace["target_applied"]), "target failure trace records target apply failure")
	_assert_true(not bool(trace["display_changed"]), "target failure trace keeps display unchanged")
	_assert_eq(trace["display_atlas_before"], Vector2i(-1, -1), "target failure trace has no display atlas before")
	_assert_eq(trace["display_atlas_after"], Vector2i(-1, -1), "target failure trace has no display atlas after")
	_assert_true(tool._last_edit_detail_label.text.contains("target=no"), "target failure trace appears in Dock detail")

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_persistence_checkpoint_reports_save_and_export_counts() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	var document_path = _test_resource_path("test_map_edit_visibility_document.tres")
	var export_path = _test_resource_path("test_map_edit_visibility_export.tres")

	_assert_true(tool.save_document(document_path), "persistence checkpoint saves document")
	var save_status = tool.persistence_status()
	_assert_eq(save_status["operation"], "save_document", "persistence checkpoint records save operation")
	_assert_eq(save_status["path"], document_path, "persistence checkpoint records save path")
	_assert_true(bool(save_status["ok"]), "persistence checkpoint records save success")
	_assert_eq(save_status["resource_class"], "HexMapDocumentResource", "persistence checkpoint records document class")
	_assert_eq(save_status["cell_count"], 2, "persistence checkpoint records save cell count")
	_assert_eq(save_status["wall_count"], 1, "persistence checkpoint records save wall count")

	_assert_true(tool.export_map_resource_to_path(export_path), "persistence checkpoint exports map")
	var export_status = tool.persistence_status()
	_assert_eq(export_status["operation"], "export_map", "persistence checkpoint records export operation")
	_assert_eq(export_status["path"], export_path, "persistence checkpoint records export path")
	_assert_true(bool(export_status["ok"]), "persistence checkpoint records export success")
	_assert_eq(export_status["resource_class"], "HexMapResource", "persistence checkpoint records export class")
	_assert_eq(export_status["cell_count"], 2, "persistence checkpoint records export cell count")
	_assert_eq(export_status["wall_count"], 1, "persistence checkpoint records export wall count")
	_assert_true(tool._persistence_detail_label.text.contains("HexMapResource"), "persistence checkpoint appears in Dock detail")

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_local_hit_uses_hex_tile_map_layer() -> void:
	var data = HexMapData.square(3, true)
	var resource = HexMapResource.from_map_data(data)
	var document = HexMapDocumentAdapter.from_map_resource(resource)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	layer.apply_map(resource)
	await process_frame

	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var wrapped_visual = HexVector.apply_basis(3, 0, 0)
	var hit_local = layer._tile_map.position + layer.hex_to_display_local(wrapped_visual)

	_assert_true(tool.apply_local_position(hit_local), "map edit tool uses HexTileMapLayer loop-aware hit")
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "map edit tool edits canonical toric cell from visual duplicate")
	_assert_true(layer.hex_map.to_map_data().has_wall(HexVector.zero()), "map edit tool updates HexTileMapLayer hex_map resource")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_hex_target_uses_command_apply_path() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var layer = CountingHexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var undo_redo = UndoRedo.new()
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_undo_redo(undo_redo)
	tool._apply_document_to_target()
	var redraw_count_after_full_apply = layer.redraw_count
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	_assert_true(tool.apply_cell(HexVector.zero()), "Hex target edit uses command apply path")
	_assert_eq(layer.apply_document_cell_count, 0, "Hex target edit does not call apply_document_cell")
	_assert_eq(layer.redraw_count, redraw_count_after_full_apply, "Hex target edit does not call full redraw")
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "Hex target command updates document")
	_assert_true(layer.is_wall(HexVector.zero()), "Hex target command updates target state")

	undo_redo.undo()
	_assert_eq(layer.apply_document_cell_count, 0, "Hex target undo does not call apply_document_cell")
	_assert_eq(layer.redraw_count, redraw_count_after_full_apply, "Hex target undo does not call full redraw")
	_assert_true(not HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "Hex target command undo updates document")
	_assert_true(layer.is_floor(HexVector.zero()), "Hex target command undo restores target state")

	undo_redo.redo()
	_assert_eq(layer.apply_document_cell_count, 0, "Hex target redo does not call apply_document_cell")
	_assert_eq(layer.redraw_count, redraw_count_after_full_apply, "Hex target redo does not call full redraw")
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "Hex target command redo updates document")
	_assert_true(layer.is_wall(HexVector.zero()), "Hex target command redo restores target state")

	undo_redo.clear_history()
	undo_redo.free()
	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_hex_tile_payload_modes_change_display() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool._apply_document_to_target()
	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	tool.set_tile_payload(0, Vector2i(1, 0), 0)

	_assert_true(tool.apply_cell(HexVector.zero()), "floor tile mode applies payload to HexTileMapLayer")
	_assert_eq(HexMapDocumentAdapter.document_tile_entries(document).size(), 1, "floor tile mode stores a document tile assignment")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i(1, 0), "floor tile mode redraws HexTileMapLayer tile")
	var trace = tool.last_edit_status()
	_assert_true(bool(trace["display_changed"]), "floor tile mode Last Edit records display change")
	_assert_eq(trace["display_renderer_after"], "HexTileMapLayer", "floor tile mode Last Edit records Hex renderer")
	_assert_true(tool._last_edit_detail_label.text.contains("payload=0:(1,0):0"), "floor tile mode Last Edit includes payload")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_overlay_tile_payload_changes_hex_display() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool._apply_document_to_target()
	tool.set_edit_mode(HexMapEditTool.EditMode.OVERLAY_TILE)
	tool.set_overlay_tile_payload("Treasure", 0, Vector2i(1, 0), 0)

	_assert_true(tool.apply_cell(HexVector.zero()), "overlay tile mode applies payload to HexTileMapLayer")
	var overlay_entries = HexMapDocumentAdapter.document_tile_entries(document)
	_assert_eq(overlay_entries.size(), 1, "overlay tile mode stores a document tile assignment")
	_assert_eq(overlay_entries[0]["kind"], HexMapDocumentAdapter.KIND_OVERLAY, "overlay tile mode stores overlay kind")
	_assert_eq(overlay_entries[0]["item_key"], "Treasure", "overlay tile mode stores item key")
	var map_cell = HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true)
	_assert_eq(layer._overlay_tile_map.get_cell_atlas_coords(map_cell), Vector2i(1, 0), "overlay tile mode draws overlay tile")
	var state = layer.display_state_for_hex(HexVector.zero())
	_assert_eq(state["overlay_count"], 1, "overlay tile mode exposes overlay count")
	var trace = tool.last_edit_status()
	_assert_true(bool(trace["display_changed"]), "overlay tile mode Last Edit records display change")
	_assert_eq(trace["display_overlay_count_after"], 1, "overlay tile mode Last Edit records overlay count")
	_assert_eq(trace["target_apply_reason"], "Applied overlay tile to HexTileMapLayer.", "overlay tile mode uses overlay apply reason")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_keeps_tile_payloads_per_mode() -> void:
	var tool = await _new_ready_edit_tool()
	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	tool._select_catalog_option_by_key(tool._tile_catalog_option, "terrain.floor")
	tool._on_tile_catalog_selected(tool._tile_catalog_option.selected)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_TILE)
	tool._select_catalog_option_by_key(tool._tile_catalog_option, "terrain.wall")
	tool._on_tile_catalog_selected(tool._tile_catalog_option.selected)
	tool.set_edit_mode(HexMapEditTool.EditMode.OVERLAY_TILE)
	tool._select_catalog_option_by_key(tool._tile_catalog_option, "overlay.treasure")
	tool._on_tile_catalog_selected(tool._tile_catalog_option.selected)

	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	_assert_eq(tool._floor_tile_payload["catalog_key"], "terrain.floor", "floor tile mode preserves floor catalog key")
	_assert_eq(tool._floor_tile_payload["atlas_coords"], Vector2i.ZERO, "floor tile mode preserves floor catalog atlas")

	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_TILE)
	_assert_eq(tool._wall_tile_payload["catalog_key"], "terrain.wall", "wall tile mode preserves wall catalog key")
	_assert_eq(tool._wall_tile_payload["atlas_coords"], Vector2i(1, 0), "wall tile mode preserves wall catalog atlas")

	tool.set_edit_mode(HexMapEditTool.EditMode.OVERLAY_TILE)
	_assert_eq(tool._overlay_tile_payload["catalog_key"], "overlay.treasure", "overlay tile mode preserves overlay catalog key")
	_assert_true(_control_row_visible(tool._overlay_item_key_option), "overlay tile mode shows known item key option")

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_object_and_label_payloads_change_hex_display() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool._apply_document_to_target()
	tool.set_edit_mode(HexMapEditTool.EditMode.OBJECT)
	tool.set_object_payload("chest")

	_assert_true(tool.apply_cell(HexVector.zero()), "object mode applies payload to HexTileMapLayer")
	var object_state = layer.display_state_for_hex(HexVector.zero())
	_assert_eq(object_state["object_count"], 1, "object mode exposes Hex object marker state")
	_assert_true(bool(tool.last_edit_status()["display_changed"]), "object mode Last Edit records marker display change")
	_assert_eq(tool.last_edit_status()["display_marker_count_after"], 1, "object mode Last Edit records marker count")

	tool.set_edit_mode(HexMapEditTool.EditMode.LABEL)
	tool.set_label_payload("area", "North")
	_assert_true(tool.apply_cell(HexVector.zero()), "label mode applies payload to HexTileMapLayer")
	var label_state = layer.display_state_for_hex(HexVector.zero())
	_assert_eq(label_state["label_count"], 1, "label mode exposes Hex label marker state")
	_assert_eq(label_state["marker_count"], 2, "label mode keeps object and label markers visible")
	_assert_true(bool(tool.last_edit_status()["display_changed"]), "label mode Last Edit records marker display change")
	_assert_eq(tool.last_edit_status()["display_marker_count_before"], 1, "label mode Last Edit records marker count before")
	_assert_eq(tool.last_edit_status()["display_marker_count_after"], 2, "label mode Last Edit records marker count after")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_forward_canvas_gui_input_edits_loop_visual_duplicate() -> void:
	var data = HexMapData.square(3, true)
	var resource = HexMapResource.from_map_data(data)
	var document = HexMapDocumentAdapter.from_map_resource(resource)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var duplicate_visual = HexVector.apply_basis(-3, 0, 0)
	layer.hex_size = 10.0
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	layer.loop_display_rect = Rect2(layer.hex_to_display_local(duplicate_visual) - Vector2.ONE, Vector2(2, 2))
	layer.apply_map(resource)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = layer.to_global(layer._tile_map.position + layer.hex_to_display_local(duplicate_visual))
	var duplicate_map_cell = HexMapTileAdapter.vector_to_map_cell(duplicate_visual, true)

	_assert_true(tool.forward_canvas_gui_input(press), "map edit tool edits loop visual duplicate via viewport input")
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "loop visual duplicate edits canonical document cell")
	_assert_eq(
		layer._loop_tile_map.get_cell_atlas_coords(duplicate_map_cell),
		layer.wall_atlas_coords,
		"map edit tool refreshes duplicate tile after viewport edit"
	)
	_assert_true(layer._highlights.has(HexVector.zero().key()), "map edit tool highlights last edited canonical cell")
	_assert_vector_eq(tool.last_edit_status()["hex"], HexVector.zero(), "last edit status stores canonical hex")
	_assert_vector_eq(tool.last_edit_status()["visual_hex"], duplicate_visual, "last edit status stores visual hex")
	_assert_true(
		tool.apply_local_position(layer._tile_map.position + layer.hex_to_display_local(HexVector.q_axis())),
		"map edit tool accepts a second loop target edit"
	)
	_assert_eq(layer._highlights.size(), 1, "map edit tool keeps only one last-edit highlight")
	_assert_true(not layer._highlights.has(HexVector.zero().key()), "map edit tool clears previous last-edit highlight")
	_assert_true(layer._highlights.has(HexVector.q_axis().key()), "map edit tool highlights the newest canonical cell")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_undo_redo_preserves_loop_visual_identity() -> void:
	var data = HexMapData.square(3, true)
	var resource = HexMapResource.from_map_data(data)
	var document = HexMapDocumentAdapter.from_map_resource(resource)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var duplicate_visual = HexVector.apply_basis(-3, 0, 0)
	layer.hex_size = 10.0
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	layer.loop_display_rect = Rect2(layer.hex_to_display_local(duplicate_visual) - Vector2.ONE, Vector2(2, 2))
	layer.apply_map(resource)
	var tool = await _new_ready_edit_tool()
	var undo_redo = UndoRedo.new()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_undo_redo(undo_redo)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var duplicate_map_cell = HexMapTileAdapter.vector_to_map_cell(duplicate_visual, true)
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = layer.to_global(layer._tile_map.position + layer.hex_to_display_local(duplicate_visual))

	_assert_true(tool.forward_canvas_gui_input(press), "loop visual duplicate edit is undoable")
	undo_redo.undo()
	_assert_true(not HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "undo restores canonical document floor")
	_assert_eq(
		layer._loop_tile_map.get_cell_atlas_coords(duplicate_map_cell),
		layer.floor_atlas_coords,
		"undo restores duplicate floor tile"
	)
	undo_redo.redo()
	_assert_true(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), "redo restores canonical document wall")
	_assert_eq(
		layer._loop_tile_map.get_cell_atlas_coords(duplicate_map_cell),
		layer.wall_atlas_coords,
		"redo restores duplicate wall tile"
	)

	undo_redo.clear_history()
	undo_redo.free()
	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_mode_specific_payload_controls() -> void:
	var tool = await _new_ready_edit_tool()

	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	_assert_true(not _control_row_visible(tool._tile_catalog_option), "wall/floor mode hides tile catalog control")
	_assert_true(not _control_row_visible(tool._object_id_edit), "wall/floor mode hides object payload controls")
	_assert_true(not _control_row_visible(tool._label_id_edit), "wall/floor mode hides label payload controls")

	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	_assert_true(_control_row_visible(tool._tile_catalog_option), "floor tile mode shows tile catalog control")
	_assert_true(not _control_row_visible(tool._object_id_edit), "floor tile mode hides object payload controls")

	tool.set_edit_mode(HexMapEditTool.EditMode.OVERLAY_TILE)
	_assert_true(_control_row_visible(tool._tile_catalog_option), "overlay tile mode shows tile catalog control")
	_assert_true(not _control_row_visible(tool._overlay_item_key_edit), "overlay tile mode hides raw item key control")
	_assert_true(_control_row_visible(tool._overlay_item_key_option), "overlay tile mode shows item key selector")
	_assert_true(not _control_row_visible(tool._object_id_edit), "overlay tile mode hides object payload controls")

	tool.set_edit_mode(HexMapEditTool.EditMode.OBJECT)
	_assert_true(_control_row_visible(tool._object_catalog_option), "object mode shows object catalog key control")
	_assert_true(not _control_row_visible(tool._object_id_edit), "object mode hides raw object id control")
	_assert_true(_control_row_visible(tool._object_definition_tree), "object mode shows object definition list")
	_assert_true(_control_row_visible(tool._object_property_editor), "object mode shows typed object property editor")
	_assert_true(not _control_row_visible(tool._object_properties_edit), "object mode hides raw object properties text")
	_assert_true(_control_row_visible(tool._object_rotation_spin), "object mode shows object rotation control")
	_assert_true(not _control_row_visible(tool._object_variant_edit), "object mode hides raw object variant control")
	_assert_true(_control_row_visible(tool._object_variant_option), "object mode shows object variant selector")
	_assert_true(not _control_row_visible(tool._object_spawn_condition_edit), "object mode hides raw spawn condition control")
	_assert_true(_control_row_visible(tool._object_spawn_condition_option), "object mode shows spawn condition selector")
	_assert_true(not _control_row_visible(tool._object_properties_table), "object mode hides raw object property table")
	_assert_true(not _control_row_visible(tool._tile_catalog_option), "object mode hides tile catalog control")

	tool.set_edit_mode(HexMapEditTool.EditMode.LABEL)
	_assert_true(not _control_row_visible(tool._label_id_edit), "label mode hides raw label id control")
	_assert_true(_control_row_visible(tool._label_definition_tree), "label mode shows label definition list")
	_assert_true(_control_row_visible(tool._label_text_edit), "label mode shows label text control")
	_assert_true(not _control_row_visible(tool._object_id_edit), "label mode hides object payload controls")

	tool.queue_free()
	await process_frame


