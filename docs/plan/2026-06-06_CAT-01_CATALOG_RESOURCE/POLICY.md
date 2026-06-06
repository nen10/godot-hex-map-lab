# CAT-01 Policy

## Decisions

1. `HexTileCatalogResource` and `HexTileCatalogEntry` are saved as typed `Resource` scripts in `addons/hex_map_kit/adapter/`.
2. Entry `key` is the canonical authoring identifier. Empty keys are ignored by lookup helpers.
3. Atlas and scene entries use one shared resource class with `entry_type` constants, because later selector UI needs one logical list across Godot TileSet source types.
4. Numeric fields remain in the catalog entry as fallback/debug data, not normal document authoring values.
5. Tags are `PackedStringArray` so saved resources preserve ordering and Godot inspector editing remains direct.

## Compatibility

- No existing document schema is removed.
- v1/v2 documents can continue storing legacy numeric fallback fields until `CAT-03` migrates tile application.
- The sample catalog is an addon resource, not a user project dependency.

## Repair Criteria

- Duplicate or missing key lookup behavior must be deterministic.
- Sample catalog must load through `ResourceLoader`.
- Tests must prove atlas tile, scene tile, tags, and fallback fields roundtrip.
