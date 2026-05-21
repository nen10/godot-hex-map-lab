class_name HexToricMapSplitRule
extends RefCounted

const HexVectorScript = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexToricCoordinateScript = preload("res://addons/hex_map_kit/core/hex_toric_coordinate.gd")

const SYMMETRY_KIND_OUTER_MOD := "outer_mod"
const SYMMETRY_KIND_OUTER_WAVE := "outer_wave"
const SYMMETRY_KIND_OUTER_PHASE2_BOUNDARY := "outer_phase2_boundary"
const SYMMETRY_KIND_OUTER_DUMMY := "outer_dummy"
const SYMMETRY_KIND_BORDER_INITIAL := "border_initial"
const SYMMETRY_KIND_BORDER_EDGE := "border_edge"
const SYMMETRY_KIND_INNER_ARC := "inner_arc"
const SYMMETRY_KIND_CENTER := "center"
const SYMMETRY_GROUP_PAIR := "pair"
const SYMMETRY_GROUP_TRIPLE := "triple"

var map_unit_radius: int
var cyclic_size: int
var split_canvas: Array = []
var split_canvas_origins: Array = []
var split_tag: Dictionary = {}


func _init(p_map_unit_radius: int = 1) -> void:
	assert(p_map_unit_radius > 0)
	map_unit_radius = p_map_unit_radius
	cyclic_size = map_unit_radius * 2 + 1
	_build_split_canvas()


func canvas_cells() -> Array:
	var result: Array = []
	for area in split_canvas:
		result.append_array(area)
	return result


func split_index_for(point) -> int:
	var wrapped = HexToricCoordinateScript.wrap_vector(point, cyclic_size)
	return split_tag.get(wrapped.key(), -1)


func get_rough_split_tag(point) -> int:
	var split_index = split_index_for(point)
	if split_index == -1:
		return -1
	return split_index if split_index % 7 == 0 else 8


func get_split_area_unit(origin, flat_left: bool = true) -> Array:
	return triangle(map_unit_radius, origin, flat_left)


func symmetry_generation_entries() -> Array:
	return _symmetry_generation_entries()


func symmetry_unity_generation_entries() -> Array:
	return _symmetry_generation_entries()


func symmetry_unity_reference_groups() -> Array:
	var entries = symmetry_unity_generation_entries()
	var buckets := {}
	for entry in entries:
		var kind: String = entry["kind"]
		if not _symmetry_reference_group_kind(kind):
			continue
		var reference = _reference_position(entry["source"])
		var bucket_key = "%s|%s" % [kind, reference.key()]
		if not buckets.has(bucket_key):
			buckets[bucket_key] = {
				"kind": kind,
				"phase": entry["phase"],
				"reference": reference,
				"sources": [],
				"source_keys": {},
				"entries": [],
			}
		var bucket: Dictionary = buckets[bucket_key]
		var source_key = entry["source"].key()
		if not bucket["source_keys"].has(source_key):
			bucket["source_keys"][source_key] = true
			bucket["sources"].append(entry["source"])
		bucket["entries"].append(entry)

	var result: Array = []
	for bucket in buckets.values():
		if bucket["sources"].size() <= 1:
			continue
		bucket.erase("source_keys")
		bucket["group"] = _symmetry_group_name(bucket["sources"].size())
		result.append(bucket)
	result.sort_custom(_compare_symmetry_reference_groups)
	return result


func _symmetry_generation_entries() -> Array:
	var tracker := {
		"entries": [],
		"order": 0,
	}
	var draw_node = _symmetry_draw_outer_area(tracker)
	draw_node = _symmetry_draw_border(draw_node, tracker)
	_symmetry_draw_inner_area(draw_node, tracker)
	return tracker["entries"]


func symmetry_generation_tags() -> Dictionary:
	var result := {}
	for entry in symmetry_generation_entries():
		var key = entry["vector"].key()
		if not result.has(key):
			result[key] = entry
			continue
		if _symmetry_kind_priority(entry["kind"]) >= _symmetry_kind_priority(result[key]["kind"]):
			result[key] = entry
	return result


