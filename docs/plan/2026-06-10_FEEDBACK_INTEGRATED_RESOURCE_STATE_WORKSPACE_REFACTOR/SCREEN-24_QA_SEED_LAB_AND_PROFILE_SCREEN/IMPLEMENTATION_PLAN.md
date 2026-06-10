# SCREEN-24 Implementation Plan

## Scope

- Add QA screen state fields for workflow ownership, Generation Profile use, score table, selected seed, promote target, Level Document source of truth, and draft boundary.
- Extend score table and Seed Lab context dictionaries to expose the same contract.
- Update editor tests and `docs/TEST.md`.

## Target Files

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`

## Steps

- [x] Mark `SCREEN-24` RUNNING and create plan docs.
- [x] Extend QA snapshot, score table context, and Seed Lab context.
- [x] Update QA editor test assertions for screen ownership and promotion boundary.
- [x] Update `docs/TEST.md`.
- [x] Run `./tools/test.sh`.
- [x] Write self-review and test-result docs.
- [x] Mark `SCREEN-24` COMPLETE, update pointer/dependencies, and commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] QA uses Generation Profile in the screen contract.
- [x] Score table, selected seed, and promote target are visible states.
- [x] Document source of truth and draft context boundary are explicit.
- [x] Promotion updates Resources Level Document context.
- [x] Sample-only success is not used as completion proof.
