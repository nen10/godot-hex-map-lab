extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexPoint = preload("res://addons/hex_map_kit/core/hex_point.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexOverlayData = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexOverlayResource = preload("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd")
const HexOverlayTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_overlay_tile_adapter.gd")
const HexAdjacencyRuleSet = preload("res://addons/hex_map_kit/adapter/hex_adjacency_rule_set.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run()


func _run() -> void:
	_test_vector_to_map_cell_matches_flat_top_offset()
	_test_vector_to_map_cell_matches_pointy_top_offset()
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
