# Workspace State Machine Contract

## Rendering Boundary

Workspace UI rendering consumes ViewState:

```text
Editor/session/resource changes
  -> workflow state models
  -> screen snapshots
  -> HexMapWorkspaceRootState
  -> root/screen ViewState
  -> tab rendering
```

Screens do not directly combine private booleans, path strings, or widget state. If a screen needs a condition, that condition belongs in the relevant state model or synthesized screen ViewState.

## State Sources

| area | state source | UI contract |
|---|---|---|
| Root/tab dispatch | `HexMapWorkspaceRootState`, `HexMapWorkspaceDispatcher` | current tab, per-screen ViewState, root debug report, event envelope |
| Generate | `HexMapGenerationRunState` | run/progress/cancel/block/apply/dirty status |
| Resource rows | `HexMapEditorAssetSlotState` | slot definition, selection, validation, source, operation result |
| Workspace binding | `HexMapWorkspaceBindingService` | selected node, hydration, manual override, writeback/conflict |
| Paint | `HexMapPaintInteractionState` | target/document/brush/cell/last edit/validation focus |
| Validate | `HexMapValidationWorkflowState` | not run/running/clean/warning/error/focus state |
| Export | `HexMapExportWorkflowState` | destination/source/ready/exporting/exported/failed state |
| Sample learning | `HexMapSampleLearningState` | off/learning/sample-source/duplicated state |
| Dialogs | `HexMapDialogLifecycleState` | closed/opening/waiting/committed/cancelled lifecycle |

## Root Events

Root dispatch may route only named user/workflow events. It must return a stateful envelope containing `ok`, `error`, `event_id`, `payload`, `result`, `root_state`, and `view_state`.

Current root events:

- `select_tab`
- `run_validation`
- `select_validation_issue`
- `select_export_destination`
- `clear_export_destination`
- `open_sample_learning`
- `dismiss_sample_learning`

New root events require a visible workflow reason and should not be added merely to expose private helper calls.

## Screen ViewState Contract

Every screen ViewState should provide:

- `state_source`
- `state_id`
- `active_state_ids` when available
- `status_text` or equivalent short user-facing state
- `tab`
- `purpose_text`
- `component_ids`
- `asset_slot_ids`

Path, node path, raw state payload, raw JSON, and debug ids may appear in snapshots but not in normal visible text.

## Test Contract

Automated tests should assert:

- state transitions,
- ViewState source and state id,
- enabled/disabled reason through ViewState,
- project asset selection or explicit missing/validation state,
- no sample-only production completion.

Automated tests should not assert:

- private container shape,
- exact debug label strings as normal UI,
- old Details/no-op button presence,
- raw path text as a visible first-impression requirement.
