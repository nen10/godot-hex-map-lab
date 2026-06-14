# SCREEN-22 Implementation Plan

## Scope

- Add Paint surface summary fields to edit-tool and workspace snapshots.
- Include active brush, target layer, selected cell, last edit, empty state, and non-resource-only contract fields.
- Update tests around missing setup and viewport edit state.
- Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
- Update queue proof, self-review, and test result.

## Target Files

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`

## Steps

1. Add visible Paint summary fields from the edit tool.
2. Add screen-level Paint surface contract fields in Workspace.
3. Assert empty-state and viewport-edit behavior in existing editor tests.
4. Run `./tools/test.sh`.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Paint empty state is part of the screen contract.
- [x] Active brush, target layer, selected cell, and last edit are visible state.
- [x] Viewport editing updates Paint state.
- [x] Paint is not resource-reference-only.
- [x] Tests cover SCREEN-22 state contract.
- [x] Queue proof, self-review, and test result are updated.
