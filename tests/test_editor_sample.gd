extends "res://tests/test_editor_plugin_test_base.gd"

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	await _test_workspace_sample_settings_panel_controls_sample_mode_sources()
	await _test_sample_learning_package_contract_keeps_bundled_assets_opt_in()
	await _test_clean_project_package_contract_uses_project_assets_without_samples()
	await _test_debug_numeric_fallback_quarantine_requires_settings_opt_in()
	await _test_sample_asset_duplicator_copies_catalog_dependencies_to_project()
	await _test_sample_settings_duplicate_button_creates_project_catalog()
	await _test_feature_screen_completion_contract_uses_project_assets_with_sample_mode_off()
	_finish("res://tests/test_editor_sample.gd")

func _test_feature_screen_completion_contract_uses_project_assets_with_sample_mode_off() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	_assert_true(not session.show_bundled_samples_in_main_selectors, "TEST-40 starts with sample mode OFF")
	_assert_true(not workspace.generation_dock().main_sample_controls_visible(), "TEST-40 Generate main UI hides sample controls")
	_assert_true(not workspace.edit_tool().main_sample_controls_visible(), "TEST-40 Paint main UI hides sample controls")

	var output_dir = _test_resource_dir("test40_project_asset_contract")
	var document_path = "%s/level_document.tres" % output_dir
	var document_result = workspace.create_level_document(document_path)
	_assert_true(bool(document_result["ok"]), "TEST-40 creates project Level Document")
	var document = document_result["resource"] as HexMapDocumentResource
	_assert_true(document is HexMapDocumentResource, "TEST-40 Level Document uses document resource")

	var catalog_path = "%s/tile_catalog.tres" % output_dir
	var catalog_result = workspace.create_tile_catalog(catalog_path)
	_assert_true(bool(catalog_result["ok"]), "TEST-40 creates project Tile Catalog")
	var catalog = catalog_result["resource"] as HexTileCatalogResource
	_assert_true(catalog is HexTileCatalogResource, "TEST-40 Tile Catalog uses catalog resource")
	var tile_set := _test_catalog_tileset()
	_assert_true(bool(workspace.set_catalog_tile_set(tile_set)["ok"]), "TEST-40 Catalog accepts arbitrary TileSet")
	_assert_eq(catalog.tile_set, tile_set, "TEST-40 Catalog stores arbitrary TileSet selection")

	var layer_stack_path = "%s/layer_stack.tres" % output_dir
	var layer_stack_result = workspace.create_layer_stack(layer_stack_path)
	_assert_true(bool(layer_stack_result["ok"]), "TEST-40 creates project Layer Stack")
	var layer_stack = layer_stack_result["resource"] as HexLayerStackResource
	_assert_true(layer_stack is HexLayerStackResource, "TEST-40 Layer Stack uses layer stack resource")

	var object_db_path = "%s/object_database.tres" % output_dir
	var object_db_result = workspace.create_object_database(object_db_path)
	_assert_true(bool(object_db_result["ok"]), "TEST-40 creates project Object Database")
	var object_database = object_db_result["resource"] as HexObjectDatabaseResource
	_assert_true(object_database is HexObjectDatabaseResource, "TEST-40 Object Database uses object database resource")

	var label_db_path = "%s/label_database.tres" % output_dir
	var label_db_result = workspace.create_label_database(label_db_path)
	_assert_true(bool(label_db_result["ok"]), "TEST-40 creates project Label Database")
	var label_database = label_db_result["resource"] as HexLabelDatabaseResource
	_assert_true(label_database is HexLabelDatabaseResource, "TEST-40 Label Database uses label database resource")

	var validation_suite_path = "%s/validation_suite.tres" % output_dir
	var validation_suite_result = workspace.create_validation_rule_suite(validation_suite_path)
	_assert_true(bool(validation_suite_result["ok"]), "TEST-40 creates project Validation Rule Suite")
	var validation_suite = validation_suite_result["resource"] as HexValidationRuleSuiteResource
	_assert_true(validation_suite is HexValidationRuleSuiteResource, "TEST-40 Validation Rule Suite uses concrete resource")

	var generation_profile_path = "%s/generation_profile.tres" % output_dir
	var generation_profile_result = workspace.create_generation_profile(generation_profile_path)
	_assert_true(bool(generation_profile_result["ok"]), "TEST-40 creates project Generation Profile")
	var generation_profile = generation_profile_result["resource"] as HexGenerationProfileResource
	_assert_true(generation_profile is HexGenerationProfileResource, "TEST-40 Generation Profile uses concrete resource")

	var export_profile_path = "%s/export_profile.tres" % output_dir
	var export_profile_result = workspace.create_export_profile(export_profile_path)
	_assert_true(bool(export_profile_result["ok"]), "TEST-40 creates project Export Profile")
	var export_profile = export_profile_result["resource"] as HexExportProfileResource
	_assert_true(export_profile is HexExportProfileResource, "TEST-40 Export Profile uses concrete resource")

	_assert_project_asset_slot(
		workspace,
		"Document",
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
		document,
		document_path,
		"TEST-40 Document screen Level Document"
	)
	_assert_project_asset_slot(
		workspace,
		"Catalog",
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		catalog,
		catalog_path,
		"TEST-40 Catalog screen Tile Catalog"
	)
	_assert_project_asset_slot(
		workspace,
		"Layers",
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
		layer_stack,
		layer_stack_path,
		"TEST-40 Layers screen Layer Stack"
	)
	_assert_project_asset_slot(
		workspace,
		"Resources",
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE,
		object_database,
		object_db_path,
		"TAB-51 Resources screen Object Database"
	)
	_assert_project_asset_slot(
		workspace,
		"Resources",
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE,
		label_database,
		label_db_path,
		"TAB-51 Resources screen Label Database"
	)
	_assert_project_asset_slot(
		workspace,
		"Validate",
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE,
		validation_suite,
		validation_suite_path,
		"TEST-40 Validate screen Validation Rule Suite"
	)
	_assert_project_asset_slot(
		workspace,
		"QA",
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE,
		generation_profile,
		generation_profile_path,
		"TEST-40 QA screen Generation Profile"
	)
	_assert_project_asset_slot(
		workspace,
		"Export",
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
		document,
		document_path,
		"TEST-40 Export screen Level Document"
	)
	_assert_project_asset_slot(
		workspace,
		"Export",
		HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE,
		export_profile,
		export_profile_path,
		"TEST-40 Export screen Export Profile"
	)
	_assert_eq(workspace.generation_dock().tile_catalog(), catalog, "TEST-40 Generate consumes project catalog, not sample fallback")
	_assert_eq(workspace.edit_tool().tile_catalog(), catalog, "TEST-40 Paint consumes project catalog, not sample fallback")

	var export_path = "%s/runtime_handoff.tres" % output_dir
	var destination_result = workspace.select_export_destination(export_path)
	_assert_true(bool(destination_result["ok"]), "TEST-40 selects user export destination")
	var export_snapshot = workspace.export_screen_snapshot()
	var destination = export_snapshot["destination"] as Dictionary
	_assert_true(bool(destination.get("selected", false)), "TEST-40 Export destination is selected")
	_assert_eq(String(destination.get("path", "")), export_path, "TEST-40 Export destination uses user project path")
	_assert_true(not _is_bundled_sample_asset_path(String(destination.get("path", ""))), "TEST-40 Export destination is not a bundled sample path")

	_assert_true(not session.show_bundled_samples_in_main_selectors, "TEST-40 project asset contract keeps sample mode OFF")
	_assert_true(not workspace.generation_dock().main_sample_controls_visible(), "TEST-40 Generate sample controls remain hidden")
	_assert_true(not workspace.edit_tool().main_sample_controls_visible(), "TEST-40 Paint sample controls remain hidden")

	workspace.queue_free()
	await process_frame


