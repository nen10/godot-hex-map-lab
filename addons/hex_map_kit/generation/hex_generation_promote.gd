@tool
class_name HexGenerationPromote
extends RefCounted

const HexMapDataScript = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexOverlayDataScript = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexMapDocumentResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapDocumentTerrainLayerResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_terrain_layer_resource.gd")
const HexMapDocumentOverlayLayerResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_overlay_layer_resource.gd")
const HexMapDocumentObjectPlacementResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_object_placement_resource.gd")
const HexMapResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexOverlayResourceScript = preload("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd")

const ROLE_TERRAIN := "terrain"
const ROLE_OVERLAY := "overlay"
const ROLE_OBJECT := "object"
const WRITABLE_SOURCE_GENERATED := "generated"
const METADATA_SOURCE := "generation_graph"


static func promote(output, document, role: String, options: Dictionary = {}) -> Dictionary:
	if not (document is HexMapDocumentResourceScript):
		return _result(false, role, 0, "Missing Level Document.")
	var target_role := _normalize_role(role)
	match target_role:
		ROLE_TERRAIN:
			if not (output is HexMapDataScript):
				return _result(false, target_role, 0, "Terrain promote requires HexMapData output.")
			return _promote_terrain(output, document, options)
		ROLE_OVERLAY:
			if not (output is HexOverlayDataScript):
				return _result(false, target_role, 0, "Overlay promote requires HexOverlayData output.")
			return _promote_overlay(output, document, options)
		ROLE_OBJECT:
			if not (output is HexOverlayDataScript):
				return _result(false, target_role, 0, "Object promote requires HexOverlayData output.")
			return _promote_objects(output, document, options)
	return _result(false, target_role, 0, "Unknown promote role '%s'." % role)


static func generated_layer_count(document, role: String) -> int:
	var target_role := _normalize_role(role)
	var count := 0
	if document == null:
		return count
	for layer in document.terrain_layers:
		if _is_generated_resource(layer, target_role):
			count += 1
	for layer in document.overlay_layers:
		if _is_generated_resource(layer, target_role):
			count += 1
	for placement in document.object_placements:
		if _is_generated_resource(placement, target_role):
			count += 1
	return count


static func clear_generated(document, role: String) -> void:
	if not (document is HexMapDocumentResourceScript):
		return
	var target_role := _normalize_role(role)
	match target_role:
		ROLE_TERRAIN:
			_remove_generated_resources(document.terrain_layers, ROLE_TERRAIN)
		ROLE_OVERLAY:
			_remove_generated_resources(document.overlay_layers, ROLE_OVERLAY)
		ROLE_OBJECT:
			_remove_generated_resources(document.object_placements, ROLE_OBJECT)


static func _promote_terrain(data: HexMapDataScript, document: HexMapDocumentResourceScript, options: Dictionary) -> Dictionary:
	_remove_generated_resources(document.terrain_layers, ROLE_TERRAIN)
	var layer := HexMapDocumentTerrainLayerResourceScript.new()
	layer.layer_id = String(options.get("layer_id", "generated_terrain"))
	layer.display_name = String(options.get("display_name", "Generated Terrain"))
	layer.role = ROLE_TERRAIN
	layer.map = HexMapResourceScript.from_map_data(data, int(options.get("orientation", HexMapResourceScript.ORIENTATION_FLAT_TOP)))
	layer.metadata = _metadata(ROLE_TERRAIN, options)
	document.terrain_layers.append(layer)
	return _result(true, ROLE_TERRAIN, data.cells.size(), "")


static func _promote_overlay(data: HexOverlayDataScript, document: HexMapDocumentResourceScript, options: Dictionary) -> Dictionary:
	var layer_id := String(options.get("layer_id", "generated_overlay"))
	if not bool(options.get("preserve_existing_generated", false)):
		_remove_generated_resources(document.overlay_layers, ROLE_OVERLAY)
	else:
		_remove_generated_resource_by_layer_id(document.overlay_layers, ROLE_OVERLAY, layer_id)
	var layer := HexMapDocumentOverlayLayerResourceScript.new()
	layer.layer_id = layer_id
	layer.display_name = String(options.get("display_name", "Generated Overlay"))
	layer.role = ROLE_OVERLAY
	layer.item_key = ""
	layer.overlay = HexOverlayResourceScript.from_overlay_data(data, int(options.get("orientation", HexMapResourceScript.ORIENTATION_FLAT_TOP)))
	if bool(options.get("write_tile_assignments", true)):
		layer.tile_assignments = _overlay_tile_assignments(data, options)
	layer.metadata = _metadata(ROLE_OVERLAY, options)
	document.overlay_layers.append(layer)
	return _result(true, ROLE_OVERLAY, _overlay_item_count(data), "")


