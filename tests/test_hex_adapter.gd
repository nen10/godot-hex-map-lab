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
const HexMapDocumentLabelPlacementResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_label_placement_resource.gd")
const HexMapDocumentObjectPlacementResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_object_placement_resource.gd")
const HexMapDocumentOverlayLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_overlay_layer_resource.gd")
const HexMapDocumentTerrainLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_terrain_layer_resource.gd")
const HexMapDocumentZoneResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_zone_resource.gd")
const HexMapValidationResult = preload("res://addons/hex_map_kit/adapter/hex_map_validation_result.gd")
const HexObjectDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_object_database_resource.gd")
const HexLabelDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_label_database_resource.gd")
const HexTileCatalogEntry = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_entry.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")
const HexTileCatalogValidator = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_validator.gd")
const HexOverlayResource = preload("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd")
const HexOverlayTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_overlay_tile_adapter.gd")
const HexAdjacencyRuleSet = preload("res://addons/hex_map_kit/adapter/hex_adjacency_rule_set.gd")

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
	_test_hex_map_document_v2_schema_roundtrips_typed_resources()
	_test_hex_map_document_v1_fixture_still_loads_with_v2_fields()
	_test_hex_map_document_migrates_v1_to_v2_preserving_legacy_fields()
	_test_hex_map_document_migration_handles_missing_fields()
	_test_hex_map_document_summary_reports_v2_counts()
	_test_hex_map_validation_result_serializes_summary_and_warnings()
	_test_hex_map_document_adapter_roundtrips_v2_payload_entries()
	_test_hex_map_document_adapter_cleans_v2_payloads_for_deleted_cell()
	_test_hex_map_document_adapter_updates_wall_floor()
	_test_hex_map_document_adapter_applies_tile_overrides()
	_test_hex_tile_catalog_resource_resolves_logical_keys()
	_test_sample_hex_tile_catalog_loads()
	_test_hex_tile_catalog_validator_reports_missing_assets()
	_test_hex_tile_catalog_validator_extracts_tags_and_custom_data()
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
	object_db.objects = [{"object_id": "chest", "display_name": "Chest"}]
	var label_db = HexLabelDatabaseResource.new()
	label_db.labels = [{"label_id": "area", "display_name": "Area"}]

	var path = _test_resource_path("test_hex_map_document.tres")
	var error = ResourceSaver.save(document, path)
	var loaded = load(path)
	var roundtrip = HexMapDocumentAdapter.to_map_resource(loaded).to_map_data()

	_assert_eq(error, OK, "hex map document resource saves")
	_assert_keys_eq(roundtrip.cells, data.cells, "hex map document preserves cells")
	_assert_keys_eq(roundtrip.walls, data.walls, "hex map document preserves walls")
	_assert_eq(loaded.map.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "hex map document preserves orientation")
	_assert_eq(loaded.tile_overrides[0]["atlas_coords"], Vector2i(4, 5), "hex map document preserves tile override")
	_assert_eq(loaded.objects[0]["properties"]["gold"], 2, "hex map document preserves object properties")
	_assert_eq(loaded.labels[0]["text"], "North Gate", "hex map document preserves labels")
	_assert_eq(object_db.objects[0]["object_id"], "chest", "object database stores object definitions")
	_assert_eq(label_db.labels[0]["label_id"], "area", "label database stores label definitions")


