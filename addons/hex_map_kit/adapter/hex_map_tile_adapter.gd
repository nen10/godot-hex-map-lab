class_name HexMapTileAdapter
extends RefCounted

const KIND_FLOOR := "floor"
const KIND_WALL := "wall"
const SAMPLE_TILE_ATLAS_PATH := "res://addons/hex_map_kit/assets/sample_hex_tiles.png"
const SAMPLE_TILE_SIZE := Vector2i(64, 57)

const HexPointScript = preload("res://addons/hex_map_kit/core/hex_point.gd")


static func vector_to_map_cell(vector, flat_top: bool = true) -> Vector2i:
	var axial := vector_to_display_axial(vector)
	if flat_top:
		return Vector2i(axial.x, axial.y + _floor_div2(axial.x))
	return Vector2i(axial.x + _floor_div2(axial.y), axial.y)


static func vector_to_sort_z(vector) -> int:
	return _vector_to_point(vector).to_cell().z


static func vector_to_display_axial(vector) -> Vector2i:
	return Vector2i(vector.q - vector.r, vector.r - vector.s)


static func to_tile_entries(
	data,
	include_floors: bool = true,
	include_walls: bool = true,
	flat_top: bool = true
) -> Array:
	var wall_set = data.wall_set()
	var entries: Array = []

	for cell in data.cells:
		var is_wall = wall_set.has(cell.key())
		var kind = KIND_WALL if is_wall else KIND_FLOOR
		if is_wall and not include_walls:
			continue
		if not is_wall and not include_floors:
			continue

		entries.append({
			"vector": cell,
			"kind": kind,
			"map_cell": vector_to_map_cell(cell, flat_top),
			"sort_z": vector_to_sort_z(cell),
		})

	entries.sort_custom(_compare_entries)
	return entries


static func apply_to_tile_map_layer(
	layer,
	data,
	floor_source_id: int = 0,
	floor_atlas_coords: Vector2i = Vector2i.ZERO,
	wall_source_id: int = 0,
	wall_atlas_coords: Vector2i = Vector2i(1, 0),
	clear_layer: bool = true,
	flat_top: bool = true
) -> void:
	if clear_layer and layer.has_method("clear"):
		layer.clear()

	for entry in to_tile_entries(data, true, true, flat_top):
		if entry["kind"] == KIND_WALL:
			layer.set_cell(entry["map_cell"], wall_source_id, wall_atlas_coords)
		else:
			layer.set_cell(entry["map_cell"], floor_source_id, floor_atlas_coords)


static func configure_hex_tile_set(
	tile_set: TileSet,
	flat_top: bool = true,
	tile_size: Vector2i = Vector2i.ZERO
) -> void:
	if tile_set == null:
		return
	tile_set.tile_shape = TileSet.TILE_SHAPE_HEXAGON
	tile_set.tile_layout = TileSet.TILE_LAYOUT_STACKED
	tile_set.tile_offset_axis = TileSet.TILE_OFFSET_AXIS_VERTICAL if flat_top else TileSet.TILE_OFFSET_AXIS_HORIZONTAL
	if tile_size.x > 0 and tile_size.y > 0:
		tile_set.tile_size = tile_size


static func configure_sample_tile_set(
	tile_set: TileSet,
	flat_top: bool = true,
	tile_size: Vector2i = SAMPLE_TILE_SIZE
) -> bool:
	if tile_set == null:
		return false
	var texture := load_sample_tile_texture()
	if texture == null:
		return false

	configure_hex_tile_set(tile_set, flat_top, tile_size)
	if tile_set.has_source(0):
		tile_set.remove_source(0)

	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = tile_size
	tile_set.add_source(source, 0)
	source.create_tile(Vector2i(0, 0))
	source.create_tile(Vector2i(1, 0))
	return true


static func load_sample_tile_texture() -> Texture2D:
	var image := Image.new()
	var error = image.load(ProjectSettings.globalize_path(SAMPLE_TILE_ATLAS_PATH))
	if error != OK:
		return null
	return ImageTexture.create_from_image(image)


static func hex_to_local(vector, hex_size: float, flat_top: bool = true) -> Vector2:
	var axial: Vector2i = vector_to_display_axial(vector)
	var q = float(axial.x)
	var r = float(axial.y)
	var sqrt3 = sqrt(3.0)

	if flat_top:
		return Vector2(
			hex_size * 1.5 * q,
			hex_size * sqrt3 * (r + q * 0.5)
		)

	return Vector2(
		hex_size * sqrt3 * (q + r * 0.5),
		hex_size * 1.5 * r
	)


static func _vector_to_point(vector):
	return HexPointScript.from_cube(vector.q, vector.s, vector.r)


static func _floor_div2(value: int) -> int:
	return int(floor(float(value) / 2.0))


static func _compare_entries(left: Dictionary, right: Dictionary) -> bool:
	var left_cell: Vector2i = left["map_cell"]
	var right_cell: Vector2i = right["map_cell"]
	if left_cell.y != right_cell.y:
		return left_cell.y < right_cell.y
	if left_cell.x != right_cell.x:
		return left_cell.x < right_cell.x
	return left["sort_z"] < right["sort_z"]
