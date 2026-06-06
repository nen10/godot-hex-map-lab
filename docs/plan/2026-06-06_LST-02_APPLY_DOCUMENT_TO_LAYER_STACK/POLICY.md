# LST-02 Policy

## Decisions

1. Add a new `apply_document_to_layer_stack()` method on `HexTileMapLayer`; keep `apply_document()` behavior unchanged.
2. A provided stack resource is stored on the layer for later role lookup and persistence.
3. Terrain and overlay roles are wired to `TileMapLayer` children. Other role nodes are created and configured but remain empty until later tasks.
4. Stack layer creation is by `node_name`; existing matching children are reused.
5. Plain `TileMapLayer` adapter compatibility is proven by tests in the same task.

## Compatibility

- Existing `HexTileMapLayer.apply_document()` tests continue to pass.
- Existing `HexMapDocumentAdapter.apply_to_tile_map_layer()` remains the plain-layer fallback.
- The method accepts optional CAT-03 catalog options without requiring catalog UI.

## Repair Criteria

- v2 terrain payload applies to the terrain role child.
- v2 overlay payload applies to the overlay role child.
- Object/collision/navigation/debug role children are created from the stack.
- Plain `TileMapLayer` apply still works.
- `./tools/test.sh` must pass.
