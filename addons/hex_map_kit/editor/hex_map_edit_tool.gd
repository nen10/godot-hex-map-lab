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
	_set_status("Imported HexMapResource.")
	return true


func export_map_resource() -> HexMapResource:
	return HexMapDocumentAdapter.to_map_resource(_document)


func set_target_layer(layer: Node) -> void:
	_target_layer = layer
	if _target_option != null:
		_select_target_layer_option(layer)
	_refresh_state_labels()


func target_layer() -> Node:
	return _target_layer


func set_undo_redo(undo_redo) -> void:
	_undo_redo = undo_redo


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
		_set_status("No document selected.")
		return false
	var actual_path = path if path != "" else _document_path
	if actual_path == "":
		_set_status("Document path is empty.")
		return false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(actual_path.get_base_dir()))
	var error = ResourceSaver.save(_document, actual_path)
	if error != OK:
		_set_status("Failed to save document: %d" % error)
		return false
	set_document_path(actual_path)
	_set_status("Saved document.")
	return true


func export_map_resource_to_path(path: String = "") -> bool:
	if _document == null:
		_set_status("No document selected.")
		return false
	var actual_path = path if path != "" else _export_path
	if actual_path == "":
		_set_status("Export path is empty.")
		return false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(actual_path.get_base_dir()))
	var error = ResourceSaver.save(export_map_resource(), actual_path)
	if error != OK:
		_set_status("Failed to export map: %d" % error)
		return false
	set_export_path(actual_path)
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
	if previous != null and is_instance_valid(previous):
		var index = _target_layer_nodes.find(previous)
		if index >= 0:
			selected_index = index + TARGET_LAYER_INDEX_OFFSET
	_target_option.select(selected_index)
	_target_layer = _resolve_target_layer()
	_refresh_state_labels()


func set_edit_mode(mode: int) -> void:
	_edit_mode = clampi(mode, 0, EDIT_MODE_NAMES.size() - 1)
	if _mode_option != null:
		_mode_option.select(_edit_mode)


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
	if _document == null:
		_set_status("No document selected.")
		return false
	var before = HexMapDocumentAdapter.duplicate_document(_document)
	var after = HexMapDocumentAdapter.duplicate_document(_document)
	_apply_mode_to_document(after, hex)
	_commit_document_change(before, after, "Hex map edit %s" % EDIT_MODE_NAMES[_edit_mode])
	_set_status("Edited %s" % hex.key())
	return true


func apply_local_position(local_pos: Vector2) -> bool:
	var hit = _local_hit(local_pos)
	if hit.is_empty():
		_set_status("No editable cell.")
		return false
	if _edit_mode != EditMode.SHAPE and not bool(hit.get("exists", false)):
		_set_status("No editable cell.")
		return false
	return apply_cell(hit["hex"])


func forward_canvas_gui_input(event: InputEvent) -> bool:
	if not event is InputEventMouseButton:
		return false
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return false
	if _target_layer == null or not (_target_layer is CanvasItem):
		return false
	var local_pos = (_target_layer as CanvasItem).to_local(mouse_event.position)
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


func _commit_document_change(before, after, action_name: String) -> void:
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


func _replace_document_state(snapshot) -> void:
	HexMapDocumentAdapter.copy_document_state(_document, snapshot)
	_refresh_state_labels()


func _apply_document_to_target() -> void:
	if _target_layer == null or _document == null:
		return
	if _target_layer is HexTileMapLayer:
		(_target_layer as HexTileMapLayer).apply_map(HexMapDocumentAdapter.to_map_resource(_document))
		return
	HexMapDocumentAdapter.apply_to_tile_map_layer(_document, _target_layer)


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


func _on_target_selected(_index: int) -> void:
	_target_layer = _resolve_target_layer()
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


func _can_use_editor_resource_picker() -> bool:
	return Engine.is_editor_hint() and ClassDB.class_exists("EditorResourcePicker")


func _set_status(text: String) -> void:
	if _status_label != null:
		_status_label.text = text


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
