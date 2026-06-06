# VAL-04 Policy

## Fixture Policy

Use small fixtures that isolate one rule at a time. A passing fixture should prove the accepted, non-error version of the same rule condition, not merely validate an unrelated empty document.

## Test Scope

Prefer adapter-level tests for core validation rules. Editor-level tests can remain limited to UI/report integration because the validator itself is the rule source of truth.

## Repair Classification

- `repair-now`: missing fail/pass fixture for any accepted rule or full test suite failure.
- `follow-up-ready`: additional future validation rules beyond the accepted core list.
- `manual-optional`: none.
