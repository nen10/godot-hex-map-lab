extends "res://tests/test_editor_plugin_test_base.gd"

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	await _test_asset_slot_state_model_reports_selection_validation_and_sample_source()
	await _test_asset_slot_state_model_contract_covers_sample_visibility_and_project_duplicates()
	await _test_asset_slot_control_exposes_state_snapshot_contract()
	await _test_file_dialog_lifecycle_helper_attaches_without_reparenting()
	await _test_asset_resource_factory_creates_project_resources_and_assigns_context()
	_finish("res://tests/test_editor_asset.gd")

func _test_asset_slot_state_model_reports_selection_validation_and_sample_source() -> void:
	var slot = HexMapEditorAssetSlotState.new()
	slot.configure("tile_catalog", "Tile Catalog", &"HexTileCatalogResource", true)
	var snapshot = slot.snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_NOT_SELECTED, "asset slot starts not selected")
	_assert_true(not bool(snapshot["selected"]), "asset slot starts without current selection")
	_assert_true(String(snapshot["validation_messages"][0]).contains("required"), "required slot reports missing selection")
	var config = snapshot["config"] as Dictionary
	var runtime = snapshot["runtime"] as Dictionary
	var validation = snapshot["validation"] as Dictionary
	var sample = snapshot["sample"] as Dictionary
	var operation = snapshot["operation"] as Dictionary
	var view_state = snapshot["view_state"] as Dictionary
	_assert_eq(String(config["slot_id"]), "tile_catalog", "STATE-20 config keeps slot definition separate")
	_assert_true(not bool(runtime["selected"]), "STATE-20 runtime starts without selection")
	_assert_eq(String(validation["status"]), HexMapEditorAssetSlotState.STATUS_NOT_SELECTED, "STATE-20 validation stores missing status separately")
	_assert_eq(String(validation["status_kind"]), HexMapEditorAssetSlotState.STATUS_KIND_MISSING, "STATE-20 required missing status has missing kind")
	_assert_true(not bool(sample["available"]), "STATE-20 sample section starts unavailable")
	_assert_true(not bool(operation["present"]), "STATE-20 operation result starts empty")
	_assert_eq(String(view_state["state_source"]), "HexMapEditorAssetSlotState", "STATE-20 ViewState reports state source")
	_assert_eq(String(view_state["status_text"]), "Missing", "STATE-20 ViewState renders missing status text")

	var optional_slot = HexMapEditorAssetSlotState.new()
	optional_slot.configure("movement_profile", "Movement Profile", &"HexMovementProfileResource", false)
	view_state = optional_slot.snapshot()["view_state"] as Dictionary
	_assert_eq(String(view_state["status_kind"]), HexMapEditorAssetSlotState.STATUS_KIND_OPTIONAL, "STATE-20 optional missing slot has optional status kind")
	_assert_eq(String(view_state["status_text"]), "Optional", "STATE-20 optional missing slot renders Optional")

	var sample_catalog = HexTileCatalogResource.new()
	slot.set_sample_source(
		sample_catalog,
		"res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres",
		"Sample Catalog"
	)
	snapshot = slot.snapshot()
	_assert_true(bool(snapshot["sample_available"]), "asset slot records optional sample source")
	_assert_true(not bool(snapshot["selected"]), "sample source is not selected by default")
	_assert_eq(snapshot["current_source"], HexMapEditorAssetSlotState.SOURCE_NONE, "sample source does not become current source")
	sample = snapshot["sample"] as Dictionary
	runtime = snapshot["runtime"] as Dictionary
	_assert_true(bool(sample["available"]), "STATE-20 sample availability is separate from runtime selection")
	_assert_eq(String(runtime["current_source"]), HexMapEditorAssetSlotState.SOURCE_NONE, "STATE-20 runtime source remains none before explicit sample action")

	slot.set_selected_resource(HexMapDocumentResource.new(), "res://project/document.tres")
	snapshot = slot.snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_INVALID, "asset slot detects type mismatch")
	_assert_true(not bool(snapshot["type_matches"]), "asset slot exposes failed type match")
	validation = snapshot["validation"] as Dictionary
	runtime = snapshot["runtime"] as Dictionary
	_assert_eq(String(validation["status_kind"]), HexMapEditorAssetSlotState.STATUS_KIND_ERROR, "STATE-20 invalid type is validation error")
	_assert_true(bool(runtime["selected"]), "STATE-20 invalid resource is still a runtime selection")
	_assert_true(
		String(snapshot["validation_messages"][0]).contains("Expected HexTileCatalogResource"),
		"asset slot mismatch message names expected type"
	)

	var project_catalog = HexTileCatalogResource.new()
	slot.set_selected_resource(project_catalog, "res://project/catalog.tres")
	snapshot = slot.snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_SELECTED, "asset slot accepts required project resource type")
	_assert_true(bool(snapshot["type_matches"]), "asset slot exposes successful type match")
	_assert_eq(snapshot["current_source"], HexMapEditorAssetSlotState.SOURCE_PROJECT, "project resource is current source")
	_assert_eq(snapshot["current_path"], "res://project/catalog.tres", "asset slot stores selected project path")
	view_state = snapshot["view_state"] as Dictionary
	_assert_eq(String(view_state["status_kind"]), HexMapEditorAssetSlotState.STATUS_KIND_OK, "STATE-20 selected project resource has OK ViewState kind")

	slot.mark_warning(["TileSet missing."])
	snapshot = slot.snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_WARNING, "asset slot represents warning state")
	_assert_eq(snapshot["validation_messages"][0], "TileSet missing.", "asset slot stores warning messages")
	validation = snapshot["validation"] as Dictionary
	_assert_eq(String(validation["status_kind"]), HexMapEditorAssetSlotState.STATUS_KIND_WARNING, "STATE-20 warning status stays in validation section")

	slot.clear_selection()
	snapshot = slot.snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_NOT_SELECTED, "clear returns slot to not selected")
	_assert_true(not bool(snapshot["selected"]), "clear removes selected resource")

	_assert_true(slot.apply_sample_source(), "asset slot can explicitly apply sample source")
	snapshot = slot.snapshot()
	_assert_eq(snapshot["current_source"], HexMapEditorAssetSlotState.SOURCE_SAMPLE, "explicit sample application marks sample source")
	_assert_eq(snapshot["current_resource"], sample_catalog, "explicit sample application selects sample resource")
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_WARNING, "SAMPLE-41 explicit sample application warns before production use")
	operation = snapshot["operation"] as Dictionary
	_assert_true(bool(operation["present"]), "STATE-20 sample action records operation result separately")
	_assert_eq(String(operation["action_id"]), "apply_sample", "STATE-20 operation records sample action id")


