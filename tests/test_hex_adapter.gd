extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexPoint = preload("res://addons/hex_map_kit/core/hex_point.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexOverlayData = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapDocumentDependencyResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_dependency_resource.gd")
const HexMapDocumentDependencyService = preload("res://addons/hex_map_kit/adapter/hex_map_document_dependency_service.gd")
const HexMapDocumentLabelPlacementResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_label_placement_resource.gd")
const HexMapDocumentObjectPlacementResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_object_placement_resource.gd")
const HexMapDocumentOverlayLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_overlay_layer_resource.gd")
const HexMapDocumentTerrainLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_terrain_layer_resource.gd")
const HexMapDocumentZoneResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_zone_resource.gd")
const HexMapValidationResult = preload("res://addons/hex_map_kit/adapter/hex_map_validation_result.gd")
const HexMapDocumentValidator = preload("res://addons/hex_map_kit/adapter/hex_map_document_validator.gd")
const HexGenerationResultResource = preload("res://addons/hex_map_kit/adapter/hex_generation_result_resource.gd")
const HexMovementProfileResource = preload("res://addons/hex_map_kit/adapter/hex_movement_profile_resource.gd")
const HexGenerationProfileResource = preload("res://addons/hex_map_kit/adapter/hex_generation_profile_resource.gd")
const HexExportProfileResource = preload("res://addons/hex_map_kit/adapter/hex_export_profile_resource.gd")
const HexGameplayLayerData = preload("res://addons/hex_map_kit/adapter/hex_gameplay_layer_data.gd")
const HexObjectDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_object_database_resource.gd")
const HexObjectDefinitionResource = preload("res://addons/hex_map_kit/adapter/hex_object_definition_resource.gd")
const HexLabelDefinitionResource = preload("res://addons/hex_map_kit/adapter/hex_label_definition_resource.gd")
const HexLabelDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_label_database_resource.gd")
const HexTileCatalogEntry = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_entry.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")
const HexValidationRuleSuiteResource = preload("res://addons/hex_map_kit/adapter/hex_validation_rule_suite_resource.gd")
const HexTileCatalogValidator = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_validator.gd")
const HexOverlayResource = preload("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd")
const HexOverlayTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_overlay_tile_adapter.gd")
const HexAdjacencyRuleSet = preload("res://addons/hex_map_kit/adapter/hex_adjacency_rule_set.gd")

class ValidationProgressRecorder:
	var events: Array[Dictionary] = []

	func record(status: Dictionary) -> void:
		events.append(status.duplicate(true))


var _failures: Array[String] = []
var _test_output_root := ""


func _init() -> void:
	_run()


func _run() -> void:
	_test_vector_to_map_cell_matches_flat_top_offset()
	_test_vector_to_map_cell_matches_pointy_top_offset()
	_test_map_cell_to_vector_roundtrips_offset_cells()
	_test_to_tile_entries_marks_floor_and_wall()
	_test_entries_are_sorted_for_stable_scene_generation()
	_test_radius_two_hexagon_matches_godot_flat_top_layout()
	_test_radius_two_hexagon_matches_godot_pointy_top_layout()
	_test_vector_to_display_axial_keeps_six_neighbor_shape()
	_test_flat_top_offset_neighbor_deltas_match_unity_even_row()
	_test_flat_top_offset_neighbor_deltas_match_unity_odd_row()
	_test_flat_top_offset_local_positions_are_center_parity_invariant()
	_test_hex_to_local_flat_top_positions()
	_test_hex_to_local_pointy_top_positions()
	_test_flat_top_neighbor_layout()
	_test_pointy_top_neighbor_layout()
	_test_configure_hex_tileset_sets_hex_layout()
	_test_sample_tile_asset_exists()
	_test_configure_sample_tile_set_creates_atlas_source()
	_test_map_resource_stores_map_data()
	_test_map_resource_roundtrips_to_map_data()
	_test_hex_map_document_roundtrips_map_and_payloads()
	_test_hex_map_document_prefers_nonempty_terrain_layer()
	_test_hex_object_database_definitions_roundtrip_resources()
	_test_hex_label_database_definitions_roundtrip_resources()
	_test_hex_map_document_schema_roundtrips_canonical_resources()
	_test_clean_resource_api_contract_covers_canonical_paths()
	_test_hex_map_document_dependency_service_crud_hydrates_and_validates()
	_test_profile_behavior_resources_roundtrip_schemas()
	_test_profile_engine_validation_rule_suite_filters_and_overrides()
	_test_hex_map_document_summary_reports_canonical_counts()
	_test_hex_map_validation_result_serializes_summary_and_warnings()
	_test_hex_generation_result_resource_serializes_scope_and_replay()
	_test_hex_map_document_validator_reports_core_rules()
	_test_hex_map_document_validator_reports_phase_progress()
	_test_hex_map_document_validator_rule_matrix()
	_test_hex_map_document_validator_profile_reachability()
	_test_hex_movement_profile_resource_roundtrips_gameplay_defaults()
	_test_hex_gameplay_layer_data_uses_profile_catalog_and_objects()
	_test_hex_map_document_adapter_roundtrips_canonical_payload_entries()
	_test_hex_map_document_object_placement_schema_mutates_and_cleans_deleted_cell()
	_test_hex_map_document_adapter_cleans_canonical_payloads_for_deleted_cell()
	_test_hex_map_document_adapter_updates_wall_floor()
	_test_hex_map_document_adapter_applies_tile_overrides()
	_test_hex_map_document_validator_reports_missing_catalog_assignments()
	_test_hex_tile_catalog_resource_resolves_logical_keys()
	_test_sample_hex_tile_catalog_loads()
	_test_hex_tile_catalog_validator_reports_missing_assets()
	_test_hex_tile_catalog_validator_extracts_tags_and_custom_data()
	_test_hex_map_tile_adapter_resolves_catalog_defaults()
	_test_overlay_tile_adapter_resolves_catalog_item_tiles()
	_test_hex_map_document_adapter_resolves_catalog_tile_entries()
	_test_overlay_resource_roundtrips_to_overlay_data()
	_test_adjacency_rule_set_parses_probability_rules()
	_test_overlay_data_apply_policy_merge_replace_skip()
	_test_overlay_tile_adapter_applies_user_item_tiles()
	_test_overlay_tile_adapter_can_preserve_existing_layer_cells()

	if _failures.is_empty():
		print("test_hex_adapter.gd: all tests passed")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _assert_vec2_approx(actual: Vector2, expected: Vector2, message: String) -> void:
	if not actual.is_equal_approx(expected):
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _assert_keys_eq(actual: Array, expected: Array, message: String) -> void:
	var actual_keys = []
	var expected_keys = []
	for point in actual:
		actual_keys.append(point.key())
	for point in expected:
		expected_keys.append(point.key())
	actual_keys.sort()
	expected_keys.sort()
	if actual_keys != expected_keys:
		_failures.append("%s: expected %s, got %s" % [message, str(expected_keys), str(actual_keys)])


func _assert_has_issue(result, rule_id: String, message: String) -> void:
	if not _validation_has_issue(result, rule_id):
		_failures.append("%s: missing issue %s in %s" % [message, rule_id, str(result.to_dictionary())])


func _assert_no_issue(result, rule_id: String, message: String) -> void:
	if _validation_has_issue(result, rule_id):
		_failures.append("%s: unexpected issue %s in %s" % [message, rule_id, str(result.to_dictionary())])


func _validation_has_issue(result, rule_id: String) -> bool:
	for issue in result.issues:
		if String(issue.get("rule_id", "")) == rule_id:
			return true
	return false


func _validation_issue(result, rule_id: String, reason: String = "") -> Dictionary:
	for issue in result.issues:
		if String(issue.get("rule_id", "")) != rule_id:
			continue
		if reason != "" and String(issue.get("metadata", {}).get("reason", "")) != reason:
			continue
		return issue
	return {}


func _test_vector_to_map_cell_matches_flat_top_offset() -> void:
	_assert_eq(
		HexMapTileAdapter.vector_to_map_cell(HexVector.zero()),
		Vector2i(0, 0),
		"origin maps to TileMap cell origin"
	)
	_assert_eq(
		HexMapTileAdapter.vector_to_map_cell(HexVector.q_axis().negated()),
		Vector2i(-1, -1),
		"negative flat-top Q axis uses floor column offset"
	)
	_assert_eq(
		HexMapTileAdapter.vector_to_map_cell(HexVector.r_axis()),
		Vector2i(-1, 0),
		"flat-top R axis maps to vertical offset"
	)


func _test_vector_to_map_cell_matches_pointy_top_offset() -> void:
	_assert_eq(
		HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), false),
		Vector2i(0, 0),
		"pointy-top origin maps to TileMap cell origin"
	)
	_assert_eq(
		HexMapTileAdapter.vector_to_map_cell(HexVector.r_axis().negated(), false),
		Vector2i(0, -1),
		"negative pointy-top R axis uses floor row offset"
	)
	_assert_eq(
		HexMapTileAdapter.vector_to_map_cell(HexVector.q_axis(), false),
		Vector2i(1, 0),
		"pointy-top Q axis maps to horizontal offset"
	)


func _test_map_cell_to_vector_roundtrips_offset_cells() -> void:
	var cells = [
		HexVector.zero(),
		HexVector.q_axis(),
		HexVector.r_axis(),
		HexVector.s_axis(),
		HexVector.q_axis().negated(),
		HexVector.r_axis().negated(),
	]
	for cell in cells:
		var flat_map_cell = HexMapTileAdapter.vector_to_map_cell(cell, true)
		var pointy_map_cell = HexMapTileAdapter.vector_to_map_cell(cell, false)
		_assert_eq(HexMapTileAdapter.map_cell_to_vector(flat_map_cell, true).key(), cell.key(), "flat-top map cell roundtrips %s" % cell.key())
		_assert_eq(HexMapTileAdapter.map_cell_to_vector(pointy_map_cell, false).key(), cell.key(), "pointy-top map cell roundtrips %s" % cell.key())


func _test_to_tile_entries_marks_floor_and_wall() -> void:
	var data = HexMapData.rectangle(2, 2)
	var wall = HexVector.apply_basis(1, 0, 0)
	data.set_walls([wall])

	var entries = HexMapTileAdapter.to_tile_entries(data)
	var entry_by_key = _entries_by_key(entries)

	_assert_eq(entries.size(), 4, "adapter emits every cell by default")
	_assert_eq(entry_by_key[HexVector.zero().key()]["kind"], HexMapTileAdapter.KIND_FLOOR, "origin is floor")
	_assert_eq(entry_by_key[HexVector.zero().key()]["map_cell"], Vector2i(0, 0), "origin map cell")
	_assert_eq(entry_by_key[wall.key()]["kind"], HexMapTileAdapter.KIND_WALL, "wall is marked")
	_assert_eq(entry_by_key[wall.key()]["map_cell"], Vector2i(1, 0), "wall map cell")


func _test_entries_are_sorted_for_stable_scene_generation() -> void:
	var cells = [
		HexVector.apply_basis(1, 0, 1),
		HexVector.zero(),
		HexVector.apply_basis(1, 0, 0),
	]
	var data = HexMapData.from_cells(cells)
	var entries = HexMapTileAdapter.to_tile_entries(data)

	_assert_eq(entries[0]["vector"].key(), HexVector.zero().key(), "origin sorts first")
	_assert_eq(entries[1]["vector"].key(), HexVector.apply_basis(1, 0, 0).key(), "row 0 q=1 sorts second")
	_assert_eq(entries[2]["vector"].key(), HexVector.apply_basis(1, 0, 1).key(), "next row sorts last")


func _test_radius_two_hexagon_matches_godot_flat_top_layout() -> void:
	_assert_radius_two_hexagon_matches_godot_layout(true)


func _test_radius_two_hexagon_matches_godot_pointy_top_layout() -> void:
	_assert_radius_two_hexagon_matches_godot_layout(false)


func _test_vector_to_display_axial_keeps_six_neighbor_shape() -> void:
	var expected = [
		Vector2i(1, 0),
		Vector2i(1, -1),
		Vector2i(0, -1),
		Vector2i(-1, 0),
		Vector2i(-1, 1),
		Vector2i(0, 1),
	]
	var directions = HexVector.directions()

	for index in range(directions.size()):
		_assert_eq(
			HexMapTileAdapter.vector_to_display_axial(directions[index]),
			expected[index],
			"display axial neighbor layout %d" % index
		)


func _test_flat_top_offset_neighbor_deltas_match_unity_even_row() -> void:
	_assert_neighbor_offset_deltas(
		HexPoint.from_cube(0, 0, 0),
		[
			Vector2i(1, 0),
			Vector2i(0, -1),
			Vector2i(-1, -1),
			Vector2i(-1, 0),
			Vector2i(-1, 1),
			Vector2i(0, 1),
		],
		"flat-top offset deltas from even R center"
	)


func _test_flat_top_offset_neighbor_deltas_match_unity_odd_row() -> void:
	var expected = [
		Vector2i(1, 0),
		Vector2i(1, -1),
		Vector2i(0, -1),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(1, 1),
	]

	_assert_neighbor_offset_deltas(
		HexPoint.from_cube(0, 0, 1),
		expected,
		"flat-top offset deltas from positive odd R center"
	)
	_assert_neighbor_offset_deltas(
		HexPoint.from_cube(0, 0, -1),
		expected,
		"flat-top offset deltas from negative odd R center"
	)


func _test_flat_top_offset_local_positions_are_center_parity_invariant() -> void:
	var size = 10.0
	var centers = [
		HexPoint.from_cube(0, 0, 0),
		HexPoint.from_cube(0, 0, 1),
		HexPoint.from_cube(0, 0, -1),
		HexPoint.from_cube(2, 0, 2),
		HexPoint.from_cube(2, 0, 3),
	]
	var directions = HexVector.directions()

	for center_index in range(centers.size()):
		for direction_index in range(directions.size()):
			_assert_vec2_approx(
				_flat_top_offset_relative_local(centers[center_index], directions[direction_index], size),
				HexMapTileAdapter.hex_to_local(directions[direction_index], size, true),
				"flat-top local neighbor position center %d direction %d" % [center_index, direction_index]
			)


func _test_hex_to_local_flat_top_positions() -> void:
	_assert_vec2_approx(
		HexMapTileAdapter.hex_to_local(HexVector.apply_basis(1, 0, 0), 10.0),
		Vector2(15.0, 8.660254),
		"flat-top Q axis uses 3/2 x and sqrt(3)/2 y"
	)


func _test_hex_to_local_pointy_top_positions() -> void:
	_assert_vec2_approx(
		HexMapTileAdapter.hex_to_local(HexVector.apply_basis(0, 0, 1), 10.0, false),
		Vector2(-8.660254, 15.0),
		"pointy-top R axis uses display axial projection"
	)


func _test_flat_top_neighbor_layout() -> void:
	var size = 10.0
	var expected = [
		Vector2(15.0, 8.660254),
		Vector2(15.0, -8.660254),
		Vector2(0.0, -17.320508),
		Vector2(-15.0, -8.660254),
		Vector2(-15.0, 8.660254),
		Vector2(0.0, 17.320508),
	]
	var directions = HexVector.directions()

	for index in range(directions.size()):
		_assert_vec2_approx(
			HexMapTileAdapter.hex_to_local(directions[index], size, true),
			expected[index],
			"flat-top neighbor layout %d" % index
		)


func _test_pointy_top_neighbor_layout() -> void:
	var size = 10.0
	var expected = [
		Vector2(17.320508, 0.0),
		Vector2(8.660254, -15.0),
		Vector2(-8.660254, -15.0),
		Vector2(-17.320508, 0.0),
		Vector2(-8.660254, 15.0),
		Vector2(8.660254, 15.0),
	]
	var directions = HexVector.directions()

	for index in range(directions.size()):
		_assert_vec2_approx(
			HexMapTileAdapter.hex_to_local(directions[index], size, false),
			expected[index],
			"pointy-top neighbor layout %d" % index
		)


