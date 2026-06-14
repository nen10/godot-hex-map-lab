extends "res://tests/test_editor_plugin_test_base.gd"

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	await _test_document_asset_screen_manages_project_document_without_samples()
	await _test_document_inspector_component_summarizes_document_and_validation()
	_finish("res://tests/test_editor_document.gd")

func _test_document_asset_screen_manages_project_document_without_samples() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var snapshot = workspace.document_screen_snapshot()
	_assert_eq(String(snapshot["tab"]), "Resources", "TAB-50 document snapshot now represents Resources tab")
	_assert_eq(String(snapshot["document_workflow_owner"]), "Resources", "SCREEN-21 Resources owns document workflow")
	_assert_true(bool(snapshot["document_management_visible"]), "SCREEN-21 Resources exposes document management")
	_assert_eq(String(snapshot["document_save_dependency_dirty_owner"]), "Resources", "SCREEN-21 Resources owns save/dependency/dirty state")
	_assert_true(bool(snapshot["dependency_hydration_visible"]), "SCREEN-21 Resources exposes dependency hydration state")
	_assert_true(bool(snapshot["dirty_state_visible"]), "SCREEN-21 Resources exposes dirty state")
	_assert_true(not bool(snapshot["paint_document_management_visible"]), "SCREEN-21 Paint does not own document management")
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("document_asset_panel"),
		"TAB-50 Resources screen exposes resource asset component"
	)
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("resources_context_panel"),
		"TAB-50 Resources screen exposes context component"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT),
		"TAB-50 Resources screen exposes level document slot"
	)
	_assert_true(
		PackedStringArray(snapshot["dependency_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG),
		"Document screen exposes catalog dependency slot"
	)
	_assert_true(
		PackedStringArray(snapshot["dependency_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK),
		"TAB-50 Resources screen exposes layer stack dependency slot"
	)
	var resources_selected = snapshot["selected_hex_tile_map"] as Dictionary
	_assert_eq(String(resources_selected["status_text"]), "No HexTileMap selected", "TAB-50 Resources screen shows selected HexTileMap state")
	var resource_groups = snapshot["resource_groups"] as Array
	var groups_by_id := {}
	for group in resource_groups:
		groups_by_id[String(group["group_id"])] = group
	_assert_true(groups_by_id.has("unique"), "TAB-50 Resources screen exposes UniqueResource group")
	_assert_true(groups_by_id.has("shared"), "TAB-50 Resources screen exposes SharedResource group")
	_assert_true(groups_by_id.has("optional"), "TAB-50 Resources screen exposes OptionalResource group")
	_assert_true(
		String((groups_by_id["unique"] as Dictionary)["tooltip"]).contains("Level Document"),
		"TAB-50 UniqueResource tooltip explains resource purpose"
	)
	_assert_true(
		String((groups_by_id["unique"] as Dictionary)["status_text"]).contains("0/2 ready"),
		"SCREEN-10 Resources unique group exposes readiness count"
	)
	_assert_true(
		((groups_by_id["optional"] as Dictionary)["slot_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE),
		"TAB-57 Resources optional group includes Movement Profile"
	)
	var selected_summary = snapshot["selected_hex_tile_map_summary"] as Dictionary
	_assert_eq(String(selected_summary["visible_text"]), "No HexTileMap selected", "SCREEN-10 Resources summary starts with no-selection state")
	_assert_true(not bool(selected_summary["node_path_visible"]), "SCREEN-10 Resources summary keeps node path out of primary text")
	var resources_visual = snapshot["resources_visual_summary"] as Dictionary
	_assert_eq(String(resources_visual["surface_id"]), "resources_readiness_board", "SCREEN-NEXT-10 Resources exposes readiness board")
	_assert_true(not bool(resources_visual["primary_path_text_visible"]), "SCREEN-NEXT-10 Resources readiness keeps paths out of primary text")
	var resources_readiness_rows = _entries_by_id(resources_visual["readiness_rows"] as Array)
	_assert_eq(String((resources_readiness_rows["selected_node"] as Dictionary)["status"]), "missing", "SCREEN-NEXT-10 Resources node readiness starts missing")
	_assert_eq(String((resources_readiness_rows["level_document"] as Dictionary)["status"]), "missing", "SCREEN-NEXT-10 Resources document readiness starts missing")
	_assert_true(String(snapshot["mounted_resources_readiness_text"]).contains("Node: Missing"), "SCREEN-NEXT-10 mounted Resources readiness label shows node state")
	_assert_true((snapshot["next_actions"] as PackedStringArray).has("Select a HexTileMap node"), "SCREEN-10 Resources next action points to node selection")
	_assert_true(bool(snapshot["clear_next_actions_beyond_resource_rows"]), "SCREEN-10 Resources exposes next actions beyond resource rows")
	var source_badge_rows = _rows_by_slot(snapshot["source_badge_rows"] as Array)
	_assert_eq(String((source_badge_rows[HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT] as Dictionary)["source_badge"]), "Missing", "SCREEN-10 Resources source badge row marks missing document")
	var source_badge_explanations = snapshot["source_badge_explanations"] as Dictionary
	_assert_true(source_badge_explanations.has("Node"), "SCREEN-10 Resources explains Node source badge")
	_assert_true(source_badge_explanations.has("Manual Override"), "SCREEN-10 Resources explains Manual Override source badge")
	_assert_eq(String(snapshot["create_missing_resources_button_text"]), "Create Missing Resources", "TAB-50 Resources screen keeps Create Missing Resources")
	_assert_eq(workspace.workspace_asset_context().level_document, null, "Document screen starts without a sample document")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Document screen starts with sample mode OFF")

	var output_dir = _test_resource_dir("screen20_document")
	var document_path = "%s/level_document.tres" % output_dir
	var create_result = workspace.create_level_document(document_path)
	_assert_true(bool(create_result["ok"]), "Document screen creates Level Document")
	_assert_true(FileAccess.file_exists(document_path), "Document screen writes created Level Document")
	var document = create_result["resource"] as HexMapDocumentResource
	_assert_true(document is HexMapDocumentResource, "Document screen create returns document resource")
	_assert_eq(workspace.workspace_asset_context().level_document, document, "created document enters workspace context")
	_assert_eq(session.current_document(), document, "created document enters editor session")
	_assert_eq(session.document_saved_path, document_path, "created document updates session saved path")
	snapshot = workspace.document_screen_snapshot()
	resources_visual = snapshot["resources_visual_summary"] as Dictionary
	resources_readiness_rows = _entries_by_id(resources_visual["readiness_rows"] as Array)
	_assert_eq(String((resources_readiness_rows["level_document"] as Dictionary)["status"]), "ready", "SCREEN-NEXT-10 Resources document readiness becomes ready")
	_assert_true(String(snapshot["mounted_resources_readiness_text"]).contains("Level Document: Ready"), "SCREEN-NEXT-10 mounted Resources readiness updates after document creation")
	_assert_eq(
		workspace.tab_asset_slot_snapshot("Document", HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT).get("current_source", ""),
		HexMapEditorAssetSlotState.SOURCE_PROJECT,
		"Document screen marks created document as project asset"
	)

	var open_result = workspace.open_level_document()
	_assert_true(bool(open_result["ok"]), "Document screen opens selected Level Document")
	_assert_eq(open_result["resource"], document, "Document screen open returns selected document")

	var save_as_path = "%s/level_document_saved_as.tres" % output_dir
	var save_result = workspace.save_level_document_as(save_as_path)
	_assert_true(bool(save_result["ok"]), "Document screen saves Level Document as project resource")
	_assert_true(FileAccess.file_exists(save_as_path), "Document screen Save As writes project resource")
	_assert_eq(document.resource_path, save_as_path, "Document screen Save As updates document resource path")
	_assert_eq(session.document_saved_path, save_as_path, "Document screen Save As updates session saved path")

	var validation = workspace.validate_level_document()
	_assert_true(validation is HexMapValidationResult, "Document screen validate returns validation result")
	_assert_true(validation.summary.has("cells"), "Document screen validation returns document summary")
	_assert_true(validation.to_dictionary().has("errors"), "Document screen validation returns issue counts")

	var clear_result = workspace.clear_level_document()
	_assert_true(bool(clear_result["ok"]), "Document screen clears Level Document")
	_assert_eq(workspace.workspace_asset_context().level_document, null, "cleared document leaves workspace context")
	_assert_eq(session.current_document(), null, "cleared document leaves editor session")
	_assert_eq(session.document_saved_path, "", "cleared document resets saved path")
	_assert_true(
		not bool(workspace.tab_asset_slot_snapshot("Document", HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT).get("selected", true)),
		"Document screen level document slot becomes unselected after clear"
	)
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Document screen actions do not enable sample mode")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "Document screen actions do not inject generation sample catalog")

	workspace.queue_free()
	await process_frame


func _test_document_inspector_component_summarizes_document_and_validation() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_object(document, HexVector.zero(), {"object_id": "marker"})
	HexMapDocumentAdapter.set_label(document, HexVector.q_axis(), {"label_id": "area", "text": "East"})

	var inspector = HexMapDocumentInspector.new()
	root.add_child(inspector)
	await process_frame
	inspector.set_document_state(document, HexMapEditTool.DOCUMENT_SOURCE_PROVIDED, "res://map.tres")
	var summary = inspector.inspector_summary()
	_assert_eq(summary["document"]["cell_count"], 2, "document inspector reports cell count")
	_assert_eq(summary["document"]["wall_count"], 1, "document inspector reports wall count")
	_assert_eq(summary["document"]["object_count"], 1, "document inspector reports object count")
	_assert_eq(summary["document"]["label_count"], 1, "document inspector reports label count")
	_assert_eq(summary["document"]["source"], HexMapEditTool.DOCUMENT_SOURCE_PROVIDED, "document inspector reports document source")
	_assert_true(inspector._document_summary_label.text.contains("cells=2"), "document inspector renders document summary")

	var result = HexMapValidationResult.new()
	result.add_error(
		"document.object_on_wall",
		"Object is on a wall.",
		HexMapValidationResult.SCOPE_CELL,
		{"cell": Vector3i(1, 0, 0)}
	)
	result.add_warning("document.optional", "Optional warning.")
	var validation_summary = HexMapDocumentInspector.validation_summary_from_result(result, {"document_present": true})
	inspector.set_validation_summary(validation_summary)
	summary = inspector.inspector_summary()
	_assert_eq(summary["validation"]["issues"], 2, "document inspector reports validation issues")
	_assert_eq(summary["validation"]["errors"], 1, "document inspector reports validation errors")
	_assert_eq(summary["validation"]["warnings"], 1, "document inspector reports validation warnings")
	_assert_true(inspector._validation_summary_label.text.contains("errors=1"), "document inspector renders validation summary")
	var rows = HexMapDocumentInspector.validation_issue_report_rows(result)
	_assert_eq(rows.size(), 2, "document inspector formats validation issue rows")
	_assert_true(rows[0].contains("document.object_on_wall"), "document inspector issue row includes rule id")
	_assert_true(rows[0].contains("cell=(1,0,0)"), "document inspector issue row includes cell")

	inspector.queue_free()
	await process_frame


