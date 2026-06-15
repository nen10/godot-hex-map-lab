# Workflow Manual

This page connects setup, Build graph authoring, Paint finishing, runtime handoff, examples, and runtime use for Hex Map Kit.

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

- a selected `HexTileMapLayer` scene node, or a Build-created `HexTileMapLayer`
- a saved `HexMapDocumentResource`
- a project `HexTileCatalogResource`
- a project `TileSet`
- project Object and Label databases
- a project Layer Stack and optional Movement Profile
- project `HexValidationRuleSuiteResource` and `HexGenerationProfileResource` assets
- a project `HexExportProfileResource` and explicit Runtime Handoff destination

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
5. After duplication, use the project copy in Catalog/Build/Paint like any other project asset.

More setup details: `docs/manual/MANUAL_SETUP.md`.

## 2. Build, Paint, Export By Goal

Open **Hex Map Workspace** and work from the production path:

```text
Build graph -> Promote layer -> Paint -> Export handoff
```

The workspace screens support that route:

1. `Build`: author and run a generation graph, inspect intermediate output, and promote useful output into the Level Document.
2. `Paint`: finish the generated map with brush-driven document edits.
3. `Export`: hand off the map to Godot runtime as a data resource, scene, or graph resource.
4. `Catalog`: maintain the tile/object vocabulary used by Build and Paint.
5. `Layers`: review role layers, visibility, lock state, and writable source boundaries.
6. `Resources`: manage selected map bindings and project asset shelves.
7. `Settings`: use samples for learning and debug/report controls.
8. `Validate` / `QA`: support issue review or seed comparison when useful; they are not the main production route.

Recommended workspace pass:

1. Select a `HexTileMapLayer` in the Scene tree, or start from Build when a graph needs a new self-contained map layer. Build can create the missing Level Document / embedded graph context instead of leaving the run path blocked by resource references.
2. In `Build`, choose Simple Build for an on-ramp or open the graph canvas for the full pipeline. Connect generation passes such as Shape, Wall, Connectivity, Region Filter, Item Generator, and Promote.
3. Press `Generate` for the current graph. Use the preview and selected node output to inspect terrain, selection, overlay, or result data.
4. Promote the output that should become real map content. Promote writes by role into the Level Document and respects layer writable source boundaries so generated layers and hand-painted document layers can coexist.
5. In `Paint`, use the brush palette, active layer, selected cell, and catalog/object keys to finish or correct the map by hand.
6. Use `Catalog`, `Layers`, and `Resources` only when the current step needs vocabulary, role structure, or project asset bindings.
7. In `Export`, choose the handoff purpose: runtime data resource, runtime scene, or generation graph resource for runtime Map Build API.

Support shelf responsibilities:

- `Resources`: selected `HexTileMapLayer`, Level Document, graph resource, catalog, object database, label database, layer stack, movement profile, validation profile, generation profile, and export profile bindings.
- `Catalog`: catalog key vocabulary, TileSet binding, tile previews, and scene entry resources. Normal Build/Paint flows use catalog keys instead of raw `source_id` / `atlas_coords`.
- `Layers`: terrain, overlay, object, collision, navigation, and debug role layers, including writable source (`generated`, `document`, `target`, or `readonly`).
- `Validate`: issue review and focus actions. Use it as a support lens before runtime handoff, not as the center of the workflow.
- `QA`: seed comparison and selected-seed preview when comparing alternatives. Graph-based regeneration is the primary control surface.

Sample/debug/process boundaries:

- Samples are learning/onboarding assets and are not silent production defaults.
- `Export` is runtime handoff, not package build output.
- Package artifacts are developer process outputs from `tools/package_addon.sh`.
- Debug overlay rendering is separate from normal gameplay rendering and is driven by Validate/debug-report flow.
- Normal editor selection uses Resource pickers and FileDialogs. Saved paths may be displayed as read-only status, but path text is not the primary input workflow.

`Resources` auto-links the selected `HexTileMapLayer` while auto-link is on. If no node is selected, the tab keeps production asset selection visible instead of filling the workspace with samples.

The selected Level Document is the canonical authoring source. `HexTileMapLayer.hex_map` is runtime/display snapshot data for preview, target import, or Runtime Handoff output; it does not replace the Level Document as the map you save, validate, or continue editing.

Fallback, mirror/debug/sample/manual override rules are tracked in [`docs/review/roadmap/FALLBACK_LEDGER_2026-06-10.md`](docs/review/roadmap/FALLBACK_LEDGER_2026-06-10.md), including owner and removal condition for each tracked decision.

