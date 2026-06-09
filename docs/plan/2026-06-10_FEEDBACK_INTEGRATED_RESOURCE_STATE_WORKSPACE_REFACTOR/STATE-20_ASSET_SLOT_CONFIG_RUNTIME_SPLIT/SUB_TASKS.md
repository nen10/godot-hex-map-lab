# STATE-20 Asset Slot Config / Runtime / Result Split Sub Tasks

## Goal

Separate Asset Slot definition, current runtime selection, validation result, sample availability, and last operation result so row UI can render from explicit ViewState instead of recombining mixed flags.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Redesign row layout now | Reject | `UI-01` owns compact/adaptive row visuals. This task creates the state contract that UI-01 can consume. |
| B. Replace `HexMapEditorAssetSlotState` with one large dictionary | Reject | A single dictionary would keep config/runtime/result coupling hidden. |
| C. Add explicit config/runtime/validation/sample/operation structures and ViewState output | Adopt | This satisfies the roadmap acceptance while keeping control code compatible. |
| D. Remove existing asset row buttons | Defer | `FB-02` already removed visible no-op controls; `UI-01` owns further row visual changes. |

## Scheduled Task

No scheduled task is required.
