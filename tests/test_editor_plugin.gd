extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexRandomizer = preload("res://addons/hex_map_kit/core/hex_randomizer.gd")
const HexDistribution = preload("res://addons/hex_map_kit/adapter/hex_distribution.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexOverlayData = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexOverlayResource = preload("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapDocumentLabelPlacementResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_label_placement_resource.gd")
const HexMapDocumentObjectPlacementResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_object_placement_resource.gd")
const HexMapDocumentOverlayLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_overlay_layer_resource.gd")
const HexMapDocumentTerrainLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_terrain_layer_resource.gd")
const HexObjectDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_object_database_resource.gd")
const HexLabelDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_label_database_resource.gd")
const HexMapGenDock = preload("res://addons/hex_map_kit/editor/hex_map_gen_dock.gd")
const HexMapEditTool = preload("res://addons/hex_map_kit/editor/hex_map_edit_tool.gd")
const HexDistEditor = preload("res://addons/hex_map_kit/editor/hex_dist_editor.gd")
const HexAdjacencyRuleEditor = preload("res://addons/hex_map_kit/editor/hex_adjacency_rule_editor.gd")
const HexCellButtonLayout = preload("res://addons/hex_map_kit/editor/hex_cell_button_layout.gd")
const HexCellButtonPanel = preload("res://addons/hex_map_kit/editor/hex_cell_button_panel.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")

class FakeTileLayer:
	var cleared := false
	var calls: Array = []

	func clear() -> void:
		cleared = true

	func set_cell(map_cell: Vector2i, source_id: int, atlas_coords: Vector2i, alternative_tile: int = 0) -> void:
		calls.append({
			"map_cell": map_cell,
			"source_id": source_id,
			"atlas_coords": atlas_coords,
			"alternative_tile": alternative_tile,
		})


class CountingHexTileMapLayer:
	extends HexTileMapLayer

	var apply_document_cell_count := 0
	var redraw_count := 0

	func apply_document_cell(document, hex: HexVector) -> bool:
		apply_document_cell_count += 1
		return super.apply_document_cell(document, hex)

	func _redraw() -> void:
		redraw_count += 1
		super._redraw()


class CellPressRecorder:
	var entries: Array = []

	func record(entry: Dictionary) -> void:
		entries.append(entry)


var _failures: Array[String] = []
var _test_output_root := ""


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_plugin_registration_files()
	await _test_map_edit_tool_builds_dock_controls()
	await _test_plugin_handles_canvas_item_when_map_edit_ready()
	await _test_map_edit_tool_auto_target_uses_selected_layer()
	await _test_map_edit_tool_auto_target_maps_hex_internal_layer_selection()
	await _test_map_edit_tool_initializes_document_from_hex_target()
	await _test_map_edit_tool_imports_generated_map_resource()
	await _test_map_edit_tool_path_file_handlers_and_action_states()
	await _test_map_edit_tool_loads_saves_v2_document_without_losing_typed_payloads()
	await _test_map_edit_tool_click_updates_document_with_undo_redo()
	await _test_map_edit_tool_debug_report_copy_includes_reportable_state()
	await _test_map_edit_tool_forward_canvas_gui_input_uses_viewport_transform()
	await _test_map_edit_tool_target_selection_sync_for_explicit_target()
	await _test_map_edit_tool_forward_canvas_gui_input_reports_no_editable_cell()
	await _test_map_edit_tool_target_readiness_reports_plain_tile_map_layer()
	await _test_map_edit_tool_target_readiness_reports_hex_tile_map_layer_loop_state()
	await _test_map_edit_tool_preserves_plain_target_tile_settings_when_redrawing()
	await _test_map_edit_tool_applies_explicit_default_tile_settings()
	await _test_map_edit_tool_target_atlas_settings_use_target_tileset()
	await _test_map_edit_tool_target_status_reports_tileset_and_overlay_payload()
	await _test_map_edit_tool_last_edit_trace_distinguishes_document_and_redraw()
	await _test_map_edit_tool_last_edit_trace_reports_target_apply_failure()
	await _test_map_edit_tool_persistence_checkpoint_reports_save_and_export_counts()
	await _test_map_edit_tool_local_hit_uses_hex_tile_map_layer()
	await _test_map_edit_tool_hex_target_uses_command_apply_path()
	await _test_map_edit_tool_hex_tile_payload_modes_change_display()
	await _test_map_edit_tool_overlay_tile_payload_changes_hex_display()
	await _test_map_edit_tool_keeps_tile_payloads_per_mode()
	await _test_map_edit_tool_object_and_label_payloads_change_hex_display()
	await _test_map_edit_tool_forward_canvas_gui_input_edits_loop_visual_duplicate()
	await _test_map_edit_tool_undo_redo_preserves_loop_visual_identity()
	await _test_map_edit_tool_mode_specific_payload_controls()
	_test_hex_cell_button_layout_direction_cells_flat_top()
	_test_hex_cell_button_layout_direction_cells_pointy_top()
	_test_hex_cell_button_layout_minimum_size_uses_padding()
	_test_hex_cell_button_layout_polygon_hit_rejects_rect_corner()
	_test_hex_cell_button_layout_shape_cells_custom_ring_disc()
	await _test_hex_cell_button_panel_emits_pressed_for_hex_hit()
	await _test_hex_cell_button_panel_emits_hover_for_hex_hit()
	await _test_hex_cell_button_panel_accepts_label_display_state()
	await _test_hex_cell_button_panel_does_not_press_disabled_cell()
	await _test_hex_cell_button_panel_focus_navigation()
	await _test_distribution_editor_loads_default_preset_values()
	await _test_distribution_editor_loads_resource_values_and_colors_cells()
	await _test_distribution_editor_uses_hex_cell_layout_for_patterns()
	await _test_distribution_editor_pattern_redraw_uses_layout_entries()
	await _test_distribution_editor_close_button_uses_cancel_flow()
	await _test_distribution_editor_manages_recent_custom_and_duplicate_preset()
	await _test_adjacency_rule_editor_applies_rule_text()
	await _test_generation_dock_adjacency_rule_validation()
	await _test_generation_dock_symmetric_hexagon_minimum_radii()
	await _test_generation_dock_shape_universe_uses_canonical_hexagon_and_square_torus()
	await _test_generation_dock_torus_connectivity_controls()
	await _test_generation_dock_torus_connectivity_generation()
	await _test_generation_dock_tracks_generation_progress_state()
	await _test_generation_dock_only_generates_from_generate_button()
	await _test_generation_dock_wires_core_progress_and_cancel()
	await _test_generation_dock_applies_configured_tile_entries()
	await _test_generation_dock_applies_orientation_to_tile_entries()
	await _test_generation_dock_resource_stores_orientation()
	await _test_generation_dock_configures_tile_map_layer_tileset()
	await _test_generation_dock_applies_primary_map_to_hex_tile_map_layer()
	await _test_generation_dock_swaps_tile_size_on_orientation_change()
	await _test_generation_dock_lists_hex_tile_map_layer_common_target()
	await _test_generation_dock_lists_and_auto_applies_selected_tile_layer()
	await _test_generation_dock_disambiguates_duplicate_target_names()
	await _test_generation_dock_adds_new_target_layer()
	await _test_generation_dock_duplicates_shared_tileset_for_selected_layer()
	await _test_generation_dock_sets_up_sample_tiles()
	await _test_generation_dock_selects_atlas_image()
	await _test_generation_dock_generate_auto_applies_current_map()
	await _test_generation_dock_generate_auto_applies_hex_tile_map_layer()
	await _test_generation_dock_overlay_uniform_generation_and_apply()
	await _test_generation_dock_overlay_applies_to_hex_tile_map_layer()
	await _test_generation_dock_overlay_limit_and_apply_policy()
	await _test_generation_dock_overlay_placement_mask_filters_candidates()
	await _test_generation_dock_overlay_adjacency_reference_generation()
	await _test_generation_dock_adjacency_generated_reference_snapshot()
	await _test_generation_dock_adjacency_generated_reference_changes_result()
	await _test_generation_dock_overlay_item_pool_tile_mapping()
	await _test_generation_dock_mapdata_source_registry_load_reload_clear()
	await _test_generation_dock_path_action_labels_and_failure_status()
	await _test_generation_dock_mapdata_query_rows_evaluate_offset_and_toric()
	await _test_generation_dock_overlay_deductor_floor_source_query()
	await _test_generation_dock_mapdata_crop_result_and_reset_rules()
	await _test_generation_dock_mapdata_crop_off_stacks_overlay_sources()
	await _test_generation_dock_generate_history_saves_overlay_delta_source()

	if _failures.is_empty():
		print("test_editor_plugin.gd: all tests passed")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _test_plugin_registration_files() -> void:
	var config = ConfigFile.new()
	var error = config.load("res://addons/hex_map_kit/plugin.cfg")
	_assert_eq(error, OK, "plugin.cfg loads")
	_assert_eq(config.get_value("plugin", "name", ""), "Hex Map Kit", "plugin.cfg has addon name")
	var script_path = "res://addons/hex_map_kit/%s" % config.get_value("plugin", "script", "")
	_assert_true(load(script_path) != null, "plugin.cfg script can be loaded")


func _test_map_edit_tool_builds_dock_controls() -> void:
	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var tile_layer = TileMapLayer.new()
	tile_layer.name = "LegacyPlainLayer"
	scene_root.add_child(tile_layer)
	var hex_layer = HexTileMapLayer.new()
	hex_layer.name = "PaintLayer"
	scene_root.add_child(hex_layer)
	await process_frame

	var tool = await _new_ready_edit_tool()
	tool.refresh_target_layer_options(scene_root)

	_assert_eq(tool.name, "Hex Map Edit", "map edit tool has separate dock name")
	var scroll = tool.get_child(0) as ScrollContainer
	_assert_true(scroll != null, "map edit tool wraps dock controls in a ScrollContainer")
	_assert_eq(scroll.anchor_right, 1.0, "map edit tool ScrollContainer fills dock width")
	_assert_eq(scroll.anchor_bottom, 1.0, "map edit tool ScrollContainer fills dock height")
	_assert_true(scroll.get_child(0) is VBoxContainer, "map edit tool ScrollContainer owns the controls container")
	_assert_eq(
		(scroll.get_child(0) as VBoxContainer).size_flags_vertical,
		Control.SIZE_SHRINK_BEGIN,
		"map edit tool controls keep vertical minimum size inside ScrollContainer"
	)
	_assert_true(tool._document_path_edit != null, "map edit tool exposes document path control")
	_assert_true(tool._document_browse_button != null, "map edit tool exposes document browse button")
	_assert_true(tool._document_load_button != null, "map edit tool exposes document load button")
	_assert_true(tool._document_save_button != null, "map edit tool exposes document save button")
	_assert_true(tool._import_map_path_edit != null, "map edit tool exposes HexMapResource import path control")
	_assert_true(tool._import_map_browse_button != null, "map edit tool exposes HexMapResource import browse button")
	_assert_true(tool._import_map_button != null, "map edit tool exposes HexMapResource import button")
	_assert_true(tool._export_button != null, "map edit tool exposes map export button")
	_assert_true(tool._export_save_as_button != null, "map edit tool exposes map export save-as button")
	_assert_true(tool._copy_debug_report_button != null, "map edit tool exposes debug report copy button")
	_assert_eq(tool._mode_option.item_count, HexMapEditTool.EDIT_MODE_NAMES.size(), "map edit tool lists edit modes")
	_assert_true(tool._object_properties_edit != null, "map edit tool exposes object properties payload control")
	_assert_true(tool._default_floor_source_spin != null, "map edit tool exposes default floor source control")
	_assert_true(tool._default_wall_atlas_x_spin != null, "map edit tool exposes default wall atlas control")
	_assert_true(tool._default_tile_read_button != null, "map edit tool exposes default tile read button")
	_assert_true(tool._default_tile_apply_button != null, "map edit tool exposes default tile apply button")
	_assert_true(tool._target_atlas_path_edit != null, "map edit tool exposes target atlas image path control")
	_assert_true(tool._target_atlas_browse_button != null, "map edit tool exposes target atlas browse button")
	_assert_true(tool._target_sample_option.item_count >= 3, "map edit tool exposes sample atlas presets")
	_assert_true(tool._select_display_layer_button != null, "map edit tool exposes display layer selection")
	_assert_eq(tool._select_display_layer_button.text, "Select Internal TileMapLayer", "display layer button describes internal selection")
	_assert_true(tool._target_option.item_count >= 2, "map edit tool lists target TileMapLayer options")
	_assert_eq(tool.target_layer(), hex_layer, "map edit tool resolves Auto target to first HexTileMapLayer")
	var object_db = HexObjectDatabaseResource.new()
	var label_db = HexLabelDatabaseResource.new()
	tool.set_object_database(object_db)
	tool.set_label_database(label_db)
	_assert_eq(tool.object_database(), object_db, "map edit tool stores object database resource")
	_assert_eq(tool.label_database(), label_db, "map edit tool stores label database resource")

	scene_root.queue_free()
	tool.queue_free()
	await process_frame


func _test_plugin_handles_canvas_item_when_map_edit_ready() -> void:
	var plugin_source = FileAccess.get_file_as_string("res://addons/hex_map_kit/plugin.gd")
	var edit_tool_source = FileAccess.get_file_as_string("res://addons/hex_map_kit/editor/hex_map_edit_tool.gd")
	_assert_true(plugin_source.contains("func _handles(object: Object) -> bool:"), "plugin defines _handles for 2D viewport input")
	_assert_true(plugin_source.contains("_dock.name = \"Hex Map Generate\""), "plugin gives generation dock a stable tab name")
	_assert_true(plugin_source.contains("viewport_input_enabled"), "plugin gates viewport input through map edit tool")
	_assert_true(plugin_source.contains("object is CanvasItem"), "plugin handles CanvasItem viewport objects")
	_assert_true(
		edit_tool_source.contains("global_canvas_transform"),
		"map edit viewport conversion uses editor viewport global canvas transform"
	)
	_assert_true(
		not plugin_source.contains("get_editor_undo_redo"),
		"plugin does not wire EditorUndoRedoManager into the edit tool"
	)

	var tool = await _new_ready_edit_tool()
	var layer = TileMapLayer.new()
	root.add_child(layer)
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	tool.set_document(document)
	tool.set_target_layer(layer)

	_assert_true(tool.viewport_input_enabled(), "map edit tool enables viewport input when target and document are ready")
	tool.set_document(null)
	_assert_true(not tool.viewport_input_enabled(), "map edit tool disables viewport input without document")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_auto_target_uses_selected_layer() -> void:
	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var first_layer = TileMapLayer.new()
	first_layer.name = "FirstLayer"
	first_layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(first_layer.tile_set, true, Vector2i(64, 64))
	scene_root.add_child(first_layer)
	var selected_layer = HexTileMapLayer.new()
	selected_layer.name = "SelectedLayer"
	scene_root.add_child(selected_layer)
	await process_frame
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	selected_layer.apply_map(document.map)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.refresh_target_layer_options(scene_root)
	tool.set_editor_selected_target_layer_for_test(selected_layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	_assert_eq(tool.target_layer(), selected_layer, "Auto target resolves to the editor-selected layer")
	_assert_true(tool.viewport_input_enabled(), "Auto target enables viewport input for the selected layer")
	var origin_local = selected_layer._tile_map.position + selected_layer.hex_to_display_local(HexVector.zero())
	_assert_true(tool.apply_local_position(origin_local), "Auto target edit applies to the selected layer")
	_assert_eq(selected_layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i(1, 0), "Auto target redraws selected layer")
	_assert_eq(first_layer.get_used_cells().size(), 0, "Auto target does not redraw the first layer when selection exists")
	_assert_eq(tool.last_edit_status()["target_resolution_reason"], "auto editor selection", "Last Edit records Auto selection reason")

	scene_root.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_auto_target_maps_hex_internal_layer_selection() -> void:
	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var hex_layer = HexTileMapLayer.new()
	hex_layer.name = "HexLayer"
	scene_root.add_child(hex_layer)
	await process_frame
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.refresh_target_layer_options(scene_root)

	_assert_eq(tool._target_option.item_count, 2, "target list exposes wrapper HexTileMapLayer only")
	_assert_eq(tool._target_option.get_item_text(1), "HexLayer", "target list labels HexTileMapLayer wrapper")
	tool.set_editor_selected_target_layer_for_test(hex_layer._tile_map)
	_assert_eq(tool.target_layer(), hex_layer, "Auto target maps selected internal TileMapLayer to HexTileMapLayer")
	_assert_eq(tool.last_edit_status().get("target_resolution_reason", ""), "", "fixture has no edit trace yet")
	_assert_true(tool.viewport_input_enabled(), "Auto target remains input-enabled through HexTileMapLayer wrapper")
	_assert_eq(
		tool.target_readiness_status()["target_class"],
		"HexTileMapLayer",
		"internal TileMapLayer selection reports wrapper target readiness"
	)

	scene_root.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_initializes_document_from_hex_target() -> void:
	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var data = HexMapData.rectangle(2, 1)
	var resource = HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_POINTY_TOP)
	var hex_layer = HexTileMapLayer.new()
	hex_layer.name = "RuntimeMap"
	scene_root.add_child(hex_layer)
	await process_frame
	hex_layer.hex_map = resource
	var tool = await _new_ready_edit_tool()
	tool.refresh_target_layer_options(scene_root)
	tool.set_editor_selected_target_layer_for_test(hex_layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	_assert_true(tool.document() != null, "map edit tool creates a document from selected HexTileMapLayer target")
	_assert_eq(tool._document_source, HexMapEditTool.DOCUMENT_SOURCE_TARGET, "target document source is recorded")
	_assert_eq(tool.document().map.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "target document preserves target map orientation")
	_assert_true(tool.viewport_input_enabled(), "target-derived document enables viewport input")
	var origin_local = hex_layer._tile_map.position + hex_layer.hex_to_display_local(HexVector.zero())
	_assert_true(tool.apply_local_position(origin_local), "target-derived document accepts viewport edit")
	_assert_true(tool.document().map.to_map_data().has_wall(HexVector.zero()), "target-derived document mutates on edit")
	_assert_true(hex_layer.hex_map.to_map_data().has_wall(HexVector.zero()), "target-derived edit updates HexTileMapLayer resource")
	_assert_true(tool.debug_report_text().contains("document_source: target"), "debug report includes target document source")

	scene_root.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_imports_generated_map_resource() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var resource = HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_POINTY_TOP)
	var tool = await _new_ready_edit_tool()

	var document = tool.import_map_resource(resource)
	var exported = tool.export_map_resource()

	_assert_true(document != null, "map edit tool imports generated HexMapResource into a document")
	_assert_eq(exported.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "map edit tool export preserves orientation")
	_assert_keys_eq(exported.to_map_data().cells, data.cells, "map edit tool export preserves cells")
	_assert_keys_eq(exported.to_map_data().walls, data.walls, "map edit tool export preserves walls")

	var document_path = _test_resource_path("test_map_edit_tool_document.tres")
	var export_path = _test_resource_path("test_map_edit_tool_export.tres")
	var import_path = _test_resource_path("test_map_edit_tool_import_source.tres")
	_save_resource(import_path, resource)
	_assert_true(tool.save_document(document_path), "map edit tool saves document resource")
	_assert_true(tool.export_map_resource_to_path(export_path), "map edit tool saves exported HexMapResource")
	_assert_true(tool.import_map_resource_from_path(import_path), "map edit tool imports HexMapResource from path")
	_assert_true(load(document_path) != null, "map edit tool saved document can be loaded")
	_assert_true(load(export_path) is HexMapResource, "map edit tool exported map can be loaded")

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_path_file_handlers_and_action_states() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var map_resource = HexMapResource.from_map_data(data)
	var document = HexMapDocumentAdapter.from_map_resource(map_resource)
	var document_path = _test_resource_path("test_selector_document.tres")
	var import_path = _test_resource_path("test_selector_import_map.tres")
	var export_path = _test_resource_path("test_selector_export_map.tres")
	_save_resource(document_path, document)
	_save_resource(import_path, map_resource)

	var tool = await _new_ready_edit_tool()
	_assert_true(tool._document_load_button.disabled, "document Load is disabled while path is empty")
	_assert_true(tool._import_map_button.disabled, "Import is disabled while path is empty")
	_assert_true(tool._document_browse_button != null and not tool._document_browse_button.disabled, "Document Browse remains enabled")
	_assert_true(tool._export_button.disabled, "Export is disabled without document")

	tool._on_document_file_selected(document_path)
	_assert_true(tool.document() != null, "document file selected handler loads document")
	_assert_eq(tool.document_path(), document_path, "document file selected handler syncs path")
	_assert_eq(tool._document_source, HexMapEditTool.DOCUMENT_SOURCE_LOAD, "document file selected handler records load source")
	_assert_true(not tool._document_save_button.disabled, "Save As is enabled after document load")

	tool._on_import_map_file_selected(import_path)
	_assert_eq(tool.import_map_path(), import_path, "import file selected handler syncs path")
	_assert_eq(tool._document_source, HexMapEditTool.DOCUMENT_SOURCE_IMPORT, "import file selected handler records import source")
	_assert_true(not tool._export_button.disabled, "Export is enabled after import")

	tool._on_export_file_selected(export_path)
	_assert_eq(tool.export_path(), export_path, "export file selected handler syncs path")
	_assert_true(load(export_path) is HexMapResource, "export file selected handler saves HexMapResource")

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_debug_report_copy_includes_reportable_state() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var layer = TileMapLayer.new()
	layer.name = "ReportLayer"
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	root.add_child(layer)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var origin_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true))

	_assert_true(tool.apply_local_position(origin_local), "debug report fixture records an edit")
	var report = tool.debug_report_text()
	_assert_true(report.contains("Hex Map Edit Debug Report"), "debug report has a stable header")
	_assert_true(report.contains("target_status:"), "debug report includes target status")
	_assert_true(report.contains("last_edit_status:"), "debug report includes raw last edit status")
	_assert_true(report.contains("target_resolution_reason:"), "debug report includes target resolution reason")
	_assert_true(report.contains("ReportLayer"), "debug report includes target path/name context")
	_assert_true(tool.copy_debug_report_to_clipboard(), "copy debug report produces clipboard text")
	_assert_eq(tool._last_copied_debug_report, report, "copy debug report stores the exact generated report")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_loads_saves_v2_document_without_losing_typed_payloads() -> void:
	var document = _sample_v2_editor_document()
	var document_path = _test_resource_path("test_map_edit_v2_document.tres")
	var saved_path = _test_resource_path("test_map_edit_v2_saved_document.tres")
	var export_path = _test_resource_path("test_map_edit_v2_export.tres")
	_save_resource(document_path, document)

	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	_assert_true(
		layer.ensure_display_tiles(
			HexMapTileAdapter.SAMPLE_TILE_SIZE,
			4,
			Vector2i(0, 0),
			5,
			Vector2i(1, 0)
		),
		"v2 document target display tiles are configured"
	)

	var tool = await _new_ready_edit_tool()
	tool.set_target_layer(layer)
	_assert_true(tool.load_document(document_path), "map edit tool loads v2 document from path")
	_assert_eq(tool.document().version, HexMapDocumentResource.VERSION_V2, "loaded document remains v2")
	_assert_eq(layer.hex_map.to_map_data().walls.size(), 1, "v2 document load applies terrain map to HexTileMapLayer")
	var initial_state = layer.display_state_for_hex(HexVector.zero())
	_assert_eq(initial_state["overlay_count"], 1, "v2 document load applies overlay assignment")
	_assert_eq(initial_state["object_count"], 1, "v2 document load applies object placement")
	_assert_eq(initial_state["label_count"], 1, "v2 document load applies label placement")

	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	tool.set_tile_payload(0, Vector2i(2, 0), 0)
	_assert_true(tool.apply_cell(HexVector.zero()), "map edit tool edits loaded v2 document")
	_assert_eq(
		tool.document().terrain_layers[0].tile_assignments[0]["atlas_coords"],
		Vector2i(2, 0),
		"v2 document edit updates typed terrain assignment"
	)

	_assert_true(tool.save_document(saved_path), "map edit tool saves loaded v2 document")
	_assert_true(tool.export_map_resource_to_path(export_path), "map edit tool exports map from loaded v2 document")
	var saved = ResourceLoader.load(saved_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	_assert_true(saved is HexMapDocumentResource, "saved v2 document loads as document resource")
	_assert_eq(saved.version, HexMapDocumentResource.VERSION_V2, "saved document keeps v2 version")
	_assert_eq(saved.terrain_layers.size(), 1, "saved document keeps typed terrain layer")
	_assert_eq(saved.overlay_layers.size(), 1, "saved document keeps typed overlay layer")
	_assert_eq(saved.object_placements.size(), 1, "saved document keeps typed object placement")
	_assert_eq(saved.label_placements.size(), 1, "saved document keeps typed label placement")
	_assert_eq(
		saved.terrain_layers[0].tile_assignments[0]["atlas_coords"],
		Vector2i(2, 0),
		"saved document keeps edited typed terrain assignment"
	)
	var exported = ResourceLoader.load(export_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	_assert_true(exported is HexMapResource, "v2 document export loads as HexMapResource")
	_assert_eq(exported.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "v2 document export preserves orientation")
	_assert_eq(exported.to_map_data().walls.size(), 1, "v2 document export preserves walls")
	var save_status = tool.persistence_status()
	_assert_eq(save_status["cell_count"], 2, "v2 document save status reports cells")
	_assert_eq(save_status["wall_count"], 1, "v2 document save status reports walls")

	tool.queue_free()
	layer.queue_free()
	await process_frame


func _test_map_edit_tool_click_updates_document_with_undo_redo() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	var undo_redo = UndoRedo.new()
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_undo_redo(undo_redo)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	var origin_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true))
	_assert_true(tool.apply_local_position(origin_local), "map edit tool applies local click to document")
	_assert_true(document.map.to_map_data().has_wall(HexVector.zero()), "map edit tool click toggles wall in document")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "map edit tool click redraws wall tile")

	undo_redo.undo()
	_assert_true(not document.map.to_map_data().has_wall(HexVector.zero()), "map edit tool undo restores document")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i.ZERO, "map edit tool undo redraws floor tile")

	undo_redo.redo()
	_assert_true(document.map.to_map_data().has_wall(HexVector.zero()), "map edit tool redo restores document edit")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "map edit tool redo redraws wall tile")

	tool.set_edit_mode(HexMapEditTool.EditMode.SHAPE)
	var added = HexVector.q_axis().scaled(2)
	var added_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(added, true))
	_assert_true(tool.apply_local_position(added_local), "map edit tool shape mode can add a missing cell from local click")
	_assert_true(document.map.to_map_data().has_cell(added), "map edit tool shape mode adds cell")

	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	tool.set_tile_payload(9, Vector2i(2, 3), 1)
	_assert_true(tool.apply_cell(HexVector.zero()), "map edit tool applies floor tile override")
	_assert_eq(document.tile_overrides[0]["source_id"], 9, "map edit tool stores tile override source")
	_assert_eq(document.tile_overrides[0]["atlas_coords"], Vector2i(2, 3), "map edit tool stores tile override atlas")

	tool.set_edit_mode(HexMapEditTool.EditMode.OBJECT)
	tool.set_object_payload("door", {"locked": true})
	_assert_true(tool.apply_cell(HexVector.zero()), "map edit tool applies object payload")
	_assert_eq(document.objects[0]["object_id"], "door", "map edit tool stores object payload")
	_assert_eq(document.objects[0]["properties"]["locked"], true, "map edit tool stores object properties")

	tool.set_edit_mode(HexMapEditTool.EditMode.LABEL)
	tool.set_label_payload("room", "Entry")
	_assert_true(tool.apply_cell(HexVector.zero()), "map edit tool applies label payload")
	_assert_eq(document.labels[0]["label_id"], "room", "map edit tool stores label payload")
	_assert_eq(document.labels[0]["text"], "Entry", "map edit tool stores label text")

	undo_redo.clear_history()
	undo_redo.free()
	layer.free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_forward_canvas_gui_input_uses_viewport_transform() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var layer = TileMapLayer.new()
	layer.position = Vector2(30.0, 18.0)
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	root.add_child(layer)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var canvas_transform = Transform2D(0.0, Vector2(120.0, -40.0))
	tool.set_viewport_canvas_transform_for_test(canvas_transform)
	var origin_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true))
	var scene_position = layer.to_global(origin_local)
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = canvas_transform * scene_position

	_assert_true(tool.forward_canvas_gui_input(press), "map edit tool accepts viewport click through transform bridge")
	_assert_true(document.map.to_map_data().has_wall(HexVector.zero()), "viewport click toggles wall in document")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "viewport click redraws target layer")
	_assert_true(bool(tool.last_edit_status().get("applied", false)), "viewport click records target redraw status")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_target_selection_sync_for_explicit_target() -> void:
	var scene_root = Node2D.new()
	root.add_child(scene_root)
	var first_layer = HexTileMapLayer.new()
	first_layer.name = "FirstLayer"
	scene_root.add_child(first_layer)
	var second_layer = HexTileMapLayer.new()
	second_layer.name = "SecondLayer"
	scene_root.add_child(second_layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.refresh_target_layer_options(scene_root)
	var before_count = tool._target_selection_sync_request_count

	tool._target_option.select(2)
	tool._on_target_selected(2)

	_assert_eq(tool.target_layer(), second_layer, "explicit target selection chooses requested layer")
	_assert_true(
		tool._target_selection_sync_request_count > before_count,
		"explicit target selection requests editor selection sync"
	)
	_assert_eq(tool._last_selection_sync_target, second_layer, "target selection sync records selected layer")
	var before_refresh_count = tool._target_selection_sync_request_count
	tool.refresh_target_layer_options(scene_root)
	_assert_eq(tool.target_layer(), second_layer, "target refresh preserves explicit selected layer")
	_assert_true(
		tool._target_selection_sync_request_count > before_refresh_count,
		"target refresh requests editor selection sync for preserved target"
	)

	scene_root.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_forward_canvas_gui_input_reports_no_editable_cell() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	root.add_child(layer)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var outside_local = layer.map_to_local(Vector2i(20, 20))
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = layer.to_global(outside_local)

	_assert_true(tool.forward_canvas_gui_input(press), "viewport click outside document is consumed by edit tool")
	_assert_eq(tool._status_label.text, "No editable cell.", "viewport click reports no editable cell")
	var origin_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true))
	var valid_press = InputEventMouseButton.new()
	valid_press.button_index = MOUSE_BUTTON_LEFT
	valid_press.pressed = true
	valid_press.position = layer.to_global(origin_local)
	_assert_true(tool.forward_canvas_gui_input(valid_press), "valid viewport click still works after an invalid click")
	_assert_true(document.map.to_map_data().has_wall(HexVector.zero()), "valid click after invalid click edits document")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_target_readiness_reports_plain_tile_map_layer() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool._apply_document_to_target()

	var status = tool.target_readiness_status()
	_assert_eq(status["target_class"], "TileMapLayer", "plain target readiness reports TileMapLayer class")
	_assert_true(bool(status["tile_set_present"]), "plain target readiness reports TileSet presence")
	_assert_true(bool(status["ready"]), "plain target readiness is ready with a TileSet")
	_assert_eq(status["used_cell_count"], 2, "plain target readiness reports used cell count")
	_assert_eq(status["floor_atlas_coords"], Vector2i.ZERO, "plain target readiness reports default floor atlas")
	_assert_eq(status["wall_atlas_coords"], Vector2i(1, 0), "plain target readiness reports default wall atlas")
	_assert_true(tool._target_status_label.text.contains("TileMapLayer"), "plain target readiness appears in Dock detail")

	layer.free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_target_readiness_reports_hex_tile_map_layer_loop_state() -> void:
	var resource = HexMapResource.from_map_data(HexMapData.square(3, true))
	var document = HexMapDocumentAdapter.from_map_resource(resource)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.floor_source_id = 4
	layer.floor_atlas_coords = Vector2i(2, 0)
	layer.wall_source_id = 5
	layer.wall_atlas_coords = Vector2i(3, 0)
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	layer.apply_map(resource)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)

	var status = tool.target_readiness_status()
	_assert_eq(status["target_class"], "HexTileMapLayer", "hex target readiness reports HexTileMapLayer class")
	_assert_true(bool(status["is_hex_tile_map_layer"]), "hex target readiness marks HexTileMapLayer")
	_assert_true(bool(status["tile_set_present"]), "hex target readiness reports internal TileSet presence")
	_assert_eq(status["floor_source_id"], 4, "hex target readiness reports floor source id")
	_assert_eq(status["floor_atlas_coords"], Vector2i(2, 0), "hex target readiness reports floor atlas")
	_assert_eq(status["wall_source_id"], 5, "hex target readiness reports wall source id")
	_assert_eq(status["wall_atlas_coords"], Vector2i(3, 0), "hex target readiness reports wall atlas")
	_assert_eq(status["loop_display_mode"], HexTileMapLayer.LOOP_DISPLAY_TORIC, "hex target readiness reports loop mode")
	_assert_true(tool._target_status_label.text.contains("loop=toric"), "hex target readiness appears in Dock detail")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_preserves_plain_target_tile_settings_when_redrawing() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	var image = Image.create(256, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture = ImageTexture.create_from_image(image)
	HexMapTileAdapter.configure_atlas_tile_set(
		layer.tile_set,
		texture,
		true,
		Vector2i(64, 64),
		0,
		[Vector2i(2, 0), Vector2i(3, 0)]
	)
	HexMapTileAdapter.apply_to_tile_map_layer(
		layer,
		data,
		0,
		Vector2i(2, 0),
		0,
		Vector2i(3, 0),
		true,
		true
	)
	root.add_child(layer)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	var readiness = tool.target_readiness_status()
	_assert_eq(readiness["floor_atlas_coords"], Vector2i(2, 0), "map edit infers plain target floor atlas")
	_assert_eq(readiness["wall_atlas_coords"], Vector2i(3, 0), "map edit infers plain target wall atlas")
	var origin_map_cell = HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true)
	var origin_local = layer.map_to_local(origin_map_cell)

	_assert_true(tool.apply_local_position(origin_local), "map edit redraws using inferred target tile settings")
	_assert_eq(
		layer.get_cell_atlas_coords(origin_map_cell),
		Vector2i(3, 0),
		"map edit redraw changes clicked floor to target wall atlas"
	)
	var trace = tool.last_edit_status()
	_assert_eq(trace["display_atlas_before"], Vector2i(2, 0), "last edit trace records inferred floor atlas before edit")
	_assert_eq(trace["display_atlas_after"], Vector2i(3, 0), "last edit trace records inferred wall atlas after edit")
	_assert_true(bool(trace["display_changed"]), "last edit trace detects display change with inferred tile settings")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_applies_explicit_default_tile_settings() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	var plain_layer = TileMapLayer.new()
	plain_layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(plain_layer.tile_set, true, Vector2i(64, 64))
	var plain_tool = await _new_ready_edit_tool()
	plain_tool.set_document(document)
	plain_tool.set_target_layer(plain_layer)
	plain_tool._default_floor_atlas_x_spin.value = 1
	plain_tool._default_floor_atlas_y_spin.value = 0
	plain_tool._default_wall_atlas_x_spin.value = 0
	plain_tool._default_wall_atlas_y_spin.value = 0
	plain_tool._on_apply_default_tiles_pressed()

	_assert_eq(plain_layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "explicit default settings draw plain floor atlas")
	_assert_eq(plain_layer.get_cell_atlas_coords(Vector2i(1, 0)), Vector2i(0, 0), "explicit default settings draw plain wall atlas")
	_assert_eq(plain_tool.target_readiness_status()["floor_atlas_coords"], Vector2i(1, 0), "explicit plain floor atlas appears in readiness")

	var hex_layer = HexTileMapLayer.new()
	root.add_child(hex_layer)
	await process_frame
	var hex_tool = await _new_ready_edit_tool()
	hex_tool.set_document(document)
	hex_tool.set_target_layer(hex_layer)
	hex_tool._default_floor_atlas_x_spin.value = 1
	hex_tool._default_floor_atlas_y_spin.value = 0
	hex_tool._default_wall_atlas_x_spin.value = 0
	hex_tool._default_wall_atlas_y_spin.value = 0
	hex_tool._on_apply_default_tiles_pressed()

	_assert_eq(hex_layer.floor_atlas_coords, Vector2i(1, 0), "explicit default settings store HexTileMapLayer floor atlas")
	_assert_eq(hex_layer.wall_atlas_coords, Vector2i(0, 0), "explicit default settings store HexTileMapLayer wall atlas")
	_assert_eq(hex_layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i(1, 0), "explicit default settings draw Hex floor atlas")
	_assert_eq(hex_layer.display_atlas_coords_for_hex(HexVector.q_axis()), Vector2i(0, 0), "explicit default settings draw Hex wall atlas")

	plain_layer.free()
	plain_tool.queue_free()
	hex_layer.queue_free()
	hex_tool.queue_free()
	await process_frame


