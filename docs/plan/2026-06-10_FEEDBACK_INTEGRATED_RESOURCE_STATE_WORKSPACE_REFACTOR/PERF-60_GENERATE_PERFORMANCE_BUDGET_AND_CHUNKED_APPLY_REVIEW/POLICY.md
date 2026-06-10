# PERF-60 Policy

## Adopted Decisions

- Use the 2026-06-08 measured profile as baseline timing evidence and update the decision with current source-path review.
- Classify costs separately for generation core, validation, direct TileMap apply, `HexTileMapLayer` preview apply, selected-document apply, layer-stack apply, and global display updates.
- Treat orientation, tile size, TileSet/catalog changes, loop display, and output apply as global updates when they can redraw most visible cells.
- Require chunked apply before large-map support is considered smooth.

## Rejected Decisions

- Do not treat threaded generation as proof that Generate is responsive end to end.
- Do not rely on debounce alone for large maps; debounce reduces repeated work but does not make one large apply cheap.
- Do not implement chunking in this review slice.
- Do not add analog tests during CLEAN UI work.

## Resource / API / UI Boundary

- Resource/API: budget decisions describe when generated map data, Level Document data, validation data, and scene-tree apply should be separated.
- UI: progress/busy/cancel decisions must be driven by `HexMapGenerationRunState` / Generate ViewState, not scattered private flags.
- Scene tree: TileMap and object instance mutation remains main-thread work and therefore defines the chunking boundary.

## Compatibility

The addon is unpublished, so the budget can require future API cleanup. Runtime helper value remains important, but not at the cost of leaving large main-thread apply paths unbounded.
