# NODE-20 UX

## User Goal

When a `HexTileMapLayer` is selected, Resources should show that node's Level Document and Layer Stack, plus the shared project resources declared by the selected document dependencies. When the user changes a Workspace resource, it should be written back to the owner that will persist it.

## Operation Steps

1. Select a `HexTileMapLayer` or one of its internal `TileMapLayer` children.
2. Workspace resolves the owning `HexTileMapLayer`.
3. Workspace reads node-owned Level Document and Layer Stack from node exports.
4. Workspace reads shared resources from the selected document dependencies.
5. Changing Level Document or Layer Stack writes to the selected node exports.
6. Changing Tile Catalog, Object DB, Label DB, Movement Profile, or profile slots writes to document dependencies.

## Adopted UX

- Auto-binding remains the default.
- Internal display layer selection resolves back to the parent `HexTileMapLayer`.
- Shared resource writeback updates the selected Level Document dependencies rather than copying resources onto the node.

## Rejected UX

- No manual link button as the primary path.
- No silent sample fallback for missing shared dependencies.
- No `hex_map` authoring role change in this task.
