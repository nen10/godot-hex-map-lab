# CATUI-01 UX

## User Outcome

Generate Dock and Edit Dock should let authors choose logical catalog keys for default floor, wall, overlay, and object marker assignments. Raw `source_id / atlas_coords` fields remain visible as the advanced fallback and debug path.

## Workflow

1. The dock loads the sample catalog by default when no explicit catalog is assigned.
2. Floor, wall, overlay, and object controls expose catalog key selectors filtered by entry tags.
3. Selecting a catalog key updates the existing numeric tile controls from the entry's effective tile fields.
4. Existing numeric controls remain editable and continue to drive rendering when no catalog key is selected.
5. Overlay item pool rows can use catalog keys while preserving their existing source/atlas fields.

## Non-Goals

- Full catalog picker resource UI is not required in this task.
- Object scene instancing is deferred to object placement and object layer tasks.
- Removing numeric controls is deferred until compatibility work proves existing documents and fallback warnings.
