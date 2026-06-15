extends "res://tests/test_editor_plugin_test_base.gd"

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	await _test_workspace_selected_hex_tile_map_auto_binding()
	await _test_workspace_create_missing_unique_resources_for_selected_hex_tile_map()
	await _test_workspace_asset_selection_writes_back_to_selected_hex_tile_map()
	await _test_workspace_tab_content_query_contract_lists_expected_components_and_slots()
	await _test_workspace_first_run_learning_cta_routes_to_settings_without_sample_defaults()
	await _test_workspace_asset_context_is_shared_by_workspace_generate_and_paint()
	await _test_workspace_hydrates_asset_context_from_document_dependencies()
	await _test_workspace_lifecycle_state_models_cover_required_transitions()
	await _test_workspace_root_state_and_dispatcher_integrate_viewstates()
	await _test_workspace_dispatcher_result_contract()
	await _test_workspace_asset_slots_use_strict_resource_type_filters()
	await _test_workspace_resource_purpose_tooltips_cover_resource_rows()
	await _test_workspace_tab_purpose_empty_states_route_to_project_actions()
	await _test_workspace_asset_slot_actions_remove_redundant_buttons()
	await _test_workspace_asset_remaining_actions_are_wired_or_deleted()
	_finish("res://tests/test_editor_workspace.gd")

