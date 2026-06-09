# ASSET-11 Implementation Plan

## Scope

Add a workspace asset context resource and wire it through the editor session, workspace, Generate dock, and Paint tool.

## Files

- `addons/hex_map_kit/editor/hex_map_workspace_asset_context.gd`
- `addons/hex_map_kit/editor/hex_map_editor_session_state.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `ASSET-11` `RUNNING`.
2. Implement context fields, setter helpers, slot ids, and snapshot.
3. Add session state ownership and context change publishing.
4. Wire workspace child panels to the same context.
5. Publish Paint catalog/object/label/layer choices to context and let Generate consume context catalog.
6. Add headless editor tests for shared context identity and panel consumption.
7. Update `docs/TEST.md`.
8. Run `./tools/test.sh`.
9. Self-review, repair, update queue proof, unlock dependency-satisfied tasks, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Catalog, Object DB, Label DB, Layer Stack, Movement Profile, Validation Suite, and Generation Profile can be held in one context.
- [x] Session, Workspace, Generate, and Paint expose the same context reference.
- [x] Paint publishes project selections into the context.
- [x] Generate reads the context catalog when available.
- [x] Queue proof and next READY task are clear.
