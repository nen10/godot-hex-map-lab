# STATE-60 UX

## User Goal

The Workspace should have one coherent state source for current tab, per-screen ViewState, workflow status, and debug report output.

## Operation Steps

1. Workspace builds tab snapshots through existing screen methods.
2. Root state collects each screen's ViewState and state ids.
3. Workspace dispatches current root events through a named dispatcher boundary.
4. Debug report output is generated from the root state snapshot.

## Adopted UX

- Existing screens remain visible and behaviorally stable.
- Root ViewState is a state contract for later UI cleanup.
- Debug report uses state snapshot data, not private widget traversal.

## Deferred UX

- Component extraction is deferred to `ARCH-41`.
- Minimal first impression label/control cleanup is deferred to `UI-00` and following UI tasks.
- Root reducer/event model can expand later; this task establishes the boundary.
