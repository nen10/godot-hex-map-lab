# CAT-04 Policy

## Compatibility Rule

Numeric fallback fields remain valid for existing documents. Missing catalog resources or catalog keys should be reported as warnings, not hard failures, when a numeric fallback can still draw the document.

## Warning Rule

Warnings should be structured enough for tests and debug reports. They should identify default terrain fallback, missing per-entry catalog keys, unassigned catalog resources, and catalog keys missing from an assigned catalog.

## Repair Classification

- `repair-now`: existing v1/v2 document fallback display breaks, warnings are absent, or full test proof fails.
- `follow-up-ready`: full migration assistant from fallback numbers to catalog keys.
- `manual-optional`: visual inspection of warning copy in the editor dock.
