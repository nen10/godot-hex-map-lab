# STATE-60 Policy

## Adopted Decisions

- Root state composes existing screen snapshots and extracts ViewState instead of duplicating screen-specific logic.
- Dispatcher handles named Workspace events and returns stateful results; it does not bypass current public methods.
- Debug report generation must be possible from the root state snapshot.

## Rejected Decisions

- Do not remove existing screen snapshot APIs.
- Do not redesign tab contents or move controls.
- Do not make compatibility/fallback/debug text normal UI.
- Do not add new analog tests.

## Boundaries

- `HexMapWorkspace` owns root state context and public dispatch method.
- A root state helper owns aggregation and debug report formatting.
- A dispatcher helper owns event id mapping to existing Workspace operations.
- Existing tab/workflow states remain their own source of truth.
