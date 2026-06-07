@tool
class_name HexMapEditTool
extends Control

const HexMapDocumentResource = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapDocumentAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")
const HexMapDocumentValidator = preload("res://addons/hex_map_kit/adapter/hex_map_document_validator.gd")
const HexMapDocumentInspector = preload("res://addons/hex_map_kit/editor/hex_map_document_inspector.gd")
const HexMapResource = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexMapEditMutationBuilder = preload("res://addons/hex_map_kit/editor/hex_map_edit_mutation_builder.gd")
const HexMapEditViewportInputAdapter = preload("res://addons/hex_map_kit/editor/hex_map_edit_viewport_input_adapter.gd")
const HexMapEditorPathSelector = preload("res://addons/hex_map_kit/editor/hex_map_editor_path_selector.gd")
const HexMapEditorSessionState = preload("res://addons/hex_map_kit/editor/hex_map_editor_session_state.gd")
const HexMapValidationDashboard = preload("res://addons/hex_map_kit/editor/hex_map_validation_dashboard.gd")
const HexLayerStackResource = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd")
const HexObjectDatabaseResource = preload("res://addons/hex_map_kit/adapter/hex_object_database_resource.gd")
const HexObjectDefinitionResource = preload("res://addons/hex_map_kit/adapter/hex_object_definition_resource.gd")
const HexTileCatalogEntry = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_entry.gd")
const HexTileCatalogResource = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_resource.gd")
const HexTileCatalogValidator = preload("res://addons/hex_map_kit/adapter/hex_tile_catalog_validator.gd")
const HexTileMapLayer = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")

const TARGET_AUTO_INDEX := 0
const TARGET_LAYER_INDEX_OFFSET := 1
const TARGET_AUTO_LABEL := "Auto: Selected / first scene layer"
const DOCUMENT_SOURCE_NONE := "none"
const DOCUMENT_SOURCE_PROVIDED := "provided"
const DOCUMENT_SOURCE_IMPORT := "import"
const DOCUMENT_SOURCE_LOAD := "load"
const DOCUMENT_SOURCE_TARGET := "target"
const DOCUMENT_SOURCE_SAVE := "save"
const DOCUMENT_SOURCE_NEW := "new"
const SAMPLE_TILE_CATALOG_PATH := "res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres"
const CATALOG_FALLBACK_LABEL := "Choose catalog key"

enum EditMode {
	SHAPE,
	WALL_FLOOR,
	FLOOR_TILE,
	WALL_TILE,
	OBJECT,
	LABEL,
	OVERLAY_TILE,
}

const EDIT_MODE_NAMES := [
	"Shape",
	"Wall / Floor",
	"Floor Tile",
	"Wall Tile",
	"Object",
	"Label",
	"Overlay Tile",
]

@export var hex_size: float = 24.0
@export var debug_viewport_input: bool = false

var _document: HexMapDocumentResource
var _document_source := DOCUMENT_SOURCE_NONE
var _document_path := ""
var _document_dirty := false
var _import_map_resource: HexMapResource
var _import_map_path := ""
var _export_path := ""
var _target_layer: Node
var _target_layer_nodes: Array[Node] = []
var _target_layer_scan_root: Node = null
var _undo_redo = null
var _object_database: Resource
var _label_database: Resource
var _layer_stack_resource: HexLayerStackResource
var _selected_layer_stack_role := ""
var _tile_catalog: HexTileCatalogResource
var _edit_mode := EditMode.WALL_FLOOR
var _tile_payload := {
	"source_id": 0,
	"atlas_coords": Vector2i.ZERO,
	"alternative_tile": 0,
	"catalog_key": "",
}
var _floor_tile_payload := {
	"source_id": 0,
	"atlas_coords": Vector2i.ZERO,
	"alternative_tile": 0,
	"catalog_key": "",
}
var _wall_tile_payload := {
	"source_id": 0,
	"atlas_coords": Vector2i.ZERO,
	"alternative_tile": 0,
	"catalog_key": "",
}
var _overlay_tile_payload := {
	"source_id": 0,
	"atlas_coords": Vector2i.ZERO,
	"alternative_tile": 0,
	"catalog_key": "",
}
var _overlay_item_key := "Overlay"
var _object_payload := {
	"object_id": "",
	"rotation_degrees": 0.0,
	"variant": "",
	"properties": {},
	"spawn_condition": "",
}
var _label_payload := {
	"label_id": "",
	"text": "",
}
var _last_edit_hit: Dictionary = {}
var _last_edit_status: Dictionary = {}
var _target_status_detail: Dictionary = {}
var _last_persistence_status: Dictionary = {}
var _last_validation_result = null
var _last_catalog_validation_result = null
var _selected_validation_issue: Dictionary = {}
var _validation_focus_status: Dictionary = {}
var _pending_viewport_trace: Dictionary = {}
var _last_highlight_hex = null
var _plain_target_tile_options: Dictionary = {}
var _target_selection_explicit := false
var _default_target_tile_settings_explicit := false
var _last_applied_to_target := false
var _last_target_apply_reason := ""
var _last_target_resolution_reason := ""
var _last_default_tile_settings_target: Node = null
var _target_selection_sync_request_count := 0
var _last_selection_sync_target: Node = null
var _test_editor_selected_target_layer: Node = null
var _test_viewport_canvas_transform_enabled := false
var _test_viewport_canvas_transform := Transform2D.IDENTITY

var _document_label: Label
var _document_inspector: HexMapDocumentInspector
var _document_resource_picker
var _document_new_button: Button
var _document_open_button: Button
var _document_path_edit: LineEdit
var _document_browse_button: Button
var _document_load_button: Button
var _document_save_button: Button
var _document_save_as_button: Button
var _document_validate_button: Button
var _import_map_resource_picker
var _import_map_path_edit: LineEdit
var _import_map_browse_button: Button
var _import_map_button: Button
var _export_path_edit: LineEdit
var _export_button: Button
var _export_save_as_button: Button
var _target_label: Label
var _target_option: OptionButton
var _target_refresh_button: Button
var _mode_option: OptionButton
var _layer_stack_template_option: OptionButton
var _layer_stack_role_tree: Tree
var _layer_stack_create_missing_button: Button
var _layer_stack_apply_document_button: Button
var _layer_stack_clear_role_button: Button
var _layer_stack_status_label: Label
var _catalog_resource_picker
var _catalog_tile_set_picker
var _catalog_scene_picker
var _catalog_entries_tree: Tree
var _catalog_status_label: Label
var _catalog_add_atlas_button: Button
var _catalog_add_scene_button: Button
var _catalog_validate_button: Button
var _catalog_scene_resource: PackedScene
var _object_database_picker
var _object_definition_tree: Tree
var _object_definition_scene_picker
var _object_add_definition_button: Button
var _object_palette_status_label: Label
var _object_property_editor: VBoxContainer
var _object_property_controls: Dictionary = {}
var _selected_object_definition_id := ""
var _refreshing_object_definition_tree := false
var _label_database_picker
var _tile_source_spin: SpinBox
var _tile_atlas_x_spin: SpinBox
var _tile_atlas_y_spin: SpinBox
var _tile_alternative_spin: SpinBox
var _tile_catalog_option: OptionButton
var _default_floor_catalog_option: OptionButton
var _default_floor_source_spin: SpinBox
var _default_floor_atlas_x_spin: SpinBox
var _default_floor_atlas_y_spin: SpinBox
var _default_floor_alternative_spin: SpinBox
var _default_wall_catalog_option: OptionButton
var _default_wall_source_spin: SpinBox
var _default_wall_atlas_x_spin: SpinBox
var _default_wall_atlas_y_spin: SpinBox
var _default_wall_alternative_spin: SpinBox
var _default_tile_read_button: Button
var _default_tile_apply_button: Button
var _target_tile_set_picker
var _target_atlas_path_edit: LineEdit
var _target_atlas_browse_button: Button
var _target_atlas_apply_button: Button
var _target_sample_option: OptionButton
var _target_sample_apply_button: Button
var _select_display_layer_button: Button
var _overlay_item_key_edit: LineEdit
var _overlay_item_key_option: OptionButton
var _object_catalog_option: OptionButton
var _object_id_edit: LineEdit
var _object_rotation_spin: SpinBox
var _object_variant_edit: LineEdit
var _object_properties_edit: LineEdit
var _object_properties_table: Tree
var _object_spawn_condition_edit: LineEdit
var _label_id_edit: LineEdit
var _label_text_edit: LineEdit
var _status_label: Label
var _target_status_label: Label
var _last_edit_detail_label: Label
var _persistence_detail_label: Label
var _validation_dashboard: HexMapValidationDashboard
var _copy_debug_report_button: Button
var _last_copied_debug_report := ""
var _editor_session_state: HexMapEditorSessionState = null


func _ready() -> void:
	name = "Hex Map Edit"
	_build_ui()
	refresh_target_layer_options()
	_refresh_state_labels()


func set_editor_session_state(session: HexMapEditorSessionState) -> void:
	_editor_session_state = session
	if _editor_session_state == null:
		return
	var session_document_saved_path := _editor_session_state.document_saved_path
	var session_import_map_saved_path := _editor_session_state.import_map_saved_path
	var session_export_saved_path := _editor_session_state.export_saved_path
	var session_target = _editor_session_state.current_target_layer()
	if session_target != null:
		set_target_layer(session_target)
	var session_document = _editor_session_state.current_document()
	if session_document is HexMapDocumentResource:
		set_document(session_document as HexMapDocumentResource)
	if session_document_saved_path != "":
		set_document_path(session_document_saved_path)
	var session_import_map = _editor_session_state.current_import_map()
	if session_import_map is HexMapResource:
		set_import_map_resource(session_import_map as HexMapResource, session_import_map_saved_path)
	elif session_import_map_saved_path != "":
		set_import_map_path(session_import_map_saved_path)
	if session_export_saved_path != "":
		set_export_path(session_export_saved_path)


func editor_session_state() -> HexMapEditorSessionState:
	return _editor_session_state


func set_document(document: HexMapDocumentResource) -> void:
	_document = document
	_document_source = DOCUMENT_SOURCE_PROVIDED if document != null else DOCUMENT_SOURCE_NONE
	_document_dirty = false
	_document_path = document.resource_path if document != null and document.resource_path != "" else ""
	if _document_path_edit != null:
		_document_path_edit.text = _document_path
	_refresh_plain_target_tile_options_from_document(_document)
	_read_target_tile_settings(false)
	_sync_resource_pickers()
	_refresh_overlay_item_key_options()
	_refresh_state_labels()
	_publish_session_document("edit.set_document")
	_publish_session_paths("edit.set_document")


func document() -> HexMapDocumentResource:
	return _document


func _document_for_editor(document: HexMapDocumentResource) -> HexMapDocumentResource:
	return document


func _document_map_resource(document: HexMapDocumentResource) -> HexMapResource:
	if document == null:
		return null
	return HexMapDocumentAdapter.to_map_resource(document)


func _document_has_cell(document: HexMapDocumentResource, hex) -> bool:
	var map_resource = _document_map_resource(document)
	return map_resource != null and map_resource.to_map_data().has_cell(hex)


func _document_has_wall(document: HexMapDocumentResource, hex) -> bool:
	var map_resource = _document_map_resource(document)
	return map_resource != null and map_resource.to_map_data().has_wall(hex)


func _document_is_flat_top(document: HexMapDocumentResource) -> bool:
	var map_resource = _document_map_resource(document)
	return map_resource == null or map_resource.is_flat_top()


func import_map_resource(resource: HexMapResource) -> HexMapDocumentResource:
	set_import_map_resource(resource)
	_document = _document_for_editor(HexMapDocumentAdapter.from_map_resource(resource))
	_document_source = DOCUMENT_SOURCE_IMPORT if _document != null else DOCUMENT_SOURCE_NONE
	_document_dirty = _document != null
	set_document_path("")
	_refresh_plain_target_tile_options_from_document(_document)
	_read_target_tile_settings(false)
	_sync_resource_pickers()
	_refresh_overlay_item_key_options()
	_refresh_state_labels()
	_publish_session_document("edit.import_map_resource")
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
	set_import_map_resource(resource, actual_path)
	import_map_resource(resource)
	set_import_map_path(actual_path)
	_apply_document_to_target()
	if _target_layer != null and is_instance_valid(_target_layer):
		_select_target_in_editor_if_possible()
	_set_status("Imported HexMapResource.")
	return true


func export_map_resource() -> HexMapResource:
	_sync_document_snapshot_from_hex_target()
	return HexMapDocumentAdapter.to_map_resource(_document)


func set_target_layer(layer: Node) -> void:
	_target_layer = layer
	_target_selection_explicit = layer != null
	if _target_selection_explicit:
		_last_target_resolution_reason = "explicit target"
	else:
		_last_target_resolution_reason = "auto target"
	_ensure_document_from_target_if_needed()
	_refresh_plain_target_tile_options_from_document(_document)
	_read_target_tile_settings(false)
	if _target_option != null:
		_select_target_layer_option(layer)
	_select_target_in_editor_if_possible()
	_refresh_layer_stack_screen()
	_refresh_state_labels()
	_publish_session_target("edit.set_target_layer")


func target_layer() -> Node:
	return _target_layer


func set_undo_redo(undo_redo) -> void:
	_undo_redo = undo_redo


func viewport_input_enabled() -> bool:
	_target_layer = _resolve_target_layer()
	_ensure_document_from_target_if_needed()
	return _document != null \
		and _target_layer != null \
		and is_instance_valid(_target_layer) \
		and _target_layer is CanvasItem


func set_viewport_canvas_transform_for_test(transform: Transform2D) -> void:
	_test_viewport_canvas_transform_enabled = true
	_test_viewport_canvas_transform = transform


func clear_viewport_canvas_transform_for_test() -> void:
	_test_viewport_canvas_transform_enabled = false


func set_editor_selected_target_layer_for_test(layer: Node) -> void:
	_test_editor_selected_target_layer = layer
	_target_selection_explicit = false
	if _target_option != null:
		_target_option.select(TARGET_AUTO_INDEX)
	_target_layer = _resolve_target_layer()
	_ensure_document_from_target_if_needed()
	_refresh_plain_target_tile_options_from_document(_document)
	_read_target_tile_settings(false)
	_refresh_state_labels()
	_publish_session_target("edit.test_editor_selected_target")


func last_edit_status() -> Dictionary:
	return _last_edit_status.duplicate(true)


func target_readiness_status() -> Dictionary:
	_refresh_target_status_detail()
	return _target_status_detail.duplicate(true)


func persistence_status() -> Dictionary:
	return _last_persistence_status.duplicate(true)


func validation_dashboard_summary() -> Dictionary:
	if _validation_dashboard == null:
		return {}
	return _validation_dashboard.validation_summary()


func document_inspector_summary() -> Dictionary:
	if _document_inspector == null:
		return {}
	return _document_inspector.inspector_summary()


func selected_validation_issue() -> Dictionary:
	return _selected_validation_issue.duplicate(true)


func validation_focus_status() -> Dictionary:
	return _validation_focus_status.duplicate(true)


func validation_debug_summary() -> Dictionary:
	return _validation_summary_from_result(_validation_result_for_report())


func validation_debug_issue_rows(limit: int = 8) -> Array[String]:
	return _validation_issue_report_rows(_validation_result_for_report(), limit)


func select_validation_issue(index: int) -> bool:
	if _validation_dashboard == null:
		return false
	return _validation_dashboard.select_issue(index)


func validate_document_now() -> bool:
	_sync_document_snapshot_from_hex_target()
	if _document == null:
		_last_validation_result = null
		_selected_validation_issue.clear()
		_validation_focus_status.clear()
		if _validation_dashboard != null:
			_validation_dashboard.clear_result("No document selected.")
		_refresh_document_inspector()
		_set_status("No document selected.")
		return false
	_last_validation_result = HexMapDocumentValidator.validate_document(_document, _validation_options())
	_selected_validation_issue.clear()
	_validation_focus_status.clear()
	if _validation_dashboard != null:
		_validation_dashboard.set_validation_result(_last_validation_result)
	_refresh_document_inspector()
	_set_status("Validation complete: %d issue(s)." % _last_validation_result.issue_count())
	_refresh_state_labels()
	return true


func set_object_database(database: Resource) -> void:
	_object_database = database
	if _selected_object_definition_id == "" and _object_database != null and _object_database.has_method("definition_ids"):
		var ids: PackedStringArray = _object_database.definition_ids()
		if ids.size() > 0:
			_selected_object_definition_id = ids[0]
	if _selected_object_definition_id != "" and String(_object_payload.get("object_id", "")) == "":
		_object_payload["object_id"] = _selected_object_definition_id
		_apply_selected_definition_defaults()
	_refresh_object_palette()
	_sync_payload_controls()
	_sync_resource_pickers()


func object_database() -> Resource:
	return _object_database


func set_label_database(database: Resource) -> void:
	_label_database = database
	_sync_resource_pickers()


func label_database() -> Resource:
	return _label_database


func set_tile_catalog(catalog: HexTileCatalogResource) -> void:
	_tile_catalog = catalog
	_last_catalog_validation_result = null
	_sync_resource_pickers()
	_refresh_catalog_options()
	_refresh_catalog_entries()
	_refresh_action_button_states()


func tile_catalog() -> HexTileCatalogResource:
	return _ensure_tile_catalog()


func set_document_path(path: String) -> void:
	_document_path = path
	if _document_path_edit != null:
		_document_path_edit.text = path
	_refresh_action_button_states()
	_publish_session_paths("edit.set_document_path")


func document_path() -> String:
	return _document_path


func set_import_map_path(path: String) -> void:
	_import_map_path = path
	if _import_map_path_edit != null:
		_import_map_path_edit.text = path
	_refresh_action_button_states()
	_publish_session_import_map("edit.set_import_map_path")


func import_map_path() -> String:
	return _import_map_path


func set_import_map_resource(resource: HexMapResource, saved_path: String = "") -> void:
	_import_map_resource = resource
	var actual_saved_path := saved_path
	if actual_saved_path == "" and resource != null:
		actual_saved_path = resource.resource_path
	if actual_saved_path != "":
		_import_map_path = actual_saved_path
		if _import_map_path_edit != null:
			_import_map_path_edit.text = actual_saved_path
	elif resource == null:
		_import_map_path = ""
		if _import_map_path_edit != null:
			_import_map_path_edit.text = ""
	_sync_resource_pickers()
	_refresh_action_button_states()
	_publish_session_import_map("edit.set_import_map_resource")


func import_map_resource_selection() -> HexMapResource:
	return _import_map_resource