func _test_configure_hex_tileset_sets_hex_layout() -> void:
	var tile_set = TileSet.new()

	HexMapTileAdapter.configure_hex_tile_set(tile_set, true, Vector2i(80, 72))
	_assert_eq(tile_set.tile_shape, TileSet.TILE_SHAPE_HEXAGON, "configured TileSet uses Hexagon shape")
	_assert_eq(tile_set.tile_layout, TileSet.TILE_LAYOUT_STACKED, "configured TileSet uses Stacked layout")
	_assert_eq(tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_VERTICAL, "flat-top maps to Vertical Offset axis")
	_assert_eq(tile_set.tile_size, Vector2i(80, 72), "configured TileSet stores tile size")

	HexMapTileAdapter.configure_hex_tile_set(tile_set, false)
	_assert_eq(tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "pointy-top maps to Horizontal Offset axis")


func _test_sample_tile_asset_exists() -> void:
	_assert_eq(FileAccess.file_exists(HexMapTileAdapter.SAMPLE_TILE_ATLAS_PATH), true, "sample tile atlas exists")
	var image := Image.new()
	var error = image.load(ProjectSettings.globalize_path(HexMapTileAdapter.SAMPLE_TILE_ATLAS_PATH))
	_assert_eq(error, OK, "sample tile atlas loads as image")
	_assert_eq(Vector2i(image.get_width(), image.get_height()), Vector2i(128, 57), "sample tile atlas dimensions")


func _test_configure_sample_tile_set_creates_atlas_source() -> void:
	var tile_set = TileSet.new()

	_assert_eq(
		HexMapTileAdapter.configure_sample_tile_set(tile_set, false),
		true,
		"sample TileSet configuration succeeds"
	)
	_assert_eq(tile_set.tile_shape, TileSet.TILE_SHAPE_HEXAGON, "sample TileSet uses Hexagon shape")
	_assert_eq(tile_set.tile_layout, TileSet.TILE_LAYOUT_STACKED, "sample TileSet uses Stacked layout")
	_assert_eq(tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "sample TileSet uses requested orientation")
	_assert_eq(tile_set.tile_size, HexMapTileAdapter.SAMPLE_TILE_SIZE, "sample TileSet uses sample tile size")
	_assert_eq(tile_set.has_source(0), true, "sample TileSet creates source 0")

	var source = tile_set.get_source(0)
	_assert_eq(source is TileSetAtlasSource, true, "sample TileSet source is atlas source")
	_assert_eq(source.texture != null, true, "sample TileSet atlas has texture")
	_assert_eq(source.texture_region_size, HexMapTileAdapter.SAMPLE_TILE_SIZE, "sample atlas source region size")
	_assert_eq(source.has_tile(Vector2i(0, 0)), true, "sample atlas creates floor tile")
	_assert_eq(source.has_tile(Vector2i(1, 0)), true, "sample atlas creates wall tile")


func _test_map_resource_stores_map_data() -> void:
	var data = HexMapData.square(2, true)
	data.set_walls([HexVector.q_axis()])

	var resource = HexMapResource.from_map_data(data)

	_assert_eq(resource.cyclic_size, 2, "resource stores cyclic size")
	_assert_eq(resource.cells.size(), 4, "resource stores all cells")
	_assert_eq(resource.walls, [Vector3i(1, 0, 0)], "resource stores wall vector components")
	_assert_eq(resource.orientation, HexMapResource.ORIENTATION_FLAT_TOP, "resource defaults to flat-top orientation")


func _test_map_resource_roundtrips_to_map_data() -> void:
	var data = HexMapData.rectangle(3, 2)
	data.set_walls([
		HexVector.apply_basis(1, 0, 0),
		HexVector.apply_basis(0, 0, 1),
	])

	var roundtrip = HexMapResource.from_map_data(data).to_map_data()

	_assert_eq(roundtrip.cyclic_size, data.cyclic_size, "roundtrip preserves cyclic size")
	_assert_keys_eq(roundtrip.cells, data.cells, "roundtrip preserves cells")
	_assert_keys_eq(roundtrip.walls, data.walls, "roundtrip preserves walls")

	var resource = HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_POINTY_TOP)
	_assert_eq(resource.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "resource stores pointy-top orientation")
	resource.set_from_map_data(data, 99)
	_assert_eq(resource.orientation, HexMapResource.ORIENTATION_FLAT_TOP, "resource normalizes unknown orientation to flat-top")


func _test_hex_map_document_roundtrips_map_and_payloads() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_POINTY_TOP)
	)
	HexMapDocumentAdapter.set_tile_override(document, HexVector.zero(), {
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 3,
		"atlas_coords": Vector2i(4, 5),
		"alternative_tile": 2,
	})
	HexMapDocumentAdapter.set_object(document, HexVector.q_axis(), {
		"object_id": "chest",
		"properties": {"gold": 2},
	})
	HexMapDocumentAdapter.set_label(document, HexVector.zero(), {
		"label_id": "area",
		"text": "North Gate",
	})
	var object_db = HexObjectDatabaseResource.new()
	var object_definition = HexObjectDefinitionResource.new()
	object_definition.id = "chest"
	object_definition.display_name = "Chest"
	object_db.add_definition(object_definition)
	var label_db = HexLabelDatabaseResource.new()
	var label_definition = HexLabelDefinitionResource.new()
	label_definition.label_id = "area"
	label_definition.display_name = "Area"
	label_db.add_definition(label_definition)

	var path = _test_resource_path("test_hex_map_document.tres")
	var error = ResourceSaver.save(document, path)
	var loaded = load(path)
	var roundtrip = HexMapDocumentAdapter.to_map_resource(loaded).to_map_data()

	_assert_eq(error, OK, "hex map document resource saves")
	_assert_keys_eq(roundtrip.cells, data.cells, "hex map document preserves cells")
	_assert_keys_eq(roundtrip.walls, data.walls, "hex map document preserves walls")
	_assert_eq(loaded.terrain_layers[0].map.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "hex map document preserves orientation")
	_assert_eq(loaded.terrain_layers[0].tile_assignments[0]["atlas_coords"], Vector2i(4, 5), "hex map document preserves tile assignment")
	_assert_eq(loaded.object_placements[0].properties["gold"], 2, "hex map document preserves object properties")
	_assert_eq(loaded.label_placements[0].text, "North Gate", "hex map document preserves labels")
	_assert_eq(object_db.definition_for_id("chest").display_name, "Chest", "object database stores typed definitions")
	_assert_eq(label_db.definition_for_id("area").display_name, "Area", "label database stores typed definitions")


func _test_hex_map_document_prefers_nonempty_terrain_layer() -> void:
	var document = HexMapDocumentResource.new()
	var empty_layer = HexMapDocumentTerrainLayerResource.new()
	empty_layer.layer_id = "manual_empty_terrain"
	empty_layer.map = HexMapResource.from_map_data(HexMapData.from_cells([]))
	document.terrain_layers.append(empty_layer)

	var generated_data = HexMapData.rectangle(3, 2)
	var generated_layer = HexMapDocumentTerrainLayerResource.new()
	generated_layer.layer_id = "generated_terrain"
	generated_layer.map = HexMapResource.from_map_data(generated_data)
	generated_layer.metadata = {
		"writable_source": "generated",
		"source": "generation_graph",
	}
	document.terrain_layers.append(generated_layer)

	var roundtrip = HexMapDocumentAdapter.to_map_resource(document).to_map_data()
	_assert_eq(roundtrip.cells.size(), generated_data.cells.size(), "document map resource prefers non-empty generated terrain over earlier empty layer")


func _test_hex_object_database_definitions_roundtrip_resources() -> void:
	var database = HexObjectDatabaseResource.new()
	var chest = HexObjectDefinitionResource.new()
	chest.id = "chest"
	chest.display_name = "Chest"
	chest.scene = _test_packed_scene("ChestScene")
	chest.tags = PackedStringArray(["loot", "blocking"])
	chest.default_properties = {"gold": 5}
	chest.preview_texture = HexMapTileAdapter.load_sample_tile_texture()
	database.add_definition(chest)

	_assert_eq(database.get("version"), null, "object database has no version field")
	_assert_eq(database.get("objects"), null, "object database has no legacy objects field")
	_assert_eq(database.definitions.size(), 1, "object database stores typed definitions")
	_assert_eq(chest.object_id(), "chest", "object definition exposes object id")
	_assert_eq(chest.to_dictionary()["scene"] is PackedScene, true, "object definition dictionary uses scene resource")
	_assert_eq(chest.to_dictionary()["preview_texture"] is Texture2D, true, "object definition dictionary uses preview texture resource")

	var spawn = HexObjectDefinitionResource.new()
	spawn.id = "spawn"
	spawn.display_name = "Spawn Point"
	spawn.scene = _test_packed_scene("SpawnScene")
	spawn.tags = PackedStringArray(["spawn"])
	spawn.default_properties = {"team": "player"}
	spawn.preview_texture = HexMapTileAdapter.load_sample_tile_texture()
	database.add_definition(spawn)
	_assert_eq(database.definition_ids().size(), 2, "object database stores added definition")
	_assert_eq(database.definitions_with_tag("spawn").size(), 1, "object database filters definitions by tag")
	_assert_eq(database.definition_for_id("spawn").default_properties["team"], "player", "object database resolves added definition")

	var replacement = HexObjectDefinitionResource.new()
	replacement.id = "spawn"
	replacement.display_name = "Hero Spawn"
	replacement.scene = _test_packed_scene("HeroSpawnScene")
	replacement.tags = PackedStringArray(["spawn", "hero"])
	replacement.default_properties = {"team": "hero"}
	replacement.preview_texture = HexMapTileAdapter.load_sample_tile_texture()
	database.add_definition(replacement)
	_assert_eq(database.definition_ids().size(), 2, "object database replaces matching id instead of duplicating")
	_assert_eq(database.definition_for_id("spawn").display_name, "Hero Spawn", "object database replaces definition by id")
	_assert_eq(database.has_definition("missing"), false, "object database reports missing definitions")

	var path = _test_resource_path("test_hex_object_database.tres")
	var error = ResourceSaver.save(database, path)
	var loaded = load(path)
	_assert_eq(error, OK, "object database resource saves")
	_assert_eq(loaded.definition_for_id("chest").scene is PackedScene, true, "object database roundtrip preserves scene resource")
	_assert_eq(loaded.definition_for_id("spawn").preview_texture is Texture2D, true, "object database roundtrip preserves preview texture")
	_assert_eq(loaded.definition_for_id("spawn").default_properties["team"], "hero", "object database roundtrip preserves replacement definition")


func _test_hex_label_database_definitions_roundtrip_resources() -> void:
	var database = HexLabelDatabaseResource.new()
	var area = HexLabelDefinitionResource.new()
	area.label_id = "area"
	area.display_name = "Area"
	area.default_text = "North Gate"
	area.style_key = "small"
	area.tags = PackedStringArray(["map", "poi"])
	area.metadata = {"priority": 1}
	database.add_definition(area)

	var replacement = HexLabelDefinitionResource.new()
	replacement.label_id = "area"
	replacement.display_name = "Area Label"
	replacement.default_text = "Gate"
	replacement.style_key = "large"
	replacement.tags = PackedStringArray(["map", "important"])
	database.add_definition(replacement)

	_assert_eq(database.get("labels"), null, "label database has no loose labels array")
	_assert_eq(database.definition_ids(), PackedStringArray(["area"]), "label database replaces matching label id")
	_assert_eq(database.definition_for_id("area").display_name, "Area Label", "label database resolves typed definition")
	_assert_eq(database.definitions_with_tag("important").size(), 1, "label database filters typed definitions by tag")
	_assert_eq(database.has_definition("missing"), false, "label database reports missing definition")
	_assert_eq(replacement.to_dictionary()["style_key"], "large", "label definition dictionary exports canonical fields")

	var path = _test_resource_path("test_hex_label_database.tres")
	var error = ResourceSaver.save(database, path)
	var loaded = load(path)
	_assert_eq(error, OK, "label database resource saves")
	_assert_eq(loaded.definition_for_id("area").default_text, "Gate", "label database roundtrip preserves default text")
	_assert_eq(loaded.definition_for_id("area").tags.has("important"), true, "label database roundtrip preserves tags")


func _test_hex_map_document_schema_roundtrips_canonical_resources() -> void:
	var data = HexMapData.rectangle(2, 1)
	var overlay_data = HexOverlayData.from_item_cells(data.cells, "Treasure", [HexVector.zero()])
	var document = HexMapDocumentResource.new()
	document.metadata.document_id = "level-001"
	document.metadata.display_name = "North Gate"
	document.metadata.generation_seed = 42

	var terrain_layer = HexMapDocumentTerrainLayerResource.new()
	terrain_layer.layer_id = "terrain-base"
	terrain_layer.display_name = "Base Terrain"
	terrain_layer.map = HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_POINTY_TOP)
	terrain_layer.default_floor_key = "terrain.grass"
	terrain_layer.default_wall_key = "terrain.wall"
	terrain_layer.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"catalog_key": "terrain.stone",
	})
	document.terrain_layers.append(terrain_layer)

	var overlay_layer = HexMapDocumentOverlayLayerResource.new()
	overlay_layer.layer_id = "overlay-treasure"
	overlay_layer.display_name = "Treasure Overlay"
	overlay_layer.item_key = "Treasure"
	overlay_layer.catalog_key = "overlay.treasure"
	overlay_layer.overlay = HexOverlayResource.from_overlay_data(overlay_data)
	overlay_layer.z_index = 5
	document.overlay_layers.append(overlay_layer)

	var placement = HexMapDocumentObjectPlacementResource.new()
	placement.placement_id = "chest-001"
	placement.object_id = "chest"
	placement.cell = Vector3i(1, 0, 0)
	placement.rotation_degrees = 45.0
	placement.variant = "gold"
	placement.properties = {"gold": 5}
	placement.spawn_condition = "default"
	placement.layer_id = "props"
	placement.runtime_enabled = false
	placement.metadata = {"unique": true}
	document.object_placements.append(placement)

	var label = HexMapDocumentLabelPlacementResource.new()
	label.label_id = "area"
	label.cell = Vector3i.ZERO
	label.text = "North"
	label.style_key = "small"
	document.label_placements.append(label)

	var zone = HexMapDocumentZoneResource.new()
	zone.zone_id = "spawn"
	zone.display_name = "Spawn Zone"
	var zone_cells: Array[Vector3i] = [Vector3i.ZERO, Vector3i(1, 0, 0)]
	zone.cells = zone_cells
	zone.tags = PackedStringArray(["safe", "entry"])
	document.zones.append(zone)

	var dependency = HexMapDocumentDependencyResource.new()
	dependency.dependency_id = "tiles-main"
	dependency.kind = HexMapDocumentDependencyResource.KIND_TILE_CATALOG
	dependency.resource = load("res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres")
	dependency.role = "terrain"
	document.dependencies.append(dependency)

	var path = _test_resource_path("test_hex_map_document_canonical.tres")
	var error = ResourceSaver.save(document, path)
	var loaded = load(path)

	_assert_eq(error, OK, "hex map document canonical resource saves")
	_assert_eq(loaded.metadata != null, true, "canonical document loads metadata")
	_assert_eq(loaded.metadata.document_id, "level-001", "canonical document metadata roundtrips")
	_assert_eq(loaded.terrain_layers[0] is HexMapDocumentTerrainLayerResource, true, "terrain layer keeps typed resource")
	_assert_eq(loaded.terrain_layers[0].default_floor_key, "terrain.grass", "terrain layer preserves floor key")
	_assert_eq(loaded.terrain_layers[0].map.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "terrain layer map preserves orientation")
	_assert_eq(loaded.overlay_layers[0] is HexMapDocumentOverlayLayerResource, true, "overlay layer keeps typed resource")
	_assert_eq(loaded.overlay_layers[0].overlay.item_keys[0], "Treasure", "overlay layer preserves overlay resource")
	_assert_eq(loaded.object_placements[0] is HexMapDocumentObjectPlacementResource, true, "object placement keeps typed resource")
	_assert_eq(loaded.object_placements[0].properties["gold"], 5, "object placement preserves properties")
	_assert_eq(loaded.object_placements[0].rotation_degrees, 45.0, "object placement preserves rotation")
	_assert_eq(loaded.object_placements[0].variant, "gold", "object placement preserves variant")
	_assert_eq(loaded.object_placements[0].spawn_condition, "default", "object placement preserves spawn condition")
	_assert_eq(loaded.object_placements[0].layer_id, "props", "object placement preserves layer id")
	_assert_eq(loaded.object_placements[0].runtime_enabled, false, "object placement preserves runtime flag")
	_assert_eq(loaded.object_placements[0].metadata["unique"], true, "object placement preserves metadata")
	_assert_eq(loaded.label_placements[0] is HexMapDocumentLabelPlacementResource, true, "label placement keeps typed resource")
	_assert_eq(loaded.label_placements[0].text, "North", "label placement preserves text")
	_assert_eq(loaded.zones[0] is HexMapDocumentZoneResource, true, "zone keeps typed resource")
	_assert_eq(loaded.zones[0].tags[1], "entry", "zone preserves tags")
	_assert_eq(loaded.dependencies[0] is HexMapDocumentDependencyResource, true, "dependency keeps typed resource")
	_assert_eq(loaded.dependencies[0].kind, HexMapDocumentDependencyResource.KIND_TILE_CATALOG, "dependency preserves kind")


