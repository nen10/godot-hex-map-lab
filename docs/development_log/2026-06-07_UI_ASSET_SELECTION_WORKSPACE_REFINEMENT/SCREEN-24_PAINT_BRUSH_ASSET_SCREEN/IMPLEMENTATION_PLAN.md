# SCREEN-24 Implementation Plan

## Scope

Add Paint brush state snapshots and owner-tab missing asset CTAs, then verify normal Paint UI hides internal ids and raw object/label id fields.

## Files

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `SCREEN-24` `RUNNING`.
2. Add public Paint brush mode snapshot helpers in `HexMapEditTool`.
3. Add Workspace Paint brush screen snapshot and mode selection helper.
4. Add missing asset CTA state for Catalog, Object Database, and Label Database ownership.
5. Add headless tests for terrain/overlay/object/label brush state and hidden internal/raw controls.
6. Update `docs/TEST.md`.
7. Run `./tools/test.sh`.
8. Self-review, repair, update queue proof, unlock dependencies, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Paint brush snapshot reports current mode and brush asset state.
- [x] Missing terrain/overlay catalog points to Catalog tab.
- [x] Missing object definition points to Object/Label asset panel.
- [x] Missing label definition points to Object/Label asset panel.
- [x] Source id / atlas coords controls are absent from normal Paint UI.
- [x] Raw object id / label id controls are absent from normal Paint UI.
- [x] Queue proof and next READY task are clear.
