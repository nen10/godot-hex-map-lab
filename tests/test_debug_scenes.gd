extends SceneTree

const GeneratedMapDebugScene = preload("res://debug/generated_map_debug.tscn")
const GeneratedMapDebug = preload("res://debug/generated_map_debug.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexMapData = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexMapGenerator = preload("res://addons/hex_map_kit/core/hex_map_generator.gd")
const HexToricMapSplitRule = preload("res://addons/hex_map_kit/core/hex_toric_map_split_rule.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapDocumentLabelPlacementResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_label_placement_resource.gd")
const HexMapDocumentObjectPlacementResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_object_placement_resource.gd")
const HexMapDocumentOverlayLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_overlay_layer_resource.gd")
const HexMapDocumentTerrainLayerResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_terrain_layer_resource.gd")
const HexMovementProfileResource = preload("res://addons/hex_map_kit/adapter/hex_movement_profile_resource.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexLayerStackResource = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd")
const HexObjectDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_object_database_resource.gd")
const HexObjectDefinitionResource = preload("res://addons/hex_map_kit/adapter/hex_object_definition_resource.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")
const HexRuntimeQuerySample = preload("res://examples/basic_runtime/runtime_query_sample.gd")
const HexRuntimeQueryExampleScene = preload("res://examples/basic_runtime/runtime_query_example.tscn")
const HexEditorWorkflowExample = preload("res://examples/editor_workflow/editor_workflow_example.gd")
const HexEditorWorkflowExampleScene = preload("res://examples/editor_workflow/editor_workflow_example.tscn")

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

	scene.configure_for_test(
		GeneratedMapDebug.SHAPE_RECTANGLE,
		1201,
		0.45,
		HexMapGenerator.CONNECT_DENSE,
		true,
		-1,
		false,
		false,
		false,
		false,
		false,
		false,
		true
	)
	var debug_range = scene.get_current_movement_range()
	_assert_true(scene.is_movement_range_enabled(), "generated map debug exposes range toggle state")
	_assert_true(debug_range.size() > 1, "generated map debug exposes movement range data")
	_assert_true(debug_range.has(HexVector.zero().key()), "generated map debug range includes start")
	_assert_eq(float(debug_range[HexVector.zero().key()]["cost"]), 0.0, "generated map debug range records start cost")

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

	var document_path = _test_resource_path("runtime_document.tres")
	_assert_eq(
		ResourceSaver.save(_runtime_document(), document_path),
		OK,
		"debug test saves runtime canonical document fixture"
	)
	var document_layer = HexTileMapLayer.new()
	root.add_child(document_layer)
	await process_frame
	_assert_true(
		document_layer.ensure_display_tiles(
			HexMapTileAdapter.SAMPLE_TILE_SIZE,
			4,
			Vector2i(0, 0),
			5,
			Vector2i(1, 0)
		),
		"runtime canonical document layer configures display tiles"
	)
	_assert_true(document_layer.load_document_path(document_path), "runtime helper loads canonical document path")
	_assert_true(not document_layer.load_document_path(_test_resource_path("missing_runtime_document.tres")), "runtime helper rejects missing document path")
	_assert_eq(document_layer.hex_map.to_map_data().walls.size(), 1, "runtime helper applies canonical terrain map")
	var runtime_state = document_layer.display_state_for_hex(HexVector.zero())
	_assert_eq(runtime_state["atlas_coords"], Vector2i(1, 0), "runtime helper applies canonical terrain tile assignment")
	_assert_eq(runtime_state["overlay_count"], 1, "runtime helper applies canonical overlay assignment")
	_assert_eq(runtime_state["object_count"], 1, "runtime helper applies canonical object placement")
	_assert_eq(runtime_state["label_count"], 1, "runtime helper applies canonical label placement")
	document_layer.queue_free()

	var movement_profile = HexMovementProfileResource.new()
	movement_profile.profile_id = "runtime-sample"
	movement_profile.wall_passable = true
	movement_profile.wall_cost = 1.0
	var query_result = HexRuntimeQuerySample.query_document_path(
		document_path,
		HexVector.zero(),
		HexVector.q_axis(),
		1.0,
		movement_profile
	)
	_assert_true(query_result["loaded"], "runtime query sample loads canonical document path")
	_assert_eq(query_result["profile_id"], "runtime-sample", "runtime query sample reports movement profile id")
	_assert_eq(query_result["path_count"], 2, "runtime query sample returns weighted path")
	_assert_eq(query_result["range_count"], 2, "runtime query sample returns movement range")
	_assert_true(
		(query_result["range"] as Dictionary).has(HexVector.q_axis().key()),
		"runtime query sample range includes passable wall cell"
	)
	var missing_query = HexRuntimeQuerySample.query_document_path(_test_resource_path("missing_runtime_query_document.tres"))
	_assert_true(not bool(missing_query["loaded"]), "runtime query sample reports missing document path")

	var runtime_export_document = _runtime_document()
	runtime_export_document.object_placements[0].properties = {"loot": true}
	runtime_export_document.object_placements[0].rotation_degrees = 15.0
	var object_database = HexObjectDatabaseResource.new()
	var object_definition = HexObjectDefinitionResource.new()
	object_definition.id = "chest"
	object_definition.scene_path = "res://objects/chest.tscn"
	object_database.add_definition(object_definition)
	var object_export = HexRuntimeQuerySample.export_runtime_objects(runtime_export_document, object_database)
	_assert_true(object_export["loaded"], "runtime object export sample returns loaded result")
	_assert_eq(object_export["authoring_count"], 1, "runtime object export reports authoring count")
	_assert_eq(object_export["runtime_objects"][0]["object_id"], "chest", "runtime object export keeps object id")
	_assert_eq(object_export["runtime_objects"][0]["scene_path"], "res://objects/chest.tscn", "runtime object export resolves scene path")
	_assert_eq(object_export["runtime_objects"][0]["rotation_degrees"], 15.0, "runtime object export keeps rotation")
	object_export["runtime_objects"][0]["properties"]["runtime_only"] = true
	_assert_true(
		not runtime_export_document.object_placements[0].properties.has("runtime_only"),
		"runtime object export does not mutate authoring properties"
	)

	for example_path in HexEditorWorkflowExample.loadable_example_paths():
		_assert_true(ResourceLoader.exists(example_path), "PKG-01 example path exists: %s" % example_path)
		_assert_true(
			ResourceLoader.load(example_path, "", ResourceLoader.CACHE_MODE_IGNORE) != null,
			"PKG-01 example path loads: %s" % example_path
		)
	for source_path in [
		"res://examples/basic_runtime/runtime_query_sample.gd",
		"res://examples/basic_runtime/runtime_query_example.gd",
		"res://examples/editor_workflow/editor_workflow_example.gd",
	]:
		var source = FileAccess.get_file_as_string(source_path)
		_assert_true(source.find("res://addons/hex_map_kit/editor/") == -1, "PKG-01 example avoids editor preloads: %s" % source_path)

	var runtime_example = HexRuntimeQueryExampleScene.instantiate()
	root.add_child(runtime_example)
	await process_frame
	var runtime_example_result = runtime_example.run_example(document_path)
	_assert_true(runtime_example_result["loaded"], "PKG-01 runtime example scene loads saved canonical document")
	_assert_eq(runtime_example_result["profile_id"], "runtime-example", "PKG-01 runtime example scene uses runtime profile")
	_assert_eq(runtime_example_result["path_count"], 2, "PKG-01 runtime example scene returns weighted path")
	runtime_example.queue_free()

	var workflow_document = HexEditorWorkflowExample.build_authoring_document()
	var workflow_summary = HexEditorWorkflowExample.workflow_summary(workflow_document)
	_assert_eq(workflow_summary["summary"]["cells"], 6, "PKG-01 editor workflow sample reports cells")
	_assert_eq(workflow_summary["summary"]["objects"], 1, "PKG-01 editor workflow sample reports object placement")
	_assert_true(
		(workflow_summary["layer_roles"] as Array).has(HexLayerStackResource.ROLE_TERRAIN),
		"PKG-01 editor workflow sample includes terrain layer role"
	)
	_assert_true(
		(workflow_summary["dependency_paths"] as Array).has(HexEditorWorkflowExample.SAMPLE_CATALOG_PATH),
		"PKG-01 editor workflow sample records catalog dependency"
	)

	var workflow_scene = HexEditorWorkflowExampleScene.instantiate()
	root.add_child(workflow_scene)
	await process_frame
	_assert_true(workflow_scene.sample_document != null, "PKG-01 editor workflow scene builds sample document")
	workflow_scene.queue_free()

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


func _runtime_document() -> HexMapDocumentResource:
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
	return document


func _test_resource_path(filename: String) -> String:
	var directory = "res://.godot_user/test-runs/test_debug_scenes"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	return "%s/%s" % [directory, filename]


func _keys(points: Array) -> Array:
	var result: Array = []
	for point in points:
		result.append(point.key())
	result.sort()
	return result
