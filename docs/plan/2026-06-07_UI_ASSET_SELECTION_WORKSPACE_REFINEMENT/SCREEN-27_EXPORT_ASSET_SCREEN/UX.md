# SCREEN-27 UX

## Intent

Make Export a first-class workspace screen for project document export, not a Paint-tab side effect or a remembered sample path.

## User Model

- Export starts with an unconfigured destination.
- The current Level Document is visible as the source asset.
- Export Profile is a project asset that can be created, selected, saved, opened, and cleared.
- Destination is selected through Save As / recent destination state, not raw editable path text.
- Export cannot run until the user selects a destination.
- Export result creates a `HexMapResource` handoff path for package/runtime use.

## Non-Goals

- Do not add sample export destinations.
- Do not make Export Profile schema-specific yet.
- Do not create analog tests during CLEAN UI work.
