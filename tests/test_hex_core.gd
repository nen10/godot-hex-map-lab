extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexPoint = preload("res://addons/hex_map_kit/core/hex_point.gd")
const HexToricCoordinate = preload("res://addons/hex_map_kit/core/hex_toric_coordinate.gd")
const HexToricMapSplitRule = preload("res://addons/hex_map_kit/core/hex_toric_map_split_rule.gd")
const HexGrid = preload("res://addons/hex_map_kit/core/hex_grid.gd")
const HexDisjointSet = preload("res://addons/hex_map_kit/core/hex_disjoint_set.gd")
const HexMovementProfile = preload("res://addons/hex_map_kit/core/hex_movement_profile.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run()


func _run() -> void:
	_test_hex_vector_basis_normalization()
	_test_hex_vector_directions()
	_test_hex_point_offset_roundtrip()
	_test_hex_point_distance_and_addition()
	_test_toric_coordinate_wraps_axial_values()
	_test_toric_coordinate_centered_vectors_preserve_identity()
	_test_toric_coordinate_unfolded_vectors_preserve_identity()
	_test_grid_neighbors_and_connected_area()
	_test_grid_toric_connected_area_wraps_neighbors()
	_test_grid_l1_ring_and_disc()
	_test_grid_shortest_path_uses_enterable_points()
	_test_grid_toric_shortest_path_wraps_edges()
	_test_movement_profile_defines_defaults_costs_and_blockers()
	_test_toric_split_rule_triangle_units()
	_test_toric_split_rule_partitions_square_canvas()
	_test_toric_split_rule_rough_tags()
	_test_toric_split_rule_symmetry_tags_cover_canvas()
	_test_toric_split_rule_symmetry_regions_follow_unity_flow()
	_test_toric_split_rule_unity_reference_groups()
	_test_inner_area_distance_from_split8_center()
	_test_inner_area_cell_count_per_step()
	_test_disjoint_set_union_find()

	if _failures.is_empty():
		print("test_hex_core.gd: all tests passed")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_false(value: bool, message: String) -> void:
	if value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _assert_vector_eq(actual, expected, message: String) -> void:
	if not actual.is_equal(expected):
		_failures.append(
			"%s: expected %s, got %s" % [message, expected.debug_string(), actual.debug_string()]
		)


func _assert_keys_eq(actual: Array, expected: Array, message: String) -> void:
	var actual_keys = _keys(actual)
	var expected_keys = _keys(expected)
	if actual_keys != expected_keys:
		_failures.append("%s: expected %s, got %s" % [message, str(expected_keys), str(actual_keys)])


func _keys(points: Array) -> Array:
	var result: Array = []
	for point in points:
		result.append(point.key())
	return result


func _sorted_keys(points: Array) -> Array:
	var result = _keys(points)
	result.sort()
	return result


func _assert_sorted_keys_eq(actual: Array, expected: Array, message: String) -> void:
	var actual_keys = _sorted_keys(actual)
	var expected_keys = _sorted_keys(expected)
	if actual_keys != expected_keys:
		_failures.append("%s: expected %s, got %s" % [message, str(expected_keys), str(actual_keys)])


func _test_hex_vector_basis_normalization() -> void:
	_assert_vector_eq(
		HexVector.apply_basis(1, 0, 1),
		HexVector.s_axis().negated(),
		"Q + R should normalize to -S"
	)
	_assert_vector_eq(
		HexVector.apply_basis(3, 1, 3),
		HexVector.apply_basis(0, -2, 0),
		"basis should slide redundant shared components"
	)
	_assert_eq(HexVector.apply_basis(3, 1, 3).l1_norm(), 2, "normalized L1 norm")
	_assert_eq(HexVector.zero().l2_norm(), 0.0, "zero L2 norm")


func _test_hex_vector_directions() -> void:
	var keys: Dictionary = {}
	for direction in HexVector.directions():
		keys[direction.key()] = true
		_assert_eq(direction.l1_norm(), 1, "each axial neighbor direction has cost 1")

	_assert_eq(keys.size(), 6, "six directions should be unique")
	_assert_vector_eq(
		HexVector.q_axis().add(HexVector.r_axis()),
		HexVector.s_axis().negated(),
		"axis addition follows the Unity basis"
	)


func _test_hex_point_offset_roundtrip() -> void:
	for y in range(-3, 4):
		for x in range(-2, 3):
			var point = HexPoint.from_offset(x, y)
			_assert_eq(point.to_offset(), Vector2i(x, y), "offset roundtrip")


func _test_hex_point_distance_and_addition() -> void:
	var origin = HexPoint.from_offset(0, 0)
	var east = origin.add_vector(HexVector.q_axis())
	var southeast = origin.add_vector(HexVector.s_axis().negated())

	_assert_eq(east.to_offset(), Vector2i(1, 0), "Q direction maps to offset east")
	_assert_eq(southeast.to_offset(), Vector2i(0, 1), "-S direction maps to next row")
	_assert_eq(origin.l1_distance_to(east), 1, "neighbor distance is 1")
	_assert_eq(origin.l1_distance_to(southeast), 1, "diagonal row neighbor distance is 1")
	_assert_vector_eq(origin.vector_to(east), HexVector.q_axis(), "vector_to points toward target")
	_assert_vector_eq(east.vector_from(origin), HexVector.q_axis(), "vector_from points away from source")


func _test_toric_coordinate_wraps_axial_values() -> void:
	var wrapped_negative = HexToricCoordinate.apply_cyclic(HexVector.q_axis().negated(), 5)
	_assert_eq(wrapped_negative.axial(), Vector2i(4, 0), "negative Q wraps into cyclic range")

	var wrapped_overflow = HexToricCoordinate.apply_cyclic(HexVector.apply_basis(0, 0, 5), 5)
	_assert_eq(wrapped_overflow.axial(), Vector2i(0, 0), "R overflow wraps to zero")

	var wrapped_s = HexToricCoordinate.apply_cyclic(HexVector.s_axis(), 5)
	_assert_eq(wrapped_s.axial(), Vector2i(4, 4), "S axis wraps through q-s/r-s axial values")


func _test_toric_coordinate_centered_vectors_preserve_identity() -> void:
	_assert_vector_eq(
		HexToricCoordinate.centered_vector(HexVector.apply_basis(6, 0, 0), 7),
		HexVector.q_axis().negated(),
		"centered toric vector uses negative Q representative"
	)
	_assert_vector_eq(
		HexToricCoordinate.centered_vector(HexVector.apply_basis(6, 0, 6), 7),
		HexVector.s_axis(),
		"centered toric vector normalizes wrapped diagonal corner"
	)

	var size = 5
	var centered_keys := {}
	for r in range(size):
		for q in range(size):
			var original = HexVector.apply_basis(q, 0, r)
			var centered = HexToricCoordinate.centered_vector(original, size)
			centered_keys[centered.key()] = true
			_assert_vector_eq(
				HexToricCoordinate.wrap_vector(centered, size),
				original,
				"centered toric vector wraps back to original identity"
			)
			_assert_true(
				centered.l_infinity_norm() <= 2,
				"centered toric vector stays inside map unit radius"
			)

	_assert_eq(centered_keys.size(), 25, "centered toric domain preserves every square cell")


func _test_toric_coordinate_unfolded_vectors_preserve_identity() -> void:
	var size = 7
	var point = HexVector.apply_basis(6, 0, 0)
	var unfolded = HexToricCoordinate.unfolded_vectors(point, size)

	_assert_true(unfolded.size() > 1, "unfolded toric vectors include glue-margin copies")
	_assert_vector_eq(
		unfolded[0],
		HexToricCoordinate.centered_vector(point, size),
		"unfolded toric vectors keep centered representative first"
	)

	var unfolded_keys := {}
	for duplicate in unfolded:
		unfolded_keys[duplicate.key()] = true
		_assert_vector_eq(
			HexToricCoordinate.wrap_vector(duplicate, size),
			HexToricCoordinate.wrap_vector(point, size),
			"unfolded toric vector wraps back to original identity"
		)
		_assert_true(duplicate.l1_norm() <= size, "unfolded vector stays in visible glue domain")

	_assert_eq(unfolded_keys.size(), unfolded.size(), "unfolded toric copies are unique")


func _test_grid_neighbors_and_connected_area() -> void:
	var origin = HexVector.zero()
	var neighbors = HexGrid.neighbors(origin)

	_assert_eq(neighbors.size(), 6, "grid returns six neighbors")
	_assert_vector_eq(neighbors[0], HexVector.q_axis(), "neighbor order matches Unity HexPath")
	_assert_vector_eq(neighbors[1], HexVector.r_axis().negated(), "neighbor order includes -R second")

	var enterable: Array = [origin]
	enterable.append_array(neighbors)
	var connected = HexGrid.connected_area(origin, enterable)
	_assert_eq(connected.size(), 7, "origin plus all neighbors are connected")

	var split_area: Array = [
		origin,
		HexVector.q_axis(),
		HexVector.q_axis().scaled(2),
		HexVector.r_axis().scaled(2),
	]
	_assert_eq(
		HexGrid.connected_area(origin, split_area).size(),
		3,
		"disconnected enterable positions stay excluded"
	)


func _test_grid_toric_connected_area_wraps_neighbors() -> void:
	var origin = HexVector.zero()
	var wrapped_west = HexToricCoordinate.wrap_vector(HexVector.q_axis().negated(), 3)
	var enterable: Array = [origin, wrapped_west]
	var connected = HexGrid.connected_area(origin, enterable, 3)

	_assert_eq(connected.size(), 2, "toric connected area follows wrapped neighbor")


func _test_grid_l1_ring_and_disc() -> void:
	var radius = 2
	var ring = HexGrid.l1_ring(radius)
	var ring_keys := {}
	for point in ring:
		ring_keys[point.key()] = true
		_assert_eq(point.l1_norm(), radius, "L1 ring contains only radius-distance cells")

	_assert_eq(ring.size(), 12, "radius 2 L1 ring has 6r cells")
	for direction in HexVector.directions():
		_assert_true(
			ring_keys.has(direction.scaled(radius).key()),
			"L1 ring contains every axial corner"
		)

	var disc = HexGrid.l1_disc(radius)
	for point in disc:
		_assert_true(point.l1_norm() <= radius, "L1 disc contains only cells within radius")

	_assert_eq(disc.size(), 19, "radius 2 L1 disc has hexagonal cell count")
	_assert_vector_eq(HexGrid.l1_disc(0)[0], HexVector.zero(), "radius 0 disc is origin only")

	var center = HexVector.apply_basis(2, 0, 3)
	var shifted = HexGrid.l1_disc(1, center)
	for point in shifted:
		_assert_true(point.subtract(center).l1_norm() <= 1, "shifted L1 disc is relative to origin")


func _test_grid_shortest_path_uses_enterable_points() -> void:
	var cells: Array = [
		HexVector.zero(),
		HexVector.q_axis(),
		HexVector.q_axis().scaled(2),
		HexVector.q_axis().scaled(3),
	]
	var path = HexGrid.shortest_path(HexVector.zero(), [HexVector.q_axis().scaled(3)], cells)
	_assert_keys_eq(path, cells, "shortest path follows a simple line")

	var blocked: Array = [
		HexVector.zero(),
		HexVector.q_axis(),
		HexVector.q_axis().scaled(3),
	]
	_assert_eq(
		HexGrid.shortest_path(HexVector.zero(), [HexVector.q_axis().scaled(3)], blocked).size(),
		0,
		"shortest path fails when enterable points are disconnected"
	)

	var nearest = HexGrid.shortest_path(
		HexVector.zero(),
		[HexVector.q_axis().scaled(3), HexVector.q_axis()],
		cells
	)
	_assert_keys_eq(
		nearest,
		[HexVector.zero(), HexVector.q_axis()],
		"shortest path stops at the nearest reachable goal"
	)


func _test_grid_toric_shortest_path_wraps_edges() -> void:
	var origin = HexVector.zero()
	var wrapped_west = HexToricCoordinate.wrap_vector(HexVector.q_axis().negated(), 3)
	var path = HexGrid.shortest_path(
		origin,
		[HexVector.q_axis().negated()],
		[origin, wrapped_west],
		3
	)

	_assert_keys_eq(path, [origin, wrapped_west], "toric shortest path follows wrapped edge")


func _test_movement_profile_defines_defaults_costs_and_blockers() -> void:
	var profile = HexMovementProfile.new()
	var floor_state = profile.cell_state(HexMovementProfile.KIND_FLOOR)
	var wall_state = profile.cell_state(HexMovementProfile.KIND_WALL)
	_assert_eq(bool(floor_state["passable"]), true, "movement profile default floor is passable")
	_assert_eq(float(floor_state["cost"]), 1.0, "movement profile default floor cost is 1")
	_assert_eq(bool(wall_state["passable"]), false, "movement profile default wall is blocked")
	_assert_eq((wall_state["blockers"] as PackedStringArray).has(HexMovementProfile.BLOCKER_WALL), true, "movement profile records wall blocker")

	profile.default_cost = 1.5
	profile.wall_passable = true
	profile.wall_cost = 4.0
	profile.terrain_costs = {
		"terrain.swamp": 3.0,
		"mud": 2.0,
	}
	profile.blocker_keys = PackedStringArray(["terrain.lava"])
	profile.blocker_tags = PackedStringArray(["blocking"])
	var swamp_state = profile.cell_state(HexMovementProfile.KIND_FLOOR, "terrain.swamp")
	var mud_state = profile.cell_state(HexMovementProfile.KIND_FLOOR, "", PackedStringArray(["mud"]))
	var lava_state = profile.cell_state(HexMovementProfile.KIND_FLOOR, "terrain.lava")
	var tag_blocked_state = profile.cell_state(HexMovementProfile.KIND_FLOOR, "terrain.crate", PackedStringArray(["blocking"]))
	var passable_wall_state = profile.cell_state(HexMovementProfile.KIND_WALL)
	_assert_eq(float(swamp_state["cost"]), 3.0, "movement profile uses catalog-key cost override")
	_assert_eq(float(mud_state["cost"]), 2.0, "movement profile uses tag cost override")
	_assert_eq(bool(lava_state["passable"]), false, "movement profile blocks configured catalog key")
	_assert_eq((lava_state["blockers"] as PackedStringArray).has("terrain.lava"), true, "movement profile records catalog blocker")
	_assert_eq(bool(tag_blocked_state["passable"]), false, "movement profile blocks configured tag")
	_assert_eq(bool(passable_wall_state["passable"]), true, "movement profile can allow walls")
	_assert_eq(float(passable_wall_state["cost"]), 4.0, "movement profile uses passable wall cost")


func _test_toric_split_rule_triangle_units() -> void:
	var origin = HexVector.zero()
	var flat_left = HexToricMapSplitRule.triangle(3, origin, true)
	var flat_right = HexToricMapSplitRule.triangle(3, origin, false)

	_assert_sorted_keys_eq(
		flat_left,
		[
			HexVector.apply_basis(0, 0, 0),
			HexVector.apply_basis(0, 0, 1),
			HexVector.apply_basis(0, 0, 2),
			HexVector.apply_basis(1, 0, 1),
			HexVector.apply_basis(1, 0, 2),
			HexVector.apply_basis(2, 0, 2),
		],
		"flat-left triangle follows Unity Geometry.Triangle r-q>=0 rule"
	)
	_assert_sorted_keys_eq(
		flat_right,
		[
			HexVector.apply_basis(0, 0, 0),
			HexVector.apply_basis(1, 0, 0),
			HexVector.apply_basis(2, 0, 0),
			HexVector.apply_basis(1, 0, 1),
			HexVector.apply_basis(2, 0, 1),
			HexVector.apply_basis(2, 0, 2),
		],
		"flat-right triangle follows Unity Geometry.Triangle r-q<=0 rule"
	)


func _test_toric_split_rule_partitions_square_canvas() -> void:
	var rule = HexToricMapSplitRule.new(2)
	var expected_cells: Array = []
	for r in range(rule.cyclic_size):
		for q in range(rule.cyclic_size):
			expected_cells.append(HexVector.apply_basis(q, 0, r))

	_assert_eq(rule.map_unit_radius, 2, "split rule stores map unit radius")
	_assert_eq(rule.cyclic_size, 5, "split rule cyclic size is 2r+1")
	_assert_eq(rule.split_canvas.size(), 9, "split rule creates eight triangles and one center")
	_assert_eq(rule.split_canvas_origins.size(), 9, "split rule stores every split origin")
	_assert_eq(rule.split_tag.size(), 25, "split tags cover every square canvas cell once")
	_assert_sorted_keys_eq(rule.canvas_cells(), expected_cells, "split canvas partitions toric square")

	for index in range(8):
		_assert_eq(rule.split_canvas[index].size(), 3, "radius 2 triangle split area cell count")
	_assert_eq(rule.split_canvas[8].size(), 1, "split area 8 is the center cell")

	for cell in expected_cells:
		_assert_true(rule.split_index_for(cell) >= 0, "every canvas cell has a split index")


func _test_toric_split_rule_rough_tags() -> void:
	var rule = HexToricMapSplitRule.new(2)

	_assert_eq(rule.get_rough_split_tag(rule.split_canvas[0][0]), 0, "rough tag preserves split 0")
	_assert_eq(rule.get_rough_split_tag(rule.split_canvas[7][0]), 7, "rough tag preserves split 7")
	_assert_eq(rule.get_rough_split_tag(rule.split_canvas[3][0]), 8, "rough tag groups inner side split")
	_assert_eq(rule.get_rough_split_tag(rule.split_canvas[8][0]), 8, "rough tag preserves center group")


func _test_toric_split_rule_symmetry_tags_cover_canvas() -> void:
	for radius in range(1, 10):
		var rule = HexToricMapSplitRule.new(radius)
		var tags = rule.symmetry_generation_tags()
		var tag_keys = tags.keys()
		tag_keys.sort()
		_assert_eq(
			tag_keys,
			_sorted_keys(rule.canvas_cells()),
			"radius %d symmetry tags cover every canvas cell" % radius
		)
		for tag in tags.values():
			var wrapped = HexToricCoordinate.wrap_vector(tag["source"], rule.cyclic_size)
			_assert_eq(
				tag["vector"].key(),
				wrapped.key(),
				"radius %d symmetry tag vector stores wrapped canvas position" % radius
			)
			_assert_eq(
				tag["moved"],
				not tag["source"].is_equal(tag["vector"]),
				"radius %d symmetry tag moved matches source wrapping" % radius
			)
			_assert_true(rule.split_index_for(tag["vector"]) >= 0, "radius %d symmetry tag vector is on canvas" % radius)


func _test_toric_split_rule_symmetry_regions_follow_unity_flow() -> void:
	for radius in [3, 4, 5, 6]:
		var rule = HexToricMapSplitRule.new(radius)
		var entries = rule.symmetry_generation_entries()
		var tags = rule.symmetry_generation_tags()
		var phase = (radius - 1) % 3
		var kinds := {}
		var has_moved_border := false
		var has_phase2_boundary := false
		var center_entries: Array = []
		var outer_mod_points := {}
		var outer_mod_split_counts := {}
		var phase2_groups = rule.symmetry_phase2_outer_mod_groups()

		_assert_true(entries.size() > 0, "symmetry flow emits draw positions")
		for entry in entries:
			kinds[entry["kind"]] = true
			if entry["kind"] == HexToricMapSplitRule.SYMMETRY_KIND_OUTER_MOD:
				outer_mod_points[entry["source"].key()] = true
				outer_mod_split_counts[entry["source_split"]] = outer_mod_split_counts.get(entry["source_split"], 0) + 1
			if entry["kind"] == HexToricMapSplitRule.SYMMETRY_KIND_OUTER_PHASE2_BOUNDARY:
				has_phase2_boundary = true
			if entry["kind"] == HexToricMapSplitRule.SYMMETRY_KIND_CENTER:
				center_entries.append(entry)
			_assert_eq(entry["phase"], phase, "symmetry flow stores MapUnitRadius mod3 phase")
			_assert_true(rule.split_index_for(entry["vector"]) >= 0, "symmetry flow draws only canvas positions")
			var is_border = entry["kind"] == HexToricMapSplitRule.SYMMETRY_KIND_BORDER_INITIAL
			is_border = is_border or entry["kind"] == HexToricMapSplitRule.SYMMETRY_KIND_BORDER_EDGE
			if entry["moved"] and is_border:
				has_moved_border = true

		_assert_true(kinds.has(HexToricMapSplitRule.SYMMETRY_KIND_OUTER_MOD), "symmetry flow has mod3 outer shape")
		if phase == 2:
			_assert_true(
				kinds.has(HexToricMapSplitRule.SYMMETRY_KIND_OUTER_PHASE2_BOUNDARY),
				"phase2 symmetry flow uses outer boundary correction"
			)
			_assert_true(
				has_phase2_boundary,
				"phase2 symmetry flow has outer boundary correction"
			)
			_assert_true(
				phase2_groups.size() == 5,
				"phase2 symmetry flow exposes five outer_mod toric groups"
			)
			var pair_count = 0
			var triple_count = 0
			var grouped_points := {}
			for group in phase2_groups:
				var raw_group_points := {}
				if group["group"] == HexToricMapSplitRule.SYMMETRY_GROUP_PAIR:
					pair_count += 1
					_assert_eq(group["points"].size(), 2, "phase2 outer_mod pair has two points")
				if group["group"] == HexToricMapSplitRule.SYMMETRY_GROUP_TRIPLE:
					triple_count += 1
					_assert_eq(group["points"].size(), 3, "phase2 outer_mod triple has three points")
				for point in group["points"]:
					_assert_true(
						not raw_group_points.has(point.key()),
						"phase2 outer_mod group points are distinct raw draw positions"
					)
					raw_group_points[point.key()] = true
					grouped_points[point.key()] = true
					_assert_true(
						rule.split_index_for(HexToricCoordinate.wrap_vector(point, rule.cyclic_size)) >= 0,
						"phase2 outer_mod group point wraps to the canvas"
					)
			_assert_eq(pair_count, 3, "phase2 outer_mod has three pair groups")
			_assert_eq(triple_count, 2, "phase2 outer_mod has two triple groups")
			_assert_eq(grouped_points.size(), 12, "phase2 outer_mod groups cover twelve generated points")
			_assert_eq(outer_mod_points.size(), 12, "phase2 outer_mod emits twelve generated points")
			_assert_eq(outer_mod_split_counts.get(0, 0), 6, "phase2 outer_mod emits six points on split 0")
			_assert_eq(outer_mod_split_counts.get(7, 0), 6, "phase2 outer_mod emits six points on split 7")
			for point_key in grouped_points:
				_assert_true(outer_mod_points.has(point_key), "phase2 groups only use emitted outer_mod points")
		else:
			_assert_true(kinds.has(HexToricMapSplitRule.SYMMETRY_KIND_OUTER_WAVE), "symmetry flow has outer-to-center waves")
			_assert_true(not has_phase2_boundary, "non-phase2 flow does not use phase2 boundary")
			_assert_eq(phase2_groups.size(), 0, "non-phase2 flow has no phase2 outer_mod groups")
		_assert_true(kinds.has(HexToricMapSplitRule.SYMMETRY_KIND_BORDER_EDGE), "symmetry flow has moved border arcs")
		_assert_true(kinds.has(HexToricMapSplitRule.SYMMETRY_KIND_INNER_ARC), "symmetry flow has common inner arcs")
		_assert_true(kinds.has(HexToricMapSplitRule.SYMMETRY_KIND_CENTER), "symmetry flow has center")
		_assert_true(has_moved_border, "symmetry flow maps outside border positions back to canvas")
		_assert_eq(center_entries.size(), 1, "symmetry flow has one center entry")
		_assert_true(tags.has(center_entries[0]["vector"].key()), "symmetry center is included in merged tags")
		_assert_eq(tags[center_entries[0]["vector"].key()]["kind"], HexToricMapSplitRule.SYMMETRY_KIND_CENTER, "symmetry center wins merged tag priority")
		_assert_eq(center_entries[0]["split"], 8, "symmetry center belongs to split 8")


func _test_toric_split_rule_unity_reference_groups() -> void:
	var expected_counts := {
		3: {
			HexToricMapSplitRule.SYMMETRY_KIND_OUTER_MOD: 1,
		},
		4: {},
		5: {},
		6: {},
		7: {},
	}

	for radius in expected_counts.keys():
		var rule = HexToricMapSplitRule.new(radius)
		var groups = rule.symmetry_unity_reference_groups()
		var counts := {}
		for group in groups:
			counts[group["kind"]] = counts.get(group["kind"], 0) + 1
			_assert_true(group["sources"].size() > 1, "unity reference group has multiple sources")
			for source in group["sources"]:
				var reference = HexToricCoordinate.wrap_vector(source, rule.cyclic_size)
				_assert_eq(reference.key(), group["reference"].key(), "unity reference group sources share toric reference")

		for kind in [
			HexToricMapSplitRule.SYMMETRY_KIND_OUTER_MOD,
			HexToricMapSplitRule.SYMMETRY_KIND_OUTER_WAVE,
			HexToricMapSplitRule.SYMMETRY_KIND_BORDER_INITIAL,
			HexToricMapSplitRule.SYMMETRY_KIND_BORDER_EDGE,
		]:
			var expected = expected_counts[radius].get(kind, 0)
			_assert_eq(counts.get(kind, 0), expected, "unity reference group count radius %d kind %s" % [radius, kind])


func _test_inner_area_distance_from_split8_center() -> void:
	for radius in range(1, 10):
		var rule = HexToricMapSplitRule.new(radius)
		var entries = rule.symmetry_generation_entries()

		var center_vec = null
		for entry in entries:
			if entry["kind"] == HexToricMapSplitRule.SYMMETRY_KIND_CENTER:
				center_vec = entry["vector"]
				break
		_assert_true(center_vec != null, "radius %d has center entry" % radius)

		var wave_cells := {}
		for entry in entries:
			if entry["kind"] != HexToricMapSplitRule.SYMMETRY_KIND_INNER_ARC:
				continue
			var w = entry["wave"]
			if w not in wave_cells:
				wave_cells[w] = {}
			wave_cells[w][entry["vector"].key()] = entry["vector"]

		var wave_list := wave_cells.keys()
		wave_list.sort()

		var prev_ring_dist := -1
		for w in wave_list:
			var cells = wave_cells[w]
			var dists := {}
			for key in cells:
				var cell = cells[key]
				var diff = cell.subtract(center_vec)
				var dist = diff.l1_norm()
				if dist not in dists:
					dists[dist] = []
				dists[dist].append(key)

			if radius <= 3:
				for c in cells.values():
					var cd = c.subtract(center_vec).l1_norm()
					_assert_eq(cd, radius - w, "radius %d wave %d cell %s distance %d == radius-wave %d" % [radius, w, c.key(), cd, radius - w])

			_assert_true(
				dists.size() == 1,
				"radius %d wave %d: all inner_arc cells share same L1 center distance, got %d" % [radius, w, dists.size()]
			)

			var ring_dist: int = dists.keys()[0]
			if prev_ring_dist != -1:
				_assert_true(
					ring_dist < prev_ring_dist,
					"radius %d wave %d dist %d < previous wave dist %d" % [radius, w, ring_dist, prev_ring_dist]
				)
			prev_ring_dist = ring_dist

		var expected_wave_count = max(radius - 1, 0)
		_assert_eq(wave_list.size(), expected_wave_count, "radius %d inner_arc wave count" % radius)


func _test_inner_area_cell_count_per_step() -> void:
	for radius in range(1, 10):
		var rule = HexToricMapSplitRule.new(radius)
		var entries = rule.symmetry_generation_entries()

		var wave_side_counts := {}
		var total_inner := 0
		for entry in entries:
			if entry["kind"] != HexToricMapSplitRule.SYMMETRY_KIND_INNER_ARC:
				continue
			total_inner += 1
			var w = entry["wave"]
			if w not in wave_side_counts:
				wave_side_counts[w] = {}
			var s = entry["side"]
			wave_side_counts[w][s] = wave_side_counts[w].get(s, 0) + 1

		for w in wave_side_counts:
			for s in wave_side_counts[w]:
				var expected = rule.map_unit_radius - w
				_assert_eq(
					wave_side_counts[w][s],
					expected,
					"radius %d wave %d side %d: %d cells == radius-wave %d" % [radius, w, s, wave_side_counts[w][s], expected]
				)

		var expected_total = 3 * radius * (radius - 1)
		_assert_eq(total_inner, expected_total, "radius %d inner_arc total cells" % radius)


func _test_disjoint_set_union_find() -> void:
	var dsu = HexDisjointSet.new()

	var a = HexVector.q_axis()
	var b = HexVector.q_axis().scaled(2)
	var c = HexVector.r_axis()
	var d = HexVector.r_axis().scaled(2)

	dsu.add_component([a, b])
	dsu.add_component([c, d])

	_assert_eq(dsu.root_count(), 2, "two initial components")
	_assert_eq(dsu.find(a.key()), dsu.find(b.key()), "a and b share root")
	_assert_eq(dsu.find(c.key()), dsu.find(d.key()), "c and d share root")
	_assert_true(dsu.find(a.key()) != dsu.find(c.key()), "separate components have different roots")

	_assert_eq(dsu.comp_size_of(a.key()), 2, "component ab has size 2")
	_assert_eq(dsu.comp_size_of(c.key()), 2, "component cd has size 2")

	_assert_true(dsu.union(a, c), "union of separate components succeeds")
	_assert_eq(dsu.root_count(), 1, "one component after union")
	_assert_eq(dsu.find(a.key()), dsu.find(c.key()), "a and c share root after union")
	_assert_eq(dsu.comp_size_of(a.key()), 4, "unioned component has size 4")
	_assert_false(dsu.union(a, c), "redundant union returns false")
	_assert_eq(dsu.root_count(), 1, "root count unchanged after redundant union")

	dsu.make_set(HexVector.s_axis())
	_assert_eq(dsu.root_count(), 2, "make_set adds new component")
	var s_root = dsu.find(HexVector.s_axis().key())
	_assert_eq(dsu.comp_size_of(s_root), 1, "new singleton has size 1")

	_assert_true(dsu.has(a.key()), "dsu has cell a")
	_assert_false(dsu.has("nonexistent,0,0"), "dsu does not have nonexistent key")

	var roots = dsu.roots()
	_assert_eq(roots.size(), 2, "roots returns correct count")

	var rep = dsu.rep_of(a.key())
	_assert_true(rep != null, "rep_of returns non-null for existing key")
	_assert_true(rep.is_equal(a) or rep.is_equal(b) or rep.is_equal(c) or rep.is_equal(d), "rep is one of the component cells")

	var cell = dsu.cell_by_key(a.key())
	_assert_true(cell != null, "cell_by_key returns non-null")
	_assert_eq(cell.key(), a.key(), "cell_by_key returns correct cell")
