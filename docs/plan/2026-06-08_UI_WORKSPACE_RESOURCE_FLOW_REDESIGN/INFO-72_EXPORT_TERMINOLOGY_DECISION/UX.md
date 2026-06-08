# INFO-72 Export Terminology Decision UX

Date: 2026-06-08

## User goal

A game developer should understand that the `Export` tab currently creates a runtime handoff resource from the current Level Document, not that it saves authoring documents, builds addon packages, or produces support/debug reports.

## Flow

1. Open `Export`.
2. Read the active output as `Runtime Handoff Resource`.
3. Select a Level Document and explicit destination.
4. Run the handoff.

## Visible contract

- Active Export tab output is Runtime Handoff only.
- Save Document stays in Resources/document authoring flows.
- Package Build stays in developer packaging process.
- Debug Report stays support/diagnostic, outside production Export.
- Data Export is a backlog term, not an active visible button.
