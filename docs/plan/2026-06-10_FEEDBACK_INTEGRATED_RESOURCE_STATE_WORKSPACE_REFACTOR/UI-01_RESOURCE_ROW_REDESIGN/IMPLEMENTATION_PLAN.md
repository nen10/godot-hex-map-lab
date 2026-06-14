# UI-01 Implementation Plan

## Scope

- Update Resource row layout in `HexMapEditorAssetSlotControl`.
- Keep state/picker/action behavior stable.
- Update editor tests and `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`.
- Update queue proof, self-review, and test result.

## Target Files

- `addons/hex_map_kit/editor/hex_map_editor_asset_slot_control.gd`
- `tests/test_editor_plugin.gd`
- `docs/development_log/2026-06-14_TEST_CREATION_LOG.md`
- `docs/TEST.md` if execution instructions change
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`

## Steps

1. Add an adaptive two-line Resource row layout with header and input rows.
2. Replace visible status words with a status swatch driven by `status_icon` / `status_kind`.
3. Keep status prose/path/type/source in tooltip/detail layout snapshots.
4. Update layout snapshots to expose adaptive row and status-swatch state.
5. Update existing editor tests to assert the new contract.
6. Run `./tools/test.sh` and repair failures.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Resource row uses stable adaptive two-line layout.
- [x] Visible status words are removed from normal row text.
- [x] Status swatch/icon is present and tooltip carries detail.
- [x] Filepath/source/type/debug detail stays out of visible row text.
- [x] Details button remains absent.
- [x] Tests cover the new row contract.
- [x] Queue proof, self-review, and test result are updated.
