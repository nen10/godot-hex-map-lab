@tool
class_name HexMapGraphBuilder
extends RefCounted

const HexGenerationGraphScript = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexGenerationGraphRunnerScript = preload("res://addons/hex_map_kit/generation/hex_generation_graph_runner.gd")
const HexGenerationGraphResourceScript = preload("res://addons/hex_map_kit/adapter/hex_generation_graph_resource.gd")
const HexMapDataScript = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexOverlayDataScript = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexMapResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexOverlayResourceScript = preload("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd")
const HexMapDocumentResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")

const ROLE_TERRAIN := "terrain"
const ROLE_OVERLAY := "overlay"
const ROLE_OBJECT := "object"


static func build(graph_res, options: Dictionary = {}) -> Dictionary:
	if not (graph_res is HexGenerationGraphResourceScript):
		return _failure(
			[ _error("missing_graph_resource", "", "HexGenerationGraphResource is required.") ],
			{},
			{},
			"",
			{}
		)

	var graph_resource = graph_res as HexGenerationGraphResourceScript
	var graph := graph_resource.to_dict()
	var context := _base_context(options)
	_apply_graph_settings_to_context(context, graph_resource.graph_settings, options)
	var semantics_result := _resolve_semantics(graph_resource, options)
	if not bool(semantics_result.get("ok", false)):
		return _failure(semantics_result.get("errors", []) as Array, graph, {}, String(semantics_result.get("source", "")), {})
	_apply_semantics_to_context(context, semantics_result.get("semantics", null))
	var missing_keys := _missing_required_context_keys(semantics_result.get("semantics", null), context)
	if not missing_keys.is_empty():
		return _failure(
			[
				_error(
					"semantics_unresolved",
					"",
					"Graph semantics require missing runtime context: %s." % ", ".join(missing_keys)
				)
			],
			graph,
			{},
			String(semantics_result.get("source", "")),
			{}
		)

	var report := HexGenerationGraphRunnerScript.run_with_report(graph, context)
	if not bool(report.get("ok", false)):
		return _failure(report.get("errors", []) as Array, graph, report, String(semantics_result.get("source", "")), {})

	var promoted := _collect_promoted_outputs(graph_resource.promote_targets, graph, report.get("cache", {}) as Dictionary)
	if not bool(promoted.get("ok", false)):
		return _failure(promoted.get("errors", []) as Array, graph, report, String(semantics_result.get("source", "")), {})

	return {
		"ok": true,
		"errors": [],
		"graph_id": graph_resource.graph_id,
		"semantics_source": String(semantics_result.get("source", "")),
		"map_data": promoted.get("map_data", null),
		"overlays": promoted.get("overlays", []),
		"cache": report.get("cache", {}),
		"report": report,
	}


static func _base_context(options: Dictionary) -> Dictionary:
	var context := {}
	if options.get("context", {}) is Dictionary:
		context = (options.get("context", {}) as Dictionary).duplicate(true)
	context["seed"] = int(options.get("seed", context.get("seed", 0)))
	if options.has("interrupt_options") and options["interrupt_options"] is Dictionary:
		context["interrupt_options"] = options["interrupt_options"]
	return context


static func _apply_graph_settings_to_context(context: Dictionary, settings: Dictionary, options: Dictionary) -> void:
	if not options.has("seed"):
		context["seed"] = int(settings.get("seed", context.get("seed", 0)))
	if not context.has("orientation"):
		context["orientation"] = int(settings.get("orientation", 0))


