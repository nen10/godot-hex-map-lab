# CAT-02 Implementation Plan

## Scope

Add a catalog validation/custom-data helper, extend adapter tests and `docs/TEST.md`, run `./tools/test.sh`, self-review, queue proof, and commit.

## Steps

1. Add `addons/hex_map_kit/adapter/hex_tile_catalog_validator.gd`.
2. Implement `validate_catalog(catalog, tile_set)` returning `HexMapValidationResult`.
3. Detect missing catalog, missing TileSet, empty/duplicate keys, missing source, wrong source type, invalid atlas coordinates, invalid alternative tile where available, and missing scene paths.
4. Implement `entry_tags_and_custom_data(tile_set, entry)` and `catalog_key_tags_and_custom_data(catalog, key, tile_set)` helpers.
5. Extend `tests/test_hex_adapter.gd` with fixtures for valid atlas custom data, missing TileSet, missing source, invalid atlas coordinate, and missing scene.
6. Update `docs/TEST.md` test overview.
7. Run `./tools/test.sh`; repair failures in-task.
8. Write `docs/review/autopilot/CAT-02_SELF_REVIEW_2026-06-07.md`, update queue proof, and commit.
