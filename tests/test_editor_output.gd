extends "res://tests/test_editor_plugin_test_base.gd"

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	await _test_export_asset_screen_requires_user_destination_and_exports_project_document()
	_finish("res://tests/test_editor_output.gd")

func _test_export_asset_screen_requires_user_destination_and_exports_project_document() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var snapshot = workspace.export_screen_snapshot()
	_assert_eq(String(snapshot["export_workflow_owner"]), "Export", "SCREEN-21 Export owns export workflow")
	_assert_true(bool(snapshot["export_management_visible"]), "SCREEN-21 Export exposes export management")
	_assert_eq(String(snapshot["destination_output_type_owner"]), "Export", "SCREEN-21 Export owns destination/output type")
	_assert_true(bool(snapshot["destination_controls_visible"]), "SCREEN-21 Export exposes destination controls")
	_assert_true(bool(snapshot["output_type_controls_visible"]), "SCREEN-21 Export exposes output type controls")
	_assert_true(not bool(snapshot["paint_export_management_visible"]), "SCREEN-21 Paint does not own export management")
	_assert_eq(snapshot["purpose_text"], "Export writes the current Level Document as a runtime HexMapResource handoff.", "TAB-56 Export screen states purpose")
	var export_state = snapshot["export_state"] as Dictionary
	_assert_eq(String(export_state["state_source"]), "HexMapExportWorkflowState", "STATE-50 Export snapshot reports state source")
	_assert_eq(String(export_state["state_id"]), HexMapExportWorkflowState.STATE_NO_DESTINATION, "STATE-50 Export starts without destination")
	_assert_true(bool(snapshot["purpose_component_present"]), "TAB-56 Export snapshot confirms purpose panel")
	_assert_eq(snapshot["active_output_type"], "runtime_handoff_resource", "TAB-56 Export uses runtime handoff as active output")
	_assert_true(bool(snapshot["active_output_type_visible"]), "SCREEN-25 Export exposes active output type")
	_assert_true(bool(snapshot["export_type_taxonomy_visible"]), "SCREEN-25 Export exposes output type taxonomy")
	_assert_true(bool(snapshot["output_destination_visible"]), "SCREEN-25 Export exposes output destination state")
	_assert_true(bool(snapshot["export_result_state_visible"]), "SCREEN-25 Export exposes result state")
	_assert_eq(String(snapshot["export_result_state"]), HexMapExportWorkflowState.STATE_NO_DESTINATION, "SCREEN-25 Export starts with result state")
	_assert_eq(String(snapshot["export_result_state_source"]), "HexMapExportWorkflowState", "SCREEN-25 Export result state names source")
	_assert_true(not bool(snapshot["resource_reference_only"]), "SCREEN-25 Export is not resource-reference-only")
	var handoff_summary = snapshot["runtime_handoff_summary"] as Dictionary
	_assert_eq(String(handoff_summary["surface_id"]), "runtime_handoff_summary", "SCREEN-NEXT-10 Export exposes runtime handoff summary")
	_assert_true(not bool(handoff_summary["primary_path_text_visible"]), "SCREEN-NEXT-10 Export handoff summary keeps path out of primary text")
	var handoff_rows = _entries_by_id(handoff_summary["readiness_rows"] as Array)
	_assert_eq(String((handoff_rows["source_document"] as Dictionary)["status"]), "missing", "SCREEN-NEXT-10 Export source readiness starts missing")
	_assert_eq(String((handoff_rows["destination"] as Dictionary)["status"]), "missing", "SCREEN-NEXT-10 Export destination readiness starts missing")
	_assert_eq(String((handoff_rows["run_action"] as Dictionary)["status"]), "blocked", "SCREEN-NEXT-10 Export action readiness starts blocked")
	_assert_true(String(snapshot["mounted_runtime_handoff_summary_text"]).contains("Source: Level Document missing"), "SCREEN-NEXT-10 mounted Export handoff summary shows missing source")
	var output_type = snapshot["output_type"] as Dictionary
	_assert_eq(output_type["label"], "Runtime Handoff Resource", "TAB-56 Export names output type")
	_assert_eq(output_type["source"], "Current Level Document", "TAB-56 Export names source")
	_assert_eq(output_type["target_resource_class"], "HexMapResource", "TAB-56 Export names output resource")
	_assert_eq(String(output_type["result_purpose_text"]), "Runtime/API handoff for HexMapResource consumers.", "SCREEN-25 Export explains runtime handoff purpose")
	_assert_eq(String(output_type["result_usage"]), "Runtime and scripting use", "SCREEN-25 Export explains result usage")
	_assert_eq(String(output_type["destination_purpose"]), "Project .tres path for the runtime handoff resource.", "SCREEN-25 Export explains destination purpose")
	_assert_true(not bool(output_type["source_ready"]), "TAB-56 Export starts with missing source")
	_assert_true(not bool(output_type["destination_ready"]), "TAB-56 Export starts with missing destination")
	_assert_eq(snapshot["cannot_export_reason"], "Level Document is not selected.", "TAB-56 Export explains blocked export")
	_assert_true(bool(snapshot["use_recent_button_disabled"]), "FB-02 Export use-recent action starts disabled without recent destination")
	_assert_eq(
		String(snapshot["use_recent_button_tooltip"]),
		"No recent Runtime Handoff destinations.",
		"FB-02 disabled Export use-recent action explains missing recent destination"
	)
	_assert_true(bool(snapshot["run_button_disabled"]), "FB-02 Export run action starts disabled")
	_assert_eq(
		String(snapshot["run_button_tooltip"]),
		"Level Document is not selected.",
		"FB-02 disabled Export run action explains missing Level Document"
	)
	_assert_true(not bool(snapshot["unsupported_export_buttons_visible"]), "TAB-56 unsupported export buttons are hidden")
	_assert_true(not bool(snapshot["data_export_button_visible"]), "TAB-56 data export button is hidden")
	_assert_true(not bool(snapshot["package_build_button_visible"]), "TAB-56 package build button is hidden")
	_assert_true(not bool(snapshot["debug_report_export_button_visible"]), "TAB-56 debug report export button is hidden")
	_assert_true(bool(snapshot["experimental_exports_hidden"]), "TAB-56 experimental exports are hidden")
	var modes = snapshot["output_modes"] as Array
	_assert_eq(_export_mode_status(modes, "runtime_handoff_resource"), "available", "TAB-56 runtime handoff is available")
	_assert_eq(_export_mode_status(modes, "data_export_json"), "backlog", "TAB-56 data export is backlog")
	_assert_eq(_export_mode_status(modes, "package_build"), "process", "TAB-56 package build is process")
	_assert_eq(_export_mode_status(modes, "debug_report"), "diagnostic", "TAB-56 debug report is diagnostic")
	_assert_eq(
		snapshot["visible_output_mode_ids"],
		PackedStringArray(["runtime_handoff_resource"]),
		"INFO-72 Export tab visible output is Runtime Handoff only"
	)
	var visible_mode_labels = snapshot["visible_output_mode_labels"] as PackedStringArray
	_assert_true(visible_mode_labels.has("Runtime Handoff"), "INFO-72 Export visible mode names Runtime Handoff")
	_assert_true(not visible_mode_labels.has("Data Export"), "INFO-72 Data Export is classified but not visible")
	_assert_true(not visible_mode_labels.has("Package Build"), "INFO-72 Package Build is classified but not visible")
	_assert_true(not visible_mode_labels.has("Debug Report"), "INFO-72 Debug Report is classified but not visible")
	_assert_eq(int(snapshot["normal_export_action_count"]), 1, "SCREEN-25 Export exposes one normal export action")
	_assert_true(String(snapshot["package_support_boundary"]).contains("developer release process"), "SCREEN-25 Export explains package boundary")
	_assert_true(String(snapshot["debug_export_boundary"]).contains("diagnostic"), "SCREEN-25 Export explains debug export boundary")
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("export_asset_panel"),
		"Export screen exposes export asset panel"
	)
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("export_purpose_panel"),
		"TAB-56 Export screen exposes purpose panel"
	)
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("export_destination_panel"),
		"Export screen exposes destination panel"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT),
		"Export screen exposes level document slot"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE),
		"Export screen exposes export profile slot"
	)
	_assert_true(not bool((snapshot["destination"] as Dictionary).get("selected", true)), "Export screen starts without destination")
	_assert_true(String(snapshot["output_destination_purpose"]).contains("runtime handoff resource"), "SCREEN-25 Export destination purpose is visible")
	_assert_true(not bool(snapshot["can_export"]), "Export screen cannot export until configured")
	_assert_true(not bool(snapshot["sample_destination_available"]), "Export screen has no sample destination")
	_assert_true(not bool(snapshot["editable_destination_path_visible"]), "Export screen does not expose editable destination path text")
	_assert_true(not bool(snapshot["sample_candidates_visible"]), "Export screen starts with sample mode OFF")
	var dialog_config = snapshot["destination_dialog_config"] as Dictionary
	_assert_true(bool(dialog_config.get("uses_file_dialog", false)), "Export destination uses FileDialog contract")
	_assert_eq(int(dialog_config.get("file_mode", -1)), EditorFileDialog.FILE_MODE_SAVE_FILE, "Export destination uses Save As dialog mode")
	_assert_true(String(dialog_config.get("current_file", "")).ends_with(".tres"), "Export destination dialog defaults to .tres")
	_assert_true(not bool(dialog_config.get("editable_path_text_visible", true)), "Export destination dialog does not require editable path text")

	var output_dir = _test_resource_dir("screen27_export")
	var profile_path = "%s/export_profile.tres" % output_dir
	var profile_result = workspace.create_export_profile(profile_path)
	_assert_true(bool(profile_result["ok"]), "Export screen creates project Export Profile")
	_assert_true(FileAccess.file_exists(profile_path), "Export screen writes project Export Profile")
	var export_profile = profile_result["resource"] as HexExportProfileResource
	_assert_true(export_profile is HexExportProfileResource, "Export screen create returns export profile resource")
	_assert_eq(
		String(export_profile.behavior_schema().get("kind", "")),
		"export_profile",
		"PROFILE-NEXT-10 created Export Profile exposes behavior schema"
	)
	_assert_eq(workspace.workspace_asset_context().export_profile, export_profile, "created export profile enters workspace context")
	_assert_eq(
		workspace.tab_asset_slot_snapshot("Export", HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE).get("current_source", ""),
		HexMapEditorAssetSlotState.SOURCE_PROJECT,
		"Export screen marks export profile as project asset"
	)
	snapshot = workspace.export_screen_snapshot()
	_assert_eq(
		String(((snapshot["export_profile_context"] as Dictionary)["behavior_schema"] as Dictionary).get("kind", "")),
		"export_profile",
		"PROFILE-NEXT-10 Export screen snapshot carries export behavior schema"
	)

	var profile_open = workspace.open_export_profile()
	_assert_true(bool(profile_open["ok"]), "Export screen opens selected Export Profile")
	var profile_save_as_path = "%s/export_profile_saved_as.tres" % output_dir
	var profile_save = workspace.save_export_profile_as(profile_save_as_path)
	_assert_true(bool(profile_save["ok"]), "Export screen saves Export Profile as project resource")
	_assert_true(FileAccess.file_exists(profile_save_as_path), "Export screen Save As writes export profile")

	var missing_destination = workspace.export_selected_document_to_destination()
	_assert_true(not bool(missing_destination["ok"]), "Export screen refuses export without selected destination")
	_assert_eq(int(missing_destination["error"]), ERR_INVALID_PARAMETER, "Export without destination reports invalid parameter")
	export_state = missing_destination["export_state"] as Dictionary
	_assert_eq(String(export_state["state_id"]), HexMapExportWorkflowState.STATE_NO_DESTINATION, "STATE-50 blocked export keeps no-destination state")

	var document := _sample_editor_document()
	workspace.workspace_asset_context().set_level_document(document)
	snapshot = workspace.export_screen_snapshot()
	_assert_true(bool(snapshot["run_button_disabled"]), "FB-02 Export run remains disabled without destination")
	_assert_eq(
		String(snapshot["run_button_tooltip"]),
		"Export destination is not selected.",
		"FB-02 disabled Export run action explains missing destination after document selection"
	)
	var export_path = "%s/runtime_handoff_map.tres" % output_dir
	var destination_result = workspace.select_export_destination(export_path)
	_assert_true(bool(destination_result["ok"]), "Export screen accepts user-selected destination")
	_assert_eq(session.export_saved_path, export_path, "Export destination updates session handoff path")
	_assert_eq(session.recent_export_destinations[0], export_path, "Export destination enters recent list")
	_assert_eq(workspace.edit_tool().export_path(), export_path, "Export destination syncs paint tool handoff path")

	snapshot = workspace.export_screen_snapshot()
	_assert_true(bool(snapshot["can_export"]), "Export screen can export after document and destination are selected")
	export_state = snapshot["export_state"] as Dictionary
	_assert_eq(String(export_state["state_id"]), HexMapExportWorkflowState.STATE_READY, "STATE-50 Export becomes ready after source and destination")
	_assert_true(not bool(snapshot["run_button_disabled"]), "FB-02 Export run action enables after document and destination")
	_assert_true(String(snapshot["run_button_tooltip"]).contains("Runtime Handoff"), "FB-02 enabled Export run action names its state change")
	_assert_true(not bool(snapshot["use_recent_button_disabled"]), "FB-02 Export use-recent action enables after destination history exists")
	_assert_true(String(snapshot["use_recent_button_tooltip"]).contains(export_path), "FB-02 enabled Export use-recent action names recent destination")
	_assert_true(bool((snapshot["destination"] as Dictionary).get("selected", false)), "Export snapshot reports selected destination")
	output_type = snapshot["output_type"] as Dictionary
	_assert_true(bool(output_type["source_ready"]), "TAB-56 Export source becomes ready")
	_assert_true(bool(output_type["destination_ready"]), "TAB-56 Export destination becomes ready")
	_assert_eq(snapshot["cannot_export_reason"], "", "TAB-56 Export clears blocked reason when ready")
	handoff_summary = snapshot["runtime_handoff_summary"] as Dictionary
	handoff_rows = _entries_by_id(handoff_summary["readiness_rows"] as Array)
	_assert_eq(String((handoff_rows["source_document"] as Dictionary)["status"]), "ready", "SCREEN-NEXT-10 Export source readiness becomes ready")
	_assert_eq(String((handoff_rows["destination"] as Dictionary)["status"]), "ready", "SCREEN-NEXT-10 Export destination readiness becomes ready")
	_assert_eq(String((handoff_rows["run_action"] as Dictionary)["status"]), "ready", "SCREEN-NEXT-10 Export action readiness becomes ready")
	_assert_true(String(snapshot["mounted_runtime_handoff_summary_text"]).contains("Action: Ready"), "SCREEN-NEXT-10 mounted Export handoff summary shows ready action")

	var export_result = workspace.export_selected_document_to_destination()
	_assert_true(bool(export_result["ok"]), "Export screen writes selected document handoff")
	export_state = export_result["export_state"] as Dictionary
	_assert_eq(String(export_state["state_id"]), HexMapExportWorkflowState.STATE_EXPORTED, "STATE-50 Export reports exported state after handoff write")
	_assert_true(FileAccess.file_exists(export_path), "Export screen writes selected destination file")
	var loaded = ResourceLoader.load(export_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	_assert_true(loaded is HexMapResource, "Export screen handoff loads as HexMapResource")
	_assert_eq(export_result["resource_class"], "HexMapResource", "Export result reports HexMapResource")
	_assert_eq(export_result["output_type"], "runtime_handoff_resource", "TAB-56 export result reports output type")
	_assert_eq(export_result["purpose_text"], "Runtime handoff HexMapResource", "TAB-56 export result reports purpose")
	var document_summary := HexMapDocumentAdapter.document_summary(document)
	_assert_eq(int(export_result["cell_count"]), int(document_summary["cells"]), "Export result reports document cell count")
	_assert_eq(String((export_result["package_handoff"] as Dictionary).get("path", "")), export_path, "Export result reports package handoff path")
	_assert_eq(String((export_result["runtime_handoff"] as Dictionary).get("resource_class", "")), "HexMapResource", "Export result reports runtime handoff type")
	snapshot = workspace.export_screen_snapshot()
	_assert_eq(String(snapshot["export_result_state"]), HexMapExportWorkflowState.STATE_EXPORTED, "SCREEN-25 Export snapshot reports exported result state")
	_assert_true(String(snapshot["export_result_status_text"]).contains("Exported Runtime Handoff"), "SCREEN-25 Export snapshot reports exported status")
	handoff_summary = snapshot["runtime_handoff_summary"] as Dictionary
	handoff_rows = _entries_by_id(handoff_summary["readiness_rows"] as Array)
	_assert_eq(String((handoff_rows["result_state"] as Dictionary)["status"]), HexMapExportWorkflowState.STATE_EXPORTED, "SCREEN-NEXT-10 Export readiness result reports exported state")

	var next_export_path = "%s/runtime_handoff_next.tres" % output_dir
	var next_destination = workspace.select_export_destination(next_export_path)
	_assert_true(bool(next_destination["ok"]), "Export screen accepts another user-selected destination")
	var recent_result = workspace.select_recent_export_destination(export_path)
	_assert_true(bool(recent_result["ok"]), "Export screen selects previous recent destination")
	_assert_eq(session.export_saved_path, export_path, "Recent destination updates active export path")
	_assert_eq(session.recent_export_destinations[0], export_path, "Recent destination moves to front")

	var clear_profile = workspace.clear_export_profile()
	_assert_true(bool(clear_profile["ok"]), "Export screen clears Export Profile")
	_assert_eq(workspace.workspace_asset_context().export_profile, null, "cleared export profile leaves workspace context")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Export screen actions do not enable sample mode")

	workspace.queue_free()
	await process_frame


