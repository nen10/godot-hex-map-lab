# SAMPLE-10 Policy

## Adopted Decisions

- `HexMapSampleSettingsPanel` is the owner of bundled sample visibility controls.
- `HexMapEditorSessionState` stores sample visibility flags so Generate/Paint can evaluate the same setting.
- Workspace sessions default sample visibility OFF.
- Standalone legacy dock/tool tests may still use direct sample setup APIs; production workspace behavior is governed by the session setting.

## Rejected Decisions

- Do not silently copy samples to project assets in this task.
- Do not make bundled samples project defaults.
- Do not remove explicit sample setup helpers that are still covered by package/sample tests.

## Boundary

- This task isolates sample visibility settings and selector fallback policy.
- Later tasks duplicate samples and move production asset slots into real tab screens.
