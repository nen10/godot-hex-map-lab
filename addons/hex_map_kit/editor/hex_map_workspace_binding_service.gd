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
const STATE_NO_TARGET := "no_target"
const STATE_SELECTED_NODE_WITHOUT_DOCUMENT := "selected_node_without_document"
const STATE_HYDRATED_DEPENDENCIES := "hydrated_dependencies"
const STATE_MANUAL_OVERRIDE := "manual_override"
const STATE_PENDING_WRITEBACK := "pending_writeback"
const STATE_APPLIED_WRITEBACK := "applied_writeback"
const STATE_CONFLICT := "conflict"
const STATE_READY := "ready"


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


static func writable_slot_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for slot_id in node_owned_slot_ids():
		ids.append(String(slot_id))
	for slot_id in shared_dependency_slot_ids():
		ids.append(String(slot_id))
	return ids


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
		"state_source": "HexMapWorkspaceBindingService",
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


static func document_dependency_hydration_snapshot(
	context: HexMapWorkspaceAssetContext,
	document: HexMapDocumentResource = null,
	last_result: Dictionary = {}
) -> Dictionary:
	var actual_document := document if document != null else (context.level_document if context != null else null)
	return {
		"state_source": "HexMapWorkspaceBindingService",
		"document": actual_document,
		"hydrated": HexMapDocumentDependencyService.hydrate_dependency_map(actual_document),
		"asset_source_snapshot": context.source_snapshot() if context != null else {},
		"last_result": last_result.duplicate(true),
	}


static func selected_writeback_snapshot(
	layer: HexTileMapLayer,
	auto_link: bool,
	context: HexMapWorkspaceAssetContext
) -> Dictionary:
	var selected := layer != null and is_instance_valid(layer)
	var blocked_reason := ""
	if not selected:
		blocked_reason = "No HexTileMap selected"
	elif not auto_link:
		blocked_reason = "Auto-link is off."
	var relationships := {}
	var relationship_slot_ids := writable_slot_ids()
	for slot_id in relationship_slot_ids:
		var relationship := relationship_for_slot(
			layer,
			context,
			String(slot_id),
			default_relationship_label_for_slot(String(slot_id))
		)
		if String(slot_id) == HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT:
			relationship["generation_metadata"] = _document_generation_metadata_snapshot(
				relationship.get("node_resource", null) as Resource
			)
		relationships[String(slot_id)] = relationship
	return {
		"state_source": "HexMapWorkspaceBindingService",
		"selected": selected,
		"auto_link": auto_link,
		"can_writeback": selected and blocked_reason == "",
		"blocked_reason": blocked_reason,
		"relationship_slot_ids": relationship_slot_ids,
		"relationships": relationships,
	}


static func apply_context_slot_to_selected_layer(
	layer: HexTileMapLayer,
	auto_link: bool,
	context: HexMapWorkspaceAssetContext,
	slot_id: String
) -> Dictionary:
	var snapshot := selected_writeback_snapshot(layer, auto_link, context)
	if not bool(snapshot.get("can_writeback", false)):
		return {
			"ok": false,
			"error": ERR_UNAVAILABLE,
			"slot_id": slot_id,
			"blocked_reason": String(snapshot.get("blocked_reason", "")),
			"policy": writeback_policy_for_slot(slot_id),
			"snapshot": snapshot,
		}
	var result := apply_context_slot_to_layer(layer, context, slot_id)
	result["snapshot"] = selected_writeback_snapshot(layer, auto_link, context)
	return result


static func sync_shared_context_to_document_dependencies(
	layer: HexTileMapLayer,
	context: HexMapWorkspaceAssetContext,
	reason: String,
	save_document: bool = true
) -> Dictionary:
	var document = context.level_document if context != null else null
	var result := {
		"state_source": "HexMapWorkspaceBindingService",
		"ok": layer != null and context != null and document != null,
		"error": OK,
		"reason": reason,
		"document": document,
		"applied_slot_ids": PackedStringArray(),
		"skipped_missing_slot_ids": PackedStringArray(),
		"slot_results": {},
		"errors": {},
		"document_saved": false,
		"save_error": OK,
	}
	if layer == null or not is_instance_valid(layer):
		result["ok"] = false
		result["error"] = ERR_DOES_NOT_EXIST
		result["blocked_reason"] = "No HexTileMap selected"
		return result
	if context == null or document == null:
		result["ok"] = false
		result["error"] = ERR_UNAVAILABLE
		result["blocked_reason"] = "No Level Document selected"
		return result

	var applied := PackedStringArray()
	var skipped := PackedStringArray()
	var slot_results := {}
	var errors := {}
	for slot_id in shared_dependency_slot_ids():
		var actual_slot_id := String(slot_id)
		var resource := context.asset_for_slot(actual_slot_id)
		if resource == null:
			skipped.append(actual_slot_id)
			continue
		var slot_result := apply_context_slot_to_layer(layer, context, actual_slot_id)
		slot_results[actual_slot_id] = slot_result
		if bool(slot_result.get("ok", false)):
			applied.append(actual_slot_id)
		else:
			errors[actual_slot_id] = int(slot_result.get("error", FAILED))

	var save_error := OK
	if save_document and errors.is_empty() and not applied.is_empty() and String(document.resource_path) != "":
		save_error = ResourceSaver.save(document, document.resource_path)
	result["ok"] = errors.is_empty() and save_error == OK
	result["error"] = OK if bool(result["ok"]) else ERR_CANT_CREATE
	result["applied_slot_ids"] = applied
	result["skipped_missing_slot_ids"] = skipped
	result["slot_results"] = slot_results
	result["errors"] = errors
	result["document_saved"] = not applied.is_empty() and String(document.resource_path) != "" and save_error == OK
	result["save_error"] = save_error
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