func _test_map_edit_tool_target_atlas_settings_use_target_tileset() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var hex_layer = HexTileMapLayer.new()
	root.add_child(hex_layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(hex_layer)
	tool._default_floor_source_spin.value = 0
	tool._default_floor_atlas_x_spin.value = 0
	tool._default_floor_atlas_y_spin.value = 0
	tool._default_wall_source_spin.value = 0
	tool._default_wall_atlas_x_spin.value = 1
	tool._default_wall_atlas_y_spin.value = 0
	tool._on_default_tile_setting_changed(0.0)

	_assert_true(
		tool._apply_target_atlas_path(
			"res://addons/hex_map_kit/assets/tactics_flat_top_hex_tiles_64x57_10.png",
			Vector2i(64, 57)
		),
		"map edit tool applies sample atlas to target TileSet"
	)
	var tile_set = hex_layer.display_tile_set()
	_assert_true(tile_set.has_source(0), "target atlas setup creates source on HexTileMapLayer TileSet")
	_assert_eq(tile_set.tile_size, Vector2i(64, 57), "target atlas setup stores tile size on Target TileSet")
	_assert_eq(document.tile_overrides.size(), 0, "target atlas setup does not write asset data into document tile overrides")
	tool._apply_document_to_target()
	_assert_eq(hex_layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i.ZERO, "target atlas setup draws floor atlas after apply")

	var replacement = TileSet.new()
	_assert_true(tool._apply_target_tile_set(replacement), "map edit tool accepts explicit Target TileSet resource")
	_assert_eq(hex_layer.display_tile_set(), replacement, "explicit Target TileSet is stored on HexTileMapLayer display layer")

	hex_layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_target_status_reports_tileset_and_overlay_payload() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var hex_layer = HexTileMapLayer.new()
	root.add_child(hex_layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(hex_layer)
	tool.set_overlay_tile_payload("Treasure", 4, Vector2i(2, 0), 1)
	_assert_true(
		tool._apply_target_atlas_path(
			"res://addons/hex_map_kit/assets/tactics_flat_top_hex_tiles_64x57_10.png",
			Vector2i(64, 57)
		),
		"target status test configures target atlas"
	)
	var status = tool.target_readiness_status()
	_assert_true(bool(status["tile_set_present"]), "target status reports TileSet presence")
	_assert_true(int(status["tile_set_source_count"]) >= 1, "target status reports source count")
	_assert_eq(status["tile_size"], Vector2i(64, 57), "target status reports tile size")
	_assert_eq(status["overlay_item_key"], "Treasure", "target status reports overlay item key")
	_assert_eq(status["overlay_source_id"], 4, "target status reports overlay payload source")
	_assert_true(status.has("overlay_tile_visible"), "target status reports overlay visibility")
	_assert_true(tool._target_status_label.text.contains("overlay=Treasure"), "target status label includes overlay payload")

	hex_layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_last_edit_trace_distinguishes_document_and_redraw() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)
	var layer = TileMapLayer.new()
	layer.tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(layer.tile_set, true, Vector2i(64, 64))
	root.add_child(layer)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	tool._apply_document_to_target()
	var origin_local = layer.map_to_local(HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true))
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = layer.to_global(origin_local)

	_assert_true(tool.forward_canvas_gui_input(press), "last edit trace accepts viewport click")
	var trace = tool.last_edit_status()
	_assert_true(bool(trace["document_changed"]), "last edit trace records document mutation")
	_assert_true(bool(trace["target_applied"]), "last edit trace records target apply")
	_assert_true(bool(trace["display_changed"]), "last edit trace records display tile change")
	_assert_true(not bool(trace["wall_before"]), "last edit trace records previous floor state")
	_assert_true(bool(trace["wall_after"]), "last edit trace records next wall state")
	_assert_eq(trace["display_atlas_before"], Vector2i.ZERO, "last edit trace records floor atlas before edit")
	_assert_eq(trace["display_atlas_after"], Vector2i(1, 0), "last edit trace records wall atlas after edit")
	_assert_eq(trace["target_used_cells_before"], 2, "last edit trace records used cells before edit")
	_assert_eq(trace["target_used_cells_after"], 2, "last edit trace records used cells after edit")
	_assert_true(tool._last_edit_detail_label.text.contains("document=yes"), "last edit trace appears in Dock detail")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_last_edit_trace_reports_target_apply_failure() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	_assert_true(tool.apply_cell(HexVector.zero()), "last edit trace mutates document without a target")
	var trace = tool.last_edit_status()
	_assert_true(bool(trace["document_changed"]), "target failure trace records document mutation")
	_assert_true(not bool(trace["target_applied"]), "target failure trace records target apply failure")
	_assert_true(not bool(trace["display_changed"]), "target failure trace keeps display unchanged")
	_assert_eq(trace["display_atlas_before"], Vector2i(-1, -1), "target failure trace has no display atlas before")
	_assert_eq(trace["display_atlas_after"], Vector2i(-1, -1), "target failure trace has no display atlas after")
	_assert_true(tool._last_edit_detail_label.text.contains("target=no"), "target failure trace appears in Dock detail")

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_persistence_checkpoint_reports_save_and_export_counts() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	var document_path = _test_resource_path("test_map_edit_visibility_document.tres")
	var export_path = _test_resource_path("test_map_edit_visibility_export.tres")

	_assert_true(tool.save_document(document_path), "persistence checkpoint saves document")
	var save_status = tool.persistence_status()
	_assert_eq(save_status["operation"], "save_document", "persistence checkpoint records save operation")
	_assert_eq(save_status["path"], document_path, "persistence checkpoint records save path")
	_assert_true(bool(save_status["ok"]), "persistence checkpoint records save success")
	_assert_eq(save_status["resource_class"], "HexMapDocumentResource", "persistence checkpoint records document class")
	_assert_eq(save_status["cell_count"], 2, "persistence checkpoint records save cell count")
	_assert_eq(save_status["wall_count"], 1, "persistence checkpoint records save wall count")

	_assert_true(tool.export_map_resource_to_path(export_path), "persistence checkpoint exports map")
	var export_status = tool.persistence_status()
	_assert_eq(export_status["operation"], "export_map", "persistence checkpoint records export operation")
	_assert_eq(export_status["path"], export_path, "persistence checkpoint records export path")
	_assert_true(bool(export_status["ok"]), "persistence checkpoint records export success")
	_assert_eq(export_status["resource_class"], "HexMapResource", "persistence checkpoint records export class")
	_assert_eq(export_status["cell_count"], 2, "persistence checkpoint records export cell count")
	_assert_eq(export_status["wall_count"], 1, "persistence checkpoint records export wall count")
	_assert_true(tool._persistence_detail_label.text.contains("HexMapResource"), "persistence checkpoint appears in Dock detail")

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_local_hit_uses_hex_tile_map_layer() -> void:
	var data = HexMapData.square(3, true)
	var resource = HexMapResource.from_map_data(data)
	var document = HexMapDocumentAdapter.from_map_resource(resource)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	layer.apply_map(resource)
	await process_frame

	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var wrapped_visual = HexVector.apply_basis(3, 0, 0)
	var hit_local = layer._tile_map.position + layer.hex_to_display_local(wrapped_visual)

	_assert_true(tool.apply_local_position(hit_local), "map edit tool uses HexTileMapLayer loop-aware hit")
	_assert_true(document.map.to_map_data().has_wall(HexVector.zero()), "map edit tool edits canonical toric cell from visual duplicate")
	_assert_true(layer.hex_map.to_map_data().has_wall(HexVector.zero()), "map edit tool updates HexTileMapLayer hex_map resource")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_hex_target_uses_command_apply_path() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var layer = CountingHexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var undo_redo = UndoRedo.new()
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_undo_redo(undo_redo)
	tool._apply_document_to_target()
	var redraw_count_after_full_apply = layer.redraw_count
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)

	_assert_true(tool.apply_cell(HexVector.zero()), "Hex target edit uses command apply path")
	_assert_eq(layer.apply_document_cell_count, 0, "Hex target edit does not call apply_document_cell")
	_assert_eq(layer.redraw_count, redraw_count_after_full_apply, "Hex target edit does not call full redraw")
	_assert_true(document.map.to_map_data().has_wall(HexVector.zero()), "Hex target command updates document")
	_assert_true(layer.is_wall(HexVector.zero()), "Hex target command updates target state")

	undo_redo.undo()
	_assert_eq(layer.apply_document_cell_count, 0, "Hex target undo does not call apply_document_cell")
	_assert_eq(layer.redraw_count, redraw_count_after_full_apply, "Hex target undo does not call full redraw")
	_assert_true(not document.map.to_map_data().has_wall(HexVector.zero()), "Hex target command undo updates document")
	_assert_true(layer.is_floor(HexVector.zero()), "Hex target command undo restores target state")

	undo_redo.redo()
	_assert_eq(layer.apply_document_cell_count, 0, "Hex target redo does not call apply_document_cell")
	_assert_eq(layer.redraw_count, redraw_count_after_full_apply, "Hex target redo does not call full redraw")
	_assert_true(document.map.to_map_data().has_wall(HexVector.zero()), "Hex target command redo updates document")
	_assert_true(layer.is_wall(HexVector.zero()), "Hex target command redo restores target state")

	undo_redo.clear_history()
	undo_redo.free()
	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_hex_tile_payload_modes_change_display() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool._apply_document_to_target()
	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	tool.set_tile_payload(0, Vector2i(1, 0), 0)

	_assert_true(tool.apply_cell(HexVector.zero()), "floor tile mode applies payload to HexTileMapLayer")
	_assert_eq(document.tile_overrides.size(), 1, "floor tile mode stores a document tile override")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i(1, 0), "floor tile mode redraws HexTileMapLayer tile")
	var trace = tool.last_edit_status()
	_assert_true(bool(trace["display_changed"]), "floor tile mode Last Edit records display change")
	_assert_eq(trace["display_renderer_after"], "HexTileMapLayer", "floor tile mode Last Edit records Hex renderer")
	_assert_true(tool._last_edit_detail_label.text.contains("payload=0:(1,0):0"), "floor tile mode Last Edit includes payload")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_overlay_tile_payload_changes_hex_display() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool._apply_document_to_target()
	tool.set_edit_mode(HexMapEditTool.EditMode.OVERLAY_TILE)
	tool.set_overlay_tile_payload("Treasure", 0, Vector2i(1, 0), 0)

	_assert_true(tool.apply_cell(HexVector.zero()), "overlay tile mode applies payload to HexTileMapLayer")
	_assert_eq(document.tile_overrides.size(), 1, "overlay tile mode stores a document tile override")
	_assert_eq(document.tile_overrides[0]["kind"], HexMapDocumentAdapter.KIND_OVERLAY, "overlay tile mode stores overlay kind")
	_assert_eq(document.tile_overrides[0]["item_key"], "Treasure", "overlay tile mode stores item key")
	var map_cell = HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true)
	_assert_eq(layer._overlay_tile_map.get_cell_atlas_coords(map_cell), Vector2i(1, 0), "overlay tile mode draws overlay tile")
	var state = layer.display_state_for_hex(HexVector.zero())
	_assert_eq(state["overlay_count"], 1, "overlay tile mode exposes overlay count")
	var trace = tool.last_edit_status()
	_assert_true(bool(trace["display_changed"]), "overlay tile mode Last Edit records display change")
	_assert_eq(trace["display_overlay_count_after"], 1, "overlay tile mode Last Edit records overlay count")
	_assert_eq(trace["target_apply_reason"], "Applied overlay tile to HexTileMapLayer.", "overlay tile mode uses overlay apply reason")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_keeps_tile_payloads_per_mode() -> void:
	var tool = await _new_ready_edit_tool()
	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	tool.set_tile_payload(1, Vector2i(2, 3), 0)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_TILE)
	tool.set_tile_payload(4, Vector2i(5, 6), 1)
	tool.set_edit_mode(HexMapEditTool.EditMode.OVERLAY_TILE)
	tool.set_overlay_tile_payload("Treasure", 7, Vector2i(8, 9), 2)

	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	_assert_eq(int(tool._tile_source_spin.value), 1, "floor tile mode restores floor payload source")
	_assert_eq(Vector2i(int(tool._tile_atlas_x_spin.value), int(tool._tile_atlas_y_spin.value)), Vector2i(2, 3), "floor tile mode restores floor payload atlas")

	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_TILE)
	_assert_eq(int(tool._tile_source_spin.value), 4, "wall tile mode restores wall payload source")
	_assert_eq(Vector2i(int(tool._tile_atlas_x_spin.value), int(tool._tile_atlas_y_spin.value)), Vector2i(5, 6), "wall tile mode restores wall payload atlas")
	_assert_eq(int(tool._tile_alternative_spin.value), 1, "wall tile mode restores wall alternative")

	tool.set_edit_mode(HexMapEditTool.EditMode.OVERLAY_TILE)
	_assert_eq(int(tool._tile_source_spin.value), 7, "overlay tile mode restores overlay payload source")
	_assert_eq(Vector2i(int(tool._tile_atlas_x_spin.value), int(tool._tile_atlas_y_spin.value)), Vector2i(8, 9), "overlay tile mode restores overlay payload atlas")
	_assert_eq(tool._overlay_item_key_edit.text, "Treasure", "overlay tile mode keeps overlay item key")
	_assert_true(_control_row_visible(tool._overlay_item_key_option), "overlay tile mode shows known item key option")

	tool.queue_free()
	await process_frame


