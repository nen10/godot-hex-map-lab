@tool
class_name HexMapSampleSettingsPanel
extends VBoxContainer

const HexMapEditorSessionState = preload("res://addons/hex_map_kit/editor/hex_map_editor_session_state.gd")
const HexMapEditorPathSelector = preload("res://addons/hex_map_kit/editor/hex_map_editor_path_selector.gd")
const HexMapSampleAssetDuplicator = preload("res://addons/hex_map_kit/editor/hex_map_sample_asset_duplicator.gd")
const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")
const HexMapSampleLearningState = preload("res://addons/hex_map_kit/editor/hex_map_sample_learning_state.gd")

signal sample_settings_changed(snapshot: Dictionary)

const ACTION_DUPLICATE_TO_PROJECT := "duplicate_to_project"

const GROUP_SAMPLE_LEARNING := "sample_learning"
const GROUP_DEBUG := "debug"

const TOGGLE_SHOW_SAMPLES := "show_bundled_samples_in_main_selectors"
const TOGGLE_SCRATCH_SAMPLES := "use_bundled_sample_assets_for_scratch_documents"
const TOGGLE_COPY_SAMPLES := "auto_create_project_copy_when_applying_sample"
const TOGGLE_DEBUG_NUMERIC_FALLBACK := "debug_numeric_tile_fallback_enabled"

const SAMPLE_CATALOG_ID := "sample_catalog"
const SAMPLE_TILE_SET_ID := "sample_tile_set"
const SAMPLE_OBJECT_SCENE_ID := "sample_object_scene"

const SAMPLE_CATALOG_PATH := HexMapSampleAssetDuplicator.SAMPLE_CATALOG_PATH
const SAMPLE_TILE_TEXTURE_PATH := HexMapSampleAssetDuplicator.SAMPLE_TILE_TEXTURE_PATH
const SAMPLE_OBJECT_SCENE_PATH := HexMapSampleAssetDuplicator.SAMPLE_OBJECT_SCENE_PATH

var _editor_session_state: HexMapEditorSessionState = null
var _show_samples_check: CheckBox
var _scratch_samples_check: CheckBox
var _copy_samples_check: CheckBox
var _debug_numeric_fallback_check: CheckBox
var _sample_status_label: Label
var _asset_rows: Array[Dictionary] = []
var _last_sample_action_result: Dictionary = {}


func _ready() -> void:
	_build_ui()
	_refresh()


func set_editor_session_state(session: HexMapEditorSessionState) -> void:
	if _editor_session_state != null and _editor_session_state.changed.is_connected(_on_session_changed):
		_editor_session_state.changed.disconnect(_on_session_changed)
	_editor_session_state = session
	if _editor_session_state != null and not _editor_session_state.changed.is_connected(_on_session_changed):
		_editor_session_state.changed.connect(_on_session_changed)
	_refresh()


func editor_session_state() -> HexMapEditorSessionState:
	return _editor_session_state


func set_show_bundled_samples_in_main_selectors(enabled: bool) -> void:
	if _editor_session_state != null:
		_editor_session_state.set_show_bundled_samples_in_main_selectors(enabled, "sample_settings.show_samples")
	_refresh()


func set_use_bundled_sample_assets_for_scratch_documents(enabled: bool) -> void:
	if _editor_session_state != null:
		_editor_session_state.set_use_bundled_sample_assets_for_scratch_documents(enabled, "sample_settings.scratch_samples")
	_refresh()


func set_auto_create_project_copy_when_applying_sample(enabled: bool) -> void:
	if _editor_session_state != null:
		_editor_session_state.set_auto_create_project_copy_when_applying_sample(enabled, "sample_settings.copy_samples")
	_refresh()


func set_debug_numeric_tile_fallback_enabled(enabled: bool) -> void:
	if _editor_session_state != null:
		_editor_session_state.set_debug_numeric_tile_fallback_enabled(enabled, "debug_settings.numeric_tile_fallback")
	_refresh()


