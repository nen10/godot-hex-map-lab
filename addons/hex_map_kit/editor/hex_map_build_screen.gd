@tool
class_name HexMapBuildScreen
extends VBoxContainer

signal graph_generated(report: Dictionary)
signal promote_requested(node_id: String, role: String)
signal load_graph_requested(overwrite_selected: bool)
signal build_context_requested

const HexMapWorkspaceAssetContextScript = preload("res://addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd")
const HexMapBuildGraphCanvasScript = preload("res://addons/hex_map_kit/editor/hex_map_build_graph_canvas.gd")
const HexMapBuildNodePaletteScript = preload("res://addons/hex_map_kit/editor/hex_map_build_node_palette.gd")
const HexMapBuildNodeInspectorScript = preload("res://addons/hex_map_kit/editor/hex_map_build_node_inspector.gd")
const HexGenerationPresetScript = preload("res://addons/hex_map_kit/generation/hex_generation_preset.gd")
const HexGenerationPromoteScript = preload("res://addons/hex_map_kit/generation/hex_generation_promote.gd")
const HexGenerationNodeTypesScript = preload("res://addons/hex_map_kit/generation/hex_generation_node_types.gd")
const HexGenerationGraphRunnerScript = preload("res://addons/hex_map_kit/generation/hex_generation_graph_runner.gd")
const HexGenerationPortsScript = preload("res://addons/hex_map_kit/generation/hex_generation_ports.gd")
const HexGenerationGraphResourceScript = preload("res://addons/hex_map_kit/adapter/hex_generation_graph_resource.gd")
const HexTileMapLayerScript = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")
const HexLayerStackResourceScript = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd")
const HexMapDocumentApplierScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_applier.gd")
const HexMapDocumentAdapterScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_adapter.gd")

const TAB_NAME := "Build"
const WORKFLOW_OWNER := "Build"
const USER_TASK := "Build a generation graph and inspect node outputs."
const SCREEN_SCRIPT := "hex_map_build_screen.gd"

var _workspace_asset_context: HexMapWorkspaceAssetContextScript = null
var _context_label: Label
var _load_graph_button: Button
var _overwrite_selected_check: CheckBox
var _profile_option: OptionButton
var _simple_generate_button: Button
var _generate_button: Button
var _cancel_button: Button
var _run_count_spin: SpinBox
var _seed_randomize_check: CheckBox
var _shape_randomize_check: CheckBox
var _status_label: Label
var _run_progress_popup: PopupPanel
var _run_progress_status_label: Label
var _run_progress_detail_label: Label
var _run_progress_bar: ProgressBar
var _canvas: HexMapBuildGraphCanvasScript
var _palette: HexMapBuildNodePaletteScript
var _inspector: HexMapBuildNodeInspectorScript
var _apply_button: Button
var _revert_button: Button
var _delete_edge_button: Button
var _preview_applied := false
var _revert_terrain_layers: Array = []
var _revert_overlay_layers: Array = []
var _revert_object_placements: Array = []
var _last_report: Dictionary = {}
var _last_promote_result: Dictionary = {}
var _last_build_context_result: Dictionary = {}
var _last_graph_load_result: Dictionary = {}
var _last_simple_generate_result: Dictionary = {}
var _last_viewport_apply_report: Dictionary = {}
var _context_hex_tile_map_layer: HexTileMapLayerScript = null
var _build_context_provider: Callable
var _preview_commit_state := "none"
var _run_busy := false
var _cancel_requested := false
var _run_progress_snapshot: Dictionary = {}
var _run_progress_node_context: Dictionary = {}
var _run_progress_popup_hide_token := 0
var _async_graph_thread: Thread = null
var _async_graph_mutex := Mutex.new()
var _async_graph_run_id := 0
var _async_graph_report: Dictionary = {}
var _async_graph_context: Dictionary = {}
var _async_graph_options: Dictionary = {}
var _async_graph_auto_preview := false
var _external_progress_callback: Callable
var _external_cancel_callback: Callable


func _ready() -> void:
	if _canvas == null:
		_build_ui()
	_refresh_context()
	_refresh_selected_node()


func _exit_tree() -> void:
	if _async_graph_thread != null:
		_set_cancel_requested_thread_safe(true)
		_async_graph_thread.wait_to_finish()
		_async_graph_thread = null


func set_workspace_asset_context(context: HexMapWorkspaceAssetContextScript) -> void:
	_workspace_asset_context = context
	_refresh_context()


func set_build_context_provider(provider: Callable) -> void:
	_build_context_provider = provider


func workspace_asset_context() -> HexMapWorkspaceAssetContextScript:
	return _workspace_asset_context


func graph_canvas() -> HexMapBuildGraphCanvasScript:
	return _canvas


func node_inspector() -> HexMapBuildNodeInspectorScript:
	return _inspector


func node_palette() -> HexMapBuildNodePaletteScript:
	return _palette


func run_graph(options: Dictionary = {}) -> Dictionary:
	if _canvas == null:
		return {}
	_run_busy = true
	_set_cancel_requested_thread_safe(false)
	_run_progress_snapshot = {}
	_run_progress_node_context = {}
	_update_run_controls()
	var context := _run_context()
	context["interrupt_options"] = _build_interrupt_options(options)
	var report := _canvas.run_graph(context)
	_run_busy = false
	_update_run_controls()
	return _finalize_graph_run(report, options)


func _begin_async_graph_run(options: Dictionary = {}, auto_preview: bool = false) -> bool:
	if _canvas == null or _run_busy:
		return false
	_run_busy = true
	_set_cancel_requested_thread_safe(false)
	_set_run_progress_snapshot_thread_safe({
		"phase": "preparing",
		"node_id": "",
		"node_title": "",
		"node_type": "",
		"steps": 0,
		"total_steps": 1,
		"progress": 0.0,
		"cancelled": false,
	})
	_run_progress_node_context = {}
	_update_run_controls()
	_show_run_progress_popup()
	_apply_graph_run_progress(_run_progress_snapshot_copy())

	var context := _run_context()
	context["interrupt_options"] = _build_interrupt_options(options)
	var prepared := _canvas.prepare_graph_run(context)
	var graph := prepared.get("graph", {}) as Dictionary
	var run_context := prepared.get("context", {}) as Dictionary

	_async_graph_mutex.lock()
	_async_graph_run_id += 1
	var run_id := _async_graph_run_id
	_async_graph_report = {}
	_async_graph_context = {}
	_async_graph_options = options.duplicate(true)
	_async_graph_auto_preview = auto_preview
	_async_graph_mutex.unlock()

	_async_graph_thread = Thread.new()
	var err := _async_graph_thread.start(Callable(self, "_async_graph_run_thread").bind(run_id, graph, run_context))
	if err != OK:
		_async_graph_thread = null
		_run_busy = false
		_update_run_controls()
		_finish_run_progress_popup("Failed")
		if _status_label != null:
			_status_label.text = "Graph run could not start."
		return false
	return true


func _async_graph_run_thread(run_id: int, graph: Dictionary, run_context: Dictionary) -> void:
	var report := HexGenerationGraphRunnerScript.run_with_report(graph, run_context)
	_async_graph_mutex.lock()
	if run_id == _async_graph_run_id:
		_async_graph_report = report.duplicate(true)
		_async_graph_context = run_context.duplicate(true)
	_async_graph_mutex.unlock()
	call_deferred("_complete_async_graph_run", run_id)


func _complete_async_graph_run(run_id: int) -> void:
	if _async_graph_thread == null:
		return
	_async_graph_thread.wait_to_finish()
	_async_graph_thread = null

	_async_graph_mutex.lock()
	var is_current := run_id == _async_graph_run_id
	var report := _async_graph_report.duplicate(true)
	var run_context := _async_graph_context.duplicate(true)
	var options := _async_graph_options.duplicate(true)
	var auto_preview := _async_graph_auto_preview
	_async_graph_mutex.unlock()
	if not is_current:
		return

	var completed_report := _canvas.complete_graph_run(report, run_context)
	_run_busy = false
	_update_run_controls()
	_finalize_graph_run(completed_report, options)
	if auto_preview and bool(completed_report.get("ok", false)):
		_auto_preview_after_generate()
	if bool(completed_report.get("cancelled", false)):
		_finish_run_progress_popup("Cancelled")
	elif bool(completed_report.get("ok", false)):
		_finish_run_progress_popup("Ready")
	else:
		_finish_run_progress_popup("Failed")


func _finalize_graph_run(report: Dictionary, options: Dictionary = {}) -> Dictionary:
	_last_report = report.duplicate(true)
	_refresh_selected_node()
	if _status_label != null:
		var run_state := _canvas.run_state_snapshot()
		if bool(run_state.get("cancelled", false)):
			_status_label.text = "Graph run cancelled."
		elif bool(run_state.get("failure_visible", false)):
			_status_label.text = "Graph stopped at %s." % String(run_state.get("failure_node_id", ""))
		else:
			_status_label.text = String((_canvas.canvas_snapshot() as Dictionary).get("status_text", ""))
	_last_report["requested_count"] = int(options.get("count", _run_count_value()))
	_last_report["primary_generate"] = true
	graph_generated.emit(_last_report.duplicate(true))
	return _last_report.duplicate(true)


func build_default_three_node_chain_and_preview() -> Dictionary:
	_canvas.build_default_three_node_chain()
	return run_graph()


