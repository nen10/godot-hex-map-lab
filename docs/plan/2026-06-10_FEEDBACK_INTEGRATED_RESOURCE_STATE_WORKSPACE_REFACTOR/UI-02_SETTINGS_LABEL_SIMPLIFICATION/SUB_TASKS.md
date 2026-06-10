# UI-02 Settings Label Simplification Sub Tasks

## Goal

Remove redundant boolean/debug/path text from Settings normal UI while preserving explicit sample/debug controls and diagnostic snapshots.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Hide Workspace debug enabled/disabled label | Adopt | The debug checkbox already communicates state; the label is redundant normal UI. |
| B. Move sample asset paths from visible row labels to tooltips/snapshots | Adopt | Sample rows are learning assets, but paths are detail/debug information. |
| C. Move duplicate-result path from visible status to tooltip/snapshot | Adopt | The state change should be visible without making filepath the first impression. |
| D. Remove sample/debug CheckBoxes | Reject | They are real explicit opt-ins and the desired boolean UI control. |
| E. Rework sample duplication flow | Reject | The flow is functional; this task only simplifies visible labels. |
| F. Add analog UI test | Reject | CLEAN UI work does not add new analog tests unless requested. |

## Scheduled Task

No scheduled task is required.
