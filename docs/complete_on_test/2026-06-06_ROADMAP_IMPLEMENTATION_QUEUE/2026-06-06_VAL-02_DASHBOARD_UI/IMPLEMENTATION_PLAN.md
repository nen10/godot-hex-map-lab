# VAL-02 Implementation Plan

## Scope

Add a validation dashboard to the Edit Dock, wire it to `HexMapDocumentValidator`, test grouped result output and cell issue focus, update docs/test proof, self-review, queue proof, and commit.

## Steps

1. Add an editor dashboard control for validation summary, issue rows, and selected issue state.
2. Preload `HexMapDocumentValidator` in `hex_map_edit_tool.gd` and wire the dashboard button to validation execution.
3. Expose headless-testable methods for validation summary and selected issue focus state.
4. Reuse the existing HexTileMapLayer highlight path for cell-scoped issue focus.
5. Add `tests/test_editor_plugin.gd` coverage for validation button grouping and selected cell issue focus.
6. Update `docs/TEST.md`.
7. Run `./tools/test.sh`; repair failures in-task.
8. Write self-review/test-result docs, update queue proof, and commit.
