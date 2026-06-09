@tool
class_name HexExportProfileResource
extends Resource

@export var profile_id: String = "project_export"
@export var display_name: String = "Project Export Profile"
@export var output_type: String = "runtime_handoff_resource"
@export var include_debug_report: bool = false
@export var options: Dictionary = {}
@export var metadata: Dictionary = {}


func option_value(key: String, default_value: Variant = null) -> Variant:
	if key == "":
		return default_value
	return options.get(key, default_value)