func _test_hex_map_document_v2_schema_roundtrips_typed_resources() -> void:
	var data = HexMapData.rectangle(2, 1)
	var overlay_data = HexOverlayData.from_item_cells(data.cells, "Treasure", [HexVector.zero()])
	var document = HexMapDocumentResource.new()
	document.ensure_v2_defaults()
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
	placement.variant = "gold"
	placement.properties = {"gold": 5}
	placement.spawn_condition = "default"
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
	dependency.dependency_path = "res://addons/hex_map_kit/presets/sample_catalog.tres"
	dependency.role = "terrain"
	document.dependencies.append(dependency)

	var path = _test_resource_path("test_hex_map_document_v2.tres")
	var error = ResourceSaver.save(document, path)
	var loaded = load(path)
	var fields = loaded.v2_schema_fields()

	_assert_eq(error, OK, "hex map document v2 resource saves")
	_assert_eq(loaded.version, HexMapDocumentResource.VERSION_V2, "v2 document stores version")
	_assert_eq(loaded.is_v2(), true, "v2 document reports v2 schema")
	_assert_eq(fields.has("terrain_layers"), true, "v2 fields include terrain layers")
	_assert_eq(fields.has("overlay_layers"), true, "v2 fields include overlay layers")
	_assert_eq(fields.has("object_placements"), true, "v2 fields include object placements")
	_assert_eq(fields.has("label_placements"), true, "v2 fields include label placements")
	_assert_eq(fields.has("zones"), true, "v2 fields include zones")
	_assert_eq(fields.has("metadata"), true, "v2 fields include metadata")
	_assert_eq(fields.has("dependencies"), true, "v2 fields include dependencies")
	_assert_eq(loaded.metadata.document_id, "level-001", "v2 document metadata roundtrips")
	_assert_eq(loaded.terrain_layers[0] is HexMapDocumentTerrainLayerResource, true, "terrain layer keeps typed resource")
	_assert_eq(loaded.terrain_layers[0].default_floor_key, "terrain.grass", "terrain layer preserves floor key")
	_assert_eq(loaded.terrain_layers[0].map.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "terrain layer map preserves orientation")
	_assert_eq(loaded.overlay_layers[0] is HexMapDocumentOverlayLayerResource, true, "overlay layer keeps typed resource")
	_assert_eq(loaded.overlay_layers[0].overlay.item_keys[0], "Treasure", "overlay layer preserves overlay resource")
	_assert_eq(loaded.object_placements[0] is HexMapDocumentObjectPlacementResource, true, "object placement keeps typed resource")
	_assert_eq(loaded.object_placements[0].properties["gold"], 5, "object placement preserves properties")
	_assert_eq(loaded.label_placements[0] is HexMapDocumentLabelPlacementResource, true, "label placement keeps typed resource")
	_assert_eq(loaded.label_placements[0].text, "North", "label placement preserves text")
	_assert_eq(loaded.zones[0] is HexMapDocumentZoneResource, true, "zone keeps typed resource")
	_assert_eq(loaded.zones[0].tags[1], "entry", "zone preserves tags")
	_assert_eq(loaded.dependencies[0] is HexMapDocumentDependencyResource, true, "dependency keeps typed resource")
	_assert_eq(loaded.dependencies[0].kind, HexMapDocumentDependencyResource.KIND_TILE_CATALOG, "dependency preserves kind")


func _test_hex_map_document_v1_fixture_still_loads_with_v2_fields() -> void:
	var data = HexMapData.rectangle(2, 1)
	var document = HexMapDocumentResource.new()
	document.version = HexMapDocumentResource.VERSION_V1
	document.map = HexMapResource.from_map_data(data)
	document.tile_overrides = [{
		"cell": Vector3i.ZERO,
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 1,
		"atlas_coords": Vector2i(2, 3),
	}]
	document.objects = [{
		"cell": Vector3i(1, 0, 0),
		"object_id": "chest",
	}]
	document.labels = [{
		"cell": Vector3i.ZERO,
		"label_id": "area",
		"text": "North",
	}]

	var path = _test_resource_path("test_hex_map_document_v1_compat.tres")
	var error = ResourceSaver.save(document, path)
	var loaded = load(path)

	_assert_eq(error, OK, "hex map document v1 fixture saves after v2 fields exist")
	_assert_eq(loaded.version, HexMapDocumentResource.VERSION_V1, "v1 fixture keeps version")
	_assert_eq(loaded.is_v2(), false, "v1 fixture is not reported as v2")
	_assert_keys_eq(loaded.map.to_map_data().cells, data.cells, "v1 fixture preserves cells")
	_assert_eq(loaded.tile_overrides[0]["atlas_coords"], Vector2i(2, 3), "v1 fixture preserves tile overrides")
	_assert_eq(loaded.objects[0]["object_id"], "chest", "v1 fixture preserves objects")
	_assert_eq(loaded.labels[0]["text"], "North", "v1 fixture preserves labels")
	_assert_eq(loaded.terrain_layers.size(), 0, "v1 fixture leaves v2 terrain layers empty")
	_assert_eq(loaded.overlay_layers.size(), 0, "v1 fixture leaves v2 overlay layers empty")
	_assert_eq(loaded.object_placements.size(), 0, "v1 fixture leaves v2 object placements empty")
	_assert_eq(loaded.label_placements.size(), 0, "v1 fixture leaves v2 label placements empty")
	_assert_eq(loaded.zones.size(), 0, "v1 fixture leaves v2 zones empty")
	_assert_eq(loaded.dependencies.size(), 0, "v1 fixture leaves v2 dependencies empty")