func _test_map_edit_tool_object_and_label_payloads_change_hex_display() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool._apply_document_to_target()
	tool.set_edit_mode(HexMapEditTool.EditMode.OBJECT)
	tool.set_object_payload("chest")

	_assert_true(tool.apply_cell(HexVector.zero()), "object mode applies payload to HexTileMapLayer")
	var object_state = layer.display_state_for_hex(HexVector.zero())
	_assert_eq(object_state["object_count"], 1, "object mode exposes Hex object marker state")
	_assert_true(bool(tool.last_edit_status()["display_changed"]), "object mode Last Edit records marker display change")
	_assert_eq(tool.last_edit_status()["display_marker_count_after"], 1, "object mode Last Edit records marker count")

	tool.set_edit_mode(HexMapEditTool.EditMode.LABEL)
	tool.set_label_payload("area", "North")
	_assert_true(tool.apply_cell(HexVector.zero()), "label mode applies payload to HexTileMapLayer")
	var label_state = layer.display_state_for_hex(HexVector.zero())
	_assert_eq(label_state["label_count"], 1, "label mode exposes Hex label marker state")
	_assert_eq(label_state["marker_count"], 2, "label mode keeps object and label markers visible")
	_assert_true(bool(tool.last_edit_status()["display_changed"]), "label mode Last Edit records marker display change")
	_assert_eq(tool.last_edit_status()["display_marker_count_before"], 1, "label mode Last Edit records marker count before")
	_assert_eq(tool.last_edit_status()["display_marker_count_after"], 2, "label mode Last Edit records marker count after")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_forward_canvas_gui_input_edits_loop_visual_duplicate() -> void:
	var data = HexMapData.square(3, true)
	var resource = HexMapResource.from_map_data(data)
	var document = HexMapDocumentAdapter.from_map_resource(resource)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var duplicate_visual = HexVector.apply_basis(-3, 0, 0)
	layer.hex_size = 10.0
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	layer.loop_display_rect = Rect2(layer.hex_to_display_local(duplicate_visual) - Vector2.ONE, Vector2(2, 2))
	layer.apply_map(resource)
	var tool = await _new_ready_edit_tool()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = layer.to_global(layer._tile_map.position + layer.hex_to_display_local(duplicate_visual))
	var duplicate_map_cell = HexMapTileAdapter.vector_to_map_cell(duplicate_visual, true)

	_assert_true(tool.forward_canvas_gui_input(press), "map edit tool edits loop visual duplicate via viewport input")
	_assert_true(document.map.to_map_data().has_wall(HexVector.zero()), "loop visual duplicate edits canonical document cell")
	_assert_eq(
		layer._loop_tile_map.get_cell_atlas_coords(duplicate_map_cell),
		layer.wall_atlas_coords,
		"map edit tool refreshes duplicate tile after viewport edit"
	)
	_assert_true(layer._highlights.has(HexVector.zero().key()), "map edit tool highlights last edited canonical cell")
	_assert_vector_eq(tool.last_edit_status()["hex"], HexVector.zero(), "last edit status stores canonical hex")
	_assert_vector_eq(tool.last_edit_status()["visual_hex"], duplicate_visual, "last edit status stores visual hex")
	_assert_true(
		tool.apply_local_position(layer._tile_map.position + layer.hex_to_display_local(HexVector.q_axis())),
		"map edit tool accepts a second loop target edit"
	)
	_assert_eq(layer._highlights.size(), 1, "map edit tool keeps only one last-edit highlight")
	_assert_true(not layer._highlights.has(HexVector.zero().key()), "map edit tool clears previous last-edit highlight")
	_assert_true(layer._highlights.has(HexVector.q_axis().key()), "map edit tool highlights the newest canonical cell")

	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_undo_redo_preserves_loop_visual_identity() -> void:
	var data = HexMapData.square(3, true)
	var resource = HexMapResource.from_map_data(data)
	var document = HexMapDocumentAdapter.from_map_resource(resource)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	var duplicate_visual = HexVector.apply_basis(-3, 0, 0)
	layer.hex_size = 10.0
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	layer.loop_display_rect = Rect2(layer.hex_to_display_local(duplicate_visual) - Vector2.ONE, Vector2(2, 2))
	layer.apply_map(resource)
	var tool = await _new_ready_edit_tool()
	var undo_redo = UndoRedo.new()
	tool.set_document(document)
	tool.set_target_layer(layer)
	tool.set_undo_redo(undo_redo)
	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	var duplicate_map_cell = HexMapTileAdapter.vector_to_map_cell(duplicate_visual, true)
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = layer.to_global(layer._tile_map.position + layer.hex_to_display_local(duplicate_visual))

	_assert_true(tool.forward_canvas_gui_input(press), "loop visual duplicate edit is undoable")
	undo_redo.undo()
	_assert_true(not document.map.to_map_data().has_wall(HexVector.zero()), "undo restores canonical document floor")
	_assert_eq(
		layer._loop_tile_map.get_cell_atlas_coords(duplicate_map_cell),
		layer.floor_atlas_coords,
		"undo restores duplicate floor tile"
	)
	undo_redo.redo()
	_assert_true(document.map.to_map_data().has_wall(HexVector.zero()), "redo restores canonical document wall")
	_assert_eq(
		layer._loop_tile_map.get_cell_atlas_coords(duplicate_map_cell),
		layer.wall_atlas_coords,
		"redo restores duplicate wall tile"
	)

	undo_redo.clear_history()
	undo_redo.free()
	layer.queue_free()
	tool.queue_free()
	await process_frame


func _test_map_edit_tool_mode_specific_payload_controls() -> void:
	var tool = await _new_ready_edit_tool()

	tool.set_edit_mode(HexMapEditTool.EditMode.WALL_FLOOR)
	_assert_true(not _control_row_visible(tool._tile_source_spin), "wall/floor mode hides tile payload controls")
	_assert_true(not _control_row_visible(tool._object_id_edit), "wall/floor mode hides object payload controls")
	_assert_true(not _control_row_visible(tool._label_id_edit), "wall/floor mode hides label payload controls")

	tool.set_edit_mode(HexMapEditTool.EditMode.FLOOR_TILE)
	_assert_true(_control_row_visible(tool._tile_source_spin), "floor tile mode shows tile source control")
	_assert_true(_control_row_visible(tool._tile_atlas_x_spin), "floor tile mode shows tile atlas controls")
	_assert_true(not _control_row_visible(tool._object_id_edit), "floor tile mode hides object payload controls")

	tool.set_edit_mode(HexMapEditTool.EditMode.OVERLAY_TILE)
	_assert_true(_control_row_visible(tool._tile_source_spin), "overlay tile mode shows tile source control")
	_assert_true(_control_row_visible(tool._overlay_item_key_edit), "overlay tile mode shows item key control")
	_assert_true(not _control_row_visible(tool._object_id_edit), "overlay tile mode hides object payload controls")

	tool.set_edit_mode(HexMapEditTool.EditMode.OBJECT)
	_assert_true(_control_row_visible(tool._object_id_edit), "object mode shows object payload controls")
	_assert_true(_control_row_visible(tool._object_properties_edit), "object mode shows object properties control")
	_assert_true(not _control_row_visible(tool._tile_source_spin), "object mode hides tile payload controls")

	tool.set_edit_mode(HexMapEditTool.EditMode.LABEL)
	_assert_true(_control_row_visible(tool._label_id_edit), "label mode shows label id control")
	_assert_true(_control_row_visible(tool._label_text_edit), "label mode shows label text control")
	_assert_true(not _control_row_visible(tool._object_id_edit), "label mode hides object payload controls")

	tool.queue_free()
	await process_frame


func _test_hex_cell_button_layout_direction_cells_flat_top() -> void:
	var radius := 12.0
	var gap := 1.5
	var entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"flat_top": true,
		"cell_radius": radius,
		"cell_gap": gap,
		"padding": Vector2(2, 2),
	})
	var by_id = _entries_by_id(entries)
	var origin: Vector2 = by_id[HexVector.zero().key()]["center"]
	_assert_eq(entries.size(), 7, "direction layout includes center and six neighbor cells")
	for direction in HexVector.directions():
		var actual: Vector2 = by_id[direction.key()]["center"] - origin
		var expected = HexMapTileAdapter.hex_to_local(direction, radius + gap, true)
		_assert_vec2_approx(actual, expected, "flat-top direction cell uses tile adapter pitch")


