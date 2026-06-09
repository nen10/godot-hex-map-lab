# CLEANUP-31 Implementation Plan

## Scope

Hide normal raw authoring fields and expose selector/schema state for overlay, object, label, and object property payloads.

## Files

- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `CLEANUP-31` `RUNNING`.
2. Split overlay raw item text from the visible overlay selector row and hide raw text.
3. Add Object Variant and Spawn Condition OptionButtons.
4. Populate variant/spawn options from selected Object Definition metadata, with conservative defaults.
5. Sync payload from selectors while keeping raw LineEdit controls hidden.
6. Add an authoring field snapshot for tests.
7. Update tests for overlay/label/object/property field sources and hidden raw controls.
8. Update `docs/TEST.md`.
9. Run `./tools/test.sh`.
10. Self-review, repair, update queue proof, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Overlay item key uses selector source and raw text is hidden.
- [x] Label ID uses Label Definition source and raw id is hidden.
- [x] Object variant uses enum selector and raw text is hidden.
- [x] Spawn condition uses enum selector and raw text is hidden.
- [x] Object property key/value uses typed property schema editor and raw JSON/table are hidden.
- [x] Queue proof and next READY task are clear.
