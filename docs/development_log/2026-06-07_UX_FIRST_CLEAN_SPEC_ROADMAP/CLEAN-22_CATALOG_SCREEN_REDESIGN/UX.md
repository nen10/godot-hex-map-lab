# CLEAN-22 Catalog Screen Redesign UX

## Goal

Catalog editing should present the tile catalog as the source of paintable keys. Normal painting selects a catalog key; atlas source details and scene resources are edited in the catalog area.

Primary controls:

```text
Catalog Resource: [ResourcePicker]
TileSet: [ResourcePicker]

Entries:
key                 type    preview    tags              status
terrain.floor       atlas   [tile]     terrain,floor     ok
terrain.wall        atlas   [tile]     terrain,wall      ok
object.spawn        scene   [scene]    object,spawn      ok

[Add Atlas Entry] [Add Scene Entry] [Validate Catalog]
```

## User Contract

- Catalog resource selection uses a typed resource picker when the editor supports it.
- Catalog TileSet selection uses a typed `TileSet` picker and updates the catalog resource.
- Entries show key, type, preview, tags, and validation status.
- Scene entries are created from a `PackedScene` picker, not a path string.
- Validation issues are visible in catalog entry status.
- Floor, wall, overlay, and object paint controls choose catalog keys in normal UI.
- `source_id`, `atlas_coords`, and `alternative_tile` are catalog-entry details, not normal paint controls.

## Non-Goals

- CLEAN-23 owns the object database palette and type-aware object property editor.
- CLEAN-26 owns the broader validation dashboard refinement.
- CLEAN-33 owns deletion of any remaining harmful UI paths outside this catalog-key paint workflow.
