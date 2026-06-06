@tool
class_name HexLayerStackResource
extends Resource

const HexLayerStackEntryResourceScript = preload("res://addons/hex_map_kit/adapter/hex_layer_stack_entry_resource.gd")

const ROLE_TERRAIN := "terrain"
const ROLE_DECORATION := "decoration"
const ROLE_OBJECT := "object"
const ROLE_COLLISION := "collision"
const ROLE_NAVIGATION := "navigation"
const ROLE_OVERLAY := "overlay"
const ROLE_DEBUG := "debug"

@export var stack_id: String = ""
@export var display_name: String = ""
@export var layers: Array[Resource] = []
@export var metadata: Dictionary = {}


static func standard_role_names() -> PackedStringArray:
	return PackedStringArray([
		ROLE_TERRAIN,
		ROLE_DECORATION,
		ROLE_OBJECT,
		ROLE_COLLISION,
		ROLE_NAVIGATION,
		ROLE_OVERLAY,
		ROLE_DEBUG,
	])


static func standard_template():
	var stack = load("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd").new()
	stack.stack_id = "standard_authoring"
	stack.display_name = "Standard Authoring Layer Stack"
	var template_layers: Array[Resource] = []
	template_layers.append(_entry("terrain", "Terrain", ROLE_TERRAIN, "TerrainTileMapLayer", 0, 0))
	template_layers.append(_entry("decoration", "Decoration", ROLE_DECORATION, "DecorationTileMapLayer", 10, 10))
	template_layers.append(_entry("object", "Objects", ROLE_OBJECT, "ObjectTileMapLayer", 20, 20))
	template_layers.append(_entry("collision", "Collision", ROLE_COLLISION, "CollisionTileMapLayer", 30, 30, false))
	template_layers.append(_entry("navigation", "Navigation", ROLE_NAVIGATION, "NavigationTileMapLayer", 40, 40, false))
	template_layers.append(_entry("overlay", "Overlay", ROLE_OVERLAY, "OverlayTileMapLayer", 50, 50))
	template_layers.append(_entry("debug", "Debug", ROLE_DEBUG, "DebugOverlayLayer", 100, 100))
	stack.layers = template_layers
	return stack


static func minimal_runtime_template():
	var stack = load("res://addons/hex_map_kit/adapter/hex_layer_stack_resource.gd").new()
	stack.stack_id = "minimal_runtime"
	stack.display_name = "Minimal Runtime Layer Stack"
	var template_layers: Array[Resource] = []
	template_layers.append(_entry("terrain", "Terrain", ROLE_TERRAIN, "TileMapLayer", 0, 0))
	template_layers.append(_entry("overlay", "Overlay", ROLE_OVERLAY, "OverlayTileMapLayer", 50, 50))
	template_layers.append(_entry("debug", "Debug", ROLE_DEBUG, "OverlayLayer", 100, 100))
	stack.layers = template_layers
	return stack


func add_layer(layer: HexLayerStackEntryResourceScript) -> void:
	if layer != null:
		layers.append(layer)


func role_names() -> PackedStringArray:
	var result := PackedStringArray()
	for layer in sorted_layers():
		var role = String(layer.get("role"))
		if role != "" and not result.has(role):
			result.append(role)
	return result


func layer_ids() -> PackedStringArray:
	var result := PackedStringArray()
	for layer in sorted_layers():
		var layer_id = String(layer.get("layer_id"))
		if layer_id != "":
			result.append(layer_id)
	return result


func node_names() -> PackedStringArray:
	var result := PackedStringArray()
	for layer in sorted_layers():
		var node_name = String(layer.get("node_name"))
		if node_name != "":
			result.append(node_name)
	return result


func has_role(role: String) -> bool:
	return first_layer_for_role(role) != null


func first_layer_for_role(role: String):
	for layer in sorted_layers():
		if String(layer.get("role")) == role:
			return layer
	return null


func layers_for_role(role: String) -> Array[Resource]:
	var result: Array[Resource] = []
	for layer in sorted_layers():
		if String(layer.get("role")) == role:
			result.append(layer)
	return result


func sorted_layers() -> Array[Resource]:
	var result: Array[Resource] = []
	for layer in layers:
		if layer != null:
			result.append(layer)
	result.sort_custom(_compare_layers)
	return result


static func _entry(
	layer_id: String,
	display_name: String,
	role: String,
	node_name: String,
	order: int,
	z_index: int,
	visible: bool = true
):
	var layer = HexLayerStackEntryResourceScript.new()
	layer.layer_id = layer_id
	layer.display_name = display_name
	layer.role = role
	layer.node_name = node_name
	layer.order = order
	layer.z_index = z_index
	layer.visible = visible
	return layer


static func _compare_layers(left, right) -> bool:
	var left_order = int(left.get("order"))
	var right_order = int(right.get("order"))
	if left_order != right_order:
		return left_order < right_order
	return String(left.get("layer_id")) < String(right.get("layer_id"))
