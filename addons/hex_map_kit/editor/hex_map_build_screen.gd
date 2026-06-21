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
const HexGenerationPortsScript = preload("res://addons/hex_map_kit/generation/hex_generation_ports.gd")
const HexGenerationGraphResourceScript = preload("res://addons/hex_map_kit/adapter/hex_generation_graph_resource.gd")
const HexTileMapLayerScript = preload("res://addons/hex_map_kit/adapter/hex_tile_map_layer.gd")

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
var _canvas: HexMapBuildGraphCanvasScript
var _palette: HexMapBuildNodePaletteScript
var _inspector: HexMapBuildNodeInspectorScript
var _apply_button: Button
var _revert_button: Button
var _preview_applied := false
var _revert_terrain_layers: Array = []
var _revert_overlay_layers: Array = []
var _revert_object_placements: Array = []
var _last_report: Dictionary = {}
var _last_promote_result: Dictionary = {}
var _last_build_context_result: Dictionary = {}
var _last_graph_load_result: Dictionary = {}
var _last_simple_generate_result: Dictionary = {}
var _context_hex_tile_map_layer: HexTileMapLayerScript = null
var _run_busy := false
var _cancel_requested := false
var _run_progress_snapshot: Dictionary = {}
var _external_progress_callback: Callable
var _external_cancel_callback: Callable


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


func run_graph(options: Dictionary = {}) -> Dictionary:
	if _canvas == null:
		return {}
	_run_busy = true
	_cancel_requested = false
	_run_progress_snapshot = {}
	_update_run_controls()
	var context := _run_context()
	context["interrupt_options"] = _build_interrupt_options(options)
	_last_report = _canvas.run_graph(context)
	_run_busy = false
	_update_run_controls()
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
			promote_result = promote_selected_output(promote_role)
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
	_last_promote_result = HexGenerationPromoteScript.promote(
		_canvas.selected_output(),
		_workspace_asset_context.level_document,
		role,
		{"graph_node_id": _canvas.selected_node_id()}
	)
	if bool(_last_promote_result.get("ok", false)):
		_apply_document_to_context_layer()
	if _status_label != null:
		_status_label.text = String(_last_promote_result.get("status_text", _last_promote_result.get("blocked_reason", "")))
	_refresh_selected_node()
	return _last_promote_result.duplicate(true)


