# INFO-70 Resource Purpose Tooltips UX

Date: 2026-06-08

## User goal

A game developer should be able to hover a resource row and understand what the resource is for and what type to pick without reading long inline descriptions.

## Flow

1. Open Resources, Catalog, Layers, Validate, QA, Export, or Settings.
2. Hover a resource row title/status/picker.
3. See a compact tooltip with pick type, current status, source, and purpose.
4. Open Catalog detail and hover TileSet status to understand what the TileSet provides.

## Visible contract

- Long purpose text stays in tooltips, not normal row labels.
- ResourcePicker rows keep compact visible labels.
- TileSet purpose is visible in Catalog detail because TileSet is not its own workspace asset slot.
