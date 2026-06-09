# STATE-00 UI Flag Inventory And Contract Sub Tasks

## Goal

Inventory the UI flags and ad hoc state combinations that distort workspace behavior, then classify state-machine conversion priorities for the later STATE tasks.

## Task Resolution

| candidate | decision | notes |
|---|---|---|
| A. Inventory only the named roadmap areas | Adopt | The acceptance names Generate, Workspace binding, asset slots, Paint, Validation, Export, Sample learning, and Dialog lifecycle. |
| B. Refactor flags directly in this task | Reject | Later STATE tasks own implementation; this task is the contract that keeps those refactors coherent. |
| C. Preserve all existing UI tests | Reject | Old shape tests may be rewritten or deleted when they encode bad UX. |
| D. Record old-test disposition by area | Adopt | This gives later tasks a clear rule for keep / rewrite / delete decisions. |

## Scheduled Task

No scheduled task is required.
