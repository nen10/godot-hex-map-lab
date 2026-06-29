@tool
class_name HexCellButtonPanel
extends Control

signal cell_pressed(entry: Dictionary)
signal cell_hovered(entry: Dictionary)
signal cell_focus_changed(entry: Dictionary)
# Emitted in addition to cell_pressed when a togglable cell is activated.
# `pressed` is the new on/off state the panel already applied to the cell, so a
# listener only has to mirror it into its own data model (no re-configure needed).
signal cell_toggled(entry: Dictionary, pressed: bool)

const HexCellButtonLayout = preload("res://addons/hex_map_kit/editor/hex_cell_button_layout.gd")

# Default icon footprint expressed as a multiple of cell_radius. A value of 1.4
# makes a square icon span most of the hex without spilling past the outline.
const DEFAULT_ICON_SCALE := 1.4

enum ContentScaleMode {
	NONE,
	FIT_INSIDE,
	FILL_WIDTH,
	FILL_HEIGHT,
	COVER,
}

enum ContentAlign {
	BEGIN,
	CENTER,
	END,
}

var _batch_rebuild := 0
var _needs_rebuild := false

var _cells: Array = []
var _pressable_cells: Dictionary = {}
var _disabled_cells: Dictionary = {}
var _label_by_cell: Dictionary = {}
var _tooltip_by_cell: Dictionary = {}
var _metadata_by_cell: Dictionary = {}
var _center_cell = null
# Togglable cells: key -> current on/off state. Presence of a key marks the cell
# as togglable; pressing it flips the bool, swaps its appearance, and emits
# cell_toggled. Geometry is untouched, so toggling never triggers a rebuild.
var _toggle_state: Dictionary = {}
var _entries: Array[Dictionary] = []
var _hovered_id := ""
var _pressed_id := ""
var _focused_id := ""

@export_group("Geometry")

@export var flat_top: bool = true:
	set(value):
		if flat_top == value:
			return
		flat_top = value
		_request_rebuild()

@export_range(1.0, 128.0, 0.5, "or_greater", "suffix:px")
var cell_radius: float = 14.0:
	set(value):
		value = maxf(1.0, value)
		if is_equal_approx(cell_radius, value):
			return
		cell_radius = value
		_request_rebuild()

@export_range(0.0, 64.0, 0.5, "or_greater", "suffix:px")
var cell_gap: float = 2.0:
	set(value):
		value = maxf(0.0, value)
		if is_equal_approx(cell_gap, value):
			return
		cell_gap = value
		_request_rebuild()

@export var padding: Vector2 = Vector2(4, 4):
	set(value):
		value = Vector2(maxf(0.0, value.x), maxf(0.0, value.y))
		if padding == value:
			return
		padding = value
		_request_rebuild()

@export var shape_kind: String = HexCellButtonLayout.SHAPE_DIRECTIONS:
	set(value):
		if shape_kind == value:
			return
		shape_kind = value
		_request_rebuild()

@export_group("Layout")

@export var report_natural_minimum: bool = true:
	set(value):
		if report_natural_minimum == value:
			return
		report_natural_minimum = value
		update_minimum_size()
		queue_redraw()

@export_enum("None", "Fit Inside", "Fill Width", "Fill Height", "Cover")
var content_scale_mode: int = ContentScaleMode.NONE:
	set(value):
		if content_scale_mode == value:
			return
		content_scale_mode = value
		queue_redraw()

@export_enum("Begin", "Center", "End")
var horizontal_alignment: int = ContentAlign.CENTER:
	set(value):
		if horizontal_alignment == value:
			return
		horizontal_alignment = value
		queue_redraw()

@export_enum("Begin", "Center", "End")
var vertical_alignment: int = ContentAlign.CENTER:
	set(value):
		if vertical_alignment == value:
			return
		vertical_alignment = value
		queue_redraw()

