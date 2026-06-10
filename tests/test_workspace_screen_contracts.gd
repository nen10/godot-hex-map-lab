extends SceneTree

const HexMapPaintInteractionState = preload("res://addons/hex_map_kit/editor/hex_map_paint_interaction_state.gd")
const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")
const HexMapWorkspaceRootState = preload("res://addons/hex_map_kit/editor/hex_map_workspace_root_state.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_root_state_derives_current_screen_contract()
	_test_empty_screen_contract_synthesizes_view_state()
	_finish()


func _test_root_state_derives_current_screen_contract() -> void:
	var paint_state = HexMapPaintInteractionState.new()
	paint_state.update_from_context({
		"target": {"present": true, "ready": true, "name": "Terrain"},
		"document": {"present": false},
		"brush": {"ready": true, "mode": "floor_tile", "brush_key": "terrain.floor"},
	})
	var root_state = HexMapWorkspaceRootState.new()
	var tab_names = PackedStringArray(["Resources", "Paint", "Validate", "Export"])
	root_state.update_from_context({
		"current_tab": "Paint",
		"tab_names": tab_names,
		"screen_snapshots": {
			"Resources": {
				"view_state": {
					"state_source": "ResourcesScreenContract",
					"state_id": "ready",
					"status_text": "Resources ready",
				},
				"component_ids": PackedStringArray(["selected_hex_tile_map", "resource_rows"]),
				"asset_slot_ids": PackedStringArray([
					HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
					HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
				]),
			},
			"Paint": {
				"interaction_state": paint_state.to_state_snapshot(),
				"component_ids": PackedStringArray(["brush_summary", "target_layer", "selected_cell"]),
				"asset_slot_ids": PackedStringArray(),
			},
			"Validate": {
				"view_state": {
					"state_source": "ValidateScreenContract",
					"state_id": "ready",
					"status_text": "Validate ready",
				},
				"component_ids": PackedStringArray(["issue_list", "focus_action"]),
				"asset_slot_ids": PackedStringArray([HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE]),
			},
			"Export": {
				"empty_state_text": "Choose an export destination.",
				"purpose_text": "Runtime handoff",
				"component_ids": PackedStringArray(["destination", "runtime_handoff"]),
				"asset_slot_ids": PackedStringArray([HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE]),
			},
		},
	})
	var snapshot = root_state.to_state_snapshot()
	var view = root_state.to_view_state()
	var current = view["current_view_state"] as Dictionary
	var paint_view = (snapshot["screen_view_states"] as Dictionary)["Paint"] as Dictionary
	var resources_view = (snapshot["screen_view_states"] as Dictionary)["Resources"] as Dictionary
	_assert_eq(String(snapshot["state_id"]), HexMapWorkspaceRootState.STATE_SCREEN_BLOCKED, "root state derives blocked current screen")
	_assert_eq(String(current["state_source"]), "HexMapPaintInteractionState", "current screen ViewState comes from Paint state")
	_assert_eq(String(current["state_id"]), HexMapPaintInteractionState.STATE_NO_DOCUMENT, "paint screen exposes no-document contract")
	_assert_eq(paint_view["asset_slot_ids"], PackedStringArray(), "Paint screen contract owns no asset slots")
	_assert_true((paint_view["component_ids"] as PackedStringArray).has("brush_summary"), "Paint screen contract lists brush summary component")
	_assert_true((resources_view["asset_slot_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT), "Resources screen contract lists document slot")
	_assert_eq(String((view["screen_state_ids"] as Dictionary)["Paint"]), HexMapPaintInteractionState.STATE_NO_DOCUMENT, "root state indexes screen state ids")


func _test_empty_screen_contract_synthesizes_view_state() -> void:
	var root_state = HexMapWorkspaceRootState.new()
	root_state.update_from_context({
		"current_tab": "Export",
		"tab_names": PackedStringArray(["Export"]),
		"screen_snapshots": {
			"Export": {
				"empty_state_text": "Choose an export destination.",
				"purpose_text": "Runtime handoff",
				"component_ids": PackedStringArray(["destination", "runtime_handoff"]),
				"asset_slot_ids": PackedStringArray([HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE]),
			},
		},
	})
	var view = root_state.to_view_state()
	var current = view["current_view_state"] as Dictionary
	_assert_eq(String(current["state_id"]), HexMapWorkspaceRootState.STATE_EMPTY, "empty screen synthesizes empty state")
	_assert_eq(String(current["status_text"]), "Choose an export destination.", "empty screen exposes empty-state text")
	_assert_eq(String(current["purpose_text"]), "Runtime handoff", "empty screen keeps purpose text")
	_assert_true((current["component_ids"] as PackedStringArray).has("runtime_handoff"), "empty screen keeps component ids")


func _finish() -> void:
	if _failures.is_empty():
		print("test_workspace_screen_contracts.gd: all tests passed")
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
