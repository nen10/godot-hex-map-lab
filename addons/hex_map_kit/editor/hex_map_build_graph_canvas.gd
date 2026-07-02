@tool
class_name HexMapBuildGraphCanvas
extends GraphEdit

signal graph_changed
signal selected_graph_node_changed(node_id: String)
signal graph_run_completed(report: Dictionary)
signal criteria_asset_chip_pressed(node_id: String, editor_key: String)
signal result_row_promote_requested(node_id: String, input_name: String)

const HexGenerationGraphScript = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexGenerationGraphRunnerScript = preload("res://addons/hex_map_kit/generation/hex_generation_graph_runner.gd")
const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const HexGenerationPortsScript = preload("res://addons/hex_map_kit/generation/hex_generation_ports.gd")
const HexGenerationAdaptationScript = preload("res://addons/hex_map_kit/generation/hex_generation_adaptation.gd")
const HexGenerationParamSchemaScript = preload("res://addons/hex_map_kit/generation/hex_generation_param_schema.gd")
const HexGenerationCriteriaUiScript = preload("res://addons/hex_map_kit/editor/hex_generation_criteria_ui.gd")
const HexMapAssetLibraryScript = preload("res://addons/hex_map_kit/editor/hex_map_asset_library.gd")
const HexMapPreviewThumbnailScript = preload("res://addons/hex_map_kit/editor/hex_map_preview_thumbnail.gd")
const HexMapDataScript = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexOverlayDataScript = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")

const UNTYPED_PORT_TYPE := 0
const UNTYPED_PORT_COLOR := Color(0.58, 0.68, 0.72)
const ADAPTATION_ITEM_PREFIX := "item:"
const ADAPTATION_OPTION_NONE := "__none__"
const ADAPTATION_OPTION_ITEM := "__item__"
const ADAPTATION_DISPLAY_UNCONNECTED := "未接続"
const ADAPTATION_DISPLAY_SELECTION := "そのまま (selection)"
const RESULT_WRITE_POLICY_ADD_ITEM := "add_item"
const RESULT_WRITE_POLICY_REPLACE_ITEM := "replace_item"
const RESULT_WRITE_POLICY_ADD_REPLACE := "add_replace"
const RESULT_WRITE_POLICY_OPTIONS := [
	{"label": "Add Item", "value": RESULT_WRITE_POLICY_ADD_ITEM},
	{"label": "Replace Item", "value": RESULT_WRITE_POLICY_REPLACE_ITEM},
	{"label": "Add Replace", "value": RESULT_WRITE_POLICY_ADD_REPLACE},
]

const NODE_TITLES := {
	HexGenerationNodeTypesScript.NODE_TERRAIN_GENERATION: "Terrain Generation",
	HexGenerationNodeTypesScript.NODE_ITEM_GENERATION: "Item Generation",
	HexGenerationNodeTypesScript.NODE_SOURCE: "Source",
	HexGenerationNodeTypesScript.NODE_SHAPE: "Shape",
	HexGenerationNodeTypesScript.NODE_WALL_FIELD: "Wall Field",
	HexGenerationNodeTypesScript.NODE_CONNECTIVITY: "Connectivity",
	HexGenerationNodeTypesScript.NODE_REGION_FILTER: "Region Filter",
	HexGenerationNodeTypesScript.NODE_TERRAIN_FILTER: "Terrain Filter",
	HexGenerationNodeTypesScript.NODE_OVERLAY_FILTER: "Overlay Filter",
	HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR: "Item Generator",
	HexGenerationNodeTypesScript.NODE_COMPOSE: "Compose",
	HexGenerationNodeTypesScript.NODE_SET_OPERATION: "Set Operation",
	HexGenerationNodeTypesScript.NODE_RESULT: "Result",
}

var _node_counter := 0
var _node_order: PackedStringArray = PackedStringArray()
var _connections: Array[Dictionary] = []
var _selected_node_id := ""
var _selected_edge: Dictionary = {}
var _last_run_report: Dictionary = {}
var _last_preview_snapshot: Dictionary = HexMapPreviewThumbnailScript.unavailable_preview("not_run")
var _last_status := "Graph canvas ready."
var _last_rejected_connection: Dictionary = {}
var _graph_revision := 0
var _last_successful_run_revision := -1
var _dirty_node_ids: PackedStringArray = PackedStringArray()
var _last_cache_node_ids: PackedStringArray = PackedStringArray()
var _last_run_cache: Dictionary = {}
var _last_failure_node_id := ""
var _last_failure_message := ""
var _last_cancelled_node_id := ""
var _last_progress_snapshot: Dictionary = {}
var _active_progress_node_id := ""


func _ready() -> void:
	name = "Build Graph Canvas"
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(640, 900)
	if not connection_request.is_connected(_on_connection_request):
		connection_request.connect(_on_connection_request)
	if not disconnection_request.is_connected(_on_disconnection_request):
		disconnection_request.connect(_on_disconnection_request)
	if not node_selected.is_connected(_on_graph_node_selected):
		node_selected.connect(_on_graph_node_selected)
	if not node_deselected.is_connected(_on_graph_node_deselected):
		node_deselected.connect(_on_graph_node_deselected)
	if not delete_nodes_request.is_connected(_on_delete_nodes_request):
		delete_nodes_request.connect(_on_delete_nodes_request)


func _on_graph_node_selected(node: Node) -> void:
	var graph_node := node as GraphNode
	if graph_node == null:
		return
	select_graph_node(graph_node.name)


func _on_graph_node_deselected(_node: Node) -> void:
	select_graph_node("")


func _on_delete_nodes_request(nodes: Array) -> void:
	var any_removed := false
	for node_ref in nodes:
		var node_name := ""
		if node_ref is Node:
			node_name = (node_ref as Node).name
		elif node_ref is String or node_ref is StringName:
			node_name = String(node_ref)
		else:
			continue
		if _remove_graph_node(node_name):
			any_removed = true
	if any_removed:
		graph_changed.emit()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE:
			if not _selected_edge.is_empty():
				delete_selected_edge()
				accept_event()
				return
			if _selected_node_id != "":
				if _remove_graph_node(_selected_node_id):
					select_graph_node("")
					graph_changed.emit()
			accept_event()
			return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		var edge := _edge_at_screen_point(mouse_event.position)
		if not edge.is_empty():
			select_edge(
				String(edge.get("from_node", "")),
				int(edge.get("from_port", -1)),
				String(edge.get("to_node", "")),
				int(edge.get("to_port", -1))
			)
		elif not _selected_edge.is_empty():
			clear_selected_edge()


func remove_graph_node(node_id: String) -> bool:
	return _remove_graph_node(node_id)


func remove_selected() -> void:
	if _selected_node_id != "":
		_remove_graph_node(_selected_node_id)
		select_graph_node("")
		graph_changed.emit()


func _remove_graph_node(node_id: String) -> bool:
	if node_id == "":
		return false
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return false
	var affected_targets: Array[String] = []
	for i in range(_connections.size() - 1, -1, -1):
		var conn := _connections[i] as Dictionary
		if String(conn.get("from_node", "")) == node_id or String(conn.get("to_node", "")) == node_id:
			var target_id := String(conn.get("to_node", ""))
			if target_id != "" and target_id != node_id and not affected_targets.has(target_id):
				affected_targets.append(target_id)
			disconnect_node(
				String(conn.get("from_node", "")),
				int(conn.get("from_port", -1)),
				String(conn.get("to_node", "")),
				int(conn.get("to_port", -1))
			)
			_connections.remove_at(i)
	if not _selected_edge.is_empty() \
			and (String(_selected_edge.get("from_node", "")) == node_id or String(_selected_edge.get("to_node", "")) == node_id):
		_selected_edge.clear()
		_update_selected_connection_highlight()
	remove_child(graph_node)
	graph_node.queue_free()
	var new_order: PackedStringArray = PackedStringArray()
	for nid in _node_order:
		if String(nid) != node_id:
			new_order.append(String(nid))
	_node_order = new_order
	for target_id in affected_targets:
		_compact_variadic_input_connections(target_id)
	_sync_graph_edit_from_connection_model()
	_last_status = "Removed node %s." % node_id
	_mark_dirty_all()
	return true


func add_graph_node(node_type: String, position: Vector2 = Vector2.ZERO, node_id: String = "", initial_params: Dictionary = {}) -> String:
	if not HexGenerationNodeTypesScript.has_type(node_type):
		_last_status = "Unknown graph node type: %s" % node_type
		return ""
	var actual_id := node_id.strip_edges()
	if actual_id == "":
		_node_counter += 1
		actual_id = "%s_%d" % [node_type, _node_counter]
	if has_node(NodePath(actual_id)):
		_last_status = "Graph node already exists: %s" % actual_id
		return ""

	var params := default_params_for_type(node_type)
	for key in initial_params.keys():
		params[key] = initial_params[key]
	var graph_node := GraphNode.new()
	graph_node.name = actual_id
	graph_node.title = _title_for_node(node_type, params)
	graph_node.position_offset = position
	graph_node.custom_minimum_size = Vector2(340, 120) if HexGenerationNodeTypesScript.is_consolidated_type(node_type) else Vector2(240, 120)
	graph_node.set("resizable", true)
	graph_node.set_meta("hex_generation_node_id", actual_id)
	graph_node.set_meta("hex_generation_node_type", node_type)
	graph_node.set_meta("hex_generation_params", params)
	graph_node.set_meta("hex_generation_resource_refs", {})
	graph_node.set_meta("hex_generation_input_slots", {})
	graph_node.set_meta("hex_generation_output_slots", {})

	add_child(graph_node)
	_configure_graph_node_titlebar(graph_node, actual_id, node_type, params)
	_node_order.append(actual_id)
	_rebuild_graph_node_rows(actual_id)
	if _selected_node_id == "":
		select_graph_node(actual_id)
	_last_status = "Added %s." % graph_node.title
	_mark_dirty_from_node(actual_id)
	graph_changed.emit()
	return actual_id


func clear_graph() -> void:
	for child in get_children():
		if child is GraphNode:
			remove_child(child)
			child.queue_free()
	_connections.clear()
	_node_order = PackedStringArray()
	_selected_node_id = ""
	_selected_edge.clear()
	_last_run_report = {}
	_last_preview_snapshot = HexMapPreviewThumbnailScript.unavailable_preview("empty_graph")
	_last_status = "Graph cleared."
	_last_cache_node_ids = PackedStringArray()
	_last_run_cache = {}
	_last_successful_run_revision = -1
	_clear_failure_highlight()
	_last_cancelled_node_id = ""
	_last_progress_snapshot = {}
	_clear_progress_highlight()
	_mark_dirty_all()
	graph_changed.emit()
	selected_graph_node_changed.emit("")


