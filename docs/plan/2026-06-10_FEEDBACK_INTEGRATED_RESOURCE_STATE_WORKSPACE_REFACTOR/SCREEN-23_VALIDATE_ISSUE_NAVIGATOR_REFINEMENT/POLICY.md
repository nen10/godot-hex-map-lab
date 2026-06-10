# SCREEN-23 Policy

## Adopted Decisions

- Validate is the owner of validation workflow run and issue navigation.
- Resource rows should not grow per-slot Validate buttons.
- Paint may receive issue focus for cell issues, but not own validation workflow controls.
- Existing dashboard/helper APIs may remain hidden until component extraction.

## Rejected Decisions

- Do not add row-level Validate buttons.
- Do not make Paint the primary validation dashboard.
- Do not add analog tests for CLEAN UI.
- Do not rely on sample assets to clear validation.

## Boundaries

- `HexMapWorkspace.validate_screen_snapshot()` owns workflow-level validation state.
- `HexMapWorkspace.select_validate_issue()` owns issue navigation.
- `HexMapEditTool` validation dashboard remains a hidden helper for editor internals/tests.
