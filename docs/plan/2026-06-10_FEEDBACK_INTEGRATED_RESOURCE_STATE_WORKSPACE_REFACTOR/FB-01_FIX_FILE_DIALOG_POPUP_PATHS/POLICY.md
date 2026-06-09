# FB-01 Policy

## Adopted Decisions

- `HexMapEditorPathSelector` owns popup attach behavior for editor FileDialogs.
- Feature code owns dialog configuration and commit callbacks.
- `popup_dialog()` must not blindly reparent or double-add an already parented dialog.
- Headless tests should inspect lifecycle contract and callback results, not real popup visibility.

## Rejected Decisions

- Do not let Workspace or Dist editor pre-parent dialogs before calling the helper.
- Do not introduce a broad DialogState state machine in this safety repair task.
- Do not keep duplicate direct `EditorInterface.get_base_control().add_child(dialog)` paths.

## Breaking Change Rationale

This is not a product API break. It is an editor lifecycle cleanup. If any internal caller relied on the previous parent path, that reliance is implementation detail and should yield to the central lifecycle contract.

## Resource / API / UI Boundary

- Resource/API: unchanged.
- UI: FileDialog popup lifecycle becomes centralized.
- Tests: verify helper-level lifecycle and feature callback contract.

## Task-Local Decisions

- Dist editor is included because it is explicitly listed in the roadmap target files and currently has direct base-control attach paths.
- Generate Dock and Edit Tool already use the helper and are outside the explicit target list, so they are not modified unless needed by tests.
