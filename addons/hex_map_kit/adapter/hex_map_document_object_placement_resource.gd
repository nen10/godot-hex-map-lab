@tool
class_name HexMapDocumentObjectPlacementResource
extends Resource

@export var placement_id: String = ""
@export var object_id: String = ""
@export var cell: Vector3i = Vector3i.ZERO
@export var rotation_degrees: float = 0.0
@export var variant: String = ""
@export var properties: Dictionary = {}
@export var spawn_condition: String = ""
@export var layer_id: String = "objects"
@export var runtime_enabled: bool = true
@export var metadata: Dictionary = {}