static func selection_binding_state(
	layer: HexTileMapLayer,
	target_layer: Node,
	auto_link: bool,
	context: HexMapWorkspaceAssetContext,
	writeback_snapshot: Dictionary = {},
	hydration_result: Dictionary = {}
) -> Dictionary:
	var selected := layer != null and is_instance_valid(layer)
	var relationships = writeback_snapshot.get("relationships", {}) as Dictionary
	if relationships == null:
		relationships = {}
	var source_snapshot := context.source_snapshot() if context != null else {}
	var active_states := PackedStringArray()
	var pending_slot_ids := PackedStringArray()
	var applied_slot_ids := PackedStringArray()
	var conflict_slot_ids := PackedStringArray()
	var manual_override_slot_ids := PackedStringArray()
	var hydrated_slot_ids := PackedStringArray()

	if not selected:
		active_states.append(STATE_NO_TARGET)
	elif layer.level_document_resource == null:
		active_states.append(STATE_SELECTED_NODE_WITHOUT_DOCUMENT)

	for slot_id in relationships.keys():
		var relationship = relationships[slot_id] as Dictionary
		if relationship == null:
			continue
		var status := String(relationship.get("status", ""))
		if status.begins_with("workspace_pending"):
			pending_slot_ids.append(String(slot_id))
		elif status == "linked":
			var workspace_resource = relationship.get("workspace_resource", null)
			if workspace_resource != null:
				applied_slot_ids.append(String(slot_id))
		elif status == "different":
			conflict_slot_ids.append(String(slot_id))

	for slot_id in shared_dependency_slot_ids():
		var source = source_snapshot.get(String(slot_id), {}) as Dictionary
		if source == null:
			continue
		var source_id := String(source.get("source", ""))
		var resource = context.asset_for_slot(String(slot_id)) if context != null else null
		if resource != null and source_id == HexMapWorkspaceAssetContext.SOURCE_DOCUMENT_DEPENDENCY:
			hydrated_slot_ids.append(String(slot_id))
		elif resource != null and source_id != "" and source_id != HexMapWorkspaceAssetContext.SOURCE_NONE:
			manual_override_slot_ids.append(String(slot_id))

	var hydration_applied = hydration_result.get("applied_slot_ids", PackedStringArray()) as PackedStringArray
	if hydration_applied != null:
		for slot_id in hydration_applied:
			if not hydrated_slot_ids.has(String(slot_id)):
				hydrated_slot_ids.append(String(slot_id))
	var hydration_skipped = hydration_result.get("skipped_manual_override_slot_ids", PackedStringArray()) as PackedStringArray
	if hydration_skipped != null:
		for slot_id in hydration_skipped:
			if not manual_override_slot_ids.has(String(slot_id)):
				manual_override_slot_ids.append(String(slot_id))

	if not conflict_slot_ids.is_empty():
		active_states.append(STATE_CONFLICT)
	if not pending_slot_ids.is_empty():
		active_states.append(STATE_PENDING_WRITEBACK)
	if not applied_slot_ids.is_empty():
		active_states.append(STATE_APPLIED_WRITEBACK)
	if not hydrated_slot_ids.is_empty():
		active_states.append(STATE_HYDRATED_DEPENDENCIES)
	if not manual_override_slot_ids.is_empty():
		active_states.append(STATE_MANUAL_OVERRIDE)
	if active_states.is_empty():
		active_states.append(STATE_READY)

	var state_id := _primary_selection_binding_state(active_states)
	var view_state := {
		"state_source": "HexMapWorkspaceBindingService",
		"state_id": state_id,
		"active_state_ids": active_states.duplicate(),
		"status_text": _selection_binding_status_text(state_id, layer),
		"auto_link": auto_link,
		"target_matches_selected": selected and target_layer == layer,
		"can_writeback": bool(writeback_snapshot.get("can_writeback", false)),
		"pending_writeback_slot_ids": pending_slot_ids.duplicate(),
		"applied_writeback_slot_ids": applied_slot_ids.duplicate(),
		"conflict_slot_ids": conflict_slot_ids.duplicate(),
		"manual_override_slot_ids": manual_override_slot_ids.duplicate(),
		"hydrated_dependency_slot_ids": hydrated_slot_ids.duplicate(),
	}
	return {
		"state_id": state_id,
		"state_source": "HexMapWorkspaceBindingService",
		"active_state_ids": active_states,
		"selected_node": layer,
		"target_layer": target_layer,
		"auto_link": auto_link,
		"target_matches_selected": selected and target_layer == layer,
		"pending_writeback_slot_ids": pending_slot_ids,
		"applied_writeback_slot_ids": applied_slot_ids,
		"conflict_slot_ids": conflict_slot_ids,
		"manual_override_slot_ids": manual_override_slot_ids,
		"hydrated_dependency_slot_ids": hydrated_slot_ids,
		"writeback": writeback_snapshot,
		"last_hydration": hydration_result.duplicate(true),
		"view_state": view_state,
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


static func default_relationship_label_for_slot(slot_id: String) -> String:
	match slot_id:
		HexMapWorkspaceAssetContext.SLOT_LEVEL_DOCUMENT:
			return "Selected HexTileMap Level Document"
		HexMapWorkspaceAssetContext.SLOT_LAYER_STACK:
			return "Selected HexTileMap Layer Stack"
		HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG:
			return "Shared Tile Catalog"
		HexMapWorkspaceAssetContext.SLOT_OBJECT_DATABASE:
			return "Shared Object Database"
		HexMapWorkspaceAssetContext.SLOT_LABEL_DATABASE:
			return "Shared Label Database"
		HexMapWorkspaceAssetContext.SLOT_MOVEMENT_PROFILE:
			return "Shared Movement Profile"
		HexMapWorkspaceAssetContext.SLOT_VALIDATION_RULE_SUITE:
			return "Shared Validation Rule Suite"
		HexMapWorkspaceAssetContext.SLOT_GENERATION_PROFILE:
			return "Shared Generation Profile"
		HexMapWorkspaceAssetContext.SLOT_EXPORT_PROFILE:
			return "Shared Export Profile"
	return "Workspace Asset"


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


static func _document_generation_metadata_snapshot(resource: Resource) -> Dictionary:
	var document := resource as HexMapDocumentResource
	if document == null or document.metadata == null:
		return {
			"present": false,
		}
	var custom: Dictionary = document.metadata.custom_properties
	return {
		"present": not document.metadata.generation_snapshot.is_empty() \
			or custom.has("generation_source"),
		"generation_seed": document.metadata.generation_seed,
		"generation_snapshot": document.metadata.generation_snapshot.duplicate(true),
		"generation_source": String(custom.get("generation_source", "")),
		"generation_output_target": String(custom.get("generation_output_target", "")),
		"generation_target_node_path": String(custom.get("generation_target_node_path", "")),
		"generation_target_document_path": String(custom.get("generation_target_document_path", "")),
	}


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


static func _primary_selection_binding_state(active_states: PackedStringArray) -> String:
	for state in [
		STATE_NO_TARGET,
		STATE_CONFLICT,
		STATE_SELECTED_NODE_WITHOUT_DOCUMENT,
		STATE_PENDING_WRITEBACK,
		STATE_MANUAL_OVERRIDE,
		STATE_HYDRATED_DEPENDENCIES,
		STATE_APPLIED_WRITEBACK,
	]:
		if active_states.has(state):
			return state
	return STATE_READY


static func _selection_binding_status_text(state_id: String, layer: HexTileMapLayer) -> String:
	match state_id:
		STATE_NO_TARGET:
			return "No HexTileMap selected"
		STATE_CONFLICT:
			return "Selected HexTileMap has conflicting workspace resources"
		STATE_SELECTED_NODE_WITHOUT_DOCUMENT:
			return "Selected HexTileMap has no Level Document"
		STATE_PENDING_WRITEBACK:
			return "Workspace resources are pending write-back"
		STATE_MANUAL_OVERRIDE:
			return "Workspace has manual resource overrides"
		STATE_HYDRATED_DEPENDENCIES:
			return "Workspace hydrated document dependencies"
		STATE_APPLIED_WRITEBACK:
			return "Workspace resources are linked"
		_:
			return "Selected HexTileMap: %s" % (layer.name if layer != null else "")
