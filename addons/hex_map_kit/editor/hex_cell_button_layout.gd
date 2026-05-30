@tool
class_name HexCellButtonLayout
extends RefCounted

const HexMapTileAdapter = preload("res://addons/hex_map_kit/adapter/hex_map_tile_adapter.gd")
const HexGrid = preload("res://addons/hex_map_kit/core/hex_grid.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")

const SHAPE_DIRECTIONS := "directions"
const SHAPE_CUSTOM := "custom"
const SHAPE_RING := "ring"
const SHAPE_DISC := "disc"


static func build_entries(spec: Dictionary) -> Array[Dictionary]:
	var flat_top := bool(spec.get("flat_top", true))
	var cell_radius := maxf(1.0, float(spec.get("cell_radius", 14.0)))
	var cell_gap := maxf(0.0, float(spec.get("cell_gap", 0.0)))
	var padding: Vector2 = spec.get("padding", Vector2(4, 4))
	var cells: Array = shape_cells(String(spec.get("shape_kind", SHAPE_DIRECTIONS)), spec)
	var pressable_cells: Dictionary = spec.get("pressable_cells", {})
	var disabled_cells: Dictionary = spec.get("disabled_cells", {})
	var label_by_cell: Dictionary = spec.get("label_by_cell", {})
	var tooltip_by_cell: Dictionary = spec.get("tooltip_by_cell", {})
	var metadata_by_cell: Dictionary = spec.get("metadata_by_cell", {})
	var has_pressable_spec := spec.has("pressable_cells") and not pressable_cells.is_empty()

	var raw_entries: Array[Dictionary] = []
	var min_point := Vector2(INF, INF)
	var max_point := Vector2(-INF, -INF)
	for cell in cells:
		var center = HexMapTileAdapter.hex_to_local(cell, cell_radius + cell_gap, flat_top)
		var polygon = hex_polygon(center, cell_radius, flat_top)
		var bounds = _polygon_bounds(polygon)
		min_point.x = minf(min_point.x, bounds.position.x)
		min_point.y = minf(min_point.y, bounds.position.y)
		max_point.x = maxf(max_point.x, bounds.end.x)
		max_point.y = maxf(max_point.y, bounds.end.y)
		raw_entries.append({
			"id": cell.key(),
			"hex": cell,
			"center": center,
			"polygon": polygon,
			"bounds": bounds,
			"pressable": _cell_bool(pressable_cells, cell, not has_pressable_spec),
			"disabled": _cell_bool(disabled_cells, cell, false),
			"label": String(_cell_value(label_by_cell, cell, "")),
			"tooltip": String(_cell_value(tooltip_by_cell, cell, "")),
			"metadata": _cell_value(metadata_by_cell, cell, {}),
		})

	if raw_entries.is_empty():
		return []

	var offset = padding - min_point
	var result: Array[Dictionary] = []
	for entry in raw_entries:
		result.append(_shift_entry(entry, offset))
	return result


static func minimum_size(entries: Array, padding: Vector2) -> Vector2:
	if entries.is_empty():
		return padding * 2.0
	var max_point := Vector2.ZERO
	for entry in entries:
		var bounds: Rect2 = entry["bounds"]
		max_point.x = maxf(max_point.x, bounds.end.x)
		max_point.y = maxf(max_point.y, bounds.end.y)
	return max_point + padding


static func hex_polygon(center: Vector2, radius: float, flat_top: bool) -> PackedVector2Array:
	var points := PackedVector2Array()
	var rotation := 0.0 if flat_top else 30.0
	for index in range(6):
		var angle = deg_to_rad(rotation + 60.0 * float(index))
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return points


static func hit_entry(entries: Array, local_pos: Vector2) -> Dictionary:
	for index in range(entries.size() - 1, -1, -1):
		var entry: Dictionary = entries[index]
		if bool(entry.get("disabled", false)) or not bool(entry.get("pressable", true)):
			continue
		var bounds: Rect2 = entry["bounds"]
		if not bounds.has_point(local_pos):
			continue
		if Geometry2D.is_point_in_polygon(local_pos, entry["polygon"]):
			return entry
	return {}


static func direction_cells() -> Array:
	var result := [HexVector.zero()]
	result.append_array(HexVector.directions())
	return result


static func shape_cells(shape_kind: String, options: Dictionary = {}) -> Array:
	match shape_kind:
		SHAPE_CUSTOM:
			return options.get("shape_cells", []).duplicate()
		SHAPE_RING:
			return HexGrid.l1_ring(max(1, int(options.get("radius", 1))), options.get("center_cell", HexVector.zero()))
		SHAPE_DISC:
			return HexGrid.l1_disc(max(0, int(options.get("radius", 1))), options.get("center_cell", HexVector.zero()))
		SHAPE_DIRECTIONS, _:
			var center = options.get("center_cell", HexVector.zero())
			var result := [center]
			for direction in HexVector.directions():
				result.append(center.add(direction))
			return result


static func _shift_entry(entry: Dictionary, offset: Vector2) -> Dictionary:
	var polygon := PackedVector2Array()
	for point in entry["polygon"]:
		polygon.append(point + offset)
	var result = entry.duplicate(true)
	result["center"] = entry["center"] + offset
	result["polygon"] = polygon
	result["bounds"] = _polygon_bounds(polygon)
	return result


static func _polygon_bounds(points: PackedVector2Array) -> Rect2:
	if points.is_empty():
		return Rect2()
	var min_point = points[0]
	var max_point = points[0]
	for point in points:
		min_point.x = minf(min_point.x, point.x)
		min_point.y = minf(min_point.y, point.y)
		max_point.x = maxf(max_point.x, point.x)
		max_point.y = maxf(max_point.y, point.y)
	return Rect2(min_point, max_point - min_point)


static func _cell_bool(values: Dictionary, cell, default_value: bool) -> bool:
	var value = _cell_value(values, cell, default_value)
	return bool(value)


static func _cell_value(values: Dictionary, cell, default_value):
	if values.has(cell.key()):
		return values[cell.key()]
	if values.has(cell):
		return values[cell]
	return default_value
