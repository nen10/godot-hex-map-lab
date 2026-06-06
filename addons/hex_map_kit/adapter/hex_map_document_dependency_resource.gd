@tool
class_name HexMapDocumentDependencyResource
extends Resource

const KIND_TILE_SET := "tile_set"
const KIND_TILE_CATALOG := "tile_catalog"
const KIND_OBJECT_DATABASE := "object_database"
const KIND_LABEL_DATABASE := "label_database"
const KIND_SCENE := "scene"
const KIND_SCRIPT := "script"
const KIND_OTHER := "other"

@export var dependency_id: String = ""
@export var kind: String = KIND_OTHER
@export var dependency_path: String = ""
@export var role: String = ""
@export var required: bool = true
@export var metadata: Dictionary = {}
