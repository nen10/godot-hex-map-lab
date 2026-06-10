extends SceneTree

const HexMapEditorAssetSlotState = preload("res://addons/hex_map_kit/editor/hex_map_editor_asset_slot_state.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_required_missing_and_project_selection_view_state()
	_test_sample_warning_and_invalid_type_state()
	_finish()


func _test_required_missing_and_project_selection_view_state() -> void:
	var slot = HexMapEditorAssetSlotState.new()
	slot.configure(
		"tile_catalog",
		"Tile Catalog",
		&"HexTileCatalogResource",
		true,
		"Catalog entries drive terrain and overlay choices.",
		"Only HexTileCatalogResource can satisfy this slot."
	)
	slot.allows_create_new = true
	var missing_view = slot.view_state()
	_assert_eq(String(missing_view["state_source"]), "HexMapEditorAssetSlotState", "asset slot view state has source")
	_assert_eq(String(missing_view["status_text"]), "Missing", "required missing slot reports Missing")
	_assert_eq(String(missing_view["status_icon"]), "missing", "required missing slot uses missing icon")
	_assert_true(bool((missing_view["actions"] as Dictionary)["create_new"]["visible"]), "create action is visible by configuration")
	_assert_true(String(missing_view["status_tooltip"]).contains("Purpose:"), "status tooltip carries purpose detail")

	var catalog = HexTileCatalogResource.new()
	slot.set_selected_resource(catalog, "res://project/catalog.tres", HexMapEditorAssetSlotState.SOURCE_PROJECT)
	var selected = slot.snapshot()
	_assert_eq(String(selected["status"]), HexMapEditorAssetSlotState.STATUS_SELECTED, "project catalog is selected")
	_assert_eq(String(selected["current_source_badge"]), HexMapEditorAssetSlotState.SOURCE_BADGE_PROJECT, "project catalog source badge is Project")
	_assert_eq(String((selected["view_state"] as Dictionary)["resource_picker_base_type"]), "HexTileCatalogResource", "picker filter remains typed")


func _test_sample_warning_and_invalid_type_state() -> void:
	var slot = HexMapEditorAssetSlotState.new()
	slot.configure("tile_catalog", "Tile Catalog", &"HexTileCatalogResource")
	var sample_catalog = HexTileCatalogResource.new()
	slot.set_sample_source(
		sample_catalog,
		"res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres",
		"Sample Catalog"
	)
	_assert_true(slot.apply_sample_source(), "sample source applies")
	var sample = slot.snapshot()
	_assert_eq(String(sample["current_source_badge"]), HexMapEditorAssetSlotState.SOURCE_BADGE_SAMPLE, "sample source badge is visible")
	_assert_eq(String(sample["status"]), HexMapEditorAssetSlotState.STATUS_WARNING, "bundled sample selection is warning state")
	_assert_eq(String((sample["validation"] as Dictionary)["status_kind"]), HexMapEditorAssetSlotState.STATUS_KIND_WARNING, "sample validation status is warning")
	_assert_true(String((sample["view_state"] as Dictionary)["status_tooltip"]).contains("bundled sample"), "sample warning is in tooltip")

	slot.set_selected_resource(Resource.new(), "res://project/not_catalog.tres", HexMapEditorAssetSlotState.SOURCE_PROJECT)
	var invalid = slot.validation_snapshot()
	_assert_eq(String(invalid["status"]), HexMapEditorAssetSlotState.STATUS_INVALID, "wrong resource type is invalid")
	_assert_eq(String(invalid["status_kind"]), HexMapEditorAssetSlotState.STATUS_KIND_ERROR, "wrong resource type maps to error kind")


func _finish() -> void:
	if _failures.is_empty():
		print("test_asset_slot_state.gd: all tests passed")
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