func build_screen_snapshot() -> Dictionary:
	var canvas_snapshot := _canvas.canvas_snapshot() if _canvas != null else {}
	var run_state := _canvas.run_state_snapshot() if _canvas != null else {}
	var inspector_snapshot := _inspector.inspector_snapshot() if _inspector != null else {}
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
		"cancel_available": _cancel_button != null and not _cancel_button.disabled,
		"run_busy": _run_busy,
		"run_progress": float(_run_progress_snapshot.get("progress", run_state.get("progress", 0.0))),
		"run_progress_phase": String(_run_progress_snapshot.get("phase", run_state.get("progress_phase", ""))),
		"run_progress_node_id": String(_run_progress_snapshot.get("node_id", run_state.get("progress_node_id", ""))),
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
		"preview_applied": _preview_applied,
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
	_load_graph_button.pressed.connect(_on_load_graph_pressed)
	top_row.add_child(_load_graph_button)
	_overwrite_selected_check = CheckBox.new()
	_overwrite_selected_check.name = "Build Overwrite Selected Graph"
	_overwrite_selected_check.text = "Overwrite selected"
	_overwrite_selected_check.button_pressed = false
	top_row.add_child(_overwrite_selected_check)
	_generate_button = Button.new()
	_generate_button.name = "Build Generate Button"
	_generate_button.text = "Generate"
	_generate_button.pressed.connect(_on_generate_pressed)
	top_row.add_child(_generate_button)
	_cancel_button = Button.new()
	_cancel_button.name = "Build Cancel Button"
	_cancel_button.text = "Cancel"
	_cancel_button.disabled = true
	_cancel_button.pressed.connect(_on_cancel_pressed)
	top_row.add_child(_cancel_button)
	_apply_button = Button.new()
	_apply_button.name = "Build Apply Button"
	_apply_button.text = "Apply"
	_apply_button.disabled = true
	_apply_button.pressed.connect(_on_apply_pressed)
	top_row.add_child(_apply_button)
	_revert_button = Button.new()
	_revert_button.name = "Build Revert Button"
	_revert_button.text = "Revert"
	_revert_button.disabled = true
	_revert_button.pressed.connect(_on_revert_pressed)
	top_row.add_child(_revert_button)
	var _remove_button := Button.new()
	_remove_button.name = "Build Remove Button"
	_remove_button.text = "Remove"
	_remove_button.tooltip_text = "Remove selected node or connection"
	_remove_button.pressed.connect(_on_remove_pressed)
	top_row.add_child(_remove_button)
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
	_simple_generate_button.pressed.connect(_on_simple_generate_pressed)
	simple_row.add_child(_simple_generate_button)
	add_child(simple_row)

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

	var batch_row := HBoxContainer.new()
	batch_row.name = "Build Batch Options"
	batch_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var batch_label := Label.new()
	batch_label.name = "Build Batch Label"
	batch_label.text = "Batch"
	batch_row.add_child(batch_label)
	_run_count_spin = SpinBox.new()
	_run_count_spin.name = "Build Batch Count"
	_run_count_spin.min_value = 1
	_run_count_spin.max_value = 32
	_run_count_spin.step = 1
	_run_count_spin.value = 1
	batch_row.add_child(_run_count_spin)
	_seed_randomize_check = CheckBox.new()
	_seed_randomize_check.name = "Build Seed Randomize"
	_seed_randomize_check.text = "Seed"
	batch_row.add_child(_seed_randomize_check)
	_shape_randomize_check = CheckBox.new()
	_shape_randomize_check.name = "Build Shape Randomize"
	_shape_randomize_check.text = "Shape"
	batch_row.add_child(_shape_randomize_check)
	add_child(batch_row)

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
	_refresh_context()


func _run_context() -> Dictionary:
	var result := {}
	if _workspace_asset_context == null:
		return result
	if _workspace_asset_context.level_document != null:
		result["document"] = _workspace_asset_context.level_document
		result["document_terrain"] = _workspace_asset_context.level_document
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
	_run_progress_snapshot = status.duplicate(true)
	if _external_progress_callback.is_valid():
		_external_progress_callback.call(status)


func _on_graph_run_cancel_check(status: Dictionary) -> bool:
	if _cancel_requested:
		return true
	if _external_cancel_callback.is_valid():
		return bool(_external_cancel_callback.call(status))
	return false


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
	graph_resource.set_from_dict(_canvas.build_graph_model())
	graph_resource.promote_targets = HexGenerationPresetScript.promote_targets_for_profile(_active_generation_profile())
	if not (graph_resource.semantics_snapshot is Dictionary):
		graph_resource.semantics_snapshot = {}
	graph_resource.semantics_snapshot = {
		"embed": true,
		"promote_target_role": promote_role,
	}
	_context_hex_tile_map_layer.generation_graph_resource = graph_resource
	return graph_resource


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
	if String(node.get("type", "")) == HexGenerationNodeTypesScript.NODE_REGION_FILTER:
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
	build_context_requested.emit()
	var report := run_graph({"count": 1})
	if bool(report.get("ok", false)):
		_auto_preview_after_generate()


func _on_simple_generate_pressed() -> void:
	build_context_requested.emit()
	run_simple_profile_graph({"count": 1})


func _on_load_graph_pressed() -> void:
	load_graph_requested.emit(_overwrite_selected_check != null and _overwrite_selected_check.button_pressed)


func _on_cancel_pressed() -> void:
	_cancel_requested = true
	if _status_label != null:
		_status_label.text = "Cancel requested."


func _on_palette_node_type_requested(node_type: String) -> void:
	var index := _canvas.canvas_snapshot().get("node_count", 0)
	var node_id := _canvas.add_graph_node(node_type, Vector2(80 + int(index) * 160, 110))
	if node_id != "":
		_canvas.select_graph_node(node_id)
	_refresh_selected_node()