func _test_hex_map_document_migrates_v1_to_v2_preserving_legacy_fields() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentResource.new()
	document.version = HexMapDocumentResource.VERSION_V1
	document.map = HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_POINTY_TOP)
	document.tile_overrides = [{
		"cell": Vector3i.ZERO,
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"item_key": "Floor",
		"source_id": 2,
		"atlas_coords": Vector2i(3, 4),
		"alternative_tile": 1,
	}, {
		"cell": Vector3i.ZERO,
		"kind": HexMapDocumentAdapter.KIND_OVERLAY,
		"item_key": "Treasure",
		"source_id": 5,
		"atlas_coords": Vector2i(6, 7),
	}]
	document.objects = [{
		"cell": Vector3i(1, 0, 0),
		"object_id": "chest",
		"properties": {"gold": 8},
		"variant": "rare",
	}]
	document.labels = [{
		"cell": Vector3i.ZERO,
		"label_id": "area",
		"text": "North Gate",
	}]

	var migrated = HexMapDocumentAdapter.migrate_v1_to_v2(document)
	var path = _test_resource_path("test_hex_map_document_v1_to_v2.tres")
	var error = ResourceSaver.save(migrated, path)
	var loaded = load(path)

	_assert_eq(document.version, HexMapDocumentResource.VERSION_V1, "migration does not mutate source version")
	_assert_eq(migrated.version, HexMapDocumentResource.VERSION_V2, "migration creates v2 document")
	_assert_eq(migrated.metadata.custom_properties["source_version"], HexMapDocumentResource.VERSION_V1, "migration records source version")
	_assert_keys_eq(migrated.map.to_map_data().cells, data.cells, "migration preserves legacy map cells")
	_assert_keys_eq(migrated.map.to_map_data().walls, data.walls, "migration preserves legacy map walls")
	_assert_eq(migrated.map.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "migration preserves legacy map orientation")
	_assert_eq(migrated.tile_overrides[0]["atlas_coords"], Vector2i(3, 4), "migration preserves legacy tile overrides")
	_assert_eq(migrated.objects[0]["properties"]["gold"], 8, "migration preserves legacy objects")
	_assert_eq(migrated.labels[0]["text"], "North Gate", "migration preserves legacy labels")
	_assert_eq(migrated.terrain_layers.size(), 1, "migration creates default terrain layer")
	_assert_eq(migrated.terrain_layers[0].tile_assignments.size(), 1, "migration moves non-overlay tile override to terrain assignment")
	_assert_eq(migrated.terrain_layers[0].tile_assignments[0]["source_id"], 2, "terrain assignment preserves source id fallback")
	_assert_eq(migrated.overlay_layers.size(), 1, "migration creates overlay layer")
	_assert_eq(migrated.overlay_layers[0].item_key, "Treasure", "migration groups overlay by item key")
	_assert_eq(migrated.overlay_layers[0].tile_assignments[0]["atlas_coords"], Vector2i(6, 7), "overlay assignment preserves atlas fallback")
	_assert_eq(migrated.object_placements.size(), 1, "migration creates object placement")
	_assert_eq(migrated.object_placements[0].object_id, "chest", "object placement preserves object id")
	_assert_eq(migrated.object_placements[0].properties["gold"], 8, "object placement preserves properties")
	_assert_eq(migrated.label_placements.size(), 1, "migration creates label placement")
	_assert_eq(migrated.label_placements[0].text, "North Gate", "label placement preserves text")
	_assert_eq(error, OK, "migrated document saves")
	_assert_eq(loaded.version, HexMapDocumentResource.VERSION_V2, "migrated roundtrip preserves v2 version")
	_assert_eq(loaded.metadata.custom_properties["source_version"], HexMapDocumentResource.VERSION_V1, "migrated roundtrip preserves source version")
	_assert_eq(loaded.terrain_layers[0] is HexMapDocumentTerrainLayerResource, true, "migrated roundtrip keeps typed terrain")
	_assert_eq(loaded.overlay_layers[0] is HexMapDocumentOverlayLayerResource, true, "migrated roundtrip keeps typed overlay")
	_assert_eq(loaded.object_placements[0] is HexMapDocumentObjectPlacementResource, true, "migrated roundtrip keeps typed object placement")
	_assert_eq(loaded.label_placements[0] is HexMapDocumentLabelPlacementResource, true, "migrated roundtrip keeps typed label placement")


