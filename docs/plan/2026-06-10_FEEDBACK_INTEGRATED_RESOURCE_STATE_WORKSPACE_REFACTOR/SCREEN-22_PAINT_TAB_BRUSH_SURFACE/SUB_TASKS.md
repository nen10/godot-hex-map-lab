# SCREEN-22 Paint Tab Brush Surface Sub Tasks

## Goal

Make Paint read as an editing surface with active brush, target layer, selected cell, and last edit state instead of a fallback Resource reference area.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Paint exposes empty state and next action state | Adopt | Existing empty-state machinery can be made part of the contract. |
| B. Paint exposes active brush summary | Adopt | Brush mode/key/readiness is the core paint action. |
| C. Paint exposes target layer summary | Adopt | Paint needs an editable target context. |
| D. Paint exposes selected cell and last edit summary | Adopt | Viewport edits must visibly update Paint state. |
| E. Paint proves it is not resource-reference-only | Adopt | This is the acceptance guard after moving non-paint controls away. |
| F. Build new analog UI test | Reject | CLEAN UI work does not add new analog tests unless requested. |
| G. Extract Paint component into a new script now | Reject | Extraction belongs to `ARCH-41`; this task strengthens screen state and visible summary. |

## Scheduled Task

No scheduled task is required.