Resource shelves show ownership through source badges:

| Badge | Meaning | Normal action |
|---|---|---|
| `Node` | The selected `HexTileMapLayer` owns the relationship. | Create or select it in `Resources`; auto-link writes it back while enabled. |
| `Project` | A project resource was selected explicitly. | Use it as the production source. |
| `Document Dependency` | The selected Level Document hydrated this shared dependency. | Keep it when the document already owns the relationship. |
| `Manual Override` | The workspace selection intentionally overrides the document dependency. | Use it for the current session, then write it back if it should become canonical. |
| `Sample Learning` | A bundled sample asset is visible for learning. | Duplicate it into project files before adapting it. |
| `Missing` | No resource is selected. | Create or select a project asset, or leave optional resources missing. |

Build output target:

1. Use graph preview to inspect intermediate output while leaving the selected Level Document unchanged.
2. Use Promote nodes or promote actions when a generated terrain/overlay/object output should become canonical document content.
3. If no `HexTileMapLayer`, Level Document, graph, or generated preview is available, Build shows the missing context or creates the missing context instead of relying on hidden sample defaults.

QA Seed Lab promotion follows the same ownership model when used as a support flow: promoted seeds update the project Level Document relationship in `Resources` and remain unsaved until the document save workflow writes the resource.

Profile assets are concrete project resources: `HexValidationRuleSuiteResource` stores validation rule enablement and severity policy, `HexGenerationProfileResource` stores generator defaults and parameters, and `HexExportProfileResource` stores Runtime Handoff output options.

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

In the editor, create or select the Level Document from `Resources`, or let Build create the missing context for a graph run. With auto-link on, selecting or creating the Level Document writes the resource relationship back to the selected `HexTileMapLayer`; shared project resources write to that document's dependencies and hydrate back into the Workspace context for Build, Paint, and Export support flows.

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

In the editor, use `Catalog Resource`, `TileSet`, `Scene Entry Resource`, `Add Atlas Entry`, `Add Scene Entry`, and `Validate Catalog`. Build and Paint controls then choose catalog keys rather than tile coordinates.

## 5. Use A Layer Stack

`HexLayerStackResource.standard_template()` defines authoring roles:

- terrain
- decoration
- object
- collision
- navigation
- overlay
- debug

Use a layer stack when applying one document to multiple child layers. Build Promote writes generated output into role-aware document layers; Paint writes hand-authored document intent. Use the single-layer path only for simple scenes or advanced debugging.

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

Script-side runtime object export is covered in section 10.

## 7. Use Validate As A Support Lens

Use validation when the map needs issue review before runtime handoff. Validation is a support lens for the Build/Paint/Export route, not the center of the workflow.

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

## 8. Create Runtime Handoff

Use the editor `Export` tab when runtime code needs a handoff generated from the current Level Document or generation graph.

The current Export tab presents three handoff purposes:

1. `Runtime Map Resource`: write a runtime-friendly `HexMapResource`.
2. `Runtime Scene`: write a scene containing the runtime layer node tree.
3. `Generation Graph`: save a graph resource that runtime code can execute through the runtime Map Build API.

Common handoff steps:

1. Confirm the current Level Document or graph context.
2. Optionally select a `HexExportProfileResource`.
3. Choose an explicit destination with the FileDialog.
4. Run the selected handoff action.

This workflow is not Save Document. Authoring saves keep the `HexMapDocumentResource`. It is also not Package Build or Debug Report; package artifacts are process-only (`tools/package_addon.sh`, `docs/manual/MANUAL_PACKAGE.md`) and debug reports are support/diagnostic text.

Debug overlay rendering is separate from normal gameplay rendering and is driven through the Validate/debug-report path.

## 9. Runtime Query

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

## 10. Runtime Object Export

Use script-side runtime object export when gameplay code should instantiate objects without mutating authoring placements. This API helper is separate from the editor `Export` tab's Runtime Handoff workflow.

```gdscript
var export = HexRuntimeQuerySample.export_runtime_objects(document, object_database)
for item in export["runtime_objects"]:
	print(item["object_id"], item["scene"], item["properties"])
```

The returned dictionaries are copies. Runtime-only changes do not write back into `document.object_placements`.

## 11. Reference

- API surface: `docs/api/API_REFERENCE.md`
- Runtime example: `examples/basic_runtime/`
- Editor workflow example: `examples/editor_workflow/`
- Scripting basics: `docs/manual/MANUAL_SCRIPTING.md`
- Editor operation details: `docs/manual/MANUAL_EDITOR_PLUGIN.md`