func _test_hex_map_document_migration_handles_missing_fields() -> void:
	var empty_document = HexMapDocumentResource.new()
	var migrated = HexMapDocumentAdapter.migrate_v1_to_v2(empty_document)
	var null_migrated = HexMapDocumentAdapter.migrate_v1_to_v2(null)

	_assert_eq(migrated.version, HexMapDocumentResource.VERSION_V2, "empty document migrates to v2")
	_assert_eq(migrated.metadata.custom_properties["source_version"], HexMapDocumentResource.VERSION_V1, "empty document records default source version")
	_assert_eq(migrated.map, null, "empty document keeps missing map empty")
	_assert_eq(migrated.tile_overrides.size(), 0, "empty document keeps tile overrides empty")
	_assert_eq(migrated.objects.size(), 0, "empty document keeps objects empty")
	_assert_eq(migrated.labels.size(), 0, "empty document keeps labels empty")
	_assert_eq(migrated.terrain_layers.size(), 0, "empty document creates no terrain layer without map")
	_assert_eq(migrated.overlay_layers.size(), 0, "empty document creates no overlay layers")
	_assert_eq(migrated.object_placements.size(), 0, "empty document creates no object placements")
	_assert_eq(migrated.label_placements.size(), 0, "empty document creates no label placements")
	_assert_eq(null_migrated.version, HexMapDocumentResource.VERSION_V2, "null document migrates to v2")
	_assert_eq(null_migrated.metadata.custom_properties["source_version"], 0, "null migration records missing source version")
	_assert_eq(null_migrated.terrain_layers.size(), 0, "null migration creates no terrain layer")


func _test_hex_map_document_summary_reports_v2_counts() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentResource.new()
	document.ensure_v2_defaults()

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
	dependency.dependency_path = "res://addons/hex_map_kit/assets/sample_hex_tiles.png"
	document.dependencies.append(dependency)

	var summary = HexMapDocumentAdapter.document_summary(document)

	_assert_eq(summary["version"], HexMapDocumentResource.VERSION_V2, "summary reports version")
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


