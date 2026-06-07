# CLEAN-26 Policy

## Decisions

- Domain grouping is a display concern in `HexMapValidationDashboard`; validation result scope remains the canonical machine contract.
- Fix suggestions are deterministic text derived from `rule_id`, scope, and metadata. They are guidance, not automatic mutation.
- Catalog validation results may be displayed in the same dashboard so a catalog issue row can be selected and focused without a separate debug-only path.
- Debug detail remains in `Copy Debug Report`; visible status labels do not dump raw issue arrays.

## Verification

- Headless editor tests should inspect dashboard rows, selection detail, cell focus, catalog focus metadata, and debug report behavior.
