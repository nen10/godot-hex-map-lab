# CLEAN-24 Layer Stack Screen Redesign UX

## Goal

Layer Stack should be an explicit authoring screen where users can see terrain, overlay, object, collision, navigation, and debug roles before applying a document.

## User Contract

- A layer stack template can be selected.
- Roles are listed with node name, visible state, locked state, z-index, writable source, and status.
- `Create Missing Layers`, `Apply Document`, and `Clear Role` are available as explicit commands.
- The normal layer workflow targets `HexTileMapLayer` layer-stack roles; plain `TileMapLayer` apply is not the primary workflow.

## Non-Goals

- CLEAN-31 owns the final workspace/tab model decision.
- CLEAN-33 owns deleting any remaining plain `TileMapLayer` primary action paths outside this screen.