func sample_asset_rows() -> Array[Dictionary]:
	return [
		_sample_row(SAMPLE_CATALOG_ID, "Bundled Sample Catalog", SAMPLE_CATALOG_PATH, true),
		_sample_row(SAMPLE_TILE_SET_ID, "Bundled Sample TileSet", SAMPLE_TILE_TEXTURE_PATH),
		_sample_row(SAMPLE_OBJECT_SCENE_ID, "Bundled Sample Object Scene", SAMPLE_OBJECT_SCENE_PATH),
	]


func duplicate_dialog_config() -> Dictionary:
	return HexMapSampleAssetDuplicator.duplicate_dialog_config()


func duplicate_sample_dialog(sample_id: String = SAMPLE_CATALOG_ID) -> EditorFileDialog:
	if not _sample_supports_duplicate(sample_id):
		return null
	var config := duplicate_dialog_config()
	var dialog := HexMapEditorPathSelector.new_dialog(
		int(config.get("file_mode", EditorFileDialog.FILE_MODE_SAVE_FILE)),
		config.get("filters", [])
	)
	if dialog == null:
		return null
	dialog.current_file = String(config.get("current_file", HexMapSampleAssetDuplicator.default_catalog_file_name()))
	dialog.file_selected.connect(_on_duplicate_file_selected.bind(sample_id))
	return dialog


func popup_duplicate_sample_dialog(sample_id: String = SAMPLE_CATALOG_ID) -> bool:
	var dialog := duplicate_sample_dialog(sample_id)
	if dialog == null:
		return false
	return HexMapEditorPathSelector.popup_dialog(dialog)


func select_duplicate_path(path: String, sample_id: String = SAMPLE_CATALOG_ID) -> Dictionary:
	return press_sample_action(sample_id, ACTION_DUPLICATE_TO_PROJECT, {"path": path})


func press_sample_action(sample_id: String, action_id: String, options: Dictionary = {}) -> Dictionary:
	var before := snapshot()
	var result := {
		"ok": false,
		"error": ERR_INVALID_PARAMETER,
		"sample_id": sample_id,
		"action_id": action_id,
		"before": before,
		"after": before,
	}
	match action_id:
		ACTION_DUPLICATE_TO_PROJECT:
			if not _sample_supports_duplicate(sample_id):
				result["error"] = ERR_UNAVAILABLE
				return result
			var path := String(options.get("path", ""))
			if path == "":
				var dialog_opened := popup_duplicate_sample_dialog(sample_id)
				result["ok"] = dialog_opened
				result["error"] = OK if dialog_opened else ERR_UNAVAILABLE
				result["dialog_opened"] = dialog_opened
				result["after"] = snapshot()
				return result
			return _duplicate_sample_to_project(sample_id, path, before)
		_:
			return result


func duplicate_sample_catalog_to_project(
	catalog_path: String,
	context: HexMapWorkspaceAssetContext = null
) -> Dictionary:
	var target_context = context
	if target_context == null and _editor_session_state != null:
		target_context = _editor_session_state.current_workspace_asset_context()
	return HexMapSampleAssetDuplicator.duplicate_sample_catalog_to_project(catalog_path, target_context)