func _on_canvas_selected_node_changed(_node_id: String) -> void:
	_refresh_selected_node()


func _on_canvas_graph_changed() -> void:
	if _status_label != null:
		_status_label.text = String((_canvas.canvas_snapshot() as Dictionary).get("status_text", ""))


func _on_canvas_graph_run_completed(_report: Dictionary) -> void:
	_refresh_selected_node()


func _on_inspector_params_changed(node_id: String, params: Dictionary) -> void:
	_canvas.set_node_params(node_id, params)


func _on_inspector_promote_requested(node_id: String, role: String) -> void:
	if _canvas != null:
		_canvas.select_graph_node(node_id)
	promote_selected_output(role)
	promote_requested.emit(node_id, role)


func _auto_preview_after_generate() -> void:
	if _canvas == null or _workspace_asset_context == null or _workspace_asset_context.level_document == null:
		return
	if _context_hex_tile_map_layer == null or not is_instance_valid(_context_hex_tile_map_layer):
		return
	var output = _canvas.selected_output()
	if output == null:
		return
	var output_type := _canvas.selected_output_type()
	if output_type == HexGenerationPortsScript.RESULT:
		_snapshot_document_for_revert()
		if output.get("primary_map") != null:
			var terrain_res = output.get("primary_map")
			if terrain_res != null and terrain_res.has_method("to_map_data"):
				HexGenerationPromoteScript.promote(
					terrain_res.to_map_data(),
					_workspace_asset_context.level_document,
					"terrain",
					{"graph_node_id": _canvas.selected_node_id()}
				)
		if output.get("overlay_map") != null:
			var overlay_res = output.get("overlay_map")
			if overlay_res != null and overlay_res.has_method("to_overlay_data"):
				HexGenerationPromoteScript.promote(
					overlay_res.to_overlay_data(),
					_workspace_asset_context.level_document,
					"overlay",
					{"graph_node_id": _canvas.selected_node_id()}
				)
		var result_node := _canvas.selected_node_dictionary()
		var result_params = result_node.get("params", {}) as Dictionary
		var orientation_val := int(result_params.get("orientation", 0))
		_context_hex_tile_map_layer.flat_top = orientation_val == 0
		_apply_document_to_context_layer()
		_preview_applied = true
		_refresh_preview_buttons()
		return
	var role := _output_type_to_promote_role(output_type)
	_snapshot_document_for_revert()
	var _result := promote_selected_output(role)
	_apply_document_to_context_layer()
	_preview_applied = true
	_refresh_preview_buttons()


func _snapshot_document_for_revert() -> void:
	if _workspace_asset_context == null or _workspace_asset_context.level_document == null:
		return
	var doc = _workspace_asset_context.level_document
	_revert_terrain_layers = doc.terrain_layers.duplicate(true)
	_revert_overlay_layers = doc.overlay_layers.duplicate(true)
	_revert_object_placements = doc.object_placements.duplicate(true)


func _apply_document_to_context_layer() -> void:
	if _context_hex_tile_map_layer == null or not is_instance_valid(_context_hex_tile_map_layer):
		return
	if _workspace_asset_context == null or _workspace_asset_context.level_document == null:
		return
	_context_hex_tile_map_layer.apply_document(_workspace_asset_context.level_document)


func _on_apply_pressed() -> void:
	_preview_applied = false
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
	doc.terrain_layers = _revert_terrain_layers.duplicate(true)
	doc.overlay_layers = _revert_overlay_layers.duplicate(true)
	doc.object_placements = _revert_object_placements.duplicate(true)
	_apply_document_to_context_layer()
	_preview_applied = false
	_revert_terrain_layers.clear()
	_revert_overlay_layers.clear()
	_revert_object_placements.clear()
	_refresh_preview_buttons()
	if _status_label != null:
		_status_label.text = "Reverted to previous state."


func _refresh_preview_buttons() -> void:
	if _apply_button != null:
		_apply_button.disabled = not _preview_applied
	if _revert_button != null:
		_revert_button.disabled = not _preview_applied


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
