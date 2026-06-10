@tool
class_name HexMapDocumentApplier
extends RefCounted

const HexLayerStackResource = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd")
const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")


static func prepare_document_apply(document) -> Dictionary:
	if document == null:
		return {
			"ok": false,
			"error": ERR_INVALID_PARAMETER,
			"state_source": "HexMapDocumentApplier",
			"document": null,
			"document_snapshot": null,
			"map_resource": null,
		}
	var snapshot = HexMapDocumentAdapter.duplicate_document(document)
	var resource = HexMapDocumentAdapter.to_map_resource(snapshot)
	return {
		"ok": true,
		"error": OK,
		"state_source": "HexMapDocumentApplier",
		"document": document,
		"document_snapshot": snapshot,
		"map_resource": resource,
	}


static func prepare_layer_stack_apply(
	document,
	stack: HexLayerStackResource = null
) -> Dictionary:
	var result := prepare_document_apply(document)
	result["layer_stack"] = stack if stack != null else HexLayerStackResource.minimal_runtime_template()
	result["uses_layer_stack"] = true
	return result