func _test_workspace_sample_settings_panel_controls_sample_mode_sources() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var panel = workspace.sample_settings_panel()
	_assert_true(panel is HexMapSampleSettingsPanel, "workspace exposes sample settings panel")
	var settings_snapshot = workspace.settings_screen_snapshot()
	_assert_true(workspace.tab_has_component("Settings", "settings_preferences_panel"), "TAB-57 Settings exposes preferences/debug purpose panel")
	_assert_eq(settings_snapshot["asset_slot_ids"], PackedStringArray(), "TAB-57 Settings has no production asset slot ids")
	_assert_true(not bool(settings_snapshot["production_asset_selection_present"]), "TAB-57 Settings has no production asset selection")
	_assert_eq(String(settings_snapshot["movement_profile_slot_owner"]), "Resources", "TAB-57 Movement Profile belongs to Resources")
	_assert_true(
		(settings_snapshot["resources_tab_asset_slot_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE),
		"TAB-57 Resources exposes Movement Profile"
	)
	_assert_true(bool(settings_snapshot["sample_learning_controls_present"]), "TAB-57 Settings keeps sample learning controls")
	var settings_sample_state = settings_snapshot["sample_state"] as Dictionary
	_assert_eq(String(settings_sample_state["state_source"]), "HexMapSampleLearningState", "STATE-50 Settings reports sample state source")
	_assert_eq(String(settings_sample_state["state_id"]), HexMapSampleLearningState.STATE_LEARNING_AVAILABLE, "STATE-50 first-run Settings reports learning available")
	var settings_group_ids = settings_snapshot["settings_group_ids"] as PackedStringArray
	for group_id in ["sample_learning", "debug", "project_defaults", "ui_preferences"]:
		_assert_true(settings_group_ids.has(group_id), "SETTINGS-NEXT-10 Settings exposes group: %s" % group_id)
	_assert_true(bool(settings_snapshot["settings_groups_separated"]), "SETTINGS-NEXT-10 Settings groups are separated")
	_assert_true(bool(settings_snapshot["sample_learning_group_present"]), "SETTINGS-NEXT-10 Sample Learning group is present")
	_assert_true(bool(settings_snapshot["debug_group_present"]), "SETTINGS-NEXT-10 Debug group is present")
	_assert_true(bool(settings_snapshot["project_defaults_group_present"]), "SETTINGS-NEXT-10 Project Defaults group is present")
	_assert_true(bool(settings_snapshot["ui_preferences_group_present"]), "SETTINGS-NEXT-10 UI Preferences group is present")
	_assert_eq(int(settings_snapshot["boolean_control_count"]), 4, "SETTINGS-NEXT-10 Settings exposes four boolean controls")
	_assert_true(bool(settings_snapshot["boolean_controls_use_checkboxes"]), "SETTINGS-NEXT-10 Settings booleans use CheckBox controls")
	_assert_true(bool(settings_snapshot["boolean_controls_have_tooltips"]), "SETTINGS-NEXT-10 Settings boolean controls have tooltip detail")
	_assert_true(bool(settings_snapshot["debug_numeric_fallback_isolated"]), "TAB-57 debug numeric fallback is isolated in Settings controls")
	_assert_true(bool(settings_snapshot["sample_actions_work_or_removed"]), "TAB-57 sample actions are functional or removed")
	_assert_true(not bool(settings_snapshot["settings_debug_label_visible"]), "UI-02 Settings hides redundant debug enabled/disabled label")
	_assert_eq(String(settings_snapshot["settings_debug_label_text"]), "", "UI-02 Settings debug label has no visible boolean text")
	_assert_true(not bool(settings_snapshot["boolean_state_text_visible"]), "UI-02 Settings booleans are represented by CheckBoxes")
	_assert_true(not bool(settings_snapshot["debug_payload_visible_in_normal_ui"]), "UI-02 Settings debug payload is not normal UI text")
	var snapshot = panel.snapshot()
	var panel_group_ids = snapshot["settings_group_ids"] as PackedStringArray
	_assert_true(panel_group_ids.has("sample_learning"), "SETTINGS-NEXT-10 sample panel exposes Sample Learning group")
	_assert_true(panel_group_ids.has("debug"), "SETTINGS-NEXT-10 sample panel exposes Debug group")
	_assert_true(bool(snapshot["boolean_controls_have_tooltips"]), "SETTINGS-NEXT-10 sample panel checkbox controls have tooltip detail")
	var boolean_controls = snapshot["boolean_controls"] as Array
	for control in boolean_controls:
		var row = control as Dictionary
		_assert_eq(String(row["control_type"]), "CheckBox", "SETTINGS-NEXT-10 boolean control is a CheckBox")
		_assert_true(String(row["tooltip"]) != "", "SETTINGS-NEXT-10 boolean CheckBox has tooltip")
	var panel_sample_state = snapshot["sample_state"] as Dictionary
	_assert_eq(String(panel_sample_state["state_id"]), HexMapSampleLearningState.STATE_OFF, "STATE-50 sample panel starts off")
	_assert_true(
		not bool(snapshot["show_bundled_samples_in_main_selectors"]),
		"sample visibility is off by default"
	)
	_assert_true(
		not bool(snapshot["use_bundled_sample_assets_for_scratch_documents"]),
		"scratch sample assets are off by default"
	)
	_assert_true(
		not bool(snapshot["auto_create_project_copy_when_applying_sample"]),
		"auto project copy is off by default"
	)
	_assert_true(
		not bool(snapshot["debug_numeric_tile_fallback_enabled"]),
		"debug numeric fallback is off by default"
	)
	_assert_true(not bool(snapshot["boolean_state_text_visible"]), "UI-02 sample settings booleans are CheckBox state, not labels")
	_assert_true(not bool(snapshot["sample_asset_paths_visible"]), "UI-02 sample paths are not visible row text")
	var sample_rows = snapshot["sample_action_rows"] as Array
	_assert_true(String((sample_rows[0] as Dictionary)["visible_label_text"]).contains("Bundled Sample Catalog"), "UI-02 sample row keeps learning asset label")
	_assert_true(not String((sample_rows[0] as Dictionary)["visible_label_text"]).contains("res://"), "UI-02 sample row visible label omits path")
	_assert_true(String((sample_rows[0] as Dictionary)["label_tooltip"]).contains("res://"), "UI-02 sample row tooltip keeps path detail")
	_assert_true(not bool((sample_rows[0] as Dictionary)["path_visible"]), "UI-02 sample row marks path hidden")
	var detail_rows = snapshot["sample_detail_rows"] as Array
	_assert_eq(detail_rows.size(), 3, "SAMPLE-NEXT-10 sample detail rows cover bundled sample assets")
	var catalog_detail = snapshot["sample_detail_drawer"] as Dictionary
	_assert_eq(String(catalog_detail["surface_id"]), "sample_detail_drawer", "SAMPLE-NEXT-10 exposes sample detail drawer")
	_assert_eq(String(catalog_detail["asset_type"]), "HexTileCatalogResource", "SAMPLE-NEXT-10 catalog detail exposes asset type")
	_assert_eq(int(catalog_detail["dependency_count"]), 2, "SAMPLE-NEXT-10 catalog detail exposes dependencies")
	_assert_true(bool(catalog_detail["duplicate_available"]), "SAMPLE-NEXT-10 catalog detail exposes duplicate availability")
	_assert_true(String(catalog_detail["duplicate_target"]).contains("sample_hex_tile_catalog_project_copy"), "SAMPLE-NEXT-10 catalog detail exposes duplicate target")
	_assert_true(String(catalog_detail["learning_use"]).contains("Learning source"), "SAMPLE-NEXT-10 catalog detail exposes learning use")
	_assert_true(not bool(catalog_detail["production_injection"]), "SAMPLE-NEXT-10 sample detail does not inject production source")
	_assert_true(String(snapshot["mounted_sample_detail_text"]).contains("dependencies:"), "SAMPLE-NEXT-10 mounted detail text exposes dependencies")
	var settings_detail_snapshot = workspace.settings_screen_snapshot()
	_assert_true(bool(settings_detail_snapshot["sample_detail_visible"]), "SAMPLE-NEXT-10 Settings snapshot exposes sample detail visibility")
	_assert_true(String(settings_detail_snapshot["mounted_sample_detail_text"]).contains("duplicate target"), "SAMPLE-NEXT-10 Settings snapshot exposes mounted detail text")
	var scene_detail_result = panel.select_sample_detail(HexMapSampleSettingsPanel.SAMPLE_OBJECT_SCENE_ID)
	_assert_true(bool(scene_detail_result["ok"]), "SAMPLE-NEXT-10 sample detail can select object scene")
	var scene_detail = scene_detail_result["detail"] as Dictionary
	_assert_eq(String(scene_detail["asset_type"]), "PackedScene", "SAMPLE-NEXT-10 object scene detail exposes asset type")
	_assert_eq(int(scene_detail["dependency_count"]), 0, "SAMPLE-NEXT-10 object scene detail exposes dependency count")
	snapshot = panel.snapshot()
	_assert_true(String(snapshot["mounted_sample_detail_text"]).contains("PackedScene"), "SAMPLE-NEXT-10 mounted detail text updates selected sample")
	_assert_eq(Array(snapshot["sample_assets"]).size(), 3, "sample settings lists bundled sample assets")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "sample mode OFF hides generation sample catalog fallback")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "sample mode OFF hides paint sample catalog fallback")
	_assert_true(
		not workspace.generation_dock().main_sample_controls_visible(),
		"workspace generation main UI hides sample controls"
	)
	_assert_true(
		not workspace.edit_tool().main_sample_controls_visible(),
		"workspace paint main UI hides sample controls"
	)

	panel.set_show_bundled_samples_in_main_selectors(true)
	snapshot = panel.snapshot()
	panel_sample_state = snapshot["sample_state"] as Dictionary
	_assert_eq(String(panel_sample_state["state_id"]), HexMapSampleLearningState.STATE_LEARNING_AVAILABLE, "STATE-50 sample panel reports learning available when sample selectors are shown")
	_assert_true(bool(snapshot["show_bundled_samples_in_main_selectors"]), "sample setting can enable sample selector visibility")
	_assert_true(bool(workspace.catalog_screen_snapshot()["sample_candidates_visible"]), "sample mode ON exposes Catalog learning candidates")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "SAMPLE-41 sample mode ON does not inject Generate sample catalog")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "SAMPLE-41 sample mode ON does not inject Paint sample catalog")

	var project_catalog = HexTileCatalogResource.new()
	session.set_workspace_asset(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, project_catalog, "test.project_catalog")
	_assert_eq(workspace.generation_dock().tile_catalog(), project_catalog, "project catalog remains primary for generation when sample mode is ON")
	_assert_eq(workspace.edit_tool().tile_catalog(), project_catalog, "project catalog remains primary for paint when sample mode is ON")

	panel.set_show_bundled_samples_in_main_selectors(false)
	_assert_eq(workspace.generation_dock().tile_catalog(), project_catalog, "project catalog remains primary for generation when sample mode is OFF")
	_assert_eq(workspace.edit_tool().tile_catalog(), project_catalog, "project catalog remains primary for paint when sample mode is OFF")
	session.set_workspace_asset(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, null, "test.clear_project_catalog")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "cleared project catalog does not reveal generation sample fallback while sample mode is OFF")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "cleared project catalog does not reveal paint sample fallback while sample mode is OFF")

	panel.set_debug_numeric_tile_fallback_enabled(true)
	snapshot = panel.snapshot()
	settings_snapshot = workspace.settings_screen_snapshot()
	_assert_true(bool(snapshot["debug_numeric_tile_fallback_enabled"]), "Settings can enable explicit debug numeric fallback")
	_assert_true(bool(settings_snapshot["debug_numeric_tile_fallback_enabled"]), "TAB-57 Settings snapshot mirrors debug numeric fallback")
	panel.set_debug_numeric_tile_fallback_enabled(false)
	settings_snapshot = workspace.settings_screen_snapshot()
	_assert_true(not session.debug_numeric_tile_fallback_enabled, "Settings can disable debug numeric fallback")
	_assert_true(not bool(settings_snapshot["debug_numeric_tile_fallback_enabled"]), "TAB-57 Settings snapshot disables debug numeric fallback")

	workspace.queue_free()
	await process_frame


