@tool
class_name HexMapDocumentZoneResource
extends Resource

@export var zone_id: String = ""
@export var display_name: String = ""
@export var cells: Array[Vector3i] = []
@export var tags: PackedStringArray = PackedStringArray()
@export var properties: Dictionary = {}
@export var metadata: Dictionary = {}
