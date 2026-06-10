# UI-02 Implementation Plan

## Scope

- Simplify Settings visible labels in Workspace and Sample Settings.
- Preserve CheckBox controls, sample duplicate action, and snapshots.
- Update tests and `docs/TEST.md`.
- Update queue proof, self-review, and test result.

## Target Files

- `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`

## Steps

1. Change sample row visible labels to names only and move sample paths to tooltips/snapshots.
2. Change sample duplicate status to outcome text and move output path to tooltip/snapshot.
3. Hide redundant Workspace debug enabled/disabled label.
4. Expose layout/snapshot fields that prove boolean/path/debug text is not normal UI.
5. Update editor tests.
6. Run `./tools/test.sh`.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Settings booleans are represented by CheckBoxes, not redundant visible labels.
- [x] Sample asset paths are not visible row text.
- [x] Duplicate result path is tooltip/snapshot detail, not visible status text.
- [x] Debug enabled/disabled label is hidden from normal Settings UI.
- [x] Tests cover Settings simplification.
- [x] Queue proof, self-review, and test result are updated.
