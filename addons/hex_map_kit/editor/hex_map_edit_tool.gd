@tool
class_name HexMapEditTool
extends Control

const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")

const TARGET_AUTO_INDEX := 0
const TARGET_LAYER_INDEX_OFFSET := 1
const TARGET_AUTO_LABEL := "Auto: Selected / first scene layer"

enum EditMode {
	SHAPE,
	WALL_FLOOR,
	FLOOR_TILE,
	WALL_TILE,
	OBJECT,
	LABEL,
}

const EDIT_MODE_NAMES := [
	"Shape",
	"Wall / Floor",
	"Floor Tile",
	"Wall Tile",
	"Object",
	"Label",
]

@export var hex_size: float = 24.0
@export var debug_viewport_input: bool = false

var _document: HexMapDocumentResource
var _document_path := ""
var _import_map_path := ""
var _export_path := ""
var _target_layer: Node
var _target_layer_nodes: Array[Node] = []
var _target_layer_scan_root: Node = null
var _undo_redo = null
var _object_database: Resource
var _label_database: Resource
var _edit_mode := EditMode.WALL_FLOOR
var _tile_payload := {
	"source_id": 0,
	"atlas_coords": Vector2i.ZERO,
	"alternative_tile": 0,
}
var _object_payload := {
	"object_id": "",
	"properties": {},
}
var _label_payload := {
	"label_id": "",
	"text": "",
}
var _last_edit_hit: Dictionary = {}
var _last_edit_status: Dictionary = {}
var _target_status_detail: Dictionary = {}
var _last_persistence_status: Dictionary = {}
var _pending_viewport_trace: Dictionary = {}
var _last_highlight_hex = null
var _last_applied_to_target := false
var _target_selection_sync_request_count := 0
var _last_selection_sync_target: Node = null
var _test_viewport_canvas_transform_enabled := false
var _test_viewport_canvas_transform := Transform2D.IDENTITY

var _document_label: Label
var _document_resource_picker
var _document_path_edit: LineEdit
var _document_load_button: Button
var _document_save_button: Button
var _import_map_path_edit: LineEdit
var _import_map_button: Button
var _export_path_edit: LineEdit
var _export_button: Button
var _target_label: Label
var _target_option: OptionButton
var _target_refresh_button: Button
var _mode_option: OptionButton
var _object_database_picker
var _label_database_picker
var _tile_source_spin: SpinBox
var _tile_atlas_x_spin: SpinBox
var _tile_atlas_y_spin: SpinBox
var _tile_alternative_spin: SpinBox
var _object_id_edit: LineEdit
var _object_properties_edit: LineEdit
var _label_id_edit: LineEdit
var _label_text_edit: LineEdit
var _status_label: Label
var _target_status_label: Label
var _last_edit_detail_label: Label
var _persistence_detail_label: Label


func _ready() -> void:
	name = "Hex Map Edit"
	_build_ui()
	refresh_target_layer_options()
	_refresh_state_labels()


func set_document(document: HexMapDocumentResource) -> void:
	_document = document
	_sync_resource_pickers()
	_refresh_state_labels()


func document() -> HexMapDocumentResource:
	return _document


func import_map_resource(resource: HexMapResource) -> HexMapDocumentResource:
	_document = HexMapDocumentAdapter.from_map_resource(resource)
	_sync_resource_pickers()
	_refresh_state_labels()
	return _document


func import_map_resource_from_path(path: String = "") -> bool:
	var actual_path = path if path != "" else _import_map_path
	if actual_path == "":
		_set_status("Import map path is empty.")
		return false
	var resource = load(actual_path)
	if not resource is HexMapResource:
		_set_status("Path is not a HexMapResource.")
		return false
	import_map_resource(resource)
	set_import_map_path(actual_path)
	_apply_document_to_target()
	if _target_layer != null and is_instance_valid(_target_layer):
		_select_target_in_editor_if_possible()
	_set_status("Imported HexMapResource.")
	return true


func export_map_resource() -> HexMapResource:
	return HexMapDocumentAdapter.to_map_resource(_document)


func set_target_layer(layer: Node) -> void:
	_target_layer = layer
	if _target_option != null:
		_select_target_layer_option(layer)
	_select_target_in_editor_if_possible()
	_refresh_state_labels()


func target_layer() -> Node:
	return _target_layer


func set_undo_redo(undo_redo) -> void:
	_undo_redo = undo_redo


func viewport_input_enabled() -> bool:
	return _document != null \
		and _target_layer != null \
		and is_instance_valid(_target_layer) \
		and _target_layer is CanvasItem


func set_viewport_canvas_transform_for_test(transform: Transform2D) -> void:
	_test_viewport_canvas_transform_enabled = true
	_test_viewport_canvas_transform = transform


func clear_viewport_canvas_transform_for_test() -> void:
	_test_viewport_canvas_transform_enabled = false


func last_edit_status() -> Dictionary:
	return _last_edit_status.duplicate(true)


func target_readiness_status() -> Dictionary:
	_refresh_target_status_detail()
	return _target_status_detail.duplicate(true)


func persistence_status() -> Dictionary:
	return _last_persistence_status.duplicate(true)


func set_object_database(database: Resource) -> void:
	_object_database = database
	_sync_resource_pickers()


func object_database() -> Resource:
	return _object_database


func set_label_database(database: Resource) -> void:
	_label_database = database
	_sync_resource_pickers()


func label_database() -> Resource:
	return _label_database


func set_document_path(path: String) -> void:
	_document_path = path
	if _document_path_edit != null:
		_document_path_edit.text = path


func document_path() -> String:
	return _document_path


func set_import_map_path(path: String) -> void:
	_import_map_path = path
	if _import_map_path_edit != null:
		_import_map_path_edit.text = path