# When enabled, the layout box is mirrored around the layout anchor
# (anchor_cell/anchor_cell_id, center_cell fallback, then geometric center) so
# the anchor stays pinned to the panel's alignment point. This keeps an
# asymmetric shape (e.g. the Markov state cluster) visually centered on its
# meaningful hex instead of drifting with the raw bounding box, and makes a row
# of panels read on a stable baseline.
@export var symmetric_about_anchor: bool = false:
	set(value):
		if symmetric_about_anchor == value:
			return
		symmetric_about_anchor = value
		update_minimum_size()
		queue_redraw()

# Extra cell key used as the layout anchor when symmetric_about_anchor is on.
# Empty means "use center_cell, then the geometric center".
var _anchor_id := ""

@export_group("Display")

@export var show_labels: bool = false:
	set(value):
		if show_labels == value:
			return
		show_labels = value
		queue_redraw()

@export var enabled: bool = true:
	set(value):
		if enabled == value:
			return
		enabled = value
		if not enabled:
			_hovered_id = ""
			_pressed_id = ""
		queue_redraw()

@export_group("Input")

@export var hit_only_cells: bool = false:
	set(value):
		if hit_only_cells == value:
			return
		hit_only_cells = value
		queue_redraw()


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	if _entries.is_empty():
		_needs_rebuild = true
	_flush_rebuild()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
	elif what == NOTIFICATION_MOUSE_EXIT:
		if _hovered_id != "" or _pressed_id != "":
			_hovered_id = ""
			_pressed_id = ""
			tooltip_text = ""
			queue_redraw()


func configure(spec: Dictionary) -> void:
	_batch_rebuild += 1

	flat_top = bool(spec.get("flat_top", flat_top))
	cell_radius = float(spec.get("cell_radius", cell_radius))
	cell_gap = float(spec.get("cell_gap", cell_gap))
	padding = spec.get("padding", padding)
	shape_kind = String(spec.get("shape_kind", shape_kind))
	report_natural_minimum = bool(spec.get("report_natural_minimum", report_natural_minimum))
	content_scale_mode = int(spec.get("content_scale_mode", content_scale_mode))
	horizontal_alignment = int(spec.get("horizontal_alignment", spec.get("content_horizontal_alignment", horizontal_alignment)))
	vertical_alignment = int(spec.get("vertical_alignment", spec.get("content_vertical_alignment", vertical_alignment)))
	symmetric_about_anchor = bool(spec.get("symmetric_about_anchor", spec.get("symmetric_about_center", symmetric_about_anchor)))
	if spec.has("anchor_cell") and spec["anchor_cell"] != null:
		_anchor_id = spec["anchor_cell"].key()
	else:
		_anchor_id = String(spec.get("anchor_cell_id", spec.get("layout_anchor_cell_id", _anchor_id)))
	hit_only_cells = bool(spec.get("hit_only_cells", hit_only_cells))
	show_labels = bool(spec.get("show_labels", show_labels))
	enabled = bool(spec.get("enabled", enabled))

	_cells = spec.get("shape_cells", _cells).duplicate()
	_center_cell = spec.get("center_cell", _center_cell)
	_pressable_cells = spec.get("pressable_cells", _pressable_cells).duplicate(true)
	_disabled_cells = spec.get("disabled_cells", _disabled_cells).duplicate(true)
	_label_by_cell = spec.get("label_by_cell", _label_by_cell).duplicate(true)
	_tooltip_by_cell = spec.get("tooltip_by_cell", _tooltip_by_cell).duplicate(true)
	_metadata_by_cell = spec.get("metadata_by_cell", _metadata_by_cell).duplicate(true)
	if spec.has("toggle_cells"):
		_toggle_state = _normalize_toggle_states(spec["toggle_cells"])

	_batch_rebuild -= 1
	_needs_rebuild = true
	_flush_rebuild()


func set_cells(cells: Array) -> void:
	_cells = cells.duplicate()
	_request_rebuild()


func set_pressable_cells(cells: Dictionary) -> void:
	_pressable_cells = cells.duplicate(true)
	_request_rebuild()


func set_disabled_cells(cells: Dictionary) -> void:
	_disabled_cells = cells.duplicate(true)
	_request_rebuild()


