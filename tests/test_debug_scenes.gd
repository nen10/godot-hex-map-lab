extends SceneTree

const GeneratedMapDebugScene = preload("res://debug/generated_map_debug.tscn")
const GeneratedMapDebug = preload("res://debug/generated_map_debug.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")

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

	scene.configure_for_test(GeneratedMapDebug.SHAPE_TORIC_SQUARE, 987, 0.45, true, false)
	var toric_data = scene.get_current_map_data()
	_assert_eq(toric_data.cyclic_size, 7, "generated map debug can show toric data")
	_assert_true(HexMapGenerator.is_floor_connected(toric_data), "debug toric data is restored")
	_assert_true(scene.get_current_path().size() > 1, "debug toric data exposes a path")
	_assert_eq(scene.get_split_index(HexVector.zero()), 2, "debug toric data exposes split rule")
	_assert_eq(
		scene.get_display_vector(HexVector.apply_basis(6, 0, 0)).key(),
		HexVector.q_axis().negated().key(),
		"debug toric data uses centered display domain"
	)

	var toric_sizes = [7, 8, 9]
	for index in range(toric_sizes.size()):
		scene.configure_for_test(
			GeneratedMapDebug.SHAPE_TORIC_SQUARE,
			987,
			0.45,
			true,
			false,
			index
		)
		var size_data = scene.get_current_map_data()
		_assert_eq(scene.get_toric_size(), toric_sizes[index], "debug toric size selector")
		_assert_eq(size_data.cells.size(), toric_sizes[index] * toric_sizes[index], "debug toric size cell count")
		_assert_true(HexMapGenerator.is_floor_connected(size_data), "debug toric size data is restored")

	scene.configure_for_test(
		GeneratedMapDebug.SHAPE_TORIC_SQUARE,
		987,
		0.45,
		true,
		false,
		0,
		true
	)
	_assert_true(
		scene.get_display_vectors(HexVector.apply_basis(6, 0, 0)).size() > 1,
		"debug toric unfold display emits glue-margin copies"
	)

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
