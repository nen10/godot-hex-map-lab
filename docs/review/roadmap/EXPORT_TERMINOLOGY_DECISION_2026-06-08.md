# Export Terminology Decision

Date: 2026-06-08

## Decision

The editor `Export` tab uses **Runtime Handoff** as its active workflow. It writes the current `HexMapDocumentResource` into a runtime-oriented `HexMapResource` at a user-selected destination.

`Export` is not the generic name for every write operation in the editor. Authoring document saves, package builds, debug/support reports, and future external-format data exports have separate homes.

## Classification

| Term | Meaning | UI placement | Status |
|---|---|---|---|
| Save Document | Save the authoring `HexMapDocumentResource` and its project path. | Resources/document authoring actions. | Not Export. |
| Runtime Handoff | Create a runtime `HexMapResource` from the current Level Document. | Active `Export` tab workflow. | Current. |
| Data Export | JSON/CSV/external interchange format output. | Not active in the current Export tab. | Backlog. |
| Package Build | Build addon/distribution artifacts. | Developer process: `tools/package_addon.sh`, package manual, release checklist. | Process, not editor UI. |
| Debug Report | Copy compact support/debug state for bug reports. | Support/diagnostic action near Validate/Edit tools. | Diagnostic, not production Export. |

## Export Tab Contents

Current visible Export tab contents:

- Runtime Handoff purpose panel.
- Level Document and Export Profile resource rows.
- FileDialog-backed runtime handoff destination.
- Run action that writes a `HexMapResource`.

Not visible as Export tab actions:

- Save Document.
- Data Export JSON/CSV.
- Package Build.
- Debug Report.

## Manual Vocabulary

- Use `Runtime Handoff` when describing the editor `Export` tab output.
- Use `Save Document` or `save authoring document` for `HexMapDocumentResource` persistence.
- Use `runtime object export` only for script/API helper output from object placements; it is not the editor Export tab workflow.
- Use `Package Build` only for addon packaging process docs.
- Use `Debug Report` only for support/diagnostic copy actions.

## Test Contract

- `Export` screen snapshots identify the active output as `runtime_handoff_resource`.
- Visible Export output modes contain only `runtime_handoff_resource`.
- Save Document, Data Export, Package Build, and Debug Report remain classified but are not active visible Export tab actions.