func _test_sample_learning_package_contract_keeps_bundled_assets_opt_in() -> void:
	var sample_catalog_path := "res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres"
	var sample_texture_path := HexMapTileAdapter.SAMPLE_TILE_ATLAS_PATH
	var sample_scene_path := "res://addons/hex_map_kit/assets/sample_spawn_marker.tscn"
	_assert_true(ResourceLoader.exists(sample_catalog_path), "PKG-70 sample catalog exists for package learning")
	_assert_true(ResourceLoader.exists(sample_texture_path), "PKG-70 sample tile texture exists for package learning")
	_assert_true(ResourceLoader.exists(sample_scene_path), "PKG-70 sample object scene exists for package learning")

	var sample_catalog = ResourceLoader.load(sample_catalog_path, "HexTileCatalogResource", ResourceLoader.CACHE_MODE_IGNORE) as HexTileCatalogResource
	_assert_true(sample_catalog is HexTileCatalogResource, "PKG-70 sample catalog loads as tile catalog")
	_assert_true(sample_catalog.tile_set is TileSet, "PKG-70 sample catalog owns TileSet")
	_assert_true(sample_catalog.has_key("terrain.floor"), "PKG-70 sample catalog exposes floor learning key")
	_assert_true(sample_catalog.has_key("terrain.wall"), "PKG-70 sample catalog exposes wall learning key")
	var texture = ResourceLoader.load(sample_texture_path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
	_assert_true(texture is Texture2D, "PKG-70 sample tile texture loads")
	var sample_scene = ResourceLoader.load(sample_scene_path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
	_assert_true(sample_scene is PackedScene, "PKG-70 sample object scene loads")
	var scene_instance = sample_scene.instantiate()
	_assert_true(scene_instance is Node, "PKG-70 sample object scene instantiates")
	scene_instance.free()

	var scene_entry = sample_catalog.entry_for_key("object.spawn_marker")
	_assert_true(scene_entry != null, "PKG-70 sample catalog includes object scene entry")
	_assert_eq(
		(scene_entry.get("scene") as PackedScene).resource_path,
		sample_scene_path,
		"PKG-70 sample scene entry points to packaged scene"
	)

	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var panel = workspace.sample_settings_panel()
	var snapshot = panel.snapshot()
	_assert_true(_sample_asset_rows_have_path(snapshot["sample_assets"] as Array, sample_catalog_path), "PKG-70 sample settings list catalog")
	_assert_true(_sample_asset_rows_have_path(snapshot["sample_assets"] as Array, sample_texture_path), "PKG-70 sample settings list tile texture")
	_assert_true(_sample_asset_rows_have_path(snapshot["sample_assets"] as Array, sample_scene_path), "PKG-70 sample settings list object scene")
	_assert_true(not bool(snapshot["show_bundled_samples_in_main_selectors"]), "PKG-70 sample mode starts OFF")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "PKG-70 sample mode OFF does not inject Generate sample catalog")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "PKG-70 sample mode OFF does not inject Paint sample catalog")

	panel.set_show_bundled_samples_in_main_selectors(true)
	_assert_true(bool(workspace.catalog_screen_snapshot()["sample_candidates_visible"]), "PKG-70 sample mode ON exposes Catalog learning candidates")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "SAMPLE-41 PKG-70 sample mode ON does not inject Generate sample catalog")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "SAMPLE-41 PKG-70 sample mode ON does not inject Paint sample catalog")

	var project_catalog = HexTileCatalogResource.new()
	session.set_workspace_asset(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, project_catalog, "pkg70.project_catalog")
	_assert_eq(workspace.generation_dock().tile_catalog(), project_catalog, "PKG-70 project catalog stays primary in Generate")
	_assert_eq(workspace.edit_tool().tile_catalog(), project_catalog, "PKG-70 project catalog stays primary in Paint")

	workspace.queue_free()
	await process_frame


