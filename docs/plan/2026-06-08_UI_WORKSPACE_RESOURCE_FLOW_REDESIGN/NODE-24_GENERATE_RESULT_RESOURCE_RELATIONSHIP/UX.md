# NODE-24 UX

## User Goal

A game developer generates a map, understands whether the result is only a preview or a committed Level Document update, and can apply the current generated result to the selected `HexTileMap` without guessing which Resource changed.

## Operation Steps

1. Select a `HexTileMap` node in the scene.
2. Open Generate and choose `Output target`.
3. Use `Preview only` to generate a runtime preview on the target display without changing the selected node's Level Document.
4. Use `Apply to selected Document` when the current generated result should become the selected node's Level Document content.
5. Read the output status to see the selected node, target document, generated snapshot presence, and any blocking reason.
6. Return to Resources and see the selected node Level Document relationship updated through the existing resource context.

## Adopted UX

- Generate exposes an explicit `Output target` control.
- `Preview only` is the default and keeps the existing visual preview behavior.
- Applying to selected Document is an explicit command and reports success or a concise blocked reason.
- A missing selected `HexTileMap` blocks document apply with `No HexTileMap selected`.
- A selected `HexTileMap` without a Level Document blocks document apply and points the user back to Resources / Create Missing Resources.

## Rejected UX

- Generate does not silently create a Level Document in this task; creation belongs to `NODE-22`.
- Generate does not use bundled samples as an output fallback.
- The normal path does not expose raw JSON or path text for generated metadata.

## Existing UX Interference

- Existing auto-apply to TileMap/HexTileMap display remains as preview behavior because current tests and editor workflows rely on immediate visual feedback.
- Seed Lab promotion remains a separate candidate/document creation path; this task only clarifies the relationship for the current Generate result.