func _test_clean_resource_api_contract_covers_canonical_paths() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var catalog = _test_tile_catalog()
	var document = HexMapDocumentResource.new()
	var terrain_layer = HexMapDocumentTerrainLayerResource.new()
	terrain_layer.map = HexMapResource.from_map_data(data)
	terrain_layer.default_floor_key = "terrain.floor"
	terrain_layer.default_wall_key = "terrain.wall"
	terrain_layer.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"catalog_key": "terrain.floor",
	})
	document.terrain_layers.append(terrain_layer)

	var dependency = HexMapDocumentDependencyResource.new()
	dependency.dependency_id = "tiles-main"
	dependency.kind = HexMapDocumentDependencyResource.KIND_TILE_CATALOG
	dependency.resource = catalog
	document.dependencies.append(dependency)

	var document_path = _test_resource_path("test_clean_resource_api_document.tres")
	var document_error = ResourceSaver.save(document, document_path)
	var loaded_document = load(document_path) as HexMapDocumentResource
	_assert_eq(document_error, OK, "clean resource API document saves")
	_assert_eq(loaded_document is HexMapDocumentResource, true, "clean resource API document loads typed resource")
	_assert_eq(loaded_document.dependencies[0].resource is HexTileCatalogResource, true, "document dependency keeps catalog Resource reference")
	var roundtrip = HexMapDocumentAdapter.to_map_resource(loaded_document).to_map_data()
	_assert_keys_eq(roundtrip.cells, data.cells, "clean resource API adapter roundtrips cells")
	_assert_keys_eq(roundtrip.walls, data.walls, "clean resource API adapter roundtrips walls")

	var scene_entry = HexTileCatalogEntry.new()
	scene_entry.key = "object.spawn"
	scene_entry.entry_type = HexTileCatalogEntry.TYPE_SCENE
	scene_entry.scene = _test_packed_scene("CleanContractSpawn")
	catalog.add_entry(scene_entry)
	var catalog_path = _test_resource_path("test_clean_resource_api_catalog.tres")
	var catalog_error = ResourceSaver.save(catalog, catalog_path)
	var loaded_catalog = load(catalog_path) as HexTileCatalogResource
	_assert_eq(catalog_error, OK, "clean resource API catalog saves")
	_assert_eq(loaded_catalog.tile_set is TileSet, true, "catalog roundtrip preserves TileSet Resource")
	_assert_eq(loaded_catalog.entry_for_key("object.spawn").scene is PackedScene, true, "catalog roundtrip preserves PackedScene scene entry")

	var object_database = HexObjectDatabaseResource.new()
	var object_definition = HexObjectDefinitionResource.new()
	object_definition.id = "spawn"
	object_definition.scene = _test_packed_scene("CleanContractObject")
	object_database.add_definition(object_definition)
	var object_database_path = _test_resource_path("test_clean_resource_api_object_database.tres")
	var object_error = ResourceSaver.save(object_database, object_database_path)
	var loaded_object_database = load(object_database_path) as HexObjectDatabaseResource
	_assert_eq(object_error, OK, "clean resource API object database saves")
	_assert_eq(loaded_object_database.definition_for_id("spawn").scene is PackedScene, true, "object definition roundtrip preserves PackedScene")

	var mismatch_document = HexMapDocumentResource.new()
	var mismatch_dependency = HexMapDocumentDependencyResource.new()
	mismatch_dependency.kind = HexMapDocumentDependencyResource.KIND_TILE_SET
	mismatch_dependency.resource = HexLabelDatabaseResource.new()
	mismatch_document.dependencies.append(mismatch_dependency)
	_assert_has_issue(
		HexMapDocumentValidator.validate_document(mismatch_document),
		HexMapDocumentValidator.RULE_DEPENDENCY_TYPE_MISMATCH,
		"dependency validation reports Resource type mismatch"
	)

	var numeric_document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_tile_override(numeric_document, HexVector.zero(), {
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 8,
		"atlas_coords": Vector2i(4, 5),
	})
	var layer = TileMapLayer.new()
	HexMapDocumentAdapter.apply_to_tile_map_layer(numeric_document, layer)
	_assert_eq(layer.get_cell_source_id(Vector2i.ZERO), -1, "clean resource API does not silently apply numeric floor tile")
	_assert_has_issue(
		HexMapDocumentValidator.validate_document(numeric_document),
		HexMapDocumentValidator.RULE_TILE_ASSIGNMENT_MISSING,
		"clean resource API reports missing catalog assignment"
	)
	layer.free()


func _test_hex_map_document_dependency_service_crud_hydrates_and_validates() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var catalog = _test_tile_catalog()
	var object_database = HexObjectDatabaseResource.new()
	var label_database = HexLabelDatabaseResource.new()
	var movement_profile = HexMovementProfileResource.new()
	var validation_suite = HexValidationRuleSuiteResource.new()
	var generation_profile = HexGenerationProfileResource.new()
	var export_profile = HexExportProfileResource.new()

	var keys = HexMapDocumentDependencyService.shared_dependency_keys()
	_assert_eq(keys.has(HexMapDocumentDependencyService.KEY_TILE_CATALOG), true, "RES-10 shared dependency keys include Tile Catalog")
	_assert_eq(keys.has(HexMapDocumentDependencyService.KEY_OBJECT_DATABASE), true, "RES-10 shared dependency keys include Object DB")
	_assert_eq(keys.has(HexMapDocumentDependencyService.KEY_LABEL_DATABASE), true, "RES-10 shared dependency keys include Label DB")
	_assert_eq(keys.has(HexMapDocumentDependencyService.KEY_MOVEMENT_PROFILE), true, "RES-10 shared dependency keys include Movement Profile")
	_assert_eq(keys.has(HexMapDocumentDependencyService.KEY_VALIDATION_RULE_SUITE), true, "RES-10 shared dependency keys include Validation Suite")
	_assert_eq(keys.has(HexMapDocumentDependencyService.KEY_GENERATION_PROFILE), true, "RES-10 shared dependency keys include Generation Profile")
	_assert_eq(keys.has(HexMapDocumentDependencyService.KEY_EXPORT_PROFILE), true, "RES-10 shared dependency keys include Export Profile")

	var catalog_dependency = HexMapDocumentDependencyService.set_shared_dependency(
		document,
		HexMapDocumentDependencyService.KEY_TILE_CATALOG,
		catalog,
		true,
		{"purpose": "terrain"}
	)
	_assert_eq(document.dependencies.size(), 1, "RES-10 set shared dependency appends first dependency")
	_assert_eq(
		catalog_dependency.kind,
		HexMapDocumentDependencyResource.KIND_TILE_CATALOG,
		"RES-10 Tile Catalog dependency uses centralized kind"
	)
	_assert_eq(catalog_dependency.resource, catalog, "RES-10 set shared dependency stores resource")
	_assert_eq(catalog_dependency.metadata["purpose"], "terrain", "RES-10 set dependency preserves metadata")
	_assert_eq(
		catalog_dependency.metadata["source_badge"],
		HexMapDocumentDependencyService.SOURCE_BADGE_DOCUMENT_DEPENDENCY,
		"RES-10 dependency metadata carries source badge"
	)
	_assert_eq(
		HexMapDocumentDependencyService.find_shared_dependency(
			document,
			HexMapDocumentDependencyService.KEY_TILE_CATALOG
		),
		catalog_dependency,
		"RES-10 find shared dependency returns existing entry"
	)

	var replacement_catalog = HexTileCatalogResource.new()
	var updated_catalog_dependency = HexMapDocumentDependencyService.set_shared_dependency(
		document,
		HexMapDocumentDependencyService.KEY_TILE_CATALOG,
		replacement_catalog,
		false
	)
	_assert_eq(updated_catalog_dependency, catalog_dependency, "RES-10 set shared dependency updates existing kind/role")
	_assert_eq(document.dependencies.size(), 1, "RES-10 update does not duplicate dependency")
	_assert_eq(updated_catalog_dependency.resource, replacement_catalog, "RES-10 update replaces dependency resource")
	_assert_eq(updated_catalog_dependency.required, false, "RES-10 update stores required flag")

	var role_dependency = HexMapDocumentDependencyService.set_dependency(
		document,
		HexMapDocumentDependencyResource.KIND_TILE_CATALOG,
		replacement_catalog,
		"terrain",
		true
	)
	_assert_eq(role_dependency.dependency_id, "tile_catalog:terrain", "RES-10 role dependency id includes role")
	_assert_eq(
		HexMapDocumentDependencyService.find_dependency(
			document,
			HexMapDocumentDependencyResource.KIND_TILE_CATALOG,
			"terrain"
		),
		role_dependency,
		"RES-10 role dependency lookup uses kind and role"
	)
	_assert_eq(
		HexMapDocumentDependencyService.remove_dependency(
			document,
			HexMapDocumentDependencyResource.KIND_TILE_CATALOG,
			"terrain"
		),
		true,
		"RES-10 remove dependency removes role-specific entry"
	)
	_assert_eq(document.dependencies.size(), 1, "RES-10 role-specific remove leaves shared dependency")

	HexMapDocumentDependencyService.set_shared_dependency(
		document,
		HexMapDocumentDependencyService.KEY_OBJECT_DATABASE,
		object_database
	)
	HexMapDocumentDependencyService.set_shared_dependency(
		document,
		HexMapDocumentDependencyService.KEY_LABEL_DATABASE,
		label_database
	)
	HexMapDocumentDependencyService.set_shared_dependency(
		document,
		HexMapDocumentDependencyService.KEY_MOVEMENT_PROFILE,
		movement_profile
	)
	HexMapDocumentDependencyService.set_shared_dependency(
		document,
		HexMapDocumentDependencyService.KEY_VALIDATION_RULE_SUITE,
		validation_suite
	)
	HexMapDocumentDependencyService.set_shared_dependency(
		document,
		HexMapDocumentDependencyService.KEY_GENERATION_PROFILE,
		generation_profile
	)
	HexMapDocumentDependencyService.set_shared_dependency(
		document,
		HexMapDocumentDependencyService.KEY_EXPORT_PROFILE,
		export_profile
	)

	var hydrated = HexMapDocumentDependencyService.hydrate_dependency_map(document)
	_assert_eq(
		(hydrated[HexMapDocumentDependencyService.KEY_TILE_CATALOG] as Dictionary)["resource"],
		replacement_catalog,
		"RES-10 hydrate returns Tile Catalog resource"
	)
	_assert_eq(
		(hydrated[HexMapDocumentDependencyService.KEY_OBJECT_DATABASE] as Dictionary)["resource"],
		object_database,
		"RES-10 hydrate returns Object DB resource"
	)
	_assert_eq(
		(hydrated[HexMapDocumentDependencyService.KEY_LABEL_DATABASE] as Dictionary)["resource"],
		label_database,
		"RES-10 hydrate returns Label DB resource"
	)
	_assert_eq(
		(hydrated[HexMapDocumentDependencyService.KEY_MOVEMENT_PROFILE] as Dictionary)["resource"],
		movement_profile,
		"RES-10 hydrate returns Movement Profile resource"
	)
	_assert_eq(
		(hydrated[HexMapDocumentDependencyService.KEY_VALIDATION_RULE_SUITE] as Dictionary)["resource"],
		validation_suite,
		"RES-10 hydrate returns Validation Suite resource"
	)
	_assert_eq(
		(hydrated[HexMapDocumentDependencyService.KEY_GENERATION_PROFILE] as Dictionary)["resource"],
		generation_profile,
		"RES-10 hydrate returns Generation Profile resource"
	)
	_assert_eq(
		(hydrated[HexMapDocumentDependencyService.KEY_EXPORT_PROFILE] as Dictionary)["resource"],
		export_profile,
		"RES-10 hydrate returns Export Profile resource"
	)
	_assert_eq(
		String((hydrated[HexMapDocumentDependencyService.KEY_EXPORT_PROFILE] as Dictionary)["source_badge"]),
		HexMapDocumentDependencyService.SOURCE_BADGE_DOCUMENT_DEPENDENCY,
		"RES-10 hydrate preserves Document Dependency source badge"
	)
	_assert_no_issue(
		HexMapDocumentDependencyService.validate_dependencies(document),
		HexMapDocumentValidator.RULE_DEPENDENCY_TYPE_MISMATCH,
		"RES-10 service validation accepts matching shared dependency resources"
	)

	_assert_eq(
		HexMapDocumentDependencyService.remove_shared_dependency(
			document,
			HexMapDocumentDependencyService.KEY_TILE_CATALOG
		),
		true,
		"RES-10 remove shared dependency returns true"
	)
	_assert_eq(
		HexMapDocumentDependencyService.find_shared_dependency(
			document,
			HexMapDocumentDependencyService.KEY_TILE_CATALOG
		),
		null,
		"RES-10 removed shared dependency is not found"
	)
	hydrated = HexMapDocumentDependencyService.hydrate_dependency_map(document)
	_assert_eq(
		bool((hydrated[HexMapDocumentDependencyService.KEY_TILE_CATALOG] as Dictionary)["selected"]),
		false,
		"RES-10 hydrate reports removed dependency as unselected"
	)

	var required_document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	HexMapDocumentDependencyService.set_dependency(
		required_document,
		HexMapDocumentDependencyResource.KIND_TILE_CATALOG,
		null,
		"terrain",
		true
	)
	_assert_has_issue(
		HexMapDocumentDependencyService.validate_dependencies(required_document),
		HexMapDocumentValidator.RULE_DEPENDENCY_MISSING,
		"RES-10 service validation reports missing required dependency"
	)
	HexMapDocumentDependencyService.set_dependency(
		required_document,
		HexMapDocumentDependencyResource.KIND_TILE_CATALOG,
		null,
		"terrain",
		false
	)
	_assert_no_issue(
		HexMapDocumentDependencyService.validate_dependencies(required_document),
		HexMapDocumentValidator.RULE_DEPENDENCY_MISSING,
		"RES-10 service validation accepts missing optional dependency"
	)
	HexMapDocumentDependencyService.set_shared_dependency(
		required_document,
		HexMapDocumentDependencyService.KEY_MOVEMENT_PROFILE,
		HexLabelDatabaseResource.new()
	)
	_assert_has_issue(
		HexMapDocumentDependencyService.validate_dependencies(required_document),
		HexMapDocumentValidator.RULE_DEPENDENCY_TYPE_MISMATCH,
		"RES-10 service validation reports Movement Profile type mismatch"
	)
	var profile_optional_document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var optional_profile_dependency = HexMapDocumentDependencyService.set_shared_dependency(
		profile_optional_document,
		HexMapDocumentDependencyService.KEY_GENERATION_PROFILE,
		null
	)
	_assert_eq(optional_profile_dependency.required, false, "PROFILE-31 Generation Profile dependency defaults to optional")
	_assert_no_issue(
		HexMapDocumentDependencyService.validate_dependencies(profile_optional_document),
		HexMapDocumentValidator.RULE_DEPENDENCY_MISSING,
		"PROFILE-31 service validation accepts missing optional Generation Profile"
	)
	HexMapDocumentDependencyService.set_shared_dependency(
		profile_optional_document,
		HexMapDocumentDependencyService.KEY_VALIDATION_RULE_SUITE,
		Resource.new()
	)
	HexMapDocumentDependencyService.set_shared_dependency(
		profile_optional_document,
		HexMapDocumentDependencyService.KEY_GENERATION_PROFILE,
		Resource.new()
	)
	HexMapDocumentDependencyService.set_shared_dependency(
		profile_optional_document,
		HexMapDocumentDependencyService.KEY_EXPORT_PROFILE,
		Resource.new()
	)
	_assert_has_issue(
		HexMapDocumentDependencyService.validate_dependencies(profile_optional_document),
		HexMapDocumentValidator.RULE_DEPENDENCY_TYPE_MISMATCH,
		"PROFILE-31 service validation rejects generic Resource profile dependencies"
	)


