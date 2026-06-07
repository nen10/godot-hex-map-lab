# SCREEN-23 Policy

## Adopted Decisions

- `SLOT_OBJECT_DATABASE` and `SLOT_LABEL_DATABASE` are the selected project assets for object/label placement.
- The Paint tab may own object/label asset panels because Object and Label placement are paint workflows in the current Workspace shape.
- Object definitions are created from selected `PackedScene` resources and stored in `HexObjectDatabaseResource`.
- Label definitions are created as typed `HexLabelDefinitionResource` entries in `HexLabelDatabaseResource`.
- Placement state is set by selecting definitions through `HexMapEditTool` public methods.

## Rejected Decisions

- Do not add a separate Workspace tab in this task; the queue allows panels, and broad tab restructuring belongs in a later UI pass.
- Do not use raw text ids as completion proof for normal object/label placement.
- Do not silently inject the bundled sample object scene into the object database.

## Resource / API / UI Boundary

- `HexObjectDatabaseResource` / `HexObjectDefinitionResource` own object definition data.
- `HexLabelDatabaseResource` / `HexLabelDefinitionResource` own label definition data.
- `HexMapWorkspace` owns screen-level asset actions and snapshots.
- `HexMapEditTool` owns active placement payload selection for object/label paint modes.

## Task-Local Decisions

- Object definition id and label definition id must be non-empty.
- Definition creation requires a selected project database; create/select database is a separate explicit action.
- Screen snapshots expose definition rows and selected placement ids for headless verification.
