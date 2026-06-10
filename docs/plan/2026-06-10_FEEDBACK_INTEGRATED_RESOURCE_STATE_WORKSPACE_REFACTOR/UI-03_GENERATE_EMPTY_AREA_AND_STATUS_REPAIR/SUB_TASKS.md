# UI-03 Generate Empty Area and Status Repair Sub Tasks

## Goal

Repair the Generate screen first impression by making run/output result state visible, removing unexplained empty-state reservation when generation is ready, and clarifying source reload purpose.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Add Generate screen result summary ViewState | Adopt | The Workspace snapshot should answer preview/apply/document/save state without forcing debug inspection. |
| B. Hide empty-state text when Generate is unblocked | Adopt | A blocked empty state is useful; an unblocked blank/placeholder area reads as dead space. |
| C. Clarify mapdata source Reload action | Adopt | Reload re-reads the same source file to refresh query data; the label/tooltip should say that. |
| D. Redesign all generation parameters into a new component | Reject | Too broad for UI-03 and would overlap later screen/component extraction. |
| E. Remove Save As `.tres` | Reject | Save is a real output action; this task should expose its state, not remove the command. |
| F. Add analog UI test | Reject | CLEAN UI work does not add new analog tests unless requested. |

## Scheduled Task

No scheduled task is required.
