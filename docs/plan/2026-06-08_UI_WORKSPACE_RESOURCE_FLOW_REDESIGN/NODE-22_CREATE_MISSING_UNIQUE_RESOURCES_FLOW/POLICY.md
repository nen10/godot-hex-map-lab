# NODE-22 Policy: Create Missing Unique Resources

## Scope

This task creates missing selected-node UniqueResources and writes the created references back to the selected HexTileMap node.

## Rules

- The flow only runs when a HexTileMap node is selected.
- The user must provide or choose a project save directory.
- Resource prefix defaults to the selected node name and must be file-name safe.
- The flow creates missing unique resources only:
  - Level Document
  - Node Layer Stack Instance
- SharedResource slots are not silently created or filled.
- If the selected node already has a unique resource, it is preserved and not overwritten.
- A runtime `HexMapResource` may seed the newly created Level Document, but it is not treated as a saved Level Document before the user runs this flow.

## Follow-Up Boundary

General ResourcePicker write-back from existing Workspace slots remains `NODE-23`.
