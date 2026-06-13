@tool
class_name HexExportProfileResource
extends Resource

@export var profile_id: String = "project_export"
@export var display_name: String = "Project Export Profile"
@export var output_type: String = "runtime_handoff_resource"
@export var file_extension: String = ".tres"
@export var include_metadata: bool = true
@export var include_validation_summary: bool = true
@export var include_runtime_queries: bool = true
@export var include_debug_report: bool = false
@export var options: Dictionary = {}
@export var metadata: Dictionary = {}


func option_value(key: String, default_value: Variant = null) -> Variant:
	if key == "":
		return default_value
	return options.get(key, default_value)


func export_options() -> Dictionary:
	return {
		"output_type": output_type,
		"file_extension": file_extension,
		"include_metadata": include_metadata,
		"include_validation_summary": include_validation_summary,
		"include_runtime_queries": include_runtime_queries,
		"include_debug_report": include_debug_report,
		"options": options.duplicate(true),
	}


func behavior_schema() -> Dictionary:
	return {
		"kind": "export_profile",
		"profile_id": profile_id,
		"display_name": display_name,
		"output_type": output_type,
		"file_extension": file_extension,
		"include_metadata": include_metadata,
		"include_validation_summary": include_validation_summary,
		"include_runtime_queries": include_runtime_queries,
		"include_debug_report": include_debug_report,
		"options": options.duplicate(true),
	}
