## User Goal

Keep gameplay and object rendering behavior intact while moving all debug overlay immediate-mode drawing into one renderer object.

## UX / Runtime Ownership

- `HexTileMapLayer` remains the runtime coordinator and public API owner.
- `HexDebugOverlayRenderer` owns only debug overlay draw primitives:
  - highlight/path outlines
  - movement-range fills
  - toric loop duplicate-cell outlines
- Normal gameplay rendering (TileMap atlas tiles and object markers) remains in layer-owned/renderer-owned gameplay paths.

## Validation Entry Point

- Validate/debug workflows can now call:
  - `focus_validation_cells(cells, color)`
- This method keeps `clear+normalize+highlight` behavior and triggers `_draw_overlay` redraw.

## Success Criteria

- Visual parity checks in tests compare overlay draw calls and colors before/after extraction.
- Existing object marker path remains observable from overlay draw calls.
- No gameplay draw path is added to the new renderer.
