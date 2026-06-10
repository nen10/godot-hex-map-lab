extends SceneTree

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexGrid = preload("res://addons/hex_map_kit/core/hex_grid.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapDocumentLabelPlacementResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_label_placement_resource.gd")
const HexMapDocumentObjectPlacementResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_object_placement_resource.gd")
const HexMapDocumentOverlayLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_overlay_layer_resource.gd")
const HexMapDocumentTerrainLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_terrain_layer_resource.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapDocumentApplier = preload("res://addons/hex_map_kit/adapter/hex_map_document_applier.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexTileMapResourceBinding = preload("res://addons/hex_map_kit/adapter/hex_tile_map_resource_binding.gd")
const HexObjectLayerAdapter = preload("res://addons/hex_map_kit/adapter/hex_object_layer_adapter.gd")
const HexLayerStackEntryResource = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_entry_resource.gd")
const HexLayerStackResource = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd")
const HexMovementProfileResource = preload("res://addons/hex_map_kit/adapter/hex_movement_profile_resource.gd")
const HexObjectDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_object_database_resource.gd")
const HexObjectDefinitionResource = preload("res://addons/hex_map_kit/adapter/hex_object_definition_resource.gd")
const HexTileCatalogEntry = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_entry.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")

class RuntimeSignalRecorder:
	var clicked_cells: Array = []
	var clicked_hits: Array = []
	var hovered_cells: Array = []
	var hovered_hits: Array = []

	func record_cell_clicked(hex, _event) -> void:
		clicked_cells.append(hex)

	func record_hit_clicked(hit: Dictionary, _event) -> void:
		clicked_hits.append(hit)

	func record_cell_hovered(hex) -> void:
		hovered_cells.append(hex)

	func record_hit_hovered(hit: Dictionary) -> void:
		hovered_hits.append(hit)

var _failures: Array[String] = []
var _test_output_root := ""


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await _test_apply_map_and_cell_editing()
	await _test_hex_tile_map_layer_responsibility_split_helpers()
	await _test_apply_edit_command_and_inverse_roundtrip()
	await _test_hex_map_resource_assignment_creates_visible_tiles()
	await _test_apply_document_payloads_create_visible_tile_and_markers()
	await _test_apply_canonical_document_payloads_create_visible_tile_and_markers()
	await _test_layer_stack_standard_template_roles()
	await _test_layer_stack_resource_roundtrips()
	await _test_apply_document_to_layer_stack_routes_canonical_roles()
	await _test_object_layer_adapter_applies_scene_tiles_and_direct_instances()
	await _test_ensure_display_tiles_uses_custom_floor_wall_sources()
	await _test_display_tile_size_syncs_hex_size_and_overlay()
	await _test_display_tile_set_resource_persists_through_packed_scene()
	await _test_apply_map_uses_resource_orientation()
	await _test_coordinate_roundtrips()
	await _test_path_highlight_and_connectivity_helpers()
	await _test_weighted_path_and_range_use_movement_profile()
	await _test_remove_highlight_removes_single_cell()
	await _test_runtime_input_signals_use_cell_hit()
	await _test_local_to_cell_hit_wraps_toric_visual_cell()
	await _test_infinite_loop_mode_keeps_visual_cell_identity()
	await _test_visual_representatives_for_toric_cell()
	await _test_visual_cell_entries_for_rect_marks_canonical_and_duplicates()
	await _test_loop_copy_layer_draws_duplicate_tiles()
	await _test_loop_copy_layer_updates_after_wall_floor_edit()
	await _test_visual_path_for_toric_path_uses_nearest_representatives()
	await _test_visual_path_anchor_selects_first_representative()
	await _test_connected_component_from_local_matches_core()
	await _test_apply_map_before_ready_redraws_after_ready()

	if _failures.is_empty():
		print("test_hex_tile_map_layer.gd: all tests passed")
		quit(0)
		return

	for failure in _failures:
		push_error(failure)
	quit(1)


func _test_apply_map_and_cell_editing() -> void:
	var data = HexMapData.rectangle(3, 2)
	var wall = HexVector.q_axis()
	data.set_walls([wall])

	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(data))

	_assert_eq(layer.get_cells().size(), 6, "layer exposes all applied cells")
	_assert_true(layer.has_cell(HexVector.zero()), "layer has origin cell")
	_assert_true(layer.is_floor(HexVector.zero()), "origin starts as floor")
	_assert_true(layer.is_wall(wall), "wall cell is queryable")

	layer.set_floor(wall)
	_assert_true(layer.is_floor(wall), "set_floor changes a wall to floor")
	layer.set_wall(HexVector.zero())
	_assert_true(layer.is_wall(HexVector.zero()), "set_wall changes a floor to wall")
	layer.set_wall(HexVector.apply_basis(9, 0, 9))
	_assert_eq(layer.get_floor_cells().size(), 5, "editing ignores cells outside the map")

	layer.queue_free()
	await process_frame


func _test_hex_tile_map_layer_responsibility_split_helpers() -> void:
	var data = HexMapData.rectangle(2, 1)
	var resource = HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_POINTY_TOP)
	var binding = HexTileMapResourceBinding.prepare_map_resource(resource)
	_assert_true(bool(binding["ok"]), "ARCH-50 resource binding prepares map resource")
	_assert_eq(String(binding["state_source"]), "HexTileMapResourceBinding", "ARCH-50 resource binding has service source")
	_assert_true(not bool(binding["flat_top"]), "ARCH-50 resource binding preserves pointy orientation")
	_assert_true(binding["snapshot_resource"] is HexMapResource, "ARCH-50 resource binding returns runtime snapshot resource")

	var document = HexMapDocumentAdapter.from_map_resource(resource)
	var document_apply = HexMapDocumentApplier.prepare_document_apply(document)
	_assert_true(bool(document_apply["ok"]), "ARCH-50 document applier prepares document")
	_assert_eq(String(document_apply["state_source"]), "HexMapDocumentApplier", "ARCH-50 document applier has service source")
	_assert_true(document_apply["document_snapshot"] is HexMapDocumentResource, "ARCH-50 document applier returns duplicated document snapshot")
	_assert_true(document_apply["map_resource"] is HexMapResource, "ARCH-50 document applier returns map resource")

	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(resource)
	var split = layer.responsibility_split_snapshot()
	_assert_eq(String(split["coordinator"]), "HexTileMapLayer", "ARCH-50 layer reports coordinator role")
	_assert_eq(String(split["resource_binding_source"]), "HexTileMapResourceBinding", "ARCH-50 layer reports resource binding helper")
	_assert_eq(String(split["document_applier_source"]), "HexMapDocumentApplier", "ARCH-50 layer reports document applier helper")
	_assert_true(bool(split["document_apply_separate_from_resource_binding"]), "ARCH-50 document apply is separate from resource binding")
	_assert_true((split["preserved_runtime_helpers"] as PackedStringArray).has("movement_range"), "ARCH-50 runtime helper value remains declared")
	_assert_eq(layer.hex_map.orientation, HexMapResource.ORIENTATION_POINTY_TOP, "ARCH-50 apply_map keeps resource orientation through helper")
	layer.apply_document(document)
	_assert_eq(layer.level_document_resource, document, "ARCH-50 apply_document keeps layer document binding")
	_assert_eq(layer.display_used_cell_count(), 2, "ARCH-50 apply_document still redraws display cells")

	layer.queue_free()
	await process_frame