func symmetry_phase2_outer_mod_groups() -> Array:
	if (map_unit_radius - 1) % 3 != 2:
		return []

	var left = _symmetry_phase2_outer_mod_points(true, split_canvas_origins[0])
	var right = _symmetry_phase2_outer_mod_points(false, split_canvas_origins[7])
	return [
		{
			"group": SYMMETRY_GROUP_TRIPLE,
			"points": [left[0]["corner"], right[1]["corner"], left[2]["corner"]],
			"kind": SYMMETRY_KIND_OUTER_MOD,
			"phase": 2,
		},
		{
			"group": SYMMETRY_GROUP_TRIPLE,
			"points": [right[0]["corner"], right[2]["corner"], left[1]["corner"]],
			"kind": SYMMETRY_KIND_OUTER_MOD,
			"phase": 2,
		},
		{
			"group": SYMMETRY_GROUP_PAIR,
			"points": [left[0]["edge"], right[1]["edge"]],
			"kind": SYMMETRY_KIND_OUTER_MOD,
			"phase": 2,
		},
		{
			"group": SYMMETRY_GROUP_PAIR,
			"points": [left[1]["edge"], right[0]["edge"]],
			"kind": SYMMETRY_KIND_OUTER_MOD,
			"phase": 2,
		},
		{
			"group": SYMMETRY_GROUP_PAIR,
			"points": [left[2]["edge"], right[2]["edge"]],
			"kind": SYMMETRY_KIND_OUTER_MOD,
			"phase": 2,
		},
	]


func symmetry_phase2_outer_mod_triangles() -> Array:
	var result: Array = []
	for group in symmetry_phase2_outer_mod_groups():
		if group["group"] == SYMMETRY_GROUP_TRIPLE:
			result.append(group)
	return result


static func triangle(edge_length: int, origin, flat_left: bool = true) -> Array:
	assert(edge_length > 0)
	var result: Array = []
	for q in range(edge_length):
		for r in range(edge_length):
			var delta = r - q
			if flat_left and delta < 0:
				continue
			if not flat_left and delta > 0:
				continue
			result.append(origin.add(HexVectorScript.apply_basis(q, 0, r)))
	return result


func _build_split_canvas() -> void:
	split_canvas_origins = [
		HexVectorScript.apply_basis(0, 0, map_unit_radius + 1),
		HexVectorScript.apply_basis(0, 0, map_unit_radius),
		HexVectorScript.apply_basis(0, 0, 0),
		HexVectorScript.apply_basis(1, 0, 0),
		HexVectorScript.apply_basis(map_unit_radius, 0, map_unit_radius + 1),
		HexVectorScript.apply_basis(map_unit_radius + 1, 0, map_unit_radius + 1),
		HexVectorScript.apply_basis(map_unit_radius + 1, 0, 1),
		HexVectorScript.apply_basis(map_unit_radius + 1, 0, 0),
	]

	split_canvas = []
	for index in range(split_canvas_origins.size()):
		split_canvas.append(get_split_area_unit(split_canvas_origins[index], index % 2 == 0))

	split_canvas_origins.append(HexVectorScript.apply_basis(map_unit_radius, 0, map_unit_radius))
	split_canvas.append([HexVectorScript.apply_basis(map_unit_radius, 0, map_unit_radius)])

	split_tag = {}
	for area_index in range(split_canvas.size()):
		for point in split_canvas[area_index]:
			split_tag[point.key()] = area_index


func _symmetry_draw_outer_area(tracker: Dictionary) -> Array:
	var draw_node0 = _symmetry_draw_edge_area(true, split_canvas_origins[0], tracker, 0)
	var draw_node7 = _symmetry_draw_edge_area(false, split_canvas_origins[7], tracker, 7)
	var result: Array = []
	result.append_array(draw_node0)
	result.append_array(draw_node7)
	return result


func _symmetry_draw_edge_area(
	flat_left: bool,
	origin,
	tracker: Dictionary,
	split_index: int
) -> Array:
	var draw_node = _symmetry_draw_area_center(flat_left, origin, tracker, split_index)
	return _symmetry_draw_area_from_center(flat_left, origin, draw_node, tracker, split_index)


func _symmetry_draw_area_center(
	flat_left: bool,
	origin,
	tracker: Dictionary,
	split_index: int
) -> Array:
	var step_directions = _symmetry_edge_step_directions(flat_left)
	var center_direction = _r_axis().subtract(_s_axis()) if flat_left else _q_axis().subtract(_s_axis())
	var pen = origin.add(center_direction.scaled(int(map_unit_radius / 3)))
	var draw_node: Array = []
	var arc_size = (map_unit_radius - 1) % 3
	var phase = arc_size

	if arc_size == 0:
		_track_symmetry_point(tracker, pen, SYMMETRY_KIND_OUTER_MOD, phase, split_index, -1, 0)
	for side in range(step_directions.size()):
		if arc_size != 0:
			_track_symmetry_point(
				tracker,
				pen,
				SYMMETRY_KIND_OUTER_MOD,
				phase,
				split_index,
				side,
				0
			)
		draw_node.append(pen)
		for index in range(arc_size):
			if index > 0:
				_track_symmetry_point(
					tracker,
					pen,
					SYMMETRY_KIND_OUTER_MOD,
					phase,
					split_index,
					side,
					index
				)
			pen = pen.add(step_directions[side])
	return draw_node


