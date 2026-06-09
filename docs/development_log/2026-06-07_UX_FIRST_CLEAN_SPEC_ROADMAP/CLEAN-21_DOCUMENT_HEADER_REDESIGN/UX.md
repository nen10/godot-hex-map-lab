# CLEAN-21 Document Header Redesign UX

## Goal

Document operations should read as document state and commands, not as path editing. The first document controls in Hex Map Edit should be:

```text
[New Document] [Open...] [Save] [Save As...] [Validate]
Document: selected   Saved: res://maps/map.tres   Dirty: no
Validation: 0 errors / 0 warnings
```

## User Contract

- `New Document` creates a canonical empty `HexMapDocumentResource`.
- `Open...` uses FileDialog, while `EditorResourcePicker` remains a resource selection input when available.
- `Save` saves to the current saved path when one exists, otherwise it falls through to `Save As...`.
- `Save As...` always opens FileDialog.
- Importing `HexMapResource` is an advanced conversion workflow, not the primary document header.
- Exporting `HexMapResource` is an explicit export action, not a document save fallback.
- UI text must not mention `v2` or `migration`.

## Non-Goals

- CLEAN-22 owns the full catalog screen.
- CLEAN-23 owns the full object palette.
- CLEAN-33 owns deletion of broader harmful UI paths.
