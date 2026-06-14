# SCREEN-25 Implementation Plan

## Scope

Add Validate screen snapshots and workspace-level validation issues for missing project assets with owner-tab routes.

## Files

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `SCREEN-25` `RUNNING`.
2. Add Validate screen snapshot in `HexMapWorkspace`.
3. Add workspace asset validation that emits routed missing-asset issues.
4. Merge document validator issues when a Level Document is selected.
5. Add headless tests for missing asset issue routes and sample non-injection.
6. Update `docs/TEST.md`.
7. Run `./tools/test.sh`.
8. Self-review, repair, update queue proof, unlock dependencies, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Validate screen reports selected context assets.
- [x] Missing Level Document routes to Document tab.
- [x] Missing Tile Catalog routes to Catalog tab.
- [x] Missing Object / Label databases route to Object/Label panel.
- [x] Missing Layer Stack routes to Layers tab.
- [x] Missing QA-owned Generation Profile routes to QA tab.
- [x] Missing assets do not trigger sample fallback.
- [x] Queue proof and next READY task are clear.