func build_vertical_slice_chain_and_preview() -> Dictionary:
	_canvas.build_default_vertical_slice_chain()
	return run_graph()


func run_simple_profile_graph(options: Dictionary = {}) -> Dictionary:
	if _canvas == null:
		_last_simple_generate_result = _simple_generate_result(false, "Build graph canvas is unavailable.")
		return _last_simple_generate_result.duplicate(true)

	var profile = _active_generation_profile()
	var graph := HexGenerationPresetScript.from_profile(profile)
	var selected_node_id := HexGenerationPresetScript.default_selected_node_id()
	var promote_role := String(options.get("promote_role", HexGenerationPresetScript.default_promote_role()))
	var restore_report := _canvas.restore_graph_model(graph, selected_node_id)
	var run_report := {}
	var promote_result := {}
	if bool(restore_report.get("ok", false)):
		run_report = run_graph({
			"count": int(options.get("count", 1)),
			"interrupt_options": options.get("interrupt_options", {}),
		})
		if bool(run_report.get("ok", false)) and _workspace_asset_context != null and _workspace_asset_context.level_document != null:
			_canvas.select_graph_node(selected_node_id)
			_auto_preview_after_generate()
			promote_result = _last_promote_result.duplicate(true)
			if promote_result.is_empty():
				promote_result = {
					"ok": _last_viewport_projection_ok(),
					"written_role": promote_role,
					"blocked_reason": String(_last_viewport_apply_report.get("blocked_reason", "")),
				}
	else:
		_refresh_selected_node()

	var profile_id := _profile_id(profile)
	var profile_display_name := _profile_display_name(profile)
	var canvas_snapshot := _canvas.canvas_snapshot()
	var graph_resource = _store_current_canvas_graph_on_context_layer(promote_role) if bool(restore_report.get("ok", false)) else null
	_last_simple_generate_result = {
		"ok": bool(restore_report.get("ok", false)) and bool(run_report.get("ok", false)),
		"blocked_reason": "" if bool(restore_report.get("ok", false)) else String(restore_report.get("reason", "Preset graph could not be restored.")),
		"profile_id": profile_id,
		"profile_display_name": profile_display_name,
		"uses_project_resource": profile != null,
		"graph_node_count": int(canvas_snapshot.get("node_count", 0)),
		"graph_connection_count": int(canvas_snapshot.get("connection_count", 0)),
		"preset_graph_visible_in_canvas": int(canvas_snapshot.get("node_count", 0)) >= 3 and int(canvas_snapshot.get("connection_count", 0)) >= 2,
		"selected_node_id": _canvas.selected_node_id(),
		"promote_target_role": promote_role,
		"graph_resource": graph_resource,
		"context_layer_has_graph_resource": _context_hex_tile_map_layer != null and _context_hex_tile_map_layer.generation_graph_resource != null,
		"restore_report": restore_report,
		"run_report": run_report,
		"promote_result": promote_result,
		"status_text": "Simple profile graph generated.",
	}
	if _status_label != null and bool(_last_simple_generate_result["ok"]):
		_status_label.text = String(_last_simple_generate_result["status_text"])
	_refresh_context()
	_refresh_selected_node()
	return _last_simple_generate_result.duplicate(true)


func ensure_graph_context_for_hex_tile_map_layer(
	layer: HexTileMapLayerScript,
	options: Dictionary = {}
) -> Dictionary:
	if _canvas == null:
		_last_build_context_result = _build_context_result(false, "Build graph canvas is unavailable.")
		return _last_build_context_result.duplicate(true)
	if layer == null:
		_context_hex_tile_map_layer = null
		_last_build_context_result = _build_context_result(false, "Choose or create a HexTileMapLayer before building a graph.")
		return _last_build_context_result.duplicate(true)
	_context_hex_tile_map_layer = layer
	if _workspace_asset_context == null:
		_workspace_asset_context = HexMapWorkspaceAssetContextScript.new()

	var created_document := false
	if layer.level_document_resource == null:
		var document = layer.to_document_resource()
		document.resource_name = "%s Build Document" % _resource_prefix_from_node(layer.name)
		layer.level_document_resource = document
		created_document = true
	_workspace_asset_context.set_level_document(
		layer.level_document_resource,
		HexMapWorkspaceAssetContextScript.SOURCE_PROJECT,
		"Selected Node"
	)
	if layer.layer_stack_resource != null:
		_workspace_asset_context.set_layer_stack(
			layer.layer_stack_resource,
			HexMapWorkspaceAssetContextScript.SOURCE_PROJECT,
			"Selected Node"
		)
	else:
		var stack = HexLayerStackResourceScript.standard_template() as HexLayerStackResourceScript
		if stack != null:
			layer.layer_stack_resource = stack
			_workspace_asset_context.set_layer_stack(
				stack,
				HexMapWorkspaceAssetContextScript.SOURCE_PROJECT,
				"Selected Node"
			)

	var created_graph := false
	var restore_report := {}
	if layer.generation_graph_resource == null:
		_canvas.build_default_vertical_slice_chain()
		var graph_resource = HexGenerationGraphResourceScript.from_dict(_canvas.build_graph_model())
		graph_resource.graph_id = "%s_build_graph" % _resource_prefix_from_node(layer.name).to_snake_case()
		graph_resource.resource_name = "%s Build Graph" % _resource_prefix_from_node(layer.name)
		layer.generation_graph_resource = graph_resource
		created_graph = true
		restore_report = {
			"ok": true,
			"node_count": int(_canvas.canvas_snapshot().get("node_count", 0)),
			"connection_count": int(_canvas.canvas_snapshot().get("connection_count", 0)),
			"selected_node_id": _canvas.selected_node_id(),
		}
	else:
		restore_report = _canvas.restore_graph_model(
			layer.generation_graph_resource.to_graph_model(),
			String(options.get("selected_node_id", "weighted_items"))
		)

	var run_report := {}
	if bool(options.get("run", true)):
		run_report = run_graph()
	else:
		_refresh_selected_node()
	_last_build_context_result = {
		"ok": bool(restore_report.get("ok", false)),
		"created_graph": created_graph,
		"created_document": created_document,
		"selected_layer": layer,
		"selected_layer_name": layer.name,
		"graph_resource": layer.generation_graph_resource,
		"document": layer.level_document_resource,
		"restore_report": restore_report,
		"run_report": run_report,
		"status_text": "Build graph context ready.",
	}
	if _status_label != null:
		_status_label.text = String(_last_build_context_result["status_text"])
	_refresh_context()
	_refresh_selected_node()
	return _last_build_context_result.duplicate(true)


func load_graph_resource(graph_resource: HexGenerationGraphResourceScript, options: Dictionary = {}) -> Dictionary:
	if _canvas == null:
		_last_graph_load_result = _graph_load_result(false, "Build graph canvas is unavailable.")
		return _last_graph_load_result.duplicate(true)
	if graph_resource == null:
		_last_graph_load_result = _graph_load_result(false, "Choose a Generation Graph resource.")
		return _last_graph_load_result.duplicate(true)

	var restore_report := _canvas.restore_graph_model(
		graph_resource.to_graph_model(),
		String(options.get("selected_node_id", "weighted_items"))
	)
	var run_report := {}
	if bool(options.get("run", false)):
		run_report = run_graph()
	else:
		_refresh_selected_node()
	_last_graph_load_result = {
		"ok": bool(restore_report.get("ok", false)),
		"blocked_reason": "" if bool(restore_report.get("ok", false)) else String(restore_report.get("reason", "Graph resource could not be restored.")),
		"graph_resource": graph_resource,
		"graph_id": graph_resource.graph_id,
		"restore_report": restore_report,
		"run_report": run_report,
		"overwrite_selected": _overwrite_selected_check != null and _overwrite_selected_check.button_pressed,
	}
	if _status_label != null:
		_status_label.text = "Graph loaded: %s" % graph_resource.graph_id if bool(_last_graph_load_result["ok"]) else String(_last_graph_load_result["blocked_reason"])
	_refresh_context()
	_refresh_selected_node()
	return _last_graph_load_result.duplicate(true)


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
	if role == HexGenerationPortsScript.RESULT or _canvas.selected_output_type() == HexGenerationPortsScript.RESULT:
		_last_promote_result = _promote_result_report(
			_canvas.selected_output(),
			_canvas.selected_node_id(),
			_canvas.selected_node_dictionary()
		)
	else:
		_last_promote_result = HexGenerationPromoteScript.promote(
			_canvas.selected_output(),
			_workspace_asset_context.level_document,
			role,
			{"graph_node_id": _canvas.selected_node_id()}
		)
	if bool(_last_promote_result.get("ok", false)):
		_last_viewport_apply_report = _apply_document_to_context_layer()
	if _status_label != null:
		_status_label.text = String(_last_promote_result.get("status_text", _last_promote_result.get("blocked_reason", "")))
	_refresh_selected_node()
	return _last_promote_result.duplicate(true)


