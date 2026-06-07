# SCREEN-21 Policy

## Adopted Decisions

- Catalog screen operations target `HexMapWorkspaceAssetContext.SLOT_TILE_CATALOG`.
- Catalog creation uses `HexMapWorkspaceAssetResourceFactory`.
- TileSet assignment stores a project-selected `TileSet` on the catalog resource.
- Entry creation starts from `TileSet` or `PackedScene` resources, not raw normal UI ids.
- Validation uses `HexTileCatalogValidator`.

## Rejected Decisions

- Do not use the bundled sample catalog as the Catalog tab default.
- Do not build the full visual entry editor in this task.
- Do not expose sample catalog candidates while sample mode is OFF.

## Boundary

- This task makes Catalog tab asset identity and entry creation functional.
- Rich preview/detail UX remains in later tasks.
