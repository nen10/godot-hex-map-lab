# SCREEN-23 Implementation Plan

## Scope

Add Object/Label project asset panels and screen helpers for Object Database, Label Database, Object Definition, and Label Definition selection.

## Files

- `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `SCREEN-23` `RUNNING`.
2. Register and mount Paint Object/Label asset slots.
3. Add public object/label definition selection helpers in `HexMapEditTool`.
4. Add Object/Label screen snapshot and asset actions in `HexMapWorkspace`.
5. Add Object Definition creation from `PackedScene` selection.
6. Add Label Definition creation and selection.
7. Add headless tests for project DB create/open/save/clear, definition creation, definition picker selection, and sample isolation.
8. Update `docs/TEST.md`.
9. Run `./tools/test.sh`.
10. Self-review, repair, update queue proof, unlock dependencies, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Object Database and Label Database project asset slots are mounted.
- [x] Object/Label databases can be created, opened, saved as, and cleared.
- [x] Object Definition creation starts from a selected `PackedScene`.
- [x] Object placement state is set by Object Definition selection.
- [x] Label Definition creation is typed and selectable.
- [x] Label placement state is set by Label Definition selection.
- [x] Sample object scene is not silently assigned.
- [x] Queue proof and next READY task are clear.