func request_connection(
	from_node: String,
	from_port: int,
	to_node: String,
	to_port: int,
	adaptation_override: String = "",
	write_policy_override: String = ""
) -> Dictionary:
	var validation := validate_connection(from_node, from_port, to_node, to_port)
	if not bool(validation.get("ok", false)):
		_last_rejected_connection = validation.duplicate(true)
		_last_status = String(validation.get("reason", "Connection rejected."))
		graph_changed.emit()
		return validation
	if _has_connection(from_node, from_port, to_node, to_port):
		return validation
	var adaptation := String(validation.get("adaptation", ""))
	if adaptation_override.strip_edges() != "":
		adaptation = adaptation_override.strip_edges()
	var to_port_name := _input_name_for_slot(to_node, to_port)
	var connection := {
		"from_node": from_node,
		"from_port": from_port,
		"to_node": to_node,
		"to_port": to_port,
		"from_port_name": HexGenerationNodeTypesScript.PORT_OUT,
		"to_port_name": to_port_name,
		"port_type": validation.get("port_type", ""),
		"adaptation": adaptation,
	}
	if _node_type_for_id(to_node) == HexGenerationNodeTypesScript.NODE_RESULT:
		connection["write_policy"] = _normalized_result_write_policy(
			write_policy_override if write_policy_override.strip_edges() != "" else _result_write_policy_for_input(to_node, to_port_name)
		)
	_connections.append(connection)
	if _node_type_for_id(to_node) == HexGenerationNodeTypesScript.NODE_RESULT:
		_sync_result_write_policy_params_from_connections(to_node)
	_clear_forced_input_port(to_node, to_port_name)
	_sync_graph_edit_from_connection_model()
	_last_status = "Connected %s to %s.%s." % [
		from_node,
		to_node,
		to_port_name,
	]
	_mark_dirty_from_node(to_node)
	graph_changed.emit()
	return validation


func validate_connection(from_node: String, from_port: int, to_node: String, to_port: int) -> Dictionary:
	var from_graph_node := _graph_node(from_node)
	var to_graph_node := _graph_node(to_node)
	if from_graph_node == null or to_graph_node == null:
		return _connection_result(false, "Connection endpoint is missing.")
	var output_name := _output_name_for_slot(from_node, from_port)
	if output_name != HexGenerationNodeTypesScript.PORT_OUT:
		return _connection_result(false, "Source slot is not an output port.")
	var to_port_name := _input_name_for_slot(to_node, to_port)
	if to_port_name == "":
		return _connection_result(false, "Target slot is not an input port.")
	if _input_slot_has_connection(to_node, to_port) and not _has_connection(from_node, from_port, to_node, to_port):
		return _connection_result(false, "Input %s.%s already has a connection." % [to_node, to_port_name])
	if _would_create_cycle(from_node, to_node):
		return _connection_result(false, "Connection would create a cycle.")
	var from_node_dict := node_dictionary(from_node)
	var output_type := HexGenerationNodeTypesScript.output_type_for_node(from_node_dict)
	var to_node_type := String(to_graph_node.get_meta("hex_generation_node_type", ""))
	var input_def := HexGenerationNodeTypesScript.input_definition(to_node_type, to_port_name)
	if input_def.is_empty():
		return _connection_result(false, "Unknown input port %s." % to_port_name)
	if HexGenerationNodeTypesScript.is_consolidated_type(to_node_type):
		return _connection_result(true, "", output_type, _default_adaptation_for_output_type(output_type, to_node_type))
	if not HexGenerationPortsScript.compatible(output_type, input_def.get("accepts", [])):
		return _connection_result(
			false,
			"Cannot connect %s output to %s input." % [output_type, str(HexGenerationPortsScript.normalize_accepts(input_def.get("accepts", [])))],
			output_type
		)
	return _connection_result(true, "", output_type)


func select_graph_node(node_id: String) -> void:
	if node_id != "" and _graph_node(node_id) == null:
		return
	if node_id != "":
		clear_selected_edge()
	_selected_node_id = node_id
	_update_last_preview_for_selected_node()
	selected_graph_node_changed.emit(_selected_node_id)


func selected_node_id() -> String:
	return _selected_node_id


func select_edge(from_node: String, from_port: int, to_node: String, to_port: int) -> Dictionary:
	var edge := _connection_for_slots(from_node, from_port, to_node, to_port)
	if edge.is_empty():
		return {}
	_selected_edge = edge.duplicate(true)
	_selected_node_id = ""
	_update_selected_connection_highlight()
	_last_status = "Selected edge %s -> %s.%s." % [
		from_node,
		to_node,
		String(edge.get("to_port_name", _input_name_for_slot(to_node, to_port))),
	]
	selected_graph_node_changed.emit("")
	graph_changed.emit()
	return _selected_edge.duplicate(true)


func clear_selected_edge() -> void:
	if _selected_edge.is_empty():
		return
	_selected_edge.clear()
	_update_selected_connection_highlight()
	graph_changed.emit()


func selected_edge() -> Dictionary:
	return _selected_edge.duplicate(true)


func delete_selected_edge() -> bool:
	if _selected_edge.is_empty():
		return false
	var edge := _selected_edge.duplicate(true)
	var deleted := delete_edge(
		String(edge.get("from_node", "")),
		int(edge.get("from_port", -1)),
		String(edge.get("to_node", "")),
		int(edge.get("to_port", -1))
	)
	return deleted


func delete_edge(from_node: String, from_port: int, to_node: String, to_port: int) -> bool:
	var deleted := false
	var to_node_id := to_node
	for index in range(_connections.size() - 1, -1, -1):
		var connection := _connections[index] as Dictionary
		if _same_connection_slots(connection, from_node, from_port, to_node, to_port):
			_connections.remove_at(index)
			deleted = true
			break
	if not deleted:
		return false
	_compact_variadic_input_connections(to_node_id)
	_sync_graph_edit_from_connection_model()
	_selected_edge.clear()
	_update_selected_connection_highlight()
	_last_status = "Deleted edge %s -> %s." % [from_node, to_node]
	_mark_dirty_from_node(to_node_id)
	graph_changed.emit()
	return true


func selected_node_dictionary() -> Dictionary:
	if _selected_node_id == "":
		return {}
	return node_dictionary(_selected_node_id)


func node_dictionary(node_id: String) -> Dictionary:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return {}
	return {
		"id": node_id,
		"type": String(graph_node.get_meta("hex_generation_node_type", "")),
		"params": (graph_node.get_meta("hex_generation_params", {}) as Dictionary).duplicate(true),
		"resource_refs": (graph_node.get_meta("hex_generation_resource_refs", {}) as Dictionary).duplicate(),
	}


func node_params(node_id: String) -> Dictionary:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return {}
	return (graph_node.get_meta("hex_generation_params", {}) as Dictionary).duplicate(true)


func set_node_params(node_id: String, params: Dictionary) -> void:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return
	graph_node.set_meta("hex_generation_params", params.duplicate(true))
	graph_node.title = _title_for_node(String(graph_node.get_meta("hex_generation_node_type", "")), params)
	_configure_graph_node_titlebar(graph_node, node_id, String(graph_node.get_meta("hex_generation_node_type", "")), params)
	if String(graph_node.get_meta("hex_generation_node_type", "")) == HexGenerationNodeTypesScript.NODE_RESULT:
		_sync_result_connection_write_policies_from_params(node_id)
	_last_status = "Updated %s parameters." % node_id
	_mark_dirty_from_node(node_id)
	graph_changed.emit()


func set_node_resource_refs(node_id: String, resource_refs: Dictionary) -> void:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return
	graph_node.set_meta("hex_generation_resource_refs", resource_refs.duplicate())
	_last_status = "Updated %s resource refs." % node_id
	_mark_dirty_from_node(node_id)
	graph_changed.emit()


func build_graph_model() -> Dictionary:
	var graph = HexGenerationGraphScript.new_graph()
	for node_id in _node_order:
		var node := node_dictionary(String(node_id))
		if node.is_empty():
			continue
		HexGenerationGraphScript.add_node(
			graph,
			String(node["id"]),
			String(node["type"]),
			node.get("params", {}),
			node.get("resource_refs", {})
		)
	for connection in _connections:
		var edge := HexGenerationGraphScript.add_edge(
			graph,
			String(connection.get("from_node", "")),
			String(connection.get("to_node", "")),
			String(connection.get("to_port_name", "")),
			String(connection.get("from_port_name", HexGenerationNodeTypesScript.PORT_OUT)),
			String(connection.get("adaptation", ""))
		)
		var write_policy := String(connection.get("write_policy", "")).strip_edges()
		if write_policy != "":
			edge["write_policy"] = _normalized_result_write_policy(write_policy)
	return graph


func restore_graph_model(graph: Dictionary, preferred_selected_node_id: String = "") -> Dictionary:
	clear_graph()
	var nodes = graph.get("nodes", {}) as Dictionary
	var topo := HexGenerationGraphScript.topological_order(graph)
	var ordered_nodes: Array = topo.get("order", []) if bool(topo.get("ok", false)) else nodes.keys()
	if ordered_nodes.is_empty():
		_last_status = "Graph resource is empty."
		graph_changed.emit()
		return {
			"ok": false,
			"node_count": 0,
			"connection_count": 0,
			"selected_node_id": "",
			"reason": "empty_graph",
		}

	var index := 0
	for raw_node_id in ordered_nodes:
		var node_id := String(raw_node_id)
		var node = nodes.get(node_id, {}) as Dictionary
		var node_type := String(node.get("type", ""))
		var restored_id := add_graph_node(node_type, Vector2(40 + index * 210, 120), node_id, node.get("params", {}) as Dictionary)
		if restored_id == "":
			continue
		set_node_params(restored_id, node.get("params", {}) as Dictionary)
		set_node_resource_refs(restored_id, node.get("resource_refs", {}) as Dictionary)
		index += 1

	var connection_count := 0
	for raw_edge in graph.get("edges", []) as Array:
		var edge = raw_edge as Dictionary
		var from_node := String(edge.get("from_node", ""))
		var to_node := String(edge.get("to_node", ""))
		var from_slot := _slot_for_output_name(from_node, String(edge.get("from_port", HexGenerationNodeTypesScript.PORT_OUT)))
		_ensure_input_row_for_port(to_node, String(edge.get("to_port", "")))
		var to_slot := _slot_for_input_name(to_node, String(edge.get("to_port", "")))
		if from_slot < 0 or to_slot < 0:
			continue
		var connection := request_connection(
			from_node,
			from_slot,
			to_node,
			to_slot,
			String(edge.get("adaptation", "")),
			String(edge.get("write_policy", ""))
		)
		if bool(connection.get("ok", false)):
			connection_count += 1

	var selected_id := preferred_selected_node_id
	if selected_id == "" or _graph_node(selected_id) == null:
		selected_id = String(ordered_nodes[ordered_nodes.size() - 1])
	select_graph_node(selected_id)
	_last_status = "Restored graph with %d nodes." % _node_order.size()
	graph_changed.emit()
	return {
		"ok": true,
		"node_count": _node_order.size(),
		"connection_count": connection_count,
		"selected_node_id": selected_id,
	}


