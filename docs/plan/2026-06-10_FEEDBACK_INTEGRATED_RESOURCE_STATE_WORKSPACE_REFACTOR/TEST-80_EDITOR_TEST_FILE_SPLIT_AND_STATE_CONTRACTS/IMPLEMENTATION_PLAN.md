# TEST-80 Implementation Plan

## Scope

- Add focused state/screen contract test files.
- Register the new test files in `tools/test.sh`.
- Remove or replace duplicated old UI shape assertions in `tests/test_editor_plugin.gd`.
- Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
- Run `./tools/test.sh` and write proof docs.

## Target Files

- `tests/test_workspace_state_transitions.gd`
- `tests/test_generation_run_state.gd`
- `tests/test_paint_interaction_state.gd`
- `tests/test_asset_slot_state.gd`
- `tests/test_workspace_screen_contracts.gd`
- `tests/test_editor_plugin.gd`
- `tools/test.sh`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/review/autopilot/TEST-80_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/TEST-80_TEST_RESULT_2026-06-10.md`
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`

## Steps

- [x] Mark `TEST-80` RUNNING and create plan docs.
- [x] Add focused state/contract test scripts.
- [x] Register split scripts in `tools/test.sh`.
- [x] Remove/replace duplicated private widget-shape assertions.
- [x] Update `docs/TEST.md` only if execution instructions changed; otherwise update `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
- [x] Run `./tools/test.sh`.
- [x] Write self-review and test-result docs.
- [x] Mark `TEST-80` COMPLETE, update pointer/dependencies, and commit.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] State transition coverage is split out.
- [x] Hydration/writeback coverage is split out.
- [x] Screen contract coverage is split out.
- [x] Old UI shape assertions are removed or replaced where the new contracts cover them.
- [x] No analog test is added.
