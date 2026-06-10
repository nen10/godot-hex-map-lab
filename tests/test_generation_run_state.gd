extends SceneTree

const HexMapGenerationRunState = preload("res://addons/hex_map_kit/editor/hex_map_generation_run_state.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_generation_run_state_transitions()
	_test_tile_settings_state_contract()
	_test_preview_and_dirty_document_states()
	_finish()


func _test_generation_run_state_transitions() -> void:
	var state = HexMapGenerationRunState.new()
	state.update_from_context({
		"running": true,
		"progress": 0.42,
		"status": "Generating",
		"step": HexMapGenerationRunState.STEP_GENERATING,
		"visible": true,
		"progress_bar_visible": true,
		"cancel_available": true,
	})
	var progress = state.to_progress_snapshot()
	var view = state.to_view_state()
	_assert_eq(state.state_id, HexMapGenerationRunState.STATE_GENERATING, "generation state derives generating")
	_assert_eq(progress["state_id"], HexMapGenerationRunState.STATE_GENERATING, "progress snapshot carries generating state")
	_assert_true(bool(progress["visible"]), "progress snapshot is visible")
	_assert_true(bool(progress["cancel_available"]), "generation progress is cancellable")
	_assert_true(bool(view["controls_disabled"]), "running generation disables controls")

	state.update_from_context({"cancel_requested": true})
	_assert_eq(state.state_id, HexMapGenerationRunState.STATE_CANCELLING, "cancel request derives cancelling state")

	state.update_from_context({
		"running": false,
		"cancel_requested": false,
		"status": "Blocked: missing profile",
		"block_reason": "missing profile",
	})
	view = state.to_view_state()
	_assert_eq(state.state_id, HexMapGenerationRunState.STATE_BLOCKED, "block reason derives blocked state")
	_assert_true(bool(view["generate_button_disabled"]), "blocked generation disables Generate")
	_assert_eq(String(view["generate_button_tooltip"]), "missing profile", "blocked state exposes tooltip reason")


func _test_tile_settings_state_contract() -> void:
	var state = HexMapGenerationRunState.new()
	state.update_from_context({
		"tile_settings_pending": true,
		"tile_settings_token": 12,
		"tile_settings_apply_count": 3,
		"heavy_update_reason": "orientation",
		"orientation": 1,
		"tile_size": Vector2i(32, 28),
		"status": "Tile settings update queued",
		"visible": true,
	})
	var snapshot = state.tile_settings_snapshot("Tile settings update queued")
	_assert_eq(state.state_id, HexMapGenerationRunState.STATE_PREVIEW_QUEUED, "pending tile settings derive queued state")
	_assert_true(bool(snapshot["pending"]), "tile settings snapshot reports pending")
	_assert_eq(String(snapshot["heavy_update_reason"]), "orientation", "tile settings snapshot records heavy update reason")
	_assert_eq(snapshot["tile_size"], Vector2i(32, 28), "tile settings snapshot carries tile size")

	state.update_from_context({
		"tile_settings_pending": false,
		"tile_settings_last_apply_result": true,
		"status": "Tile settings applied",
	})
	snapshot = state.tile_settings_snapshot("Tile settings applied")
	_assert_eq(state.state_id, HexMapGenerationRunState.STATE_APPLIED_TILE_SETTINGS, "applied tile settings derives applied state")
	_assert_true(bool(snapshot["last_apply_result"]), "tile settings snapshot records last apply result")


func _test_preview_and_dirty_document_states() -> void:
	var state = HexMapGenerationRunState.new()
	state.update_from_context({
		"generated_preview_present": true,
		"status": "Ready",
	})
	_assert_eq(state.state_id, HexMapGenerationRunState.STATE_GENERATED_PREVIEW, "generated preview derives preview state")

	state.update_from_context({"dirty_document": true})
	var view = state.to_view_state()
	_assert_eq(state.state_id, HexMapGenerationRunState.STATE_APPLIED_DIRTY_DOCUMENT, "dirty document derives applied dirty state")
	_assert_true(bool(view["dirty_document"]), "view state exposes dirty document")


func _finish() -> void:
	if _failures.is_empty():
		print("test_generation_run_state.gd: all tests passed")
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