func build_screen_snapshot() -> Dictionary:
	var canvas_snapshot := _canvas.canvas_snapshot() if _canvas != null else {}
	var run_state := _canvas.run_state_snapshot() if _canvas != null else {}
	var inspector_snapshot := _inspector.inspector_snapshot() if _inspector != null else {}
	var progress_snapshot := _run_progress_snapshot_copy()
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
		"load_graph_button_present": _load_graph_button != null,
		"overwrite_selected_graph_check_present": _overwrite_selected_check != null,
		"overwrite_selected_graph": _overwrite_selected_check != null and _overwrite_selected_check.button_pressed,
		"overwrite_selected_graph_default": false,
		"last_graph_load": _last_graph_load_result.duplicate(true),
		"simple_profile_bar_present": _profile_option != null and _simple_generate_button != null,
		"simple_profile_option_present": _profile_option != null,
		"simple_generate_button_present": _simple_generate_button != null,
		"simple_profile_selected": _selected_profile_label(),
		"simple_profile_uses_project_resource": _active_generation_profile() != null,
		"simple_generate_result": _last_simple_generate_result.duplicate(true),
		"simple_and_graph_same_model": bool(_last_simple_generate_result.get("preset_graph_visible_in_canvas", false)) \
			and int(canvas_snapshot.get("node_count", 0)) == int(_last_simple_generate_result.get("graph_node_count", -1)),
		"preset_graph_visible_in_canvas": bool(_last_simple_generate_result.get("preset_graph_visible_in_canvas", false)),
		"promote_target_role": String(_last_simple_generate_result.get("promote_target_role", HexGenerationPresetScript.default_promote_role())),
		"dirty_status_visible": true,
		"last_run_visible": true,
		"generate_button_present": _generate_button != null,
		"cancel_button_present": _cancel_button != null,
		"cancel_button_location": "popup",
		"cancel_available": _cancel_button != null and not _cancel_button.disabled,
		"run_busy": _run_busy,
		"run_progress": float(progress_snapshot.get("progress", run_state.get("progress", 0.0))),
		"run_progress_phase": String(progress_snapshot.get("phase", run_state.get("progress_phase", ""))),
		"run_progress_node_id": String(progress_snapshot.get("node_id", run_state.get("progress_node_id", ""))),
		"run_progress_popup_present": _run_progress_popup != null,
		"run_progress_popup_visible": _run_progress_popup != null and _run_progress_popup.visible,
		"run_progress_popup_status": _run_progress_status_label.text if _run_progress_status_label != null else "",
		"run_progress_popup_detail": _run_progress_detail_label.text if _run_progress_detail_label != null else "",
		"last_cancelled": bool(run_state.get("cancelled", false)),
		"primary_generate_count": 1,
		"generate_default_count": 1,
		"batch_controls_secondary": true,
		"batch_count": _run_count_value(),
		"seed_randomize": _seed_randomize_check != null and _seed_randomize_check.button_pressed,
		"shape_randomize": _shape_randomize_check != null and _shape_randomize_check.button_pressed,
		"status_text": _status_label.text if _status_label != null else "",
		"context_text": _context_label.text if _context_label != null else "",
		"context_chips": _build_context_chips(),
		"context_chips_visible": _context_label != null,
		"context_chips_text": _context_label.text if _context_label != null else "",
		"global_map_chip_duplicated": false,
		"canvas": canvas_snapshot,
		"run_state": run_state,
		"cache_ready": bool(run_state.get("cache_ready", false)),
		"dirty_node_ids": run_state.get("dirty_node_ids", PackedStringArray()),
		"failure_node_id": String(run_state.get("failure_node_id", "")),
		"palette": _palette.palette_snapshot() if _palette != null else {},
		"inspector": inspector_snapshot,
		"preview_available": bool(run_state.get("cache_ready", false)),
		"preview": canvas_snapshot.get("preview", {}),
		"node_thumbnail_secondary": true,
		"preview_applied": _preview_applied,
		"preview_commit_state": _preview_commit_state,
		"viewport_preview_visible": _viewport_preview_visible(),
		"viewport_preview_layer_path": _context_layer_path(),
		"viewport_preview_cell_count": _viewport_preview_cell_count(),
		"viewport_apply_report": _last_viewport_apply_report.duplicate(true),
		"viewport_projection_status": String(_last_viewport_apply_report.get("projection_status", "not_projected")),
		"commit_actions_below_canvas": true,
		"canvas_minimum_height": int(_canvas.custom_minimum_size.y) if _canvas != null else 0,
		"three_node_chain_ready": int(canvas_snapshot.get("node_count", 0)) >= 3 and int(canvas_snapshot.get("connection_count", 0)) >= 2,
		"graph_chain_runs": bool(_last_report.get("ok", false)),
		"promote_result": _last_promote_result.duplicate(true),
		"promote_available": _inspector != null and bool((_inspector.inspector_snapshot() as Dictionary).get("promote_enabled", false)),
		"build_context": _last_build_context_result.duplicate(true),
		"build_context_ready": bool(_last_build_context_result.get("ok", false)),
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
	_load_graph_button = Button.new()
	_load_graph_button.name = "Build Load Graph Button"
	_load_graph_button.text = "Load Graph"
	_style_compact_control(_load_graph_button)
	_load_graph_button.pressed.connect(_on_load_graph_pressed)
	top_row.add_child(_load_graph_button)
	_overwrite_selected_check = CheckBox.new()
	_overwrite_selected_check.name = "Build Overwrite Selected Graph"
	_overwrite_selected_check.text = "Overwrite selected"
	_overwrite_selected_check.button_pressed = false
	_style_compact_control(_overwrite_selected_check)
	top_row.add_child(_overwrite_selected_check)
	_generate_button = Button.new()
	_generate_button.name = "Build Generate Button"
	_generate_button.text = "Generate"
	_style_compact_control(_generate_button)
	_generate_button.pressed.connect(_on_generate_pressed)
	top_row.add_child(_generate_button)
	add_child(top_row)

	var simple_row := HBoxContainer.new()
	simple_row.name = "Build Simple Profile Bar"
	simple_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var profile_label := Label.new()
	profile_label.name = "Build Simple Profile Label"
	profile_label.text = "Profile"
	simple_row.add_child(profile_label)
	_profile_option = OptionButton.new()
	_profile_option.name = "Build Simple Profile Option"
	_profile_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	simple_row.add_child(_profile_option)
	_simple_generate_button = Button.new()
	_simple_generate_button.name = "Build Simple Generate Button"
	_simple_generate_button.text = "Generate (Simple)"
	_style_compact_control(_simple_generate_button)
	_simple_generate_button.pressed.connect(_on_simple_generate_pressed)
	simple_row.add_child(_simple_generate_button)
	add_child(simple_row)

	var split := HSplitContainer.new()
	split.name = "Build Work Surface"
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.size_flags_stretch_ratio = 3.0
	split.custom_minimum_size = Vector2(0, 420)
	add_child(split)

	var canvas_area := VBoxContainer.new()
	canvas_area.name = "Build Canvas Area"
	canvas_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_canvas = HexMapBuildGraphCanvasScript.new()
	canvas_area.add_child(_canvas)
	_palette = HexMapBuildNodePaletteScript.new()
	canvas_area.add_child(_palette)
	split.add_child(canvas_area)

	var action_row := HBoxContainer.new()
	action_row.name = "Build Graph Actions"
	action_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var batch_label := Label.new()
	batch_label.name = "Build Batch Label"
	batch_label.text = "Batch"
	batch_label.add_theme_font_size_override("font_size", 18)
	action_row.add_child(batch_label)
	_run_count_spin = SpinBox.new()
	_run_count_spin.name = "Build Batch Count"
	_run_count_spin.min_value = 1
	_run_count_spin.max_value = 32
	_run_count_spin.step = 1
	_run_count_spin.value = 1
	_run_count_spin.custom_minimum_size = Vector2(72, 0)
	_style_compact_control(_run_count_spin)
	action_row.add_child(_run_count_spin)
	_seed_randomize_check = CheckBox.new()
	_seed_randomize_check.name = "Build Seed Randomize"
	_seed_randomize_check.text = "Seed"
	_style_compact_control(_seed_randomize_check)
	action_row.add_child(_seed_randomize_check)
	_shape_randomize_check = CheckBox.new()
	_shape_randomize_check.name = "Build Shape Randomize"
	_shape_randomize_check.text = "Shape"
	_style_compact_control(_shape_randomize_check)
	action_row.add_child(_shape_randomize_check)
	var action_spacer := Control.new()
	action_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_row.add_child(action_spacer)
	_apply_button = Button.new()
	_apply_button.name = "Build Apply Button"
	_apply_button.text = "Apply"
	_apply_button.disabled = true
	_style_compact_control(_apply_button)
	_apply_button.pressed.connect(_on_apply_pressed)
	action_row.add_child(_apply_button)
	_revert_button = Button.new()
	_revert_button.name = "Build Revert Button"
	_revert_button.text = "Revert"
	_revert_button.disabled = true
	_style_compact_control(_revert_button)
	_revert_button.pressed.connect(_on_revert_pressed)
	action_row.add_child(_revert_button)
	var _remove_button := Button.new()
	_remove_button.name = "Build Remove Button"
	_remove_button.text = "Remove"
	_remove_button.tooltip_text = "Remove selected node or connection"
	_style_compact_control(_remove_button)
	_remove_button.pressed.connect(_on_remove_pressed)
	action_row.add_child(_remove_button)
	_delete_edge_button = Button.new()
	_delete_edge_button.name = "Build Delete Edge Button"
	_delete_edge_button.text = "Delete Edge"
	_delete_edge_button.tooltip_text = "Delete the selected graph connection"
	_delete_edge_button.disabled = true
	_style_compact_control(_delete_edge_button)
	_delete_edge_button.pressed.connect(_on_delete_edge_pressed)
	action_row.add_child(_delete_edge_button)
	add_child(action_row)

	_inspector = HexMapBuildNodeInspectorScript.new()
	_inspector.custom_minimum_size = Vector2(0, 150)
	_inspector.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	add_child(_inspector)

	_status_label = Label.new()
	_status_label.name = "Build Graph Status"
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_status_label)
	_build_run_progress_popup()

	_palette.node_type_requested.connect(_on_palette_node_type_requested)
	_palette.node_template_requested.connect(_on_palette_node_template_requested)
	_canvas.selected_graph_node_changed.connect(_on_canvas_selected_node_changed)
	_canvas.graph_changed.connect(_on_canvas_graph_changed)
	_canvas.graph_run_completed.connect(_on_canvas_graph_run_completed)
	_inspector.node_params_changed.connect(_on_inspector_params_changed)
	_inspector.promote_requested.connect(_on_inspector_promote_requested)
	_refresh_context()


