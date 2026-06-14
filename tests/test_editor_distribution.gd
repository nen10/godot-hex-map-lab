extends "res://tests/test_editor_plugin_test_base.gd"

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	await _test_distribution_editor_loads_default_preset_values()
	await _test_distribution_editor_loads_resource_values_and_colors_cells()
	await _test_distribution_editor_uses_hex_cell_layout_for_patterns()
	await _test_distribution_editor_pattern_redraw_uses_layout_entries()
	await _test_distribution_editor_close_button_uses_cancel_flow()
	await _test_distribution_editor_file_dialogs_use_lifecycle_helper_contract()
	await _test_distribution_editor_manages_recent_custom_and_duplicate_preset()
	await _test_adjacency_rule_editor_applies_rule_text()
	_finish("res://tests/test_editor_distribution.gd")

func _test_distribution_editor_loads_default_preset_values() -> void:
	var editor = HexDistEditor.new()
	root.add_child(editor)
	await process_frame

	var expected = HexDistribution.from_preset_id(
		HexRandomizer.get_preset_id(HexRandomizer.get_preset_names()[0])
	)
	_assert_eq(_spin_values(editor._d3_spins), expected.distribution_3, "distribution editor shows preset 3-neighbor values")
	_assert_eq(_spin_values(editor._d2_spins), expected.distribution_2, "distribution editor shows preset 2-neighbor values")
	_assert_eq(_spin_values(editor._d1_spins), expected.distribution_1, "distribution editor shows preset 1-neighbor values")
	_assert_eq(editor._pattern_controls.size(), 14, "distribution editor tracks every pattern control")

	editor.queue_free()
	await process_frame


func _test_distribution_editor_loads_resource_values_and_colors_cells() -> void:
	var path = _test_resource_path("test_hex_distribution_editor.tres")
	var custom = HexDistribution.new(
		[0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0],
		[0.5, 2.5, 4.5, 6.5],
		[1.5, 7.5]
	)
	_save_distribution(path, custom)

	var editor = HexDistEditor.new(path)
	root.add_child(editor)
	await process_frame

	_assert_eq(_spin_values(editor._d3_spins), custom.distribution_3, "distribution editor loads custom 3-neighbor values")
	_assert_eq(_spin_values(editor._d2_spins), custom.distribution_2, "distribution editor loads custom 2-neighbor values")
	_assert_eq(_spin_values(editor._d1_spins), custom.distribution_1, "distribution editor loads custom 1-neighbor values")
	_assert_eq(editor._editing_path, path, "distribution editor keeps the loaded resource path")
	_assert_true(not editor._save_button.disabled, "distribution editor enables apply for loaded resources")

	editor._d3_spins[0].value = 8.0
	editor._on_spin_changed(8.0, 3, 0)
	_assert_color_approx(
		editor._center_color(3, 0),
		Color(0.1, 0.1, 0.1),
		"distribution editor center color follows spin value"
	)

	editor.queue_free()
	await process_frame


func _test_distribution_editor_uses_hex_cell_layout_for_patterns() -> void:
	var editor = HexDistEditor.new()
	var origin := Vector2(70, 36)
	var entries = editor._distribution_pattern_entries(3, origin)
	var center_entry := {}
	var refs := {}
	for entry in entries:
		var metadata: Dictionary = entry["metadata"]
		if bool(metadata.get("center", false)):
			center_entry = entry
		else:
			refs[int(metadata["ref_index"])] = entry

	var hex_size := 16.0
	var expected_refs = [
		origin + Vector2(-hex_size * 1.5, -hex_size * sqrt(3.0) / 2.0),
		origin + Vector2(0, -hex_size * sqrt(3.0)),
		origin + Vector2(hex_size * 1.5, -hex_size * sqrt(3.0) / 2.0),
	]
	_assert_eq(entries.size(), 4, "distribution 3-neighbor pattern uses center and three reference entries")
	_assert_true(not center_entry.is_empty(), "distribution pattern marks the center entry")
	_assert_vec2_approx(center_entry["center"], origin, "distribution pattern keeps the existing center position")
	for index in range(expected_refs.size()):
		_assert_vec2_approx(refs[index]["center"], expected_refs[index], "distribution pattern keeps the existing reference position")

	editor.free()


func _test_distribution_editor_pattern_redraw_uses_layout_entries() -> void:
	var editor = HexDistEditor.new()
	root.add_child(editor)
	await process_frame

	var control = editor._pattern_controls[0]
	var entries = editor._distribution_pattern_entries(3)
	_assert_eq(entries.size(), 4, "distribution redraw test uses layout-backed entries")
	_assert_true(
		control.draw.is_connected(Callable(editor, "_draw_pattern").bind(3, 0, control)),
		"distribution pattern control draws through the layout-backed draw method"
	)
	editor._on_spin_changed(1.0, 3, 0)

	editor.queue_free()
	await process_frame


func _test_distribution_editor_close_button_uses_cancel_flow() -> void:
	var state := {"count": 0}
	var editor = HexDistEditor.new("", Callable(), Callable(self, "_count_cancel").bind(state))
	root.add_child(editor)
	await process_frame

	editor.emit_signal("close_requested")
	await process_frame

	_assert_eq(state["count"], 1, "distribution editor window close calls cancel callback")


