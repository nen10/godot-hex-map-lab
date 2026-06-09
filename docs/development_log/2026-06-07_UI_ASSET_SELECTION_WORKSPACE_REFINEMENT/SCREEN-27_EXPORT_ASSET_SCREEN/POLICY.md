# SCREEN-27 Policy

## Rules

- Export is project-asset driven: source document and optional profile come from workspace asset context.
- Destination selection is explicit. A missing destination is a validation/action failure, not an implicit default.
- Recent destinations are allowed only when they were selected by the user in the session.
- Sample assets and sample destinations do not count as export completion proof.
- Headless tests should assert export state and saved resource handoff; no new analog tests are added.

## Acceptance Mapping

- Export tab/component: workspace exposes `export_asset_panel` and `export_destination_panel`.
- Export profile: workspace context exposes `export_profile` and Export tab owns that slot.
- FileDialog/recent destination: snapshot exposes Save As dialog config and recent selected destination state.
- Package/runtime handoff: export writes a `HexMapResource` and updates session export saved path.
