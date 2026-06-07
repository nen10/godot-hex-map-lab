# LST-02 Implementation Plan

## Scope

Add `HexTileMapLayer.apply_document_to_layer_stack()`, role child lookup/creation helpers, tests, `docs/TEST.md` update, full test run, self-review, queue proof, and commit.

## Steps

1. Preload `HexLayerStackResource` in `hex_tile_map_layer.gd` and add an exported stack resource reference.
2. Add `apply_document_to_layer_stack(document, stack, options)` and `layer_for_stack_role(role)` helpers.
3. Create or reuse stack child nodes by layer entry `node_name`; map terrain and overlay roles to active TileMapLayer children.
4. Apply the document through existing map/payload drawing paths so object/label state remains compatible.
5. Extend `tests/test_hex_tile_map_layer.gd` with v2 terrain/overlay role routing and plain `TileMapLayer` compatibility checks.
6. Update `docs/TEST.md`.
7. Run `./tools/test.sh`; repair failures in-task.
8. Write `docs/review/autopilot/LST-02_SELF_REVIEW_2026-06-07.md`, update queue proof, and commit.
