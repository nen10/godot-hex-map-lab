# SCREEN-21 UX

## User Goal

A developer uses Resources for Level Document state, Layers for Layer Stack roles, Export for Runtime Handoff output, and Paint only for active editing context and brush work.

## Operation Steps

1. Open Resources to create, select, save, and inspect the Level Document and dependencies.
2. Open Layers to choose a Layer Stack, inspect role rows, create missing child layers, apply the document, or clear a role.
3. Open Export to choose Runtime Handoff destination/output and run export.
4. Open Paint to see active document/target readiness and edit cells with a selected brush.

## Adopted UX

- Resources owns document save/dependency/dirty state.
- Layers owns Layer Stack role/template/create/apply/clear controls.
- Export owns Runtime Handoff destination, output type, and run/result state.
- Paint may show active document and target readiness as context, but not management controls for those workflows.

## Deferred UX

- Full Paint component extraction is deferred to `SCREEN-22` and `ARCH-41`.
- Validation workflow movement is deferred to `SCREEN-23`.
- Rich visual redesign of each tab is deferred beyond this task.
