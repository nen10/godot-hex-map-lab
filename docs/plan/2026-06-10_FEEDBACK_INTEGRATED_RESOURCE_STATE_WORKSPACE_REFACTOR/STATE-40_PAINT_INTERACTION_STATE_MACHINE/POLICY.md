# STATE-40 Policy

## Adopted Decisions

- Paint state must include target, document, brush, hover/selected cell, apply/dirty result, validation focus, missing assets, and ViewState.
- ViewState should be consumable by `HexMapWorkspace` Paint tab snapshots.
- Existing input/apply behavior remains stable unless the state contract exposes a bug.

## Rejected Decisions

- Do not move Catalog/Layer/Document controls in this task.
- Do not add new analog tests.
- Do not treat bundled sample catalog as silent Paint readiness.

## Boundaries

- `HexMapEditTool` owns current Paint interaction state.
- `HexMapEditViewportInputAdapter` remains input translation.
- `HexMapWorkspace` exposes Paint tab state for tests and later screen redesign.
