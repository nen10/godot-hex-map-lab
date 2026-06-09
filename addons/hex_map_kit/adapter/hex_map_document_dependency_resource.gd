@tool
class_name HexMapDocumentDependencyResource
extends Resource

const KIND_TILE_SET := "tile_set"
const KIND_TILE_CATALOG := "tile_catalog"
const KIND_OBJECT_DATABASE := "object_database"
const KIND_LABEL_DATABASE := "label_database"
const KIND_MOVEMENT_PROFILE := "movement_profile"
const KIND_VALIDATION_RULE_SUITE := "validation_rule_suite"
const KIND_GENERATION_PROFILE := "generation_profile"
const KIND_EXPORT_PROFILE := "export_profile"
const KIND_SCENE := "scene"
const KIND_SCRIPT := "script"
const KIND_OTHER := "other"

@export var dependency_id: String = ""
@export var kind: String = KIND_OTHER
@export var resource: Resource
@export var role: String = ""
@export var required: bool = true
@export var metadata: Dictionary = {}


func resource_debug_path() -> String:
	return resource.resource_path if resource != null else ""
