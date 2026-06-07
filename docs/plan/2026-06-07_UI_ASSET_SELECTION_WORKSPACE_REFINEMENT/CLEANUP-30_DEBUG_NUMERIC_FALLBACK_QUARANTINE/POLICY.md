# CLEANUP-30 Policy

## Rules

- `debug_numeric_fallback_enabled` must not be inferred from empty catalog keys.
- Normal document apply to plain `TileMapLayer` should pass `debug_numeric_fallback_enabled = false`.
- Debug fallback may use existing numeric source/atlas options only when the session setting is explicitly enabled.
- Tests must cover both default OFF behavior and explicit debug ON behavior.
- Missing catalog assignment remains a validation issue.

## Acceptance Mapping

- Normal apply path: plain target apply with no catalog leaves cells unfilled.
- Debug opt-in: Settings toggles numeric fallback and then plain target apply can use numeric tile settings.
- Validation: existing document validator still reports missing catalog assignment.
