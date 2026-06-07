# VAL-02 UX

## User Outcome

The Edit Dock should let authors validate the current document without leaving the editor. The result should be grouped enough to scan quickly and precise enough to select a cell-scoped issue for follow-up editing.

## Validation Panel

- A Validate command runs the document validation engine on the current document.
- The summary shows total issues and severity counts.
- The issue list groups rows by severity, scope, and rule id while keeping each row readable.
- Selecting a cell-scoped row records the selected issue and focuses the corresponding document cell in a headless-testable way.

## Non-Goals

- Copy Debug Report validation summary is deferred to `VAL-03`.
- Exhaustive rule matrix fixtures are deferred to `VAL-04`.
