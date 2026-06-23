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
	print(JSON.stringify({
		"item_generator_output_type_id": item_out_type,
		"region_filter_input_type_id": filt_in_type,
		"SLOT_TERRAIN": Canvas.SLOT_TYPES[Ports.TERRAIN],
		"SLOT_OVERLAY": Canvas.SLOT_TYPES[Ports.OVERLAY],
		"logical_validate_ok": logical.get("ok"),
		"logical_reason": logical.get("reason"),
		"graphedit_drag_allows_overlay_to_filter": ge_allows,
		"region_filter_accepts": NT.input_definition(NT.NODE_REGION_FILTER, "in").get("accepts"),
	}, "  "))
	quit()