func snapshot() -> Dictionary:
	var sample_state := sample_state_snapshot()
	return {
		"show_bundled_samples_in_main_selectors": _show_bundled_samples_in_main_selectors(),
		"use_bundled_sample_assets_for_scratch_documents": _use_bundled_sample_assets_for_scratch_documents(),
		"auto_create_project_copy_when_applying_sample": _auto_create_project_copy_when_applying_sample(),
		"debug_numeric_tile_fallback_enabled": _debug_numeric_tile_fallback_enabled(),
		"sample_assets": sample_asset_rows(),
		"sample_asset_count": sample_asset_rows().size(),
		"sample_action_rows": sample_action_rows_snapshot(),
		"settings_groups": settings_group_snapshot(),
		"settings_group_ids": PackedStringArray([GROUP_SAMPLE_LEARNING, GROUP_DEBUG]),
		"sample_learning_toggle_ids": PackedStringArray([TOGGLE_SHOW_SAMPLES, TOGGLE_SCRATCH_SAMPLES, TOGGLE_COPY_SAMPLES]),
		"debug_toggle_ids": PackedStringArray([TOGGLE_DEBUG_NUMERIC_FALLBACK]),
		"boolean_controls": boolean_controls_snapshot(),
		"boolean_controls_have_tooltips": _boolean_controls_have_tooltips(),
		"last_sample_action": _last_sample_action_result.duplicate(),
		"sample_status_text": _sample_status_text(),
		"sample_status_tooltip": _sample_status_tooltip(),
		"sample_status_path_visible": false,
		"sample_asset_paths_visible": false,
		"boolean_state_text_visible": false,
		"sample_state": sample_state,
		"sample_view_state": sample_state.get("view_state", {}),
	}


func settings_group_snapshot() -> Array[Dictionary]:
	return [
		{
			"id": GROUP_SAMPLE_LEARNING,
			"title": "Sample Learning",
			"component_id": "sample_settings_panel",
			"toggle_ids": PackedStringArray([TOGGLE_SHOW_SAMPLES, TOGGLE_SCRATCH_SAMPLES, TOGGLE_COPY_SAMPLES]),
			"sample_asset_count": sample_asset_rows().size(),
			"separated": true,
		},
		{
			"id": GROUP_DEBUG,
			"title": "Debug",
			"component_id": "sample_settings_panel",
			"toggle_ids": PackedStringArray([TOGGLE_DEBUG_NUMERIC_FALLBACK]),
			"sample_asset_count": 0,
			"separated": true,
		},
	]


func boolean_controls_snapshot() -> Array[Dictionary]:
	return [
		_boolean_control_snapshot(TOGGLE_SHOW_SAMPLES, GROUP_SAMPLE_LEARNING, _show_samples_check),
		_boolean_control_snapshot(TOGGLE_SCRATCH_SAMPLES, GROUP_SAMPLE_LEARNING, _scratch_samples_check),
		_boolean_control_snapshot(TOGGLE_COPY_SAMPLES, GROUP_SAMPLE_LEARNING, _copy_samples_check),
		_boolean_control_snapshot(TOGGLE_DEBUG_NUMERIC_FALLBACK, GROUP_DEBUG, _debug_numeric_fallback_check),
	]


func sample_state_snapshot(sample_source_selected_slots: PackedStringArray = PackedStringArray()) -> Dictionary:
	var state := HexMapSampleLearningState.new()
	state.update_from_context({
		"show_samples": _show_bundled_samples_in_main_selectors(),
		"last_sample_action": _last_sample_action_result,
		"sample_source_selected_slots": sample_source_selected_slots,
	})
	return state.to_state_snapshot()


