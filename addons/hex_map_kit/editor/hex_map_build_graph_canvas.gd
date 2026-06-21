@tool
class_name HexMapBuildGraphCanvas
extends GraphEdit

signal graph_changed
signal selected_graph_node_changed(node_id: String)
signal graph_run_completed(report: Dictionary)

const HexGenerationGraphScript = preload("res://addons/hex_map_kit/generation/hex_generation_graph.gd")
const HexGenerationGraphRunnerScript = preload("res://addons/hex_map_kit/generation/hex_generation_graph_runner.gd")
const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const HexGenerationPortsScript = preload("res://addons/hex_map_kit/generation/hex_generation_ports.gd")
const HexMapPreviewThumbnailScript = preload("res://addons/hex_map_kit/editor/hex_map_preview_thumbnail.gd")
const HexMapDataScript = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexOverlayDataScript = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")

const NODE_TYPE_ORDER := [
	HexGenerationNodeTypesScript.NODE_SOURCE,
	HexGenerationNodeTypesScript.NODE_SHAPE,
	HexGenerationNodeTypesScript.NODE_WALL_FIELD,
	HexGenerationNodeTypesScript.NODE_CONNECTIVITY,
	HexGenerationNodeTypesScript.NODE_REGION_FILTER,
	HexGenerationNodeTypesScript.NODE_SET_OPERATION,
	HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR,
	HexGenerationNodeTypesScript.NODE_COMPOSE,
	HexGenerationNodeTypesScript.NODE_RESULT,
]

const SLOT_TYPES := {
	HexGenerationPortsScript.TERRAIN: 1,
	HexGenerationPortsScript.SELECTION: 2,
	HexGenerationPortsScript.OVERLAY: 3,
	HexGenerationPortsScript.RESULT: 4,
}

const SLOT_COLORS := {
	HexGenerationPortsScript.TERRAIN: Color(0.38, 0.62, 0.82),
	HexGenerationPortsScript.SELECTION: Color(0.94, 0.72, 0.32),
	HexGenerationPortsScript.OVERLAY: Color(0.66, 0.48, 0.78),
	HexGenerationPortsScript.RESULT: Color(0.46, 0.78, 0.58),
}

const NODE_TITLES := {
	HexGenerationNodeTypesScript.NODE_SOURCE: "Source",
	HexGenerationNodeTypesScript.NODE_SHAPE: "Shape",
	HexGenerationNodeTypesScript.NODE_WALL_FIELD: "Wall Field",
	HexGenerationNodeTypesScript.NODE_CONNECTIVITY: "Connectivity",
	HexGenerationNodeTypesScript.NODE_REGION_FILTER: "Region Filter",
	HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR: "Item Generator",
	HexGenerationNodeTypesScript.NODE_COMPOSE: "Compose",
	HexGenerationNodeTypesScript.NODE_SET_OPERATION: "Set Operation",
	HexGenerationNodeTypesScript.NODE_RESULT: "Result",
}

var _node_counter := 0
var _node_order: PackedStringArray = PackedStringArray()
var _connections: Array[Dictionary] = []
var _selected_node_id := ""
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


func _ready() -> void:
	name = "Build Graph Canvas"
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(520, 340)
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
			if _selected_node_id != "":
				if _remove_graph_node(_selected_node_id):
					select_graph_node("")
					graph_changed.emit()
			accept_event()
			return


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
	for i in range(_connections.size() - 1, -1, -1):
		var conn := _connections[i] as Dictionary
		if String(conn.get("from_node", "")) == node_id or String(conn.get("to_node", "")) == node_id:
			disconnect_node(
				String(conn.get("from_node", "")),
				int(conn.get("from_port", -1)),
				String(conn.get("to_node", "")),
				int(conn.get("to_port", -1))
			)
			_connections.remove_at(i)
	remove_child(graph_node)
	graph_node.queue_free()
	var new_order: PackedStringArray = PackedStringArray()
	for nid in _node_order:
		if String(nid) != node_id:
			new_order.append(String(nid))
	_node_order = new_order
	_last_status = "Removed node %s." % node_id
	_mark_dirty_all()
	return true


