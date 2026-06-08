# NODE-23 UX: Dock Selection Writes Back To Node

## Intent

When a HexTileMap is selected and auto-link is ON, choosing resources in the Workspace updates the selected node or the shared workspace context according to the ownership policy.

## Flow

1. User selects a HexTileMap node.
2. User picks or creates a Level Document in the Workspace.
3. The selected node immediately references that Level Document.
4. User picks or creates a Layer Stack.
5. The selected node immediately references that Layer Stack.
6. User picks shared resources such as Catalog, Object Database, or Label Database.
7. Workspace keeps those resources in shared project context and displays that they are shared, not node-owned.

## Empty / Blocked States

- No selected node: write-back is blocked with `No HexTileMap selected`.
- Auto-link OFF: write-back is blocked with an explicit auto-link reason.
- Resource type mismatch: ResourcePicker/type validation blocks the assignment path where existing filters can enforce it.
