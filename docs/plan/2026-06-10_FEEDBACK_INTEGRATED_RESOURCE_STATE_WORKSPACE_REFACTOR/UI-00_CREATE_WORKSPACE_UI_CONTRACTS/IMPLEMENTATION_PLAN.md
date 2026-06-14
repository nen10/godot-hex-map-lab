# UI-00 Implementation Plan

## Scope

- Create UI contract documents required by the queue.
- Update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md` with UI-00 coverage.
- Update queue proof, self-review, and test result.

## Target Files

- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-00_CREATE_WORKSPACE_UI_CONTRACTS/WORKSPACE_SCREEN_CONTRACT.md`
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-00_CREATE_WORKSPACE_UI_CONTRACTS/WORKSPACE_STATE_MACHINE.md`
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-00_CREATE_WORKSPACE_UI_CONTRACTS/VISIBLE_CONTROL_INVENTORY.md`
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-00_CREATE_WORKSPACE_UI_CONTRACTS/RESOURCE_ROW_SPEC.md`
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/UI-00_CREATE_WORKSPACE_UI_CONTRACTS/DEBUG_LABEL_POLICY.md`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`

## Steps

1. Document global screen visibility rules and per-tab contracts.
2. Document root state / ViewState / dispatch contract for UI rendering.
3. Inventory current visible controls and assign keep/simplify/hide/move decisions.
4. Define Resource row compact/adaptive spec for UI-01.
5. Define debug label policy for normal UI, tooltip/detail, and debug report.
6. Run `./tools/test.sh`.
7. Update queue proof and review docs.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] `WORKSPACE_SCREEN_CONTRACT.md` separates always-visible, tooltip/detail, and debug-report content per tab.
- [x] `WORKSPACE_STATE_MACHINE.md` defines root/screen ViewState rendering boundaries.
- [x] `VISIBLE_CONTROL_INVENTORY.md` records keep/simplify/hide/move decisions.
- [x] `RESOURCE_ROW_SPEC.md` defines compact/adaptive row behavior and excludes filepath/debug normal text.
- [x] `DEBUG_LABEL_POLICY.md` defines where debug/path/internal state may appear.
- [x] Generate caution is explicitly documented.
- [x] `docs/TEST.md`, self-review, test result, and queue proof are updated.
