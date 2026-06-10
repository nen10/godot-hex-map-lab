# STATE-40 UX

## User Goal

The Paint workflow should expose whether the user can paint, what target/document/brush is active, which cell is selected or hovered, whether an apply changed the document/target, and what missing asset or validation focus blocks editing.

## Operation Steps

1. User selects a HexTileMap target and project resources.
2. User chooses a Paint mode and brush resource/key.
3. Viewport hover/click updates hovered/selected cell state.
4. Apply mutates document/target and records dirty/result state.
5. Missing target/document/catalog/object/label assets and validation focus are visible in state.

## Adopted UX

- Expose Paint state as ViewState for current UI and later screen work.
- Keep existing Paint controls and viewport behavior unchanged.
- Use state ids and explicit fields rather than private flags.

## Deferred UX

- Paint tab brush-surface visual redesign is deferred to `SCREEN-22`.
- Catalog editing controls moving out of Paint is deferred to `SCREEN-20`.
