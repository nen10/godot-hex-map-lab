# STATE-40 Paint Interaction State Machine Sub Tasks

## Goal

Expose Paint interaction state for target, document, brush, viewport hover, apply, dirty, validation focus, missing assets, selected cell, active brush, and layer target.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Redesign Paint tab into a brush surface now | Reject | `SCREEN-22` owns the Paint tab visual/workflow redesign. |
| B. Add explicit Paint interaction state/ViewState | Adopt | This satisfies the state-machine foundation and gives later screens a stable contract. |
| C. Rewrite viewport input adapter | Reject | Existing adapter behavior is stable; this task should expose state, not alter input semantics. |
| D. Add analog viewport tests | Reject | CLEAN UI work currently avoids new analog tests unless requested. |

## Scheduled Task

No scheduled task is required.
