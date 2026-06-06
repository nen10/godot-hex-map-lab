extends SceneTree

const GeneratedMapDebugScene = preload("res://debug/generated_map_debug.tscn")
const GeneratedMapDebug = preload("res://debug/generated_map_debug.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexToricMapSplitRule = preload("res://addons/hex_map_kit/core/hex_toric_map_split_rule.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var scene = GeneratedMapDebugScene.instantiate()
	root.add_child(scene)
	await process_frame

	var default_data = scene.get_current_map_data()
	_assert_eq(default_data.cells.size(), 48, "generated map debug starts with rectangle data")
	_assert_true(HexMapGenerator.is_floor_connected(default_data), "default debug data is restored")
	_assert_true(scene.get_current_path().size() > 1, "default debug data exposes a path")

	scene.configure_for_test(GeneratedMapDebug.SHAPE_HEXAGON, 246, 0.45, true, true)
	var hexagon_data = scene.get_current_map_data()
	_assert_eq(hexagon_data.cells.size(), 37, "generated map debug can show hexagon data")
	_assert_true(HexMapGenerator.is_floor_connected(hexagon_data), "debug hexagon data is restored")
	_assert_true(scene.get_current_path().size() > 1, "debug hexagon data exposes a path")

	scene.configure_for_test(GeneratedMapDebug.SHAPE_TORUS, 987, 0.45, true, false)
	var toric_data = scene.get_current_map_data()
	_assert_eq(toric_data.cyclic_size, 7, "generated map debug can show torus data")
	_assert_true(HexMapGenerator.is_floor_connected(toric_data), "debug torus data is restored")
	_assert_true(scene.get_current_path().size() > 1, "debug torus data exposes a path")
	_assert_eq(scene.get_split_index(HexVector.zero()), 2, "debug torus data exposes split rule")
	_assert_eq(
		scene.get_display_vector(HexVector.apply_basis(6, 0, 0)).key(),
		HexVector.apply_basis(6, 0, 0).key(),
		"debug torus data starts with default display domain"
	)

	scene.configure_for_test(
		GeneratedMapDebug.SHAPE_TORUS,
		987,
		0.45,
		HexMapGenerator.CONNECT_DENSE,
		false,
		0,
		false,
		false,
		true
	)
	var symmetric_toric_data = scene.get_current_map_data()
	var expected_symmetric_data = HexMapGenerator.generate_symmetric_square(
		3,
		0.45,
		987,
		HexMapGenerator.CONNECT_DENSE,
		[HexVector.zero()],
		20,
		[],
		true
	)
	_assert_true(scene.uses_symmetric_toric_generation(), "debug sym-gen mode is active for odd N")
	_assert_eq(symmetric_toric_data.cyclic_size, 7, "debug sym-gen data stores cyclic size")
	_assert_true(HexMapGenerator.is_floor_connected(symmetric_toric_data), "debug sym-gen data is restored")
	_assert_true(scene.get_current_path().size() > 1, "debug sym-gen data exposes a path")
	_assert_eq(scene.get_split_index(HexVector.zero()), 2, "debug sym-gen data exposes split rule")
	_assert_eq(
		_keys(symmetric_toric_data.walls),
		_keys(expected_symmetric_data.walls),
		"debug sym-gen data uses symmetric generator"
	)

	var toric_sizes = [7, 8, 9, 11, 13, 19]
	for index in range(toric_sizes.size()):
		scene.configure_for_test(
			GeneratedMapDebug.SHAPE_TORUS,
			987,
			0.45,
			true,
			false,
			index
		)
		var size_data = scene.get_current_map_data()
		_assert_eq(scene.get_toric_size(), toric_sizes[index], "debug torus size selector")
		_assert_eq(size_data.cells.size(), toric_sizes[index] * toric_sizes[index], "debug torus size cell count")
		_assert_true(HexMapGenerator.is_floor_connected(size_data), "debug torus size data is restored")

	for index in [0, 2, 3, 4, 5]:
		scene.configure_for_test(
			GeneratedMapDebug.SHAPE_TORUS,
			987,
			0.45,
			true,
			false,
			index,
			false,
			false,
			true
		)
		var symmetric_size_data = scene.get_current_map_data()
		var toric_size = toric_sizes[index]
		_assert_true(scene.uses_symmetric_toric_generation(), "debug sym-gen size selector uses odd N")
		_assert_eq(scene.get_toric_size(), toric_size, "debug sym-gen size selector")
		_assert_eq(
			symmetric_size_data.cells.size(),
			toric_size * toric_size,
			"debug sym-gen size cell count"
		)
		_assert_true(
			HexMapGenerator.is_floor_connected(symmetric_size_data),
			"debug sym-gen size data is restored"
		)

	scene.configure_for_test(
		GeneratedMapDebug.SHAPE_TORUS,
		987,
		0.45,
		true,
		false,
		1,
		false,
		false,
		true
	)
	var even_size_data = scene.get_current_map_data()
	_assert_eq(scene.get_toric_size(), 8, "debug sym-gen keeps N=8 visible")
	_assert_true(
		not scene.uses_symmetric_toric_generation(),
		"debug sym-gen skips even N because 9-split requires odd N"
	)
	_assert_eq(even_size_data.cells.size(), 64, "debug sym-gen even N falls back to standard cell count")
	_assert_true(HexMapGenerator.is_floor_connected(even_size_data), "debug sym-gen even N fallback is restored")

	scene.configure_for_test(
		GeneratedMapDebug.SHAPE_TORUS,
		987,
		0.45,
		true,
		false,
		0,
		true
	)
	_assert_true(
		scene.get_display_vectors(HexVector.apply_basis(6, 0, 0)).size() > 1,
		"debug torus unfold display emits glue-margin copies"
	)

	scene.configure_for_test(
		GeneratedMapDebug.SHAPE_TORUS,
		987,
		0.45,
		true,
		false,
		0,
		false,
		false,
		false,
		true
	)
	_assert_eq(
		scene.get_display_vector(HexVector.apply_basis(6, 0, 0)).key(),
		HexVector.q_axis().negated().key(),
		"debug torus centered display uses centered representative"
	)

	scene.configure_for_test(
		GeneratedMapDebug.SHAPE_TORUS,
		987,
		0.45,
		true,
		false,
		0,
		false,
		false,
		false,
		false,
		true,
		true
	)
	_assert_true(scene.is_loop_path_enabled(), "debug torus exposes loop path toggle state")
	_assert_true(scene.is_cell_hit_display_enabled(), "debug torus exposes cell hit toggle state")
	_assert_eq(
		scene.get_current_visual_path().size(),
		scene.get_current_path().size(),
		"debug torus loop path keeps path cardinality"
	)

	scene.configure_for_test(
		GeneratedMapDebug.SHAPE_TORUS,
		987,
		0.45,
		true,
		false,
		0,
		true,
		false,
		true
	)
	_assert_true(
		scene.get_display_vectors(HexVector.apply_basis(6, 0, 0)).size() > 1,
		"debug sym-gen unfold display emits glue-margin copies"
	)

	scene.configure_for_test(
		GeneratedMapDebug.SHAPE_TORUS,
		987,
		0.45,
		true,
		false,
		0,
		false,
		false,
		true,
		true
	)
	_assert_eq(
		scene.get_display_vector(HexVector.apply_basis(6, 0, 0)).key(),
		HexVector.q_axis().negated().key(),
		"debug sym-gen centered display uses centered representative"
	)

	scene.configure_for_test(
		GeneratedMapDebug.SHAPE_TORUS,
		987,
		0.45,
		true,
		false,
		0,
		false,
		true
	)
	var phase2_tiling_groups = scene.get_phase2_outer_mod_tiling_groups()
	_assert_eq(phase2_tiling_groups.size(), 5, "debug phase2 outer_mod exposes compact tiling groups")
	for group in phase2_tiling_groups:
		var max_distance = 0
		for left in range(group.size()):
			for right in range(left + 1, group.size()):
				max_distance = maxi(max_distance, group[left].subtract(group[right]).l1_norm())
		_assert_true(max_distance <= 4, "debug phase2 outer_mod tiling groups stay local")
	var reference_tiling_groups = scene.get_unity_reference_tiling_groups()
	_assert_eq(reference_tiling_groups.size(), 1, "debug phase2 exposes compact unity reference groups")
	for group in reference_tiling_groups:
		var max_distance = 0
		for left in range(group.size()):
			for right in range(left + 1, group.size()):
				max_distance = maxi(max_distance, group[left].subtract(group[right]).l1_norm())
		_assert_true(max_distance <= 4, "debug unity reference tiling groups stay local")

	scene.configure_for_test(
		GeneratedMapDebug.SHAPE_TORUS,
		987,
		0.45,
		true,
		false,
		3,
		false,
		true
	)
	_assert_eq(scene.get_toric_size(), 11, "debug torus size selector includes N=11")
	var symmetry_tags = scene.get_symmetry_region_tags()
	var has_symmetry_center := false
	for tag in symmetry_tags.values():
		if tag["kind"] == HexToricMapSplitRule.SYMMETRY_KIND_CENTER:
			has_symmetry_center = true
	_assert_true(symmetry_tags.size() > 0, "debug torus symmetry overlay exposes region tags")
	_assert_eq(symmetry_tags.size(), scene.get_toric_size() * scene.get_toric_size(), "debug torus symmetry overlay covers canvas")
	_assert_true(has_symmetry_center, "debug torus symmetry overlay exposes center")

	scene.configure_for_test(
		GeneratedMapDebug.SHAPE_TORUS,
		987,
		0.45,
		true,
		false,
		3,
		false,
		true,
		true
	)
	_assert_true(scene.uses_symmetric_toric_generation(), "debug sym-gen symmetry overlay uses symmetric data")
	var symmetric_symmetry_tags = scene.get_symmetry_region_tags()
	var has_symmetric_symmetry_center := false
	for tag in symmetric_symmetry_tags.values():
		if tag["kind"] == HexToricMapSplitRule.SYMMETRY_KIND_CENTER:
			has_symmetric_symmetry_center = true
	_assert_true(
		symmetric_symmetry_tags.size() > 0,
		"debug sym-gen symmetry overlay exposes region tags"
	)
	_assert_eq(
		symmetric_symmetry_tags.size(),
		scene.get_toric_size() * scene.get_toric_size(),
		"debug sym-gen symmetry overlay covers canvas"
	)
	_assert_true(
		has_symmetric_symmetry_center,
		"debug sym-gen symmetry overlay exposes center"
	)

	var runtime_layer = HexTileMapLayer.new()
	root.add_child(runtime_layer)
	await process_frame
	var duplicate_visual = HexVector.apply_basis(-3, 0, 0)
	runtime_layer.hex_size = 10.0
	runtime_layer.loop_display_enabled = true
	runtime_layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	runtime_layer.loop_display_rect = Rect2(runtime_layer.hex_to_local(duplicate_visual) - Vector2.ONE, Vector2(2, 2))
	runtime_layer.apply_map(HexMapResource.from_map_data(HexMapData.square(3, true)))
	_assert_eq(
		runtime_layer._loop_tile_map.get_cell_atlas_coords(HexMapTileAdapter.vector_to_map_cell(duplicate_visual, true)),
		runtime_layer.floor_atlas_coords,
		"debug test observes runtime loop duplicate tile copy state"
	)
	runtime_layer.queue_free()

	scene.queue_free()
	await process_frame

	if _failures.is_empty():
		print("test_debug_scenes.gd: all tests passed")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])


func _keys(points: Array) -> Array:
	var result: Array = []
	for point in points:
		result.append(point.key())
	result.sort()
	return result
