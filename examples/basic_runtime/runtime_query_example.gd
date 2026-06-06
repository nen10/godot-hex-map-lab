class_name HexRuntimeQueryExample
extends Node

const HexRuntimeQuerySample = preload("res://examples/basic_runtime/runtime_query_sample.gd")
const HexMovementProfileResource = preload("res://addons/hex_map_kit/adapter/hex_movement_profile_resource.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")

@export_file("*.tres") var document_path: String = ""
@export var movement_budget: float = 4.0

var last_query_result: Dictionary = {}


func run_example(path: String = "") -> Dictionary:
	var target_path = path if path != "" else document_path
	var profile = HexMovementProfileResource.new()
	profile.profile_id = "runtime-example"
	profile.wall_passable = true
	profile.wall_cost = 1.0
	last_query_result = HexRuntimeQuerySample.query_document_path(
		target_path,
		HexVector.zero(),
		HexVector.q_axis(),
		movement_budget,
		profile
	)
	return last_query_result


func reset_result() -> void:
	last_query_result = {}