func _test_hex_cell_button_layout_direction_cells_pointy_top() -> void:
	var radius := 12.0
	var gap := 1.5
	var flat_entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"flat_top": true,
		"cell_radius": radius,
		"cell_gap": gap,
		"padding": Vector2(2, 2),
	})
	var pointy_entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"flat_top": false,
		"cell_radius": radius,
		"cell_gap": gap,
		"padding": Vector2(2, 2),
	})
	var direction = HexVector.q_axis()
	var flat_by_id = _entries_by_id(flat_entries)
	var pointy_by_id = _entries_by_id(pointy_entries)
	var flat_delta: Vector2 = flat_by_id[direction.key()]["center"] - flat_by_id[HexVector.zero().key()]["center"]
	var pointy_delta: Vector2 = pointy_by_id[direction.key()]["center"] - pointy_by_id[HexVector.zero().key()]["center"]
	_assert_vec2_approx(
		pointy_delta,
		HexMapTileAdapter.hex_to_local(direction, radius + gap, false),
		"pointy-top direction cell uses tile adapter pitch"
	)
	_assert_true(not pointy_delta.is_equal_approx(flat_delta), "pointy-top layout differs from flat-top layout")


func _test_hex_cell_button_layout_minimum_size_uses_padding() -> void:
	var tight_padding := Vector2(2, 2)
	var wide_padding := Vector2(10, 10)
	var tight_entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_CUSTOM,
		"shape_cells": [HexVector.zero()],
		"cell_radius": 12.0,
		"padding": tight_padding,
	})
	var wide_entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_CUSTOM,
		"shape_cells": [HexVector.zero()],
		"cell_radius": 12.0,
		"padding": wide_padding,
	})
	var tight_size = HexCellButtonLayout.minimum_size(tight_entries, tight_padding)
	var wide_size = HexCellButtonLayout.minimum_size(wide_entries, wide_padding)
	_assert_true(wide_size.x > tight_size.x and wide_size.y > tight_size.y, "layout minimum size grows with padding")


func _test_hex_cell_button_layout_polygon_hit_rejects_rect_corner() -> void:
	var entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_CUSTOM,
		"shape_cells": [HexVector.zero()],
		"cell_radius": 12.0,
		"padding": Vector2(2, 2),
	})
	var entry: Dictionary = entries[0]
	var rect_corner = entry["bounds"].position + Vector2(0.2, 0.2)
	_assert_true(entry["bounds"].has_point(rect_corner), "hex rect corner fixture is inside entry bounds")
	_assert_true(HexCellButtonLayout.hit_entry(entries, rect_corner).is_empty(), "hex hit test rejects bounds corner outside polygon")
	_assert_eq(HexCellButtonLayout.hit_entry(entries, entry["center"])["id"], entry["id"], "hex hit test accepts polygon center")


func _test_hex_cell_button_layout_shape_cells_custom_ring_disc() -> void:
	var custom = [HexVector.zero(), HexVector.q_axis()]
	var custom_cells = HexCellButtonLayout.shape_cells(HexCellButtonLayout.SHAPE_CUSTOM, {"shape_cells": custom})
	_assert_keys_eq(custom_cells, custom, "custom shape returns the requested cell set")
	custom.clear()
	_assert_eq(custom_cells.size(), 2, "custom shape returns a duplicate cell array")
	_assert_eq(
		HexCellButtonLayout.shape_cells(HexCellButtonLayout.SHAPE_RING, {"radius": 1}).size(),
		6,
		"ring shape hook returns radius-1 ring cells"
	)
	_assert_eq(
		HexCellButtonLayout.shape_cells(HexCellButtonLayout.SHAPE_DISC, {"radius": 1}).size(),
		7,
		"disc shape hook returns radius-1 disc cells"
	)


func _test_hex_cell_button_panel_emits_pressed_for_hex_hit() -> void:
	var panel = HexCellButtonPanel.new()
	panel.configure({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"pressable_cells": _direction_pressable_cells(),
		"cell_radius": 12.0,
	})
	var recorder = CellPressRecorder.new()
	panel.cell_pressed.connect(Callable(recorder, "record"))
	root.add_child(panel)
	await process_frame

	var entry: Dictionary = _entries_by_id(panel.get_entries())[HexVector.q_axis().key()]
	_send_panel_click(panel, entry["center"])
	_assert_eq(recorder.entries.size(), 1, "hex cell panel emits pressed for hex polygon hit")
	_assert_eq(recorder.entries[0]["id"], HexVector.q_axis().key(), "hex cell panel emits the hit cell entry")

	panel.queue_free()
	await process_frame


func _test_hex_cell_button_panel_emits_hover_for_hex_hit() -> void:
	var panel = HexCellButtonPanel.new()
	panel.configure({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"pressable_cells": _direction_pressable_cells(),
		"cell_radius": 12.0,
	})
	var recorder = CellPressRecorder.new()
	panel.cell_hovered.connect(Callable(recorder, "record"))
	root.add_child(panel)
	await process_frame

	var entry: Dictionary = _entries_by_id(panel.get_entries())[HexVector.q_axis().key()]
	_send_panel_motion(panel, entry["center"])
	_assert_eq(recorder.entries.size(), 1, "hex cell panel emits hover for hex polygon hit")
	_assert_eq(recorder.entries[0]["id"], HexVector.q_axis().key(), "hex cell panel hover emits the hit cell entry")

	panel.queue_free()
	await process_frame


func _test_hex_cell_button_panel_accepts_label_display_state() -> void:
	var labels := {HexVector.zero().key(): "0,0,0"}
	var panel = HexCellButtonPanel.new()
	panel.configure({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"label_by_cell": labels,
		"show_labels": true,
		"cell_radius": 12.0,
	})
	root.add_child(panel)
	await process_frame

	var center_entry: Dictionary = _entries_by_id(panel.get_entries())[HexVector.zero().key()]
	_assert_true(panel.show_labels, "hex cell panel keeps label display enabled")
	_assert_eq(center_entry["label"], "0,0,0", "hex cell panel keeps label text in layout entry")

	panel.queue_free()
	await process_frame


func _test_hex_cell_button_panel_does_not_press_disabled_cell() -> void:
	var disabled := {}
	disabled[HexVector.q_axis().key()] = true
	var panel = HexCellButtonPanel.new()
	panel.configure({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"pressable_cells": _direction_pressable_cells(),
		"disabled_cells": disabled,
		"cell_radius": 12.0,
	})
	var recorder = CellPressRecorder.new()
	panel.cell_pressed.connect(Callable(recorder, "record"))
	root.add_child(panel)
	await process_frame

	var entry: Dictionary = _entries_by_id(panel.get_entries())[HexVector.q_axis().key()]
	_send_panel_click(panel, entry["center"])
	_assert_eq(recorder.entries.size(), 0, "hex cell panel ignores disabled cell press")

	panel.queue_free()
	await process_frame


func _test_hex_cell_button_panel_focus_navigation() -> void:
	var panel = HexCellButtonPanel.new()
	panel.configure({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"pressable_cells": _direction_pressable_cells(),
		"cell_radius": 12.0,
	})
	var focus_recorder = CellPressRecorder.new()
	var press_recorder = CellPressRecorder.new()
	panel.cell_focus_changed.connect(Callable(focus_recorder, "record"))
	panel.cell_pressed.connect(Callable(press_recorder, "record"))
	root.add_child(panel)
	await process_frame

	_send_panel_key(panel, KEY_RIGHT)
	_send_panel_key(panel, KEY_SPACE)
	_assert_eq(focus_recorder.entries.size(), 1, "hex cell panel emits focus change for keyboard navigation")
	_assert_eq(press_recorder.entries.size(), 1, "hex cell panel emits pressed for focused keyboard cell")
	_assert_eq(press_recorder.entries[0]["id"], HexVector.directions()[0].key(), "keyboard press uses the focused cell")

	panel.queue_free()
	await process_frame


func _test_distribution_editor_loads_default_preset_values() -> void:
	var editor = HexDistEditor.new()
	root.add_child(editor)
	await process_frame

	var expected = HexDistribution.from_preset_id(
		HexRandomizer.get_preset_id(HexRandomizer.get_preset_names()[0])
	)
	_assert_eq(_spin_values(editor._d3_spins), expected.distribution_3, "distribution editor shows preset 3-neighbor values")
	_assert_eq(_spin_values(editor._d2_spins), expected.distribution_2, "distribution editor shows preset 2-neighbor values")
	_assert_eq(_spin_values(editor._d1_spins), expected.distribution_1, "distribution editor shows preset 1-neighbor values")
	_assert_eq(editor._pattern_controls.size(), 14, "distribution editor tracks every pattern control")

	editor.queue_free()
	await process_frame


func _test_distribution_editor_loads_resource_values_and_colors_cells() -> void:
	var path = _test_resource_path("test_hex_distribution_editor.tres")
	var custom = HexDistribution.new(
		[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0],
		[0.5, 2.5, 4.5, 6.5],
		[1.5, 7.5]
	)
	_save_distribution(path, custom)

	var editor = HexDistEditor.new(path)
	root.add_child(editor)
	await process_frame

	_assert_eq(_spin_values(editor._d3_spins), custom.distribution_3, "distribution editor loads custom 3-neighbor values")
	_assert_eq(_spin_values(editor._d2_spins), custom.distribution_2, "distribution editor loads custom 2-neighbor values")
	_assert_eq(_spin_values(editor._d1_spins), custom.distribution_1, "distribution editor loads custom 1-neighbor values")
	_assert_eq(editor._editing_path, path, "distribution editor keeps the loaded resource path")
	_assert_true(not editor._save_button.disabled, "distribution editor enables apply for loaded resources")

	editor._d3_spins[0].value = 8.0
	editor._on_spin_changed(8.0, 3, 0)
	_assert_color_approx(
		editor._center_color(3, 0),
		Color(0.1, 0.1, 0.1),
		"distribution editor center color follows spin value"
	)

	editor.queue_free()
	await process_frame


func _test_distribution_editor_uses_hex_cell_layout_for_patterns() -> void:
	var editor = HexDistEditor.new()
	var origin := Vector2(70, 36)
	var entries = editor._distribution_pattern_entries(3, origin)
	var center_entry := {}
	var refs := {}
	for entry in entries:
		var metadata: Dictionary = entry["metadata"]
		if bool(metadata.get("center", false)):
			center_entry = entry
		else:
			refs[int(metadata["ref_index"])] = entry

	var hex_size := 16.0
	var expected_refs = [
		origin + Vector2(-hex_size * 1.5, -hex_size * sqrt(3.0) / 2.0),
		origin + Vector2(0, -hex_size * sqrt(3.0)),
		origin + Vector2(hex_size * 1.5, -hex_size * sqrt(3.0) / 2.0),
	]
	_assert_eq(entries.size(), 4, "distribution 3-neighbor pattern uses center and three reference entries")
	_assert_true(not center_entry.is_empty(), "distribution pattern marks the center entry")
	_assert_vec2_approx(center_entry["center"], origin, "distribution pattern keeps the existing center position")
	for index in range(expected_refs.size()):
		_assert_vec2_approx(refs[index]["center"], expected_refs[index], "distribution pattern keeps the existing reference position")

	editor.free()


func _test_distribution_editor_pattern_redraw_uses_layout_entries() -> void:
	var editor = HexDistEditor.new()
	root.add_child(editor)
	await process_frame

	var control = editor._pattern_controls[0]
	var entries = editor._distribution_pattern_entries(3)
	_assert_eq(entries.size(), 4, "distribution redraw test uses layout-backed entries")
	_assert_true(
		control.draw.is_connected(Callable(editor, "_draw_pattern").bind(3, 0, control)),
		"distribution pattern control draws through the layout-backed draw method"
	)
	editor._on_spin_changed(1.0, 3, 0)

	editor.queue_free()
	await process_frame


func _test_distribution_editor_close_button_uses_cancel_flow() -> void:
	var state := {"count": 0}
	var editor = HexDistEditor.new("", Callable(), Callable(self, "_count_cancel").bind(state))
	root.add_child(editor)
	await process_frame

	editor.emit_signal("close_requested")
	await process_frame

	_assert_eq(state["count"], 1, "distribution editor window close calls cancel callback")


func _test_distribution_editor_manages_recent_custom_and_duplicate_preset() -> void:
	HexDistEditor.clear_recent_distributions()
	var path = _test_resource_path("test_hex_distribution_duplicate.tres")

	var editor = HexDistEditor.new()
	root.add_child(editor)
	await process_frame

	var expected = HexDistribution.from_preset_id(
		HexRandomizer.get_preset_id(HexRandomizer.get_preset_names()[0])
	)
	_assert_true(editor._duplicate_preset_button != null, "distribution editor exposes duplicate preset button")
	_assert_eq(editor._duplicate_preset_button.text, "Duplicate Preset...", "distribution editor labels duplicate preset flow")
	_assert_true(editor.save_current_distribution_as(path), "distribution editor saves current preset as custom distribution")
	_assert_eq(HexDistEditor.recent_distribution_paths(), [path], "distribution editor remembers saved custom distribution")
	_assert_eq(editor._editing_path, path, "distribution editor switches to saved custom distribution")
	var saved = load(path)
	_assert_true(saved is HexDistribution, "duplicate preset save creates HexDistribution resource")
	_assert_eq(saved.distribution_3, expected.distribution_3, "duplicate preset save keeps preset 3-neighbor values")
	_assert_eq(saved.distribution_2, expected.distribution_2, "duplicate preset save keeps preset 2-neighbor values")
	_assert_eq(saved.distribution_1, expected.distribution_1, "duplicate preset save keeps preset 1-neighbor values")

	editor.queue_free()
	await process_frame

	var recent_editor = HexDistEditor.new()
	root.add_child(recent_editor)
	await process_frame
	_assert_eq(recent_editor._recent_option.item_count, 1, "distribution editor lists recent custom distributions")
	_assert_eq(recent_editor._recent_option.get_item_text(0), path, "distribution editor shows recent custom path")
	recent_editor._on_recent_selected(0)
	_assert_eq(recent_editor._editing_path, path, "distribution editor loads custom distribution from recent list")
	_assert_eq(_spin_values(recent_editor._d3_spins), expected.distribution_3, "recent custom load restores saved values")

	recent_editor.queue_free()
	await process_frame


func _test_adjacency_rule_editor_applies_rule_text() -> void:
	var state := {"rules": "", "count": 0}
	var editor = HexAdjacencyRuleEditor.new(
		"default=0.2",
		Callable(self, "_capture_rules").bind(state),
		Callable(self, "_count_cancel").bind(state)
	)
	root.add_child(editor)
	await process_frame

	_assert_eq(editor._rules_edit.text, "default=0.2", "adjacency rule editor loads initial rule text")
	_assert_eq(editor._rules_status_label.text, "Rules: 1", "adjacency rule editor shows initial valid rule count")
	editor._rules_edit.text = "1=0.8;default=0.1"
	editor._on_rules_text_changed(editor._rules_edit.text)
	_assert_eq(editor._rules_status_label.text, "Rules: 2", "adjacency rule editor updates valid rule count")
	editor._rules_edit.text = "1=0.8;bad=x"
	editor._on_rules_text_changed(editor._rules_edit.text)
	_assert_true(editor._rules_status_label.text.contains("Invalid: bad=x"), "adjacency rule editor reports invalid entry")
	_assert_true(not editor._rules_status_label.text.contains("fallback default"), "adjacency rule editor does not show fallback status")
	editor._on_apply_pressed()
	await process_frame

	_assert_eq(state["rules"], "1=0.8;bad=x", "adjacency rule editor apply returns rule text")
	_assert_eq(state["count"], 0, "adjacency rule editor apply does not call cancel")


func _test_generation_dock_adjacency_rule_validation() -> void:
	var dock = await _new_ready_dock()
	dock._wall_prob_slider.set_value_no_signal(0.35)
	dock._overlay_adjacency_rules_edit.text = "default=0.2;1=0.8;2,1=0.4;bad=x;bad=0.5"
	var rules = dock._overlay_adjacency_rules()
	_assert_eq(rules["default"], 0.2, "generation dock adjacency rules keep default")
	_assert_eq(rules[1], 0.8, "generation dock adjacency rules keep count rule")
	_assert_eq(rules[Vector2i(2, 1)], 0.4, "generation dock adjacency rules normalize count/component rule")
	_assert_true(dock._overlay_adjacency_rules_status_label.text.contains("Rules: 3"), "generation dock adjacency status shows valid rule count")
	_assert_true(dock._overlay_adjacency_rules_status_label.text.contains("Invalid: bad=x, bad=0.5"), "generation dock adjacency status shows invalid entries")

	dock._overlay_adjacency_rules_edit.text = "bad"
	rules = dock._overlay_adjacency_rules()
	_assert_eq(rules, {}, "generation dock adjacency rules stay empty when no valid rules exist")
	_assert_true(dock._overlay_adjacency_rules_status_label.text.contains("Rules: 0"), "generation dock adjacency status shows empty rules")
	_assert_true(not dock._overlay_adjacency_rules_status_label.text.contains("fallback default"), "generation dock adjacency status does not show fallback")

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_adjacency_check.set_pressed_no_signal(true)
	dock._on_overlay_adjacency_toggled(true)
	dock._overlay_adjacency_rules_edit.text = "bad"
	dock._refresh_controls()
	_assert_true(dock._generate_button.disabled, "generation dock disables Generate when adjacency rules are empty")
	_assert_true(not await dock._generate_map(), "generation dock does not generate adjacency overlay with empty rules")
	_assert_eq(
		dock.generation_status()["status"],
		HexMapGenDock.GENERATION_BLOCK_STATUS_PREFIX + HexMapGenDock.GENERATION_BLOCK_EMPTY_ADJACENCY_RULES,
		"empty adjacency rules block generation status"
	)

	dock._overlay_adjacency_rules_edit.text = "default=0.0"
	dock._refresh_controls()
	_assert_true(not dock._generate_button.disabled, "valid adjacency rules unblock Generate")
	_assert_eq(dock.generation_status()["status"], "Ready", "resolved adjacency block restores ready status")

	dock.queue_free()
	await process_frame


func _test_generation_dock_symmetric_hexagon_minimum_radii() -> void:
	var dock = await _new_ready_dock()

	dock._generate_option.select(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_HEXAGON)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._connect_method_option.select(1)
	dock._refresh_controls()
	for radius in [1, 2]:
		dock._gen_radius_spin.set_value_no_signal(radius)
		_assert_true(await dock._generate_map(), "generation dock completes radius %d symmetric hexagon generation" % radius)

		var data = dock._current_data
		var hex_cell_count = 1 + 3 * radius * (radius + 1)
		_assert_eq(data.cells.size(), hex_cell_count, "generation dock creates radius %d symmetric hexagon cells" % radius)
		_assert_true(data.walls.size() > 0, "generation dock radius %d symmetric hexagon creates walls" % radius)
		_assert_true(data.walls.size() <= hex_cell_count - 1, "generation dock radius %d symmetric hexagon keeps protected floor" % radius)
		_assert_true(HexMapGenerator.is_floor_connected(data), "generation dock radius %d symmetric hexagon completes connectivity" % radius)
		_assert_true(
			dock._stats_label.text.contains(HexMapGenDock.GENERATE_NAMES[HexMapGenDock.GENERATE_SYMMETRIC]),
			"generation dock stats include generation mode"
		)

	dock.queue_free()
	await process_frame


func _test_generation_dock_shape_universe_uses_canonical_hexagon_and_square_torus() -> void:
	var dock = await _new_ready_dock()

	var simple_hexagon = dock._shape_universe_from_values(
		false,
		HexMapGenDock.SHAPE_HEXAGON,
		2,
		1,
		1,
		3
	)
	var symmetric_hexagon = dock._shape_universe_from_values(
		true,
		HexMapGenDock.SHAPE_HEXAGON,
		1,
		1,
		1,
		2
	)
	var torus_universe = dock._shape_universe_from_values(
		false,
		HexMapGenDock.SHAPE_TORUS,
		1,
		1,
		1,
		2
	)
	_assert_keys_eq(simple_hexagon, HexMapData.hexagon(2).cells, "simple hexagon universe uses canonical HexMapData shape")
	_assert_keys_eq(symmetric_hexagon, HexMapData.hexagon(2).cells, "symmetric hexagon universe uses canonical HexMapData shape")
	_assert_keys_eq(simple_hexagon, symmetric_hexagon, "simple and symmetric hexagon universes match for the same radius")
	_assert_keys_eq(torus_universe, HexMapData.square(5, false).cells, "torus universe remains a non-toric square cell set")

	dock.queue_free()
	await process_frame


