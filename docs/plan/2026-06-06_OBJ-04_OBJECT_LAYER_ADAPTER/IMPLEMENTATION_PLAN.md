# OBJ-04 Object Layer Adapter Implementation Plan

作成日: 2026-06-07

## Scope

- Add `HexObjectLayerAdapter` for scene-tile and direct-instance object prototype application.
- Add `HexTileMapLayer` methods for object scene tile role application and direct instance application.
- Route scene-tile object placements through `apply_document_to_layer_stack()` when a catalog and object role layer are present.
- Add tests for scene-tile object role placement and direct `PackedScene` instance placement.
- Update `docs/TEST.md`.
- Run `./tools/test.sh`.
- Write test result and self-review, then update queue proof.

## Test Path

- `tests/test_hex_tile_map_layer.gd`
- `./tools/test.sh`

## Repair Policy

Missing object role placement, direct instance placement failure, or regression of existing marker display is `repair-now`.
