# PERF-60 UX

## User Goal

Generate, preview, orientation/tile setting changes, validation, and apply-to-document should stay responsive enough that users understand what is happening before the editor appears frozen.

## Operation Steps

1. User changes Generate shape, size, seed, overlay, tile settings, or output target.
2. Generate core work runs with progress/cancel when it can be long.
3. Validation, preview apply, selected-document apply, and global redraw steps expose busy state when they can exceed interaction budget.
4. Orientation and tile settings changes debounce repeated input before applying the latest visible result.
5. Large map apply is treated as a candidate for chunking rather than a single invisible main-thread write.

## Adopted UX

- Tiny maps may update inline without extra ceremony.
- Small maps should show short busy/progress state only when the operation can be perceptibly delayed.
- Medium and large maps must keep progress/status visible across validation and apply, not only during core generation.
- Cancellation is required for the threaded generation core, and unavailable for synchronous apply until chunking is implemented.
- Debounce state is part of the UX for global tile/orientation changes.

## Deferred UX

- Chunked apply controls are not implemented in this task.
- Large-map validation progress is not implemented in this task.
- No new analog/manual observation document is created.

## Existing UX Interference

- Main-thread TileMap writes, `HexTileMapLayer._redraw()`, loop display refresh, object placement, and validation traversal can still block a frame.
- Current progress state can describe validation/apply work, but it cannot interrupt a synchronous apply once that pass has started.
