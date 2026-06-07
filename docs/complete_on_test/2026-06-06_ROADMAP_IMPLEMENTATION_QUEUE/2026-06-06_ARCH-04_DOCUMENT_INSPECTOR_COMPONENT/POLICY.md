# ARCH-04 Policy

Task: `ARCH-04`  
Created: 2026-06-07  
Status: COMPLETE

## Decisions

- Add a new editor component for document and validation summary display.
- Keep `HexMapValidationDashboard` responsible for validation action and issue row selection.
- Move shared validation summary and issue-row formatting into the inspector component as static helpers.
- Keep validation execution and target TileSet option selection inside the owning dock.
- Keep existing debug report keys stable.

## Compatibility

- No saved resource changes.
- Existing validation summary dictionaries keep their current keys.
- Existing Edit Dock and Generate Dock tests remain the primary regression proof.
