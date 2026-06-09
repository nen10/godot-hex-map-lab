# ASSET-12 Implementation Plan

## Scope

Add reusable asset-slot Resource creation helpers, Save As dialog hooks, context assignment, and tests.

## Files

- `addons/hex_map_kit/editor/hex_map_workspace_asset_resource_factory.gd`
- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `ASSET-12` `RUNNING`.
2. Implement slot id to Resource creation mapping.
3. Implement save helper that writes `.tres` resources and assigns the created resource to context.
4. Add asset slot Save As dialog construction and create path signal.
5. Add headless tests for all supported resource types, context assignment, default file names, and sample exclusion.
6. Update `docs/TEST.md`.
7. Run `./tools/test.sh`.
8. Self-review, repair, update queue proof, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Asset slots can surface a `Create New...` Save As path.
- [x] Level Document, Tile Catalog, Object DB, Label DB, Layer Stack, Movement Profile, Validation Suite, and Generation Profile can be created.
- [x] Created resources are saved and assigned to workspace asset context.
- [x] Created resources do not silently include bundled sample assets.
- [x] Queue proof and next READY task are clear.