func import_map_path() -> String:
	return _import_map_path


func set_export_path(path: String) -> void:
	_export_path = path
	if _export_path_edit != null:
		_export_path_edit.text = path


func export_path() -> String:
	return _export_path


func load_document(path: String = "") -> bool:
	var actual_path = path if path != "" else _document_path
	if actual_path == "":
		_set_status("Document path is empty.")
		return false
	var resource = load(actual_path)
	if not resource is HexMapDocumentResource:
		_set_status("Path is not a HexMapDocumentResource.")
		return false
	_document = resource
	set_document_path(actual_path)
	_sync_resource_pickers()
	_apply_document_to_target()
	_refresh_state_labels()
	_set_status("Loaded document.")
	return true


func save_document(path: String = "") -> bool:
	if _document == null:
		_set_persistence_status("save_document", path, false, ERR_DOES_NOT_EXIST, "HexMapDocumentResource")
		_set_status("No document selected.")
		return false
	var actual_path = path if path != "" else _document_path
	if actual_path == "":
		_set_persistence_status("save_document", actual_path, false, ERR_INVALID_PARAMETER, "HexMapDocumentResource")
		_set_status("Document path is empty.")
		return false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(actual_path.get_base_dir()))
	var error = ResourceSaver.save(_document, actual_path)
	if error != OK:
		_set_persistence_status("save_document", actual_path, false, error, "HexMapDocumentResource")
		_set_status("Failed to save document: %d" % error)
		return false
	set_document_path(actual_path)
	_set_persistence_status("save_document", actual_path, true, OK, "HexMapDocumentResource")
	_set_status("Saved document.")
	return true


func export_map_resource_to_path(path: String = "") -> bool:
	if _document == null:
		_set_persistence_status("export_map", path, false, ERR_DOES_NOT_EXIST, "HexMapResource")
		_set_status("No document selected.")
		return false
	var actual_path = path if path != "" else _export_path
	if actual_path == "":
		_set_persistence_status("export_map", actual_path, false, ERR_INVALID_PARAMETER, "HexMapResource")
		_set_status("Export path is empty.")
		return false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(actual_path.get_base_dir()))
	var error = ResourceSaver.save(export_map_resource(), actual_path)
	if error != OK:
		_set_persistence_status("export_map", actual_path, false, error, "HexMapResource")
		_set_status("Failed to export map: %d" % error)
		return false
	set_export_path(actual_path)
	_set_persistence_status("export_map", actual_path, true, OK, "HexMapResource")
	_set_status("Exported HexMapResource.")
	return true


func refresh_target_layer_options(root_node: Node = null) -> void:
	if _target_option == null:
		return
	var previous = _target_layer
	var scan_root = root_node
	if scan_root != null:
		_target_layer_scan_root = scan_root
	elif _target_layer_scan_root != null and is_instance_valid(_target_layer_scan_root):
		scan_root = _target_layer_scan_root
	elif Engine.is_editor_hint():
		scan_root = EditorInterface.get_edited_scene_root()
		_target_layer_scan_root = scan_root

	_target_layer_nodes.clear()
	_target_option.clear()
	_target_option.add_item(TARGET_AUTO_LABEL)
	if scan_root != null:
		_collect_target_layers_recursive(scan_root, _target_layer_nodes)
	for node in _target_layer_nodes:
		_target_option.add_item(_target_layer_display_name(node, scan_root))

	var selected_index = TARGET_AUTO_INDEX
	var should_sync_target := false
	if previous != null and is_instance_valid(previous):
		var index = _target_layer_nodes.find(previous)
		if index >= 0:
			selected_index = index + TARGET_LAYER_INDEX_OFFSET
			should_sync_target = true
	_target_option.select(selected_index)
	_target_layer = _resolve_target_layer()
	if should_sync_target and _target_layer != null and is_instance_valid(_target_layer):
		_select_target_in_editor_if_possible()
	_refresh_state_labels()


func set_edit_mode(mode: int) -> void:
	_edit_mode = clampi(mode, 0, EDIT_MODE_NAMES.size() - 1)
	if _mode_option != null:
		_mode_option.select(_edit_mode)
	_refresh_payload_controls_visibility()


func edit_mode() -> int:
	return _edit_mode


func set_tile_payload(source_id: int, atlas_coords: Vector2i, alternative_tile: int = 0) -> void:
	_tile_payload = {
		"source_id": source_id,
		"atlas_coords": atlas_coords,
		"alternative_tile": alternative_tile,
	}
	_sync_payload_controls()


func set_object_payload(object_id: String, properties: Dictionary = {}) -> void:
	_object_payload = {
		"object_id": object_id,
		"properties": properties.duplicate(true),
	}
	_sync_payload_controls()


func set_label_payload(label_id: String, text: String) -> void:
	_label_payload = {
		"label_id": label_id,
		"text": text,
	}
	_sync_payload_controls()


func apply_cell(hex) -> bool:
	return _apply_hit({
		"hex": hex,
		"visual_hex": hex,
		"local": Vector2.ZERO,
		"exists": _document != null and _document.map != null and _document.map.to_map_data().has_cell(hex),
	})


func _apply_hit(hit: Dictionary) -> bool:
	if _document == null:
		_set_status("No document selected.")
		return false
	var before = HexMapDocumentAdapter.duplicate_document(_document)
	var after = HexMapDocumentAdapter.duplicate_document(_document)
	var hex = hit["hex"]
	var visual_hex = hit.get("visual_hex", hex)
	var target_used_cells_before = _target_used_cell_count()
	var display_before = _target_display_state(hex, visual_hex)
	_apply_mode_to_document(after, hex)
	var applied = _commit_document_change(before, after, "Hex map edit %s" % EDIT_MODE_NAMES[_edit_mode])
	var target_used_cells_after = _target_used_cell_count()
	var display_after = _target_display_state(hex, visual_hex)
	_last_edit_hit = hit.duplicate(true)
	_last_edit_status = _build_last_edit_trace(
		hit,
		before,
		after,
		applied,
		target_used_cells_before,
		target_used_cells_after,
		display_before,
		display_after
	)
	if visual_hex.key() != hex.key():
		_set_status("Edited %s via %s" % [hex.key(), visual_hex.key()])
	else:
		_set_status("Edited %s" % hex.key())
	_refresh_last_hit_display()
	_refresh_last_edit_detail()
	return true


