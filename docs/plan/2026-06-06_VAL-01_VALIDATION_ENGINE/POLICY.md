# VAL-01 Policy

## Validation Schema

Use `HexMapValidationResult` for all core validation output. Each rule should provide a stable `rule_id`, severity, scope, and details such as cell, object id, dependency path, or catalog key metadata.

## Rule Severity

The initial engine reports the accepted core rules as errors because they indicate document content that cannot be trusted without repair or explicit fallback handling.

## Repair Classification

- `repair-now`: missing accepted rule, non-serializable result, or full suite failure.
- `follow-up-ready`: additional rule categories beyond the accepted core list.
- `manual-optional`: none; this is headless-testable adapter logic.
