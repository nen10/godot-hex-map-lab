# CAT-03 UX

## User Outcome

Documents and generators can start using logical catalog keys for floor, wall, and overlay tile choices while advanced/debug numeric `source_id / atlas_coords / alternative_tile` paths continue to work.

## Operation Steps

1. Provide a `HexTileCatalogResource` to map/tile/document adapter helpers.
2. Pass default floor and wall catalog keys for generated or document-wide terrain display.
3. Store per-cell `catalog_key` values on terrain and overlay assignments when authoring intent should override the default.
4. Map overlay item keys to catalog keys before applying overlay data to a TileMapLayer.
5. Fall back to raw numeric fields when no catalog key is available or the key is unresolved.

## Non-Goals

- Editor selector UI. That belongs to `CATUI-01`.
- Validation of missing catalog keys. That belongs to `VAL-01` with CAT-02 helper support.
- Layer stack routing. That belongs to `LST-02`.