func _test_clean_project_package_contract_uses_project_assets_without_samples() -> void:
	var config = ConfigFile.new()
	_assert_eq(config.load("res://addons/hex_map_kit/plugin.cfg"), OK, "PKG-71 plugin config loads in clean project contract")
	var script_path = "res://addons/hex_map_kit/%s" % config.get_value("plugin", "script", "")
	_assert_true(load(script_path) != null, "PKG-71 plugin script loads in clean project contract")

	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	_assert_true(not session.show_bundled_samples_in_main_selectors, "PKG-71 clean project starts with sample mode OFF")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "PKG-71 clean project has no Generate sample injection")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "PKG-71 clean project has no Paint sample injection")

	var initial_validation = workspace.run_validate_screen()
	_assert_true(bool(initial_validation["ok"]), "PKG-71 clean project validation runs before asset selection")
	var initial_rows = initial_validation["issue_rows"] as Array
	_assert_true(
		not _validation_issue_row_for_rule(initial_rows, "workspace.level_document_missing").is_empty(),
		"PKG-71 clean project reports missing document before selection"
	)
	_assert_true(
		not _validation_issue_row_for_rule(initial_rows, "workspace.tile_catalog_missing").is_empty(),
		"PKG-71 clean project reports missing catalog before selection"
	)
	_assert_true(
		not _validation_issue_row_for_rule(initial_rows, "workspace.object_database_missing").is_empty(),
		"PKG-71 clean project reports missing object database before selection"
	)

	var output_dir = _test_resource_dir("pkg71_clean_project")
	var document_path = "%s/clean_level_document.tres" % output_dir
	var document_result = workspace.create_level_document(document_path)
	_assert_true(bool(document_result["ok"]), "PKG-71 creates clean project Level Document")
	var document = document_result["resource"] as HexMapDocumentResource
	_assert_true(document is HexMapDocumentResource, "PKG-71 Level Document is project resource")

	var catalog_path = "%s/clean_tile_catalog.tres" % output_dir
	var catalog_result = workspace.create_tile_catalog(catalog_path)
	_assert_true(bool(catalog_result["ok"]), "PKG-71 creates clean project Tile Catalog")
	var catalog = catalog_result["resource"] as HexTileCatalogResource
	_assert_true(catalog is HexTileCatalogResource, "PKG-71 Tile Catalog is project resource")
	var tile_set := _test_catalog_tileset()
	_assert_true(bool(workspace.set_catalog_tile_set(tile_set)["ok"]), "PKG-71 assigns user TileSet")
	_assert_eq(catalog.tile_set, tile_set, "PKG-71 catalog stores user TileSet")
	_assert_true(
		bool(workspace.create_catalog_atlas_entry_from_tileset("terrain.clean_floor", tile_set, 0, Vector2i.ZERO)["ok"]),
		"PKG-71 creates catalog entry from user TileSet"
	)

	var object_db_path = "%s/clean_object_database.tres" % output_dir
	var object_db_result = workspace.create_object_database(object_db_path)
	_assert_true(bool(object_db_result["ok"]), "PKG-71 creates clean project Object Database")
	var object_database = object_db_result["resource"] as HexObjectDatabaseResource
	_assert_true(object_database is HexObjectDatabaseResource, "PKG-71 Object Database is project resource")

	var marker := Node2D.new()
	marker.name = "CleanProjectObject"
	var scene := PackedScene.new()
	_assert_eq(scene.pack(marker), OK, "PKG-71 packs user object scene")
	marker.free()
	var scene_path = "%s/clean_project_object.tscn" % output_dir
	_assert_eq(ResourceSaver.save(scene, scene_path), OK, "PKG-71 saves user object scene")
	scene.resource_path = scene_path
	var definition_result = workspace.create_object_definition_from_packed_scene("object.clean_project", scene, "Clean Project Object")
	_assert_true(bool(definition_result["ok"]), "PKG-71 creates object definition from user PackedScene")
	var object_definition = definition_result["definition"] as HexObjectDefinitionResource
	_assert_true(object_definition is HexObjectDefinitionResource, "PKG-71 object definition is typed")
	_assert_eq(object_definition.scene, scene, "PKG-71 object definition stores user scene")

	_assert_project_asset_slot(
		workspace,
		"Document",
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
		document,
		document_path,
		"PKG-71 clean project Document slot"
	)
	_assert_project_asset_slot(
		workspace,
		"Catalog",
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		catalog,
		catalog_path,
		"PKG-71 clean project Catalog slot"
	)
	_assert_project_asset_slot(
		workspace,
		"Resources",
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE,
		object_database,
		object_db_path,
		"TAB-51 PKG-71 clean project Object Database slot"
	)
	_assert_eq(workspace.generation_dock().tile_catalog(), catalog, "PKG-71 Generate uses project catalog after selection")
	_assert_eq(workspace.edit_tool().tile_catalog(), catalog, "PKG-71 Paint uses project catalog after selection")

	var after_selection = workspace.run_validate_screen()
	var after_result = after_selection["result"] as HexMapValidationResult
	_assert_true(after_result is HexMapValidationResult, "PKG-71 clean project validation returns result after selection")
	_assert_true(
		not _validation_result_has_rule(after_result, "workspace.level_document_missing"),
		"PKG-71 selected document clears missing document validation"
	)
	_assert_true(
		not _validation_result_has_rule(after_result, "workspace.tile_catalog_missing"),
		"PKG-71 selected catalog clears missing catalog validation"
	)
	_assert_true(
		not _validation_result_has_rule(after_result, "workspace.object_database_missing"),
		"PKG-71 selected object database clears missing object validation"
	)
	_assert_true(not session.show_bundled_samples_in_main_selectors, "PKG-71 clean project flow keeps sample mode OFF")

	workspace.queue_free()
	await process_frame