func validate_graph_model() -> Dictionary:
	return HexGenerationGraphScript.validate(build_graph_model())


func run_graph(context: Dictionary = {}) -> Dictionary:
	var prepared := prepare_graph_run(context)
	var run_context := prepared.get("context", {}) as Dictionary
	var report = HexGenerationGraphRunnerScript.run_with_report(prepared.get("graph", {}) as Dictionary, run_context)
	complete_graph_run(report, run_context)
	return _last_run_report.duplicate(true)


func prepare_graph_run(context: Dictionary = {}) -> Dictionary:
	var run_context := context.duplicate(true)
	run_context["previous_cache"] = _last_run_cache.duplicate(true)
	run_context["dirty_node_ids"] = _dirty_node_ids.duplicate()
	return {
		"graph": build_graph_model(),
		"context": run_context,
	}


func complete_graph_run(report: Dictionary, run_context: Dictionary = {}) -> Dictionary:
	_last_progress_snapshot = _progress_snapshot_from_context(run_context)
	if bool(report.get("ok", false)):
		_last_run_report = report.duplicate(true)
		_last_run_cache = (report.get("cache", {}) as Dictionary).duplicate(true)
		_last_cache_node_ids = _cache_node_ids(_last_run_cache)
		_last_successful_run_revision = _graph_revision
		_dirty_node_ids = PackedStringArray()
		_clear_failure_highlight()
		_last_cancelled_node_id = ""
		_last_status = "Graph generated %d node outputs." % int(_last_run_cache.size())
	elif bool(report.get("cancelled", false)):
		_last_run_report = report.duplicate(true)
		_last_cancelled_node_id = _first_error_node_id(report)
		_clear_failure_highlight()
		_last_status = _first_error_message(report)
	else:
		_last_run_report = report.duplicate(true)
		_last_cancelled_node_id = ""
		_set_failure_highlight(_first_error_node_id(report), _first_error_message(report))
		_last_status = _first_error_message(report)
	_clear_progress_highlight()
	_update_last_preview_for_selected_node()
	_sync_graph_edit_from_connection_model()
	graph_run_completed.emit(_last_run_report.duplicate(true))
	graph_changed.emit()
	return _last_run_report.duplicate(true)


func selected_output() -> Variant:
	var cache = _last_run_report.get("cache", {}) as Dictionary
	if _selected_node_id == "" or not cache.has(_selected_node_id):
		return null
	return cache[_selected_node_id]


func selected_output_type() -> String:
	var node := selected_node_dictionary()
	if node.is_empty():
		return ""
	return HexGenerationNodeTypesScript.output_type_for_node(node)


func selected_preview_snapshot() -> Dictionary:
	return _last_preview_snapshot.duplicate(true)


func canvas_snapshot() -> Dictionary:
	return {
		"component": "HexMapBuildGraphCanvas",
		"node_ids": _node_order.duplicate(),
		"node_count": _node_order.size(),
		"connection_count": _connections.size(),
		"connections": _connections.duplicate(true),
		"selected_node_id": _selected_node_id,
		"selected_edge": _selected_edge.duplicate(true),
		"selected_edge_present": not _selected_edge.is_empty(),
		"selected_output_type": selected_output_type(),
		"preview": selected_preview_snapshot(),
		"preview_available": bool(_last_preview_snapshot.get("available", false)),
		"status_text": _last_status,
		"last_rejected_connection": _last_rejected_connection.duplicate(true),
		"dominant_surface": true,
		"untyped_port_type": UNTYPED_PORT_TYPE,
		"port_type_colors": _port_color_snapshot(),
		"adaptation_rows": _adaptation_rows_snapshot(),
		"result_rows": _result_rows_snapshot(),
		"node_titlebars": _node_titlebars_snapshot(),
		"run_state": run_state_snapshot(),
	}


func run_state_snapshot() -> Dictionary:
	return {
		"graph_revision": _graph_revision,
		"last_successful_run_revision": _last_successful_run_revision,
		"cache_ready": _last_successful_run_revision == _graph_revision and not _last_cache_node_ids.is_empty(),
		"cache_dirty": not _dirty_node_ids.is_empty(),
		"dirty_node_ids": _dirty_node_ids.duplicate(),
		"cache_node_ids": _last_cache_node_ids.duplicate(),
		"cache_node_count": _last_cache_node_ids.size(),
		"recomputed_node_ids": _last_run_report.get("recomputed_node_ids", PackedStringArray()),
		"reused_node_ids": _last_run_report.get("reused_node_ids", PackedStringArray()),
		"failure_node_id": _last_failure_node_id,
		"failure_message": _last_failure_message,
		"failure_visible": _last_failure_node_id != "",
		"failure_node_highlighted": _failure_node_highlighted(),
		"cancelled": bool(_last_run_report.get("cancelled", false)),
		"cancelled_node_id": _last_cancelled_node_id,
		"progress": float(_last_progress_snapshot.get("progress", 0.0)),
		"progress_phase": String(_last_progress_snapshot.get("phase", "")),
		"progress_node_id": String(_last_progress_snapshot.get("node_id", "")),
		"progress_node_highlighted": _progress_node_highlighted(),
	}


func set_progress_node(node_id: String) -> void:
	if node_id == _active_progress_node_id:
		return
	_clear_progress_highlight()
	_active_progress_node_id = node_id
	if _active_progress_node_id == "":
		return
	var graph_node := _graph_node(_active_progress_node_id)
	if graph_node == null:
		return
	if bool(graph_node.get_meta("hex_generation_failure_highlighted", false)):
		return
	graph_node.modulate = Color(0.78, 0.9, 1.0, 1.0)
	graph_node.set_meta("hex_generation_progress_highlighted", true)


func clear_progress_node() -> void:
	_clear_progress_highlight()


func build_default_three_node_chain() -> PackedStringArray:
	clear_graph()
	var shape := add_graph_node(HexGenerationNodeTypesScript.NODE_SHAPE, Vector2(40, 80), "shape")
	var walls := add_graph_node(HexGenerationNodeTypesScript.NODE_WALL_FIELD, Vector2(260, 80), "walls")
	var connect := add_graph_node(HexGenerationNodeTypesScript.NODE_CONNECTIVITY, Vector2(480, 80), "connectivity")
	request_connection(shape, 0, walls, 0)
	request_connection(walls, 0, connect, 0)
	select_graph_node(connect)
	return PackedStringArray([shape, walls, connect])


static func title_for_node_type(node_type: String) -> String:
	return String(NODE_TITLES.get(node_type, node_type.capitalize()))


static func _title_for_node(node_type: String, params: Dictionary) -> String:
	var display_name := String(params.get("display_name", "")).strip_edges()
	if display_name != "":
		return display_name
	if node_type == HexGenerationNodeTypesScript.NODE_SOURCE:
		var output_type := String(params.get("output_type", HexGenerationPortsScript.TERRAIN))
		if output_type == HexGenerationPortsScript.OVERLAY:
			return "Source Overlay"
		if output_type == HexGenerationPortsScript.TERRAIN:
			return "Source Terrain"
	return title_for_node_type(node_type)


static func default_params_for_type(node_type: String) -> Dictionary:
	if HexGenerationNodeTypesScript.is_consolidated_type(node_type):
		return HexGenerationParamSchemaScript.default_params(node_type)
	match node_type:
		HexGenerationNodeTypesScript.NODE_SOURCE:
			return {
				"kind": "context",
				"source_key": "document_terrain",
				"output_type": HexGenerationPortsScript.TERRAIN,
			}
		HexGenerationNodeTypesScript.NODE_SHAPE:
			return {
				"shape": "rectangle",
				"width": 6,
				"height": 4,
			}
		HexGenerationNodeTypesScript.NODE_WALL_FIELD:
			return {
				"wall_probability": 0.25,
				"seed": 17,
			}
		HexGenerationNodeTypesScript.NODE_CONNECTIVITY:
			return {
				"method": "dense",
				"seed": 41,
			}
		HexGenerationNodeTypesScript.NODE_REGION_FILTER, HexGenerationNodeTypesScript.NODE_TERRAIN_FILTER:
			return {
				"filter_target": "floor",
				"shift_q": 0,
				"shift_r": 0,
				"shift_s": 0,
				"within_distance_of": [HexVectorScript.zero()],
				"max_distance": 3,
			}
		HexGenerationNodeTypesScript.NODE_OVERLAY_FILTER:
			return {
				"filter_target": "item_key",
				"item_key": "spawn",
				"shift_q": 0,
				"shift_r": 0,
				"shift_s": 0,
				"within_distance_of": [HexVectorScript.zero()],
				"max_distance": 3,
			}
		HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR:
			return {
				"placement_method": "weighted",
				"placement_probability": 1.0,
				"seed": 99,
				"item_pool": [{"name": "spawn", "weight": 1.0}],
			}
		HexGenerationNodeTypesScript.NODE_COMPOSE:
			return {
				"write_policy": HexOverlayDataScript.APPLY_ADD_ITEM,
				"existing_policy": HexOverlayDataScript.EXISTING_MERGE,
			}
		HexGenerationNodeTypesScript.NODE_SET_OPERATION:
			return {
				"operation": "union",
			}
		HexGenerationNodeTypesScript.NODE_RESULT:
			return {
				"orientation": 0,
			}
	return {}


