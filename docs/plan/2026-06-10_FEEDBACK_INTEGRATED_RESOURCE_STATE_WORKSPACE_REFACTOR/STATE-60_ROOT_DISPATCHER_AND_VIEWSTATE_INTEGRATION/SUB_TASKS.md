# STATE-60 Root Dispatcher / ViewState Integration Sub Tasks

## Goal

Integrate the state-machine surfaces from STATE-10 through STATE-50 into a Workspace root state, dispatcher boundary, and debug-report source.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Add Workspace root state aggregation | Adopt | This gives later screens one state snapshot instead of recombining tab flags. |
| B. Add a dispatcher boundary for root events | Adopt | Dispatcher should route a small set of current Workspace events without redesigning behavior. |
| C. Rewrite all tab rendering to new components | Reject | `ARCH-41` and screen tasks own component extraction and visual redesign. |
| D. Replace existing per-screen snapshots | Reject | Existing tests depend on them; root state should compose them first. |
| E. Add analog UI verification | Reject | CLEAN UI work does not add new analog tests unless requested. |

## Scheduled Task

No scheduled task is required.