func _test_debug_numeric_fallback_quarantine_requires_settings_opt_in() -> void:
	var session = HexMapEditorSessionState.new()
	var panel = HexMapSampleSettingsPanel.new()
	panel.set_editor_session_state(session)
	root.add_child(panel)
	await process_frame

	var data = HexMapData.rectangle(1, 1)
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_tile_override(document, HexVector.zero(), {
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 8,
		"atlas_coords": Vector2i(4, 5),
	})
	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	var image = Image.create(384, 384, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture = ImageTexture.create_from_image(image)
	HexMapTileAdapter.configure_atlas_tile_set(
		layer.tile_set,
		texture,
		true,
		Vector2i(64, 64),
		8,
		[Vector2i(4, 5)]
	)
	root.add_child(layer)
	var tool = await _new_ready_edit_tool()
	tool.set_editor_session_state(session)
	tool.set_document(document)
	tool.set_target_layer(layer)

	_assert_true(not session.debug_numeric_tile_fallback_enabled, "numeric fallback quarantine starts disabled")
	_assert_true(tool._apply_document_to_target(), "normal apply completes without numeric fallback")
	_assert_eq(layer.get_cell_source_id(Vector2i.ZERO), -1, "normal apply does not silently fill missing catalog through numeric fallback")
	var validation = HexMapDocumentValidator.validate_document(document)
	_assert_true(
		_validation_result_has_rule(validation, HexMapDocumentValidator.RULE_TILE_ASSIGNMENT_MISSING),
		"missing catalog assignment remains a validation issue"
	)

	panel.set_debug_numeric_tile_fallback_enabled(true)
	_assert_true(session.debug_numeric_tile_fallback_enabled, "debug fallback requires explicit Settings opt-in")
	_assert_true(tool._apply_document_to_target(), "debug apply completes with explicit numeric fallback")
	_assert_eq(layer.get_cell_source_id(Vector2i.ZERO), 8, "debug opt-in applies numeric fallback source")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(4, 5), "debug opt-in applies numeric fallback atlas")

	panel.queue_free()
	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_sample_asset_duplicator_copies_catalog_dependencies_to_project() -> void:
	var context = HexMapWorkspaceAssetContext.new()
	_assert_eq(context.tile_catalog, null, "sample duplicate does not silently assign catalog before action")
	var output_dir = _test_resource_dir("sample11_duplicate")
	var catalog_path = "%s/project_sample_catalog.tres" % output_dir
	var result = HexMapSampleAssetDuplicator.duplicate_sample_catalog_to_project(catalog_path, context)
	_assert_true(bool(result["ok"]), "sample duplicate succeeds")
	_assert_eq(int(result["error"]), OK, "sample duplicate reports OK")
	_assert_true(FileAccess.file_exists(String(result["catalog_path"])), "sample duplicate writes catalog")
	_assert_true(FileAccess.file_exists(String(result["texture_path"])), "sample duplicate copies sample tile texture")
	_assert_true(FileAccess.file_exists(String(result["scene_path"])), "sample duplicate copies sample object scene")
	_assert_true(not String(result["catalog_path"]).begins_with("res://addons/hex_map_kit/assets/"), "sample duplicate catalog path is project-owned")
	_assert_true(not String(result["texture_path"]).begins_with("res://addons/hex_map_kit/assets/"), "sample duplicate texture path is project-owned")
	_assert_true(not String(result["scene_path"]).begins_with("res://addons/hex_map_kit/assets/"), "sample duplicate scene path is project-owned")

	var catalog = result["catalog"] as HexTileCatalogResource
	_assert_true(catalog is HexTileCatalogResource, "sample duplicate returns catalog resource")
	_assert_eq(context.tile_catalog, catalog, "sample duplicate assigns project catalog to context")
	_assert_eq(catalog.resource_path, catalog_path, "sample duplicate catalog stores project path")
	_assert_eq(
		String(catalog.metadata.get("duplicated_from_sample", "")),
		"res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres",
		"sample duplicate records source sample path"
	)
	_assert_true(bool(catalog.metadata.get("project_copy", false)), "sample duplicate marks catalog as project copy")
	_assert_true(catalog.tile_set != null, "sample duplicate preserves embedded TileSet")
	var atlas_source = catalog.tile_set.get_source(0) as TileSetAtlasSource
	_assert_true(atlas_source is TileSetAtlasSource, "sample duplicate TileSet has atlas source")
	_assert_true(atlas_source.texture != null, "sample duplicate atlas source has texture")
	_assert_eq(atlas_source.texture.resource_path, String(result["texture_path"]), "sample duplicate TileSet texture points to project copy")
	var scene_source = catalog.tile_set.get_source(1) as TileSetScenesCollectionSource
	_assert_true(scene_source is TileSetScenesCollectionSource, "sample duplicate TileSet has scene source")
	_assert_true(scene_source.has_scene_tile_id(1), "sample duplicate scene source preserves scene tile id")
	var scene = scene_source.get_scene_tile_scene(1)
	_assert_true(scene is PackedScene, "sample duplicate scene source has PackedScene")
	_assert_eq(scene.resource_path, String(result["scene_path"]), "sample duplicate scene source points to project scene")
	var scene_entry = catalog.entry_for_key("object.spawn_marker")
	_assert_true(scene_entry != null, "sample duplicate preserves scene catalog entry")
	_assert_eq(scene_entry.get("scene").resource_path, String(result["scene_path"]), "sample duplicate scene entry points to project scene")
	var validation = HexTileCatalogValidator.validate_catalog(catalog)
	_assert_eq(validation.issue_count(), 0, "sample duplicate catalog validates cleanly")

	var session = HexMapEditorSessionState.new()
	var panel = HexMapSampleSettingsPanel.new()
	panel.set_editor_session_state(session)
	var panel_rows = panel.sample_asset_rows()
	_assert_true(bool(panel_rows[0].get("duplicate_available", false)), "sample settings exposes duplicate availability")
	_assert_true(not bool(panel_rows[1].get("duplicate_available", false)), "sample tile texture duplicates through catalog action")
	_assert_true(not bool(panel_rows[2].get("duplicate_available", false)), "sample object scene duplicates through catalog action")
	var panel_result = panel.duplicate_sample_catalog_to_project("%s/panel_sample_catalog.tres" % output_dir)
	_assert_true(bool(panel_result["ok"]), "sample settings panel can duplicate sample catalog")
	_assert_eq(
		session.current_workspace_asset_context().tile_catalog,
		panel_result["catalog"],
		"sample settings panel duplicate assigns catalog to session context"
	)
	context.set_tile_catalog(null)
	catalog.tile_set = null
	session.current_workspace_asset_context().set_tile_catalog(null)
	var panel_catalog = panel_result["catalog"] as HexTileCatalogResource
	if panel_catalog != null:
		panel_catalog.tile_set = null
	panel.free()


