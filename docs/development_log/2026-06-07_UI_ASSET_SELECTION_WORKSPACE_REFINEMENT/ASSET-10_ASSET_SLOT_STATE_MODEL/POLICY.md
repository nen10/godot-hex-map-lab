# ASSET-10 Policy

## Adopted Decisions

- `HexMapEditorAssetSlotState` is the public state contract for slot tests and later screens.
- Status values are stable strings: `not_selected`, `selected`, `invalid`, and `warning`.
- Required type mismatch is state-model validation, not widget-specific behavior.
- Sample source fields are optional and do not mutate current selection until explicitly applied.
- `HexMapEditorAssetSlotControl` may render labels/buttons, but tests use `slot_state_snapshot()` and public methods.

## Rejected Decisions

- Do not make sample resources the initial current resource.
- Do not couple tests to `LineEdit`, `Button`, or `EditorResourcePicker` private node names.
- Do not migrate existing Paint/Generate screens in this task.

## Boundary

- This task creates the reusable slot state/control and tests the contract.
- Later tasks connect the control to workspace context and screen-specific selectors.
