@tool
class_name HexMapGraphInstantiator
extends RefCounted

const HexGenerationGraphResourceScript = preload("res://addons/hex_map_kit/adapter/hex_generation_graph_resource.gd")
const HexTileMapLayerScript = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")
const HexMapDocumentAdapterScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapDocumentResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexLayerStackResourceScript = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd")

const WRITABLE_SOURCE_GENERATED := "generated"
const METADATA_SOURCE_GENERATION_GRAPH := "generation_graph"


static func instantiate_new_layer(graph_resource, parent: Node, options: Dictionary = {}) -> Dictionary:
	if not (graph_resource is HexGenerationGraphResourceScript):
		return _result(false, "new_layer", "HexGenerationGraphResource is required.")
	if parent == null:
		return _result(false, "new_layer", "A scene parent is required for graph load.")

	var graph_copy := duplicate_graph_for_embed(graph_resource)
	var layer := HexTileMapLayerScript.new()
	layer.name = _unique_child_name(parent, String(options.get("base_name", "LoadedGraphHexMapLayer")))
	parent.add_child(layer)
	if Engine.is_editor_hint():
		layer.owner = parent
	layer.generation_graph_resource = graph_copy

	var document = embedded_document(graph_copy)
	if document == null:
		document = HexMapDocumentResourceScript.new()
		document.resource_name = "%s Document" % layer.name
	layer.level_document_resource = document

	var stack = embedded_layer_stack(graph_copy)
	if stack != null:
		layer.layer_stack_resource = stack

	return {
		"ok": true,
		"mode": "new_layer",
		"blocked_reason": "",
		"created_layer": true,
		"overwrote_selected": false,
		"layer": layer,
		"graph_resource": graph_copy,
		"document": layer.level_document_resource,
		"layer_stack": layer.layer_stack_resource,
		"copied_graph": graph_copy != graph_resource,
		"copied_semantics": true,
		"single_context_owner": true,
	}


static func overwrite_selected_layer(graph_resource, layer: HexTileMapLayerScript, _options: Dictionary = {}) -> Dictionary:
	if not (graph_resource is HexGenerationGraphResourceScript):
		return _result(false, "overwrite", "HexGenerationGraphResource is required.")
	if layer == null:
		return _result(false, "overwrite", "Overwrite requires a selected HexTileMapLayer.")

	var incoming_document = embedded_document(graph_resource)
	var merge_report := {
		"assigned_document": false,
		"replaced_generated": 0,
		"preserved_manual": true,
	}
	if incoming_document != null:
		if layer.level_document_resource == null:
			layer.level_document_resource = HexMapDocumentAdapterScript.duplicate_document(incoming_document)
			merge_report["assigned_document"] = true
		else:
			merge_report = merge_generated_document_resources(layer.level_document_resource, incoming_document)

	var incoming_stack = embedded_layer_stack(graph_resource)
	if layer.layer_stack_resource == null and incoming_stack != null:
		layer.layer_stack_resource = incoming_stack

	layer.generation_graph_resource = graph_resource
	return {
		"ok": true,
		"mode": "overwrite",
		"blocked_reason": "",
		"created_layer": false,
		"overwrote_selected": true,
		"layer": layer,
		"graph_resource": graph_resource,
		"document": layer.level_document_resource,
		"layer_stack": layer.layer_stack_resource,
		"merge_report": merge_report,
		"single_context_owner": true,
	}


static func duplicate_graph_for_embed(graph_resource: HexGenerationGraphResourceScript) -> HexGenerationGraphResourceScript:
	var copy := HexGenerationGraphResourceScript.from_dict(graph_resource.to_dict())
	copy.graph_id = graph_resource.graph_id
	copy.resource_name = graph_resource.resource_name
	copy.ownership_semantics = "embed"
	copy.semantics_reference_path = ""
	copy.promote_targets = graph_resource.promote_targets.duplicate(true)
	copy.semantics_snapshot = _duplicate_semantics_snapshot(graph_resource.semantics_snapshot)
	return copy


static func embedded_document(graph_resource: HexGenerationGraphResourceScript):
	var semantics := graph_resource.semantics_snapshot
	for key in ["level_document", "document"]:
		if semantics.get(key, null) is HexMapDocumentResourceScript:
			return HexMapDocumentAdapterScript.duplicate_document(semantics[key])
	return null


static func embedded_layer_stack(graph_resource: HexGenerationGraphResourceScript):
	var semantics := graph_resource.semantics_snapshot
	if semantics.get("layer_stack", null) is HexLayerStackResourceScript:
		return (semantics["layer_stack"] as HexLayerStackResourceScript).duplicate(true)
	return null


static func merge_generated_document_resources(target: HexMapDocumentResourceScript, incoming: HexMapDocumentResourceScript) -> Dictionary:
	var replaced := 0
	replaced += _replace_generated_entries(target.terrain_layers, incoming.terrain_layers)
	replaced += _replace_generated_entries(target.overlay_layers, incoming.overlay_layers)
	replaced += _replace_generated_entries(target.object_placements, incoming.object_placements)
	return {
		"assigned_document": false,
		"replaced_generated": replaced,
		"preserved_manual": true,
	}


static func _replace_generated_entries(target_entries: Array, incoming_entries: Array) -> int:
	var replaced := 0
	for index in range(target_entries.size() - 1, -1, -1):
		if _is_generation_graph_generated(target_entries[index]):
			target_entries.remove_at(index)
			replaced += 1
	for entry in incoming_entries:
		if _is_generation_graph_generated(entry):
			target_entries.append((entry as Resource).duplicate(true))
			replaced += 1
	return replaced


static func _is_generation_graph_generated(entry) -> bool:
	if not entry is Resource:
		return false
	var metadata = entry.get("metadata") if entry.get("metadata") != null else {}
	if not metadata is Dictionary:
		return false
	return String((metadata as Dictionary).get("writable_source", "")) == WRITABLE_SOURCE_GENERATED \
		and String((metadata as Dictionary).get("source", "")) == METADATA_SOURCE_GENERATION_GRAPH


static func _duplicate_semantics_snapshot(snapshot: Dictionary) -> Dictionary:
	var result := {}
	for key in snapshot.keys():
		result[key] = _duplicate_semantics_value(snapshot[key])
	return result


static func _duplicate_semantics_value(value):
	if value is HexMapDocumentResourceScript:
		return HexMapDocumentAdapterScript.duplicate_document(value)
	if value is Resource:
		return (value as Resource).duplicate(true)
	if value is Dictionary:
		var result := {}
		for key in (value as Dictionary).keys():
			result[key] = _duplicate_semantics_value((value as Dictionary)[key])
		return result
	if value is Array:
		var result: Array = []
		for entry in value:
			result.append(_duplicate_semantics_value(entry))
		return result
	return value


static func _unique_child_name(parent: Node, base_name: String) -> String:
	var safe_base := base_name.strip_edges()
	if safe_base == "":
		safe_base = "LoadedGraphHexMapLayer"
	var names := {}
	for child in parent.get_children():
		names[String(child.name)] = true
	if not names.has(safe_base):
		return safe_base
	var suffix := 2
	while names.has("%s%d" % [safe_base, suffix]):
		suffix += 1
	return "%s%d" % [safe_base, suffix]


static func _result(ok: bool, mode: String, reason: String) -> Dictionary:
	return {
		"ok": ok,
		"mode": mode,
		"blocked_reason": reason,
		"created_layer": false,
		"overwrote_selected": false,
		"layer": null,
		"single_context_owner": false,
	}
