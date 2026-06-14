# ARCH-40 Implementation Plan

## Scope

- Extend `HexMapWorkspaceBindingService` with service-owned writeback snapshot, slot writeback, shared dependency sync, and hydration snapshot helpers.
- Replace Workspace relationship/writeback orchestration with service calls.
- Add headless assertions proving hydration/writeback service ownership.
- Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.

## Target Files

- `addons/hex_map_kit/editor/hex_map_workspace_binding_service.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`

## Steps

- [x] Mark `ARCH-40` RUNNING and create plan docs.
- [x] Add service helpers for hydration/writeback orchestration.
- [x] Replace Workspace-local relationship/writeback assembly with service calls.
- [x] Update tests for service source and broad dependency writeback coverage.
- [x] Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
- [x] Run `./tools/test.sh`.
- [x] Write self-review and test-result docs.
- [x] Mark `ARCH-40` COMPLETE, update pointer/dependencies, and commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Workspace no longer directly assembles writeback relationship state.
- [x] Shared dependency writeback loop lives in the service.
- [x] Hydration/writeback service source is testable.
- [x] Existing selection/resource UX remains intact.
