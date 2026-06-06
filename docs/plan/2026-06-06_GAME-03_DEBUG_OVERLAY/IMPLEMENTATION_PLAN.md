# GAME-03 Implementation Plan

Date: 2026-06-07

## Steps

1. Mark `GAME-03` as `RUNNING` in the queue.
2. Add `HexTileMapLayer` movement range overlay state, draw, clear, and inspection helpers.
3. Add generated-map debug scene range toggle, summary text, heat drawing, and headless getters.
4. Add `tests/test_hex_tile_map_layer.gd` coverage for overlay cost/color state and clear behavior.
5. Add `tests/test_debug_scenes.gd` coverage for generated debug scene range state.
6. Update `docs/TEST.md`.
7. Run `./tools/test.sh`, self-review, repair if needed, update queue proof, and commit.
