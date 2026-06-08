# NODE-22 Implementation Plan

## Steps

1. Add a node-owned `level_document_resource` reference to `HexTileMapLayer`.
2. Add Workspace readback for missing unique resources, save-directory/prefix defaults, and planned output paths.
3. Add a Document tab component for missing selected-node resources with directory choose and create controls.
4. Implement `create_missing_selected_hex_tile_map_resources(save_directory, resource_prefix)`:
   - create/save missing Level Document
   - create/save missing Layer Stack
   - assign created resources to selected HexTileMap
   - update Workspace/session context
5. Keep SharedResources unmodified.
6. Update component registry, editor tests, and `docs/TEST.md`.
7. Run `./tools/test.sh`.
8. Write self-review and queue proof.

## Acceptance Mapping

- Choose directory/prefix: panel config and public snapshot expose both.
- Default names: deterministic path generation uses `<prefix>_document.tres` and `<prefix>_layer_stack.tres`.
- Auto-reference selected node: tests assert created resources are assigned to `HexTileMapLayer`.
- SharedResource not silently created: tests assert Tile Catalog remains null.
- Resource relationship display: selected-node snapshot and missing-resource snapshot report created relationships.
