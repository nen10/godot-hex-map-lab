# NODE-20 Policy

## Adopted Decisions

- Binding ownership is service-owned: Workspace asks the service to resolve, hydrate, and write.
- Node-owned slots are `level_document` and `layer_stack`.
- Shared dependency slots are Tile Catalog, Object DB, Label DB, Movement Profile, Validation Suite, Generation Profile, and Export Profile.
- Shared dependency writeback requires a selected Level Document.
- Dependency read/write uses `HexMapDocumentDependencyService`.

## Rejected Decisions

- Do not add shared resources as new direct exports on `HexTileMapLayer`.
- Do not mutate `hex_map` as an authoring fallback.
- Do not preserve old "shared context only" behavior once a selected document exists.

## Boundaries

- Service: pure binding and ownership decisions.
- Workspace: state orchestration, screen refresh, and child component sync.
- `HexTileMapLayer`: still stores node-owned exports and runtime/display behavior.

## Task-local Open Decisions

- If a shared resource is selected while no Level Document exists, return a blocked writeback result and keep the Workspace context selection visible.
