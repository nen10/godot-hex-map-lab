# NODE-21 Policy

## Adopted Decisions

- `HexTileMapLayer.hex_map` remains available as runtime/display snapshot data.
- `HexMapDocumentResource` remains the canonical authoring resource.
- Edit Tool target conversion from `hex_map` creates an unsaved Level Document snapshot and must be labeled that way.
- Runtime Handoff exports a `HexMapResource` from the current Level Document.

## Rejected Decisions

- Do not remove `hex_map` in this task.
- Do not call `hex_map` "initial map" in Workspace contracts.
- Do not treat compatibility display data as authoring source of truth.

## Boundaries

- Adapter/runtime helpers may continue to use `HexMapResource`.
- Workspace and editor UI must point authoring workflows at Level Document.
- Larger `HexTileMapLayer` responsibility separation is deferred to `ARCH-50`.
