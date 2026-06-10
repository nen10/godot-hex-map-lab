# SCREEN-20 Policy

## Adopted Decisions

- Catalog editing responsibility belongs to Catalog.
- Paint consumes catalog keys as brush inputs.
- Catalog metadata may include source id and atlas coordinates, but Paint must not expose them as primary controls.
- Internal helper APIs can remain until component extraction if normal UI and state contracts are clean.

## Rejected Decisions

- Do not move Layer/Document/Export controls in this task.
- Do not remove Paint catalog-key selection.
- Do not rely on sample catalog success as production completion proof.
- Do not add analog tests for CLEAN UI.

## Boundaries

- `HexMapWorkspace.catalog_screen_snapshot()` owns Catalog workflow state.
- `HexMapWorkspace.paint_brush_screen_snapshot()` describes Paint's consumption boundary.
- `HexMapEditTool` may keep non-visible helper controls/methods for now.
