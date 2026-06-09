@tool
class_name HexMapGenerationRunState
extends RefCounted

const STATE_IDLE := "idle"
const STATE_PARAMS_DIRTY := "params_dirty"
const STATE_PREVIEW_QUEUED := "preview_queued"
const STATE_PREPARING := "preparing"
const STATE_GENERATING := "generating"
const STATE_CANCELLING := "cancelling"
const STATE_VALIDATING := "validating"
const STATE_APPLYING_TO_DOCUMENT := "applying_to_document"
const STATE_APPLYING_TILE_SETTINGS := "applying_tile_settings"
const STATE_APPLIED_DIRTY_DOCUMENT := "applied_dirty_document"
const STATE_APPLIED_TILE_SETTINGS := "applied_tile_settings"
const STATE_GENERATED_PREVIEW := "generated_preview"
const STATE_CANCELLED := "cancelled"
const STATE_FAILED := "failed"
const STATE_BLOCKED := "blocked"

const STEP_IDLE := "idle"
const STEP_PREPARING := "preparing"
const STEP_GENERATING := "generating"
const STEP_VALIDATING := "validating"
const STEP_APPLYING := "applying"
const STEP_TILE_SETTINGS := "tile_settings"
const STEP_COMPLETE := "complete"
const STEP_CANCELLED := "cancelled"
const STEP_BLOCKED := "blocked"

var state_id := STATE_IDLE
var running := false
var cancel_requested := false
var progress := 0.0
var status := "Ready"
var step := STEP_IDLE
var visible := false
var progress_bar_visible := false
var cancel_available := false
var modal_window_count := 0
var tile_settings_pending := false
var tile_settings_token := 0
var tile_settings_apply_count := 0
var tile_settings_last_apply_result := false
var generated_preview_present := false
var output_target_mode := ""
var dirty_document := false
var block_reason := ""
var failure_reason := ""
var orientation := 0
var tile_size := Vector2i.ZERO
var heavy_update_reason := ""


func update_from_context(context: Dictionary) -> void:
	running = bool(context.get("running", running))
	cancel_requested = bool(context.get("cancel_requested", cancel_requested))
	progress = clampf(float(context.get("progress", progress)), 0.0, 1.0)
	status = String(context.get("status", status))
	step = String(context.get("step", step))
	visible = bool(context.get("visible", visible))
	progress_bar_visible = bool(context.get("progress_bar_visible", progress_bar_visible))
	cancel_available = bool(context.get("cancel_available", cancel_available))
	modal_window_count = int(context.get("modal_window_count", modal_window_count))
	tile_settings_pending = bool(context.get("tile_settings_pending", tile_settings_pending))
	tile_settings_token = int(context.get("tile_settings_token", tile_settings_token))
	tile_settings_apply_count = int(context.get("tile_settings_apply_count", tile_settings_apply_count))
	tile_settings_last_apply_result = bool(context.get(
		"tile_settings_last_apply_result",
		tile_settings_last_apply_result
	))
	generated_preview_present = bool(context.get("generated_preview_present", generated_preview_present))
	output_target_mode = String(context.get("output_target_mode", output_target_mode))
	dirty_document = bool(context.get("dirty_document", dirty_document))
	block_reason = String(context.get("block_reason", block_reason))
	failure_reason = String(context.get("failure_reason", failure_reason))
	orientation = int(context.get("orientation", orientation))
	tile_size = context.get("tile_size", tile_size)
	if context.has("heavy_update_reason"):
		heavy_update_reason = String(context.get("heavy_update_reason", ""))
	elif not tile_settings_pending and status == "Ready":
		heavy_update_reason = ""
	state_id = _derive_state()


func to_status_snapshot() -> Dictionary:
	return {
		"state_id": state_id,
		"state_source": "HexMapGenerationRunState",
		"running": running,
		"cancel_requested": cancel_requested,
		"progress": progress,
		"status": status,
		"step": step,
		"visible": visible,
		"cancel_available": cancel_available,
		"block_reason": block_reason,
		"failure_reason": failure_reason,
	}


func to_progress_snapshot(current_step_text: String = "") -> Dictionary:
	return {
		"state_id": state_id,
		"state_source": "HexMapGenerationRunState",
		"running": running,
		"cancel_requested": cancel_requested,
		"progress": progress,
		"status": status,
		"step": step,
		"current_step_text": current_step_text if current_step_text != "" else status,
		"visible": visible,
		"progress_bar_visible": progress_bar_visible,
		"cancel_available": cancel_available,
		"modal_window_count": modal_window_count,
		"block_reason": block_reason,
		"failure_reason": failure_reason,
	}


func to_view_state(current_step_text: String = "") -> Dictionary:
	var generate_disabled := running or block_reason != ""
	return {
		"state_id": state_id,
		"state_source": "HexMapGenerationRunState",
		"running": running,
		"controls_disabled": running,
		"generate_button_disabled": generate_disabled,
		"generate_button_tooltip": block_reason if block_reason != "" and not running else "",
		"cancel_requested": cancel_requested,
		"cancel_button_disabled": not cancel_available,
		"status_text": current_step_text if current_step_text != "" else status,
		"progress": progress,
		"progress_visible": visible,
		"progress_bar_visible": progress_bar_visible,
		"tile_settings_pending": tile_settings_pending,
		"dirty_document": dirty_document,
		"generated_preview_present": generated_preview_present,
		"output_target_mode": output_target_mode,
		"block_reason": block_reason,
		"failure_reason": failure_reason,
		"heavy_update_reason": heavy_update_reason,
		"orientation": orientation,
		"tile_size": tile_size,
	}


func tile_settings_snapshot(current_step_text: String = "") -> Dictionary:
	return {
		"state_id": state_id,
		"state_source": "HexMapGenerationRunState",
		"pending": tile_settings_pending,
		"token": tile_settings_token,
		"apply_count": tile_settings_apply_count,
		"last_apply_result": tile_settings_last_apply_result,
		"heavy_update_reason": heavy_update_reason,
		"orientation": orientation,
		"tile_size": tile_size,
		"progress": to_progress_snapshot(current_step_text),
	}


func _derive_state() -> String:
	if block_reason != "":
		return STATE_BLOCKED
	if failure_reason != "" or status == "Failed":
		return STATE_FAILED
	if running and cancel_requested:
		return STATE_CANCELLING
	if running:
		if step == STEP_GENERATING:
			return STATE_GENERATING
		if step == STEP_VALIDATING:
			return STATE_VALIDATING
		if step == STEP_APPLYING:
			return STATE_APPLYING_TO_DOCUMENT
		return STATE_PREPARING
	if tile_settings_pending:
		return STATE_PREVIEW_QUEUED
	if status == "Applying tile settings":
		return STATE_APPLYING_TILE_SETTINGS
	if status == "Tile settings applied":
		return STATE_APPLIED_TILE_SETTINGS
	if status == "Cancelled":
		return STATE_CANCELLED
	if dirty_document:
		return STATE_APPLIED_DIRTY_DOCUMENT
	if generated_preview_present:
		return STATE_GENERATED_PREVIEW
	return STATE_IDLE
