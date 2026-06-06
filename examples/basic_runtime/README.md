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
