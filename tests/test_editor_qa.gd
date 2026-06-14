extends "res://tests/test_editor_plugin_test_base.gd"

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	await _test_qa_asset_screen_manages_profiles_and_score_context_without_samples()
	_finish("res://tests/test_editor_qa.gd")

func _test_qa_asset_screen_manages_profiles_and_score_context_without_samples() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var snapshot = workspace.qa_screen_snapshot()
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("qa_asset_panel"),
		"QA screen exposes QA asset panel"
	)
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("qa_seed_lab_panel"),
		"TAB-55 QA screen exposes Seed Lab panel"
	)
	_assert_true(bool(snapshot["seed_lab_component_present"]), "TAB-55 QA snapshot confirms Seed Lab component")
	_assert_eq(snapshot["purpose_text"], "Compare generated seeds and promote one result to the Level Document.", "TAB-55 QA screen states purpose")
	_assert_true(String(snapshot["generate_role_text"]).contains("Generate previews one candidate"), "TAB-55 QA distinguishes Generate and QA roles")
	_assert_eq(String(snapshot["qa_workflow_owner"]), "QA", "SCREEN-24 QA owns seed lab workflow")
	_assert_true(bool(snapshot["generation_profile_context_visible"]), "SCREEN-24 QA exposes Generation Profile context")
	_assert_true(bool(snapshot["score_table_visible"]), "SCREEN-24 QA exposes score table state")
	_assert_true(bool(snapshot["mounted_score_table_present"]), "QA-NEXT-10 QA mounts scored table widget")
	_assert_true(bool(snapshot["selected_seed_visible"]), "SCREEN-24 QA exposes selected seed state")
	_assert_true(bool(snapshot["promote_target_visible"]), "SCREEN-24 QA exposes promote target state")
	_assert_eq(String(snapshot["document_source_of_truth"]), "Level Document", "SCREEN-24 QA names Level Document as source of truth")
	_assert_true(bool(snapshot["draft_context_boundary_visible"]), "SCREEN-24 QA exposes draft context boundary")
	_assert_true(String(snapshot["draft_context_text"]).contains("promotes"), "SCREEN-24 QA explains promote boundary")
	_assert_true(not bool(snapshot["resource_reference_only"]), "SCREEN-24 QA is not resource-reference-only")
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE),
		"QA screen exposes generation profile slot"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE),
		"QA screen exposes validation suite slot"
	)
	_assert_true(not bool(snapshot["sample_candidates_visible"]), "QA screen starts with sample mode OFF")

	var output_dir = _test_resource_dir("screen26_qa")
	var profile_path = "%s/generation_profile.tres" % output_dir
	var profile_result = workspace.create_generation_profile(profile_path)
	_assert_true(bool(profile_result["ok"]), "QA screen creates project Generation Profile")
	_assert_true(FileAccess.file_exists(profile_path), "QA screen writes project Generation Profile")
	var profile = profile_result["resource"] as HexGenerationProfileResource
	_assert_true(profile is HexGenerationProfileResource, "QA screen create returns generation profile resource")
	_assert_eq(
		String(profile.behavior_schema().get("kind", "")),
		"generation_profile",
		"PROFILE-NEXT-10 created Generation Profile exposes behavior schema"
	)
	_assert_eq(workspace.workspace_asset_context().generation_profile, profile, "created generation profile enters workspace context")
	_assert_eq(
		workspace.tab_asset_slot_snapshot("QA", HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE).get("current_source", ""),
		HexMapEditorAssetSlotState.SOURCE_PROJECT,
		"QA screen marks generation profile as project asset"
	)

	var suite_path = "%s/validation_suite.tres" % output_dir
	var suite_result = workspace.create_validation_rule_suite(suite_path)
	_assert_true(bool(suite_result["ok"]), "QA screen creates project Validation Rule Suite")
	_assert_true(FileAccess.file_exists(suite_path), "QA screen writes project Validation Rule Suite")
	var suite = suite_result["resource"] as HexValidationRuleSuiteResource
	_assert_true(suite is HexValidationRuleSuiteResource, "QA screen create returns validation suite resource")
	_assert_eq(
		String(suite.behavior_schema().get("kind", "")),
		"validation_rule_suite",
		"PROFILE-NEXT-10 created Validation Suite exposes behavior schema"
	)
	_assert_eq(workspace.workspace_asset_context().validation_rule_suite, suite, "created validation suite enters workspace context")

	var score_context = workspace.qa_score_table_context()
	_assert_true(bool(score_context["score_table_visible"]), "SCREEN-24 score context exposes score table")
	_assert_true(bool(score_context["generation_profile_used"]), "SCREEN-24 score context uses Generation Profile")
	var score_context_table = score_context["scored_table"] as Dictionary
	var score_context_columns = score_context_table["columns"] as PackedStringArray
	for column in ["rank", "seed", "score", "validation", "selected", "preview", "promotion"]:
		_assert_true(score_context_columns.has(column), "QA-NEXT-10 score context exposes column: %s" % column)
	_assert_true(bool((score_context["generation_profile"] as Dictionary).get("selected", false)), "QA score context reports selected generation profile")
	_assert_true(bool((score_context["validation_rule_suite"] as Dictionary).get("selected", false)), "QA score context reports selected validation suite")
	_assert_eq(
		String(((score_context["generation_profile"] as Dictionary)["behavior_schema"] as Dictionary).get("kind", "")),
		"generation_profile",
		"PROFILE-NEXT-10 QA score context carries generation behavior schema"
	)
	_assert_eq(
		String(((score_context["validation_rule_suite"] as Dictionary)["behavior_schema"] as Dictionary).get("kind", "")),
		"validation_rule_suite",
		"PROFILE-NEXT-10 QA score context carries validation behavior schema"
	)
	_assert_eq(
		String((score_context["generation_profile"] as Dictionary).get("resource_path", "")),
		profile_path,
		"QA score context reports generation profile path"
	)
	_assert_eq(
		String((score_context["validation_rule_suite"] as Dictionary).get("resource_path", "")),
		suite_path,
		"QA score context reports validation suite path"
	)

	var profile_open = workspace.open_generation_profile()
	_assert_true(bool(profile_open["ok"]), "QA screen opens selected Generation Profile")
	var profile_save_as_path = "%s/generation_profile_saved_as.tres" % output_dir
	var profile_save = workspace.save_generation_profile_as(profile_save_as_path)
	_assert_true(bool(profile_save["ok"]), "QA screen saves Generation Profile as project resource")
	_assert_true(FileAccess.file_exists(profile_save_as_path), "QA screen Save As writes generation profile")

	var suite_open = workspace.open_validation_rule_suite()
	_assert_true(bool(suite_open["ok"]), "QA screen opens selected Validation Rule Suite")
	var suite_save_as_path = "%s/validation_suite_saved_as.tres" % output_dir
	var suite_save = workspace.save_validation_rule_suite_as(suite_save_as_path)
	_assert_true(bool(suite_save["ok"]), "QA screen saves Validation Rule Suite as project resource")
	_assert_true(FileAccess.file_exists(suite_save_as_path), "QA screen Save As writes validation suite")

	var preset_profile_path = "%s/balanced_generation_profile.tres" % output_dir
	var preset_profile = workspace.duplicate_generation_profile_preset_to_project("balanced", preset_profile_path)
	_assert_true(bool(preset_profile["ok"]), "QA screen duplicates generation preset to project")
	_assert_true(FileAccess.file_exists(preset_profile_path), "QA screen writes duplicated generation preset")
	var duplicated_profile = preset_profile["resource"] as Resource
	_assert_true(duplicated_profile is HexGenerationProfileResource, "PROFILE-30 duplicated generation profile uses concrete resource")
	_assert_eq(String(duplicated_profile.get_meta("preset_source", "")), "balanced", "duplicated generation profile records preset source")
	var duplicated_generation_schema = (duplicated_profile as HexGenerationProfileResource).behavior_schema()
	var duplicated_generation_terrain = duplicated_generation_schema["terrain"] as Dictionary
	_assert_eq(
		String(duplicated_generation_terrain.get("connectivity_mode", "")),
		"dense",
		"PROFILE-NEXT-10 duplicated generation preset carries concrete behavior"
	)
	_assert_eq(workspace.workspace_asset_context().generation_profile, duplicated_profile, "duplicated generation profile enters workspace context")

	var preset_suite_path = "%s/standard_validation_suite.tres" % output_dir
	var preset_suite = workspace.duplicate_validation_rule_suite_preset_to_project("standard", preset_suite_path)
	_assert_true(bool(preset_suite["ok"]), "QA screen duplicates validation suite preset to project")
	_assert_true(FileAccess.file_exists(preset_suite_path), "QA screen writes duplicated validation suite preset")
	var duplicated_suite = preset_suite["resource"] as Resource
	_assert_true(duplicated_suite is HexValidationRuleSuiteResource, "PROFILE-30 duplicated validation suite uses concrete resource")
	_assert_eq(String(duplicated_suite.get_meta("preset_source", "")), "standard", "duplicated validation suite records preset source")
	_assert_eq(
		String((duplicated_suite as HexValidationRuleSuiteResource).rule_severity("document.object_on_wall", "")),
		"error",
		"PROFILE-NEXT-10 duplicated validation preset carries severity behavior"
	)
	_assert_eq(workspace.workspace_asset_context().validation_rule_suite, duplicated_suite, "duplicated validation suite enters workspace context")

	score_context = workspace.qa_score_table_context()
	_assert_eq(
		String((score_context["generation_profile"] as Dictionary).get("preset_source", "")),
		"balanced",
		"QA score context reports duplicated generation preset"
	)
	_assert_eq(
		String((score_context["validation_rule_suite"] as Dictionary).get("preset_source", "")),
		"standard",
		"QA score context reports duplicated validation preset"
	)
	snapshot = workspace.qa_screen_snapshot()
	var seed_lab = snapshot["seed_lab"] as Dictionary
	var empty_scored_table = seed_lab["scored_table"] as Dictionary
	_assert_eq(int(empty_scored_table["row_count"]), 0, "QA-NEXT-10 scored table starts empty")
	_assert_eq(seed_lab["empty_state_text"], "Run Seed Lab to compare generated seeds.", "TAB-55 QA Seed Lab starts with empty state")
	_assert_true(bool(seed_lab["score_table_visible"]), "SCREEN-24 Seed Lab exposes score table")
	_assert_true(bool(seed_lab["selected_seed_visible"]), "SCREEN-24 Seed Lab exposes selected seed")
	_assert_true(bool(seed_lab["promote_target_visible"]), "SCREEN-24 Seed Lab exposes promotion target")
	_assert_eq(String(seed_lab["document_source_of_truth"]), "Level Document", "SCREEN-24 Seed Lab names document source of truth")
	_assert_true(bool(seed_lab["draft_context_boundary_visible"]), "SCREEN-24 Seed Lab exposes draft boundary")
	_assert_true(bool(seed_lab["can_run_batch"]), "TAB-55 QA Seed Lab can run through generation dock")
	_assert_true(not bool(seed_lab["can_promote"]), "TAB-55 QA Seed Lab requires selected seed before promotion")

	var dock = workspace.generation_dock()
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._connect_method_option.select(_connect_method_index(HexMapGenerator.CONNECT_DENSE))
	dock._refresh_controls()

	var batch_result = workspace.run_qa_seed_lab(2, {"seeds": [901, 902]})
	_assert_true(bool(batch_result["ok"]), "TAB-55 QA Seed Lab runs batch")
	var score_rows = batch_result["score_rows"] as Array
	_assert_eq(score_rows.size(), 2, "TAB-55 QA Seed Lab records score rows")
	_assert_true(not (batch_result["selected_seed_row"] as Dictionary).is_empty(), "TAB-55 QA Seed Lab selects top row after batch")
	var qa_row_preview = (score_rows[0] as Dictionary)["preview"] as Dictionary
	_assert_true(bool(qa_row_preview["available"]), "GEN-NEXT-11 QA score row carries preview")
	_assert_eq(String(qa_row_preview["source_kind"]), HexMapPreviewThumbnail.SOURCE_MAP_DATA, "GEN-NEXT-11 QA score row preview comes from generated map data")
	_assert_true(not bool(qa_row_preview["sample_source"]), "GEN-NEXT-11 QA score row preview does not use sample source")
	snapshot = workspace.qa_screen_snapshot()
	seed_lab = snapshot["seed_lab"] as Dictionary
	_assert_eq(int(seed_lab["score_row_count"]), 2, "TAB-55 QA snapshot reports score row count")
	_assert_eq(int(snapshot["score_table_row_count"]), 2, "SCREEN-24 QA screen reports score table row count")
	_assert_true((snapshot["score_rows"] as Array).size() == 2, "TAB-55 QA screen exposes score rows")
	_assert_eq((snapshot["score_row_previews"] as Array).size(), 2, "GEN-NEXT-11 QA screen exposes score row previews")
	var scored_table = snapshot["scored_table"] as Dictionary
	_assert_eq(String(scored_table["surface_id"]), "qa_scored_table", "QA-NEXT-10 exposes scored table surface")
	_assert_eq(int(scored_table["row_count"]), 2, "QA-NEXT-10 scored table has one row per seed")
	_assert_eq(int(scored_table["preview_available_count"]), 2, "QA-NEXT-10 scored table rows expose generated previews")
	_assert_eq(int(scored_table["selected_row_index"]), 0, "QA-NEXT-10 scored table marks auto-selected top seed")
	_assert_eq(int(snapshot["mounted_score_tree_row_count"]), 2, "QA-NEXT-10 mounted score table renders batch rows")
	_assert_true(String(snapshot["score_table_rows_text"]).contains("promotion ready to promote"), "QA-NEXT-10 score table row text exposes promotion readiness")
	_assert_true(String(snapshot["mounted_score_table_rows_text"]).contains("validation "), "QA-NEXT-10 mounted score table text exposes validation status")
	var scored_rows = scored_table["rows"] as Array
	var top_scored_row = scored_rows[0] as Dictionary
	_assert_true(bool(top_scored_row["selected"]), "QA-NEXT-10 top scored row is selected after batch")
	_assert_true(bool(top_scored_row["preview_available"]), "QA-NEXT-10 scored row exposes preview availability")
	_assert_true(String(top_scored_row["generation_result_id"]) != "", "GENPIPE-NEXT-10 QA scored row exposes result id")
	_assert_true(bool(top_scored_row["result_resource_present"]), "GENPIPE-NEXT-10 QA scored row reports result resource")
	_assert_true(bool(top_scored_row["replay_available"]), "GENPIPE-NEXT-10 QA scored row reports replay availability")
	_assert_true(
		bool((top_scored_row["result_scope"] as Dictionary).get("candidate_document_present", false)),
		"GENPIPE-NEXT-10 QA scored row exposes candidate scope"
	)
	_assert_eq(
		String(top_scored_row["validation"]),
		"%dE/%dW" % [
			int(top_scored_row["validation_errors"]),
			int(top_scored_row["validation_warnings"]),
		],
		"QA-NEXT-10 scored row exposes validation status"
	)
	var qa_selected_preview = snapshot["selected_seed_preview"] as Dictionary
	_assert_true(bool(qa_selected_preview["available"]), "GEN-NEXT-11 QA selected seed preview is available")
	_assert_eq(String(qa_selected_preview["source_context"]), "qa_selected_seed", "GEN-NEXT-11 QA selected preview is context-bound")
	_assert_true(bool(snapshot["selected_seed_available"]), "SCREEN-24 QA screen reports selected seed after batch")
	_assert_true(bool(seed_lab["can_promote"]), "TAB-55 QA Seed Lab can promote selected row")
	_assert_true(bool(snapshot["promote_to_document_available"]), "SCREEN-24 QA screen enables promotion after seed selection")
	var mounted_qa_thumbnail := _find_preview_thumbnail(workspace, "QA Selected Seed Thumbnail")
	_assert_true(mounted_qa_thumbnail != null, "GEN-NEXT-11 mounted QA thumbnail exists")
	_assert_true(bool(mounted_qa_thumbnail.preview_snapshot()["available"]), "GEN-NEXT-11 mounted QA thumbnail uses selected seed preview")

	var seed_select = workspace.select_qa_seed_row(1)
	_assert_true(bool(seed_select["ok"]), "TAB-55 QA Seed Lab selects score row")
	var selected_scored_table = seed_select["scored_table"] as Dictionary
	_assert_eq(int(selected_scored_table["selected_row_index"]), 1, "QA-NEXT-10 scored table updates selected row index")
	var selected_scored_rows = selected_scored_table["rows"] as Array
	_assert_eq(String((selected_scored_rows[1] as Dictionary)["selected_state"]), "selected", "QA-NEXT-10 selected row text state updates")
	var selected_seed = int((seed_select["selected_seed_row"] as Dictionary).get("seed", 0))
	var selected_generation_result_id = String((seed_select["selected_seed_row"] as Dictionary).get("generation_result_id", ""))
	var promote_result = workspace.promote_qa_selected_seed_to_document()
	_assert_true(bool(promote_result["ok"]), "TAB-55 QA Seed Lab promotes selected row")
	var promoted_document = promote_result["document"] as HexMapDocumentResource
	_assert_true(promoted_document is HexMapDocumentResource, "TAB-55 promotion creates Level Document")
	_assert_eq(promoted_document.metadata.generation_seed, selected_seed, "TAB-55 promoted document records selected seed")
	_assert_eq(
		String(promoted_document.metadata.custom_properties.get("generation_result_id", "")),
		selected_generation_result_id,
		"GENPIPE-NEXT-10 promoted document records generation result id"
	)
	_assert_eq(
		String(promoted_document.metadata.custom_properties.get("generation_result_source", "")),
		"HexGenerationResultResource",
		"GENPIPE-NEXT-10 promoted document records result resource source"
	)
	_assert_eq(workspace.workspace_asset_context().level_document, promoted_document, "TAB-55 promotion updates Resources Level Document context")
	snapshot = workspace.qa_screen_snapshot()
	_assert_true(bool(snapshot["promotion_updates_resources"]), "TAB-55 QA snapshot reports Resources document update")
	_assert_true(bool(snapshot["promotion_updates_resources"]), "SCREEN-24 promotion updates Resources Level Document")
	_assert_eq(String(snapshot["qa_promotion_boundary"]), "Promote selected QA seed to Level Document", "SCREEN-24 QA names promotion boundary")
	scored_table = snapshot["scored_table"] as Dictionary
	_assert_eq(int(scored_table["promoted_row_index"]), 1, "QA-NEXT-10 scored table marks promoted row")
	scored_rows = scored_table["rows"] as Array
	var promoted_scored_row = scored_rows[1] as Dictionary
	_assert_true(bool(promoted_scored_row["promoted"]), "QA-NEXT-10 promoted row carries promoted flag")
	_assert_eq(String(promoted_scored_row["promotion_state"]), "promoted", "QA-NEXT-10 promoted row has promotion state")
	_assert_true(String(snapshot["mounted_score_table_rows_text"]).contains("promotion promoted"), "QA-NEXT-10 mounted table text exposes promoted state")
	seed_lab = snapshot["seed_lab"] as Dictionary
	_assert_true(bool((seed_lab["promotion_target"] as Dictionary).get("promoted", false)), "TAB-55 promotion target marks promoted document")
	_assert_eq(
		String((seed_lab["promotion_target"] as Dictionary).get("generation_result_id", "")),
		selected_generation_result_id,
		"GENPIPE-NEXT-10 QA promotion target exposes result id"
	)

	var clear_profile = workspace.clear_generation_profile()
	_assert_true(bool(clear_profile["ok"]), "QA screen clears Generation Profile")
	_assert_eq(workspace.workspace_asset_context().generation_profile, null, "cleared generation profile leaves workspace context")
	var clear_suite = workspace.clear_validation_rule_suite()
	_assert_true(bool(clear_suite["ok"]), "QA screen clears Validation Rule Suite")
	_assert_eq(workspace.workspace_asset_context().validation_rule_suite, null, "cleared validation suite leaves workspace context")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "QA screen actions do not enable sample mode")

	workspace.queue_free()
	await process_frame


