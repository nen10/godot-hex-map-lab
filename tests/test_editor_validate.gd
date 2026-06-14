extends "res://tests/test_editor_plugin_test_base.gd"

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	await _test_validate_asset_screen_reports_missing_project_assets_without_samples()
	_finish("res://tests/test_editor_validate.gd")

func _test_validate_asset_screen_reports_missing_project_assets_without_samples() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var snapshot = workspace.validate_screen_snapshot()
	_assert_eq(snapshot["purpose_text"], "Validate workspace assets and the active Level Document.", "TAB-54 Validate screen states purpose")
	_assert_true(String(snapshot["target_summary"]).contains("Level Document missing"), "TAB-54 Validate screen summarizes target readiness")
	_assert_true(bool(snapshot["navigator_component_present"]), "TAB-54 Validate snapshot confirms issue navigator component")
	_assert_eq(String(snapshot["validation_workflow_owner"]), "Validate", "SCREEN-23 Validate owns validation workflow")
	_assert_true(bool(snapshot["workflow_validate_action_visible"]), "SCREEN-23 Validate exposes workflow run action")
	_assert_eq(String(snapshot["workflow_validate_button_text"]), "Run Validation", "SCREEN-23 Validate run action is explicit")
	_assert_true(bool(snapshot["issue_navigator_visible"]), "SCREEN-23 Validate exposes issue navigator")
	_assert_true(bool(snapshot["issue_list_visible"]), "SCREEN-23 Validate exposes issue list")
	_assert_true(bool(snapshot["severity_scope_focus_visible"]), "SCREEN-23 Validate exposes severity/scope/focus state")
	_assert_true(bool(snapshot["severity_visible"]), "SCREEN-23 Validate exposes severity")
	_assert_true(bool(snapshot["scope_visible"]), "SCREEN-23 Validate exposes scope")
	_assert_true(bool(snapshot["focus_action_visible"]), "SCREEN-23 Validate exposes focus action")
	_assert_true(bool(snapshot["issue_click_routes_focus"]), "SCREEN-23 Validate issue click routes focus")
	_assert_true(not bool(snapshot["slot_level_validate_buttons_present"]), "SCREEN-23 Validate has no slot-level Validate buttons")
	_assert_true(not bool(snapshot["paint_validation_dashboard_visible"]), "SCREEN-23 Paint does not own validation dashboard")
	_assert_eq(snapshot["empty_state_text"], "Run validation to list workspace issues.", "TAB-54 Validate screen has pre-run empty state")
	var validation_state = snapshot["validation_state"] as Dictionary
	_assert_eq(String(validation_state["state_source"]), "HexMapValidationWorkflowState", "STATE-50 Validate snapshot reports state source")
	_assert_eq(String(validation_state["state_id"]), HexMapValidationWorkflowState.STATE_NOT_RUN, "STATE-50 Validate starts not run")
	_assert_eq(String((snapshot["view_state"] as Dictionary)["status_text"]), "Run validation to list workspace issues.", "STATE-50 Validate ViewState reports not-run status")
	_assert_true(not bool(snapshot["validation_progress_visible"]), "PERF-NEXT-11 Validate progress is hidden before first run")
	_assert_true(not bool(snapshot["resource_row_validate_buttons_present"]), "TAB-54 Validate keeps row-level Validate buttons absent")
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("validation_asset_panel"),
		"Validate screen exposes validation asset panel"
	)
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("validation_issue_navigator"),
		"Validate screen exposes issue navigator"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE),
		"Validate screen exposes validation suite asset slot"
	)
	_assert_true(not bool(snapshot["sample_candidates_visible"]), "Validate screen starts with sample mode OFF")

	var validate_result = workspace.run_validate_screen()
	_assert_true(bool(validate_result["ok"]), "Validate screen runs workspace validation")
	validation_state = validate_result["validation_state"] as Dictionary
	_assert_eq(String(validation_state["state_id"]), HexMapValidationWorkflowState.STATE_ERROR, "STATE-50 Validate run reports error state")
	var validation_progress_state = validate_result["validation_progress_state"] as Dictionary
	_assert_true(bool(validate_result["validation_progress_visible"]), "PERF-NEXT-11 Validate run exposes progress state")
	_assert_eq(String(validation_progress_state["phase"]), "complete", "PERF-NEXT-11 Validate run finishes progress phase")
	_assert_eq(float(validation_progress_state["progress"]), 1.0, "PERF-NEXT-11 Validate run finishes progress ratio")
	_assert_true(int(validation_progress_state["event_count"]) >= 2, "PERF-NEXT-11 Validate run records progress events")
	_assert_eq(
		String((validate_result["view_state"] as Dictionary)["progress_phase"]),
		"complete",
		"PERF-NEXT-11 Validate view state exposes progress phase"
	)
	var result = validate_result["result"] as HexMapValidationResult
	_assert_true(result is HexMapValidationResult, "Validate screen returns validation result")
	_assert_eq(result.error_count(), 5, "Validate screen reports required missing project assets as errors")
	var rows = validate_result["issue_rows"] as Array
	var issue_table = validate_result["issue_table"] as Dictionary
	var issue_columns = issue_table["columns"] as PackedStringArray
	for column in ["severity", "domain", "scope", "target", "suggestion", "actions"]:
		_assert_true(issue_columns.has(column), "VAL-NEXT-10 issue table exposes column: %s" % column)
	_assert_eq(String(issue_table["surface_id"]), "validate_issue_table", "VAL-NEXT-10 Validate exposes issue table surface")
	_assert_eq(int(issue_table["row_count"]), rows.size(), "VAL-NEXT-10 issue table row count matches issue rows")
	_assert_true(bool(issue_table["real_actions_only"]), "VAL-NEXT-10 issue table only exposes real row actions")
	var document_row = _validation_issue_row_for_rule(rows, "workspace.level_document_missing")
	_assert_eq(String(document_row["severity_label"]), "Error", "SCREEN-23 issue row exposes severity label")
	_assert_true(String(document_row["domain"]) != "", "SCREEN-23 issue row exposes domain/scope grouping")
	_assert_eq(String(document_row["scope"]), HexMapValidationResult.SCOPE_DEPENDENCY, "VAL-NEXT-10 missing document row exposes scope column")
	_assert_true(String(document_row["target_text"]) != "", "VAL-NEXT-10 missing document row exposes target column")
	_assert_eq(String(document_row["suggestion"]), String(document_row["fix_suggestion"]), "VAL-NEXT-10 missing document row exposes suggestion column")
	var document_actions = document_row["available_actions"] as Array
	_assert_eq(document_actions.size(), 1, "VAL-NEXT-10 missing document row exposes one real focus action")
	_assert_eq(String((document_actions[0] as Dictionary)["id"]), "focus_issue", "VAL-NEXT-10 missing document action is focus_issue")
	_assert_eq(String((document_actions[0] as Dictionary)["target_tab"]), "Resources", "VAL-NEXT-10 missing document action targets Resources")
	_assert_true(bool((document_actions[0] as Dictionary)["real"]), "VAL-NEXT-10 missing document action is marked real")
	_assert_true(String(document_row["focus_target"]) != "", "SCREEN-23 issue row exposes focus target")
	_assert_true(String(document_row["fix_suggestion"]) != "", "SCREEN-23 issue row exposes fix suggestion")
	_assert_eq(document_row["target_tab"], "Resources", "missing document points to Resources tab")
	_assert_eq(document_row["target_component_id"], "document_asset_panel", "missing document points to document panel")
	_assert_eq(document_row["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "missing document points to level document slot")
	_assert_eq(document_row["destination_tab"], "Resources", "TAB-54 missing document route selects Resources")
	_assert_eq(document_row["focus_type"], "asset_slot", "TAB-54 missing document route focuses asset slot")
	_assert_eq(document_row["suggested_action"], "Select or create Level Document.", "TAB-54 missing document route suggests concrete action")

	var catalog_row = _validation_issue_row_for_rule(rows, "workspace.tile_catalog_missing")
	_assert_eq(catalog_row["target_tab"], "Catalog", "missing catalog points to Catalog tab")
	_assert_eq(catalog_row["target_component_id"], "catalog_asset_panel", "missing catalog points to catalog panel")
	_assert_eq(catalog_row["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "missing catalog points to tile catalog slot")
	_assert_eq(catalog_row["destination_tab"], "Catalog", "TAB-54 missing catalog route selects Catalog")
	_assert_true(String(catalog_row["focus_target"]) != "", "TAB-54 missing catalog row exposes focus target")
	_assert_true(String(catalog_row["fix_suggestion"]) != "", "TAB-54 missing catalog row exposes fix suggestion")

	var object_row = _validation_issue_row_for_rule(rows, "workspace.object_database_missing")
	_assert_eq(object_row["target_tab"], "Resources", "TAB-51 missing object database points to Resources tab")
	_assert_eq(object_row["target_component_id"], "document_asset_panel", "TAB-51 missing object database points to Resources asset panel")
	_assert_eq(object_row["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE, "missing object database points to object database slot")

	var label_row = _validation_issue_row_for_rule(rows, "workspace.label_database_missing")
	_assert_eq(label_row["target_tab"], "Resources", "TAB-51 missing label database points to Resources tab")
	_assert_eq(label_row["target_component_id"], "document_asset_panel", "TAB-51 missing label database points to Resources asset panel")
	_assert_eq(label_row["target_slot_id"], HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE, "missing label database points to label database slot")

	var layer_row = _validation_issue_row_for_rule(rows, "workspace.layer_stack_missing")
	_assert_eq(layer_row["target_tab"], "Layers", "missing layer stack points to Layers tab")
	_assert_eq(layer_row["target_component_id"], "layer_stack_asset_panel", "missing layer stack points to layer stack panel")
	_assert_eq(layer_row["destination_tab"], "Layers", "TAB-54 missing layer stack route selects Layers")

	var validation_suite_slot = snapshot["validation_rule_suite_slot"] as Dictionary
	_assert_eq(bool(validation_suite_slot.get("is_required", true)), false, "PROFILE-31 Validate missing Validation Suite is optional")
	_assert_eq(String(validation_suite_slot.get("required_type", "")), "HexValidationRuleSuiteResource", "PROFILE-31 Validate missing slot keeps concrete type")
	_assert_eq(
		String((snapshot["validation_rule_suite_context"] as Dictionary).get("status", "")),
		"optional_missing",
		"PROFILE-31 Validate profile context reports optional missing state"
	)
	_assert_eq(
		((snapshot["validation_rule_suite_context"] as Dictionary)["behavior_schema"] as Dictionary).is_empty(),
		true,
		"PROFILE-NEXT-10 missing Validation Suite context has no behavior schema"
	)
	var qa_missing_snapshot = workspace.qa_screen_snapshot()
	_assert_eq(
		String((qa_missing_snapshot["generation_profile_context"] as Dictionary).get("status", "")),
		"optional_missing",
		"PROFILE-31 QA profile context reports optional missing state"
	)
	_assert_eq(
		String((qa_missing_snapshot["generation_profile_context"] as Dictionary).get("behavior_schema_status", "")),
		"optional_missing",
		"PROFILE-NEXT-10 missing Generation Profile context marks missing behavior schema"
	)
	var export_missing_snapshot = workspace.export_screen_snapshot()
	_assert_eq(
		String((export_missing_snapshot["export_profile_context"] as Dictionary).get("status", "")),
		"optional_missing",
		"PROFILE-31 Export profile context reports optional missing state"
	)
	_assert_eq(
		String((export_missing_snapshot["export_profile_context"] as Dictionary).get("behavior_schema_status", "")),
		"optional_missing",
		"PROFILE-NEXT-10 missing Export Profile context marks missing behavior schema"
	)

	var selection = workspace.select_validate_issue(int(document_row["index"]))
	_assert_true(bool(selection["ok"]), "TAB-54 Validate issue selection succeeds")
	validation_state = selection["validation_state"] as Dictionary
	_assert_eq(String(validation_state["state_id"]), HexMapValidationWorkflowState.STATE_FOCUS_APPLIED, "STATE-50 Validate selection applies focus state")
	_assert_eq(selection["selected_tab"], "Resources", "TAB-54 selecting document issue moves to Resources")
	_assert_eq((selection["navigation"] as Dictionary)["target_component_id"], "document_asset_panel", "TAB-54 selection records component target")
	snapshot = workspace.validate_screen_snapshot()
	_assert_eq((snapshot["selected_issue_row"] as Dictionary)["rule_id"], "workspace.level_document_missing", "TAB-54 snapshot stores selected issue")
	selection = workspace.select_validate_issue(int(catalog_row["index"]))
	_assert_eq(selection["selected_tab"], "Catalog", "TAB-54 selecting catalog issue moves to Catalog")
	selection = workspace.select_validate_issue(int(layer_row["index"]))
	_assert_eq(selection["selected_tab"], "Layers", "TAB-54 selecting layer issue moves to Layers")
	var invalid_selection = workspace.select_validate_issue(999)
	_assert_true(not bool(invalid_selection["ok"]), "TAB-54 invalid issue selection is rejected")
	snapshot = workspace.validate_screen_snapshot()
	_assert_true(String(snapshot["issue_table_rows_text"]).contains("Focus in Resources"), "VAL-NEXT-10 issue table rows text includes real focus action")
	_assert_true(String(snapshot["mounted_issue_table_text"]).contains("Error | Document"), "VAL-NEXT-10 mounted issue table text includes rich columns")

	var cell_document := _sample_editor_document()
	(cell_document.object_placements[0] as HexMapDocumentObjectPlacementResource).cell = Vector3i(1, 0, 0)
	workspace.workspace_asset_context().set_level_document(cell_document)
	var cell_validate_result = workspace.run_validate_screen()
	validation_progress_state = cell_validate_result["validation_progress_state"] as Dictionary
	_assert_true(int(validation_progress_state["event_count"]) >= 8, "PERF-NEXT-11 document validation reports phase events")
	_assert_true(int(validation_progress_state["cells"]) > 0, "PERF-NEXT-11 document validation progress reports cell count")
	_assert_eq(
		String(((cell_validate_result["result"] as HexMapValidationResult).summary.get("validation_progress", {}) as Dictionary).get("phase", "")),
		"complete",
		"PERF-NEXT-11 workspace validation result stores final progress"
	)
	var cell_rows = cell_validate_result["issue_rows"] as Array
	var wall_row = _validation_issue_row_for_rule(cell_rows, "document.object_on_wall")
	_assert_eq(wall_row["destination_tab"], "Paint", "TAB-54 cell-scoped issue routes to Paint")
	_assert_eq(wall_row["focus_type"], "cell", "TAB-54 cell-scoped issue records cell focus")
	_assert_true(String(wall_row["target_text"]).contains("Cell"), "VAL-NEXT-10 cell-scoped issue exposes target cell")
	_assert_true(String(wall_row["suggestion"]).contains("floor"), "VAL-NEXT-10 cell-scoped issue exposes fix suggestion")
	var wall_actions = wall_row["available_actions"] as Array
	_assert_eq(wall_actions.size(), 1, "VAL-NEXT-10 cell-scoped issue exposes one real focus action")
	_assert_eq(String((wall_actions[0] as Dictionary)["target_tab"]), "Paint", "VAL-NEXT-10 cell-scoped action targets Paint")
	_assert_true(String(wall_row["suggested_action"]).contains("Paint"), "TAB-54 cell-scoped issue suggests Paint inspection")
	selection = workspace.select_validate_issue(int(wall_row["index"]))
	_assert_eq(selection["selected_tab"], "Paint", "TAB-54 selecting cell issue moves to Paint")

	snapshot = workspace.validate_screen_snapshot()
	_assert_true((snapshot["issue_rows"] as Array).size() >= rows.size(), "Validate screen snapshot keeps last issue rows")
	_assert_true(bool(snapshot["issue_click_routes_focus"]), "SCREEN-23 Validate keeps issue click routing after cell focus")
	_assert_eq(workspace.workspace_asset_context().tile_catalog, null, "Validate screen does not inject sample catalog")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "Validate screen does not inject generation sample catalog")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Validate screen actions do not enable sample mode")

	workspace.queue_free()
	await process_frame


