# CLEAN-13 Implementation Plan

## Steps

1. Replace catalog `tile_set_path` with `tile_set: TileSet`.
2. Replace entry `scene_path` with `scene: PackedScene`.
3. Delete tile catalog fallback fields and `effective_*` helpers.
4. Add `placeholder` entry type and remove `fallback` entry type.
5. Update catalog and document validators to prefer catalog-owned resource references.
6. Update sample catalog to embed/package resource references and verify validator-clean.
7. Update tests and docs for the canonical resource contract.
8. Run `./tools/test.sh`, self-review, repair `repair-now` findings, update queue, and commit.

## Test Path

- `./tools/test.sh`
