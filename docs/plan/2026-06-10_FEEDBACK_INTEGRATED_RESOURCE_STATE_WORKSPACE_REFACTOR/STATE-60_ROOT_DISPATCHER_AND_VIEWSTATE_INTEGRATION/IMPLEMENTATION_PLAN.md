# STATE-60 Implementation Plan

## Scope

- Add Workspace root state aggregation and ViewState output.
- Add Workspace dispatcher boundary for a small set of root events.
- Add debug report text generation from root state snapshot.
- Update existing editor tests and `docs/TEST.md`.

## Target Files

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- new root state / dispatcher helper scripts if needed
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## Steps

1. Add root state helper that composes tab snapshots, screen ViewStates, state ids, and debug-report text.
2. Add dispatcher helper for select-tab, run-validation, select-validation-issue, select-export-destination, clear-export-destination, and sample-CTA events.
3. Wire `HexMapWorkspace` public methods for root state, root ViewState, dispatch, and debug report.
4. Extend existing editor tests for root ViewState and dispatch output.
5. Run `./tools/test.sh` and repair failures.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Workspace root state composes screen ViewStates.
- [x] Root event dispatch returns stateful results through a dispatcher boundary.
- [x] Debug report text is generated from root state snapshot.
- [x] Existing screen snapshots remain stable.
- [x] Tests cover root ViewState, dispatch, and debug report contracts.
- [x] Queue proof, self-review, and test result are updated.
