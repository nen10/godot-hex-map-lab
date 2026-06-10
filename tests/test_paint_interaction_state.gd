extends SceneTree

const HexMapPaintInteractionState = preload("res://addons/hex_map_kit/editor/hex_map_paint_interaction_state.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_no_target_blocks_paint()
	_test_ready_hover_selected_dirty_and_validation_states()
	_finish()


func _test_no_target_blocks_paint() -> void:
	var state = HexMapPaintInteractionState.new()
	state.update_from_context({
		"target": {"present": false},
		"document": {"present": false},
		"brush": {"ready": false},
	})
	var view = state.to_view_state()
	_assert_eq(state.state_id, HexMapPaintInteractionState.STATE_NO_TARGET, "missing target is primary paint state")
	_assert_true(state.active_state_ids.has(HexMapPaintInteractionState.STATE_NO_DOCUMENT), "missing document is active state")
	_assert_true(state.active_state_ids.has(HexMapPaintInteractionState.STATE_MISSING_ASSET), "missing brush is active state")
	_assert_true(not bool(view["can_paint"]), "paint is blocked without target/document/brush")
	_assert_eq(String(view["status_text"]), "No editable target layer.", "no-target status is user-facing")


func _test_ready_hover_selected_dirty_and_validation_states() -> void:
	var state = HexMapPaintInteractionState.new()
	state.update_from_context({
		"target": {
			"present": true,
			"ready": true,
			"name": "Terrain",
			"role": "terrain",
		},
		"document": {
			"present": true,
			"dirty": true,
			"status": "dirty",
		},
		"brush": {
			"ready": true,
			"mode": "floor_tile",
			"mode_label": "Floor",
			"brush_key": "terrain.floor",
		},
		"hovered_cell": {
			"present": true,
			"cell_key": "0,0,0",
		},
		"selected_cell": {
			"present": true,
			"cell_key": "0,0,0",
		},
		"last_apply": {
			"present": true,
			"applied": true,
			"summary": "Paint edit applied.",
		},
		"validation_focus": {
			"focused": true,
			"focus_target": "cell",
		},
	})
	var snapshot = state.to_state_snapshot()
	var view = state.to_view_state()
	_assert_eq(state.state_id, HexMapPaintInteractionState.STATE_VALIDATION_FOCUS, "validation focus outranks dirty/selection states")
	_assert_true(state.active_state_ids.has(HexMapPaintInteractionState.STATE_READY), "ready state remains active")
	_assert_true(state.active_state_ids.has(HexMapPaintInteractionState.STATE_SELECTED_CELL), "selected cell is active")
	_assert_true(state.active_state_ids.has(HexMapPaintInteractionState.STATE_APPLIED_DIRTY), "dirty apply state is active")
	_assert_true(bool(view["can_paint"]), "ready target/document/brush can paint")
	_assert_eq(String(view["selected_cell_key"]), "0,0,0", "view state exposes selected cell key")
	_assert_eq(String(view["brush_key"]), "terrain.floor", "view state exposes brush key")
	_assert_eq(String((snapshot["view_state"] as Dictionary)["state_source"]), "HexMapPaintInteractionState", "snapshot nests paint ViewState")


func _finish() -> void:
	if _failures.is_empty():
		print("test_paint_interaction_state.gd: all tests passed")
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
