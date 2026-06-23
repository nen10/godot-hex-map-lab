# REPAIR-10 terrain layer pick follow-up self-review

Date: 2026-06-23
Branch: `autopilot/ui`

## Issue (user reported)

1. With no dock-referenced TileMapLayer, pressing Generate does not show tiles on the first press.
2. While generated tiles are visible, clicking the referenced TileMapLayer in the scene tree (focus change) makes the tiles disappear.

Both recover on the next Generate.

(A third report, node parameters always resetting to initial values, is intentionally deferred; it needs dedicated node state management.)

## Root cause

`HexMapDocumentAdapter._document_map_resource()` returned the first terrain layer that has a non-null `map`, ignoring whether that map has cells.

The Build preview path (`HexMapBuildScreen._viewport_document_snapshot` /
`_viewport_ordered_terrain_layers`) reorders non-empty generated terrain to the front,
so the preview renders. But any direct `apply_document(level_document_resource)` that runs
through the layer setter, `_ready`, or workspace selection re-sync does NOT reorder, so an
empty/placeholder terrain layer placed before the generated terrain wins and the viewport
renders nothing. Re-running Generate re-applies the reordered snapshot, which is why the
tiles reappear.

## Change

`addons/hex_map_kit/adapter/hex_map_document_adapter.gd`:

- `_document_map_resource()` now prefers the first terrain layer whose map has cells.
- It falls back to the first non-null map when no terrain layer has cells (unchanged behavior for empty documents).
- Added helper `_map_resource_has_cells()`.

This makes document-to-map resolution consistent across every apply path
(preview, setter, `_ready`, selection re-sync), independent of the Build-screen-only reorder.

## Scope

Adapter-level resolution fix plus one regression test. No change to graph generation,
promotion, Apply/Revert, or Result semantics.

## Verification

- New unit test in `tests/test_hex_adapter.gd`:
  `_test_hex_map_document_prefers_nonempty_terrain_layer`.
- `tests/test_generation_promote.gd`: pass.
- Full `./tools/test.sh`: pass.

## Remaining / honest limitations

- Report #1 (no dock-referenced layer, first Generate) is expected to improve from this fix
  when the failure was empty-terrain masking, but it may also involve editor scene/selection
  context that requires interactive confirmation in the Godot editor.
- Report #3 (node params reset) is deferred to a future node-state task.