func _test_apply_edit_command_and_inverse_roundtrip() -> void:
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(HexMapData.rectangle(1, 1)))
	var hex = HexVector.zero()
	var before = layer.cell_edit_state(hex)
	var after = before.duplicate(true)
	after["wall"] = true
	after["tile_overrides"] = [{
		"cell": Vector3i(0, 0, 0),
		"kind": HexMapDocumentAdapter.KIND_WALL,
		"source_id": 0,
		"atlas_coords": Vector2i.ZERO,
		"alternative_tile": 0,
	}]
	after["overlay_tiles"] = [{
		"cell": Vector3i(0, 0, 0),
		"kind": HexMapDocumentAdapter.KIND_OVERLAY,
		"item_key": "Treasure",
		"source_id": 0,
		"atlas_coords": Vector2i(1, 0),
		"alternative_tile": 0,
	}]
	after["objects"] = [{
		"cell": Vector3i(0, 0, 0),
		"object_id": "chest",
		"properties": {"locked": true},
	}]
	after["labels"] = [{
		"cell": Vector3i(0, 0, 0),
		"label_id": "area",
		"text": "North",
	}]
	var command = {
		"mode": HexTileMapLayer.EDIT_MODE_WALL_FLOOR,
		"hex": hex,
		"before": before,
		"after": after,
	}

	_assert_true(layer.apply_edit_command(command), "apply_edit_command applies a cell state diff")
	_assert_true(layer.is_wall(hex), "apply_edit_command updates wall state")
	_assert_eq(layer.display_atlas_coords_for_hex(hex), Vector2i.ZERO, "apply_edit_command applies wall tile override")
	var display_state = layer.display_state_for_hex(hex)
	_assert_eq(display_state["overlay_count"], 1, "apply_edit_command applies overlay tile state")
	_assert_eq(display_state["marker_count"], 2, "apply_edit_command applies object and label markers")
	var snapshot = layer.to_document_resource()
	_assert_true(HexMapDocumentAdapter.to_map_resource(snapshot).to_map_data().has_wall(hex), "to_document_resource exports command wall state")
	_assert_eq(HexMapDocumentAdapter.document_tile_entries(snapshot).size(), 2, "to_document_resource exports tile and overlay entries")
	_assert_eq(HexMapDocumentAdapter.document_object_entries(snapshot).size(), 1, "to_document_resource exports object entries")
	_assert_eq(HexMapDocumentAdapter.document_label_entries(snapshot).size(), 1, "to_document_resource exports label entries")

	_assert_true(layer.apply_edit_command(layer.inverse_edit_command(command)), "inverse_edit_command can be applied")
	_assert_true(layer.is_floor(hex), "inverse_edit_command restores floor state")
	var restored_state = layer.display_state_for_hex(hex)
	_assert_eq(restored_state["overlay_count"], 0, "inverse_edit_command removes overlay state")
	_assert_eq(restored_state["marker_count"], 0, "inverse_edit_command removes marker state")

	layer.queue_free()
	await process_frame


func _test_hex_map_resource_assignment_creates_visible_tiles() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var layer = HexTileMapLayer.new()
	layer.hex_map = HexMapResource.from_map_data(data)
	root.add_child(layer)
	await process_frame

	var tile_set = layer.display_tile_set()
	_assert_true(layer.display_tile_set_present(), "hex_map assignment creates display TileSet")
	_assert_true(tile_set.has_source(0), "hex_map assignment creates sample atlas source")
	var source = tile_set.get_source(0)
	_assert_true(source is TileSetAtlasSource, "hex_map assignment creates atlas source")
	_assert_true((source as TileSetAtlasSource).has_tile(Vector2i.ZERO), "hex_map assignment creates floor atlas tile")
	_assert_true((source as TileSetAtlasSource).has_tile(Vector2i(1, 0)), "hex_map assignment creates wall atlas tile")
	_assert_eq(layer.display_used_cell_count(), 2, "hex_map assignment redraws display cells")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i.ZERO, "hex_map assignment displays floor atlas")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.q_axis()), Vector2i(1, 0), "hex_map assignment displays wall atlas")
	_assert_eq(layer.hex_size, float(HexMapTileAdapter.SAMPLE_TILE_SIZE.x) * 0.5, "hex_map assignment syncs flat-top sample tile size")

	layer.queue_free()
	await process_frame


func _test_apply_document_payloads_create_visible_tile_and_markers() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentAdapter.from_map_resource(HexMapResource.from_map_data(data))
	HexMapDocumentAdapter.set_tile_override(document, HexVector.zero(), {
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 0,
		"atlas_coords": Vector2i(1, 0),
	})
	HexMapDocumentAdapter.set_tile_override(document, HexVector.q_axis(), {
		"kind": HexMapDocumentAdapter.KIND_WALL,
		"source_id": 0,
		"atlas_coords": Vector2i(0, 0),
	})
	HexMapDocumentAdapter.set_object(document, HexVector.zero(), {"object_id": "chest"})
	HexMapDocumentAdapter.set_label(document, HexVector.zero(), {"label_id": "area", "text": "North"})
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame

	layer.apply_document(document)
	var floor_state = layer.display_state_for_hex(HexVector.zero())
	var wall_state = layer.display_state_for_hex(HexVector.q_axis())

	_assert_eq(layer.hex_map.to_map_data().walls.size(), 1, "apply_document stores the primary map resource")
	_assert_eq(floor_state["atlas_coords"], Vector2i(1, 0), "apply_document displays floor tile override")
	_assert_eq(floor_state["object_count"], 1, "apply_document exposes object marker state")
	_assert_eq(floor_state["label_count"], 1, "apply_document exposes label marker state")
	_assert_eq(floor_state["marker_count"], 2, "apply_document exposes aggregate marker state")
	_assert_eq(wall_state["atlas_coords"], Vector2i(0, 0), "apply_document displays wall tile override")

	layer.queue_free()
	await process_frame


