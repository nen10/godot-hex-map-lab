# RES-11 UX

## User Goal

When a Level Document is selected, the Workspace should immediately show the Tile Catalog, Object Database, Label Database, and profile resources declared by that document. The user should be able to see that those resources came from document dependencies and override any of them temporarily with an explicit project selection.

## Operation Steps

1. Select or create a Level Document in Resources.
2. Workspace reads `document.dependencies`.
3. Shared resource rows in Resources, Catalog, Validate, QA, Export, Generate, and Paint receive hydrated resources.
4. Dependency-derived rows expose `Document Dependency` as their source badge.
5. If a dependency is absent or has no resource, the row remains missing.
6. If the user selects a different project asset in a row, that manual selection remains until the context is cleared or replaced.

## Adopted UX

- Document dependency hydration is automatic on Level Document context change.
- Missing dependency state remains visible and actionable.
- Manual project override has priority over dependency rehydration.

## Rejected UX

- No bundled sample auto-selection.
- No hidden fallback path text or raw JSON dependency display in normal UI.
- No document dependency writeback in this task.
