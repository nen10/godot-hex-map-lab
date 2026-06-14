## Complexity

Class: C2

Reason:
- The extraction is isolated to debug overlay rendering behavior and does not change
  gameplay computation paths, but it spans the draw-state flow and a new test file slice.

## Candidate Resolution

| candidate | goal / UX | decision |
|---|---|---|
| Keep debug overlay code in `HexTileMapLayer` | minimize edits | reject |
| Extract `HexDebugOverlayRenderer` and route all immediate-mode overlay drawing through it | preserve behavior while isolating debug rendering | adopt |
| Remove debug overlay rendering entirely from runtime drawing and move to editor only | simplify runtime | reject |

## Adopted Sub-Tasks

| sub-task | scope | proof |
|---|---|---|
| `ARCH-NEXT-22.01` | Create `addons/hex_map_kit/adapter/hex_debug_overlay_renderer.gd` with all immediate-mode highlight/path/range/outline drawing | new renderer + tests |
| `ARCH-NEXT-22.02` | Delegate `HexTileMapLayer._draw_overlay` and `_draw_loop_cell_outlines` to renderer state machine | changed layer API flow |
| `ARCH-NEXT-22.03` | Add `focus_validation_cells(cells, color)` entry point for Validate/debug issue highlighting | layer public API |
| `ARCH-NEXT-22.04` | Add regression tests for focus-path, parity, and marker-rendering preservation | `tests/test_hex_tile_map_layer.gd` assertions |
| `ARCH-NEXT-22.05` | Update plan proof docs and queue completion entry | queue/docs updates |