func _test_apply_canonical_document_payloads_create_visible_tile_and_markers() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentResource.new()

	var terrain_layer = HexMapDocumentTerrainLayerResource.new()
	terrain_layer.map = HexMapResource.from_map_data(data)
	terrain_layer.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"source_id": 0,
		"atlas_coords": Vector2i(1, 0),
	})
	terrain_layer.tile_assignments.append({
		"cell": Vector3i(1, 0, 0),
		"kind": HexMapDocumentAdapter.KIND_WALL,
		"source_id": 0,
		"atlas_coords": Vector2i(0, 0),
	})
	document.terrain_layers.append(terrain_layer)

	var overlay_layer = HexMapDocumentOverlayLayerResource.new()
	overlay_layer.item_key = "Treasure"
	overlay_layer.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"source_id": 0,
		"atlas_coords": Vector2i(1, 0),
	})
	document.overlay_layers.append(overlay_layer)

	var placement = HexMapDocumentObjectPlacementResource.new()
	placement.object_id = "chest"
	placement.cell = Vector3i.ZERO
	document.object_placements.append(placement)

	var label = HexMapDocumentLabelPlacementResource.new()
	label.label_id = "area"
	label.cell = Vector3i.ZERO
	label.text = "North"
	document.label_placements.append(label)

	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame

	layer.apply_document(document)
	var floor_state = layer.display_state_for_hex(HexVector.zero())
	var wall_state = layer.display_state_for_hex(HexVector.q_axis())

	_assert_eq(layer.hex_map.to_map_data().walls.size(), 1, "apply_document stores canonical terrain map")
	_assert_eq(floor_state["atlas_coords"], Vector2i(1, 0), "apply_document displays canonical floor tile assignment")
	_assert_eq(floor_state["overlay_count"], 1, "apply_document displays canonical overlay assignment")
	_assert_eq(floor_state["object_count"], 1, "apply_document exposes canonical object marker state")
	_assert_eq(floor_state["label_count"], 1, "apply_document exposes canonical label marker state")
	_assert_eq(wall_state["atlas_coords"], Vector2i(0, 0), "apply_document displays canonical wall tile assignment")

	layer.queue_free()
	await process_frame


func _test_layer_stack_standard_template_roles() -> void:
	var stack = HexLayerStackResource.standard_template()
	var minimal = HexLayerStackResource.minimal_runtime_template()

	_assert_eq(stack.role_names(), HexLayerStackResource.standard_role_names(), "standard layer stack exposes every role")
	_assert_eq(
		stack.layer_ids(),
		PackedStringArray(["terrain", "decoration", "object", "collision", "navigation", "overlay", "debug"]),
		"standard layer stack creates expected layer ids"
	)
	_assert_eq(
		stack.node_names(),
		PackedStringArray([
			"TerrainTileMapLayer",
			"DecorationTileMapLayer",
			"ObjectTileMapLayer",
			"CollisionTileMapLayer",
			"NavigationTileMapLayer",
			"OverlayTileMapLayer",
			"DebugOverlayLayer",
		]),
		"standard layer stack creates expected node names"
	)
	_assert_true(stack.has_role(HexLayerStackResource.ROLE_TERRAIN), "standard layer stack has terrain role")
	_assert_true(stack.has_role(HexLayerStackResource.ROLE_DECORATION), "standard layer stack has decoration role")
	_assert_true(stack.has_role(HexLayerStackResource.ROLE_OBJECT), "standard layer stack has object role")
	_assert_true(stack.has_role(HexLayerStackResource.ROLE_COLLISION), "standard layer stack has collision role")
	_assert_true(stack.has_role(HexLayerStackResource.ROLE_NAVIGATION), "standard layer stack has navigation role")
	_assert_true(stack.has_role(HexLayerStackResource.ROLE_OVERLAY), "standard layer stack has overlay role")
	_assert_true(stack.has_role(HexLayerStackResource.ROLE_DEBUG), "standard layer stack has debug role")
	_assert_eq(stack.first_layer_for_role(HexLayerStackResource.ROLE_OVERLAY).node_name, "OverlayTileMapLayer", "overlay role resolves expected layer")
	_assert_eq(stack.first_layer_for_role(HexLayerStackResource.ROLE_COLLISION).visible, false, "collision role starts hidden")
	_assert_eq(
		minimal.role_names(),
		PackedStringArray([
			HexLayerStackResource.ROLE_TERRAIN,
			HexLayerStackResource.ROLE_OVERLAY,
			HexLayerStackResource.ROLE_DEBUG,
		]),
		"minimal runtime template exposes current runtime roles"
	)
	await process_frame


func _test_layer_stack_resource_roundtrips() -> void:
	var stack = HexLayerStackResource.standard_template()
	stack.metadata = {"template": "standard"}
	var path = _test_resource_path("test_hex_layer_stack.tres")
	var error = ResourceSaver.save(stack, path)
	var loaded = load(path)

	_assert_eq(error, OK, "layer stack resource saves")
	_assert_true(loaded is HexLayerStackResource, "layer stack resource loads as typed resource")
	_assert_eq(loaded.role_names(), HexLayerStackResource.standard_role_names(), "loaded layer stack preserves roles")
	_assert_true(loaded.layers[0] is HexLayerStackEntryResource, "loaded layer stack preserves typed entries")
	_assert_eq(loaded.first_layer_for_role(HexLayerStackResource.ROLE_TERRAIN).node_name, "TerrainTileMapLayer", "loaded layer stack preserves node name")
	_assert_eq(loaded.metadata["template"], "standard", "loaded layer stack preserves metadata")
	await process_frame


