@tool
class_name HexMapDocumentResource
extends Resource

const HexMapResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")

@export var map: HexMapResourceScript
@export var tile_overrides: Array = []
@export var objects: Array = []
@export var labels: Array = []
@export var version: int = 1
