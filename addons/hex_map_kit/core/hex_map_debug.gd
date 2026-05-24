class_name HexMapDebug
extends RefCounted

const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")


static func render_ascii(
	data,
	floor_char: String = ".",
	wall_char: String = "#",
	missing_char: String = " ",
	indent_rows: bool = true
) -> String:
	if data.cells.is_empty():
		return ""

	var bounds = _axial_bounds(data.cells)
	var cell_set = data.cell_set()
	var wall_set = data.wall_set()
	var rows: Array = []

	for r in range(bounds["min_r"], bounds["max_r"] + 1):
		var row = ""
		if indent_rows and abs(r) % 2 == 1:
			row += missing_char

		for q in range(bounds["min_q"], bounds["max_q"] + 1):
			var key = _axial_key(q, r)
			if not cell_set.has(key):
				row += missing_char
			elif wall_set.has(key):
				row += wall_char
			else:
				row += floor_char
		rows.append(row)

	return "\n".join(rows)


static func render_summary(data) -> String:
	return "cells=%d walls=%d floors=%d cyclic_size=%d" % [
		data.cells.size(),
		data.walls.size(),
		data.floor_cells().size(),
		data.cyclic_size,
	]


static func _axial_bounds(points: Array) -> Dictionary:
	var first_axial: Vector2i = points[0].axial()
	var result = {
		"min_q": first_axial.x,
		"max_q": first_axial.x,
		"min_r": first_axial.y,
		"max_r": first_axial.y,
	}

	for point in points:
		var axial: Vector2i = point.axial()
		result["min_q"] = mini(result["min_q"], axial.x)
		result["max_q"] = maxi(result["max_q"], axial.x)
		result["min_r"] = mini(result["min_r"], axial.y)
		result["max_r"] = maxi(result["max_r"], axial.y)

	return result


static func _axial_key(q: int, r: int) -> String:
	return HexVectorScript.apply_basis(q, 0, r).key()