func _test_apply_document_to_layer_stack_routes_canonical_roles() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var document = HexMapDocumentResource.new()

	var terrain_layer_resource = HexMapDocumentTerrainLayerResource.new()
	terrain_layer_resource.map = HexMapResource.from_map_data(data)
	terrain_layer_resource.default_floor_key = "terrain.floor"
	terrain_layer_resource.default_wall_key = "terrain.wall"
	terrain_layer_resource.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"kind": HexMapDocumentAdapter.KIND_FLOOR,
		"catalog_key": "terrain.wall",
		"source_id": 0,
		"atlas_coords": Vector2i(1, 0),
	})
	terrain_layer_resource.tile_assignments.append({
		"cell": Vector3i(1, 0, 0),
		"kind": HexMapDocumentAdapter.KIND_WALL,
		"catalog_key": "terrain.floor",
		"source_id": 0,
		"atlas_coords": Vector2i(0, 0),
	})
	document.terrain_layers.append(terrain_layer_resource)

	var overlay_layer_resource = HexMapDocumentOverlayLayerResource.new()
	overlay_layer_resource.item_key = "Treasure"
	overlay_layer_resource.tile_assignments.append({
		"cell": Vector3i.ZERO,
		"source_id": 0,
		"atlas_coords": Vector2i(1, 0),
	})
	document.overlay_layers.append(overlay_layer_resource)

	var stack = HexLayerStackResource.standard_template()
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame

	_assert_true(layer.apply_document_to_layer_stack(document, stack), "layer stack apply returns success")
	var terrain_node = layer.layer_for_stack_role(HexLayerStackResource.ROLE_TERRAIN)
	var overlay_node = layer.layer_for_stack_role(HexLayerStackResource.ROLE_OVERLAY)
	var object_node = layer.layer_for_stack_role(HexLayerStackResource.ROLE_OBJECT)
	var collision_node = layer.layer_for_stack_role(HexLayerStackResource.ROLE_COLLISION)
	var navigation_node = layer.layer_for_stack_role(HexLayerStackResource.ROLE_NAVIGATION)
	var debug_node = layer.layer_for_stack_role(HexLayerStackResource.ROLE_DEBUG)

	_assert_true(terrain_node is TileMapLayer, "layer stack creates terrain TileMapLayer")
	_assert_true(overlay_node is TileMapLayer, "layer stack creates overlay TileMapLayer")
	_assert_true(object_node is TileMapLayer, "layer stack creates object role layer")
	_assert_true(collision_node is TileMapLayer, "layer stack creates collision role layer")
	_assert_true(navigation_node is TileMapLayer, "layer stack creates navigation role layer")
	_assert_true(debug_node is TileMapLayer, "layer stack creates debug role layer")
	_assert_true(layer.display_tile_map_layer() == terrain_node, "display tile map uses terrain role in stack mode")
	_assert_eq((terrain_node as TileMapLayer).get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "terrain role receives floor tile override")
	_assert_eq((terrain_node as TileMapLayer).get_cell_atlas_coords(Vector2i(1, 0)), Vector2i(0, 0), "terrain role receives wall tile override")
	_assert_eq((overlay_node as TileMapLayer).get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "overlay role receives overlay tile")
	_assert_eq((collision_node as CanvasItem).visible, false, "collision role visibility follows template")
	_assert_eq((navigation_node as CanvasItem).visible, false, "navigation role visibility follows template")

	var plain_layer = TileMapLayer.new()
	var catalog = HexTileCatalogResource.new()
	var floor_entry = HexTileCatalogEntry.new()
	floor_entry.key = "terrain.floor"
	floor_entry.source_id = 0
	floor_entry.atlas_coords = Vector2i(0, 0)
	catalog.entries.append(floor_entry)
	var wall_entry = HexTileCatalogEntry.new()
	wall_entry.key = "terrain.wall"
	wall_entry.source_id = 0
	wall_entry.atlas_coords = Vector2i(1, 0)
	catalog.entries.append(wall_entry)
	HexMapDocumentAdapter.apply_to_tile_map_layer(document, plain_layer, {"tile_catalog": catalog})
	_assert_eq(plain_layer.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(1, 0), "plain TileMapLayer document apply resolves floor catalog override")
	_assert_eq(plain_layer.get_cell_atlas_coords(Vector2i(1, 0)), Vector2i(0, 0), "plain TileMapLayer document apply resolves wall catalog override")
	plain_layer.free()

	layer.queue_free()
	await process_frame


func _test_object_layer_adapter_applies_scene_tiles_and_direct_instances() -> void:
	var document = HexMapDocumentResource.new()
	var terrain_layer = HexMapDocumentTerrainLayerResource.new()
	terrain_layer.map = HexMapResource.from_map_data(HexMapData.rectangle(2, 1))
	document.terrain_layers.append(terrain_layer)
	var placement = HexMapDocumentObjectPlacementResource.new()
	placement.object_id = "object.crate"
	placement.cell = Vector3i.ZERO
	placement.rotation_degrees = 30.0
	placement.variant = "rare"
	placement.properties = {"loot": true}
	placement.spawn_condition = "always"
	document.object_placements.append(placement)

	var prototype_node = Node2D.new()
	prototype_node.name = "CratePrototype"
	var packed_scene = PackedScene.new()
	_assert_eq(packed_scene.pack(prototype_node), OK, "object layer direct prototype packs")
	prototype_node.free()

	var scene_source = TileSetScenesCollectionSource.new()
	var scene_tile_id = scene_source.create_scene_tile(packed_scene)
	var catalog = HexTileCatalogResource.new()
	var catalog_entry = HexTileCatalogEntry.new()
	catalog_entry.key = "object.crate"
	catalog_entry.entry_type = HexTileCatalogEntry.TYPE_SCENE
	catalog_entry.source_id = 7
	catalog_entry.atlas_coords = Vector2i(scene_tile_id, 0)
	catalog_entry.scene = packed_scene
	catalog.entries.append(catalog_entry)

	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	_assert_true(
		layer.ensure_display_tiles(HexMapTileAdapter.SAMPLE_TILE_SIZE, 2, Vector2i(0, 0), 3, Vector2i(1, 0)),
		"object layer adapter configures terrain display tiles"
	)
	layer.display_tile_map_layer().tile_set.add_source(scene_source, 7)

	_assert_true(
		layer.apply_document_to_layer_stack(document, HexLayerStackResource.standard_template(), {"tile_catalog": catalog}),
		"object layer adapter applies document to stack"
	)
	var object_node = layer.layer_for_stack_role(HexLayerStackResource.ROLE_OBJECT) as TileMapLayer
	_assert_true(object_node != null, "object layer adapter creates object role TileMapLayer")
	_assert_eq(object_node.get_cell_source_id(Vector2i.ZERO), 7, "object layer adapter places scene tile source")
	_assert_eq(object_node.get_cell_atlas_coords(Vector2i.ZERO), Vector2i(scene_tile_id, 0), "object layer adapter places scene tile id")

	var direct_count = layer.apply_object_instances(document, null, {"scene_prototypes": {"object.crate": packed_scene}})
	var instance_layer = layer.object_instance_layer()
	_assert_eq(direct_count, 1, "object layer adapter instantiates direct prototype")
	_assert_eq(instance_layer.get_child_count(), 1, "object layer adapter stores managed direct instance")
	var instance = instance_layer.get_child(0)
	_assert_eq(String(instance.get_meta("object_id")), "object.crate", "object layer direct instance records object id")
	_assert_eq(String(instance.get_meta("variant")), "rare", "object layer direct instance records variant")
	_assert_eq(instance.get_meta("properties")["loot"], true, "object layer direct instance records properties")
	_assert_eq((instance as Node2D).rotation_degrees, 30.0, "object layer direct instance applies rotation")
	_assert_eq(
		(instance as Node2D).position,
		HexMapTileAdapter.hex_to_local(HexVector.zero(), layer.hex_size, layer.flat_top),
		"object layer direct instance applies cell position"
	)

	var cleared_count = layer.apply_object_instances(document, null, {"scene_prototypes": {}})
	_assert_eq(cleared_count, 0, "object layer adapter skips missing direct prototype")
	_assert_eq(instance_layer.get_child_count(), 0, "object layer adapter clears previous direct instances before apply")

	var object_database = HexObjectDatabaseResource.new()
	var object_definition = HexObjectDefinitionResource.new()
	object_definition.id = "object.crate"
	object_definition.scene = packed_scene
	object_database.add_definition(object_definition)
	var database_count = layer.apply_object_instances(document, null, {"object_database": object_database})
	_assert_eq(database_count, 1, "object layer adapter instantiates database scene resource")
	_assert_eq(instance_layer.get_child_count(), 1, "object layer adapter stores database direct instance")

	layer.queue_free()
	await process_frame


