# UI-01 Resource Row Redesign Sub Tasks

## Goal

Redesign Resource rows so first impression is compact/adaptive, state-driven, and free of filepath/debug/internal normal text.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Replace visible status words with icon/swatch + tooltip | Adopt | This directly satisfies the UI-00 Resource row spec without adding icon-library dependency. |
| B. Convert row layout to adaptive two-line structure | Adopt | Narrow docks should keep role/status readable and move picker/actions to the second line. |
| C. Keep existing state snapshots and picker behavior | Adopt | STATE-20 contract is stable and should remain the source of truth. |
| D. Keep hidden detail labels as an optional detail surface | Adopt | There is no visible Details button; tests can still expand details programmatically. |
| E. Remove ResourcePicker | Reject | Picker is the primary project asset selection UI. |
| F. Implement Settings label cleanup | Reject | UI-02 owns Settings labels/debug text. |
| G. Move screen ownership controls | Reject | SCREEN tasks own tab responsibility migration. |
| H. Add analog UI test | Reject | CLEAN UI work does not add new analog tests unless requested. |

## Scheduled Task

No scheduled task is required.
