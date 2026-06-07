# SCREEN-25 UX

## User Goal

A project author runs validation from the Validate tab and sees missing project assets as actionable issues routed to the screen that owns the missing asset.

## Operation Steps

1. Open the Workspace `Validate` tab.
2. Confirm the target Level Document and optional Validation Rule Suite.
3. Run validation.
4. Review issue rows with severity, message, and fix target.
5. Navigate to Document, Catalog, Object/Label, Layers, Validate, or QA depending on the issue.

## Adopted UX

- Missing project assets are first-class validation issues.
- Issue rows expose stable routing fields, not only prose.
- Bundled sample assets are not injected to make validation pass.

## Deferred UX

- Visual issue navigator row selection/focus is kept as state contract in this task.
- Custom Validation Rule Suite semantics remain later work; this task treats the suite as a selected project asset slot.

## Removed UX

- Treating missing catalog/object/layer assets as sample fallback.
- Reporting missing assets without a fix target.