func _test_ensure_display_tiles_uses_custom_floor_wall_sources() -> void:
	var data = HexMapData.rectangle(2, 1)
	data.set_walls([HexVector.q_axis()])
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame

	_assert_true(
		layer.ensure_display_tiles(
			HexMapTileAdapter.SAMPLE_TILE_SIZE,
			4,
			Vector2i(0, 0),
			5,
			Vector2i(1, 0)
		),
		"ensure_display_tiles creates custom display tiles"
	)
	layer.apply_map(HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_POINTY_TOP))
	var tile_set = layer.display_tile_set()
	_assert_true(tile_set.has_source(4), "ensure_display_tiles creates floor source")
	_assert_true(tile_set.has_source(5), "ensure_display_tiles creates wall source")
	_assert_eq(tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "custom display tiles follow resource orientation")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.zero()), Vector2i(0, 0), "custom display tiles use floor atlas")
	_assert_eq(layer.display_atlas_coords_for_hex(HexVector.q_axis()), Vector2i(1, 0), "custom display tiles use wall atlas")

	layer.queue_free()
	await process_frame


func _test_display_tile_size_syncs_hex_size_and_overlay() -> void:
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame

	_assert_true(layer._overlay != null, "HexTileMapLayer creates a foreground overlay child")
	_assert_eq(layer._overlay.name, HexTileMapLayer.OVERLAY_NAME, "foreground overlay has stable internal name")
	_assert_eq(layer._overlay.layer, layer, "foreground overlay delegates drawing to HexTileMapLayer")
	_assert_true(layer._overlay.z_index > layer._tile_map.z_index, "foreground overlay draws above base TileMapLayer")
	var flat_image = Image.create(160, 64, false, Image.FORMAT_RGBA8)
	flat_image.fill(Color.WHITE)
	var flat_texture = ImageTexture.create_from_image(flat_image)
	_assert_true(
		layer.configure_display_tiles_from_texture(flat_texture, 0, 0, Vector2i(80, 64), Vector2i.ZERO, Vector2i(1, 0)),
		"flat-top display tiles can be configured for size sync"
	)
	_assert_eq(layer.hex_size, 40.0, "flat-top display tile width syncs hex_size")
	layer.apply_map(HexMapResource.from_map_data(HexMapData.rectangle(2, 1)))
	var flat_target = HexVector.q_axis()
	var flat_hit = layer.local_to_cell_hit(layer._tile_map.position + layer.hex_to_display_local(flat_target))
	_assert_vector_eq(flat_hit["hex"], flat_target, "flat-top hit follows synced display hex size")
	layer.highlight_cell(flat_target, Color(1.0, 0.0, 0.0))
	_assert_true(layer._highlights.has(flat_target.key()), "highlight storage remains canonical with overlay drawing")

	layer.flat_top = false
	var pointy_image = Image.create(128, 72, false, Image.FORMAT_RGBA8)
	pointy_image.fill(Color.WHITE)
	var pointy_texture = ImageTexture.create_from_image(pointy_image)
	_assert_true(
		layer.configure_display_tiles_from_texture(pointy_texture, 0, 0, Vector2i(64, 72), Vector2i.ZERO, Vector2i(1, 0)),
		"pointy-top display tiles can be configured for size sync"
	)
	_assert_eq(layer.hex_size, 36.0, "pointy-top display tile height syncs hex_size")
	var pointy_hit = layer.local_to_cell_hit(layer._tile_map.position + layer.hex_to_display_local(flat_target))
	_assert_vector_eq(pointy_hit["hex"], flat_target, "pointy-top hit follows synced display hex size")

	layer.queue_free()
	await process_frame


func _test_display_tile_set_resource_persists_through_packed_scene() -> void:
	var layer = HexTileMapLayer.new()
	layer.name = "PackedHexLayer"
	root.add_child(layer)
	await process_frame
	_assert_true(
		layer.configure_atlas_display_tiles(
			HexMapTileAdapter.SAMPLE_TILE_ATLAS_PATH,
			3,
			HexMapTileAdapter.SAMPLE_TILE_SIZE,
			Vector2i.ZERO,
			Vector2i(1, 0)
		),
		"packed scene test configures display atlas"
	)
	_assert_true(layer.display_tile_set_resource == layer.display_tile_set(), "display TileSet is mirrored to exported resource")

	var packed_scene := PackedScene.new()
	var error := packed_scene.pack(layer)
	_assert_eq(error, OK, "HexTileMapLayer packs into PackedScene")
	var restored = packed_scene.instantiate()
	_assert_true(restored is HexTileMapLayer, "PackedScene restores HexTileMapLayer")
	root.add_child(restored)
	await process_frame
	var restored_layer := restored as HexTileMapLayer
	_assert_true(restored_layer.display_tile_set_present(), "restored layer keeps display TileSet")
	_assert_true(restored_layer.display_tile_set().has_source(3), "restored display TileSet keeps atlas source")
	_assert_eq(restored_layer.display_tile_set().tile_size, HexMapTileAdapter.SAMPLE_TILE_SIZE, "restored display TileSet keeps tile size")
	var status = restored_layer.display_layer_status()
	_assert_true(int(status["tile_set_source_count"]) >= 1, "display layer status reports restored source count")
	_assert_eq(status["tile_size"], HexMapTileAdapter.SAMPLE_TILE_SIZE, "display layer status reports restored tile size")

	layer.queue_free()
	restored_layer.queue_free()
	await process_frame


