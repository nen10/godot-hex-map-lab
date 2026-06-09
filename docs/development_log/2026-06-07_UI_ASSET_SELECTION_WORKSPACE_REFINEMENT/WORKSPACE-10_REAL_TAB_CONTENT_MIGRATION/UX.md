# WORKSPACE-10 UX

## User Goal

Each workspace tab contains a real task surface instead of only a tab name, so users can see which project assets belong to Document, Catalog, Layers, Validate, QA, Export, and Settings.

## Operation Steps

1. Open the workspace.
2. Visit Document, Catalog, Layers, Validate, QA, Export, and Settings.
3. Each tab shows the asset slots relevant to that task.
4. Paint remains focused on painting/brush interaction rather than carrying document/catalog/layer setup responsibilities.

## Adopted UX

- Resource selection uses the existing asset slot state/control model.
- Workspace tab content shares the same workspace asset context.
- The first migration creates compact real task panels; deeper screen-specific editors remain scheduled in later SCREEN tasks.

## Deferred UX

- Rich catalog entry editing, document metadata editing, issue navigation, QA score tables, and export destination UX remain in later screen tasks.
- Public component registry hardening remains `WORKSPACE-11`.
