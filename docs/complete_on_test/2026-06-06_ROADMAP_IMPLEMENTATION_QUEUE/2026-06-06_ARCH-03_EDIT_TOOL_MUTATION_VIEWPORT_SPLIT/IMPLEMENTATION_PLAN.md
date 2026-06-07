# ARCH-03 Implementation Plan

Task: `ARCH-03`  
Created: 2026-06-07  
Status: COMPLETE

## Acceptance

Viewport hit/edit/undo tests pass; object and validation UI can reuse mutation helpers.

## Steps

1. Add `HexMapEditViewportInputAdapter` under `addons/hex_map_kit/editor/`.
2. Add `HexMapEditMutationBuilder` under `addons/hex_map_kit/editor/`.
3. Delegate `HexMapEditTool` local hit and viewport press filtering to the viewport adapter.
4. Delegate document edit and `HexTileMapLayer` command construction to the mutation builder.
5. Add focused helper tests in `tests/test_editor_plugin.gd`.
6. Update `docs/TEST.md`.
7. Run targeted editor plugin test and `./tools/test.sh`.
8. Write ARCH-03 test result and self-review docs.
9. Update queue proof and dependency sweep.

## Repair Classification

- `repair-now`: any viewport edit, undo/redo, object/label/tile payload, or validation UI regression.
- `follow-up-ready`: broader UI component extraction not needed for this task.
- `manual-optional`: inspect viewport editing in the Godot editor after refactor.
