# Editor Plugin Manual

Hex Map Kit provides one editor workspace for authoring, generating, validating, and creating runtime handoffs from hex-map level documents.

This manual describes user workflows. For API details, use `docs/api/API_REFERENCE.md`. For end-to-end authoring and runtime handoff, use `docs/manual/MANUAL_WORKFLOW.md`.

## 1. Enable The Addon

Confirm that `project.godot` enables the plugin:

```ini
[editor_plugins]
enabled=PackedStringArray("res://addons/hex_map_kit/plugin.cfg")
```

After Godot starts, the editor shows the **Hex Map Workspace** dock. The workspace uses these task tabs:

- `Resources`
- `Generate`
- `Paint`
- `Catalog`
- `Layers`
- `Validate`
- `QA`
- `Export`
- `Settings`

The tab names are the stable task map for the editor UI. Production work starts with a selected scene node and project asset slots, not bundled samples:

1. Select the target `HexTileMap` in the Scene tree. The Workspace auto-links the selected node by default.
2. In `Resources`, create or select a project `HexMapDocumentResource`, Layer Stack, Object Database, Label Database, and optional Movement Profile. Use `Create Missing Resources` for missing node-owned unique resources.
3. In `Catalog`, create or select a project `HexTileCatalogResource`, then select its `TileSet` and optional scene-entry `PackedScene` resources.
4. In `Generate`, choose whether the generated result is `Preview only` or should be applied to the selected document.
5. In `Paint`, choose terrain/object/label brushes from the project resources already selected in `Resources` and `Catalog`.
6. In `Layers`, inspect the selected `HexTileMap`, create role layers, and apply the document by role.
7. In `Validate` and `QA`, inspect issues, compare seeds, and promote a selected result to the project Level Document.
8. In `Export`, select a project `HexExportProfileResource` and choose an explicit Runtime Handoff destination with the FileDialog.
9. In `Settings`, use Samples only for learning or duplicating bundled assets into project-owned resources.

## 2. Manage Resources And Level Document

Use `Resources` when a map needs terrain, overlays, objects, labels, zones, metadata, dependencies, and runtime handoff in one Level Document relationship.

The normal Resources workflow:

- Select a `HexTileMap` in the Scene tree. The Resources context shows the selected node, `Auto-link: On`, or `No HexTileMap selected`.
- Use `Level Document` to create or select a project `HexMapDocumentResource` with the Resource picker and `Create New...` FileDialog.
- Use `Layer Stack` for the selected node's role-layer resource.
- Use `Object Database`, `Label Database`, and `Movement Profile` for shared or optional authoring data.
- Use `Create Missing Resources` to create missing node-owned unique resources at a chosen project folder and prefix.
- Leave shared project resources unselected until the project has real assets; missing states route to `Resources`, `Catalog`, or validation rows instead of silently loading samples.

Selecting or creating node-owned resources writes back to the selected `HexTileMap` while auto-link is on. Shared resources stay in the Workspace asset context and are reused by Generate, Paint, Validate, QA, and Export according to their task.

The saved resource path is shown as read-only status. Do not use editable `res://...` text as the normal document workflow.

Use the `Export` tab's Runtime Handoff workflow when producing a runtime-oriented `HexMapResource`; it is separate from saving the authoring `HexMapDocumentResource`.

## 3. Generate A Map

The `Generate` task builds primary terrain or overlay data from explicit parameters. Changing a parameter does not regenerate the map; press `Generate` to run the current settings.

Common generation controls:

- `Generator`: `Simple` or `Hex-inward Markov mesh model`.
- `Shape`: hexagon, rectangle, square, or torus depending on the generator.
- `Wall Prob`: wall probability from `0.00` to `1.00`.
- `Seed`: deterministic generation seed.
- `Rand`: replace the seed.
- `Restore Connectivity`: reconnect floor regions after generation.

For display, choose a `Target`, orientation, tile size, and catalog keys:

| Setting | Purpose |
|---|---|
| `Target` | Auto-selected or explicit `TileMapLayer` / `HexTileMapLayer` target |
| `Orientation` | `flat-top / Vertical Offset` or `pointy-top / Horizontal Offset` |
| `Tile Size` | TileSet tile size |
| `Floor Catalog` | catalog key used for floor display |
| `Wall Catalog` | catalog key used for wall display |
| `Apply Write` | clear target first or add generated cells over existing cells |

Generation normally auto-applies to the target layer. Numeric source and atlas controls are not part of normal authoring; catalog entries and the target `TileSet` own those details.

Use `Output target` to decide what happens to the generated result:

- `Preview only`: updates the target display and keeps the selected Level Document unchanged.
- `Apply to selected Document`: enables `Apply to Document` when a `HexTileMap`, Level Document, and generated preview are available. Applying copies the generated document state into the selected node's Level Document and records generation metadata.

If no `HexTileMap` is selected, or the selected node has no Level Document, the apply path stays blocked with a visible reason.

## 4. Compare Seeds In QA

Use the Seed Lab workflow when the map shape and rules are known but the seed needs comparison.

1. Set generation parameters in `Generate`.
2. In `Seed Lab`, choose the seed count.
3. Press `Run Batch`.
4. Compare the score table by rank, seed, score, status, cells, and validation summary.
5. Select a row to update the selected seed preview.
6. Press `Promote to Document` to create a canonical document from that seed.

After promotion, Seed Lab status shows Dirty state and `generation_seed` metadata. Promotion does not silently save; use the document save workflow.

## 5. Use A Tile Catalog

Use catalog keys instead of raw tile source numbers in normal authoring.

Catalog setup:

- `Catalog Resource`: create or select a project `HexTileCatalogResource`.
- `TileSet`: select an arbitrary project TileSet resource for the catalog.
- `Scene Entry Resource`: select a project `PackedScene` for scene-tile entries.
- `Add Atlas Entry`: add an atlas tile entry to the catalog.
- `Add Scene Entry`: add a scene entry that references the selected `PackedScene`.
- `Validate Catalog`: show missing TileSet, missing source, invalid atlas coords, missing scene, and tag/status issues.

The catalog entry list shows key, type, preview, tags, and status. Paint and generation controls select catalog keys such as `terrain.floor`, `terrain.wall`, or `overlay.treasure`. `source_id` and `atlas_coords` are catalog-entry internals, not normal paint inputs.

## 6. Paint Terrain, Objects, And Labels

Choose a target layer, then use `Edit Mode` for the authoring intent:

- `Shape`: create or remove canonical document cells.
- `Wall / Floor`: toggle terrain occupancy.
- `Floor Tile`: assign a floor catalog key.
- `Wall Tile`: assign a wall catalog key.
- `Object`: place object definitions by object key.
- `Label`: place text labels by label key.

Viewport edits update the document and target display together. Undo / Redo should restore both document state and visible tiles.

### Object Placement

Object mode uses typed resources:

- `Object DB`: create or select a project `HexObjectDatabaseResource`.
- definition list: choose the object key to place.
- `Definition Scene`: select the definition project `PackedScene`.
- `Placement Properties`: edit bool, number, string, and enum values through typed controls.

Normal object placement does not use raw `object_id` text or raw JSON property editing.

### Labels

Label mode uses the selected label database and label key. Label placement belongs to the document and can be validated with the same validation dashboard as terrain and objects.

## 7. Manage A Layer Stack

Use `Layer Stack` when one document should apply into multiple role-specific layers.

Typical workflow:

1. Choose `Standard Authoring` or `Minimal Runtime` template.
2. Review each role, node name, visible state, locked state, z-index, and writable source.
3. Select a `HexTileMapLayer` target.
4. Press `Create Missing Layers` to add absent role layers.
5. Press `Apply Document` to apply the current document by role.
6. Press `Clear Role` to clear the selected role layer.