func set_cell_labels(labels: Dictionary) -> void:
	_label_by_cell = labels.duplicate(true)
	_request_rebuild()


func set_cell_tooltips(tooltips: Dictionary) -> void:
	_tooltip_by_cell = tooltips.duplicate(true)
	_request_rebuild()


func set_cell_metadata(metadata: Dictionary) -> void:
	_metadata_by_cell = metadata.duplicate(true)
	_request_rebuild()


func set_center_cell(cell) -> void:
	_center_cell = cell
	_request_rebuild()


# --- Toggle state -----------------------------------------------------------

# Mark cells as togglable and seed their initial on/off state.
# `cells` maps cell (HexVector or key string) -> bool.
func set_toggle_cells(cells: Dictionary) -> void:
	_toggle_state = _normalize_toggle_states(cells)
	_request_rebuild()


func set_cell_toggled(cell, pressed: bool, emit_signal_too: bool = false) -> bool:
	var key := _cell_key(cell)
	if not _toggle_state.has(key):
		return false
	_toggle_state[key] = pressed
	_apply_toggle_appearance(key)
	queue_redraw()
	if emit_signal_too:
		var entry := _entry_by_id(key)
		if not entry.is_empty():
			cell_toggled.emit(entry, pressed)
	return true


func is_cell_toggled(cell) -> bool:
	return bool(_toggle_state.get(_cell_key(cell), false))


func get_toggle_states() -> Dictionary:
	return _toggle_state.duplicate(true)


# --- Live visual updates (no geometry rebuild) ------------------------------

# Patch one cell's presentation in place and redraw immediately. Recognized
# keys: "label", "tooltip" (entry fields) and any metadata key such as
# "fill_color", "label_color", "icon", "icon_*". Use this for external drivers
# like a SpinBox that must recolor/relabel a cell without rebuilding geometry.
func update_cell(cell, patch: Dictionary) -> bool:
	var key := _cell_key(cell)
	var entry := _entry_by_id(key)
	if entry.is_empty():
		return false
	var metadata: Dictionary = entry.get("metadata", {}) if entry.get("metadata", {}) is Dictionary else {}
	for patch_key in patch:
		match patch_key:
			"label":
				entry["label"] = String(patch[patch_key])
				_label_by_cell[key] = entry["label"]
			"tooltip":
				entry["tooltip"] = String(patch[patch_key])
				_tooltip_by_cell[key] = entry["tooltip"]
			_:
				metadata[patch_key] = patch[patch_key]
	entry["metadata"] = metadata
	# Persist into the source map so a later rebuild keeps the change.
	_metadata_by_cell[key] = metadata.duplicate(true)
	queue_redraw()
	return true


func set_cell_fill_color(cell, color: Color) -> bool:
	return update_cell(cell, {"fill_color": color})


func set_cell_label(cell, text: String, label_color = null) -> bool:
	var patch := {"label": text}
	if label_color != null:
		patch["label_color"] = label_color
	return update_cell(cell, patch)


func set_layout_anchor_cell(cell) -> void:
	_anchor_id = "" if cell == null else cell.key()
	update_minimum_size()
	queue_redraw()


func set_layout_anchor_cell_id(cell_id: String) -> void:
	_anchor_id = cell_id
	update_minimum_size()
	queue_redraw()


func get_entries() -> Array:
	return _entries.duplicate(true)


func get_natural_size() -> Vector2:
	return _natural_size()


func get_content_rect() -> Rect2:
	var draw_scale := _content_scale()
	var bounds := _content_bounds()
	return Rect2(_content_offset() + bounds.position * draw_scale, bounds.size * draw_scale)


func layout_pos_from_local(local_pos: Vector2) -> Vector2:
	return _to_layout_pos(local_pos)


func local_pos_from_layout(layout_pos: Vector2) -> Vector2:
	return _content_offset() + layout_pos * _content_scale()


func entry_at(local_pos: Vector2, pressable_only: bool = true) -> Dictionary:
	return HexCellButtonLayout.hit_entry(_entries, _to_layout_pos(local_pos), pressable_only)


