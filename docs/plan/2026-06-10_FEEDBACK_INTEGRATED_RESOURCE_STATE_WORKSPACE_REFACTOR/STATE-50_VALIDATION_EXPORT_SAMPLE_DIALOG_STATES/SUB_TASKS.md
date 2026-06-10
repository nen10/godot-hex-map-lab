# STATE-50 Validation / Export / Sample / Dialog State Sub Tasks

## Goal

Expose explicit lifecycle state and ViewState for Validation, Export, Sample learning, and Dialog flows.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Add one state helper per lifecycle surface | Adopt | Validation, Export, Sample, and Dialog have different transitions and should stay separately testable. |
| B. Redesign Validate / Export / Settings screens now | Reject | This task provides state contracts; `SCREEN-23`, `SCREEN-25`, and UI tasks own later screen redesign. |
| C. Replace FileDialog lifecycle helper | Reject | Existing helper is stable; this task should expose lifecycle state snapshots around it. |
| D. Treat sample assets as normal readiness fallback | Reject | Samples remain learning/duplicate sources only. |
| E. Add analog validation/export/sample testing | Reject | CLEAN UI work does not add new analog tests unless requested. |

## Scheduled Task

No scheduled task is required.