The normal layer stack workflow targets `HexTileMapLayer`. Plain `TileMapLayer` direct apply is an advanced/debug route, not the primary authoring path.

## 8. Validate And Focus Issues

Use `Validate` before treating a document as runtime-ready.

Validation rows are grouped by domain and severity:

- domains: Document, Catalog, Layer, Object, Gameplay, Package
- severities: Error, Warning, Info

Selecting an issue shows:

- focus target, such as a cell, catalog entry, dependency, or resource
- fix suggestion
- issue details needed for support or debugging

Cell issues can focus the target cell. Catalog issues can focus catalog entries. Resource issues point back to the relevant dependency or selected resource.

## 9. Create A Runtime Handoff

Use `Export` when gameplay/runtime code needs a `HexMapResource` created from the current Level Document.

Current Export tab terms:

- `Runtime Handoff Resource`: active output type.
- `Current Level Document`: source.
- `HexMapResource`: target resource class.
- `Export Profile`: optional `HexExportProfileResource` project resource for handoff settings.
- destination: explicit FileDialog path chosen by the user.

The Export tab does not save the authoring document. Use Resources/document save actions for `HexMapDocumentResource` persistence. Package Build is a developer process (`tools/package_addon.sh`), and Debug Report is a support/diagnostic action.

## 10. Copy A Debug Report

Use `Copy Debug Report` when reporting an authoring or validation problem.

The report includes:

- target status
- last edit details
- save/export details
- validation summary
- raw status needed for support

Normal authoring should use concise status and validation rows. The debug report is for support, not for everyday editing, and is not an Export tab output.

## 11. Use Samples For Learning

Bundled samples are learning assets. Open `Settings` / Samples to inspect them or duplicate the sample catalog into project-owned files before adapting it.

First-run onboarding:

1. Press `Learn with bundled samples` to open `Settings`.
2. Keep sample mode OFF when starting a production project from empty project assets.
3. Enable `Show bundled samples in asset selectors` when you want learning candidates visible in main selectors.
4. Use `Duplicate sample catalog to project` before editing the sample catalog, TileSet texture, or object scene for production.

Sample mode ON does not override selected project assets. Generate and Paint do not use bundled samples as production fallbacks; duplicate a sample to a project path before adapting it.

The included sample atlas is:

```text
res://addons/hex_map_kit/assets/sample_hex_tiles.png
```

The sample catalog and object scene are:

```text
res://addons/hex_map_kit/assets/sample_hex_tile_catalog.tres
res://addons/hex_map_kit/assets/sample_spawn_marker.tscn
```

The sample setup uses:

- source id `0`
- floor atlas coords `Vector2i(0, 0)`
- wall atlas coords `Vector2i(1, 0)`
- tile size `64 x 57`

These numeric values are sample asset details. Normal workflow should still select catalog keys for generated, painted, and overlay tiles.

`Use Sample Tiles` is a quick learning/debug action, not normal production setup. For production, use the Catalog tab to select a project Tile Catalog and TileSet, or duplicate the bundled sample catalog to a project path and then edit the project copy.

Use `Browse Atlas Image` or the target TileSet/Atlas browser when preparing a target `TileSet`. Target status reports TileSet path, source count, tile size, floor/wall/overlay payload, and overlay visibility.

## 12. Distribution Editor

For symmetric generation, use `Dist` to choose a preset. Press `Edit` to open Distribution Editor.

Distribution Editor actions:

- `Load .tres`: load a `HexDistribution` resource.
- `Save New...`: save current values to a new resource.
- `Apply`: save the current resource and apply it to Generate.
- `Duplicate Preset...`: copy a preset into a custom editable resource.

Distribution values are generator weights from `0.0` to `8.0`; probability is `value / 8.0`.

## 13. Reference

- Workflow: `docs/manual/MANUAL_WORKFLOW.md`
- Scripting: `docs/manual/MANUAL_SCRIPTING.md`
- API: `docs/api/API_REFERENCE.md`
- Tests and manual debug notes: `docs/TEST.md`
