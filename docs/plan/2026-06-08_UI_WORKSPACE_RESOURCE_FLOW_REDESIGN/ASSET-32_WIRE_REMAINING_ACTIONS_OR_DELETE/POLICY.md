# ASSET-32 Policy

## Adoption

- A visible action must have an observable result from button press to workspace state.
- Tests must exercise the signal/button path, not only direct public APIs.
- Undefined actions are deleted from visible UI instead of preserved as placeholders.

## Boundaries

- `HexMapEditorAssetSlotControl` owns row action presses.
- `HexMapWorkspaceAssetPanel` owns translating row actions into workspace asset context changes.
- `HexMapSampleSettingsPanel` may keep sample metadata and duplication helpers, but not visible incomplete row actions.

## Non-Adoption

- Do not add new analog tests during CLEAN UI work.
- Do not wire sample duplicate to an implicit default destination.
- Do not add hidden fallback behavior that silently uses bundled samples as completion.

## Task-Local Decisions

- A test helper that presses the same action handlers as the buttons is acceptable when Godot editor dialogs cannot be opened in headless tests.
- Settings sample `Open` and `Duplicate To Project` are removed now; `SAMPLE-40` can reintroduce functional controls with a complete destination/focus workflow.