func _test_hex_map_document_adapter_roundtrips_v2_payload_entries() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentResource.new()
	document.ensure_v2_defaults()

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
	placement.object_id = "chest"
	placement.cell = Vector3i.ZERO
	placement.properties = {"gold": 3}
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

	_assert_keys_eq(map_resource.to_map_data().cells, data.cells, "v2 adapter map resource preserves cells")
	_assert_keys_eq(map_resource.to_map_data().walls, data.walls, "v2 adapter map resource preserves walls")
	_assert_eq(map_resource.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "v2 adapter map resource preserves orientation")
	_assert_eq(tile_entries.size(), 2, "v2 adapter exposes terrain and overlay tile entries")
	_assert_eq(tile_entries[0]["atlas_coords"], Vector2i(1, 0), "v2 adapter exposes terrain tile assignment")
	_assert_eq(tile_entries[1]["kind"], HexMapDocumentAdapter.KIND_OVERLAY, "v2 adapter marks overlay assignment kind")
	_assert_eq(tile_entries[1]["item_key"], "Treasure", "v2 adapter fills overlay item key from layer")
	_assert_eq(object_entries[0]["object_id"], "chest", "v2 adapter exposes object placement")
	_assert_eq(object_entries[0]["properties"]["gold"], 3, "v2 adapter preserves object properties")
	_assert_eq(label_entries[0]["text"], "North", "v2 adapter exposes label placement")
	_assert_eq(copy.terrain_layers[0] is HexMapDocumentTerrainLayerResource, true, "v2 duplicate preserves typed terrain layer")
	_assert_eq(copy.object_placements[0] is HexMapDocumentObjectPlacementResource, true, "v2 duplicate preserves typed object placement")


func _test_hex_map_document_adapter_cleans_v2_payloads_for_deleted_cell() -> void:
	var data = HexMapData.rectangle(2, 1)
	var deleted = HexVector.q_axis()
	var document = HexMapDocumentResource.new()
	document.ensure_v2_defaults()

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

	_assert_eq(HexMapDocumentAdapter.to_map_resource(document).to_map_data().has_cell(deleted), false, "v2 delete removes map cell")
	_assert_eq(document.terrain_layers[0].tile_assignments.size(), 0, "v2 delete removes terrain tile assignment")
	_assert_eq(document.overlay_layers[0].tile_assignments.size(), 0, "v2 delete removes overlay tile assignment")
	_assert_eq(document.object_placements.size(), 0, "v2 delete removes object placement")
	_assert_eq(document.label_placements.size(), 0, "v2 delete removes label placement")
	_assert_eq(document.zones.size(), 0, "v2 delete removes empty zone")


func _test_hex_map_document_adapter_updates_wall_floor() -> void:
	var document = HexMapDocumentAdapter.from_map_resource(
		HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	)

	HexMapDocumentAdapter.set_wall(document, HexVector.zero(), true)
	_assert_eq(document.map.to_map_data().has_wall(HexVector.zero()), true, "document adapter sets wall")
	HexMapDocumentAdapter.set_wall(document, HexVector.zero(), false)
	_assert_eq(document.map.to_map_data().has_wall(HexVector.zero()), false, "document adapter clears wall")

	var new_cell = HexVector.q_axis().scaled(2)
	HexMapDocumentAdapter.set_cell_exists(document, new_cell, true)
	_assert_eq(document.map.to_map_data().has_cell(new_cell), true, "document adapter adds shape cell")
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
	_assert_eq(document.map.to_map_data().has_cell(HexVector.q_axis()), false, "document adapter removes shape cell")
	_assert_eq(document.tile_overrides.size(), 0, "document adapter removes tile overrides for deleted shape cell")
	_assert_eq(document.objects.size(), 0, "document adapter removes objects for deleted shape cell")
	_assert_eq(document.labels.size(), 0, "document adapter removes labels for deleted shape cell")


func _test_hex_map_document_adapter_applies_tile_overrides() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_tile_override(document, HexVector.zero(), {
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 8,
		"atlas_coords": Vector2i(4, 5),
		"alternative_tile": 2,
	})
	HexMapDocumentAdapter.set_tile_override(document, HexVector.zero(), {
		"kind": HexMapDocumentAdapter.KIND_WALL,
		"source_id": 9,
		"atlas_coords": Vector2i(6, 7),
	})
	HexMapDocumentAdapter.set_tile_override(document, HexVector.q_axis(), {
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 10,
		"atlas_coords": Vector2i(8, 9),
	})
	HexMapDocumentAdapter.set_tile_override(document, HexVector.q_axis(), {
		"kind": HexMapDocumentAdapter.KIND_WALL,
		"source_id": 11,
		"atlas_coords": Vector2i(12, 13),
	})
	var layer = TileMapLayer.new()

	HexMapDocumentAdapter.apply_to_tile_map_layer(document, layer, {
		"floor_source_id": 1,
		"floor_atlas_coords": Vector2i.ZERO,
		"wall_source_id": 2,
		"wall_atlas_coords": Vector2i(1, 0),
	})

	_assert_eq(layer.get_cell_source_id(Vector2i.ZERO), 8, "document adapter applies floor tile override source")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(4, 5), "document adapter applies floor tile override atlas")
	_assert_eq(layer.get_cell_alternative_tile(Vector2i.ZERO), 2, "document adapter applies floor tile override alternative")
	_assert_eq(layer.get_cell_source_id(Vector2i(1, 0)), 11, "document adapter applies wall tile override source")
	_assert_eq(layer.get_cell_atlas_coords(Vector2i(1, 0)), Vector2i(12, 13), "document adapter applies wall tile override atlas")
	layer.free()


