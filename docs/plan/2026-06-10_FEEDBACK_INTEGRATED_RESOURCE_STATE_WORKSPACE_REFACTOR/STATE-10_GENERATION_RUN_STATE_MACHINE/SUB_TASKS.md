# STATE-10 Generation Run State Machine Sub Tasks

## Goal

Move Generate run progress, cancel, debounce, apply, dirty/result, and block/error state behind one explicit run state and ViewState surface.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Replace all `_generation_*` private fields immediately | Reject | Too much risk in one slice; keep fields as compatibility mirrors while making the state model authoritative for snapshots/ViewState. |
| B. Add a small `HexMapGenerationRunState` helper | Adopt | This creates a focused state boundary for later cleanup without changing generation algorithms. |
| C. Route Generate tab controls through a ViewState snapshot | Adopt | Acceptance requires state -> ViewState rendering. |
| D. Redesign Generate layout / empty space | Defer | `UI-03` owns Generate visual repair after the state model exists. |

## Scheduled Task

No scheduled task is required.
