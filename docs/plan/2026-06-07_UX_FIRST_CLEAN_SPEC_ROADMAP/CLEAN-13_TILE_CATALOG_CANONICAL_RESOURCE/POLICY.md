# CLEAN-13 Policy

## Constraints

- Follow the clean-spec roadmap: unpublished addon compatibility can be broken when it simplifies the public contract.
- Keep the task scoped to tile catalog resources. Object database `scene_path` cleanup is owned by CLEAN-12.
- Preserve catalog-key-driven painting behavior while removing string and fallback fields from the tile catalog schema.
- Do not design UI around headless test convenience. Tests should cover the canonical resource contract.

## Validation

- Prefer catalog-owned `tile_set` when no explicit validation TileSet is supplied.
- Keep explicit `tile_set` option support for active-layer validation paths.
- Treat missing `TileSet`, missing `PackedScene`, invalid source id, invalid atlas coords, and source type mismatch as validation issues.
- Placeholder entries are allowed catalog records and do not require TileSet addressing.