func _style_compact_control(control: Control) -> void:
	if control == null:
		return
	control.add_theme_font_size_override("font_size", 18)


func _build_run_progress_popup() -> void:
	_run_progress_popup = PopupPanel.new()
	_run_progress_popup.name = "Build Run Progress Popup"
	_run_progress_popup.exclusive = true
	_run_progress_popup.visible = false
	add_child(_run_progress_popup)

	var root_box := VBoxContainer.new()
	root_box.name = "Build Run Progress Popup Content"
	root_box.custom_minimum_size = Vector2(460, 128)
	root_box.add_theme_constant_override("separation", 8)
	_run_progress_popup.add_child(root_box)

	_run_progress_status_label = Label.new()
	_run_progress_status_label.name = "Build Run Progress Status"
	_run_progress_status_label.text = "Preparing"
	_run_progress_status_label.add_theme_font_size_override("font_size", 18)
	root_box.add_child(_run_progress_status_label)

	_run_progress_detail_label = Label.new()
	_run_progress_detail_label.name = "Build Run Progress Detail"
	_run_progress_detail_label.text = ""
	_run_progress_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root_box.add_child(_run_progress_detail_label)

	_run_progress_bar = ProgressBar.new()
	_run_progress_bar.name = "Build Run Progress Bar"
	_run_progress_bar.min_value = 0.0
	_run_progress_bar.max_value = 1.0
	_run_progress_bar.step = 0.001
	_run_progress_bar.value = 0.0
	_run_progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_box.add_child(_run_progress_bar)

	var action_row := HBoxContainer.new()
	action_row.name = "Build Run Progress Actions"
	action_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_row.add_child(spacer)
	_cancel_button = Button.new()
	_cancel_button.name = "Build Cancel Button"
	_cancel_button.text = "Cancel"
	_cancel_button.disabled = true
	_style_compact_control(_cancel_button)
	_cancel_button.pressed.connect(_on_cancel_pressed)
	action_row.add_child(_cancel_button)
	root_box.add_child(action_row)


func _run_context() -> Dictionary:
	var result := {}
	if _workspace_asset_context == null:
		return result
	if _workspace_asset_context.level_document != null:
		result["document"] = _workspace_asset_context.level_document
		result["document_terrain"] = _workspace_asset_context.level_document
	var settings := _current_graph_settings()
	result["seed"] = int(settings.get("seed", 0))
	result["orientation"] = int(settings.get("orientation", 0))
	return result


func _build_interrupt_options(options: Dictionary) -> Dictionary:
	var interrupt_options = (options.get("interrupt_options", {}) as Dictionary).duplicate()
	_external_progress_callback = interrupt_options.get("progress_callback", Callable())
	_external_cancel_callback = interrupt_options.get("cancel_callback", Callable())
	if not interrupt_options.has("chunk_size"):
		interrupt_options["chunk_size"] = 16
	interrupt_options["progress_callback"] = Callable(self, "_on_graph_run_progress")
	interrupt_options["cancel_callback"] = Callable(self, "_on_graph_run_cancel_check")
	return interrupt_options


func _update_run_controls() -> void:
	if _generate_button != null:
		_generate_button.text = "Generating" if _run_busy else "Generate"
		_generate_button.disabled = _run_busy
	if _simple_generate_button != null:
		_simple_generate_button.disabled = _run_busy
	if _cancel_button != null:
		_cancel_button.disabled = not _run_busy


func _on_graph_run_progress(status: Dictionary) -> void:
	var snapshot := status.duplicate(true)
	_set_run_progress_snapshot_thread_safe(snapshot)
	if _async_graph_thread != null:
		call_deferred("_apply_graph_run_progress", snapshot)
	else:
		_apply_graph_run_progress(snapshot)
	if _external_progress_callback.is_valid():
		if _async_graph_thread != null:
			call_deferred("_call_external_progress_callback", snapshot)
		else:
			_external_progress_callback.call(snapshot)


func _on_graph_run_cancel_check(status: Dictionary) -> bool:
	if _cancel_requested_thread_safe():
		return true
	if _external_cancel_callback.is_valid():
		return bool(_external_cancel_callback.call(status))
	return false


func _call_external_progress_callback(status: Dictionary) -> void:
	if _external_progress_callback.is_valid():
		_external_progress_callback.call(status)


func _set_run_progress_snapshot_thread_safe(status: Dictionary) -> void:
	_async_graph_mutex.lock()
	_run_progress_snapshot = status.duplicate(true)
	_async_graph_mutex.unlock()


func _run_progress_snapshot_copy() -> Dictionary:
	_async_graph_mutex.lock()
	var result := _run_progress_snapshot.duplicate(true)
	_async_graph_mutex.unlock()
	return result


func _set_cancel_requested_thread_safe(requested: bool) -> void:
	_async_graph_mutex.lock()
	_cancel_requested = requested
	_async_graph_mutex.unlock()


func _cancel_requested_thread_safe() -> bool:
	_async_graph_mutex.lock()
	var requested := _cancel_requested
	_async_graph_mutex.unlock()
	return requested


func _apply_graph_run_progress(status: Dictionary) -> void:
	var display := _display_progress_from_status(status)
	_set_run_progress_popup(
		float(display.get("progress", 0.0)),
		String(display.get("status", "Generating")),
		String(display.get("detail", ""))
	)
	var node_id := String(display.get("node_id", ""))
	if _canvas != null:
		_canvas.set_progress_node(node_id)


func _display_progress_from_status(status: Dictionary) -> Dictionary:
	var phase := String(status.get("phase", ""))
	if phase.begins_with("graph_node_"):
		_run_progress_node_context = status.duplicate(true)
		var node_title := String(status.get("node_title", _node_display_name(String(status.get("node_type", "")), String(status.get("node_id", "")))))
		var node_index := int(status.get("node_index", status.get("steps", 0)))
		var node_total := max(1, int(status.get("node_total", status.get("total_steps", 1))))
		var action := "Generating"
		if phase == "graph_node_complete":
			action = "Completed"
		elif phase == "graph_node_reused":
			action = "Reused"
		return {
			"progress": float(status.get("progress", 0.0)),
			"status": "%s %s" % [action, node_title],
			"detail": "Node %d of %d" % [clampi(node_index, 0, node_total), node_total],
			"node_id": String(status.get("node_id", "")),
		}

	var context := _run_progress_node_context.duplicate(true)
	var node_id := String(context.get("node_id", status.get("node_id", "")))
	var node_title := String(context.get("node_title", _node_display_name(String(context.get("node_type", "")), node_id)))
	var node_step := int(context.get("steps", 0))
	var node_total := max(1, int(context.get("total_steps", context.get("node_total", 1))))
	var core_progress := clampf(float(status.get("progress", 0.0)), 0.0, 1.0)
	var overall := clampf((float(node_step) + core_progress) / float(node_total), 0.0, 1.0)
	var core_phase := _humanize_progress_phase(phase)
	return {
		"progress": overall,
		"status": "Generating %s" % node_title if node_title != "" else "Generating",
		"detail": "%s - Node %d of %d - %d%%" % [
			core_phase,
			clampi(node_step + 1, 1, node_total),
			node_total,
			int(round(core_progress * 100.0)),
		],
		"node_id": node_id,
	}


func _node_display_name(node_type: String, node_id: String) -> String:
	if node_type != "":
		return HexMapBuildGraphCanvasScript.title_for_node_type(node_type)
	return node_id


func _humanize_progress_phase(phase: String) -> String:
	match phase:
		"random_walls":
			return "Random walls"
		"symmetric_toric_start", "symmetric_toric_outer", "symmetric_toric_border", "symmetric_toric_inner":
			return "Markov mesh"
		"random_items":
			return "Random items"
		"limited_items":
			return "Limited items"
		"toric_adjacency_items":
			return "Adjacency items"
		"restore_dense_components", "restore_dense_search", "restore_dense_bridges", "restore_dense_carve":
			return "Connectivity"
		_:
			return phase.capitalize() if phase != "" else "Working"


func _show_run_progress_popup() -> void:
	if _run_progress_popup == null:
		return
	_run_progress_popup_hide_token += 1
	_set_run_progress_popup(0.0, "Preparing", "")
	_run_progress_popup.popup_centered(Vector2i(480, 160))
	if _cancel_button != null:
		_cancel_button.disabled = false


