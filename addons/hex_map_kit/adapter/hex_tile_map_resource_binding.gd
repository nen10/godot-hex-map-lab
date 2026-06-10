@tool
class_name HexTileMapResourceBinding
extends RefCounted

const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")


static func prepare_map_resource(resource: HexMapResource) -> Dictionary:
	if resource == null:
		return {
			"ok": false,
			"error": ERR_INVALID_PARAMETER,
			"state_source": "HexTileMapResourceBinding",
			"resource": null,
			"map_data": null,
			"snapshot_resource": null,
		}
	var data = resource.to_map_data()
	return {
		"ok": true,
		"error": OK,
		"state_source": "HexTileMapResourceBinding",
		"resource": resource,
		"orientation": resource.orientation,
		"flat_top": resource.is_flat_top(),
		"map_data": data,
		"snapshot_resource": HexMapResource.from_map_data(data, resource.orientation),
	}
