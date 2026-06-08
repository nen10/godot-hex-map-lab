# NODE-20 Policy

## Adopted Decisions

- Use `HexTileMapLayer` as the current implementation class for the roadmap's HexTileMap authoring node language.
- `Level Document` is a UniqueResource for the selected node.
- `Node Layer Stack Instance` is a UniqueResource for the selected node; shared templates may seed it, but the active stack belongs to the node context.
- `TileSet`, `Tile Catalog`, `Object Database`, `Label Database`, `Movement Profile`, `Generation Profile`, `Validation Rule Suite`, and `Export Profile` are SharedResource candidates.
- `HexMapResource` / generated map snapshot is OptionalResource unless a future task explicitly defines it as a committed runtime initial state.

## Rejected Decisions

- Do not silently create shared resources when a node is selected.
- Do not make sample resources node defaults.
- Do not treat every available profile as required selected-node setup.
- Do not use `hex_map` runtime data as the primary authoring document replacement.

## Breaking Change Rationale

The addon is unpublished, and this roadmap prioritizes editor clarity. Future tasks may add or rename exported references on the authoring node if that is cleaner than preserving older dock-only state.

## Resource / API / UI Boundary

- Node-owned resources describe the selected map instance.
- Shared resources describe reusable project tools or libraries.
- Optional resources describe feature-specific or derived state.
- UI grouping should follow this classification even before the node has all final exported fields.

## Task-Local Decisions

The ownership policy documents current implementation gaps instead of guessing a partial writeback design. Later tasks decide exact exported field names and writeback behavior.
