extends SceneTree

const HexMapDocumentDependencyService = preload("res://addons/hex_map_kit/adapter/hex_map_document_dependency_service.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexLayerStackResource = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")
const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")
const HexMapWorkspaceBindingService = preload("res://addons/hex_map_kit/editor/hex_map_workspace_binding_service.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_no_target_and_node_owned_writeback_states()
	_test_document_dependency_hydration_and_manual_override_states()
	_finish()


func _test_no_target_and_node_owned_writeback_states() -> void:
	var context = HexMapWorkspaceAssetContext.new()
	var empty_writeback = HexMapWorkspaceBindingService.selected_writeback_snapshot(null, true, context)
	var empty_state = HexMapWorkspaceBindingService.selection_binding_state(null, null, true, context, empty_writeback)
	_assert_eq(String(empty_writeback["blocked_reason"]), "No HexTileMap selected", "no target writeback records blocked reason")
	_assert_eq(String(empty_state["state_id"]), HexMapWorkspaceBindingService.STATE_NO_TARGET, "no target binding state is explicit")

	var layer = HexTileMapLayer.new()
	layer.name = "SelectedHexTileMap"
	var document = HexMapDocumentResource.new()
	var stack = HexLayerStackResource.new()
	layer.level_document_resource = document
	layer.layer_stack_resource = stack

	var sync_result = HexMapWorkspaceBindingService.sync_node_owned_context_from_layer(layer, context)
	_assert_true(bool(sync_result["ok"]), "node-owned context sync succeeds")
	_assert_eq(context.level_document, document, "node-owned sync copies level document")
	_assert_eq(context.layer_stack, stack, "node-owned sync copies layer stack")

	var writeback = HexMapWorkspaceBindingService.selected_writeback_snapshot(layer, true, context)
	var relationships = writeback["relationships"] as Dictionary
	var document_relationship = relationships[HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT] as Dictionary
	var stack_relationship = relationships[HexMapWorkspaceAssetContext.SLOT_LAYER_STACK] as Dictionary
	_assert_true(bool(writeback["can_writeback"]), "selected layer can write back")
	_assert_eq(String(document_relationship["status"]), "linked", "document relationship is linked")
	_assert_eq(String(stack_relationship["status"]), "linked", "layer stack relationship is linked")

	var state = HexMapWorkspaceBindingService.selection_binding_state(layer, layer, true, context, writeback)
	_assert_eq(String(state["state_id"]), HexMapWorkspaceBindingService.STATE_APPLIED_WRITEBACK, "linked resources derive applied writeback state")
	_assert_true((state["applied_writeback_slot_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT), "applied writeback records document slot")
	layer.free()


func _test_document_dependency_hydration_and_manual_override_states() -> void:
	var document = HexMapDocumentResource.new()
	var dependency_catalog = HexTileCatalogResource.new()
	HexMapDocumentDependencyService.set_shared_dependency(
		document,
		HexMapDocumentDependencyService.KEY_TILE_CATALOG,
		dependency_catalog
	)

	var context = HexMapWorkspaceAssetContext.new()
	context.set_level_document(document)
	var hydration = HexMapWorkspaceBindingService.hydrate_context_from_document_dependencies(context, document)
	_assert_true((hydration["applied_slot_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG), "hydration applies tile catalog dependency")
	_assert_eq(context.tile_catalog, dependency_catalog, "hydration assigns tile catalog")
	_assert_eq(context.asset_source(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG), HexMapWorkspaceAssetContext.SOURCE_DOCUMENT_DEPENDENCY, "hydration marks document dependency source")

	var layer = HexTileMapLayer.new()
	layer.level_document_resource = document
	var writeback = HexMapWorkspaceBindingService.selected_writeback_snapshot(layer, true, context)
	var state = HexMapWorkspaceBindingService.selection_binding_state(layer, layer, true, context, writeback, hydration)
	_assert_eq(String(state["state_id"]), HexMapWorkspaceBindingService.STATE_HYDRATED_DEPENDENCIES, "hydrated dependency state is primary when no writeback is applied")
	_assert_true((state["hydrated_dependency_slot_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG), "binding state records hydrated tile catalog")

	var manual_catalog = HexTileCatalogResource.new()
	context.set_tile_catalog(manual_catalog, HexMapWorkspaceAssetContext.SOURCE_PROJECT)
	hydration = HexMapWorkspaceBindingService.hydrate_context_from_document_dependencies(context, document)
	_assert_true((hydration["skipped_manual_override_slot_ids"] as PackedStringArray).has(HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG), "hydration skips manual project override")
	_assert_eq(context.tile_catalog, manual_catalog, "manual override catalog remains selected")
	writeback = HexMapWorkspaceBindingService.selected_writeback_snapshot(layer, true, context)
	state = HexMapWorkspaceBindingService.selection_binding_state(layer, layer, true, context, writeback, hydration)
	_assert_true((state["active_state_ids"] as PackedStringArray).has(HexMapWorkspaceBindingService.STATE_MANUAL_OVERRIDE), "binding state records manual override")
	_assert_true((state["active_state_ids"] as PackedStringArray).has(HexMapWorkspaceBindingService.STATE_CONFLICT), "binding state records dependency conflict")
	layer.free()


func _finish() -> void:
	if _failures.is_empty():
		print("test_workspace_state_transitions.gd: all tests passed")
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
