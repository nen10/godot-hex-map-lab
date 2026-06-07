# SCREEN-21 Implementation Plan

## Scope

Make the Catalog tab manage Tile Catalog project assets, TileSet assignment, validation, and entry creation from selected resources.

## Files

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `SCREEN-21` `RUNNING`.
2. Add Catalog screen snapshot and action helpers.
3. Support project catalog create / open / save as / clear / validate.
4. Support assigning arbitrary TileSet resources.
5. Support atlas entry creation from TileSet selection.
6. Support scene entry creation from PackedScene selection.
7. Add headless tests for project catalog flow and sample mode isolation.
8. Update `docs/TEST.md`.
9. Run `./tools/test.sh`.
10. Self-review, repair, update queue proof, unlock dependencies, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Arbitrary project Tile Catalog can be created and selected.
- [x] Arbitrary TileSet can be assigned to the catalog.
- [x] Sample catalog is hidden while sample mode is OFF.
- [x] Atlas entry creation starts from TileSet selection.
- [x] Scene entry creation starts from PackedScene selection.
- [x] Catalog can be opened, saved as, cleared, and validated.
- [x] Queue proof and next READY task are clear.
