@tool
class_name HexMapBuildScreen
extends VBoxContainer

signal graph_generated(report: Dictionary)
signal promote_requested(node_id: String, role: String)

const HexMapWorkspaceAssetContextScript = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")
const HexMapBuildGraphCanvasScript = preload("res://addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd")
const HexMapBuildNodePaletteScript = preload("res://addons/hex_map_kit/editor/hex_map_build_node_palette.gd")
const HexMapBuildNodeInspectorScript = preload("res://addons/hex_map_kit/editor/hex_map_build_node_inspector.gd")
const HexMapPreviewThumbnailScript = preload("res://addons/hex_map_kit/editor/hex_map_preview_thumbnail.gd")
const HexGenerationPromoteScript = preload("res://addons/hex_map_kit/generation/hex_generation_promote.gd")

const TAB_NAME := "Build"
const WORKFLOW_OWNER := "Build"
const USER_TASK := "Build a generation graph and inspect node outputs."
const SCREEN_SCRIPT := "hex_map_build_screen.gd"

var _workspace_asset_context: HexMapWorkspaceAssetContextScript = null
var _context_label: Label
var _generate_button: Button
var _status_label: Label
var _canvas: HexMapBuildGraphCanvasScript
var _palette: HexMapBuildNodePaletteScript
var _preview: HexMapPreviewThumbnailScript
var _preview_status_label: Label
var _inspector: HexMapBuildNodeInspectorScript
var _last_report: Dictionary = {}
var _last_promote_result: Dictionary = {}


func _ready() -> void:
	if _canvas == null:
		_build_ui()
	_refresh_context()
	_refresh_selected_node()


func set_workspace_asset_context(context: HexMapWorkspaceAssetContextScript) -> void:
	_workspace_asset_context = context
	_refresh_context()


func workspace_asset_context() -> HexMapWorkspaceAssetContextScript:
	return _workspace_asset_context


func graph_canvas() -> HexMapBuildGraphCanvasScript:
	return _canvas


func node_inspector() -> HexMapBuildNodeInspectorScript:
	return _inspector


func node_palette() -> HexMapBuildNodePaletteScript:
	return _palette


func output_preview() -> HexMapPreviewThumbnailScript:
	return _preview


func run_graph() -> Dictionary:
	if _canvas == null:
		return {}
	_last_report = _canvas.run_graph(_run_context())
	_refresh_preview()
	_refresh_selected_node()
	if _status_label != null:
		_status_label.text = String((_canvas.canvas_snapshot() as Dictionary).get("status_text", ""))
	graph_generated.emit(_last_report.duplicate(true))
	return _last_report.duplicate(true)


func build_default_three_node_chain_and_preview() -> Dictionary:
	_canvas.build_default_three_node_chain()
	return run_graph()


func build_vertical_slice_chain_and_preview() -> Dictionary:
	_canvas.build_default_vertical_slice_chain()
	return run_graph()


func promote_selected_output(role: String = "overlay") -> Dictionary:
	if _canvas == null:
		return {}
	if _workspace_asset_context == null or _workspace_asset_context.level_document == null:
		_last_promote_result = {
			"ok": false,
			"blocked_reason": "Choose a Level Document before promoting graph output.",
		}
		_refresh_selected_node()
		return _last_promote_result.duplicate(true)
	_last_promote_result = HexGenerationPromoteScript.promote(
		_canvas.selected_output(),
		_workspace_asset_context.level_document,
		role,
		{"graph_node_id": _canvas.selected_node_id()}
	)
	if _status_label != null:
		_status_label.text = String(_last_promote_result.get("status_text", _last_promote_result.get("blocked_reason", "")))
	_refresh_selected_node()
	return _last_promote_result.duplicate(true)


func build_screen_snapshot() -> Dictionary:
	var canvas_snapshot := _canvas.canvas_snapshot() if _canvas != null else {}
	var inspector_snapshot := _inspector.inspector_snapshot() if _inspector != null else {}
	var preview_snapshot := _preview.preview_snapshot() if _preview != null else HexMapPreviewThumbnailScript.unavailable_preview("missing")
	return {
		"component": "HexMapBuildScreen",
		"screen_role_source": "HexMapBuildScreen",
		"screen_script": SCREEN_SCRIPT,
		"tab": TAB_NAME,
		"workflow_owner": WORKFLOW_OWNER,
		"user_task": USER_TASK,
		"first_surface": "graph_canvas",
		"canvas_is_dominant": true,
		"resource_row_primary": false,
		"primary_action": "Generate",
		"generate_button_present": _generate_button != null,
		"status_text": _status_label.text if _status_label != null else "",
		"context_text": _context_label.text if _context_label != null else "",
		"canvas": canvas_snapshot,
		"palette": _palette.palette_snapshot() if _palette != null else {},
		"inspector": inspector_snapshot,
		"preview": preview_snapshot,
		"preview_available": bool(preview_snapshot.get("available", false)),
		"three_node_chain_ready": int(canvas_snapshot.get("node_count", 0)) >= 3 and int(canvas_snapshot.get("connection_count", 0)) >= 2,
		"graph_chain_runs": bool(_last_report.get("ok", false)),
		"promote_result": _last_promote_result.duplicate(true),
		"promote_available": _inspector != null and bool((_inspector.inspector_snapshot() as Dictionary).get("promote_enabled", false)),
		"label_heavy_but_metrics_pass": false,
	}


