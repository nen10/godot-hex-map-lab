# GAME-03 Policy

Date: 2026-06-07

## Decisions

- The overlay stores canonical cell keys, cells, accumulated costs, and resolved colors so visual state can be tested headlessly.
- Range heat uses existing `HexTileMapLayer` overlay drawing rather than adding a new scene layer type.
- Existing path and highlight overlays stay independent; movement range can be cleared without clearing path or highlights.
- The generated-map debug scene gets a Range toggle and getters, but no new persistent resource schema.

## Repair classification

- `repair-now`: range overlay missing reachable cells, missing cost data, stale overlay after map changes, broken existing path/highlight drawing, or failing `./tools/test.sh`.
- `follow-up-ready`: richer editor controls, labels, legends, or profile validation beyond the accepted debug overlay.
- `manual-optional`: visual polish of the heat ramp.
