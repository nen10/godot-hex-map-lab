# NODE-23 Policy: Dock Selection Writes Back To Node

## Scope

This task wires Workspace slot changes into selected-node references for node-owned resources.

## Ownership Rules

- Level Document: write to `HexTileMapLayer.level_document_resource`.
- Layer Stack: write to `HexTileMapLayer.layer_stack_resource`.
- Tile Catalog: shared Workspace context only.
- Object Database: shared Workspace context only.
- Label Database: shared Workspace context only.

## Write-Back Rules

- Write-back only runs for a selected HexTileMap while auto-link is enabled.
- Node-owned write-back updates Workspace/session context after assignment.
- Shared resources are not copied into the node by default.
- Blocked write-back must be visible through snapshot/tooltip state.

## Follow-Up Boundary

Detailed Resources tab grouping remains `TAB-50`; this task provides the state and write-back behavior that grouping can display.
