# SCREEN-22 Policy

## Adopted Decisions

- Paint completion evidence must include active brush, target layer, selected cell, and last edit state.
- Paint may reference Resources/Catalog ownership through CTA metadata, but must not become a Resource reference screen.
- Viewport edit state is part of Paint's screen contract.
- Existing state machine output is the source of truth for Paint screen summaries.

## Rejected Decisions

- Do not re-add Document, Layer, Catalog, or Export management controls to Paint.
- Do not add analog tests for CLEAN UI.
- Do not extract the Paint component in this task.
- Do not use sample-only success as completion proof.

## Boundaries

- `HexMapEditTool.paint_workspace_snapshot()` owns low-level visible Paint summary state.
- `HexMapWorkspace.paint_brush_screen_snapshot()` owns screen-level Paint surface contract.
- Viewport input updates Paint through the existing Paint interaction state machine.
