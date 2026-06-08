# ASSET-31 Policy

## Adoption

- Visible asset-row actions must have an implemented, observable effect.
- Resource selection and clearing are delegated to `EditorResourcePicker`.
- Validation belongs to Validate tab or slot status, not a per-row button.
- Create New and explicit sample application are the only normal asset-row actions retained in this task.

## Boundaries

- `HexMapEditorAssetSlotControl` owns visible row actions.
- `HexMapWorkspaceAssetPanel` continues to handle create path and ResourcePicker changes.
- Later wiring or deletion of any remaining action surface belongs to `ASSET-32`.

## Non-Adoption

- Do not add new buttons to compensate for removed buttons.
- Do not keep a button solely because a signal exists.
- Do not add analog tests during CLEAN UI work.

## Task-Local Decisions

- Programmatic clear/select/open/validate methods may remain if tests or future integration use them; the visible row removes redundant/no-op buttons.
