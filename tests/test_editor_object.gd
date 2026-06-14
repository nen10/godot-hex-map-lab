extends "res://tests/test_editor_plugin_test_base.gd"

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	await _test_object_label_asset_screen_manages_project_definitions_without_samples()
	await _test_map_edit_tool_object_palette_uses_definitions_and_typed_properties()
	_finish("res://tests/test_editor_object.gd")

func _test_object_label_asset_screen_manages_project_definitions_without_samples() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var snapshot = workspace.object_label_screen_snapshot()
	_assert_eq(String(snapshot["tab"]), "Resources", "TAB-51 Object/Label resources are managed from Resources")
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("document_asset_panel"),
		"TAB-51 Object/Label resources use Resources asset component"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE),
		"TAB-51 Resources exposes object database slot"
	)
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE),
		"TAB-51 Resources exposes label database slot"
	)
	_assert_true(not workspace.tab_has_component("Paint", "object_label_asset_panel"), "TAB-51 Paint does not duplicate Object/Label resource rows")
	_assert_eq(workspace.workspace_asset_context().object_database, null, "Object/Label screen starts without sample object database")
	_assert_eq(workspace.workspace_asset_context().label_database, null, "Object/Label screen starts without sample label database")
	_assert_true(not bool(snapshot["sample_object_scene_assigned"]), "Object/Label screen does not assign sample object scene")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Object/Label screen starts with sample mode OFF")

	var output_dir = _test_resource_dir("screen23_object_label")
	var object_db_path = "%s/object_database.tres" % output_dir
	var object_create_result = workspace.create_object_database(object_db_path)
	_assert_true(bool(object_create_result["ok"]), "Object/Label screen creates project Object Database")
	_assert_true(FileAccess.file_exists(object_db_path), "Object/Label screen writes project Object Database")
	var object_database = object_create_result["resource"] as HexObjectDatabaseResource
	_assert_true(object_database is HexObjectDatabaseResource, "Object/Label screen create returns object database resource")
	_assert_eq(workspace.workspace_asset_context().object_database, object_database, "created object database enters workspace context")
	_assert_eq(workspace.edit_tool().object_database(), object_database, "created object database enters edit tool")
	_assert_eq(
		workspace.tab_asset_slot_snapshot("Resources", HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE).get("current_source", ""),
		HexMapEditorAssetSlotState.SOURCE_PROJECT,
		"TAB-51 Resources marks created object database as project asset"
	)

	var label_db_path = "%s/label_database.tres" % output_dir
	var label_create_result = workspace.create_label_database(label_db_path)
	_assert_true(bool(label_create_result["ok"]), "Object/Label screen creates project Label Database")
	_assert_true(FileAccess.file_exists(label_db_path), "Object/Label screen writes project Label Database")
	var label_database = label_create_result["resource"] as HexLabelDatabaseResource
	_assert_true(label_database is HexLabelDatabaseResource, "Object/Label screen create returns label database resource")
	_assert_eq(workspace.workspace_asset_context().label_database, label_database, "created label database enters workspace context")
	_assert_eq(workspace.edit_tool().label_database(), label_database, "created label database enters edit tool")

	var marker := Node2D.new()
	var scene := PackedScene.new()
	_assert_eq(scene.pack(marker), OK, "test PackedScene packs for object definition")
	marker.free()
	var object_definition_result = workspace.create_object_definition_from_packed_scene("object.door", scene, "Door")
	_assert_true(bool(object_definition_result["ok"]), "Object/Label screen creates Object Definition from PackedScene")
	var object_definition = object_definition_result["definition"] as HexObjectDefinitionResource
	_assert_true(object_definition is HexObjectDefinitionResource, "Object/Label screen returns object definition")
	_assert_eq(object_definition.scene, scene, "Object Definition stores selected PackedScene")
	_assert_true(object_database.definition_ids().has("object.door"), "Object Database lists created object definition")

	var object_select_result = workspace.select_object_definition("object.door")
	_assert_true(bool(object_select_result["ok"]), "Object/Label screen selects Object Definition for placement")
	_assert_eq(String(object_select_result["payload"].get("object_id", "")), "object.door", "Object placement payload uses selected definition id")
	snapshot = workspace.object_label_screen_snapshot()
	_assert_eq(snapshot["selected_object_definition_id"], "object.door", "Object/Label snapshot reports selected object definition")
	var door_row = _object_definition_row_for_id(snapshot["object_definition_rows"], "object.door")
	_assert_eq(door_row["scene"], "PackedScene", "Object Definition row reports PackedScene status")

	var label_definition_result = workspace.create_label_definition("label.zone", "Zone Label", "North Gate", "map")
	_assert_true(bool(label_definition_result["ok"]), "Object/Label screen creates Label Definition")
	var label_definition = label_definition_result["definition"] as HexLabelDefinitionResource
	_assert_true(label_definition is HexLabelDefinitionResource, "Object/Label screen returns label definition")
	_assert_eq(label_definition.default_text, "North Gate", "Label Definition stores default text")
	_assert_true(label_database.definition_ids().has("label.zone"), "Label Database lists created label definition")

	var label_select_result = workspace.select_label_definition("label.zone")
	_assert_true(bool(label_select_result["ok"]), "Object/Label screen selects Label Definition for placement")
	_assert_eq(String(label_select_result["payload"].get("label_id", "")), "label.zone", "Label placement payload uses selected definition id")
	_assert_eq(String(label_select_result["payload"].get("text", "")), "North Gate", "Label placement payload uses definition default text")
	snapshot = workspace.object_label_screen_snapshot()
	_assert_eq(snapshot["selected_label_definition_id"], "label.zone", "Object/Label snapshot reports selected label definition")
	_assert_true(PackedStringArray(snapshot["label_definition_ids"]).has("label.zone"), "Object/Label snapshot lists label definition")

	var object_open_result = workspace.open_object_database()
	_assert_true(bool(object_open_result["ok"]), "Object/Label screen opens selected Object Database")
	_assert_eq(object_open_result["resource"], object_database, "Object/Label open returns selected Object Database")
	var object_save_as_path = "%s/object_database_saved_as.tres" % output_dir
	var object_save_result = workspace.save_object_database_as(object_save_as_path)
	_assert_true(bool(object_save_result["ok"]), "Object/Label screen saves Object Database as project resource")
	_assert_true(FileAccess.file_exists(object_save_as_path), "Object/Label screen Save As writes object database")

	var label_open_result = workspace.open_label_database()
	_assert_true(bool(label_open_result["ok"]), "Object/Label screen opens selected Label Database")
	_assert_eq(label_open_result["resource"], label_database, "Object/Label open returns selected Label Database")
	var label_save_as_path = "%s/label_database_saved_as.tres" % output_dir
	var label_save_result = workspace.save_label_database_as(label_save_as_path)
	_assert_true(bool(label_save_result["ok"]), "Object/Label screen saves Label Database as project resource")
	_assert_true(FileAccess.file_exists(label_save_as_path), "Object/Label screen Save As writes label database")

	var object_clear_result = workspace.clear_object_database()
	_assert_true(bool(object_clear_result["ok"]), "Object/Label screen clears Object Database")
	_assert_eq(workspace.workspace_asset_context().object_database, null, "cleared object database leaves workspace context")
	var label_clear_result = workspace.clear_label_database()
	_assert_true(bool(label_clear_result["ok"]), "Object/Label screen clears Label Database")
	_assert_eq(workspace.workspace_asset_context().label_database, null, "cleared label database leaves workspace context")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Object/Label screen actions do not enable sample mode")

	workspace.queue_free()
	await process_frame


