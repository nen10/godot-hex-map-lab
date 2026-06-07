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

For production authoring, prepare project assets in the workspace:

- a saved `HexMapDocumentResource`
- a project `HexTileCatalogResource`
- a project `TileSet`
- project Object and Label databases
- project Validation Rule Suite and Generation Profile resources
- an explicit export destination

For display, prepare a `TileMapLayer` or `HexTileMapLayer` with a project hex `TileSet`.

Bundled learning samples are available in Settings / Samples:

```text
res://addons/hex_map_kit/assets/sample_hex_tiles.png
res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres
```

The sample catalog owns its `TileSet` resource and its scene-tile entry references a package-contained `PackedScene`. Duplicate the sample catalog to a project path before adapting it for production.

Sample onboarding path:

1. In a new workspace, `Learn with bundled samples` opens Settings / Samples.
2. Sample mode starts OFF, so main screens stay focused on project asset selection.
3. `Show bundled samples in asset selectors` reveals learning candidates without replacing selected project assets.
4. `Duplicate sample catalog to project` creates project-owned copies of the catalog, tile texture, and object scene dependencies.
5. After duplication, use the project copy in Catalog/Paint/Generate like any other project asset.

More setup details: `docs/manual/MANUAL_SETUP.md`.

## 2. Use The Editor By Goal

Open **Hex Map Workspace** and work from the authoring goal:

- Document: create, open, save, save as, validate, and export a `HexMapDocumentResource`.
- Generate: choose generator shape, seed, catalog keys, target, orientation, and tile size.
- QA: run Seed Lab batch comparison and promote a selected seed to a document.
- Catalog: select a `HexTileCatalogResource`, catalog `TileSet`, and scene-entry `PackedScene`; validate catalog status.
- Paint: edit terrain, floor tile keys, wall tile keys, objects, and labels in the viewport.
- Layers: create missing role layers and apply the document through a `HexTileMapLayer` layer stack.
- Validate: inspect domain/severity grouped issues, focus cells/resources/catalog entries, and read fix suggestions.
- Settings: learn with bundled samples or duplicate sample assets into project-owned resources.
- Support: use `Copy Debug Report` when a compact status row is not enough.

Normal editor selection uses Resource pickers and FileDialogs. Saved paths may be displayed as read-only status, but path text is not the primary input workflow.

Project asset first pass:

1. Create or select the Level Document in `Document`.
2. Create or select the Tile Catalog and assign its TileSet in `Catalog`.
3. Create or select Object and Label databases in `Paint`.
4. Create or select Validation Rule Suite and Generation Profile resources in `Validate` and `QA`.
5. Choose an Export Profile and destination in `Export`.

Sample onboarding is optional and separate from this first pass. Use it to inspect or duplicate bundled assets, then return to project asset slots for production work.

## 3. Author A Level Document

Use `HexMapDocumentResource` for maps that need terrain, overlay, objects, labels, zones, metadata, and dependencies in one resource.

Script construction starts with:

```gdscript
var document = HexMapDocumentResource.new()
```

Typical authoring fields:

- `terrain_layers`: primary map and terrain tile assignments.
- `overlay_layers`: generated/user item overlays.
- `object_placements`: object ids, cells, variants, runtime properties, spawn conditions.
- `label_placements`: text labels attached to cells.
- `metadata`: document id, display name, generation seed/snapshot, custom properties.
- `dependencies`: resource references for catalogs, object databases, label databases, TileSets, scripts, or scenes.

The public editor workflow sample builds a small canonical document:

```gdscript
const HexEditorWorkflowExample = preload("res://examples/editor_workflow/editor_workflow_example.gd")

var document = HexEditorWorkflowExample.build_authoring_document()
var info = HexEditorWorkflowExample.workflow_summary(document)
```

## 4. Use Catalog Keys

Use catalog keys instead of raw `source_id` / `atlas_coords` in normal authoring flows.

Example catalog keys:

- `terrain.floor`
- `terrain.wall`
- `overlay.treasure`
- `object.spawn_marker`

Catalog-backed terrain layers can set defaults:

```gdscript
terrain_layer.default_floor_key = "terrain.floor"
terrain_layer.default_wall_key = "terrain.wall"
```

Individual payloads can also carry `catalog_key`. Missing catalog assignments are validation issues; document apply does not silently substitute numeric tiles.

In the editor, use `Catalog Resource`, `TileSet`, `Scene Entry Resource`, `Add Atlas Entry`, `Add Scene Entry`, and `Validate Catalog`. Paint and Generate controls then choose catalog keys rather than tile coordinates.

## 5. Use A Layer Stack

`HexLayerStackResource.standard_template()` defines authoring roles:

- terrain
- decoration
- object
- collision
- navigation
- overlay
- debug

Use a layer stack when applying one document to multiple child layers. Use the single-layer path only for simple scenes or advanced debugging.

```gdscript
var stack = HexLayerStackResource.standard_template()
hex_tile_map_layer.apply_document_to_layer_stack(document, stack)
```

In the editor, use `Create Missing Layers`, `Apply Document`, and `Clear Role` with a `HexTileMapLayer` target.

## 6. Place Runtime Objects

Object authoring uses a typed object database:

- `Object DB`: `HexObjectDatabaseResource`.
- definition list: object key selection.
- `Definition Scene`: `PackedScene` reference.
- `Placement Properties`: typed bool, number, string, and enum controls.

Script-side runtime export is covered in section 9.

## 7. Validate Before Runtime Handoff

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

In the editor, use the validation dashboard for domain/severity rows, focus targets, and fix suggestions. Use `Copy Debug Report` for support reports that need target status, last edit, save/export status, validation summary, and raw details.

## 8. Runtime Query

Pass a canonical document Resource to runtime query helpers:

```gdscript
const HexRuntimeQuerySample = preload("res://examples/basic_runtime/runtime_query_sample.gd")
const HexMovementProfileResource = preload("res://addons/hex_map_kit/adapter/hex_movement_profile_resource.gd")
const HexVector = preload("res://addons/hex_map_kit/core/hex_vector.gd")
const HexEditorWorkflowExample = preload("res://examples/editor_workflow/editor_workflow_example.gd")

var profile = HexMovementProfileResource.new()
profile.profile_id = "player"
profile.wall_passable = false
var document = HexEditorWorkflowExample.build_authoring_document()

var result = HexRuntimeQuerySample.query_document(
	document,
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

When runtime code needs to load a saved resource first, use `HexRuntimeQuerySample.query_document_path()` or the path helper on the scene wrapper.

For a scene wrapper, open:

```text
res://examples/basic_runtime/runtime_query_example.tscn
```

## 9. Runtime Object Export

Use runtime object export when gameplay code should instantiate objects without mutating authoring placements.

```gdscript
var export = HexRuntimeQuerySample.export_runtime_objects(document, object_database)
for item in export["runtime_objects"]:
	print(item["object_id"], item["scene"], item["properties"])
```

The returned dictionaries are copies. Runtime-only changes do not write back into `document.object_placements`.

## 10. Reference

- API surface: `docs/api/API_REFERENCE.md`
- Runtime example: `examples/basic_runtime/`
- Editor workflow example: `examples/editor_workflow/`
- Scripting basics: `docs/manual/MANUAL_SCRIPTING.md`
- Editor operation details: `docs/manual/MANUAL_EDITOR_PLUGIN.md`