func _test_sample_settings_duplicate_button_creates_project_catalog() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var panel = workspace.sample_settings_panel()
	_assert_true(_has_button_text(panel, "Duplicate To Project"), "SAMPLE-40 Settings shows functional duplicate action")
	_assert_true(not _has_button_text(panel, "Open"), "SAMPLE-40 Settings keeps Open removed without focus/preview target")
	var row_actions = panel.sample_action_rows_snapshot()
	_assert_eq(row_actions.size(), 3, "SAMPLE-40 sample action snapshot covers sample rows")
	_assert_true(not String(row_actions[0]["visible_label_text"]).contains("res://"), "UI-02 sample action visible row hides path")
	_assert_true(String(row_actions[0]["label_tooltip"]).contains("res://"), "UI-02 sample action tooltip carries path")
	var row_detail = row_actions[0]["detail"] as Dictionary
	_assert_eq(String(row_detail["asset_type"]), "HexTileCatalogResource", "SAMPLE-NEXT-10 sample action row exposes detail asset type")
	_assert_eq(int(row_detail["dependency_count"]), 2, "SAMPLE-NEXT-10 sample action row exposes detail dependencies")
	_assert_true(
		(row_actions[0]["action_button_texts"] as PackedStringArray).has("Duplicate To Project"),
		"SAMPLE-40 catalog row exposes duplicate action"
	)
	_assert_eq(
		(row_actions[1]["action_button_texts"] as PackedStringArray).size(),
		0,
		"SAMPLE-40 tile texture row has no standalone duplicate action"
	)
	_assert_eq(
		(row_actions[2]["action_button_texts"] as PackedStringArray).size(),
		0,
		"SAMPLE-40 object scene row has no standalone duplicate action"
	)

	var output_dir = _test_resource_dir("sample40_settings_duplicate")
	var catalog_path = "%s/settings_sample_catalog.tres" % output_dir
	var result = panel.press_sample_action(
		HexMapSampleSettingsPanel.SAMPLE_CATALOG_ID,
		HexMapSampleSettingsPanel.ACTION_DUPLICATE_TO_PROJECT,
		{"path": catalog_path}
	)
	_assert_true(bool(result["ok"]), "SAMPLE-40 duplicate button path succeeds")
	_assert_eq(int(result["error"]), OK, "SAMPLE-40 duplicate button path reports OK")
	_assert_true(FileAccess.file_exists(String(result["catalog_path"])), "SAMPLE-40 duplicate button writes catalog")
	_assert_true(FileAccess.file_exists(String(result["texture_path"])), "SAMPLE-40 duplicate button copies texture")
	_assert_true(FileAccess.file_exists(String(result["scene_path"])), "SAMPLE-40 duplicate button copies scene")
	_assert_true(not _is_bundled_sample_asset_path(String(result["catalog_path"])), "SAMPLE-40 duplicate catalog is project-owned")
	_assert_true(not _is_bundled_sample_asset_path(String(result["texture_path"])), "SAMPLE-40 duplicate texture is project-owned")
	_assert_true(not _is_bundled_sample_asset_path(String(result["scene_path"])), "SAMPLE-40 duplicate scene is project-owned")

	var catalog = result["catalog"] as HexTileCatalogResource
	_assert_true(catalog is HexTileCatalogResource, "SAMPLE-40 duplicate returns catalog")
	_assert_eq(workspace.workspace_asset_context().tile_catalog, catalog, "SAMPLE-40 duplicate assigns workspace Catalog context")
	_assert_project_asset_slot(
		workspace,
		"Catalog",
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		catalog,
		catalog_path,
		"SAMPLE-40 duplicated sample Catalog slot"
	)
	_assert_eq(workspace.generation_dock().tile_catalog(), catalog, "SAMPLE-40 duplicate updates Generate catalog")
	_assert_eq(workspace.edit_tool().tile_catalog(), catalog, "SAMPLE-40 duplicate updates Paint catalog")
	var snapshot = panel.snapshot()
	var last_action = snapshot["last_sample_action"] as Dictionary
	_assert_true(bool(last_action["ok"]), "SAMPLE-40 panel snapshot records successful duplicate")
	var duplicate_detail = snapshot["sample_detail_drawer"] as Dictionary
	_assert_eq(String(duplicate_detail["duplicate_target"]), catalog_path, "SAMPLE-NEXT-10 detail drawer updates duplicate target after project copy")
	_assert_true(bool(duplicate_detail["duplicate_target_project_owned"]), "SAMPLE-NEXT-10 duplicate target is project-owned")
	var sample_state = snapshot["sample_state"] as Dictionary
	_assert_eq(String(sample_state["state_id"]), HexMapSampleLearningState.STATE_DUPLICATED_TO_PROJECT, "STATE-50 sample panel reports duplicated-to-project state")
	_assert_eq(String(last_action["slot_id"]), HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "SAMPLE-40 panel snapshot records affected slot")
	_assert_eq(String(snapshot["sample_status_text"]), "Catalog slot updated from bundled sample.", "UI-02 panel status shows outcome without path")
	_assert_true(String(snapshot["sample_status_tooltip"]).contains(catalog_path), "UI-02 panel status tooltip keeps changed catalog path")
	_assert_true(not bool(snapshot["sample_status_path_visible"]), "UI-02 panel status keeps path out of visible text")

	workspace.queue_free()
	await process_frame