func _configure_graph_node_titlebar(graph_node: GraphNode, node_id: String, node_type: String, params: Dictionary) -> void:
	if graph_node == null or not graph_node.has_method("get_titlebar_hbox"):
		return
	var titlebar = graph_node.call("get_titlebar_hbox") as HBoxContainer
	if titlebar == null:
		return
	for child in titlebar.get_children():
		if String(child.name).begins_with("HexTitlebar"):
			titlebar.remove_child(child)
			child.queue_free()
	if not HexGenerationNodeTypesScript.is_consolidated_type(node_type):
		return
	var edit := LineEdit.new()
	edit.name = "HexTitlebarDisplayName_%s" % node_id
	edit.custom_minimum_size = Vector2(220, 0)
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.text = _title_for_node(node_type, params)
	edit.tooltip_text = "Node display name"
	edit.text_submitted.connect(func(_text: String):
		_commit_titlebar_display_name(node_id, edit.text)
	)
	edit.focus_exited.connect(func():
		_commit_titlebar_display_name(node_id, edit.text)
	)
	titlebar.add_child(edit)
	for state in HexGenerationCriteriaUiScript.chip_states(node_type, params):
		var state_dict := state as Dictionary
		var editor_key := String(state_dict.get("editor_key", ""))
		var chip := MenuButton.new()
		chip.name = "HexTitlebarCriteriaChip_%s_%s" % [node_id, editor_key]
		chip.text = String(state_dict.get("label", "asset: inline"))
		chip.tooltip_text = "Criteria asset actions"
		var popup := chip.get_popup()
		HexGenerationCriteriaUiScript.populate_chip_menu(popup, editor_key, params)
		popup.id_pressed.connect(func(id: int):
			_on_titlebar_criteria_chip_menu_id(node_id, editor_key, id, popup)
		)
		titlebar.add_child(chip)


func _on_titlebar_criteria_chip_menu_id(node_id: String, editor_key: String, id: int, popup: PopupMenu) -> void:
	select_graph_node(node_id)
	if id == HexGenerationCriteriaUiScript.CHIP_MENU_OPEN_EDITOR:
		criteria_asset_chip_pressed.emit(node_id, editor_key)
	elif id == HexGenerationCriteriaUiScript.CHIP_MENU_SAVE_AS_ASSET:
		_save_titlebar_criteria_asset(node_id, editor_key)
	elif id == HexGenerationCriteriaUiScript.CHIP_MENU_DETACH_TO_INLINE:
		_detach_titlebar_criteria_asset(node_id, editor_key)
	elif id >= HexGenerationCriteriaUiScript.CHIP_MENU_LOAD_ASSET_BASE:
		var path := HexGenerationCriteriaUiScript.menu_item_path(popup, id)
		if path != "":
			_load_titlebar_criteria_asset(node_id, editor_key, path)


func _load_titlebar_criteria_asset(node_id: String, editor_key: String, path: String) -> void:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return
	var params := (graph_node.get_meta("hex_generation_params", {}) as Dictionary).duplicate(true)
	var resource = HexMapAssetLibraryScript.load(path)
	var next_params := HexGenerationCriteriaUiScript.params_after_asset_load(editor_key, params, resource, path)
	if next_params.is_empty():
		_last_status = "Could not load criteria asset."
		graph_changed.emit()
		return
	set_node_params(node_id, next_params)


func _save_titlebar_criteria_asset(node_id: String, editor_key: String) -> void:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return
	var params := (graph_node.get_meta("hex_generation_params", {}) as Dictionary).duplicate(true)
	var display_name := HexGenerationCriteriaUiScript.criteria_save_name(editor_key, _title_for_node(String(graph_node.get_meta("hex_generation_node_type", "")), params), node_id)
	var save_result := HexGenerationCriteriaUiScript.save_current_as_asset(editor_key, params, display_name)
	if int(save_result.get("error", FAILED)) != OK:
		_last_status = "Could not save criteria asset."
		graph_changed.emit()
		return
	_scan_editor_filesystem()
	set_node_params(node_id, (save_result.get("params", params) as Dictionary).duplicate(true))


func _detach_titlebar_criteria_asset(node_id: String, editor_key: String) -> void:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return
	var params := (graph_node.get_meta("hex_generation_params", {}) as Dictionary).duplicate(true)
	set_node_params(node_id, HexGenerationCriteriaUiScript.params_after_detach(editor_key, params))


func _scan_editor_filesystem() -> void:
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()


func _commit_titlebar_display_name(node_id: String, display_name: String) -> void:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return
	var params := (graph_node.get_meta("hex_generation_params", {}) as Dictionary).duplicate(true)
	var next_name := display_name.strip_edges()
	if String(params.get("display_name", "")).strip_edges() == next_name:
		return
	params["display_name"] = next_name
	graph_node.set_meta("hex_generation_params", params)
	graph_node.title = _title_for_node(String(graph_node.get_meta("hex_generation_node_type", "")), params)
	_last_status = "Updated %s display name." % node_id
	_mark_dirty_from_node(node_id)
	graph_changed.emit()
	if _selected_node_id == node_id:
		selected_graph_node_changed.emit(node_id)


func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	request_connection(String(from_node), from_port, String(to_node), to_port)


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	for index in range(_connections.size() - 1, -1, -1):
		var connection := _connections[index] as Dictionary
		if String(connection.get("from_node", "")) == String(from_node) \
				and int(connection.get("from_port", -1)) == from_port \
				and String(connection.get("to_node", "")) == String(to_node) \
				and int(connection.get("to_port", -1)) == to_port:
			_connections.remove_at(index)
			break
	_compact_variadic_input_connections(String(to_node))
	_sync_graph_edit_from_connection_model()
	if not _selected_edge.is_empty() and _same_connection_slots(_selected_edge, String(from_node), from_port, String(to_node), to_port):
		_selected_edge.clear()
		_update_selected_connection_highlight()
	_last_status = "Disconnected graph ports."
	_mark_dirty_from_node(String(to_node))
	graph_changed.emit()


func _graph_node(node_id: String) -> GraphNode:
	if node_id == "":
		return null
	return get_node_or_null(NodePath(node_id)) as GraphNode


func _rebuild_graph_node_rows(node_id: String) -> void:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return
	_clear_graph_node_rows(graph_node)
	var node_type := String(graph_node.get_meta("hex_generation_node_type", ""))
	var params := graph_node.get_meta("hex_generation_params", {}) as Dictionary
	var input_names := _input_names_for_node(node_id)
	var output_type := _output_type_for_node_meta(node_type, params)
	var row_count = max(input_names.size(), 1 if output_type != "" else 0)
	graph_node.set_meta("hex_generation_input_slots", {})
	graph_node.set_meta("hex_generation_output_slots", {})
	for row_index in range(row_count):
		var input_name := String(input_names[row_index]) if row_index < input_names.size() else ""
		var row := _slot_row_control(node_id, input_name, output_type if row_index == 0 else "")
		graph_node.add_child(row)
		var has_left := input_name != ""
		var has_right := row_index == 0 and output_type != ""
		graph_node.set_slot(
			row_index,
			has_left,
			UNTYPED_PORT_TYPE,
			UNTYPED_PORT_COLOR,
			has_right,
			UNTYPED_PORT_TYPE,
			UNTYPED_PORT_COLOR
		)
		if has_left:
			var input_slots: Dictionary = graph_node.get_meta("hex_generation_input_slots", {})
			input_slots[row_index] = input_name
			graph_node.set_meta("hex_generation_input_slots", input_slots)
		if has_right:
			var output_slots: Dictionary = graph_node.get_meta("hex_generation_output_slots", {})
			output_slots[row_index] = HexGenerationNodeTypesScript.PORT_OUT
			graph_node.set_meta("hex_generation_output_slots", output_slots)


func _clear_graph_node_rows(graph_node: GraphNode) -> void:
	if graph_node.has_method("clear_all_slots"):
		graph_node.call("clear_all_slots")
	for index in range(graph_node.get_child_count() - 1, -1, -1):
		var child := graph_node.get_child(index)
		graph_node.remove_child(child)
		child.queue_free()


func _input_names_for_node(node_id: String) -> Array:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return []
	var node_type := String(graph_node.get_meta("hex_generation_node_type", ""))
	if _node_uses_dynamic_input_rows(node_type):
		return _dynamic_input_names_for_node(node_id, node_type)
	var result: Array = []
	for port_name in HexGenerationNodeTypesScript.input_definitions(node_type).keys():
		result.append(String(port_name))
	result.sort()
	return result


func _dynamic_input_names_for_node(node_id: String, node_type: String) -> Array:
	var result: Array = []
	for port_name in _connected_input_port_names(node_id):
		if not result.has(port_name):
			result.append(port_name)
	for forced_name in _forced_input_port_names(node_id):
		if HexGenerationNodeTypesScript.input_definition(node_type, forced_name).is_empty():
			continue
		if not result.has(forced_name):
			result.append(forced_name)
	result.sort_custom(func(a, b): return _input_port_sort_key(String(a)) < _input_port_sort_key(String(b)))
	var empty_name := _next_empty_variadic_input_name(result)
	if empty_name != "" and not result.has(empty_name):
		result.append(empty_name)
	return result


func _node_uses_dynamic_input_rows(node_type: String) -> bool:
	return node_type == HexGenerationNodeTypesScript.NODE_SET_OPERATION \
		or node_type == HexGenerationNodeTypesScript.NODE_RESULT


func _connected_input_port_names(node_id: String) -> Array[String]:
	var result: Array[String] = []
	for connection in _connections:
		var connection_dict := connection as Dictionary
		if String(connection_dict.get("to_node", "")) != node_id:
			continue
		var port_name := String(connection_dict.get("to_port_name", connection_dict.get("to_port", "")))
		if port_name != "" and not result.has(port_name):
			result.append(port_name)
	return result


func _forced_input_port_names(node_id: String) -> Array[String]:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return []
	var forced = graph_node.get_meta("hex_generation_forced_input_ports", [])
	var result: Array[String] = []
	if forced is Array:
		for value in forced:
			var text := String(value)
			if text != "" and not result.has(text):
				result.append(text)
	return result


func _next_empty_variadic_input_name(existing_names: Array) -> String:
	var index := 0
	while existing_names.has("in_%d" % index):
		index += 1
	return "in_%d" % index


func _input_port_sort_key(port_name: String) -> int:
	if port_name.begins_with("in_"):
		return int(port_name.substr(3))
	match port_name:
		HexGenerationNodeTypesScript.RESULT_TERRAIN_PORT:
			return 10000
		"a":
			return 10001
		"b":
			return 10002
		_:
			if HexGenerationNodeTypesScript.is_result_overlay_port(port_name):
				return 11000 + int(port_name.substr(HexGenerationNodeTypesScript.RESULT_OVERLAY_PORT_PREFIX.length()))
	return 20000


