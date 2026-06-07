# ARCH-03 Edit Tool Mutation Viewport Split UX

Task: `ARCH-03`  
Created: 2026-06-07  
Status: COMPLETE

## Goal

Keep Hex Map Edit Dock behavior unchanged while separating viewport input interpretation from edit mutation construction.

## Operation Steps

1. The user clicks an editable viewport cell exactly as before.
2. Viewport mouse input is filtered and converted into target-local hit state by an adapter helper.
3. Edit mode and payload state are converted into document or `HexTileMapLayer` mutation commands by a mutation helper.
4. The dock still owns UI controls, status labels, target resolution, undo/redo submission, and display refresh.
5. Existing viewport hit/edit/undo tests and focused helper tests verify the split.

## Non-goals

- No edit-mode redesign.
- No public editor workflow changes.
- No saved resource schema changes.
- No broad `HexMapEditTool` UI extraction.