func _test_profile_behavior_resources_roundtrip_schemas() -> void:
	var validation_suite = HexValidationRuleSuiteResource.new()
	validation_suite.suite_id = "strict"
	validation_suite.display_name = "Strict Validation"
	validation_suite.enabled_rule_ids = PackedStringArray(["document.object_on_wall"])
	validation_suite.disabled_rule_ids = PackedStringArray(["document.orphan_payload"])
	validation_suite.severity_overrides = {
		"document.object_on_wall": "error",
	}
	validation_suite.rule_parameters = {
		"document.object_on_wall": {
			"allow_labels": false,
		},
	}
	validation_suite.validation_targets = PackedStringArray(["document", "profiles"])
	validation_suite.fail_fast = true
	var validation_path = _test_resource_path("profile_next_validation_suite.tres")
	var validation_error = ResourceSaver.save(validation_suite, validation_path)
	var loaded_validation = load(validation_path) as HexValidationRuleSuiteResource
	var validation_schema = loaded_validation.behavior_schema()

	_assert_eq(validation_error, OK, "PROFILE-NEXT-10 validation suite saves")
	_assert_eq(String(validation_schema["kind"]), "validation_rule_suite", "PROFILE-NEXT-10 validation schema kind is concrete")
	_assert_eq(loaded_validation.rule_enabled("document.object_on_wall"), true, "PROFILE-NEXT-10 validation schema enables listed rule")
	_assert_eq(loaded_validation.rule_enabled("document.orphan_payload"), false, "PROFILE-NEXT-10 validation schema disables listed rule")
	_assert_eq(loaded_validation.rule_severity("document.object_on_wall"), "error", "PROFILE-NEXT-10 validation schema preserves severity")
	_assert_eq(
		bool(loaded_validation.rule_parameter("document.object_on_wall", "allow_labels", true)),
		false,
		"PROFILE-NEXT-10 validation schema preserves rule parameters"
	)
	_assert_eq(
		(validation_schema["validation_targets"] as PackedStringArray).has("profiles"),
		true,
		"PROFILE-NEXT-10 validation schema preserves target scopes"
	)
	_assert_eq(bool(validation_schema["fail_fast"]), true, "PROFILE-NEXT-10 validation schema preserves fail-fast behavior")

	var generation_profile = HexGenerationProfileResource.new()
	generation_profile.profile_id = "seed_lab"
	generation_profile.display_name = "Seed Lab Generation"
	generation_profile.generator_id = "standard_map"
	generation_profile.default_seed = 42
	generation_profile.seed_policy = "profile_default"
	generation_profile.shape_id = "hexagon"
	generation_profile.width = 9
	generation_profile.height = 7
	generation_profile.radius = 5
	generation_profile.wall_probability = 0.42
	generation_profile.connectivity_mode = "sparse"
	generation_profile.overlay_policy = "uniform_distribution"
	generation_profile.validation_mode = "validate_before_promotion"
	generation_profile.parameters = {"overlay_key": "terrain.forest"}
	var generation_path = _test_resource_path("profile_next_generation_profile.tres")
	var generation_error = ResourceSaver.save(generation_profile, generation_path)
	var loaded_generation = load(generation_path) as HexGenerationProfileResource
	var generation_schema = loaded_generation.behavior_schema()
	var generation_options = loaded_generation.generation_options()

	_assert_eq(generation_error, OK, "PROFILE-NEXT-10 generation profile saves")
	_assert_eq(String(generation_schema["kind"]), "generation_profile", "PROFILE-NEXT-10 generation schema kind is concrete")
	_assert_eq(String(generation_options["shape_id"]), "hexagon", "PROFILE-NEXT-10 generation options preserve shape")
	_assert_eq(int((generation_schema["shape"] as Dictionary)["radius"]), 5, "PROFILE-NEXT-10 generation schema preserves radius")
	_assert_eq(float((generation_schema["terrain"] as Dictionary)["wall_probability"]), 0.42, "PROFILE-NEXT-10 generation schema preserves wall probability")
	_assert_eq(String((generation_schema["terrain"] as Dictionary)["connectivity_mode"]), "sparse", "PROFILE-NEXT-10 generation schema preserves connectivity")
	_assert_eq(String(loaded_generation.parameter_value("overlay_key", "")), "terrain.forest", "PROFILE-NEXT-10 generation schema preserves parameter bag")

	var export_profile = HexExportProfileResource.new()
	export_profile.profile_id = "runtime"
	export_profile.display_name = "Runtime Export"
	export_profile.output_type = "runtime_handoff_resource"
	export_profile.file_extension = ".res"
	export_profile.include_metadata = false
	export_profile.include_validation_summary = true
	export_profile.include_runtime_queries = false
	export_profile.include_debug_report = true
	export_profile.options = {"compression": "none"}
	var export_path = _test_resource_path("profile_next_export_profile.tres")
	var export_error = ResourceSaver.save(export_profile, export_path)
	var loaded_export = load(export_path) as HexExportProfileResource
	var export_schema = loaded_export.behavior_schema()
	var export_options = loaded_export.export_options()

	_assert_eq(export_error, OK, "PROFILE-NEXT-10 export profile saves")
	_assert_eq(String(export_schema["kind"]), "export_profile", "PROFILE-NEXT-10 export schema kind is concrete")
	_assert_eq(String(export_options["file_extension"]), ".res", "PROFILE-NEXT-10 export options preserve file extension")
	_assert_eq(bool(export_schema["include_metadata"]), false, "PROFILE-NEXT-10 export schema preserves metadata inclusion")
	_assert_eq(bool(export_schema["include_validation_summary"]), true, "PROFILE-NEXT-10 export schema preserves validation summary inclusion")
	_assert_eq(bool(export_schema["include_runtime_queries"]), false, "PROFILE-NEXT-10 export schema preserves runtime query flag")
	_assert_eq(String(loaded_export.option_value("compression", "")), "none", "PROFILE-NEXT-10 export schema preserves option bag")


func _test_profile_engine_validation_rule_suite_filters_and_overrides() -> void:
	var data = HexMapData.rectangle(1, 1)
	data.set_walls([HexVector.zero()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_object(document, HexVector.zero(), {"object_id": "blocked_object"})
	HexMapDocumentAdapter.set_label(document, HexVector.q_axis(), {
		"label_id": "orphan_label",
		"text": "Outside",
	})

	var default_result = HexMapDocumentValidator.validate_document(document)
	_assert_has_issue(
		default_result,
		HexMapDocumentValidator.RULE_OBJECT_ON_WALL,
		"PROFILE-NEXT-11 null profile default detects object on wall"
	)
	_assert_has_issue(
		default_result,
		HexMapDocumentValidator.RULE_ORPHAN_PAYLOAD,
		"PROFILE-NEXT-11 null profile default detects orphan payload"
	)
	_assert_eq(
		String(_validation_issue(default_result, HexMapDocumentValidator.RULE_ORPHAN_PAYLOAD).get("severity", "")),
		HexMapValidationResult.SEVERITY_ERROR,
		"PROFILE-NEXT-11 null profile keeps orphan payload default severity"
	)

	var null_profile_result = HexMapDocumentValidator.validate_document(document, {
		"validation_rule_suite": null,
	})
	_assert_has_issue(
		null_profile_result,
		HexMapDocumentValidator.RULE_OBJECT_ON_WALL,
		"PROFILE-NEXT-11 explicit null validation suite preserves object rule"
	)
	_assert_eq(
		String(_validation_issue(null_profile_result, HexMapDocumentValidator.RULE_ORPHAN_PAYLOAD).get("severity", "")),
		HexMapValidationResult.SEVERITY_ERROR,
		"PROFILE-NEXT-11 explicit null validation suite preserves default severity"
	)

	var suite := HexValidationRuleSuiteResource.new()
	suite.disabled_rule_ids = PackedStringArray([HexMapDocumentValidator.RULE_OBJECT_ON_WALL])
	suite.severity_overrides = {
		HexMapDocumentValidator.RULE_ORPHAN_PAYLOAD: HexMapValidationResult.SEVERITY_WARNING,
	}
	var suite_result = HexMapDocumentValidator.validate_document(document, {
		"validation_rule_suite": suite,
	})
	_assert_no_issue(
		suite_result,
		HexMapDocumentValidator.RULE_OBJECT_ON_WALL,
		"PROFILE-NEXT-11 validation suite disables object-on-wall rule"
	)
	_assert_eq(
		String(_validation_issue(suite_result, HexMapDocumentValidator.RULE_ORPHAN_PAYLOAD).get("severity", "")),
		HexMapValidationResult.SEVERITY_WARNING,
		"PROFILE-NEXT-11 validation suite overrides orphan payload severity"
	)
	_assert_eq(
		int(suite_result.summary.get("warnings", 0)) >= 1,
		true,
		"PROFILE-NEXT-11 validation suite refreshes counts after severity override"
	)
	_assert_eq(
		bool(suite_result.summary.get("validation_rule_suite_applied", false)),
		true,
		"PROFILE-NEXT-11 validation suite records engine application"
	)


func _test_hex_map_document_summary_reports_canonical_counts() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentResource.new()

	var terrain_layer = HexMapDocumentTerrainLayerResource.new()
	terrain_layer.map = HexMapResource.from_map_data(data)
	document.terrain_layers.append(terrain_layer)

	var placement = HexMapDocumentObjectPlacementResource.new()
	placement.object_id = "chest"
	placement.cell = Vector3i(1, 0, 0)
	document.object_placements.append(placement)

	var label = HexMapDocumentLabelPlacementResource.new()
	label.label_id = "area"
	label.cell = Vector3i.ZERO
	label.text = "North"
	document.label_placements.append(label)

	var zone = HexMapDocumentZoneResource.new()
	zone.zone_id = "spawn"
	var zone_cells: Array[Vector3i] = [Vector3i.ZERO]
	zone.cells = zone_cells
	document.zones.append(zone)

	var dependency = HexMapDocumentDependencyResource.new()
	dependency.kind = HexMapDocumentDependencyResource.KIND_TILE_SET
	dependency.resource = TileSet.new()
	document.dependencies.append(dependency)

	var summary = HexMapDocumentAdapter.document_summary(document)

	_assert_eq(summary["cells"], 2, "summary reports cells")
	_assert_eq(summary["walls"], 1, "summary reports walls")
	_assert_eq(summary["floors"], 1, "summary reports floors")
	_assert_eq(summary["objects"], 1, "summary reports objects")
	_assert_eq(summary["labels"], 1, "summary reports labels")
	_assert_eq(summary["zones"], 1, "summary reports zones")
	_assert_eq(summary["dependencies"], 1, "summary reports dependencies")
	_assert_eq(summary["warnings"], 0, "summary reports warning count")


func _test_hex_map_validation_result_serializes_summary_and_warnings() -> void:
	var document = HexMapDocumentResource.new()
	var result = HexMapDocumentAdapter.validation_result_for_document(document)
	var null_result = HexMapDocumentAdapter.validation_result_for_document(null)
	var path = _test_resource_path("test_hex_map_validation_result.tres")
	var error = ResourceSaver.save(result, path)
	var loaded = load(path)

	_assert_eq(result is HexMapValidationResult, true, "validation helper returns validation result resource")
	_assert_eq(result.warning_count(), 2, "validation result counts warnings")
	_assert_eq(result.error_count(), 0, "validation result has no errors for empty document")
	_assert_eq(result.summary["warnings"], 2, "validation summary reports warnings")
	_assert_eq(result.issues[0]["rule_id"], "document.map_missing", "validation result records missing map warning")
	_assert_eq(result.issues[1]["scope"], HexMapValidationResult.SCOPE_DEPENDENCY, "validation result records dependency scope")
	_assert_eq(null_result.error_count(), 1, "null validation result reports missing document error")
	_assert_eq(error, OK, "validation result saves")
	_assert_eq(loaded is HexMapValidationResult, true, "validation result loads as typed resource")
	_assert_eq(loaded.warning_count(), 2, "loaded validation result counts warnings")
	_assert_eq(loaded.summary["warnings"], 2, "loaded validation result preserves summary")
	_assert_eq(loaded.issues[1]["rule_id"], "document.dependencies_empty", "loaded validation result preserves issues")


func _test_hex_generation_result_resource_serializes_scope_and_replay() -> void:
	var data = HexMapData.rectangle(2, 1)
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	var validation_result = HexMapDocumentValidator.validate_document(document)
	var result_resource := HexGenerationResultResource.new()
	result_resource.result_id = "seed_42_index_0"
	result_resource.seed = 42
	result_resource.status = "generated"
	result_resource.score = 1002.5
	result_resource.primary_map = HexMapResource.from_map_data(data)
	result_resource.candidate_document = document
	result_resource.validation_result = validation_result
	result_resource.validation_summary = {
		"validated": true,
		"passed": validation_result.error_count() == 0,
		"errors": validation_result.error_count(),
		"warnings": validation_result.warning_count(),
	}
	result_resource.generation_snapshot = {
		"seed": 42,
		"rect_width": 2,
		"rect_height": 1,
	}
	result_resource.source_snapshot = result_resource.generation_snapshot.duplicate(true)
	result_resource.score_row = {
		"seed": 42,
		"score": 1002.5,
	}
	result_resource.preview = {
		"available": true,
		"source_kind": "map_data",
		"cell_count": 2,
	}
	result_resource.metadata = {
		"source_context": "test",
	}

	var scope = result_resource.scope_snapshot()
	_assert_eq(result_resource.can_replay(), true, "generation result can replay generated candidate")
	_assert_eq(bool(scope["primary_map_present"]), true, "generation result scope includes primary map")
	_assert_eq(bool(scope["candidate_document_present"]), true, "generation result scope includes candidate document")
	_assert_eq(bool(scope["validation_result_present"]), true, "generation result scope includes validation result")
	_assert_eq(bool(scope["preview_available"]), true, "generation result scope includes preview availability")
	var replayed = result_resource.replay_document()
	_assert_eq(replayed is HexMapDocumentResource, true, "generation result replays to document resource")
	_assert_eq(
		(replayed as HexMapDocumentResource).terrain_layers[0].map.to_map_data().cells.size(),
		2,
		"generation result replay preserves candidate map"
	)
	var row = result_resource.to_score_row()
	_assert_eq(String(row["generation_result_id"]), "seed_42_index_0", "generation result score row exposes result id")
	_assert_eq(row["generation_result"], result_resource, "generation result score row keeps resource reference")
	_assert_eq(bool(row["replay_available"]), true, "generation result score row exposes replay availability")

	var path = _test_resource_path("test_generation_result_resource.tres")
	var error = ResourceSaver.save(result_resource, path)
	var loaded = load(path)
	_assert_eq(error, OK, "generation result resource saves")
	_assert_eq(loaded is HexGenerationResultResource, true, "generation result resource loads as typed resource")
	_assert_eq(String(loaded.result_id), "seed_42_index_0", "loaded generation result keeps result id")
	_assert_eq(loaded.replay_document() is HexMapDocumentResource, true, "loaded generation result replays document")


func _test_hex_map_document_validator_reports_core_rules() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_tile_override(document, HexVector.apply_basis(3, 0, 0), {
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 1,
		"atlas_coords": Vector2i(0, 0),
	})
	HexMapDocumentAdapter.set_label(document, HexVector.apply_basis(4, 0, 0), {
		"label_id": "orphan",
		"text": "Outside",
	})
	HexMapDocumentAdapter.set_object(document, HexVector.q_axis(), {"object_id": "chest"})
	var dependency = HexMapDocumentDependencyResource.new()
	dependency.dependency_id = "missing-catalog"
	dependency.kind = HexMapDocumentDependencyResource.KIND_TILE_CATALOG
	document.dependencies.append(dependency)

	var result = HexMapDocumentValidator.validate_document(document)
	_assert_has_issue(result, "document.payload_outside_map", "validator detects tile payload outside map")
	_assert_has_issue(result, "document.orphan_payload", "validator detects orphan label payload")
	_assert_has_issue(result, "document.dependency_missing", "validator detects missing dependency resource")
	_assert_has_issue(result, "document.object_on_wall", "validator detects object on wall")
	_assert_eq(result.error_count() >= 4, true, "validator reports core document errors")

	var catalog_document = HexMapDocumentResource.new()
	var catalog_terrain = HexMapDocumentTerrainLayerResource.new()
	catalog_terrain.map = HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	catalog_terrain.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"catalog_key": "terrain.floor",
		"source_id": 0,
		"atlas_coords": Vector2i.ZERO,
	})
	catalog_document.terrain_layers.append(catalog_terrain)
	var missing_catalog_result = HexMapDocumentValidator.validate_document(catalog_document)
	_assert_has_issue(missing_catalog_result, "document.catalog_missing", "validator detects missing catalog resource")

	var catalog = HexTileCatalogResource.new()
	var missing_tile = HexTileCatalogEntry.new()
	missing_tile.key = "terrain.floor"
	missing_tile.entry_type = HexTileCatalogEntry.TYPE_ATLAS
	missing_tile.source_id = 99
	missing_tile.atlas_coords = Vector2i.ZERO
	catalog.add_entry(missing_tile)
	var tile_set = TileSet.new()
	HexMapTileAdapter.configure_sample_tile_set(tile_set)
	var missing_tile_result = HexMapDocumentValidator.validate_document(catalog_document, {
		"tile_catalog": catalog,
		"tile_set": tile_set,
	})
	_assert_has_issue(missing_tile_result, "document.tile_missing", "validator detects missing catalog tile")


