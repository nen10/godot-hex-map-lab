# LST-02 UX

## User Outcome

Runtime/editor targets can apply a v2 document into role-named child layers instead of treating every visual payload as one implementation layer. The single plain `TileMapLayer` apply path remains available for compatibility and debugging.

## Operation Steps

1. Prepare a v2 `HexMapDocumentResource`.
2. Choose a `HexLayerStackResource` template.
3. Call `HexTileMapLayer.apply_document_to_layer_stack(document, stack, options)`.
4. Terrain entries render into the terrain role child.
5. Overlay tile entries render into the overlay role child.
6. Existing `HexMapDocumentAdapter.apply_to_tile_map_layer()` still works on a plain `TileMapLayer`.

## Non-Goals

- Editor UI for choosing a stack. That belongs to later UI tasks.
- Object scene instancing into object layers. That belongs to `OBJ-04`.
- Validation dashboard reporting. That belongs to `VAL-02`.