func apply_local_position(local_pos: Vector2) -> bool:
	var hit = _local_hit(local_pos)
	if hit.is_empty():
		_set_status("No editable cell.")
		return false
	if _edit_mode != EditMode.SHAPE and not bool(hit.get("exists", false)):
		_set_status("No editable cell.")
		return false
	return _apply_hit(hit)


func forward_canvas_gui_input(event: InputEvent) -> bool:
	if not event is InputEventMouseButton:
		return false
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return false
	var local_pos = _editor_viewport_event_to_target_local(mouse_event)
	if local_pos == null:
		return false
	return apply_local_position(local_pos)


func _build_ui() -> void:
	if _mode_option != null:
		return
	var root = VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(root)

	var title = Label.new()
	title.text = "Hex Map Edit"
	root.add_child(title)

	_document_label = Label.new()
	root.add_child(_document_label)
	if _can_use_editor_resource_picker():
		_document_resource_picker = EditorResourcePicker.new()
		_document_resource_picker.base_type = "HexMapDocumentResource"
		_document_resource_picker.resource_changed.connect(_on_document_resource_changed)
		root.add_child(_wrap_labeled("Resource", _document_resource_picker))
	var document_path_row = HBoxContainer.new()
	_document_path_edit = LineEdit.new()
	_document_path_edit.placeholder_text = "res://path/to/map_document.tres"
	_document_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_document_path_edit.text_changed.connect(_on_document_path_changed)
	document_path_row.add_child(_wrap_labeled("Document", _document_path_edit))
	_document_load_button = Button.new()
	_document_load_button.text = "Load"
	_document_load_button.pressed.connect(_on_load_document_pressed)
	document_path_row.add_child(_document_load_button)
	_document_save_button = Button.new()
	_document_save_button.text = "Save"
	_document_save_button.pressed.connect(_on_save_document_pressed)
	document_path_row.add_child(_document_save_button)
	root.add_child(document_path_row)

	var import_path_row = HBoxContainer.new()
	_import_map_path_edit = LineEdit.new()
	_import_map_path_edit.placeholder_text = "res://path/to/map_resource.tres"
	_import_map_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_import_map_path_edit.text_changed.connect(_on_import_map_path_changed)
	import_path_row.add_child(_wrap_labeled("Import Map", _import_map_path_edit))
	_import_map_button = Button.new()
	_import_map_button.text = "Import"
	_import_map_button.pressed.connect(_on_import_map_pressed)
	import_path_row.add_child(_import_map_button)
	root.add_child(import_path_row)

	var export_path_row = HBoxContainer.new()
	_export_path_edit = LineEdit.new()
	_export_path_edit.placeholder_text = "res://path/to/map_resource.tres"
	_export_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_export_path_edit.text_changed.connect(_on_export_path_changed)
	export_path_row.add_child(_wrap_labeled("Export", _export_path_edit))
	_export_button = Button.new()
	_export_button.text = "Export"
	_export_button.pressed.connect(_on_export_pressed)
	export_path_row.add_child(_export_button)
	root.add_child(export_path_row)

	_target_label = Label.new()
	root.add_child(_target_label)
	var target_row = HBoxContainer.new()
	_target_option = OptionButton.new()
	_target_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_target_option.item_selected.connect(_on_target_selected)
	target_row.add_child(_wrap_labeled("Target", _target_option))
	_target_refresh_button = Button.new()
	_target_refresh_button.text = "Refresh"
	_target_refresh_button.pressed.connect(_on_target_refresh_pressed)
	target_row.add_child(_target_refresh_button)
	root.add_child(target_row)

	_mode_option = OptionButton.new()
	for mode_name in EDIT_MODE_NAMES:
		_mode_option.add_item(mode_name)
	_mode_option.select(_edit_mode)
	_mode_option.item_selected.connect(_on_mode_selected)
	root.add_child(_wrap_labeled("Edit Mode", _mode_option))

	_tile_source_spin = _new_int_spin(0, -1, 4096)
	_tile_source_spin.value_changed.connect(_on_tile_payload_changed)
	root.add_child(_wrap_labeled("Tile Source", _tile_source_spin))
	var atlas_row = HBoxContainer.new()
	_tile_atlas_x_spin = _new_int_spin(0, 0, 4096)
	_tile_atlas_y_spin = _new_int_spin(0, 0, 4096)
	_tile_alternative_spin = _new_int_spin(0, 0, 4096)
	_tile_atlas_x_spin.value_changed.connect(_on_tile_payload_changed)
	_tile_atlas_y_spin.value_changed.connect(_on_tile_payload_changed)
	_tile_alternative_spin.value_changed.connect(_on_tile_payload_changed)
	atlas_row.add_child(_wrap_labeled("Atlas X", _tile_atlas_x_spin))
	atlas_row.add_child(_wrap_labeled("Atlas Y", _tile_atlas_y_spin))
	atlas_row.add_child(_wrap_labeled("Alt", _tile_alternative_spin))
	root.add_child(atlas_row)

	_object_id_edit = LineEdit.new()
	_object_id_edit.placeholder_text = "object_id"
	_object_id_edit.text_changed.connect(_on_object_payload_changed)
	root.add_child(_wrap_labeled("Object", _object_id_edit))
	if _can_use_editor_resource_picker():
		_object_database_picker = EditorResourcePicker.new()
		_object_database_picker.base_type = "HexObjectDatabaseResource"
		_object_database_picker.resource_changed.connect(_on_object_database_changed)
		root.add_child(_wrap_labeled("Object DB", _object_database_picker))
	_object_properties_edit = LineEdit.new()
	_object_properties_edit.placeholder_text = "{\"key\":\"value\"}"
	_object_properties_edit.text_changed.connect(_on_object_payload_changed)
	root.add_child(_wrap_labeled("Properties", _object_properties_edit))

	_label_id_edit = LineEdit.new()
	_label_id_edit.placeholder_text = "label_id"
	_label_id_edit.text_changed.connect(_on_label_payload_changed)
	root.add_child(_wrap_labeled("Label ID", _label_id_edit))
	if _can_use_editor_resource_picker():
		_label_database_picker = EditorResourcePicker.new()
		_label_database_picker.base_type = "HexLabelDatabaseResource"
		_label_database_picker.resource_changed.connect(_on_label_database_changed)
		root.add_child(_wrap_labeled("Label DB", _label_database_picker))

	_label_text_edit = LineEdit.new()
	_label_text_edit.placeholder_text = "label text"
	_label_text_edit.text_changed.connect(_on_label_payload_changed)
	root.add_child(_wrap_labeled("Text", _label_text_edit))

	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_status_label)
	_target_status_label = _new_detail_label()
	root.add_child(_wrap_labeled("Target Status", _target_status_label))
	_last_edit_detail_label = _new_detail_label()
	root.add_child(_wrap_labeled("Last Edit", _last_edit_detail_label))
	_persistence_detail_label = _new_detail_label()
	root.add_child(_wrap_labeled("Save / Export", _persistence_detail_label))
	_refresh_target_status_detail()
	_refresh_last_edit_detail()
	_refresh_persistence_detail()
	_refresh_payload_controls_visibility()