func _test_hex_map_document_validator_reports_phase_progress() -> void:
	var data = HexMapData.rectangle(12, 12)
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	for index in range(min(12, data.cells.size())):
		HexMapDocumentAdapter.set_tile_override(document, data.cells[index], {
			"kind": HexMapDocumentAdapter.KIND_FLOOR,
			"catalog_key": "terrain.floor.%d" % index,
		})
	var recorder := ValidationProgressRecorder.new()
	var result = HexMapDocumentValidator.validate_document(document, {
		"progress_callback": Callable(recorder, "record"),
	})
	var events := recorder.events
	_assert_eq(events.size() >= 8, true, "validator reports progress for each validation phase")
	_assert_eq(
		String(events[0].get("phase", "")),
		HexMapDocumentValidator.VALIDATION_PHASE_PREPARE,
		"validator progress starts with prepare phase"
	)
	var last_event := events[events.size() - 1]
	_assert_eq(
		String(last_event.get("phase", "")),
		HexMapDocumentValidator.VALIDATION_PHASE_COMPLETE,
		"validator progress ends with complete phase"
	)
	_assert_eq(float(last_event.get("progress", 0.0)), 1.0, "validator final progress is complete")
	_assert_eq(int(last_event.get("cells", 0)), data.cells.size(), "validator progress reports large-map cell count")
	_assert_eq(
		int(result.summary.get("validation_progress_event_count", 0)),
		events.size(),
		"validator summary stores progress event count"
	)
	_assert_eq(
		String(result.summary.get("validation_progress_phase", "")),
		HexMapDocumentValidator.VALIDATION_PHASE_COMPLETE,
		"validator summary stores final progress phase"
	)
	var previous_progress := -1.0
	var saw_tiles := false
	var saw_dependencies := false
	var saw_reachability := false
	for event in events:
		var progress := float(event.get("progress", 0.0))
		_assert_eq(progress >= previous_progress, true, "validator progress is monotonic")
		previous_progress = progress
		var phase := String(event.get("phase", ""))
		if phase == HexMapDocumentValidator.VALIDATION_PHASE_TILE_ENTRIES:
			saw_tiles = true
		if phase == HexMapDocumentValidator.VALIDATION_PHASE_DEPENDENCIES:
			saw_dependencies = true
		if phase == HexMapDocumentValidator.VALIDATION_PHASE_PROFILE_REACHABILITY:
			saw_reachability = true
	_assert_eq(saw_tiles, true, "validator progress reports tile traversal phase")
	_assert_eq(saw_dependencies, true, "validator progress reports dependency traversal phase")
	_assert_eq(saw_reachability, true, "validator progress reports reachability traversal phase")


func _test_hex_map_document_validator_rule_matrix() -> void:
	var outside_tile_document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	HexMapDocumentAdapter.set_tile_override(outside_tile_document, HexVector.q_axis(), {
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 0,
		"atlas_coords": Vector2i.ZERO,
	})
	_assert_has_issue(
		HexMapDocumentValidator.validate_document(outside_tile_document),
		"document.payload_outside_map",
		"rule matrix detects outside tile payload"
	)
	var inside_tile_document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	HexMapDocumentAdapter.set_tile_override(inside_tile_document, HexVector.zero(), {
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 0,
		"atlas_coords": Vector2i.ZERO,
	})
	_assert_no_issue(
		HexMapDocumentValidator.validate_document(inside_tile_document),
		"document.payload_outside_map",
		"rule matrix accepts in-map tile payload"
	)

	var orphan_label_document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	HexMapDocumentAdapter.set_label(orphan_label_document, HexVector.q_axis(), {
		"label_id": "outside",
		"text": "Outside",
	})
	_assert_has_issue(
		HexMapDocumentValidator.validate_document(orphan_label_document),
		"document.orphan_payload",
		"rule matrix detects orphan label payload"
	)
	var attached_label_document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	HexMapDocumentAdapter.set_label(attached_label_document, HexVector.zero(), {
		"label_id": "inside",
		"text": "Inside",
	})
	_assert_no_issue(
		HexMapDocumentValidator.validate_document(attached_label_document),
		"document.orphan_payload",
		"rule matrix accepts attached label payload"
	)

	var catalog_document = _catalog_key_document("terrain.floor")
	_assert_has_issue(
		HexMapDocumentValidator.validate_document(catalog_document),
		"document.catalog_missing",
		"rule matrix detects missing catalog"
	)
	var valid_catalog = _catalog_with_atlas_entry("terrain.floor", 0, Vector2i.ZERO)
	_assert_no_issue(
		HexMapDocumentValidator.validate_document(catalog_document, {"tile_catalog": valid_catalog}),
		"document.catalog_missing",
		"rule matrix accepts provided catalog"
	)

	var tile_set = TileSet.new()
	HexMapTileAdapter.configure_sample_tile_set(tile_set)
	var missing_tile_catalog = _catalog_with_atlas_entry("terrain.floor", 99, Vector2i.ZERO)
	_assert_has_issue(
		HexMapDocumentValidator.validate_document(catalog_document, {
			"tile_catalog": missing_tile_catalog,
			"tile_set": tile_set,
		}),
		"document.tile_missing",
		"rule matrix detects missing catalog tile"
	)
	_assert_no_issue(
		HexMapDocumentValidator.validate_document(catalog_document, {
			"tile_catalog": valid_catalog,
			"tile_set": tile_set,
		}),
		"document.tile_missing",
		"rule matrix accepts present catalog tile"
	)

	var missing_dependency_document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var missing_dependency = HexMapDocumentDependencyResource.new()
	missing_dependency.dependency_id = "missing"
	missing_dependency_document.dependencies.append(missing_dependency)
	_assert_has_issue(
		HexMapDocumentValidator.validate_document(missing_dependency_document),
		"document.dependency_missing",
		"rule matrix detects missing required dependency"
	)
	var optional_dependency_document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var optional_dependency = HexMapDocumentDependencyResource.new()
	optional_dependency.dependency_id = "optional-missing"
	optional_dependency.required = false
	optional_dependency_document.dependencies.append(optional_dependency)
	_assert_no_issue(
		HexMapDocumentValidator.validate_document(optional_dependency_document),
		"document.dependency_missing",
		"rule matrix accepts optional missing dependency"
	)
	var mismatch_dependency_document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	)
	var mismatch_dependency = HexMapDocumentDependencyResource.new()
	mismatch_dependency.kind = HexMapDocumentDependencyResource.KIND_TILE_SET
	mismatch_dependency.resource = HexLabelDatabaseResource.new()
	mismatch_dependency_document.dependencies.append(mismatch_dependency)
	_assert_has_issue(
		HexMapDocumentValidator.validate_document(mismatch_dependency_document),
		HexMapDocumentValidator.RULE_DEPENDENCY_TYPE_MISMATCH,
		"rule matrix detects dependency type mismatch"
	)

	var wall_data = HexMapData.rectangle(2, 1)
	wall_data.set_walls([HexVector.q_axis()])
	var object_on_wall_document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(wall_data))
	HexMapDocumentAdapter.set_object(object_on_wall_document, HexVector.q_axis(), {"object_id": "chest"})
	_assert_has_issue(
		HexMapDocumentValidator.validate_document(object_on_wall_document),
		"document.object_on_wall",
		"rule matrix detects object on wall"
	)
	var object_on_floor_document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(wall_data))
	HexMapDocumentAdapter.set_object(object_on_floor_document, HexVector.zero(), {"object_id": "chest"})
	_assert_no_issue(
		HexMapDocumentValidator.validate_document(object_on_floor_document),
		"document.object_on_wall",
		"rule matrix accepts object on floor"
	)

	var object_scene = _test_packed_scene("RuleMatrixObjectScene")

	var missing_scene_database = HexObjectDatabaseResource.new()
	var missing_scene_definition = HexObjectDefinitionResource.new()
	missing_scene_definition.id = "missing-scene-object"
	missing_scene_database.add_definition(missing_scene_definition)
	var missing_scene_document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(HexMapData.rectangle(1, 1)))
	HexMapDocumentAdapter.set_object(missing_scene_document, HexVector.zero(), {"object_id": "missing-scene-object"})
	_assert_has_issue(
		HexMapDocumentValidator.validate_document(missing_scene_document, {"object_database": missing_scene_database}),
		HexMapDocumentValidator.RULE_OBJECT_SCENE_MISSING,
		"rule matrix detects missing object scene"
	)
	missing_scene_definition.scene = object_scene
	missing_scene_database.add_definition(missing_scene_definition)
	_assert_no_issue(
		HexMapDocumentValidator.validate_document(missing_scene_document, {"object_database": missing_scene_database}),
		HexMapDocumentValidator.RULE_OBJECT_SCENE_MISSING,
		"rule matrix accepts present object scene"
	)

	var unique_database = HexObjectDatabaseResource.new()
	var unique_definition = HexObjectDefinitionResource.new()
	unique_definition.id = "boss"
	unique_definition.scene = object_scene
	unique_definition.default_properties = {"unique": true}
	unique_database.add_definition(unique_definition)
	var duplicate_unique_document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(HexMapData.rectangle(2, 1)))
	HexMapDocumentAdapter.set_object(duplicate_unique_document, HexVector.zero(), {"object_id": "boss"})
	HexMapDocumentAdapter.set_object(duplicate_unique_document, HexVector.q_axis(), {"object_id": "boss"})
	_assert_has_issue(
		HexMapDocumentValidator.validate_document(duplicate_unique_document, {"object_database": unique_database}),
		HexMapDocumentValidator.RULE_OBJECT_DUPLICATE_UNIQUE,
		"rule matrix detects duplicate unique object"
	)
	unique_definition.default_properties = {}
	unique_database.add_definition(unique_definition)
	_assert_no_issue(
		HexMapDocumentValidator.validate_document(duplicate_unique_document, {"object_database": unique_database}),
		HexMapDocumentValidator.RULE_OBJECT_DUPLICATE_UNIQUE,
		"rule matrix accepts duplicate non-unique object"
	)


func _test_hex_map_document_validator_profile_reachability() -> void:
	var data = HexMapData.rectangle(3, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_label(document, HexVector.zero(), {
		"label_id": "start",
		"text": "Start",
	})
	HexMapDocumentAdapter.set_label(document, HexVector.q_axis().scaled(2), {
		"label_id": "goal",
		"text": "Goal",
	})

	var ground_profile = HexMovementProfileResource.new()
	ground_profile.profile_id = "ground"
	var no_profile_result = HexMapDocumentValidator.validate_document(document)
	_assert_no_issue(
		no_profile_result,
		HexMapDocumentValidator.RULE_PROFILE_REACHABILITY,
		"profile reachability is opt-in without movement profile"
	)
	var unreachable_result = HexMapDocumentValidator.validate_document(document, {
		"movement_profile": ground_profile,
	})
	_assert_has_issue(
		unreachable_result,
		HexMapDocumentValidator.RULE_PROFILE_REACHABILITY,
		"profile reachability detects disconnected important points"
	)
	var unreachable_issue = _validation_issue(
		unreachable_result,
		HexMapDocumentValidator.RULE_PROFILE_REACHABILITY,
		"unreachable"
	)
	_assert_eq(
		String(unreachable_issue.get("metadata", {}).get("profile_id", "")),
		"ground",
		"profile reachability issue reports profile id"
	)

	var passable_wall_profile = HexMovementProfileResource.new()
	passable_wall_profile.profile_id = "passable-wall"
	passable_wall_profile.wall_passable = true
	passable_wall_profile.wall_cost = 1.0
	_assert_no_issue(
		HexMapDocumentValidator.validate_document(document, {
			"movement_profile": passable_wall_profile,
		}),
		HexMapDocumentValidator.RULE_PROFILE_REACHABILITY,
		"profile reachability accepts passable-wall profile"
	)

	var blocked_document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_label(blocked_document, HexVector.zero(), {
		"label_id": "start",
		"text": "Start",
	})
	HexMapDocumentAdapter.set_label(blocked_document, HexVector.q_axis(), {
		"label_id": "wall",
		"text": "Wall",
	})
	var blocked_result = HexMapDocumentValidator.validate_document(blocked_document, {
		"movement_profiles": [ground_profile],
	})
	_assert_has_issue(
		blocked_result,
		HexMapDocumentValidator.RULE_PROFILE_REACHABILITY,
		"profile reachability detects blocked important point"
	)
	var blocked_issue = _validation_issue(
		blocked_result,
		HexMapDocumentValidator.RULE_PROFILE_REACHABILITY,
		"blocked"
	)
	_assert_eq(
		String(blocked_issue.get("metadata", {}).get("profile_id", "")),
		"ground",
		"blocked profile reachability issue reports profile id"
	)
	_assert_eq(
		(blocked_issue.get("metadata", {}).get("blockers", []) as Array).has("wall"),
		true,
		"blocked profile reachability issue records blocker keys"
	)


func _catalog_key_document(catalog_key: String) -> HexMapDocumentResource:
	var document = HexMapDocumentResource.new()
	var terrain_layer = HexMapDocumentTerrainLayerResource.new()
	terrain_layer.map = HexMapResource.from_map_data(HexMapData.rectangle(1, 1))
	terrain_layer.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"catalog_key": catalog_key,
		"source_id": 0,
		"atlas_coords": Vector2i.ZERO,
	})
	document.terrain_layers.append(terrain_layer)
	return document