func _symmetry_phase2_outer_mod_points(flat_left: bool, origin) -> Array:
	var step_directions = _symmetry_edge_step_directions(flat_left)
	var center_direction = _r_axis().subtract(_s_axis()) if flat_left else _q_axis().subtract(_s_axis())
	var pen = origin.add(center_direction.scaled(int(map_unit_radius / 3)))
	var result: Array = []

	for side in range(step_directions.size()):
		var corner = pen
		pen = pen.add(step_directions[side])
		var edge = pen
		pen = pen.add(step_directions[side])
		result.append({
			"corner": corner,
			"edge": edge,
			"side": side,
		})
	return result


func _symmetry_draw_area_from_center(
	flat_left: bool,
	origin,
	draw_node: Array,
	tracker: Dictionary,
	split_index: int
) -> Array:
	var step_directions = _symmetry_edge_step_directions(flat_left)
	var wave_directions: Array = []
	var ref_directions: Array = []
	var arc_size = (map_unit_radius - 1) % 3
	var pen = HexVectorScript.zero()
	var wave_count = 0

	for side in range(3):
		wave_directions.append(step_directions[(side + 2) % 3].subtract(step_directions[side]))
	for side in range(3):
		ref_directions.append([
			step_directions[side].negated(),
			wave_directions[side].negated().subtract(step_directions[side]).subtract(step_directions[side]),
			wave_directions[side].negated().subtract(step_directions[side]),
		])

	while not pen.is_equal(origin):
		wave_count += 1
		arc_size += 3
		for side in range(3):
			draw_node[side] = draw_node[side].add(wave_directions[side])
			pen = draw_node[side]
			_track_symmetry_point(
				tracker,
				pen,
				SYMMETRY_KIND_OUTER_WAVE,
				(map_unit_radius - 1) % 3,
				split_index,
				side,
				wave_count
			)
			_track_symmetry_point(
				tracker,
				pen.add(ref_directions[side][2]),
				SYMMETRY_KIND_OUTER_DUMMY,
				(map_unit_radius - 1) % 3,
				split_index,
				side,
				wave_count
			)

		for side in range(3):
			pen = draw_node[side]
			for index in range(1, arc_size - 1):
				pen = pen.add(step_directions[side])
				_track_symmetry_point(
					tracker,
					pen,
					SYMMETRY_KIND_OUTER_WAVE,
					(map_unit_radius - 1) % 3,
					split_index,
					side,
					wave_count
				)

		for side in range(3):
			pen = draw_node[side].add(step_directions[side].scaled(arc_size - 1))
			_track_symmetry_point(
				tracker,
				pen,
				SYMMETRY_KIND_OUTER_WAVE,
				(map_unit_radius - 1) % 3,
				split_index,
				side,
				wave_count
			)
			pen = pen.add(step_directions[side])

	return draw_node


func _symmetry_draw_border(draw_node: Array, tracker: Dictionary) -> Array:
	var step_directions = _symmetry_step_directions_for_arcs()
	for side in range(3):
		var source = draw_node[side].add(step_directions[side])
		_track_symmetry_point(
			tracker,
			source,
			SYMMETRY_KIND_BORDER_INITIAL,
			(map_unit_radius - 1) % 3,
			-1,
			side,
			0,
			true
		)

	for side in range(6):
		var index = 1 - int(side / 3)
		var source = draw_node[side].add(step_directions[side].scaled(index))
		var pen = _reference_position(source)
		for cursor in range(index, map_unit_radius):
			source = pen.add(step_directions[side])
			pen = _reference_position(source)
			_track_symmetry_point(
				tracker,
				source,
				SYMMETRY_KIND_BORDER_EDGE,
				(map_unit_radius - 1) % 3,
				-1,
				side,
				cursor,
				true
			)

	var next_draw_node: Array = []
	for side in range(draw_node.size()):
		next_draw_node.append(_reference_position(draw_node[side].add(step_directions[side])))
	return next_draw_node


