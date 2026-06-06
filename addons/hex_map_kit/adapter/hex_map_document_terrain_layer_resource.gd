@tool
class_name HexMapDocumentTerrainLayerResource
extends Resource

const HexMapResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")

const ROLE_TERRAIN := "terrain"

@export var layer_id: String = "terrain"
@export var display_name: String = "Terrain"
@export var role: String = ROLE_TERRAIN
@export var map: HexMapResourceScript
@export var default_floor_key: String = ""
@export var default_wall_key: String = ""
@export var tile_assignments: Array[Dictionary] = []
@export var metadata: Dictionary = {}