func _apply_mode_to_document(document: HexMapDocumentResource, hex) -> void:
	match _edit_mode:
		EditMode.SHAPE:
			var exists = document.map != null and document.map.to_map_data().has_cell(hex)
			HexMapDocumentAdapter.set_cell_exists(document, hex, not exists)
		EditMode.WALL_FLOOR:
			var is_wall = document.map != null and document.map.to_map_data().has_wall(hex)
			HexMapDocumentAdapter.set_wall(document, hex, not is_wall)
		EditMode.FLOOR_TILE:
			var payload = _tile_payload.duplicate(true)
			payload["kind"] = HexMapDocumentAdapter.KIND_FLOOR
			HexMapDocumentAdapter.set_tile_override(document, hex, payload)
		EditMode.WALL_TILE:
			var payload = _tile_payload.duplicate(true)
			payload["kind"] = HexMapDocumentAdapter.KIND_WALL
			HexMapDocumentAdapter.set_tile_override(document, hex, payload)
		EditMode.OBJECT:
			HexMapDocumentAdapter.set_object(document, hex, _object_payload)
		EditMode.LABEL:
			HexMapDocumentAdapter.set_label(document, hex, _label_payload)


func _commit_document_change(before, after, action_name: String) -> bool:
	_last_applied_to_target = false
	if _undo_redo != null:
		_undo_redo.create_action(action_name)
		_undo_redo.add_do_method(Callable(self, "_replace_document_state").bind(after))
		_undo_redo.add_do_method(Callable(self, "_apply_document_to_target"))
		_undo_redo.add_undo_method(Callable(self, "_replace_document_state").bind(before))
		_undo_redo.add_undo_method(Callable(self, "_apply_document_to_target"))
		_undo_redo.commit_action()
	else:
		_replace_document_state(after)
		_apply_document_to_target()
	return _last_applied_to_target


func _replace_document_state(snapshot) -> void:
	HexMapDocumentAdapter.copy_document_state(_document, snapshot)
	_refresh_state_labels()


func _apply_document_to_target() -> bool:
	if _target_layer == null or _document == null or not is_instance_valid(_target_layer):
		_last_applied_to_target = false
		_refresh_target_status_detail()
		return false
	if _target_layer is HexTileMapLayer:
		(_target_layer as HexTileMapLayer).apply_map(HexMapDocumentAdapter.to_map_resource(_document))
		(_target_layer as HexTileMapLayer).refresh_loop_display()
		_refresh_last_hit_display()
		_last_applied_to_target = true
		_refresh_target_status_detail()
		return true
	HexMapDocumentAdapter.apply_to_tile_map_layer(_document, _target_layer)
	_last_applied_to_target = true
	_refresh_target_status_detail()
	return true


func _local_hit(local_pos: Vector2) -> Dictionary:
	if _target_layer is HexTileMapLayer:
		return (_target_layer as HexTileMapLayer).local_to_cell_hit(local_pos)
	if _target_layer is TileMapLayer:
		var map_cell = (_target_layer as TileMapLayer).local_to_map(local_pos)
		var flat_top = true
		if _document != null and _document.map != null:
			flat_top = _document.map.is_flat_top()
		var tile_hex = HexMapTileAdapter.map_cell_to_vector(map_cell, flat_top)
		return {
			"hex": tile_hex,
			"visual_hex": tile_hex,
			"local": local_pos,
			"exists": _document != null and _document.map != null and _document.map.to_map_data().has_cell(tile_hex),
		}
	var hex = _local_to_hex(local_pos)
	return {
		"hex": hex,
		"visual_hex": hex,
		"local": local_pos,
		"exists": _document != null and _document.map != null and _document.map.to_map_data().has_cell(hex),
	}


