# ARCH-04 Implementation Plan

Task: `ARCH-04`  
Created: 2026-06-07  
Status: COMPLETE

## Acceptance

Validation/dashboard logic is not embedded only in giant dock file.

## Steps

1. Add `HexMapDocumentInspector` under `addons/hex_map_kit/editor/`.
2. Move document summary, validation summary, and validation issue report row helpers into the inspector component.
3. Add the inspector to Edit Dock and keep existing document label behavior.
4. Delegate Edit Dock validation debug summary and issue report rows to the inspector helper.
5. Delegate Generate Dock validation summary helpers to the inspector helper while preserving generation-specific keys.
6. Add focused component tests and keep existing validation/debug report tests passing.
7. Update `docs/TEST.md`.
8. Run targeted editor plugin test and `./tools/test.sh`.
9. Write ARCH-04 test result and self-review docs.
10. Update queue proof and dependency sweep.

## Repair Classification

- `repair-now`: any validation dashboard, debug report, issue focus, or generation validation summary regression.
- `follow-up-ready`: deeper validation dashboard redesign not required by this task.
- `manual-optional`: inspect compact inspector text in the Godot editor.
