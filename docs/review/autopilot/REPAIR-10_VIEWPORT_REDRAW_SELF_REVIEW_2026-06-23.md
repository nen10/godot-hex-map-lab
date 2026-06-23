# REPAIR-10 viewport redraw follow-up self-review

Date: 2026-06-23
Branch: `autopilot/ui`

## Issue

User reported that the Build tab button sequence `Generate -> Apply -> Generate` makes the generated map visible, but the expected behavior is that the first `Generate` makes the generated result visible in the viewport.

This is not an origin/scale issue. Existing projection reports could be true because cells were written to the `TileMapLayer`, while the first editor viewport render could still miss the freshly-written internal tilemap update.

## Change

Changed `addons/hex_map_kit/adapter/hex_tile_map_layer.gd`:

- `_queue_visual_redraw()` now refreshes the actual child `TileMapLayer` renderers, not just the parent `Node2D` and overlay canvas.
- Added a coalesced deferred redraw pass so first-write editor rendering gets a second update after the current call stack.
- The refresh calls:
  - `queue_redraw()`
  - `notify_runtime_tile_data_update()`
  - `update_internals()`
- The fix does **not** force layer visibility. A first attempt to set `tile_map.visible = true` regressed layer visibility tests and was removed.

## Scope

This is a targeted rendering refresh fix. It does not change graph generation, document promotion, Apply/Revert state, layer ordering, or Result semantics.

## Risk review

- Visibility state remains owned by the layer stack / editor UI; this patch does not override it.
- Deferred redraw is coalesced by `_visual_redraw_deferred` to avoid scheduling repeated redraws during one redraw cycle.
- Existing headless tests still validate projection state; GUI visual probe validates actual rendered pixels.