func _local_to_hex(local_pos: Vector2):
	var flat_top = true
	if _document != null and _document.map != null:
		flat_top = _document.map.is_flat_top()
	var frac_q: float
	var frac_r: float
	var sqrt3 = sqrt(3.0)
	if flat_top:
		frac_q = (2.0 / 3.0 * local_pos.x) / hex_size
		frac_r = (-1.0 / 3.0 * local_pos.x + sqrt3 / 3.0 * local_pos.y) / hex_size
	else:
		frac_q = (sqrt3 / 3.0 * local_pos.x - 1.0 / 3.0 * local_pos.y) / hex_size
		frac_r = (2.0 / 3.0 * local_pos.y) / hex_size
	return _cube_round(frac_q, frac_r)


func _cube_round(frac_q: float, frac_r: float):
	var frac_s = -frac_q - frac_r
	var rq = roundi(frac_q)
	var rr = roundi(frac_r)
	var rs = roundi(frac_s)
	var q_diff = abs(rq - frac_q)
	var r_diff = abs(rr - frac_r)
	var s_diff = abs(rs - frac_s)
	if q_diff > r_diff and q_diff > s_diff:
		rq = -rr - rs
	elif r_diff > s_diff:
		rr = -rq - rs
	return HexVector.apply_basis(rq + rr, 0, rr)


func _on_mode_selected(index: int) -> void:
	set_edit_mode(index)


func _on_document_path_changed(text: String) -> void:
	_document_path = text.strip_edges()


func _on_import_map_path_changed(text: String) -> void:
	_import_map_path = text.strip_edges()


func _on_document_resource_changed(resource: Resource) -> void:
	if resource is HexMapDocumentResource:
		_document = resource
		_refresh_state_labels()


func _on_object_database_changed(resource: Resource) -> void:
	_object_database = resource


func _on_label_database_changed(resource: Resource) -> void:
	_label_database = resource


func _on_export_path_changed(text: String) -> void:
	_export_path = text.strip_edges()


func _on_load_document_pressed() -> void:
	load_document()


func _on_save_document_pressed() -> void:
	save_document()


func _on_import_map_pressed() -> void:
	import_map_resource_from_path()


func _on_export_pressed() -> void:
	export_map_resource_to_path()


func _on_target_refresh_pressed() -> void:
	refresh_target_layer_options()


func _on_target_selected(index: int) -> void:
	_target_layer = _resolve_target_layer()
	if index != TARGET_AUTO_INDEX:
		_select_target_in_editor_if_possible()
	_refresh_state_labels()


func _on_tile_payload_changed(_value: float) -> void:
	_tile_payload = {
		"source_id": int(_tile_source_spin.value),
		"atlas_coords": Vector2i(int(_tile_atlas_x_spin.value), int(_tile_atlas_y_spin.value)),
		"alternative_tile": int(_tile_alternative_spin.value),
	}


func _on_object_payload_changed(_text: String) -> void:
	_object_payload["object_id"] = _object_id_edit.text
	var parsed = JSON.parse_string(_object_properties_edit.text)
	_object_payload["properties"] = parsed if parsed is Dictionary else {}


func _on_label_payload_changed(_text: String) -> void:
	_label_payload["label_id"] = _label_id_edit.text
	_label_payload["text"] = _label_text_edit.text


func _sync_payload_controls() -> void:
	if _tile_source_spin != null:
		_tile_source_spin.set_value_no_signal(int(_tile_payload.get("source_id", 0)))
		_tile_atlas_x_spin.set_value_no_signal(int(_tile_payload.get("atlas_coords", Vector2i.ZERO).x))
		_tile_atlas_y_spin.set_value_no_signal(int(_tile_payload.get("atlas_coords", Vector2i.ZERO).y))
		_tile_alternative_spin.set_value_no_signal(int(_tile_payload.get("alternative_tile", 0)))
	if _object_id_edit != null:
		_object_id_edit.text = String(_object_payload.get("object_id", ""))
		_object_properties_edit.text = JSON.stringify(_object_payload.get("properties", {}))
	if _label_id_edit != null:
		_label_id_edit.text = String(_label_payload.get("label_id", ""))
		_label_text_edit.text = String(_label_payload.get("text", ""))


func _refresh_payload_controls_visibility() -> void:
	var show_tile = _edit_mode == EditMode.FLOOR_TILE or _edit_mode == EditMode.WALL_TILE
	var show_object = _edit_mode == EditMode.OBJECT
	var show_label = _edit_mode == EditMode.LABEL
	_set_control_row_visible(_tile_source_spin, show_tile)
	_set_control_row_visible(_tile_atlas_x_spin, show_tile)
	_set_control_row_visible(_tile_atlas_y_spin, show_tile)
	_set_control_row_visible(_tile_alternative_spin, show_tile)
	_set_control_row_visible(_object_id_edit, show_object)
	_set_control_row_visible(_object_properties_edit, show_object)
	_set_control_row_visible(_object_database_picker, show_object)
	_set_control_row_visible(_label_id_edit, show_label)
	_set_control_row_visible(_label_text_edit, show_label)
	_set_control_row_visible(_label_database_picker, show_label)


func _set_control_row_visible(control, visible: bool) -> void:
	if control == null:
		return
	if control is Control:
		var parent = (control as Control).get_parent()
		if parent is Control:
			(parent as Control).visible = visible
		else:
			(control as Control).visible = visible


func _sync_resource_pickers() -> void:
	if _document_resource_picker != null:
		_document_resource_picker.edited_resource = _document
	if _object_database_picker != null:
		_object_database_picker.edited_resource = _object_database
	if _label_database_picker != null:
		_label_database_picker.edited_resource = _label_database


