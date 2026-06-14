extends "res://tests/test_editor_plugin_test_base.gd"

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	await _test_catalog_asset_screen_manages_project_catalog_without_samples()
	_finish("res://tests/test_editor_catalog.gd")

func _test_catalog_asset_screen_manages_project_catalog_without_samples() -> void:
	var session = HexMapEditorSessionState.new()
	var workspace = HexMapWorkspace.new()
	workspace.set_editor_session_state(session)
	root.add_child(workspace)
	await process_frame

	var snapshot = workspace.catalog_screen_snapshot()
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("catalog_asset_panel"),
		"Catalog screen exposes catalog asset component"
	)
	_assert_true(
		PackedStringArray(snapshot["component_ids"]).has("catalog_detail_panel"),
		"TAB-52 Catalog screen exposes entry detail component"
	)
	_assert_true(bool(snapshot["detail_component_present"]), "TAB-52 Catalog screen reports detail component presence")
	_assert_true(
		PackedStringArray(snapshot["asset_slot_ids"]).has(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG),
		"Catalog screen exposes tile catalog slot"
	)
	_assert_true(not bool(snapshot["sample_candidates_visible"]), "Catalog screen hides sample catalog candidates while sample mode is OFF")
	_assert_eq(String(snapshot["catalog_entry_workflow_owner"]), "Catalog", "SCREEN-20 Catalog owns catalog entry workflow")
	_assert_eq(
		String(snapshot["catalog_editor_component_owner"]),
		"HexMapCatalogEditorComponent",
		"CAT-NEXT-10 Catalog screen reports dedicated editor component owner"
	)
	var catalog_owner_rows = snapshot["catalog_component_owner_rows"] as Array
	_assert_eq(
		catalog_owner_rows.size(),
		HexMapCatalogEditorComponent.component_owner_rows().size(),
		"CAT-NEXT-10 Catalog editor component owner row count"
	)
	var catalog_owner_ids := PackedStringArray()
	for row in catalog_owner_rows:
		var row_data := row as Dictionary
		catalog_owner_ids.append(String(row_data.get("component_id", "")))
		_assert_eq(
			String(row_data.get("screen_role_source", "")),
			"HexMapCatalogEditorComponent",
			"CAT-NEXT-10 Catalog editor owner row source"
		)
		_assert_eq(
			String(row_data.get("component_class", "")),
			"HexMapCatalogEditorComponent",
			"CAT-NEXT-10 Catalog editor owner row class"
		)
	_assert_true(catalog_owner_ids.has("catalog_entry_list"), "CAT-NEXT-10 Catalog component owns entry list")
	_assert_true(catalog_owner_ids.has("catalog_entry_detail"), "CAT-NEXT-10 Catalog component owns entry detail")
	_assert_true(catalog_owner_ids.has("catalog_entry_preview"), "CAT-NEXT-11 Catalog component owns entry preview")
	_assert_true(catalog_owner_ids.has("catalog_entry_create"), "CAT-NEXT-10 Catalog component owns entry create actions")
	_assert_true(catalog_owner_ids.has("catalog_entry_validate"), "CAT-NEXT-10 Catalog component owns entry validation")
	_assert_true(bool(snapshot["entry_list_visible"]), "SCREEN-20 Catalog exposes entry list state")
	_assert_true(bool(snapshot["entry_detail_visible"]), "SCREEN-20 Catalog exposes entry detail state")
	_assert_true(bool(snapshot["tags_status_visible"]), "SCREEN-20 Catalog exposes tags/status state")
	_assert_true(not bool(snapshot["paint_catalog_entry_management_visible"]), "SCREEN-20 Paint does not own catalog management")
	_assert_eq(workspace.workspace_asset_context().tile_catalog, null, "Catalog screen starts without sample catalog")
	_assert_eq(workspace.generation_dock().tile_catalog(), null, "Catalog screen does not inject generation sample catalog")
	var missing_detail = snapshot["entry_detail"] as Dictionary
	_assert_true(not bool(missing_detail["preview_available"]), "TAB-52 Catalog screen starts with unavailable preview")
	_assert_eq(
		String(missing_detail["preview_render_kind"]),
		HexTileCatalogPreviewControl.RENDER_UNAVAILABLE,
		"CAT-NEXT-11 missing Catalog detail uses unavailable preview render kind"
	)
	_assert_eq(
		String(missing_detail["preview_badge_text"]),
		"Preview unavailable",
		"CAT-NEXT-11 missing Catalog detail exposes preview badge"
	)
	_assert_eq(
		String(missing_detail["preview_unavailable_reason"]),
		"No Tile Catalog selected.",
		"TAB-52 Catalog screen explains missing catalog preview state"
	)

	var output_dir = _test_resource_dir("screen21_catalog")
	var catalog_path = "%s/tile_catalog.tres" % output_dir
	var create_result = workspace.create_tile_catalog(catalog_path)
	_assert_true(bool(create_result["ok"]), "Catalog screen creates project Tile Catalog")
	_assert_true(FileAccess.file_exists(catalog_path), "Catalog screen writes project Tile Catalog")
	var catalog = create_result["resource"] as HexTileCatalogResource
	_assert_true(catalog is HexTileCatalogResource, "Catalog screen create returns catalog resource")
	_assert_eq(workspace.workspace_asset_context().tile_catalog, catalog, "created catalog enters workspace context")
	_assert_eq(
		workspace.tab_asset_slot_snapshot("Catalog", HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG).get("current_source", ""),
		HexMapEditorAssetSlotState.SOURCE_PROJECT,
		"Catalog screen marks created catalog as project asset"
	)

	var tile_set := _test_catalog_tileset()
	var tile_set_result = workspace.set_catalog_tile_set(tile_set)
	_assert_true(bool(tile_set_result["ok"]), "Catalog screen assigns arbitrary TileSet")
	_assert_eq(catalog.tile_set, tile_set, "Catalog screen stores selected TileSet on catalog")

	var atlas_result = workspace.create_catalog_atlas_entry_from_tileset("terrain.floor", tile_set, 0, Vector2i.ZERO)
	_assert_true(bool(atlas_result["ok"]), "Catalog screen creates atlas entry from TileSet selection")
	var atlas_entry = atlas_result["entry"] as HexTileCatalogEntry
	_assert_true(atlas_entry is HexTileCatalogEntry, "Catalog screen returns atlas entry")
	_assert_eq(atlas_entry.entry_type, HexTileCatalogEntry.TYPE_ATLAS, "Catalog atlas entry uses atlas type")

	var marker := Node2D.new()
	var scene := PackedScene.new()
	_assert_eq(scene.pack(marker), OK, "test PackedScene packs")
	marker.free()
	var scene_result = workspace.create_catalog_scene_entry_from_packed_scene("object.spawn", scene)
	_assert_true(bool(scene_result["ok"]), "Catalog screen creates scene entry from PackedScene selection")
	var scene_entry = scene_result["entry"] as HexTileCatalogEntry
	_assert_true(scene_entry is HexTileCatalogEntry, "Catalog screen returns scene entry")
	_assert_eq(scene_entry.entry_type, HexTileCatalogEntry.TYPE_SCENE, "Catalog scene entry uses scene type")
	_assert_eq(scene_entry.scene, scene, "Catalog scene entry stores selected PackedScene")

	snapshot = workspace.catalog_screen_snapshot()
	_assert_eq(int(snapshot["entry_count"]), 2, "Catalog screen snapshot reports created entries")
	_assert_true(PackedStringArray(snapshot["entry_keys"]).has("terrain.floor"), "Catalog screen snapshot lists atlas key")
	_assert_true(PackedStringArray(snapshot["entry_keys"]).has("object.spawn"), "Catalog screen snapshot lists scene key")
	_assert_true(bool(snapshot["create_edit_entry_available"]), "SCREEN-20 Catalog exposes create/edit entry availability")
	_assert_true(bool(snapshot["create_atlas_entry_available"]), "SCREEN-20 Catalog exposes atlas entry creation")
	_assert_true(bool(snapshot["create_scene_entry_available"]), "SCREEN-20 Catalog exposes scene entry creation")
	_assert_true(bool(snapshot["validate_catalog_available"]), "SCREEN-20 Catalog exposes validation action")
	_assert_eq(
		String((snapshot["catalog_validation_status"] as Dictionary)["status_text"]),
		"Catalog OK",
		"SCREEN-20 Catalog validation status is visible"
	)
	_assert_true(not bool(snapshot["raw_coordinate_controls_primary"]), "TAB-52 Catalog source/atlas fields are metadata, not primary inputs")
	_assert_true(
		not PackedStringArray(snapshot["primary_input_fields"]).has("source_id"),
		"TAB-52 Catalog primary inputs do not expose raw source id"
	)
	_assert_true(
		PackedStringArray(snapshot["metadata_fields"]).has("atlas_coords"),
		"TAB-52 Catalog keeps atlas coordinates as metadata"
	)
	var entry_rows = snapshot["entry_rows"] as Array
	_assert_eq(entry_rows.size(), 2, "TAB-52 Catalog screen exposes entry rows")
	var atlas_detail = workspace.catalog_entry_detail("terrain.floor")
	_assert_eq(String(atlas_detail["meaning"]), "terrain.floor", "TAB-52 Catalog atlas detail exposes entry meaning")
	_assert_eq(String(atlas_detail["type_label"]), "Tile", "TAB-52 Catalog atlas detail has human type label")
	_assert_true(bool(atlas_detail["preview_available"]), "TAB-52 Catalog atlas detail has tile preview")
	_assert_eq(String(atlas_detail["preview_kind"]), "tile", "TAB-52 Catalog atlas detail reports tile preview kind")
	_assert_eq(
		String(atlas_detail["preview_render_kind"]),
		HexTileCatalogPreviewControl.RENDER_ATLAS_TEXTURE_REGION,
		"CAT-NEXT-11 Catalog atlas detail renders a TileSet atlas texture region"
	)
	_assert_true(String(atlas_detail["preview_text"]).contains("Tile source 0"), "TAB-52 Catalog atlas preview describes tile source")
	var atlas_preview = atlas_detail["preview"] as Dictionary
	_assert_true(atlas_preview.get("texture", null) is Texture2D, "CAT-NEXT-11 Catalog atlas preview carries texture")
	_assert_true(atlas_preview.get("texture_region", null) is Rect2, "CAT-NEXT-11 Catalog atlas preview carries texture region")
	_assert_true(not bool(atlas_preview.get("sample_source", true)), "CAT-NEXT-11 Catalog atlas preview does not use sample fallback")
	var atlas_metadata = atlas_detail["metadata"] as Dictionary
	_assert_eq(int(atlas_metadata["source_id"]), 0, "TAB-52 Catalog atlas source id is metadata")
	_assert_eq(atlas_metadata["atlas_coords"], Vector2i.ZERO, "TAB-52 Catalog atlas coords are metadata")
	_assert_true(not bool(atlas_detail["raw_coordinate_controls_primary"]), "TAB-52 Catalog atlas detail does not make raw coordinates primary")
	var scene_detail = workspace.catalog_entry_detail("object.spawn")
	_assert_eq(String(scene_detail["type_label"]), "Scene", "TAB-52 Catalog scene detail has human type label")
	_assert_true(bool(scene_detail["preview_available"]), "TAB-52 Catalog scene detail has scene preview")
	_assert_eq(String(scene_detail["preview_kind"]), "scene", "TAB-52 Catalog scene detail reports scene preview kind")
	_assert_eq(
		String(scene_detail["preview_render_kind"]),
		HexTileCatalogPreviewControl.RENDER_SCENE_RESOURCE,
		"CAT-NEXT-11 Catalog scene detail renders a scene resource preview"
	)
	var scene_preview = scene_detail["preview"] as Dictionary
	_assert_eq(String(scene_preview["scene_root_type"]), "Node2D", "CAT-NEXT-11 Catalog scene preview records scene root type")
	snapshot = workspace.catalog_screen_snapshot()
	_assert_true(bool(snapshot["tile_preview_visible"]), "SCREEN-20 Catalog exposes tile preview state")
	_assert_true(not bool(snapshot["scene_preview_visible"]), "SCREEN-20 default selected entry keeps scene preview inactive until selected")
	_assert_true(bool(snapshot["mounted_preview_present"]), "CAT-NEXT-11 Catalog detail mounts preview control")
	var mounted_preview = snapshot["mounted_preview_snapshot"] as Dictionary
	_assert_eq(
		String(mounted_preview["render_kind"]),
		HexTileCatalogPreviewControl.RENDER_ATLAS_TEXTURE_REGION,
		"CAT-NEXT-11 mounted Catalog preview renders default selected atlas entry"
	)
	var mounted_preview_control := _find_catalog_preview_control(workspace, "Catalog Entry Preview")
	_assert_true(mounted_preview_control is HexTileCatalogPreviewControl, "CAT-NEXT-11 Catalog mounted preview control is present")
	_assert_eq(
		String(mounted_preview_control.preview_snapshot()["render_kind"]),
		HexTileCatalogPreviewControl.RENDER_ATLAS_TEXTURE_REGION,
		"CAT-NEXT-11 mounted preview control stores atlas snapshot"
	)
	workspace.select_catalog_entry("object.spawn")
	snapshot = workspace.catalog_screen_snapshot()
	_assert_true(bool(snapshot["scene_preview_visible"]), "CAT-NEXT-11 selecting scene entry activates scene preview")
	_assert_eq(
		String((snapshot["mounted_preview_snapshot"] as Dictionary)["render_kind"]),
		HexTileCatalogPreviewControl.RENDER_SCENE_RESOURCE,
		"CAT-NEXT-11 mounted Catalog preview stores scene snapshot after selection"
	)
	var validation = workspace.validate_tile_catalog()
	_assert_true(validation is HexMapValidationResult, "Catalog screen validate returns validation result")
	_assert_eq(validation.issue_count(), 0, "Catalog screen validates project catalog with selected TileSet and PackedScene")

	var placeholder_entry := HexTileCatalogEntry.new()
	placeholder_entry.key = "placeholder.todo"
	placeholder_entry.display_name = "Unassigned Tile"
	placeholder_entry.entry_type = HexTileCatalogEntry.TYPE_PLACEHOLDER
	catalog.add_entry(placeholder_entry)
	var placeholder_detail = workspace.select_catalog_entry("placeholder.todo")
	_assert_eq(String(placeholder_detail["meaning"]), "Unassigned Tile", "TAB-52 Catalog placeholder detail exposes display name meaning")
	_assert_true(not bool(placeholder_detail["preview_available"]), "TAB-52 Catalog placeholder preview is unavailable")
	_assert_eq(
		String(placeholder_detail["preview_badge_text"]),
		"Preview unavailable",
		"CAT-NEXT-11 Catalog placeholder exposes unavailable preview badge"
	)
	_assert_eq(
		String(placeholder_detail["preview_unavailable_reason"]),
		"Placeholder entry has no preview.",
		"TAB-52 Catalog placeholder explains preview absence"
	)
	snapshot = workspace.catalog_screen_snapshot()
	_assert_eq(
		String(snapshot["mounted_preview_badge_tooltip"]),
		"Placeholder entry has no preview.",
		"CAT-NEXT-11 mounted Catalog badge tooltip explains placeholder preview absence"
	)

	var open_result = workspace.open_tile_catalog()
	_assert_true(bool(open_result["ok"]), "Catalog screen opens selected Tile Catalog")
	_assert_eq(open_result["resource"], catalog, "Catalog screen open returns selected catalog")

	var save_as_path = "%s/tile_catalog_saved_as.tres" % output_dir
	var save_result = workspace.save_tile_catalog_as(save_as_path)
	_assert_true(bool(save_result["ok"]), "Catalog screen saves Tile Catalog as project resource")
	_assert_true(FileAccess.file_exists(save_as_path), "Catalog screen Save As writes project catalog")
	_assert_eq(catalog.resource_path, save_as_path, "Catalog screen Save As updates catalog resource path")

	var clear_result = workspace.clear_tile_catalog()
	_assert_true(bool(clear_result["ok"]), "Catalog screen clears Tile Catalog")
	_assert_eq(workspace.workspace_asset_context().tile_catalog, null, "cleared catalog leaves workspace context")
	_assert_true(not session.show_bundled_samples_in_main_selectors, "Catalog screen actions do not enable sample mode")

	workspace.queue_free()
	await process_frame


