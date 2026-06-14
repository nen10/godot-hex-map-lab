# SCREEN-22 Implementation Plan

## Scope

Make the Layers tab manage project Layer Stack assets, explicit template duplication, scene-root target picking, and role application actions through stable screen methods.

## Files

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `SCREEN-22` `RUNNING`.
2. Add public Layer Stack action wrappers in `HexMapEditTool`.
3. Add Layers screen snapshot and action helpers in `HexMapWorkspace`.
4. Support project Layer Stack create / open / save as / clear.
5. Support explicit template duplication to a project `.tres`.
6. Support target root picking and role create/apply/clear from the workspace screen contract.
7. Add headless tests for project Layer Stack flow, target-root selection, role actions, and non-sample template duplication.
8. Update `docs/TEST.md`.
9. Run `./tools/test.sh`.
10. Self-review, repair, update queue proof, unlock dependencies, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Project Layer Stack can be created and selected from the Layers tab.
- [x] Layer Stack can be opened, saved as, and cleared.
- [x] Built-in templates are duplicated to project assets before selection.
- [x] Target root selection resolves a scene `HexTileMapLayer`.
- [x] Role rows expose missing/ok state for selected target.
- [x] Create missing layers, apply document, and clear role work through the Layers screen contract.
- [x] Queue proof and next READY task are clear.