func _test_asset_slot_state_model_contract_covers_sample_visibility_and_project_duplicates() -> void:
	var slot = HexMapEditorAssetSlotState.new()
	slot.configure("tile_catalog", "Tile Catalog", &"HexTileCatalogResource", true)
	var snapshot = slot.snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_NOT_SELECTED, "TEST-42 required asset missing is not selected")
	_assert_true(String(snapshot["validation_messages"][0]).contains("required"), "TEST-42 required asset missing reports validation message")

	var sample_catalog = HexTileCatalogResource.new()
	slot.set_sample_source(
		sample_catalog,
		"res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres",
		"Bundled Sample Catalog"
	)
	snapshot = slot.snapshot()
	_assert_true(bool(snapshot["allows_sample"]), "TEST-42 slot allows explicit sample source")
	_assert_true(bool(snapshot["sample_available"]), "TEST-42 slot reports sample candidate availability")
	_assert_true(not bool(snapshot["selected"]), "TEST-42 sample candidate is not selected by default")
	_assert_eq(snapshot["current_source"], HexMapEditorAssetSlotState.SOURCE_NONE, "TEST-42 sample candidate does not become current source")

	slot.set_selected_resource(HexMapDocumentResource.new(), "res://project/level_document.tres")
	snapshot = slot.snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_INVALID, "TEST-42 invalid type reports invalid state")
	_assert_true(not bool(snapshot["type_matches"]), "TEST-42 invalid type exposes failed type match")
	_assert_eq(snapshot["current_source"], HexMapEditorAssetSlotState.SOURCE_PROJECT, "TEST-42 invalid project selection still records project source")

	var project_catalog = HexTileCatalogResource.new()
	slot.set_selected_resource(project_catalog, "res://project/tile_catalog.tres")
	snapshot = slot.snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_SELECTED, "TEST-42 selected project asset reports selected state")
	_assert_eq(snapshot["current_source"], HexMapEditorAssetSlotState.SOURCE_PROJECT, "TEST-42 selected project asset records project source")
	_assert_eq(snapshot["current_resource"], project_catalog, "TEST-42 selected project asset records resource")

	_assert_true(slot.apply_sample_source(), "TEST-42 explicit sample action can select sample")
	snapshot = slot.snapshot()
	_assert_eq(snapshot["current_source"], HexMapEditorAssetSlotState.SOURCE_SAMPLE, "TEST-42 explicit sample action records sample source")
	_assert_eq(snapshot["current_resource"], sample_catalog, "TEST-42 explicit sample action records sample resource")

	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	_assert_true(not bool(workspace.catalog_screen_snapshot()["sample_candidates_visible"]), "TEST-42 sample mode OFF hides Catalog sample candidates")
	_assert_true(not bool(workspace.validate_screen_snapshot()["sample_candidates_visible"]), "TEST-42 sample mode OFF hides Validate sample candidates")
	_assert_true(not bool(workspace.qa_screen_snapshot()["sample_candidates_visible"]), "TEST-42 sample mode OFF hides QA sample candidates")
	_assert_true(not bool(workspace.export_screen_snapshot()["sample_candidates_visible"]), "TEST-42 sample mode OFF hides Export sample candidates")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "TEST-42 sample mode OFF hides Generate sample fallback")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "TEST-42 sample mode OFF hides Paint sample fallback")

	var panel = workspace.sample_settings_panel()
	panel.set_show_bundled_samples_in_main_selectors(true)
	_assert_true(bool(panel.snapshot()["show_bundled_samples_in_main_selectors"]), "TEST-42 sample mode ON records Settings flag")
	_assert_true(bool(workspace.catalog_screen_snapshot()["sample_candidates_visible"]), "TEST-42 sample mode ON shows Catalog learning candidates")
	_assert_true(bool(workspace.validate_screen_snapshot()["sample_candidates_visible"]), "TEST-42 sample mode ON shows Validate learning candidates")
	_assert_true(bool(workspace.qa_screen_snapshot()["sample_candidates_visible"]), "TEST-42 sample mode ON shows QA learning candidates")
	_assert_true(bool(workspace.export_screen_snapshot()["sample_candidates_visible"]), "TEST-42 sample mode ON shows Export learning candidates")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "SAMPLE-41 sample mode ON does not auto-use Generate sample fallback")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "SAMPLE-41 sample mode ON does not auto-use Paint sample fallback")

	var direct_sample_catalog = ResourceLoader.load(
		"res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres",
		"HexTileCatalogResource",
		ResourceLoader.CACHE_MODE_IGNORE
	) as HexTileCatalogResource
	session.set_workspace_asset(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, direct_sample_catalog, "test.direct_sample_catalog")
	var direct_sample_slot = workspace.tab_asset_slot_snapshot("Catalog", HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG)
	_assert_eq(String(direct_sample_slot["current_source"]), HexMapEditorAssetSlotState.SOURCE_SAMPLE, "SAMPLE-41 direct bundled sample selection is SOURCE_SAMPLE")
	_assert_eq(String(direct_sample_slot["status"]), HexMapEditorAssetSlotState.STATUS_WARNING, "SAMPLE-41 direct bundled sample selection warns")
	_assert_true(
		String((direct_sample_slot["validation_messages"] as Array)[0]).contains("Duplicate"),
		"SAMPLE-41 direct bundled sample warning points to project duplicate"
	)
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "SAMPLE-41 direct bundled sample selection is not Generate source")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "SAMPLE-41 direct bundled sample selection is not Paint source")

	var output_dir = _test_resource_dir("test42_asset_slot_state")
	var catalog_path = "%s/duplicated_sample_catalog.tres" % output_dir
	var duplicate_result = panel.duplicate_sample_catalog_to_project(catalog_path)
	_assert_true(bool(duplicate_result["ok"]), "TEST-42 duplicate sample to project succeeds")
	var duplicated_catalog = duplicate_result["catalog"] as HexTileCatalogResource
	_assert_true(duplicated_catalog is HexTileCatalogResource, "TEST-42 duplicate returns catalog resource")
	_assert_true(bool(duplicated_catalog.metadata.get("project_copy", false)), "TEST-42 duplicate marks project copy metadata")
	_assert_eq(
		String(duplicated_catalog.metadata.get("duplicated_from_sample", "")),
		"res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres",
		"TEST-42 duplicate records source sample metadata"
	)
	_assert_eq(session.current_workspace_asset_context().tile_catalog, duplicated_catalog, "TEST-42 duplicate enters workspace context")
	_assert_project_asset_slot(
		workspace,
		"Catalog",
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		duplicated_catalog,
		catalog_path,
		"TEST-42 duplicated sample Catalog slot"
	)
	_assert_eq(workspace.generation_dock().tile_catalog(), duplicated_catalog, "TEST-42 duplicated project catalog is primary for Generate")
	_assert_eq(workspace.edit_tool().tile_catalog(), duplicated_catalog, "TEST-42 duplicated project catalog is primary for Paint")

	workspace.queue_free()
	await process_frame


