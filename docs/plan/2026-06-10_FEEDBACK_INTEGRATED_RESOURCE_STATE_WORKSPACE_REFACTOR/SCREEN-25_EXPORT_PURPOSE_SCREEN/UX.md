# SCREEN-25 UX

## User Goal

The user opens Export to choose a runtime handoff destination, understand that the current Level Document will become a `HexMapResource`, run export, and see the result state.

## Operation Steps

1. Open Export.
2. Confirm that Runtime Handoff is the active output type.
3. Choose a user project destination.
4. Run export.
5. Confirm the exported resource type, destination path, and result state.

## Adopted UX

- Export owns destination and output type controls.
- Runtime Handoff is the visible active export type.
- Data export, package build, and debug report are classified but not shown as production Export buttons.
- Output destination and intended runtime/API use are visible in the screen contract.
- Exported state is surfaced after writing the handoff resource.

## Deferred UX

- Package build UI remains deferred to process/final packaging work.
- Debug report export remains diagnostic, not a production export mode.
- New analog tests are deferred during CLEAN UI work.

## Existing UX Interference

- Paint must not own export management.
- Editable destination path text must remain hidden; FileDialog selection is the user destination path.
