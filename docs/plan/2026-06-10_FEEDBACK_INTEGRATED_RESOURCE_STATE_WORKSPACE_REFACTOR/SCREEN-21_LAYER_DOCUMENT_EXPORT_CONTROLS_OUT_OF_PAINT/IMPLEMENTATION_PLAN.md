# SCREEN-21 Implementation Plan

## Scope

- Add Resources ownership fields for Level Document save/dependency/dirty workflow.
- Add Layers ownership fields for Layer Stack role/template/create/apply/clear workflow.
- Add Export ownership fields for destination/output/run workflow.
- Hide Paint-side Document, Layer Stack, and Export management controls from normal UI.
- Add Paint boundary fields proving non-paint controls are absent while context remains.
- Update editor tests and `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
- Update queue proof, self-review, and test result.

## Target Files

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`

## Steps

1. Add ownership state to Resources, Layers, Export, and Paint snapshots.
2. Hide Paint-side Document management controls.
3. Hide Paint-side Layer Stack management controls.
4. Hide Paint-side Export management controls.
5. Update existing tests to assert responsible-tab ownership and Paint boundary.
6. Run `./tools/test.sh`.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Resources owns document save/dependency/dirty state.
- [x] Layers owns Layer Stack role/template/action state.
- [x] Export owns Runtime Handoff destination/output/run state.
- [x] Paint does not expose Document, Layer Stack, or Export management controls in normal UI.
- [x] Tests cover SCREEN-21 state contract.
- [x] Queue proof, self-review, and test result are updated.
