# UI-02 Policy

## Adopted Decisions

- Boolean state belongs to CheckBox/toggle state, not redundant labels.
- Sample paths are tooltip/detail/debug content.
- Debug fallback payload is not normal Settings text.
- Existing sample duplicate behavior remains unchanged.

## Rejected Decisions

- Do not remove explicit debug opt-in controls.
- Do not make sample assets production defaults.
- Do not hide successful sample duplicate outcome entirely.
- Do not add path text back as normal UI for test convenience.

## Boundaries

- `HexMapSampleSettingsPanel` owns sample row/status presentation.
- `HexMapWorkspace` owns the Settings preference summary labels.
- `HexMapSampleLearningState` remains the sample workflow state source.
