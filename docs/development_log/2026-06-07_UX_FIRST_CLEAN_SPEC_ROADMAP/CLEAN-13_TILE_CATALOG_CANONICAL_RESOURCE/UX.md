# CLEAN-13 UX Notes

## Goal

Tile catalogs are the asset identity surface for terrain, overlay, and scene-tile painting. Users choose catalog keys and resource references; they should not maintain path strings or fallback numeric fields as normal authoring state.

## User-Facing Contract

- A catalog owns a `TileSet` resource reference.
- Scene entries own a `PackedScene` resource reference.
- Entry types are `atlas`, `scene`, and `placeholder`.
- `source_id`, `atlas_coords`, and `alternative_tile` remain internal TileSet addressing details, not the primary paint UI.
- Missing catalog keys or missing resources are validation issues. They are not silently repaired through fallback tile fields.

## Acceptance

- The sample catalog loads with a `TileSet` resource and scene entry `PackedScene`.
- `HexTileCatalogValidator.validate_catalog(sample)` is clean.
- Tile, overlay, and document adapters still resolve normal atlas catalog keys.
- Scene tile entries validate by resource reference, not `scene_path`.