static func _promote_objects(data: HexOverlayDataScript, document: HexMapDocumentResourceScript, options: Dictionary) -> Dictionary:
	_remove_generated_resources(document.object_placements, ROLE_OBJECT)
	var count := 0
	for item_key in data.item_keys():
		for cell in data.item_cells(String(item_key)):
			var placement := HexMapDocumentObjectPlacementResourceScript.new()
			placement.placement_id = "generated_%s_%d" % [_safe_id(String(item_key)), count]
			placement.object_id = String(item_key)
			placement.cell = _component_from_hex(cell)
			placement.layer_id = String(options.get("layer_id", "generated_objects"))
			placement.metadata = _metadata(ROLE_OBJECT, options)
			document.object_placements.append(placement)
			count += 1
	return _result(true, ROLE_OBJECT, count, "")


static func _overlay_tile_assignments(data: HexOverlayDataScript, options: Dictionary = {}) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item_key in data.item_keys():
		for cell in data.item_cells(String(item_key)):
			result.append({
				"cell": _component_from_hex(cell),
				"kind": "overlay",
				"item_key": String(item_key),
				"catalog_key": String(item_key),
				"source_id": -1,
				"atlas_coords": Vector2i.ZERO,
				"alternative_tile": 0,
				"metadata": _metadata(ROLE_OVERLAY, options),
			})
	return result


static func _remove_generated_resources(resources: Array, role: String) -> void:
	for index in range(resources.size() - 1, -1, -1):
		if _is_generated_resource(resources[index], role):
			resources.remove_at(index)


static func _remove_generated_resource_by_layer_id(resources: Array, role: String, layer_id: String) -> void:
	if layer_id == "":
		return
	for index in range(resources.size() - 1, -1, -1):
		var resource = resources[index]
		if not _is_generated_resource(resource, role):
			continue
		if resource is Resource and String((resource as Resource).get("layer_id")) == layer_id:
			resources.remove_at(index)


static func _is_generated_resource(resource, role: String) -> bool:
	if not resource is Resource:
		return false
	var metadata = resource.get("metadata") if resource.get("metadata") != null else {}
	if not metadata is Dictionary:
		return false
	return String((metadata as Dictionary).get("writable_source", "")) == WRITABLE_SOURCE_GENERATED \
		and String((metadata as Dictionary).get("source", "")) == METADATA_SOURCE \
		and String((metadata as Dictionary).get("target_role", "")) == _normalize_role(role)


static func _metadata(role: String, options: Dictionary) -> Dictionary:
	var result := {
		"source": METADATA_SOURCE,
		"target_role": _normalize_role(role),
		"writable_source": WRITABLE_SOURCE_GENERATED,
		"graph_node_id": String(options.get("graph_node_id", "")),
	}
	for key in ["overlay_index", "result_port", "result_overlay_count", "result_row_kind", "write_policy"]:
		if options.has(key):
			result[key] = options[key]
	return result


static func _component_from_hex(hex) -> Vector3i:
	return Vector3i(int(hex.q), int(hex.s), int(hex.r))


static func _normalize_role(role: String) -> String:
	var normalized := role.strip_edges().to_lower()
	if normalized == "objects":
		return ROLE_OBJECT
	if normalized == ROLE_TERRAIN or normalized == ROLE_OVERLAY or normalized == ROLE_OBJECT:
		return normalized
	return normalized


static func _overlay_item_count(data: HexOverlayDataScript) -> int:
	var count := 0
	for item_key in data.item_keys():
		count += data.item_cells(String(item_key)).size()
	return count


static func _safe_id(value: String) -> String:
	var result := ""
	for index in range(value.length()):
		var code = value.unicode_at(index)
		if (code >= 48 and code <= 57) \
			or (code >= 65 and code <= 90) \
			or (code >= 97 and code <= 122):
			result += char(code).to_lower()
		else:
			result += "_"
	return "item" if result == "" else result


static func _result(ok: bool, role: String, cell_count: int, blocked_reason: String) -> Dictionary:
	return {
		"ok": ok,
		"written_role": _normalize_role(role),
		"writable_source": WRITABLE_SOURCE_GENERATED,
		"cell_count": cell_count,
		"blocked_reason": blocked_reason,
		"status_text": "%s layer promoted: %d cells" % [_normalize_role(role), cell_count] if ok else blocked_reason,
	}
