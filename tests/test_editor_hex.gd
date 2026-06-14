extends "res://tests/test_editor_plugin_test_base.gd"

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	await _test_hex_cell_button_layout_direction_cells_flat_top()
	await _test_hex_cell_button_layout_direction_cells_pointy_top()
	await _test_hex_cell_button_layout_minimum_size_uses_padding()
	await _test_hex_cell_button_layout_polygon_hit_rejects_rect_corner()
	await _test_hex_cell_button_layout_shape_cells_custom_ring_disc()
	await _test_hex_cell_button_panel_emits_pressed_for_hex_hit()
	await _test_hex_cell_button_panel_emits_hover_for_hex_hit()
	await _test_hex_cell_button_panel_accepts_label_display_state()
	await _test_hex_cell_button_panel_does_not_press_disabled_cell()
	await _test_hex_cell_button_panel_focus_navigation()
	_finish("res://tests/test_editor_hex.gd")

func _test_hex_cell_button_layout_direction_cells_flat_top() -> void:
	var radius := 12.0
	var gap := 1.5
	var entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"flat_top": true,
		"cell_radius": radius,
		"cell_gap": gap,
		"padding": Vector2(2, 2),
	})
	var by_id = _entries_by_id(entries)
	var origin: Vector2 = by_id[HexVector.zero().key()]["center"]
	_assert_eq(entries.size(), 7, "direction layout includes center and six neighbor cells")
	for direction in HexVector.directions():
		var actual: Vector2 = by_id[direction.key()]["center"] - origin
		var expected = HexMapTileAdapter.hex_to_local(direction, radius + gap, true)
		_assert_vec2_approx(actual, expected, "flat-top direction cell uses tile adapter pitch")


func _test_hex_cell_button_layout_direction_cells_pointy_top() -> void:
	var radius := 12.0
	var gap := 1.5
	var flat_entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"flat_top": true,
		"cell_radius": radius,
		"cell_gap": gap,
		"padding": Vector2(2, 2),
	})
	var pointy_entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"flat_top": false,
		"cell_radius": radius,
		"cell_gap": gap,
		"padding": Vector2(2, 2),
	})
	var direction = HexVector.q_axis()
	var flat_by_id = _entries_by_id(flat_entries)
	var pointy_by_id = _entries_by_id(pointy_entries)
	var flat_delta: Vector2 = flat_by_id[direction.key()]["center"] - flat_by_id[HexVector.zero().key()]["center"]
	var pointy_delta: Vector2 = pointy_by_id[direction.key()]["center"] - pointy_by_id[HexVector.zero().key()]["center"]
	_assert_vec2_approx(
		pointy_delta,
		HexMapTileAdapter.hex_to_local(direction, radius + gap, false),
		"pointy-top direction cell uses tile adapter pitch"
	)
	_assert_true(not pointy_delta.is_equal_approx(flat_delta), "pointy-top layout differs from flat-top layout")


func _test_hex_cell_button_layout_minimum_size_uses_padding() -> void:
	var tight_padding := Vector2(2, 2)
	var wide_padding := Vector2(10, 10)
	var tight_entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_CUSTOM,
		"shape_cells": [HexVector.zero()],
		"cell_radius": 12.0,
		"padding": tight_padding,
	})
	var wide_entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_CUSTOM,
		"shape_cells": [HexVector.zero()],
		"cell_radius": 12.0,
		"padding": wide_padding,
	})
	var tight_size = HexCellButtonLayout.minimum_size(tight_entries, tight_padding)
	var wide_size = HexCellButtonLayout.minimum_size(wide_entries, wide_padding)
	_assert_true(wide_size.x > tight_size.x and wide_size.y > tight_size.y, "layout minimum size grows with padding")


func _test_hex_cell_button_layout_polygon_hit_rejects_rect_corner() -> void:
	var entries = HexCellButtonLayout.build_entries({
		"shape_kind": HexCellButtonLayout.SHAPE_CUSTOM,
		"shape_cells": [HexVector.zero()],
		"cell_radius": 12.0,
		"padding": Vector2(2, 2),
	})
	var entry: Dictionary = entries[0]
	var rect_corner = entry["bounds"].position + Vector2(0.2, 0.2)
	_assert_true(entry["bounds"].has_point(rect_corner), "hex rect corner fixture is inside entry bounds")
	_assert_true(HexCellButtonLayout.hit_entry(entries, rect_corner).is_empty(), "hex hit test rejects bounds corner outside polygon")
	_assert_eq(HexCellButtonLayout.hit_entry(entries, entry["center"])["id"], entry["id"], "hex hit test accepts polygon center")