func _slot_row_control(node_id: String, input_name: String, output_type: String) -> Control:
	var row := HBoxContainer.new()
	row.name = "Slot %s %s" % [node_id, input_name if input_name != "" else "out"]
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 8)
	var label := Label.new()
	label.text = _slot_row_text(input_name, output_type)
	label.clip_text = false
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(96, 0)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 18)
	row.add_child(label)
	if input_name != "" and _uses_adaptation_control(node_id, input_name):
		_add_adaptation_controls(row, node_id, input_name)
	if input_name != "" and _node_type_for_id(node_id) == HexGenerationNodeTypesScript.NODE_RESULT:
		_add_result_row_controls(row, node_id, input_name)
	return row


func _input_name_for_slot(node_id: String, slot: int) -> String:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return ""
	var input_slots = graph_node.get_meta("hex_generation_input_slots", {}) as Dictionary
	return String(input_slots.get(slot, ""))


func _output_name_for_slot(node_id: String, slot: int) -> String:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return ""
	var output_slots = graph_node.get_meta("hex_generation_output_slots", {}) as Dictionary
	return String(output_slots.get(slot, ""))


func _slot_for_input_name(node_id: String, input_name: String) -> int:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return -1
	var input_slots = graph_node.get_meta("hex_generation_input_slots", {}) as Dictionary
	for slot in input_slots.keys():
		if String(input_slots[slot]) == input_name:
			return int(slot)
	return -1


func _slot_for_output_name(node_id: String, output_name: String) -> int:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return -1
	var output_slots = graph_node.get_meta("hex_generation_output_slots", {}) as Dictionary
	for slot in output_slots.keys():
		if String(output_slots[slot]) == output_name:
			return int(slot)
	return -1


func _output_type_for_node_meta(node_type: String, params: Dictionary) -> String:
	return HexGenerationNodeTypesScript.output_type_for_node({
		"type": node_type,
		"params": params,
	})


func _slot_row_text(input_name: String, output_type: String) -> String:
	if input_name != "" and output_type != "":
		return "%s -> %s" % [input_name, output_type]
	if input_name != "":
		return input_name
	return output_type


func _node_type_for_id(node_id: String) -> String:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return ""
	return String(graph_node.get_meta("hex_generation_node_type", ""))


func _uses_adaptation_control(node_id: String, input_name: String) -> bool:
	var node_type := _node_type_for_id(node_id)
	if node_type == HexGenerationNodeTypesScript.NODE_RESULT:
		return false
	if node_type == HexGenerationNodeTypesScript.NODE_TERRAIN_GENERATION:
		return input_name == "terminals"
	if node_type == HexGenerationNodeTypesScript.NODE_ITEM_GENERATION:
		return input_name == "domain"
	if node_type == HexGenerationNodeTypesScript.NODE_SET_OPERATION:
		return true
	return false


func _add_adaptation_controls(row: HBoxContainer, node_id: String, input_name: String) -> void:
	var edge := _connection_for_input_name(node_id, input_name)
	var connected := not edge.is_empty()
	var adaptation := String(edge.get("adaptation", "")) if connected else ""
	if not connected:
		var unconnected_label := Label.new()
		unconnected_label.name = "AdaptationUnconnected %s %s" % [node_id, input_name]
		unconnected_label.text = ADAPTATION_DISPLAY_UNCONNECTED
		unconnected_label.tooltip_text = "Connect an output before choosing adaptation."
		unconnected_label.custom_minimum_size = Vector2(112, 0)
		unconnected_label.add_theme_color_override("font_color", Color(0.62, 0.66, 0.68))
		row.add_child(unconnected_label)
		return
	var option := OptionButton.new()
	option.name = "Adaptation %s %s" % [node_id, input_name]
	option.custom_minimum_size = Vector2(112, 0)
	option.tooltip_text = "Input adaptation"
	_add_adaptation_option(option, _adaptation_display_text("", true), ADAPTATION_OPTION_NONE)
	_add_adaptation_option(option, "floor", HexGenerationAdaptationScript.ADAPT_FLOOR)
	_add_adaptation_option(option, "wall", HexGenerationAdaptationScript.ADAPT_WALL)
	_add_adaptation_option(option, "any", HexGenerationAdaptationScript.ADAPT_ANY)
	_add_adaptation_option(option, "cells", HexGenerationAdaptationScript.ADAPT_CELLS)
	_add_adaptation_option(option, "item(key)", ADAPTATION_OPTION_ITEM)
	var selected_index := _adaptation_option_index(option, adaptation)
	option.select(selected_index)
	row.add_child(option)
	var key_edit := LineEdit.new()
	key_edit.name = "Adaptation Key %s %s" % [node_id, input_name]
	key_edit.custom_minimum_size = Vector2(84, 0)
	key_edit.text = _item_key_from_adaptation(adaptation)
	key_edit.placeholder_text = "key"
	key_edit.visible = _adaptation_is_item(adaptation)
	key_edit.editable = connected
	row.add_child(key_edit)
	option.item_selected.connect(_on_adaptation_option_selected.bind(node_id, input_name, option, key_edit))
	key_edit.text_changed.connect(_on_adaptation_key_changed.bind(node_id, input_name))


func _add_result_row_controls(row: HBoxContainer, node_id: String, input_name: String) -> void:
	var row_data := _result_row_data(node_id, input_name)
	var resolution := Label.new()
	resolution.name = "ResultResolution %s %s" % [node_id, input_name]
	resolution.text = String(row_data.get("resolution", "unused"))
	resolution.tooltip_text = String(row_data.get("tooltip", ""))
	resolution.custom_minimum_size = Vector2(92, 0)
	resolution.add_theme_font_size_override("font_size", 16)
	row.add_child(resolution)
	if bool(row_data.get("is_overlay", false)):
		var up_button := Button.new()
		up_button.name = "ResultRowMoveUp %s %s" % [node_id, input_name]
		up_button.text = "Up"
		up_button.tooltip_text = "Move this overlay row earlier in the Result stack"
		up_button.disabled = not bool(row_data.get("can_move_up", false))
		up_button.pressed.connect(func():
			move_result_overlay_row(node_id, input_name, -1)
		)
		row.add_child(up_button)
		var down_button := Button.new()
		down_button.name = "ResultRowMoveDown %s %s" % [node_id, input_name]
		down_button.text = "Down"
		down_button.tooltip_text = "Move this overlay row later in the Result stack"
		down_button.disabled = not bool(row_data.get("can_move_down", false))
		down_button.pressed.connect(func():
			move_result_overlay_row(node_id, input_name, 1)
		)
		row.add_child(down_button)
		_add_result_write_policy_control(row, node_id, input_name)
	if bool(row_data.get("connected", false)):
		var promote_button := Button.new()
		promote_button.name = "ResultRowPromote %s %s" % [node_id, input_name]
		promote_button.text = "Promote"
		promote_button.disabled = not bool(row_data.get("promotable", false))
		promote_button.tooltip_text = "Promote this Result row" if bool(row_data.get("promotable", false)) else String(row_data.get("tooltip", ""))
		promote_button.pressed.connect(func():
			result_row_promote_requested.emit(node_id, input_name)
		)
		row.add_child(promote_button)


func _add_result_write_policy_control(row: HBoxContainer, node_id: String, input_name: String) -> void:
	var option := OptionButton.new()
	option.name = "ResultWritePolicy %s %s" % [node_id, input_name]
	option.custom_minimum_size = Vector2(132, 0)
	option.tooltip_text = "Overlay write policy"
	for policy in RESULT_WRITE_POLICY_OPTIONS:
		var policy_dict := policy as Dictionary
		var item_index := option.item_count
		option.add_item(String(policy_dict.get("label", "")))
		option.set_item_metadata(item_index, String(policy_dict.get("value", RESULT_WRITE_POLICY_ADD_ITEM)))
	option.select(_result_write_policy_option_index(option, _result_write_policy_for_input(node_id, input_name)))
	option.item_selected.connect(func(index: int):
		set_result_row_write_policy(node_id, input_name, String(option.get_item_metadata(index)))
	)
	row.add_child(option)


func _add_adaptation_option(option: OptionButton, label: String, value: String) -> void:
	var index := option.item_count
	option.add_item(label)
	option.set_item_metadata(index, value)


func _adaptation_display_text(adaptation: String, connected: bool = true) -> String:
	if not connected:
		return ADAPTATION_DISPLAY_UNCONNECTED
	var normalized := adaptation.strip_edges()
	if normalized == "" or normalized == ADAPTATION_OPTION_NONE:
		return ADAPTATION_DISPLAY_SELECTION
	return normalized


func _adaptation_option_index(option: OptionButton, adaptation: String) -> int:
	var normalized := adaptation.strip_edges()
	if _adaptation_is_item(normalized):
		normalized = ADAPTATION_OPTION_ITEM
	elif normalized == "":
		normalized = ADAPTATION_OPTION_NONE
	for index in range(option.item_count):
		if String(option.get_item_metadata(index)) == normalized:
			return index
	return 0


func _adaptation_is_item(adaptation: String) -> bool:
	var normalized := adaptation.strip_edges()
	return normalized.begins_with(ADAPTATION_ITEM_PREFIX) or (normalized.begins_with("item(") and normalized.ends_with(")"))


func _item_key_from_adaptation(adaptation: String) -> String:
	var normalized := adaptation.strip_edges()
	if normalized.begins_with(ADAPTATION_ITEM_PREFIX):
		return normalized.substr(ADAPTATION_ITEM_PREFIX.length())
	if normalized.begins_with("item(") and normalized.ends_with(")"):
		return normalized.substr(5, normalized.length() - 6)
	return "item"


func _on_adaptation_option_selected(
	index: int,
	node_id: String,
	input_name: String,
	option: OptionButton,
	key_edit: LineEdit
) -> void:
	var value := String(option.get_item_metadata(index))
	if value == ADAPTATION_OPTION_NONE:
		value = ""
	elif value == ADAPTATION_OPTION_ITEM:
		value = "%s%s" % [ADAPTATION_ITEM_PREFIX, _non_empty_item_key(key_edit.text)]
	key_edit.visible = value.begins_with(ADAPTATION_ITEM_PREFIX)
	set_connection_adaptation(node_id, input_name, value)


func _on_adaptation_key_changed(text: String, node_id: String, input_name: String) -> void:
	set_connection_adaptation(node_id, input_name, "%s%s" % [ADAPTATION_ITEM_PREFIX, _non_empty_item_key(text)])


