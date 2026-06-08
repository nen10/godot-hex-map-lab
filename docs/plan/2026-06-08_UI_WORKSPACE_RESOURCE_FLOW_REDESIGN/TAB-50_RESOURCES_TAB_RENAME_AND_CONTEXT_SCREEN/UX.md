# TAB-50 UX

## User Goal

The first workspace tab should read as the place to understand and manage the selected HexTileMap resource context, not as a narrow Level Document editor.

## Operation Steps

1. Open the Hex Map Workspace.
2. See the first tab labeled `Resources`.
3. Inspect the selected HexTileMap node context.
4. Scan Unique, Shared, and Optional resource groups.
5. Create missing unique resources for the selected HexTileMap when needed.

## Adopted UX

- Rename the visible `Document` tab to `Resources`.
- Keep Level Document creation APIs for compatibility, but present the screen as resource context management.
- Show selected HexTileMap context and resource group summaries on the Resources tab.
- Keep `Create Missing Resources` in the Resources tab for node-owned Level Document / Layer Stack creation.

## Rejected UX

- No silent sample defaults to make the Resources tab look configured.
- No raw path text as the primary explanation of resource ownership.
- No separate compatibility tab named `Document`.

## Existing UX Interference

- Existing tests and code may still use `document_screen_snapshot()` or the old tab name as an internal alias; that must not affect the visible tab label.
