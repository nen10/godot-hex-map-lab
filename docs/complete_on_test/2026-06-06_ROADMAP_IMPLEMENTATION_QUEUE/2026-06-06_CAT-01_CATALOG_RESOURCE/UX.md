# CAT-01 UX

## User Outcome

Authors can refer to map tiles by stable logical keys instead of memorizing `source_id` and atlas coordinates. A catalog entry names a tile or scene prototype and keeps the raw Godot TileSet details behind the key.

## Operation Steps

1. Create or load a `HexTileCatalogResource`.
2. Add `HexTileCatalogEntry` records with unique `key` values such as `terrain.grass`, `terrain.wall`, or `object.spawn`.
3. For atlas tiles, store `source_id`, `atlas_coords`, `alternative_tile`, tags, and optional fallback display data.
4. For scene tiles, store `source_id`, scene path, tags, and optional fallback display data.
5. Resolve entries by key when adapters or later UI tasks need tile details.

## Non-Goals

- Replace Generate/Edit Dock numeric controls. That belongs to `CATUI-01`.
- Validate TileSet source existence or custom data. That belongs to `CAT-02`.
- Apply catalog-backed document tiles. That belongs to `CAT-03`.