func _test_apply_map_uses_resource_orientation() -> void:
	var data = HexMapData.from_cells([
		HexVector.zero(),
		HexVector.r_axis().negated(),
	])
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame

	layer.apply_map(HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_POINTY_TOP))
	_assert_true(not layer.flat_top, "layer adopts pointy-top resource orientation")
	_assert_eq(layer.hex_size, float(HexMapTileAdapter.SAMPLE_TILE_SIZE.y) * 0.5, "pointy-top resource syncs sample tile height")
	_assert_eq(layer._tile_map.tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_HORIZONTAL, "layer configures pointy-top TileSet axis")
	_assert_true(layer._tile_map.get_used_cells().has(Vector2i(0, -1)), "layer uses pointy-top map cell")

	layer.apply_map(HexMapResource.from_map_data(data, HexMapResource.ORIENTATION_FLAT_TOP))
	_assert_true(layer.flat_top, "layer adopts flat-top resource orientation")
	_assert_eq(layer.hex_size, float(HexMapTileAdapter.SAMPLE_TILE_SIZE.x) * 0.5, "flat-top resource syncs sample tile width")
	_assert_eq(layer._tile_map.tile_set.tile_offset_axis, TileSet.TILE_OFFSET_AXIS_VERTICAL, "layer configures flat-top TileSet axis")
	_assert_true(layer._tile_map.get_used_cells().has(Vector2i(1, -1)), "layer uses flat-top map cell")

	layer.queue_free()
	await process_frame


func _test_coordinate_roundtrips() -> void:
	var layer = HexTileMapLayer.new()
	layer.hex_size = 10.0
	root.add_child(layer)
	await process_frame

	var points: Array = [
		HexVector.zero(),
		HexVector.q_axis(),
		HexVector.r_axis(),
		HexVector.s_axis(),
		HexVector.q_axis().add(HexVector.r_axis()),
		HexVector.q_axis().scaled(2).subtract(HexVector.r_axis()),
		HexVector.apply_basis(30, 0, 0),
		HexVector.apply_basis(0, -30, 0),
		HexVector.apply_basis(0, 0, 30),
	]

	for flat_top in [true, false]:
		layer.flat_top = flat_top
		layer.ensure_display_tiles(Vector2i(64, 64))
		for point in points:
			_assert_vector_eq(
				layer.local_to_hex(layer.hex_to_local(point)),
				point,
				"local_to_hex roundtrips hex_to_local flat_top=%s point=%s" % [str(flat_top), point.key()]
			)
			var display_local = layer.hex_to_display_local(point)
			var expected_display = layer._tile_map.map_to_local(HexMapTileAdapter.vector_to_map_cell(point, flat_top))
			_assert_eq(
				display_local,
				expected_display,
				"hex_to_display_local follows TileMapLayer.map_to_local flat_top=%s point=%s" % [str(flat_top), point.key()]
			)
			_assert_vector_eq(
				layer.local_to_cell_hit(layer._tile_map.position + display_local)["hex"],
				point,
				"local_to_cell_hit roundtrips display local flat_top=%s point=%s" % [str(flat_top), point.key()]
			)

	layer.queue_free()
	await process_frame


func _test_path_highlight_and_connectivity_helpers() -> void:
	var data = HexMapData.rectangle(4, 1)
	var bridge = HexVector.q_axis().scaled(2)
	data.set_walls([bridge])

	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(data))

	_assert_true(not layer.is_map_connected(), "layer reports disconnected floor cells")
	_assert_eq(
		layer.find_path(HexVector.zero(), HexVector.q_axis().scaled(3)).size(),
		0,
		"find_path returns empty when floor cells are disconnected"
	)

	layer.set_floor(bridge)
	var expected_path = [
		HexVector.zero(),
		HexVector.q_axis(),
		HexVector.q_axis().scaled(2),
		HexVector.q_axis().scaled(3),
	]
	_assert_keys_eq(
		layer.find_path(HexVector.zero(), HexVector.q_axis().scaled(3)),
		expected_path,
		"find_path follows floor cells after editing"
	)
	_assert_true(layer.is_map_connected(), "layer reports restored connectivity")
	_assert_keys_eq(
		layer.connected_component(HexVector.zero()),
		expected_path,
		"connected_component returns the floor component"
	)

	layer.highlight_cell(HexVector.q_axis(), Color(1.0, 0.0, 0.0))
	_assert_eq(layer._highlights.size(), 1, "highlight_cell stores one highlight")
	layer.clear_highlights()
	_assert_eq(layer._highlights.size(), 0, "clear_highlights clears highlights")

	layer.draw_path(expected_path, Color(0.0, 1.0, 0.0))
	_assert_eq(layer._display_path.size(), 4, "draw_path stores display path")
	layer.clear_path()
	_assert_eq(layer._display_path.size(), 0, "clear_path clears display path")

	layer.queue_free()
	await process_frame


func _test_weighted_path_and_range_use_movement_profile() -> void:
	var data = HexMapData.rectangle(3, 1)
	var wall = HexVector.q_axis()
	var goal = HexVector.q_axis().scaled(2)
	data.set_walls([wall])

	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(data))

	_assert_eq(
		layer.find_weighted_path(HexVector.zero(), goal).size(),
		0,
		"weighted layer path excludes default blocked walls"
	)
	var default_range = layer.movement_range(HexVector.zero(), 2.0)
	_assert_true(default_range.has(HexVector.zero().key()), "default movement range includes start")
	_assert_true(not default_range.has(wall.key()), "default movement range excludes wall blocker")
	_assert_true(not default_range.has(goal.key()), "default movement range excludes cells behind wall blocker")

	var wall_profile = HexMovementProfileResource.new()
	wall_profile.wall_passable = true
	wall_profile.wall_cost = 1.0
	_assert_keys_eq(
		layer.find_weighted_path(HexVector.zero(), goal, wall_profile),
		[HexVector.zero(), wall, goal],
		"weighted layer path uses profile-specific passable walls"
	)
	var passable_wall_range = layer.movement_range(HexVector.zero(), 2.0, wall_profile)
	_assert_true(passable_wall_range.has(wall.key()), "profile movement range includes passable wall")
	_assert_true(passable_wall_range.has(goal.key()), "profile movement range reaches cells behind passable wall")
	_assert_eq(float(passable_wall_range[goal.key()]["cost"]), 2.0, "profile movement range records accumulated cost")

	layer.draw_movement_range(passable_wall_range)
	var overlay_state = layer.movement_range_overlay_state()
	_assert_eq(overlay_state.size(), 3, "movement range overlay stores every reachable cell")
	_assert_eq(float(overlay_state[goal.key()]["cost"]), 2.0, "movement range overlay stores heat cost")
	_assert_true(
		(overlay_state[goal.key()]["color"] as Color) != (overlay_state[HexVector.zero().key()]["color"] as Color),
		"movement range overlay stores cost heat colors"
	)
	var overlay_entries = layer.movement_range_overlay_entries()
	_assert_eq(overlay_entries.size(), 3, "movement range overlay exposes sorted entries")
	layer.clear_movement_range_overlay()
	_assert_eq(layer.movement_range_overlay_entries().size(), 0, "clear_movement_range_overlay clears heat data")

	layer.queue_free()
	await process_frame