func _test_generation_dock_torus_connectivity_controls() -> void:
	var dock = await _new_ready_dock()

	_assert_eq(dock._generate_option.selected, HexMapGenDock.GENERATE_SYMMETRIC, "generation dock defaults to symmetric generator")
	_assert_true(dock._torus_connectivity_check.visible, "toric connection is visible for symmetric generation")
	_assert_true(not dock._torus_connectivity_check.disabled, "toric connection is enabled for symmetric generation")

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._on_generate_changed(HexMapGenDock.GENERATE_SIMPLE)
	await process_frame
	_assert_true(not dock._torus_connectivity_check.visible, "toric connection is hidden for simple generation")
	_assert_true(dock._torus_connectivity_check.disabled, "toric connection is disabled for simple generation")

	dock._generate_option.select(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._on_generate_changed(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_HEXAGON)
	dock._on_symmetric_shape_changed(HexMapGenDock.SHAPE_HEXAGON)
	dock._torus_connectivity_check.set_pressed_no_signal(true)
	dock._on_torus_connectivity_toggled(true)
	await process_frame
	_assert_eq(dock._shape_option_symmetric.selected, HexMapGenDock.SHAPE_RECTANGLE, "toric connection selects symmetric square")
	_assert_true(dock._torus_connectivity_check.button_pressed, "toric connection remains on after selecting square")

	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_HEXAGON)
	dock._on_symmetric_shape_changed(HexMapGenDock.SHAPE_HEXAGON)
	await process_frame
	_assert_true(not dock._torus_connectivity_check.button_pressed, "symmetric hexagon turns toric connection off")

	_begin_manual_generation(dock, false)
	_assert_true(dock._torus_connectivity_check.disabled, "toric connection is disabled while generation is running")
	dock._finish_generation(true)

	dock.queue_free()
	await process_frame


func _test_generation_dock_torus_connectivity_generation() -> void:
	var dock = await _new_ready_dock()

	dock._generate_option.select(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._on_generate_changed(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._on_symmetric_shape_changed(HexMapGenDock.SHAPE_RECTANGLE)
	dock._gen_radius_spin.set_value_no_signal(2)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._connect_method_option.select(_connect_method_index(HexMapGenerator.CONNECT_NONE))
	dock._torus_connectivity_check.set_pressed_no_signal(false)
	dock._refresh_controls()

	_assert_true(await dock._generate_map(), "generation dock completes non-toric symmetric square generation")
	_assert_eq(dock._current_data.cyclic_size, 0, "symmetric square without toric connection is non-toric")

	dock._torus_connectivity_check.set_pressed_no_signal(true)
	dock._on_torus_connectivity_toggled(true)
	_assert_true(await dock._generate_map(), "generation dock completes toric symmetric square generation")
	_assert_eq(dock._current_data.cyclic_size, 5, "symmetric square with toric connection uses toric size")

	dock.queue_free()
	await process_frame


func _test_generation_dock_tracks_generation_progress_state() -> void:
	var dock = await _new_ready_dock()

	var idle_status = dock.generation_status()
	_assert_true(not idle_status["running"], "generation dock is not running before Generate")
	_assert_true(not idle_status["cancel_requested"], "generation dock has no cancel request before Generate")
	_assert_eq(idle_status["progress"], 0.0, "generation dock starts with zero progress")
	_assert_eq(idle_status["status"], "Ready", "generation dock starts ready")
	_assert_eq(dock._generation_id, 0, "generation dock does not auto generate on creation")
	_assert_eq(dock._current_data, null, "generation dock starts without generated data")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on creation")
	_assert_eq(_window_child_count(dock), 0, "generation dock has no modal progress window on creation")

	dock._on_generate_pressed()
	await _wait_for_progress_controls(dock, "Generate button generation")
	await _wait_for_generation(dock, "Generate button generation")
	var ready_status = dock.generation_status()
	_assert_true(not ready_status["running"], "generation dock clears running state after Generate")
	_assert_true(not ready_status["cancel_requested"], "generation dock clears cancel request after Generate")
	_assert_eq(ready_status["progress"], 1.0, "generation dock reports completed progress")
	_assert_eq(ready_status["status"], "Ready", "generation dock reports ready status")
	_assert_true(_progress_controls_visible(dock), "generation dock keeps Generate progress visible after fast generation")
	_assert_true(dock._generation_progress_cancel_button.disabled, "generation dock disables progress cancel after Generate finish")
	_assert_eq(_window_child_count(dock), 0, "generation dock does not create modal progress window for Generate")
	await _wait_seconds(HexMapGenDock.GENERATION_PROGRESS_MIN_VISIBLE_SEC + 0.1)
	_assert_true(_progress_controls_hidden(dock), "generation dock hides Generate progress after minimum display time")

	_begin_manual_generation(dock, true)
	await _wait_for_progress_controls(dock, "manual successful generation")
	_assert_true(not dock._generation_progress_cancel_button.disabled, "generation dock enables progress cancel while running")
	dock._generation_progress_visible_started_msec = Time.get_ticks_msec()
	dock._finish_generation(false)
	var finished_status = dock.generation_status()
	_assert_true(not finished_status["running"], "generation dock clears running state immediately after successful finish")
	_assert_eq(finished_status["status"], "Ready", "generation dock reports ready before progress hide delay completes")
	_assert_true(_progress_controls_visible(dock), "generation dock keeps success progress visible for minimum display time")
	_assert_true(dock._generation_progress_cancel_button.disabled, "generation dock disables progress cancel after successful finish")
	await _wait_seconds(HexMapGenDock.GENERATION_PROGRESS_MIN_VISIBLE_SEC + 0.1)
	_assert_true(_progress_controls_hidden(dock), "generation dock hides success progress after minimum display time")

	_begin_manual_generation(dock, true)
	await _wait_for_progress_controls(dock, "manual cancelled generation")
	dock.request_generation_cancel()
	var cancel_status = dock.generation_status()
	_assert_true(cancel_status["running"], "generation dock keeps running state after cancel request")
	_assert_true(cancel_status["cancel_requested"], "generation dock stores cancel request state")
	_assert_eq(cancel_status["status"], "Cancel requested", "generation dock reports cancel request status")
	_assert_true(dock._generation_progress_cancel_button.disabled, "generation dock disables progress cancel after cancel request")

	dock._finish_generation(true)
	var cancelled_status = dock.generation_status()
	_assert_true(not cancelled_status["running"], "generation dock clears running state after cancelled finish")
	_assert_true(not cancelled_status["cancel_requested"], "generation dock clears cancel request after cancelled finish")
	_assert_eq(cancelled_status["status"], "Cancelled", "generation dock reports cancelled status")
	_assert_true(_progress_controls_hidden(dock), "generation dock hides progress after cancellation")

	dock.queue_free()
	await process_frame


func _test_generation_dock_only_generates_from_generate_button() -> void:
	var dock = await _new_ready_dock()

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._connect_method_option.select(0)
	dock._refresh_controls()

	var generation_id = dock._generation_id
	dock._rect_width_spin.value = 2
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on SpinBox value change")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on SpinBox value change")

	dock._rect_width_spin.emit_signal("focus_exited")
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on focus exit")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on focus exit")

	dock._generate_option.select(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._gen_radius_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._on_generate_changed(HexMapGenDock.GENERATE_SYMMETRIC)
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on generator selection change")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on generator selection change")

	dock._wall_prob_slider.value = 0.25
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on slider value change")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on slider value change")

	dock._on_dist_changed(0)
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on dist selection change")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on dist selection change")

	dock._on_seed_randomize()
	await process_frame
	_assert_eq(dock._generation_id, generation_id, "generation dock does not regenerate on seed randomize")
	_assert_true(_progress_controls_hidden(dock), "generation dock does not show progress on seed randomize")

	dock._on_generate_pressed()
	await _wait_for_progress_controls(dock, "explicit Generate button generation")
	await _wait_for_generation(dock, "explicit Generate button generation")
	_assert_eq(dock._generation_id, generation_id + 1, "generation dock regenerates immediately from Generate")
	_assert_true(
		dock._stats_label.text.contains(HexMapGenDock.GENERATE_NAMES[HexMapGenDock.GENERATE_SYMMETRIC]),
		"Generate button updates generator mode"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_wires_core_progress_and_cancel() -> void:
	var dock = await _new_ready_dock()

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._connect_method_option.select(0)
	dock._refresh_controls()
	await dock._generate_map()
	var completed_data = dock._current_data

	dock._rect_width_spin.set_value_no_signal(20)
	dock._rect_height_spin.set_value_no_signal(20)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._connect_method_option.select(0)
	dock._generation_chunk_size = 1
	dock._generation_progress_delay_usec = 5000
	dock._refresh_controls()

	dock._generate_map(true)
	await _wait_for_core_progress(dock)
	await _wait_for_progress_controls(dock, "long threaded generation")
	_assert_true(not dock._generation_progress_cancel_button.disabled, "generation dock shows cancellable progress for long generation")
	_assert_eq(_window_child_count(dock), 0, "generation dock does not create modal progress window for long generation")
	dock.request_generation_cancel()
	await _wait_for_generation(dock, "cancelled threaded generation")

	var cancelled_status = dock.generation_status()
	_assert_eq(cancelled_status["status"], "Cancelled", "generation dock reports threaded cancellation")
	_assert_true(dock._generation_core_progress_event_count > 0, "generation dock receives core progress callback events")
	_assert_true(dock._generation_cancel_poll_count > 0, "generation dock exposes cancel state through core cancel callback")
	_assert_true(dock._generation_last_core_progress > 0.0, "generation dock records non-hardcoded core progress")
	_assert_eq(dock._current_data, completed_data, "generation dock keeps last completed map when cancel returns partial data")

	dock.queue_free()
	await process_frame


func _test_generation_dock_applies_configured_tile_entries() -> void:
	var dock = await _new_ready_dock()

	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	dock._current_data = data
	dock._floor_source_spin.value = 4
	dock._floor_atlas_x_spin.value = 2
	dock._floor_atlas_y_spin.value = 3
	dock._wall_source_spin.value = 5
	dock._wall_atlas_x_spin.value = 6
	dock._wall_atlas_y_spin.value = 7

	var fake_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_data_to_tile_map_layer(fake_layer), "generation dock applies current data to a layer")
	_assert_true(fake_layer.cleared, "generation dock clears target layer before applying")
	_assert_eq(fake_layer.calls.size(), 2, "generation dock emits one tile entry per cell")
	_assert_eq(fake_layer.calls[0]["map_cell"], Vector2i.ZERO, "generation dock applies floor cell position")
	_assert_eq(fake_layer.calls[0]["source_id"], 4, "generation dock applies configured floor source")
	_assert_eq(fake_layer.calls[0]["atlas_coords"], Vector2i(2, 3), "generation dock applies configured floor atlas")
	_assert_eq(fake_layer.calls[1]["map_cell"], Vector2i(1, 0), "generation dock applies wall cell position")
	_assert_eq(fake_layer.calls[1]["source_id"], 5, "generation dock applies configured wall source")
	_assert_eq(fake_layer.calls[1]["atlas_coords"], Vector2i(6, 7), "generation dock applies configured wall atlas")
	_assert_true(dock._apply_write_policy_option.visible, "Apply Write is visible in Primary mode")

	dock._apply_write_policy_option.select(1)
	var preserving_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_data_to_tile_map_layer(preserving_layer), "generation dock applies current data with Add Item write policy")
	_assert_true(not preserving_layer.cleared, "Apply Write Add Item preserves existing Primary layer cells")

	dock.queue_free()
	await process_frame


func _test_generation_dock_applies_orientation_to_tile_entries() -> void:
	var dock = await _new_ready_dock()

	dock._current_data = HexMapData.from_cells([
		HexVector.zero(),
		HexVector.r_axis().negated(),
	])
	dock._tile_orientation_option.select(1)

	var fake_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_data_to_tile_map_layer(fake_layer), "generation dock applies pointy-top data")
	_assert_eq(fake_layer.calls[0]["map_cell"], Vector2i(0, -1), "pointy-top uses Horizontal Offset map cell")
	_assert_eq(fake_layer.calls[1]["map_cell"], Vector2i.ZERO, "pointy-top keeps origin map cell")

	dock._tile_orientation_option.select(0)
	fake_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_data_to_tile_map_layer(fake_layer), "generation dock applies flat-top data")
	_assert_eq(fake_layer.calls[0]["map_cell"], Vector2i(1, -1), "flat-top uses Vertical Offset map cell")
	_assert_eq(fake_layer.calls[1]["map_cell"], Vector2i.ZERO, "flat-top keeps origin map cell")

	dock.queue_free()
	await process_frame


func _test_generation_dock_resource_stores_orientation() -> void:
	var dock = await _new_ready_dock()

	dock._current_data = HexMapData.rectangle(1, 1)
	dock._tile_orientation_option.select(1)
	var resource = dock.current_resource()

	_assert_eq(resource.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "generation dock saves pointy-top orientation to resource")
	_assert_eq(resource.cells.size(), 1, "generation dock saved resource keeps map data")

	dock.queue_free()
	await process_frame


func _test_generation_dock_configures_tile_map_layer_tileset() -> void:
	var dock = await _new_ready_dock()

	dock._current_data = HexMapData.rectangle(1, 1)
	dock._tile_orientation_option.select(1)
	dock._tile_width_spin.value = 96
	dock._tile_height_spin.value = 84

	var layer = TileMapLayer.new()
	_assert_true(dock.apply_current_data_to_tile_map_layer(layer), "generation dock applies to a TileMapLayer")
	_assert_true(layer.tile_set != null, "generation dock creates a TileSet when configuring TileMapLayer")
	_assert_eq(layer.tile_set.tile_shape, TileSet.TILE_SHAPE_HEXAGON, "generation dock configures TileSet shape")
	_assert_eq(layer.tile_set.tile_layout, TileSet.TILE_LAYOUT_STACKED, "generation dock configures TileSet layout")
	_assert_eq(layer.tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "generation dock maps pointy-top to Horizontal Offset")
	_assert_eq(layer.tile_set.tile_size, Vector2i(96, 84), "generation dock configures TileSet tile size")

	layer.free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_applies_primary_map_to_hex_tile_map_layer() -> void:
	var dock = await _new_ready_dock()

	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	dock._current_data = data
	dock._tile_orientation_option.select(1)
	dock._tile_width_spin.value = HexMapTileAdapter.SAMPLE_TILE_SIZE.x
	dock._tile_height_spin.value = HexMapTileAdapter.SAMPLE_TILE_SIZE.y
	dock._floor_source_spin.value = 4
	dock._floor_atlas_x_spin.value = 0
	dock._floor_atlas_y_spin.value = 0
	dock._wall_source_spin.value = 5
	dock._wall_atlas_x_spin.value = 1
	dock._wall_atlas_y_spin.value = 0
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame

	_assert_true(dock.apply_current_data_to_tile_map_layer(layer), "generation dock applies primary data to HexTileMapLayer")
	_assert_true(layer.hex_map is HexMapResource, "HexTileMapLayer primary apply stores hex_map resource")
	_assert_eq(layer.hex_map.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "HexTileMapLayer primary apply stores orientation")
	_assert_eq(layer.display_used_cell_count(), 2, "HexTileMapLayer primary apply redraws display cells")
	_assert_eq(layer.floor_source_id, 4, "HexTileMapLayer primary apply stores floor source")
	_assert_eq(layer.wall_source_id, 5, "HexTileMapLayer primary apply stores wall source")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i(0, 0), "HexTileMapLayer primary apply uses floor atlas")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.q_axis()), Vector2i(1, 0), "HexTileMapLayer primary apply uses wall atlas")
	var tile_set = layer.display_tile_set()
	_assert_true(tile_set.has_source(4), "HexTileMapLayer primary apply creates floor source")
	_assert_true(tile_set.has_source(5), "HexTileMapLayer primary apply creates wall source")
	_assert_eq(tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "HexTileMapLayer primary apply configures pointy-top axis")

	layer.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_swaps_tile_size_on_orientation_change() -> void:
	var dock = await _new_ready_dock()

	dock._tile_width_spin.value = 80
	dock._tile_height_spin.value = 72
	dock._tile_orientation_option.select(1)
	dock._on_tile_orientation_changed(1)
	_assert_eq(Vector2i(int(dock._tile_width_spin.value), int(dock._tile_height_spin.value)), Vector2i(72, 80), "pointy-top switch swaps tile size controls")

	dock._tile_orientation_option.select(0)
	dock._on_tile_orientation_changed(0)
	_assert_eq(Vector2i(int(dock._tile_width_spin.value), int(dock._tile_height_spin.value)), Vector2i(80, 72), "flat-top switch swaps tile size controls back")

	dock.queue_free()
	await process_frame


