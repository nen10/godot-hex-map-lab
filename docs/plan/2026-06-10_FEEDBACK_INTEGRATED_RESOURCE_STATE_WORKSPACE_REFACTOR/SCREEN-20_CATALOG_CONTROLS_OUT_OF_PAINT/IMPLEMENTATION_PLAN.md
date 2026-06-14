# SCREEN-20 Implementation Plan

## Scope

- Add Catalog ownership/workflow fields to Catalog screen snapshots.
- Hide Paint catalog entry list/create/validate controls from normal UI.
- Add Paint boundary fields proving it consumes catalog keys only.
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

1. Add Catalog ownership fields for entry list/detail/preview/create/validate.
2. Add Paint catalog ownership fields that mark detail/edit controls non-primary.
3. Hide Paint catalog entry management controls from normal UI.
4. Update existing Catalog/Paint tests.
5. Run `./tools/test.sh`.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Catalog owns entry list, preview, tags/status, create/edit, and validation state.
- [x] Paint does not expose catalog entry management controls in normal UI.
- [x] Paint consumes catalog key selectors and hides raw source/atlas controls.
- [x] Tests cover SCREEN-20 state contract.
- [x] Queue proof, self-review, and test result are updated.