func _test_remove_highlight_removes_single_cell() -> void:
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(HexMapData.rectangle(2, 1)))
	layer.highlight_cell(HexVector.zero(), Color(1.0, 0.0, 0.0))
	layer.highlight_cell(HexVector.q_axis(), Color(0.0, 1.0, 0.0))

	_assert_eq(layer._highlights.size(), 2, "remove_highlight fixture starts with two highlights")
	layer.remove_highlight(HexVector.zero())
	_assert_eq(layer._highlights.size(), 1, "remove_highlight removes one highlight")
	_assert_true(not layer._highlights.has(HexVector.zero().key()), "remove_highlight removes requested cell")
	_assert_true(layer._highlights.has(HexVector.q_axis().key()), "remove_highlight preserves other cell")

	layer.queue_free()
	await process_frame


func _test_runtime_input_signals_use_cell_hit() -> void:
	var layer = HexTileMapLayer.new()
	var recorder = RuntimeSignalRecorder.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(HexMapData.rectangle(2, 1)))
	layer.cell_clicked.connect(Callable(recorder, "record_cell_clicked"))
	layer.cell_hit_clicked.connect(Callable(recorder, "record_hit_clicked"))
	layer.cell_hovered.connect(Callable(recorder, "record_cell_hovered"))
	layer.cell_hit_hovered.connect(Callable(recorder, "record_hit_hovered"))

	var target = HexVector.q_axis()
	var target_position = layer.to_global(layer._tile_map.position + layer.hex_to_display_local(target))
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = target_position
	layer._unhandled_input(press)

	var motion = InputEventMouseMotion.new()
	motion.position = target_position
	layer._unhandled_input(motion)
	layer._unhandled_input(motion)

	_assert_eq(recorder.clicked_cells.size(), 1, "runtime layer emits one clicked cell signal")
	_assert_vector_eq(recorder.clicked_cells[0], target, "clicked cell signal uses canonical hit cell")
	_assert_eq(recorder.clicked_hits.size(), 1, "runtime layer emits detailed click hit")
	_assert_vector_eq(recorder.clicked_hits[0]["visual_hex"], target, "click hit includes visual cell")
	_assert_eq(recorder.hovered_cells.size(), 1, "runtime layer emits hover once for the same hit")
	_assert_eq(recorder.hovered_hits.size(), 1, "runtime layer emits detailed hover hit")

	layer.queue_free()
	await process_frame


func _test_local_to_cell_hit_wraps_toric_visual_cell() -> void:
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(HexMapData.square(3, true)))
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	var visual = HexVector.apply_basis(3, 0, 0)
	var hit = layer.local_to_cell_hit(layer._tile_map.position + layer.hex_to_display_local(visual))

	_assert_vector_eq(hit["visual_hex"], visual, "toric hit keeps visual representative")
	_assert_vector_eq(hit["hex"], HexVector.zero(), "toric hit wraps visual representative to canonical cell")
	_assert_true(hit["exists"], "toric hit exists when canonical cell exists")

	layer.queue_free()
	await process_frame


func _test_infinite_loop_mode_keeps_visual_cell_identity() -> void:
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(HexMapData.square(3, true)))
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_INFINITE
	var visual = HexVector.apply_basis(3, 0, 0)
	var hit = layer.local_to_cell_hit(layer._tile_map.position + layer.hex_to_display_local(visual))

	_assert_vector_eq(hit["hex"], visual, "infinite hit keeps visual cell as canonical identity")
	_assert_true(not bool(hit["exists"]), "infinite hit does not collapse outside finite resource into toric cell")

	layer.queue_free()
	await process_frame


func _test_visual_representatives_for_toric_cell() -> void:
	var layer = HexTileMapLayer.new()
	layer.hex_size = 10.0
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(HexMapData.square(3, true)))
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	var visual = HexVector.apply_basis(-3, 0, 0)
	var rect = Rect2(layer.hex_to_display_local(visual) - Vector2.ONE, Vector2(2, 2))
	var reps = layer.visual_representatives_for_cell(HexVector.zero(), rect, 0)

	_assert_keys_eq(reps, [visual], "toric visual representatives include the visible period copy only")

	var far_visual = HexVector.apply_basis(9, 0, 0)
	var far_rect = Rect2(layer.hex_to_display_local(far_visual) - Vector2.ONE, Vector2(2, 2))
	var far_reps = layer.visual_representatives_for_cell(HexVector.zero(), far_rect, 0)
	_assert_keys_eq(far_reps, [far_visual], "toric visual representatives honor far-from-origin display rects")

	layer.queue_free()
	await process_frame


func _test_visual_cell_entries_for_rect_marks_canonical_and_duplicates() -> void:
	var layer = HexTileMapLayer.new()
	layer.hex_size = 10.0
	root.add_child(layer)
	await process_frame
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	layer.apply_map(HexMapResource.from_map_data(HexMapData.square(3, true)))

	var canonical_rect = Rect2(layer.hex_to_display_local(HexVector.zero()) - Vector2.ONE, Vector2(2, 2))
	var canonical_entries = layer.visual_cell_entries_for_rect(canonical_rect, 0)
	var canonical_entry = _find_visual_entry(canonical_entries, HexVector.zero(), HexVector.zero())
	_assert_true(not canonical_entry.is_empty(), "visual cell entries include canonical representative")
	_assert_true(bool(canonical_entry.get("is_canonical", false)), "canonical representative is marked")
	_assert_eq(
		canonical_entry.get("map_cell", Vector2i(999, 999)),
		HexMapTileAdapter.vector_to_map_cell(HexVector.zero(), true),
		"canonical visual entry stores map cell"
	)

	var duplicate_visual = HexVector.apply_basis(-3, 0, 0)
	var duplicate_rect = Rect2(layer.hex_to_display_local(duplicate_visual) - Vector2.ONE, Vector2(2, 2))
	var duplicate_entries = layer.visual_cell_entries_for_rect(duplicate_rect, 0)
	var duplicate_entry = _find_visual_entry(duplicate_entries, HexVector.zero(), duplicate_visual)
	_assert_true(not duplicate_entry.is_empty(), "visual cell entries include toric duplicate representative")
	_assert_true(not bool(duplicate_entry.get("is_canonical", true)), "duplicate representative is not marked canonical")
	_assert_eq(
		duplicate_entry.get("map_cell", Vector2i(999, 999)),
		HexMapTileAdapter.vector_to_map_cell(duplicate_visual, true),
		"duplicate visual entry stores visual map cell"
	)

	layer.queue_free()
	await process_frame