func _test_hex_tile_catalog_resource_resolves_logical_keys() -> void:
	var catalog = HexTileCatalogResource.new()
	catalog.catalog_id = "test-catalog"
	catalog.display_name = "Test Catalog"
	catalog.tile_set_path = "res://addons/hex_map_kit/assets/sample_hex_tiles.png"

	var floor = HexTileCatalogEntry.new()
	floor.key = "terrain.floor"
	floor.display_name = "Floor"
	floor.entry_type = HexTileCatalogEntry.TYPE_ATLAS
	floor.source_id = 2
	floor.atlas_coords = Vector2i(3, 4)
	floor.alternative_tile = 1
	floor.tags = PackedStringArray(["terrain", "floor", "walkable"])
	floor.fallback_source_id = 0
	floor.fallback_atlas_coords = Vector2i.ZERO
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
	scene.scene_path = "res://addons/hex_map_kit/debug/spawn_marker.tscn"
	scene.tags = PackedStringArray(["object", "spawn", "scene"])
	scene.fallback_source_id = 0
	scene.fallback_atlas_coords = Vector2i(1, 0)
	catalog.add_entry(scene)

	var fallback_only = HexTileCatalogEntry.new()
	fallback_only.key = "terrain.unknown"
	fallback_only.entry_type = HexTileCatalogEntry.TYPE_FALLBACK
	fallback_only.source_id = -1
	fallback_only.fallback_source_id = 5
	fallback_only.fallback_atlas_coords = Vector2i(6, 7)
	fallback_only.fallback_alternative_tile = 2
	fallback_only.tags = PackedStringArray(["terrain"])
	catalog.add_entry(fallback_only)

	var empty = HexTileCatalogEntry.new()
	catalog.add_entry(empty)

	var path = _test_resource_path("test_hex_tile_catalog.tres")
	var error = ResourceSaver.save(catalog, path)
	var loaded = load(path)
	var loaded_floor = loaded.entry_for_key("terrain.floor")
	var loaded_scene = loaded.entry_for_key("object.spawn")
	var loaded_fallback = loaded.entry_for_key("terrain.unknown")

	_assert_eq(error, OK, "tile catalog resource saves")
	_assert_eq(loaded is HexTileCatalogResource, true, "tile catalog loads as typed resource")
	_assert_eq(loaded.has_key("terrain.floor"), true, "catalog reports existing key")
	_assert_eq(loaded.has_key(""), false, "catalog rejects empty key lookup")
	_assert_eq(loaded.entry_for_key("missing"), null, "catalog returns null for missing key")
	_assert_eq(loaded.keys(), PackedStringArray(["terrain.floor", "terrain.floor", "object.spawn", "terrain.unknown"]), "catalog keys omit empty keys and preserve order")
	_assert_eq(loaded_floor is HexTileCatalogEntry, true, "catalog entry keeps typed resource")
	_assert_eq(loaded_floor.source_id, 2, "catalog lookup returns first duplicate key")
	_assert_eq(loaded_floor.atlas_coords, Vector2i(3, 4), "catalog preserves atlas coords")
	_assert_eq(loaded_floor.alternative_tile, 1, "catalog preserves alternative tile")
	_assert_eq(loaded_floor.has_tag("walkable"), true, "catalog entry preserves tags")
	_assert_eq(loaded_floor.metadata["terrain_kind"], "floor", "catalog entry preserves metadata")
	_assert_eq(loaded_scene.is_scene_tile(), true, "catalog scene entry reports scene type")
	_assert_eq(loaded_scene.scene_path, "res://addons/hex_map_kit/debug/spawn_marker.tscn", "catalog preserves scene path")
	_assert_eq(loaded_scene.fallback_atlas_coords, Vector2i(1, 0), "scene entry preserves fallback atlas")
	_assert_eq(loaded_fallback.effective_source_id(), 5, "fallback entry exposes effective source id")
	_assert_eq(loaded_fallback.effective_atlas_coords(), Vector2i(6, 7), "fallback entry exposes effective atlas")
	_assert_eq(loaded_fallback.effective_alternative_tile(), 2, "fallback entry exposes effective alternative tile")
	_assert_eq(loaded.entries_with_tag("terrain").size(), 2, "catalog tag filter returns matching entries")
	_assert_eq(loaded.entries_with_tag("spawn")[0].key, "object.spawn", "catalog tag filter preserves entry order")