func add_graph_node(node_type: String, position: Vector2 = Vector2.ZERO, node_id: String = "") -> String:
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

	var graph_node := GraphNode.new()
	graph_node.name = actual_id
	graph_node.title = title_for_node_type(node_type)
	graph_node.position_offset = position
	graph_node.custom_minimum_size = Vector2(180, 112)
	graph_node.set_meta("hex_generation_node_id", actual_id)
	graph_node.set_meta("hex_generation_node_type", node_type)
	graph_node.set_meta("hex_generation_params", default_params_for_type(node_type))
	graph_node.set_meta("hex_generation_resource_refs", {})

	var input_names := _input_names_for_type(node_type)
	var output_type := _output_type_for_node_meta(node_type, graph_node.get_meta("hex_generation_params", {}))
	var row_count = max(input_names.size(), 1 if output_type != "" else 0)
	graph_node.set_meta("hex_generation_input_slots", {})
	graph_node.set_meta("hex_generation_output_slots", {})
	for row_index in range(row_count):
		var input_name := String(input_names[row_index]) if row_index < input_names.size() else ""
		var label := Label.new()
		label.text = _slot_row_text(input_name, output_type if row_index == 0 else "")
		label.clip_text = true
		graph_node.add_child(label)
		var has_left := input_name != ""
		var left_type := _input_slot_type_id(node_type, input_name)
		var left_color := _color_for_accepts(node_type, input_name)
		var has_right := row_index == 0 and output_type != ""
		var right_type := _slot_type_id(output_type)
		var right_color := _color_for_port_type(output_type)
		graph_node.set_slot(row_index, has_left, left_type, left_color, has_right, right_type, right_color)
		if has_left:
			var input_slots: Dictionary = graph_node.get_meta("hex_generation_input_slots", {})
			input_slots[row_index] = input_name
			graph_node.set_meta("hex_generation_input_slots", input_slots)
		if has_right:
			var output_slots: Dictionary = graph_node.get_meta("hex_generation_output_slots", {})
			output_slots[row_index] = HexGenerationNodeTypesScript.PORT_OUT
			graph_node.set_meta("hex_generation_output_slots", output_slots)

	add_child(graph_node)
	_node_order.append(actual_id)
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
	_last_run_report = {}
	_last_preview_snapshot = HexMapPreviewThumbnailScript.unavailable_preview("empty_graph")
	_last_status = "Graph cleared."
	_last_cache_node_ids = PackedStringArray()
	_last_run_cache = {}
	_last_successful_run_revision = -1
	_clear_failure_highlight()
	_last_cancelled_node_id = ""
	_last_progress_snapshot = {}
	_mark_dirty_all()
	graph_changed.emit()
	selected_graph_node_changed.emit("")


func request_connection(from_node: String, from_port: int, to_node: String, to_port: int) -> Dictionary:
	var validation := validate_connection(from_node, from_port, to_node, to_port)
	if not bool(validation.get("ok", false)):
		_last_rejected_connection = validation.duplicate(true)
		_last_status = String(validation.get("reason", "Connection rejected."))
		graph_changed.emit()
		return validation
	if _has_connection(from_node, from_port, to_node, to_port):
		return validation
	connect_node(from_node, from_port, to_node, to_port)
	_connections.append({
		"from_node": from_node,
		"from_port": from_port,
		"to_node": to_node,
		"to_port": to_port,
		"from_port_name": HexGenerationNodeTypesScript.PORT_OUT,
		"to_port_name": _input_name_for_slot(to_node, to_port),
		"port_type": validation.get("port_type", ""),
	})
	_last_status = "Connected %s to %s.%s." % [
		from_node,
		to_node,
		_input_name_for_slot(to_node, to_port),
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
	var from_node_dict := node_dictionary(from_node)
	var output_type := HexGenerationNodeTypesScript.output_type_for_node(from_node_dict)
	var to_node_type := String(to_graph_node.get_meta("hex_generation_node_type", ""))
	var input_def := HexGenerationNodeTypesScript.input_definition(to_node_type, to_port_name)
	if input_def.is_empty():
		return _connection_result(false, "Unknown input port %s." % to_port_name)
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
	_selected_node_id = node_id
	_update_last_preview_for_selected_node()
	selected_graph_node_changed.emit(_selected_node_id)


func selected_node_id() -> String:
	return _selected_node_id


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
		HexGenerationGraphScript.add_edge(
			graph,
			String(connection.get("from_node", "")),
			String(connection.get("to_node", "")),
			String(connection.get("to_port_name", "")),
			String(connection.get("from_port_name", HexGenerationNodeTypesScript.PORT_OUT))
		)
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
		var restored_id := add_graph_node(node_type, Vector2(40 + index * 210, 120), node_id)
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
		var to_slot := _slot_for_input_name(to_node, String(edge.get("to_port", "")))
		if from_slot < 0 or to_slot < 0:
			continue
		var connection := request_connection(from_node, from_slot, to_node, to_slot)
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
	var run_context := context.duplicate(true)
	run_context["previous_cache"] = _last_run_cache.duplicate(true)
	run_context["dirty_node_ids"] = _dirty_node_ids.duplicate()
	var report = HexGenerationGraphRunnerScript.run_with_report(build_graph_model(), run_context)
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
	_update_last_preview_for_selected_node()
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
		"selected_output_type": selected_output_type(),
		"preview": selected_preview_snapshot(),
		"preview_available": bool(_last_preview_snapshot.get("available", false)),
		"status_text": _last_status,
		"last_rejected_connection": _last_rejected_connection.duplicate(true),
		"dominant_surface": true,
		"port_type_colors": _port_color_snapshot(),
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
	}


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


