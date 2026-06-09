# CLEAN-20 Policy

## Decisions

- Resource references are the primary state for editor resource selection.
- Path strings are supplemental saved-location metadata.
- Editable path `LineEdit` controls are not valid acceptance criteria for clean UX tests.
- Programmatic path helper methods may remain for tests, scripts, and FileDialog callbacks, but they must not be the normal UI input surface.

## Verification

- UI smoke tests should verify resource picker availability and read-only path/status fields.
- FileDialog callback tests should verify state transitions, not editable text entry.
- Headless tests may exercise setter methods as API helpers, but must not require normal users to type paths.
