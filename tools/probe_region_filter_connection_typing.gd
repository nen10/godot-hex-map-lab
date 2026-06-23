extends SceneTree
const Canvas = preload("res://addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd")
const NT = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const Ports = preload("res://addons/hex_map_kit/generation/hex_generation_ports.gd")
func _init(): _run.call_deferred()
func _run():
	var c = Canvas.new(); root.add_child(c); await process_frame
	var items = c.add_graph_node(NT.NODE_ITEM_GENERATOR, Vector2(0,0), "items")
	var filt = c.add_graph_node(NT.NODE_REGION_FILTER, Vector2(300,0), "filter")
	await process_frame
	# slot type ids
	var items_node := c.get_node(NodePath(items))
	var filt_node := c.get_node(NodePath(filt))
	var item_out_type: int = (items_node.get_output_port_type(0) if items_node.get_output_port_count()>0 else -999)
	var filt_in_type: int = (filt_node.get_input_port_type(0) if filt_node.get_input_port_count()>0 else -999)
	# logical validation (request_connection path)
	var logical = c.validate_connection(items, 0, filt, 0)
	# GraphEdit drag-level type check
	var ge_allows := c.is_valid_connection_type(item_out_type, filt_in_type)
	# NOTE: GraphEdit.is_valid_connection_type returns true ONLY for explicitly added
	# pairs. By default no pairs are added, so the editor falls back to its implicit
	# rule: a drag connection is accepted only when the two port type ids are equal.
	# Therefore the decisive editor signal is whether the type ids match.
	var port_type_ids_match := item_out_type == filt_in_type
	print(JSON.stringify({
		"item_generator_output_type_id": item_out_type,
		"region_filter_input_type_id": filt_in_type,
		"SLOT_TERRAIN": Canvas.SLOT_TYPES[Ports.TERRAIN],
		"SLOT_OVERLAY": Canvas.SLOT_TYPES[Ports.OVERLAY],
		"logical_validate_ok": logical.get("ok"),
		"logical_reason": logical.get("reason"),
		"port_type_ids_match_editor_connectable": port_type_ids_match,
		"is_valid_connection_type_added_pair_only": ge_allows,
		"region_filter_accepts": NT.input_definition(NT.NODE_REGION_FILTER, "in").get("accepts"),
	}, "  "))
	quit()
