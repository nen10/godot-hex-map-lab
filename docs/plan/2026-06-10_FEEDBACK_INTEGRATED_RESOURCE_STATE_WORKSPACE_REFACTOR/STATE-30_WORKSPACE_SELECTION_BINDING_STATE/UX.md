# STATE-30 UX

## User Goal

The Workspace should always know what is selected, whether that selection has a Level Document, whether dependencies came from the document, whether the user has overridden any resource manually, and whether writeback is pending or applied.

## Operation Steps

1. User selects no HexTileMap, a HexTileMap without document, or a HexTileMap with a document.
2. Workspace auto-links the selected node and hydrates document dependencies into context.
3. User may manually override a shared resource in the Workspace.
4. Workspace can write selected context back to node/document dependencies.
5. State exposes no target, missing document, hydrated dependencies, manual override, pending writeback, applied writeback, and conflict.

## Adopted UX

- Use a selection/binding ViewState snapshot for workspace target/resource state.
- Keep auto-link as the normal path.
- Keep current UI layout; expose state for later `SCREEN-10` rendering.

## Deferred UX

- New Resources tab layout and target summary card are deferred to `SCREEN-10`.
- Cross-screen dispatcher integration is deferred to `STATE-60`.