func _catalog_with_atlas_entry(key: String, source_id: int, atlas_coords: Vector2i) -> HexTileCatalogResource:
	var catalog = HexTileCatalogResource.new()
	var entry = HexTileCatalogEntry.new()
	entry.key = key
	entry.entry_type = HexTileCatalogEntry.TYPE_ATLAS
	entry.source_id = source_id
	entry.atlas_coords = atlas_coords
	catalog.add_entry(entry)
	return catalog


func _test_hex_movement_profile_resource_roundtrips_gameplay_defaults() -> void:
	var profile = HexMovementProfileResource.new()
	profile.profile_id = "tactics"
	profile.display_name = "Tactics"
	profile.default_cost = 1.25
	profile.wall_passable = true
	profile.wall_cost = 5.0
	profile.terrain_costs = {"terrain.road": 0.5}
	profile.blocker_keys = PackedStringArray(["object.crate"])
	profile.blocker_tags = PackedStringArray(["blocking"])
	var path = _test_resource_path("test_hex_movement_profile.tres")
	var error = ResourceSaver.save(profile, path)
	var loaded = load(path) as HexMovementProfileResource

	_assert_eq(error, OK, "movement profile resource saves")
	_assert_eq(loaded.profile_id, "tactics", "movement profile resource preserves id")
	_assert_eq(loaded.display_name, "Tactics", "movement profile resource preserves display name")
	_assert_eq(float(loaded.default_cost), 1.25, "movement profile resource preserves default cost")
	_assert_eq(float(loaded.cell_state("terrain", "terrain.road")["cost"]), 0.5, "movement profile resource resolves catalog cost")
	_assert_eq(bool(loaded.cell_state("wall")["passable"]), true, "movement profile resource preserves passable wall default")
	_assert_eq(
		bool(loaded.cell_state("floor", "object.crate")["passable"]),
		false,
		"movement profile resource preserves blocker keys"
	)


func _test_hex_gameplay_layer_data_uses_profile_catalog_and_objects() -> void:
	var data = HexMapData.rectangle(3, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentResource.new()
	var terrain_layer = HexMapDocumentTerrainLayerResource.new()
	terrain_layer.map = HexMapResource.from_map_data(data)
	terrain_layer.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"catalog_key": "terrain.road",
		"source_id": 0,
		"atlas_coords": Vector2i.ZERO,
	})
	terrain_layer.tile_assignments.append({
		"cell": Vector3i(2, 0, 0),
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"catalog_key": "terrain.water",
		"source_id": 0,
		"atlas_coords": Vector2i.ZERO,
	})
	document.terrain_layers.append(terrain_layer)
	HexMapDocumentAdapter.set_object(document, HexVector.zero(), {"object_id": "object.crate"})
	var catalog = HexTileCatalogResource.new()
	catalog.add_entry(_test_catalog_entry("terrain.road", 0, Vector2i.ZERO, ["road", "cost:2"]))
	catalog.add_entry(_test_catalog_entry("terrain.water", 0, Vector2i.ZERO, ["blocking"]))

	var profile = HexMovementProfileResource.new()
	profile.default_cost = 1.0
	profile.blocker_keys = PackedStringArray(["object.crate"])
	profile.blocker_tags = PackedStringArray(["blocking"])
	var gameplay = HexGameplayLayerData.from_document(document, profile, catalog)
	var map_gameplay = HexGameplayLayerData.from_map_data(data, profile)

	_assert_eq(map_gameplay.has_cell(HexVector.q_axis()), true, "gameplay layer data includes map wall cell")
	_assert_eq(map_gameplay.is_passable(HexVector.q_axis()), false, "gameplay layer data blocks map walls by default")
	_assert_eq(gameplay.has_cell(HexVector.zero()), true, "gameplay layer data includes document floor cell")
	_assert_eq(gameplay.is_passable(HexVector.zero()), false, "gameplay layer data applies object blocker key")
	_assert_eq(gameplay.blocker_keys(HexVector.zero()).has("object.crate"), true, "gameplay layer data records object blocker")
	_assert_eq(float(gameplay.movement_cost(HexVector.zero())), 2.0, "gameplay layer data applies catalog cost tag")
	_assert_eq(gameplay.is_passable(HexVector.q_axis()), false, "gameplay layer data keeps wall blocked")
	_assert_eq(gameplay.blocker_keys(HexVector.q_axis()).has("wall"), true, "gameplay layer data records wall blocker")
	_assert_eq(gameplay.is_passable(HexVector.q_axis().scaled(2)), false, "gameplay layer data applies blocking catalog tag")
	_assert_eq(
		gameplay.blocker_keys(HexVector.q_axis().scaled(2)).has("blocking"),
		true,
		"gameplay layer data records catalog tag blocker"
	)


func _test_hex_map_document_adapter_roundtrips_canonical_payload_entries() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentResource.new()

	var terrain_layer = HexMapDocumentTerrainLayerResource.new()
	terrain_layer.map = HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_POINTY_TOP)
	terrain_layer.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 4,
		"atlas_coords": Vector2i(1, 0),
	})
	document.terrain_layers.append(terrain_layer)

	var overlay_layer = HexMapDocumentOverlayLayerResource.new()
	overlay_layer.item_key = "Treasure"
	overlay_layer.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"source_id": 5,
		"atlas_coords": Vector2i(2, 0),
	})
	document.overlay_layers.append(overlay_layer)

	var placement = HexMapDocumentObjectPlacementResource.new()
	placement.placement_id = "chest-003"
	placement.object_id = "chest"
	placement.cell = Vector3i.ZERO
	placement.rotation_degrees = 15.0
	placement.variant = "small"
	placement.properties = {"gold": 3}
	placement.spawn_condition = "always"
	placement.layer_id = "props"
	placement.metadata = {"unique": false}
	document.object_placements.append(placement)

	var label = HexMapDocumentLabelPlacementResource.new()
	label.label_id = "area"
	label.cell = Vector3i.ZERO
	label.text = "North"
	document.label_placements.append(label)

	var map_resource = HexMapDocumentAdapter.to_map_resource(document)
	var tile_entries = HexMapDocumentAdapter.document_tile_entries(document)
	var object_entries = HexMapDocumentAdapter.document_object_entries(document)
	var label_entries = HexMapDocumentAdapter.document_label_entries(document)
	var copy = HexMapDocumentAdapter.duplicate_document(document)

	_assert_keys_eq(map_resource.to_map_data().cells, data.cells, "document adapter map resource preserves cells")
	_assert_keys_eq(map_resource.to_map_data().walls, data.walls, "document adapter map resource preserves walls")
	_assert_eq(map_resource.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "document adapter map resource preserves orientation")
	_assert_eq(tile_entries.size(), 2, "document adapter exposes terrain and overlay tile entries")
	_assert_eq(tile_entries[0]["atlas_coords"], Vector2i(1, 0), "document adapter exposes terrain tile assignment")
	_assert_eq(tile_entries[1]["kind"], HexMapDocumentAdapter.KIND_OVERLAY, "document adapter marks overlay assignment kind")
	_assert_eq(tile_entries[1]["item_key"], "Treasure", "document adapter fills overlay item key from layer")
	_assert_eq(object_entries[0]["object_id"], "chest", "document adapter exposes object placement")
	_assert_eq(object_entries[0]["properties"]["gold"], 3, "document adapter preserves object properties")
	_assert_eq(object_entries[0]["placement_id"], "chest-003", "document adapter exposes object placement id")
	_assert_eq(object_entries[0]["rotation_degrees"], 15.0, "document adapter exposes object rotation")
	_assert_eq(object_entries[0]["rotation"], 15.0, "document adapter exposes object rotation alias")
	_assert_eq(object_entries[0]["variant"], "small", "document adapter exposes object variant")
	_assert_eq(object_entries[0]["spawn_condition"], "always", "document adapter exposes object spawn condition")
	_assert_eq(object_entries[0]["layer_id"], "props", "document adapter exposes object layer id")
	_assert_eq(object_entries[0]["metadata"]["unique"], false, "document adapter exposes object metadata")
	_assert_eq(label_entries[0]["text"], "North", "document adapter exposes label placement")
	_assert_eq(copy.terrain_layers[0] is HexMapDocumentTerrainLayerResource, true, "duplicate preserves typed terrain layer")
	_assert_keys_eq(copy.terrain_layers[0].map.to_map_data().cells, data.cells, "duplicate preserves terrain map cells")
	_assert_eq(copy.terrain_layers[0].map.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "duplicate preserves terrain map orientation")
	_assert_eq(copy.object_placements[0] is HexMapDocumentObjectPlacementResource, true, "duplicate preserves typed object placement")


func _test_hex_map_document_object_placement_schema_mutates_and_cleans_deleted_cell() -> void:
	var data = HexMapData.rectangle(2, 1)
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))

	HexMapDocumentAdapter.set_object(document, HexVector.q_axis(), {
		"object_id": "chest",
		"placement_id": "chest-placed",
		"rotation_degrees": 120.0,
		"variant": "rare",
		"properties": {"gold": 13},
		"spawn_condition": "flag:opened_gate",
		"layer_id": "props",
		"runtime_enabled": false,
		"metadata": {"unique": true},
	})
	var entries = HexMapDocumentAdapter.document_object_entries(document)

	_assert_eq(document.object_placements.size(), 1, "object placement mutation creates typed placement")
	_assert_eq(entries[0]["object_id"], "chest", "object placement entry has object id")
	_assert_eq(entries[0]["cell"], Vector3i(1, 0, 0), "object placement entry has cell")
	_assert_eq(entries[0]["rotation_degrees"], 120.0, "object placement entry has rotation")
	_assert_eq(entries[0]["rotation"], 120.0, "object placement entry has rotation alias")
	_assert_eq(entries[0]["variant"], "rare", "object placement entry has variant")
	_assert_eq(entries[0]["properties"]["gold"], 13, "object placement entry has properties")
	_assert_eq(entries[0]["spawn_condition"], "flag:opened_gate", "object placement entry has spawn condition")
	_assert_eq(document.object_placements[0].placement_id, "chest-placed", "typed object placement has placement id")
	_assert_eq(document.object_placements[0].rotation_degrees, 120.0, "typed object placement has rotation")
	_assert_eq(document.object_placements[0].variant, "rare", "typed object placement has variant")
	_assert_eq(document.object_placements[0].spawn_condition, "flag:opened_gate", "typed object placement has spawn condition")
	_assert_eq(document.object_placements[0].layer_id, "props", "typed object placement has layer id")
	_assert_eq(document.object_placements[0].runtime_enabled, false, "typed object placement has runtime flag")
	_assert_eq(document.object_placements[0].metadata["unique"], true, "typed object placement has metadata")
	var path = _test_resource_path("test_hex_map_document_object_placement_schema.tres")
	var error = ResourceSaver.save(document, path)
	var loaded = load(path)
	_assert_eq(error, OK, "object placement schema document saves")
	_assert_eq(loaded.object_placements[0].rotation_degrees, 120.0, "object placement schema roundtrip preserves rotation")
	_assert_eq(loaded.object_placements[0].spawn_condition, "flag:opened_gate", "object placement schema roundtrip preserves spawn condition")

	HexMapDocumentAdapter.set_cell_exists(document, HexVector.q_axis(), false)
	_assert_eq(document.object_placements.size(), 0, "object placement schema cleanup removes typed placement")


func _test_hex_map_document_adapter_cleans_canonical_payloads_for_deleted_cell() -> void:
	var data = HexMapData.rectangle(2, 1)
	var deleted = HexVector.q_axis()
	var document = HexMapDocumentResource.new()

	var terrain_layer = HexMapDocumentTerrainLayerResource.new()
	terrain_layer.map = HexMapResource.from_map_data(data)
	terrain_layer.tile_assignments.append({
		"cell": Vector3i(1, 0, 0),
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 4,
		"atlas_coords": Vector2i(1, 0),
	})
	document.terrain_layers.append(terrain_layer)

	var overlay_layer = HexMapDocumentOverlayLayerResource.new()
	overlay_layer.item_key = "Treasure"
	overlay_layer.tile_assignments.append({
		"cell": Vector3i(1, 0, 0),
		"source_id": 5,
		"atlas_coords": Vector2i(2, 0),
	})
	document.overlay_layers.append(overlay_layer)

	var placement = HexMapDocumentObjectPlacementResource.new()
	placement.object_id = "chest"
	placement.cell = Vector3i(1, 0, 0)
	document.object_placements.append(placement)

	var label = HexMapDocumentLabelPlacementResource.new()
	label.label_id = "area"
	label.cell = Vector3i(1, 0, 0)
	label.text = "East"
	document.label_placements.append(label)

	var zone = HexMapDocumentZoneResource.new()
	zone.zone_id = "east"
	var zone_cells: Array[Vector3i] = [Vector3i(1, 0, 0)]
	zone.cells = zone_cells
	document.zones.append(zone)

	HexMapDocumentAdapter.set_cell_exists(document, deleted, false)

	_assert_eq(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_cell(deleted), false, "canonical delete removes map cell")
	_assert_eq(document.terrain_layers[0].tile_assignments.size(), 0, "canonical delete removes terrain tile assignment")
	_assert_eq(document.overlay_layers[0].tile_assignments.size(), 0, "canonical delete removes overlay tile assignment")
	_assert_eq(document.object_placements.size(), 0, "canonical delete removes object placement")
	_assert_eq(document.label_placements.size(), 0, "canonical delete removes label placement")
	_assert_eq(document.zones.size(), 0, "canonical delete removes empty zone")


func _test_hex_map_document_adapter_updates_wall_floor() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)

	HexMapDocumentAdapter.set_wall(document, HexVector.zero(), true)
	_assert_eq(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), true, "document adapter sets wall")
	HexMapDocumentAdapter.set_wall(document, HexVector.zero(), false)
	_assert_eq(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_wall(HexVector.zero()), false, "document adapter clears wall")

	var new_cell = HexVector.q_axis().scaled(2)
	HexMapDocumentAdapter.set_cell_exists(document, new_cell, true)
	_assert_eq(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_cell(new_cell), true, "document adapter adds shape cell")
	HexMapDocumentAdapter.set_tile_override(document, HexVector.q_axis(), {
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 8,
		"atlas_coords": Vector2i(4, 5),
	})
	HexMapDocumentAdapter.set_object(document, HexVector.q_axis(), {"object_id": "chest"})
	HexMapDocumentAdapter.set_label(document, HexVector.q_axis(), {
		"label_id": "area",
		"text": "North Gate",
	})
	HexMapDocumentAdapter.set_cell_exists(document, HexVector.q_axis(), false)
	_assert_eq(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_cell(HexVector.q_axis()), false, "document adapter removes shape cell")
	_assert_eq(document.terrain_layers[0].tile_assignments.size(), 0, "document adapter removes tile assignments for deleted shape cell")
	_assert_eq(document.object_placements.size(), 0, "document adapter removes objects for deleted shape cell")
	_assert_eq(document.label_placements.size(), 0, "document adapter removes labels for deleted shape cell")