func use_natural_centered_layout() -> void:
	report_natural_minimum = true
	content_scale_mode = ContentScaleMode.NONE
	horizontal_alignment = ContentAlign.CENTER
	vertical_alignment = ContentAlign.CENTER
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	update_minimum_size()
	queue_redraw()


func use_responsive_fit_layout(minimum_size: Vector2 = Vector2.ZERO) -> void:
	report_natural_minimum = false
	content_scale_mode = ContentScaleMode.FIT_INSIDE
	horizontal_alignment = ContentAlign.CENTER
	vertical_alignment = ContentAlign.CENTER
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = minimum_size
	update_minimum_size()
	queue_redraw()


func _get_minimum_size() -> Vector2:
	return _natural_size() if report_natural_minimum else Vector2.ZERO


func _has_point(point: Vector2) -> bool:
	if not hit_only_cells:
		return Rect2(Vector2.ZERO, size).has_point(point)
	return not HexCellButtonLayout.hit_entry(_entries, _to_layout_pos(point), false).is_empty()


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
				_activate_entry(entry)
				accept_event()
			_pressed_id = ""
			queue_redraw()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if _handle_key(event.keycode):
			accept_event()


func _draw() -> void:
	if _entries.is_empty():
		return

	var draw_scale := _content_scale()
	var content_offset := _content_offset()
	draw_set_transform(content_offset, 0.0, Vector2.ONE * draw_scale)

	for entry in _entries:
		var polygon: PackedVector2Array = entry["polygon"]
		if polygon.size() < 3:
			continue
		if not _entry_hide_shape(entry):
			draw_colored_polygon(polygon, _entry_fill(entry))
			var outline := PackedVector2Array(polygon)
			outline.append(polygon[0])
			draw_polyline(outline, _entry_outline(entry), 1.25)
		_draw_entry_label(entry)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Icons are drawn in a second pass in screen space so each one can carry its
	# own rotation/scale transform without disturbing the shared content transform.
	for entry in _entries:
		_draw_entry_icon(entry, content_offset, draw_scale)


func _request_rebuild() -> void:
	_needs_rebuild = true
	if _batch_rebuild > 0:
		return
	_flush_rebuild()


func _flush_rebuild() -> void:
	if not _needs_rebuild:
		return
	_needs_rebuild = false
	_rebuild()


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
	_trim_interaction_state()
	_apply_all_toggle_appearance()
	update_minimum_size()
	queue_redraw()


func _natural_size() -> Vector2:
	return _content_bounds().size


func _content_bounds() -> Rect2:
	if _entries.is_empty():
		return Rect2(Vector2.ZERO, padding * 2.0)
	var bounds := _padded_entries_bounds()
	if not symmetric_about_anchor:
		return bounds
	var anchor := _layout_anchor()
	var half_extent := Vector2(
		maxf(absf(bounds.position.x - anchor.x), absf(bounds.end.x - anchor.x)),
		maxf(absf(bounds.position.y - anchor.y), absf(bounds.end.y - anchor.y))
	)
	return Rect2(anchor - half_extent, half_extent * 2.0)


func _padded_entries_bounds() -> Rect2:
	var bounds := _entries_bounds()
	return Rect2(
		bounds.position - padding,
		bounds.size + padding * 2.0
	)


func _entries_bounds() -> Rect2:
	if _entries.is_empty():
		return Rect2(Vector2.ZERO, padding * 2.0)
	var min_point := Vector2(INF, INF)
	var max_point := Vector2(-INF, -INF)
	for entry in _entries:
		var bounds: Rect2 = entry["bounds"]
		min_point.x = minf(min_point.x, bounds.position.x)
		min_point.y = minf(min_point.y, bounds.position.y)
		max_point.x = maxf(max_point.x, bounds.end.x)
		max_point.y = maxf(max_point.y, bounds.end.y)
	return Rect2(min_point, max_point - min_point)


