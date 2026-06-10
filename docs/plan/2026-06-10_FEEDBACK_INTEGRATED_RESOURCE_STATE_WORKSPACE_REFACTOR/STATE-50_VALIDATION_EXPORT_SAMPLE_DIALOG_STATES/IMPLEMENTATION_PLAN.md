# STATE-50 Implementation Plan

## Scope

- Add explicit Validation, Export, Sample, and Dialog lifecycle state helpers.
- Surface lifecycle state and ViewState in Workspace snapshots.
- Keep current screen layout and controls stable.
- Update existing editor tests and `docs/TEST.md`.

## Target Files

- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_map_sample_settings_panel.gd`
- `addons/hex_map_kit/editor/hex_map_editor_path_selector.gd`
- new editor state helper scripts if needed
- `tests/test_editor_plugin.gd`
- `docs/TEST.md`

## Steps

1. Inspect existing Validate, Export, Sample, and Dialog snapshots/actions.
2. Add lifecycle state helper scripts and ViewState contracts.
3. Wire Workspace and sample settings snapshots to include state.
4. Extend existing editor tests for required transitions.
5. Run `./tools/test.sh` and repair failures.

## Test Path

- `./tools/test.sh`

## Completion Checklist

- [x] Validation state covers not run, running, clean, warning, error, issue selected, and focus applied.
- [x] Export state covers no destination, ready, exporting, exported, and failed.
- [x] Sample state covers off, learning available, duplicated to project, and explicit sample source selected.
- [x] Dialog state covers closed, opening, waiting user, committed, and cancelled.
- [x] Workspace snapshots expose lifecycle ViewStates.
- [x] Existing tests cover state transitions instead of private widget shapes.
- [x] Queue proof, self-review, and test result are updated.
