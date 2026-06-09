# STATE-30 Workspace Selection Binding State Sub Tasks

## Goal

Make workspace target selection, document binding, dependency hydration, manual override, writeback, applied writeback, and conflict state explicit so Workspace screens can render one selection/binding ViewState.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Redesign Resources tab around the new state | Reject | `SCREEN-10` owns Resources tab UX after state contracts exist. |
| B. Add a focused workspace binding state helper | Adopt | A helper keeps selection/writeback state separate from UI rendering and existing services. |
| C. Replace binding service behavior | Reject | `NODE-20` already created the binding service; this task should surface state, not rewrite ownership. |
| D. Remove auto-link behavior | Reject | Acceptance requires auto-link without a manual link button. |

## Scheduled Task

No scheduled task is required.