func _set_run_progress_popup(progress: float, status: String, detail: String = "") -> void:
	if _run_progress_bar != null:
		_run_progress_bar.value = clampf(progress, 0.0, 1.0)
	if _run_progress_status_label != null:
		_run_progress_status_label.text = status
	if _run_progress_detail_label != null:
		_run_progress_detail_label.text = detail


func _finish_run_progress_popup(status: String) -> void:
	_run_progress_popup_hide_token += 1
	var hide_token := _run_progress_popup_hide_token
	_set_run_progress_popup(1.0 if status == "Ready" else float(_run_progress_snapshot_copy().get("progress", 0.0)), status, "")
	if _cancel_button != null:
		_cancel_button.disabled = true
	if _canvas != null:
		_canvas.clear_progress_node()
	if is_inside_tree():
		get_tree().create_timer(0.45).timeout.connect(Callable(self, "_hide_run_progress_popup_if_current").bind(hide_token))


func _hide_run_progress_popup_if_current(hide_token: int) -> void:
	if hide_token != _run_progress_popup_hide_token:
		return
	if _run_busy:
		return
	if _run_progress_popup != null:
		_run_progress_popup.hide()


func _refresh_context() -> void:
	if _context_label == null:
		return
	var chips := PackedStringArray()
	for chip in _build_context_chips():
		var chip_data := chip as Dictionary
		chips.append("%s: %s" % [String(chip_data.get("label", "")), String(chip_data.get("value", ""))])
	_context_label.text = "( %s )" % " ) ( ".join(chips)
	_refresh_profile_options()


func _build_context_chips() -> Array[Dictionary]:
	var catalog_ready := _workspace_asset_context != null and _workspace_asset_context.tile_catalog != null
	var graph_ready := _context_hex_tile_map_layer != null and _context_hex_tile_map_layer.generation_graph_resource != null
	return [
		{
			"id": "catalog",
			"label": "Catalog",
			"value": "linked" if catalog_ready else "choose",
			"ready": catalog_ready,
		},
		{
			"id": "target",
			"label": "Target",
			"value": "generated terrain",
			"ready": true,
		},
		{
			"id": "graph",
			"label": "Graph",
			"value": "ready" if graph_ready else "new",
			"ready": graph_ready,
		},
	]


func _refresh_profile_options() -> void:
	if _profile_option == null:
		return
	var current_id := -1
	if _profile_option.item_count > 0:
		current_id = _profile_option.get_selected_id()
	_profile_option.clear()
	var profile = _active_generation_profile()
	_profile_option.add_item(_profile_display_name(profile), 0)
	_profile_option.set_item_metadata(0, profile)
	_profile_option.select(0 if current_id < 0 else 0)


func _active_generation_profile():
	if _workspace_asset_context == null:
		return null
	return _workspace_asset_context.generation_profile


func _selected_profile_label() -> String:
	if _profile_option == null or _profile_option.item_count == 0:
		return ""
	return _profile_option.get_item_text(_profile_option.selected)


func _profile_id(profile) -> String:
	if profile == null:
		return "default_profile"
	var value = profile.get("profile_id") if profile is Resource else ""
	return String(value) if String(value) != "" else "project_generation"


func _profile_display_name(profile) -> String:
	if profile == null:
		return "Default Profile"
	var value = profile.get("display_name") if profile is Resource else ""
	return String(value) if String(value) != "" else _profile_id(profile)


func _build_context_result(ok: bool, reason: String) -> Dictionary:
	return {
		"ok": ok,
		"blocked_reason": reason,
		"created_graph": false,
		"created_document": false,
		"status_text": reason,
	}


func _simple_generate_result(ok: bool, reason: String) -> Dictionary:
	return {
		"ok": ok,
		"blocked_reason": reason,
		"profile_id": "",
		"profile_display_name": "",
		"uses_project_resource": false,
		"graph_node_count": 0,
		"graph_connection_count": 0,
		"preset_graph_visible_in_canvas": false,
		"selected_node_id": "",
		"promote_target_role": HexGenerationPresetScript.default_promote_role(),
		"graph_resource": null,
		"context_layer_has_graph_resource": false,
		"restore_report": {},
		"run_report": {},
		"promote_result": {},
		"status_text": reason,
	}


func _store_current_canvas_graph_on_context_layer(promote_role: String):
	if _context_hex_tile_map_layer == null or _canvas == null:
		return null
	var graph_resource = _context_hex_tile_map_layer.generation_graph_resource
	if graph_resource == null:
		graph_resource = HexGenerationGraphResourceScript.new()
		graph_resource.graph_id = "%s_simple_build_graph" % _resource_prefix_from_node(_context_hex_tile_map_layer.name).to_snake_case()
		graph_resource.resource_name = "%s Simple Build Graph" % _resource_prefix_from_node(_context_hex_tile_map_layer.name)
	graph_resource.ownership_semantics = "embed"
	graph_resource.semantics_reference_path = ""
	graph_resource.set_from_dict(_canvas_graph_model_with_current_settings())
	graph_resource.promote_targets = HexGenerationPresetScript.promote_targets_for_profile(_active_generation_profile())
	if not (graph_resource.semantics_snapshot is Dictionary):
		graph_resource.semantics_snapshot = {}
	graph_resource.semantics_snapshot = {
		"embed": true,
		"promote_target_role": promote_role,
	}
	_context_hex_tile_map_layer.generation_graph_resource = graph_resource
	return graph_resource


func _flush_canvas_graph_to_context_resource(reason: String = "build_screen.graph_edit"):
	if _context_hex_tile_map_layer == null or not is_instance_valid(_context_hex_tile_map_layer) or _canvas == null:
		return null
	var graph_resource = _context_hex_tile_map_layer.generation_graph_resource
	if graph_resource == null:
		graph_resource = HexGenerationGraphResourceScript.new()
		graph_resource.graph_id = "%s_build_graph" % _resource_prefix_from_node(_context_hex_tile_map_layer.name).to_snake_case()
		graph_resource.resource_name = "%s Build Graph" % _resource_prefix_from_node(_context_hex_tile_map_layer.name)
	graph_resource.ownership_semantics = "embed"
	graph_resource.semantics_reference_path = ""
	graph_resource.set_from_dict(_canvas_graph_model_with_current_settings())
	if not (graph_resource.semantics_snapshot is Dictionary):
		graph_resource.semantics_snapshot = {}
	var semantics: Dictionary = graph_resource.semantics_snapshot.duplicate(true)
	semantics["embed"] = true
	semantics["last_edit_reason"] = reason
	graph_resource.semantics_snapshot = semantics
	_context_hex_tile_map_layer.generation_graph_resource = graph_resource
	return graph_resource


func _canvas_graph_model_with_current_settings() -> Dictionary:
	var graph := _canvas.build_graph_model() if _canvas != null else HexGenerationGraphResourceScript.new().to_dict()
	graph["settings"] = _current_graph_settings()
	return graph


func _current_graph_settings() -> Dictionary:
	var settings := {}
	if _context_hex_tile_map_layer != null \
			and is_instance_valid(_context_hex_tile_map_layer) \
			and _context_hex_tile_map_layer.generation_graph_resource != null:
		settings = _context_hex_tile_map_layer.generation_graph_resource.graph_settings.duplicate(true)
	return {
		"seed": int(settings.get("seed", 0)),
		"orientation": int(settings.get("orientation", 0)),
	}


func _graph_load_result(ok: bool, reason: String) -> Dictionary:
	return {
		"ok": ok,
		"blocked_reason": reason,
		"graph_resource": null,
		"graph_id": "",
		"restore_report": {},
		"run_report": {},
		"overwrite_selected": _overwrite_selected_check != null and _overwrite_selected_check.button_pressed,
	}


func _resource_prefix_from_node(node_name: String) -> String:
	var raw := node_name.strip_edges()
	if raw == "":
		return "BuildGraph"
	var result := ""
	for index in raw.length():
		var character := raw[index]
		if character.is_valid_identifier() or character.is_valid_int():
			result += character
	return "BuildGraph" if result == "" else result


func _run_count_value() -> int:
	return max(1, int(_run_count_spin.value if _run_count_spin != null else 1))


func _refresh_selected_node() -> void:
	if _inspector == null or _canvas == null:
		return
	var node := _canvas.selected_node_dictionary()
	if node.is_empty():
		_inspector.clear_inspector()
		return
	var warnings := _compute_connection_warnings(node)
	_inspector.inspect_node(node, _canvas.selected_output_type(), _canvas.selected_preview_snapshot(), warnings)
	if String(node.get("type", "")) == HexGenerationNodeTypesScript.NODE_REGION_FILTER \
			or String(node.get("type", "")) == HexGenerationNodeTypesScript.NODE_TERRAIN_FILTER:
		_inspector.set_effective_flat_top(_find_effective_flat_top(node))
	_inspector.set_promote_enabled(_workspace_asset_context != null and _workspace_asset_context.level_document != null)


