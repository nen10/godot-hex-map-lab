# FB-01 Implementation Plan

## Scope

- Strengthen `HexMapEditorPathSelector` as the single FileDialog popup lifecycle helper.
- Remove caller-side pre-`add_child()` from Workspace popup paths.
- Convert Dist editor load/save dialogs to helper-created and helper-popped dialogs.
- Add headless tests for lifecycle contract and target call sites.
- Run `./tools/test.sh`, self-review, queue update, and commit.

## Change Targets

- `addons/hex_map_kit/editor/hex_map_editor_path_selector.gd`
- `addons/hex_map_kit/editor/hex_map_workspace.gd`
- `addons/hex_map_kit/editor/hex_dist_editor.gd`
- `tests/test_editor_plugin.gd`
- `docs/plan/2026-06-10_FEEDBACK_INTEGRATED_RESOURCE_STATE_WORKSPACE_REFACTOR/IMPLEMENTATION_QUEUE.md`
- `docs/review/autopilot/FB-01_SELF_REVIEW_2026-06-10.md`
- `docs/review/autopilot/FB-01_TEST_RESULT_2026-06-10.md`

## Steps

1. Add a lifecycle snapshot / attach helper in `HexMapEditorPathSelector`.
2. Make `popup_dialog()` attach only when the dialog has no parent.
3. Remove `add_child(dialog)` from Workspace export and missing-resource directory popups.
4. Update Dist editor to preload `HexMapEditorPathSelector`, build dialogs through `new_dialog()`, and popup through `popup_dialog()`.
5. Add editor headless tests for helper lifecycle and Dist dialog configuration / callback path.
6. Run `./tools/test.sh`.
7. Write self-review and test result.
8. Mark `FB-01` complete and update current pointer.

## Deferred Steps

- Do not add full DialogState reducer.
- Do not redesign FileDialog UI copy.
- Do not create analog tests.

## Test Path

```sh
./tools/test.sh
```

## Docs Update

No global docs update is expected. The task-specific plan, review, test result, and queue proof are the documentation deliverables.

## Completion Checklist

- `popup_dialog()` is the only popup attach path in target files.
- No target call site adds a dialog before calling `popup_dialog()`.
- Dialog commit/cancel remains callback-based and testable.
- Tests cover helper lifecycle without real popup interaction.
