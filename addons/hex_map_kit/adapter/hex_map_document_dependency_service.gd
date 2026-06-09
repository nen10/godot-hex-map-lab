class_name HexMapDocumentDependencyService
extends RefCounted

const HexMapDocumentDependencyResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_dependency_resource.gd")
const HexMapDocumentValidatorScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_validator.gd")

const KEY_TILE_CATALOG := "tile_catalog"
const KEY_OBJECT_DATABASE := "object_database"
const KEY_LABEL_DATABASE := "label_database"
const KEY_MOVEMENT_PROFILE := "movement_profile"
const KEY_VALIDATION_RULE_SUITE := "validation_rule_suite"
const KEY_GENERATION_PROFILE := "generation_profile"
const KEY_EXPORT_PROFILE := "export_profile"

const SOURCE_BADGE_DOCUMENT_DEPENDENCY := "Document Dependency"


static func shared_dependency_keys() -> PackedStringArray:
	return PackedStringArray([
		KEY_TILE_CATALOG,
		KEY_OBJECT_DATABASE,
		KEY_LABEL_DATABASE,
		KEY_MOVEMENT_PROFILE,
		KEY_VALIDATION_RULE_SUITE,
		KEY_GENERATION_PROFILE,
		KEY_EXPORT_PROFILE,
	])


static func dependency_id_for(kind: String, role: String = "") -> String:
	if role == "":
		return kind
	return "%s:%s" % [kind, role]


static func shared_dependency_kind(key: String) -> String:
	match key:
		KEY_TILE_CATALOG:
			return HexMapDocumentDependencyResourceScript.KIND_TILE_CATALOG
		KEY_OBJECT_DATABASE:
			return HexMapDocumentDependencyResourceScript.KIND_OBJECT_DATABASE
		KEY_LABEL_DATABASE:
			return HexMapDocumentDependencyResourceScript.KIND_LABEL_DATABASE
		KEY_MOVEMENT_PROFILE:
			return HexMapDocumentDependencyResourceScript.KIND_MOVEMENT_PROFILE
		KEY_VALIDATION_RULE_SUITE:
			return HexMapDocumentDependencyResourceScript.KIND_VALIDATION_RULE_SUITE
		KEY_GENERATION_PROFILE:
			return HexMapDocumentDependencyResourceScript.KIND_GENERATION_PROFILE
		KEY_EXPORT_PROFILE:
			return HexMapDocumentDependencyResourceScript.KIND_EXPORT_PROFILE
	return ""


static func shared_dependency_role(_key: String) -> String:
	return ""


static func find_shared_dependency(document, key: String):
	return find_dependency(document, shared_dependency_kind(key), shared_dependency_role(key))


static func set_shared_dependency(
	document,
	key: String,
	resource: Resource,
	required: Variant = null,
	metadata: Dictionary = {}
):
	var actual_required := bool(required) if required != null else shared_dependency_required_default(key)
	return set_dependency(
		document,
		shared_dependency_kind(key),
		resource,
		shared_dependency_role(key),
		actual_required,
		metadata
	)


static func remove_shared_dependency(document, key: String) -> bool:
	return remove_dependency(document, shared_dependency_kind(key), shared_dependency_role(key))


static func find_dependency(document, kind: String, role: String = ""):
	if document == null or kind == "":
		return null
	for dependency in document.dependencies:
		if not dependency is Resource:
			continue
		if String(dependency.get("kind")) != kind:
			continue
		if String(dependency.get("role")) != role:
			continue
		return dependency
	return null


static func set_dependency(
	document,
	kind: String,
	resource: Resource,
	role: String = "",
	required: bool = true,
	metadata: Dictionary = {}
):
	if document == null or kind == "":
		return null
	var dependency = find_dependency(document, kind, role)
	if dependency == null:
		dependency = HexMapDocumentDependencyResourceScript.new()
		document.dependencies.append(dependency)
	dependency.set("dependency_id", dependency_id_for(kind, role))
	dependency.set("kind", kind)
	dependency.set("role", role)
	dependency.set("resource", resource)
	dependency.set("required", required)
	dependency.set("metadata", _dependency_metadata(metadata))
	return dependency


static func remove_dependency(document, kind: String, role: String = "") -> bool:
	if document == null or kind == "":
		return false
	var removed := false
	for index in range(document.dependencies.size() - 1, -1, -1):
		var dependency = document.dependencies[index]
		if not dependency is Resource:
			continue
		if String(dependency.get("kind")) != kind:
			continue
		if String(dependency.get("role")) != role:
			continue
		document.dependencies.remove_at(index)
		removed = true
	return removed


static func hydrate_dependency_map(document) -> Dictionary:
	var result := {}
	for key in shared_dependency_keys():
		var dependency = find_shared_dependency(document, key)
		result[key] = dependency_snapshot(dependency, key)
	return result


static func dependency_snapshot(dependency, key: String = "") -> Dictionary:
	var resource = dependency.get("resource") if dependency is Resource else null
	var kind = String(dependency.get("kind")) if dependency is Resource else shared_dependency_kind(key)
	var role = String(dependency.get("role")) if dependency is Resource else shared_dependency_role(key)
	var metadata = dependency.get("metadata") if dependency is Resource else {}
	if not metadata is Dictionary:
		metadata = {}
	var source_badge := String((metadata as Dictionary).get("source_badge", SOURCE_BADGE_DOCUMENT_DEPENDENCY))
	return {
		"key": key,
		"dependency": dependency,
		"dependency_id": String(dependency.get("dependency_id")) if dependency is Resource else dependency_id_for(kind, role),
		"kind": kind,
		"role": role,
		"required": bool(dependency.get("required")) if dependency is Resource else shared_dependency_required_default(key),
		"resource": resource,
		"resource_path": resource.resource_path if resource is Resource else "",
		"selected": resource is Resource,
		"source_badge": source_badge,
		"metadata": (metadata as Dictionary).duplicate(true),
	}


static func shared_dependency_required_default(key: String) -> bool:
	match key:
		KEY_VALIDATION_RULE_SUITE, KEY_GENERATION_PROFILE, KEY_EXPORT_PROFILE:
			return false
	return true


static func validate_dependencies(document):
	return HexMapDocumentValidatorScript.validate_document(document)


static func _dependency_metadata(metadata: Dictionary) -> Dictionary:
	var result := metadata.duplicate(true)
	if not result.has("source_badge"):
		result["source_badge"] = SOURCE_BADGE_DOCUMENT_DEPENDENCY
	return result
