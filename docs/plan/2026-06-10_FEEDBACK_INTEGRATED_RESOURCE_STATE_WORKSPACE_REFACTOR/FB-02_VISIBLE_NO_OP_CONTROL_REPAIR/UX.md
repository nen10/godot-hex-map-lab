# FB-02 UX

## User Goal

When a developer opens the Workspace, every visible button should either perform a real state change or clearly explain why it is disabled. Resource rows should not ask the developer to inspect a `Details` button that only expands implementation trivia.

## Operation Steps

1. User opens Workspace and inspects Resource rows.
2. Required resource rows show status and real actions such as creating or learning from a sample.
3. Missing or unconfigured states are communicated by status/tooltip, not by placeholder buttons.
4. User opens Export or Missing Unique Resources panels.
5. A disabled action exposes the missing prerequisite through tooltip text.
6. A visible enabled action changes selection, creates resources, duplicates a sample, or performs export work.

## Adopted UX

- Remove visible `Details` from Resource rows.
- Keep user-facing status available through existing row labels/tooltips and snapshots.
- Disabled buttons must state their unmet condition.
- Existing real actions such as `Create New...`, `Learn With Sample`, `Duplicate To Project`, destination selection, and runtime handoff remain available.

## Retained UX

- Programmatic row snapshots may still expose detail state for tests/debugging.
- Functional Paint/Edit Tool actions are retained until the task-centric screen migration removes or relocates them.
- Sample learning remains explicit and never a silent default.

## Removed Or Deferred UX

- Removed: Resource row visible `Details` button.
- Deferred: full Resource row compact/adaptive redesign to `UI-01`.
- Deferred: moving Catalog/Layer/Document/Export controls out of Paint to the relevant screen tasks.
- Deferred: analog visual testing.

## Existing UX Interference

Older tests that assert the presence of a visible `Details` button describe the old placeholder UI, not the roadmap target. They should be updated to assert the button is absent and the remaining state is discoverable through tooltip/snapshot contracts.
