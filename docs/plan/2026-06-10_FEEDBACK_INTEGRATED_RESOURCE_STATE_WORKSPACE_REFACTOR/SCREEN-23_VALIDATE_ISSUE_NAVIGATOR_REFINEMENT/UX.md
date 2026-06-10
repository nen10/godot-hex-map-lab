# SCREEN-23 UX

## User Goal

A developer runs validation from Validate, scans issues by severity/scope/domain, selects an issue, and is routed to the tab or cell that can fix it.

## Operation Steps

1. Open Validate.
2. Run workspace validation.
3. Review issue count, severity, domain/scope, focus target, and fix suggestion.
4. Select an issue.
5. Validate routes to Resources, Catalog, Layers, Paint, or Validate depending on the fix target.

## Adopted UX

- Validate owns the workflow-level Run Validation action.
- Validate owns issue list, severity/scope/focus metadata, and selected issue state.
- Issue selection applies tab/resource/cell focus metadata.
- Slot-level Validate buttons remain absent.

## Deferred UX

- Rich table widgets and per-issue buttons are deferred.
- Component extraction is deferred to `ARCH-41`.
