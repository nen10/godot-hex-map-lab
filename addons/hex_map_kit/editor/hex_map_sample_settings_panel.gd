@tool
class_name HexMapSampleSettingsPanel
extends VBoxContainer

const HexMapEditorSessionState = preload("res://addons/hex_map_kit/editor/hex_map_editor_session_state.gd")
const HexMapSampleAssetDuplicator = preload("res://addons/hex_map_kit/editor/hex_map_sample_asset_duplicator.gd")
const HexMapWorkspaceAssetContext = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")

signal sample_settings_changed(snapshot: Dictionary)
signal open_sample_requested(sample_id: String, path: String)
signal duplicate_sample_requested(sample_id: String, path: String)

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
var _asset_rows: Array[Dictionary] = []


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


func sample_asset_rows() -> Array[Dictionary]:
	return [
		_sample_row(SAMPLE_CATALOG_ID, "Bundled Sample Catalog", SAMPLE_CATALOG_PATH, true),
		_sample_row(SAMPLE_TILE_SET_ID, "Bundled Sample TileSet", SAMPLE_TILE_TEXTURE_PATH),
		_sample_row(SAMPLE_OBJECT_SCENE_ID, "Bundled Sample Object Scene", SAMPLE_OBJECT_SCENE_PATH),
	]


func duplicate_dialog_config() -> Dictionary:
	return HexMapSampleAssetDuplicator.duplicate_dialog_config()


func duplicate_sample_catalog_to_project(
	catalog_path: String,
	context: HexMapWorkspaceAssetContext = null
) -> Dictionary:
	var target_context = context
	if target_context == null and _editor_session_state != null:
		target_context = _editor_session_state.current_workspace_asset_context()
	return HexMapSampleAssetDuplicator.duplicate_sample_catalog_to_project(catalog_path, target_context)


func snapshot() -> Dictionary:
	return {
		"show_bundled_samples_in_main_selectors": _show_bundled_samples_in_main_selectors(),
		"use_bundled_sample_assets_for_scratch_documents": _use_bundled_sample_assets_for_scratch_documents(),
		"auto_create_project_copy_when_applying_sample": _auto_create_project_copy_when_applying_sample(),
		"sample_assets": sample_asset_rows(),
	}


func _build_ui() -> void:
	if _show_samples_check != null:
		return
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	_show_samples_check = CheckBox.new()
	_show_samples_check.text = "Show bundled samples in asset selectors"
	_show_samples_check.toggled.connect(_on_show_samples_toggled)
	add_child(_show_samples_check)

	_scratch_samples_check = CheckBox.new()
	_scratch_samples_check.text = "Use bundled sample assets for scratch documents"
	_scratch_samples_check.toggled.connect(_on_scratch_samples_toggled)
	add_child(_scratch_samples_check)

	_copy_samples_check = CheckBox.new()
	_copy_samples_check.text = "Create project copies when applying samples"
	_copy_samples_check.toggled.connect(_on_copy_samples_toggled)
	add_child(_copy_samples_check)

	for row in sample_asset_rows():
		var row_control = HBoxContainer.new()
		row_control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var label = Label.new()
		label.text = "%s: %s" % [String(row["label"]), String(row["path"])]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row_control.add_child(label)

		var open_button = Button.new()
		open_button.text = "Open"
		open_button.pressed.connect(_on_open_sample_pressed.bind(String(row["id"]), String(row["path"])))
		row_control.add_child(open_button)

		var duplicate_button = Button.new()
		duplicate_button.text = "Duplicate To Project"
		duplicate_button.disabled = not bool(row.get("duplicate_available", false))
		duplicate_button.pressed.connect(_on_duplicate_sample_pressed.bind(String(row["id"]), String(row["path"])))
		row_control.add_child(duplicate_button)
		add_child(row_control)
		_asset_rows.append({
			"id": row["id"],
			"control": row_control,
			"open_button": open_button,
			"duplicate_button": duplicate_button,
		})


func _refresh() -> void:
	if _show_samples_check == null:
		return
	_show_samples_check.set_pressed_no_signal(_show_bundled_samples_in_main_selectors())
	_scratch_samples_check.set_pressed_no_signal(_use_bundled_sample_assets_for_scratch_documents())
	_copy_samples_check.set_pressed_no_signal(_auto_create_project_copy_when_applying_sample())
	sample_settings_changed.emit(snapshot())


func _show_bundled_samples_in_main_selectors() -> bool:
	return _editor_session_state != null and _editor_session_state.show_bundled_samples_in_main_selectors


func _use_bundled_sample_assets_for_scratch_documents() -> bool:
	return _editor_session_state != null and _editor_session_state.use_bundled_sample_assets_for_scratch_documents


func _auto_create_project_copy_when_applying_sample() -> bool:
	return _editor_session_state != null and _editor_session_state.auto_create_project_copy_when_applying_sample


func _sample_row(sample_id: String, label: String, path: String, duplicate_available: bool = false) -> Dictionary:
	return {
		"id": sample_id,
		"label": label,
		"path": path,
		"duplicate_available": duplicate_available,
	}


func _on_show_samples_toggled(enabled: bool) -> void:
	set_show_bundled_samples_in_main_selectors(enabled)


func _on_scratch_samples_toggled(enabled: bool) -> void:
	set_use_bundled_sample_assets_for_scratch_documents(enabled)


func _on_copy_samples_toggled(enabled: bool) -> void:
	set_auto_create_project_copy_when_applying_sample(enabled)


func _on_open_sample_pressed(sample_id: String, path: String) -> void:
	open_sample_requested.emit(sample_id, path)


func _on_duplicate_sample_pressed(sample_id: String, path: String) -> void:
	duplicate_sample_requested.emit(sample_id, path)


func _on_session_changed(key: String) -> void:
	if key.begins_with("sample_settings."):
		_refresh()
