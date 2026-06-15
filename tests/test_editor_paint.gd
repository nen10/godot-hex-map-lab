extends "res://tests/test_editor_plugin_test_base.gd"

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	await _test_paint_brush_asset_screen_routes_missing_assets_without_raw_controls()
	_finish("res://tests/test_editor_paint.gd")

func _test_paint_brush_asset_screen_routes_missing_assets_without_raw_controls() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var terrain_mode = workspace.select_paint_brush_mode("terrain")
	_assert_true(bool(terrain_mode["ok"]), "Paint brush screen selects terrain mode")
	var brush = (terrain_mode["brush"] as Dictionary)
	var paint_screen = workspace.paint_brush_screen_snapshot()
	_assert_eq(PackedStringArray(paint_screen["asset_slot_ids"]), PackedStringArray(), "TAB-51 Paint brush screen does not expose ResourcePicker asset rows")
	_assert_eq(String(paint_screen["screen_role_source"]), "HexMapPaintScreen", "ARCH-41 Paint snapshot uses Paint screen script")
	_assert_eq(String(paint_screen["screen_script"]), "hex_map_paint_screen.gd", "ARCH-41 Paint snapshot names screen script")
	_assert_eq(String(paint_screen["first_surface"]), "paint_workspace", "SCREEN-31 Paint opens on workspace surface")
	_assert_true(bool(paint_screen["paint_workspace_is_primary"]), "SCREEN-31 Paint workspace is primary")
	_assert_true(not bool(paint_screen["resource_row_primary"]), "SCREEN-31 Paint does not lead with a Resource row")
	_assert_true(bool(paint_screen["context_chips_visible"]), "SCREEN-31 Paint shows context chips")
	var paint_context_chips = paint_screen["context_chips"] as Array
	for chip in paint_context_chips:
		_assert_true(String((chip as Dictionary).get("label", "")) != "Map", "RESCTX-42 Paint context chips do not duplicate global Map")
	_assert_true(bool(paint_screen["brush_palette_visible"]), "SCREEN-31 Paint shows brush palette")
	_assert_true(bool(paint_screen["brush_shape_controls_visible"]), "SCREEN-31 Paint shows brush shape controls")
	var shape_controls = paint_screen["brush_shape_controls"] as Dictionary
	var shape_modes = shape_controls["modes"] as PackedStringArray
	_assert_true(shape_modes.has("single"), "SCREEN-31 Paint shape controls include single")
	_assert_true(shape_modes.has("line"), "SCREEN-31 Paint shape controls include line")
	_assert_true(shape_modes.has("disc"), "SCREEN-31 Paint shape controls include disc")
	_assert_true(shape_modes.has("flood"), "SCREEN-31 Paint shape controls include flood")
	_assert_true(bool(paint_screen["empty_cta_visible"]), "SCREEN-31 Paint empty state exposes document CTA")
	var empty_cta = paint_screen["empty_cta"] as Dictionary
	_assert_eq(String(empty_cta["primary_action"]), "Create Level Document", "SCREEN-31 Paint empty CTA creates document")
	var paint_role = paint_screen["screen_role"] as Dictionary
	var paint_delegates = paint_role["delegates"] as Dictionary
	_assert_eq(String(paint_delegates["document_management"]), "Resources", "ARCH-41 Paint delegates document management")
	_assert_eq(String(paint_delegates["catalog_entry_management"]), "Catalog", "ARCH-41 Paint delegates catalog management")
	_assert_eq(String(paint_screen["paint_surface_owner"]), "Paint", "SCREEN-22 Paint screen owns brush surface")
	_assert_true(bool(paint_screen["paint_surface_visible"]), "SCREEN-22 Paint screen shows surface summary")
	_assert_true(bool(paint_screen["empty_state_visible"]), "SCREEN-22 Paint screen exposes empty state before setup")
	_assert_true(bool(paint_screen["active_brush_visible"]), "SCREEN-22 Paint screen exposes active brush state")
	_assert_true(bool(paint_screen["target_layer_summary_visible"]), "SCREEN-22 Paint screen exposes target layer state")
	_assert_true(bool(paint_screen["selected_cell_summary_visible"]), "SCREEN-22 Paint screen exposes selected cell state")
	_assert_true(bool(paint_screen["last_edit_summary_visible"]), "SCREEN-22 Paint screen exposes last edit state")
	_assert_true(not bool(paint_screen["viewport_edit_updates_paint_state"]), "SCREEN-22 Paint screen starts before viewport edit state")
	_assert_true(not bool(paint_screen["resource_reference_only"]), "SCREEN-22 Paint screen is not resource-reference-only")
	_assert_true(PackedStringArray(paint_screen["paint_context_sections"]).has("active_brush"), "SCREEN-22 Paint context includes active brush")
	_assert_true(PackedStringArray(paint_screen["paint_context_sections"]).has("last_edit"), "SCREEN-22 Paint context includes last edit")
	var paint_affordance = paint_screen["paint_affordance_board"] as Dictionary
	_assert_eq(String(paint_affordance["surface_id"]), "paint_affordance_board", "PAINT-NEXT-10 Paint exposes affordance board")
	_assert_true(bool(paint_screen["paint_affordance_visible"]), "PAINT-NEXT-10 mounted Paint affordance board is visible")
	_assert_true((paint_affordance["rows"] as Array).size() >= 5, "PAINT-NEXT-10 Paint affordance board has cursor/mode/target/cell/edit rows")
	_assert_true(not bool(paint_affordance["primary_path_text_visible"]), "PAINT-NEXT-10 Paint affordance board keeps paths out of primary text")
	_assert_true(String(paint_screen["mounted_paint_affordance_text"]).contains("Cursor:"), "PAINT-NEXT-10 mounted Paint affordance text names cursor")
	_assert_eq(String(paint_screen["document_workflow_owner"]), "Resources", "SCREEN-21 Paint screen routes document workflow to Resources")
	_assert_true(not bool(paint_screen["document_management_visible"]), "SCREEN-21 Paint screen hides document management")
	_assert_eq(String(paint_screen["layer_workflow_owner"]), "Layers", "SCREEN-21 Paint screen routes layer workflow to Layers")
	_assert_true(not bool(paint_screen["layer_management_visible"]), "SCREEN-21 Paint screen hides layer management")
	_assert_eq(String(paint_screen["export_workflow_owner"]), "Export", "SCREEN-21 Paint screen routes export workflow to Export")
	_assert_true(not bool(paint_screen["export_management_visible"]), "SCREEN-21 Paint screen hides export management")
	_assert_true(not bool(paint_screen["paint_non_paint_management_visible"]), "SCREEN-21 Paint screen hides non-paint workflow management")
	_assert_eq(String(paint_screen["validation_workflow_owner"]), "Validate", "SCREEN-23 Paint screen routes validation workflow to Validate")
	_assert_true(not bool(paint_screen["validation_dashboard_visible"]), "SCREEN-23 Paint screen hides validation dashboard")
	var picker_rows = paint_screen["resource_picker_rows_visible"] as Dictionary
	_assert_true(not bool(picker_rows["object_database"]), "TAB-51 Paint hides Object Database ResourcePicker row")
	_assert_true(not bool(picker_rows["label_database"]), "TAB-51 Paint hides Label Database ResourcePicker row")
	_assert_eq(brush["mode"], "terrain", "Paint brush snapshot reports terrain mode")
	_assert_true(not bool(brush["ready"]), "Paint brush terrain is not ready without catalog")
	var cta = brush["missing_asset_cta"] as Dictionary
	_assert_eq(cta["target_tab"], "Catalog", "Paint brush missing terrain catalog points to Catalog tab")
	_assert_eq(cta["target_component_id"], "catalog_asset_panel", "Paint brush missing terrain catalog points to catalog panel")
	_assert_eq(cta["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "Paint brush missing terrain catalog points to tile catalog slot")
	var paint_state = paint_screen["interaction_state"] as Dictionary
	var paint_view_state = paint_screen["view_state"] as Dictionary
	var paint_active_states := PackedStringArray(paint_state["active_state_ids"])
	_assert_eq(String(paint_state["state_source"]), "HexMapPaintInteractionState", "STATE-40 Paint screen reports state source")
	_assert_eq(String(paint_view_state["state_source"]), "HexMapPaintInteractionState", "STATE-40 Paint screen reports ViewState source")
	_assert_true(paint_active_states.has(HexMapPaintInteractionState.STATE_NO_TARGET), "STATE-40 Paint state covers missing target")
	_assert_true(paint_active_states.has(HexMapPaintInteractionState.STATE_NO_DOCUMENT), "STATE-40 Paint state covers missing document")
	_assert_true(paint_active_states.has(HexMapPaintInteractionState.STATE_MISSING_ASSET), "STATE-40 Paint state covers missing asset")
	_assert_true(not bool(paint_view_state["can_paint"]), "STATE-40 Paint ViewState blocks painting when setup is incomplete")
	_assert_eq(String((paint_view_state["missing_asset"] as Dictionary)["target_tab"]), "Catalog", "STATE-40 Paint ViewState routes missing asset")

	var controls = brush["normal_internal_controls_visible"] as Dictionary
	_assert_true(not bool(controls["source_id"]), "Paint brush hides source id control")
	_assert_true(not bool(controls["atlas_x"]), "Paint brush hides atlas x control")
	_assert_true(not bool(controls["atlas_y"]), "Paint brush hides atlas y control")
	_assert_true(not bool(controls["raw_overlay_item_key"]), "Paint brush hides raw overlay item key control")
	_assert_true(not bool(controls["raw_object_id"]), "Paint brush hides raw object id control")
	_assert_true(not bool(controls["raw_object_variant"]), "Paint brush hides raw object variant control")
	_assert_true(not bool(controls["raw_spawn_condition"]), "Paint brush hides raw spawn condition control")
	_assert_true(not bool(controls["raw_label_id"]), "Paint brush hides raw label id control")
	_assert_eq(String(brush["catalog_entry_workflow_owner"]), "Catalog", "SCREEN-20 Paint declares Catalog owns entry workflow")
	_assert_true(not bool(brush["catalog_entry_management_visible"]), "SCREEN-20 Paint hides catalog entry management controls")
	_assert_true(bool(brush["paint_consumes_catalog_key"]), "SCREEN-20 Paint consumes catalog keys")
	_assert_true(not bool(brush["raw_catalog_metadata_controls_primary"]), "SCREEN-20 Paint keeps raw catalog metadata non-primary")
	_assert_eq(String(paint_screen["catalog_entry_workflow_owner"]), "Catalog", "SCREEN-20 Paint screen points catalog management to Catalog")
	_assert_true(not bool(paint_screen["catalog_entry_management_visible"]), "SCREEN-20 Paint screen hides catalog entry management")

	var output_dir = _test_resource_dir("screen24_paint_brush")
	var catalog_path = "%s/tile_catalog.tres" % output_dir
	var catalog_result = workspace.create_tile_catalog(catalog_path)
	_assert_true(bool(catalog_result["ok"]), "Paint brush test creates project Tile Catalog")
	var tile_set := _test_catalog_tileset()
	_assert_true(bool(workspace.set_catalog_tile_set(tile_set)["ok"]), "Paint brush test assigns TileSet")
	_assert_true(
		bool(workspace.create_catalog_atlas_entry_from_tileset("terrain.floor", tile_set, 0, Vector2i.ZERO)["ok"]),
		"Paint brush test creates catalog key"
	)
	var terrain_brush = workspace.select_paint_catalog_brush_key("terrain.floor", "terrain")
	_assert_true(bool(terrain_brush["ok"]), "Paint brush selects terrain catalog key")
	brush = terrain_brush["brush"] as Dictionary
	_assert_true(bool(brush["ready"]), "Paint brush terrain is ready with selected catalog key")
	_assert_eq(brush["brush_key"], "terrain.floor", "Paint brush terrain reports catalog key")
	paint_screen = workspace.paint_brush_screen_snapshot()
	paint_view_state = paint_screen["view_state"] as Dictionary
	_assert_true(bool((paint_view_state["brush"] as Dictionary)["ready"]), "STATE-40 Paint ViewState renders active ready brush")
	_assert_eq(String(paint_view_state["brush_key"]), "terrain.floor", "STATE-40 Paint ViewState renders active brush key")
	var brush_palette = paint_screen["brush_palette"] as Dictionary
	_assert_eq(String(brush_palette["active_brush_key"]), "terrain.floor", "SCREEN-31 Paint brush palette shows catalog key")
	_assert_true(bool(brush_palette["ready"]), "SCREEN-31 Paint brush palette reflects ready brush")

	var overlay_brush = workspace.select_paint_catalog_brush_key("terrain.floor", "overlay")
	_assert_true(bool(overlay_brush["ok"]), "Paint brush selects overlay catalog key")
	brush = overlay_brush["brush"] as Dictionary
	_assert_eq(brush["mode"], "overlay", "Paint brush snapshot reports overlay mode")
	_assert_true(bool(brush["ready"]), "Paint brush overlay is ready with selected catalog key")

	var object_mode = workspace.select_paint_brush_mode("object")
	_assert_true(bool(object_mode["ok"]), "Paint brush screen selects object mode")
	brush = object_mode["brush"] as Dictionary
	_assert_true(not bool(brush["ready"]), "Paint brush object is not ready without object database")
	cta = brush["missing_asset_cta"] as Dictionary
	_assert_eq(cta["target_tab"], "Resources", "TAB-51 Paint brush missing object points to Resources")
	_assert_eq(cta["target_component_id"], "document_asset_panel", "TAB-51 Paint brush missing object points to Resources asset panel")
	_assert_eq(cta["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE, "Paint brush missing object points to object database slot")
	paint_screen = workspace.paint_brush_screen_snapshot()
	picker_rows = paint_screen["resource_picker_rows_visible"] as Dictionary
	_assert_true(not bool(picker_rows["object_database"]), "TAB-51 Paint object mode still hides Object Database ResourcePicker row")

	var object_db_result = workspace.create_object_database("%s/object_database.tres" % output_dir)
	_assert_true(bool(object_db_result["ok"]), "Paint brush test creates project Object Database")
	var marker := Node2D.new()
	var scene := PackedScene.new()
	_assert_eq(scene.pack(marker), OK, "test PackedScene packs for paint brush object")
	marker.free()
	_assert_true(
		bool(workspace.create_object_definition_from_packed_scene("object.spawn", scene, "Spawn")["ok"]),
		"Paint brush test creates object definition"
	)
	var object_select = workspace.select_object_definition("object.spawn")
	_assert_true(bool(object_select["ok"]), "Paint brush selects object definition")
	brush = (workspace.paint_brush_screen_snapshot()["brush"] as Dictionary)
	_assert_true(bool(brush["ready"]), "Paint brush object is ready with selected definition")
	_assert_eq(brush["brush_key"], "object.spawn", "Paint brush object reports definition id")

	var label_mode = workspace.select_paint_brush_mode("label")
	_assert_true(bool(label_mode["ok"]), "Paint brush screen selects label mode")
	brush = label_mode["brush"] as Dictionary
	_assert_true(not bool(brush["ready"]), "Paint brush label is not ready without label database")
	cta = brush["missing_asset_cta"] as Dictionary
	_assert_eq(cta["target_tab"], "Resources", "TAB-51 Paint brush missing label points to Resources")
	_assert_eq(cta["target_component_id"], "document_asset_panel", "TAB-51 Paint brush missing label points to Resources asset panel")
	_assert_eq(cta["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE, "Paint brush missing label points to label database slot")
	paint_screen = workspace.paint_brush_screen_snapshot()
	picker_rows = paint_screen["resource_picker_rows_visible"] as Dictionary
	_assert_true(not bool(picker_rows["label_database"]), "TAB-51 Paint label mode still hides Label Database ResourcePicker row")

	var label_db_result = workspace.create_label_database("%s/label_database.tres" % output_dir)
	_assert_true(bool(label_db_result["ok"]), "Paint brush test creates project Label Database")
	_assert_true(
		bool(workspace.create_label_definition("label.spawn", "Spawn Label", "Spawn", "map")["ok"]),
		"Paint brush test creates label definition"
	)
	var label_select = workspace.select_label_definition("label.spawn")
	_assert_true(bool(label_select["ok"]), "Paint brush selects label definition")
	brush = (workspace.paint_brush_screen_snapshot()["brush"] as Dictionary)
	_assert_true(bool(brush["ready"]), "Paint brush label is ready with selected definition")
	_assert_eq(brush["brush_key"], "label.spawn", "Paint brush label reports definition id")
	_assert_true(not bool(brush["zone_mode_available"]), "Paint brush reports zone mode as deferred")

	var zone_mode = workspace.select_paint_brush_mode("zone")
	_assert_true(not bool(zone_mode["ok"]), "Paint brush rejects zone mode until document mutation exists")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Paint brush actions do not enable sample mode")

	var paint_document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var paint_layer = HexTileMapLayer.new()
	paint_layer.name = "PaintAffordanceTarget"
	root.add_child(paint_layer)
	await process_frame
	var edit_tool = workspace.edit_tool()
	edit_tool.set_document(paint_document)
	edit_tool.set_target_layer(paint_layer)
	edit_tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	edit_tool._apply_document_to_target()
	var origin_local = paint_layer._tile_map.position + paint_layer.hex_to_display_local(HexVector.zero())
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = paint_layer.to_global(origin_local)
	_assert_true(edit_tool.forward_canvas_gui_input(press), "PAINT-NEXT-10 workspace Paint viewport click is accepted")
	paint_screen = workspace.paint_brush_screen_snapshot()
	paint_affordance = paint_screen["paint_affordance_board"] as Dictionary
	var cursor_feedback = paint_screen["brush_cursor_feedback"] as Dictionary
	_assert_eq(String(cursor_feedback["status"]), "selected", "PAINT-NEXT-10 Paint cursor feedback tracks selected viewport cell")
	_assert_eq(String(cursor_feedback["cell_key"]), HexVector.zero().key(), "PAINT-NEXT-10 Paint cursor feedback stores edited cell")
	var mode_feedback = paint_affordance["mode"] as Dictionary
	_assert_eq(String(mode_feedback["mode_id"]), "shape", "PAINT-NEXT-10 Paint mode feedback stores shape mode")
	_assert_true(bool(mode_feedback["ready"]), "PAINT-NEXT-10 Paint mode feedback is ready for shape edit")
	var target_feedback = paint_affordance["target"] as Dictionary
	_assert_eq(String(target_feedback["name"]), "PaintAffordanceTarget", "PAINT-NEXT-10 Paint target feedback names target layer")
	_assert_true(bool(target_feedback["ready"]), "PAINT-NEXT-10 Paint target feedback is ready")
	var viewport_sync = paint_screen["viewport_sync"] as Dictionary
	_assert_eq(String(viewport_sync["active_layer_name"]), "PaintAffordanceTarget", "SCREEN-31 Paint viewport sync tracks active layer")
	_assert_eq(String(viewport_sync["selected_cell_key"]), HexVector.zero().key(), "SCREEN-31 Paint viewport sync tracks selected cell")
	_assert_true(String(viewport_sync["last_edit_summary"]).contains("painted 1 cell on PaintAffordanceTarget"), "SCREEN-31 Paint viewport sync reports last edit in user terms")
	var selected_feedback = paint_affordance["selected_cell"] as Dictionary
	_assert_eq(String(selected_feedback["cell_key"]), HexVector.zero().key(), "PAINT-NEXT-10 Paint selected-cell feedback follows viewport edit")
	var last_feedback = paint_affordance["last_edit"] as Dictionary
	_assert_true(bool(last_feedback["document_changed"]), "PAINT-NEXT-10 Paint last-edit feedback reports document change")
	_assert_true(bool(last_feedback["target_applied"]), "PAINT-NEXT-10 Paint last-edit feedback reports target apply")
	_assert_true(bool(last_feedback["display_changed"]), "PAINT-NEXT-10 Paint last-edit feedback reports display change")
	_assert_true(String(paint_screen["mounted_paint_affordance_text"]).contains(HexVector.zero().key()), "PAINT-NEXT-10 mounted affordance text follows viewport cell")
	_assert_true(paint_layer._highlights.has(HexVector.zero().key()), "PAINT-NEXT-10 viewport highlight matches Paint selected cell")

	paint_layer.queue_free()
	workspace.queue_free()
	await process_frame
