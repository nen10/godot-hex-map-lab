# CAT-01 Implementation Plan

## Scope

Implement `HexTileCatalogResource` and `HexTileCatalogEntry`, add a sample catalog resource, update adapter tests and `docs/TEST.md`, run `./tools/test.sh`, self-review, and update queue proof.

## Steps

1. Add `hex_tile_catalog_entry.gd` with typed exported fields for key, display name, entry type, source id, atlas coords, alternative tile, scene path, tags, fallback source/atlas/alternative, and metadata.
2. Add `hex_tile_catalog_resource.gd` with exported catalog metadata and entries plus helpers for `entry_for_key()`, `has_key()`, `keys()`, and `entries_with_tag()`.
3. Add `addons/hex_map_kit/assets/sample_hex_tile_catalog.tres` with floor, wall, overlay, and scene-style entries.
4. Extend `tests/test_hex_adapter.gd` to verify resource save/load, logical key resolution, scene entry fields, tag filtering, fallback fields, duplicate key determinism, and sample catalog loading.
5. Update `docs/TEST.md` test overview for the new catalog coverage.
6. Run `./tools/test.sh`; repair failures in-task.
7. Write `docs/review/autopilot/CAT-01_SELF_REVIEW_2026-06-07.md`, update queue proof, and commit.
