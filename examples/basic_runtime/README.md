# Basic Runtime Query Sample

`runtime_query_sample.gd` shows a runtime-safe way to load a `HexMapDocumentResource` and ask movement queries:

```gdscript
var profile = HexMovementProfileResource.new()
profile.wall_passable = true
var result = HexRuntimeQuerySample.query_document_path(
	"res://path/to/level_document.tres",
	HexVector.zero(),
	HexVector.q_axis(),
	4.0,
	profile
)
print(result["path_count"])
print(result["range_count"])
```

The sample uses core/adapter scripts only and does not depend on editor plugin classes.

`runtime_query_example.tscn` wraps the same helper as a minimal scene. Set `document_path` to a saved v2 document, then call `run_example()` from gameplay code or tests to populate `last_query_result`.

For object placements, `HexRuntimeQuerySample.export_runtime_objects(document, object_database)` returns copied runtime dictionaries with resolved `scene_path`, rotation, variant, properties, and spawn condition. The helper does not mutate authoring `object_placements`; runtime code can instantiate from the returned data while the document remains an editor/source-of-truth resource.
