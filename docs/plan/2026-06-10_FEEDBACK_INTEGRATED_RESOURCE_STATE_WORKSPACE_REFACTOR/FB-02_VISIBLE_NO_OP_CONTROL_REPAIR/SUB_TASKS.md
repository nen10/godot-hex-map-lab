# FB-02 Sub Tasks

## Task Resolution

task resolution:

- task candidate: remove Resource row Details button
  - goal / UX: Resource rows should not expose a visible `Details` action when the detail surface is not a real user workflow.
  - decision: adopt in this task.
  - summary: Remove the visible asset slot `Details` button from the compact row while keeping tooltip/status snapshots testable.
- task candidate: repair disabled button explanations
  - goal / UX: Disabled controls should explain the missing condition directly on hover.
  - decision: adopt in this task.
  - summary: Add tooltip state for disabled Export and Missing Unique Resources actions.
- task candidate: delete all functional Open/Validate actions in Paint/Edit Tool
  - goal / UX: Eventually move non-paint responsibility out of Paint.
  - decision: defer.
  - summary: Catalog, Layer, Document, and Export control migration belongs to later screen/state tasks. `FB-02` only removes visible no-op or placeholder controls.
- task candidate: redesign all Resource rows into the final compact row spec
  - goal / UX: First impression should be cleaner than the current debug-heavy row shape.
  - decision: defer to `UI-01`.
  - summary: `FB-02` removes the explicit no-op surface. Full compact/adaptive row redesign remains a planned task.

## Scheduled Tasks

No new Scheduled task is added by this task.

Reason:

- Paint/Edit Tool responsibility moves are already covered by `SCREEN-20`, `SCREEN-21`, and `SCREEN-22`.
- Full Resource row redesign is already covered by `UI-01_RESOURCE_ROW_REDESIGN`.

## Completion Boundary

`FB-02` is complete when:

- Asset slot rows no longer render a visible `Details` button.
- Visible Select/Open/Validate placeholder actions remain absent from workspace asset rows and sample settings.
- Disabled Export and Missing Unique Resources controls expose condition tooltips.
- Targeted editor tests and `./tools/test.sh` pass.