static func _resolve_semantics(graph_resource: HexGenerationGraphResourceScript, options: Dictionary) -> Dictionary:
	if options.has("semantics_override"):
		return {
			"ok": true,
			"errors": [],
			"source": "override",
			"semantics": options["semantics_override"],
		}

	if not graph_resource.semantics_snapshot.is_empty() or String(graph_resource.ownership_semantics) == "embed":
		return {
			"ok": true,
			"errors": [],
			"source": "embed",
			"semantics": graph_resource.semantics_snapshot.duplicate(true),
		}

	var reference_path := String(graph_resource.semantics_reference_path).strip_edges()
	if reference_path == "":
		return {
			"ok": false,
			"errors": [_error("semantics_missing", "", "Graph semantics are not embedded and no reference path is set.")],
			"source": "none",
			"semantics": {},
		}
	if not ResourceLoader.exists(reference_path):
		return {
			"ok": false,
			"errors": [_error("semantics_unresolved", "", "Graph semantics reference does not exist: %s." % reference_path)],
			"source": "reference",
			"semantics": {},
		}
	var resource = ResourceLoader.load(reference_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if resource == null:
		return {
			"ok": false,
			"errors": [_error("semantics_unresolved", "", "Graph semantics reference could not be loaded: %s." % reference_path)],
			"source": "reference",
			"semantics": {},
		}
	return {
		"ok": true,
		"errors": [],
		"source": "reference",
		"semantics": resource,
	}


static func _apply_semantics_to_context(context: Dictionary, semantics) -> void:
	if semantics is Dictionary:
		var semantic_dict := semantics as Dictionary
		for key in ["context", "runtime_context", "resources"]:
			if semantic_dict.has(key) and semantic_dict[key] is Dictionary:
				_merge_context(context, semantic_dict[key] as Dictionary)
		for direct_key in ["document", "document_terrain", "document_overlay", "map", "overlay", "result"]:
			if semantic_dict.has(direct_key):
				context[direct_key] = semantic_dict[direct_key]
		return
	if semantics is HexMapDocumentResourceScript:
		context["document"] = semantics
		return
	if semantics is HexMapResourceScript:
		context["document_terrain"] = (semantics as HexMapResourceScript).to_map_data()
		context["map"] = semantics
		return
	if semantics is HexOverlayResourceScript:
		context["document_overlay"] = (semantics as HexOverlayResourceScript).to_overlay_data()
		context["overlay"] = semantics


static func _merge_context(context: Dictionary, values: Dictionary) -> void:
	for key in values.keys():
		context[key] = values[key]


static func _missing_required_context_keys(semantics, context: Dictionary) -> PackedStringArray:
	var required := PackedStringArray()
	if not semantics is Dictionary:
		return required
	var semantic_dict := semantics as Dictionary
	var raw_required = semantic_dict.get("required_context_keys", semantic_dict.get("requires", []))
	if not raw_required is Array and not raw_required is PackedStringArray:
		return required
	for raw_key in raw_required:
		var key := String(raw_key)
		if key == "":
			continue
		if not context.has(key) or context[key] == null:
			required.append(key)
	return required


static func _collect_promoted_outputs(promote_targets: Array, graph: Dictionary, cache: Dictionary) -> Dictionary:
	var targets := promote_targets.duplicate(true)
	if targets.is_empty():
		var fallback = _last_terrain_output(graph, cache)
		if fallback == null:
			return {
				"ok": false,
				"errors": [_error("missing_runtime_map_output", "", "Graph build did not produce a terrain output.")],
				"map_data": null,
				"overlays": [],
			}
		return {
			"ok": true,
			"errors": [],
			"map_data": fallback,
			"overlays": [],
		}

	var map_data = null
	var overlays: Array = []
	var errors: Array = []
	for raw_target in targets:
		if not raw_target is Dictionary:
			continue
		var target = raw_target as Dictionary
		var node_id := String(target.get("node_id", "")).strip_edges()
		var role := _normalize_role(String(target.get("role", "")))
		if node_id == "":
			continue
		if not cache.has(node_id):
			errors.append(_error("missing_promote_output", node_id, "Promote target '%s' was not produced by the graph." % node_id))
			continue
		var output = cache[node_id]
		match role:
			ROLE_TERRAIN:
				if output is HexMapDataScript:
					map_data = output
				else:
					errors.append(_error("promote_type_mismatch", node_id, "Terrain promote target requires HexMapData output."))
			ROLE_OVERLAY, ROLE_OBJECT:
				if output is HexOverlayDataScript:
					overlays.append({
						"node_id": node_id,
						"role": role,
						"data": output,
					})
				else:
					errors.append(_error("promote_type_mismatch", node_id, "Overlay/object promote target requires HexOverlayData output."))
			_:
				errors.append(_error("unknown_promote_role", node_id, "Unknown runtime promote role '%s'." % role))

	if map_data == null:
		var fallback = _last_terrain_output(graph, cache)
		if fallback != null:
			map_data = fallback
	if map_data == null:
		errors.append(_error("missing_runtime_map_output", "", "Graph build did not produce a terrain output."))
	return {
		"ok": errors.is_empty(),
		"errors": errors,
		"map_data": map_data,
		"overlays": overlays,
	}


static func _last_terrain_output(graph: Dictionary, cache: Dictionary):
	var topo := HexGenerationGraphScript.topological_order(graph)
	if not bool(topo.get("ok", false)):
		return null
	var order: Array = topo.get("order", [])
	for index in range(order.size() - 1, -1, -1):
		var node_id := String(order[index])
		var output = cache.get(node_id, null)
		if output is HexMapDataScript:
			return output
	return null


static func _normalize_role(role: String) -> String:
	var normalized := role.strip_edges().to_lower()
	if normalized == "objects":
		return ROLE_OBJECT
	return normalized


static func _failure(errors: Array, graph: Dictionary, report: Dictionary, semantics_source: String, cache: Dictionary) -> Dictionary:
	return {
		"ok": false,
		"errors": errors,
		"graph_id": "",
		"semantics_source": semantics_source,
		"map_data": null,
		"overlays": [],
		"cache": cache,
		"report": report,
		"graph": graph,
	}


static func _error(code: String, node: String, message: String) -> Dictionary:
	return {
		"code": code,
		"node": node,
		"edge": {},
		"message": message,
	}
