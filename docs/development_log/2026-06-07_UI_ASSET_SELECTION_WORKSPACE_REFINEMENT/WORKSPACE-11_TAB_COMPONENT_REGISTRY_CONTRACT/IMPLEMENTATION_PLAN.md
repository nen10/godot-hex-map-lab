# WORKSPACE-11 Implementation Plan

## Scope

Expose stable workspace tab component ids and tab asset slot ids through public-ish query methods.

## Files

- `addons/hex_map_kit/editor/hex_map_workspace_component_registry.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `WORKSPACE-11` `RUNNING`.
2. Update component registry rows to reflect actual mounted tab components.
3. Add registry helpers for component ids and asset slot ids by tab.
4. Add workspace `tab_component_ids()` / registry-aligned query behavior.
5. Mount a validation issue navigator component id for the Validate tab.
6. Update headless tests to assert registry contract.
7. Update `docs/TEST.md`.
8. Run `./tools/test.sh`.
9. Self-review, repair, update queue proof, unlock dependencies, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] `workspace.tab_component_ids("Catalog")` includes `catalog_asset_panel`.
- [x] `workspace.tab_component_ids("Validate")` includes `validation_issue_navigator`.
- [x] `workspace.tab_asset_slot_ids("Catalog")` includes `tile_catalog`.
- [x] `workspace.tab_asset_slot_ids("QA")` includes `generation_profile`.
- [x] Tests avoid private child node names.
- [x] Queue proof and next READY task are clear.
