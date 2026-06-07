class_name HexObjectLayerAdapter
extends RefCounted

const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")

const MANAGED_INSTANCE_META := "hex_object_layer_instance"


static func apply_scene_tile_prototypes(tile_map: TileMapLayer, document_or_entries: Variant, options: Dictionary = {}) -> int:
	if tile_map == null:
		return 0
	tile_map.clear()
	var placements = placement_entries(document_or_entries)
	var catalog = options.get("tile_catalog", options.get("catalog", null))
	var flat_top = bool(options.get("flat_top", true))
	var count := 0
	for placement in placements:
		var config = scene_tile_config(placement, catalog)
		if int(config.get("source_id", -1)) < 0:
			continue
		var hex = _hex_from_cell(placement.get("cell", Vector3i.ZERO))
		var map_cell = HexMapTileAdapter.vector_to_map_cell(hex, flat_top)
		tile_map.set_cell(
			map_cell,
			int(config.get("source_id", -1)),
			config.get("atlas_coords", Vector2i.ZERO),
			int(config.get("alternative_tile", 0))
		)
		count += 1
	return count


static func apply_direct_instance_prototypes(parent: Node, document_or_entries: Variant, options: Dictionary = {}) -> int:
	if parent == null:
		return 0
	clear_managed_instances(parent)
	var placements = placement_entries(document_or_entries)
	var object_database = options.get("object_database", null)
	var prototypes: Dictionary = options.get("scene_prototypes", {})
	var flat_top = bool(options.get("flat_top", true))
	var hex_size = float(options.get("hex_size", 24.0))
	var count := 0
	for placement in placements:
		var packed_scene = direct_instance_prototype(placement, object_database, prototypes)
		if packed_scene == null:
			continue
		var instance = packed_scene.instantiate()
		if instance == null:
			continue
		_configure_instance(instance, placement, hex_size, flat_top)
		parent.add_child(instance)
		count += 1
	return count


static func placement_entries(document_or_entries: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if document_or_entries is Array:
		for raw_entry in document_or_entries:
			if raw_entry is Dictionary:
				result.append((raw_entry as Dictionary).duplicate(true))
		return result
	if document_or_entries != null:
		return HexMapDocumentAdapter.document_object_entries(document_or_entries)
	return result


static func scene_tile_config(placement: Dictionary, catalog = null) -> Dictionary:
	if placement.has("source_id"):
		return {
			"source_id": int(placement.get("source_id", -1)),
			"atlas_coords": placement.get("atlas_coords", Vector2i.ZERO),
			"alternative_tile": int(placement.get("alternative_tile", 0)),
		}
	var catalog_key = String(placement.get("catalog_key", ""))
	if catalog_key == "":
		catalog_key = String(placement.get("object_id", ""))
	if catalog != null and catalog.has_method("entry_for_key") and catalog_key != "":
		return HexMapTileAdapter.tile_config_from_catalog(catalog, catalog_key)
	return {"source_id": -1}


static func direct_instance_prototype(placement: Dictionary, object_database = null, prototypes: Dictionary = {}):
	var object_id = String(placement.get("object_id", ""))
	if object_id != "" and prototypes.has(object_id) and prototypes[object_id] is PackedScene:
		return prototypes[object_id]
	var scene_path = String(placement.get("scene_path", ""))
	if scene_path == "" and object_database != null and object_database.has_method("definition_for_id"):
		var definition = object_database.definition_for_id(object_id)
		if definition != null:
			scene_path = String(definition.get("scene_path"))
	if scene_path != "" and ResourceLoader.exists(scene_path):
		var resource = ResourceLoader.load(scene_path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if resource is PackedScene:
			return resource
	return null


static func clear_managed_instances(parent: Node) -> void:
	if parent == null:
		return
	for child in parent.get_children():
		if child is Object and child.has_meta(MANAGED_INSTANCE_META):
			parent.remove_child(child)
			child.free()


static func _configure_instance(instance: Node, placement: Dictionary, hex_size: float, flat_top: bool) -> void:
	instance.set_meta(MANAGED_INSTANCE_META, true)
	instance.set_meta("object_id", String(placement.get("object_id", "")))
	instance.set_meta("cell", placement.get("cell", Vector3i.ZERO))
	instance.set_meta("variant", String(placement.get("variant", "")))
	instance.set_meta("properties", placement.get("properties", {}).duplicate(true) if placement.get("properties", {}) is Dictionary else {})
	instance.set_meta("spawn_condition", String(placement.get("spawn_condition", "")))
	instance.name = _instance_name(placement)
	if instance is Node2D:
		var node_2d = instance as Node2D
		node_2d.position = HexMapTileAdapter.hex_to_local(_hex_from_cell(placement.get("cell", Vector3i.ZERO)), hex_size, flat_top)
		node_2d.rotation_degrees = float(placement.get("rotation_degrees", placement.get("rotation", 0.0)))


static func _hex_from_cell(cell_value: Variant):
	if cell_value is Vector3i:
		return HexVector.apply_basis(cell_value.x, cell_value.y, cell_value.z)
	if cell_value is Vector3:
		return HexVector.apply_basis(int(cell_value.x), int(cell_value.y), int(cell_value.z))
	return HexVector.zero()


static func _instance_name(placement: Dictionary) -> String:
	var object_id = String(placement.get("object_id", "object"))
	if object_id == "":
		object_id = "object"
	return "Object_%s_%s" % [_safe_name(object_id), _safe_name(_hex_from_cell(placement.get("cell", Vector3i.ZERO)).key())]


static func _safe_name(value: String) -> String:
	var result := ""
	for index in range(value.length()):
		var code = value.unicode_at(index)
		if (code >= 48 and code <= 57) \
				or (code >= 65 and code <= 90) \
				or (code >= 97 and code <= 122):
			result += value[index]
		else:
			result += "_"
	return result
