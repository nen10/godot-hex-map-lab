# CLEANUP-31 UX

## Intent

Normal authoring should use asset, definition, enum, and property-schema controls instead of raw text fields.

## Target Fields

- Overlay item key: catalog/known item selector.
- Label ID: Label Definition selector.
- Object variant: enum selector.
- Spawn condition: enum selector.
- Object property key/value: typed property editor from definition/default schema.

## Non-Goals

- Do not remove internal payload state or tests that need direct helper calls.
- Do not create analog tests during CLEAN UI work.
- Do not design a full object variant schema Resource in this task.
