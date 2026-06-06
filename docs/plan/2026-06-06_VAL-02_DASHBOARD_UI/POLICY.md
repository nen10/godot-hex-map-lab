# VAL-02 Policy

## State Boundary

Keep validation presentation state separate from document mutation. The Edit Dock may own context, target focus, and status messages, but row formatting and selected issue state should live in a small editor dashboard control.

## Rule Handling

Use stable `HexMapValidationResult` issue dictionaries from `HexMapDocumentValidator`. Do not special-case individual rule ids in the UI except for extracting common fields such as severity, scope, rule id, message, and cell.

## Repair Classification

- `repair-now`: validate button missing, grouped issue rows unavailable, selected cell-scoped issue not recorded/focused, or full test suite failure.
- `follow-up-ready`: richer filtering/sorting beyond accepted grouped rows.
- `manual-optional`: visual styling review of the dashboard layout.