func _test_hex_cell_button_layout_shape_cells_custom_ring_disc() -> void:
	var custom = [HexVector.zero(), HexVector.q_axis()]
	var custom_cells = HexCellButtonLayout.shape_cells(HexCellButtonLayout.SHAPE_CUSTOM, {"shape_cells": custom})
	_assert_keys_eq(custom_cells, custom, "custom shape returns the requested cell set")
	custom.clear()
	_assert_eq(custom_cells.size(), 2, "custom shape returns a duplicate cell array")
	_assert_eq(
		HexCellButtonLayout.shape_cells(HexCellButtonLayout.SHAPE_RING, {"radius": 1}).size(),
		6,
		"ring shape hook returns radius-1 ring cells"
	)
	_assert_eq(
		HexCellButtonLayout.shape_cells(HexCellButtonLayout.SHAPE_DISC, {"radius": 1}).size(),
		7,
		"disc shape hook returns radius-1 disc cells"
	)


func _test_hex_cell_button_panel_emits_pressed_for_hex_hit() -> void:
	var panel = HexCellButtonPanel.new()
	panel.configure({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"pressable_cells": _direction_pressable_cells(),
		"cell_radius": 12.0,
	})
	var recorder = CellPressRecorder.new()
	panel.cell_pressed.connect(Callable(recorder, "record"))
	root.add_child(panel)
	await process_frame

	var entry: Dictionary = _entries_by_id(panel.get_entries())[HexVector.q_axis().key()]
	_send_panel_click(panel, entry["center"])
	_assert_eq(recorder.entries.size(), 1, "hex cell panel emits pressed for hex polygon hit")
	_assert_eq(recorder.entries[0]["id"], HexVector.q_axis().key(), "hex cell panel emits the hit cell entry")

	panel.queue_free()
	await process_frame


func _test_hex_cell_button_panel_emits_hover_for_hex_hit() -> void:
	var panel = HexCellButtonPanel.new()
	panel.configure({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"pressable_cells": _direction_pressable_cells(),
		"cell_radius": 12.0,
	})
	var recorder = CellPressRecorder.new()
	panel.cell_hovered.connect(Callable(recorder, "record"))
	root.add_child(panel)
	await process_frame

	var entry: Dictionary = _entries_by_id(panel.get_entries())[HexVector.q_axis().key()]
	_send_panel_motion(panel, entry["center"])
	_assert_eq(recorder.entries.size(), 1, "hex cell panel emits hover for hex polygon hit")
	_assert_eq(recorder.entries[0]["id"], HexVector.q_axis().key(), "hex cell panel hover emits the hit cell entry")

	panel.queue_free()
	await process_frame


func _test_hex_cell_button_panel_accepts_label_display_state() -> void:
	var labels := {HexVector.zero().key(): "0,0,0"}
	var panel = HexCellButtonPanel.new()
	panel.configure({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"label_by_cell": labels,
		"show_labels": true,
		"cell_radius": 12.0,
	})
	root.add_child(panel)
	await process_frame

	var center_entry: Dictionary = _entries_by_id(panel.get_entries())[HexVector.zero().key()]
	_assert_true(panel.show_labels, "hex cell panel keeps label display enabled")
	_assert_eq(center_entry["label"], "0,0,0", "hex cell panel keeps label text in layout entry")

	panel.queue_free()
	await process_frame


func _test_hex_cell_button_panel_does_not_press_disabled_cell() -> void:
	var disabled := {}
	disabled[HexVector.q_axis().key()] = true
	var panel = HexCellButtonPanel.new()
	panel.configure({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"pressable_cells": _direction_pressable_cells(),
		"disabled_cells": disabled,
		"cell_radius": 12.0,
	})
	var recorder = CellPressRecorder.new()
	panel.cell_pressed.connect(Callable(recorder, "record"))
	root.add_child(panel)
	await process_frame

	var entry: Dictionary = _entries_by_id(panel.get_entries())[HexVector.q_axis().key()]
	_send_panel_click(panel, entry["center"])
	_assert_eq(recorder.entries.size(), 0, "hex cell panel ignores disabled cell press")

	panel.queue_free()
	await process_frame


func _test_hex_cell_button_panel_focus_navigation() -> void:
	var panel = HexCellButtonPanel.new()
	panel.configure({
		"shape_kind": HexCellButtonLayout.SHAPE_DIRECTIONS,
		"pressable_cells": _direction_pressable_cells(),
		"cell_radius": 12.0,
	})
	var focus_recorder = CellPressRecorder.new()
	var press_recorder = CellPressRecorder.new()
	panel.cell_focus_changed.connect(Callable(focus_recorder, "record"))
	panel.cell_pressed.connect(Callable(press_recorder, "record"))
	root.add_child(panel)
	await process_frame

	_send_panel_key(panel, KEY_RIGHT)
	_send_panel_key(panel, KEY_SPACE)
	_assert_eq(focus_recorder.entries.size(), 1, "hex cell panel emits focus change for keyboard navigation")
	_assert_eq(press_recorder.entries.size(), 1, "hex cell panel emits pressed for focused keyboard cell")
	_assert_eq(press_recorder.entries[0]["id"], HexVector.directions()[0].key(), "keyboard press uses the focused cell")

	panel.queue_free()
	await process_frame


