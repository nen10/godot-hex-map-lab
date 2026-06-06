# ARCH-03 Policy

Task: `ARCH-03`  
Created: 2026-06-07  
Status: COMPLETE

## Decisions

- Extract viewport input and local hit derivation into an editor helper that does not own dock controls.
- Extract edit-mode mutation construction into an editor helper that returns before/after state or command dictionaries.
- Keep undo/redo wiring inside `HexMapEditTool` because it depends on editor services and current target lifetime.
- Keep target resolution and status labels inside `HexMapEditTool`.
- Use existing edit mode integer values to avoid introducing saved schema or UI enum migration.
- Add focused tests for helper behavior while retaining existing integration tests for viewport edit and undo/redo.

## Compatibility

- No saved resource changes.
- No public API requirement for helper scripts.
- Existing `HexMapEditTool` private tests remain valid for regression coverage.