func _refresh_state_labels() -> void:
	if _document_label != null:
		_document_label.text = "Document: %s" % ("selected" if _document != null else "none")
	if _target_label != null:
		var target_name = "none"
		if _target_layer != null and is_instance_valid(_target_layer):
			target_name = _target_layer.name
		_target_label.text = "Target: %s" % target_name
	_refresh_target_status_detail()


func _resolve_target_layer():
	if _target_option == null:
		return _target_layer
	var node_index = _target_option.selected - TARGET_LAYER_INDEX_OFFSET
	if node_index >= 0 and node_index < _target_layer_nodes.size():
		var node = _target_layer_nodes[node_index]
		return node if is_instance_valid(node) else null
	if _target_layer != null and is_instance_valid(_target_layer):
		return _target_layer
	for node in _target_layer_nodes:
		if is_instance_valid(node):
			return node
	return null


func _select_target_layer_option(layer: Node) -> void:
	var selected_index = TARGET_AUTO_INDEX
	if layer != null:
		var index = _target_layer_nodes.find(layer)
		if index >= 0:
			selected_index = index + TARGET_LAYER_INDEX_OFFSET
	_target_option.select(selected_index)


func _collect_target_layers_recursive(node: Node, result: Array[Node]) -> void:
	if node is TileMapLayer or node is HexTileMapLayer:
		result.append(node)
	for child in node.get_children():
		_collect_target_layers_recursive(child, result)


func _target_layer_display_name(node: Node, scan_root: Node) -> String:
	if node == null:
		return ""
	if scan_root != null:
		var path = str(scan_root.get_path_to(node))
		if path != "":
			return path
	return node.name


func _select_target_in_editor_if_possible() -> void:
	if _target_layer == null or not is_instance_valid(_target_layer):
		return
	_target_selection_sync_request_count += 1
	_last_selection_sync_target = _target_layer
	if not Engine.is_editor_hint():
		return
	var selection = EditorInterface.get_selection()
	if selection == null:
		return
	selection.clear()
	selection.add_node(_target_layer)


func _editor_viewport_event_to_target_local(event: InputEventMouseButton):
	_pending_viewport_trace = {}
	if _target_layer == null or not (_target_layer is CanvasItem):
		_set_status("No editable target layer.")
		_debug_viewport_input("target missing", event.position, Vector2.ZERO, Vector2.ZERO, {})
		return null
	var scene_pos = _editor_viewport_position_to_scene_position(event.position)
	if scene_pos == null:
		_set_status("Cannot resolve editor viewport position.")
		_debug_viewport_input("scene position missing", event.position, Vector2.ZERO, Vector2.ZERO, {})
		return null
	var local_pos = (_target_layer as CanvasItem).to_local(scene_pos)
	_pending_viewport_trace = {
		"viewport_position": event.position,
		"scene_position": scene_pos,
		"local_position": local_pos,
	}
	if debug_viewport_input:
		var hit = _local_hit(local_pos)
		_debug_viewport_input("resolved", event.position, scene_pos, local_pos, hit)
	return local_pos


func _editor_viewport_position_to_scene_position(viewport_pos: Vector2):
	if _test_viewport_canvas_transform_enabled:
		return _test_viewport_canvas_transform.affine_inverse() * viewport_pos
	if Engine.is_editor_hint() and EditorInterface.has_method("get_editor_viewport_2d"):
		var viewport = EditorInterface.get_editor_viewport_2d()
		if viewport != null:
			var global_canvas_transform = viewport.get("global_canvas_transform")
			if global_canvas_transform is Transform2D:
				return (global_canvas_transform as Transform2D).affine_inverse() * viewport_pos
			var canvas_transform = viewport.get("canvas_transform")
			if canvas_transform is Transform2D:
				return (canvas_transform as Transform2D).affine_inverse() * viewport_pos
			if viewport.has_method("get_canvas_transform"):
				return viewport.get_canvas_transform().affine_inverse() * viewport_pos
	return viewport_pos


func _debug_viewport_input(stage: String, viewport_pos: Vector2, scene_pos: Vector2, local_pos: Vector2, hit: Dictionary) -> void:
	if not debug_viewport_input:
		return
	var target_path = _target_path_string()
	var hit_hex = hit["hex"].key() if hit.has("hex") else "<none>"
	var visual_hex = hit["visual_hex"].key() if hit.has("visual_hex") else "<none>"
	print(
		"[HexMapEdit] %s target=%s mode=%d viewport=%s scene=%s local=%s hex=%s visual=%s exists=%s" %
		[stage, target_path, _edit_mode, viewport_pos, scene_pos, local_pos, hit_hex, visual_hex, str(hit.get("exists", false))]
	)


func _refresh_target_status_detail() -> void:
	_target_status_detail = _build_target_readiness_status()
	if _target_status_label != null:
		_target_status_label.text = _format_target_status_detail(_target_status_detail)


func _build_target_readiness_status() -> Dictionary:
	var status = {
		"target_path": _target_path_string(),
		"target_class": _target_class_string(),
		"is_hex_tile_map_layer": _target_layer is HexTileMapLayer,
		"tile_set_present": false,
		"floor_source_id": 0,
		"floor_atlas_coords": Vector2i.ZERO,
		"wall_source_id": 0,
		"wall_atlas_coords": Vector2i(1, 0),
		"used_cell_count": 0,
		"loop_display_mode": HexTileMapLayer.LOOP_DISPLAY_NONE,
		"ready": false,
		"message": "No editable target layer.",
	}
	if _target_layer == null or not is_instance_valid(_target_layer):
		return status
	if _target_layer is HexTileMapLayer:
		var hex_layer := _target_layer as HexTileMapLayer
		status["tile_set_present"] = hex_layer.display_tile_set_present()
		status["floor_source_id"] = hex_layer.floor_source_id
		status["floor_atlas_coords"] = hex_layer.floor_atlas_coords
		status["wall_source_id"] = hex_layer.wall_source_id
		status["wall_atlas_coords"] = hex_layer.wall_atlas_coords
		status["used_cell_count"] = hex_layer.display_used_cell_count()
		status["loop_display_mode"] = hex_layer.loop_display_mode
	elif _target_layer is TileMapLayer:
		var tile_layer := _target_layer as TileMapLayer
		status["tile_set_present"] = tile_layer.tile_set != null
		status["used_cell_count"] = tile_layer.get_used_cells().size()
	else:
		status["message"] = "Target is not a TileMapLayer."
		return status
	status["ready"] = bool(status["tile_set_present"])
	status["message"] = "ready" if bool(status["ready"]) else "TileSet missing."
	return status


