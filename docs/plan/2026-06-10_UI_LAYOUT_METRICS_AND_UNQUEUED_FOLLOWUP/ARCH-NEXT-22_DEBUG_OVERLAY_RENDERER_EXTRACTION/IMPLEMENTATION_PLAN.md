## Scope

- Extract debug overlay immediate-mode drawing from `HexTileMapLayer` into
  `HexDebugOverlayRenderer`.
- Add one validation-focus API entry point for issue highlighting.
- Add minimal targeted tests and queue/review proofs.

## Target Files

- `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`
- `addons/hex_map_kit/adapter/hex_debug_overlay_renderer.gd`
- `addons/hex_map_kit/adapter/hex_debug_overlay_renderer.gd.uid`
- `tests/test_hex_tile_map_layer.gd`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/ARCH-NEXT-22_DEBUG_OVERLAY_RENDERER_EXTRACTION/*`
- `docs/plan/2026-06-10_UI_LAYOUT_METRICS_AND_UNQUEUED_FOLLOWUP/IMPLEMENTATION_QUEUE.md`
- `docs/review/autopilot/ARCH-NEXT-22_SELF_REVIEW_2026-06-14.md`
- `docs/review/autopilot/ARCH-NEXT-22_TEST_RESULT_2026-06-14.md`

## Planned Execution

1. Add `HexDebugOverlayRenderer` with public renderer helpers:
   - `draw_debug_overlay`
   - `draw_loop_cell_outlines`
   - `draw_hex_highlight`
   - `draw_hex_fill`
2. Update `HexTileMapLayer` overlay pipeline to pass state into renderer and remove inline private draw implementation.
3. Add `focus_validation_cells(cells, color)` public entry that normalizes highlight input and triggers redraw.
4. Add tests for:
   - validation focus path
   - parity replay against direct renderer calls
   - gameplay marker preservation when overlay draws.
5. Run `./tools/test.sh` and update queue + review docs.
