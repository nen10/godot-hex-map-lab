@tool
class_name HexMapWorkspaceBindingService
extends RefCounted

const HexMapDocumentDependencyService = preload("res://addons/hex_map_kit/adapter/hex_map_document_dependency_service.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexExportProfileResource = preload("res://addons/hex_map_kit/adapter/hex_export_profile_resource.gd")
const HexGenerationProfileResource = preload("res://addons/hex_map_kit/adapter/hex_generation_profile_resource.gd")
const HexLabelDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_label_database_resource.gd")
const HexMovementProfileResource = preload("res://addons/hex_map_kit/adapter/hex_movement_profile_resource.gd")
const HexObjectDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_object_database_resource.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")
const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")
const HexValidationRuleSuiteResource = preload("res://addons/hex_map_kit/adapter/hex_validation_rule_suite_resource.gd")

const POLICY_NODE_OWNED := "node_owned"
const POLICY_DOCUMENT_DEPENDENCY := "document_dependency"
const POLICY_UNSUPPORTED := "unsupported"


static func node_owned_slot_ids() -> PackedStringArray:
	return PackedStringArray([
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT,
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK,
	])


static func shared_dependency_slot_ids() -> PackedStringArray:
	return PackedStringArray([
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG,
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE,
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE,
		HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE,
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE,
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE,
		HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE,
	])


static func resolve_hex_tile_map_layer(node: Node) -> HexTileMapLayer:
	if node == null or not is_instance_valid(node):
		return null
	if node is HexTileMapLayer:
		return node as HexTileMapLayer
	if node is TileMapLayer and _is_hex_tile_map_internal_layer(node):
		return node.get_parent() as HexTileMapLayer
	var current := node.get_parent()
	while current != null:
		if current is HexTileMapLayer:
			return current as HexTileMapLayer
		current = current.get_parent()
	return null


static func sync_node_owned_context_from_layer(
	layer: HexTileMapLayer,
	context: HexMapWorkspaceAssetContext
) -> Dictionary:
	if context == null:
		return {
			"ok": false,
			"error": ERR_INVALID_PARAMETER,
			"selected": layer != null,
			"layer": layer,
			"applied_slot_ids": PackedStringArray(),
		}
	var applied := PackedStringArray()
	context.set_level_document(layer.level_document_resource if layer != null else null)
	applied.append(HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT)
	context.set_layer_stack(layer.layer_stack_resource if layer != null else null)
	applied.append(HexMapWorkspaceAssetContext.SLOT_LAYER_STACK)
	return {
		"ok": true,
		"error": OK,
		"selected": layer != null,
		"layer": layer,
		"level_document": context.level_document,
		"layer_stack": context.layer_stack,
		"applied_slot_ids": applied,
	}


static func hydrate_context_from_document_dependencies(
	context: HexMapWorkspaceAssetContext,
	document: HexMapDocumentResource = null
) -> Dictionary:
	var actual_document := document if document != null else (context.level_document if context != null else null)
	var result := {
		"ok": context != null,
		"error": OK if context != null else ERR_INVALID_PARAMETER,
		"document": actual_document,
		"source": HexMapWorkspaceAssetContext.SOURCE_DOCUMENT_DEPENDENCY,
		"source_badge": HexMapDocumentDependencyService.SOURCE_BADGE_DOCUMENT_DEPENDENCY,
		"hydrated": {},
		"applied_slot_ids": PackedStringArray(),
		"missing_dependency_slot_ids": PackedStringArray(),
		"cleared_dependency_slot_ids": PackedStringArray(),
		"invalid_dependency_slot_ids": PackedStringArray(),
		"skipped_manual_override_slot_ids": PackedStringArray(),
		"asset_source_snapshot": {},
	}
	if context == null:
		return result
	var hydrated := HexMapDocumentDependencyService.hydrate_dependency_map(actual_document)
	result["hydrated"] = hydrated
	var applied := PackedStringArray()
	var missing := PackedStringArray()
	var cleared := PackedStringArray()
	var invalid := PackedStringArray()
	var skipped := PackedStringArray()
	for slot_id in shared_dependency_slot_ids():
		var key := dependency_key_for_slot(String(slot_id))
		if key == "":
			continue
		var entry = hydrated.get(key, {}) as Dictionary
		var dependency_resource = entry.get("resource", null) as Resource
		var current_resource := context.asset_for_slot(String(slot_id))
		var current_source := context.asset_source(String(slot_id))
		if dependency_resource == null:
			missing.append(String(slot_id))
			if current_source == HexMapWorkspaceAssetContext.SOURCE_DOCUMENT_DEPENDENCY:
				context.set_asset(String(slot_id), null)
				cleared.append(String(slot_id))
			elif current_resource != null:
				skipped.append(String(slot_id))
			continue
		if not _dependency_resource_matches_slot(String(slot_id), dependency_resource):
			invalid.append(String(slot_id))
			if current_source == HexMapWorkspaceAssetContext.SOURCE_DOCUMENT_DEPENDENCY:
				context.set_asset(String(slot_id), null)
				cleared.append(String(slot_id))
			elif current_resource != null:
				skipped.append(String(slot_id))
			continue
		if current_resource == null or current_source == HexMapWorkspaceAssetContext.SOURCE_DOCUMENT_DEPENDENCY:
			context.set_asset(
				String(slot_id),
				dependency_resource,
				HexMapWorkspaceAssetContext.SOURCE_DOCUMENT_DEPENDENCY,
				String(entry.get("source_badge", HexMapDocumentDependencyService.SOURCE_BADGE_DOCUMENT_DEPENDENCY))
			)
			applied.append(String(slot_id))
		else:
			skipped.append(String(slot_id))
	result["applied_slot_ids"] = applied
	result["missing_dependency_slot_ids"] = missing
	result["cleared_dependency_slot_ids"] = cleared
	result["invalid_dependency_slot_ids"] = invalid
	result["skipped_manual_override_slot_ids"] = skipped
	result["asset_source_snapshot"] = context.source_snapshot()
	return result


static func apply_context_slot_to_layer(
	layer: HexTileMapLayer,
	context: HexMapWorkspaceAssetContext,
	slot_id: String
) -> Dictionary:
	if context == null:
		return _writeback_result(false, ERR_INVALID_PARAMETER, slot_id, writeback_policy_for_slot(slot_id), "", "Workspace asset context is unavailable.", null, null)
	if layer == null or not is_instance_valid(layer):
		return _writeback_result(false, ERR_UNAVAILABLE, slot_id, writeback_policy_for_slot(slot_id), "", "No HexTileMap selected", null, null)
	if node_owned_slot_ids().has(slot_id):
		return _apply_node_owned_slot(layer, context, slot_id)
	if shared_dependency_slot_ids().has(slot_id):
		return _apply_shared_dependency_slot(layer, context, slot_id)
	return _writeback_result(false, ERR_INVALID_PARAMETER, slot_id, POLICY_UNSUPPORTED, "", "Unsupported workspace asset slot.", null, null)


static func relationship_for_slot(
	layer: HexTileMapLayer,
	context: HexMapWorkspaceAssetContext,
	slot_id: String,
	label: String
) -> Dictionary:
	var workspace_resource := context.asset_for_slot(slot_id) if context != null else null
	if node_owned_slot_ids().has(slot_id):
		var node_resource := _node_resource_for_slot(layer, slot_id)
		var status := "missing"
		if workspace_resource != null and node_resource != null and workspace_resource == node_resource:
			status = "linked"
		elif workspace_resource != null and node_resource == null:
			status = "workspace_pending_node_writeback"
		elif workspace_resource == null and node_resource != null:
			status = "node_only"
		elif workspace_resource != null and node_resource != workspace_resource:
			status = "different"
		return {
			"policy": POLICY_NODE_OWNED,
			"label": label,
			"workspace_resource": workspace_resource,
			"node_resource": node_resource,
			"dependency_resource": null,
			"status": status,
			"matches": workspace_resource == node_resource,
		}
	var dependency_resource := _dependency_resource_for_slot(context.level_document if context != null else null, slot_id)
	var dependency_status := "missing"
	if workspace_resource != null and dependency_resource != null and workspace_resource == dependency_resource:
		dependency_status = "linked"
	elif workspace_resource != null and dependency_resource == null:
		dependency_status = "workspace_pending_dependency_writeback"
	elif workspace_resource == null and dependency_resource != null:
		dependency_status = "dependency_only"
	elif workspace_resource != null and dependency_resource != workspace_resource:
		dependency_status = "different"
	return {
		"policy": POLICY_DOCUMENT_DEPENDENCY if shared_dependency_slot_ids().has(slot_id) else POLICY_UNSUPPORTED,
		"label": label,
		"workspace_resource": workspace_resource,
		"node_resource": null,
		"dependency_resource": dependency_resource,
		"status": dependency_status,
		"matches": workspace_resource == dependency_resource,
	}


static func writeback_policy_for_slot(slot_id: String) -> String:
	if node_owned_slot_ids().has(slot_id):
		return POLICY_NODE_OWNED
	if shared_dependency_slot_ids().has(slot_id):
		return POLICY_DOCUMENT_DEPENDENCY
	return POLICY_UNSUPPORTED


static func dependency_key_for_slot(slot_id: String) -> String:
	match slot_id:
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG:
			return HexMapDocumentDependencyService.KEY_TILE_CATALOG
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE:
			return HexMapDocumentDependencyService.KEY_OBJECT_DATABASE
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE:
			return HexMapDocumentDependencyService.KEY_LABEL_DATABASE
		HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE:
			return HexMapDocumentDependencyService.KEY_MOVEMENT_PROFILE
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE:
			return HexMapDocumentDependencyService.KEY_VALIDATION_RULE_SUITE
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE:
			return HexMapDocumentDependencyService.KEY_GENERATION_PROFILE
		HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE:
			return HexMapDocumentDependencyService.KEY_EXPORT_PROFILE
	return ""


static func _apply_node_owned_slot(
	layer: HexTileMapLayer,
	context: HexMapWorkspaceAssetContext,
	slot_id: String
) -> Dictionary:
	match slot_id:
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT:
			var document := context.level_document
			layer.level_document_resource = document
			return _writeback_result(true, OK, slot_id, POLICY_NODE_OWNED, "Selected HexTileMap Level Document", "", document, null)
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK:
			var stack := context.layer_stack
			layer.layer_stack_resource = stack
			return _writeback_result(true, OK, slot_id, POLICY_NODE_OWNED, "Selected HexTileMap Layer Stack", "", stack, null)
	return _writeback_result(false, ERR_INVALID_PARAMETER, slot_id, POLICY_UNSUPPORTED, "", "Unsupported node-owned slot.", null, null)


static func _apply_shared_dependency_slot(
	_layer: HexTileMapLayer,
	context: HexMapWorkspaceAssetContext,
	slot_id: String
) -> Dictionary:
	var document := context.level_document
	if document == null:
		return _writeback_result(false, ERR_UNAVAILABLE, slot_id, POLICY_DOCUMENT_DEPENDENCY, "Document Dependency", "No Level Document selected", null, null)
	var key := dependency_key_for_slot(slot_id)
	if key == "":
		return _writeback_result(false, ERR_INVALID_PARAMETER, slot_id, POLICY_UNSUPPORTED, "", "Unsupported document dependency slot.", null, null)
	var resource := context.asset_for_slot(slot_id)
	var dependency = null
	if resource == null:
		HexMapDocumentDependencyService.remove_shared_dependency(document, key)
	else:
		dependency = HexMapDocumentDependencyService.set_shared_dependency(document, key, resource)
	return _writeback_result(true, OK, slot_id, POLICY_DOCUMENT_DEPENDENCY, "Document Dependency", "", resource, dependency)


static func _node_resource_for_slot(layer: HexTileMapLayer, slot_id: String) -> Resource:
	if layer == null or not is_instance_valid(layer):
		return null
	match slot_id:
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT:
			return layer.level_document_resource
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK:
			return layer.layer_stack_resource
	return null


static func _dependency_resource_for_slot(document: HexMapDocumentResource, slot_id: String) -> Resource:
	var key := dependency_key_for_slot(slot_id)
	if document == null or key == "":
		return null
	var dependency = HexMapDocumentDependencyService.find_shared_dependency(document, key)
	return dependency.get("resource") if dependency is Resource else null


static func _dependency_resource_matches_slot(slot_id: String, resource: Resource) -> bool:
	match slot_id:
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG:
			return resource is HexTileCatalogResource
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE:
			return resource is HexObjectDatabaseResource
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE:
			return resource is HexLabelDatabaseResource
		HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE:
			return resource is HexMovementProfileResource
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE:
			return resource is HexValidationRuleSuiteResource
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE:
			return resource is HexGenerationProfileResource
		HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE:
			return resource is HexExportProfileResource
	return false


static func _is_hex_tile_map_internal_layer(node: Node) -> bool:
	var parent := node.get_parent()
	if not (parent is HexTileMapLayer):
		return false
	return node.name == HexTileMapLayer.BASE_TILE_MAP_NAME \
		or node.name == HexTileMapLayer.LOOP_TILE_MAP_NAME \
		or node.name == HexTileMapLayer.OVERLAY_TILE_MAP_NAME


static func _writeback_result(
	ok: bool,
	error: int,
	slot_id: String,
	policy: String,
	label: String,
	blocked_reason: String,
	resource: Resource,
	dependency
) -> Dictionary:
	return {
		"ok": ok,
		"error": error,
		"slot_id": slot_id,
		"policy": policy,
		"label": label,
		"blocked_reason": blocked_reason,
		"resource": resource,
		"dependency": dependency,
	}
