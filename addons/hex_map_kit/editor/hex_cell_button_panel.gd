@tool
class_name HexCellButtonPanel
extends Control

signal cell_pressed(entry: Dictionary)
signal cell_hovered(entry: Dictionary)
signal cell_focus_changed(entry: Dictionary)

const HexCellButtonLayout = preload("res://addons/hex_map_kit/editor/hex_cell_button_layout.gd")

@export var flat_top: bool = true
@export var cell_radius: float = 14.0
@export var cell_gap: float = 2.0
@export var padding: Vector2 = Vector2(4, 4)
@export var shape_kind: String = HexCellButtonLayout.SHAPE_DIRECTIONS
@export var show_labels: bool = false
@export var enabled: bool = true

var _cells: Array = []
var _pressable_cells: Dictionary = {}
var _disabled_cells: Dictionary = {}
var _label_by_cell: Dictionary = {}
var _tooltip_by_cell: Dictionary = {}
var _metadata_by_cell: Dictionary = {}
var _center_cell = null
var _entries: Array[Dictionary] = []
var _hovered_id := ""
var _pressed_id := ""
var _focused_id := ""


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	if _entries.is_empty():
		_rebuild()


func configure(spec: Dictionary) -> void:
	flat_top = bool(spec.get("flat_top", flat_top))
	cell_radius = float(spec.get("cell_radius", cell_radius))
	cell_gap = float(spec.get("cell_gap", cell_gap))
	padding = spec.get("padding", padding)
	shape_kind = String(spec.get("shape_kind", shape_kind))
	show_labels = bool(spec.get("show_labels", show_labels))
	enabled = bool(spec.get("enabled", enabled))
	_cells = spec.get("shape_cells", _cells).duplicate()
	_center_cell = spec.get("center_cell", _center_cell)
	_pressable_cells = spec.get("pressable_cells", _pressable_cells).duplicate(true)
	_disabled_cells = spec.get("disabled_cells", _disabled_cells).duplicate(true)
	_label_by_cell = spec.get("label_by_cell", _label_by_cell).duplicate(true)
	_tooltip_by_cell = spec.get("tooltip_by_cell", _tooltip_by_cell).duplicate(true)
	_metadata_by_cell = spec.get("metadata_by_cell", _metadata_by_cell).duplicate(true)
	_rebuild()


func set_cells(cells: Array) -> void:
	_cells = cells.duplicate()
	_rebuild()


func set_pressable_cells(cells: Dictionary) -> void:
	_pressable_cells = cells.duplicate(true)
	_rebuild()


func set_cell_labels(labels: Dictionary) -> void:
	_label_by_cell = labels.duplicate(true)
	_rebuild()


func set_cell_tooltips(tooltips: Dictionary) -> void:
	_tooltip_by_cell = tooltips.duplicate(true)
	_rebuild()


func set_cell_metadata(metadata: Dictionary) -> void:
	_metadata_by_cell = metadata.duplicate(true)
	_rebuild()


func get_entries() -> Array:
	return _entries.duplicate(true)


func entry_at(local_pos: Vector2, pressable_only: bool = true) -> Dictionary:
	return HexCellButtonLayout.hit_entry(_entries, local_pos, pressable_only)


func _get_minimum_size() -> Vector2:
	return HexCellButtonLayout.minimum_size(_entries, padding)


func _gui_input(event: InputEvent) -> void:
	if not enabled:
		return
	if event is InputEventMouseMotion:
		_set_hovered_entry(entry_at(event.position, false))
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var entry = entry_at(event.position)
		if event.pressed:
			_pressed_id = String(entry.get("id", ""))
			if _pressed_id != "":
				accept_event()
				queue_redraw()
		else:
			var released_id = String(entry.get("id", ""))
			if _pressed_id != "" and _pressed_id == released_id:
				cell_pressed.emit(entry)
				accept_event()
			_pressed_id = ""
			queue_redraw()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if _handle_key(event.keycode):
			accept_event()


func _draw() -> void:
	for entry in _entries:
		var polygon: PackedVector2Array = entry["polygon"]
		draw_colored_polygon(polygon, _entry_fill(entry))
		var outline := PackedVector2Array(polygon)
		outline.append(polygon[0])
		draw_polyline(outline, _entry_outline(entry), 1.25)
		_draw_entry_label(entry)


func _rebuild() -> void:
	var spec := {
		"flat_top": flat_top,
		"cell_radius": cell_radius,
		"cell_gap": cell_gap,
		"padding": padding,
		"shape_kind": shape_kind,
		"shape_cells": _cells,
		"pressable_cells": _pressable_cells,
		"disabled_cells": _disabled_cells,
		"label_by_cell": _label_by_cell,
		"tooltip_by_cell": _tooltip_by_cell,
		"metadata_by_cell": _metadata_by_cell,
	}
	if _center_cell != null:
		spec["center_cell"] = _center_cell
	_entries = HexCellButtonLayout.build_entries(spec)
	update_minimum_size()
	queue_redraw()


