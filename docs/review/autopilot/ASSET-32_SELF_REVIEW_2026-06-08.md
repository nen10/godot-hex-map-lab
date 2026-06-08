# ASSET-32 Self Review 2026-06-08

Task: `ASSET-32_WIRE_REMAINING_ACTIONS_OR_DELETE`

## Acceptance Review

- Remaining visible actions are observable: COMPLETE. `Create New...` can be pressed through the workspace asset-panel route and creates/saves/selects the project resource in workspace context.
- Explicit sample action remains wired: COMPLETE. The sample action uses a named action path that selects the sample resource and emits `sample_requested`.
- Undefined actions deleted: COMPLETE. Settings sample row `Open` and `Duplicate To Project` buttons and unmanaged signals were removed from visible UI.
- Tests cover signal/button path: COMPLETE. Editor tests press the action route instead of only calling direct create/duplicate APIs.

## Implementation Review

- Added named asset-row actions and `press_action()` to `HexMapEditorAssetSlotControl`.
- Routed asset action presses through `HexMapWorkspaceAssetPanel` and `HexMapWorkspace`.
- Removed incomplete Settings sample row action buttons while preserving sample metadata and direct duplication helper.

## Test Review

- Added editor test coverage for workspace `Create New...` action press, explicit sample action press/signal, and absent Settings sample row action buttons.
- Updated `docs/TEST.md`.
- Ran `./tools/test.sh`: PASS.

## Repair-Now Audit

- Remaining `repair-now`: none.

## Sample-Only Audit

- Completion does not rely on bundled samples for production resource creation.
- Sample coverage is limited to explicit sample action behavior and Settings sample row visibility.

## Follow-Up

- `SAMPLE-40` is ready to reintroduce or keep removing Settings sample actions with a complete focus/duplicate workflow.