func _test_asset_slot_control_exposes_state_snapshot_contract() -> void:
	var state = HexMapEditorAssetSlotState.new()
	state.configure("object_database", "Object Database", &"HexObjectDatabaseResource", true)
	state.allows_create_new = true
	state.set_sample_source(HexObjectDatabaseResource.new(), "res://addons/hex_map_kit/assets/sample_object_db.tres", "Sample Object DB")

	var control = HexMapEditorAssetSlotControl.new()
	root.add_child(control)
	control.set_slot_state(state)
	await process_frame

	var snapshot = control.slot_state_snapshot()
	_assert_eq(snapshot["slot_id"], "object_database", "asset slot control exposes slot id in state snapshot")
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_NOT_SELECTED, "asset slot control exposes missing state")
	_assert_true(bool(snapshot["allows_sample"]), "asset slot control snapshot exposes sample availability")
	_assert_true(bool(snapshot["allows_create_new"]), "asset slot control snapshot exposes create-new availability")
	_assert_true(not bool(snapshot["selected"]), "asset slot control does not auto-select sample source")
	_assert_eq(String(snapshot["picker_base_type"]), "HexObjectDatabaseResource", "ASSET-30 asset slot state exposes strict picker base type")
	_assert_true(not bool(snapshot["uses_generic_resource_filter"]), "ASSET-30 typed asset slot does not use generic Resource filter")
	var view_state = snapshot["view_state"] as Dictionary
	_assert_eq(String(view_state["status_kind"]), HexMapEditorAssetSlotState.STATUS_KIND_MISSING, "STATE-20 control snapshot exposes missing ViewState kind")
	_assert_eq(String((snapshot["config"] as Dictionary)["required_type"]), "HexObjectDatabaseResource", "STATE-20 control snapshot separates config")
	_assert_true(not bool((snapshot["runtime"] as Dictionary)["selected"]), "STATE-20 control snapshot separates runtime")
	_assert_true(bool((snapshot["sample"] as Dictionary)["available"]), "STATE-20 control snapshot separates sample availability")
	var layout = control.slot_layout_snapshot()
	_assert_true(bool(layout["single_row"]), "asset slot control uses single row layout")
	_assert_true(bool(layout["single_row_visible"]), "UI-01 asset slot single row is visible")
	_assert_eq(String(layout["status_text"]), "", "UI-01 asset slot removes visible status word from row")
	_assert_true(not bool(layout["status_text_visible"]), "UI-01 asset slot hides status text label")
	_assert_true(bool(layout["status_icon_visible"]), "UI-01 asset slot shows compact status swatch")
	_assert_eq(String(layout["status_kind"]), HexMapEditorAssetSlotState.STATUS_KIND_MISSING, "STATE-20 layout exposes ViewState status kind")
	_assert_eq(String(layout["status_icon"]), "missing", "STATE-20 layout exposes status icon id")
	_assert_true(not bool(layout["details_visible"]), "asset slot details start collapsed")
	_assert_eq(String(layout["details_button_text"]), "", "FB-02 asset slot removes visible Details button text")
	_assert_true(not bool(layout["details_button_visible"]), "FB-02 asset slot Details button is not visible")
	_assert_true(String(layout["status_tooltip"]).contains("Type: HexObjectDatabaseResource"), "asset slot compact status tooltip includes type")
	_assert_true(String(layout["status_tooltip"]).contains("Pick: HexObjectDatabaseResource"), "ASSET-30 asset slot tooltip says what type to pick")
	if bool(layout["resource_picker_visible"]):
		_assert_eq(String(layout["resource_picker_base_type"]), "HexObjectDatabaseResource", "ASSET-30 EditorResourcePicker uses strict base type")
	var action_texts = layout["action_button_texts"] as PackedStringArray
	_assert_true(action_texts.has("Create New..."), "ASSET-31 asset slot keeps implemented Create New action")
	_assert_true(action_texts.has("Sample Object DB"), "ASSET-31 asset slot keeps explicit sample action")
	_assert_true(not action_texts.has("Select..."), "ASSET-31 asset slot removes redundant Select button")
	_assert_true(not action_texts.has("Open"), "ASSET-31 asset slot removes unimplemented Open button")
	_assert_true(not action_texts.has("Clear"), "ASSET-31 asset slot delegates Clear to ResourcePicker")
	_assert_true(not action_texts.has("Validate"), "ASSET-31 asset slot removes row-level Validate button")
	_assert_true(not _has_button_text(control, "Select..."), "ASSET-31 visible Select button is absent")
	_assert_true(not _has_button_text(control, "Open"), "ASSET-31 visible Open button is absent")
	_assert_true(not _has_button_text(control, "Clear"), "ASSET-31 visible Clear button is absent")
	_assert_true(not _has_button_text(control, "Validate"), "ASSET-31 visible Validate button is absent")
	_assert_true(not _has_button_text(control, "Details"), "FB-02 visible Details button is absent")
	_assert_true(String(layout["current_detail_text"]).contains("Current: Not selected"), "asset slot details keep current selection text")

	var database = HexObjectDatabaseResource.new()
	control.set_selected_resource(database, "res://project/object_database.tres")
	snapshot = control.slot_state_snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_SELECTED, "asset slot control records selected state")
	_assert_eq(snapshot["current_resource"], database, "asset slot control records selected resource")
	_assert_eq(snapshot["current_path"], "res://project/object_database.tres", "asset slot control records selected path")
	layout = control.slot_layout_snapshot()
	_assert_eq(String(layout["status_text"]), "", "UI-01 selected asset row keeps status word out of visible text")
	_assert_eq(String(layout["status_kind"]), HexMapEditorAssetSlotState.STATUS_KIND_OK, "STATE-20 selected layout status comes from ViewState")
	_assert_eq(String(layout["status_icon"]), "check", "UI-01 selected asset row exposes check status icon id")
	_assert_true(String(layout["status_tooltip"]).contains("res://project/object_database.tres"), "asset slot compact tooltip carries selected path")

	control.mark_invalid(["Object database is missing required definitions."])
	snapshot = control.slot_state_snapshot()
	_assert_eq(snapshot["status"], HexMapEditorAssetSlotState.STATUS_INVALID, "asset slot control can expose invalid state")
	_assert_eq(
		snapshot["validation_messages"][0],
		"Object database is missing required definitions.",
		"asset slot control exposes validation messages"
	)
	layout = control.slot_layout_snapshot()
	_assert_eq(String(layout["status_text"]), "", "UI-01 invalid asset row keeps status word out of visible text")
	_assert_eq(String(layout["status_kind"]), HexMapEditorAssetSlotState.STATUS_KIND_ERROR, "STATE-20 invalid layout status comes from ViewState")
	_assert_eq(String(layout["status_icon"]), "alert", "UI-01 invalid asset row exposes alert status icon id")
	_assert_true(String(layout["message_detail_text"]).contains("Object database is missing"), "asset slot details keep validation messages")
	control.set_details_visible(true)
	layout = control.slot_layout_snapshot()
	_assert_true(bool(layout["details_visible"]), "asset slot details can expand without private node access")

	_assert_true(control.apply_sample_source(), "asset slot control applies sample only through explicit action")
	snapshot = control.slot_state_snapshot()
	_assert_eq(snapshot["current_source"], HexMapEditorAssetSlotState.SOURCE_SAMPLE, "asset slot control records explicit sample source")
	_assert_eq(snapshot["current_path"], "res://addons/hex_map_kit/assets/sample_object_db.tres", "asset slot control records sample path after explicit action")
	_assert_eq(String((snapshot["operation"] as Dictionary)["action_id"]), "apply_sample", "STATE-20 control snapshot records sample operation separately")
	layout = control.slot_layout_snapshot()
	_assert_eq(String(layout["status_text"]), "", "UI-01 sample warning keeps status word out of visible text")
	_assert_eq(String(layout["status_kind"]), HexMapEditorAssetSlotState.STATUS_KIND_WARNING, "STATE-20 sample warning layout status comes from ViewState")
	_assert_eq(String(layout["status_icon"]), "warning", "UI-01 sample warning row exposes warning status icon id")
	_assert_true(String(layout["status_tooltip"]).contains("Source: Sample Learning"), "asset slot compact tooltip records sample source badge")

	var create_recorder = AssetCreatePathRecorder.new()
	control.create_path_selected.connect(Callable(create_recorder, "record"))
	_assert_eq(control.default_create_file_name(), "object_database.tres", "asset slot control exposes default create file name")
	var dialog_config = control.create_dialog_config()
	_assert_eq(String(dialog_config["current_file"]), "object_database.tres", "asset slot create dialog uses slot-specific file name")
	_assert_eq(int(dialog_config["file_mode"]), EditorFileDialog.FILE_MODE_SAVE_FILE, "asset slot create dialog uses Save As mode")
	control.select_create_path("res://project/new_object_database.tres")
	_assert_eq(create_recorder.entries.size(), 1, "asset slot create dialog emits selected path")
	_assert_eq(create_recorder.entries[0]["slot_id"], "object_database", "asset slot create path includes slot id")
	_assert_eq(create_recorder.entries[0]["path"], "res://project/new_object_database.tres", "asset slot create path includes selected path")

	control.queue_free()
	await process_frame