func _format_target_status_detail(status: Dictionary) -> String:
	if status.is_empty():
		return "none"
	var tile_state = "ready" if bool(status.get("tile_set_present", false)) else "missing"
	var loop_text = ""
	if bool(status.get("is_hex_tile_map_layer", false)):
		loop_text = " loop=%s" % _loop_mode_name(int(status.get("loop_display_mode", 0)))
	return "%s %s tiles=%s floor=%d:%s wall=%d:%s used=%d%s %s" % [
		String(status.get("target_class", "")),
		String(status.get("target_path", "")),
		tile_state,
		int(status.get("floor_source_id", 0)),
		_atlas_text(status.get("floor_atlas_coords", Vector2i.ZERO)),
		int(status.get("wall_source_id", 0)),
		_atlas_text(status.get("wall_atlas_coords", Vector2i(1, 0))),
		int(status.get("used_cell_count", 0)),
		loop_text,
		String(status.get("message", "")),
	]


func _target_class_string() -> String:
	if _target_layer == null:
		return "none"
	if not is_instance_valid(_target_layer):
		return "invalid"
	if _target_layer is HexTileMapLayer:
		return "HexTileMapLayer"
	if _target_layer is TileMapLayer:
		return "TileMapLayer"
	return _target_layer.get_class()


func _build_last_edit_trace(
	hit: Dictionary,
	before,
	after,
	applied: bool,
	target_used_cells_before: int,
	target_used_cells_after: int,
	display_before: Dictionary,
	display_after: Dictionary
) -> Dictionary:
	var hex = hit["hex"]
	var visual_hex = hit.get("visual_hex", hex)
	var before_state = _document_cell_state(before, hex)
	var after_state = _document_cell_state(after, hex)
	var viewport_trace = _pending_viewport_trace.duplicate(true)
	_pending_viewport_trace = {}
	var local_position = hit.get("local", Vector2.ZERO)
	var viewport_position = viewport_trace.get("viewport_position", Vector2.ZERO)
	var scene_position = viewport_trace.get("scene_position", Vector2.ZERO)
	if viewport_trace.has("local_position"):
		local_position = viewport_trace["local_position"]
	var display_atlas_before = display_before.get("atlas_coords", Vector2i(-1, -1))
	var display_atlas_after = display_after.get("atlas_coords", Vector2i(-1, -1))
	var document_changed = var_to_str(before_state) != var_to_str(after_state)
	var display_changed = display_atlas_before != display_atlas_after \
		or int(display_before.get("source_id", -1)) != int(display_after.get("source_id", -1))
	var trace = {
		"target_path": _target_path_string(),
		"target_class": _target_class_string(),
		"mode": _edit_mode,
		"viewport_position": viewport_position,
		"scene_position": scene_position,
		"local_position": local_position,
		"hex": hex,
		"visual_hex": visual_hex,
		"exists": bool(hit.get("exists", false)),
		"exists_before": bool(before_state.get("exists", false)),
		"exists_after": bool(after_state.get("exists", false)),
		"wall_before": bool(before_state.get("wall", false)),
		"wall_after": bool(after_state.get("wall", false)),
		"document_changed": document_changed,
		"target_applied": applied,
		"applied": applied,
		"target_used_cells_before": target_used_cells_before,
		"target_used_cells_after": target_used_cells_after,
		"display_atlas_before": display_atlas_before,
		"display_atlas_after": display_atlas_after,
		"display_changed": display_changed,
	}
	trace["message"] = _format_last_edit_detail(trace)
	return trace


func _refresh_last_edit_detail() -> void:
	if _last_edit_detail_label != null:
		_last_edit_detail_label.text = _format_last_edit_detail(_last_edit_status)


func _format_last_edit_detail(trace: Dictionary) -> String:
	if trace.is_empty():
		return "none"
	var hex_text = trace["hex"].key() if trace.has("hex") else "<none>"
	var visual_text = trace["visual_hex"].key() if trace.has("visual_hex") else hex_text
	var visual_suffix = " via %s" % visual_text if visual_text != hex_text else ""
	return "%s%s %s->%s document=%s target=%s display=%s tile=%s->%s used=%d->%d" % [
		hex_text,
		visual_suffix,
		"wall" if bool(trace.get("wall_before", false)) else "floor",
		"wall" if bool(trace.get("wall_after", false)) else "floor",
		_bool_text(bool(trace.get("document_changed", false))),
		_bool_text(bool(trace.get("target_applied", false))),
		_bool_text(bool(trace.get("display_changed", false))),
		_atlas_text(trace.get("display_atlas_before", Vector2i(-1, -1))),
		_atlas_text(trace.get("display_atlas_after", Vector2i(-1, -1))),
		int(trace.get("target_used_cells_before", 0)),
		int(trace.get("target_used_cells_after", 0)),
	]