func _test_hex_map_document_adapter_applies_tile_overrides() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	document.terrain_layers[0].default_floor_key = "terrain.floor"
	document.terrain_layers[0].default_wall_key = "terrain.wall"
	HexMapDocumentAdapter.set_tile_override(document, HexVector.zero(), {
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"catalog_key": "terrain.stone",
	})
	var layer = TileMapLayer.new()

	HexMapDocumentAdapter.apply_to_tile_map_layer(document, layer, {"tile_catalog": _test_tile_catalog()})

	_assert_eq(layer.get_cell_source_id(Vector2i.ZERO), 7, "document adapter applies floor catalog override source")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(3, 0), "document adapter applies floor catalog override atlas")
	_assert_eq(layer.get_cell_source_id(Vector2i(1, 0)), 5, "document adapter applies default wall catalog source")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i(1, 0)), Vector2i(1, 0), "document adapter applies default wall catalog atlas")
	layer.free()


func _test_hex_map_document_validator_reports_missing_catalog_assignments() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_tile_override(document, HexVector.zero(), {
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 8,
		"atlas_coords": Vector2i(4, 5),
	})
	var layer = TileMapLayer.new()
	HexMapDocumentAdapter.apply_to_tile_map_layer(document, layer)
	_assert_eq(layer.get_cell_source_id(Vector2i.ZERO), -1, "catalogless document apply does not draw numeric tile assignment")
	_assert_eq(layer.get_cell_source_id(Vector2i(1, 0)), -1, "catalogless document apply does not draw numeric wall default")
	var result = HexMapDocumentValidator.validate_document(document)
	_assert_has_issue(result, HexMapDocumentValidator.RULE_TILE_ASSIGNMENT_MISSING, "validator reports missing catalog assignments")
	layer.free()

	var canonical_document = HexMapDocumentResource.new()
	var terrain_layer = HexMapDocumentTerrainLayerResource.new()
	terrain_layer.map = HexMapResource.from_map_data(data)
	terrain_layer.default_floor_key = "terrain.floor"
	terrain_layer.default_wall_key = "terrain.wall"
	terrain_layer.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"catalog_key": "missing.floor",
	})
	canonical_document.terrain_layers.append(terrain_layer)
	var canonical_layer = TileMapLayer.new()
	var catalog = _test_tile_catalog()
	HexMapDocumentAdapter.apply_to_tile_map_layer(canonical_document, canonical_layer, {"tile_catalog": catalog})
	_assert_eq(canonical_layer.get_cell_source_id(Vector2i.ZERO), 4, "missing override key leaves default catalog tile visible")
	var missing_key_result = HexMapDocumentValidator.validate_document(canonical_document, {"tile_catalog": catalog})
	_assert_has_issue(missing_key_result, HexMapDocumentValidator.RULE_TILE_MISSING, "validator reports missing catalog override key")
	canonical_layer.free()


func _test_hex_tile_catalog_resource_resolves_logical_keys() -> void:
	var catalog = HexTileCatalogResource.new()
	catalog.catalog_id = "test-catalog"
	catalog.display_name = "Test Catalog"
	catalog.tile_set = _test_catalog_tile_set()

	var floor = HexTileCatalogEntry.new()
	floor.key = "terrain.floor"
	floor.display_name = "Floor"
	floor.entry_type = HexTileCatalogEntry.TYPE_ATLAS
	floor.source_id = 2
	floor.atlas_coords = Vector2i(3, 0)
	floor.alternative_tile = 1
	floor.tags = PackedStringArray(["terrain", "floor", "walkable"])
	floor.metadata = {"terrain_kind": "floor"}
	catalog.add_entry(floor)

	var duplicate_floor = HexTileCatalogEntry.new()
	duplicate_floor.key = "terrain.floor"
	duplicate_floor.source_id = 99
	catalog.add_entry(duplicate_floor)

	var scene = HexTileCatalogEntry.new()
	scene.key = "object.spawn"
	scene.display_name = "Spawn"
	scene.entry_type = HexTileCatalogEntry.TYPE_SCENE
	scene.source_id = 7
	var scene_root = Node2D.new()
	scene_root.name = "SpawnMarker"
	var scene_resource = PackedScene.new()
	_assert_eq(scene_resource.pack(scene_root), OK, "catalog test scene packs")
	scene_root.free()
	scene.scene = scene_resource
	scene.tags = PackedStringArray(["object", "spawn", "scene"])
	catalog.add_entry(scene)

	var placeholder = HexTileCatalogEntry.new()
	placeholder.key = "terrain.unknown"
	placeholder.entry_type = HexTileCatalogEntry.TYPE_PLACEHOLDER
	placeholder.source_id = -1
	placeholder.tags = PackedStringArray(["terrain"])
	catalog.add_entry(placeholder)

	var empty = HexTileCatalogEntry.new()
	catalog.add_entry(empty)

	var path = _test_resource_path("test_hex_tile_catalog.tres")
	var error = ResourceSaver.save(catalog, path)
	var loaded = load(path)
	var loaded_floor = loaded.entry_for_key("terrain.floor")
	var loaded_scene = loaded.entry_for_key("object.spawn")
	var loaded_placeholder = loaded.entry_for_key("terrain.unknown")

	_assert_eq(error, OK, "tile catalog resource saves")
	_assert_eq(loaded is HexTileCatalogResource, true, "tile catalog loads as typed resource")
	_assert_eq(loaded.tile_set is TileSet, true, "catalog preserves TileSet resource")
	_assert_eq(loaded.has_key("terrain.floor"), true, "catalog reports existing key")
	_assert_eq(loaded.has_key(""), false, "catalog rejects empty key lookup")
	_assert_eq(loaded.entry_for_key("missing"), null, "catalog returns null for missing key")
	_assert_eq(loaded.keys(), PackedStringArray(["terrain.floor", "terrain.floor", "object.spawn", "terrain.unknown"]), "catalog keys omit empty keys and preserve order")
	_assert_eq(loaded_floor is HexTileCatalogEntry, true, "catalog entry keeps typed resource")
	_assert_eq(loaded_floor.source_id, 2, "catalog lookup returns first duplicate key")
	_assert_eq(loaded_floor.atlas_coords, Vector2i(3, 0), "catalog preserves atlas coords")
	_assert_eq(loaded_floor.alternative_tile, 1, "catalog preserves alternative tile")
	_assert_eq(loaded_floor.has_tag("walkable"), true, "catalog entry preserves tags")
	_assert_eq(loaded_floor.metadata["terrain_kind"], "floor", "catalog entry preserves metadata")
	_assert_eq(loaded_scene.is_scene_tile(), true, "catalog scene entry reports scene type")
	_assert_eq(loaded_scene.scene is PackedScene, true, "catalog preserves scene resource")
	_assert_eq(loaded_placeholder.is_placeholder(), true, "placeholder entry reports placeholder type")
	_assert_eq(HexMapTileAdapter.tile_config_from_catalog(loaded, "terrain.unknown")["source_id"], -1, "placeholder entry resolves to no tile")
	_assert_eq(loaded.entries_with_tag("terrain").size(), 2, "catalog tag filter returns matching entries")
	_assert_eq(loaded.entries_with_tag("spawn")[0].key, "object.spawn", "catalog tag filter preserves entry order")


func _test_sample_hex_tile_catalog_loads() -> void:
	var sample = load("res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres")
	var sample_text = FileAccess.get_file_as_string("res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres")

	_assert_eq(sample is HexTileCatalogResource, true, "sample tile catalog loads")
	_assert_eq(sample.catalog_id, "sample_hex_tile_catalog", "sample catalog stores id")
	_assert_eq(sample.tile_set is TileSet, true, "sample catalog owns TileSet resource")
	_assert_eq(sample_text.contains("debug/"), false, "sample catalog does not reference debug paths")
	_assert_eq(sample.has_key("terrain.floor"), true, "sample catalog has floor key")
	_assert_eq(sample.entry_for_key("terrain.wall").atlas_coords, Vector2i(1, 0), "sample catalog maps wall key to atlas tile")
	_assert_eq(sample.entry_for_key("object.spawn_marker").is_scene_tile(), true, "sample catalog includes scene tile entry")
	_assert_eq(sample.entry_for_key("object.spawn_marker").scene is PackedScene, true, "sample catalog preserves scene resource")
	_assert_eq(
		(sample.entry_for_key("object.spawn_marker").scene as PackedScene).resource_path,
		"res://addons/hex_map_kit/assets/sample_spawn_marker.tscn",
		"sample catalog scene entry references packaged scene"
	)
	_assert_eq(
		ResourceLoader.exists("res://addons/hex_map_kit/assets/sample_spawn_marker.tscn"),
		true,
		"sample catalog packaged scene exists"
	)
	_assert_eq(sample.entries_with_tag("terrain").size(), 2, "sample catalog terrain tags load")
	_assert_eq(sample.entries_with_tag("blocking")[0].key, "terrain.wall", "sample catalog wall blocking tag loads")
	var validation = HexTileCatalogValidator.validate_catalog(sample)
	_assert_eq(validation.error_count(), 0, "sample catalog validator is clean")


func _test_hex_tile_catalog_validator_reports_missing_assets() -> void:
	var tile_set = TileSet.new()
	HexMapTileAdapter.configure_sample_tile_set(tile_set)

	var catalog = HexTileCatalogResource.new()
	catalog.catalog_id = "broken-catalog"

	var missing_source = HexTileCatalogEntry.new()
	missing_source.key = "terrain.missing_source"
	missing_source.source_id = 99
	missing_source.atlas_coords = Vector2i.ZERO
	catalog.add_entry(missing_source)

	var invalid_atlas = HexTileCatalogEntry.new()
	invalid_atlas.key = "terrain.invalid_atlas"
	invalid_atlas.source_id = 0
	invalid_atlas.atlas_coords = Vector2i(9, 9)
	catalog.add_entry(invalid_atlas)

	var missing_scene = HexTileCatalogEntry.new()
	missing_scene.key = "object.missing_scene"
	missing_scene.entry_type = HexTileCatalogEntry.TYPE_SCENE
	missing_scene.source_id = 0
	catalog.add_entry(missing_scene)

	var duplicate = HexTileCatalogEntry.new()
	duplicate.key = "terrain.invalid_atlas"
	duplicate.source_id = 0
	duplicate.atlas_coords = Vector2i.ZERO
	catalog.add_entry(duplicate)

	var empty_key = HexTileCatalogEntry.new()
	catalog.add_entry(empty_key)

	var no_tileset_result = HexTileCatalogValidator.validate_catalog(catalog, null)
	var result = HexTileCatalogValidator.validate_catalog(catalog, tile_set)

	_assert_has_issue(no_tileset_result, HexTileCatalogValidator.RULE_TILE_SET_MISSING, "catalog validator detects missing TileSet")
	_assert_has_issue(result, HexTileCatalogValidator.RULE_SOURCE_MISSING, "catalog validator detects missing source")
	_assert_has_issue(result, HexTileCatalogValidator.RULE_ATLAS_COORDS_INVALID, "catalog validator detects invalid atlas coords")
	_assert_has_issue(result, HexTileCatalogValidator.RULE_SCENE_MISSING, "catalog validator detects missing scene")
	_assert_has_issue(result, HexTileCatalogValidator.RULE_SOURCE_TYPE_MISMATCH, "catalog validator detects scene source type mismatch")
	_assert_has_issue(result, HexTileCatalogValidator.RULE_ENTRY_KEY_DUPLICATE, "catalog validator detects duplicate key")
	_assert_has_issue(result, HexTileCatalogValidator.RULE_ENTRY_KEY_MISSING, "catalog validator detects missing key")
	_assert_eq(result.summary["entries"], 5, "catalog validator summary reports entry count")
	_assert_eq(result.summary["tile_set_present"], true, "catalog validator summary reports TileSet")
	_assert_eq(result.summary["errors"], result.error_count(), "catalog validator summary reports error count")


func _test_hex_tile_catalog_validator_extracts_tags_and_custom_data() -> void:
	var tile_set = TileSet.new()
	HexMapTileAdapter.configure_sample_tile_set(tile_set)
	tile_set.add_custom_data_layer()
	tile_set.set_custom_data_layer_name(0, "movement_cost")
	tile_set.set_custom_data_layer_type(0, TYPE_INT)
	tile_set.add_custom_data_layer()
	tile_set.set_custom_data_layer_name(1, "blocks_path")
	tile_set.set_custom_data_layer_type(1, TYPE_BOOL)
	tile_set.add_custom_data_layer()
	tile_set.set_custom_data_layer_name(2, "terrain_kind")
	tile_set.set_custom_data_layer_type(2, TYPE_STRING)

	var source = tile_set.get_source(0) as TileSetAtlasSource
	var tile_data = source.get_tile_data(Vector2i.ZERO, 0)
	tile_data.set_custom_data("movement_cost", 3)
	tile_data.set_custom_data("blocks_path", false)
	tile_data.set_custom_data("terrain_kind", "grass")

	var catalog = HexTileCatalogResource.new()
	catalog.tile_set = tile_set
	var floor = HexTileCatalogEntry.new()
	floor.key = "terrain.grass"
	floor.entry_type = HexTileCatalogEntry.TYPE_ATLAS
	floor.source_id = 0
	floor.atlas_coords = Vector2i.ZERO
	floor.tags = PackedStringArray(["terrain", "grass", "cost:3"])
	catalog.add_entry(floor)

	var result = HexTileCatalogValidator.validate_catalog(catalog)
	var extracted = HexTileCatalogValidator.catalog_key_tags_and_custom_data(catalog, "terrain.grass")
	var missing = HexTileCatalogValidator.catalog_key_tags_and_custom_data(catalog, "missing")

	_assert_eq(result.error_count(), 0, "catalog validator accepts valid atlas entry")
	_assert_no_issue(result, HexTileCatalogValidator.RULE_TILE_SET_MISSING, "catalog validator has TileSet for valid entry")
	_assert_eq(extracted["tags"], PackedStringArray(["terrain", "grass", "cost:3"]), "catalog validator extracts tags")
	_assert_eq(extracted["custom_data"]["movement_cost"], 3, "catalog validator extracts integer custom data")
	_assert_eq(extracted["custom_data"]["blocks_path"], false, "catalog validator extracts bool custom data")
	_assert_eq(extracted["custom_data"]["terrain_kind"], "grass", "catalog validator extracts string custom data")
	_assert_eq(missing["tags"], PackedStringArray(), "catalog validator returns empty tags for missing key")
	_assert_eq(missing["custom_data"], {}, "catalog validator returns empty custom data for missing key")


func _test_hex_map_tile_adapter_resolves_catalog_defaults() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var catalog = _test_tile_catalog()
	var layer = TileMapLayer.new()

	HexMapTileAdapter.apply_to_tile_map_layer_with_catalog(
		layer,
		data,
		catalog,
		"terrain.floor",
		"terrain.wall",
		{"clear_layer": true}
	)

	_assert_eq(layer.get_cell_source_id(Vector2i.ZERO), 4, "map tile adapter resolves floor source by catalog key")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(0, 0), "map tile adapter resolves floor atlas by catalog key")
	_assert_eq(layer.get_cell_source_id(Vector2i(1, 0)), 5, "map tile adapter resolves wall source by catalog key")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i(1, 0)), Vector2i(1, 0), "map tile adapter resolves wall atlas by catalog key")

	layer.clear()
	HexMapTileAdapter.apply_to_tile_map_layer_with_catalog(
		layer,
		data,
		catalog,
		"missing.floor",
		"missing.wall",
		{"clear_layer": true}
	)

	_assert_eq(layer.get_cell_source_id(Vector2i.ZERO), -1, "map tile adapter skips missing floor catalog key")
	_assert_eq(layer.get_cell_source_id(Vector2i(1, 0)), -1, "map tile adapter skips missing wall catalog key")
	layer.free()