func _compute_connection_warnings(node: Dictionary) -> Array[Dictionary]:
	var warnings: Array[Dictionary] = []
	var graph_model := _canvas.build_graph_model()
	var node_id := String(node.get("id", ""))
	if node_id == "":
		return warnings
	var node_type := String(node.get("type", ""))
	var edges: Array = graph_model.get("edges", [])

	var input_defs := HexGenerationNodeTypesScript.input_definitions(node_type)
	for port_name in input_defs.keys():
		var port_def = input_defs[port_name] as Dictionary
		if bool(port_def.get("required", false)):
			var connected := false
			for edge in edges:
				var edge_dict = edge as Dictionary
				if String(edge_dict.get("to_node", "")) == node_id and String(edge_dict.get("to_port", "")) == port_name:
					connected = true
					break
			if not connected:
				warnings.append({"text": "Missing required input: %s" % port_name, "level": "error"})

	var has_outgoing := false
	for edge in edges:
		var edge_dict = edge as Dictionary
		if String(edge_dict.get("from_node", "")) == node_id:
			has_outgoing = true
			break
	if not has_outgoing and node_type != HexGenerationNodeTypesScript.NODE_COMPOSE:
		warnings.append({"text": "Output is unused. Connect to downstream node.", "level": "info"})

	var params := node.get("params", {}) as Dictionary
	var output_type := _canvas.selected_output_type()
	if node_type == HexGenerationNodeTypesScript.NODE_SOURCE:
		var kind := String(params.get("kind", "provided"))
		var source_output := output_type
		if source_output != "":
			for edge in edges:
				var edge_dict = edge as Dictionary
				if String(edge_dict.get("from_node", "")) == node_id:
					var to_node_id := String(edge_dict.get("to_node", ""))
					var to_port := String(edge_dict.get("to_port", ""))
					var to_node = _canvas.selected_node_dictionary()
					var to_nodes: Dictionary = graph_model.get("nodes", {})
					var to_node_entry = to_nodes.get(to_node_id, {}) as Dictionary
					var to_type := String(to_node_entry.get("type", ""))
					if to_type != "":
						var input_def := HexGenerationNodeTypesScript.input_definition(to_type, to_port)
						var accepts: Array = input_def.get("accepts", [])
						if not accepts.is_empty() and not accepts.has(source_output):
							warnings.append({"text": "Output type (%s) mismatches input port '%s' on %s (accepts: %s)" % [source_output, to_port, to_node_id, String(", ".join(accepts))], "level": "warning"})
							break

	return warnings


func _find_effective_flat_top(node: Dictionary) -> bool:
	var settings := _current_graph_settings()
	if settings.has("orientation"):
		return int(settings.get("orientation", 0)) == 0
	var node_id := String(node.get("id", ""))
	if node_id == "":
		return true
	var graph_model := _canvas.build_graph_model()
	var nodes: Dictionary = graph_model.get("nodes", {})
	var edges: Array = graph_model.get("edges", [])
	var visited := {node_id: true}
	var queue: Array[String] = [node_id]
	while not queue.is_empty():
		var current := queue.pop_front()
		for edge in edges:
			var edge_dict = edge as Dictionary
			if String(edge_dict.get("from_node", "")) == current:
				var to_node := String(edge_dict.get("to_node", ""))
				if visited.has(to_node):
					continue
				visited[to_node] = true
				var to_node_entry = nodes.get(to_node, {}) as Dictionary
				if String(to_node_entry.get("type", "")) == HexGenerationNodeTypesScript.NODE_RESULT:
					var to_params = to_node_entry.get("params", {}) as Dictionary
					return int(to_params.get("orientation", 0)) == 0
				queue.append(to_node)
	return true


func _on_generate_pressed() -> void:
	var context_result := _ensure_build_context_for_generate("build_screen.generate")
	if _build_context_provider.is_valid() and not bool(context_result.get("ok", false)):
		if _status_label != null:
			_status_label.text = String(context_result.get("blocked_reason", "Build context is unavailable."))
		return
	_begin_async_graph_run({"count": 1}, true)


func _on_simple_generate_pressed() -> void:
	var context_result := _ensure_build_context_for_generate("build_screen.simple_generate")
	if _build_context_provider.is_valid() and not bool(context_result.get("ok", false)):
		if _status_label != null:
			_status_label.text = String(context_result.get("blocked_reason", "Build context is unavailable."))
		return
	run_simple_profile_graph({"count": 1})


func _on_load_graph_pressed() -> void:
	load_graph_requested.emit(_overwrite_selected_check != null and _overwrite_selected_check.button_pressed)


func _on_cancel_pressed() -> void:
	_set_cancel_requested_thread_safe(true)
	_set_run_progress_popup(float(_run_progress_snapshot_copy().get("progress", 0.0)), "Cancel requested", "")
	if _status_label != null:
		_status_label.text = "Cancel requested."


func _on_palette_node_type_requested(node_type: String) -> void:
	var index := _canvas.canvas_snapshot().get("node_count", 0)
	var node_id := _canvas.add_graph_node(node_type, Vector2(80 + int(index) * 160, 110))
	if node_id != "":
		_canvas.select_graph_node(node_id)
	_refresh_selected_node()


func _on_palette_node_template_requested(node_type: String, params: Dictionary) -> void:
	var index := _canvas.canvas_snapshot().get("node_count", 0)
	var node_id := _canvas.add_graph_node(node_type, Vector2(80 + int(index) * 160, 110), "", params)
	if node_id != "":
		_canvas.select_graph_node(node_id)
		_flush_canvas_graph_to_context_resource("build_screen.node_template_added")
	_refresh_selected_node()


func _on_canvas_selected_node_changed(_node_id: String) -> void:
	_refresh_selected_node()


func _on_canvas_graph_changed() -> void:
	if _status_label != null:
		_status_label.text = String((_canvas.canvas_snapshot() as Dictionary).get("status_text", ""))
	_refresh_edge_action()


func _refresh_edge_action() -> void:
	if _delete_edge_button == null or _canvas == null:
		return
	_delete_edge_button.disabled = _canvas.selected_edge().is_empty()


func _on_delete_edge_pressed() -> void:
	if _canvas == null:
		return
	if _canvas.delete_selected_edge():
		if _status_label != null:
			_status_label.text = "Deleted selected edge."
	_refresh_edge_action()
	_refresh_selected_node()


func _on_canvas_graph_run_completed(_report: Dictionary) -> void:
	_refresh_selected_node()


func _on_inspector_params_changed(node_id: String, params: Dictionary) -> void:
	_canvas.set_node_params(node_id, params)
	_flush_canvas_graph_to_context_resource("build_screen.node_params_changed")


func _on_inspector_promote_requested(node_id: String, role: String) -> void:
	if _canvas != null:
		_canvas.select_graph_node(node_id)
	promote_selected_output(role)
	promote_requested.emit(node_id, role)


func _ensure_build_context_for_generate(reason: String) -> Dictionary:
	if _build_context_provider.is_valid():
		var provided = _build_context_provider.call({"reason": reason, "run": false})
		if provided is Dictionary:
			var result := (provided as Dictionary).duplicate(true)
			_apply_build_context_result(result)
			return result
		return _build_context_result(false, "Build context provider returned no result.")
	build_context_requested.emit()
	_apply_build_context_result(_last_build_context_result)
	return _last_build_context_result.duplicate(true)


func _apply_build_context_result(result: Dictionary) -> void:
	var layer = result.get("selected_layer", null) as HexTileMapLayerScript
	if layer != null and is_instance_valid(layer):
		_context_hex_tile_map_layer = layer
		if _workspace_asset_context == null:
			_workspace_asset_context = HexMapWorkspaceAssetContextScript.new()
		if layer.level_document_resource != null:
			_workspace_asset_context.set_level_document(
				layer.level_document_resource,
				HexMapWorkspaceAssetContextScript.SOURCE_PROJECT,
				"Selected Node"
			)
		if layer.layer_stack_resource != null:
			_workspace_asset_context.set_layer_stack(
				layer.layer_stack_resource,
				HexMapWorkspaceAssetContextScript.SOURCE_PROJECT,
				"Selected Node"
			)
	if bool(result.get("ok", false)):
		_last_build_context_result = result.duplicate(true)
	_refresh_context()


func _auto_preview_after_generate() -> void:
	if _canvas == null or _workspace_asset_context == null or _workspace_asset_context.level_document == null:
		return
	if _context_hex_tile_map_layer == null or not is_instance_valid(_context_hex_tile_map_layer):
		return
	var output = _canvas.selected_output()
	var output_type := _canvas.selected_output_type()
	if output != null and output_type == HexGenerationPortsScript.RESULT:
		_snapshot_document_for_revert()
		if _promote_result_output(output, _canvas.selected_node_id(), _canvas.selected_node_dictionary()):
			_commit_viewport_preview("result")
		return
	_snapshot_document_for_revert()
	if _promote_terminal_result_outputs():
		_commit_viewport_preview("result")
		return
	var target_projection := _promote_graph_resource_targets()
	if bool(target_projection.get("available", false)):
		if bool(target_projection.get("promoted", false)):
			_commit_viewport_preview("promote_targets")
		elif _status_label != null:
			_status_label.text = String(target_projection.get("blocked_reason", "Graph promote target did not produce a preview."))
		return
	if _promote_terminal_outputs():
		_commit_viewport_preview("terminal_outputs")
		return
	if output != null:
		var role := _output_type_to_promote_role(output_type)
		var promote_result := promote_selected_output(role)
		if bool(promote_result.get("ok", false)):
			_preview_applied = _last_viewport_projection_ok()
			_preview_commit_state = "preview_pending" if _preview_applied else "none"
			_refresh_preview_buttons()