func _document_cell_state(document, hex) -> Dictionary:
	var state = {
		"exists": false,
		"wall": false,
		"tile_overrides": [],
		"objects": [],
		"labels": [],
	}
	if document == null or document.map == null:
		return state
	var data = document.map.to_map_data()
	state["exists"] = data.has_cell(hex)
	state["wall"] = data.has_wall(hex)
	state["tile_overrides"] = _entries_for_cell(document.tile_overrides, hex)
	state["objects"] = _entries_for_cell(document.objects, hex)
	state["labels"] = _entries_for_cell(document.labels, hex)
	return state


func _entries_for_cell(entries: Array, hex) -> Array:
	var result: Array = []
	var target_key = hex.key()
	for entry in entries:
		if not entry is Dictionary:
			continue
		if _entry_cell_key(entry) == target_key:
			result.append((entry as Dictionary).duplicate(true))
	return result


func _entry_cell_key(entry: Dictionary) -> String:
	var cell = entry.get("cell", Vector3i.ZERO)
	if typeof(cell) == TYPE_VECTOR3I:
		return HexVector.apply_basis(cell.x, cell.y, cell.z).key()
	if cell is HexVector:
		return HexVector.apply_basis(cell.q, cell.s, cell.r).key()
	return ""


func _target_display_state(hex, visual_hex) -> Dictionary:
	var state = {
		"source_id": -1,
		"atlas_coords": Vector2i(-1, -1),
	}
	if _target_layer == null or not is_instance_valid(_target_layer):
		return state
	if _target_layer is HexTileMapLayer:
		state["atlas_coords"] = (_target_layer as HexTileMapLayer).display_atlas_coords_for_hex(hex, visual_hex)
		return state
	if _target_layer is TileMapLayer:
		var flat_top = true
		if _document != null and _document.map != null:
			flat_top = _document.map.is_flat_top()
		var map_cell = HexMapTileAdapter.vector_to_map_cell(visual_hex, flat_top)
		state["source_id"] = (_target_layer as TileMapLayer).get_cell_source_id(map_cell)
		state["atlas_coords"] = (_target_layer as TileMapLayer).get_cell_atlas_coords(map_cell)
	return state


func _target_used_cell_count() -> int:
	if _target_layer == null or not is_instance_valid(_target_layer):
		return 0
	if _target_layer is HexTileMapLayer:
		return (_target_layer as HexTileMapLayer).display_used_cell_count()
	if _target_layer is TileMapLayer:
		return (_target_layer as TileMapLayer).get_used_cells().size()
	return 0


func _set_persistence_status(
	operation: String,
	path: String,
	ok: bool,
	error: int = OK,
	resource_class: String = ""
) -> void:
	var summary = _document_summary(_document)
	_last_persistence_status = {
		"operation": operation,
		"path": path,
		"ok": ok,
		"error": error,
		"resource_class": resource_class,
		"cell_count": int(summary.get("cell_count", 0)),
		"wall_count": int(summary.get("wall_count", 0)),
	}
	_last_persistence_status["message"] = _format_persistence_detail(_last_persistence_status)
	_refresh_persistence_detail()


func _document_summary(document) -> Dictionary:
	if document == null or document.map == null:
		return {"cell_count": 0, "wall_count": 0}
	var data = document.map.to_map_data()
	return {
		"cell_count": data.cells.size(),
		"wall_count": data.walls.size(),
	}


func _refresh_persistence_detail() -> void:
	if _persistence_detail_label != null:
		_persistence_detail_label.text = _format_persistence_detail(_last_persistence_status)


func _format_persistence_detail(status: Dictionary) -> String:
	if status.is_empty():
		return "none"
	return "%s %s %s cells=%d walls=%d %s" % [
		String(status.get("operation", "")),
		String(status.get("path", "")),
		String(status.get("resource_class", "")),
		int(status.get("cell_count", 0)),
		int(status.get("wall_count", 0)),
		"ok" if bool(status.get("ok", false)) else "error=%d" % int(status.get("error", ERR_UNAVAILABLE)),
	]


func _target_path_string() -> String:
	if _target_layer == null or not is_instance_valid(_target_layer):
		return ""
	if _target_layer.is_inside_tree():
		return str(_target_layer.get_path())
	return _target_layer.name


func _refresh_last_hit_display() -> void:
	if _target_layer == null or not (_target_layer is HexTileMapLayer):
		return
	if _last_edit_hit.is_empty() or not _last_edit_hit.has("hex"):
		return
	var hex_layer := _target_layer as HexTileMapLayer
	if _last_highlight_hex != null:
		hex_layer.remove_highlight(_last_highlight_hex)
	_last_highlight_hex = _last_edit_hit["hex"]
	hex_layer.highlight_cell(_last_highlight_hex, Color(0.96, 0.76, 0.18, 0.95))


func _can_use_editor_resource_picker() -> bool:
	return Engine.is_editor_hint() and ClassDB.class_exists("EditorResourcePicker")


func _set_status(text: String) -> void:
	if _status_label != null:
		_status_label.text = text


func _new_detail_label() -> Label:
	var label = Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


func _bool_text(value: bool) -> String:
	return "yes" if value else "no"


func _atlas_text(value) -> String:
	if value is Vector2i:
		return "(%d,%d)" % [value.x, value.y]
	return str(value)


func _loop_mode_name(mode: int) -> String:
	match mode:
		HexTileMapLayer.LOOP_DISPLAY_TORIC:
			return "toric"
		HexTileMapLayer.LOOP_DISPLAY_INFINITE:
			return "infinite"
		_:
			return "none"


func _new_int_spin(value: int, min_value: int, max_value: int) -> SpinBox:
	var spin = SpinBox.new()
	spin.min_value = min_value
	spin.max_value = max_value
	spin.step = 1
	spin.value = value
	spin.allow_greater = true
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return spin


func _wrap_labeled(label_text: String, control: Control) -> Control:
	var box = HBoxContainer.new()
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 82.0
	box.add_child(label)
	box.add_child(control)
	return box