func _build_ui() -> void:
	if _show_samples_check != null:
		return
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	var sample_group := _settings_group_container("Sample Learning", GROUP_SAMPLE_LEARNING)
	add_child(sample_group)

	_show_samples_check = CheckBox.new()
	_show_samples_check.text = "Show bundled samples in asset selectors"
	_show_samples_check.tooltip_text = "Shows bundled samples as learning candidates; they remain opt-in and not production defaults."
	_show_samples_check.toggled.connect(_on_show_samples_toggled)
	sample_group.add_child(_show_samples_check)

	_scratch_samples_check = CheckBox.new()
	_scratch_samples_check.text = "Use bundled sample assets for scratch documents"
	_scratch_samples_check.tooltip_text = "Allows scratch documents to start from bundled learning assets only."
	_scratch_samples_check.toggled.connect(_on_scratch_samples_toggled)
	sample_group.add_child(_scratch_samples_check)

	_copy_samples_check = CheckBox.new()
	_copy_samples_check.text = "Create project copies when applying samples"
	_copy_samples_check.tooltip_text = "Duplicates sample assets to the project before use in production flows."
	_copy_samples_check.toggled.connect(_on_copy_samples_toggled)
	sample_group.add_child(_copy_samples_check)

	var debug_group := _settings_group_container("Debug", GROUP_DEBUG)
	add_child(debug_group)

	_debug_numeric_fallback_check = CheckBox.new()
	_debug_numeric_fallback_check.text = "Enable numeric tile fallback for debug"
	_debug_numeric_fallback_check.tooltip_text = "Enables numeric tile fallback only for explicit debug inspection."
	_debug_numeric_fallback_check.toggled.connect(_on_debug_numeric_fallback_toggled)
	debug_group.add_child(_debug_numeric_fallback_check)

	_sample_status_label = Label.new()
	_sample_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sample_status_label.visible = false
	sample_group.add_child(_sample_status_label)

	for row in sample_asset_rows():
		var row_control = HBoxContainer.new()
		row_control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var label = Label.new()
		label.text = String(row["label"])
		label.tooltip_text = String(row["path"])
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row_control.add_child(label)

		var row_snapshot := {
			"id": row["id"],
			"control": row_control,
			"label": label,
		}
		if bool(row.get("duplicate_available", false)):
			var duplicate_button = Button.new()
			duplicate_button.text = "Duplicate To Project"
			duplicate_button.pressed.connect(_on_duplicate_sample_pressed.bind(String(row["id"])))
			row_control.add_child(duplicate_button)
			row_snapshot["duplicate_button"] = duplicate_button

		sample_group.add_child(row_control)
		_asset_rows.append(row_snapshot)


func _refresh() -> void:
	if _show_samples_check == null:
		return
	_show_samples_check.set_pressed_no_signal(_show_bundled_samples_in_main_selectors())
	_scratch_samples_check.set_pressed_no_signal(_use_bundled_sample_assets_for_scratch_documents())
	_copy_samples_check.set_pressed_no_signal(_auto_create_project_copy_when_applying_sample())
	_debug_numeric_fallback_check.set_pressed_no_signal(_debug_numeric_tile_fallback_enabled())
	if _sample_status_label != null:
		_sample_status_label.text = _sample_status_text()
		_sample_status_label.tooltip_text = _sample_status_tooltip()
		_sample_status_label.visible = _sample_status_label.text != ""
	sample_settings_changed.emit(snapshot())


func _show_bundled_samples_in_main_selectors() -> bool:
	return _editor_session_state != null and _editor_session_state.show_bundled_samples_in_main_selectors


func _use_bundled_sample_assets_for_scratch_documents() -> bool:
	return _editor_session_state != null and _editor_session_state.use_bundled_sample_assets_for_scratch_documents


func _auto_create_project_copy_when_applying_sample() -> bool:
	return _editor_session_state != null and _editor_session_state.auto_create_project_copy_when_applying_sample


func _debug_numeric_tile_fallback_enabled() -> bool:
	return _editor_session_state != null and _editor_session_state.debug_numeric_tile_fallback_enabled


func _sample_row(sample_id: String, label: String, path: String, duplicate_available: bool = false) -> Dictionary:
	return {
		"id": sample_id,
		"label": label,
		"path": path,
		"duplicate_available": duplicate_available,
	}


func sample_action_rows_snapshot() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row in _asset_rows:
		var action_texts := PackedStringArray()
		var duplicate_button = row.get("duplicate_button", null) as Button
		if duplicate_button != null and duplicate_button.visible:
			action_texts.append(duplicate_button.text)
		var label = row.get("label", null) as Label
		result.append({
			"id": String(row.get("id", "")),
			"visible_label_text": label.text if label != null else "",
			"label_tooltip": label.tooltip_text if label != null else "",
			"path_visible": false,
			"action_button_texts": action_texts,
		})
	return result