func _test_file_dialog_lifecycle_helper_attaches_without_reparenting() -> void:
	var first_parent := Control.new()
	first_parent.name = "DialogParentA"
	var second_parent := Control.new()
	second_parent.name = "DialogParentB"
	root.add_child(first_parent)
	root.add_child(second_parent)
	await process_frame

	var dialog := Control.new()
	dialog.name = "DialogLifecycleSubject"
	var initial_snapshot = HexMapEditorPathSelector.dialog_lifecycle_snapshot(dialog)
	_assert_true(bool(initial_snapshot["valid"]), "FileDialog lifecycle snapshot accepts a dialog node")
	_assert_true(not bool(initial_snapshot["has_parent"]), "new dialog node starts without a parent")
	_assert_eq(
		String((initial_snapshot["dialog_state"] as Dictionary)["state_id"]),
		HexMapDialogLifecycleState.STATE_CLOSED,
		"STATE-50 unattached dialog starts closed"
	)

	_assert_true(
		HexMapEditorPathSelector.attach_dialog(dialog, first_parent),
		"FileDialog lifecycle helper attaches unparented dialog node"
	)
	var attached_snapshot = HexMapEditorPathSelector.dialog_lifecycle_snapshot(dialog)
	_assert_true(bool(attached_snapshot["has_parent"]), "FileDialog lifecycle snapshot records attached parent")
	_assert_eq(attached_snapshot["parent"], first_parent, "FileDialog lifecycle helper uses the requested parent")
	_assert_true(bool(attached_snapshot["inside_tree"]), "attached dialog node is inside the test scene tree")
	_assert_eq(first_parent.get_child_count(), 1, "FileDialog attach adds the dialog node once")
	_assert_eq(
		String((attached_snapshot["dialog_state"] as Dictionary)["state_id"]),
		HexMapDialogLifecycleState.STATE_WAITING_USER,
		"STATE-50 attached dialog waits for user"
	)

	_assert_true(
		HexMapEditorPathSelector.attach_dialog(dialog, second_parent),
		"FileDialog lifecycle helper accepts already attached dialog node without reparenting"
	)
	var reattach_snapshot = HexMapEditorPathSelector.dialog_lifecycle_snapshot(dialog)
	_assert_eq(reattach_snapshot["parent"], first_parent, "FileDialog lifecycle helper does not reparent an attached dialog node")
	_assert_eq(first_parent.get_child_count(), 1, "FileDialog lifecycle helper does not double-add dialog node to original parent")
	_assert_eq(second_parent.get_child_count(), 0, "FileDialog lifecycle helper does not add attached dialog node to second parent")

	dialog.queue_free()
	first_parent.queue_free()
	second_parent.queue_free()
	await process_frame