func _test_distribution_editor_file_dialogs_use_lifecycle_helper_contract() -> void:
	var editor = HexDistEditor.new()
	root.add_child(editor)
	await process_frame

	var save_config := editor.save_new_dialog_config()
	_assert_true(bool(save_config.get("uses_file_dialog", false)), "distribution Save New uses FileDialog contract")
	_assert_eq(int(save_config["file_mode"]), EditorFileDialog.FILE_MODE_SAVE_FILE, "distribution Save New dialog uses Save File mode")
	_assert_eq(String(save_config["current_file"]), "hex_dist.tres", "distribution Save New dialog uses default .tres file name")
	_assert_true(PackedStringArray(save_config["filters"]).has("*.tres ; Hex Distribution"), "distribution Save New dialog filters Hex Distribution resources")

	var load_config := editor.load_dialog_config()
	_assert_true(bool(load_config.get("uses_file_dialog", false)), "distribution Load uses FileDialog contract")
	_assert_eq(int(load_config["file_mode"]), EditorFileDialog.FILE_MODE_OPEN_FILE, "distribution Load dialog uses Open File mode")
	_assert_true(PackedStringArray(load_config["filters"]).has("*.tres ; Hex Distribution"), "distribution Load dialog filters Hex Distribution resources")

	_assert_eq(editor.save_new_dialog(), null, "distribution Save New dialog is not instantiated outside editor popup context")
	_assert_eq(editor.load_dialog(), null, "distribution Load dialog is not instantiated outside editor popup context")
	editor.queue_free()
	await process_frame


func _test_distribution_editor_manages_recent_custom_and_duplicate_preset() -> void:
	HexDistEditor.clear_recent_distributions()
	var path = _test_resource_path("test_hex_distribution_duplicate.tres")

	var editor = HexDistEditor.new()
	root.add_child(editor)
	await process_frame

	var expected = HexDistribution.from_preset_id(
		HexRandomizer.get_preset_id(HexRandomizer.get_preset_names()[0])
	)
	_assert_true(editor._duplicate_preset_button != null, "distribution editor exposes duplicate preset button")
	_assert_eq(editor._duplicate_preset_button.text, "Duplicate Preset...", "distribution editor labels duplicate preset flow")
	_assert_true(editor.save_current_distribution_as(path), "distribution editor saves current preset as custom distribution")
	_assert_eq(HexDistEditor.recent_distribution_paths(), [path], "distribution editor remembers saved custom distribution")
	_assert_eq(editor._editing_path, path, "distribution editor switches to saved custom distribution")
	var saved = load(path)
	_assert_true(saved is HexDistribution, "duplicate preset save creates HexDistribution resource")
	_assert_eq(saved.distribution_3, expected.distribution_3, "duplicate preset save keeps preset 3-neighbor values")
	_assert_eq(saved.distribution_2, expected.distribution_2, "duplicate preset save keeps preset 2-neighbor values")
	_assert_eq(saved.distribution_1, expected.distribution_1, "duplicate preset save keeps preset 1-neighbor values")

	editor.queue_free()
	await process_frame

	var recent_editor = HexDistEditor.new()
	root.add_child(recent_editor)
	await process_frame
	_assert_eq(recent_editor._recent_option.item_count, 1, "distribution editor lists recent custom distributions")
	_assert_eq(recent_editor._recent_option.get_item_text(0), path, "distribution editor shows recent custom path")
	recent_editor._on_recent_selected(0)
	_assert_eq(recent_editor._editing_path, path, "distribution editor loads custom distribution from recent list")
	_assert_eq(_spin_values(recent_editor._d3_spins), expected.distribution_3, "recent custom load restores saved values")

	recent_editor.queue_free()
	await process_frame


func _test_adjacency_rule_editor_applies_rule_text() -> void:
	var state := {"rules": "", "count": 0}
	var editor = HexAdjacencyRuleEditor.new(
		"default=0.2",
		Callable(self, "_capture_rules").bind(state),
		Callable(self, "_count_cancel").bind(state)
	)
	root.add_child(editor)
	await process_frame

	_assert_eq(editor._rules_edit.text, "default=0.2", "adjacency rule editor loads initial rule text")
	_assert_eq(editor._rules_status_label.text, "Rules: 1", "adjacency rule editor shows initial valid rule count")
	editor._rules_edit.text = "1=0.8;default=0.1"
	editor._on_rules_text_changed(editor._rules_edit.text)
	_assert_eq(editor._rules_status_label.text, "Rules: 2", "adjacency rule editor updates valid rule count")
	editor._rules_edit.text = "1=0.8;bad=x"
	editor._on_rules_text_changed(editor._rules_edit.text)
	_assert_true(editor._rules_status_label.text.contains("Invalid: bad=x"), "adjacency rule editor reports invalid entry")
	_assert_true(not editor._rules_status_label.text.contains("fallback default"), "adjacency rule editor does not show fallback status")
	editor._on_apply_pressed()
	await process_frame

	_assert_eq(state["rules"], "1=0.8;bad=x", "adjacency rule editor apply returns rule text")
	_assert_eq(state["count"], 0, "adjacency rule editor apply does not call cancel")


