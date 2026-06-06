# Editor Workflow Example

This example shows the authoring-side handoff without depending on editor plugin classes at runtime.

`editor_workflow_example.gd` builds a small `HexMapDocumentResource` v2 document with:

- terrain layer and catalog floor/wall keys,
- overlay tile assignment,
- object placement,
- label placement,
- dependency metadata for the sample catalog,
- standard authoring layer stack role names.

The sample is meant to mirror the Generate/Edit/Validate workflow output: save or construct a v2 document, validate it, then pass the saved path to `examples/basic_runtime/runtime_query_example.tscn` or `runtime_query_sample.gd`.