func set_export_path(path: String) -> void:
	_export_path = path
	if _export_path_edit != null:
		_export_path_edit.text = path
	_refresh_action_button_states()
	_publish_session_paths("edit.set_export_path")


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
	_document = _document_for_editor(resource)
	_document_source = DOCUMENT_SOURCE_LOAD
	_document_dirty = false
	set_document_path(actual_path)
	_sync_resource_pickers()
	_refresh_overlay_item_key_options()
	_refresh_plain_target_tile_options_from_document(_document)
	_read_target_tile_settings(false)
	_apply_document_to_target()
	_refresh_state_labels()
	_set_status("Loaded document.")
	_publish_session_document("edit.load_document")
	return true


func save_document(path: String = "") -> bool:
	_sync_document_snapshot_from_hex_target()
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
	_document_source = DOCUMENT_SOURCE_SAVE
	_document_dirty = false
	_set_persistence_status("save_document", actual_path, true, OK, "HexMapDocumentResource")
	_set_status("Saved document.")
	_refresh_state_labels()
	_publish_session_document("edit.save_document")
	return true


func export_map_resource_to_path(path: String = "") -> bool:
	_sync_document_snapshot_from_hex_target()
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
	_refresh_state_labels()
	_publish_session_paths("edit.export_map_resource_to_path")
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
	if _target_selection_explicit and previous != null and is_instance_valid(previous):
		var index = _target_layer_nodes.find(previous)
		if index >= 0:
			selected_index = index + TARGET_LAYER_INDEX_OFFSET
			should_sync_target = true
	_target_option.select(selected_index)
	_target_layer = _resolve_target_layer()
	_refresh_plain_target_tile_options_from_document(_document)
	_read_target_tile_settings(false)
	if should_sync_target and _target_layer != null and is_instance_valid(_target_layer):
		_select_target_in_editor_if_possible()
	_ensure_document_from_target_if_needed()
	_publish_session_target("edit.refresh_target_options")
	_refresh_layer_stack_screen()
	_refresh_state_labels()


func set_edit_mode(mode: int) -> void:
	_store_current_tile_payload_for_mode()
	_edit_mode = clampi(mode, 0, EDIT_MODE_NAMES.size() - 1)
	_load_tile_payload_for_mode()
	if _mode_option != null:
		_mode_option.select(_edit_mode)
	_sync_payload_controls()
	_refresh_payload_controls_visibility()
	_refresh_target_status_detail()


func edit_mode() -> int:
	return _edit_mode


func set_tile_payload(source_id: int, atlas_coords: Vector2i, alternative_tile: int = 0) -> void:
	_tile_payload = {
		"source_id": source_id,
		"atlas_coords": atlas_coords,
		"alternative_tile": alternative_tile,
		"catalog_key": "",
	}
	_store_current_tile_payload_for_mode()
	_sync_payload_controls()
	_refresh_target_status_detail()


func set_overlay_tile_payload(item_key: String, source_id: int, atlas_coords: Vector2i, alternative_tile: int = 0) -> void:
	_overlay_item_key = item_key
	set_tile_payload(source_id, atlas_coords, alternative_tile)
	_overlay_tile_payload = _tile_payload.duplicate(true)
	_refresh_overlay_item_key_options()


func set_object_payload(
	object_id: String,
	properties: Dictionary = {},
	rotation_degrees: float = 0.0,
	variant: String = "",
	spawn_condition: String = ""
) -> void:
	_object_payload = {
		"object_id": object_id,
		"rotation_degrees": rotation_degrees,
		"variant": variant,
		"properties": properties.duplicate(true),
		"spawn_condition": spawn_condition,
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
		"exists": _document_has_cell(_document, hex),
	})


func _apply_hit(hit: Dictionary) -> bool:
	if _document == null:
		_set_status("No document selected.")
		return false
	_target_layer = _resolve_target_layer()
	if _target_layer is HexTileMapLayer and is_instance_valid(_target_layer):
		return _apply_hex_tile_map_layer_hit(hit)
	var hex = hit["hex"]
	var visual_hex = hit.get("visual_hex", hex)
	var edit = HexMapEditMutationBuilder.build_document_edit(
		_document,
		hex,
		_edit_mode,
		_tile_payload,
		_overlay_item_key,
		_object_payload,
		_label_payload,
		EDIT_MODE_NAMES
	)
	if edit.is_empty():
		_set_status("No editable cell.")
		return false
	var before = edit["before"]
	var after = edit["after"]
	_refresh_plain_target_tile_options_from_document(before)
	var target_used_cells_before = _target_used_cell_count()
	var display_before = _target_display_state(hex, visual_hex)
	var applied = _commit_document_change(
		before,
		after,
		"Hex map edit %s" % EDIT_MODE_NAMES[_edit_mode],
		hex,
		_target_cell_apply_reason_for_mode()
	)
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
	if not HexMapEditViewportInputAdapter.hit_is_editable(hit, _edit_mode, EditMode.SHAPE):
		_set_status("No editable cell.")
		return false
	return _apply_hit(hit)


func forward_canvas_gui_input(event: InputEvent) -> bool:
	if not HexMapEditViewportInputAdapter.accepts_mouse_press(event):
		return false
	var mouse_event := event as InputEventMouseButton
	var local_pos = _editor_viewport_event_to_target_local(mouse_event)
	if local_pos == null:
		return false
	apply_local_position(local_pos)
	return true


func _build_ui() -> void:
	if _mode_option != null:
		return
	var scroll = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)

	var root = VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	scroll.add_child(root)

	var title = Label.new()
	title.text = "Hex Map Edit"
	root.add_child(title)

	var document_actions_row = HBoxContainer.new()
	_document_new_button = Button.new()
	_document_new_button.text = "New Document"
	_document_new_button.pressed.connect(_on_new_document_pressed)
	document_actions_row.add_child(_document_new_button)
	_document_open_button = Button.new()
	_document_open_button.text = "Open..."
	_document_open_button.pressed.connect(_on_document_browse_pressed)
	document_actions_row.add_child(_document_open_button)
	_document_browse_button = _document_open_button
	_document_save_button = Button.new()
	_document_save_button.text = "Save"
	_document_save_button.pressed.connect(_on_save_document_pressed)
	document_actions_row.add_child(_document_save_button)
	_document_save_as_button = Button.new()
	_document_save_as_button.text = "Save As..."
	_document_save_as_button.pressed.connect(_on_save_document_as_pressed)
	document_actions_row.add_child(_document_save_as_button)
	_document_validate_button = Button.new()
	_document_validate_button.text = "Validate"
	_document_validate_button.pressed.connect(_on_validate_document_pressed)
	document_actions_row.add_child(_document_validate_button)
	root.add_child(document_actions_row)

	_document_label = Label.new()
	_document_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_document_label)
	_document_inspector = HexMapDocumentInspector.new()
	root.add_child(_document_inspector)
	if _can_use_editor_resource_picker():
		_document_resource_picker = EditorResourcePicker.new()
		_document_resource_picker.base_type = "HexMapDocumentResource"
		_document_resource_picker.resource_changed.connect(_on_document_resource_changed)
		root.add_child(_wrap_labeled("Document Resource", _document_resource_picker))
	var document_path_row = HBoxContainer.new()
	_document_path_edit = LineEdit.new()
	_document_path_edit.placeholder_text = "Unsaved document"
	_document_path_edit.editable = false
	_document_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_document_path_edit.tooltip_text = "Saved location. Use Document Resource, Browse, or Save As to change it."
	document_path_row.add_child(_wrap_labeled("Saved", _document_path_edit))
	root.add_child(document_path_row)

	var import_resource_row = HBoxContainer.new()
	if _can_use_editor_resource_picker():
		_import_map_resource_picker = EditorResourcePicker.new()
		_import_map_resource_picker.base_type = "HexMapResource"
		_import_map_resource_picker.resource_changed.connect(_on_import_map_resource_changed)
		import_resource_row.add_child(_wrap_labeled("Convert Resource", _import_map_resource_picker))
		_import_map_browse_button = Button.new()
		_import_map_browse_button.text = "Browse..."
		_import_map_browse_button.pressed.connect(_on_import_map_browse_pressed)
		import_resource_row.add_child(_import_map_browse_button)
		_import_map_button = Button.new()
		_import_map_button.text = "Convert"
		_import_map_button.pressed.connect(_on_import_map_pressed)
		import_resource_row.add_child(_import_map_button)
	else:
		_import_map_browse_button = Button.new()
		_import_map_browse_button.text = "Browse..."
		_import_map_browse_button.pressed.connect(_on_import_map_browse_pressed)
		import_resource_row.add_child(_import_map_browse_button)
		_import_map_button = Button.new()
		_import_map_button.text = "Convert"
		_import_map_button.pressed.connect(_on_import_map_pressed)
		import_resource_row.add_child(_import_map_button)
	root.add_child(import_resource_row)
	var import_path_row = HBoxContainer.new()
	_import_map_path_edit = LineEdit.new()
	_import_map_path_edit.placeholder_text = "No import resource selected"
	_import_map_path_edit.editable = false
	_import_map_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_import_map_path_edit.tooltip_text = "Saved location of the selected import resource."
	import_path_row.add_child(_wrap_labeled("Import Saved", _import_map_path_edit))
	root.add_child(import_path_row)

	var export_path_row = HBoxContainer.new()
	_export_path_edit = LineEdit.new()
	_export_path_edit.placeholder_text = "No export destination selected"
	_export_path_edit.editable = false
	_export_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_export_path_edit.tooltip_text = "Last export destination. Use Save As to choose it."
	export_path_row.add_child(_wrap_labeled("Export Saved", _export_path_edit))
	_export_button = Button.new()
	_export_button.text = "Export..."
	_export_button.pressed.connect(_on_export_pressed)
	export_path_row.add_child(_export_button)
	_export_save_as_button = Button.new()
	_export_save_as_button.text = "Export As..."
	_export_save_as_button.pressed.connect(_on_export_save_as_pressed)
	export_path_row.add_child(_export_save_as_button)
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

	var layer_stack_title = Label.new()
	layer_stack_title.text = "Layer Stack"
	root.add_child(layer_stack_title)
	_layer_stack_template_option = OptionButton.new()
	_layer_stack_template_option.add_item("Standard Authoring")
	_layer_stack_template_option.set_item_metadata(0, "standard")
	_layer_stack_template_option.add_item("Minimal Runtime")
	_layer_stack_template_option.set_item_metadata(1, "minimal")
	_layer_stack_template_option.item_selected.connect(_on_layer_stack_template_selected)
	root.add_child(_wrap_labeled("Template", _layer_stack_template_option))
	_layer_stack_role_tree = Tree.new()
	_layer_stack_role_tree.hide_root = true
	_layer_stack_role_tree.columns = 6
	_layer_stack_role_tree.set_column_titles_visible(true)
	_layer_stack_role_tree.set_column_title(0, "role")
	_layer_stack_role_tree.set_column_title(1, "node")
	_layer_stack_role_tree.set_column_title(2, "visible")
	_layer_stack_role_tree.set_column_title(3, "locked")
	_layer_stack_role_tree.set_column_title(4, "z")
	_layer_stack_role_tree.set_column_title(5, "writable")
	_layer_stack_role_tree.custom_minimum_size = Vector2(0, 132)
	_layer_stack_role_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_layer_stack_role_tree.item_selected.connect(_on_layer_stack_role_selected)
	root.add_child(_layer_stack_role_tree)
	_layer_stack_status_label = _new_detail_label()
	root.add_child(_wrap_labeled("Layer Stack Status", _layer_stack_status_label))
	var layer_stack_actions = HBoxContainer.new()
	_layer_stack_create_missing_button = Button.new()
	_layer_stack_create_missing_button.text = "Create Missing Layers"
	_layer_stack_create_missing_button.pressed.connect(_on_create_missing_layers_pressed)
	layer_stack_actions.add_child(_layer_stack_create_missing_button)
	_layer_stack_apply_document_button = Button.new()
	_layer_stack_apply_document_button.text = "Apply Document"
	_layer_stack_apply_document_button.pressed.connect(_on_apply_layer_stack_document_pressed)
	layer_stack_actions.add_child(_layer_stack_apply_document_button)
	_layer_stack_clear_role_button = Button.new()
	_layer_stack_clear_role_button.text = "Clear Role"
	_layer_stack_clear_role_button.pressed.connect(_on_clear_layer_stack_role_pressed)
	layer_stack_actions.add_child(_layer_stack_clear_role_button)
	root.add_child(layer_stack_actions)

	var catalog_title = Label.new()
	catalog_title.text = "Catalog"
	root.add_child(catalog_title)
	if _can_use_editor_resource_picker():
		_catalog_resource_picker = EditorResourcePicker.new()
		_catalog_resource_picker.base_type = "HexTileCatalogResource"
		_catalog_resource_picker.resource_changed.connect(_on_catalog_resource_changed)
		root.add_child(_wrap_labeled("Catalog Resource", _catalog_resource_picker))

		_catalog_tile_set_picker = EditorResourcePicker.new()
		_catalog_tile_set_picker.base_type = "TileSet"
		_catalog_tile_set_picker.resource_changed.connect(_on_catalog_tile_set_changed)
		root.add_child(_wrap_labeled("TileSet", _catalog_tile_set_picker))

		_catalog_scene_picker = EditorResourcePicker.new()
		_catalog_scene_picker.base_type = "PackedScene"
		_catalog_scene_picker.resource_changed.connect(_on_catalog_scene_changed)
		root.add_child(_wrap_labeled("Scene Entry Resource", _catalog_scene_picker))

	_catalog_entries_tree = Tree.new()
	_catalog_entries_tree.hide_root = true
	_catalog_entries_tree.columns = 5
	_catalog_entries_tree.set_column_titles_visible(true)
	_catalog_entries_tree.set_column_title(0, "key")
	_catalog_entries_tree.set_column_title(1, "type")
	_catalog_entries_tree.set_column_title(2, "preview")
	_catalog_entries_tree.set_column_title(3, "tags")
	_catalog_entries_tree.set_column_title(4, "status")
	_catalog_entries_tree.custom_minimum_size = Vector2(0, 132)
	_catalog_entries_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(_catalog_entries_tree)
	_catalog_status_label = _new_detail_label()
	root.add_child(_wrap_labeled("Catalog Status", _catalog_status_label))
	var catalog_actions_row = HBoxContainer.new()
	_catalog_add_atlas_button = Button.new()
	_catalog_add_atlas_button.text = "Add Atlas Entry"
	_catalog_add_atlas_button.pressed.connect(_on_add_catalog_atlas_entry_pressed)
	catalog_actions_row.add_child(_catalog_add_atlas_button)
	_catalog_add_scene_button = Button.new()
	_catalog_add_scene_button.text = "Add Scene Entry"
	_catalog_add_scene_button.pressed.connect(_on_add_catalog_scene_entry_pressed)
	catalog_actions_row.add_child(_catalog_add_scene_button)
	_catalog_validate_button = Button.new()
	_catalog_validate_button.text = "Validate Catalog"
	_catalog_validate_button.pressed.connect(_on_validate_catalog_pressed)
	catalog_actions_row.add_child(_catalog_validate_button)
	root.add_child(catalog_actions_row)

	var default_tiles_title = Label.new()
	default_tiles_title.text = "Default Target Tiles"
	root.add_child(default_tiles_title)
	var default_catalog_row = HBoxContainer.new()
	_default_floor_catalog_option = _new_catalog_option("floor")
	_default_floor_catalog_option.item_selected.connect(_on_default_floor_catalog_selected)
	default_catalog_row.add_child(_wrap_labeled("Floor Catalog", _default_floor_catalog_option))
	_default_wall_catalog_option = _new_catalog_option("wall")
	_default_wall_catalog_option.item_selected.connect(_on_default_wall_catalog_selected)
	default_catalog_row.add_child(_wrap_labeled("Wall Catalog", _default_wall_catalog_option))
	root.add_child(default_catalog_row)
	var default_floor_row = HBoxContainer.new()
	_default_floor_source_spin = _new_int_spin(0, -1, 4096)
	_default_floor_atlas_x_spin = _new_int_spin(0, -1, 4096)
	_default_floor_atlas_y_spin = _new_int_spin(0, -1, 4096)
	_default_floor_alternative_spin = _new_int_spin(0, 0, 4096)
	_default_floor_source_spin.value_changed.connect(_on_default_tile_setting_changed)
	_default_floor_atlas_x_spin.value_changed.connect(_on_default_tile_setting_changed)
	_default_floor_atlas_y_spin.value_changed.connect(_on_default_tile_setting_changed)
	_default_floor_alternative_spin.value_changed.connect(_on_default_tile_setting_changed)
	default_floor_row.add_child(_wrap_labeled("Floor Src", _default_floor_source_spin))
	default_floor_row.add_child(_wrap_labeled("Atlas X", _default_floor_atlas_x_spin))
	default_floor_row.add_child(_wrap_labeled("Atlas Y", _default_floor_atlas_y_spin))
	default_floor_row.add_child(_wrap_labeled("Alt", _default_floor_alternative_spin))
	root.add_child(default_floor_row)

	var default_wall_row = HBoxContainer.new()
	_default_wall_source_spin = _new_int_spin(0, -1, 4096)
	_default_wall_atlas_x_spin = _new_int_spin(1, -1, 4096)
	_default_wall_atlas_y_spin = _new_int_spin(0, -1, 4096)
	_default_wall_alternative_spin = _new_int_spin(0, 0, 4096)
	_default_wall_source_spin.value_changed.connect(_on_default_tile_setting_changed)
	_default_wall_atlas_x_spin.value_changed.connect(_on_default_tile_setting_changed)
	_default_wall_atlas_y_spin.value_changed.connect(_on_default_tile_setting_changed)
	_default_wall_alternative_spin.value_changed.connect(_on_default_tile_setting_changed)
	default_wall_row.add_child(_wrap_labeled("Wall Src", _default_wall_source_spin))
	default_wall_row.add_child(_wrap_labeled("Atlas X", _default_wall_atlas_x_spin))
	default_wall_row.add_child(_wrap_labeled("Atlas Y", _default_wall_atlas_y_spin))
	default_wall_row.add_child(_wrap_labeled("Alt", _default_wall_alternative_spin))
	root.add_child(default_wall_row)

	var default_tile_action_row = HBoxContainer.new()
	_default_tile_read_button = Button.new()
	_default_tile_read_button.text = "Read Target Tiles"
	_default_tile_read_button.pressed.connect(_on_read_default_tiles_pressed)
	default_tile_action_row.add_child(_default_tile_read_button)
	_default_tile_apply_button = Button.new()
	_default_tile_apply_button.text = "Apply Target Tiles"
	_default_tile_apply_button.pressed.connect(_on_apply_default_tiles_pressed)
	default_tile_action_row.add_child(_default_tile_apply_button)
	root.add_child(default_tile_action_row)

	var target_asset_title = Label.new()
	target_asset_title.text = "Target TileSet / Atlas"
	root.add_child(target_asset_title)
	if _can_use_editor_resource_picker():
		_target_tile_set_picker = EditorResourcePicker.new()
		_target_tile_set_picker.base_type = "TileSet"
		_target_tile_set_picker.resource_changed.connect(_on_target_tile_set_changed)
		root.add_child(_wrap_labeled("TileSet", _target_tile_set_picker))
	var target_atlas_row = HBoxContainer.new()
	_target_atlas_path_edit = LineEdit.new()
	_target_atlas_path_edit.placeholder_text = "res://path/to/tiles.png"
	_target_atlas_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_target_atlas_path_edit.text_changed.connect(_on_target_atlas_path_changed)
	target_atlas_row.add_child(_wrap_labeled("Atlas Image", _target_atlas_path_edit))
	_target_atlas_browse_button = Button.new()
	_target_atlas_browse_button.text = "Browse"
	_target_atlas_browse_button.pressed.connect(_on_target_atlas_browse_pressed)
	target_atlas_row.add_child(_target_atlas_browse_button)
	_target_atlas_apply_button = Button.new()
	_target_atlas_apply_button.text = "Apply Atlas"
	_target_atlas_apply_button.pressed.connect(_on_apply_target_atlas_pressed)
	target_atlas_row.add_child(_target_atlas_apply_button)
	root.add_child(target_atlas_row)

	var sample_row = HBoxContainer.new()
	_target_sample_option = OptionButton.new()
	for preset in _target_atlas_presets():
		_target_sample_option.add_item(String(preset.get("label", "")))
	sample_row.add_child(_wrap_labeled("Sample", _target_sample_option))
	_target_sample_apply_button = Button.new()
	_target_sample_apply_button.text = "Apply Sample"
	_target_sample_apply_button.pressed.connect(_on_apply_sample_target_atlas_pressed)
	sample_row.add_child(_target_sample_apply_button)
	_select_display_layer_button = Button.new()
	_select_display_layer_button.text = "Select Internal TileMapLayer"
	_select_display_layer_button.pressed.connect(_on_select_display_layer_pressed)
	sample_row.add_child(_select_display_layer_button)
	root.add_child(sample_row)

	_tile_catalog_option = _new_catalog_option("floor")
	_tile_catalog_option.item_selected.connect(_on_tile_catalog_selected)
	root.add_child(_wrap_labeled("Tile Catalog", _tile_catalog_option))
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

	_overlay_item_key_edit = LineEdit.new()
	_overlay_item_key_edit.placeholder_text = "overlay item key"
	_overlay_item_key_edit.text = _overlay_item_key
	_overlay_item_key_edit.text_changed.connect(_on_overlay_item_key_changed)
	var overlay_item_row = HBoxContainer.new()
	overlay_item_row.add_child(_wrap_labeled("Overlay Item", _overlay_item_key_edit))
	_overlay_item_key_option = OptionButton.new()
	_overlay_item_key_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_overlay_item_key_option.item_selected.connect(_on_overlay_item_key_option_selected)
	overlay_item_row.add_child(_wrap_labeled("Known", _overlay_item_key_option))
	root.add_child(overlay_item_row)

	_object_id_edit = LineEdit.new()
	_object_id_edit.placeholder_text = "object_id"
	_object_id_edit.text_changed.connect(_on_object_payload_changed)
	_object_catalog_option = _new_catalog_option("object")
	_object_catalog_option.item_selected.connect(_on_object_catalog_selected)
	root.add_child(_wrap_labeled("Object Key", _object_catalog_option))
	root.add_child(_wrap_labeled("Object", _object_id_edit))
	_object_rotation_spin = _new_int_spin(0, -360, 360)
	_object_rotation_spin.value_changed.connect(_on_object_rotation_changed)
	_object_variant_edit = LineEdit.new()
	_object_variant_edit.placeholder_text = "variant"
	_object_variant_edit.text_changed.connect(_on_object_payload_changed)
	var object_variant_row = HBoxContainer.new()
	object_variant_row.add_child(_wrap_labeled("Rotation", _object_rotation_spin))
	object_variant_row.add_child(_wrap_labeled("Variant", _object_variant_edit))
	root.add_child(object_variant_row)
	if _can_use_editor_resource_picker():
		_object_database_picker = EditorResourcePicker.new()
		_object_database_picker.base_type = "HexObjectDatabaseResource"
		_object_database_picker.resource_changed.connect(_on_object_database_changed)
		root.add_child(_wrap_labeled("Object DB", _object_database_picker))
	_object_definition_tree = Tree.new()
	_object_definition_tree.hide_root = true
	_object_definition_tree.columns = 4
	_object_definition_tree.set_column_titles_visible(true)
	_object_definition_tree.set_column_title(0, "id")
	_object_definition_tree.set_column_title(1, "scene")
	_object_definition_tree.set_column_title(2, "tags")
	_object_definition_tree.set_column_title(3, "defaults")
	_object_definition_tree.custom_minimum_size = Vector2(0, 120)
	_object_definition_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_object_definition_tree.item_selected.connect(_on_object_definition_tree_selected)
	root.add_child(_object_definition_tree)
	if _can_use_editor_resource_picker():
		_object_definition_scene_picker = EditorResourcePicker.new()
		_object_definition_scene_picker.base_type = "PackedScene"
		_object_definition_scene_picker.resource_changed.connect(_on_object_definition_scene_changed)
		root.add_child(_wrap_labeled("Definition Scene", _object_definition_scene_picker))
	var object_definition_actions = HBoxContainer.new()
	_object_add_definition_button = Button.new()
	_object_add_definition_button.text = "Add Object Definition"
	_object_add_definition_button.pressed.connect(_on_add_object_definition_pressed)
	object_definition_actions.add_child(_object_add_definition_button)
	root.add_child(object_definition_actions)
	_object_palette_status_label = _new_detail_label()
	root.add_child(_wrap_labeled("Object Palette", _object_palette_status_label))
	_object_properties_edit = LineEdit.new()
	_object_properties_edit.placeholder_text = "{\"key\":\"value\"}"
	_object_properties_edit.text_changed.connect(_on_object_payload_changed)
	root.add_child(_wrap_labeled("Properties", _object_properties_edit))
	_object_property_editor = VBoxContainer.new()
	_object_property_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(_wrap_labeled("Placement Properties", _object_property_editor))
	_object_properties_table = Tree.new()
	_object_properties_table.columns = 2
	_object_properties_table.hide_root = true
	_object_properties_table.custom_minimum_size = Vector2(0.0, 72.0)
	_object_properties_table.set_column_title(0, "Key")
	_object_properties_table.set_column_title(1, "Value")
	_object_properties_table.set_column_titles_visible(true)
	root.add_child(_wrap_labeled("Property Table", _object_properties_table))
	_object_spawn_condition_edit = LineEdit.new()
	_object_spawn_condition_edit.placeholder_text = "spawn condition"
	_object_spawn_condition_edit.text_changed.connect(_on_object_payload_changed)
	root.add_child(_wrap_labeled("Spawn", _object_spawn_condition_edit))

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
	_validation_dashboard = HexMapValidationDashboard.new()
	_validation_dashboard.validate_requested.connect(_on_validate_document_pressed)
	_validation_dashboard.issue_selected.connect(_on_validation_issue_selected)
	root.add_child(_validation_dashboard)
	_copy_debug_report_button = Button.new()
	_copy_debug_report_button.text = "Copy Debug Report"
	_copy_debug_report_button.pressed.connect(_on_copy_debug_report_pressed)
	root.add_child(_copy_debug_report_button)
	_sync_resource_pickers()
	_refresh_layer_stack_screen()
	_refresh_catalog_entries()
	_refresh_object_palette()
	_refresh_object_property_editor()
	_refresh_target_status_detail()
	_refresh_last_edit_detail()
	_refresh_persistence_detail()
	_refresh_payload_controls_visibility()
	_refresh_overlay_item_key_options()
	_refresh_action_button_states()


