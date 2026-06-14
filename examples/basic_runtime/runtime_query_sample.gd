class_name HexRuntimeQuerySample
extends RefCounted

const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexGameplayQueryService = preload("res://addons/hex_map_kit/adapter/hex_gameplay_query_service.gd")
const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")


static func query_document(
	document: HexMapDocumentResource,
	start = null,
	goal = null,
	movement_budget: float = 4.0,
	movement_profile = null,
	tile_catalog = null
) -> Dictionary:
	var service = HexGameplayQueryService.from_document(document, movement_profile, tile_catalog)
	if service.map_data == null:
		return _error_result("Document map is missing.")

	var gameplay = service.gameplay_layer_data(movement_profile)
	var passable_cells = gameplay.passable_cells()
	var start_hex = _hex_or_default(start, HexVector.zero())
	if not gameplay.is_passable(start_hex):
		if not passable_cells.is_empty():
			start_hex = passable_cells[0]
	var goal_hex = _hex_or_default(goal, _farthest_from(start_hex, passable_cells))
	var path = service.find_weighted_path(start_hex, goal_hex, movement_profile)
	var range_result = service.movement_range(start_hex, movement_budget, movement_profile)
	return {
		"loaded": true,
		"error": "",
		"profile_id": _profile_id(movement_profile),
		"start": start_hex,
		"goal": goal_hex,
		"path": path,
		"path_count": path.size(),
		"range": range_result,
		"range_count": range_result.size(),
	}


static func query_document_path(
	document_path: String,
	start = null,
	goal = null,
	movement_budget: float = 4.0,
	movement_profile = null,
	tile_catalog = null
) -> Dictionary:
	if document_path == "" or not ResourceLoader.exists(document_path):
		return _error_result("Document path does not exist: %s" % document_path)
	var resource = ResourceLoader.load(document_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if not resource is HexMapDocumentResource:
		return _error_result("Resource is not a HexMapDocumentResource: %s" % document_path)
	return query_document(resource, start, goal, movement_budget, movement_profile, tile_catalog)


static func export_runtime_objects(document: HexMapDocumentResource, object_database = null) -> Dictionary:
	if document == null:
		return _error_result("Document is missing.")
	var authoring_entries = HexMapDocumentAdapter.document_object_entries(document)
	var runtime_objects: Array[Dictionary] = []
	for entry in authoring_entries:
		runtime_objects.append(_runtime_object_entry(entry, object_database))
	return {
		"loaded": true,
		"error": "",
		"authoring_count": authoring_entries.size(),
		"runtime_objects": runtime_objects,
	}


static func _error_result(message: String) -> Dictionary:
	return {
		"loaded": false,
		"error": message,
		"profile_id": "",
		"start": HexVector.zero(),
		"goal": HexVector.zero(),
		"path": [],
		"path_count": 0,
		"range": {},
		"range_count": 0,
	}


static func _runtime_object_entry(entry: Dictionary, object_database = null) -> Dictionary:
	var object_id = String(entry.get("object_id", ""))
	return {
		"object_id": object_id,
		"cell": entry.get("cell", Vector3i.ZERO),
		"rotation_degrees": float(entry.get("rotation_degrees", entry.get("rotation", 0.0))),
		"variant": String(entry.get("variant", "")),
		"properties": entry.get("properties", {}).duplicate(true) if entry.get("properties", {}) is Dictionary else {},
		"spawn_condition": String(entry.get("spawn_condition", "")),
		"scene": _object_scene(entry, object_database, object_id),
	}


static func _object_scene(entry: Dictionary, object_database, object_id: String):
	var scene = entry.get("scene", null)
	if scene is PackedScene:
		return scene
	if object_database != null and object_database.has_method("definition_for_id"):
		var definition = object_database.definition_for_id(object_id)
		if definition != null:
			var definition_scene = definition.get("scene")
			if definition_scene is PackedScene:
				return definition_scene
	return null


static func _hex_or_default(value, fallback):
	if value is Vector3i:
		return HexVector.apply_basis(value.x, value.y, value.z)
	if value is HexVector:
		return HexVector.apply_basis(value.q, value.s, value.r)
	if fallback == null:
		return HexVector.zero()
	return fallback


static func _farthest_from(start, cells: Array):
	if cells.is_empty():
		return start
	var result = cells[0]
	var result_distance := -1
	var result_key := ""
	for cell in cells:
		var distance = cell.subtract(start).l1_norm()
		var key = cell.key()
		if distance > result_distance or (distance == result_distance and key > result_key):
			result = cell
			result_distance = distance
			result_key = key
	return result


static func _profile_id(profile) -> String:
	if profile == null:
		return "default"
	var value = profile.get("profile_id")
	if value == null:
		return "default"
	return String(value)
