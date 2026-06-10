@tool
class_name HexTileCatalogPreviewControl
extends Control

const RENDER_UNAVAILABLE := "unavailable"
const RENDER_ATLAS_TEXTURE_REGION := "atlas_texture_region"
const RENDER_SCENE_RESOURCE := "scene_resource"

var _snapshot := unavailable_preview("empty")


func _ready() -> void:
	custom_minimum_size = Vector2(136, 104)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL


func set_preview_snapshot(snapshot: Dictionary) -> void:
	_snapshot = snapshot.duplicate(true)
	tooltip_text = String(_snapshot.get("badge_tooltip", _snapshot.get("unavailable_reason", "")))
	queue_redraw()


func preview_snapshot() -> Dictionary:
	return _snapshot.duplicate(true)


func clear_preview(reason: String = "empty") -> void:
	set_preview_snapshot(unavailable_preview(reason))


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, Color(0.13, 0.14, 0.15), true)
	draw_rect(rect, Color(0.30, 0.32, 0.34), false, 1.0)
	if not bool(_snapshot.get("available", false)):
		_draw_unavailable(rect)
		return
	match String(_snapshot.get("render_kind", "")):
		RENDER_ATLAS_TEXTURE_REGION:
			_draw_atlas_region(rect)
		RENDER_SCENE_RESOURCE:
			_draw_scene_glyph(rect)
		_:
			_draw_unavailable(rect)


static func unavailable_preview(reason: String = "empty") -> Dictionary:
	return {
		"available": false,
		"kind": "none",
		"render_kind": RENDER_UNAVAILABLE,
		"text": "",
		"unavailable_reason": reason,
		"badge": {
			"available": false,
			"text": "Preview unavailable",
			"tone": "warning",
			"tooltip": reason,
		},
		"badge_text": "Preview unavailable",
		"badge_tooltip": reason,
		"sample_source": false,
	}


func _draw_atlas_region(rect: Rect2) -> void:
	var texture = _snapshot.get("texture", null)
	var region_value = _snapshot.get("texture_region", Rect2())
	if texture is Texture2D and region_value is Rect2:
		var region: Rect2 = region_value
		var destination := _fit_rect(region.size, rect.grow(-8.0))
		draw_texture_rect_region(texture as Texture2D, destination, region)
		draw_rect(destination, Color(0.68, 0.76, 0.82), false, 1.0)
	else:
		_draw_unavailable(rect)


func _draw_scene_glyph(rect: Rect2) -> void:
	var center := rect.get_center()
	var body := Rect2(center - Vector2(28, 22), Vector2(56, 44))
	draw_rect(body, Color(0.28, 0.36, 0.54), true)
	draw_rect(body, Color(0.60, 0.70, 0.92), false, 2.0)
	draw_circle(center + Vector2(-14, -8), 6.0, Color(0.74, 0.86, 1.0))
	draw_circle(center + Vector2(14, 8), 6.0, Color(0.74, 0.86, 1.0))
	draw_line(center + Vector2(-8, -4), center + Vector2(8, 4), Color(0.74, 0.86, 1.0), 2.0)


func _draw_unavailable(rect: Rect2) -> void:
	var inner := rect.grow(-12.0)
	draw_rect(inner, Color(0.20, 0.18, 0.12), true)
	draw_rect(inner, Color(0.72, 0.55, 0.22), false, 1.0)
	draw_line(inner.position + Vector2(10, 10), inner.end - Vector2(10, 10), Color(0.72, 0.55, 0.22), 2.0)
	draw_line(Vector2(inner.end.x - 10, inner.position.y + 10), Vector2(inner.position.x + 10, inner.end.y - 10), Color(0.72, 0.55, 0.22), 2.0)


func _fit_rect(content_size: Vector2, bounds: Rect2) -> Rect2:
	if content_size.x <= 0.0 or content_size.y <= 0.0:
		return bounds
	var scale: float = min(bounds.size.x / content_size.x, bounds.size.y / content_size.y)
	var fitted: Vector2 = content_size * scale
	return Rect2(bounds.position + (bounds.size - fitted) * 0.5, fitted)
