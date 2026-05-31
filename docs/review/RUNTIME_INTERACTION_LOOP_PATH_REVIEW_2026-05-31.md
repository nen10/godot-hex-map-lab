# RUNTIME_INTERACTION_LOOP_PATH Review 2026-05-31

## Findings

- P2: debug overlay / path / cell-hit draw calls were inside the per-cell draw loop. Fixed by moving those calls after the base cell loop.
- P2: debug cell-hit offset could diverge from rendered cells when symmetry overlay expanded the map bounds. Fixed by sharing the same symmetry-equivalence offset inputs.
- P2: toric representative search used display rect size but not rect position. Fixed by sizing the candidate period search from rect extents and adding a far-from-origin rect test.

## Verification

- `HexTileMapLayer` exposes runtime click / hover signals and detailed hit dictionaries.
- `local_to_cell_hit()` separates canonical `hex` from `visual_hex`; toric mode wraps and infinite mode keeps visual identity.
- `visual_representatives_for_cell()`, `visual_path_for_canonical_path()`, and `draw_loop_path()` cover toric visual representatives.
- Local connected-component helpers use canonical hit/cell behavior.
- Debug scene exposes loop path and cell-hit states.
- `./tools/test.sh` passes.

## Residual Risk

Loop tile copies are still drawn as runtime outlines, not duplicated TileMapLayer cells. This matches the initial implementation scope.
