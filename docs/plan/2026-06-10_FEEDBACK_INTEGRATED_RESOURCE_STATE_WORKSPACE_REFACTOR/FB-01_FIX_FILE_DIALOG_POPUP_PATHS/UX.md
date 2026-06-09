# FB-01 UX

## User Goal

When a developer chooses a file or folder from Workspace, AssetSlot, Sample settings, or Distribution editor flows, the dialog should open through one predictable lifecycle. The button should either open a real FileDialog or report unavailable; it should not silently create duplicate parent paths or rely on a no-op dialog path.

## Operation Steps

1. User presses an action that needs a project file/folder.
2. The feature creates the relevant `EditorFileDialog` with file mode, access, filters, default file, and selected callback.
3. The feature calls a single lifecycle helper to attach and popup the dialog.
4. The helper attaches only if the dialog has no parent.
5. The selected callback commits the chosen path to the feature state.
6. In headless tests, handlers or lifecycle snapshots are inspected without requiring popup UI.

## Adopted UX

- File/folder selection is project resource selection, not editable path text.
- Button results can report `dialog_opened` / `ERR_UNAVAILABLE` when popup is not available.
- Existing commit callbacks remain direct and testable.

## Retained UX

- AssetSlot `Create New...`, Sample `Duplicate To Project`, Workspace Export destination, Missing Unique Resources directory, and Dist load/save still use Godot `EditorFileDialog`.
- Tests may call selected handlers directly for deterministic path commit checks.

## Removed Or Deferred UX

- Caller-side `add_child(dialog)` before helper popup is removed.
- Full DialogState UI is deferred to `STATE-50`.
- No analog test is added.

## Existing UX Interference

Any older behavior that depends on a dialog being parented to the workspace or dist window directly is not a user-facing requirement. The user-facing requirement is a predictable popup lifecycle and callback path.
