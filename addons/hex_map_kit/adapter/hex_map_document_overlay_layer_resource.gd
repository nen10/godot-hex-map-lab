@tool
class_name HexMapDocumentOverlayLayerResource
extends Resource

const HexOverlayResourceScript = preload("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd")

const ROLE_OVERLAY := "overlay"

@export var layer_id: String = "overlay"
@export var display_name: String = "Overlay"
@export var role: String = ROLE_OVERLAY
@export var item_key: String = ""
@export var catalog_key: String = ""
@export var overlay: HexOverlayResourceScript
@export var tile_assignments: Array[Dictionary] = []
@export var z_index: int = 0
@export var visible: bool = true
@export var metadata: Dictionary = {}
