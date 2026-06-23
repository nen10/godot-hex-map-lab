@tool
class_name HexGenerationResultResource
extends Resource

const HexMapDocumentResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_document_resource.gd")
const HexMapResourceScript = preload("res://addons/hex_map_kit/adapter/hex_map_resource.gd")
const HexOverlayResourceScript = preload("res://addons/hex_map_kit/adapter/hex_overlay_resource.gd")
const HexMapValidationResultScript = preload("res://addons/hex_map_kit/adapter/hex_map_validation_result.gd")

@export var result_id: String = ""
@export var seed: int = 0
@export var status: String = ""
@export var overlay_mode: bool = false
@export var score: float = 0.0
@export var primary_map: HexMapResourceScript
@export var overlay_map: HexOverlayResourceScript
@export var overlay_maps: Array = []
@export var candidate_document: HexMapDocumentResourceScript
@export var validation_result: HexMapValidationResultScript
@export var validation_summary: Dictionary = {}
@export var generation_snapshot: Dictionary = {}
@export var source_snapshot: Dictionary = {}
@export var score_row: Dictionary = {}
@export var preview: Dictionary = {}
@export var metadata: Dictionary = {}


func can_replay() -> bool:
	return candidate_document != null and status == "generated"


func replay_document():
	if not can_replay():
		return null
	return candidate_document.duplicate(true)


func scope_snapshot() -> Dictionary:
	var overlay_count := _overlay_count()
	return {
		"result_id": result_id,
		"seed": seed,
		"status": status,
		"overlay_mode": overlay_mode,
		"score": score,
		"primary_map_present": primary_map != null,
		"overlay_map_present": overlay_map != null,
		"overlay_maps_present": overlay_count > 0,
		"overlay_count": overlay_count,
		"overlay_input_summary": _metadata_array("overlay_inputs"),
		"overlay_conflicts": _metadata_array("overlay_conflicts"),
		"candidate_document_present": candidate_document != null,
		"validation_result_present": validation_result != null,
		"validation_summary": validation_summary.duplicate(true),
		"preview_available": bool(preview.get("available", false)),
		"can_replay": can_replay(),
		"metadata": metadata.duplicate(true),
	}


func to_score_row() -> Dictionary:
	var row := score_row.duplicate(true)
	row["generation_result"] = self
	row["generation_result_id"] = result_id
	row["result_scope"] = scope_snapshot()
	row["replay_available"] = can_replay()
	return row


func _overlay_count() -> int:
	var count := 0
	for overlay in overlay_maps:
		if overlay != null:
			count += 1
	return count


func _metadata_array(key: String) -> Array:
	var value = metadata.get(key, [])
	return value.duplicate(true) if value is Array else []