func _non_empty_item_key(text: String) -> String:
	var value := text.strip_edges()
	return "item" if value == "" else value


func set_connection_adaptation(node_id: String, input_name: String, adaptation: String) -> bool:
	for index in range(_connections.size()):
		var connection := _connections[index] as Dictionary
		if String(connection.get("to_node", "")) == node_id \
				and String(connection.get("to_port_name", "")) == input_name:
			connection["adaptation"] = adaptation.strip_edges()
			if not _selected_edge.is_empty() and _same_connection_slots(
				connection,
				String(_selected_edge.get("from_node", "")),
				int(_selected_edge.get("from_port", -1)),
				String(_selected_edge.get("to_node", "")),
				int(_selected_edge.get("to_port", -1))
			):
				_selected_edge = connection.duplicate(true)
			_last_status = "Updated %s.%s adaptation." % [node_id, input_name]
			_mark_dirty_from_node(node_id)
			graph_changed.emit()
			return true
	return false


func connection_adaptation(node_id: String, input_name: String) -> String:
	var edge := _connection_for_input_name(node_id, input_name)
	return String(edge.get("adaptation", ""))


func set_result_row_write_policy(node_id: String, input_name: String, write_policy: String) -> bool:
	if _node_type_for_id(node_id) != HexGenerationNodeTypesScript.NODE_RESULT:
		return false
	var normalized := _normalized_result_write_policy(write_policy)
	for index in range(_connections.size()):
		var connection := _connections[index] as Dictionary
		if String(connection.get("to_node", "")) != node_id:
			continue
		if String(connection.get("to_port_name", "")) != input_name:
			continue
		connection["write_policy"] = normalized
		_set_result_param_write_policy(node_id, input_name, normalized)
		_last_status = "Updated %s.%s write policy." % [node_id, input_name]
		_mark_dirty_from_node(node_id)
		graph_changed.emit()
		return true
	return false


func result_row_write_policy(node_id: String, input_name: String) -> String:
	return _result_write_policy_for_input(node_id, input_name)


func can_move_result_overlay_row(node_id: String, input_name: String, direction: int) -> bool:
	var overlay_indices := _result_overlay_connection_indices(node_id)
	var current := _result_overlay_connection_list_index(overlay_indices, node_id, input_name)
	if current < 0:
		return false
	var next := current + (1 if direction > 0 else -1)
	return next >= 0 and next < overlay_indices.size()


func move_result_overlay_row(node_id: String, input_name: String, direction: int) -> bool:
	if direction == 0:
		return false
	var overlay_indices := _result_overlay_connection_indices(node_id)
	var current := _result_overlay_connection_list_index(overlay_indices, node_id, input_name)
	if current < 0:
		return false
	var next := current + (1 if direction > 0 else -1)
	if next < 0 or next >= overlay_indices.size():
		return false
	var a := int(overlay_indices[current])
	var b := int(overlay_indices[next])
	var temp := _connections[a]
	_connections[a] = _connections[b]
	_connections[b] = temp
	_compact_variadic_input_connections(node_id)
	_sync_result_write_policy_params_from_connections(node_id)
	_sync_graph_edit_from_connection_model()
	_last_status = "Moved Result overlay row %s.%s." % [node_id, input_name]
	_mark_dirty_from_node(node_id)
	graph_changed.emit()
	return true


func result_row_output(node_id: String, input_name: String) -> Dictionary:
	var row_data := _result_row_data(node_id, input_name)
	if not bool(row_data.get("promotable", false)):
		return {
			"ok": false,
			"blocked_reason": String(row_data.get("tooltip", "Result row is not promotable.")),
			"row": row_data,
		}
	var cache = _last_run_report.get("cache", {}) as Dictionary
	var output = cache.get(node_id, null)
	if output == null:
		return {
			"ok": false,
			"blocked_reason": "Run the graph before promoting this Result row.",
			"row": row_data,
		}
	var role := String(row_data.get("promote_role", ""))
	if role == "terrain":
		var terrain_res = output.get("primary_map")
		if terrain_res != null and terrain_res.has_method("to_map_data"):
			return {
				"ok": true,
				"role": "terrain",
				"output": terrain_res.to_map_data(),
				"row": row_data,
			}
	elif role == "overlay":
		var overlay_maps = output.get("overlay_maps")
		var overlay_index := int(row_data.get("overlay_index", -1))
		if overlay_maps is Array and overlay_index >= 0 and overlay_index < (overlay_maps as Array).size():
			var overlay_res = (overlay_maps as Array)[overlay_index]
			if overlay_res != null and overlay_res.has_method("to_overlay_data"):
				return {
					"ok": true,
					"role": "overlay",
					"output": overlay_res.to_overlay_data(),
					"row": row_data,
				}
	return {
		"ok": false,
		"blocked_reason": "Result row output is unavailable.",
		"row": row_data,
	}


func _connection_for_input_name(node_id: String, input_name: String) -> Dictionary:
	for connection in _connections:
		var connection_dict := connection as Dictionary
		if String(connection_dict.get("to_node", "")) == node_id \
				and String(connection_dict.get("to_port_name", "")) == input_name:
			return connection_dict
	return {}


func _result_row_data(node_id: String, input_name: String) -> Dictionary:
	var edge := _connection_for_input_name(node_id, input_name)
	var connected := not edge.is_empty()
	var data := {
		"node_id": node_id,
		"input": input_name,
		"connected": connected,
		"source_node": String(edge.get("from_node", "")),
		"resolution": ADAPTATION_DISPLAY_UNCONNECTED if not connected else "unused",
		"kind": "unconnected" if not connected else "unused",
		"promotable": false,
		"promote_role": "",
		"overlay_index": -1,
		"result_overlay_count": 0,
		"unused_reason": "not_connected",
		"write_policy": _result_write_policy_for_input(node_id, input_name),
		"write_policy_label": _result_write_policy_label(_result_write_policy_for_input(node_id, input_name)),
		"is_overlay": false,
	}
	if not connected:
		data["tooltip"] = "Connect an output to include it in the Result stack."
		return data
	var metadata := _result_metadata_for_node(node_id)
	for entry in metadata.get("terrain_inputs", []) as Array:
		var terrain_entry := entry as Dictionary
		if String(terrain_entry.get("port", "")) != input_name:
			continue
		var role := String(terrain_entry.get("role", "unused"))
		if role == "substrate":
			data["resolution"] = "substrate"
			data["kind"] = "substrate"
			data["promotable"] = true
			data["promote_role"] = "terrain"
			data["unused_reason"] = ""
		else:
			data["kind"] = "unused_terrain"
			data["unused_reason"] = "extra_terrain"
		data["tooltip"] = _result_row_tooltip(data)
		return data
	for entry in metadata.get("overlay_inputs", []) as Array:
		var overlay_entry := entry as Dictionary
		if String(overlay_entry.get("port", "")) != input_name:
			continue
		var overlay_index := int(overlay_entry.get("overlay_index", _result_overlay_index_for_input_name(node_id, input_name)))
		var policy := _normalized_result_write_policy(String(overlay_entry.get("write_policy", data["write_policy"])))
		data["resolution"] = "overlay %d" % overlay_index
		data["kind"] = "overlay"
		data["promotable"] = true
		data["promote_role"] = "overlay"
		data["overlay_index"] = overlay_index
		data["result_overlay_count"] = int(metadata.get("overlay_count", max(overlay_index + 1, 0)))
		data["unused_reason"] = ""
		data["write_policy"] = policy
		data["write_policy_label"] = _result_write_policy_label(policy)
		data["is_overlay"] = true
		data["can_move_up"] = can_move_result_overlay_row(node_id, input_name, -1)
		data["can_move_down"] = can_move_result_overlay_row(node_id, input_name, 1)
		data["tooltip"] = _result_row_tooltip(data)
		return data
	for entry in metadata.get("unused_inputs", []) as Array:
		var unused_entry := entry as Dictionary
		if String(unused_entry.get("port", "")) != input_name:
			continue
		data["kind"] = "unused_%s" % String(unused_entry.get("producer_kind", "input"))
		data["unused_reason"] = String(unused_entry.get("reason", "not_result_material"))
		data["tooltip"] = _result_row_tooltip(data)
		return data
	var producer_type := _result_input_producer_type(node_id, input_name)
	if producer_type == HexGenerationPortsScript.TERRAIN:
		if _result_input_is_first_terrain(node_id, input_name):
			data["resolution"] = "substrate"
			data["kind"] = "substrate"
			data["promotable"] = true
			data["promote_role"] = "terrain"
			data["unused_reason"] = ""
		else:
			data["kind"] = "unused_terrain"
			data["unused_reason"] = "extra_terrain"
	elif producer_type == HexGenerationPortsScript.OVERLAY:
		var overlay_index := _result_overlay_index_for_input_name(node_id, input_name)
		data["resolution"] = "overlay %d" % overlay_index if overlay_index >= 0 else "overlay"
		data["kind"] = "overlay"
		data["promotable"] = true
		data["promote_role"] = "overlay"
		data["overlay_index"] = overlay_index
		data["result_overlay_count"] = _result_overlay_connection_indices(node_id).size()
		data["unused_reason"] = ""
		data["is_overlay"] = true
		data["can_move_up"] = can_move_result_overlay_row(node_id, input_name, -1)
		data["can_move_down"] = can_move_result_overlay_row(node_id, input_name, 1)
	else:
		data["kind"] = "unused_%s" % producer_type
		data["unused_reason"] = "not_result_material"
	data["tooltip"] = _result_row_tooltip(data)
	return data


func _result_metadata_for_node(node_id: String) -> Dictionary:
	var cache = _last_run_report.get("cache", {}) as Dictionary
	var result_value = cache.get(node_id, null)
	if not result_value is Object:
		return {}
	var metadata_value = (result_value as Object).get("metadata")
	return metadata_value as Dictionary if metadata_value is Dictionary else {}


func _result_row_tooltip(row_data: Dictionary) -> String:
	match String(row_data.get("unused_reason", "")):
		"extra_terrain":
			return "Unused: Result substrate is the first connected terrain input."
		"not_result_material":
			return "Unused: Result can promote the terrain substrate and overlay rows only."
		"not_connected":
			return "Connect an output to include it in the Result stack."
		_:
			if bool(row_data.get("is_overlay", false)):
				return "Overlay row: order and write policy define the Result stack."
			if String(row_data.get("kind", "")) == "substrate":
				return "Substrate: first connected terrain input."
	return ""