func _promote_terminal_result_outputs() -> bool:
	var graph_model := _canvas.build_graph_model()
	var nodes: Dictionary = graph_model.get("nodes", {})
	var edges: Array = graph_model.get("edges", [])
	var cache: Dictionary = _last_report.get("cache", {})
	for node_id in nodes.keys():
		var text_id := String(node_id)
		if not cache.has(text_id):
			continue
		var node_entry = nodes[text_id] as Dictionary
		if String(node_entry.get("type", "")) != HexGenerationNodeTypesScript.NODE_RESULT:
			continue
		var has_outgoing := false
		for edge in edges:
			var edge_dict = edge as Dictionary
			if String(edge_dict.get("from_node", "")) == text_id:
				has_outgoing = true
				break
		if has_outgoing:
			continue
		if _promote_result_output(cache[text_id], text_id, node_entry):
			return true
	return false


func _promote_result_output(output, node_id: String, node_entry: Dictionary) -> bool:
	return bool(_promote_result_report(output, node_id, node_entry).get("ok", false))


func _promote_result_report(output, node_id: String, node_entry: Dictionary) -> Dictionary:
	if output == null:
		_last_promote_result = {
			"ok": false,
			"written_role": "result",
			"blocked_reason": "Result output is empty.",
		}
		return _last_promote_result.duplicate(true)
	var promoted := false
	var total_count := 0
	var terrain_result := {}
	var overlay_results: Array = []
	var overlay_layer_ids: Array = []
	if output.get("primary_map") != null:
		var terrain_res = output.get("primary_map")
		if terrain_res != null and terrain_res.has_method("to_map_data"):
			terrain_result = HexGenerationPromoteScript.promote(
				terrain_res.to_map_data(),
				_workspace_asset_context.level_document,
				"terrain",
				{"graph_node_id": node_id}
			)
			promoted = promoted or bool(terrain_result.get("ok", false))
			total_count += int(terrain_result.get("cell_count", 0))
	var overlay_resources := _result_overlay_resources(output)
	HexGenerationPromoteScript.clear_generated(_workspace_asset_context.level_document, "overlay")
	for overlay_index in range(overlay_resources.size()):
		var overlay_res = overlay_resources[overlay_index]
		if overlay_res != null and overlay_res.has_method("to_overlay_data"):
			var layer_id := "generated_overlay_%d" % overlay_index
			var overlay_result = HexGenerationPromoteScript.promote(
				overlay_res.to_overlay_data(),
				_workspace_asset_context.level_document,
				"overlay",
				{
					"graph_node_id": node_id,
					"layer_id": layer_id,
					"display_name": "Generated Overlay %d" % (overlay_index + 1),
					"preserve_existing_generated": true,
					"overlay_index": overlay_index,
					"result_port": _result_overlay_port_for_resource_index(output, overlay_index),
					"result_overlay_count": overlay_resources.size(),
				}
			)
			overlay_results.append(overlay_result)
			promoted = promoted or bool(overlay_result.get("ok", false))
			total_count += int(overlay_result.get("cell_count", 0))
			if bool(overlay_result.get("ok", false)):
				overlay_layer_ids.append(layer_id)
	var orientation_val := int(_current_graph_settings().get("orientation", 0))
	if _context_hex_tile_map_layer != null and is_instance_valid(_context_hex_tile_map_layer):
		_context_hex_tile_map_layer.flat_top = orientation_val == 0
	_last_promote_result = {
		"ok": promoted,
		"written_role": "result",
		"cell_count": total_count,
		"terrain_result": terrain_result,
		"overlay_result": overlay_results[0] if not overlay_results.is_empty() else {},
		"overlay_results": overlay_results,
		"overlay_layer_ids": overlay_layer_ids,
		"overlay_count": overlay_resources.size(),
		"overlay_inputs": _result_metadata_array(output, "overlay_inputs"),
		"overlay_conflicts": _result_metadata_array(output, "overlay_conflicts"),
		"blocked_reason": "" if promoted else "Result output had no promotable terrain or overlay.",
		"status_text": "result bundle promoted: %d cells" % total_count if promoted else "Result output had no promotable terrain or overlay.",
	}
	return _last_promote_result.duplicate(true)


func _result_overlay_resources(output) -> Array:
	var resources: Array = []
	var overlay_maps = output.get("overlay_maps")
	if overlay_maps is Array:
		for overlay_res in overlay_maps:
			if overlay_res != null:
				resources.append(overlay_res)
	if resources.is_empty() and output.get("overlay_map") != null:
		resources.append(output.get("overlay_map"))
	return resources


func _result_overlay_port_for_resource_index(output, resource_index: int) -> String:
	var present_ports := _result_present_overlay_ports(output)
	if resource_index >= 0 and resource_index < present_ports.size():
		return String(present_ports[resource_index])
	return "%s%d" % [HexGenerationNodeTypesScript.RESULT_OVERLAY_PORT_PREFIX, resource_index]


func _result_present_overlay_ports(output) -> Array:
	var result: Array = []
	for entry in _result_metadata_array(output, "overlay_inputs"):
		var row = entry as Dictionary
		if bool(row.get("present", false)):
			result.append(String(row.get("port", "")))
	return result


func _result_metadata_array(output, key: String) -> Array:
	if output == null:
		return []
	var metadata = output.get("metadata")
	if not metadata is Dictionary:
		return []
	var value = (metadata as Dictionary).get(key, [])
	return value.duplicate(true) if value is Array else []


func _commit_viewport_preview(source: String) -> void:
	_last_viewport_apply_report = _apply_document_to_context_layer()
	_last_viewport_apply_report["result_overlay_count"] = int(_last_promote_result.get("overlay_count", 0))
	_last_viewport_apply_report["result_overlay_layer_ids"] = (_last_promote_result.get("overlay_layer_ids", []) as Array).duplicate(true)
	var overlay_conflicts = _last_promote_result.get("overlay_conflicts", [])
	_last_viewport_apply_report["result_overlay_conflict_count"] = overlay_conflicts.size() if overlay_conflicts is Array else 0
	_preview_applied = _viewport_projection_ok(_last_viewport_apply_report)
	_preview_commit_state = "preview_pending" if _preview_applied else "none"
	if _status_label != null:
		if _preview_applied:
			_status_label.text = "Generated preview shown in viewport (%s)." % source
		else:
			_status_label.text = String(_last_viewport_apply_report.get("blocked_reason", "Generated data could not be shown in viewport."))
	_refresh_preview_buttons()


func _promote_graph_resource_targets() -> Dictionary:
	if _context_hex_tile_map_layer == null or not is_instance_valid(_context_hex_tile_map_layer):
		return {"available": false, "promoted": false}
	var graph_resource = _context_hex_tile_map_layer.generation_graph_resource
	if graph_resource == null or graph_resource.promote_targets.is_empty():
		return {"available": false, "promoted": false}
	var cache: Dictionary = _last_report.get("cache", {})
	var promoted := false
	var blocked_reason := ""
	for raw_target in graph_resource.promote_targets:
		var target = raw_target as Dictionary
		var node_id := String(target.get("node_id", ""))
		var role := String(target.get("role", ""))
		if node_id == "" or role == "" or not cache.has(node_id):
			continue
		var result := {}
		var target_node := _canvas.node_dictionary(node_id)
		if role == HexGenerationPortsScript.RESULT or String(HexGenerationNodeTypesScript.output_type_for_node(target_node)) == HexGenerationPortsScript.RESULT:
			result = _promote_result_report(cache[node_id], node_id, target_node)
		else:
			result = HexGenerationPromoteScript.promote(
				cache[node_id],
				_workspace_asset_context.level_document,
				role,
				{"graph_node_id": node_id}
			)
		if bool(result.get("ok", false)):
			promoted = true
		elif blocked_reason == "":
			blocked_reason = String(result.get("blocked_reason", "Promote target failed."))
	return {
		"available": true,
		"promoted": promoted,
		"blocked_reason": blocked_reason,
	}


func _promote_terminal_outputs() -> bool:
	var graph_model := _canvas.build_graph_model()
	var nodes: Dictionary = graph_model.get("nodes", {})
	var edges: Array = graph_model.get("edges", [])
	var cache: Dictionary = _last_report.get("cache", {})
	var promoted_terrain := false
	var promoted_overlay := false
	for node_id in nodes.keys():
		if not cache.has(String(node_id)):
			continue
		var node_entry = nodes[String(node_id)] as Dictionary
		var output = cache[String(node_id)]
		if output == null:
			continue
		var has_outgoing := false
		for edge in edges:
			var edge_dict = edge as Dictionary
			if String(edge_dict.get("from_node", "")) == String(node_id):
				has_outgoing = true
				break
		if not has_outgoing:
			var terminal_type := HexGenerationNodeTypesScript.output_type_for_node(node_entry)
			if terminal_type == HexGenerationPortsScript.TERRAIN and not promoted_terrain:
				HexGenerationPromoteScript.promote(
					output,
					_workspace_asset_context.level_document,
					"terrain",
					{"graph_node_id": String(node_id)}
				)
				promoted_terrain = true
			elif terminal_type == HexGenerationPortsScript.OVERLAY and not promoted_overlay:
				HexGenerationPromoteScript.promote(
					output,
					_workspace_asset_context.level_document,
					"overlay",
					{"graph_node_id": String(node_id)}
				)
				promoted_overlay = true
	if not promoted_terrain and not promoted_overlay:
		var sel_output = _canvas.selected_output()
		if sel_output != null:
			var role := _output_type_to_promote_role(_canvas.selected_output_type())
			var result := promote_selected_output(role)
			return bool(result.get("ok", false))
	return promoted_terrain or promoted_overlay


