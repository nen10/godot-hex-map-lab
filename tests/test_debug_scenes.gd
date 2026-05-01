extends SceneTree

const GeneratedMapDebugScene = preload("res://debug/generated_map_debug.tscn")
const GeneratedMapDebug = preload("res://debug/generated_map_debug.gd")
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
