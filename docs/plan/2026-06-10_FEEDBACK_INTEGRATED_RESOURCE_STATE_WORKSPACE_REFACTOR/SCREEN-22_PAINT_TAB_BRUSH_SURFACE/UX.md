# SCREEN-22 UX

## User Goal

A developer opens Paint and immediately sees what brush will be applied, which target receives edits, which cell is selected, and what the last edit did.

## Operation Steps

1. Open Paint before setup and see a clear empty state with the next missing action.
2. Select project resources and target context from responsible tabs.
3. Open Paint and choose a brush mode/key.
4. Click a cell in the viewport.
5. Confirm Paint updates selected cell and last edit state.

## Adopted UX

- Paint owns the editing surface: active brush, target layer, selected cell, last edit, and undo hint.
- Paint empty state points to the missing setup action without becoming a Resource picker screen.
- Viewport editing updates Paint state visibly.
- Paint is not resource-reference-only after Catalog/Layer/Document/Export controls move out.

## Deferred UX

- New visual layout component extraction is deferred to `ARCH-41`.
- Additional viewport affordance polish is deferred beyond this task.
