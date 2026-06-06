@tool
class_name HexMapDocumentResource
extends Resource

const HexMapResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexMapDocumentMetadataResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_metadata_resource.gd")

const VERSION_V1 := 1
const VERSION_V2 := 2

@export var map: HexMapResourceScript
@export var tile_overrides: Array = []
@export var objects: Array = []
@export var labels: Array = []
@export var version: int = VERSION_V1

@export var terrain_layers: Array[Resource] = []
@export var overlay_layers: Array[Resource] = []
@export var object_placements: Array[Resource] = []
@export var label_placements: Array[Resource] = []
@export var zones: Array[Resource] = []
@export var metadata: HexMapDocumentMetadataResourceScript
@export var dependencies: Array[Resource] = []


func ensure_v2_defaults() -> void:
	version = VERSION_V2
	if metadata == null:
		metadata = HexMapDocumentMetadataResourceScript.new()


func is_v2() -> bool:
	return version >= VERSION_V2


func v2_schema_fields() -> PackedStringArray:
	return PackedStringArray([
		"terrain_layers",
		"overlay_layers",
		"object_placements",
		"label_placements",
		"zones",
		"metadata",
		"dependencies",
	])