func _apply_hex_tile_map_layer_hit(hit: Dictionary) -> bool:
	var hex_layer := _target_layer as HexTileMapLayer
	if hex_layer == null:
		return false
	var hex = hit["hex"]
	var visual_hex = hit.get("visual_hex", hex)
	_refresh_plain_target_tile_options_from_document(_document)
	var target_used_cells_before = _target_used_cell_count()
	var display_before = _target_display_state(hex, visual_hex)
	var command = _build_hex_tile_map_layer_edit_command(hex_layer, hex)
	if command.is_empty():
		_set_status("No editable cell.")
		return false
	var before_state: Dictionary = command["before"]
	var after_state: Dictionary = command["after"]
	var applied = _commit_hex_tile_map_layer_edit_command(
		command,
		"Hex map edit %s" % EDIT_MODE_NAMES[_edit_mode],
		_target_cell_apply_reason_for_mode()
	)
	var target_used_cells_after = _target_used_cell_count()
	var display_after = _target_display_state(hex, visual_hex)
	_last_edit_hit = hit.duplicate(true)
	_last_edit_status = _build_last_edit_trace_from_states(
		hit,
		before_state,
		after_state,
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


func _build_hex_tile_map_layer_edit_command(hex_layer: HexTileMapLayer, hex) -> Dictionary:
	var before = hex_layer.cell_edit_state(hex)
	return HexMapEditMutationBuilder.build_hex_tile_map_layer_edit_command(
		before,
		hex,
		_edit_mode,
		_tile_payload,
		_overlay_item_key,
		_object_payload,
		_label_payload,
		EDIT_MODE_NAMES
	)


func _commit_hex_tile_map_layer_edit_command(command: Dictionary, action_name: String, target_apply_reason: String) -> bool:
	_last_applied_to_target = false
	if _undo_redo != null:
		var inverse = (_target_layer as HexTileMapLayer).inverse_edit_command(command)
		_undo_redo.create_action(action_name)
		_undo_redo.add_do_method(Callable(self, "_apply_hex_tile_map_layer_edit_command").bind(command.duplicate(true), target_apply_reason))
		_undo_redo.add_undo_method(Callable(self, "_apply_hex_tile_map_layer_edit_command").bind(inverse, target_apply_reason))
		_undo_redo.commit_action()
	else:
		_apply_hex_tile_map_layer_edit_command(command, target_apply_reason)
	return _last_applied_to_target


func _apply_hex_tile_map_layer_edit_command(command: Dictionary, target_apply_reason: String = "") -> bool:
	_target_layer = _resolve_target_layer()
	if _target_layer == null or not is_instance_valid(_target_layer) or not (_target_layer is HexTileMapLayer):
		_last_applied_to_target = false
		_last_target_apply_reason = "No editable target layer."
		_refresh_target_status_detail()
		return false
	_sync_default_tile_settings_for_target_if_needed()
	if _default_target_tile_settings_explicit:
		_apply_default_tile_settings_to_target(false)
	var state: Dictionary = command.get("after", {})
	_apply_hex_cell_state_to_document(_document, state)
	var applied = (_target_layer as HexTileMapLayer).apply_edit_command(command)
	_last_applied_to_target = applied
	_last_target_apply_reason = target_apply_reason if target_apply_reason != "" else "Applied cell to HexTileMapLayer."
	_refresh_overlay_item_key_options()
	_refresh_last_hit_display()
	_refresh_target_status_detail()
	_refresh_state_labels()
	return applied


func _apply_hex_cell_state_to_document(document: HexMapDocumentResource, state: Dictionary) -> bool:
	if document == null or state.is_empty() or not state.has("hex"):
		return false
	var hex = _state_hex(state)
	var exists := bool(state.get("exists", true))
	HexMapDocumentAdapter.set_cell_exists(document, hex, exists)
	if not exists:
		return true
	HexMapDocumentAdapter.set_wall(document, hex, bool(state.get("wall", false)))
	var tile_entries: Array = []
	for entry in state.get("tile_overrides", []):
		if entry is Dictionary:
			tile_entries.append(_entry_with_cell(entry as Dictionary, hex))
	for entry in state.get("overlay_tiles", []):
			if entry is Dictionary:
				var overlay_entry = _entry_with_cell(entry as Dictionary, hex)
				overlay_entry["kind"] = HexMapDocumentAdapter.KIND_OVERLAY
				tile_entries.append(overlay_entry)
	HexMapDocumentAdapter.replace_cell_payloads(
		document,
		hex,
		tile_entries,
		_state_entries_with_cell(state.get("objects", []), hex),
		_state_entries_with_cell(state.get("labels", []), hex)
	)
	return true


func _object_properties_from_payload(payload: Dictionary) -> Dictionary:
	var properties = payload.get("properties", {})
	if properties is Dictionary:
		return properties.duplicate(true)
	return {}


func object_definition_rows() -> Array[Dictionary]:
	var database = _object_database as HexObjectDatabaseResource
	if database == null:
		return []
	var rows: Array[Dictionary] = []
	for definition in database.definitions:
		if definition == null:
			continue
		rows.append({
			"id": String(definition.get("id")),
			"display_name": String(definition.get("display_name")),
			"scene": "PackedScene" if definition.get("scene") is PackedScene else "missing scene",
			"tags": _packed_string_array_text(definition.get("tags")),
			"defaults": _object_default_properties_text(definition.get("default_properties")),
		})
	return rows


func object_property_control_types() -> Dictionary:
	var result := {}
	for key in _object_property_controls.keys():
		var control = _object_property_controls[key]
		if control is CheckBox:
			result[key] = "bool"
		elif control is SpinBox:
			result[key] = "number"
		elif control is LineEdit:
			result[key] = "string"
		elif control is OptionButton:
			result[key] = "enum"
		else:
			result[key] = "resource"
	return result


func _refresh_object_palette() -> void:
	_refresh_object_definition_tree()
	_sync_selected_object_definition_scene_picker()
	_refresh_object_palette_status()


func _refresh_object_definition_tree() -> void:
	if _object_definition_tree == null:
		return
	_refreshing_object_definition_tree = true
	_object_definition_tree.clear()
	var root_item = _object_definition_tree.create_item()
	for row in object_definition_rows():
		var item = _object_definition_tree.create_item(root_item)
		item.set_text(0, String(row.get("id", "")))
		item.set_text(1, String(row.get("scene", "")))
		item.set_text(2, String(row.get("tags", "")))
		item.set_text(3, String(row.get("defaults", "")))
		if String(row.get("id", "")) == _selected_object_definition_id:
			item.select(0)
	_refreshing_object_definition_tree = false


func _refresh_object_palette_status() -> void:
	if _object_palette_status_label == null:
		return
	var database = _object_database as HexObjectDatabaseResource
	if database == null:
		_object_palette_status_label.text = "No object database selected."
		return
	_object_palette_status_label.text = "definitions=%d selected=%s" % [
		database.definitions.size(),
		_selected_object_definition_id if _selected_object_definition_id != "" else "none",
	]


func _sync_selected_object_definition_scene_picker() -> void:
	if _object_definition_scene_picker == null:
		return
	var definition = _selected_object_definition()
	_object_definition_scene_picker.edited_resource = definition.scene if definition != null else null


func _ensure_object_database() -> HexObjectDatabaseResource:
	if _object_database == null:
		_object_database = HexObjectDatabaseResource.new()
	return _object_database as HexObjectDatabaseResource


func _selected_object_definition():
	if _object_database == null or not _object_database.has_method("definition_for_id"):
		return null
	return _object_database.definition_for_id(_selected_object_definition_id)


func _select_object_definition(definition_id: String) -> void:
	_selected_object_definition_id = definition_id
	if definition_id != "":
		_object_payload["object_id"] = definition_id
		if _object_id_edit != null:
			_object_id_edit.text = definition_id
		_select_object_key_option_by_key(definition_id)
	_apply_selected_definition_defaults()
	_refresh_object_palette()
	_refresh_object_property_editor()
	_refresh_target_status_detail()


func _apply_selected_definition_defaults() -> void:
	var definition = _selected_object_definition()
	if definition == null:
		return
	var defaults = definition.get("default_properties")
	if not defaults is Dictionary:
		return
	var properties = _object_properties_from_payload(_object_payload)
	for key in defaults.keys():
		if not properties.has(key):
			properties[key] = _object_default_property_value(defaults[key])
	_object_payload["properties"] = properties


func _unique_object_definition_id(prefix: String) -> String:
	var database = _ensure_object_database()
	var index: int = database.definitions.size() + 1
	var key = "%s_%d" % [prefix, index]
	while database.has_definition(key):
		index += 1
		key = "%s_%d" % [prefix, index]
	return key


func _object_default_properties_text(defaults) -> String:
	if not defaults is Dictionary:
		return "none"
	var keys = (defaults as Dictionary).keys()
	keys.sort()
	return ",".join(PackedStringArray(keys))


func _packed_string_array_text(value) -> String:
	if value is PackedStringArray:
		return ",".join(value)
	if value is Array:
		var parts := PackedStringArray()
		for item in value:
			parts.append(String(item))
		return ",".join(parts)
	return ""


func _refresh_object_properties_table() -> void:
	if _object_properties_table == null:
		return
	_object_properties_table.clear()
	var root_item = _object_properties_table.create_item()
	var properties = _object_properties_from_payload(_object_payload)
	var keys = properties.keys()
	keys.sort()
	for key in keys:
		var row = _object_properties_table.create_item(root_item)
		row.set_text(0, String(key))
		row.set_text(1, str(properties[key]))


func _refresh_object_property_editor() -> void:
	if _object_property_editor == null:
		return
	for child in _object_property_editor.get_children():
		child.queue_free()
	_object_property_controls.clear()
	var property_keys = _object_property_keys_for_editor()
	var properties = _object_properties_from_payload(_object_payload)
	for key in property_keys:
		var schema = _object_property_schema_for_key(key)
		var value = properties.get(key, _object_default_property_value(schema))
		var control = _object_property_control_for_value(key, value, schema)
		_object_property_controls[key] = control
		_object_property_editor.add_child(_wrap_labeled(String(key), control))


func _object_property_keys_for_editor() -> Array:
	var keys := []
	var definition = _selected_object_definition()
	if definition != null:
		var defaults = definition.get("default_properties")
		if defaults is Dictionary:
			for key in (defaults as Dictionary).keys():
				if not keys.has(key):
					keys.append(key)
	var properties = _object_properties_from_payload(_object_payload)
	for key in properties.keys():
		if not keys.has(key):
			keys.append(key)
	keys.sort()
	return keys


func _object_property_schema_for_key(key) -> Variant:
	var definition = _selected_object_definition()
	if definition == null:
		return _object_properties_from_payload(_object_payload).get(key, "")
	var defaults = definition.get("default_properties")
	if defaults is Dictionary and (defaults as Dictionary).has(key):
		return (defaults as Dictionary)[key]
	return _object_properties_from_payload(_object_payload).get(key, "")


func _object_property_control_for_value(key, value, schema) -> Control:
	if _object_property_is_enum_schema(schema):
		return _new_object_property_enum_control(key, value, schema)
	if value is bool:
		var check = CheckBox.new()
		check.button_pressed = bool(value)
		check.toggled.connect(_on_object_property_bool_toggled.bind(key))
		return check
	if value is int or value is float:
		var spin = SpinBox.new()
		spin.min_value = -1000000
		spin.max_value = 1000000
		spin.allow_greater = true
		spin.allow_lesser = true
		spin.step = 1 if value is int else 0.01
		spin.value = float(value)
		spin.value_changed.connect(_on_object_property_number_changed.bind(key, value is float))
		return spin
	if value is Resource and _can_use_editor_resource_picker():
		var picker = EditorResourcePicker.new()
		picker.base_type = "Resource"
		picker.edited_resource = value
		picker.resource_changed.connect(_on_object_property_resource_changed.bind(key))
		return picker
	var edit = LineEdit.new()
	edit.text = String(value)
	edit.text_changed.connect(_on_object_property_text_changed.bind(key))
	return edit


func _new_object_property_enum_control(key, value, schema) -> OptionButton:
	var option = OptionButton.new()
	var options = _object_property_enum_options(schema)
	var selected_value = String(value)
	if selected_value == "" and _object_property_is_enum_schema(schema):
		selected_value = String((schema as Dictionary).get("value", ""))
	var selected_index := 0
	for index in range(options.size()):
		var option_value = String(options[index])
		option.add_item(option_value)
		option.set_item_metadata(index, option_value)
		if option_value == selected_value:
			selected_index = index
	option.select(selected_index)
	option.item_selected.connect(_on_object_property_enum_selected.bind(key, option))
	if options.size() > 0:
		_set_object_property_value(key, String(option.get_item_metadata(selected_index)), false)
	return option


func _object_property_is_enum_schema(schema) -> bool:
	return schema is Dictionary \
		and String((schema as Dictionary).get("type", "")) == "enum" \
		and (schema as Dictionary).get("options", []) is Array


func _object_property_enum_options(schema) -> Array:
	if not _object_property_is_enum_schema(schema):
		return []
	return (schema as Dictionary).get("options", [])


func _object_default_property_value(schema):
	if _object_property_is_enum_schema(schema):
		var schema_dict := schema as Dictionary
		var options = _object_property_enum_options(schema)
		if schema_dict.has("value"):
			return String(schema_dict.get("value", ""))
		return String(options[0]) if options.size() > 0 else ""
	return schema


func _on_object_property_bool_toggled(pressed: bool, key) -> void:
	_set_object_property_value(key, pressed)


func _on_object_property_number_changed(value: float, key, keep_float: bool) -> void:
	_set_object_property_value(key, value if keep_float else int(value))


func _on_object_property_text_changed(text: String, key) -> void:
	_set_object_property_value(key, text)


func _on_object_property_enum_selected(index: int, key, option: OptionButton) -> void:
	if option == null or index < 0 or index >= option.item_count:
		return
	_set_object_property_value(key, String(option.get_item_metadata(index)))


func _on_object_property_resource_changed(resource: Resource, key) -> void:
	_set_object_property_value(key, resource)


func _set_object_property_value(key, value, refresh_table: bool = true) -> void:
	var properties = _object_properties_from_payload(_object_payload)
	properties[key] = value
	_object_payload["properties"] = properties
	if _object_properties_edit != null:
		_object_properties_edit.text = JSON.stringify(properties)
	if refresh_table:
		_refresh_object_properties_table()
	_refresh_target_status_detail()


func _state_entries_with_cell(entries_value, hex) -> Array:
	var result: Array = []
	if not entries_value is Array:
		return result
	for entry in entries_value:
		if entry is Dictionary:
			result.append(_entry_with_cell(entry as Dictionary, hex))
	return result


func _entry_with_cell(entry: Dictionary, hex) -> Dictionary:
	var result = entry.duplicate(true)
	var normalized = HexVector.apply_basis(hex.q, hex.s, hex.r)
	result["cell"] = Vector3i(normalized.q, normalized.s, normalized.r)
	return result


func _replace_document_entries_for_cell(entries: Array, hex, replacement: Array) -> void:
	var key = hex.key()
	for index in range(entries.size() - 1, -1, -1):
		if entries[index] is Dictionary and _entry_cell_key(entries[index] as Dictionary) == key:
			entries.remove_at(index)
	for entry in replacement:
		if entry is Dictionary:
			entries.append((entry as Dictionary).duplicate(true))


func _state_hex(state: Dictionary):
	var value = state.get("hex", HexVector.zero())
	if value is HexVector:
		return HexVector.apply_basis(value.q, value.s, value.r)
	if typeof(value) == TYPE_VECTOR3I:
		return HexVector.apply_basis(value.x, value.y, value.z)
	return HexVector.zero()


func _ensure_resource_component(components: Array, component: Vector3i) -> void:
	if _resource_component_index(components, component) >= 0:
		return
	components.append(component)


func _remove_resource_component(components: Array, component: Vector3i) -> void:
	for index in range(components.size() - 1, -1, -1):
		if components[index] == component:
			components.remove_at(index)


func _resource_component_index(components: Array, component: Vector3i) -> int:
	for index in range(components.size()):
		if components[index] == component:
			return index
	return -1


func _commit_document_change(before, after, action_name: String, hex = null, target_apply_reason: String = "") -> bool:
	_last_applied_to_target = false
	if _undo_redo != null:
		_undo_redo.create_action(action_name)
		_undo_redo.add_do_method(Callable(self, "_replace_document_state").bind(after))
		_undo_redo.add_do_method(Callable(self, "_apply_document_change_to_target").bind(hex, target_apply_reason))
		_undo_redo.add_undo_method(Callable(self, "_replace_document_state").bind(before))
		_undo_redo.add_undo_method(Callable(self, "_apply_document_change_to_target").bind(hex, target_apply_reason))
		_undo_redo.commit_action()
	else:
		_replace_document_state(after)
		_apply_document_change_to_target(hex, target_apply_reason)
	_document_dirty = true
	_refresh_state_labels()
	return _last_applied_to_target


func _replace_document_state(snapshot) -> void:
	HexMapDocumentAdapter.copy_document_state(_document, snapshot)
	_refresh_overlay_item_key_options()
	_refresh_state_labels()


func _apply_document_change_to_target(hex = null, target_apply_reason: String = "") -> bool:
	_target_layer = _resolve_target_layer()
	if _target_layer is HexTileMapLayer and hex != null:
		if _document == null or not is_instance_valid(_target_layer):
			_last_applied_to_target = false
			_last_target_apply_reason = "No editable target layer."
			_refresh_target_status_detail()
			return false
		_sync_default_tile_settings_for_target_if_needed()
		if _default_target_tile_settings_explicit:
			_apply_default_tile_settings_to_target(false)
		var applied = (_target_layer as HexTileMapLayer).apply_document_cell(_document, hex)
		_last_applied_to_target = applied
		_last_target_apply_reason = target_apply_reason if target_apply_reason != "" else "Applied cell to HexTileMapLayer."
		_refresh_last_hit_display()
		_refresh_target_status_detail()
		return applied
	return _apply_document_to_target()


func _apply_document_to_target() -> bool:
	_target_layer = _resolve_target_layer()
	if _target_layer == null or _document == null or not is_instance_valid(_target_layer):
		_last_applied_to_target = false
		_last_target_apply_reason = "No editable target layer."
		_refresh_target_status_detail()
		return false
	_sync_default_tile_settings_for_target_if_needed()
	if _target_layer is HexTileMapLayer:
		var hex_layer := _target_layer as HexTileMapLayer
		if _default_target_tile_settings_explicit:
			_apply_default_tile_settings_to_target(false)
		hex_layer.apply_document(_document)
		_refresh_last_hit_display()
		_last_applied_to_target = true
		_last_target_apply_reason = "Applied document to HexTileMapLayer."
		_refresh_target_status_detail()
		return true
	HexMapDocumentAdapter.apply_to_tile_map_layer(
		_document,
		_target_layer,
		_plain_target_tile_options_for_document_apply()
	)
	_last_applied_to_target = true
	_last_target_apply_reason = "Applied document to TileMapLayer."
	_refresh_target_status_detail()
	return true


func _local_hit(local_pos: Vector2) -> Dictionary:
	return HexMapEditViewportInputAdapter.local_hit(local_pos, _target_layer, _document, hex_size)


func _on_mode_selected(index: int) -> void:
	set_edit_mode(index)


func _on_layer_stack_template_selected(index: int) -> void:
	if _layer_stack_template_option == null:
		return
	var template_id = String(_layer_stack_template_option.get_item_metadata(index))
	_layer_stack_resource = HexLayerStackResource.minimal_runtime_template() if template_id == "minimal" else HexLayerStackResource.standard_template()
	_selected_layer_stack_role = ""
	_refresh_layer_stack_screen()
	_set_status("Layer stack template selected.")


func _on_layer_stack_role_selected() -> void:
	if _layer_stack_role_tree == null:
		return
	var selected = _layer_stack_role_tree.get_selected()
	if selected == null:
		return
	_selected_layer_stack_role = selected.get_text(0)
	_refresh_action_button_states()


func _on_create_missing_layers_pressed() -> void:
	if _apply_layer_stack_to_target(false):
		_set_status("Created missing layer stack roles.")
	else:
		_set_status("Layer stack requires a HexTileMapLayer target and document.")


func _on_apply_layer_stack_document_pressed() -> void:
	if _apply_layer_stack_to_target(true):
		_document_dirty = true
		_refresh_state_labels()
		_set_status("Applied document to layer stack.")
	else:
		_set_status("Layer stack apply requires a HexTileMapLayer target and document.")


func _on_clear_layer_stack_role_pressed() -> void:
	var role = _selected_layer_stack_role
	if role == "":
		_set_status("No layer stack role selected.")
		return
	var target = _target_layer as HexTileMapLayer
	if target == null:
		_set_status("Clear Role requires a HexTileMapLayer target.")
		return
	var layer = target.layer_for_stack_role(role)
	if layer is TileMapLayer:
		(layer as TileMapLayer).clear()
		_set_status("Cleared layer stack role: %s." % role)
	else:
		_set_status("Layer stack role has no TileMapLayer: %s." % role)
	_refresh_layer_stack_screen()


func _on_document_path_changed(text: String) -> void:
	_document_path = text.strip_edges()
	_refresh_action_button_states()


func _on_import_map_path_changed(text: String) -> void:
	_import_map_path = text.strip_edges()
	_refresh_action_button_states()


func _on_document_resource_changed(resource: Resource) -> void:
	if resource is HexMapDocumentResource:
		_document = _document_for_editor(resource)
		_document_source = DOCUMENT_SOURCE_PROVIDED
		_document_dirty = false
		if resource.resource_path != "":
			set_document_path(resource.resource_path)
		else:
			set_document_path("")
	elif resource == null:
		_document = null
		_document_source = DOCUMENT_SOURCE_NONE
		_document_dirty = false
		set_document_path("")
	_refresh_plain_target_tile_options_from_document(_document)
	_refresh_overlay_item_key_options()
	_refresh_state_labels()
	_publish_session_document("edit.resource_picker")


func _on_import_map_resource_changed(resource: Resource) -> void:
	if resource is HexMapResource:
		set_import_map_resource(resource)
	elif resource == null:
		set_import_map_resource(null)


func _on_object_database_changed(resource: Resource) -> void:
	set_object_database(resource)


func _on_object_definition_tree_selected() -> void:
	if _refreshing_object_definition_tree:
		return
	if _object_definition_tree == null:
		return
	var selected = _object_definition_tree.get_selected()
	if selected == null:
		return
	var definition_id = selected.get_text(0)
	if definition_id == "":
		return
	_select_object_definition(definition_id)


func _on_object_definition_scene_changed(resource: Resource) -> void:
	var definition = _selected_object_definition()
	if definition == null:
		_set_status("No object definition selected.")
		return
	if resource == null:
		definition.scene = null
		_refresh_object_palette()
		_set_status("Object definition scene cleared.")
		return
	if not (resource is PackedScene):
		_set_status("Selected resource is not a PackedScene.")
		return
	definition.scene = resource as PackedScene
	_refresh_object_palette()
	_set_status("Object definition scene selected.")


func _on_add_object_definition_pressed() -> void:
	var database = _ensure_object_database()
	if database == null:
		_set_status("No object database selected.")
		return
	var definition = HexObjectDefinitionResource.new()
	definition.id = _unique_object_definition_id("object.definition")
	definition.display_name = definition.id
	definition.tags = PackedStringArray(["object"])
	database.add_definition(definition)
	_select_object_definition(definition.id)
	_refresh_object_palette()
	_sync_payload_controls()
	_set_status("Added object definition.")


func _on_label_database_changed(resource: Resource) -> void:
	_label_database = resource


func _on_export_path_changed(text: String) -> void:
	_export_path = text.strip_edges()
	_refresh_action_button_states()


func _on_new_document_pressed() -> void:
	new_document()


func new_document() -> HexMapDocumentResource:
	_document = HexMapDocumentResource.new()
	_document_source = DOCUMENT_SOURCE_NEW
	_document_dirty = true
	set_document_path("")
	_last_validation_result = null
	_selected_validation_issue.clear()
	_validation_focus_status.clear()
	if _validation_dashboard != null:
		_validation_dashboard.clear_result("No validation run.")
	_refresh_plain_target_tile_options_from_document(_document)
	_sync_resource_pickers()
	_refresh_overlay_item_key_options()
	_refresh_state_labels()
	_set_status("Created new document.")
	_publish_session_document("edit.new_document")
	return _document


func _on_load_document_pressed() -> void:
	var selected_resource = _selected_document_resource()
	if selected_resource != null:
		_document = _document_for_editor(selected_resource)
		_document_source = DOCUMENT_SOURCE_LOAD
		_document_dirty = false
		if selected_resource.resource_path != "":
			set_document_path(selected_resource.resource_path)
		else:
			set_document_path("")
		_refresh_plain_target_tile_options_from_document(_document)
		_read_target_tile_settings(false)
		_apply_document_to_target()
		_refresh_overlay_item_key_options()
		_refresh_state_labels()
		_set_status("Loaded selected document.")
		_publish_session_document("edit.load_selected_document")
		return
	load_document()


func _on_save_document_pressed() -> void:
	if _document_path != "":
		save_document(_document_path)
		return
	_on_save_document_as_pressed()


func _on_save_document_as_pressed() -> void:
	var default_filename = _document_path.get_file() if _document_path != "" else "hex_map_document.tres"
	if not _popup_resource_file_dialog(
		EditorFileDialog.FILE_MODE_SAVE_FILE,
		HexMapEditorPathSelector.TRES_FILTERS,
		Callable(self, "_on_document_save_file_selected"),
		default_filename
	):
		_set_status("Document Save As is available in the editor.")


func _on_import_map_pressed() -> void:
	if _import_map_resource != null:
		import_map_resource(_import_map_resource)
		_apply_document_to_target()
		if _target_layer != null and is_instance_valid(_target_layer):
			_select_target_in_editor_if_possible()
		_set_status("Imported selected HexMapResource.")
		return
	import_map_resource_from_path()


func _on_export_pressed() -> void:
	if _export_path == "":
		_on_export_save_as_pressed()
		return
	export_map_resource_to_path()


func _on_document_browse_pressed() -> void:
	if not _popup_resource_file_dialog(
		EditorFileDialog.FILE_MODE_OPEN_FILE,
		HexMapEditorPathSelector.TRES_FILTERS,
		Callable(self, "_on_document_file_selected")
	):
		_set_status("Document browse is available in the editor.")


func _on_document_file_selected(path: String) -> void:
	load_document(path)


func _on_document_save_file_selected(path: String) -> void:
	save_document(path)


func _on_import_map_browse_pressed() -> void:
	if not _popup_resource_file_dialog(
		EditorFileDialog.FILE_MODE_OPEN_FILE,
		HexMapEditorPathSelector.TRES_FILTERS,
		Callable(self, "_on_import_map_file_selected")
	):
		_set_status("Import map browse is available in the editor.")


func _on_import_map_file_selected(path: String) -> void:
	import_map_resource_from_path(path)


func _on_export_save_as_pressed() -> void:
	if not _popup_resource_file_dialog(
		EditorFileDialog.FILE_MODE_SAVE_FILE,
		HexMapEditorPathSelector.TRES_FILTERS,
		Callable(self, "_on_export_file_selected"),
		"hex_map.tres"
	):
		_set_status("Export path is empty.")


func _on_export_file_selected(path: String) -> void:
	export_map_resource_to_path(path)


func _on_target_refresh_pressed() -> void:
	refresh_target_layer_options()


func _on_target_selected(index: int) -> void:
	_target_selection_explicit = index != TARGET_AUTO_INDEX
	_target_layer = _resolve_target_layer()
	_ensure_document_from_target_if_needed()
	_refresh_plain_target_tile_options_from_document(_document)
	_read_target_tile_settings(false)
	if _target_selection_explicit:
		_select_target_in_editor_if_possible()
	_refresh_layer_stack_screen()
	_refresh_state_labels()


func _on_tile_payload_changed(_value: float) -> void:
	_tile_payload = {
		"source_id": int(_tile_source_spin.value),
		"atlas_coords": Vector2i(int(_tile_atlas_x_spin.value), int(_tile_atlas_y_spin.value)),
		"alternative_tile": int(_tile_alternative_spin.value),
		"catalog_key": "",
	}
	_select_catalog_option_by_key(_tile_catalog_option, "")
	_store_current_tile_payload_for_mode()
	_refresh_target_status_detail()


func _on_tile_catalog_selected(index: int) -> void:
	var key = _catalog_key_from_option(_tile_catalog_option, index)
	if key == "":
		return
	var fallback = HexMapTileAdapter.tile_config(
		int(_tile_source_spin.value),
		Vector2i(int(_tile_atlas_x_spin.value), int(_tile_atlas_y_spin.value)),
		int(_tile_alternative_spin.value)
	)
	var config = _catalog_tile_config(key, fallback)
	if not _apply_catalog_config_to_spins(
		config,
		_tile_source_spin,
		_tile_atlas_x_spin,
		_tile_atlas_y_spin,
		_tile_alternative_spin
	):
		return
	_tile_payload = config.duplicate(true)
	_tile_payload["catalog_key"] = key
	_store_current_tile_payload_for_mode()
	_refresh_target_status_detail()


func _on_catalog_resource_changed(resource: Resource) -> void:
	if resource == null:
		set_tile_catalog(null)
		_set_status("Catalog cleared.")
		return
	if resource is HexTileCatalogResource:
		set_tile_catalog(resource as HexTileCatalogResource)
		_set_status("Catalog selected.")
	else:
		_set_status("Selected resource is not a tile catalog.")


func _on_catalog_tile_set_changed(resource: Resource) -> void:
	var catalog = _ensure_tile_catalog()
	if catalog == null:
		_set_status("No catalog selected.")
		return
	if resource == null:
		catalog.tile_set = null
		_last_catalog_validation_result = null
		_refresh_catalog_entries()
		_set_status("Catalog TileSet cleared.")
		return
	if not (resource is TileSet):
		_set_status("Selected resource is not a TileSet.")
		return
	catalog.tile_set = resource as TileSet
	_last_catalog_validation_result = null
	_refresh_catalog_entries()
	_set_status("Catalog TileSet selected.")


func _on_catalog_scene_changed(resource: Resource) -> void:
	if resource == null:
		_catalog_scene_resource = null
		_set_status("Scene resource cleared.")
		return
	if resource is PackedScene:
		_catalog_scene_resource = resource as PackedScene
		_set_status("Scene resource selected for catalog entry.")
	else:
		_catalog_scene_resource = null
		_set_status("Selected resource is not a PackedScene.")


func _on_add_catalog_atlas_entry_pressed() -> void:
	var catalog = _ensure_tile_catalog()
	if catalog == null:
		_set_status("No catalog selected.")
		return
	var entry = HexTileCatalogEntry.new()
	entry.key = _unique_catalog_key("atlas.entry")
	entry.display_name = entry.key
	entry.entry_type = HexTileCatalogEntry.TYPE_ATLAS
	entry.tags = PackedStringArray(["terrain"])
	catalog.add_entry(entry)
	_last_catalog_validation_result = null
	_refresh_catalog_options()
	_refresh_catalog_entries()
	_set_status("Added atlas catalog entry.")


func _on_add_catalog_scene_entry_pressed() -> void:
	var catalog = _ensure_tile_catalog()
	if catalog == null:
		_set_status("No catalog selected.")
		return
	var entry = HexTileCatalogEntry.new()
	entry.key = _unique_catalog_key("scene.entry")
	entry.display_name = entry.key
	entry.entry_type = HexTileCatalogEntry.TYPE_SCENE
	entry.scene = _catalog_scene_resource
	entry.tags = PackedStringArray(["object"])
	catalog.add_entry(entry)
	_last_catalog_validation_result = null
	_refresh_catalog_options()
	_refresh_catalog_entries()
	_set_status("Added scene catalog entry.")


func _on_validate_catalog_pressed() -> void:
	var catalog = _ensure_tile_catalog()
	_last_catalog_validation_result = HexTileCatalogValidator.validate_catalog(catalog)
	_selected_validation_issue.clear()
	_validation_focus_status.clear()
	if _validation_dashboard != null:
		_validation_dashboard.set_validation_result(_last_catalog_validation_result)
	_refresh_catalog_entries()
	if _last_catalog_validation_result == null:
		_set_status("No catalog selected.")
	else:
		_set_status(
			"Catalog validation complete: %d error(s), %d warning(s)." % [
				_last_catalog_validation_result.error_count(),
				_last_catalog_validation_result.warning_count(),
			]
		)


func _on_overlay_item_key_changed(text: String) -> void:
	_overlay_item_key = text.strip_edges()
	_refresh_target_status_detail()


func _on_overlay_item_key_option_selected(index: int) -> void:
	if _overlay_item_key_option == null:
		return
	var key = _overlay_item_key_option.get_item_text(index)
	if key == "":
		return
	_overlay_item_key = key
	if _overlay_item_key_edit != null:
		_overlay_item_key_edit.text = key
	_refresh_target_status_detail()


func _on_target_tile_set_changed(resource: Resource) -> void:
	if resource is TileSet and _apply_target_tile_set(resource as TileSet):
		_set_status("Applied Target TileSet.")
	else:
		_set_status("No editable target TileSet.")


func _on_target_atlas_path_changed(_text: String) -> void:
	_refresh_action_button_states()


func _on_apply_target_atlas_pressed() -> void:
	var path = _target_atlas_path_edit.text.strip_edges() if _target_atlas_path_edit != null else ""
	if _apply_target_atlas_path(path, HexMapTileAdapter.SAMPLE_TILE_SIZE):
		_set_status("Applied target atlas.")
	else:
		_set_status("Failed to apply target atlas.")


func _on_target_atlas_browse_pressed() -> void:
	if not _popup_resource_file_dialog(
		EditorFileDialog.FILE_MODE_OPEN_FILE,
		HexMapEditorPathSelector.IMAGE_FILTERS,
		Callable(self, "_on_target_atlas_file_selected")
	):
		_set_status("Atlas image browse is available in the editor.")


func _on_target_atlas_file_selected(path: String) -> void:
	if _target_atlas_path_edit != null:
		_target_atlas_path_edit.text = path
	if _apply_target_atlas_path(path, HexMapTileAdapter.SAMPLE_TILE_SIZE):
		_set_status("Applied target atlas.")
	else:
		_set_status("Failed to apply target atlas.")


func _on_apply_sample_target_atlas_pressed() -> void:
	var presets = _target_atlas_presets()
	var index = _target_sample_option.selected if _target_sample_option != null else 0
	if index < 0 or index >= presets.size():
		_set_status("No sample atlas selected.")
		return
	var preset: Dictionary = presets[index]
	if _target_atlas_path_edit != null:
		_target_atlas_path_edit.text = String(preset.get("path", ""))
	if _apply_target_atlas_path(String(preset.get("path", "")), preset.get("tile_size", HexMapTileAdapter.SAMPLE_TILE_SIZE)):
		_set_status("Applied sample target atlas.")
	else:
		_set_status("Failed to apply sample target atlas.")


func _on_select_display_layer_pressed() -> void:
	if _select_display_layer_in_editor_if_possible():
		_set_status("Selected internal TileMapLayer. Auto target resolves back to HexTileMapLayer.")
	else:
		_set_status("No HexTileMapLayer internal TileMapLayer.")


func _on_default_tile_setting_changed(_value: float) -> void:
	_default_target_tile_settings_explicit = true
	_plain_target_tile_options = _default_tile_settings_from_controls()
	_refresh_target_status_detail()


func _on_read_default_tiles_pressed() -> void:
	if _read_target_tile_settings(true):
		_set_status("Read target tile settings.")
	else:
		_set_status("No target tile settings to read.")


func _on_apply_default_tiles_pressed() -> void:
	_default_target_tile_settings_explicit = true
	_plain_target_tile_options = _default_tile_settings_from_controls()
	if _apply_default_tile_settings_to_target(true):
		_apply_document_to_target()
		_set_status("Applied target tile settings.")
	else:
		_set_status("No editable target layer.")


func _on_default_floor_catalog_selected(index: int) -> void:
	var key = _catalog_key_from_option(_default_floor_catalog_option, index)
	if key == "":
		return
	var fallback = HexMapTileAdapter.tile_config(
		int(_default_floor_source_spin.value),
		Vector2i(int(_default_floor_atlas_x_spin.value), int(_default_floor_atlas_y_spin.value)),
		int(_default_floor_alternative_spin.value)
	)
	if _apply_catalog_config_to_spins(
		_catalog_tile_config(key, fallback),
		_default_floor_source_spin,
		_default_floor_atlas_x_spin,
		_default_floor_atlas_y_spin,
		_default_floor_alternative_spin
	):
		_on_default_tile_setting_changed(0)


func _on_default_wall_catalog_selected(index: int) -> void:
	var key = _catalog_key_from_option(_default_wall_catalog_option, index)
	if key == "":
		return
	var fallback = HexMapTileAdapter.tile_config(
		int(_default_wall_source_spin.value),
		Vector2i(int(_default_wall_atlas_x_spin.value), int(_default_wall_atlas_y_spin.value)),
		int(_default_wall_alternative_spin.value)
	)
	if _apply_catalog_config_to_spins(
		_catalog_tile_config(key, fallback),
		_default_wall_source_spin,
		_default_wall_atlas_x_spin,
		_default_wall_atlas_y_spin,
		_default_wall_alternative_spin
	):
		_on_default_tile_setting_changed(0)


func _on_copy_debug_report_pressed() -> void:
	if copy_debug_report_to_clipboard():
		_set_status("Copied debug report.")
	else:
		_set_status("Debug report is empty.")


func _on_validate_document_pressed() -> void:
	validate_document_now()


func _on_validation_issue_selected(issue: Dictionary, _index: int) -> void:
	_selected_validation_issue = issue.duplicate(true)
	if _focus_validation_issue(issue):
		_set_status("Selected validation issue: %s" % String(issue.get("rule_id", "")))
	else:
		_set_status("Selected validation issue.")


func copy_debug_report_to_clipboard() -> bool:
	_last_copied_debug_report = debug_report_text()
	if _last_copied_debug_report == "":
		return false
	DisplayServer.clipboard_set(_last_copied_debug_report)
	return true


func debug_report_text() -> String:
	_refresh_target_status_detail()
	_refresh_last_edit_detail()
	_refresh_persistence_detail()
	var lines := PackedStringArray()
	lines.append("Hex Map Edit Debug Report")
	lines.append("status: %s" % (_status_label.text if _status_label != null else ""))
	lines.append("document: %s" % ("selected" if _document != null else "none"))
	lines.append("document_source: %s" % _document_source)
	lines.append("target: %s" % _target_path_string())
	lines.append("target_status: %s" % (_target_status_label.text if _target_status_label != null else ""))
	lines.append("last_edit: %s" % (_last_edit_detail_label.text if _last_edit_detail_label != null else ""))
	lines.append("save_export: %s" % (_persistence_detail_label.text if _persistence_detail_label != null else ""))
	lines.append("validation_summary: %s" % var_to_str(validation_debug_summary()))
	lines.append("validation_issues: %s" % var_to_str(validation_debug_issue_rows()))
	lines.append("target_readiness_status: %s" % var_to_str(_target_status_detail))
	lines.append("last_edit_status: %s" % var_to_str(_last_edit_status))
	lines.append("persistence_status: %s" % var_to_str(_last_persistence_status))
	lines.append("target_resolution_reason: %s" % _last_target_resolution_reason)
	lines.append("target_apply_reason: %s" % _last_target_apply_reason)
	return _join_lines(lines)


func _popup_resource_file_dialog(
	file_mode: int,
	filters: Array,
	selected_callback: Callable,
	current_file: String = ""
) -> bool:
	if not selected_callback.is_valid():
		return false
	if not Engine.is_editor_hint():
		return false
	var dialog := HexMapEditorPathSelector.new_dialog(file_mode, filters)
	if current_file != "":
		dialog.current_file = current_file
	dialog.file_selected.connect(selected_callback)
	return HexMapEditorPathSelector.popup_dialog(dialog)


func _join_lines(lines: PackedStringArray) -> String:
	var result := ""
	for index in range(lines.size()):
		if index > 0:
			result += "\n"
		result += lines[index]
	return result


func _on_object_payload_changed(_text: String) -> void:
	if _object_id_edit != null:
		_object_payload["object_id"] = _object_id_edit.text
	if _object_rotation_spin != null:
		_object_payload["rotation_degrees"] = float(_object_rotation_spin.value)
	if _object_variant_edit != null:
		_object_payload["variant"] = _object_variant_edit.text
	if _object_properties_edit != null and _control_row_is_visible(_object_properties_edit):
		var parsed = JSON.parse_string(_object_properties_edit.text)
		_object_payload["properties"] = parsed if parsed is Dictionary else {}
	if _object_spawn_condition_edit != null:
		_object_payload["spawn_condition"] = _object_spawn_condition_edit.text
	_refresh_object_properties_table()
	_refresh_object_property_editor()
	_select_catalog_option_by_key(_object_catalog_option, String(_object_payload.get("object_id", "")))


func _on_object_rotation_changed(_value: float) -> void:
	_on_object_payload_changed("")


func _on_label_payload_changed(_text: String) -> void:
	_label_payload["label_id"] = _label_id_edit.text
	_label_payload["text"] = _label_text_edit.text


func _on_object_catalog_selected(index: int) -> void:
	var key = _catalog_key_from_option(_object_catalog_option, index)
	if key == "":
		return
	_object_payload["object_id"] = key
	if _object_database != null and _object_database.has_method("has_definition") and _object_database.has_definition(key):
		_selected_object_definition_id = key
		_apply_selected_definition_defaults()
	if _object_id_edit != null:
		_object_id_edit.text = key
	_refresh_object_palette()
	_refresh_object_property_editor()
	_refresh_target_status_detail()


func _store_current_tile_payload_for_mode() -> void:
	var payload = _tile_payload.duplicate(true)
	match _edit_mode:
		EditMode.FLOOR_TILE:
			_floor_tile_payload = payload
		EditMode.WALL_TILE:
			_wall_tile_payload = payload
		EditMode.OVERLAY_TILE:
			_overlay_tile_payload = payload


func _load_tile_payload_for_mode() -> void:
	match _edit_mode:
		EditMode.FLOOR_TILE:
			_tile_payload = _floor_tile_payload.duplicate(true)
		EditMode.WALL_TILE:
			_tile_payload = _wall_tile_payload.duplicate(true)
		EditMode.OVERLAY_TILE:
			_tile_payload = _overlay_tile_payload.duplicate(true)


func _sync_payload_controls() -> void:
	if _tile_source_spin != null:
		_tile_source_spin.set_value_no_signal(int(_tile_payload.get("source_id", 0)))
		_tile_atlas_x_spin.set_value_no_signal(int(_tile_payload.get("atlas_coords", Vector2i.ZERO).x))
		_tile_atlas_y_spin.set_value_no_signal(int(_tile_payload.get("atlas_coords", Vector2i.ZERO).y))
		_tile_alternative_spin.set_value_no_signal(int(_tile_payload.get("alternative_tile", 0)))
		_populate_catalog_option(_tile_catalog_option, _tile_catalog_tag_for_mode(), String(_tile_payload.get("catalog_key", "")))
	if _overlay_item_key_edit != null:
		_overlay_item_key_edit.text = _overlay_item_key
	if _object_id_edit != null:
		_object_id_edit.text = String(_object_payload.get("object_id", ""))
		_object_rotation_spin.set_value_no_signal(float(_object_payload.get("rotation_degrees", 0.0)))
		_object_variant_edit.text = String(_object_payload.get("variant", ""))
		_object_properties_edit.text = JSON.stringify(_object_payload.get("properties", {}))
		_object_spawn_condition_edit.text = String(_object_payload.get("spawn_condition", ""))
		_refresh_object_properties_table()
		_populate_object_key_option(String(_object_payload.get("object_id", "")))
		_refresh_object_palette()
		_refresh_object_property_editor()
	if _label_id_edit != null:
		_label_id_edit.text = String(_label_payload.get("label_id", ""))
		_label_text_edit.text = String(_label_payload.get("text", ""))


func _refresh_payload_controls_visibility() -> void:
	var show_tile = _edit_mode == EditMode.FLOOR_TILE \
		or _edit_mode == EditMode.WALL_TILE \
		or _edit_mode == EditMode.OVERLAY_TILE
	var show_overlay = _edit_mode == EditMode.OVERLAY_TILE
	var show_object = _edit_mode == EditMode.OBJECT
	var show_label = _edit_mode == EditMode.LABEL
	_set_control_row_visible(_tile_catalog_option, show_tile)
	_set_control_row_visible(_tile_source_spin, false)
	_set_control_row_visible(_tile_atlas_x_spin, false)
	_set_control_row_visible(_tile_atlas_y_spin, false)
	_set_control_row_visible(_tile_alternative_spin, false)
	_set_control_row_visible(_default_floor_source_spin, false)
	_set_control_row_visible(_default_floor_atlas_x_spin, false)
	_set_control_row_visible(_default_floor_atlas_y_spin, false)
	_set_control_row_visible(_default_floor_alternative_spin, false)
	_set_control_row_visible(_default_wall_source_spin, false)
	_set_control_row_visible(_default_wall_atlas_x_spin, false)
	_set_control_row_visible(_default_wall_atlas_y_spin, false)
	_set_control_row_visible(_default_wall_alternative_spin, false)
	_set_control_row_visible(_overlay_item_key_edit, show_overlay)
	_set_control_row_visible(_overlay_item_key_option, show_overlay)
	_set_control_row_visible(_object_catalog_option, show_object)
	_set_control_row_visible(_object_id_edit, false)
	_set_control_row_visible(_object_definition_tree, show_object)
	_set_control_row_visible(_object_definition_scene_picker, show_object)
	_set_control_row_visible(_object_add_definition_button, show_object)
	_set_control_row_visible(_object_palette_status_label, show_object)
	_set_control_row_visible(_object_rotation_spin, show_object)
	_set_control_row_visible(_object_variant_edit, show_object)
	_set_control_row_visible(_object_property_editor, show_object)
	_set_control_row_visible(_object_properties_edit, false)
	_set_control_row_visible(_object_properties_table, false)
	_set_control_row_visible(_object_spawn_condition_edit, show_object)
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


func _control_row_is_visible(control) -> bool:
	if control == null or not (control is Control):
		return false
	var parent = (control as Control).get_parent()
	if parent is Control:
		return (parent as Control).visible
	return (control as Control).visible


func _sync_resource_pickers() -> void:
	if _document_resource_picker != null:
		_document_resource_picker.edited_resource = _document
	if _import_map_resource_picker != null:
		_import_map_resource_picker.edited_resource = _import_map_resource
	if _catalog_resource_picker != null:
		_catalog_resource_picker.edited_resource = _ensure_tile_catalog()
	if _catalog_tile_set_picker != null:
		var catalog = _ensure_tile_catalog()
		_catalog_tile_set_picker.edited_resource = catalog.tile_set if catalog != null else null
	if _catalog_scene_picker != null:
		_catalog_scene_picker.edited_resource = _catalog_scene_resource
	if _target_tile_set_picker != null:
		_target_tile_set_picker.edited_resource = _target_tile_set_for_current_target()
	if _object_database_picker != null:
		_object_database_picker.edited_resource = _object_database
	if _label_database_picker != null:
		_label_database_picker.edited_resource = _label_database


func _publish_session_target(reason: String) -> void:
	if _editor_session_state == null:
		return
	var target = _target_layer if _target_layer != null and is_instance_valid(_target_layer) else null
	_editor_session_state.set_target_layer(target, reason)


func _publish_session_document(reason: String) -> void:
	if _editor_session_state == null:
		return
	_editor_session_state.set_document(_document, _document_source, _document_path, reason)


func _publish_session_import_map(reason: String) -> void:
	if _editor_session_state == null:
		return
	_editor_session_state.set_import_map(_import_map_resource, _import_map_path, reason)
	_editor_session_state.set_import_map_saved_path(_import_map_path, reason)


func _publish_session_paths(reason: String) -> void:
	if _editor_session_state == null:
		return
	_editor_session_state.set_document_saved_path(_document_path, reason)
	_editor_session_state.set_import_map_saved_path(_import_map_path, reason)
	_editor_session_state.set_export_saved_path(_export_path, reason)


func _refresh_overlay_item_key_options() -> void:
	if _overlay_item_key_option == null:
		return
	var previous_key = _overlay_item_key
	_overlay_item_key_option.clear()
	var keys: Array[String] = []
	if previous_key != "":
		keys.append(previous_key)
	if _document != null:
		for entry in HexMapDocumentAdapter.document_tile_entries(_document):
			if not entry is Dictionary:
				continue
			if String(entry.get("kind", "")) != HexMapDocumentAdapter.KIND_OVERLAY:
				continue
			var key = String(entry.get("item_key", ""))
			if key != "" and not keys.has(key):
				keys.append(key)
	for key in keys:
		_overlay_item_key_option.add_item(key)
	var selected_index := keys.find(previous_key)
	if selected_index >= 0:
		_overlay_item_key_option.select(selected_index)


func _document_state_text() -> String:
	if _document == null:
		return "none"
	match _document_source:
		DOCUMENT_SOURCE_NEW:
			return "new"
		DOCUMENT_SOURCE_LOAD:
			return "opened"
		DOCUMENT_SOURCE_IMPORT:
			return "converted"
		DOCUMENT_SOURCE_TARGET:
			return "from target"
		DOCUMENT_SOURCE_SAVE:
			return "saved"
		DOCUMENT_SOURCE_PROVIDED:
			return "selected"
	return "selected"


func _document_saved_text() -> String:
	return _document_path if _document_path != "" else "Unsaved"


func _document_validation_text() -> String:
	if _document == null:
		return "none"
	if _last_validation_result == null:
		return "not run"
	return "%d errors / %d warnings" % [
		_last_validation_result.error_count() if _last_validation_result.has_method("error_count") else 0,
		_last_validation_result.warning_count() if _last_validation_result.has_method("warning_count") else 0,
	]


func _refresh_state_labels() -> void:
	_target_layer = _resolve_target_layer()
	_ensure_document_from_target_if_needed()
	if _document_label != null:
		_document_label.text = "Document: %s   Saved: %s   Dirty: %s   Validation: %s" % [
			_document_state_text(),
			_document_saved_text(),
			_bool_text(_document_dirty),
			_document_validation_text(),
		]
	_refresh_document_inspector()
	if _target_label != null:
		var target_name = "none"
		if _target_layer != null and is_instance_valid(_target_layer):
			target_name = _target_layer.name
		_target_label.text = "Target: %s" % target_name
	_refresh_target_status_detail()
	_refresh_overlay_item_key_options()
	_refresh_action_button_states()


func _refresh_document_inspector() -> void:
	if _document_inspector == null:
		return
	_document_inspector.set_document_state(
		_document,
		_document_source,
		_document_path,
		_document_source == DOCUMENT_SOURCE_TARGET
	)
	_document_inspector.set_validation_summary(
		HexMapDocumentInspector.validation_summary_from_result(_last_validation_result, {
			"document_present": _document != null,
		})
	)


func _ensure_document_from_target_if_needed() -> bool:
	if _document != null:
		return false
	if _target_layer == null or not is_instance_valid(_target_layer):
		return false
	if not (_target_layer is HexTileMapLayer):
		return false
	var hex_layer := _target_layer as HexTileMapLayer
	if hex_layer.hex_map == null and hex_layer.get_cells().is_empty():
		return false
	_document = _document_for_editor(hex_layer.to_document_resource())
	_document_source = DOCUMENT_SOURCE_TARGET
	_document_dirty = true
	_refresh_plain_target_tile_options_from_document(_document)
	_sync_resource_pickers()
	_publish_session_document("edit.target_document")
	return true


func _sync_document_snapshot_from_hex_target() -> bool:
	_target_layer = _resolve_target_layer()
	if _target_layer == null or not is_instance_valid(_target_layer):
		return false
	if not (_target_layer is HexTileMapLayer):
		return false
	if _document != null and _document_source != DOCUMENT_SOURCE_TARGET:
		return false
	var snapshot = _document_for_editor((_target_layer as HexTileMapLayer).to_document_resource())
	if _document == null:
		_document = snapshot
		_document_source = DOCUMENT_SOURCE_TARGET
		_document_dirty = true
	else:
		HexMapDocumentAdapter.copy_document_state(_document, snapshot)
		_document_dirty = true
	_refresh_overlay_item_key_options()
	_sync_resource_pickers()
	_publish_session_document("edit.sync_target_document")
	return true


func _resolve_target_layer():
	if _target_option == null:
		return _target_layer
	var node_index = _target_option.selected - TARGET_LAYER_INDEX_OFFSET
	if node_index >= 0 and node_index < _target_layer_nodes.size():
		var node = _target_layer_nodes[node_index]
		if is_instance_valid(node):
			_last_target_resolution_reason = "explicit target option"
			return node
		_last_target_resolution_reason = "explicit target invalid"
		return null
	if _target_selection_explicit and _target_layer != null and is_instance_valid(_target_layer):
		_last_target_resolution_reason = "explicit cached target"
		return _target_layer
	var selected_layer = _find_editor_selected_target_layer()
	if selected_layer != null:
		_last_target_resolution_reason = "auto editor selection"
		return selected_layer
	for node in _target_layer_nodes:
		if is_instance_valid(node):
			_last_target_resolution_reason = "auto first scene layer"
			return node
	_last_target_resolution_reason = "auto target missing"
	return null


func _find_editor_selected_target_layer():
	if _test_editor_selected_target_layer != null and is_instance_valid(_test_editor_selected_target_layer):
		return _editable_target_from_node(_test_editor_selected_target_layer)
	if not Engine.is_editor_hint():
		return null
	var selection = EditorInterface.get_selection()
	if selection == null or not selection.has_method("get_selected_nodes"):
		return null
	for node in selection.get_selected_nodes():
		var target = _editable_target_from_node(node)
		if target != null:
			return target
	return null


func _editable_target_from_node(node):
	if node == null or not is_instance_valid(node):
		return null
	if node is HexTileMapLayer:
		return node
	if node is TileMapLayer:
		if _is_hex_tile_map_internal_layer(node):
			var parent = node.get_parent()
			return parent if parent is HexTileMapLayer else null
	return null


func layer_stack_rows() -> Array[Dictionary]:
	var stack = _ensure_layer_stack_resource()
	var rows: Array[Dictionary] = []
	for entry in stack.sorted_layers():
		if entry == null:
			continue
		var role = String(entry.get("role"))
		var layer = _layer_stack_target_layer_for_role(role)
		var metadata = entry.get("metadata")
		var entry_locked = bool((metadata as Dictionary).get("locked", false)) if metadata is Dictionary else false
		var writable_source = String((metadata as Dictionary).get("writable_source", "document")) if metadata is Dictionary else "document"
		rows.append({
			"role": role,
			"node": String(entry.get("node_name")),
			"visible": bool(entry.get("visible")),
			"locked": entry_locked,
			"z_index": int(entry.get("z_index")),
			"writable": writable_source,
			"status": "ok" if layer != null else "missing",
		})
	return rows


func _refresh_layer_stack_screen() -> void:
	if _layer_stack_role_tree != null:
		_layer_stack_role_tree.clear()
		var root_item = _layer_stack_role_tree.create_item()
		for row in layer_stack_rows():
			var item = _layer_stack_role_tree.create_item(root_item)
			item.set_text(0, String(row.get("role", "")))
			item.set_text(1, String(row.get("node", "")))
			item.set_text(2, _bool_text(bool(row.get("visible", false))))
			item.set_text(3, _bool_text(bool(row.get("locked", false))))
			item.set_text(4, str(int(row.get("z_index", 0))))
			item.set_text(5, String(row.get("writable", "")))
			if String(row.get("role", "")) == _selected_layer_stack_role:
				item.select(0)
	if _layer_stack_status_label != null:
		var stack = _ensure_layer_stack_resource()
		_layer_stack_status_label.text = "%s roles=%d target=%s" % [
			stack.display_name if stack.display_name != "" else stack.stack_id,
			stack.layers.size(),
			"HexTileMapLayer" if _target_layer is HexTileMapLayer else "none",
		]
	_refresh_action_button_states()


func _ensure_layer_stack_resource() -> HexLayerStackResource:
	if _layer_stack_resource == null:
		_layer_stack_resource = HexLayerStackResource.standard_template()
	return _layer_stack_resource


func _layer_stack_target_layer_for_role(role: String):
	var target = _target_layer as HexTileMapLayer
	if target == null:
		return null
	return target.layer_for_stack_role(role)


func _apply_layer_stack_to_target(_apply_document: bool) -> bool:
	_target_layer = _resolve_target_layer()
	var target = _target_layer as HexTileMapLayer
	if target == null or _document == null:
		return false
	var ok = target.apply_document_to_layer_stack(
		_document,
		_ensure_layer_stack_resource(),
		_plain_target_tile_options_for_document_apply()
	)
	_refresh_layer_stack_screen()
	return ok


func _is_hex_tile_map_internal_layer(node: Node) -> bool:
	if node == null or not (node is TileMapLayer):
		return false
	var parent = node.get_parent()
	if not (parent is HexTileMapLayer):
		return false
	return node.name == HexTileMapLayer.BASE_TILE_MAP_NAME \
		or node.name == HexTileMapLayer.LOOP_TILE_MAP_NAME \
		or node.name == HexTileMapLayer.OVERLAY_TILE_MAP_NAME


func _select_target_layer_option(layer: Node) -> void:
	var selected_index = TARGET_AUTO_INDEX
	if layer != null:
		var index = _target_layer_nodes.find(layer)
		if index >= 0:
			selected_index = index + TARGET_LAYER_INDEX_OFFSET
	_target_option.select(selected_index)


func _collect_target_layers_recursive(node: Node, result: Array[Node]) -> void:
	if node is HexTileMapLayer:
		result.append(node)
		return
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
	_target_layer = _resolve_target_layer()
	var trace = HexMapEditViewportInputAdapter.target_local_trace(event.position, null, _target_layer)
	if not bool(trace.get("ok", false)) and String(trace.get("debug_stage", "")) == "target missing":
		_set_status(String(trace.get("status", "No editable target layer.")))
		_debug_viewport_input(String(trace.get("debug_stage", "target missing")), event.position, Vector2.ZERO, Vector2.ZERO, {})
		return null
	var scene_pos = _editor_viewport_position_to_scene_position(event.position)
	trace = HexMapEditViewportInputAdapter.target_local_trace(event.position, scene_pos, _target_layer)
	if not bool(trace.get("ok", false)):
		_set_status(String(trace.get("status", "Cannot resolve editor viewport position.")))
		_debug_viewport_input(
			String(trace.get("debug_stage", "scene position missing")),
			event.position,
			trace.get("scene_position", Vector2.ZERO),
			trace.get("local_position", Vector2.ZERO),
			{}
		)
		return null
	var local_pos = trace["local_position"]
	_pending_viewport_trace = {
		"viewport_position": trace["viewport_position"],
		"scene_position": trace["scene_position"],
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


func _default_tile_settings_from_controls() -> Dictionary:
	if _default_floor_source_spin == null:
		return _plain_target_tile_options_for_apply()
	return {
		"floor_source_id": int(_default_floor_source_spin.value),
		"floor_atlas_coords": Vector2i(
			int(_default_floor_atlas_x_spin.value),
			int(_default_floor_atlas_y_spin.value)
		),
		"floor_alternative_tile": int(_default_floor_alternative_spin.value),
		"floor_catalog_key": _catalog_key_from_option(_default_floor_catalog_option),
		"wall_source_id": int(_default_wall_source_spin.value),
		"wall_atlas_coords": Vector2i(
			int(_default_wall_atlas_x_spin.value),
			int(_default_wall_atlas_y_spin.value)
		),
		"wall_alternative_tile": int(_default_wall_alternative_spin.value),
		"wall_catalog_key": _catalog_key_from_option(_default_wall_catalog_option),
		"clear_layer": true,
	}


func _sync_default_tile_controls_from_options(options: Dictionary) -> void:
	if _default_floor_source_spin == null:
		return
	_default_floor_source_spin.set_value_no_signal(int(options.get("floor_source_id", 0)))
	var floor_atlas = options.get("floor_atlas_coords", Vector2i.ZERO)
	_default_floor_atlas_x_spin.set_value_no_signal(int(floor_atlas.x))
	_default_floor_atlas_y_spin.set_value_no_signal(int(floor_atlas.y))
	_default_floor_alternative_spin.set_value_no_signal(int(options.get("floor_alternative_tile", 0)))
	_select_catalog_option_by_key(_default_floor_catalog_option, String(options.get("floor_catalog_key", "")))
	_default_wall_source_spin.set_value_no_signal(int(options.get("wall_source_id", 0)))
	var wall_atlas = options.get("wall_atlas_coords", Vector2i(1, 0))
	_default_wall_atlas_x_spin.set_value_no_signal(int(wall_atlas.x))
	_default_wall_atlas_y_spin.set_value_no_signal(int(wall_atlas.y))
	_default_wall_alternative_spin.set_value_no_signal(int(options.get("wall_alternative_tile", 0)))
	_select_catalog_option_by_key(_default_wall_catalog_option, String(options.get("wall_catalog_key", "")))


func _read_target_tile_settings(mark_explicit: bool = true) -> bool:
	if _default_target_tile_settings_explicit and not mark_explicit:
		_sync_default_tile_controls_from_options(_plain_target_tile_options_for_apply())
		return true
	_target_layer = _resolve_target_layer()
	if _target_layer == null or not is_instance_valid(_target_layer):
		_last_default_tile_settings_target = null
		_sync_default_tile_controls_from_options(_plain_target_tile_options_for_apply())
		return false
	if _target_layer is HexTileMapLayer:
		var hex_layer := _target_layer as HexTileMapLayer
		_plain_target_tile_options = {
			"floor_source_id": hex_layer.floor_source_id,
			"floor_atlas_coords": hex_layer.floor_atlas_coords,
			"floor_alternative_tile": hex_layer.floor_alternative_tile,
			"wall_source_id": hex_layer.wall_source_id,
			"wall_atlas_coords": hex_layer.wall_atlas_coords,
			"wall_alternative_tile": hex_layer.wall_alternative_tile,
			"clear_layer": true,
		}
	elif _target_layer is TileMapLayer:
		_refresh_plain_target_tile_options_from_document(_document, true)
	else:
		_sync_default_tile_controls_from_options(_plain_target_tile_options_for_apply())
		return false
	if mark_explicit:
		_default_target_tile_settings_explicit = true
	_last_default_tile_settings_target = _target_layer
	_sync_default_tile_controls_from_options(_plain_target_tile_options_for_apply())
	_refresh_target_status_detail()
	return true


func _sync_default_tile_settings_for_target_if_needed() -> void:
	if _default_target_tile_settings_explicit:
		return
	if _target_layer == null or not is_instance_valid(_target_layer):
		return
	if _last_default_tile_settings_target == null \
		or not is_instance_valid(_last_default_tile_settings_target) \
		or _last_default_tile_settings_target != _target_layer:
		_read_target_tile_settings(false)


func _apply_default_tile_settings_to_target(update_status: bool = true) -> bool:
	_target_layer = _resolve_target_layer()
	if _target_layer == null or not is_instance_valid(_target_layer):
		if update_status:
			_refresh_target_status_detail()
		return false
	var options = _default_tile_settings_from_controls()
	_plain_target_tile_options = options.duplicate(true)
	if _target_layer is HexTileMapLayer:
		var hex_layer := _target_layer as HexTileMapLayer
		hex_layer.floor_source_id = int(options.get("floor_source_id", 0))
		hex_layer.floor_atlas_coords = options.get("floor_atlas_coords", Vector2i.ZERO)
		hex_layer.floor_alternative_tile = int(options.get("floor_alternative_tile", 0))
		hex_layer.wall_source_id = int(options.get("wall_source_id", 0))
		hex_layer.wall_atlas_coords = options.get("wall_atlas_coords", Vector2i(1, 0))
		hex_layer.wall_alternative_tile = int(options.get("wall_alternative_tile", 0))
	if update_status:
		_refresh_target_status_detail()
	return true


func _apply_target_tile_set(tile_set: TileSet) -> bool:
	_target_layer = _resolve_target_layer()
	if tile_set == null or _target_layer == null or not is_instance_valid(_target_layer):
		return false
	if _target_layer is HexTileMapLayer:
		(_target_layer as HexTileMapLayer).set_display_tile_set(tile_set)
	elif _target_layer is TileMapLayer:
		(_target_layer as TileMapLayer).tile_set = tile_set
	else:
		return false
	_read_target_tile_settings(false)
	_refresh_target_status_detail()
	_sync_resource_pickers()
	return true


func _apply_target_atlas_path(path: String, tile_size: Vector2i) -> bool:
	if path == "" or tile_size.x <= 0 or tile_size.y <= 0:
		return false
	_target_layer = _resolve_target_layer()
	if _target_layer == null or not is_instance_valid(_target_layer):
		return false
	var texture := HexMapTileAdapter.load_tile_texture(path)
	if texture == null:
		return false
	var options = _default_tile_settings_from_controls()
	var floor_source = int(options.get("floor_source_id", 0))
	var wall_source = int(options.get("wall_source_id", 0))
	var floor_atlas = options.get("floor_atlas_coords", Vector2i.ZERO)
	var wall_atlas = options.get("wall_atlas_coords", Vector2i(1, 0))
	var flat_top = _target_flat_top()
	var ok := false
	if _target_layer is HexTileMapLayer:
		var hex_layer := _target_layer as HexTileMapLayer
		hex_layer.flat_top = flat_top
		ok = hex_layer.configure_display_tiles_from_texture(
			texture,
			floor_source,
			wall_source,
			tile_size,
			floor_atlas,
			wall_atlas
		)
	elif _target_layer is TileMapLayer:
		var tile_layer := _target_layer as TileMapLayer
		if tile_layer.tile_set == null:
			tile_layer.tile_set = TileSet.new()
		if floor_source == wall_source:
			ok = HexMapTileAdapter.configure_atlas_tile_set(
				tile_layer.tile_set,
				texture,
				flat_top,
				tile_size,
				floor_source,
				[floor_atlas, wall_atlas]
			)
		else:
			ok = HexMapTileAdapter.configure_atlas_tile_set(
				tile_layer.tile_set,
				texture,
				flat_top,
				tile_size,
				floor_source,
				[floor_atlas]
			)
			ok = HexMapTileAdapter.configure_atlas_tile_set(
				tile_layer.tile_set,
				texture,
				flat_top,
				tile_size,
				wall_source,
				[wall_atlas]
			) and ok
	if ok:
		_read_target_tile_settings(false)
		_refresh_target_status_detail()
		_sync_resource_pickers()
	return ok


func _target_flat_top() -> bool:
	if _target_layer is HexTileMapLayer:
		return (_target_layer as HexTileMapLayer).flat_top
	return _document_is_flat_top(_document)


func _target_tile_set_for_current_target():
	_target_layer = _resolve_target_layer()
	if _target_layer == null or not is_instance_valid(_target_layer):
		return null
	if _target_layer is HexTileMapLayer:
		var hex_layer := _target_layer as HexTileMapLayer
		if not hex_layer.display_tile_set_present():
			return null
		return hex_layer.display_tile_set()
	if _target_layer is TileMapLayer:
		return (_target_layer as TileMapLayer).tile_set
	return null


func _target_atlas_presets() -> Array:
	return [
		{
			"label": "Sample 64x57",
			"path": HexMapTileAdapter.SAMPLE_TILE_ATLAS_PATH,
			"tile_size": HexMapTileAdapter.SAMPLE_TILE_SIZE,
		},
		{
			"label": "Tactics Flat 64x57",
			"path": "res://addons/hex_map_kit/assets/tactics_flat_top_hex_tiles_64x57_10.png",
			"tile_size": Vector2i(64, 57),
		},
		{
			"label": "Tactics Pointy 57x64",
			"path": "res://addons/hex_map_kit/assets/tactics_pointy_top_hex_tiles_57x64_10.png",
			"tile_size": Vector2i(57, 64),
		},
	]


func _select_display_layer_in_editor_if_possible() -> bool:
	_target_layer = _resolve_target_layer()
	if _target_layer == null or not (_target_layer is HexTileMapLayer):
		return false
	var display_layer = (_target_layer as HexTileMapLayer).display_tile_map_layer()
	if display_layer == null:
		return false
	_target_selection_sync_request_count += 1
	_last_selection_sync_target = display_layer
	if Engine.is_editor_hint():
		var selection = EditorInterface.get_selection()
		if selection != null:
			selection.clear()
			selection.add_node(display_layer)
	return true


func _plain_target_tile_options_for_apply() -> Dictionary:
	var options = {
		"floor_source_id": 0,
		"floor_atlas_coords": Vector2i.ZERO,
		"floor_alternative_tile": 0,
		"floor_catalog_key": "",
		"wall_source_id": 0,
		"wall_atlas_coords": Vector2i(1, 0),
		"wall_alternative_tile": 0,
		"wall_catalog_key": "",
		"clear_layer": true,
	}
	for key in _plain_target_tile_options:
		options[key] = _plain_target_tile_options[key]
	return options


func _plain_target_tile_options_for_document_apply() -> Dictionary:
	var options = _plain_target_tile_options_for_apply()
	options["tile_catalog"] = _ensure_tile_catalog()
	options["debug_numeric_fallback_enabled"] = String(options.get("floor_catalog_key", "")) == "" \
		or String(options.get("wall_catalog_key", "")) == ""
	return options


func _refresh_plain_target_tile_options_from_document(document, force: bool = false) -> void:
	if _default_target_tile_settings_explicit and not force:
		_sync_default_tile_controls_from_options(_plain_target_tile_options_for_apply())
		return
	if _target_layer == null or not is_instance_valid(_target_layer):
		_sync_default_tile_controls_from_options(_plain_target_tile_options_for_apply())
		return
	if not (_target_layer is TileMapLayer) or _target_layer is HexTileMapLayer:
		_sync_default_tile_controls_from_options(_plain_target_tile_options_for_apply())
		return
	var map_resource = _document_map_resource(document)
	if map_resource == null:
		_sync_default_tile_controls_from_options(_plain_target_tile_options_for_apply())
		return
	var tile_layer := _target_layer as TileMapLayer
	var data = map_resource.to_map_data()
	var flat_top = map_resource.is_flat_top()
	var floor_entry = _first_display_tile_entry_for_hexes(tile_layer, data.floor_cells(), flat_top)
	if not floor_entry.is_empty():
		_plain_target_tile_options["floor_source_id"] = int(floor_entry["source_id"])
		_plain_target_tile_options["floor_atlas_coords"] = floor_entry["atlas_coords"]
		_plain_target_tile_options["floor_alternative_tile"] = int(floor_entry.get("alternative_tile", 0))
	var wall_entry = _first_display_tile_entry_for_hexes(tile_layer, data.walls, flat_top)
	if not wall_entry.is_empty():
		_plain_target_tile_options["wall_source_id"] = int(wall_entry["source_id"])
		_plain_target_tile_options["wall_atlas_coords"] = wall_entry["atlas_coords"]
		_plain_target_tile_options["wall_alternative_tile"] = int(wall_entry.get("alternative_tile", 0))
	_sync_default_tile_controls_from_options(_plain_target_tile_options_for_apply())


func _first_display_tile_entry_for_hexes(tile_layer: TileMapLayer, hexes: Array, flat_top: bool) -> Dictionary:
	for hex in hexes:
		var map_cell = HexMapTileAdapter.vector_to_map_cell(hex, flat_top)
		var source_id = tile_layer.get_cell_source_id(map_cell)
		if source_id < 0:
			continue
		return {
			"source_id": source_id,
			"atlas_coords": tile_layer.get_cell_atlas_coords(map_cell),
			"alternative_tile": tile_layer.get_cell_alternative_tile(map_cell),
		}
	return {}


func _refresh_target_status_detail() -> void:
	_target_layer = _resolve_target_layer()
	_target_status_detail = _build_target_readiness_status()
	if _target_status_label != null:
		_target_status_label.text = _format_target_status_detail(_target_status_detail)
	_refresh_action_button_states()


func _build_target_readiness_status() -> Dictionary:
	var status = {
		"target_path": _target_path_string(),
		"target_class": _target_class_string(),
		"is_hex_tile_map_layer": _target_layer is HexTileMapLayer,
		"document_present": _document != null,
		"document_source": _document_source,
		"document_path": _document_path,
		"document_unsaved_target": _document_source == DOCUMENT_SOURCE_TARGET,
		"target_hex_map_present": false,
		"tile_set_present": false,
		"tile_set_resource_path": "",
		"tile_set_source_count": 0,
		"tile_size": Vector2i.ZERO,
		"floor_source_id": 0,
		"floor_atlas_coords": Vector2i.ZERO,
		"floor_alternative_tile": 0,
		"wall_source_id": 0,
		"wall_atlas_coords": Vector2i(1, 0),
		"wall_alternative_tile": 0,
		"overlay_source_id": int(_overlay_tile_payload.get("source_id", 0)),
		"overlay_atlas_coords": _overlay_tile_payload.get("atlas_coords", Vector2i.ZERO),
		"overlay_alternative_tile": int(_overlay_tile_payload.get("alternative_tile", 0)),
		"overlay_item_key": _overlay_item_key,
		"overlay_tile_visible": false,
		"overlay_tile_z_index": 0,
		"overlay_canvas_visible": false,
		"overlay_canvas_z_index": 0,
		"used_cell_count": 0,
		"loop_display_mode": HexTileMapLayer.LOOP_DISPLAY_NONE,
		"target_resolution_reason": _last_target_resolution_reason,
		"ready": false,
		"message": "No editable target layer.",
	}
	if _target_layer == null or not is_instance_valid(_target_layer):
		return status
	if _target_layer is HexTileMapLayer:
		var hex_layer := _target_layer as HexTileMapLayer
		var layer_status := hex_layer.display_layer_status()
		status["target_hex_map_present"] = hex_layer.hex_map != null
		status["tile_set_present"] = hex_layer.display_tile_set_present()
		status["tile_set_resource_path"] = String(layer_status.get("tile_set_resource_path", ""))
		status["tile_set_source_count"] = int(layer_status.get("tile_set_source_count", 0))
		status["tile_size"] = layer_status.get("tile_size", Vector2i.ZERO)
		status["floor_source_id"] = hex_layer.floor_source_id
		status["floor_atlas_coords"] = hex_layer.floor_atlas_coords
		status["floor_alternative_tile"] = hex_layer.floor_alternative_tile
		status["wall_source_id"] = hex_layer.wall_source_id
		status["wall_atlas_coords"] = hex_layer.wall_atlas_coords
		status["wall_alternative_tile"] = hex_layer.wall_alternative_tile
		status["used_cell_count"] = hex_layer.display_used_cell_count()
		status["loop_display_mode"] = hex_layer.loop_display_mode
		status["overlay_tile_visible"] = bool(layer_status.get("overlay_tile_visible", false))
		status["overlay_tile_z_index"] = int(layer_status.get("overlay_tile_z_index", 0))
		status["overlay_canvas_visible"] = bool(layer_status.get("overlay_canvas_visible", false))
		status["overlay_canvas_z_index"] = int(layer_status.get("overlay_canvas_z_index", 0))
	elif _target_layer is TileMapLayer:
		var tile_layer := _target_layer as TileMapLayer
		var options = _plain_target_tile_options_for_apply()
		status["tile_set_present"] = tile_layer.tile_set != null
		if tile_layer.tile_set != null:
			status["tile_set_resource_path"] = tile_layer.tile_set.resource_path
			status["tile_set_source_count"] = tile_layer.tile_set.get_source_count()
			status["tile_size"] = tile_layer.tile_set.tile_size
		status["floor_source_id"] = int(options.get("floor_source_id", 0))
		status["floor_atlas_coords"] = options.get("floor_atlas_coords", Vector2i.ZERO)
		status["floor_alternative_tile"] = int(options.get("floor_alternative_tile", 0))
		status["wall_source_id"] = int(options.get("wall_source_id", 0))
		status["wall_atlas_coords"] = options.get("wall_atlas_coords", Vector2i(1, 0))
		status["wall_alternative_tile"] = int(options.get("wall_alternative_tile", 0))
		status["used_cell_count"] = tile_layer.get_used_cells().size()
	else:
		status["message"] = "Target is not a TileMapLayer."
		return status
	status["ready"] = bool(status["tile_set_present"])
	status["message"] = "ready" if bool(status["ready"]) else "TileSet missing."
	if _document == null and _target_layer is HexTileMapLayer and not bool(status["target_hex_map_present"]):
		status["message"] = "No document selected."
	return status


func _validation_options() -> Dictionary:
	var options := {}
	if _tile_catalog != null:
		options["tile_catalog"] = _tile_catalog
	var tile_set = _target_tile_set_for_validation()
	if tile_set != null:
		options["tile_set"] = tile_set
	return options


func _target_tile_set_for_validation():
	_target_layer = _resolve_target_layer()
	if _target_layer == null or not is_instance_valid(_target_layer):
		return null
	if _target_layer is HexTileMapLayer:
		return (_target_layer as HexTileMapLayer).display_tile_set()
	if _target_layer is TileMapLayer:
		return (_target_layer as TileMapLayer).tile_set
	return null


func _validation_result_for_report():
	_sync_document_snapshot_from_hex_target()
	if _document == null:
		return null
	return HexMapDocumentValidator.validate_document(_document, _validation_options())


func _validation_summary_from_result(result) -> Dictionary:
	return HexMapDocumentInspector.validation_summary_from_result(result, {
		"document_present": result != null,
	})


func _validation_issue_report_rows(result, limit: int = 8) -> Array[String]:
	return HexMapDocumentInspector.validation_issue_report_rows(result, limit)


func _validation_issue_report_row(issue: Dictionary) -> String:
	return HexMapDocumentInspector.validation_issue_report_row(issue)


func _focus_validation_issue(issue: Dictionary) -> bool:
	_validation_focus_status = {
		"rule_id": String(issue.get("rule_id", "")),
		"scope": String(issue.get("scope", "")),
		"domain": HexMapValidationDashboard.issue_domain(issue),
		"focus_target": HexMapValidationDashboard.issue_focus_target(issue),
		"fix_suggestion": HexMapValidationDashboard.issue_fix_suggestion(issue),
		"focus_type": "none",
		"focused": false,
		"target_path": _target_path_string(),
	}
	if _focus_validation_catalog_issue(issue):
		return true
	if _focus_validation_resource_issue(issue):
		return true
	var hex = _validation_issue_hex(issue)
	_validation_focus_status["cell"] = issue.get("cell", Vector3i.ZERO)
	_validation_focus_status["cell_key"] = hex.key() if hex != null else ""
	if hex == null:
		return false
	_validation_focus_status["focus_type"] = "cell"
	_last_edit_hit = {
		"hex": hex,
		"visual_hex": hex,
		"local": Vector2.ZERO,
		"exists": _document_has_cell(_document, hex),
		"validation_rule_id": String(issue.get("rule_id", "")),
	}
	_validation_focus_status["focused"] = bool(_last_edit_hit.get("exists", false))
	_refresh_last_hit_display()
	return bool(_validation_focus_status.get("focused", false))


func _focus_validation_catalog_issue(issue: Dictionary) -> bool:
	var metadata = issue.get("metadata", {})
	if not metadata is Dictionary:
		return false
	var catalog_key = String((metadata as Dictionary).get("catalog_key", ""))
	var entry_key = String((metadata as Dictionary).get("entry_key", ""))
	var key = entry_key if entry_key != "" else catalog_key
	var entry_index = int((metadata as Dictionary).get("entry_index", -1))
	if entry_index < 0 and key != "":
		entry_index = _catalog_entry_index_for_key(key)
	if entry_index < 0 and key == "":
		return false
	_validation_focus_status["focus_type"] = "catalog_entry"
	_validation_focus_status["catalog_key"] = key
	_validation_focus_status["catalog_entry_index"] = entry_index
	if entry_index < 0:
		return false
	var item = _catalog_tree_item_at_index(entry_index)
	if item != null:
		item.select(0)
		_validation_focus_status["focused"] = true
	return bool(_validation_focus_status.get("focused", false))


func _focus_validation_resource_issue(issue: Dictionary) -> bool:
	var metadata = issue.get("metadata", {})
	var dependency_path = String(issue.get("dependency_resource_path", ""))
	var dependency_id = ""
	var dependency_kind = ""
	var dependency_role = ""
	if metadata is Dictionary:
		dependency_id = String((metadata as Dictionary).get("dependency_id", ""))
		dependency_kind = String((metadata as Dictionary).get("kind", ""))
		dependency_role = String((metadata as Dictionary).get("role", ""))
	if dependency_path == "" and dependency_id == "" and dependency_kind == "" and dependency_role == "":
		return false
	_validation_focus_status["focus_type"] = "resource"
	_validation_focus_status["resource_path"] = dependency_path
	_validation_focus_status["dependency_id"] = dependency_id
	_validation_focus_status["dependency_kind"] = dependency_kind
	_validation_focus_status["dependency_role"] = dependency_role
	_validation_focus_status["focused"] = dependency_path != ""
	return bool(_validation_focus_status.get("focused", false))


func _catalog_entry_index_for_key(key: String) -> int:
	if key == "":
		return -1
	var catalog = _ensure_tile_catalog()
	if catalog == null:
		return -1
	for index in range(catalog.entries.size()):
		var entry = catalog.entries[index]
		if entry != null and String(entry.get("key")) == key:
			return index
	return -1


func _catalog_tree_item_at_index(entry_index: int):
	if _catalog_entries_tree == null or entry_index < 0:
		return null
	var root_item = _catalog_entries_tree.get_root()
	if root_item == null:
		return null
	var item = root_item.get_first_child()
	var index := 0
	while item != null:
		if index == entry_index:
			return item
		item = item.get_next()
		index += 1
	return null


func _validation_issue_hex(issue: Dictionary):
	var scope = String(issue.get("scope", ""))
	if scope != "cell" and scope != "object":
		return null
	var cell = issue.get("cell", null)
	if not cell is Vector3i:
		return null
	return HexVector.apply_basis(cell.x, cell.y, cell.z)


func _format_target_status_detail(status: Dictionary) -> String:
	if status.is_empty():
		return "none"
	var tile_state = "ready" if bool(status.get("tile_set_present", false)) else "missing"
	var tile_path = String(status.get("tile_set_resource_path", ""))
	if tile_path == "" and bool(status.get("tile_set_present", false)):
		tile_path = "(embedded)"
	var loop_text = ""
	if bool(status.get("is_hex_tile_map_layer", false)):
		loop_text = " loop=%s" % _loop_mode_name(int(status.get("loop_display_mode", 0)))
	return "%s %s document=%s:%s:%s tiles=%s path=%s sources=%d size=%s floor=%d:%s:%d wall=%d:%s:%d overlay=%s:%d:%s:%d ov_visible=%s/%s used=%d%s %s %s" % [
		String(status.get("target_class", "")),
		String(status.get("target_path", "")),
		"yes" if bool(status.get("document_present", false)) else "no",
		String(status.get("document_source", DOCUMENT_SOURCE_NONE)),
		String(status.get("document_path", "")) if String(status.get("document_path", "")) != "" else ("unsaved-target" if bool(status.get("document_unsaved_target", false)) else "unsaved"),
		tile_state,
		tile_path,
		int(status.get("tile_set_source_count", 0)),
		str(status.get("tile_size", Vector2i.ZERO)),
		int(status.get("floor_source_id", 0)),
		_atlas_text(status.get("floor_atlas_coords", Vector2i.ZERO)),
		int(status.get("floor_alternative_tile", 0)),
		int(status.get("wall_source_id", 0)),
		_atlas_text(status.get("wall_atlas_coords", Vector2i(1, 0))),
		int(status.get("wall_alternative_tile", 0)),
		String(status.get("overlay_item_key", "")),
		int(status.get("overlay_source_id", 0)),
		_atlas_text(status.get("overlay_atlas_coords", Vector2i.ZERO)),
		int(status.get("overlay_alternative_tile", 0)),
		_bool_text(bool(status.get("overlay_tile_visible", false))),
		_bool_text(bool(status.get("overlay_canvas_visible", false))),
		int(status.get("used_cell_count", 0)),
		loop_text,
		String(status.get("target_resolution_reason", "")),
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
	var before_state = _document_cell_state(before, hex)
	var after_state = _document_cell_state(after, hex)
	return _build_last_edit_trace_from_states(
		hit,
		before_state,
		after_state,
		applied,
		target_used_cells_before,
		target_used_cells_after,
		display_before,
		display_after
	)


func _build_last_edit_trace_from_states(
	hit: Dictionary,
	before_state: Dictionary,
	after_state: Dictionary,
	applied: bool,
	target_used_cells_before: int,
	target_used_cells_after: int,
	display_before: Dictionary,
	display_after: Dictionary
) -> Dictionary:
	var hex = hit["hex"]
	var visual_hex = hit.get("visual_hex", hex)
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
	var display_signature_before = String(display_before.get("signature", var_to_str(display_before)))
	var display_signature_after = String(display_after.get("signature", var_to_str(display_after)))
	var display_changed = display_signature_before != display_signature_after
	var trace = {
		"target_path": _target_path_string(),
		"target_class": _target_class_string(),
		"mode": _edit_mode,
		"payload": _edit_payload_summary(),
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
		"display_source_before": int(display_before.get("source_id", -1)),
		"display_source_after": int(display_after.get("source_id", -1)),
		"display_alternative_before": int(display_before.get("alternative_tile", -1)),
		"display_alternative_after": int(display_after.get("alternative_tile", -1)),
		"display_overlay_source_before": int(display_before.get("overlay_source_id", -1)),
		"display_overlay_source_after": int(display_after.get("overlay_source_id", -1)),
		"display_overlay_atlas_before": display_before.get("overlay_atlas_coords", Vector2i(-1, -1)),
		"display_overlay_atlas_after": display_after.get("overlay_atlas_coords", Vector2i(-1, -1)),
		"display_overlay_alternative_before": int(display_before.get("overlay_alternative_tile", -1)),
		"display_overlay_alternative_after": int(display_after.get("overlay_alternative_tile", -1)),
		"display_overlay_count_before": int(display_before.get("overlay_count", 0)),
		"display_overlay_count_after": int(display_after.get("overlay_count", 0)),
		"display_renderer_before": String(display_before.get("renderer", "none")),
		"display_renderer_after": String(display_after.get("renderer", "none")),
		"display_marker_count_before": int(display_before.get("marker_count", 0)),
		"display_marker_count_after": int(display_after.get("marker_count", 0)),
		"display_signature_before": display_signature_before,
		"display_signature_after": display_signature_after,
		"target_apply_reason": _last_target_apply_reason,
		"target_resolution_reason": _last_target_resolution_reason,
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
	return "%s%s %s->%s document=%s target=%s display=%s renderer=%s->%s source=%d->%d tile=%s->%s alt=%d->%d overlay=%d->%d markers=%d->%d used=%d->%d reason=%s resolution=%s payload=%s" % [
		hex_text,
		visual_suffix,
		"wall" if bool(trace.get("wall_before", false)) else "floor",
		"wall" if bool(trace.get("wall_after", false)) else "floor",
		_bool_text(bool(trace.get("document_changed", false))),
		_bool_text(bool(trace.get("target_applied", false))),
		_bool_text(bool(trace.get("display_changed", false))),
		String(trace.get("display_renderer_before", "none")),
		String(trace.get("display_renderer_after", "none")),
		int(trace.get("display_source_before", -1)),
		int(trace.get("display_source_after", -1)),
		_atlas_text(trace.get("display_atlas_before", Vector2i(-1, -1))),
		_atlas_text(trace.get("display_atlas_after", Vector2i(-1, -1))),
		int(trace.get("display_alternative_before", -1)),
		int(trace.get("display_alternative_after", -1)),
		int(trace.get("display_overlay_count_before", 0)),
		int(trace.get("display_overlay_count_after", 0)),
		int(trace.get("display_marker_count_before", 0)),
		int(trace.get("display_marker_count_after", 0)),
		int(trace.get("target_used_cells_before", 0)),
		int(trace.get("target_used_cells_after", 0)),
		String(trace.get("target_apply_reason", "")),
		String(trace.get("target_resolution_reason", "")),
		String(trace.get("payload", "")),
	]


func _edit_payload_summary() -> String:
	return HexMapEditMutationBuilder.edit_payload_summary(
		_edit_mode,
		_tile_payload,
		_overlay_item_key,
		_object_payload,
		_label_payload,
		EDIT_MODE_NAMES
	)


func _target_cell_apply_reason_for_mode() -> String:
	match _edit_mode:
		EditMode.OBJECT, EditMode.LABEL:
			return "Applied marker to HexTileMapLayer."
		EditMode.OVERLAY_TILE:
			return "Applied overlay tile to HexTileMapLayer."
		_:
			return "Applied cell to HexTileMapLayer."


func _document_cell_state(document, hex) -> Dictionary:
	var state = {
		"exists": false,
		"wall": false,
		"tile_overrides": [],
		"objects": [],
		"labels": [],
	}
	var map_resource = _document_map_resource(document)
	if map_resource == null:
		return state
	var data = map_resource.to_map_data()
	state["exists"] = data.has_cell(hex)
	state["wall"] = data.has_wall(hex)
	state["tile_overrides"] = _entries_for_cell(HexMapDocumentAdapter.document_tile_entries(document), hex)
	state["objects"] = _entries_for_cell(HexMapDocumentAdapter.document_object_entries(document), hex)
	state["labels"] = _entries_for_cell(HexMapDocumentAdapter.document_label_entries(document), hex)
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
		"renderer": "none",
		"source_id": -1,
		"atlas_coords": Vector2i(-1, -1),
		"alternative_tile": -1,
		"overlay_source_id": -1,
		"overlay_atlas_coords": Vector2i(-1, -1),
		"overlay_alternative_tile": -1,
		"overlay_count": 0,
		"marker_count": 0,
		"signature": "none:-1:(-1,-1):-1:-1:(-1,-1):-1:0:0",
	}
	if _target_layer == null or not is_instance_valid(_target_layer):
		return state
	if _target_layer is HexTileMapLayer:
		return (_target_layer as HexTileMapLayer).display_state_for_hex(hex, visual_hex)
	if _target_layer is TileMapLayer:
		var flat_top = _document_is_flat_top(_document)
		var map_cell = HexMapTileAdapter.vector_to_map_cell(visual_hex, flat_top)
		state["renderer"] = "TileMapLayer"
		state["source_id"] = (_target_layer as TileMapLayer).get_cell_source_id(map_cell)
		state["atlas_coords"] = (_target_layer as TileMapLayer).get_cell_atlas_coords(map_cell)
		state["alternative_tile"] = (_target_layer as TileMapLayer).get_cell_alternative_tile(map_cell)
		state["signature"] = "%s:%d:%s:%d:%d" % [
			String(state["renderer"]),
			int(state["source_id"]),
			str(state["atlas_coords"]),
			int(state["alternative_tile"]),
			int(state["marker_count"]),
		]
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
	return HexMapDocumentInspector.document_summary(document)


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


func _selected_document_resource() -> HexMapDocumentResource:
	if _document_resource_picker != null \
			and _document_resource_picker.edited_resource is HexMapDocumentResource:
		return _document_resource_picker.edited_resource as HexMapDocumentResource
	return _document


func _refresh_action_button_states() -> void:
	var target_valid = _target_layer != null and is_instance_valid(_target_layer)
	var hex_target = target_valid and _target_layer is HexTileMapLayer
	var document_present = _document != null
	var catalog_present = _ensure_tile_catalog() != null
	_set_button_enabled(_document_browse_button, true, "")
	_set_button_enabled(
		_document_load_button,
		_selected_document_resource() != null or _document_path != "",
		"No document resource selected."
	)
	_set_button_enabled(_document_save_button, document_present, "No document selected.")
	_set_button_enabled(_document_save_as_button, document_present, "No document selected.")
	_set_button_enabled(_document_validate_button, document_present, "No document selected.")
	_set_button_enabled(_import_map_browse_button, true, "")
	_set_button_enabled(
		_import_map_button,
		_import_map_resource != null or _import_map_path != "",
		"No import resource selected."
	)
	_set_button_enabled(_export_button, document_present, "No document selected.")
	_set_button_enabled(_export_save_as_button, document_present, "No document selected.")
	_set_button_enabled(_target_atlas_browse_button, target_valid, "No editable target layer.")
	_set_button_enabled(
		_target_atlas_apply_button,
		target_valid and _target_atlas_path_edit != null and _target_atlas_path_edit.text.strip_edges() != "",
		"No editable target layer or atlas path."
	)
	_set_button_enabled(_target_sample_apply_button, target_valid, "No editable target layer.")
	_set_button_enabled(_select_display_layer_button, hex_target, "No HexTileMapLayer target.")
	_set_button_enabled(_default_tile_read_button, target_valid, "No editable target layer.")
	_set_button_enabled(_default_tile_apply_button, target_valid, "No editable target layer.")
	_set_button_enabled(_layer_stack_create_missing_button, hex_target and document_present, "Layer stack requires HexTileMapLayer target and document.")
	_set_button_enabled(_layer_stack_apply_document_button, hex_target and document_present, "Layer stack requires HexTileMapLayer target and document.")
	_set_button_enabled(_layer_stack_clear_role_button, hex_target and _selected_layer_stack_role != "", "Select a layer stack role.")
	_set_button_enabled(_catalog_add_atlas_button, catalog_present, "No catalog selected.")
	_set_button_enabled(_catalog_add_scene_button, catalog_present, "No catalog selected.")
	_set_button_enabled(_catalog_validate_button, catalog_present, "No catalog selected.")
	if _validation_dashboard != null:
		_validation_dashboard.set_validate_enabled(document_present, "No document selected.")


func _set_button_enabled(button: Button, enabled: bool, reason: String) -> void:
	if button == null:
		return
	button.disabled = not enabled
	button.tooltip_text = "" if enabled else reason


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


func _new_catalog_option(tag: String, selected_key: String = "") -> OptionButton:
	var option = OptionButton.new()
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_populate_catalog_option(option, tag, selected_key)
	return option


func _ensure_tile_catalog() -> HexTileCatalogResource:
	if _tile_catalog == null:
		_tile_catalog = load(SAMPLE_TILE_CATALOG_PATH) as HexTileCatalogResource
	return _tile_catalog


func _refresh_catalog_options() -> void:
	_populate_catalog_option(_default_floor_catalog_option, "floor", _catalog_key_from_option(_default_floor_catalog_option))
	_populate_catalog_option(_default_wall_catalog_option, "wall", _catalog_key_from_option(_default_wall_catalog_option))
	_populate_catalog_option(_tile_catalog_option, _tile_catalog_tag_for_mode(), String(_tile_payload.get("catalog_key", "")))
	_populate_object_key_option(String(_object_payload.get("object_id", "")))
	_refresh_catalog_entries()


func _populate_catalog_option(option: OptionButton, tag: String, selected_key: String = "") -> void:
	if option == null:
		return
	option.clear()
	option.add_item(CATALOG_FALLBACK_LABEL)
	option.set_item_metadata(0, "")
	var selected_index := 0
	var catalog = _ensure_tile_catalog()
	if catalog != null:
		for entry in catalog.entries_with_tag(tag):
			if entry == null:
				continue
			var key = String(entry.get("key"))
			if key == "":
				continue
			var label = String(entry.get("display_name"))
			if label == "":
				label = key
			else:
				label = "%s (%s)" % [label, key]
			option.add_item(label)
			var index = option.item_count - 1
			option.set_item_metadata(index, key)
			if key == selected_key:
				selected_index = index
	option.select(selected_index)


func _populate_object_key_option(selected_key: String = "") -> void:
	if _object_catalog_option == null:
		return
	var database = _object_database as HexObjectDatabaseResource
	if database == null:
		_populate_catalog_option(_object_catalog_option, "object", selected_key)
		return
	_object_catalog_option.clear()
	_object_catalog_option.add_item(CATALOG_FALLBACK_LABEL)
	_object_catalog_option.set_item_metadata(0, "")
	var selected_index := 0
	for definition in database.definitions:
		if definition == null:
			continue
		var key = String(definition.get("id"))
		if key == "":
			continue
		var label = String(definition.get("display_name"))
		if label == "":
			label = key
		else:
			label = "%s (%s)" % [label, key]
		_object_catalog_option.add_item(label)
		var index = _object_catalog_option.item_count - 1
		_object_catalog_option.set_item_metadata(index, key)
		if key == selected_key:
			selected_index = index
	_object_catalog_option.select(selected_index)


func _tile_catalog_tag_for_mode() -> String:
	match _edit_mode:
		EditMode.WALL_TILE:
			return "wall"
		EditMode.OVERLAY_TILE:
			return "overlay"
		_:
			return "floor"


func _catalog_key_from_option(option: OptionButton, index: int = -1) -> String:
	if option == null or option.item_count <= 0:
		return ""
	var selected_index = option.selected if index < 0 else index
	if selected_index < 0 or selected_index >= option.item_count:
		return ""
	return String(option.get_item_metadata(selected_index))


func _select_catalog_option_by_key(option: OptionButton, key: String) -> void:
	if option == null:
		return
	for index in range(option.item_count):
		if String(option.get_item_metadata(index)) == key:
			option.select(index)
			return
	option.select(0)


func _select_object_key_option_by_key(key: String) -> void:
	_select_catalog_option_by_key(_object_catalog_option, key)


func catalog_entry_rows() -> Array[Dictionary]:
	var catalog = _ensure_tile_catalog()
	if catalog == null:
		return []
	var validation = _catalog_validation_result()
	var status_by_index = _catalog_status_by_entry_index(validation)
	var rows: Array[Dictionary] = []
	for index in range(catalog.entries.size()):
		var entry = catalog.entries[index]
		if entry == null:
			rows.append({
				"key": "<missing>",
				"type": "",
				"preview": "",
				"tags": "",
				"status": String(status_by_index.get(index, "warning")),
			})
			continue
		rows.append({
			"key": String(entry.get("key")),
			"type": String(entry.get("entry_type")),
			"preview": _catalog_entry_preview_text(entry),
			"tags": _catalog_entry_tags_text(entry),
			"status": String(status_by_index.get(index, "ok")),
		})
	return rows


func catalog_validation_summary() -> Dictionary:
	var validation = _catalog_validation_result()
	if validation == null:
		return {}
	return {
		"errors": validation.error_count(),
		"warnings": validation.warning_count(),
		"issues": validation.issue_count(),
		"entries": int(validation.summary.get("entries", 0)),
		"tile_set_present": bool(validation.summary.get("tile_set_present", false)),
	}


func _refresh_catalog_entries() -> void:
	if _catalog_entries_tree != null:
		_catalog_entries_tree.clear()
		var root = _catalog_entries_tree.create_item()
		for row in catalog_entry_rows():
			var item = _catalog_entries_tree.create_item(root)
			item.set_text(0, String(row.get("key", "")))
			item.set_text(1, String(row.get("type", "")))
			item.set_text(2, String(row.get("preview", "")))
			item.set_text(3, String(row.get("tags", "")))
			item.set_text(4, String(row.get("status", "")))
	if _catalog_status_label != null:
		_catalog_status_label.text = _catalog_status_text()


func _catalog_validation_result():
	if _last_catalog_validation_result == null:
		_last_catalog_validation_result = HexTileCatalogValidator.validate_catalog(_ensure_tile_catalog())
	return _last_catalog_validation_result


func _catalog_status_by_entry_index(validation) -> Dictionary:
	var statuses := {}
	if validation == null:
		return statuses
	for issue in validation.issues:
		if not issue is Dictionary:
			continue
		var metadata = issue.get("metadata", {})
		if not metadata is Dictionary or not metadata.has("entry_index"):
			continue
		var entry_index = int(metadata.get("entry_index", -1))
		if entry_index < 0:
			continue
		var severity = String(issue.get("severity", ""))
		if severity == HexMapValidationResult.SEVERITY_ERROR:
			statuses[entry_index] = "error"
		elif not statuses.has(entry_index):
			statuses[entry_index] = "warning"
	return statuses


func _catalog_entry_preview_text(entry) -> String:
	var entry_type = String(entry.get("entry_type"))
	if entry_type == HexTileCatalogEntry.TYPE_ATLAS:
		return "tile %d %s alt %d" % [
			int(entry.get("source_id")),
			_atlas_text(entry.get("atlas_coords")),
			int(entry.get("alternative_tile")),
		]
	if entry_type == HexTileCatalogEntry.TYPE_SCENE:
		var scene = entry.get("scene")
		return "scene" if scene is PackedScene else "missing scene"
	if entry_type == HexTileCatalogEntry.TYPE_PLACEHOLDER:
		return "placeholder"
	return "invalid"


func _catalog_entry_tags_text(entry) -> String:
	var tags: PackedStringArray = entry.get("tags")
	return ",".join(tags)


func _catalog_status_text() -> String:
	var catalog = _ensure_tile_catalog()
	if catalog == null:
		return "No catalog selected."
	var validation = _catalog_validation_result()
	var label = String(catalog.display_name if catalog.display_name != "" else catalog.catalog_id)
	if label == "":
		label = "unnamed catalog"
	return "%s entries=%d TileSet=%s errors=%d warnings=%d" % [
		label,
		catalog.entries.size(),
		"yes" if catalog.tile_set != null else "no",
		validation.error_count() if validation != null else 0,
		validation.warning_count() if validation != null else 0,
	]


func _unique_catalog_key(prefix: String) -> String:
	var catalog = _ensure_tile_catalog()
	if catalog == null:
		return prefix
	var index: int = catalog.entries.size() + 1
	var key = "%s_%d" % [prefix, index]
	while catalog.has_key(key):
		index += 1
		key = "%s_%d" % [prefix, index]
	return key


func _catalog_tile_config(key: String, fallback: Dictionary = {}) -> Dictionary:
	var config = HexMapTileAdapter.tile_config_from_catalog(_ensure_tile_catalog(), key)
	return config if int(config.get("source_id", -1)) >= 0 else fallback


func _apply_catalog_config_to_spins(
	config: Dictionary,
	source_spin: SpinBox,
	atlas_x_spin: SpinBox,
	atlas_y_spin: SpinBox,
	alternative_spin: SpinBox
) -> bool:
	if int(config.get("source_id", -1)) < 0:
		return false
	source_spin.set_value_no_signal(int(config.get("source_id", 0)))
	var atlas = config.get("atlas_coords", Vector2i.ZERO)
	atlas_x_spin.set_value_no_signal(int(atlas.x))
	atlas_y_spin.set_value_no_signal(int(atlas.y))
	alternative_spin.set_value_no_signal(int(config.get("alternative_tile", 0)))
	return true


func _wrap_labeled(label_text: String, control: Control) -> Control:
	var box = HBoxContainer.new()
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 82.0
	box.add_child(label)
	box.add_child(control)
	return box