func _layout_anchor() -> Vector2:
	var anchor_entry := _entry_by_id(_anchor_id)
	if not anchor_entry.is_empty():
		return anchor_entry["center"]
	if _center_cell != null:
		anchor_entry = _entry_by_id(_center_cell.key())
		if not anchor_entry.is_empty():
			return anchor_entry["center"]
	return _entries_bounds().get_center()


func _content_scale() -> float:
	var natural := _natural_size()
	if natural.x <= 0.0 or natural.y <= 0.0 or size.x <= 0.0 or size.y <= 0.0:
		return 1.0

	match content_scale_mode:
		ContentScaleMode.FIT_INSIDE:
			return maxf(0.001, minf(size.x / natural.x, size.y / natural.y))
		ContentScaleMode.FILL_WIDTH:
			return maxf(0.001, size.x / natural.x)
		ContentScaleMode.FILL_HEIGHT:
			return maxf(0.001, size.y / natural.y)
		ContentScaleMode.COVER:
			return maxf(0.001, maxf(size.x / natural.x, size.y / natural.y))
		_:
			return 1.0


func _content_offset() -> Vector2:
	var bounds := _content_bounds()
	var natural := bounds.size
	var draw_scale := _content_scale()
	var drawn_size := natural * draw_scale
	var free_space := size - drawn_size
	return Vector2(
		free_space.x * _align_factor(horizontal_alignment),
		free_space.y * _align_factor(vertical_alignment)
	) - bounds.position * draw_scale


func _to_layout_pos(local_pos: Vector2) -> Vector2:
	var draw_scale := _content_scale()
	if is_zero_approx(draw_scale):
		return local_pos
	return (local_pos - _content_offset()) / draw_scale


func _align_factor(align: int) -> float:
	match align:
		ContentAlign.CENTER:
			return 0.5
		ContentAlign.END:
			return 1.0
		_:
			return 0.0


func _trim_interaction_state() -> void:
	if _hovered_id != "" and _entry_by_id(_hovered_id).is_empty():
		_hovered_id = ""
		tooltip_text = ""
	if _pressed_id != "" and _entry_by_id(_pressed_id).is_empty():
		_pressed_id = ""
	if _focused_id != "" and _entry_by_id(_focused_id).is_empty():
		_focused_id = ""
	for key in _toggle_state.keys():
		if _entry_by_id(key).is_empty():
			_toggle_state.erase(key)


# --- Toggle / activation internals -----------------------------------------

func _cell_key(cell) -> String:
	if cell is String:
		return cell
	if cell == null:
		return ""
	return cell.key()


func _normalize_toggle_states(cells) -> Dictionary:
	var result := {}
	if cells is Dictionary:
		for cell in (cells as Dictionary):
			result[_cell_key(cell)] = bool((cells as Dictionary)[cell])
	return result


# A press routes here so mouse and keyboard share one path. Togglable cells flip
# first and emit cell_toggled; cell_pressed is always emitted for compatibility.
func _activate_entry(entry: Dictionary) -> void:
	if entry.is_empty():
		return
	var key := String(entry.get("id", ""))
	if _toggle_state.has(key):
		var new_state := not bool(_toggle_state[key])
		_toggle_state[key] = new_state
		_apply_toggle_appearance(key)
		queue_redraw()
		entry = _entry_by_id(key)
		cell_toggled.emit(entry, new_state)
	cell_pressed.emit(entry)


func _apply_all_toggle_appearance() -> void:
	for key in _toggle_state:
		_apply_toggle_appearance(key)


# Swap a toggle cell's fill (and optional label) to match its current state.
# Colors/labels come from metadata: toggle_on_fill/toggle_off_fill (default
# black/white) and optional toggle_on_label/toggle_off_label.
func _apply_toggle_appearance(key: String) -> void:
	var entry := _entry_by_id(key)
	if entry.is_empty():
		return
	var metadata: Dictionary = entry.get("metadata", {}) if entry.get("metadata", {}) is Dictionary else {}
	var pressed := bool(_toggle_state.get(key, false))
	var on_fill: Color = metadata.get("toggle_on_fill", Color.BLACK)
	var off_fill: Color = metadata.get("toggle_off_fill", Color.WHITE)
	metadata["fill_color"] = on_fill if pressed else off_fill
	if metadata.has("toggle_on_label") or metadata.has("toggle_off_label"):
		entry["label"] = String(metadata.get("toggle_on_label", "")) if pressed else String(metadata.get("toggle_off_label", ""))
		_label_by_cell[key] = entry["label"]
	if not metadata.has("label_color"):
		metadata["label_color"] = _contrasting_label_color(metadata["fill_color"])
	entry["metadata"] = metadata
	_metadata_by_cell[key] = metadata.duplicate(true)


