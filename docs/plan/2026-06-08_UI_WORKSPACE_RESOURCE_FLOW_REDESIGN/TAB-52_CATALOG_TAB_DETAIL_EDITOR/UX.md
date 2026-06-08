# TAB-52 UX

Task: `TAB-52_CATALOG_TAB_DETAIL_EDITOR`

## User Outcome

The Catalog tab explains what each catalog entry means and whether it can be previewed, instead of exposing raw TileSet coordinates as the main surface.

## Screen Contract

- Catalog resource and TileSet state are summarized.
- Entry list shows key, type, display name, tags, status, and a human-readable preview.
- Entry detail explains the selected/default entry meaning and preview availability.
- Atlas/source coordinates are available as metadata, not primary editable controls.
- Missing preview states explain the reason, such as missing TileSet, missing scene, or placeholder entry.

## Non-Goals

- Do not build a pixel-perfect tile preview renderer in this task.
- Do not add analog tests.
- Do not redesign the full Catalog data model.
