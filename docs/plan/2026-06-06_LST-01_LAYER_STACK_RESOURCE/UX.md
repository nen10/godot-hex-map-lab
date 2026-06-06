# LST-01 UX

## User Outcome

Authors can describe the intended layer stack with role names instead of relying on `HexTileMapLayer` internal child names. Later apply/UI tasks can route terrain, overlay, object, collision, navigation, and debug data by role.

## Operation Steps

1. Create a `HexLayerStackResource`.
2. Pick a template for standard authoring or minimal runtime use.
3. Inspect roles and layer names for terrain, decoration, object, collision, navigation, overlay, and debug layers.
4. Save the resource with the project or document workflow.

## Non-Goals

- Applying documents into a child-layer stack. That belongs to `LST-02`.
- Editor UI for selecting templates. That belongs to later catalog/layer-stack UI work.
- Object scene placement. That belongs to `OBJ-04`.
