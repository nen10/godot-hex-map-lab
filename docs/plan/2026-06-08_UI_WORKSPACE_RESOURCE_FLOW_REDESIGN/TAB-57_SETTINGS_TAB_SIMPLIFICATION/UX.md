# TAB-57 Settings Tab Simplification UX

Date: 2026-06-08

## User goal

The Settings tab should read as sample learning, debug opt-in, and editor preference space. A game developer should not see production resource assignment in Settings when the Resources tab is the workspace source of truth.

## Flow

1. Open Resources to inspect or choose project production assets.
2. Use the Movement Profile row from Resources when movement/pathfinding behavior needs a project resource.
3. Open Settings for sample learning controls, sample duplicate-to-project actions, and explicit debug numeric fallback.
4. Confirm Settings does not offer production ResourcePicker rows.

## Visible contract

- Settings has a compact preferences/status panel.
- Settings keeps `HexMapSampleSettingsPanel`.
- Settings does not mount a production asset panel.
- Movement Profile is visible in Resources as an optional project resource.
- Sample `Duplicate To Project` remains functional and `Open` remains absent until a complete preview/focus flow exists.
