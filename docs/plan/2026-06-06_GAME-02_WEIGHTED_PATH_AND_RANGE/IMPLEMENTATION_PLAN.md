# GAME-02 Implementation Plan

Date: 2026-06-07

## Steps

1. Mark `GAME-02` as `RUNNING` in the queue.
2. Add weighted path and movement range primitives to `HexGrid`.
3. Add movement cost dictionary extraction to `HexGameplayLayerData`.
4. Add `HexTileMapLayer` runtime query helpers:
   - `gameplay_layer_data(movement_profile = null)`
   - `find_weighted_path(start, goal, movement_profile = null)`
   - `movement_range(start, movement_budget, movement_profile = null)`
5. Add core tests for weighted path selection, range budget limits, blocked cells, and unweighted compatibility.
6. Add `HexTileMapLayer` tests for profile-specific wall behavior.
7. Update `docs/TEST.md`.
8. Run `./tools/test.sh`, write test result and self-review, update queue proof, and commit.
