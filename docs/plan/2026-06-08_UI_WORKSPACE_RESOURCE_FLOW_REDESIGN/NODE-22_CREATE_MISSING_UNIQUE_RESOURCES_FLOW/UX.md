# NODE-22 UX: Create Missing Unique Resources

## Intent

When a HexTileMap is selected but lacks node-owned resources, the Workspace gives the user one deliberate creation flow instead of silently using samples or generic defaults.

## Flow

1. User selects a HexTileMap node.
2. Workspace shows missing unique resources for that selected node.
3. User chooses a save directory.
4. User can edit the resource prefix; default is the selected node name.
5. User presses `Create Missing Resources`.
6. Workspace creates only the missing unique resources and assigns them to the selected node.

## Created Resources

Default names:

```text
<NodeName>_document.tres
<NodeName>_layer_stack.tres
```

Shared resources such as Tile Catalog, Object Database, and Label Database are not created by this flow.

## Empty / Blocked States

- No selected node: show `No HexTileMap selected`.
- No save directory: creation is unavailable until a directory is chosen.
- No missing unique resources: the action reports that the selected node is already configured.
