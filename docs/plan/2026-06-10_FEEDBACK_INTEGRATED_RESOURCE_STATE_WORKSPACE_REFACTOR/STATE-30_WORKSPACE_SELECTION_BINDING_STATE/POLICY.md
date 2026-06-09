# STATE-30 Policy

## Adopted Decisions

- Workspace selection and binding state must be represented by explicit state ids.
- Manual override is a state fact and must not be hidden behind generic selected resource flags.
- Pending writeback and applied writeback are separate from validation and selection.
- Conflict is a first-class state when selected node/document resources differ from workspace context.

## Rejected Decisions

- Do not require a manual Link button for the normal selected HexTileMap path.
- Do not treat sample resources as valid silent hydration.
- Do not redesign tab layout in this task.

## Boundaries

- `HexMapWorkspaceBindingService` remains the service for reading/writing node and document dependencies.
- `HexMapEditorSessionState` remains the shared runtime selection holder.
- `HexMapWorkspace` exposes the ViewState for tests and later UI screens.
