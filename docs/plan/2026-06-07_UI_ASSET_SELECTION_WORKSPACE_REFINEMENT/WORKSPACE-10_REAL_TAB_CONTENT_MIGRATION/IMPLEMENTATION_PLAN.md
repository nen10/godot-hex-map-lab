# WORKSPACE-10 Implementation Plan

## Scope

Mount real workspace content into the non-empty responsibility tabs and expose state-based query helpers for tests.

## Files

- `addons/hex_map_kit/editor/hex_map_workspace_asset_panel.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `WORKSPACE-10` `RUNNING`.
2. Add reusable asset panel component for workspace tabs.
3. Mount Document / Catalog / Layers / Validate / QA / Export asset panels.
4. Register Generate / Paint / Settings components for public workspace queries.
5. Add `tab_has_component()`, `asset_slot_count()`, and `tab_asset_slot_ids()`.
6. Add headless tests for non-empty tabs, tab-owned asset slots, shared context, and Paint focus.
7. Update `docs/TEST.md`.
8. Run `./tools/test.sh`.
9. Self-review, repair, update queue proof, unlock dependencies, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Document / Catalog / Layers / Validate / QA / Export / Settings tabs are non-empty.
- [x] Document / Catalog / Layers / Validate / QA / Export / Settings expose owned asset slot counts.
- [x] Tab asset slots use shared workspace asset context.
- [x] Paint is registered as a paint component and does not own setup asset panels.
- [x] Queue proof and next READY task are clear.