func _test_sample_hex_tile_catalog_loads() -> void:
	var sample = load("res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres")

	_assert_eq(sample is HexTileCatalogResource, true, "sample tile catalog loads")
	_assert_eq(sample.catalog_id, "sample_hex_tile_catalog", "sample catalog stores id")
	_assert_eq(sample.has_key("terrain.floor"), true, "sample catalog has floor key")
	_assert_eq(sample.entry_for_key("terrain.wall").atlas_coords, Vector2i(1, 0), "sample catalog maps wall key to atlas tile")
	_assert_eq(sample.entry_for_key("object.spawn_marker").is_scene_tile(), true, "sample catalog includes scene tile entry")
	_assert_eq(sample.entry_for_key("object.spawn_marker").scene_path, "res://addons/hex_map_kit/debug/hex_spawn_marker.tscn", "sample catalog preserves scene path")
	_assert_eq(sample.entries_with_tag("terrain").size(), 2, "sample catalog terrain tags load")
	_assert_eq(sample.entries_with_tag("blocking")[0].key, "terrain.wall", "sample catalog wall blocking tag loads")


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
	missing_scene.scene_path = "res://missing/catalog_scene.tscn"
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
	var floor = HexTileCatalogEntry.new()
	floor.key = "terrain.grass"
	floor.entry_type = HexTileCatalogEntry.TYPE_ATLAS
	floor.source_id = 0
	floor.atlas_coords = Vector2i.ZERO
	floor.tags = PackedStringArray(["terrain", "grass", "cost:3"])
	catalog.add_entry(floor)

	var result = HexTileCatalogValidator.validate_catalog(catalog, tile_set)
	var extracted = HexTileCatalogValidator.catalog_key_tags_and_custom_data(catalog, "terrain.grass", tile_set)
	var missing = HexTileCatalogValidator.catalog_key_tags_and_custom_data(catalog, "missing", tile_set)

	_assert_eq(result.error_count(), 0, "catalog validator accepts valid atlas entry")
	_assert_no_issue(result, HexTileCatalogValidator.RULE_TILE_SET_MISSING, "catalog validator has TileSet for valid entry")
	_assert_eq(extracted["tags"], PackedStringArray(["terrain", "grass", "cost:3"]), "catalog validator extracts tags")
	_assert_eq(extracted["custom_data"]["movement_cost"], 3, "catalog validator extracts integer custom data")
	_assert_eq(extracted["custom_data"]["blocks_path"], false, "catalog validator extracts bool custom data")
	_assert_eq(extracted["custom_data"]["terrain_kind"], "grass", "catalog validator extracts string custom data")
	_assert_eq(missing["tags"], PackedStringArray(), "catalog validator returns empty tags for missing key")
	_assert_eq(missing["custom_data"], {}, "catalog validator returns empty custom data for missing key")


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