func _test_workspace_selected_hex_tile_map_auto_binding() -> void:
	var session = HexMapEditorSessionState.new()
	var recorder = SessionChangeRecorder.new()
	session.changed.connect(Callable(recorder, "record"))
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var empty_snapshot = workspace.selected_hex_tile_map_snapshot()
	_assert_true(session.selected_hex_tile_map_auto_link_enabled(), "NODE-21 auto-link defaults ON in session state")
	_assert_true(not bool(empty_snapshot["selected"]), "NODE-21 workspace starts without selected HexTileMap")
	_assert_eq(String(empty_snapshot["status_text"]), "No HexTileMap selected", "NODE-21 empty state text is visible")
	_assert_true(bool(empty_snapshot["auto_link"]), "NODE-21 workspace snapshot exposes auto-link ON")
	_assert_eq(String(empty_snapshot["auto_link_text"]), "Auto-link: On", "NODE-21 auto-link status is informational")
	var binding_state = empty_snapshot["binding_state"] as Dictionary
	_assert_eq(String(binding_state["state_source"]), "HexMapWorkspaceBindingService", "STATE-30 binding state has explicit source")
	_assert_eq(String(binding_state["state_id"]), HexMapWorkspaceBindingService.STATE_NO_TARGET, "STATE-30 no-target state is explicit")
	_assert_true((binding_state["active_state_ids"] as PackedStringArray).has(HexMapWorkspaceBindingService.STATE_NO_TARGET), "STATE-30 active states include no target")
	var empty_writeback = empty_snapshot["writeback"] as Dictionary
	_assert_eq(String(empty_writeback["state_source"]), "HexMapWorkspaceBindingService", "ARCH-40 writeback snapshot is service-owned")

	var scene_root = Node2D.new()
	scene_root.name = "SelectionScene"
	root.add_child(scene_root)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "SelectedHexTileMap"
	selected_layer.hex_map = HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	var selected_stack = HexLayerStackResource.minimal_runtime_template()
	selected_layer.layer_stack_resource = selected_stack
	selected_layer.display_tile_set_resource = TileSet.new()
	scene_root.add_child(selected_layer)
	await process_frame

	var selected_snapshot = workspace.set_selected_hex_tile_map_node(selected_layer, "test.selected_hex_tile_map")
	_assert_true(bool(selected_snapshot["selected"]), "NODE-21 selected HexTileMap is recorded")
	_assert_eq(selected_snapshot["selected_node"], selected_layer, "NODE-21 selected node is the HexTileMapLayer")
	_assert_true(String(selected_snapshot["status_text"]).contains("SelectedHexTileMap"), "NODE-21 selected status names the node")
	_assert_true(not String(selected_snapshot["status_text"]).contains("/"), "SCREEN-10 selected status keeps node path out of primary text")
	_assert_true(not bool(selected_snapshot["node_path_visible"]), "SCREEN-10 selected snapshot marks node path as detail")
	_assert_eq(session.current_selected_hex_tile_map_layer(), selected_layer, "NODE-21 session stores selected HexTileMap")
	_assert_eq(session.current_target_layer(), selected_layer, "NODE-21 auto-link publishes selected node as target")
	_assert_eq(workspace.edit_tool().target_layer(), selected_layer, "NODE-21 workspace applies selected node to edit tool")
	_assert_eq(workspace.workspace_asset_context().layer_stack, selected_stack, "NODE-21 selected node layer stack enters workspace context")
	_assert_eq(workspace.workspace_asset_context().level_document, null, "NODE-21 runtime map is not mislabeled as Level Document")
	_assert_eq(String(selected_snapshot["level_document_status"]), "Missing", "NODE-21 missing unique document is visible")
	binding_state = selected_snapshot["binding_state"] as Dictionary
	_assert_eq(String(binding_state["state_id"]), HexMapWorkspaceBindingService.STATE_SELECTED_NODE_WITHOUT_DOCUMENT, "STATE-30 selected node without document is explicit")
	_assert_true((binding_state["active_state_ids"] as PackedStringArray).has(HexMapWorkspaceBindingService.STATE_APPLIED_WRITEBACK), "STATE-30 linked Layer Stack is explicit applied writeback state")
	_assert_eq(String(selected_snapshot["layer_stack_status"]), "Linked", "NODE-21 selected node layer stack is visible")
	_assert_eq(String(selected_snapshot["authoring_source"]), "Level Document", "NODE-21 Level Document is the authoring source")
	_assert_true(not bool(selected_snapshot["hex_map_is_authoring_source"]), "NODE-21 hex_map is not the authoring source")
	_assert_true(bool(selected_snapshot["runtime_display_snapshot_present"]), "NODE-21 runtime display snapshot is visible as node state")
	_assert_eq(String(selected_snapshot["runtime_display_snapshot_role"]), "Runtime display snapshot", "NODE-21 runtime map role is explicit")
	_assert_eq(String(selected_snapshot["display_tile_set_status"]), "Linked", "NODE-21 selected node display TileSet is visible")
	_assert_eq(String(selected_snapshot["tile_catalog_status"]), "No Tile Catalog linked to node", "NODE-21 missing shared catalog is not silently filled")
	_assert_eq(
		(workspace.resources_screen_snapshot()["selected_hex_tile_map"] as Dictionary)["selected_node"],
		selected_layer,
		"TAB-50 Resources screen shows selected HexTileMap node"
	)
	var selected_resources_snapshot = workspace.resources_screen_snapshot()
	var selected_resources_summary = selected_resources_snapshot["selected_hex_tile_map_summary"] as Dictionary
	_assert_true(String(selected_resources_summary["visible_text"]).contains("SelectedHexTileMap"), "SCREEN-10 Resources summary names selected HexTileMap")
	_assert_true(not String(selected_resources_summary["visible_text"]).contains("/"), "SCREEN-10 Resources summary omits node path")
	_assert_true((selected_resources_snapshot["next_actions"] as PackedStringArray).has("Choose a save folder"), "SCREEN-10 Resources exposes missing-resource save-folder next action")
	var selected_source_badges = _rows_by_slot(selected_resources_snapshot["source_badge_rows"] as Array)
	_assert_eq(String((selected_source_badges[HexMapWorkspaceAssetContext.SLOT_LAYER_STACK] as Dictionary)["source_badge"]), "Node", "SCREEN-10 Resources marks selected node Layer Stack as Node source")
	_assert_eq(String((selected_source_badges[HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT] as Dictionary)["source_badge"]), "Missing", "SCREEN-10 Resources marks missing Level Document source")
	_assert_true(recorder.keys.has("selected_hex_tile_map_layer"), "NODE-21 session emits selected node change")
	_assert_true(recorder.keys.has("target_layer"), "NODE-21 auto-link emits target change")

	var display_layer = selected_layer.display_tile_map_layer()
	var internal_snapshot = workspace.set_selected_hex_tile_map_node(display_layer, "test.selected_internal_layer")
	_assert_eq(internal_snapshot["selected_node"], selected_layer, "NODE-21 internal display layer maps back to selected HexTileMap")

	var dependency_document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var dependency_catalog = HexTileCatalogResource.new()
	HexMapDocumentDependencyService.set_shared_dependency(
		dependency_document,
		HexMapDocumentDependencyService.KEY_TILE_CATALOG,
		dependency_catalog
	)
	selected_layer.level_document_resource = dependency_document
	workspace.set_selected_hex_tile_map_node(selected_layer, "test.selected_hex_tile_map.dependencies")
	_assert_eq(workspace.workspace_asset_context().level_document, dependency_document, "NODE-20 selected node Level Document enters workspace context")
	_assert_eq(workspace.workspace_asset_context().tile_catalog, dependency_catalog, "NODE-20 selected node document dependencies hydrate shared context")
	var dependency_resources_snapshot = workspace.resources_screen_snapshot()
	var dependency_hydration = dependency_resources_snapshot["dependency_hydration"] as Dictionary
	_assert_eq(String(dependency_hydration["state_source"]), "HexMapWorkspaceBindingService", "ARCH-40 hydration snapshot is service-owned")
	var dependency_source_badges = _rows_by_slot(dependency_resources_snapshot["source_badge_rows"] as Array)
	_assert_eq(
		String((dependency_source_badges[HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG] as Dictionary)["source_badge"]),
		HexMapDocumentDependencyService.SOURCE_BADGE_DOCUMENT_DEPENDENCY,
		"SCREEN-10 Resources marks hydrated Tile Catalog as Document Dependency"
	)
	binding_state = workspace.selected_hex_tile_map_binding_state_snapshot()
	_assert_true((binding_state["active_state_ids"] as PackedStringArray).has(HexMapWorkspaceBindingService.STATE_HYDRATED_DEPENDENCIES), "STATE-30 document dependency hydration state is explicit")
	_assert_true((binding_state["hydrated_dependency_slot_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG), "STATE-30 hydrated dependency records Tile Catalog slot")
	var last_hydration = binding_state["last_hydration"] as Dictionary
	_assert_eq(String(last_hydration["state_source"]), "HexMapWorkspaceBindingService", "ARCH-40 binding state keeps service hydration result")

	var invalid_node = Node2D.new()
	invalid_node.name = "NotAHexTileMap"
	scene_root.add_child(invalid_node)
	var cleared_snapshot = workspace.set_selected_hex_tile_map_node(invalid_node, "test.invalid_selection")
	_assert_true(not bool(cleared_snapshot["selected"]), "NODE-21 non-HexTileMap selection clears selected node")
	_assert_eq(String(cleared_snapshot["status_text"]), "No HexTileMap selected", "NODE-21 clear state keeps exact empty text")
	binding_state = cleared_snapshot["binding_state"] as Dictionary
	_assert_eq(String(binding_state["state_id"]), HexMapWorkspaceBindingService.STATE_NO_TARGET, "STATE-30 clear returns to no-target state")
	_assert_eq(session.current_selected_hex_tile_map_layer(), null, "NODE-21 session clears selected node")
	_assert_eq(session.current_target_layer(), null, "NODE-21 auto-link clears target when no HexTileMap is selected")
	_assert_eq(workspace.edit_tool().target_layer(), null, "NODE-21 edit target clears with no selected HexTileMap")
	_assert_eq(workspace.workspace_asset_context().layer_stack, null, "NODE-21 selected-node layer stack clears with no selected HexTileMap")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _test_workspace_create_missing_unique_resources_for_selected_hex_tile_map() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var empty_missing_snapshot = workspace.missing_unique_resources_snapshot()
	_assert_true(not bool(empty_missing_snapshot["can_create"]), "FB-02 missing resource create is disabled before HexTileMap selection")
	_assert_eq(
		String(empty_missing_snapshot["choose_directory_button_tooltip"]),
		"Select a HexTileMap node before choosing a save directory.",
		"FB-02 disabled missing resource directory action explains missing selection"
	)
	_assert_eq(
		String(empty_missing_snapshot["create_button_tooltip"]),
		"Select a HexTileMap node before creating missing resources.",
		"FB-02 disabled missing resource create action explains missing selection"
	)

	var scene_root = Node2D.new()
	scene_root.name = "MissingResourcesScene"
	root.add_child(scene_root)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "Missing Resource Map"
	selected_layer.hex_map = HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	scene_root.add_child(selected_layer)
	await process_frame

	workspace.set_selected_hex_tile_map_node(selected_layer, "test.node22.select")
	var missing_snapshot = workspace.missing_unique_resources_snapshot()
	_assert_true(not bool(missing_snapshot["can_create"]), "NODE-22 create is unavailable without save directory")
	_assert_eq(
		String(missing_snapshot["choose_directory_button_tooltip"]),
		"Choose a project directory for the selected HexTileMap resources.",
		"FB-02 enabled missing resource directory action names its state change"
	)
	_assert_eq(
		String(missing_snapshot["create_button_tooltip"]),
		"Choose a save directory before creating missing resources.",
		"FB-02 disabled missing resource create action explains missing directory"
	)
	_assert_eq(int(missing_snapshot["missing_count"]), 2, "NODE-22 selected node reports missing unique resources")
	_assert_true(
		(missing_snapshot["missing_resource_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT),
		"NODE-22 missing list includes Level Document"
	)
	_assert_true(
		(missing_snapshot["missing_resource_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK),
		"NODE-22 missing list includes Layer Stack"
	)
	_assert_eq(String(missing_snapshot["resource_prefix"]), "Missing_Resource_Map", "NODE-22 prefix defaults to safe selected node name")
	_assert_eq(
		int((missing_snapshot["dialog_config"] as Dictionary).get("file_mode", -1)),
		EditorFileDialog.FILE_MODE_OPEN_DIR,
		"NODE-22 save directory uses folder picker config"
	)

	var save_dir = _test_resource_dir("node22_missing_unique_resources")
	var planned_snapshot = workspace.missing_unique_resources_snapshot(save_dir)
	_assert_eq(
		String(planned_snapshot["create_button_tooltip"]),
		"Create Level Document and Layer Stack resources in the selected directory.",
		"FB-02 ready missing resource create action names its state change"
	)
	var planned_paths = planned_snapshot["paths"] as Dictionary
	_assert_eq(
		String(planned_paths[HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT]),
		"%s/Missing_Resource_Map_document.tres" % save_dir,
		"NODE-22 document path uses selected node prefix"
	)
	_assert_eq(
		String(planned_paths[HexMapWorkspaceAssetContext.SLOT_LAYER_STACK]),
		"%s/Missing_Resource_Map_layer_stack.tres" % save_dir,
		"NODE-22 layer stack path uses selected node prefix"
	)

	var catalog = HexTileCatalogResource.new()
	catalog.resource_name = "Selected Project Catalog"
	var object_database = HexObjectDatabaseResource.new()
	object_database.resource_name = "Selected Object Database"
	var label_database = HexLabelDatabaseResource.new()
	label_database.resource_name = "Selected Label Database"
	var movement_profile = HexMovementProfileResource.new()
	movement_profile.resource_name = "Selected Movement Profile"
	workspace.workspace_asset_context().set_tile_catalog(catalog)
	workspace.workspace_asset_context().set_object_database(object_database)
	workspace.workspace_asset_context().set_label_database(label_database)
	workspace.workspace_asset_context().set_movement_profile(movement_profile)

	var result = workspace.create_missing_selected_hex_tile_map_resources(save_dir)
	_assert_true(bool(result["ok"]), "NODE-22 creates missing selected-node resources")
	_assert_true(
		(result["created_resource_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT),
		"NODE-22 creates missing Level Document"
	)
	_assert_true(
		(result["created_resource_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK),
		"NODE-22 creates missing Layer Stack"
	)
	var document_path := String(planned_paths[HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT])
	var stack_path := String(planned_paths[HexMapWorkspaceAssetContext.SLOT_LAYER_STACK])
	_assert_true(ResourceLoader.exists(document_path), "NODE-22 saved document exists")
	_assert_true(ResourceLoader.exists(stack_path), "NODE-22 saved layer stack exists")
	_assert_true(selected_layer.level_document_resource is HexMapDocumentResource, "NODE-22 assigns created document to selected node")
	_assert_true(selected_layer.layer_stack_resource is HexLayerStackResource, "NODE-22 assigns created layer stack to selected node")
	_assert_eq(selected_layer.level_document_resource.resource_path, document_path, "NODE-22 node document reference uses saved path")
	_assert_eq(selected_layer.layer_stack_resource.resource_path, stack_path, "NODE-22 node layer stack reference uses saved path")
	_assert_eq(workspace.workspace_asset_context().level_document, selected_layer.level_document_resource, "NODE-22 workspace context shows created document")
	_assert_eq(workspace.workspace_asset_context().layer_stack, selected_layer.layer_stack_resource, "NODE-22 workspace context shows created layer stack")
	_assert_eq(session.current_document(), selected_layer.level_document_resource, "NODE-22 session document follows created document")
	_assert_eq(workspace.workspace_asset_context().tile_catalog, catalog, "NODE-22 preserves selected shared Tile Catalog")
	_assert_eq(workspace.workspace_asset_context().object_database, object_database, "NODE-22 preserves selected shared Object Database")
	_assert_eq(workspace.workspace_asset_context().label_database, label_database, "NODE-22 preserves selected shared Label Database")
	_assert_eq(workspace.workspace_asset_context().movement_profile, movement_profile, "NODE-22 preserves selected shared Movement Profile")
	_assert_true(not bool(result["shared_resources_created"]), "NODE-22 result states no shared resources were created")
	var dependency_sync = result["shared_dependency_sync"] as Dictionary
	_assert_true(bool(dependency_sync["ok"]), "NODE-22 shared dependency sync succeeds after document creation")
	var dependency_slots = dependency_sync["applied_slot_ids"] as PackedStringArray
	_assert_true(dependency_slots.has(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG), "NODE-22 writes selected Tile Catalog to document dependency")
	_assert_true(dependency_slots.has(HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE), "NODE-22 writes selected Object Database to document dependency")
	_assert_true(dependency_slots.has(HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE), "NODE-22 writes selected Label Database to document dependency")
	_assert_true(dependency_slots.has(HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE), "NODE-22 writes selected Movement Profile to document dependency")
	var created_document = selected_layer.level_document_resource
	var catalog_dependency = HexMapDocumentDependencyService.find_shared_dependency(created_document, HexMapDocumentDependencyService.KEY_TILE_CATALOG)
	var object_dependency = HexMapDocumentDependencyService.find_shared_dependency(created_document, HexMapDocumentDependencyService.KEY_OBJECT_DATABASE)
	var label_dependency = HexMapDocumentDependencyService.find_shared_dependency(created_document, HexMapDocumentDependencyService.KEY_LABEL_DATABASE)
	var movement_dependency = HexMapDocumentDependencyService.find_shared_dependency(created_document, HexMapDocumentDependencyService.KEY_MOVEMENT_PROFILE)
	_assert_eq(catalog_dependency.get("resource"), catalog, "NODE-22 document dependency matches selected Tile Catalog")
	_assert_eq(object_dependency.get("resource"), object_database, "NODE-22 document dependency matches selected Object Database")
	_assert_eq(label_dependency.get("resource"), label_database, "NODE-22 document dependency matches selected Label Database")
	_assert_eq(movement_dependency.get("resource"), movement_profile, "NODE-22 document dependency matches selected Movement Profile")
	var after_snapshot = result["after"] as Dictionary
	_assert_eq(int(after_snapshot["missing_count"]), 0, "NODE-22 after snapshot has no missing unique resources")
	_assert_eq(String(workspace.selected_hex_tile_map_snapshot()["level_document_status"]), "Linked", "NODE-22 selected-node summary shows linked document")

	var repeat_result = workspace.create_missing_selected_hex_tile_map_resources(save_dir)
	_assert_true(bool(repeat_result["ok"]), "NODE-22 repeat create is a no-op when resources already exist")
	_assert_eq((repeat_result["created_resource_ids"] as PackedStringArray).size(), 0, "NODE-22 repeat create does not overwrite existing unique resources")

	var existing_stack = HexLayerStackResource.minimal_runtime_template()
	var partial_layer = HexTileMapLayer.new()
	partial_layer.name = "PartialResources"
	partial_layer.layer_stack_resource = existing_stack
	scene_root.add_child(partial_layer)
	await process_frame
	var partial_dir = _test_resource_dir("node22_partial_unique_resources")
	workspace.set_selected_hex_tile_map_node(partial_layer, "test.node22.partial")
	var partial_result = workspace.create_missing_selected_hex_tile_map_resources(partial_dir, "PartialMap")
	_assert_true(bool(partial_result["ok"]), "NODE-22 creates only missing unique resources for partially configured node")
	_assert_true(
		(partial_result["created_resource_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT),
		"NODE-22 partial flow creates missing document"
	)
	_assert_true(
		not (partial_result["created_resource_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK),
		"NODE-22 partial flow preserves existing layer stack"
	)
	_assert_eq(partial_layer.layer_stack_resource, existing_stack, "NODE-22 existing layer stack reference is preserved")

	workspace.clear_selected_hex_tile_map_layer("test.node22.clear")
	var blocked_result = workspace.create_missing_selected_hex_tile_map_resources(save_dir, "NoSelection")
	_assert_true(not bool(blocked_result["ok"]), "NODE-22 no selected HexTileMap blocks creation")
	_assert_eq(int(blocked_result["error"]), ERR_DOES_NOT_EXIST, "NODE-22 no selected HexTileMap returns missing target error")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _test_workspace_asset_selection_writes_back_to_selected_hex_tile_map() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var scene_root = Node2D.new()
	scene_root.name = "WritebackScene"
	root.add_child(scene_root)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "WritebackHexTileMap"
	scene_root.add_child(selected_layer)
	await process_frame
	workspace.set_selected_hex_tile_map_node(selected_layer, "test.node23.select")

	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	workspace.workspace_asset_context().set_level_document(document)
	_assert_eq(selected_layer.level_document_resource, document, "NODE-23 Document slot writes to selected HexTileMap")
	_assert_eq(session.current_document(), document, "NODE-23 Document write-back updates session document")
	var writeback = workspace.selected_hex_tile_map_writeback_snapshot()
	_assert_eq(String(writeback["state_source"]), "HexMapWorkspaceBindingService", "ARCH-40 selected writeback snapshot is service-owned")
	_assert_true((writeback["relationship_slot_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE), "ARCH-40 writeback service covers profile dependency slots")
	var relationships = writeback["relationships"] as Dictionary
	var document_relationship = relationships[HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT] as Dictionary
	_assert_eq(String(document_relationship["status"]), "linked", "NODE-23 Document relationship is visible as linked")
	_assert_true(bool(document_relationship["matches"]), "NODE-23 Document relationship reports node/workspace match")
	var binding_state = workspace.selected_hex_tile_map_binding_state_snapshot()
	_assert_true((binding_state["active_state_ids"] as PackedStringArray).has(HexMapWorkspaceBindingService.STATE_APPLIED_WRITEBACK), "STATE-30 document writeback records applied writeback state")

	var stack = HexLayerStackResource.minimal_runtime_template()
	workspace.workspace_asset_context().set_layer_stack(stack)
	_assert_eq(selected_layer.layer_stack_resource, stack, "NODE-23 Layer Stack slot writes to selected HexTileMap")
	_assert_eq(workspace.edit_tool().layer_stack_resource(), stack, "NODE-23 Layer Stack write-back updates edit tool")
	writeback = workspace.selected_hex_tile_map_writeback_snapshot()
	relationships = writeback["relationships"] as Dictionary
	var stack_relationship = relationships[HexMapWorkspaceAssetContext.SLOT_LAYER_STACK] as Dictionary
	_assert_eq(String(stack_relationship["status"]), "linked", "NODE-23 Layer Stack relationship is visible as linked")

	var catalog = HexTileCatalogResource.new()
	var object_database = HexObjectDatabaseResource.new()
	var label_database = HexLabelDatabaseResource.new()
	var movement_profile = HexMovementProfileResource.new()
	var validation_suite = HexValidationRuleSuiteResource.new()
	var generation_profile = HexGenerationProfileResource.new()
	var export_profile = HexExportProfileResource.new()
	workspace.workspace_asset_context().set_tile_catalog(catalog)
	workspace.workspace_asset_context().set_object_database(object_database)
	workspace.workspace_asset_context().set_label_database(label_database)
	workspace.workspace_asset_context().set_movement_profile(movement_profile)
	workspace.workspace_asset_context().set_validation_rule_suite(validation_suite)
	workspace.workspace_asset_context().set_generation_profile(generation_profile)
	workspace.workspace_asset_context().set_export_profile(export_profile)
	writeback = workspace.selected_hex_tile_map_writeback_snapshot()
	relationships = writeback["relationships"] as Dictionary
	var catalog_relationship = relationships[HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG] as Dictionary
	var object_relationship = relationships[HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE] as Dictionary
	var label_relationship = relationships[HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE] as Dictionary
	_assert_eq(String(catalog_relationship["policy"]), "document_dependency", "NODE-20 Tile Catalog writes through document dependency")
	_assert_eq(String(object_relationship["policy"]), "document_dependency", "NODE-20 Object Database writes through document dependency")
	_assert_eq(String(label_relationship["policy"]), "document_dependency", "NODE-20 Label Database writes through document dependency")
	_assert_eq(catalog_relationship["node_resource"], null, "NODE-23 Tile Catalog is not copied onto the node")
	_assert_eq(object_relationship["node_resource"], null, "NODE-23 Object Database is not copied onto the node")
	_assert_eq(label_relationship["node_resource"], null, "NODE-23 Label Database is not copied onto the node")
	_assert_eq(catalog_relationship["dependency_resource"], catalog, "NODE-20 Tile Catalog dependency matches workspace resource")
	_assert_eq(object_relationship["dependency_resource"], object_database, "NODE-20 Object Database dependency matches workspace resource")
	_assert_eq(label_relationship["dependency_resource"], label_database, "NODE-20 Label Database dependency matches workspace resource")
	_assert_eq(
		HexMapDocumentDependencyService.find_shared_dependency(document, HexMapDocumentDependencyService.KEY_TILE_CATALOG).get("resource"),
		catalog,
		"NODE-20 Tile Catalog writes to selected document dependency"
	)
	_assert_eq(
		HexMapDocumentDependencyService.find_shared_dependency(document, HexMapDocumentDependencyService.KEY_OBJECT_DATABASE).get("resource"),
		object_database,
		"NODE-20 Object Database writes to selected document dependency"
	)
	_assert_eq(
		HexMapDocumentDependencyService.find_shared_dependency(document, HexMapDocumentDependencyService.KEY_LABEL_DATABASE).get("resource"),
		label_database,
		"NODE-20 Label Database writes to selected document dependency"
	)
	_assert_eq(
		HexMapDocumentDependencyService.find_shared_dependency(document, HexMapDocumentDependencyService.KEY_MOVEMENT_PROFILE).get("resource"),
		movement_profile,
		"NODE-20 Movement Profile writes to selected document dependency"
	)
	_assert_eq(
		HexMapDocumentDependencyService.find_shared_dependency(document, HexMapDocumentDependencyService.KEY_VALIDATION_RULE_SUITE).get("resource"),
		validation_suite,
		"NODE-20 Validation Suite writes to selected document dependency"
	)
	_assert_eq(
		HexMapDocumentDependencyService.find_shared_dependency(document, HexMapDocumentDependencyService.KEY_GENERATION_PROFILE).get("resource"),
		generation_profile,
		"NODE-20 Generation Profile writes to selected document dependency"
	)
	_assert_eq(
		HexMapDocumentDependencyService.find_shared_dependency(document, HexMapDocumentDependencyService.KEY_EXPORT_PROFILE).get("resource"),
		export_profile,
		"NODE-20 Export Profile writes to selected document dependency"
	)
	var direct_dependency_sync = HexMapWorkspaceBindingService.sync_shared_context_to_document_dependencies(
		selected_layer,
		workspace.workspace_asset_context(),
		"test.arch40.direct_sync",
		false
	)
	_assert_eq(String(direct_dependency_sync["state_source"]), "HexMapWorkspaceBindingService", "ARCH-40 shared dependency sync is service-owned")
	_assert_true((direct_dependency_sync["applied_slot_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE), "ARCH-40 service sync covers Export Profile dependency")
	binding_state = workspace.selected_hex_tile_map_binding_state_snapshot()
	_assert_true((binding_state["active_state_ids"] as PackedStringArray).has(HexMapWorkspaceBindingService.STATE_MANUAL_OVERRIDE), "STATE-30 project resource selections are explicit manual override state")
	_assert_true((binding_state["active_state_ids"] as PackedStringArray).has(HexMapWorkspaceBindingService.STATE_APPLIED_WRITEBACK), "STATE-30 shared dependency writeback remains explicit applied state")

	session.set_auto_link_selected_hex_tile_map(false, "test.node23.disable_auto_link")
	var blocked_document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	workspace.workspace_asset_context().set_level_document(blocked_document)
	_assert_eq(selected_layer.level_document_resource, document, "NODE-23 auto-link OFF blocks node-owned write-back")
	writeback = workspace.selected_hex_tile_map_writeback_snapshot()
	_assert_true(not bool(writeback["can_writeback"]), "NODE-23 write-back snapshot blocks when auto-link is OFF")
	_assert_eq(String(writeback["blocked_reason"]), "Auto-link is off.", "NODE-23 auto-link OFF reason is visible")
	binding_state = workspace.selected_hex_tile_map_binding_state_snapshot(writeback)
	_assert_true((binding_state["active_state_ids"] as PackedStringArray).has(HexMapWorkspaceBindingService.STATE_CONFLICT), "STATE-30 conflicting workspace/node document state is explicit")

	var pending_layer = HexTileMapLayer.new()
	pending_layer.name = "PendingWritebackHexTileMap"
	scene_root.add_child(pending_layer)
	await process_frame
	workspace.set_selected_hex_tile_map_node(pending_layer, "test.node23.pending_select")
	var pending_document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(3, 1))
	)
	workspace.workspace_asset_context().set_level_document(pending_document)
	binding_state = workspace.selected_hex_tile_map_binding_state_snapshot()
	_assert_true((binding_state["active_state_ids"] as PackedStringArray).has(HexMapWorkspaceBindingService.STATE_PENDING_WRITEBACK), "STATE-30 pending writeback state is explicit")
	_assert_true((binding_state["pending_writeback_slot_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT), "STATE-30 pending writeback records Level Document slot")

	workspace.clear_selected_hex_tile_map_layer("test.node23.clear")
	var no_selection_result = workspace.apply_workspace_asset_context_to_selected_hex_tile_map(
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
		"test.node23.no_selection"
	)
	_assert_true(not bool(no_selection_result["ok"]), "NODE-23 no selected HexTileMap blocks explicit write-back")
	_assert_eq(String(no_selection_result["blocked_reason"]), "No HexTileMap selected", "NODE-23 no selected reason is visible")

	scene_root.queue_free()
	workspace.queue_free()
	await process_frame


func _test_workspace_tab_content_query_contract_lists_expected_components_and_slots() -> void:
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
	var expected_contract := {
		"Resources": {
			"components": PackedStringArray(["resources_context_panel", "document_asset_panel", "missing_unique_resources_panel"]),
			"screen_script": "hex_map_resources_screen.gd",
			"screen_role_source": "HexMapResourcesScreen",
			"slots": PackedStringArray([
				HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
				HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
				HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE,
				HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE,
				HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
				HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE,
			]),
		},
		"Build": {
			"components": PackedStringArray(["build_graph_screen", "generation_panel"]),
			"screen_script": "hex_map_build_screen.gd",
			"screen_role_source": "HexMapBuildScreen",
			"component_owners": {
				"generation_panel": {
					"screen_script": "hex_map_gen_dock.gd",
					"screen_role_source": "HexMapGenDock",
				},
			},
			"slots": PackedStringArray(),
		},
		"Paint": {
			"components": PackedStringArray(["brush_palette"]),
			"screen_script": "hex_map_paint_screen.gd",
			"screen_role_source": "HexMapPaintScreen",
			"slots": PackedStringArray(),
		},
		"Catalog": {
			"components": PackedStringArray(["catalog_visual_board", "catalog_detail_panel", "catalog_asset_panel"]),
			"screen_script": "hex_map_catalog_screen.gd",
			"screen_role_source": "HexMapCatalogScreen",
			"slots": PackedStringArray([HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG]),
		},
		"Layers": {
			"components": PackedStringArray(["layer_stack_role_panel", "layer_stack_asset_panel", "layer_role_stack_visual"]),
			"screen_script": "hex_map_layers_screen.gd",
			"screen_role_source": "HexMapLayersScreen",
			"slots": PackedStringArray([HexMapWorkspaceAssetContext.SLOT_LAYER_STACK]),
		},
		"Validate": {
			"components": PackedStringArray(["validation_asset_panel", "validation_issue_navigator"]),
			"screen_script": "hex_map_validate_screen.gd",
			"screen_role_source": "HexMapValidateScreen",
			"slots": PackedStringArray([
				HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
				HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE,
			]),
		},
		"QA": {
			"components": PackedStringArray(["qa_seed_lab_panel", "qa_asset_panel"]),
			"screen_script": "hex_map_qa_screen.gd",
			"screen_role_source": "HexMapQAScreen",
			"slots": PackedStringArray([
				HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE,
				HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE,
				HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
			]),
		},
		"Export": {
			"components": PackedStringArray(["export_purpose_panel", "export_asset_panel", "export_destination_panel"]),
			"screen_script": "hex_map_export_screen.gd",
			"screen_role_source": "HexMapExportScreen",
			"slots": PackedStringArray([
				HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
				HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE,
			]),
		},
		"Settings": {
			"components": PackedStringArray(["settings_preferences_panel", "sample_settings_panel"]),
			"screen_script": "hex_map_settings_screen.gd",
			"screen_role_source": "HexMapSettingsScreen",
			"slots": PackedStringArray(),
		},
	}
	var builder_components := {
		"resources_context_panel": "build_resources_context_panel",
		"missing_unique_resources_panel": "build_missing_unique_resources_panel",
		"catalog_visual_board": "build_catalog_detail_panel",
		"catalog_detail_panel": "build_catalog_detail_panel",
		"layer_stack_role_panel": "build_layer_stack_role_panel",
		"layer_role_stack_visual": "build_layer_stack_role_panel",
		"validation_issue_navigator": "build_validation_issue_navigator",
		"qa_seed_lab_panel": "build_seed_lab_panel",
		"export_purpose_panel": "build_export_purpose_panel",
		"export_destination_panel": "build_export_destination_panel",
		"settings_preferences_panel": "build_settings_preferences_panel",
	}
	var screen_script_owner_rows := {
		"Resources": HexMapResourcesScreen.component_owner_rows(),
		"Catalog": HexMapCatalogScreen.component_owner_rows(),
		"Layers": HexMapLayersScreen.component_owner_rows(),
		"Validate": HexMapValidateScreen.component_owner_rows(),
		"QA": HexMapQAScreen.component_owner_rows(),
		"Export": HexMapExportScreen.component_owner_rows(),
		"Settings": HexMapSettingsScreen.component_owner_rows(),
	}

	_assert_eq(workspace.workspace_tab_names(), expected_tabs, "TEST-41 workspace tab query exposes expected UX tabs")
	var expected_component_row_count := 0
	for tab_name in expected_tabs:
		var contract = expected_contract[tab_name] as Dictionary
		var expected_components = contract["components"] as PackedStringArray
		var expected_slots = contract["slots"] as PackedStringArray
		var expected_screen_script := String(contract["screen_script"])
		var expected_role_source := String(contract["screen_role_source"])
		var component_owners = contract.get("component_owners", {}) as Dictionary
		expected_component_row_count += expected_components.size()
		_assert_eq(workspace.tab_component_ids(tab_name), expected_components, "TEST-41 %s component ids match contract" % tab_name)
		_assert_eq(workspace.components_for_tab(tab_name).size(), expected_components.size(), "TEST-41 %s component row count matches contract" % tab_name)
		_assert_eq(workspace.tab_asset_slot_ids(tab_name), expected_slots, "TEST-41 %s asset slot ids match contract" % tab_name)
		_assert_eq(workspace.asset_slot_count(tab_name), expected_slots.size(), "TEST-41 %s asset slot count matches contract" % tab_name)
		_assert_true(workspace.tab_has_scroll_container(tab_name), "TEST-41 %s has workspace scroll root" % tab_name)
		_assert_eq(workspace.tab_scroll_root_class(tab_name), "ScrollContainer", "TEST-41 %s root class is ScrollContainer" % tab_name)
		_assert_eq(workspace.tab_content_root_class(tab_name), "VBoxContainer", "TEST-41 %s content class is VBoxContainer" % tab_name)
		for component_id in expected_components:
			var component_owner = component_owners.get(String(component_id), {}) as Dictionary
			var component_screen_script := String(component_owner.get("screen_script", expected_screen_script))
			var component_role_source := String(component_owner.get("screen_role_source", expected_role_source))
			_assert_true(workspace.tab_has_component(tab_name, String(component_id)), "TEST-41 %s has component %s" % [tab_name, component_id])
			var owner := workspace.component_owner_for(tab_name, String(component_id))
			_assert_eq(String(owner.get("screen_script", "")), component_screen_script, "ARCH-NEXT-10 %s/%s registry screen owner" % [tab_name, component_id])
			_assert_eq(String(owner.get("screen_role_source", "")), component_role_source, "ARCH-NEXT-10 %s/%s registry role owner" % [tab_name, component_id])
			var mounted_owner := workspace.mounted_component_owner_for(tab_name, String(component_id))
			_assert_eq(String(mounted_owner.get("screen_script", "")), component_screen_script, "ARCH-NEXT-10 %s/%s mounted screen owner" % [tab_name, component_id])
			_assert_eq(String(mounted_owner.get("screen_role_source", "")), component_role_source, "ARCH-NEXT-10 %s/%s mounted role owner" % [tab_name, component_id])
			if builder_components.has(String(component_id)):
				_assert_eq(
					String(mounted_owner.get("builder", "")),
					String(builder_components[String(component_id)]),
					"ARCH-NEXT-10 %s/%s physical builder owner" % [tab_name, component_id]
				)
		for slot_id in expected_slots:
			_assert_true(workspace.tab_asset_slot_ids(tab_name).has(String(slot_id)), "TEST-41 %s has asset slot %s" % [tab_name, slot_id])
		if screen_script_owner_rows.has(tab_name):
			var screen_rows = screen_script_owner_rows[tab_name] as Array
			_assert_eq(screen_rows.size(), expected_components.size(), "ARCH-NEXT-10 %s screen script owner row count" % tab_name)
			var screen_component_ids := PackedStringArray()
			for screen_row in screen_rows:
				var screen_row_data := screen_row as Dictionary
				screen_component_ids.append(String(screen_row_data.get("component_id", "")))
				_assert_eq(String(screen_row_data.get("screen_script", "")), expected_screen_script, "ARCH-NEXT-10 %s script row owner" % tab_name)
				_assert_eq(String(screen_row_data.get("screen_role_source", "")), expected_role_source, "ARCH-NEXT-10 %s script role owner" % tab_name)
			_assert_eq(screen_component_ids, expected_components, "ARCH-NEXT-10 %s screen script component ids" % tab_name)

	_assert_eq(workspace.component_rows().size(), expected_component_row_count, "TEST-41 component registry row count matches tab contract")
	_assert_eq(workspace.component_owner_rows().size(), expected_component_row_count, "ARCH-NEXT-10 component owner registry row count matches tab contract")
	for row in workspace.component_rows():
		var tab_name := String(row.get("tab", ""))
		var component_id := String(row.get("component_id", ""))
		var component_class := String(row.get("component_class", ""))
		var responsibility := String(row.get("responsibility", ""))
		var source_owner := String(row.get("source_owner", ""))
		var screen_script := String(row.get("screen_script", ""))
		var screen_role_source := String(row.get("screen_role_source", ""))
		var row_slot_ids := PackedStringArray(row.get("asset_slot_ids", PackedStringArray()))
		_assert_true(expected_tabs.has(tab_name), "TEST-41 component row tab is registered")
		_assert_true(component_id != "", "TEST-41 component row has stable component id")
		_assert_true(component_class != "", "TEST-41 component row has component class")
		_assert_true(responsibility != "", "TEST-41 component row has responsibility")
		_assert_true(source_owner != "", "TEST-41 component row has source owner")
		_assert_true(screen_script != "", "ARCH-NEXT-10 component row has screen script owner")
		_assert_true(screen_role_source != "", "ARCH-NEXT-10 component row has screen role owner")
		_assert_true(workspace.tab_component_ids(tab_name).has(component_id), "TEST-41 component row is mounted in tab query")
		for slot_id in row_slot_ids:
			_assert_true(
				HexMapWorkspaceAssetContext.asset_slot_ids().has(String(slot_id)),
				"TEST-41 component row asset slot id is known: %s" % slot_id
			)

	var expected_screen_roles := {
		"Build": "hex_map_build_screen.gd",
		"Resources": "hex_map_resources_screen.gd",
		"Paint": "hex_map_paint_screen.gd",
		"Catalog": "hex_map_catalog_screen.gd",
		"Layers": "hex_map_layers_screen.gd",
		"Validate": "hex_map_validate_screen.gd",
		"QA": "hex_map_qa_screen.gd",
		"Export": "hex_map_export_screen.gd",
		"Settings": "hex_map_settings_screen.gd",
	}
	var screen_roles := workspace.workspace_screen_role_contracts()
	_assert_eq(screen_roles.size(), expected_screen_roles.size(), "ARCH-41 screen role registry has one contract per extracted screen script")
	var screen_snapshots := {
		"Build": workspace.generation_screen_snapshot(),
		"Resources": workspace.resources_screen_snapshot(),
		"Paint": workspace.paint_brush_screen_snapshot(),
		"Catalog": workspace.catalog_screen_snapshot(),
		"Layers": workspace.layer_stack_screen_snapshot(),
		"Validate": workspace.validate_screen_snapshot(),
		"QA": workspace.qa_screen_snapshot(),
		"Export": workspace.export_screen_snapshot(),
		"Settings": workspace.settings_screen_snapshot(),
	}
	for tab_name in expected_screen_roles.keys():
		var role = workspace.screen_role_contract_for_tab(String(tab_name)) as Dictionary
		_assert_eq(String(role["tab"]), String(tab_name), "ARCH-41 screen role maps to tab %s" % tab_name)
		_assert_eq(String(role["screen_script"]), String(expected_screen_roles[tab_name]), "ARCH-41 screen role script maps to %s" % tab_name)
		_assert_true(String(role["workflow_owner"]) != "", "ARCH-41 screen role has workflow owner")
		_assert_true(String(role["user_task"]) != "", "ARCH-41 screen role is justified by user task")
		_assert_true((role["owns"] as PackedStringArray).size() > 0, "ARCH-41 screen role owns at least one workflow section")
		var screen_snapshot = screen_snapshots[tab_name] as Dictionary
		_assert_eq(String(screen_snapshot["screen_script"]), String(expected_screen_roles[tab_name]), "ARCH-41 snapshot uses screen script for %s" % tab_name)
		_assert_eq(String(screen_snapshot["workflow_owner"]), String(role["workflow_owner"]), "ARCH-41 snapshot workflow owner comes from role for %s" % tab_name)

	_assert_true(not workspace.tab_has_component("Paint", "document_asset_panel"), "TEST-41 Paint tab excludes Document setup panel")
	var resources_contract = expected_contract["Resources"] as Dictionary
	_assert_eq(
		workspace.tab_component_ids("Document"),
		resources_contract["components"],
		"TAB-50 legacy Document tab query aliases Resources components"
	)
	_assert_eq(
		workspace.tab_asset_slot_ids("Document"),
		resources_contract["slots"],
		"TAB-50 legacy Document tab query aliases Resources asset slots"
	)
	_assert_true(workspace.select_workspace_tab("Document"), "TAB-50 legacy Document tab selection aliases Resources tab")
	_assert_eq(workspace.current_workspace_tab_name(), "Resources", "TAB-50 legacy Document selection lands on Resources tab")
	_assert_eq(workspace.tab_component_ids("MissingTab"), PackedStringArray(), "TEST-41 missing tab has no component ids")
	_assert_eq(workspace.tab_asset_slot_ids("MissingTab"), PackedStringArray(), "TEST-41 missing tab has no asset slot ids")
	_assert_eq(workspace.asset_slot_count("MissingTab"), 0, "TEST-41 missing tab has zero asset slots")

	workspace.queue_free()
	await process_frame


func _test_workspace_first_run_learning_cta_routes_to_settings_without_sample_defaults() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	_assert_true(session.sample_learning_cta_visible(), "sample learning CTA is visible for first workspace session")
	var snapshot = workspace.sample_learning_cta_snapshot()
	_assert_true(bool(snapshot["visible"]), "workspace exposes visible first-run sample CTA")
	_assert_eq(String(snapshot["learn_label"]), "Learn with bundled samples", "sample CTA uses learning action label")
	_assert_eq(workspace.current_workspace_tab_name(), "Build", "workspace starts on normal project Build tab")
	_assert_true(
		not session.show_bundled_samples_in_main_selectors,
		"sample CTA does not enable sample selector visibility by default"
	)
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "sample CTA initial state does not assign generation sample catalog")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "sample CTA initial state does not assign paint sample catalog")

	workspace.open_sample_learning_cta()
	await process_frame
	snapshot = workspace.sample_learning_cta_snapshot()
	_assert_true(not bool(snapshot["visible"]), "opening sample CTA hides it for this session")
	_assert_true(bool(snapshot["dismissed"]), "opening sample CTA records dismissed first-run state")
	_assert_eq(workspace.current_workspace_tab_name(), "Settings", "sample CTA routes to Settings tab")
	_assert_true(
		not session.show_bundled_samples_in_main_selectors,
		"sample CTA routing does not enable sample mode"
	)
	_assert_true(
		not session.use_bundled_sample_assets_for_scratch_documents,
		"sample CTA routing does not enable scratch sample assets"
	)
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "sample CTA routing does not assign generation sample catalog")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "sample CTA routing does not assign paint sample catalog")

	workspace.queue_free()
	await process_frame

	var reused_workspace = HexMapWorkspace.new()
	reused_workspace.set_editor_session_state(session)
	root.add_child(reused_workspace)
	await process_frame
	_assert_true(not reused_workspace.sample_learning_cta_visible(), "dismissed sample CTA does not reappear in same session")
	reused_workspace.queue_free()
	await process_frame

	var dismiss_session = HexMapEditorSessionState.new()
	var dismiss_workspace = HexMapWorkspace.new()
	dismiss_workspace.set_editor_session_state(dismiss_session)
	root.add_child(dismiss_workspace)
	await process_frame
	_assert_true(dismiss_workspace.sample_learning_cta_visible(), "fresh session starts with sample CTA")
	dismiss_workspace.dismiss_sample_learning_cta()
	await process_frame
	_assert_true(not dismiss_workspace.sample_learning_cta_visible(), "sample CTA dismiss action hides CTA")
	_assert_eq(dismiss_workspace.current_workspace_tab_name(), "Build", "dismissing sample CTA keeps normal project Build tab")
	_assert_true(
		not dismiss_session.show_bundled_samples_in_main_selectors,
		"dismissing sample CTA does not enable sample mode"
	)
	_assert_eq(dismiss_workspace.generation_dock().tile_catalog(), null, "dismissed sample CTA leaves generation catalog unset")
	_assert_eq(dismiss_workspace.edit_tool().tile_catalog(), null, "dismissed sample CTA leaves paint catalog unset")

	dismiss_workspace.queue_free()
	await process_frame


func _test_workspace_asset_context_is_shared_by_workspace_generate_and_paint() -> void:
	var context = HexMapWorkspaceAssetContext.new()
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var catalog = HexTileCatalogResource.new()
	var object_database = HexObjectDatabaseResource.new()
	var label_database = HexLabelDatabaseResource.new()
	var layer_stack = HexLayerStackResource.minimal_runtime_template()
	var movement_profile = HexMovementProfileResource.new()
	var validation_suite = HexValidationRuleSuiteResource.new()
	var generation_profile = HexGenerationProfileResource.new()
	var export_profile = HexExportProfileResource.new()

	context.set_level_document(document)
	context.set_tile_catalog(catalog)
	context.set_object_database(object_database)
	context.set_label_database(label_database)
	context.set_layer_stack(layer_stack)
	context.set_movement_profile(movement_profile)
	context.set_validation_rule_suite(validation_suite)
	context.set_generation_profile(generation_profile)
	context.set_export_profile(export_profile)

	var slot_ids = HexMapWorkspaceAssetContext.asset_slot_ids()
	_assert_true(slot_ids.has("tile_catalog"), "workspace asset context exposes tile catalog slot id")
	_assert_true(slot_ids.has("object_database"), "workspace asset context exposes object database slot id")
	_assert_true(slot_ids.has("label_database"), "workspace asset context exposes label database slot id")
	_assert_true(slot_ids.has("layer_stack"), "workspace asset context exposes layer stack slot id")
	_assert_true(slot_ids.has("movement_profile"), "workspace asset context exposes movement profile slot id")
	_assert_true(slot_ids.has("validation_rule_suite"), "workspace asset context exposes validation suite slot id")
	_assert_true(slot_ids.has("generation_profile"), "workspace asset context exposes generation profile slot id")
	_assert_true(slot_ids.has("export_profile"), "workspace asset context exposes export profile slot id")

	var snapshot = context.snapshot()
	_assert_eq(snapshot["level_document"], document, "workspace asset context holds level document")
	_assert_eq(snapshot["tile_catalog"], catalog, "workspace asset context holds tile catalog")
	_assert_eq(snapshot["object_database"], object_database, "workspace asset context holds object database")
	_assert_eq(snapshot["label_database"], label_database, "workspace asset context holds label database")
	_assert_eq(snapshot["layer_stack"], layer_stack, "workspace asset context holds layer stack")
	_assert_eq(snapshot["movement_profile"], movement_profile, "workspace asset context holds movement profile")
	_assert_eq(snapshot["validation_rule_suite"], validation_suite, "workspace asset context holds validation suite")
	_assert_eq(snapshot["generation_profile"], generation_profile, "workspace asset context holds generation profile")
	_assert_eq(snapshot["export_profile"], export_profile, "workspace asset context holds export profile")

	var session = HexMapEditorSessionState.new()
	var recorder = SessionChangeRecorder.new()
	session.changed.connect(Callable(recorder, "record"))
	session.set_workspace_asset_context(context, "test.asset_context")
	_assert_eq(session.current_workspace_asset_context(), context, "session owns workspace asset context")
	_assert_true(recorder.keys.has("workspace_asset_context"), "session emits context replacement key")

	var session_catalog = HexTileCatalogResource.new()
	session.set_workspace_asset(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, session_catalog, "test.tile_catalog")
	_assert_eq(context.tile_catalog, session_catalog, "session publishes asset changes into context")
	_assert_true(
		recorder.keys.has("workspace_asset_context.tile_catalog"),
		"session republishes context slot change key"
	)

	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	_assert_eq(workspace.workspace_asset_context(), context, "workspace exposes session asset context")
	_assert_eq(
		workspace.workspace_asset_context_for_tab("Generate"),
		context,
		"Generate legacy tab name receives workspace asset context"
	)
	_assert_eq(
		workspace.workspace_asset_context_for_tab("Paint"),
		context,
		"Paint tab receives workspace asset context"
	)
	_assert_eq(
		workspace.workspace_asset_context_for_tab("Validate"),
		context,
		"Validate tab resolves the shared workspace asset context"
	)
	_assert_eq(
		workspace.workspace_asset_context_for_tab("QA"),
		context,
		"QA tab resolves the shared workspace asset context"
	)
	_assert_eq(
		workspace.generation_dock().workspace_asset_context(),
		context,
		"generation dock references workspace asset context"
	)
	_assert_eq(
		workspace.edit_tool().workspace_asset_context(),
		context,
		"paint tool references workspace asset context"
	)
	_assert_eq(
		workspace.generation_dock().tile_catalog(),
		session_catalog,
		"generation dock consumes context tile catalog"
	)
	_assert_eq(
		workspace.tab_asset_slot_snapshot("Catalog", HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG).get("current_resource", null),
		session_catalog,
		"Catalog tab asset slot consumes context tile catalog"
	)
	_assert_eq(
		workspace.edit_tool().tile_catalog(),
		session_catalog,
		"paint tool consumes context tile catalog"
	)

	var paint_catalog = HexTileCatalogResource.new()
	var paint_object_database = HexObjectDatabaseResource.new()
	var paint_label_database = HexLabelDatabaseResource.new()
	var paint_layer_stack = HexLayerStackResource.standard_template()
	workspace.edit_tool().set_tile_catalog(paint_catalog)
	workspace.edit_tool().set_object_database(paint_object_database)
	workspace.edit_tool().set_label_database(paint_label_database)
	workspace.edit_tool().set_layer_stack_resource(paint_layer_stack)
	_assert_eq(context.tile_catalog, paint_catalog, "paint tool publishes selected catalog to context")
	_assert_eq(context.object_database, paint_object_database, "paint tool publishes selected object database to context")
	_assert_eq(context.label_database, paint_label_database, "paint tool publishes selected label database to context")
	_assert_eq(context.layer_stack, paint_layer_stack, "paint tool publishes selected layer stack to context")
	_assert_eq(
		workspace.generation_dock().tile_catalog(),
		paint_catalog,
		"generation dock consumes paint-selected project catalog through context"
	)
	_assert_eq(
		workspace.tab_asset_slot_snapshot("Catalog", HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG).get("current_resource", null),
		paint_catalog,
		"Catalog tab asset slot tracks paint-selected project catalog through context"
	)

	workspace.queue_free()
	await process_frame


func _test_workspace_hydrates_asset_context_from_document_dependencies() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var catalog = HexTileCatalogResource.new()
	var object_database = HexObjectDatabaseResource.new()
	var label_database = HexLabelDatabaseResource.new()
	var movement_profile = HexMovementProfileResource.new()
	var validation_suite = HexValidationRuleSuiteResource.new()
	var generation_profile = HexGenerationProfileResource.new()
	var export_profile = HexExportProfileResource.new()
	HexMapDocumentDependencyService.set_shared_dependency(document, HexMapDocumentDependencyService.KEY_TILE_CATALOG, catalog)
	HexMapDocumentDependencyService.set_shared_dependency(document, HexMapDocumentDependencyService.KEY_OBJECT_DATABASE, object_database)
	HexMapDocumentDependencyService.set_shared_dependency(document, HexMapDocumentDependencyService.KEY_LABEL_DATABASE, label_database)
	HexMapDocumentDependencyService.set_shared_dependency(document, HexMapDocumentDependencyService.KEY_MOVEMENT_PROFILE, movement_profile)
	HexMapDocumentDependencyService.set_shared_dependency(document, HexMapDocumentDependencyService.KEY_VALIDATION_RULE_SUITE, validation_suite)
	HexMapDocumentDependencyService.set_shared_dependency(document, HexMapDocumentDependencyService.KEY_GENERATION_PROFILE, generation_profile)
	HexMapDocumentDependencyService.set_shared_dependency(document, HexMapDocumentDependencyService.KEY_EXPORT_PROFILE, export_profile)

	var context := workspace.workspace_asset_context()
	context.set_level_document(document)
	await process_frame

	_assert_eq(context.tile_catalog, catalog, "RES-11 document dependency hydrates Tile Catalog")
	_assert_eq(context.object_database, object_database, "RES-11 document dependency hydrates Object Database")
	_assert_eq(context.label_database, label_database, "RES-11 document dependency hydrates Label Database")
	_assert_eq(context.movement_profile, movement_profile, "RES-11 document dependency hydrates Movement Profile")
	_assert_eq(context.validation_rule_suite, validation_suite, "RES-11 document dependency hydrates Validation Rule Suite")
	_assert_eq(context.generation_profile, generation_profile, "RES-11 document dependency hydrates Generation Profile")
	_assert_eq(context.export_profile, export_profile, "RES-11 document dependency hydrates Export Profile")
	_assert_eq(workspace.generation_dock().tile_catalog(), catalog, "RES-11 Generate consumes hydrated Tile Catalog")
	_assert_eq(workspace.edit_tool().tile_catalog(), catalog, "RES-11 Paint consumes hydrated Tile Catalog")
	_assert_eq(workspace.edit_tool().object_database(), object_database, "RES-11 Paint consumes hydrated Object Database")
	_assert_eq(workspace.edit_tool().label_database(), label_database, "RES-11 Paint consumes hydrated Label Database")

	var catalog_slot = workspace.tab_asset_slot_snapshot("Catalog", HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG)
	_assert_eq(
		String(catalog_slot.get("current_source", "")),
		HexMapEditorAssetSlotState.SOURCE_DOCUMENT_DEPENDENCY,
		"RES-11 Catalog row source records document dependency"
	)
	_assert_eq(
		String(catalog_slot.get("current_source_badge", "")),
		HexMapDocumentDependencyService.SOURCE_BADGE_DOCUMENT_DEPENDENCY,
		"RES-11 Catalog row shows Document Dependency badge"
	)
	var validate_snapshot = workspace.validate_screen_snapshot()
	var validation_suite_slot = validate_snapshot["validation_rule_suite_slot"] as Dictionary
	_assert_eq(
		validation_suite_slot.get("current_resource", null),
		validation_suite,
		"PROFILE-31 Validate tab shows hydrated concrete Validation Rule Suite"
	)
	_assert_eq(
		String(validation_suite_slot.get("required_type", "")),
		"HexValidationRuleSuiteResource",
		"PROFILE-31 Validate tab uses concrete Validation Rule Suite type"
	)
	_assert_eq(
		String(validation_suite_slot.get("current_source_badge", "")),
		HexMapDocumentDependencyService.SOURCE_BADGE_DOCUMENT_DEPENDENCY,
		"PROFILE-31 Validate tab shows Validation Rule Suite document dependency badge"
	)
	var validation_suite_context = validate_snapshot["validation_rule_suite_context"] as Dictionary
	_assert_eq(
		String(validation_suite_context.get("resource_class", "")),
		"HexValidationRuleSuiteResource",
		"PROFILE-31 Validate profile context reports concrete class"
	)
	var validation_behavior = validation_suite_context["behavior_schema"] as Dictionary
	_assert_eq(
		String(validation_behavior.get("kind", "")),
		"validation_rule_suite",
		"PROFILE-NEXT-10 Validate profile context exposes validation behavior schema"
	)
	_assert_eq(
		String(validation_suite_context.get("behavior_schema_status", "")),
		"selected",
		"PROFILE-NEXT-10 Validate profile context marks selected behavior schema"
	)
	_assert_true(
		String(validation_suite_context.get("behavior_summary", "")).contains("Validation schema"),
		"PROFILE-NEXT-10 Validate profile context exposes behavior summary"
	)
	var qa_snapshot = workspace.qa_screen_snapshot()
	var generation_profile_slot = qa_snapshot["generation_profile_slot"] as Dictionary
	_assert_eq(
		generation_profile_slot.get("current_resource", null),
		generation_profile,
		"PROFILE-31 QA tab shows hydrated concrete Generation Profile"
	)
	_assert_eq(
		String(generation_profile_slot.get("required_type", "")),
		"HexGenerationProfileResource",
		"PROFILE-31 QA tab uses concrete Generation Profile type"
	)
	_assert_eq(
		String((qa_snapshot["generation_profile_context"] as Dictionary).get("source_badge", "")),
		HexMapDocumentDependencyService.SOURCE_BADGE_DOCUMENT_DEPENDENCY,
		"PROFILE-31 QA profile context reports document dependency source"
	)
	var generation_profile_context = qa_snapshot["generation_profile_context"] as Dictionary
	var generation_behavior = generation_profile_context["behavior_schema"] as Dictionary
	_assert_eq(
		String(generation_behavior.get("kind", "")),
		"generation_profile",
		"PROFILE-NEXT-10 QA profile context exposes generation behavior schema"
	)
	_assert_eq(
		String(generation_profile_context.get("behavior_schema_status", "")),
		"selected",
		"PROFILE-NEXT-10 QA profile context marks selected generation behavior"
	)
	_assert_true(
		String(generation_profile_context.get("behavior_summary", "")).contains("Generation schema"),
		"PROFILE-NEXT-10 QA profile context exposes generation behavior summary"
	)
	var export_snapshot = workspace.export_screen_snapshot()
	var export_profile_slot = export_snapshot["export_profile_slot"] as Dictionary
	_assert_eq(
		export_profile_slot.get("current_resource", null),
		export_profile,
		"PROFILE-31 Export tab shows hydrated concrete Export Profile"
	)
	_assert_eq(
		String(export_profile_slot.get("required_type", "")),
		"HexExportProfileResource",
		"PROFILE-31 Export tab uses concrete Export Profile type"
	)
	_assert_eq(
		String((export_snapshot["export_profile_context"] as Dictionary).get("resource_class", "")),
		"HexExportProfileResource",
		"PROFILE-31 Export profile context reports concrete class"
	)
	var export_profile_context = export_snapshot["export_profile_context"] as Dictionary
	var export_behavior = export_profile_context["behavior_schema"] as Dictionary
	_assert_eq(
		String(export_behavior.get("kind", "")),
		"export_profile",
		"PROFILE-NEXT-10 Export profile context exposes export behavior schema"
	)
	_assert_eq(
		String(export_profile_context.get("behavior_schema_status", "")),
		"selected",
		"PROFILE-NEXT-10 Export profile context marks selected export behavior"
	)
	_assert_true(
		String(export_profile_context.get("behavior_summary", "")).contains("Export schema"),
		"PROFILE-NEXT-10 Export profile context exposes export behavior summary"
	)
	var resources_snapshot = workspace.resources_screen_snapshot()
	var source_snapshot = resources_snapshot["asset_source_snapshot"] as Dictionary
	_assert_eq(
		String((source_snapshot[HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE] as Dictionary)["source_badge"]),
		HexMapDocumentDependencyService.SOURCE_BADGE_DOCUMENT_DEPENDENCY,
		"RES-11 Resources source snapshot records Object Database dependency badge"
	)
	var resources_badges = _rows_by_slot(resources_snapshot["source_badge_rows"] as Array)
	_assert_eq(
		String((resources_badges[HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE] as Dictionary)["source_badge"]),
		HexMapDocumentDependencyService.SOURCE_BADGE_DOCUMENT_DEPENDENCY,
		"SCREEN-10 Resources source badge row records Object Database dependency badge"
	)

	var partial_document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var partial_catalog = HexTileCatalogResource.new()
	HexMapDocumentDependencyService.set_shared_dependency(partial_document, HexMapDocumentDependencyService.KEY_TILE_CATALOG, partial_catalog)
	context.set_level_document(partial_document)
	await process_frame

	_assert_eq(context.tile_catalog, partial_catalog, "RES-11 second document hydrates replacement Tile Catalog")
	_assert_eq(context.object_database, null, "RES-11 missing Object Database dependency stays missing")
	_assert_eq(context.label_database, null, "RES-11 missing Label Database dependency stays missing")
	_assert_eq(context.movement_profile, null, "RES-11 missing Movement Profile dependency stays missing")
	_assert_eq(context.validation_rule_suite, null, "RES-11 missing Validation Suite dependency stays missing")
	_assert_eq(context.generation_profile, null, "RES-11 missing Generation Profile dependency stays missing")
	_assert_eq(context.export_profile, null, "RES-11 missing Export Profile dependency stays missing")
	var missing_validation_slot = workspace.tab_asset_slot_snapshot("Validate", HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE)
	_assert_eq(bool(missing_validation_slot.get("is_required", true)), false, "PROFILE-31 missing Validation Suite is optional")
	_assert_eq(String(missing_validation_slot.get("status", "")), HexMapEditorAssetSlotState.STATUS_NOT_SELECTED, "PROFILE-31 missing Validation Suite is visible missing state")
	var missing_qa_slot = workspace.tab_asset_slot_snapshot("QA", HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE)
	_assert_eq(bool(missing_qa_slot.get("is_required", true)), false, "PROFILE-31 missing Generation Profile is optional")
	var missing_export_slot = workspace.tab_asset_slot_snapshot("Export", HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE)
	_assert_eq(bool(missing_export_slot.get("is_required", true)), false, "PROFILE-31 missing Export Profile is optional")
	_assert_true(
		not session.show_bundled_samples_in_main_selectors,
		"RES-11 missing dependency hydration does not enable bundled samples"
	)
	var validation_result = workspace.validate_workspace_assets()
	var missing_rules := PackedStringArray()
	for issue in validation_result.issues:
		if issue is Dictionary:
			missing_rules.append(String((issue as Dictionary).get("rule_id", "")))
	_assert_true(
		missing_rules.has("workspace.object_database_missing"),
		"RES-11 validation still reports missing Object Database after partial dependency hydration"
	)
	_assert_true(
		not missing_rules.has("workspace.validation_suite_missing") and not missing_rules.has("workspace.generation_profile_missing"),
		"PROFILE-31 workspace validation does not treat missing profiles as blocking issues"
	)

	var manual_catalog = HexTileCatalogResource.new()
	context.set_tile_catalog(manual_catalog)
	await process_frame
	var override_result = workspace.hydrate_workspace_context_from_document_dependencies(partial_document)
	_assert_eq(context.tile_catalog, manual_catalog, "RES-11 manual catalog override supersedes dependency hydration")
	_assert_eq(
		String(workspace.tab_asset_slot_snapshot("Catalog", HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG).get("current_source", "")),
		HexMapEditorAssetSlotState.SOURCE_PROJECT,
		"RES-11 manual override row returns to project source"
	)
	_assert_true(
		(override_result["skipped_manual_override_slot_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG),
		"RES-11 hydration result records skipped manual override"
	)

	workspace.queue_free()
	await process_frame


func _test_workspace_lifecycle_state_models_cover_required_transitions() -> void:
	var validation_state := HexMapValidationWorkflowState.new()
	validation_state.update_from_context({"running": true})
	_assert_eq(validation_state.state_id, HexMapValidationWorkflowState.STATE_RUNNING, "STATE-50 validation state covers running")
	validation_state.update_from_context({"result_present": true, "issue_count": 0, "error_count": 0, "warning_count": 0})
	_assert_eq(validation_state.state_id, HexMapValidationWorkflowState.STATE_CLEAN, "STATE-50 validation state covers clean")
	validation_state.update_from_context({"result_present": true, "issue_count": 1, "error_count": 0, "warning_count": 1})
	_assert_eq(validation_state.state_id, HexMapValidationWorkflowState.STATE_WARNING, "STATE-50 validation state covers warning")

	var export_state := HexMapExportWorkflowState.new()
	export_state.update_from_context({"exporting": true})
	_assert_eq(export_state.state_id, HexMapExportWorkflowState.STATE_EXPORTING, "STATE-50 export state covers exporting")
	export_state.update_from_context({
		"destination": {"selected": true, "path": "res://tmp/export.tres"},
		"can_export": true,
	})
	_assert_eq(export_state.state_id, HexMapExportWorkflowState.STATE_READY, "STATE-50 export state covers ready")
	export_state.update_from_context({
		"destination": {"selected": true, "path": "res://tmp/export.tres"},
		"last_result": {"ok": false, "path": "res://tmp/export.tres"},
		"block_reason": "Export failed.",
	})
	_assert_eq(export_state.state_id, HexMapExportWorkflowState.STATE_FAILED, "STATE-50 export state covers failed")

	var sample_state := HexMapSampleLearningState.new()
	sample_state.update_from_context({"sample_source_selected_slots": PackedStringArray([HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG])})
	_assert_eq(sample_state.state_id, HexMapSampleLearningState.STATE_SAMPLE_SOURCE_SELECTED, "STATE-50 sample state covers explicit sample source")

	var dialog_state := HexMapDialogLifecycleState.new()
	dialog_state.update_from_context({"opening": true})
	_assert_eq(dialog_state.state_id, HexMapDialogLifecycleState.STATE_OPENING, "STATE-50 dialog state covers opening")
	dialog_state.update_from_context({"inside_tree": true})
	_assert_eq(dialog_state.state_id, HexMapDialogLifecycleState.STATE_WAITING_USER, "STATE-50 dialog state covers waiting user")
	dialog_state.update_from_context({"committed": true, "result": {"path": "res://tmp/result.tres"}})
	_assert_eq(dialog_state.state_id, HexMapDialogLifecycleState.STATE_COMMITTED, "STATE-50 dialog state covers committed")
	dialog_state.update_from_context({"cancelled": true})
	_assert_eq(dialog_state.state_id, HexMapDialogLifecycleState.STATE_CANCELLED, "STATE-50 dialog state covers cancelled")


func _test_workspace_root_state_and_dispatcher_integrate_viewstates() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var root_state = workspace.workspace_root_state_snapshot()
	_assert_eq(String(root_state["state_source"]), "HexMapWorkspaceRootState", "STATE-60 root snapshot reports state source")
	_assert_eq(String(root_state["current_tab"]), "Build", "STATE-60 root state starts on Build")
	var screen_view_states = root_state["screen_view_states"] as Dictionary
	_assert_eq(String((screen_view_states["Build"] as Dictionary)["state_source"]), "HexMapBuildScreen", "STATE-60 Build root ViewState comes from graph screen")
	_assert_eq(String((screen_view_states["Paint"] as Dictionary)["state_source"]), "HexMapPaintInteractionState", "STATE-60 Paint root ViewState comes from paint state")
	_assert_eq(String((screen_view_states["Validate"] as Dictionary)["state_source"]), "HexMapValidationWorkflowState", "STATE-60 Validate root ViewState comes from validation state")
	_assert_eq(String((screen_view_states["Export"] as Dictionary)["state_source"]), "HexMapExportWorkflowState", "STATE-60 Export root ViewState comes from export state")
	_assert_eq(String((screen_view_states["Settings"] as Dictionary)["state_source"]), "HexMapSampleLearningState", "STATE-60 Settings root ViewState comes from sample state")
	_assert_true((screen_view_states["Resources"] as Dictionary).has("status_text"), "STATE-60 synthesized Resources ViewState exposes status text")
	var root_view_state = workspace.workspace_root_view_state()
	_assert_eq(String(root_view_state["state_source"]), "HexMapWorkspaceRootState", "STATE-60 root ViewState reports state source")
	_assert_eq(
		String(root_view_state["current_screen_state_id"]),
		String((screen_view_states["Build"] as Dictionary)["state_id"]),
		"STATE-60 root ViewState mirrors current screen state"
	)
	var debug_report := workspace.workspace_state_debug_report_text()
	_assert_true(debug_report.contains("Hex Map Workspace State Debug Report"), "STATE-60 debug report has title")
	_assert_true(debug_report.contains("screen_state_ids:"), "STATE-60 debug report lists screen state ids")
	_assert_true(debug_report.contains("- Validate: not_run"), "STATE-60 debug report includes validation state")

	var select_result = workspace.dispatch_workspace_event(HexMapWorkspaceDispatcher.EVENT_SELECT_TAB, {"tab": "Validate"})
	_assert_true(bool(select_result["ok"]), "STATE-60 dispatcher selects tab")
	_assert_true(select_result.has("reducer_result"), "STATE-60 dispatch result exposes reducer_result")
	_assert_true(select_result.has("side_effects"), "STATE-60 dispatch result exposes side_effects")
	_assert_true(select_result.has("ui_state_update"), "STATE-60 dispatch result exposes ui_state_update")
	_assert_true(select_result.has("debug_report_proof"), "STATE-60 dispatch result exposes debug_report_proof")
	_assert_eq(workspace.current_workspace_tab_name(), "Validate", "STATE-60 dispatcher changes selected tab")
	_assert_eq(String((select_result["root_state"] as Dictionary)["current_tab"]), "Validate", "STATE-60 dispatch envelope returns root state")
	_assert_eq(String((select_result["view_state"] as Dictionary)["current_tab"]), "Validate", "STATE-60 dispatch envelope returns root ViewState")
	var select_side_effect = select_result["side_effects"] as Dictionary
	var tab_effect = select_side_effect.get("tab_change", {}) as Dictionary
	_assert_eq(String(tab_effect.get("requested_tab", "")), "Validate", "STATE-60 dispatch side effects includes tab request")
	var select_ui_update = select_result["ui_state_update"] as Dictionary
	_assert_true(bool(select_ui_update.get("root_state", false)), "STATE-60 dispatch ui_state_update marks root_state")
	_assert_true(select_result["debug_report_proof"].to_upper() != "", "STATE-60 dispatch proof includes debug text")

	var validate_result = workspace.dispatch_workspace_event(HexMapWorkspaceDispatcher.EVENT_RUN_VALIDATION)
	_assert_true(bool(validate_result["ok"]), "STATE-60 dispatcher runs validation")
	root_state = validate_result["root_state"] as Dictionary
	screen_view_states = root_state["screen_view_states"] as Dictionary
	var validation_view = screen_view_states["Validate"] as Dictionary
	_assert_eq(String(validation_view["state_source"]), "HexMapValidationWorkflowState", "STATE-60 dispatched validation keeps ViewState source")
	_assert_eq(String(validation_view["state_id"]), HexMapValidationWorkflowState.STATE_ERROR, "STATE-60 dispatched validation updates root state")
	_assert_true(validate_result.has("reducer_result"), "STATE-60 dispatch validation has reducer_result")
	_assert_true(validate_result.has("side_effects"), "STATE-60 dispatch validation has side_effects")
	_assert_true(validate_result.has("ui_state_update"), "STATE-60 dispatch validation has ui_state_update")
	_assert_true(validate_result.has("debug_report_proof"), "STATE-60 dispatch validation proof has text")
	var validate_action = validate_result["reducer_result"] as Dictionary
	var issue_rows = validate_action["issue_rows"] as Array
	_assert_true(issue_rows.size() > 0, "STATE-60 dispatched validation returns issue rows")
	var validation_effect = (validate_result["side_effects"] as Dictionary).get("validation", {}) as Dictionary
	_assert_true(bool(validation_effect.get("requested", false)), "STATE-60 dispatch validation reports requested effect")
	_assert_eq(int(validation_effect.get("issue_count", 0)), issue_rows.size(), "STATE-60 dispatch validation side effect reports issue count")
	_assert_true(bool((validate_result["ui_state_update"] as Dictionary).get("validate_screen", false)), "STATE-60 dispatch validation updates Validate screen")
	_assert_true(String(validate_result["debug_report_proof"]).contains("Hex Map Workspace State Debug Report"), "STATE-60 dispatch validation reports debug text")

	var focus_result = workspace.dispatch_workspace_event(HexMapWorkspaceDispatcher.EVENT_SELECT_VALIDATION_ISSUE, {"index": 0})
	_assert_true(bool(focus_result["ok"]), "STATE-60 dispatcher selects validation issue")
	_assert_eq(workspace.current_workspace_tab_name(), "Resources", "STATE-60 validation issue focus routes owning screen")
	root_state = focus_result["root_state"] as Dictionary
	screen_view_states = root_state["screen_view_states"] as Dictionary
	validation_view = screen_view_states["Validate"] as Dictionary
	_assert_eq(String(validation_view["state_id"]), HexMapValidationWorkflowState.STATE_FOCUS_APPLIED, "STATE-60 root state records validation focus")
	_assert_true(focus_result.has("reducer_result"), "STATE-60 focus dispatch has reducer_result")
	_assert_true(focus_result.has("side_effects"), "STATE-60 focus dispatch has side_effects")
	var focus_effect = (focus_result["side_effects"] as Dictionary).get("validation_issue_focus", {}) as Dictionary
	_assert_true(bool(focus_effect.get("focused", false)), "STATE-60 focus dispatch records focused side effect")
	_assert_true(String((focus_result["ui_state_update"] as Dictionary).get("selected_tab", "")) != "", "STATE-60 focus dispatch updates selected_tab")

	var output_dir = _test_resource_dir("state60_workspace_dispatcher")
	var export_path = "%s/root_dispatch_handoff.tres" % output_dir
	var destination_result = workspace.dispatch_workspace_event(
		HexMapWorkspaceDispatcher.EVENT_SELECT_EXPORT_DESTINATION,
		{"path": export_path}
	)
	_assert_true(bool(destination_result["ok"]), "STATE-60 dispatcher selects export destination")
	_assert_true(destination_result.has("side_effects"), "STATE-60 export destination has side_effects")
	_assert_eq(String((destination_result["reducer_result"] as Dictionary).get("path", "")), String(export_path), "STATE-60 export destination reducer keeps selected path")
	var export_effect = (destination_result["side_effects"] as Dictionary).get("export_destination", {}) as Dictionary
	_assert_true(bool(export_effect.get("destination_selected", false)), "STATE-60 export destination side effect indicates selected")
	root_state = destination_result["root_state"] as Dictionary
	screen_view_states = root_state["screen_view_states"] as Dictionary
	_assert_eq(String((screen_view_states["Export"] as Dictionary)["state_source"]), "HexMapExportWorkflowState", "STATE-60 export dispatch updates root ViewState")
	var clear_result = workspace.dispatch_workspace_event(HexMapWorkspaceDispatcher.EVENT_CLEAR_EXPORT_DESTINATION)
	_assert_true(bool(clear_result["ok"]), "STATE-60 dispatcher clears export destination")
	_assert_true(clear_result.has("reducer_result"), "STATE-60 clear export destination has reducer_result")
	_assert_true(clear_result.has("side_effects"), "STATE-60 clear export destination has side_effects")
	_assert_true(bool((clear_result["ui_state_update"] as Dictionary).get("export_screen", false)), "STATE-60 clear export destination updates Export screen")

	var sample_result = workspace.dispatch_workspace_event(HexMapWorkspaceDispatcher.EVENT_OPEN_SAMPLE_LEARNING)
	_assert_true(bool(sample_result["ok"]), "STATE-60 dispatcher opens sample learning destination")
	_assert_true(sample_result.has("reducer_result"), "STATE-60 sample open has reducer_result")
	_assert_true(sample_result.has("side_effects"), "STATE-60 sample open has side_effects")
	_assert_eq(workspace.current_workspace_tab_name(), "Settings", "STATE-60 sample learning dispatch routes Settings")
	_assert_true(String((sample_result["ui_state_update"] as Dictionary).get("selected_tab", "")) == "Settings", "STATE-60 sample open updates selected_tab")
	var unknown_result = workspace.dispatch_workspace_event("unknown_workspace_event")
	_assert_true(not bool(unknown_result["ok"]), "STATE-60 dispatcher rejects unknown event")
	_assert_eq(int(unknown_result["error"]), ERR_INVALID_PARAMETER, "STATE-60 unknown event reports invalid parameter")
	_assert_true(unknown_result.has("reducer_result"), "STATE-60 unknown event has reducer_result")
	_assert_true(unknown_result.has("side_effects"), "STATE-60 unknown event has side_effects")
	_assert_true(unknown_result.has("ui_state_update"), "STATE-60 unknown event has ui_state_update")
	_assert_true(String(unknown_result["debug_report_proof"]) != "", "STATE-60 unknown event has debug report proof")

	workspace.queue_free()
	await process_frame


func _test_workspace_dispatcher_result_contract() -> void:
	var null_workspace_result = HexMapWorkspaceDispatcher.dispatch(null, HexMapWorkspaceDispatcher.EVENT_SELECT_TAB, {"tab": "Resources"})
	_assert_true(null_workspace_result.has("reducer_result"), "STATE-60 dispatch typed contract includes reducer_result on null workspace")
	_assert_true(null_workspace_result.has("side_effects"), "STATE-60 dispatch typed contract includes side_effects on null workspace")
	_assert_true(null_workspace_result.has("ui_state_update"), "STATE-60 dispatch typed contract includes ui_state_update on null workspace")
	_assert_true(null_workspace_result.has("debug_report_proof"), "STATE-60 dispatch typed contract includes debug proof on null workspace")
	_assert_eq(int(null_workspace_result["error"]), ERR_UNAVAILABLE, "STATE-60 dispatch null workspace reports unavailable")
	var unknown_dispatch = HexMapWorkspaceDispatcher.dispatch(null, "unknown_workspace_event")
	_assert_true(not bool(unknown_dispatch["ok"]), "STATE-60 dispatch null workspace unknown event fails")
	_assert_eq(int(unknown_dispatch["error"]), ERR_INVALID_PARAMETER, "STATE-60 dispatch null workspace unknown event reports invalid parameter")
	_assert_eq(String(unknown_dispatch["event_id"]), "unknown_workspace_event", "STATE-60 dispatch null workspace unknown event keeps event id")


func _test_workspace_asset_slots_use_strict_resource_type_filters() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var typed_expectations: Array[Dictionary] = [
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "type": "HexMapDocumentResource"},
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "type": "HexTileCatalogResource"},
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE, "type": "HexObjectDatabaseResource"},
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE, "type": "HexLabelDatabaseResource"},
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_LAYER_STACK, "type": "HexLayerStackResource"},
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE, "type": "HexMovementProfileResource"},
		{"tab": "Catalog", "slot": HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "type": "HexTileCatalogResource"},
		{"tab": "Layers", "slot": HexMapWorkspaceAssetContext.SLOT_LAYER_STACK, "type": "HexLayerStackResource"},
		{"tab": "Validate", "slot": HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "type": "HexMapDocumentResource"},
		{"tab": "Validate", "slot": HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE, "type": "HexValidationRuleSuiteResource"},
		{"tab": "QA", "slot": HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "type": "HexMapDocumentResource"},
		{"tab": "QA", "slot": HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE, "type": "HexGenerationProfileResource"},
		{"tab": "QA", "slot": HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE, "type": "HexValidationRuleSuiteResource"},
		{"tab": "Export", "slot": HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT, "type": "HexMapDocumentResource"},
		{"tab": "Export", "slot": HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE, "type": "HexExportProfileResource"},
	]
	for expectation in typed_expectations:
		var tab_name := String(expectation["tab"])
		var slot_id := String(expectation["slot"])
		var expected_type := String(expectation["type"])
		var snapshot = workspace.tab_asset_slot_snapshot(tab_name, slot_id)
		var layout = workspace.tab_asset_slot_layout_snapshot(tab_name, slot_id)
		_assert_eq(String(snapshot["required_type"]), expected_type, "ASSET-30 %s/%s uses strict required type" % [tab_name, slot_id])
		_assert_eq(String(snapshot["picker_base_type"]), expected_type, "ASSET-30 %s/%s picker base type is strict" % [tab_name, slot_id])
		_assert_true(not bool(snapshot["uses_generic_resource_filter"]), "ASSET-30 %s/%s does not use generic Resource" % [tab_name, slot_id])
		_assert_true(String(layout["status_tooltip"]).contains("Pick: %s" % expected_type), "ASSET-30 %s/%s tooltip says what to pick" % [tab_name, slot_id])
		if bool(layout.get("resource_picker_visible", false)):
			_assert_eq(String(layout["resource_picker_base_type"]), expected_type, "ASSET-30 %s/%s EditorResourcePicker base type is strict" % [tab_name, slot_id])

	workspace.queue_free()
	await process_frame


func _test_workspace_resource_purpose_tooltips_cover_resource_rows() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var expectations: Array[Dictionary] = [
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT},
		{"tab": "Catalog", "slot": HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG},
		{"tab": "Layers", "slot": HexMapWorkspaceAssetContext.SLOT_LAYER_STACK},
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE},
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE},
		{"tab": "Resources", "slot": HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE},
		{"tab": "QA", "slot": HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE},
		{"tab": "Validate", "slot": HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE},
		{"tab": "Export", "slot": HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE},
	]
	for expectation in expectations:
		var tab_name := String(expectation["tab"])
		var slot_id := String(expectation["slot"])
		var layout = workspace.tab_asset_slot_layout_snapshot(tab_name, slot_id)
		var tooltip := String(layout["status_tooltip"])
		var purpose := HexMapWorkspaceAssetResourceFactory.resource_purpose(slot_id)
		var expected_type := HexMapWorkspaceAssetResourceFactory.resource_type_name(slot_id)
		_assert_true(tooltip.contains("Pick: %s" % expected_type), "INFO-70 %s/%s tooltip explains pick type" % [tab_name, slot_id])
		_assert_true(tooltip.contains("Type: %s" % expected_type), "INFO-70 %s/%s tooltip includes type" % [tab_name, slot_id])
		_assert_true(tooltip.contains("Purpose: %s" % purpose), "INFO-70 %s/%s tooltip includes purpose" % [tab_name, slot_id])
		_assert_true(not String(layout["status_text"]).contains(purpose), "INFO-70 %s/%s keeps long purpose out of visible row text" % [tab_name, slot_id])
		var filter_reason := HexMapWorkspaceAssetResourceFactory.type_filter_reason(slot_id)
		if filter_reason != "":
			_assert_true(tooltip.contains("Filter: %s" % filter_reason), "INFO-70 %s/%s tooltip includes flexible filter reason" % [tab_name, slot_id])

	var catalog_snapshot = workspace.catalog_screen_snapshot()
	var tile_set_tooltip := String(catalog_snapshot["tile_set_tooltip"])
	_assert_true(tile_set_tooltip.contains("Pick: TileSet"), "INFO-70 Catalog TileSet tooltip explains pick type")
	_assert_true(tile_set_tooltip.contains("Type: TileSet"), "INFO-70 Catalog TileSet tooltip includes type")
	_assert_true(
		tile_set_tooltip.contains("Purpose: %s" % HexMapWorkspaceAssetResourceFactory.tile_set_purpose()),
		"INFO-70 Catalog TileSet tooltip includes purpose"
	)

	workspace.queue_free()
	await process_frame


func _test_workspace_tab_purpose_empty_states_route_to_project_actions() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var snapshots := {
		"Resources": workspace.resources_screen_snapshot(),
		"Paint": workspace.paint_brush_screen_snapshot(),
		"Catalog": workspace.catalog_screen_snapshot(),
		"Layers": workspace.layer_stack_screen_snapshot(),
		"Validate": workspace.validate_screen_snapshot(),
		"QA": workspace.qa_screen_snapshot(),
		"Export": workspace.export_screen_snapshot(),
		"Settings": workspace.settings_screen_snapshot(),
	}
	var production_tabs := PackedStringArray([
		"Resources",
		"Paint",
		"Catalog",
		"Layers",
		"Validate",
		"QA",
		"Export",
	])
	for tab_name in snapshots.keys():
		var snapshot = snapshots[tab_name] as Dictionary
		var empty_state = snapshot["empty_state"] as Dictionary
		var purpose := String(snapshot["purpose_text"])
		var empty_text := String(empty_state["empty_state_text"])
		var actions = empty_state["next_actions"] as PackedStringArray
		var help_tooltip := String(empty_state["help_tooltip"])
		_assert_true(purpose != "", "INFO-71 %s states tab purpose" % tab_name)
		_assert_eq(String(empty_state["purpose_text"]), purpose, "INFO-71 %s empty state mirrors purpose" % tab_name)
		_assert_eq(String(snapshot["empty_state_text"]), empty_text, "INFO-71 %s snapshot exposes empty text" % tab_name)
		_assert_true(empty_text != "", "INFO-71 %s has first-run empty-state text" % tab_name)
		_assert_true(actions.size() >= 1 and actions.size() <= 2, "INFO-71 %s has one or two next actions" % tab_name)
		_assert_eq(int(empty_state["next_action_count"]), actions.size(), "INFO-71 %s reports action count" % tab_name)
		_assert_true(help_tooltip != "", "INFO-71 %s keeps detailed help in tooltip" % tab_name)
		_assert_true(bool(empty_state["detail_help_in_tooltip"]), "INFO-71 %s detailed help stays out of primary text" % tab_name)
		_assert_true(not empty_text.contains(help_tooltip), "INFO-71 %s primary empty text does not inline tooltip detail" % tab_name)
		if production_tabs.has(String(tab_name)):
			var primary_text := ("%s %s" % [empty_text, " ".join(actions)]).to_lower()
			_assert_true(not primary_text.contains("sample"), "INFO-71 %s primary empty state does not use samples" % tab_name)
			_assert_true(not primary_text.contains("bundled"), "INFO-71 %s primary empty state does not use bundled assets" % tab_name)

	var resource_actions = (snapshots["Resources"] as Dictionary)["empty_state"]["next_actions"] as PackedStringArray
	_assert_true(resource_actions.has("Select a HexTileMap node"), "INFO-71 Resources next action points to node selection")
	var catalog_actions = (snapshots["Catalog"] as Dictionary)["empty_state"]["next_actions"] as PackedStringArray
	_assert_true(catalog_actions.has("Select or create a Tile Catalog"), "INFO-71 Catalog next action points to project catalog")
	var paint_actions = (snapshots["Paint"] as Dictionary)["empty_state"]["next_actions"] as PackedStringArray
	_assert_true(
		paint_actions.has("Select or create Level Document") or paint_actions.has("Select or create Tile Catalog"),
		"INFO-71 Paint next action points to project setup"
	)
	var export_actions = (snapshots["Export"] as Dictionary)["empty_state"]["next_actions"] as PackedStringArray
	_assert_true(export_actions.has("Select Level Document"), "INFO-71 Export next action includes document selection")
	_assert_true(export_actions.has("Choose Runtime Handoff destination"), "INFO-71 Export next action includes destination selection")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "INFO-71 empty states do not enable sample selector visibility")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "INFO-71 empty states do not inject generation sample catalog")
	_assert_eq(workspace.edit_tool().tile_catalog(), null, "INFO-71 empty states do not inject paint sample catalog")

	workspace.queue_free()
	await process_frame


func _test_workspace_asset_slot_actions_remove_redundant_buttons() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	for tab_name in workspace.workspace_tab_names():
		for slot_id in workspace.tab_asset_slot_ids(tab_name):
			var layout = workspace.tab_asset_slot_layout_snapshot(tab_name, String(slot_id))
			var action_texts = layout.get("action_button_texts", PackedStringArray()) as PackedStringArray
			_assert_true(not action_texts.has("Select..."), "ASSET-31 %s/%s removes Select action" % [tab_name, slot_id])
			_assert_true(not action_texts.has("Open"), "ASSET-31 %s/%s removes Open action" % [tab_name, slot_id])
			_assert_true(not action_texts.has("Clear"), "ASSET-31 %s/%s removes Clear action" % [tab_name, slot_id])
			_assert_true(not action_texts.has("Validate"), "ASSET-31 %s/%s removes Validate action" % [tab_name, slot_id])
			_assert_true(action_texts.has("Create New..."), "ASSET-31 %s/%s keeps Create New action" % [tab_name, slot_id])
			_assert_eq(String(layout.get("details_button_text", "")), "", "FB-02 %s/%s removes Details button text" % [tab_name, slot_id])
			_assert_true(not bool(layout.get("details_button_visible", false)), "FB-02 %s/%s hides Details button" % [tab_name, slot_id])

	workspace.queue_free()
	await process_frame


func _test_workspace_asset_remaining_actions_are_wired_or_deleted() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var output_dir = _test_resource_dir("asset32_remaining_actions")
	var catalog_path = "%s/action_catalog.tres" % output_dir
	var create_result = workspace.press_asset_slot_action(
		"Catalog",
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		HexMapEditorAssetSlotControl.ACTION_CREATE_NEW,
		{"path": catalog_path}
	)
	_assert_true(bool(create_result["ok"]), "ASSET-32 Create New button path succeeds")
	_assert_eq(int(create_result["error"]), OK, "ASSET-32 Create New button path reports OK")
	_assert_true(ResourceLoader.exists(catalog_path), "ASSET-32 Create New button path writes project resource")
	var created_catalog = workspace.workspace_asset_context().tile_catalog
	_assert_true(created_catalog is HexTileCatalogResource, "ASSET-32 Create New button path assigns Catalog context")
	_assert_eq(create_result["context_resource"], created_catalog, "ASSET-32 Create New button path returns context resource")
	var after_create = create_result["after"] as Dictionary
	_assert_eq(after_create["current_resource"], created_catalog, "ASSET-32 Create New button path refreshes row state")
	_assert_eq(String(after_create["current_source"]), HexMapEditorAssetSlotState.SOURCE_PROJECT, "ASSET-32 Create New button path records project source")
	_assert_eq(String(after_create["current_path"]), catalog_path, "ASSET-32 Create New button path records selected path")
	_assert_eq(String((after_create["operation"] as Dictionary)["action_id"]), HexMapEditorAssetSlotControl.ACTION_CREATE_NEW, "STATE-20 Create New action records operation result")
	_assert_true(bool((after_create["operation"] as Dictionary)["ok"]), "STATE-20 Create New operation result records success separately")

	var panel = workspace.sample_settings_panel()
	_assert_true(not _has_button_text(panel, "Open"), "ASSET-32 Settings sample Open action is removed until functional")
	_assert_eq(Array(panel.snapshot()["sample_assets"]).size(), 3, "ASSET-32 Settings sample rows remain visible as learning assets")

	var sample_catalog = HexTileCatalogResource.new()
	var sample_state = HexMapEditorAssetSlotState.new()
	sample_state.configure(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "Tile Catalog", &"HexTileCatalogResource", true)
	sample_state.set_sample_source(sample_catalog, "res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres", "Bundled Sample Catalog")
	var sample_control = HexMapEditorAssetSlotControl.new()
	root.add_child(sample_control)
	sample_control.set_slot_state(sample_state)
	var sample_recorder = AssetSampleActionRecorder.new()
	sample_control.sample_requested.connect(Callable(sample_recorder, "record"))
	await process_frame

	var sample_result = sample_control.press_action(HexMapEditorAssetSlotControl.ACTION_APPLY_SAMPLE)
	_assert_true(bool(sample_result["ok"]), "ASSET-32 sample action button path succeeds")
	_assert_eq(sample_recorder.slots.size(), 1, "ASSET-32 sample action button path emits sample signal")
	_assert_eq(sample_recorder.slots[0], HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG, "ASSET-32 sample action signal includes slot id")
	var after_sample = sample_result["after"] as Dictionary
	_assert_eq(after_sample["current_resource"], sample_catalog, "ASSET-32 sample action button path selects sample resource")
	_assert_eq(String(after_sample["current_source"]), HexMapEditorAssetSlotState.SOURCE_SAMPLE, "ASSET-32 sample action button path records sample source")
	_assert_eq(String((after_sample["operation"] as Dictionary)["action_id"]), HexMapEditorAssetSlotControl.ACTION_APPLY_SAMPLE, "STATE-20 sample action records operation result")

	sample_control.queue_free()
	workspace.queue_free()
	await process_frame