func _result_input_producer_type(node_id: String, input_name: String) -> String:
	var edge := _connection_for_input_name(node_id, input_name)
	if edge.is_empty():
		return ""
	var from_node := node_dictionary(String(edge.get("from_node", "")))
	if from_node.is_empty():
		return ""
	return HexGenerationNodeTypesScript.output_type_for_node(from_node)


func _result_input_is_first_terrain(node_id: String, input_name: String) -> bool:
	for connection in _connections:
		var connection_dict := connection as Dictionary
		if String(connection_dict.get("to_node", "")) != node_id:
			continue
		if _result_input_producer_type(node_id, String(connection_dict.get("to_port_name", ""))) != HexGenerationPortsScript.TERRAIN:
			continue
		return String(connection_dict.get("to_port_name", "")) == input_name
	return false


func _result_overlay_index_for_input_name(node_id: String, input_name: String) -> int:
	var overlay_index := 0
	for connection in _connections:
		var connection_dict := connection as Dictionary
		if String(connection_dict.get("to_node", "")) != node_id:
			continue
		if _result_input_producer_type(node_id, String(connection_dict.get("to_port_name", ""))) != HexGenerationPortsScript.OVERLAY:
			continue
		if String(connection_dict.get("to_port_name", "")) == input_name:
			return overlay_index
		overlay_index += 1
	return -1


func _result_overlay_connection_indices(node_id: String) -> Array:
	var result: Array = []
	for index in range(_connections.size()):
		var connection := _connections[index] as Dictionary
		if String(connection.get("to_node", "")) != node_id:
			continue
		if _result_input_producer_type(node_id, String(connection.get("to_port_name", ""))) != HexGenerationPortsScript.OVERLAY:
			continue
		result.append(index)
	return result


func _result_overlay_connection_list_index(indices: Array, node_id: String, input_name: String) -> int:
	for list_index in range(indices.size()):
		var connection := _connections[int(indices[list_index])] as Dictionary
		if String(connection.get("to_node", "")) == node_id and String(connection.get("to_port_name", "")) == input_name:
			return list_index
	return -1


func _normalized_result_write_policy(write_policy: String) -> String:
	match write_policy.strip_edges():
		RESULT_WRITE_POLICY_REPLACE_ITEM:
			return RESULT_WRITE_POLICY_REPLACE_ITEM
		RESULT_WRITE_POLICY_ADD_REPLACE:
			return RESULT_WRITE_POLICY_ADD_REPLACE
		_:
			return RESULT_WRITE_POLICY_ADD_ITEM


func _result_write_policy_label(write_policy: String) -> String:
	var normalized := _normalized_result_write_policy(write_policy)
	for policy in RESULT_WRITE_POLICY_OPTIONS:
		var policy_dict := policy as Dictionary
		if String(policy_dict.get("value", "")) == normalized:
			return String(policy_dict.get("label", normalized))
	return normalized


func _result_write_policy_option_index(option: OptionButton, write_policy: String) -> int:
	var normalized := _normalized_result_write_policy(write_policy)
	for index in range(option.item_count):
		if String(option.get_item_metadata(index)) == normalized:
			return index
	return 0


func _result_write_policy_for_input(node_id: String, input_name: String) -> String:
	var edge := _connection_for_input_name(node_id, input_name)
	if not edge.is_empty() and String(edge.get("write_policy", "")).strip_edges() != "":
		return _normalized_result_write_policy(String(edge.get("write_policy", "")))
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return RESULT_WRITE_POLICY_ADD_ITEM
	var params = graph_node.get_meta("hex_generation_params", {}) as Dictionary
	var policies = params.get("result_write_policies", {})
	if policies is Dictionary:
		return _normalized_result_write_policy(String((policies as Dictionary).get(input_name, RESULT_WRITE_POLICY_ADD_ITEM)))
	return RESULT_WRITE_POLICY_ADD_ITEM


func _set_result_param_write_policy(node_id: String, input_name: String, write_policy: String) -> void:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return
	var params := (graph_node.get_meta("hex_generation_params", {}) as Dictionary).duplicate(true)
	var policies = params.get("result_write_policies", {})
	var policy_map := (policies as Dictionary).duplicate(true) if policies is Dictionary else {}
	policy_map[input_name] = _normalized_result_write_policy(write_policy)
	params["result_write_policies"] = policy_map
	graph_node.set_meta("hex_generation_params", params)


func _sync_result_connection_write_policies_from_params(node_id: String) -> void:
	for connection in _connections:
		var connection_dict := connection as Dictionary
		if String(connection_dict.get("to_node", "")) != node_id:
			continue
		var input_name := String(connection_dict.get("to_port_name", ""))
		connection_dict["write_policy"] = _result_write_policy_for_input(node_id, input_name)


func _sync_result_write_policy_params_from_connections(node_id: String) -> void:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return
	var params := (graph_node.get_meta("hex_generation_params", {}) as Dictionary).duplicate(true)
	var policy_map := {}
	for connection in _connections:
		var connection_dict := connection as Dictionary
		if String(connection_dict.get("to_node", "")) != node_id:
			continue
		var input_name := String(connection_dict.get("to_port_name", ""))
		if input_name == "":
			continue
		policy_map[input_name] = _normalized_result_write_policy(String(connection_dict.get("write_policy", RESULT_WRITE_POLICY_ADD_ITEM)))
	params["result_write_policies"] = policy_map
	graph_node.set_meta("hex_generation_params", params)


func _result_resolution_text(node_id: String, input_name: String) -> String:
	return String(_result_row_data(node_id, input_name).get("resolution", "unused"))


func _sync_graph_edit_from_connection_model() -> void:
	_disconnect_visible_connections()
	for node_id in _node_order:
		_rebuild_graph_node_rows(String(node_id))
	_refresh_all_connection_slot_indices()
	_connect_visible_connections()
	_update_selected_connection_highlight()


func _disconnect_visible_connections() -> void:
	for raw_connection in get_connection_list():
		var connection := raw_connection as Dictionary
		var from_node := String(connection.get("from_node", connection.get("from", "")))
		var to_node := String(connection.get("to_node", connection.get("to", "")))
		var from_port := int(connection.get("from_port", -1))
		var to_port := int(connection.get("to_port", -1))
		if from_node == "" or to_node == "" or from_port < 0 or to_port < 0:
			continue
		disconnect_node(StringName(from_node), from_port, StringName(to_node), to_port)


func _connect_visible_connections() -> void:
	for connection in _connections:
		var connection_dict := connection as Dictionary
		var from_node := String(connection_dict.get("from_node", ""))
		var to_node := String(connection_dict.get("to_node", ""))
		var from_port := int(connection_dict.get("from_port", -1))
		var to_port := int(connection_dict.get("to_port", -1))
		if from_node == "" or to_node == "" or from_port < 0 or to_port < 0:
			continue
		connect_node(StringName(from_node), from_port, StringName(to_node), to_port)


func _refresh_all_connection_slot_indices() -> void:
	for index in range(_connections.size()):
		var connection := _connections[index] as Dictionary
		connection["from_port"] = _slot_for_output_name(
			String(connection.get("from_node", "")),
			String(connection.get("from_port_name", HexGenerationNodeTypesScript.PORT_OUT))
		)
		connection["to_port"] = _slot_for_input_name(
			String(connection.get("to_node", "")),
			String(connection.get("to_port_name", ""))
		)


func _compact_variadic_input_connections(node_id: String) -> void:
	var node_type := _node_type_for_id(node_id)
	if not _node_uses_dynamic_input_rows(node_type):
		return
	var next_index := 0
	for connection in _connections:
		var connection_dict := connection as Dictionary
		if String(connection_dict.get("to_node", "")) != node_id:
			continue
		var port_name := String(connection_dict.get("to_port_name", ""))
		if not port_name.begins_with("in_"):
			continue
		connection_dict["to_port_name"] = "in_%d" % next_index
		next_index += 1
	if node_type == HexGenerationNodeTypesScript.NODE_RESULT:
		_sync_result_write_policy_params_from_connections(node_id)


func _ensure_input_row_for_port(node_id: String, input_name: String) -> void:
	if input_name == "" or _slot_for_input_name(node_id, input_name) >= 0:
		return
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return
	var node_type := String(graph_node.get_meta("hex_generation_node_type", ""))
	if HexGenerationNodeTypesScript.input_definition(node_type, input_name).is_empty():
		return
	var forced := _forced_input_port_names(node_id)
	if not forced.has(input_name):
		forced.append(input_name)
	graph_node.set_meta("hex_generation_forced_input_ports", forced)
	_rebuild_graph_node_rows(node_id)


func _clear_forced_input_port(node_id: String, input_name: String) -> void:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return
	var forced := _forced_input_port_names(node_id)
	if not forced.has(input_name):
		return
	forced.erase(input_name)
	graph_node.set_meta("hex_generation_forced_input_ports", forced)


func _input_slot_has_connection(node_id: String, slot: int) -> bool:
	for connection in _connections:
		var connection_dict := connection as Dictionary
		if String(connection_dict.get("to_node", "")) == node_id and int(connection_dict.get("to_port", -1)) == slot:
			return true
	return false


func _would_create_cycle(from_node: String, to_node: String) -> bool:
	if from_node == to_node:
		return true
	return HexGenerationGraphScript.would_create_cycle(build_graph_model(), from_node, to_node)


func _default_adaptation_for_output_type(output_type: String, target_node_type: String) -> String:
	if target_node_type == HexGenerationNodeTypesScript.NODE_RESULT:
		return ""
	match output_type:
		HexGenerationPortsScript.TERRAIN:
			return HexGenerationAdaptationScript.ADAPT_FLOOR
		HexGenerationPortsScript.OVERLAY:
			return HexGenerationAdaptationScript.ADAPT_CELLS
		_:
			return ""


