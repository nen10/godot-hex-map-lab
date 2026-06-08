# UIR-01 Policy

## Adopted Decisions

- The inventory must distinguish mounted functionality from visible user comprehension.
- A component can be implemented and still fail first impression if the tab reads as a resource checklist.
- Buttons are considered suspect when the visible control has no connected workspace behavior from button press to state change.
- Root tab scroll is considered absent when the workspace page is a plain `VBoxContainer`, even if an embedded child tool has an internal `ScrollContainer`.

## Rejected Decisions

- Do not mark a tab healthy because tests can call helper APIs directly.
- Do not count bundled samples as production completion.
- Do not infer a user-facing feature from a hidden snapshot method unless the visible controls expose it.

## Resource / API / UI Boundary

- Resource/API readback confirms what state exists.
- UI inventory records what a developer can see and operate in the dock.
- Later implementation tasks decide how to restructure the UI.

## Task-Local Decisions

This task may add only docs/review artifacts and queue proof. Code, tests, and screenshots are out of scope unless needed to prove the inventory.
