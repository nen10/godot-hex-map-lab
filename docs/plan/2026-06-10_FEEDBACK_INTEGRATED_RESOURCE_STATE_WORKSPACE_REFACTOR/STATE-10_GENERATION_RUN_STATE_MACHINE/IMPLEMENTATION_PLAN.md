# STATE-10 Implementation Plan

## Scope

- Add an explicit Generate run state helper.
- Wire `HexMapGenDock` progress/cancel/debounce/apply/block/failure status into that helper.
- Expose a Generate run ViewState snapshot and render controls from it.
- Update editor tests and `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.

## Target Files

- `addons/hex_map_kit/editor/hex_map_generation_run_state.gd`
- `addons/hex_map_kit/editor/hex_map_gen_dock.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change

## Steps

1. Create `HexMapGenerationRunState` with state ids and ViewState output.
2. Synchronize existing Generate run fields through the state helper.
3. Update Generate snapshots/control refresh to consume run ViewState.
4. Extend tests for queued tile settings, generating/cancel, apply, failed/block state, and orientation state.
5. Run `./tools/test.sh` and repair failures.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Progress / cancel / debounce / apply / dirty/failure state is visible from one run state.
- [x] Generate tab controls render from state -> ViewState.
- [x] Orientation/tile setting updates enter the run state.
- [x] Tests cover the state snapshot contract.
- [x] Queue proof, self-review, and test result are updated.
