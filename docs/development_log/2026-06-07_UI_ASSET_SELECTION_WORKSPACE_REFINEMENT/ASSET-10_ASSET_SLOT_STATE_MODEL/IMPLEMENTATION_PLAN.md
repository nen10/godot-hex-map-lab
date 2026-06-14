# ASSET-10 Implementation Plan

## Scope

Add the shared asset slot state model and a lightweight control wrapper, then cover the state contract in editor tests.

## Files

- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_state.gd`
- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `ASSET-10` `RUNNING`.
2. Implement asset slot state constants, selection, type validation, sample source fields, and snapshots.
3. Implement asset slot control wrapper with public state methods and optional explicit sample application.
4. Add editor tests for missing/selected/invalid/warning/sample states.
5. Update `docs/TEST.md`.
6. Run `./tools/test.sh`.
7. Self-review, update queue proof, unlock dependency-satisfied tasks, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] `not_selected`, `selected`, `invalid`, and `warning` are represented.
- [x] Resource type mismatch is represented.
- [x] Sample source is optional and not default current selection.
- [x] Tests inspect state model/control snapshots, not private widget names.
- [x] Queue proof and next READY task are clear.