func _symmetry_draw_inner_area(draw_node: Array, tracker: Dictionary) -> void:
	var step_directions = _symmetry_step_directions_for_arcs()
	var reference_directions = _symmetry_reference_directions_for_arcs()
	for wave in range(1, map_unit_radius):
		var next_draw_node: Array = []
		for side in range(draw_node.size()):
			next_draw_node.append(draw_node[side].subtract(reference_directions[side][1]))
		draw_node = next_draw_node
		for side in range(6):
			for index in range(map_unit_radius - wave):
				_track_symmetry_point(
					tracker,
					draw_node[side].add(step_directions[side].scaled(index)),
					SYMMETRY_KIND_INNER_ARC,
					(map_unit_radius - 1) % 3,
					-1,
					side,
					wave
				)

	var center = draw_node[0].add(draw_node[1]).add(draw_node[2]).divided(3)
	_track_symmetry_point(
		tracker,
		center,
		SYMMETRY_KIND_CENTER,
		(map_unit_radius - 1) % 3,
		-1,
		-1,
		0
	)


func _track_symmetry_point(
	tracker: Dictionary,
	source,
	kind: String,
	phase: int,
	source_split: int,
	side: int,
	wave: int,
	use_reference: bool = false
) -> void:
	var vector = _reference_position(source) if use_reference else source
	assert(split_index_for(vector) >= 0)
	tracker["entries"].append({
		"source": source,
		"vector": vector,
		"kind": kind,
		"phase": phase,
		"source_split": source_split,
		"side": side,
		"wave": wave,
		"moved": not source.is_equal(vector),
		"split": split_index_for(vector),
		"order": tracker["order"],
	})
	tracker["order"] += 1


func _reference_position(point):
	return HexToricCoordinateScript.wrap_vector(point, cyclic_size)


func _symmetry_edge_step_directions(flat_left: bool) -> Array:
	if flat_left:
		return [_r_axis(), _q_axis(), _s_axis()]
	return [_q_axis(), _r_axis(), _s_axis()]


func _symmetry_step_directions_for_arcs() -> Array:
	return [
		_r_axis().negated(),
		_q_axis().negated(),
		_s_axis().negated(),
		_s_axis(),
		_q_axis(),
		_r_axis(),
	]


func _symmetry_reference_directions_for_arcs() -> Array:
	var steps = _symmetry_step_directions_for_arcs()
	var result: Array = []
	for side in range(6):
		var group = int(side / 3)
		result.append([
			steps[5 - side],
			steps[group * 3 + (side + 1 + group) % 3],
			steps[group * 3 + (side + 2 - group) % 3].negated(),
		])
	return result


func _symmetry_kind_priority(kind: String) -> int:
	match kind:
		SYMMETRY_KIND_CENTER:
			return 60
		SYMMETRY_KIND_INNER_ARC:
			return 50
		SYMMETRY_KIND_BORDER_INITIAL, SYMMETRY_KIND_BORDER_EDGE:
			return 40
		SYMMETRY_KIND_OUTER_MOD:
			return 30
		SYMMETRY_KIND_OUTER_PHASE2_BOUNDARY:
			return 25
		SYMMETRY_KIND_OUTER_WAVE:
			return 20
		SYMMETRY_KIND_OUTER_DUMMY:
			return 10
		_:
			return 0


func _symmetry_reference_group_kind(kind: String) -> bool:
	return kind == SYMMETRY_KIND_OUTER_MOD \
		or kind == SYMMETRY_KIND_OUTER_WAVE \
		or kind == SYMMETRY_KIND_BORDER_INITIAL \
		or kind == SYMMETRY_KIND_BORDER_EDGE


func _symmetry_group_name(source_count: int) -> String:
	if source_count == 2:
		return SYMMETRY_GROUP_PAIR
	if source_count == 3:
		return SYMMETRY_GROUP_TRIPLE
	return "%d-fold" % source_count


static func _compare_symmetry_reference_groups(left: Dictionary, right: Dictionary) -> bool:
	if left["phase"] != right["phase"]:
		return left["phase"] < right["phase"]
	if left["kind"] != right["kind"]:
		return left["kind"] < right["kind"]
	return left["reference"].key() < right["reference"].key()


func _q_axis():
	return HexVectorScript.q_axis()


func _s_axis():
	return HexVectorScript.s_axis()


func _r_axis():
	return HexVectorScript.r_axis()
