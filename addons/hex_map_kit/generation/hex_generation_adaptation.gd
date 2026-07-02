@tool
class_name HexGenerationAdaptation
extends RefCounted

const HexMapDataScript = preload("res://addons/hex_map_kit/core/hex_map_data.gd")
const HexOverlayDataScript = preload("res://addons/hex_map_kit/core/hex_overlay_data.gd")
const HexGenerationResultResourceScript = preload("res://addons/hex_map_kit/adapter/hex_generation_result_resource.gd")

const KIND_TERRAIN := "terrain"
const KIND_OVERLAY := "overlay"
const KIND_SELECTION := "selection"
const KIND_RESULT := "result"
const KIND_EMPTY := "empty"

const ADAPT_FLOOR := "floor"
const ADAPT_WALL := "wall"
const ADAPT_ANY := "any"
const ADAPT_CELLS := "cells"


static func producer_kind(value) -> String:
	if value is HexMapDataScript:
		return KIND_TERRAIN
	if value is HexOverlayDataScript:
		return KIND_OVERLAY
	if value is Array:
		return KIND_SELECTION
	if value is HexGenerationResultResourceScript:
		return KIND_RESULT
	return KIND_EMPTY


static func default_adaptation_for_value(value) -> String:
	match producer_kind(value):
		KIND_TERRAIN:
			return ADAPT_FLOOR
		KIND_OVERLAY:
			return ADAPT_CELLS
		KIND_SELECTION:
			return ""
		_:
			return ""


static func adapt_to_selection(value, adaptation: String = "") -> Array:
	var normalized := _normalize_adaptation(adaptation, value)
	match producer_kind(value):
		KIND_TERRAIN:
			var terrain := value as HexMapDataScript
			match normalized:
				ADAPT_WALL:
					return terrain.walls.duplicate()
				ADAPT_ANY:
					return terrain.cells.duplicate()
				ADAPT_FLOOR:
					return terrain.floor_cells()
				_:
					return terrain.item_cells(_item_key_from_adaptation(normalized))
		KIND_OVERLAY:
			var overlay := value as HexOverlayDataScript
			if normalized == ADAPT_CELLS or normalized == ADAPT_FLOOR or normalized == ADAPT_ANY:
				return overlay.occupied_cells()
			return overlay.item_cells(_item_key_from_adaptation(normalized))
		KIND_SELECTION:
			return HexMapDataScript.unique_points(value as Array)
		_:
			return []


static func _normalize_adaptation(adaptation: String, value) -> String:
	var text := String(adaptation).strip_edges()
	if text == "":
		return default_adaptation_for_value(value)
	if text.begins_with("item(") and text.ends_with(")"):
		return "item:%s" % text.substr(5, text.length() - 6)
	return text


static func _item_key_from_adaptation(adaptation: String) -> String:
	match adaptation:
		ADAPT_FLOOR:
			return HexMapDataScript.ITEM_FLOOR
		ADAPT_WALL:
			return HexMapDataScript.ITEM_WALL
		ADAPT_ANY, ADAPT_CELLS:
			return HexMapDataScript.ITEM_ANY
		_:
			if adaptation.begins_with("item:"):
				return adaptation.substr(5)
			return adaptation