func _snapshot_document_for_revert() -> void:
	if _workspace_asset_context == null or _workspace_asset_context.level_document == null:
		return
	var doc = _workspace_asset_context.level_document
	_revert_terrain_layers = doc.terrain_layers.duplicate(true)
	_revert_overlay_layers = doc.overlay_layers.duplicate(true)
	_revert_object_placements = doc.object_placements.duplicate(true)


func _apply_document_to_context_layer() -> Dictionary:
	if _context_hex_tile_map_layer == null or not is_instance_valid(_context_hex_tile_map_layer):
		_last_viewport_apply_report = {"ok": false, "blocked_reason": "No Build viewport layer."}
		return _last_viewport_apply_report.duplicate(true)
	if _workspace_asset_context == null or _workspace_asset_context.level_document == null:
		_last_viewport_apply_report = {"ok": false, "blocked_reason": "No Build Level Document."}
		return _last_viewport_apply_report.duplicate(true)
	if _context_hex_tile_map_layer.level_document_resource != _workspace_asset_context.level_document:
		_context_hex_tile_map_layer.level_document_resource = _workspace_asset_context.level_document
	var tiles_ok := _context_hex_tile_map_layer.ensure_display_tiles()
	var viewport_document = _viewport_document_snapshot(_workspace_asset_context.level_document)
	var apply_state := HexMapDocumentApplierScript.prepare_document_apply(viewport_document)
	if bool(apply_state.get("ok", false)):
		var resource = apply_state.get("map_resource", null)
		if resource != null:
			_last_viewport_apply_report = _context_hex_tile_map_layer.apply_map(resource)
			_last_viewport_apply_report["ok"] = not bool(_last_viewport_apply_report.get("cancelled", false))
			_finalize_viewport_apply_report(tiles_ok)
			return _last_viewport_apply_report.duplicate(true)
	_last_viewport_apply_report = {
		"ok": false,
		"blocked_reason": String(apply_state.get("blocked_reason", "Cannot prepare generated document preview.")),
		"display_tiles_ready": tiles_ok,
	}
	_finalize_viewport_apply_report(tiles_ok)
	return _last_viewport_apply_report.duplicate(true)


func _finalize_viewport_apply_report(tiles_ok: bool) -> void:
	if _context_hex_tile_map_layer == null or not is_instance_valid(_context_hex_tile_map_layer):
		return
	var display_status := _context_hex_tile_map_layer.display_layer_status()
	var display_layer := _context_hex_tile_map_layer.display_tile_map_layer()
	_last_viewport_apply_report["display_tiles_ready"] = tiles_ok
	_last_viewport_apply_report["display_used_cell_count"] = _context_hex_tile_map_layer.display_used_cell_count()
	_last_viewport_apply_report["layer_inside_tree"] = _context_hex_tile_map_layer.is_inside_tree()
	_last_viewport_apply_report["layer_path"] = _context_layer_path()
	_last_viewport_apply_report["display_tile_map_path"] = str(display_layer.get_path()) if display_layer != null and display_layer.is_inside_tree() else ""
	_last_viewport_apply_report["display_status"] = display_status
	_last_viewport_apply_report["display_tile_source_count"] = int(display_status.get("tile_set_source_count", 0))
	_last_viewport_apply_report["projection_ok"] = _viewport_projection_ok(_last_viewport_apply_report)
	_last_viewport_apply_report["projection_status"] = "visible" if bool(_last_viewport_apply_report["projection_ok"]) else "failed"
	if not bool(_last_viewport_apply_report["projection_ok"]) and String(_last_viewport_apply_report.get("blocked_reason", "")) == "":
		_last_viewport_apply_report["blocked_reason"] = _viewport_projection_blocked_reason(_last_viewport_apply_report)


func _viewport_projection_ok(report: Dictionary) -> bool:
	return bool(report.get("ok", false)) \
		and bool(report.get("display_tiles_ready", false)) \
		and bool(report.get("layer_inside_tree", false)) \
		and int(report.get("display_tile_source_count", 0)) > 0 \
		and int(report.get("display_used_cell_count", 0)) > 0


func _last_viewport_projection_ok() -> bool:
	return _viewport_projection_ok(_last_viewport_apply_report)


func _viewport_projection_blocked_reason(report: Dictionary) -> String:
	if not bool(report.get("ok", false)):
		return String(report.get("blocked_reason", "Layer apply failed."))
	if not bool(report.get("layer_inside_tree", false)):
		return "Build viewport layer is not inside the scene tree."
	if not bool(report.get("display_tiles_ready", false)):
		return "Build viewport display tiles are not ready."
	if int(report.get("display_tile_source_count", 0)) <= 0:
		return "Build viewport display tile set has no sources."
	if int(report.get("display_used_cell_count", 0)) <= 0:
		return "Build viewport display has no used cells."
	return "Generated data could not be shown in viewport."


func _viewport_document_snapshot(document):
	var copy = HexMapDocumentAdapterScript.duplicate_document(document)
	if copy == null:
		return document
	var ordered := _viewport_ordered_terrain_layers(copy.terrain_layers)
	copy.terrain_layers.clear()
	for layer in ordered:
		copy.terrain_layers.append(layer)
	return copy


func _viewport_ordered_terrain_layers(layers: Array) -> Array:
	if layers.size() <= 1:
		return layers.duplicate(false)
	var generated_nonempty: Array = []
	var other_nonempty: Array = []
	var empty_layers: Array = []
	for layer in layers:
		var cell_count := _terrain_layer_cell_count(layer)
		if cell_count <= 0:
			empty_layers.append(layer)
		elif _terrain_layer_is_generated(layer):
			generated_nonempty.append(layer)
		else:
			other_nonempty.append(layer)
	var ordered: Array = []
	ordered.append_array(generated_nonempty)
	ordered.append_array(other_nonempty)
	ordered.append_array(empty_layers)
	return ordered


func _terrain_layer_cell_count(layer) -> int:
	if layer == null:
		return 0
	var map = layer.get("map")
	if map == null or not map.has_method("to_map_data"):
		return 0
	var data = map.to_map_data()
	return data.cells.size() if data != null else 0


func _terrain_layer_is_generated(layer) -> bool:
	if layer == null:
		return false
	var metadata = layer.get("metadata")
	if not metadata is Dictionary:
		return false
	return String((metadata as Dictionary).get("writable_source", "")) == "generated"


func _on_apply_pressed() -> void:
	if not _last_viewport_projection_ok():
		_preview_applied = false
		_preview_commit_state = "none"
		_refresh_preview_buttons()
		if _status_label != null:
			_status_label.text = String(_last_viewport_apply_report.get("blocked_reason", "Cannot apply because viewport projection failed."))
		return
	_preview_applied = false
	_preview_commit_state = "applied"
	_revert_terrain_layers.clear()
	_revert_overlay_layers.clear()
	_revert_object_placements.clear()
	_refresh_preview_buttons()
	if _status_label != null:
		_status_label.text = "Preview applied to Layer."


func _on_revert_pressed() -> void:
	if _workspace_asset_context == null or _workspace_asset_context.level_document == null:
		return
	if _revert_terrain_layers.is_empty() and _revert_overlay_layers.is_empty() and _revert_object_placements.is_empty():
		return
	var doc = _workspace_asset_context.level_document
	_replace_resource_array(doc.terrain_layers, _revert_terrain_layers)
	_replace_resource_array(doc.overlay_layers, _revert_overlay_layers)
	_replace_resource_array(doc.object_placements, _revert_object_placements)
	_apply_document_to_context_layer()
	_preview_applied = false
	_preview_commit_state = "reverted"
	_revert_terrain_layers.clear()
	_revert_overlay_layers.clear()
	_revert_object_placements.clear()
	_refresh_preview_buttons()
	if _status_label != null:
		_status_label.text = "Reverted to previous state."


func _replace_resource_array(target: Array, source: Array) -> void:
	target.clear()
	for entry in source:
		target.append(entry)


func _refresh_preview_buttons() -> void:
	var can_commit := _preview_applied and _last_viewport_projection_ok()
	if _apply_button != null:
		_apply_button.disabled = not can_commit
	if _revert_button != null:
		_revert_button.disabled = not can_commit


func _viewport_preview_cell_count() -> int:
	if _context_hex_tile_map_layer == null or not is_instance_valid(_context_hex_tile_map_layer):
		return 0
	return _context_hex_tile_map_layer.display_used_cell_count()


func _viewport_preview_visible() -> bool:
	return (_preview_commit_state == "preview_pending" or _preview_commit_state == "applied") \
		and _last_viewport_projection_ok()


func _context_layer_path() -> String:
	if _context_hex_tile_map_layer == null or not is_instance_valid(_context_hex_tile_map_layer):
		return ""
	if _context_hex_tile_map_layer.is_inside_tree():
		return str(_context_hex_tile_map_layer.get_path())
	return _context_hex_tile_map_layer.name


func _output_type_to_promote_role(output_type: String) -> String:
	match output_type:
		"overlay":
			return "overlay"
		_:
			return "terrain"


func _on_remove_pressed() -> void:
	if _canvas != null:
		_canvas.remove_selected()
		if _status_label != null:
			_status_label.text = "Removed selected."
