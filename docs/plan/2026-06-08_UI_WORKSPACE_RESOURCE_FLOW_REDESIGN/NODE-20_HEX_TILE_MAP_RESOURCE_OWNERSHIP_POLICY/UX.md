# NODE-20 UX

## User Goal

When a developer selects a HexTileMap authoring node, the workspace should explain which resources belong to that node and which resources are shared project tools. The user should not have to guess whether selecting a catalog, document, layer stack, or profile changes only the dock or also the selected node.

## Operation Steps

1. Select a HexTileMap authoring node in the scene.
2. Read the workspace context summary.
3. See node-owned resources separately from shared project resources.
4. Create missing node-owned resources when needed.
5. Use feature tabs for optional task-specific profiles instead of treating every resource as always required.

## Adopted UX

- The selected node owns its Level Document and node-specific Layer Stack.
- Shared project resources stay visually separate from node-owned resources.
- Optional runtime/generated snapshots are visible as optional state, not required authoring setup.
- Noisy resources such as Generation Profile, Validation Suite, Export Profile, and Movement Profile are not forced into the top selected-node group.

## Retained UX

- `HexTileMapLayer.hex_map` remains useful as runtime/display map data.
- `HexTileMapLayer.layer_stack_resource` remains a node-specific layer role resource.
- Workspace asset context remains the current shared editor state model.

## Deferred UX

- Scene Tree auto-binding is deferred to `NODE-21`.
- Creating missing unique resources is deferred to `NODE-22`.
- Dock selection writeback is deferred to `NODE-23`.
- Generate output/resource relationship is deferred to `NODE-24`.

## Existing UX Interference

The current workspace already exposes all resources as asset slots, but this makes tab responsibility unclear. This task classifies ownership so later UI work can group resources rationally.