static func screen_contract() -> Dictionary:
	return {
		"screen_role_source": "HexMapBuildScreen",
		"screen_script": SCREEN_SCRIPT,
		"tab": TAB_NAME,
		"workflow_owner": WORKFLOW_OWNER,
		"user_task": USER_TASK,
		"owns": PackedStringArray([
			"build_graph_canvas",
			"build_node_palette",
			"build_node_inspector",
			"build_output_preview",
		]),
		"delegates": {},
	}


func _build_ui() -> void:
	name = "Build Graph Screen"
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	var top_row := HBoxContainer.new()
	top_row.name = "Build Context Strip"
	top_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_context_label = Label.new()
	_context_label.name = "Build Context Chips"
	_context_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_context_label.clip_text = true
	top_row.add_child(_context_label)
	_generate_button = Button.new()
	_generate_button.name = "Build Generate Button"
	_generate_button.text = "Generate"
	_generate_button.pressed.connect(_on_generate_pressed)
	top_row.add_child(_generate_button)
	add_child(top_row)

	var split := HSplitContainer.new()
	split.name = "Build Work Surface"
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(split)

	var canvas_area := HBoxContainer.new()
	canvas_area.name = "Build Canvas Area"
	canvas_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_palette = HexMapBuildNodePaletteScript.new()
	canvas_area.add_child(_palette)
	_canvas = HexMapBuildGraphCanvasScript.new()
	canvas_area.add_child(_canvas)
	split.add_child(canvas_area)

	var preview_panel := VBoxContainer.new()
	preview_panel.name = "Build Output Preview"
	preview_panel.custom_minimum_size = Vector2(190, 180)
	_preview = HexMapPreviewThumbnailScript.new()
	_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_panel.add_child(_preview)
	_preview_status_label = Label.new()
	_preview_status_label.name = "Build Preview Status"
	_preview_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview_panel.add_child(_preview_status_label)
	split.add_child(preview_panel)

	_inspector = HexMapBuildNodeInspectorScript.new()
	add_child(_inspector)

	_status_label = Label.new()
	_status_label.name = "Build Graph Status"
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_status_label)

	_palette.node_type_requested.connect(_on_palette_node_type_requested)
	_canvas.selected_graph_node_changed.connect(_on_canvas_selected_node_changed)
	_canvas.graph_changed.connect(_on_canvas_graph_changed)
	_canvas.graph_run_completed.connect(_on_canvas_graph_run_completed)
	_inspector.node_params_changed.connect(_on_inspector_params_changed)
	_inspector.promote_requested.connect(_on_inspector_promote_requested)
	_refresh_preview()


func _run_context() -> Dictionary:
	var result := {}
	if _workspace_asset_context == null:
		return result
	if _workspace_asset_context.level_document != null:
		result["document"] = _workspace_asset_context.level_document
		result["document_terrain"] = _workspace_asset_context.level_document
	return result


func _refresh_context() -> void:
	if _context_label == null:
		return
	var map_text := "Map: choose"
	var catalog_text := "Catalog: choose"
	var target_text := "Target: generated terrain"
	if _workspace_asset_context != null:
		if _workspace_asset_context.level_document != null:
			map_text = "Map: Level Document"
		if _workspace_asset_context.tile_catalog != null:
			catalog_text = "Catalog: linked"
	_context_label.text = "( %s ) ( %s ) ( %s )" % [map_text, catalog_text, target_text]


func _refresh_selected_node() -> void:
	if _inspector == null or _canvas == null:
		return
	var node := _canvas.selected_node_dictionary()
	if node.is_empty():
		_inspector.clear_inspector()
		return
	_inspector.inspect_node(node, _canvas.selected_output_type(), _canvas.selected_preview_snapshot())
	_inspector.set_promote_enabled(_workspace_asset_context != null and _workspace_asset_context.level_document != null)


func _refresh_preview() -> void:
	if _preview == null or _canvas == null:
		return
	var snapshot := _canvas.selected_preview_snapshot()
	_preview.set_preview_snapshot(snapshot)
	if _preview_status_label != null:
		if bool(snapshot.get("available", false)):
			_preview_status_label.text = "%s preview: %d cells" % [
				String(snapshot.get("source_kind", "")),
				int(snapshot.get("cell_count", int(snapshot.get("entry_count", 0)))),
			]
		else:
			_preview_status_label.text = "Preview waits for Generate."


func _on_generate_pressed() -> void:
	run_graph()


func _on_palette_node_type_requested(node_type: String) -> void:
	var index := _canvas.canvas_snapshot().get("node_count", 0)
	var node_id := _canvas.add_graph_node(node_type, Vector2(80 + int(index) * 160, 110))
	if node_id != "":
		_canvas.select_graph_node(node_id)
	_refresh_selected_node()


func _on_canvas_selected_node_changed(_node_id: String) -> void:
	_refresh_selected_node()
	_refresh_preview()


func _on_canvas_graph_changed() -> void:
	if _status_label != null:
		_status_label.text = String((_canvas.canvas_snapshot() as Dictionary).get("status_text", ""))


func _on_canvas_graph_run_completed(_report: Dictionary) -> void:
	_refresh_preview()
	_refresh_selected_node()


func _on_inspector_params_changed(node_id: String, params: Dictionary) -> void:
	_canvas.set_node_params(node_id, params)


func _on_inspector_promote_requested(node_id: String, role: String) -> void:
	if _canvas != null:
		_canvas.select_graph_node(node_id)
	promote_selected_output(role)
	promote_requested.emit(node_id, role)
