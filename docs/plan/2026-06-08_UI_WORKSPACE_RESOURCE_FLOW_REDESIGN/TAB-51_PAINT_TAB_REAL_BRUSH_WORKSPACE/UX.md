# TAB-51 UX

Task: `TAB-51_PAINT_TAB_REAL_BRUSH_WORKSPACE`

## User Outcome

The Paint tab reads as the active editing workspace for the selected `HexTileMap`, not as a second place to manage Resources.

## Screen Contract

- Paint opens around current editing state: active document, selected/target layer, active brush mode, brush key, selected cell/last edit, and undo availability.
- Brush status is visible for terrain, overlay, object, label, and unavailable zone workflows.
- Missing Object Database / Label Database states use concise CTAs that point to Resources.
- Object/Label project asset selection belongs to Resources; Paint consumes the selected resources and definitions.
- A viewport edit switches the workspace to Paint so the edit result is visible immediately.

## Non-Goals

- Do not implement new brush shapes beyond existing behavior.
- Do not add zone painting if the mutation model is not ready.
- Do not add analog tests for this CLEAN UI task.
