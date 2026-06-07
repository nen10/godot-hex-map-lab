# Basic Runtime Query Sample

`runtime_query_sample.gd` shows a runtime-safe way to query a `HexMapDocumentResource`:

```gdscript
var profile = HexMovementProfileResource.new()
profile.wall_passable = true
var document = HexEditorWorkflowExample.build_authoring_document()
var result = HexRuntimeQuerySample.query_document(
	document,
	HexVector.zero(),
	HexVector.q_axis(),
	4.0,
	profile
)
print(result["path_count"])
print(result["range_count"])
```

The sample uses core/adapter scripts only and does not depend on editor plugin classes.

Use `HexRuntimeQuerySample.query_document_path()` only when runtime code needs to load a saved document path first.

`runtime_query_example.tscn` wraps the same helper as a minimal scene. Set `document` to a `HexMapDocumentResource`, then call `run_example()` from gameplay code or tests to populate `last_query_result`. `document_path` and `run_path_example()` remain available as saved-resource load helpers.

For object placements, `HexRuntimeQuerySample.export_runtime_objects(document, object_database)` returns copied runtime dictionaries with resolved `scene` `PackedScene` resources, rotation, variant, properties, and spawn condition. The helper does not mutate authoring `object_placements`; runtime code can instantiate from the returned data while the document remains an editor/source-of-truth resource.