func _test_generation_dock_lists_hex_tile_map_layer_common_target() -> void:
	var dock = await _new_ready_dock()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var plain_layer = TileMapLayer.new()
	plain_layer.name = "PlainLayer"
	scene_root.add_child(plain_layer)
	var hex_layer = HexTileMapLayer.new()
	hex_layer.name = "RuntimeMap"
	scene_root.add_child(hex_layer)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.item_count, 4, "generation dock lists Auto, HexTileMapLayer, plain target, and add new layer")
	_assert_eq(dock._tile_layer_option.get_item_text(1), "RuntimeMap (HexTileMapLayer)", "generation dock prioritizes HexTileMapLayer target")
	_assert_eq(dock._tile_layer_option.get_item_text(2), "PlainLayer", "generation dock keeps plain target label for explicit/Overlay use")
	dock._tile_layer_option.select(1)
	_assert_eq(dock.selected_tile_map_layer(), hex_layer, "generation dock returns selected HexTileMapLayer")
	dock._set_editor_selected_tile_map_layer_for_test(hex_layer)
	_assert_eq(dock._find_editor_selected_tile_map_layer(), hex_layer, "generation dock accepts editor-selected HexTileMapLayer")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_lists_and_auto_applies_selected_tile_layer() -> void:
	var dock = await _new_ready_dock()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var first_layer = TileMapLayer.new()
	first_layer.name = "FirstLayer"
	scene_root.add_child(first_layer)
	var second_layer = TileMapLayer.new()
	second_layer.name = "SecondLayer"
	scene_root.add_child(second_layer)
	await process_frame

	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	dock._current_data = data
	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.item_count, 4, "generation dock lists Auto, TileMapLayers, and add new layer")
	_assert_eq(dock._tile_layer_option.get_item_text(0), "Auto: Selected / first scene layer", "generation dock keeps Auto target")
	_assert_eq(dock._tile_layer_option.get_item_text(1), "FirstLayer", "generation dock shows short first TileMapLayer name")
	_assert_eq(dock._tile_layer_option.get_item_text(2), "SecondLayer", "generation dock shows short second TileMapLayer name")
	_assert_eq(dock._tile_layer_option.get_item_text(3), "Add new layer...", "generation dock exposes add new layer target")
	dock._tile_layer_option.select(2)
	_assert_eq(dock.selected_tile_map_layer(), second_layer, "generation dock returns selected TileMapLayer")
	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.get_item_text(0), "Auto: Selected / first scene layer", "generation dock keeps Auto after refresh")
	_assert_eq(dock.selected_tile_map_layer(), second_layer, "generation dock preserves selected TileMapLayer after refresh")

	dock._tile_layer_option.select(1)
	dock._set_editor_selected_tile_map_layer_for_test(second_layer)
	dock._on_sample_tiles_pressed()
	_assert_eq(first_layer.tile_set, null, "sample tile setup ignores Target and does not touch unselected TileMapLayer")
	_assert_true(second_layer.tile_set != null, "sample tile setup uses editor-selected TileMapLayer")
	dock._floor_atlas_x_spin.value = 1
	dock._wall_atlas_x_spin.value = 0

	_assert_eq(first_layer.get_used_cells().size(), 0, "tile setting auto apply ignores Target and does not touch unselected TileMapLayer")
	_assert_eq(second_layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "floor SpinBox change reapplies editor-selected TileMapLayer")
	_assert_eq(second_layer.get_cell_atlas_coords(Vector2i(1, 0)), Vector2i(0, 0), "wall SpinBox change reapplies editor-selected TileMapLayer")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_disambiguates_duplicate_target_names() -> void:
	var dock = await _new_ready_dock()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var group_a = Node2D.new()
	group_a.name = "Terrain"
	scene_root.add_child(group_a)
	var group_b = Node2D.new()
	group_b.name = "Overlay"
	scene_root.add_child(group_b)
	var terrain_layer = TileMapLayer.new()
	terrain_layer.name = "Layer"
	group_a.add_child(terrain_layer)
	var overlay_layer = TileMapLayer.new()
	overlay_layer.name = "Layer"
	group_b.add_child(overlay_layer)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.get_item_text(1), "Terrain/Layer", "duplicate Target names show short scene tree path")
	_assert_eq(dock._tile_layer_option.get_item_text(2), "Overlay/Layer", "duplicate Target names include parent path")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_adds_new_target_layer() -> void:
	var dock = await _new_ready_dock()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.item_count, 2, "empty Target list still shows Auto and add new layer")
	_assert_eq(dock._tile_layer_option.get_item_text(0), "Auto: Selected / first scene layer", "empty Target list keeps Auto")
	_assert_eq(dock._tile_layer_option.get_item_text(1), "Add new layer...", "empty Target list keeps add new layer")

	var add_index = dock._add_tile_layer_option_index()
	dock._tile_layer_option.select(add_index)
	dock._on_tile_layer_target_selected(add_index)
	await process_frame

	var added_layer = dock.selected_tile_map_layer()
	_assert_true(added_layer is HexTileMapLayer, "add new layer creates a HexTileMapLayer")
	_assert_eq(added_layer.get_parent(), scene_root, "add new layer places HexTileMapLayer under scene root")
	_assert_true(String(added_layer.name).begins_with("HexMapLayer"), "add new layer uses HexMapLayer base name")
	_assert_eq(dock._tile_layer_option.selected, 1, "add new layer selects the created Target")
	_assert_eq(dock._find_editor_selected_tile_map_layer(), added_layer, "add new layer selects the created HexTileMapLayer")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_duplicates_shared_tileset_for_selected_layer() -> void:
	var dock = await _new_ready_dock()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var first_layer = TileMapLayer.new()
	first_layer.name = "FirstLayer"
	scene_root.add_child(first_layer)
	var second_layer = TileMapLayer.new()
	second_layer.name = "SecondLayer"
	scene_root.add_child(second_layer)
	await process_frame

	var shared_tile_set = TileSet.new()
	first_layer.tile_set = shared_tile_set
	second_layer.tile_set = shared_tile_set
	dock.refresh_tile_layer_options(scene_root)
	dock._tile_layer_option.select(1)
	dock._set_editor_selected_tile_map_layer_for_test(second_layer)
	dock._current_data = HexMapData.rectangle(1, 1)
	dock._tile_width_spin.value = 96
	await process_frame

	_assert_eq(first_layer.tile_set, shared_tile_set, "tile setting auto apply leaves unselected shared TileSet owner untouched")
	_assert_true(second_layer.tile_set != shared_tile_set, "tile setting auto apply duplicates shared TileSet for selected layer")
	_assert_eq(second_layer.tile_set.tile_size, Vector2i(96, 57), "selected layer receives updated TileSet size")
	_assert_true(first_layer.get_used_cells().is_empty(), "shared TileSet isolation does not apply cells to unselected layer")
	_assert_eq(second_layer.get_used_cells().size(), 1, "shared TileSet isolation still applies cells to selected layer")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_sets_up_sample_tiles() -> void:
	var dock = await _new_ready_dock()

	dock._tile_orientation_option.select(1)
	var layer = TileMapLayer.new()
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(layer), "generation dock configures sample tiles")
	_assert_true(layer.tile_set != null, "sample tile setup creates TileSet")
	_assert_eq(layer.tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "sample tile setup follows dock orientation")
	_assert_eq(layer.tile_set.tile_size, HexMapTileAdapter.SAMPLE_TILE_SIZE, "sample tile setup uses sample tile size")
	_assert_true(layer.tile_set.has_source(0), "sample tile setup creates source 0")
	_assert_eq(Vector2i(int(dock._tile_width_spin.value), int(dock._tile_height_spin.value)), HexMapTileAdapter.SAMPLE_TILE_SIZE, "sample tile setup syncs tile size controls")
	_assert_eq(int(dock._floor_source_spin.value), 0, "sample tile setup sets floor source")
	_assert_eq(Vector2i(int(dock._floor_atlas_x_spin.value), int(dock._floor_atlas_y_spin.value)), Vector2i.ZERO, "sample tile setup sets floor atlas")
	_assert_eq(int(dock._wall_source_spin.value), 0, "sample tile setup sets wall source")
	_assert_eq(Vector2i(int(dock._wall_atlas_x_spin.value), int(dock._wall_atlas_y_spin.value)), Vector2i(1, 0), "sample tile setup sets wall atlas")

	var hex_layer = HexTileMapLayer.new()
	root.add_child(hex_layer)
	await process_frame
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(hex_layer), "generation dock configures sample tiles on HexTileMapLayer")
	var hex_tile_set = hex_layer.display_tile_set()
	_assert_true(hex_tile_set != null, "HexTileMapLayer sample tile setup creates display TileSet")
	_assert_eq(hex_tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "HexTileMapLayer sample tile setup follows dock orientation")
	_assert_true(hex_tile_set.has_source(0), "HexTileMapLayer sample tile setup creates source 0")
	_assert_eq(hex_layer.floor_atlas_coords, Vector2i.ZERO, "HexTileMapLayer sample tile setup stores floor atlas")
	_assert_eq(hex_layer.wall_atlas_coords, Vector2i(1, 0), "HexTileMapLayer sample tile setup stores wall atlas")

	layer.free()
	hex_layer.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_selects_atlas_image() -> void:
	var dock = await _new_ready_dock()

	dock._tile_orientation_option.select(0)
	var layer = TileMapLayer.new()
	_assert_true(
		dock.setup_atlas_tiles_on_tile_map_layer(
			layer,
			HexMapTileAdapter.SAMPLE_TILE_ATLAS_PATH,
			3,
			HexMapTileAdapter.SAMPLE_TILE_SIZE,
			Vector2i(0, 0),
			Vector2i(1, 0)
		),
		"generation dock configures selected atlas image"
	)
	_assert_eq(dock._current_atlas_image_path, HexMapTileAdapter.SAMPLE_TILE_ATLAS_PATH, "generation dock stores selected atlas path")
	_assert_true(layer.tile_set.has_source(3), "selected atlas creates configured source id")
	_assert_eq(layer.tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_VERTICAL, "selected atlas follows flat-top orientation")
	var source = layer.tile_set.get_source(3)
	_assert_true(source is TileSetAtlasSource, "selected atlas source is TileSetAtlasSource")
	_assert_true(source.has_tile(Vector2i(0, 0)), "selected atlas creates floor tile")
	_assert_true(source.has_tile(Vector2i(1, 0)), "selected atlas creates wall tile")
	_assert_eq(int(dock._floor_source_spin.value), 3, "selected atlas syncs floor source")
	_assert_eq(int(dock._wall_source_spin.value), 3, "selected atlas syncs wall source")

	layer.free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_generate_auto_applies_current_map() -> void:
	var dock = await _new_ready_dock()

	_assert_true(dock._apply_layer_button != null, "generation dock keeps Apply Layer button")
	_assert_eq(dock._apply_layer_button.text, "Apply Layer", "generation dock labels manual apply button")
	_assert_true(not _has_button_text(dock, "Generate & Apply"), "generation dock removes Generate & Apply button")

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._refresh_controls()

	_assert_true(await dock._generate_map(), "generation dock regenerates without a target TileMapLayer")
	_assert_eq(dock._current_data.cells.size(), 2, "auto apply generation regenerates current data from controls")
	_assert_eq(dock._current_data.walls.size(), 0, "auto apply generation uses current wall probability")

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var layer = TileMapLayer.new()
	layer.name = "AutoApplyLayer"
	scene_root.add_child(layer)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.item_count, 3, "generation dock lists Auto, auto apply target, and add new layer")
	dock._tile_layer_option.select(1)
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(layer), "auto apply test configures sample tiles")

	var generation_id = dock._generation_id
	dock._on_generate_pressed()
	await _wait_for_progress_controls(dock, "auto apply Generate button generation")
	await _wait_for_generation(dock, "auto apply Generate button generation")
	_assert_eq(dock._generation_id, generation_id + 1, "generation dock auto apply Generate button generation succeeds")
	_assert_eq(layer.get_used_cells().size(), 2, "generation dock auto applies regenerated cells")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i.ZERO, "auto apply writes floor tile atlas")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i(1, 0)), Vector2i.ZERO, "auto apply writes every generated floor cell")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_generate_auto_applies_hex_tile_map_layer() -> void:
	var dock = await _new_ready_dock()

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(0.0)
	dock._refresh_controls()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var layer = HexTileMapLayer.new()
	layer.name = "HexAutoApplyLayer"
	scene_root.add_child(layer)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	_assert_eq(dock._tile_layer_option.item_count, 3, "generation dock lists Auto, HexTileMapLayer target, and add new layer")
	_assert_eq(dock._tile_layer_option.get_item_text(1), "HexAutoApplyLayer (HexTileMapLayer)", "generation dock labels HexTileMapLayer auto apply target")
	dock._tile_layer_option.select(1)

	var generation_id = dock._generation_id
	dock._on_generate_pressed()
	await _wait_for_progress_controls(dock, "HexTileMapLayer auto apply Generate button generation")
	await _wait_for_generation(dock, "HexTileMapLayer auto apply Generate button generation")
	_assert_eq(dock._generation_id, generation_id + 1, "generation dock auto apply HexTileMapLayer generation succeeds")
	_assert_true(layer.hex_map is HexMapResource, "generation dock auto apply stores HexTileMapLayer resource")
	_assert_eq(layer.display_used_cell_count(), 2, "generation dock auto applies regenerated cells to HexTileMapLayer")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i.ZERO, "HexTileMapLayer auto apply writes floor tile atlas")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.q_axis()), Vector2i.ZERO, "HexTileMapLayer auto apply writes every generated floor cell")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_uniform_generation_and_apply() -> void:
	var dock = await _new_ready_dock()

	_assert_eq(dock._generate_button.text, "Primary Generation", "generation dock starts in primary generation mode")
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._refresh_controls()
	_assert_eq(dock._generate_button.text, "Overlay Generation", "overlay mode relabels Generate button")
	_assert_true(dock._overlay_controls_container.visible, "overlay mode shows overlay controls")
	_assert_true(dock._wall_prob_row.visible, "overlay uniform mode keeps placement probability visible")

	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._overlay_item_pool_rows[0]["name"].text = "Tree"
	dock._overlay_item_pool_rows[0]["amount"].value = 1.0
	dock._on_overlay_add_item_pressed()
	dock._overlay_item_pool_rows[1]["name"].text = "Rock"
	dock._overlay_item_pool_rows[1]["amount"].value = 0.0
	dock._refresh_controls()

	var data = HexMapData.rectangle(2, 2)
	data.set_walls([HexVector.q_axis()])
	dock.register_mapdata_source(HexMapResource.from_map_data(data), "res://overlay_basic.tres")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, dock._mapdata_sources[0]["id"], "Floor")
	dock._refresh_controls()

	var scene_root = Node2D.new()
	scene_root.name = "SceneRoot"
	root.add_child(scene_root)
	var layer = TileMapLayer.new()
	layer.name = "OverlayLayer"
	scene_root.add_child(layer)
	await process_frame

	dock.refresh_tile_layer_options(scene_root)
	dock._tile_layer_option.select(1)
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(layer), "overlay apply test configures sample tiles")

	_assert_true(dock._current_data == null, "overlay generation does not require current primary data")
	_assert_true(dock._apply_write_policy_option.visible, "Apply Write remains visible in Overlay mode")
	_assert_true(await dock._generate_map(), "generation dock generates overlay data")
	_assert_true(dock._current_overlay_data != null, "overlay generation stores current overlay data")
	_assert_eq(dock._current_overlay_data.item_cells("Tree").size(), data.floor_cells().size(), "overlay uniform generation uses primary floor cells as candidates")
	_assert_eq(dock._current_overlay_data.item_cells("Rock").size(), 0, "overlay uniform generation honors item weights")
	_assert_eq(layer.get_used_cells().size(), data.floor_cells().size(), "overlay generation auto applies overlay cells to Target")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "overlay apply uses Wall atlas controls as item tile")
	_assert_true(dock.current_resource() is HexOverlayResource, "overlay mode saves current overlay resource")

	scene_root.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_applies_to_hex_tile_map_layer() -> void:
	var dock = await _new_ready_dock()
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_item_pool_rows[0]["name"].text = "Tree"
	dock._overlay_item_pool_rows[0]["tile_source"].value = 0
	dock._overlay_item_pool_rows[0]["tile_atlas_x"].value = 1
	dock._overlay_item_pool_rows[0]["tile_atlas_y"].value = 0
	dock._refresh_controls()
	var data = HexMapData.rectangle(2, 1)
	dock._current_overlay_data = HexOverlayData.from_item_cells(data.cells, "Tree", data.cells)
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(data))

	_assert_true(dock.apply_current_overlay_data_to_tile_map_layer(layer), "generation dock applies overlay data to HexTileMapLayer")
	var origin_map_cell = HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true)
	_assert_eq(layer._overlay_tile_map.get_cell_atlas_coords(origin_map_cell), Vector2i(1, 0), "HexTileMapLayer overlay apply writes overlay atlas")
	var state = layer.display_state_for_hex(HexVector.zero())
	_assert_eq(state["overlay_count"], 1, "HexTileMapLayer overlay apply exposes overlay state")
	var snapshot = layer.to_document_resource()
	_assert_eq(snapshot.tile_overrides.size(), 2, "HexTileMapLayer overlay apply exports overlay entries")
	_assert_eq(snapshot.tile_overrides[0]["kind"], HexMapDocumentAdapter.KIND_OVERLAY, "HexTileMapLayer overlay snapshot stores overlay kind")

	layer.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_limit_and_apply_policy() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._overlay_item_pool_rows[0]["name"].text = "Coin"
	dock._overlay_item_limit_check.set_pressed_no_signal(true)
	dock._overlay_item_pool_rows[0]["amount"].value = 2
	dock._on_overlay_add_item_pressed()
	dock._overlay_item_pool_rows[1]["name"].text = "Gem"
	dock._overlay_item_pool_rows[1]["amount"].value = 1
	var data = HexMapData.rectangle(4, 1)
	dock.register_mapdata_source(HexMapResource.from_map_data(data), "res://overlay_limit.tres")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, dock._mapdata_sources[0]["id"], "Floor")
	dock._refresh_controls()

	_assert_eq(dock._overlay_item_pool_rows[0]["amount_label"].text, "Limit", "overlay limited uniform mode shows item limits")
	_assert_true(not dock._wall_prob_row.visible, "overlay limited uniform mode hides placement probability")
	_assert_true(await dock._generate_map(), "generation dock generates limited overlay data")
	_assert_eq(dock._current_overlay_data.item_cells("Coin").size(), 2, "overlay limited generation places requested item count")
	_assert_eq(dock._current_overlay_data.item_cells("Gem").size(), 1, "overlay limited generation supports multiple item limits")

	dock._overlay_item_pool_rows[0]["name"].text = "Key"
	dock._overlay_item_pool_rows[0]["amount"].value = 1
	dock._overlay_item_pool_rows[1]["amount"].value = 0
	dock._apply_write_policy_option.select(1)
	_assert_true(await dock._generate_map(), "generation dock merges overlay data with Add Item policy")
	_assert_eq(dock._current_overlay_data.item_cells("Coin").size(), 2, "overlay Add Item policy preserves existing item data")
	_assert_eq(dock._current_overlay_data.item_cells("Gem").size(), 1, "overlay Add Item policy preserves existing second item data")
	_assert_eq(dock._current_overlay_data.item_cells("Key").size(), 1, "overlay Add Item policy adds generated item data")

	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_placement_mask_filters_candidates() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._overlay_item_pool_rows[0]["name"].text = "Moss"
	dock._overlay_item_pool_rows[0]["amount"].value = 1.0
	var data = HexMapData.rectangle(3, 1)
	data.set_walls([HexVector.q_axis()])
	var source_id = dock.register_mapdata_source(HexMapResource.from_map_data(data), "res://mask_data.tres")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Wall")
	dock._refresh_controls()

	_assert_true(await dock._generate_map(), "generation dock generates overlay from placement mask")
	_assert_eq(dock._current_overlay_data.item_cells("Moss").size(), 1, "placement mask restricts overlay candidates to selected primary item")
	_assert_eq(dock._current_overlay_data.item_cells("Moss")[0].key(), HexVector.q_axis().key(), "placement mask item is generated on the selected wall cell")

	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_adjacency_reference_generation() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_adjacency_check.set_pressed_no_signal(true)
	dock._on_overlay_adjacency_toggled(true)
	dock._overlay_item_name_edit.text = "NearWall"
	dock._overlay_neighbor_radius_spin.value = 1
	dock._overlay_adjacency_rules_edit.text = "1=1.0;default=0.0"
	var data = HexMapData.hexagon(1)
	data.set_walls([HexVector.q_axis()])
	var source_id = dock.register_mapdata_source(HexMapResource.from_map_data(data), "res://adjacency_data.tres")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Floor")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_REFERENCE, source_id, "Wall")
	dock._refresh_controls()

	_assert_eq(dock._generate_option.selected, HexMapGenDock.GENERATE_SYMMETRIC, "adjacency reference switches overlay generation to Markov Mesh")
	_assert_true(dock._overlay_reference_container.visible, "adjacency reference shows reference controls")
	_assert_true(await dock._generate_map(), "generation dock generates adjacency overlay")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "NearWall"), "adjacency reference generates item next to reference cell")
	_assert_true(not dock._current_overlay_data.has_item(HexVector.apply_basis(-1, 1, 0), "NearWall"), "adjacency reference leaves cells without matching neighbor rule empty")

	dock.queue_free()
	await process_frame


