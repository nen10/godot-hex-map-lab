# NODE-21 UX

## User Goal

Users should understand that the Level Document is the map they author, validate, save, and export. `HexTileMapLayer.hex_map` is visible only as runtime/display snapshot data used for preview, import, or handoff.

## Operation Steps

1. Select a `HexTileMapLayer`.
2. Resources reports Level Document authoring status separately from runtime display snapshot status.
3. Paint/Edit reports document source as Level Document, selected document, or temporary target snapshot conversion.
4. Runtime handoff remains `HexMapResource`, but it is output from the Level Document, not the authoring source.

## Adopted UX

- Level Document is named as canonical authoring source.
- Target-derived documents are described as temporary target snapshot conversions.
- `hex_map` state is exposed as runtime display snapshot state.

## Rejected UX

- No "runtime initial map" authoring language.
- No UI that implies `hex_map` replaces Level Document.
