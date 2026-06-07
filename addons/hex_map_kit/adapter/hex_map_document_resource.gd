@tool
class_name HexMapDocumentResource
extends Resource

const HexMapDocumentMetadataResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_metadata_resource.gd")

@export var terrain_layers: Array[Resource] = []
@export var overlay_layers: Array[Resource] = []
@export var object_placements: Array[Resource] = []
@export var label_placements: Array[Resource] = []
@export var zones: Array[Resource] = []
@export var metadata: HexMapDocumentMetadataResourceScript
@export var dependencies: Array[Resource] = []


func _init() -> void:
	if metadata == null:
		metadata = HexMapDocumentMetadataResourceScript.new()
