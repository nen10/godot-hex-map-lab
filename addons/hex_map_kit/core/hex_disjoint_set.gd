class_name HexDisjointSet
extends RefCounted

var _parent: Dictionary = {}
var _comp_size: Dictionary = {}
var _comp_rep: Dictionary = {}
var _all_cells: Dictionary = {}
var _root_count: int = 0


func root_count() -> int:
	return _root_count


func has(key: String) -> bool:
	return _parent.has(key)


func find(key: String) -> String:
	if not _parent.has(key):
		return ""
	if _parent[key] != key:
		_parent[key] = find(_parent[key])
	return _parent[key]


func add_component(cells: Array) -> String:
	if cells.is_empty():
		return ""
	var root_key = cells[0].key()
	_parent[root_key] = root_key
	_comp_size[root_key] = cells.size()
	_comp_rep[root_key] = cells[0]
	_all_cells[root_key] = cells[0]
	_root_count += 1
	for i in range(1, cells.size()):
		var c = cells[i]
		var key = c.key()
		_parent[key] = root_key
		_all_cells[key] = c
	return root_key


func make_set(cell) -> void:
	var key = cell.key()
	if _parent.has(key):
		return
	_parent[key] = key
	_comp_size[key] = 1
	_comp_rep[key] = cell
	_all_cells[key] = cell
	_root_count += 1


func union(a, b) -> bool:
	var ra = find(a.key())
	var rb = find(b.key())
	if ra == "" or rb == "":
		return false
	if ra == rb:
		return false
	if _comp_size[ra] < _comp_size[rb]:
		var tmp = ra
		ra = rb
		rb = tmp
	_parent[rb] = ra
	_comp_size[ra] += _comp_size[rb]
	_root_count -= 1
	return true


func comp_size_of(key: String) -> int:
	var r = find(key)
	if r == "":
		return 0
	return _comp_size[r]


func rep_of(key: String):
	var r = find(key)
	if r == "":
		return null
	return _comp_rep[r]


func roots() -> Array:
	var result: Array = []
	for key in _parent:
		if _parent[key] == key:
			result.append(key)
	return result


func cell_by_key(key: String):
	return _all_cells.get(key, null)