func _set_hovered_entry(entry: Dictionary) -> void:
	var entry_id = String(entry.get("id", ""))
	if _hovered_id == entry_id:
		return
	_hovered_id = entry_id
	tooltip_text = String(entry.get("tooltip", ""))
	cell_hovered.emit(entry)
	queue_redraw()


func _handle_key(keycode: int) -> bool:
	if keycode == KEY_ENTER or keycode == KEY_KP_ENTER or keycode == KEY_SPACE:
		var entry = _entry_by_id(_focused_id)
		if entry.is_empty():
			entry = _first_pressable_entry()
		if not entry.is_empty():
			_focused_id = String(entry["id"])
			cell_pressed.emit(entry)
			queue_redraw()
			return true
	if keycode == KEY_RIGHT or keycode == KEY_DOWN:
		return _move_focus(1)
	if keycode == KEY_LEFT or keycode == KEY_UP:
		return _move_focus(-1)
	return false


func _move_focus(delta: int) -> bool:
	var pressable = _pressable_entries()
	if pressable.is_empty():
		return false
	var current_index := -1
	for index in range(pressable.size()):
		if String(pressable[index]["id"]) == _focused_id:
			current_index = index
			break
	var next_index = 0 if current_index < 0 else (current_index + delta + pressable.size()) % pressable.size()
	_focused_id = String(pressable[next_index]["id"])
	cell_focus_changed.emit(pressable[next_index])
	queue_redraw()
	return true


func _pressable_entries() -> Array:
	var result := []
	for entry in _entries:
		if bool(entry.get("pressable", true)) and not bool(entry.get("disabled", false)):
			result.append(entry)
	return result


func _first_pressable_entry() -> Dictionary:
	var entries = _pressable_entries()
	return {} if entries.is_empty() else entries[0]


func _entry_by_id(entry_id: String) -> Dictionary:
	for entry in _entries:
		if String(entry.get("id", "")) == entry_id:
			return entry
	return {}


func _entry_fill(entry: Dictionary) -> Color:
	if bool(entry.get("disabled", false)):
		return Color(0.18, 0.18, 0.18, 0.55)
	var entry_id = String(entry.get("id", ""))
	if entry_id == _pressed_id:
		return Color(0.28, 0.44, 0.72, 0.95)
	if entry_id == _hovered_id:
		return Color(0.32, 0.42, 0.58, 0.85)
	var metadata = entry.get("metadata", {})
	if metadata is Dictionary and (metadata as Dictionary).has("fill_color"):
		return (metadata as Dictionary)["fill_color"]
	if _entry_is_center(entry):
		return Color(0.24, 0.24, 0.28, 0.75)
	if not bool(entry.get("pressable", true)):
		return Color(0.22, 0.22, 0.24, 0.7)
	return Color(0.24, 0.31, 0.42, 0.85)


func _entry_outline(entry: Dictionary) -> Color:
	if String(entry.get("id", "")) == _focused_id:
		return Color(0.95, 0.8, 0.25)
	if bool(entry.get("pressable", true)) and not bool(entry.get("disabled", false)):
		return Color(0.68, 0.72, 0.78)
	return Color(0.45, 0.47, 0.5)


func _draw_entry_label(entry: Dictionary) -> void:
	if not show_labels:
		return
	var text = String(entry.get("label", ""))
	if text == "":
		return
	var font = get_theme_font("font", "Label")
	if font == null:
		return
	var font_size = mini(get_theme_font_size("font_size", "Label"), max(7, int(cell_radius * 0.75)))
	var max_width = maxf(8.0, cell_radius * 1.8)
	while font_size > 7 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > max_width:
		font_size -= 1
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var center: Vector2 = entry["center"]
	var position = center + Vector2(-max_width * 0.5, text_size.y * 0.35)
	draw_string(
		font,
		position,
		text,
		HORIZONTAL_ALIGNMENT_CENTER,
		max_width,
		font_size,
		_entry_label_color(entry)
	)


func _entry_label_color(entry: Dictionary) -> Color:
	if bool(entry.get("disabled", false)):
		return Color(0.55, 0.55, 0.55, 0.9)
	var metadata = entry.get("metadata", {})
	if metadata is Dictionary and (metadata as Dictionary).has("label_color"):
		return (metadata as Dictionary)["label_color"]
	return Color(0.92, 0.94, 0.98, 1.0)


func _entry_is_center(entry: Dictionary) -> bool:
	var metadata: Dictionary = entry.get("metadata", {})
	if bool(metadata.get("center", false)):
		return true
	var cell = entry.get("hex", null)
	return _center_cell != null and cell != null and cell.is_equal(_center_cell)
