# CLEAN-20 Resource Selection UI Standard UX

## Goal

Document, import, catalog, object database, and label database selection should feel like resource selection, not path typing. Paths remain useful only as saved-location status or as FileDialog results.

## User Contract

- Normal document selection uses `EditorResourcePicker` when available, or `Browse` when a file dialog is needed.
- Importing a generated `HexMapResource` uses a resource picker or `Browse`; pressing `Import` imports the selected resource.
- `Save As` and export actions are the only workflows that ask the user to choose a destination path.
- Any visible path text is read-only status answering "Where is this saved?"
- Session state carries resource references first, plus optional saved paths for persistence continuity.

## Non-Goals

- CLEAN-21 will redesign the document header and dirty-state commands.
- CLEAN-22/CLEAN-23 will redesign catalog and object palette screens.
- CLEAN-33 will remove broader harmful controls such as numeric fallback tile payload UI.