static func default_params_for_type(node_type: String) -> Dictionary:
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
				"toric": false,
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
		HexGenerationNodeTypesScript.NODE_REGION_FILTER:
			return {
				"filter_target": "floor",
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
	disconnect_node(from_node, from_port, to_node, to_port)
	_last_status = "Disconnected graph ports."
	_mark_dirty_from_node(String(to_node))
	graph_changed.emit()


func _graph_node(node_id: String) -> GraphNode:
	if node_id == "":
		return null
	return get_node_or_null(NodePath(node_id)) as GraphNode


func _input_names_for_type(node_type: String) -> Array:
	var result: Array = []
	for port_name in HexGenerationNodeTypesScript.input_definitions(node_type).keys():
		result.append(String(port_name))
	result.sort()
	return result


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


func _input_slot_type_id(node_type: String, input_name: String) -> int:
	var input_def := HexGenerationNodeTypesScript.input_definition(node_type, input_name)
	var accepts := HexGenerationPortsScript.normalize_accepts(input_def.get("accepts", []))
	return _slot_type_id(String(accepts[0])) if not accepts.is_empty() else 0


func _slot_type_id(port_type: String) -> int:
	return int(SLOT_TYPES.get(port_type, 0))


func _color_for_accepts(node_type: String, input_name: String) -> Color:
	var input_def := HexGenerationNodeTypesScript.input_definition(node_type, input_name)
	var accepts := HexGenerationPortsScript.normalize_accepts(input_def.get("accepts", []))
	return _color_for_port_type(String(accepts[0])) if not accepts.is_empty() else Color(0.5, 0.5, 0.5)


func _color_for_port_type(port_type: String) -> Color:
	return SLOT_COLORS.get(port_type, Color(0.5, 0.5, 0.5))


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


func _has_connection(from_node: String, from_port: int, to_node: String, to_port: int) -> bool:
	for connection in _connections:
		if String(connection.get("from_node", "")) == from_node \
				and int(connection.get("from_port", -1)) == from_port \
				and String(connection.get("to_node", "")) == to_node \
				and int(connection.get("to_port", -1)) == to_port:
			return true
	return false


func _connection_result(ok: bool, reason: String, port_type: String = "") -> Dictionary:
	return {
		"ok": ok,
		"reason": reason,
		"port_type": port_type,
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
	var filter := add_graph_node(HexGenerationNodeTypesScript.NODE_REGION_FILTER, Vector2(650, 120), "spawn_floor_filter")
	var items := add_graph_node(HexGenerationNodeTypesScript.NODE_ITEM_GENERATOR, Vector2(890, 120), "weighted_items")
	var result := add_graph_node(HexGenerationNodeTypesScript.NODE_RESULT, Vector2(1150, 120), "result")
	request_connection(shape, 0, walls, 0)
	request_connection(walls, 0, connect, 0)
	request_connection(connect, 0, filter, 0)
	request_connection(filter, 0, items, 0)
	request_connection(connect, 0, result, 1)
	request_connection(items, 0, result, 0)
	select_graph_node(result)
	return PackedStringArray([shape, walls, connect, filter, items, result])


func _port_color_snapshot() -> Dictionary:
	return {
		HexGenerationPortsScript.TERRAIN: _color_for_port_type(HexGenerationPortsScript.TERRAIN).to_html(false),
		HexGenerationPortsScript.SELECTION: _color_for_port_type(HexGenerationPortsScript.SELECTION).to_html(false),
		HexGenerationPortsScript.OVERLAY: _color_for_port_type(HexGenerationPortsScript.OVERLAY).to_html(false),
		HexGenerationPortsScript.RESULT: _color_for_port_type(HexGenerationPortsScript.RESULT).to_html(false),
	}


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
