# CAT-03 Policy

## Decisions

1. Catalog resolution is optional and additive. Existing calls without a catalog keep current numeric behavior.
2. `HexMapTileAdapter` owns conversion from catalog key to tile config because floor/wall, overlay, and document adapters all need the same fallback semantics.
3. `HexOverlayTileAdapter` accepts item-key-to-catalog-key maps and converts them to existing item tile configs.
4. `HexMapDocumentAdapter.apply_to_tile_map_layer()` accepts `tile_catalog`, `floor_catalog_key`, and `wall_catalog_key` options; per-entry `catalog_key` values override numeric fields where available.
5. Unresolved keys do not silently erase tiles; fallback numeric config remains the advanced/debug path and validation tasks report missing catalog mappings separately.

## Compatibility

- Existing numeric tests remain valid.
- v1/v2 documents with only `source_id / atlas_coords` continue to display.
- Catalog-backed apply does not require editor UI changes.

## Repair Criteria

- Floor/wall defaults resolve by catalog key.
- Per-cell document tile assignments resolve by catalog key.
- Overlay item keys can be mapped to catalog keys.
- Missing catalog keys fall back to numeric fields.
- `./tools/test.sh` must pass.
