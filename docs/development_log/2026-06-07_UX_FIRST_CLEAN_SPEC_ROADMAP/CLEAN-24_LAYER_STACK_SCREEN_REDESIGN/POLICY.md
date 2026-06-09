# CLEAN-24 Policy

## Decisions

- Layer stack rows are derived from `HexLayerStackResource` templates and selected target state.
- Locked and writable source are screen-level authoring metadata, read from entry metadata when present.
- Creating missing layers and applying documents require a `HexTileMapLayer` target.

## Verification

- Tests should assert template selection, role row content, create/apply/clear actions, and visibility of layer stack controls.
