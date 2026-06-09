# SCREEN-20 Implementation Plan

## Scope

Make the Document tab manage Level Document project assets through create, open, save as, clear, validate, and dependency slot visibility.

## Files

- `addons/hex_map_kit/editor/hex_map_workspace_asset_panel.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `SCREEN-20` `RUNNING`.
2. Add asset panel actions for create / save as / open / clear.
3. Add workspace Document screen helpers and snapshot.
4. Validate Level Document through project context dependencies.
5. Add headless tests for create, open, save as, clear, validate, and dependency slots without sample defaults.
6. Update `docs/TEST.md`.
7. Run `./tools/test.sh`.
8. Self-review, repair, update queue proof, unlock dependencies, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Level Document can be created without sample assets.
- [x] Level Document can be opened through the Document screen contract.
- [x] Level Document can be saved as a project `.tres`.
- [x] Level Document can be cleared.
- [x] Level Document can be validated.
- [x] Dependency slots are visible in the Document tab.
- [x] Queue proof and next READY task are clear.
