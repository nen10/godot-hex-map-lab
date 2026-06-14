# SCREEN-23 Implementation Plan

## Scope

- Add Validate-tab workflow run action UI/state.
- Add Validate issue navigator ownership fields for issue list, severity, scope, focus action, and selection routing.
- Hide Paint-side validation dashboard from normal UI while preserving helper APIs.
- Update existing Validate/Paint tests and `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
- Update queue proof, self-review, and test result.

## Target Files

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`

## Steps

1. Add Validate run button and snapshot state.
2. Add Validate issue navigator ownership fields.
3. Hide Paint validation dashboard as a normal UI element.
4. Update tests around Validate screen and Paint boundary.
5. Run `./tools/test.sh`.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Validate owns workflow-level run action.
- [x] Issue list/severity/scope/focus action are visible state.
- [x] Issue selection routes to tab/resource/cell focus.
- [x] Slot-level Validate buttons remain absent.
- [x] Paint does not expose validation dashboard as normal UI.
- [x] Tests cover SCREEN-23 state contract.
- [x] Queue proof, self-review, and test result are updated.