func _is_node_hover_valid(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> bool:
	return bool(validate_connection(String(from_node), from_port, String(to_node), to_port).get("ok", false))


func _has_connection(from_node: String, from_port: int, to_node: String, to_port: int) -> bool:
	for connection in _connections:
		if _same_connection_slots(connection as Dictionary, from_node, from_port, to_node, to_port):
			return true
	return false


func _connection_for_slots(from_node: String, from_port: int, to_node: String, to_port: int) -> Dictionary:
	for connection in _connections:
		var connection_dict := connection as Dictionary
		if _same_connection_slots(connection_dict, from_node, from_port, to_node, to_port):
			return connection_dict
	return {}


func _same_connection_slots(connection: Dictionary, from_node: String, from_port: int, to_node: String, to_port: int) -> bool:
	return String(connection.get("from_node", "")) == from_node \
		and int(connection.get("from_port", -1)) == from_port \
		and String(connection.get("to_node", "")) == to_node \
		and int(connection.get("to_port", -1)) == to_port


func _edge_at_screen_point(point: Vector2) -> Dictionary:
	if not has_method("get_closest_connection_at_point"):
		return {}
	var raw = get_closest_connection_at_point(point)
	if not raw is Dictionary:
		return {}
	var data := raw as Dictionary
	var from_node := String(data.get("from_node", data.get("from", data.get("from_node_name", ""))))
	var to_node := String(data.get("to_node", data.get("to", data.get("to_node_name", ""))))
	var from_port := int(data.get("from_port", -1))
	var to_port := int(data.get("to_port", -1))
	if from_node == "" or to_node == "" or from_port < 0 or to_port < 0:
		return {}
	return _connection_for_slots(from_node, from_port, to_node, to_port)


func _update_selected_connection_highlight() -> void:
	for connection in _connections:
		var conn := connection as Dictionary
		var selected := not _selected_edge.is_empty() and _same_connection_slots(
			conn,
			String(_selected_edge.get("from_node", "")),
			int(_selected_edge.get("from_port", -1)),
			String(_selected_edge.get("to_node", "")),
			int(_selected_edge.get("to_port", -1))
		)
		_set_connection_selected(conn, selected)


func _set_connection_selected(connection: Dictionary, selected: bool) -> void:
	var from_node := String(connection.get("from_node", ""))
	var to_node := String(connection.get("to_node", ""))
	if from_node == "" or to_node == "":
		return
	set_connection_activity(from_node, int(connection.get("from_port", -1)), to_node, int(connection.get("to_port", -1)), 1.0 if selected else 0.0)


func _connection_result(ok: bool, reason: String, port_type: String = "", adaptation: String = "") -> Dictionary:
	return {
		"ok": ok,
		"reason": reason,
		"port_type": port_type,
		"adaptation": adaptation,
	}


func _first_error_message(report: Dictionary) -> String:
	var errors = report.get("errors", []) as Array
	if errors.is_empty():
		return "Graph could not run."
	var error = errors[0] as Dictionary
	return String(error.get("message", "Graph could not run."))


func _first_error_node_id(report: Dictionary) -> String:
	var errors = report.get("errors", []) as Array
	if errors.is_empty():
		return ""
	var error = errors[0] as Dictionary
	return String(error.get("node", ""))


func _set_failure_highlight(node_id: String, message: String) -> void:
	_clear_failure_highlight()
	_last_failure_node_id = node_id
	_last_failure_message = message
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return
	graph_node.modulate = Color(1.0, 0.72, 0.72, 1.0)
	graph_node.tooltip_text = message
	graph_node.set_meta("hex_generation_failure_highlighted", true)


func _clear_failure_highlight() -> void:
	if _last_failure_node_id != "":
		var graph_node := _graph_node(_last_failure_node_id)
		if graph_node != null:
			graph_node.modulate = Color.WHITE
			graph_node.tooltip_text = ""
			graph_node.set_meta("hex_generation_failure_highlighted", false)
	_last_failure_node_id = ""
	_last_failure_message = ""


func _failure_node_highlighted() -> bool:
	var graph_node := _graph_node(_last_failure_node_id)
	if graph_node == null:
		return false
	return bool(graph_node.get_meta("hex_generation_failure_highlighted", false))


func _clear_progress_highlight() -> void:
	if _active_progress_node_id != "":
		var graph_node := _graph_node(_active_progress_node_id)
		if graph_node != null and bool(graph_node.get_meta("hex_generation_progress_highlighted", false)):
			graph_node.modulate = Color.WHITE
			graph_node.set_meta("hex_generation_progress_highlighted", false)
	_active_progress_node_id = ""


func _progress_node_highlighted() -> bool:
	var graph_node := _graph_node(_active_progress_node_id)
	if graph_node == null:
		return false
	return bool(graph_node.get_meta("hex_generation_progress_highlighted", false))


func _progress_snapshot_from_context(context: Dictionary) -> Dictionary:
	var options = context.get("interrupt_options", {})
	if not options is Dictionary:
		return {}
	var progress_options = options as Dictionary
	return {
		"phase": String(progress_options.get("phase", "")),
		"node_id": String(progress_options.get("node_id", progress_options.get("node", ""))),
		"progress": float(progress_options.get("progress", 0.0)),
		"cancelled": bool(progress_options.get("cancelled", false)),
	}


func _update_last_preview_for_selected_node() -> void:
	var output = selected_output()
	if output is HexMapDataScript:
		_last_preview_snapshot = HexMapPreviewThumbnailScript.preview_from_map_data(output, {"source_context": _selected_node_id})
	elif output is HexOverlayDataScript:
		_last_preview_snapshot = HexMapPreviewThumbnailScript.preview_from_overlay_data(output, {"source_context": _selected_node_id})
	elif output is Array:
		var selection: Array = output
		var overlay = HexOverlayDataScript.from_item_cells(selection, "selection", selection)
		_last_preview_snapshot = HexMapPreviewThumbnailScript.preview_from_overlay_data(overlay, {"source_context": _selected_node_id})
	else:
		_last_preview_snapshot = HexMapPreviewThumbnailScript.unavailable_preview("not_run", {"source_context": _selected_node_id})


func build_default_vertical_slice_chain() -> PackedStringArray:
	clear_graph()
	var shape := add_graph_node(HexGenerationNodeTypesScript.NODE_SHAPE, Vector2(30, 120), "shape")
	var walls := add_graph_node(HexGenerationNodeTypesScript.NODE_WALL_FIELD, Vector2(230, 120), "walls")
	var connect := add_graph_node(HexGenerationNodeTypesScript.NODE_CONNECTIVITY, Vector2(430, 120), "connectivity")
	var filter := add_graph_node(HexGenerationNodeTypesScript.NODE_TERRAIN_FILTER, Vector2(650, 120), "spawn_floor_filter")
	var items := add_graph_node(HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR, Vector2(890, 120), "weighted_items")
	var result := add_graph_node(HexGenerationNodeTypesScript.NODE_RESULT, Vector2(1150, 120), "result")
	request_connection(shape, 0, walls, 0)
	request_connection(walls, 0, connect, 0)
	request_connection(connect, 0, filter, 0)
	request_connection(filter, 0, items, 0)
	request_connection(connect, 0, result, 0)
	request_connection(items, 0, result, 1)
	select_graph_node(result)
	return PackedStringArray([shape, walls, connect, filter, items, result])


func _port_color_snapshot() -> Dictionary:
	return {
		"untyped": UNTYPED_PORT_COLOR.to_html(false),
	}


func _adaptation_rows_snapshot() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for node_id in _node_order:
		for input_name in _input_names_for_node(String(node_id)):
			if not _uses_adaptation_control(String(node_id), String(input_name)):
				continue
			var edge := _connection_for_input_name(String(node_id), String(input_name))
			rows.append({
				"node_id": String(node_id),
				"input": String(input_name),
				"connected": not edge.is_empty(),
				"adaptation": String(edge.get("adaptation", "")),
				"display": _adaptation_display_text(String(edge.get("adaptation", "")), not edge.is_empty()),
				"control_present": _find_adaptation_option(String(node_id), String(input_name)) != null,
			})
	return rows


func _node_titlebars_snapshot() -> Dictionary:
	var result := {}
	for node_id in _node_order:
		var node := node_dictionary(String(node_id))
		if node.is_empty():
			continue
		var params := node.get("params", {}) as Dictionary
		var display_name_edit := _find_titlebar_display_name_edit(String(node_id))
		result[String(node_id)] = {
			"title": _title_for_node(String(node.get("type", "")), params),
			"display_name": String(params.get("display_name", "")),
			"display_name_field_min_width": display_name_edit.custom_minimum_size.x if display_name_edit != null else 0.0,
			"display_name_field_expands": display_name_edit != null and bool(display_name_edit.size_flags_horizontal & Control.SIZE_EXPAND),
			"criteria_chips": HexGenerationCriteriaUiScript.chip_states(String(node.get("type", "")), params),
		}
	return result


func _result_rows_snapshot() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for node_id in _node_order:
		if _node_type_for_id(String(node_id)) != HexGenerationNodeTypesScript.NODE_RESULT:
			continue
		for input_name in _input_names_for_node(String(node_id)):
			rows.append(_result_row_data(String(node_id), String(input_name)))
	return rows


func _find_adaptation_option(node_id: String, input_name: String) -> OptionButton:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return null
	return graph_node.find_child("Adaptation %s %s" % [node_id, input_name], true, false) as OptionButton


func _find_titlebar_display_name_edit(node_id: String) -> LineEdit:
	var graph_node := _graph_node(node_id)
	if graph_node == null:
		return null
	return graph_node.find_child("HexTitlebarDisplayName_%s" % node_id, true, false) as LineEdit


func _mark_dirty_all() -> void:
	_graph_revision += 1
	_dirty_node_ids = _node_order.duplicate()


func _mark_dirty_from_node(node_id: String) -> void:
	if node_id == "":
		_mark_dirty_all()
		return
	_graph_revision += 1
	var dirty := _dirty_node_set()
	dirty[node_id] = true
	for downstream_id in _downstream_node_ids(node_id):
		dirty[String(downstream_id)] = true
	_dirty_node_ids = _sorted_node_ids(dirty.keys())


func _dirty_node_set() -> Dictionary:
	var result := {}
	for node_id in _dirty_node_ids:
		result[String(node_id)] = true
	return result


func _downstream_node_ids(node_id: String) -> PackedStringArray:
	var result := PackedStringArray()
	var visited := {}
	var queue: Array[String] = [node_id]
	while not queue.is_empty():
		var current := queue.pop_front()
		for connection in _connections:
			if String(connection.get("from_node", "")) != current:
				continue
			var next_node := String(connection.get("to_node", ""))
			if next_node == "" or visited.has(next_node):
				continue
			visited[next_node] = true
			result.append(next_node)
			queue.append(next_node)
	return result


func _cache_node_ids(cache: Dictionary) -> PackedStringArray:
	return _sorted_node_ids(cache.keys())


func _sorted_node_ids(values: Array) -> PackedStringArray:
	var result: Array[String] = []
	for value in values:
		var text := String(value)
		if text != "":
			result.append(text)
	result.sort()
	return PackedStringArray(result)
