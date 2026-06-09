# SCREEN-26 Implementation Plan

## Scope

Add QA screen project asset actions, preset duplicate-to-project actions, and score-table context that names the selected profile/suite.

## Files

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-07_UI_ASSET_SELECTION_WORKSPACE_REFINEMENT/IMPLEMENTATION_QUEUE.md`

## Steps

1. Mark `SCREEN-26` `RUNNING`.
2. Add QA screen snapshot and score table context helpers.
3. Add create / open / save as / clear actions for Generation Profile.
4. Add create / open / save as / clear actions for Validation Rule Suite.
5. Add duplicate preset actions for project profile/suite resources.
6. Add headless tests for custom assets, duplicated presets, and score table context.
7. Update `docs/TEST.md`.
8. Run `./tools/test.sh`.
9. Self-review, repair, update queue proof, unlock dependencies, then commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Custom Generation Profile can be created and selected.
- [x] Custom Validation Rule Suite can be created and selected.
- [x] Built-in Generation Profile preset can be duplicated to project asset.
- [x] Built-in Validation Rule Suite preset can be duplicated to project asset.
- [x] Score table context displays selected profile and validation suite.
- [x] Sample assets are not used as QA completion proof.
- [x] Queue proof and next READY task are clear.
