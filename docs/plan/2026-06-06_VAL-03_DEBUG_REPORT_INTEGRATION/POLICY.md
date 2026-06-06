# VAL-03 Policy

## Report Scope

Validation debug report output should be structured enough for support/debugging but compact enough to avoid replacing the dashboard UI. Use summary counts and short grouped row text rather than dumping full serialized issue dictionaries into normal labels.

## Generate Dock Input

The Generate Dock validation summary may validate a generated `HexMapDocumentResource` converted from the current `HexMapData`. Overlay-specific validation can be added later with generation QA tasks.

## Repair Classification

- `repair-now`: debug report missing validation summary, normal status bloated by issue rows, or full test suite failure.
- `follow-up-ready`: generated overlay validation beyond current map summary.
- `manual-optional`: none.