func _test_generation_dock_adjacency_generated_reference_snapshot() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_adjacency_check.set_pressed_no_signal(true)
	dock._on_overlay_adjacency_toggled(true)
	dock._refresh_controls()

	_assert_true(dock._overlay_generated_reference_check.visible, "Generated Item Reference control is visible for adjacency overlay")
	var static_snapshot = dock._create_generation_snapshot()
	_assert_true(
		not bool(static_snapshot.get("overlay_generated_reference_enabled", true)),
		"Generated Item Reference is disabled in snapshot by default"
	)

	dock._overlay_generated_reference_check.set_pressed_no_signal(true)
	var dynamic_snapshot = dock._create_generation_snapshot()
	_assert_true(
		bool(dynamic_snapshot.get("overlay_generated_reference_enabled", false)),
		"Generated Item Reference checkbox is reflected in generation snapshot"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_adjacency_generated_reference_changes_result() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_adjacency_check.set_pressed_no_signal(true)
	dock._on_overlay_adjacency_toggled(true)
	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._gen_radius_spin.set_value_no_signal(1)
	dock._overlay_item_name_edit.text = "Vine"
	dock._overlay_neighbor_radius_spin.value = 1
	dock._overlay_adjacency_rules_edit.text = "1=1.0;default=0.0"
	var first_candidate = HexVector.q_axis()
	var second_candidate = HexVector.q_axis().scaled(2)
	var source_data = HexOverlayData.from_cells(
		HexMapData.square(3, false).cells,
		{
			"Candidate": [first_candidate, second_candidate],
			"Seed": [HexVector.zero()],
		}
	)
	var source_id = dock.register_mapdata_source(
		HexOverlayResource.from_overlay_data(source_data),
		"res://generated_reference.tres"
	)
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Candidate")
	dock._add_query_row(HexMapGenDock.QUERY_KIND_REFERENCE, source_id, "Seed")
	dock._refresh_controls()

	var static_snapshot = dock._create_generation_snapshot()
	var static_data = dock._generate_overlay_data_from_snapshot(static_snapshot, {})
	_assert_keys_eq(
		static_data.item_cells("Vine"),
		[first_candidate],
		"adjacency snapshot without Generated Item Reference keeps generated items out of reference stats"
	)

	dock._overlay_generated_reference_check.set_pressed_no_signal(true)
	var dynamic_snapshot = dock._create_generation_snapshot()
	var dynamic_data = dock._generate_overlay_data_from_snapshot(dynamic_snapshot, {})
	_assert_keys_eq(
		dynamic_data.item_cells("Vine"),
		[first_candidate, second_candidate],
		"adjacency snapshot with Generated Item Reference uses generated target items as later references"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_item_pool_tile_mapping() -> void:
	var dock = await _new_ready_dock()

	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._overlay_item_pool_rows[0]["name"].text = "Tree"
	dock._overlay_item_pool_rows[0]["tile_atlas_x"].value = 0
	dock._overlay_item_pool_rows[0]["tile_atlas_y"].value = 0
	dock._floor_source_spin.set_value_no_signal(0)
	dock._floor_atlas_x_spin.set_value_no_signal(0)
	dock._floor_atlas_y_spin.set_value_no_signal(0)
	dock._on_overlay_item_tile_copy_pressed(dock._overlay_item_pool_rows[0], false)
	_assert_eq(dock._overlay_item_pool_rows[0]["tile_source"].value, 0.0, "item pool copies Floor tile source")
	_assert_eq(dock._overlay_item_pool_rows[0]["tile_atlas_x"].value, 0.0, "item pool copies Floor tile atlas x")
	_assert_eq(dock._overlay_item_pool_rows[0]["tile_atlas_y"].value, 0.0, "item pool copies Floor tile atlas y")
	dock._on_overlay_add_item_pressed()
	dock._overlay_item_pool_rows[1]["name"].text = "Rock"
	dock._wall_source_spin.set_value_no_signal(0)
	dock._wall_atlas_x_spin.set_value_no_signal(1)
	dock._wall_atlas_y_spin.set_value_no_signal(0)
	dock._on_overlay_item_tile_copy_pressed(dock._overlay_item_pool_rows[1], true)
	_assert_eq(dock._overlay_item_pool_rows[1]["tile_source"].value, 0.0, "item pool copies Wall tile source")
	_assert_eq(dock._overlay_item_pool_rows[1]["tile_atlas_x"].value, 1.0, "item pool copies Wall tile atlas x")
	_assert_eq(dock._overlay_item_pool_rows[1]["tile_atlas_y"].value, 0.0, "item pool copies Wall tile atlas y")
	_assert_eq(dock._overlay_item_pool_rows[1]["copy_floor"].text, "Floor Tile", "item pool exposes Floor tile copy button")
	_assert_eq(dock._overlay_item_pool_rows[1]["copy_wall"].text, "Wall Tile", "item pool exposes Wall tile copy button")
	dock._current_overlay_data = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{
			"Tree": [HexVector.zero()],
			"Rock": [HexVector.q_axis()],
		}
	)

	var layer = TileMapLayer.new()
	_assert_true(dock.setup_sample_tiles_on_tile_map_layer(layer), "overlay tile mapping test configures sample tiles")
	_assert_true(dock.apply_current_overlay_data_to_tile_map_layer(layer), "overlay tile mapping applies current overlay data")
	_assert_eq(layer.get_cell_source_id(Vector2i.ZERO), 0, "overlay item pool maps Tree to copied source")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(0, 0), "overlay item pool maps Tree to copied Floor tile")
	_assert_eq(layer.get_cell_source_id(Vector2i(1, 0)), 0, "overlay item pool maps Rock to copied source")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i(1, 0)), Vector2i(1, 0), "overlay item pool maps Rock to copied Wall tile")

	var replacing_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_overlay_data_to_tile_map_layer(replacing_layer), "overlay apply clears with Clear And Write")
	_assert_true(replacing_layer.cleared, "Apply Write Clear And Write clears existing Overlay layer cells")

	dock._apply_write_policy_option.select(1)
	var fake_overlay_layer = FakeTileLayer.new()
	_assert_true(dock.apply_current_overlay_data_to_tile_map_layer(fake_overlay_layer), "overlay apply works without clearing")
	_assert_true(not fake_overlay_layer.cleared, "Apply Write Add Item preserves existing Overlay layer cells")

	layer.free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_mapdata_source_registry_load_reload_clear() -> void:
	var dock = await _new_ready_dock()
	var path = _test_resource_path("test_mapdata_source_overlay.tres")
	var overlay = HexOverlayData.from_cells(
		[HexVector.zero()],
		{"Tree": [HexVector.zero()]}
	)
	_save_resource(path, HexOverlayResource.from_overlay_data(overlay))

	var source_id = dock.load_mapdata_source(path)
	_assert_true(source_id > 0, "source registry loads HexOverlayResource")
	_assert_eq(dock._mapdata_sources.size(), 1, "source registry stores loaded source")
	_assert_eq(dock._mapdata_sources[0]["resource_type"], HexMapGenDock.MAPDATA_SOURCE_OVERLAY, "source registry records overlay type")
	_assert_eq(dock._mapdata_sources[0]["item_keys"], ["Tree"], "source registry exposes overlay item keys")
	_assert_true(
		dock._source_entry_details_text(dock._mapdata_sources[0]).contains("Tree: 1"),
		"source registry details show overlay item cell count"
	)
	_assert_true(
		dock._source_entry_details_text(dock._mapdata_sources[0]).contains(path),
		"source registry details show resource path"
	)

	var reloaded = HexOverlayData.from_cells(
		[HexVector.zero()],
		{"Rock": [HexVector.zero()]}
	)
	_save_resource(path, HexOverlayResource.from_overlay_data(reloaded))
	var reloaded_id = dock.load_mapdata_source(path)
	_assert_eq(reloaded_id, source_id, "same source path reloads existing entry")
	_assert_eq(dock._mapdata_sources.size(), 1, "same source path does not add duplicate")
	_assert_eq(dock._mapdata_sources[0]["item_keys"], ["Rock"], "reload updates item keys")

	var map_data = HexMapData.rectangle(2, 1)
	map_data.set_walls([HexVector.q_axis()])
	var map_id = dock.register_mapdata_source(HexMapResource.from_map_data(map_data), "res://source_registry_map.tres")
	var map_entry = dock._source_entry_by_id(map_id)
	var map_details = dock._source_entry_details_text(map_entry)
	_assert_true(map_details.contains("Any: 2"), "source registry details show primary Any count")
	_assert_true(map_details.contains("Floor: 1"), "source registry details show primary Floor count")
	_assert_true(map_details.contains("Wall: 1"), "source registry details show primary Wall count")

	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Rock")
	_assert_eq(dock._overlay_mask_query_rows.size(), 1, "query row references loaded source")
	dock.clear_mapdata_source(source_id)
	_assert_eq(dock._mapdata_sources.size(), 1, "clear removes only selected source")
	_assert_eq(dock._overlay_mask_query_rows.size(), 0, "clear removes query rows using source")
	_assert_true(dock._source_registry_status_label.text.contains("Sources: 1"), "source registry status shows remaining source count")
	dock.clear_mapdata_source(map_id)
	_assert_eq(dock._mapdata_sources.size(), 0, "clear removes all sources")
	_assert_eq(dock._source_registry_status_label.text, "No mapdata sources loaded.", "source registry status shows empty state")

	dock.queue_free()
	await process_frame


func _test_generation_dock_path_action_labels_and_failure_status() -> void:
	var dock = await _new_ready_dock()
	_assert_eq(dock._source_load_button.text, "Browse .tres", "source registry uses browse wording")
	_assert_eq(dock._generate_history_dir_button.text, "History Dir", "generate history uses directory wording")
	_assert_eq(dock._save_button.text, "Save As .tres", "generation save uses save-as wording")
	_assert_eq(dock._atlas_image_button.text, "Browse Atlas Image", "atlas image uses browse wording")

	dock._on_source_file_selected(_test_resource_path("missing_source_registry_resource.tres"))
	_assert_true(
		dock._source_registry_status_label.text.contains("Failed to load mapdata source"),
		"source registry file selection failure appears in status"
	)
	dock._generate_history_check.set_pressed_no_signal(true)
	dock._generate_history_dir = ""
	dock._refresh_generate_history_label()
	_assert_eq(dock._generate_history_dir_label.text, "History: choose directory", "history enabled without dir asks for directory")

	dock.queue_free()
	await process_frame


func _test_generation_dock_mapdata_query_rows_evaluate_offset_and_toric() -> void:
	var dock = await _new_ready_dock()
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(3)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._refresh_controls()
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		HexMapData.rectangle(3, 1).cells,
		"zero Mask Query Rows pass the full shape universe"
	)
	var map_data = HexMapData.rectangle(3, 1)
	map_data.set_walls([HexVector.q_axis()])
	var map_id = dock.register_mapdata_source(HexMapResource.from_map_data(map_data), "res://map_query.tres")
	_assert_eq(dock._overlay_mask_add_source_option.get_item_text(0), "map_query.tres", "query add source option is scoped to resource name")
	_assert_eq(dock._overlay_mask_add_source_option.get_popup().max_size.y, 260, "query add source option popup is height-limited for scrolling")

	var floor_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, map_id, "Floor")
	_assert_true(floor_row["row"] is VBoxContainer, "query row uses two-line container")
	_assert_eq(floor_row["source_label"].text, "map_query.tres", "query row shows resource name as a label")
	_assert_eq(floor_row["source_item"].get_item_text(floor_row["source_item"].selected), "Floor", "query row item combo is scoped to item key")
	_assert_eq(floor_row["source_item"].item_count, 3, "query row item combo lists only selected resource items")
	_assert_eq(floor_row["source_item"].get_popup().max_size.y, 260, "query row item combo popup is height-limited for scrolling")
	_assert_true(floor_row["offset_panel"] is HexCellButtonPanel, "query row has common hex cell offset panel")
	_assert_eq(floor_row["offset_panel"].get_entries().size(), 7, "query row offset panel lays out center and six direction cells")
	_assert_eq(_pressable_entry_count(floor_row["offset_panel"].get_entries()), 6, "query row offset panel exposes six pressable directions")
	var center_entry: Dictionary = _entries_by_id(floor_row["offset_panel"].get_entries())[HexVector.zero().key()]
	_send_panel_motion(floor_row["offset_panel"], center_entry["center"])
	_assert_true(floor_row["offset_panel"].tooltip_text.contains("Current offset"), "query row center cell shows current offset tooltip")
	var wall_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, map_id, "Wall")
	wall_row["operation"].select(1)
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		map_data.cells,
		"query rows OR selected item cells"
	)

	wall_row["operation"].select(0)
	wall_row["match"].select(1)
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		map_data.floor_cells(),
		"query rows apply Exclude as universe complement with AND"
	)

	dock._overlay_mask_query_rows.clear()
	dock._rect_width_spin.set_value_no_signal(1)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._refresh_controls()
	var outside_overlay = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{"Outside": [HexVector.q_axis()], "Inside": [HexVector.zero()]}
	)
	var outside_id = dock.register_mapdata_source(HexOverlayResource.from_overlay_data(outside_overlay), "res://outside_query.tres")
	var outside_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, outside_id, "Outside")
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		[],
		"mask query Crop Off clips Contain cells to current shape universe"
	)
	outside_row["match"].select(1)
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		[HexVector.zero()],
		"mask query Crop Off uses current shape universe for Exclude complement"
	)

	dock._overlay_mask_query_rows.clear()
	var shifted_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, outside_id, "Inside")
	_press_query_row_direction(shifted_row, 0)
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_MASK),
		[],
		"mask query Crop Off clips offset results outside current shape universe"
	)
	dock._current_data = HexMapData.rectangle(2, 1)
	var snapshot = dock._create_generation_snapshot()
	_assert_keys_eq(
		snapshot["overlay_candidate_cells"],
		[],
		"empty Mask query does not fallback to current Primary floor cells"
	)
	_assert_true(dock._generate_button.disabled, "empty Mask query disables Generate")
	_assert_true(not await dock._generate_map(), "empty Mask query does not start generation")
	_assert_eq(
		dock.generation_status()["status"],
		HexMapGenDock.GENERATION_BLOCK_STATUS_PREFIX + HexMapGenDock.GENERATION_BLOCK_EMPTY_MASK,
		"empty Mask query block reason is visible"
	)

	var overlay = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{"Gem": [HexVector.zero()]}
	)
	var overlay_id = dock.register_mapdata_source(HexOverlayResource.from_overlay_data(overlay), "res://offset_query.tres")
	dock._overlay_reference_query_rows.clear()
	dock._rect_width_spin.set_value_no_signal(2)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._refresh_controls()
	var offset_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_REFERENCE, overlay_id, "Gem")
	var offset_panel: HexCellButtonPanel = offset_row["offset_panel"]
	dock._on_query_cell_radius_changed(18.0)
	dock._on_query_cell_gap_changed(3.0)
	dock._on_query_cell_padding_changed(5.0)
	_assert_eq(offset_panel.cell_radius, 18.0, "query offset panel radius is adjustable")
	_assert_eq(offset_panel.cell_gap, 3.0, "query offset panel gap is adjustable")
	_assert_eq(offset_panel.padding, Vector2(5, 5), "query offset panel padding is adjustable")
	_assert_eq(dock._query_cell_radius_spin.value, 18.0, "query cell radius syncs shared control")
	_assert_eq(dock._query_cell_gap_spin.value, 3.0, "query cell gap syncs shared control")
	_assert_eq(dock._query_cell_padding_spin.value, 5.0, "query cell padding syncs shared control")
	var q_entry: Dictionary = _entries_by_id(offset_panel.get_entries())[HexVector.q_axis().key()]
	_send_panel_click(offset_panel, q_entry["center"])
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_REFERENCE),
		[HexVector.q_axis()],
		"query rows offset item cells"
	)
	dock._set_generation_controls_disabled(true)
	_assert_true(not offset_panel.enabled, "generation disable state disables query offset panel")
	dock._set_generation_controls_disabled(false)
	_assert_true(offset_panel.enabled, "generation enable state re-enables query offset panel")

	var toric_data = HexOverlayData.from_cells(
		HexMapData.square(3, true).cells,
		{"Wrap": [HexVector.apply_basis(2, 0, 0)]},
		3
	)
	var toric_id = dock.register_mapdata_source(HexOverlayResource.from_overlay_data(toric_data), "res://toric_query.tres")
	dock._overlay_reference_query_rows.clear()
	var toric_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_REFERENCE, toric_id, "Wrap")
	_press_query_row_direction(toric_row, 0)
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_REFERENCE),
		[HexVector.zero()],
		"query rows wrap offset cells for toric source"
	)
	dock._rect_width_spin.set_value_no_signal(5)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._refresh_controls()
	_assert_keys_eq(
		dock._evaluate_query_rows(HexMapGenDock.QUERY_KIND_REFERENCE),
		[HexVector.zero(), HexVector.apply_basis(3, 0, 0)],
		"toric source query expands all matching representatives inside the shape universe"
	)

	dock._overlay_mask_query_rows.clear()
	var toric_mask_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, toric_id, "Wrap")
	_press_query_row_direction(toric_mask_row, 0)
	var crop_data = dock._overlay_crop_result_data()
	_assert_keys_eq(
		crop_data.item_cells(dock._crop_result_item_key(toric_mask_row)),
		[HexVector.zero(), HexVector.apply_basis(3, 0, 0)],
		"Crop result stores all toric source representatives inside the shape universe"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_overlay_deductor_floor_source_query() -> void:
	var dock = await _new_ready_dock()
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SYMMETRIC)
	dock._shape_option_symmetric.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._gen_radius_spin.set_value_no_signal(1)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._connect_method_option.select(_connect_method_index(HexMapGenerator.CONNECT_DENSE))
	dock._refresh_controls()
	_assert_true(dock._overlay_deductor_floor_container.visible, "deductor floor source is visible for Markov Mesh overlay")

	dock._overlay_adjacency_check.set_pressed_no_signal(true)
	dock._refresh_controls()
	_assert_true(not dock._overlay_deductor_floor_container.visible, "deductor floor source hides for adjacency overlay")
	dock._overlay_adjacency_check.set_pressed_no_signal(false)
	dock._refresh_controls()

	var candidate_source = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{"Candidate": [HexVector.q_axis()]}
	)
	var candidate_id = dock.register_mapdata_source(
		HexOverlayResource.from_overlay_data(candidate_source),
		"res://deductor_candidate.tres"
	)
	dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, candidate_id, "Candidate")

	var default_snapshot = dock._create_generation_snapshot()
	_assert_keys_eq(
		default_snapshot["overlay_candidate_cells"],
		[HexVector.q_axis()],
		"deductor floor test uses placement mask candidate"
	)
	_assert_keys_eq(
		default_snapshot["overlay_deductor_floor_cells"],
		[],
		"deductor floor default is resolved after generation"
	)
	_assert_eq(
		default_snapshot["overlay_deductor_floor_source_enabled"],
		false,
		"deductor floor snapshot records missing source rows"
	)
	_assert_eq(
		dock._overlay_deductor_floor_status_label.text,
		"Default: generated complement",
		"deductor floor default status describes generated complement"
	)
	var default_generated = dock._generate_overlay_data_from_snapshot(default_snapshot, {})
	_assert_true(
		default_generated.has_item(HexVector.q_axis(), "Item1"),
		"deductor floor default uses generated complement instead of placement candidates"
	)

	var floor_source = HexMapData.rectangle(1, 1)
	var floor_id = dock.register_mapdata_source(
		HexMapResource.from_map_data(floor_source),
		"res://deductor_floor.tres"
	)
	dock._overlay_mask_crop_check.set_pressed_no_signal(true)
	var floor_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_DEDUCTOR_FLOOR, floor_id, "Floor")
	_assert_true(dock._overlay_mask_crop_check.button_pressed, "deductor floor query edit does not turn Crop off")
	var custom_snapshot = dock._create_generation_snapshot()
	_assert_keys_eq(
		custom_snapshot["overlay_candidate_cells"],
		[HexVector.q_axis()],
		"deductor floor source keeps placement mask candidates separate"
	)
	_assert_keys_eq(
		custom_snapshot["overlay_deductor_floor_cells"],
		[HexVector.zero()],
		"deductor floor source overrides connectivity floor cells"
	)
	_assert_true(
		dock._overlay_deductor_floor_status_label.text.contains("Deductor floor cells: 1"),
		"deductor floor source shows resolved cell count"
	)

	var generated = dock._generate_overlay_data_from_snapshot(custom_snapshot, {})
	_assert_true(
		generated.has_item(HexVector.q_axis(), "Item1"),
		"deductor floor source can differ from candidates during generation"
	)

	dock._on_query_row_remove_pressed(floor_row, HexMapGenDock.QUERY_KIND_DEDUCTOR_FLOOR)
	dock._gen_radius_spin.set_value_no_signal(0)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.set_value_no_signal(1)
	dock._rect_height_spin.set_value_no_signal(1)
	dock._refresh_controls()
	var empty_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_DEDUCTOR_FLOOR, floor_id, "Any")
	empty_row["match"].select(1)
	var empty_snapshot = dock._create_generation_snapshot()
	_assert_keys_eq(
		empty_snapshot["overlay_deductor_floor_cells"],
		[],
		"empty deductor floor query stays empty"
	)
	_assert_eq(
		dock._overlay_deductor_floor_status_label.text,
		"Deductor Floor Source query result is empty.",
		"empty deductor floor query shows status warning"
	)

	dock.queue_free()
	await process_frame