func _contrasting_label_color(fill: Color) -> Color:
	var luminance := fill.r * 0.299 + fill.g * 0.587 + fill.b * 0.114
	return Color(0.08, 0.08, 0.09) if luminance > 0.55 else Color(0.92, 0.94, 0.98)


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
			_activate_entry(entry)
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


# Suppress the hex fill/outline for a cell so an icon can stand in for the cell
# itself. Set metadata["icon_only"] (or metadata["hide_shape"]) to true.
func _entry_hide_shape(entry: Dictionary) -> bool:
	var metadata = entry.get("metadata", {})
	if metadata is Dictionary:
		var md := metadata as Dictionary
		return bool(md.get("icon_only", md.get("hide_shape", false)))
	return false


func _entry_hide_label(entry: Dictionary) -> bool:
	var metadata = entry.get("metadata", {})
	if metadata is Dictionary:
		var md := metadata as Dictionary
		return bool(md.get("hide_label", md.get("icon_only", false)))
	return false


# Resolve a per-cell icon from metadata. Two ways to reference one:
#   metadata["icon"]            -> any Texture2D (e.g. preload(...), load(...))
#   metadata["icon_name"]       -> theme icon name, resolved via get_theme_icon
#   metadata["icon_theme_type"] -> theme type for the name (default "EditorIcons")
func _entry_icon(entry: Dictionary) -> Texture2D:
	var metadata = entry.get("metadata", {})
	if not (metadata is Dictionary):
		return null
	var md := metadata as Dictionary
	var direct = md.get("icon", null)
	if direct is Texture2D:
		return direct
	var icon_name := String(md.get("icon_name", ""))
	if icon_name == "":
		return null
	var theme_type := String(md.get("icon_theme_type", "EditorIcons"))
	if has_theme_icon(icon_name, theme_type):
		return get_theme_icon(icon_name, theme_type)
	return null


func _draw_entry_icon(entry: Dictionary, content_offset: Vector2, draw_scale: float) -> void:
	var tex := _entry_icon(entry)
	if tex == null:
		return
	var tex_size := tex.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return
	var metadata: Dictionary = entry.get("metadata", {})

	# Footprint: cell_radius * icon_scale (layout units), preserving aspect ratio.
	var icon_scale := float(metadata.get("icon_scale", DEFAULT_ICON_SCALE))
	var target := maxf(1.0, cell_radius * icon_scale)
	var fit := target / maxf(tex_size.x, tex_size.y)

	# Rotation: degrees and/or radians, plus optional auto-orient that points the
	# icon along the anchor -> cell direction (e.g. the generation arrow).
	var rotation := deg_to_rad(float(metadata.get("icon_rotation_degrees", 0.0)))
	rotation += float(metadata.get("icon_rotation", 0.0))
	if bool(metadata.get("icon_orient_to_anchor", false)):
		var direction: Vector2 = (entry["center"] as Vector2) - _layout_anchor()
		if direction.length() > 0.0001:
			rotation += direction.angle()

	var modulate: Color = metadata.get("icon_modulate", _entry_label_color(entry))
	var local_center := content_offset + (entry["center"] as Vector2) * draw_scale
	draw_set_transform(local_center, rotation, Vector2.ONE * draw_scale * fit)
	draw_texture_rect(tex, Rect2(-tex_size * 0.5, tex_size), false, modulate)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_entry_label(entry: Dictionary) -> void:
	if not show_labels:
		return
	if _entry_hide_label(entry):
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
