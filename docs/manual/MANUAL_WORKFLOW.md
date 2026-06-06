# Workflow Manual

This page connects setup, authoring, validation, examples, and runtime use for Hex Map Kit.

## 1. Setup

Install the addon at:

```text
res://addons/hex_map_kit/
```

Enable it in Godot:

```ini
[editor_plugins]
enabled=PackedStringArray("res://addons/hex_map_kit/plugin.cfg")
```

For display, prepare a `TileMapLayer` or `HexTileMapLayer` with a hex `TileSet`. The included sample atlas and catalog are:

```text
res://addons/hex_map_kit/assets/sample_hex_tiles.png
res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres
```

More setup details: `docs/manual/MANUAL_SETUP.md`.

## 2. Author A Level Document V2

Use `HexMapDocumentResource` v2 for maps that need terrain, overlay, objects, labels, zones, metadata, and dependencies in one resource.

Script construction starts with:

```gdscript
var document = HexMapDocumentResource.new()
document.ensure_v2_defaults()
```

Typical v2 authoring fields:

- `terrain_layers`: primary map and terrain tile assignments.
- `overlay_layers`: generated/user item overlays.
- `object_placements`: object ids, cells, variants, runtime properties, spawn conditions.
- `label_placements`: text labels attached to cells.
- `metadata`: document id, display name, generation seed/snapshot, custom properties.
- `dependencies`: catalog, object database, TileSet, script, or scene dependencies.

The public editor workflow sample builds a small document v2:

```gdscript
const HexEditorWorkflowExample = preload("res://examples/editor_workflow/editor_workflow_example.gd")

var document = HexEditorWorkflowExample.build_authoring_document()
var info = HexEditorWorkflowExample.workflow_summary(document)
```

## 3. Use Catalog Keys

Use catalog keys instead of raw `source_id` / `atlas_coords` in normal authoring flows.

Sample keys:

- `terrain.floor`
- `terrain.wall`
- `overlay.treasure`
- `object.spawn_marker`

Catalog-backed terrain layers can set defaults:

```gdscript
terrain_layer.default_floor_key = "terrain.floor"
terrain_layer.default_wall_key = "terrain.wall"
```

Individual payloads can also carry `catalog_key`. Numeric tile fallback remains useful for compatibility and debugging, but public workflows should prefer catalog keys.

## 4. Use A Layer Stack

`HexLayerStackResource.standard_template()` defines authoring roles:

- terrain
- decoration
- object
- collision
- navigation
- overlay
- debug

Use a layer stack when applying one v2 document to multiple child layers. Use the compatibility single-layer path only for simple scenes or older documents.

```gdscript
var stack = HexLayerStackResource.standard_template()
hex_tile_map_layer.apply_document_to_layer_stack(document, stack)
```

## 5. Validate Before Runtime Handoff

Run validation before treating a document as runtime-ready.

```gdscript
var result = HexMapDocumentValidator.validate_document(document, {
	"tile_catalog": tile_catalog,
	"tile_set": tile_set,
	"object_database": object_database,
})

if result.error_count() > 0:
	print(result.issues)
```

Validation checks include payloads outside the map, orphan objects/labels, missing catalog or tile entries, missing dependencies, objects on walls, missing object scenes, duplicate unique objects, and movement-profile reachability rules.

In the editor, use the validation dashboard and Copy Debug Report paths described in `docs/manual/MANUAL_EDITOR_PLUGIN.md`.

## 6. Runtime Query

Load a saved v2 document path and ask movement/path queries with the basic runtime example:

```gdscript
const HexRuntimeQuerySample = preload("res://examples/basic_runtime/runtime_query_sample.gd")
const HexMovementProfileResource = preload("res://addons/hex_map_kit/adapter/hex_movement_profile_resource.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")

var profile = HexMovementProfileResource.new()
profile.profile_id = "player"
profile.wall_passable = false

var result = HexRuntimeQuerySample.query_document_path(
	"res://maps/level_document.tres",
	HexVector.zero(),
	HexVector.q_axis(),
	4.0,
	profile
)
```

`result` includes:

- `loaded`
- `error`
- `profile_id`
- `start`
- `goal`
- `path`
- `path_count`
- `range`
- `range_count`

For a scene wrapper, open:

```text
res://examples/basic_runtime/runtime_query_example.tscn
```

## 7. Runtime Object Export

Use runtime object export when gameplay code should instantiate objects without mutating authoring placements.

```gdscript
var export = HexRuntimeQuerySample.export_runtime_objects(document, object_database)
for item in export["runtime_objects"]:
	print(item["object_id"], item["scene_path"], item["properties"])
```

The returned dictionaries are copies. Runtime-only changes do not write back into `document.object_placements`.

## 8. Reference

- API surface: `docs/api/API_REFERENCE.md`
- Runtime example: `examples/basic_runtime/`
- Editor workflow example: `examples/editor_workflow/`
- Scripting basics: `docs/manual/MANUAL_SCRIPTING.md`
- Editor operation details: `docs/manual/MANUAL_EDITOR_PLUGIN.md`