func _test_generation_dock_mapdata_crop_result_and_reset_rules() -> void:
	var dock = await _new_ready_dock()
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._rect_width_spin.value = 1
	dock._rect_height_spin.value = 1
	dock._refresh_controls()

	var overlay = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{
			"Tree": [HexVector.zero()],
			"Rock": [HexVector.q_axis()],
		}
	)
	var source_id = dock.register_mapdata_source(HexOverlayResource.from_overlay_data(overlay), "res://crop_query.tres")
	var contain_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Tree")
	var exclude_row = dock._add_query_row(HexMapGenDock.QUERY_KIND_MASK, source_id, "Rock")
	exclude_row["operation"].select(1)
	exclude_row["match"].select(1)
	dock._overlay_mask_crop_check.set_pressed_no_signal(true)
	dock._refresh_mask_crop_count()

	var crop = dock._overlay_crop_result_data()
	_assert_keys_eq(crop.cells, [HexVector.zero()], "crop result uses current shape universe")
	_assert_keys_eq(crop.item_cells("Any"), [HexVector.zero()], "crop result stores Any universe")
	_assert_keys_eq(crop.item_cells("crop_query.tres / Tree"), [HexVector.zero()], "crop result stores prefixed contain item")
	_assert_eq(crop.item_cells("crop_query.tres / Rock").size(), 0, "crop result excludes Exclude item output")
	_assert_eq(dock._overlay_mask_count_label.text, "Cells: 1", "crop count ignores Any and duplicate cells")

	var crop_item_key = dock._crop_result_item_key(contain_row)
	var crop_layer = FakeTileLayer.new()
	_assert_true(dock._apply_crop_result_to_tile_map_layer(crop_layer), "crop result applies with Clear And Write")
	_assert_true(crop_layer.cleared, "crop result Clear And Write clears target layer")
	_assert_keys_eq(dock._current_overlay_data.item_cells(crop_item_key), [HexVector.zero()], "crop result Clear And Write replaces current overlay")

	dock._current_overlay_data = HexOverlayData.from_cells([HexVector.zero()], {"Old": [HexVector.zero()]})
	dock._apply_write_policy_option.select(1)
	var crop_add_layer = FakeTileLayer.new()
	_assert_true(dock._apply_crop_result_to_tile_map_layer(crop_add_layer), "crop result applies with Add Item")
	_assert_true(not crop_add_layer.cleared, "crop result Add Item preserves target layer cells")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "Old"), "crop result Add Item preserves current overlay item")
	_assert_keys_eq(dock._current_overlay_data.item_cells(crop_item_key), [HexVector.zero()], "crop result Add Item merges crop item")

	_press_query_row_direction(dock._overlay_mask_query_rows[0], 0)
	_assert_true(not dock._overlay_mask_crop_check.button_pressed, "mask query edit turns Crop off")
	dock._overlay_mask_crop_check.set_pressed_no_signal(true)
	dock._on_shape_size_changed(2)
	_assert_true(not dock._overlay_mask_crop_check.button_pressed, "shape size edit turns Crop off")
	dock._overlay_mask_crop_check.set_pressed_no_signal(true)
	dock._add_query_row(HexMapGenDock.QUERY_KIND_REFERENCE, source_id, "Tree")
	_assert_true(dock._overlay_mask_crop_check.button_pressed, "reference query edit does not turn Crop off")

	dock.queue_free()
	await process_frame


func _test_generation_dock_mapdata_crop_off_stacks_overlay_sources() -> void:
	var dock = await _new_ready_dock()
	dock._overlay_mode_check.set_pressed_no_signal(true)
	var primary = HexMapData.rectangle(1, 1)
	dock.register_mapdata_source(HexMapResource.from_map_data(primary), "res://stack_primary.tres")
	var first = HexOverlayData.from_cells(
		[HexVector.zero()],
		{"Tree": [HexVector.zero()]}
	)
	var second = HexOverlayData.from_cells(
		[HexVector.zero(), HexVector.q_axis()],
		{"Rock": [HexVector.zero()], "Gem": [HexVector.q_axis()]}
	)
	dock.register_mapdata_source(HexOverlayResource.from_overlay_data(first), "res://stack_first.tres")
	dock.register_mapdata_source(HexOverlayResource.from_overlay_data(second), "res://stack_second.tres")
	dock._overlay_existing_policy_option.select(1)
	dock._current_overlay_data = HexOverlayData.from_cells([HexVector.zero()], {"Old": [HexVector.zero()]})

	_assert_true(dock._apply_overlay_source_stack_to_current(), "crop off stack applies overlay sources")
	_assert_true(dock._source_registry_status_label.text.contains("Stacked 2 overlay source(s)"), "crop off stack status shows source count")
	_assert_true(dock._source_registry_status_label.text.contains("occupied=2"), "crop off stack status shows occupied count")
	_assert_true(dock._source_registry_status_label.text.contains(HexOverlayData.APPLY_CLEAR_AND_WRITE), "crop off stack status shows Clear And Write policy")
	_assert_eq(dock._current_overlay_data.item_cells("Tree").size(), 0, "replace existing removes earlier item on same cell")
	_assert_eq(dock._current_overlay_data.item_cells("Old").size(), 0, "Clear And Write policy replaces existing current overlay")
	_assert_keys_eq(dock._current_overlay_data.item_cells("Rock"), [HexVector.zero()], "stack keeps later replacement item")
	_assert_keys_eq(dock._current_overlay_data.item_cells("Gem"), [HexVector.q_axis()], "stack preserves non-conflicting later item")
	_assert_eq(dock._current_overlay_data.item_cells("Floor").size(), 0, "stack ignores Primary source")

	dock._current_overlay_data = HexOverlayData.from_cells([HexVector.zero()], {"Old": [HexVector.zero()]})
	dock._apply_write_policy_option.select(1)
	dock._overlay_existing_policy_option.select(0)
	_assert_true(dock._apply_overlay_source_stack_to_current(), "Add Item write policy merges stack into current overlay")
	_assert_true(dock._source_registry_status_label.text.contains(HexOverlayData.APPLY_ADD_ITEM), "crop off stack status shows Add Item policy")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "Old"), "Add Item write policy preserves existing current item")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "Tree"), "Add Item write policy adds stacked source item")

	var empty_dock = await _new_ready_dock()
	empty_dock._overlay_mode_check.set_pressed_no_signal(true)
	_assert_true(not empty_dock._apply_overlay_source_stack_to_current(), "empty overlay source stack does not update current overlay")
	_assert_eq(
		empty_dock._source_registry_status_label.text,
		"No HexOverlayData source found in Source Registry.",
		"empty overlay source stack shows status reason"
	)

	empty_dock.queue_free()
	dock.queue_free()
	await process_frame


func _test_generation_dock_generate_history_saves_overlay_delta_source() -> void:
	var dock = await _new_ready_dock()
	var history_dir = _test_resource_dir("mapdata_history")
	dock._set_generate_history_directory_for_test(history_dir)
	dock._overlay_mode_check.set_pressed_no_signal(true)
	dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	dock._wall_prob_slider.set_value_no_signal(1.0)
	dock._overlay_item_limit_check.set_pressed_no_signal(true)
	dock._overlay_item_pool_rows[0]["name"].text = "Key"
	dock._overlay_item_pool_rows[0]["amount"].value = 1.0
	dock._apply_write_policy_option.select(1)
	dock._current_data = HexMapData.rectangle(1, 1)
	dock._current_overlay_data = HexOverlayData.from_cells(
		[HexVector.zero()],
		{"Old": [HexVector.zero()]}
	)
	dock._refresh_controls()

	var before_count = dock._mapdata_sources.size()
	_assert_true(await dock._generate_map(), "generate history test generates overlay")
	_assert_eq(dock._mapdata_sources.size(), before_count + 1, "generate history adds saved source")
	var source = dock._mapdata_sources[dock._mapdata_sources.size() - 1]
	var saved_data = source["data"]
	_assert_eq(source["resource_type"], HexMapGenDock.MAPDATA_SOURCE_OVERLAY, "generate history registers overlay source")
	_assert_true(String(source["resource_path"]).contains("overlay-combination-key"), "generate history uses combination in limited overlay filenames")
	_assert_eq(saved_data.item_cells("Old").size(), 0, "generate history stores overlay delta before Add Item policy")
	_assert_eq(saved_data.item_cells("Key").size(), 1, "generate history stores generated overlay delta item")
	_assert_true(dock._current_overlay_data.has_item(HexVector.zero(), "Old"), "current overlay still applies Add Item policy")
	_assert_eq(dock._history_condition_name({"overlay_mode": true}), "overlay-uniform", "generate history keeps overlay uniform name")
	_assert_eq(dock._history_condition_name({"overlay_mode": true, "symmetric": true}), "overlay-markov", "generate history keeps overlay markov name")
	_assert_eq(dock._history_condition_name({"overlay_mode": true, "overlay_adjacency_enabled": true}), "overlay-adjacency", "generate history keeps overlay adjacency name")

	var primary_dock = await _new_ready_dock()
	primary_dock._set_generate_history_directory_for_test(history_dir)
	primary_dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	primary_dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	primary_dock._rect_width_spin.set_value_no_signal(2)
	primary_dock._rect_height_spin.set_value_no_signal(1)
	primary_dock._wall_prob_slider.set_value_no_signal(0.0)
	var primary_before_count = primary_dock._mapdata_sources.size()
	_assert_true(await primary_dock._generate_map(), "generate history test generates primary map")
	_assert_eq(primary_dock._mapdata_sources.size(), primary_before_count + 1, "generate history adds primary source")
	_assert_eq(primary_dock._mapdata_sources[0]["resource_type"], HexMapGenDock.MAPDATA_SOURCE_MAP, "generate history registers primary source")
	_assert_eq(primary_dock._mapdata_sources[0]["item_keys"], ["Any", "Floor", "Wall"], "generate history primary source exposes primary item keys")

	var cancel_dock = await _new_ready_dock()
	cancel_dock._set_generate_history_directory_for_test(history_dir)
	cancel_dock._generate_option.select(HexMapGenDock.GENERATE_SIMPLE)
	cancel_dock._shape_option_simple.select(HexMapGenDock.SHAPE_RECTANGLE)
	cancel_dock._rect_width_spin.set_value_no_signal(20)
	cancel_dock._rect_height_spin.set_value_no_signal(20)
	cancel_dock._wall_prob_slider.set_value_no_signal(1.0)
	cancel_dock._generation_chunk_size = 1
	cancel_dock._generation_progress_delay_usec = 5000
	cancel_dock._generate_map(true)
	await _wait_for_core_progress(cancel_dock)
	cancel_dock.request_generation_cancel()
	await _wait_for_generation(cancel_dock, "cancelled generate history generation")
	_assert_eq(cancel_dock._mapdata_sources.size(), 0, "generate history does not add source when generation is cancelled")

	cancel_dock.queue_free()
	primary_dock.queue_free()
	dock.queue_free()
	await process_frame


func _test_resource_path(filename: String) -> String:
	return "%s/%s" % [_test_output_dir(), filename]


func _test_resource_dir(dirname: String) -> String:
	var path = "%s/%s" % [_test_output_dir(), dirname]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
	return path


func _test_output_dir() -> String:
	if _test_output_root == "":
		_test_output_root = "res://.godot_user/test-runs/%s/test_editor_plugin" % _safe_path_part(_test_run_id())
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_test_output_root))
	return _test_output_root


func _test_run_id() -> String:
	var run_id = OS.get_environment("HEX_MAP_TEST_RUN_ID")
	if run_id == "":
		run_id = "manual-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()]
	return run_id


func _safe_path_part(value: String) -> String:
	var result := ""
	for index in range(value.length()):
		var code = value.unicode_at(index)
		if (code >= 48 and code <= 57) \
			or (code >= 65 and code <= 90) \
			or (code >= 97 and code <= 122) \
			or code == 45 \
			or code == 46 \
			or code == 95:
			result += char(code)
		else:
			result += "-"
	return "run" if result == "" else result


func _save_distribution(path: String, distribution: HexDistribution) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var error = ResourceSaver.save(distribution, path)
	_assert_eq(error, OK, "test distribution resource saves")


func _save_resource(path: String, resource: Resource) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var error = ResourceSaver.save(resource, path)
	_assert_eq(error, OK, "test resource saves")


func _count_cancel(state: Dictionary) -> void:
	state["count"] += 1


func _capture_rules(rules_text: String, state: Dictionary) -> void:
	state["rules"] = rules_text


func _spin_values(spins: Array) -> Array:
	var result: Array = []
	for spin in spins:
		result.append(float(spin.value))
	return result


func _connect_method_index(method: int) -> int:
	for index in range(HexMapGenDock.CONNECT_METHOD_VALUES.size()):
		if HexMapGenDock.CONNECT_METHOD_VALUES[index] == method:
			return index
	_failures.append("connect method %d is not listed in dock" % method)
	return 0


func _sample_v2_editor_document() -> HexMapDocumentResource:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentResource.new()
	document.ensure_v2_defaults()

	var terrain_layer = HexMapDocumentTerrainLayerResource.new()
	terrain_layer.map = HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_POINTY_TOP)
	terrain_layer.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 0,
		"atlas_coords": Vector2i(1, 0),
		"alternative_tile": 0,
	})
	document.terrain_layers.append(terrain_layer)

	var overlay_layer = HexMapDocumentOverlayLayerResource.new()
	overlay_layer.item_key = "Treasure"
	overlay_layer.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"source_id": 0,
		"atlas_coords": Vector2i(1, 0),
		"alternative_tile": 0,
	})
	document.overlay_layers.append(overlay_layer)

	var placement = HexMapDocumentObjectPlacementResource.new()
	placement.object_id = "chest"
	placement.cell = Vector3i.ZERO
	document.object_placements.append(placement)

	var label = HexMapDocumentLabelPlacementResource.new()
	label.label_id = "area"
	label.cell = Vector3i.ZERO
	label.text = "North"
	document.label_placements.append(label)
	return document


func _new_ready_dock():
	var dock = HexMapGenDock.new()
	root.add_child(dock)
	await process_frame
	return dock


func _new_ready_edit_tool():
	var tool = HexMapEditTool.new()
	root.add_child(tool)
	await process_frame
	return tool


func _begin_manual_generation(dock: HexMapGenDock, show_progress: bool = false) -> void:
	dock._generation_id += 1
	dock._begin_generation(dock._generation_id, show_progress)


func _wait_for_generation(dock: HexMapGenDock, message: String) -> void:
	var guard := 0
	while dock.generation_status()["running"] and guard < 240:
		await process_frame
		guard += 1
	_assert_true(guard < 240, "%s finishes" % message)
	await process_frame


func _wait_for_progress_controls(dock: HexMapGenDock, message: String) -> void:
	var guard := 0
	while not _progress_controls_ready(dock) \
		and dock.generation_status()["running"] \
		and guard < 240:
		await process_frame
		guard += 1
	_assert_true(_progress_controls_ready(dock), "%s shows dock progress" % message)


func _wait_for_core_progress(dock: HexMapGenDock) -> void:
	var guard := 0
	while dock._generation_last_core_progress <= 0.0 \
		and dock.generation_status()["running"] \
		and guard < 240:
		await process_frame
		guard += 1
	_assert_true(dock._generation_core_progress_event_count > 0, "threaded generation emits core progress")
	_assert_true(dock._generation_last_core_progress > 0.0, "threaded generation emits nonzero core progress")


func _wait_seconds(seconds: float) -> void:
	await create_timer(seconds).timeout


func _progress_controls_visible(dock: HexMapGenDock) -> bool:
	return dock._generation_progress_container != null \
		and dock._generation_progress_container.visible


func _progress_controls_ready(dock: HexMapGenDock) -> bool:
	return _progress_controls_visible(dock) \
		and dock._generation_progress_cancel_button != null


func _progress_controls_hidden(dock: HexMapGenDock) -> bool:
	return dock._generation_progress_container == null \
		or not dock._generation_progress_container.visible


func _window_child_count(node: Node) -> int:
	var count := 0
	for child in node.get_children():
		if child is Window:
			count += 1
		count += _window_child_count(child)
	return count


func _has_button_text(node: Node, text: String) -> bool:
	if node is Button and node.text == text:
		return true
	for child in node.get_children():
		if _has_button_text(child, text):
			return true
	return false


func _entries_by_id(entries: Array) -> Dictionary:
	var result := {}
	for entry in entries:
		result[String(entry["id"])] = entry
	return result


func _pressable_entry_count(entries: Array) -> int:
	var count := 0
	for entry in entries:
		if bool(entry.get("pressable", false)) and not bool(entry.get("disabled", false)):
			count += 1
	return count


func _direction_pressable_cells() -> Dictionary:
	var result := {}
	for direction in HexVector.directions():
		result[direction.key()] = true
	return result


func _press_query_row_direction(row: Dictionary, direction_index: int) -> void:
	var panel: HexCellButtonPanel = row["offset_panel"]
	var direction = HexVector.directions()[direction_index]
	var entry: Dictionary = _entries_by_id(panel.get_entries())[direction.key()]
	_send_panel_click(panel, entry["center"])


func _send_panel_click(panel: HexCellButtonPanel, position: Vector2) -> void:
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.position = position
	press.pressed = true
	panel._gui_input(press)

	var release = InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.position = position
	release.pressed = false
	panel._gui_input(release)


func _send_panel_motion(panel: HexCellButtonPanel, position: Vector2) -> void:
	var motion = InputEventMouseMotion.new()
	motion.position = position
	panel._gui_input(motion)


func _send_panel_key(panel: HexCellButtonPanel, keycode: int) -> void:
	var event = InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	panel._gui_input(event)


func _control_row_visible(control: Control) -> bool:
	if control == null:
		return false
	var parent = control.get_parent()
	if parent is Control:
		return (parent as Control).visible
	return control.visible


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _assert_vec2_approx(actual: Vector2, expected: Vector2, message: String, tolerance: float = 0.01) -> void:
	if actual.distance_to(expected) > tolerance:
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _assert_vector_eq(actual, expected, message: String) -> void:
	if not actual.is_equal(expected):
		_failures.append(
			"%s: expected %s, got %s" % [message, expected.debug_string(), actual.debug_string()]
		)


func _assert_keys_eq(actual: Array, expected: Array, message: String) -> void:
	var actual_keys: Array = []
	for point in actual:
		actual_keys.append(point.key())
	actual_keys.sort()
	var expected_keys: Array = []
	for point in expected:
		expected_keys.append(point.key())
	expected_keys.sort()
	_assert_eq(actual_keys, expected_keys, message)


func _assert_color_approx(actual: Color, expected: Color, message: String) -> void:
	if not is_equal_approx(actual.r, expected.r) \
		or not is_equal_approx(actual.g, expected.g) \
		or not is_equal_approx(actual.b, expected.b) \
		or not is_equal_approx(actual.a, expected.a):
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])