func _test_loop_copy_layer_draws_duplicate_tiles() -> void:
	var layer = HexTileMapLayer.new()
	layer.hex_size = 10.0
	root.add_child(layer)
	await process_frame
	var duplicate_visual = HexVector.apply_basis(-3, 0, 0)
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	layer.loop_display_rect = Rect2(layer.hex_to_display_local(duplicate_visual) - Vector2.ONE, Vector2(2, 2))
	layer.apply_map(HexMapResource.from_map_data(HexMapData.square(3, true)))
	var duplicate_map_cell = HexMapTileAdapter.vector_to_map_cell(duplicate_visual, true)

	_assert_true(layer._loop_tile_map != null, "loop copy layer is created")
	_assert_eq(
		layer._loop_tile_map.get_cell_atlas_coords(duplicate_map_cell),
		layer.floor_atlas_coords,
		"loop copy layer draws duplicate floor tile"
	)
	_assert_eq(layer._loop_tile_map.tile_set, layer._tile_map.tile_set, "loop copy layer shares base TileSet")

	layer.queue_free()
	await process_frame


func _test_loop_copy_layer_updates_after_wall_floor_edit() -> void:
	var layer = HexTileMapLayer.new()
	layer.hex_size = 10.0
	root.add_child(layer)
	await process_frame
	var duplicate_visual = HexVector.apply_basis(-3, 0, 0)
	layer.loop_display_enabled = true
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	layer.loop_display_rect = Rect2(layer.hex_to_display_local(duplicate_visual) - Vector2.ONE, Vector2(2, 2))
	layer.apply_map(HexMapResource.from_map_data(HexMapData.square(3, true)))
	var duplicate_map_cell = HexMapTileAdapter.vector_to_map_cell(duplicate_visual, true)

	layer.set_wall(HexVector.zero())
	_assert_eq(
		layer._loop_tile_map.get_cell_atlas_coords(duplicate_map_cell),
		layer.wall_atlas_coords,
		"loop copy layer updates duplicate tile after set_wall"
	)
	layer.set_floor(HexVector.zero())
	_assert_eq(
		layer._loop_tile_map.get_cell_atlas_coords(duplicate_map_cell),
		layer.floor_atlas_coords,
		"loop copy layer updates duplicate tile after set_floor"
	)

	layer.queue_free()
	await process_frame


func _test_visual_path_for_toric_path_uses_nearest_representatives() -> void:
	var layer = HexTileMapLayer.new()
	layer.hex_size = 10.0
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(HexMapData.square(3, true)))
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	var canonical_path = [
		HexVector.zero(),
		HexVector.apply_basis(2, 0, 0),
	]
	var visual_path = layer.visual_path_for_canonical_path(canonical_path)
	var wrapped_visual = HexVector.q_axis().scaled(-1)
	var canonical_distance = layer.hex_to_display_local(canonical_path[0]).distance_to(layer.hex_to_display_local(canonical_path[1]))
	var visual_distance = layer.hex_to_display_local(visual_path[0]).distance_to(layer.hex_to_display_local(visual_path[1]))

	_assert_keys_eq(visual_path, [HexVector.zero(), wrapped_visual], "toric visual path chooses adjacent representative across wrap")
	_assert_true(visual_distance < canonical_distance, "toric visual path is shorter than canonical jump")
	layer.draw_loop_path(canonical_path)
	_assert_keys_eq(layer._display_path, visual_path, "draw_loop_path stores visual representatives")

	layer.queue_free()
	await process_frame


func _test_visual_path_anchor_selects_first_representative() -> void:
	var layer = HexTileMapLayer.new()
	layer.hex_size = 10.0
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(HexMapData.square(3, true)))
	layer.loop_display_mode = HexTileMapLayer.LOOP_DISPLAY_TORIC
	var duplicate_visual = HexVector.apply_basis(3, 0, 0)
	var canonical_path = [
		HexVector.zero(),
		HexVector.q_axis(),
	]
	var visual_path = layer.visual_path_for_canonical_path(canonical_path, layer.hex_to_display_local(duplicate_visual))

	_assert_vector_eq(
		visual_path[0],
		duplicate_visual,
		"visual path anchor selects nearest first representative"
	)

	layer.queue_free()
	await process_frame


func _test_connected_component_from_local_matches_core() -> void:
	var data = HexMapData.rectangle(3, 1)
	data.set_walls([HexVector.q_axis()])
	var layer = HexTileMapLayer.new()
	root.add_child(layer)
	await process_frame
	layer.apply_map(HexMapResource.from_map_data(data))
	var target = HexVector.q_axis().scaled(2)
	var component = layer.connected_component_from_local(layer._tile_map.position + layer.hex_to_display_local(target))
	var expected = HexGrid.connected_area(target, data.floor_cells(), data.cyclic_size)

	_assert_keys_eq(component, expected, "connected_component_from_local uses canonical hit cell")
	layer.highlight_connected_component(target, Color(0.0, 0.5, 1.0))
	_assert_eq(layer._highlights.size(), expected.size(), "highlight_connected_component stores component highlights")

	layer.queue_free()
	await process_frame


func _test_apply_map_before_ready_redraws_after_ready() -> void:
	var data = HexMapData.rectangle(2, 1)
	var layer = HexTileMapLayer.new()
	layer.apply_map(HexMapResource.from_map_data(data))
	root.add_child(layer)
	await process_frame

	_assert_true(layer.has_cell(HexVector.zero()), "apply_map before ready stores map data")
	_assert_true(layer._tile_map != null, "ready creates the managed TileMapLayer child")

	layer.queue_free()
	await process_frame


func _assert_true(value: bool, message: String) -> void:
	if not value:
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


func _find_visual_entry(entries: Array, canonical, visual) -> Dictionary:
	for entry in entries:
		if entry["hex"].is_equal(canonical) and entry["visual_hex"].is_equal(visual):
			return entry
	return {}


func _keys(points: Array) -> Array:
	var result: Array = []
	for point in points:
		result.append(point.key())
	result.sort()
	return result


func _test_resource_path(filename: String) -> String:
	return "%s/%s" % [_test_output_dir(), filename]


func _test_output_dir() -> String:
	if _test_output_root == "":
		_test_output_root = "res://.godot_user/test-runs/%s/test_hex_tile_map_layer" % _safe_path_part(_test_run_id())
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_test_output_root))
	return _test_output_root


func _test_run_id() -> String:
	var run_id = OS.get_environment("HEX_MAP_TEST_RUN_ID")
	if run_id == "":
		run_id = "manual-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()]
	return run_id


func _safe_path_part(value: String) -> String:
	var result := ""
	for index in range(value.length()):
		var code = value.unicode_at(index)
		if (code >= 48 and code <= 57) \
			or (code >= 65 and code <= 90) \
			or (code >= 97 and code <= 122) \
			or code == 45 \
			or code == 46 \
			or code == 95:
			result += char(code)
		else:
			result += "_"
	return result