func _settings_group_container(title: String, group_id: String) -> VBoxContainer:
	var group := VBoxContainer.new()
	group.name = "%s Settings Group" % title
	group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	group.set_meta("hex_settings_group_id", group_id)
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 13)
	group.add_child(label)
	return group


func _boolean_control_snapshot(control_id: String, group_id: String, control: CheckBox) -> Dictionary:
	return {
		"id": control_id,
		"group_id": group_id,
		"control_type": "CheckBox",
		"checked": control.button_pressed if control != null else false,
		"label": control.text if control != null else "",
		"tooltip": control.tooltip_text if control != null else "",
		"has_tooltip": control != null and control.tooltip_text != "",
	}


func _boolean_controls_have_tooltips() -> bool:
	for row in boolean_controls_snapshot():
		if not row is Dictionary:
			return false
		if not bool((row as Dictionary).get("has_tooltip", false)):
			return false
	return true


func _sample_supports_duplicate(sample_id: String) -> bool:
	return sample_id == SAMPLE_CATALOG_ID


func _duplicate_sample_to_project(sample_id: String, path: String, before: Dictionary = {}) -> Dictionary:
	var result := duplicate_sample_catalog_to_project(path)
	result["sample_id"] = sample_id
	result["action_id"] = ACTION_DUPLICATE_TO_PROJECT
	result["slot_id"] = HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG
	result["path"] = String(result.get("catalog_path", ""))
	result["resource"] = result.get("catalog", null)
	result["before"] = before if not before.is_empty() else snapshot()
	_last_sample_action_result = _sample_action_result_summary(result)
	_refresh()
	result["after"] = snapshot()
	return result


func _sample_action_result_summary(result: Dictionary) -> Dictionary:
	return {
		"ok": bool(result.get("ok", false)),
		"error": int(result.get("error", ERR_INVALID_PARAMETER)),
		"sample_id": String(result.get("sample_id", "")),
		"action_id": String(result.get("action_id", "")),
		"slot_id": String(result.get("slot_id", "")),
		"catalog_path": String(result.get("catalog_path", "")),
		"texture_path": String(result.get("texture_path", "")),
		"scene_path": String(result.get("scene_path", "")),
		"resource": result.get("resource", null),
	}


func _sample_status_text() -> String:
	if _last_sample_action_result.is_empty():
		return ""
	if not bool(_last_sample_action_result.get("ok", false)):
		return "Sample duplicate failed."
	return "Catalog slot updated from bundled sample."


func _sample_status_tooltip() -> String:
	if _last_sample_action_result.is_empty():
		return ""
	if not bool(_last_sample_action_result.get("ok", false)):
		return "Sample duplicate failed."
	var path := String(_last_sample_action_result.get("catalog_path", ""))
	return "Project Catalog: %s" % path if path != "" else ""


func _on_show_samples_toggled(enabled: bool) -> void:
	set_show_bundled_samples_in_main_selectors(enabled)


func _on_scratch_samples_toggled(enabled: bool) -> void:
	set_use_bundled_sample_assets_for_scratch_documents(enabled)


func _on_copy_samples_toggled(enabled: bool) -> void:
	set_auto_create_project_copy_when_applying_sample(enabled)


func _on_debug_numeric_fallback_toggled(enabled: bool) -> void:
	set_debug_numeric_tile_fallback_enabled(enabled)


func _on_duplicate_sample_pressed(sample_id: String) -> void:
	press_sample_action(sample_id, ACTION_DUPLICATE_TO_PROJECT)


func _on_duplicate_file_selected(path: String, sample_id: String) -> void:
	select_duplicate_path(path, sample_id)


func _on_session_changed(key: String) -> void:
	if key.begins_with("sample_settings.") or key.begins_with("debug_settings."):
		_refresh()
