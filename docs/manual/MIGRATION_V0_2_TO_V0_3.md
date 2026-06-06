# Migration Guide: v0.2 To v0.3

This guide covers projects moving from Hex Map Kit `0.2.x` to the `0.3.0` package surface.

## What Changed

v0.3 keeps the existing core generation APIs and adds public workflows around:

- Level Document v2 typed resources,
- catalog-backed tile and object keys,
- layer stack application,
- validation dashboard and validation result schema,
- gameplay movement profiles and runtime query helpers,
- object placement schema and runtime object export,
- package examples and API/manual docs.

## Existing `HexMapResource`

Existing primary map `.tres` resources remain usable.

Recommended migration path:

```gdscript
var document = HexMapDocumentAdapter.from_map_resource(existing_map_resource)
document = HexMapDocumentAdapter.migrate_v1_to_v2(document)
```

After migration, save as `HexMapDocumentResource` v2 when you need terrain layers, overlays, objects, labels, metadata, dependencies, or runtime handoff.

## Existing Documents

Documents using v1 fields such as `map`, `tile_overrides`, `objects`, and `labels` should be migrated through:

```gdscript
var v2_document = HexMapDocumentAdapter.migrate_v1_to_v2(old_document)
```

The migration preserves legacy map data, tile overrides, object entries, label entries, source version metadata, and compatibility fallback paths.

## Tile Assignment

v0.2 workflows often used raw tile data:

```text
source_id
atlas_coords
alternative_tile
```

v0.3 public workflows should prefer catalog keys:

```text
terrain.floor
terrain.wall
overlay.treasure
object.spawn_marker
```

Raw numeric tile fields still exist for compatibility and debugging. For user-facing authoring, set `default_floor_key`, `default_wall_key`, and per-payload `catalog_key` where possible.

## Layer Application

Single `TileMapLayer` application remains available for compatibility. For v0.3 authoring, prefer a `HexTileMapLayer` with a layer stack:

```gdscript
var stack = HexLayerStackResource.standard_template()
hex_tile_map_layer.apply_document_to_layer_stack(v2_document, stack)
```

Use the single-layer path for simple runtime scenes or older documents.

## Validation

Before runtime handoff, run:

```gdscript
var result = HexMapDocumentValidator.validate_document(v2_document, {
	"tile_catalog": tile_catalog,
	"tile_set": tile_set,
	"object_database": object_database,
})
```

Resolve `error` issues before treating a document as release-ready. Warnings can be handled by project policy.

## Runtime Query

For runtime movement/path/range checks, use:

```gdscript
const HexRuntimeQuerySample = preload("res://examples/basic_runtime/runtime_query_sample.gd")

var result = HexRuntimeQuerySample.query_document_path(
	"res://maps/level_document.tres",
	start_hex,
	goal_hex,
	4.0,
	movement_profile
)
```

For object runtime export, use:

```gdscript
var export = HexRuntimeQuerySample.export_runtime_objects(v2_document, object_database)
```

The export result copies authoring properties so runtime changes do not mutate the saved document.

## Package Layout

The v0.3 package zip contains only:

```text
addons/hex_map_kit/
```

Development docs, tests, debug scenes, examples, and tools stay in the source repository. Build and inspect the package with:

```sh
./tools/package_addon.sh
```

Public upload remains a human release check.

