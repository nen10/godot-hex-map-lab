# SCREEN-21 Policy

## Adopted Decisions

- Document workflow responsibility belongs to Resources.
- Layer Stack role workflow responsibility belongs to Layers.
- Runtime Handoff export responsibility belongs to Export.
- Paint owns active target, selected cell, brush, and last edit state.
- Internal helpers may remain if normal UI and screen snapshots make ownership clear.

## Rejected Decisions

- Do not hide Paint's active document/target readiness context.
- Do not move Catalog controls again in this task.
- Do not move Validate workflow in this task.
- Do not rely on sample assets as completion proof.
- Do not add analog tests for CLEAN UI.

## Boundaries

- `HexMapWorkspace.resources_screen_snapshot()` owns document workflow state.
- `HexMapWorkspace.layer_stack_screen_snapshot()` owns Layer Stack role workflow state.
- `HexMapWorkspace.export_screen_snapshot()` owns Runtime Handoff output workflow state.
- `HexMapWorkspace.paint_brush_screen_snapshot()` describes Paint's non-paint control boundary.
- `HexMapEditTool` may keep hidden helper controls/methods until component extraction.
