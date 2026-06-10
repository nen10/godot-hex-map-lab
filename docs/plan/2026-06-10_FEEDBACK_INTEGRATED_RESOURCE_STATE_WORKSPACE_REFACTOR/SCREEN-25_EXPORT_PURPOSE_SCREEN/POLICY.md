# SCREEN-25 Policy

## Adopted Decisions

- Export screen snapshots must identify Export as the workflow owner.
- The active output type is `runtime_handoff_resource`.
- Runtime Handoff writes the current Level Document as a runtime/API `HexMapResource`.
- Data export, package build, and debug report are classified but not exposed as normal Export actions.
- Export state must show blocked, ready, and exported result state through `HexMapExportWorkflowState`.

## Rejected Decisions

- Do not add visible package or debug export buttons as placeholder controls.
- Do not expose an editable raw destination path text box.
- Do not use sample destinations or bundled samples as completion proof.

## Resource / API / UI Boundary

- Resource: Level Document remains the source; Export Profile is an optional concrete resource.
- API: Export snapshot and output type context expose purpose, readiness, destination, and result state.
- UI: Export chooses destination and runs runtime handoff; package build remains process-owned.

## Compatibility

The addon is unpublished, so screen snapshot contract fields can be added directly.
