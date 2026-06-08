# TAB-50 Policy

## Adoption

- The visible tab label is `Resources`.
- Selected HexTileMap context is part of the Resources screen.
- UniqueResource, SharedResource, and OptionalResource groups are visible and have tooltips explaining purpose.
- `Create Missing Resources` remains available for selected-node unique resources.

## Boundaries

- `HexMapWorkspaceComponentRegistry` owns tab naming and component responsibility rows.
- `HexMapWorkspace` owns Resources tab mounting, snapshots, and tab query behavior.
- Existing document create/open/save APIs stay in place.

## Non-Adoption

- Do not rename runtime `HexMapDocumentResource` concepts.
- Do not move Paint/Catalog/Layers detailed editors into this task.
- Do not add new analog tests during CLEAN UI work.

## Task-Local Decisions

- `Document` may remain an internal compatibility alias for programmatic tab queries, but it is not a visible tab name.
