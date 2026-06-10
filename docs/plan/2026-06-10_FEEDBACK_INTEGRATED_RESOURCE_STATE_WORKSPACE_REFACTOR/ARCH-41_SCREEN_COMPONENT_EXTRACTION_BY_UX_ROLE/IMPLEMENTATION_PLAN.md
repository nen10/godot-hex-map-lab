# ARCH-41 Implementation Plan

## Scope

- Add screen role scripts for Resources, Catalog, Layers, Validate, QA, Export, and Paint.
- Preload and use role contracts in Workspace snapshots.
- Use Paint role contract from EditTool for delegated non-paint ownership.
- Add tests and `docs/TEST.md` coverage.

## Target Files

- `addons/hex_map_kit/editor/hex_map_*_screen.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_edit_tool.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`

## Steps

- [x] Mark `ARCH-41` RUNNING and create plan docs.
- [x] Add per-screen role scripts.
- [x] Wire Workspace/EditTool snapshots to role contracts.
- [x] Update tests for screen script mapping and Paint delegation.
- [x] Update `docs/TEST.md`.
- [x] Run `./tools/test.sh`.
- [x] Write self-review and test-result docs.
- [x] Mark `ARCH-41` COMPLETE, update pointer/dependencies, and commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Extraction is justified by user task ownership.
- [x] Each screen script maps to a tab/workflow.
- [x] Paint delegates Catalog/Layer/Export/Document responsibility.
- [x] Existing Paint/Catalog/Layers/Validate/QA/Export behavior remains intact.