func _test_overlay_tile_adapter_resolves_catalog_item_tiles() -> void:
	var cells = HexMapData.rectangle(3, 1).cells
	var data = HexOverlayData.from_cells(cells, {
		"Treasure": [cells[0]],
		"Shop": [cells[1]],
	})
	var catalog = _test_tile_catalog()
	var layer = TileMapLayer.new()
	var item_keys = {
		"Treasure": "overlay.treasure",
		"Shop": "missing.shop",
	}

	HexOverlayTileAdapter.apply_to_tile_map_layer_with_catalog(layer, data, catalog, item_keys)

	_assert_eq(layer.get_cell_source_id(Vector2i.ZERO), 6, "overlay adapter resolves item tile source by catalog key")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(2, 0), "overlay adapter resolves item atlas by catalog key")
	_assert_eq(layer.get_cell_source_id(Vector2i(1, 0)), -1, "overlay adapter skips missing item catalog key")
	layer.free()


func _test_hex_map_document_adapter_resolves_catalog_tile_entries() -> void:
	var data = HexMapData.rectangle(3, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentResource.new()

	var terrain_layer = HexMapDocumentTerrainLayerResource.new()
	terrain_layer.map = HexMapResource.from_map_data(data)
	terrain_layer.default_floor_key = "terrain.floor"
	terrain_layer.default_wall_key = "terrain.wall"
	terrain_layer.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"catalog_key": "terrain.stone",
		"source_id": 88,
		"atlas_coords": Vector2i(8, 8),
	})
	terrain_layer.tile_assignments.append({
		"cell": Vector3i(2, 0, 0),
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"catalog_key": "missing.floor",
		"source_id": 9,
		"atlas_coords": Vector2i(9, 9),
		"alternative_tile": 2,
	})
	document.terrain_layers.append(terrain_layer)

	var catalog = _test_tile_catalog()
	var layer = TileMapLayer.new()
	var missing_key_map_cell = HexMapTileAdapter.vector_to_map_cell(HexVector.q_axis().scaled(2))

	HexMapDocumentAdapter.apply_to_tile_map_layer(document, layer, {"tile_catalog": catalog})

	_assert_eq(layer.get_cell_source_id(Vector2i.ZERO), 7, "document adapter resolves per-cell catalog key source")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(3, 0), "document adapter resolves per-cell catalog key atlas")
	_assert_eq(layer.get_cell_source_id(Vector2i(1, 0)), 5, "document adapter resolves default wall catalog key")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i(1, 0)), Vector2i(1, 0), "document adapter resolves default wall atlas")
	_assert_eq(layer.get_cell_source_id(missing_key_map_cell), 4, "document adapter leaves default tile when override catalog key is missing")
	var result = HexMapDocumentValidator.validate_document(document, {"tile_catalog": catalog})
	_assert_has_issue(result, HexMapDocumentValidator.RULE_TILE_MISSING, "document validator reports missing override catalog key")
	layer.free()


func _test_overlay_resource_roundtrips_to_overlay_data() -> void:
	var cells = HexMapData.rectangle(3, 1).cells
	var data = HexOverlayData.from_cells(cells, {
		"Treasure": [cells[0], cells[2]],
		"Shop": [cells[1]],
	}, 3)
	var resource = HexOverlayResource.from_overlay_data(data, HexMapResource.ORIENTATION_POINTY_TOP)
	var roundtrip = resource.to_overlay_data()

	_assert_eq(resource.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "overlay resource stores orientation")
	_assert_eq(resource.cyclic_size, 3, "overlay resource stores cyclic size")
	_assert_keys_eq(roundtrip.cells, data.cells, "overlay resource roundtrip preserves cells")
	_assert_keys_eq(roundtrip.item_cells("Treasure"), data.item_cells("Treasure"), "overlay resource roundtrip preserves Treasure cells")
	_assert_keys_eq(roundtrip.item_cells("Shop"), data.item_cells("Shop"), "overlay resource roundtrip preserves Shop cells")


func _test_adjacency_rule_set_parses_probability_rules() -> void:
	var rules = HexAdjacencyRuleSet.parse_rules_text("default=0.2;1=0.8;2,1=0.4;bad=x")
	_assert_eq(rules["default"], 0.2, "adjacency rule set parses default probability")
	_assert_eq(rules[1], 0.8, "adjacency rule set parses neighbor count probability")
	_assert_eq(rules[Vector2i(2, 1)], 0.4, "adjacency rule set normalizes count/component probability key")
	_assert_eq(rules.has("bad"), false, "adjacency rule set ignores invalid named keys")
	var report = HexAdjacencyRuleSet.parse_rules_text_report("default=0.2;1=0.8;2,1=0.4;bad=x;bad=0.5")
	_assert_eq(report["invalid_entries"], ["bad=x", "bad=0.5"], "adjacency rule set reports invalid entries")

	var empty_rules = HexAdjacencyRuleSet.parse_rules_text("bad")
	_assert_eq(empty_rules, {}, "adjacency rule set returns empty rules when no entries are valid")
	var empty_report = HexAdjacencyRuleSet.parse_rules_text_report("bad")
	_assert_eq(empty_report["rules"], {}, "adjacency rule set reports empty rules without fallback default")

	var resource = HexAdjacencyRuleSet.new()
	resource.rules_text = "default=1.4;0=-0.2"
	var clamped = resource.to_probability_rules()
	_assert_eq(clamped["default"], 1.0, "adjacency rule set clamps high probability")
	_assert_eq(clamped[0], 0.0, "adjacency rule set clamps low probability")


func _test_overlay_data_apply_policy_merge_replace_skip() -> void:
	var cells = HexMapData.rectangle(3, 1).cells
	var base = HexOverlayData.from_cells(cells, {
		"Treasure": [cells[0]],
	})
	var incoming = HexOverlayData.from_cells(cells, {
		"Shop": [cells[0], cells[1]],
	})

	var merged = base.duplicate_data()
	merged.apply_overlay(incoming, HexOverlayData.APPLY_ADD_ITEM, HexOverlayData.EXISTING_MERGE)
	_assert_eq(merged.items_at(cells[0]), ["Shop", "Treasure"], "merge existing keeps both item keys at a cell")
	_assert_keys_eq(merged.item_cells("Shop"), [cells[0], cells[1]], "merge existing adds incoming item cells")

	var replaced = base.duplicate_data()
	replaced.apply_overlay(incoming, HexOverlayData.APPLY_ADD_ITEM, HexOverlayData.EXISTING_REPLACE)
	_assert_eq(replaced.items_at(cells[0]), ["Shop"], "replace existing removes previous item keys at incoming cells")
	_assert_eq(replaced.items_at(cells[1]), ["Shop"], "replace existing writes incoming item")

	var skipped = base.duplicate_data()
	skipped.apply_overlay(incoming, HexOverlayData.APPLY_ADD_ITEM, HexOverlayData.EXISTING_SKIP)
	_assert_eq(skipped.items_at(cells[0]), ["Treasure"], "skip existing leaves occupied cell unchanged")
	_assert_eq(skipped.items_at(cells[1]), ["Shop"], "skip existing writes empty cell")

	var cleared = base.duplicate_data()
	cleared.apply_overlay(incoming, HexOverlayData.APPLY_CLEAR_AND_WRITE, HexOverlayData.EXISTING_MERGE)
	_assert_eq(cleared.item_cells("Treasure"), [], "clear and write removes previous item keys")
	_assert_keys_eq(cleared.item_cells("Shop"), [cells[0], cells[1]], "clear and write stores incoming item cells")


func _test_overlay_tile_adapter_applies_user_item_tiles() -> void:
	var cells = HexMapData.rectangle(3, 1).cells
	var data = HexOverlayData.from_cells(cells, {
		"Treasure": [cells[0]],
		"Shop": [cells[1]],
		"Unmapped": [cells[2]],
	})
	var item_tiles = {
		"Treasure": HexOverlayTileAdapter.tile_config(4, Vector2i(2, 3)),
		"Shop": HexOverlayTileAdapter.tile_config(5, Vector2i(6, 7), 2),
	}
	var layer = TileMapLayer.new()

	HexOverlayTileAdapter.apply_to_tile_map_layer(layer, data, item_tiles)
	_assert_eq(layer.get_used_cells().size(), 2, "overlay tile adapter applies only mapped item keys")
	_assert_eq(layer.get_cell_source_id(Vector2i.ZERO), 4, "overlay tile adapter applies Treasure source")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(2, 3), "overlay tile adapter applies Treasure atlas")
	_assert_eq(layer.get_cell_source_id(Vector2i(1, 0)), 5, "overlay tile adapter applies Shop source")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i(1, 0)), Vector2i(6, 7), "overlay tile adapter applies Shop atlas")
	_assert_eq(layer.get_cell_alternative_tile(Vector2i(1, 0)), 2, "overlay tile adapter applies alternative tile")

	layer.free()


func _test_overlay_tile_adapter_can_preserve_existing_layer_cells() -> void:
	var cells = HexMapData.rectangle(1, 1).cells
	var data = HexOverlayData.from_cells(cells, {
		"Treasure": [cells[0]],
	})
	var item_tiles = {
		"Treasure": HexOverlayTileAdapter.tile_config(4, Vector2i(2, 3)),
	}
	var layer = TileMapLayer.new()
	layer.set_cell(Vector2i(9, 9), 8, Vector2i(1, 1))

	HexOverlayTileAdapter.apply_to_tile_map_layer(layer, data, item_tiles, false)
	_assert_eq(layer.get_cell_source_id(Vector2i(9, 9)), 8, "overlay tile adapter preserves existing layer cell when not clearing")
	_assert_eq(layer.get_cell_source_id(Vector2i.ZERO), 4, "overlay tile adapter writes generated overlay cell when not clearing")

	layer.free()


func _test_resource_path(filename: String) -> String:
	return "%s/%s" % [_test_output_dir(), filename]


func _test_tile_catalog() -> HexTileCatalogResource:
	var catalog = HexTileCatalogResource.new()
	catalog.tile_set = _test_catalog_tile_set()
	catalog.add_entry(_test_catalog_entry("terrain.floor", 4, Vector2i(0, 0), ["terrain", "floor"]))
	catalog.add_entry(_test_catalog_entry("terrain.wall", 5, Vector2i(1, 0), ["terrain", "wall"]))
	catalog.add_entry(_test_catalog_entry("overlay.treasure", 6, Vector2i(2, 0), ["overlay", "treasure"]))
	catalog.add_entry(_test_catalog_entry("terrain.stone", 7, Vector2i(3, 0), ["terrain", "floor"]))
	return catalog


func _test_catalog_entry(key: String, source_id: int, atlas_coords: Vector2i, tags: Array) -> HexTileCatalogEntry:
	var entry = HexTileCatalogEntry.new()
	entry.key = key
	entry.source_id = source_id
	entry.atlas_coords = atlas_coords
	entry.tags = PackedStringArray(tags)
	return entry


func _test_packed_scene(node_name: String = "PackedSceneRoot") -> PackedScene:
	var node = Node2D.new()
	node.name = node_name
	var scene = PackedScene.new()
	_assert_eq(scene.pack(node), OK, "test packed scene packs")
	node.free()
	return scene


func _test_catalog_tile_set() -> TileSet:
	var tile_set = TileSet.new()
	var texture = HexMapTileAdapter.load_tile_texture("res://addons/hex_map_kit/assets/tactics_flat_top_hex_tiles_64x57_10.png")
	for entry in [
		{"source_id": 2, "coords": Vector2i(3, 0)},
		{"source_id": 4, "coords": Vector2i(0, 0)},
		{"source_id": 5, "coords": Vector2i(1, 0)},
		{"source_id": 6, "coords": Vector2i(2, 0)},
		{"source_id": 7, "coords": Vector2i(3, 0)},
	]:
		var coords: Vector2i = entry["coords"]
		var tile_coords: Array[Vector2i] = [coords]
		HexMapTileAdapter.configure_atlas_tile_set(
			tile_set,
			texture,
			true,
			HexMapTileAdapter.SAMPLE_TILE_SIZE,
			int(entry["source_id"]),
			tile_coords
		)
	return tile_set


func _test_output_dir() -> String:
	if _test_output_root == "":
		_test_output_root = "res://.godot_user/test-runs/%s/test_hex_adapter" % _safe_path_part(_test_run_id())
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


func _assert_neighbor_offset_deltas(center, expected: Array, message: String) -> void:
	var center_cell = center.to_offset()
	var directions = HexVector.directions()

	for index in range(directions.size()):
		var neighbor_cell = center.add_vector(directions[index]).to_offset()
		_assert_eq(
			neighbor_cell - center_cell,
			expected[index],
			"%s direction %d" % [message, index]
		)


func _flat_top_offset_relative_local(center, direction, size: float) -> Vector2:
	var center_local = _flat_top_point_local_from_unity_offset(center, size)
	var neighbor_local = _flat_top_point_local_from_unity_offset(center.add_vector(direction), size)
	return neighbor_local - center_local


func _flat_top_point_local_from_unity_offset(point, size: float) -> Vector2:
	var cell = point.to_offset()
	var offset_point = HexPoint.from_offset(cell.x, cell.y)
	var a = float(offset_point.q - offset_point.r)
	var b = float(offset_point.r)
	var sqrt3 = sqrt(3.0)
	return Vector2(
		size * 1.5 * a,
		size * sqrt3 * (b + a * 0.5)
	)


func _assert_radius_two_hexagon_matches_godot_layout(flat_top: bool) -> void:
	var tile_set = TileSet.new()
	HexMapTileAdapter.configure_hex_tile_set(tile_set, flat_top, Vector2i(64, 64))
	var layer = TileMapLayer.new()
	layer.tile_set = tile_set
	var data = HexMapData.hexagon(2)
	var entries = HexMapTileAdapter.to_tile_entries(data, true, true, flat_top)
	var entry_by_key := {}
	for entry in entries:
		entry_by_key[entry["vector"].key()] = entry

	_assert_eq(entries.size(), 19, "radius 2 hexagon emits 19 entries flat_top=%s" % str(flat_top))
	var center = HexVector.apply_basis(2, 0, 2)
	_assert_eq(entry_by_key.has(center.key()), true, "radius 2 canonical hexagon has an interior layout center")
	if not entry_by_key.has(center.key()):
		layer.free()
		return
	var center_entry = entry_by_key[center.key()]
	var center_local = layer.map_to_local(center_entry["map_cell"])
	var directions = HexVector.directions()
	for direction in directions:
		var neighbor = center.add(direction)
		_assert_eq(entry_by_key.has(neighbor.key()), true, "radius 2 canonical hexagon has center neighbor %s" % direction.key())
		if not entry_by_key.has(neighbor.key()):
			continue
		var entry = entry_by_key[neighbor.key()]
		var actual = layer.map_to_local(entry["map_cell"]) - center_local
		var expected = _godot_neighbor_delta(direction, flat_top)
		_assert_vec2_approx(
			actual,
			expected,
			"Godot TileMapLayer neighbor layout flat_top=%s direction=%s" % [str(flat_top), direction.key()]
		)
	layer.free()


func _entries_by_key(entries: Array) -> Dictionary:
	var result := {}
	for entry in entries:
		result[entry["vector"].key()] = entry
	return result


func _godot_neighbor_delta(direction, flat_top: bool) -> Vector2:
	var axial = HexMapTileAdapter.vector_to_display_axial(direction)
	var q = float(axial.x)
	var r = float(axial.y)
	if flat_top:
		return Vector2(48.0 * q, 64.0 * (r + q * 0.5))
	return Vector2(64.0 * (q + r * 0.5), 48.0 * r)