func _test_asset_resource_factory_creates_project_resources_and_assigns_context() -> void:
	var context = HexMapWorkspaceAssetContext.new()
	var output_dir = _test_resource_dir("asset12_create_new")
	var expectations := {
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT: "HexMapDocumentResource",
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG: "HexTileCatalogResource",
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE: "HexObjectDatabaseResource",
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE: "HexLabelDatabaseResource",
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK: "HexLayerStackResource",
		HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE: "HexMovementProfileResource",
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE: "HexValidationRuleSuiteResource",
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE: "HexGenerationProfileResource",
		HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE: "HexExportProfileResource",
	}

	for slot_id in HexMapWorkspaceAssetContext.asset_slot_ids():
		var default_file = HexMapWorkspaceAssetResourceFactory.default_file_name(slot_id)
		_assert_true(default_file.ends_with(".tres"), "create-new default file uses .tres for %s" % slot_id)
		var path = "%s/%s" % [output_dir, default_file]
		var result = HexMapWorkspaceAssetResourceFactory.create_and_save_for_slot(slot_id, path, context)
		_assert_true(bool(result["ok"]), "create-new saves resource for %s" % slot_id)
		_assert_eq(int(result["error"]), OK, "create-new reports OK for %s" % slot_id)
		_assert_true(FileAccess.file_exists(String(result["path"])), "create-new writes resource file for %s" % slot_id)
		_assert_eq(context.asset_for_slot(slot_id), result["resource"], "create-new assigns resource to context for %s" % slot_id)
		_assert_eq(
			HexMapWorkspaceAssetResourceFactory.resource_type_name(slot_id),
			expectations[slot_id],
			"create-new reports expected resource type for %s" % slot_id
		)
		_assert_created_asset_resource_type(slot_id, result["resource"])
		_assert_created_asset_has_no_sample_payload(slot_id, result["resource"])

	var extension_result = HexMapWorkspaceAssetResourceFactory.create_and_save_for_slot(
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE,
		"%s/profile_without_extension" % output_dir,
		context
	)
	_assert_true(String(extension_result["path"]).ends_with(".tres"), "create-new normalizes missing .tres extension")
	_assert_true(
		not String(extension_result["path"]).contains("sample"),
		"create-new normalized path does not introduce sample naming"
	)


