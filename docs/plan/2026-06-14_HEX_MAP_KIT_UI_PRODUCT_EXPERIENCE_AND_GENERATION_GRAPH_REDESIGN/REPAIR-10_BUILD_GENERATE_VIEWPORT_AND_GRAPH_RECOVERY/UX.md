# REPAIR-10 UX

## User Story

When the user presses `Generate` in Build, the generated map appears in the Godot 2D viewport on a real `HexTileMapLayer`. The user can then keep it with `Apply` or restore the previous in-memory document with `Revert`.

## First Impression

The first proof is the viewport, not a square node-output panel. If the result cannot be projected to the viewport, the UI must not imply success.

Expected visible behavior:

1. User opens Build.
2. User presses `Generate`.
3. If a `HexTileMapLayer` is selected, that layer is used.
4. If none is selected, Build creates and selects `BuildHexMapLayer`.
5. The generated terrain/overlay appears in the Godot viewport.
6. `Apply` and `Revert` become enabled only after successful viewport projection.

## Secondary Preview

`HexMapPreviewThumbnail` is a node-output summary/cache aid. It is not the Build completion surface, and tests must not accept it as proof that the viewport result is visible.

## Layout Repair

This task only repairs layout issues that block Build operation clarity:

- Graph canvas receives the dominant space.
- Batch/commit/remove actions sit below the graph, not as a crowding strip beside or above the main work surface.
- Node labels and port labels must be readable without normal clipping.
- Button text is compact enough for the dock width.

## Failure State

If generation data exists but viewport projection fails:

- `Apply` remains disabled.
- `Revert` remains disabled unless there is a valid pending preview.
- status text names the projection failure.
- snapshot exposes the projection failure report.