func _test_map_edit_tool_object_palette_uses_definitions_and_typed_properties() -> void:
	var tool = await _new_ready_edit_tool()
	var database = HexObjectDatabaseResource.new()
	var door = HexObjectDefinitionResource.new()
	door.id = "object.door"
	door.display_name = "Door"
	door.tags = PackedStringArray(["door", "interactive"])
	door.set_meta("variant_options", ["closed", "open"])
	door.set_meta("spawn_condition_options", ["always", "on_interact"])
	door.default_properties = {
		"health": 10,
		"label": "North",
		"locked": true,
		"speed": 1.5,
		"state": {
			"type": "enum",
			"options": ["closed", "open"],
			"value": "closed",
		},
	}
	database.add_definition(door)
	tool.set_object_database(database)
	tool.set_edit_mode(HexMapEditTool.EditMode.OBJECT)

	var rows = tool.object_definition_rows()
	var door_row = _object_definition_row_for_id(rows, "object.door")
	_assert_eq(door_row["display_name"], "Door", "object palette lists definition display name")
	_assert_eq(door_row["scene"], "missing scene", "object palette reports missing scene before resource selection")
	_assert_eq(tool._object_payload["object_id"], "object.door", "object database selection chooses first object key")
	_assert_true(_control_row_visible(tool._object_definition_tree), "object mode shows definition list")
	_assert_true(_control_row_visible(tool._object_property_editor), "object mode shows typed property editor")
	_assert_true(not _control_row_visible(tool._object_properties_edit), "object mode hides raw JSON properties")
	_assert_true(not _control_row_visible(tool._object_properties_table), "object mode hides raw property table")
	var authoring_snapshot = tool.authoring_field_source_snapshot()
	_assert_true(bool((authoring_snapshot["object_variant"] as Dictionary).get("selector_visible", false)), "object variant uses selector")
	_assert_true(not bool((authoring_snapshot["object_variant"] as Dictionary).get("raw_text_visible", true)), "object variant raw text is hidden")
	_assert_true(
		PackedStringArray((authoring_snapshot["object_variant"] as Dictionary).get("options", PackedStringArray())).has("open"),
		"object variant selector uses definition enum options"
	)
	_assert_true(bool((authoring_snapshot["spawn_condition"] as Dictionary).get("selector_visible", false)), "spawn condition uses selector")
	_assert_true(not bool((authoring_snapshot["spawn_condition"] as Dictionary).get("raw_text_visible", true)), "spawn condition raw text is hidden")
	_assert_true(
		PackedStringArray((authoring_snapshot["spawn_condition"] as Dictionary).get("options", PackedStringArray())).has("on_interact"),
		"spawn condition selector uses definition enum options"
	)

	var packed_scene = PackedScene.new()
	var scene_root = Node2D.new()
	_assert_eq(packed_scene.pack(scene_root), OK, "test PackedScene packs for object definition")
	tool._select_object_definition("object.door")
	tool._on_object_definition_scene_changed(packed_scene)
	_assert_eq(door.scene, packed_scene, "object definition scene picker stores PackedScene")
	door_row = _object_definition_row_for_id(tool.object_definition_rows(), "object.door")
	_assert_eq(door_row["scene"], "PackedScene", "object definition row shows PackedScene status")

	tool._select_object_key_option_by_key("object.door")
	tool._on_object_catalog_selected(tool._object_catalog_option.selected)
	_assert_eq(tool._object_payload["object_id"], "object.door", "object key selector stores definition id")
	var control_types = tool.object_property_control_types()
	_assert_eq(control_types["locked"], "bool", "bool property uses CheckBox")
	_assert_eq(control_types["health"], "number", "int property uses SpinBox")
	_assert_eq(control_types["speed"], "number", "float property uses SpinBox")
	_assert_eq(control_types["label"], "string", "string property uses LineEdit")
	_assert_eq(control_types["state"], "enum", "enum property uses OptionButton")

	tool._on_object_property_bool_toggled(false, "locked")
	tool._on_object_property_number_changed(12.0, "health", false)
	tool._on_object_property_number_changed(2.25, "speed", true)
	tool._on_object_property_text_changed("South", "label")
	var state_option = tool._object_property_controls["state"] as OptionButton
	state_option.select(1)
	tool._on_object_property_enum_selected(1, "state", state_option)
	tool._object_variant_option.select(2)
	tool._on_object_variant_option_selected(2)
	tool._object_spawn_condition_option.select(2)
	tool._on_object_spawn_condition_option_selected(2)
	var properties = tool._object_payload["properties"]
	_assert_eq(properties["locked"], false, "typed bool editor updates placement property")
	_assert_eq(properties["health"], 12, "typed int editor updates placement property")
	_assert_eq(properties["speed"], 2.25, "typed float editor updates placement property")
	_assert_eq(properties["label"], "South", "typed string editor updates placement property")
	_assert_eq(properties["state"], "open", "typed enum editor updates placement property")
	_assert_eq(tool._object_payload["variant"], "open", "object variant selector updates payload")
	_assert_eq(tool._object_payload["spawn_condition"], "on_interact", "spawn condition selector updates payload")

	var count_before = database.definitions.size()
	tool._on_add_object_definition_pressed()
	_assert_eq(database.definitions.size(), count_before + 1, "Add Object Definition appends definition")

	scene_root.free()
	tool.queue_free()
	await process_frame


