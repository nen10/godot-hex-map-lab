# NODE-21 UX: Selected HexTileMap Auto-Binding

## Intent

The Workspace follows the selected HexTileMap node by default. A user should not have to press a Link button after selecting a map in the Scene Tree.

## Primary Flow

1. User selects a HexTileMap node in the Scene Tree.
2. Workspace immediately shows that node as the active target.
3. Resource rows display the selected node's Document, Catalog, and Layer Stack references when available.
4. User selects another HexTileMap node.
5. Workspace switches context to the newly selected node.

## Empty State

When no HexTileMap node is selected, the Workspace context surface displays:

```text
No HexTileMap selected
```

The empty state must be visible without requiring the user to open diagnostics or inspect raw paths.

## Auto-Link

Auto-link is default ON. The normal UI does not expose a detached "select but do not link" workflow because that use case is not defined for this roadmap.

Manual link controls are not primary actions for this task. If shown at all, link state is informational status, not an action button competing with ResourcePicker.
